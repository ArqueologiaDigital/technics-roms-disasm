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
Voice_Calc_LevelPair_PatchAtk:
	lda xsp, (xsp - 14)
	push xiz
	ld (xsp + 14), xwa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 23)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 31)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 14)
	ld xbc, (xwa + 35)
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 19)
	bitm 4, (xwa + 16)
	jr z, Voice_Calc_LevelPair_PatchAtk_SetInvFlag
	ld xwa, (xsp + 14)
	andmi16 (xwa + 1), 0x7FFF
	jr Voice_Calc_LevelPair_PatchAtk_ApplyKeyTrack

; Sets the "inverted" flag in the local frame when the patch record asks for the reversed
; curve.
Voice_Calc_LevelPair_PatchAtk_SetInvFlag:
	ld xwa, (xsp + 14)
	ormi16 (xwa + 1), 0x8000

; Segment 0's TARGET index: (i8)tonerec[0x6B] + paramA+0x27, clamped 0..0x64, then curved
; through Voice_LevelPair_AttackCurve (0x011899) into IZ. It is a plain signed ADD of the
; tone record's byte 0x6B -- there is no PitchBend_Scale and no 0..0xFF clamp at this point.
; The PitchBend_Scale key-scale term (depth paramA+0x2E, note slot+0x0C, shift 4) comes
; later, after the curve lookup, in this routine's own fall-through tail and in _NoOscLFO's
; paramA+0x2E-non-zero branch; _NoLFO is the arm that SKIPS it. The 0..0xFF clamp is applied
; on the fall-through tail, in _NoLFO and in _NoOscLFO's non-zero branch alike.
; NO RENAME PROPOSED -- _ApplyKeyTrack is a `jr` branch target and is also listed in
; symbols/subcpu_symbols_reference.txt, so only the comment is corrected here.
Voice_Calc_LevelPair_PatchAtk_ApplyKeyTrack:
	ld a, (xbc + 107)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 39)
	extz wa
	add wa, bc
	ldw bc, 0x64
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	ldto_berp A, 0xF8
	extz wa
	lda xbc, (Voice_LevelPair_AttackCurve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 4)
	cp (xwa + 51), 0x0
	jr z, Voice_Calc_LevelPair_PatchAtk_NoOscLFO
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
	jr z, Voice_Calc_LevelPair_PatchAtk_NoLFO
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
	ldfr_werp HL, 0xFA
	ld wa, iz
	add wa, (xsp + 8)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_PatchAtk_CheckMax

; Arm taken when the LFO depth is zero.
Voice_Calc_LevelPair_PatchAtk_NoLFO:
	ld wa, iz
	add wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_PatchAtk_CheckMax

; Arm taken when the oscillator LFO depth is zero.
Voice_Calc_LevelPair_PatchAtk_NoOscLFO:
	ld xwa, (xsp + 4)
	cp (xwa + 46), 0x0
	jr z, Voice_Calc_LevelPair_PatchAtk_CheckMax
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
	ldfr_werp HL, 0xFA
	ld wa, iz
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl

; If bit 0 of the flag word is set and the accumulator is exactly 0xFF, decrement it -- the
; firmware refuses to emit the 0xFF "hard mute" level on this path.
Voice_Calc_LevelPair_PatchAtk_CheckMax:
	ld xwa, (xsp + 10)
	bitm 0, (xwa)
	jr z, Voice_Calc_LevelPair_PatchAtk_WriteDSP
	ld wa, iz
	cp wa, 0xFF
	jr nz, Voice_Calc_LevelPair_PatchAtk_WriteDSP
	dec 1, iz

; Packs (level << 8) | table[0x011963 + tonerec+40] and stores it to 0x0451E4 (TG reg 0x800,
; the main volume register) AND caches it in voice+60. Then continues into the per-channel
; L/R words.
Voice_Calc_LevelPair_PatchAtk_WriteDSP:
	ld xwa, (xsp + 4)
	ld a, (xwa + 40)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld w, 0x0:opc
	ld bc, iz
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x636e:24), bc
	ld xwa, (xsp + 14)
	ld (xwa + 60), bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 41)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa
	ld xwa, (xsp + 4)
	ld a, (xwa + 43)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 12), wa
	ld xwa, (xsp + 4)
	cp (xwa + 52), 0x0
	jrl z, Voice_Calc_LevelPair_PatchAtk_NoDepth2
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
	jr z, Voice_Calc_LevelPair_PatchAtk_NoModDepth
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
	ldfr_werp HL, 0xFA
	ld wa, (xsp + 10)
	add wa, (xsp + 8)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	add wa, (xsp + 8)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	jr Voice_Calc_LevelPair_PatchAtk_WriteChans

; No-modulation arm of the per-channel level computation.
Voice_Calc_LevelPair_PatchAtk_NoModDepth:
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
	jr Voice_Calc_LevelPair_PatchAtk_WriteChans

; Second no-depth arm.
Voice_Calc_LevelPair_PatchAtk_NoDepth2:
	ld xwa, (xsp + 4)
	cp (xwa + 47), 0x0
	jr z, Voice_Calc_LevelPair_PatchAtk_WriteChans
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
	ldfr_werp HL, 0xFA
	ld wa, (xsp + 10)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl

; Falls through into the per-channel writer that fills 0x0451E6 / 0x0451E8 (TG regs 0x840 /
; 0x880).
Voice_Calc_LevelPair_PatchAtk_WriteChans:
	ld xwa, (xsp + 4)
	ld a, (xwa + 42)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld hl, wa
	ld wa, 4:i3
	cp hl, 4:i3
	jr lt, Voice_Calc_LevelPair_PatchAtk_ClampDepth
	ld wa, hl

; NOT a modulation depth -- this is segment 1's rate field, floored at 4.
; Voice_EnvelopeRate_Table has exactly one entry below 4 (entry 0 = 0x00), so the floor's
; sole effect is to turn a rate of 0 into 4. Segments 0 and 2 are left free to use 0.
; [INFERENCE] the staging-block header reads that asymmetry as "rate 0 means arrive
; immediately, and segment 1 is the one segment where an instant jump would be audible";
; neither the chip behaviour nor the claim that segment 1 is a decay is measured here.
; NO RENAME PROPOSED -- _ClampDepth is a `jr lt` branch target and is also listed in
; symbols/subcpu_symbols_reference.txt, so only the comment is corrected here.
Voice_Calc_LevelPair_PatchAtk_ClampDepth:
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
	ld xwa, (xsp + 14)
	ld (xwa + 62), bc
	ld wa, de
	ld w, 0x0:opc
	ld bc, (xsp + 12)
	sla bc, 8
	or bc, wa
	ld xwa, (xsp + 14)
	ld (xwa + 64), bc
	pop xiz
	lda xsp, (xsp + 14)
	ret

; Emits the per-channel L/R level pair. In: XWA (frame (xsp+6)) = per-voice record.
; Left value starts from (patchrec+32) added to (voice+62 & 0x7F); right value from the same
; signed byte added to (voice+64 & 0x7F). Both clamped (right to 0..0x7F, left to 4..0x7F),
; merged into the cached words voice+62 / voice+64 keeping their high bytes, and stored to
; 0x0451E6 (TG reg 0x840) and 0x0451E8 (TG reg 0x880).
; If the "channel" flag in the frame is set, the right word gets bit 15 forced instead of
; the cached high byte.
Voice_WriteChPanShift:
	dec 8, xsp
	pushw iz
	ld (xsp + 4), c
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 39)
	ld wa, (xwa + 24)
	bit 8, wa
	jrl z, Voice_WriteChPanShift_Passthrough
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	and wa, 0xFF
	jrl z, Voice_WriteChPanShift_Passthrough
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 39)
	ld wa, (xwa + 24)
	bit 9, wa
	jr z, Voice_WriteChPanShift_AddShift
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	and wa, 0x7F
	ld (xsp + 2), wa
	sub (xsp + 2), bc
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	and wa, 0x7F
	ld iz, wa
	sub iz, bc
	jr Voice_WriteChPanShift_ClampAndWrite

; Adds the signed shift byte to both 7-bit channel fields.
Voice_WriteChPanShift_AddShift:
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	and wa, 0x7F
	ld (xsp + 2), wa
	add (xsp + 2), bc
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	and wa, 0x7F
	ld iz, wa
	add iz, bc

; Clamps both fields via Int_ClampSignedToRange and branches on the channel flag.
Voice_WriteChPanShift_ClampAndWrite:
	ld wa, (xsp + 2)
	ldw bc, 0x7F
	ld de, 4:i3
	calr Int_ClampSignedToRange
	ld (xsp + 2), hl
	ld wa, iz
	ldw bc, 0x7F
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	cp (xsp + 4), 0x0
	jr z, Voice_WriteChPanShift_NoChanFlag
	ld wa, iz
	set 15, wa
	ld (Payload_Bss_Start+0x6372:24), wa
	jr Voice_WriteChPanShift_WriteL

; Channel flag clear: merge the right field under the cached voice+64 high byte before
; storing to 0x0451E8.
Voice_WriteChPanShift_NoChanFlag:
	ld wa, iz
	ld w, 0x0:opc
	ld bc, wa
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	ld a, 0x0:opc
	or wa, bc
	ld (Payload_Bss_Start+0x6372:24), wa

; Merge and store the left field to 0x0451E6 (TG reg 0x840).
Voice_WriteChPanShift_WriteL:
	ld wa, (xsp + 2)
	ld w, 0x0:opc
	ld bc, wa
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	ld a, 0x0:opc
	or wa, bc
	ld (Payload_Bss_Start+0x6370:24), wa
	jr Voice_WriteChPanShift_Done

; No-shift path: copy the cached voice+62 / voice+64 words verbatim to 0x0451E6 / 0x0451E8.
Voice_WriteChPanShift_Passthrough:
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	ld (Payload_Bss_Start+0x6370:24), wa
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	ld (Payload_Bss_Start+0x6372:24), wa

; popw IZ, inc 8 xsp, ret.
Voice_WriteChPanShift_Done:
	popw iz
	inc 8, xsp
	ret

Voice_Calc_LevelPair_FixedAtk:
	lda xsp, (xsp - 12)
	pushw iz
	ld (xsp + 10), xwa
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 19)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 23)
	ld (xsp + 6), xwa
	ld xwa, (xsp + 10)
	ormi16 (xwa + 1), 0x8000
	ld xwa, (xsp + 6)
	ld a, (xwa + 8)
	extz wa
	lda xbc, (Voice_LevelPair_AttackCurve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 6)
	cp (xwa + 14), 0x0
	jr z, Voice_Calc_LevelPair_FixedAtk_WriteLevel
	ld xwa, (xsp + 6)
	ld a, (xwa + 14)
	ld e, a
	exts de
	ld xwa, (xsp + 10)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	add iz, hl
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl

; Packs (level << 8) | 0x7F and stores to 0x0451E4 (TG reg 0x800) and to the cache at
; voice+60. The low byte is the constant 0x7F here, which is what distinguishes the "simple"
; path from Voice_Calc_LevelPair_PatchAtk's table lookup.
Voice_Calc_LevelPair_FixedAtk_WriteLevel:
	ld wa, iz
	sla wa, 8
	ld bc, wa
	or bc, 0x7F
	ld (Payload_Bss_Start+0x636e:24), bc
	ld xwa, (xsp + 10)
	ld (xwa + 60), bc
	ld xwa, (xsp + 6)
	ld a, (xwa + 9)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld hl, wa
	ld xwa, (xsp + 6)
	ld a, (xwa + 11)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld de, wa
	ld xwa, (xsp + 6)
	ld a, (xwa + 10)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld bc, wa
	ld wa, 4:i3
	cp bc, 4:i3
	jr lt, Voice_Calc_LevelPair_FixedAtk_WriteChans
	ld wa, bc

; Per-channel L/R computation for the simple path (table 0x0118FE indexed by tonerec+9/+11).
Voice_Calc_LevelPair_FixedAtk_WriteChans:
	ld bc, wa
	ld w, 0x0:opc
	ld bc, hl
	sla bc, 8
	or bc, wa
	ld xwa, (xsp + 10)
	ld (xwa + 62), bc
	ld xwa, (xsp + 2)
	bitm 5, (xwa + 13)
	jr z, Voice_Calc_LevelPair_FixedAtk_NoChanFlag
	ld xwa, (xsp + 6)
	ld a, (xwa + 12)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld w, 0x0:opc
	ld bc, de
	sla bc, 8
	or bc, wa
	ld xwa, (xsp + 10)
	ld (xwa + 64), bc
	ld xwa, (xsp + 6)
	ld a, (xwa + 13)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld c, a
	ld xwa, (xsp + 10)
	ld (xwa + 70), c
	jr Voice_Calc_LevelPair_FixedAtk_Done

; Channel-flag-clear arm of the simple path.
Voice_Calc_LevelPair_FixedAtk_NoChanFlag:
	ld bc, de
	sla bc, 8
	ld xwa, (xsp + 10)
	ld (xwa + 64), bc
	ld xwa, (xsp + 10)
	ld (xwa + 70), 0x0

; popw IZ, unwind 12 bytes, ret.
Voice_Calc_LevelPair_FixedAtk_Done:
	popw iz
	lda xsp, (xsp + 12)
	ret

; Second, instruction-identical copy of Voice_WriteChPanShift (0x02591D). Same inputs, same
; outputs (0x0451E6 / 0x0451E8 = TG regs 0x840 / 0x880); it exists so the "full" level path
; can call it with a `calr` in range.
Voice_WriteChPanShift2:
	dec 8, xsp
	pushw iz
	ld (xsp + 4), c
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 39)
	ld wa, (xwa + 24)
	bit 8, wa
	jrl z, Voice_WriteChPanShift2_Passthrough
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	and wa, 0xFF
	jrl z, Voice_WriteChPanShift2_Passthrough
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 39)
	ld wa, (xwa + 24)
	bit 9, wa
	jr z, Voice_WriteChPanShift2_AddShift
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	and wa, 0x7F
	ld (xsp + 2), wa
	sub (xsp + 2), bc
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	and wa, 0x7F
	ld iz, wa
	sub iz, bc
	jr Voice_WriteChPanShift2_ClampAndWrite

; As 0x02598A.
Voice_WriteChPanShift2_AddShift:
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	and wa, 0x7F
	ld (xsp + 2), wa
	add (xsp + 2), bc
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 32)
	ld c, a
	exts bc
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	and wa, 0x7F
	ld iz, wa
	add iz, bc

; As 0x0259C2.
Voice_WriteChPanShift2_ClampAndWrite:
	ld wa, (xsp + 2)
	ldw bc, 0x7F
	ld de, 4:i3
	calr Int_ClampSignedToRange
	ld (xsp + 2), hl
	ld wa, iz
	ldw bc, 0x7F
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	cp (xsp + 4), 0x0
	jr z, Voice_WriteChPanShift2_NoChanFlag
	ld wa, iz
	set 15, wa
	ld (Payload_Bss_Start+0x6372:24), wa
	jr Voice_WriteChPanShift2_WriteL

; As 0x0259EE.
Voice_WriteChPanShift2_NoChanFlag:
	ld wa, iz
	ld w, 0x0:opc
	ld bc, wa
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	ld a, 0x0:opc
	or wa, bc
	ld (Payload_Bss_Start+0x6372:24), wa

; As 0x025A03.
Voice_WriteChPanShift2_WriteL:
	ld wa, (xsp + 2)
	ld w, 0x0:opc
	ld bc, wa
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	ld a, 0x0:opc
	or wa, bc
	ld (Payload_Bss_Start+0x6370:24), wa
	jr Voice_WriteChPanShift2_Done

; As 0x025A1B.
Voice_WriteChPanShift2_Passthrough:
	ld xwa, (xsp + 6)
	ld wa, (xwa + 62)
	ld (Payload_Bss_Start+0x6370:24), wa
	ld xwa, (xsp + 6)
	ld wa, (xwa + 64)
	ld (Payload_Bss_Start+0x6372:24), wa

; As 0x025A31.
Voice_WriteChPanShift2_Done:
	popw iz
	inc 8, xsp
	ret

; Full level-pair recomputation for one voice; the body runs past the end of this region
; (to ~0x025F7E). In: XWA = per-voice record. Same shape as Voice_Calc_LevelPair_PatchAtk
; (0x025636) but with an extra oscillator-table branch at 0x025CCB. Ultimately writes
; 0x0451E4 / 0x0451E6 / 0x0451E8 (TG regs 0x800 / 0x840 / 0x880) via Voice_WriteChPanShift2.
Voice_Calc_LevelPair_Full:
	lda xsp, (xsp - 14)
	push xiz
	ld (xsp + 14), xwa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 23)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 19)
	bitm 4, (xwa + 16)
	jr z, Voice_Calc_LevelPair_Full_SetInvFlag
	ld xwa, (xsp + 14)
	andmi16 (xwa + 1), 0x7FFF
	jr Voice_Calc_LevelPair_Full_CheckBit11

; Sets the inverted-curve flag in the local frame.
Voice_Calc_LevelPair_Full_SetInvFlag:
	ld xwa, (xsp + 14)
	ormi16 (xwa + 1), 0x8000

; Bit-11 test that selects between the oscillator-table path (0x025CCB, just past this
; region) and the direct path.
Voice_Calc_LevelPair_Full_CheckBit11:
	ld xwa, (xsp + 14)
	ld wa, (xwa + 1)
	bit 11, wa
	jr z, Voice_Calc_LevelPair_Full_OscTablePath
	ld a, (Voice_LevelPair_Bit11Default:24)
	extz wa
	ld iz, wa
	jrl Voice_Calc_LevelPair_Full_CheckMax

; Not a routine entry -- this is the main body of Voice_Calc_LevelPair_Full, whose entry
; (0x025C87) sits just below this region's lower boundary. Documented here because the
; region starts inside it.
;
; Voice_Calc_LevelPair_Full(XWA = voice-slot record) computes the THREE (level,rate) register
; pairs that the sub-CPU keeps for a voice in the tone-generator shadow block, for the
; "full" voice type -- the one whose tone record carries a per-oscillator trim table.
; Called from Voice_Release_Type4.
;
; This branch is taken when bit 11 of slot+1 is CLEAR. It reads a signed per-oscillator
; trim byte from tonerec[0x010C] (tonerec = the pointer at slot+35), adds it to
; paramA+39 (paramA = the pointer at slot+23), clamps the sum to 0..0x64 with
; Int_ClampSignedToRange, and converts it through the 101-entry curve at 0x011899 into an
; 8-bit register level. The bit-11-set branch instead takes a fixed level from the byte
; at 0x0118B3 and jumps straight to _CheckMax.
;
; Level modulation then follows: if paramA+51 is non-zero the LFO/velocity scaler
; Pan_ScaleWithVelocity(paramA+48,+49,+50, depth paramA+51, velocity slot+8) is added,
; and if paramA+46 is non-zero PitchBend_Scale(depth paramA+46, note slot+12) is added
; too; each sum is re-clamped to 0..0xFF.
;
; Register value format written into the shadow block is (level << 8) | rate, where rate
; comes from the 0..0x7F curve at 0x011963. Bit 7 of the low byte is a separate "apply
; immediately" flag that only the per-tick writers (Voice_ComputeAndWriteVolume*) set.
;
; Hardware: nothing directly. The results land in RAM at 0x0451E4/E6/E8; they reach the
; tone generator later, when ToneGen_WriteVoiceParams pushes shadow offsets +24/+26/+28
; to TG register banks 0x800/0x840/0x880 via the 0x100000/0x100002 latch pair.
Voice_Calc_LevelPair_Full_OscTablePath:
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 35)
	ld	a, (xwa+268)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 39)
	extz wa
	add wa, bc
	ldw bc, 0x64
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	ldto_berp A, 0xF8
	extz wa
	lda xbc, (Voice_LevelPair_AttackCurve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 4)
	cp (xwa + 51), 0x0
	jr z, Voice_Calc_LevelPair_Full_NoLFO
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
	jr z, Voice_Calc_LevelPair_Full_NoDepth
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
	ldfr_werp HL, 0xFA
	ld wa, iz
	add wa, (xsp + 8)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_Full_CheckMax

; LFO term only (paramA+46 == 0): add the scaler result, clamp 0..0xFF, go to _CheckMax.
Voice_Calc_LevelPair_Full_NoDepth:
	ld wa, iz
	add wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_Full_CheckMax

; paramA+51 == 0: skip the LFO scaler; apply only the paramA+46 depth term, if any.
Voice_Calc_LevelPair_Full_NoLFO:
	ld xwa, (xsp + 4)
	cp (xwa + 46), 0x0
	jr z, Voice_Calc_LevelPair_Full_CheckMax
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
	ldfr_werp HL, 0xFA
	ld wa, iz
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl

; If bit 0 of the byte pointed to by slot+31 is set and the computed level is exactly
; 0xFF, decrement it. Reserves 0xFF as a "fully attenuated / voice finished" code -- the
; portamento ramp uses 0xFF00 as its terminal value and releases the voice there.
Voice_Calc_LevelPair_Full_CheckMax:
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 31)
	bitm 0, (xwa)
	jr z, Voice_Calc_LevelPair_Full_WriteDSP
	ld wa, iz
	cp wa, 0xFF
	jr nz, Voice_Calc_LevelPair_Full_WriteDSP
	dec 1, iz

; Assembles pair 1: rate = table_0x011963[paramA+40], word = (level<<8)|rate, stored to
; the shadow word 0x0451E4 (TG bank 0x800) and cached in the slot at +60. Then starts
; pairs 2 and 3 from paramA+41 and paramA+43 through the 101-entry curve at 0x0118FE.
Voice_Calc_LevelPair_Full_WriteDSP:
	ld xwa, (xsp + 4)
	ld a, (xwa + 40)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld w, 0x0:opc
	ld bc, iz
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x636e:24), bc
	ld xwa, (xsp + 14)
	ld (xwa + 60), bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 41)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa
	ld xwa, (xsp + 4)
	ld a, (xwa + 43)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 12), wa
	ld xwa, (xsp + 4)
	cp (xwa + 52), 0x0
	jrl z, Voice_Calc_LevelPair_Full_NoDepth2
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
	jr z, Voice_Calc_LevelPair_Full_NoModDepth
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
	ldfr_werp HL, 0xFA
	ld wa, (xsp + 10)
	add wa, (xsp + 8)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	add wa, (xsp + 8)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	jr Voice_Calc_LevelPair_Full_WriteChDepth

; paramA+47 == 0 while paramA+52 != 0: add only the LFO scaler to pairs 2 and 3.
Voice_Calc_LevelPair_Full_NoModDepth:
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
	jr Voice_Calc_LevelPair_Full_WriteChDepth

; paramA+52 == 0: no LFO term for pairs 2/3; apply only the paramA+47 depth term.
Voice_Calc_LevelPair_Full_NoDepth2:
	ld xwa, (xsp + 4)
	cp (xwa + 47), 0x0
	jr z, Voice_Calc_LevelPair_Full_WriteChDepth
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
	ldfr_werp HL, 0xFA
	ld wa, (xsp + 10)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	addw_erp WA, 0xFA
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl

; Rate for pair 2 = table_0x011963[paramA+42], floored at 4 (values below 4 are raised).
Voice_Calc_LevelPair_Full_WriteChDepth:
	ld xwa, (xsp + 4)
	ld a, (xwa + 42)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld hl, wa
	ld wa, 4:i3
	cp hl, 4:i3
	jr lt, Voice_Calc_LevelPair_Full_WriteCh2
	ld wa, hl

; Rate for pair 3 = table_0x011963[paramA+44]; writes shadow words 0x0451E6 (TG bank
; 0x840) and 0x0451E8 (TG bank 0x880) and returns.
Voice_Calc_LevelPair_Full_WriteCh2:
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
Voice_InterpolatePanCurve:
	ld hl, (xwa + 8)
	and hl, 0x7F00
	sra hl, 8
	ld a, (xbc + 30)
	extz wa
	cp hl, wa
	jr ge, Voice_InterpolatePanCurve_HighCheck
	ld a, (xbc + 31)
	extz wa
	cp hl, wa
	jr ge, Voice_InterpolatePanCurve_LowRange
	ldw hl, 0xFE00
	jr Voice_InterpolatePanCurve_Done

; Velocity between +31 and +30: ramp -64 -> 0 as velocity rises.
Voice_InterpolatePanCurve_LowRange:
	ld a, (xbc + 31)
	ld e, a
	extz de
	ld a, (xbc + 30)
	extz wa
	ld ix, wa
	sub ix, de
	ld a, (xbc + 30)
	extz wa
	sub wa, hl
	muls wa, 0xFFC0
	ld hl, wa
	exts xwa
	divs xwa, ix
	ld hl, wa
	jr Voice_InterpolatePanCurve_Done

; Velocity at or above +30: test it against the upper plateau edge +32.
Voice_InterpolatePanCurve_HighCheck:
	ld a, (xbc + 32)
	extz wa
	cp hl, wa
	jr le, Voice_InterpolatePanCurve_Zero
	ld a, (xbc + 33)
	extz wa
	cp hl, wa
	jr le, Voice_InterpolatePanCurve_HighRange
	ldw hl, 0xFE00
	jr Voice_InterpolatePanCurve_Done

; Velocity between +32 and +33: ramp 0 -> -64 as velocity rises.
Voice_InterpolatePanCurve_HighRange:
	ld a, (xbc + 32)
	ld e, a
	extz de
	ld a, (xbc + 33)
	extz wa
	ld ix, wa
	sub ix, de
	ld a, (xbc + 32)
	extz wa
	ld bc, hl
	sub bc, wa
	ld wa, bc
	muls wa, 0xFFC0
	ld hl, wa
	exts xwa
	divs xwa, ix
	ld hl, wa
	jr Voice_InterpolatePanCurve_Done

; Inside the plateau: return 0 (no correction).
Voice_InterpolatePanCurve_Zero:
	ld hl, 0:i3

; Common return.
Voice_InterpolatePanCurve_Done:
	ret

; Voice_InterpolateNoteCurve(XWA = voice-slot record, XBC = paramA record) -> HL.
; Byte-for-byte the same shaper as Voice_InterpolatePanCurve, but keyed on the MIDI note
; number (slot+12 & 0x7F) and using paramA breakpoints +34/+35/+36/+37 instead of
; +30..+33. Returns 0 / [0..-64] / -512 with the same meanings.
; Sole caller: Voice_ComputePitch_ApplyLFO, added to the pitch accumulator.
Voice_InterpolateNoteCurve:
	ld a, (xwa + 12)
	ld l, a
	extz hl
	and hl, 0x7F
	ld a, (xbc + 34)
	extz wa
	cp hl, wa
	jr ge, Voice_InterpolateNoteCurve_HighCheck
	ld a, (xbc + 35)
	extz wa
	cp hl, wa
	jr ge, Voice_InterpolateNoteCurve_LowRange
	ldw hl, 0xFE00
	jr Voice_InterpolateNoteCurve_Done

; Note between +35 and +34: ramp -64 -> 0.
Voice_InterpolateNoteCurve_LowRange:
	ld a, (xbc + 35)
	ld e, a
	extz de
	ld a, (xbc + 34)
	extz wa
	ld ix, wa
	sub ix, de
	ld a, (xbc + 34)
	extz wa
	sub wa, hl
	muls wa, 0xFFC0
	ld hl, wa
	exts xwa
	divs xwa, ix
	ld hl, wa
	jr Voice_InterpolateNoteCurve_Done

; Note at or above +34: test against the upper plateau edge +36.
Voice_InterpolateNoteCurve_HighCheck:
	ld a, (xbc + 36)
	extz wa
	cp hl, wa
	jr le, Voice_InterpolateNoteCurve_Zero
	ld a, (xbc + 37)
	extz wa
	cp hl, wa
	jr le, Voice_InterpolateNoteCurve_HighRange
	ldw hl, 0xFE00
	jr Voice_InterpolateNoteCurve_Done

; Note between +36 and +37: ramp 0 -> -64.
Voice_InterpolateNoteCurve_HighRange:
	ld a, (xbc + 36)
	ld e, a
	extz de
	ld a, (xbc + 37)
	extz wa
	ld ix, wa
	sub ix, de
	ld a, (xbc + 36)
	extz wa
	ld bc, hl
	sub bc, wa
	ld wa, bc
	muls wa, 0xFFC0
	ld hl, wa
	exts xwa
	divs xwa, ix
	ld hl, wa
	jr Voice_InterpolateNoteCurve_Done

; Inside the plateau: return 0.
Voice_InterpolateNoteCurve_Zero:
	ld hl, 0:i3

; Common return.
Voice_InterpolateNoteCurve_Done:
	ret

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
Voice_ComputePitch:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 6)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	bit 7, bc
	jr z, Voice_ComputePitch_CheckSysExTune
	ld xwa, (xsp + 6)
	ormi16 (xwa + 1), 0x800

; Mask the note to 7 bits; select the alternate table if 0x041343 bit 0 is set or
; paramA+25 == 0xE0.
Voice_ComputePitch_CheckSysExTune:
	and bc, 0x7F
	ld wa, (Voice_GlobalFlags:24)
	bit 0, wa
	jr nz, Voice_ComputePitch_SysExTable
	ld xwa, (xsp + 2)
	cp (xwa + 25), 0xE0
	jr nz, Voice_ComputePitch_CheckAltTune

; Alternate mapping: IZ = table_0x011C96[note] - 0x0C.
Voice_ComputePitch_SysExTable:
	ld wa, bc
	extz xwa
	ld xbc, Voice_AltNoteMap_Curve
	add xbc, xwa
	ld a, (xbc)
	extz wa
	ld iz, wa
	sub iz, 0xC
	jrl Voice_ComputePitch_ApplyLFO

; Second entry point to the alternate mapping, gated on 0x041343 bit 1.
Voice_ComputePitch_CheckAltTune:
	ld wa, (Voice_GlobalFlags:24)
	bit 1, wa
	jr z, Voice_ComputePitch_NormalTune
	ld wa, bc
	extz xwa
	ld xbc, Voice_AltNoteMap_Curve
	add xbc, xwa
	ld a, (xbc)
	extz wa
	ld iz, wa
	sub iz, 0xC
	jr Voice_ComputePitch_ApplyLFO

; Normal mapping, negative-detune arm: negate paramA+24 before the multiply.
Voice_ComputePitch_NormalTune:
	ld xwa, (xsp + 2)
	cp (xwa + 24), 0x0
	jr ge, Voice_ComputePitch_PortaPositive
	ld wa, bc
	extz xwa
	ld xbc, Voice_DepthMirror_Table
	add xbc, xwa
	ld a, (xbc)
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 25)
	ld e, a
	extz de
	ld wa, bc
	ld bc, de
	calr Voice_Colour_LookupIndex
	sub hl, 0xD0
	ld xwa, (xsp + 2)
	ld a, (xwa + 24)
	exts wa
	cpl wa
	ld bc, wa
	inc 1, bc
	ld wa, hl
	muls xwa, bc
	ld hl, wa
	jr Voice_ComputePitch_PortaScale

; Normal mapping, non-negative-detune arm.
Voice_ComputePitch_PortaPositive:
	ld xwa, (xsp + 2)
	ld a, (xwa + 25)
	ld e, a
	extz de
	ld wa, bc
	ld bc, de
	calr Voice_Colour_LookupIndex
	sub hl, 0xD0
	ld xwa, (xsp + 2)
	ld a, (xwa + 24)
	ld c, a
	exts bc
	ld wa, hl
	muls xwa, bc
	ld hl, wa

; Common scaling of the detuned value: >>5 (arithmetic) then bias +0xD8.
Voice_ComputePitch_PortaScale:
	sra hl, 5
	ld iz, hl
	add iz, 0xD8

; Accumulates every additive pitch term (LFO scaler, 0x011A4F fine tune, controller
; byte, global 0x045314, +0x2940, velocity and key crossfades, optional tonerec[0x011E]).
Voice_ComputePitch_ApplyLFO:
	ld xwa, (xsp + 2)
	ld a, (xwa + 26)
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 27)
	ld e, a
	extz de
	ld xwa, (xsp + 2)
	ld a, (xwa + 28)
	extz wa
	pushw wa
	ld xwa, (xsp + 4)
	ld a, (xwa + 29)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld wa, (xwa + 8)
	calr Voice_Colour_ClampUpper
	add iz, hl
	ld xwa, (xsp + 6)
	ld wa, (xwa + 43)
	and wa, 0x7F
	extz xwa
	ld xbc, Voice_FineTune_Curve
	add xbc, xwa
	ld a, (xbc)
	exts wa
	add iz, wa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 15)
	ld a, (xwa + 3)
	exts wa
	add iz, wa
	ld xwa, (Payload_Bss_Start+0x649e:24)
	add	iz, (xwa+224)
	add iz, (10560:16)
	ld xwa, (xsp + 6)
	ld xbc, (xsp + 2)
	calr Voice_InterpolatePanCurve
	add iz, hl
	ld xwa, (xsp + 6)
	ld xbc, (xsp + 2)
	calr Voice_InterpolateNoteCurve
	add iz, hl
	ld xwa, (xsp + 2)
	bitm 7, (xwa)
	jr z, Voice_ComputePitch_WriteDone
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld	a, (xwa+286)
	extz wa
	add iz, wa

; Store the accumulator to slot+13 and clear the portamento offset slot+51.
Voice_ComputePitch_WriteDone:
	ld xwa, (xsp + 6)
	ld (xwa + 13), iz
	ld xwa, (xsp + 6)
	ldw (xwa + 51), 0x0
	popw iz
	inc 8, xsp
	ret

; Despite the name, these 17 bytes are EXECUTABLE CODE, not data.
; "clamp WA into [DE..BC], return in HL" -- the same operation as
; Int_ClampSignedToRange at 0x022B19, with the low bound tested first (that routine tests
; the high bound first). Nothing in the image references it; it is dead code left between
; Voice_ComputePitch and Voice_ComputePitch_Mono.
; Converted from `.byte` to real mnemonics 2026-09-01 (lane SUB): `jr ge, 4` / `jr 6` /
; `jr le, 2` take the raw 8-bit displacement field, verified byte-identical via a llvm-mc
; round trip (assemble -> objcopy -> compare against the original 17 bytes).
Voice_ComputePitch_InlineData:
	cp	wa, de
	jr	ge, Voice_ComputePitch_Skip
	ld	wa, de
	jr	Voice_ComputePitch_Join
Voice_ComputePitch_Skip:
	cp	wa, bc
	jr	le, Voice_ComputePitch_Join
	ld	wa, bc
Voice_ComputePitch_Join:
	ld	hl, wa
	ret

; Voice_ComputePitch_Mono(XWA = voice-slot record). The cut-down pitch computation used
; by the mono/legato voice types; callers are Voice_Init_Type1 and Voice_Init_Type2.
; Same two mappings as Voice_ComputePitch (alternate table 0x011C96 gated on 0x041343
; bits 0/1 or paramA+7 == 0xE0; otherwise the 0x00FEE4 + Voice_Colour_LookupIndex path
; scaled by the signed detune at paramA+6), but it reads its detune/curve selectors from
; paramA+6/+7 instead of +24/+25, and its _ApplyLFO tail omits the velocity/key
; crossfades and the tonerec[0x011E] term. Writes slot+13 and clears slot+51.
Voice_ComputePitch_Mono:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld xwa, (xsp + 4)
	ld xiz, (xwa + 23)
	ld xwa, (xsp + 4)
	ld a, (xwa + 12)
	ld e, a
	extz de
	and de, 0x7F
	ld wa, (Voice_GlobalFlags:24)
	bit 0, wa
	jr nz, Voice_ComputePitch_Mono_SysExTable
	cp (xiz + 7), 0xE0
	jr nz, Voice_ComputePitch_Mono_CheckAltTune

; Alternate mapping: HL = table_0x011C96[note] - 0x0C.
Voice_ComputePitch_Mono_SysExTable:
	ld wa, de
	extz xwa
	ld xbc, Voice_AltNoteMap_Curve
	add xbc, xwa
	ld a, (xbc)
	extz wa
	ld hl, wa
	sub hl, 0xC
	jr Voice_ComputePitch_Mono_ApplyLFO

; Second gate on 0x041343 bit 1 into the alternate mapping.
Voice_ComputePitch_Mono_CheckAltTune:
	ld wa, (Voice_GlobalFlags:24)
	bit 1, wa
	jr z, Voice_ComputePitch_Mono_CheckPorta
	ld wa, de
	extz xwa
	ld xbc, Voice_AltNoteMap_Curve
	add xbc, xwa
	ld a, (xbc)
	extz wa
	ld hl, wa
	sub hl, 0xC

; Normal mapping, negative-detune arm (paramA+6 < 0).
Voice_ComputePitch_Mono_CheckPorta:
	cp (xiz + 6), 0x0
	jr ge, Voice_ComputePitch_Mono_PortaPositive
	ld wa, de
	extz xwa
	ld xbc, Voice_DepthMirror_Table
	add xbc, xwa
	ld a, (xbc)
	ld e, a
	extz de
	ld a, (xiz + 7)
	ld c, a
	extz bc
	ld wa, de
	calr Voice_Colour_LookupIndex
	sub hl, 0xD0
	ld a, (xiz + 6)
	exts wa
	cpl wa
	ld bc, wa
	inc 1, bc
	ld wa, hl
	muls xwa, bc
	ld hl, wa
	jr Voice_ComputePitch_Mono_PortaScale

; Normal mapping, non-negative-detune arm.
Voice_ComputePitch_Mono_PortaPositive:
	ld a, (xiz + 7)
	ld c, a
	extz bc
	ld wa, de
	calr Voice_Colour_LookupIndex
	sub hl, 0xD0
	ld a, (xiz + 6)
	ld c, a
	exts bc
	ld wa, hl
	muls xwa, bc
	ld hl, wa

; >>5 then bias +0xD8.
Voice_ComputePitch_Mono_PortaScale:
	sra hl, 5
	add hl, 0xD8

; Adds table_0x011A4F[slot+43 & 0x7F], the byte at (slot+15)+3, the global at 0x045314
; and +0x2940; stores to slot+13 and clears slot+51.
Voice_ComputePitch_Mono_ApplyLFO:
	ld xwa, (xsp + 4)
	ld wa, (xwa + 43)
	and wa, 0x7F
	extz xwa
	ld xbc, Voice_FineTune_Curve
	add xbc, xwa
	ld a, (xbc)
	exts wa
	add hl, wa
	ld xwa, (xsp + 4)
	ld xwa, (xwa + 15)
	ld a, (xwa + 3)
	exts wa
	add hl, wa
	ld xwa, (Payload_Bss_Start+0x649e:24)
	add	hl, (xwa+224)
	add hl, (10560:16)
	ld xwa, (xsp + 4)
	ld (xwa + 13), hl
	ld xwa, (xsp + 4)
	ldw (xwa + 51), 0x0
	pop xiz
	inc 4, xsp
	ret

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
Voice_ApplyPortamento:
	ld de, (xwa + 13)
	ld xbc, (xwa + 23)
	cp (xbc + 23), 0x0
	jr z, Voice_ApplyPortamento_NoChanDetune
	ld xbc, (xwa + 23)
	ld c, (xbc + 23)
	extz bc
	sub bc, 0x64
	add de, bc
	jr Voice_ApplyPortamento_ApplyDetune

; paramA+23 == 0: apply the fixed -0x200 bias instead of a channel detune.
Voice_ApplyPortamento_NoChanDetune:
	sub de, 0x200

; Add the signed byte (slot+39)[+34], then test 0x041343 bit 1 for the key-shift arm.
Voice_ApplyPortamento_ApplyDetune:
	ld xbc, (xwa + 39)
	ld c, (xbc + 34)
	exts bc
	add de, bc
	ld bc, (Voice_GlobalFlags:24)
	bit 1, bc
	jr z, Voice_ApplyPortamento_Done
	cp (xwa + 4), 0x1
	jr ugt, Voice_ApplyPortamento_HighNote
	ld xbc, (xwa + 35)
	sub de, (xbc + 16)
	dec 8, de
	jr Voice_ApplyPortamento_Done

; slot+4 > 1 arm of the key-shift correction: subtract a flat 0x10.
Voice_ApplyPortamento_HighNote:
	sub de, 0x10

; Move the result to BC and tail-jump to Voice_Build_OutputLevel.
Voice_ApplyPortamento_Done:
	ld bc, de
	jrl Voice_Build_OutputLevel

; Voice_ApplyPortamento2(XWA = voice-slot record). The mono/legato counterpart of
; Voice_ApplyPortamento. Channel detune comes from paramA+5 (not +23), there is no
; (slot+39)[+34] term, and the key-shift arm additionally subtracts tonerec[+12] and then
; adds back a vibrato contribution of tonerec[+12] >> 2 -- except when tonerec[+12] is
; exactly 0xFE00, in which case the raw 0xFE00 is added (a sentinel, the same -512 value
; the crossfade shapers use). Tail-jumps to Voice_Build_OutputLevel.
; Callers: Voice_Init_Type1, Voice_Init_Type2, Voice_AllVoices_WriteAmplitude_BranchB.
Voice_ApplyPortamento2:
	ld xbc, (xwa + 23)
	ld de, (xwa + 13)
	cp (xbc + 5), 0x0
	jr z, Voice_ApplyPortamento2_NoChanDetune
	ld c, (xbc + 5)
	extz bc
	sub bc, 0x64
	add de, bc
	jr Voice_ApplyPortamento2_ApplyDetune

; paramA+5 == 0: apply the fixed -0x200 bias.
Voice_ApplyPortamento2_NoChanDetune:
	sub de, 0x200

; Key-shift arm gated on 0x041343 bit 1; computes the tonerec[+12] vibrato term.
Voice_ApplyPortamento2_ApplyDetune:
	ld bc, (Voice_GlobalFlags:24)
	bit 1, bc
	jr z, Voice_ApplyPortamento2_Done
	ld xbc, (xwa + 35)
	sub de, (xbc + 16)
	ld xbc, (xwa + 35)
	sub de, (xbc + 12)
	ldw hl, 0xFE00
	ld xbc, (xwa + 35)
	ld bc, (xbc + 12)
	cp bc, 0xFE00
	jr z, Voice_ApplyPortamento2_AddVibrato
	ld xbc, (xwa + 35)
	ld bc, (xbc + 12)
	sra bc, 2
	ld hl, bc

; Add the vibrato term (either tonerec[+12]>>2 or the 0xFE00 sentinel).
Voice_ApplyPortamento2_AddVibrato:
	add de, hl

; Move to BC and tail-jump to Voice_Build_OutputLevel.
Voice_ApplyPortamento2_Done:
	ld bc, de
	jrl Voice_Build_OutputLevel

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
Voice_WriteChPitchWithVib:
	dec 2, xsp
	push xiz
	extz bc
	muls bc, 0x47
	lda xde, (Payload_Bss_Start+0x4237:24)
	ld	xbc, (xde+bc)
	bitm 3, (xbc)
	jr z, Voice_WriteChPitchWithVib_Done
	ld c, (xbc + 14)
	ld (xsp + 4), c
	extz bc
	lda xde, (Voice_VibratoDepth_Table:24)
	ld	c, (xde+bc)
	extz bc
	sll bc, 8
	set 7, bc
	ld (Payload_Bss_Start+0x6382:24), bc
	ld c, (xsp + 4)
	extz bc
	lda xde, (Voice_VibratoDepth_Table:24)
	ld	c, (xde+bc)
	extz bc
	sll bc, 8
	ld (Payload_Bss_Start+0x6384:24), bc
	extz wa
	call Voice_Query_PartVoices
	lda xwa, (xhl + 5)
	ld xiz, xwa
	cp (xiz), 0x40
	jr nc, Voice_WriteChPitchWithVib_Done

; Per-slot body: match the slot's channel byte, then push the two TG registers.
Voice_WriteChPitchWithVib_Loop:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4237:24)
	ld	xbc, (xbc+wa)
	ld a, (xsp + 4)
	cp a, (xbc + 14)
	jr nz, Voice_WriteChPitchWithVib_NextSlot
	ld a, (xiz)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteLevelPair

; Advance the slot-list cursor; the list terminates on the first index >= 0x40.
Voice_WriteChPitchWithVib_NextSlot:
	inc 1, xiz
	cp (xiz), 0x40
	jr c, Voice_WriteChPitchWithVib_Loop

; Restore IZ and return.
Voice_WriteChPitchWithVib_Done:
	pop xiz
	inc 2, xsp
	ret

Voice_Calc_LevelPair_EGA:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 108)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 45)
	extz wa
	add wa, bc
	ldw bc, 0x64
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	ldto_berp A, 0xF8
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 10)
	bit 0, wa
	jr z, Voice_Calc_LevelPair_EGA_ApplyLFO
	ld xwa, (xsp + 6)
	ld wa, (xwa + 1)
	bit 8, wa
	jr nz, Voice_Calc_LevelPair_EGA_ApplyLFO
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 24)
	extz wa
	lda xbc, (Voice_EnvLevel_IndexMap:24)
	ld	a, (xbc+wa)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	cp wa, iz
	jr gt, Voice_Calc_LevelPair_EGA_ApplyLFO
	ld iz, wa

; Body of Voice_Calc_LevelPair_EGA (entry 0x026769, already named -- left alone).
; That routine computes the level for register pair 1 from tonerec[108] + paramA+45,
; clamped 0..0x64 and curved through table_0x0118FE, optionally capped by
; table_0x0118FE[table_0x011ADF[tonerec+24]] when bit 0 of tonerec+10 is set and bit 8 of
; slot+1 is clear.
; This label is the modulation stage: if paramA+53 is non-zero, add
; Pan_ScaleWithVelocity(paramA+48..+50, depth paramA+53, velocity slot+8) and re-clamp
; through Voice_Clamp_Byte_HL.
Voice_Calc_LevelPair_EGA_ApplyLFO:
	ld xwa, (xsp + 2)
	cp (xwa + 53), 0x0
	jr z, Voice_Calc_LevelPair_EGA_WriteDSP
	ld xwa, (xsp + 2)
	ld a, (xwa + 48)
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 49)
	ld e, a
	extz de
	ld xwa, (xsp + 2)
	ld a, (xwa + 50)
	extz wa
	pushw wa
	ld xwa, (xsp + 4)
	ld a, (xwa + 53)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld wa, (xwa + 8)
	calr Pan_ScaleWithVelocity
	add iz, hl
	ld wa, iz
	calr Voice_Clamp_Byte_HL
	ld iz, hl

; Stage the result: 0x0451F8 = (level<<8)|0x0080, 0x0451FA = (level<<8). These are shadow
; offsets +44/+46, pushed to TG banks 0x800 and 0x840 by ToneGen_WriteLevelBurst*. Bit 7 of the
; low byte is the "apply now" flag that the note-on/full-dump path leaves clear.
Voice_Calc_LevelPair_EGA_WriteDSP:
	ld wa, iz
	sla wa, 8
	set 7, wa
	ld (Payload_Bss_Start+0x6382:24), wa
	ld wa, iz
	sla wa, 8
	ld (Payload_Bss_Start+0x6384:24), wa
	popw iz
	inc 8, xsp
	ret

Voice_Stage_EnvSegments:
	ld bc, (xwa + 62)
	ld (Payload_Bss_Start+0x6370:24), bc
	ld wa, (xwa + 64)
	ld (Payload_Bss_Start+0x6372:24), wa
	ret

; Voice_WriteVolume_SetFlag(XWA = voice-slot record). Two-instruction helper: copies the
; already-computed pair-1 word from slot+64 into shadow 0x0451F8 with bit 7 forced set,
; and the same word verbatim into 0x0451FA. Used to re-assert an existing level without
; recomputing it. Sole caller: Voice_AllNotes_SustainRetrigger_BranchE.
Voice_WriteVolume_SetFlag:
	ld bc, (xwa + 64)
	set 7, bc
	ld (Payload_Bss_Start+0x6382:24), bc
	ld wa, (xwa + 64)
	ld (Payload_Bss_Start+0x6384:24), wa
	ret

; Voice_ComputeVolume_CappedLFO(XWA = voice-slot record). Variant of
; Voice_Calc_LevelPair_EGA used on the voice-cut path (sole caller:
; Voice_Cut_BranchB). Difference: when bit 0 of tonerec+10 is SET the level is taken as
; the SMALLER of table_0x0118FE[table_0x011ADF[tonerec+24]] and
; table_0x0118FE[paramA+45] -- i.e. the oscillator ceiling wins outright rather than only
; capping. When the bit is clear it falls back to the tonerec[0x010D] + paramA+45 path.
; Stages the result to 0x0451F8/0x0451FA exactly as Volume1 does.
Voice_ComputeVolume_CappedLFO:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 10)
	bit 0, wa
	jr z, Voice_ComputeVolume_CappedLFO_UseOscMax
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 24)
	extz wa
	lda xbc, (Voice_EnvLevel_IndexMap:24)
	ld	a, (xbc+wa)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 2)
	ld a, (xwa + 45)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld bc, iz
	cp bc, wa
	jr ule, Voice_ComputeVolume_CappedLFO_ApplyLFO
	ld xwa, (xsp + 2)
	ld a, (xwa + 45)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	jr Voice_ComputeVolume_CappedLFO_ApplyLFO

; tonerec+10 bit 0 clear: level = curve(clamp(tonerec[0x010D] + paramA+45, 0..0x64)).
Voice_ComputeVolume_CappedLFO_UseOscMax:
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld	a, (xwa+269)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 45)
	extz wa
	add wa, bc
	ldw bc, 0x64
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	ldto_berp A, 0xF8
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa

; Optional paramA+53 velocity/LFO term, then Voice_Clamp_Byte_HL.
Voice_ComputeVolume_CappedLFO_ApplyLFO:
	ld xwa, (xsp + 2)
	cp (xwa + 53), 0x0
	jr z, Voice_ComputeVolume_CappedLFO_WriteDSP
	ld xwa, (xsp + 2)
	ld a, (xwa + 48)
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 49)
	ld e, a
	extz de
	ld xwa, (xsp + 2)
	ld a, (xwa + 50)
	extz wa
	pushw wa
	ld xwa, (xsp + 4)
	ld a, (xwa + 53)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld wa, (xwa + 8)
	calr Pan_ScaleWithVelocity
	add iz, hl
	ld wa, iz
	calr Voice_Clamp_Byte_HL
	ld iz, hl

; Stage 0x0451F8 = (level<<8)|0x0080 and 0x0451FA = (level<<8).
Voice_ComputeVolume_CappedLFO_WriteDSP:
	ld wa, iz
	sla wa, 8
	set 7, wa
	ld (Payload_Bss_Start+0x6382:24), wa
	ld wa, iz
	sla wa, 8
	ld (Payload_Bss_Start+0x6384:24), wa
	popw iz
	inc 8, xsp
	ret

Voice_Calc_LevelPair_EGB:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld a, (xwa + 15)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 10)
	bit 0, wa
	jr z, Voice_Calc_LevelPair_EGB_ApplyLFO
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 24)
	extz wa
	lda xbc, (Voice_EnvLevel_IndexMap:24)
	ld	a, (xbc+wa)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	cp wa, iz
	jr gt, Voice_Calc_LevelPair_EGB_ApplyLFO
	ld iz, wa

; Body of Voice_Calc_LevelPair_EGB (entry 0x026975, already named). That routine
; builds register pair 2 (shadow +48/+50 -> TG banks 0x900/0x940) from
; table_0x0118FE[paramA+15], optionally capped by the tonerec+24 oscillator ceiling.
; This label applies the paramA+22 velocity/LFO depth via Pan_ScaleWithVelocity with a
; fixed 0x7F ceiling.
Voice_Calc_LevelPair_EGB_ApplyLFO:
	ld xwa, (xsp + 2)
	cp (xwa + 22), 0x0
	jr z, Voice_Calc_LevelPair_EGB_NoLFO
	ld xwa, (xsp + 2)
	ld a, (xwa + 19)
	ld c, a
	extz bc
	pushw 0x7F
	ld xwa, (xsp + 4)
	ld a, (xwa + 22)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld wa, (xwa + 8)
	ld de, 0:i3
	calr Pan_ScaleWithVelocity
	add iz, hl
	ld xwa, (xsp + 2)
	cp (xwa + 17), 0x0
	jr z, Voice_Calc_LevelPair_EGB_NoKeyTrack
	ld xwa, (xsp + 2)
	ld a, (xwa + 17)
	ld e, a
	exts de
	ld xwa, (xsp + 6)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	add iz, hl
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_EGB_WriteDSP

; paramA+17 == 0: skip the key-tracking term, just clamp 0..0xFF.
Voice_Calc_LevelPair_EGB_NoKeyTrack:
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_EGB_WriteDSP

; paramA+22 == 0: no velocity term; apply only the paramA+17 key-tracking term via
; PitchBend_Scale(note = slot+12).
Voice_Calc_LevelPair_EGB_NoLFO:
	ld xwa, (xsp + 2)
	cp (xwa + 17), 0x0
	jr z, Voice_Calc_LevelPair_EGB_WriteDSP
	ld xwa, (xsp + 2)
	ld a, (xwa + 17)
	ld e, a
	exts de
	ld xwa, (xsp + 6)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	add iz, hl
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl

; Chooses the detune arm from the sign of paramA+7 and scales paramA+16 through
; Detune_ScaleSymmetric to produce the pair's low byte.
Voice_Calc_LevelPair_EGB_WriteDSP:
	ld xwa, (xsp + 2)
	cp (xwa + 7), 0x0
	jr ge, Voice_Calc_LevelPair_EGB_PositiveDetune
	ld xwa, (xsp + 2)
	ld a, (xwa + 16)
	exts wa
	cpl wa
	inc 1, wa
	calr Detune_ScaleSymmetric
	jr Voice_Calc_LevelPair_EGB_WriteResult

; paramA+7 >= 0: use paramA+16 unnegated.
Voice_Calc_LevelPair_EGB_PositiveDetune:
	ld xwa, (xsp + 2)
	ld a, (xwa + 16)
	exts wa
	calr Detune_ScaleSymmetric

; Stage (level<<8)|detune into BOTH 0x0451FC and 0x0451FE (shadow +48/+50, TG banks
; 0x900 and 0x940 -- the pair is written with the same word twice).
Voice_Calc_LevelPair_EGB_WriteResult:
	ld h, 0x0:opc
	ld wa, iz
	sla wa, 8
	or wa, hl
	ld (Payload_Bss_Start+0x6386:24), wa
	ld (Payload_Bss_Start+0x6388:24), wa
	popw iz
	inc 8, xsp
	ret

Voice_Calc_LevelPair_EGC:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld a, (xwa + 69)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld iz, wa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 10)
	bit 0, wa
	jr z, Voice_Calc_LevelPair_EGC_ApplyLFO
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 24)
	extz wa
	lda xbc, (Voice_EnvLevel_IndexMap:24)
	ld	a, (xbc+wa)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	cp wa, iz
	jr gt, Voice_Calc_LevelPair_EGC_ApplyLFO
	ld iz, wa

; Body of Voice_Calc_LevelPair_EGC (entry 0x026AAA, already named). Identical in
; shape to Volume2 but reading paramA+69/+73/+76/+71/+70/+61 instead of
; +15/+19/+22/+17/+16/+7, and staging to 0x045200/0x045202 (shadow +52/+54, TG banks
; 0x9C0 and 0xA00).
Voice_Calc_LevelPair_EGC_ApplyLFO:
	ld xwa, (xsp + 2)
	cp (xwa + 76), 0x0
	jr z, Voice_Calc_LevelPair_EGC_NoLFO
	ld xwa, (xsp + 2)
	ld a, (xwa + 73)
	ld c, a
	extz bc
	pushw 0x7F
	ld xwa, (xsp + 4)
	ld a, (xwa + 76)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld wa, (xwa + 8)
	ld de, 0:i3
	calr Pan_ScaleWithVelocity
	add iz, hl
	ld xwa, (xsp + 2)
	cp (xwa + 71), 0x0
	jr z, Voice_Calc_LevelPair_EGC_NoKeyTrack
	ld xwa, (xsp + 2)
	ld a, (xwa + 71)
	ld e, a
	exts de
	ld xwa, (xsp + 6)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	add iz, hl
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_EGC_WriteDSP

; paramA+71 == 0: skip key tracking, clamp 0..0xFF.
Voice_Calc_LevelPair_EGC_NoKeyTrack:
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	jr Voice_Calc_LevelPair_EGC_WriteDSP

; paramA+76 == 0: key tracking only.
Voice_Calc_LevelPair_EGC_NoLFO:
	ld xwa, (xsp + 2)
	cp (xwa + 71), 0x0
	jr z, Voice_Calc_LevelPair_EGC_WriteDSP
	ld xwa, (xsp + 2)
	ld a, (xwa + 71)
	ld e, a
	exts de
	ld xwa, (xsp + 6)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	add iz, hl
	ld wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl

; Sums paramA+61 and paramA+70, clamps to -0x32..+0x32, scales via
; Detune_ScaleSymmetric, and stages (level<<8)|detune to 0x045200 and 0x045202.
Voice_Calc_LevelPair_EGC_WriteDSP:
	ld xwa, (xsp + 2)
	ld a, (xwa + 61)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 70)
	exts wa
	add wa, bc
	ldw bc, 0x32
	ldw de, 0xFFCE
	calr Int_ClampSignedToRange
	ld wa, hl
	calr Detune_ScaleSymmetric
	ld h, 0x0:opc
	ld wa, iz
	sla wa, 8
	or wa, hl
	ld (Payload_Bss_Start+0x638a:24), wa
	ld (Payload_Bss_Start+0x638c:24), wa
	popw iz
	inc 8, xsp
	ret

Voice_Calc_LevelPair_Silence:
	ldw (Payload_Bss_Start+0x6386:24), 0x0000
	ldw (Payload_Bss_Start+0x6388:24), 0x0000
	ld c, (xwa + 70)
	extz bc
	sll bc, 8
	set 7, bc
	ld (Payload_Bss_Start+0x6382:24), bc
	ld a, (xwa + 70)
	extz wa
	sll wa, 8
	ld (Payload_Bss_Start+0x6384:24), wa
	ldw (Payload_Bss_Start+0x638a:24), 0x0000
	ldw (Payload_Bss_Start+0x638c:24), 0x0000
	ret

; Voice_WriteVolume_OrPan(XWA = voice-slot record). If bit 5 of (slot+19)[+13] is set,
; stage pair 1 from table_0x0118FE[paramA+13]: 0x0451FA = (v<<8), 0x0451F8 = (v<<8)|0x80.
; Otherwise stage 0x0451F8 = 0x0080 (target 0x00 with the apply-now bit SET) and
; 0x0451FA = 0x0000 (target 0x00, apply-now bit CLEAR). Under the 0xFF = silent polarity
; that is the LOUD extreme, not silence: the firmware's silence word is 0xFF80 / 0xFF00
; (Voice_SetPitch). [INFERENCE] 0x00 is below 0x04, the loudest byte Voice_EnvelopeLevel_
; Curve can produce, so "fully open" is an extrapolation past the end of the curve rather
; than a level the builders ever emit.
; Sole caller: Voice_AllNotes_SustainRetrigger_BranchF.
Voice_WriteVolume_OrPan:
	ld xbc, (xwa + 19)
	ld xwa, (xwa + 23)
	bitm 5, (xbc + 13)
	jr z, Voice_WriteVolume_OrPan_Muted
	ld a, (xwa + 13)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	sll wa, 8
	ld (Payload_Bss_Start+0x6384:24), wa
	set 7, wa
	ld (Payload_Bss_Start+0x6382:24), wa
	ret

; Bit-5-clear arm: target 0x00 with the "apply now" bit set. Under the 0xFF = silent
; polarity that is the loud extreme, not muted -- [INFERENCE] 0x00 lies past the loud end
; of the level curve, so this is an extrapolation, not a value the builders emit.
; NO RENAME PROPOSED -- the label is a `jr z` branch target, so only the comment is
; corrected here.
Voice_WriteVolume_OrPan_Muted:
	ldw (Payload_Bss_Start+0x6382:24), 0x0080
	ldw (Payload_Bss_Start+0x6384:24), 0x0000
	ret

; Voice_AdvanceLFOPhase(XWA = 9-byte LFO sub-record) -> HL = phase output.
; The sub-record fields used are: +0 flags/mode, +7 period, +8 phase counter.
; Mode = (flags & 0x1C):
;   0x08 "triangle": ++phase; while phase < period return (phase<<8)/period; when it
;        reaches the period, reset phase to 0, clear flag bit 3, set bit 2, return 0x100.
;   0x10 "ramp/hold": ++phase; return 0; when phase reaches the period, reset it, clear
;        flag bit 4 and set bit 3.
;   anything else: return 0 (idle).
; Called only from the three loops of Voice_UpdateAllLFO.
Voice_AdvanceLFOPhase:
	ld c, (xwa)
	and c, 0x1C
	cp c, 0x8
	jr z, Voice_AdvanceLFOPhase_Triangle
	cp c, 0x10
	jr nz, Voice_AdvanceLFOPhase_Idle
	lda xbc, (xwa + 8)
	incm8 1, (xbc)
	ld c, (xbc)
	cp c, (xwa + 7)
	jr c, Voice_AdvanceLFOPhase_IncDone
	ld (xwa + 8), 0x0
	resm 4, (xwa)
	setm 3, (xwa)

; Ramp/hold mode still running: return 0.
Voice_AdvanceLFOPhase_IncDone:
	ld hl, 0:i3
	jr Voice_AdvanceLFOPhase_Done

; Triangle mode: advance and return the scaled phase (phase<<8)/period.
Voice_AdvanceLFOPhase_Triangle:
	lda xbc, (xwa + 8)
	incm8 1, (xbc)
	ld c, (xbc)
	cp c, (xwa + 7)
	jr nc, Voice_AdvanceLFOPhase_TriangleReset
	ld l, (xwa + 8)
	extz hl
	sll hl, 8
	ld a, (xwa + 7)
	ld c, a
	extz bc
	ld wa, hl
	extz xwa
	div xwa, bc
	ld hl, wa
	jr Voice_AdvanceLFOPhase_Done

; Triangle wrap: phase = 0, flag bit 3 -> bit 2, return 0x100 (full scale).
Voice_AdvanceLFOPhase_TriangleReset:
	ld (xwa + 8), 0x0
	resm 3, (xwa)
	setm 2, (xwa)
	ldw hl, 0x100
	jr Voice_AdvanceLFOPhase_Done

; Unrecognised mode: return 0.
Voice_AdvanceLFOPhase_Idle:
	ld hl, 0:i3

; Common return.
Voice_AdvanceLFOPhase_Done:
	ret

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
Voice_UpdateAllLFO:
	push xiz
	ld iz, 0:i3
	cp iz, 0x80
	jr nc, Voice_UpdateAllLFO_Loop2

; Group 1 body: 128 sub-records at 0x04424E, EGEnv_Compute_A, scratch 0x04520C.
Voice_UpdateAllLFO_Loop1:
	ld wa, iz
	extz xwa
	ld xbc, 0x1B
	call Math_Multiply32
	lda xbc, (Payload_Bss_Start+0x53d8:24)
	add xbc, xhl
	ld a, (xbc)
	and a, 0x18
	jr z, Voice_UpdateAllLFO_NextSlot1
	ld xwa, xbc
	calr Voice_AdvanceLFOPhase
	ldfr_werp HL, 0xFA
	cpiw_erp 0xFA, 0
	jr z, Voice_UpdateAllLFO_NextSlot1
	ldto_berp A, 0xF8
	extz wa
	calr EGEnv_Compute_A
	ld (Payload_Bss_Start+0x6396:24), hl
	cp_erpw 0xFA, 0x00, 0x01
	jr z, Voice_UpdateAllLFO_DispatchVoice1
	ld hl, (Payload_Bss_Start+0x6396:24)
	extz xhl
	and xhl, 0x1FFF
	ldto_werp BC, 0xFA
	extz xbc
	ld xwa, xhl
	call Math_Multiply32
	andw (Payload_Bss_Start+0x6396:24), 57344
	srl xhl, 8
	or (Payload_Bss_Start+0x6396:24), hl

; Push the group-1 result for this slot with ToneGen_WriteExtParam_600.
Voice_UpdateAllLFO_DispatchVoice1:
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_600

; ++slot; loop while slot < 0x80.
Voice_UpdateAllLFO_NextSlot1:
	inc 1, iz
	cp iz, 0x80
	jr c, Voice_UpdateAllLFO_Loop1

; Group 2 preamble: reset the slot counter, bail out to group 3 if 0x40 slots is none.
Voice_UpdateAllLFO_Loop2:
	ld iz, 0:i3
	cp iz, 0x40
	jr nc, Voice_UpdateAllLFO_Loop3

; Group 2 body: 64 sub-records at 0x044257, EGEnv_Compute_B, scratch 0x045204.
Voice_UpdateAllLFO_Loop2_ProcessSlot:
	ld wa, iz
	extz xwa
	ld xbc, 0x1B
	call Math_Multiply32
	lda xwa, (Payload_Bss_Start+0x53e1:24)
	add xwa, xhl
	ld xbc, xwa
	ld a, (xbc)
	and a, 0x18
	jr z, Voice_UpdateAllLFO_NextSlot2
	ld xwa, xbc
	calr Voice_AdvanceLFOPhase
	ldfr_werp HL, 0xFA
	cpiw_erp 0xFA, 0
	jr z, Voice_UpdateAllLFO_NextSlot2
	ldto_berp A, 0xF8
	extz wa
	calr EGEnv_Compute_B
	ld (Payload_Bss_Start+0x638e:24), hl
	cp_erpw 0xFA, 0x00, 0x01
	jr z, Voice_UpdateAllLFO_DispatchVoice2
	ld hl, (Payload_Bss_Start+0x638e:24)
	extz xhl
	and xhl, 0x1FFF
	ldto_werp BC, 0xFA
	extz xbc
	ld xwa, xhl
	call Math_Multiply32
	andw (Payload_Bss_Start+0x638e:24), 57344
	srl xhl, 8
	or (Payload_Bss_Start+0x638e:24), hl

; Push the group-2 result with ToneGen_WriteExtParam_1C0_Single.
Voice_UpdateAllLFO_DispatchVoice2:
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_1C0_Single

; ++slot; loop while slot < 0x40.
Voice_UpdateAllLFO_NextSlot2:
	inc 1, iz
	cp iz, 0x40
	jr c, Voice_UpdateAllLFO_Loop2_ProcessSlot

; Group 3 preamble: reset the slot counter for the 128-slot pass.
Voice_UpdateAllLFO_Loop3:
	ld iz, 0:i3
	cp iz, 0x80
	jrl nc, Voice_UpdateAllLFO_Done

; Group 3 body: 128 sub-records at 0x044260, converted via Voice_Freq_WriteLeft.
Voice_UpdateAllLFO_Loop3_ProcessSlot:
	ld wa, iz
	extz xwa
	ld xbc, 0x1B
	call Math_Multiply32
	lda xwa, (Payload_Bss_Start+0x53ea:24)
	add xwa, xhl
	ld xbc, xwa
	ld a, (xbc)
	and a, 0x18
	jr z, Voice_UpdateAllLFO_NextSlot3
	ld xwa, xbc
	calr Voice_AdvanceLFOPhase
	ldfr_werp HL, 0xFA
	cpiw_erp 0xFA, 0
	jr z, Voice_UpdateAllLFO_NextSlot3
	ldto_berp A, 0xF8
	extz wa
	calr Voice_Freq_WriteLeft
	cp_erpw 0xFA, 0x00, 0x01
	jr z, Voice_UpdateAllLFO_DispatchVoice3
	cp iz, 0x40
	jr nc, Voice_UpdateAllLFO_DispatchGroup3_High
	ld hl, (Payload_Bss_Start+0x638e:24)
	extz xhl
	and xhl, 0x1FFF
	ldto_werp BC, 0xFA
	extz xbc
	ld xwa, xhl
	call Math_Multiply32
	andw (Payload_Bss_Start+0x638e:24), 57344
	srl xhl, 8
	or (Payload_Bss_Start+0x638e:24), hl
	jr Voice_UpdateAllLFO_DispatchVoice3

; Slots 0x40..0x7F of group 3 fold their result into scratch 0x04520E instead of
; 0x045204.
Voice_UpdateAllLFO_DispatchGroup3_High:
	ld hl, (Payload_Bss_Start+0x6398:24)
	extz xhl
	and xhl, 0x1FFF
	ldto_werp BC, 0xFA
	extz xbc
	ld xwa, xhl
	call Math_Multiply32
	andw (Payload_Bss_Start+0x6398:24), 57344
	srl xhl, 8
	or (Payload_Bss_Start+0x6398:24), hl

; Push the group-3 result with ToneGen_WriteExtParam_TypeDispatch_Single.
Voice_UpdateAllLFO_DispatchVoice3:
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_TypeDispatch_Single

; ++slot; loop while slot < 0x80.
Voice_UpdateAllLFO_NextSlot3:
	inc 1, iz
	cp iz, 0x80
	jrl c, Voice_UpdateAllLFO_Loop3_ProcessSlot

; Restore IZ and return.
Voice_UpdateAllLFO_Done:
	pop xiz
	ret

Voice_Step_DelayTimers:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xwa
	ld xwa, (xsp + 2)
	ld iz, (xwa + 47)
	ld wa, iz
	extz xwa
	bit 15, wa
	jr z, Voice_Step_DelayTimers_LowSlot
	sub iz, 0x100
	ld wa, iz
	and wa, 0x7F00
	jr nz, Voice_Step_DelayTimers_LowSlot
	ld xwa, (xsp + 2)
	ld a, (xwa)
	extz wa
	ld xbc, (xsp + 2)
	ld bc, (xbc + 45)
	call ToneGen_WriteSingleReg
	ld xwa, (xsp + 2)
	ld a, (xwa)
	extz wa
	call Voice_Clear_HoldBit
	res 15, iz

; ---------------------------------------------------------------------------
; Voice_Step_DelayTimers (0x026E5B) -- ticks TWO independent deferred-action
; timers packed into the single word at (record + 0x2F), once per call.
;
;   bit 15      = high slot ARMED      bits 8..14 = high slot countdown
;   bit  7      = low  slot ARMED      bits 0..6  = low  slot countdown
;
; Each armed slot is decremented; when its counter reaches zero the slot fires
; and DISARMS ITSELF (res 0x0F,IZ / and IZ,0x007F), then the packed word is
; written back.
;
;   high slot expiry -> ToneGen_WriteSingleReg (param from record+0x2D)
;                    -> Voice_Clear_HoldBit
;   low  slot expiry -> Voice_Reload_Levels
;
; NAMING (2026-08-06): previously Voice_Step_AmpDelay, and a later pass argued
; for Voice_Step_ReleaseDelay. BOTH described only one slot -- "release" the
; high one, "amp" the low one -- which is why the two readings disagreed. The
; routine is a generic two-slot delay timer, so it is named for the mechanism.
; Sibling: Voice_Step_ExprRamp (0x026EC3).
; ---------------------------------------------------------------------------
; Body of Voice_Step_DelayTimers (entry 0x026E5B, already named -- left alone). That routine
; drives the packed 16-bit countdown word at slot+47, which holds TWO independent timers:
;   high byte, bit 15 = "note-off armed": each tick subtracts 0x100; when the high 7 bits
;     reach zero it writes slot+45 to the voice's TG register through
;     ToneGen_WriteSingleReg, calls Voice_Clear_HoldBit, and clears bit 15;
;   low byte, bit 7 = "release armed": handled at THIS label. Decrement by 1; when the
;     low 7 bits reach zero, call Voice_Reload_Levels for the slot and clear bit 7.
; ★ These two paths are the ONLY way a slot goes back to the free pool during steady-
; state playback (the other being the portamento terminal state), so any stall upstream
; of Voice_Step_DelayTimers stops voice reclamation outright.
Voice_Step_DelayTimers_LowSlot:
	bit 7, iz
	jr z, Voice_Step_DelayTimers_Store
	dec 1, iz
	ld wa, iz
	and wa, 0x7F
	jr nz, Voice_Step_DelayTimers_Store
	ld xwa, (xsp + 2)
	ld a, (xwa)
	extz wa
	call Voice_Reload_Levels
	and iz, 0x7F

; Write the updated countdown word back to slot+47 and return.
Voice_Step_DelayTimers_Store:
	ld xwa, (xsp + 2)
	ld (xwa + 47), iz
	popw iz
	inc 4, xsp
	ret

Voice_Step_ExprRamp:
	dec 6, xsp
	pushw iz
	ld (xsp + 4), xwa
	ld xwa, (xsp + 4)
	ld wa, (xwa + 49)
	ld (xsp + 2), wa
	and wa, 0x7F
	jrl nz, Voice_Step_ExprRamp_ActiveCount
	ld xwa, (xsp + 4)
	ld a, (xwa + 53)
	extz wa
	or (xsp + 2), wa
	xormi16 (xsp + 2), 0x800
	ld wa, (xsp + 2)
	bit 11, wa
	jrl z, Voice_Step_ExprRamp_ZeroState
	ld xwa, (xsp + 4)
	ld a, (xwa + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2518:24)
	cp	(xbc+wa), 0x01
	jr nz, Voice_Step_ExprRamp_ModeCheck2
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	ld xbc, (xsp + 4)
	ld bc, (xbc + 43)
	call ToneGen_WriteExprReg
	jr Voice_Step_ExprRamp_DispatchMode

; Body of Voice_Step_ExprRamp (entry 0x026EC3, already named -- left alone). That
; routine drives the per-slot glide/fade state word at slot+49: bits 0..6 are a delay
; counter, bits 12..14 select the ramp mode, bit 15 marks the state machine active.
; This label is the second of three arms selecting which TG register-0x180 value to write
; before dispatching: part-record byte (0x04138E + part*0x11F) == 2.
Voice_Step_ExprRamp_ModeCheck2:
	ld xwa, (xsp + 4)
	ld a, (xwa + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2518:24)
	cp	(xbc+wa), 0x02
	jr nz, Voice_Step_ExprRamp_ModeDefault
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	ld xbc, (xsp + 4)
	ld bc, (xbc + 43)
	call ToneGen_WriteExprReg
	jr Voice_Step_ExprRamp_DispatchMode

; Neither part mode 1 nor 2: merge (slot+39)[+36] into the low bits of slot+43 and write
; that through ToneGen_WriteExprReg.
Voice_Step_ExprRamp_ModeDefault:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	ld l, a
	extz hl
	ld xwa, (xsp + 4)
	ld xwa, (xwa + 39)
	ld a, (xwa + 36)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld wa, (xwa + 43)
	and wa, 0xFF80
	ld de, wa
	or de, bc
	ld wa, hl
	ld bc, de
	call ToneGen_WriteExprReg
	jr Voice_Step_ExprRamp_DispatchMode

; Bit 11 of the state word clear: write slot+43 to TG register bank 0x180 unmodified.
Voice_Step_ExprRamp_ZeroState:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	ld xbc, (xsp + 4)
	ld bc, (xbc + 43)
	call ToneGen_WriteExprReg

; Dispatch on (state & 0x7000): 0x1000 -> Release ramp, 0x2000 -> Descend, 0x4000 ->
; Ascend, anything else -> NullMode (state cleared).
Voice_Step_ExprRamp_DispatchMode:
	ld wa, (xsp + 2)
	and wa, 0x7000
	cp wa, 0x1000
	jrl z, Voice_Step_ExprRamp_Release_Start
	cp wa, 0x2000
	jrl z, Voice_Step_ExprRamp_Descend_Tick
	cp wa, 0x4000
	jrl nz, Voice_Step_ExprRamp_NullMode
	ld xwa, (xsp + 4)
	ld iz, (xwa + 54)
	ld xwa, (xsp + 4)
	add iz, (xwa + 51)
	cp iz, 0xFF00
	jr gt, Voice_Step_ExprRamp_Ascend_Tick
	ld xwa, (xsp + 4)
	ldw (xwa + 51), 0xFF00
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	call Voice_Clear_HoldBit
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	call Voice_Reload_Levels
	andmi16 (xsp + 2), 0x6FFF
	jrl Voice_Step_ExprRamp_StoreDone

; Ascend arm, still ramping. Writes TG bank 0x840 = 0xFF00 directly (address latch
; 0x100000 = slot + 0x840, data latch 0x100002), with the P6.7 select driven around the
; latch pair (res/set bit 7 of SFR 0x18) -- the standard per-word sequence, documented in
; full at ToneGen_WriteVoiceParams.
; CORRECTION: SFR 0x18 is PORT 6 (shared/sfr_tmp94c241.s: `.equ P6, 0x18`), not an
; interrupt-mask register: every INTE* register on this part sits at 0xE0..0xF0. This pair
; masks nothing; the earlier "maskable-interrupt gate" wording was wrong. RESET programs the
; bit as a plain output (`ldio 0x1B,0x7F` then `ldio 0x1A,0x80` at 0x01F956/0x01F959), and
; the ASL-era listing renders the two instructions as RES/SET 7, (P6), unidasm as
; res/set 7,(0x18).
; [INFERENCE] that the pin is the CPU's A23 line taken out of bus mode. That reading has no
; datasheet or schematic behind it and symbols/proposals/subcpu-region-07.txt grades it
; UNCERTAIN; only the port identity above is established.
; The terminal value the ramp counts toward is 0xFF00; on reaching it the slot is handed
; to Voice_Clear_HoldBit + Voice_Reload_Levels and the mode bits are cleared.
Voice_Step_ExprRamp_Ascend_Tick:
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_Step_ExprRamp_Ascend_Tick2

; Second half of the same write burst: TG bank 0x800 = 0xFF80.
Voice_Step_ExprRamp_Ascend_Tick2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_Step_ExprRamp_Ascend_ClampFloor

; Clamp the ramp accumulator at the per-slot floor slot+58; on clamping, clear state bit
; 14 and set bit 13 (mode 0x4000 -> 0x2000, ascend hands over to descend).
Voice_Step_ExprRamp_Ascend_ClampFloor:
	nop
	nop
	nop
	ld xwa, (xsp + 4)
	cp iz, (xwa + 58)
	jr ge, Voice_Step_ExprRamp_Ascend_WritePitch
	ld xwa, (xsp + 4)
	ld iz, (xwa + 58)
	resm 6, (xsp + 3)
	setm 5, (xsp + 3)

; Store the accumulator to slot+51, re-derive the pitch via Voice_ApplyPortamento, then
; push the whole shadow block with ToneGen_WriteVoiceParams_Ext.
Voice_Step_ExprRamp_Ascend_WritePitch:
	ld xwa, (xsp + 4)
	ld (xwa + 51), iz
	ld xwa, (xsp + 4)
	calr Voice_ApplyPortamento
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	ld xde, (xsp + 4)
	call ToneGen_WriteVoiceParams_Ext
	jrl Voice_Step_ExprRamp_StoreDone

; Descend arm: TG bank 0x840 = 0xFF00.
Voice_Step_ExprRamp_Descend_Tick:
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_Step_ExprRamp_Descend_Tick2

; Descend arm: TG bank 0x800 = 0xFF80.
Voice_Step_ExprRamp_Descend_Tick2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_Step_ExprRamp_Descend_WritePitch

; Push the shadow block with ToneGen_WriteVoiceParams_Ext2 (no pitch recompute on this
; arm).
Voice_Step_ExprRamp_Descend_WritePitch:
	nop
	nop
	nop
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	ld xbc, (xsp + 4)
	call ToneGen_WriteVoiceParams_Ext2
	jrl Voice_Step_ExprRamp_StoreDone

; Release arm: accumulator += slot+56 (the release increment; the ascend arm uses
; slot+54). On reaching 0xFF00 the slot is released exactly as in the ascend arm.
Voice_Step_ExprRamp_Release_Start:
	ld xwa, (xsp + 4)
	ld iz, (xwa + 56)
	ld xwa, (xsp + 4)
	add iz, (xwa + 51)
	cp iz, 0xFF00
	jr gt, Voice_Step_ExprRamp_Release_Tick
	ld xwa, (xsp + 4)
	ldw (xwa + 51), 0xFF00
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	call Voice_Clear_HoldBit
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	call Voice_Reload_Levels
	andmi16 (xsp + 2), 0x6FFF
	jrl Voice_Step_ExprRamp_StoreDone

; Release arm: TG bank 0x840 = 0xFF00.
Voice_Step_ExprRamp_Release_Tick:
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_Step_ExprRamp_Release_Tick2

; Release arm: TG bank 0x800 = 0xFF80.
Voice_Step_ExprRamp_Release_Tick2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_Step_ExprRamp_Release_WritePitch

; Store to slot+51, Voice_ApplyPortamento, ToneGen_WriteVoiceParams_Ext.
Voice_Step_ExprRamp_Release_WritePitch:
	nop
	nop
	nop
	ld xwa, (xsp + 4)
	ld (xwa + 51), iz
	ld xwa, (xsp + 4)
	calr Voice_ApplyPortamento
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	ld xde, (xsp + 4)
	call ToneGen_WriteVoiceParams_Ext
	jr Voice_Step_ExprRamp_StoreDone

; Unrecognised mode bits: zero the state word so the slot stops being serviced.
Voice_Step_ExprRamp_NullMode:
	ldw (xsp + 2), 0x0
	jr Voice_Step_ExprRamp_StoreDone

; Delay-counter arm, taken when (state & 0x7F) != 0: the ramp has not started yet.
; When the counter is exactly 1 it emits the "pre-roll" TG values (bank 0x840 = 0xA200,
; bank 0x800 = 0xA280) before decrementing.
Voice_Step_ExprRamp_ActiveCount:
	ld wa, (xsp + 2)
	and wa, 0x7F
	cp wa, 1:i3
	jr nz, Voice_Step_ExprRamp_CountDecrement
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa200
	jr Voice_Step_ExprRamp_CountTick

; Second half of the pre-roll burst: TG bank 0x800 = 0xA280.
Voice_Step_ExprRamp_CountTick:
	nop
	nop
	nop
	res	7, (P6:8)
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa280
	jr Voice_Step_ExprRamp_CountTick2

; Decrement the delay counter and fall through to the store.
Voice_Step_ExprRamp_CountTick2:
	nop
	nop
	nop
	decm 1, (xsp + 2)
	jr Voice_Step_ExprRamp_StoreDone

; Ordinary delay tick (counter != 1): just decrement.
Voice_Step_ExprRamp_CountDecrement:
	decm 1, (xsp + 2)

; Write the state word back to slot+49 and return.
Voice_Step_ExprRamp_StoreDone:
	ld xwa, (xsp + 4)
	ld bc, (xsp + 2)
	ld (xwa + 49), bc
	popw iz
	inc 6, xsp
	ret

Pitch_Bend_Ramp_Tick:
	ld wa, (Voice_GlobalFlags:24)
	bit 11, wa
	jr z, Pitch_Bend_Ramp_Tick_Bit12
	incw 1, (Payload_Bss_Start+0x24e6:24)
	ld a, (Voice_KeyShiftRamp_Steps:24)
	exts wa
	add wa, wa
	ld (Payload_Bss_Start+0x24e4:24), wa
	andw (Voice_GlobalFlags:24), 63487
	orw (Voice_GlobalFlags:24), 5120
	ret

; Body of Pitch_Bend_Ramp_Tick (entry 0x0271BC, already named -- left alone). That
; routine is the once-per-audio-tick step of the KEY SHIFT / transpose ramp, driven
; entirely by the global mode word at 0x041343:
;   bit 11 = "shift requested" (set by Voice_SetKeyShiftEnable). Loads the first entry of
;            the signed semitone table at 0x011C7C, doubles it into the global pitch
;            offset word 0x04135A, clears bit 11 and sets bits 10 and 12.
;   bit 12 = "shift engaged". THIS LABEL: bump the step index 0x04135C and clear bit 10.
;   bit 13 = "ramping"; bit 14 -> step index += 2, bit 15 -> step index += 1. Each step
;            reloads 0x04135A = table_0x011C7C[index] * 2 and sets bit 10.
;   bit 10 = "pitch offset changed" -- consumed by Audio_Tick_ServiceVoices_B, which uses
;            it to choose the loop arm that re-writes every sounding voice's pitch.
; The ramp self-terminates when the loaded offset is zero: entries 24 and 25 of the
; 26-byte table are 0x00, and both the +1 and +2 step sequences from index 0 land on 24.
; Also read by Voice_ComputePitch (bits 0/1) and Voice_ApplyPortamento (bit 1).
Pitch_Bend_Ramp_Tick_Bit12:
	ld wa, (Voice_GlobalFlags:24)
	bit 12, wa
	jr z, Pitch_Bend_Ramp_Tick_Bit13Check
	incw 1, (Payload_Bss_Start+0x24e6:24)
	andw (Voice_GlobalFlags:24), 64511
	ret

; bit 13 clear -> ClearMode; set -> choose the +2 (bit 14) or +1 (bit 15) step.
Pitch_Bend_Ramp_Tick_Bit13Check:
	ld wa, (Voice_GlobalFlags:24)
	bit 13, wa
	jrl z, Pitch_Bend_Ramp_Tick_ClearMode
	ld wa, (Voice_GlobalFlags:24)
	bit 14, wa
	jr z, Pitch_Bend_Ramp_Tick_Bit14Clear
	incw 2, (Payload_Bss_Start+0x24e6:24)
	ld wa, (Payload_Bss_Start+0x24e6:24)
	extz xwa
	ld xbc, Voice_KeyShiftRamp_Steps
	add xbc, xwa
	ld a, (xbc)
	exts wa
	add wa, wa
	ld (Payload_Bss_Start+0x24e4:24), wa
	orw (Voice_GlobalFlags:24), 1024
	jr Pitch_Bend_Ramp_Tick_CheckCounter

; bit 14 clear: if bit 15 is set take the +1 step, otherwise zero the offset.
Pitch_Bend_Ramp_Tick_Bit14Clear:
	ld wa, (Voice_GlobalFlags:24)
	extz xwa
	bit 15, wa
	jr z, Pitch_Bend_Ramp_Tick_ZeroPitch
	incw 1, (Payload_Bss_Start+0x24e6:24)
	ld wa, (Payload_Bss_Start+0x24e6:24)
	extz xwa
	ld xbc, Voice_KeyShiftRamp_Steps
	add xbc, xwa
	ld a, (xbc)
	exts wa
	add wa, wa
	ld (Payload_Bss_Start+0x24e4:24), wa
	orw (Voice_GlobalFlags:24), 1024
	jr Pitch_Bend_Ramp_Tick_CheckCounter

; No direction bit set: force the global pitch offset 0x04135A to 0 and raise bit 10.
Pitch_Bend_Ramp_Tick_ZeroPitch:
	ldw (Payload_Bss_Start+0x24e4:24), 0x0000
	orw (Voice_GlobalFlags:24), 1024

; Termination test: return unless the offset word 0x04135A is now zero; when it is, clear
; bits 13..15 of 0x041343, reset the step index 0x04135C and raise bit 10 one last time.
Pitch_Bend_Ramp_Tick_CheckCounter:
	cpw (Payload_Bss_Start+0x24e4:24), 0
	ret nz
	andw (Voice_GlobalFlags:24), 8191
	ldw (Payload_Bss_Start+0x24e6:24), 0x0000
	orw (Voice_GlobalFlags:24), 1024
	ret

; Ramp inactive: clear bit 10 and return.
Pitch_Bend_Ramp_Tick_ClearMode:
	andw (Voice_GlobalFlags:24), 64511
	ret

; Voice_InitVoiceState(WA = channel index). Loads the whole 22-word tone-generator shadow
; block at 0x0451CC with power-on defaults, immediately before the caller pushes it to
; the chip. Sole caller: Voice_TickNoteDecay.
; Notable defaults: 0x0451E4 = 0xFF7F (register pair 1 = maximum attenuation, maximum
; rate -- i.e. silent); 0x0451E6 and 0x0451E8 copied from the global word 0x041362 (set
; to 0x8000 or 0xA000 by Voice_SetRhythmMode); 0x0451DA from 0x041360; 0x0451D4 = 0x017F,
; 0x0451D6 = 0x7F7F, 0x0451D8 = 0x0040; 0x0451D0 = table_0x010764[0x041364] * 4; every
; other word zeroed. Finally stores 0xF0 into the per-channel record byte at
; 0x0430BB + ch*0x47.
Voice_InitVoiceState:
	ldw (Payload_Bss_Start+0x6358:24), 0x0000
	ld bc, (Payload_Bss_Start+0x24ea:24)
	ld (Payload_Bss_Start+0x6364:24), bc
	ldw (Payload_Bss_Start+0x6376:24), 0x0000
	ldw (Payload_Bss_Start+0x6378:24), 0x0000
	ldw (Payload_Bss_Start+0x637a:24), 0x0000
	ldw (Payload_Bss_Start+0x635e:24), 0x017f
	ldw (Payload_Bss_Start+0x6360:24), 0x7f7f
	ldw (Payload_Bss_Start+0x637c:24), 0x0000
	ldw (Payload_Bss_Start+0x637e:24), 0x0000
	ldw (Payload_Bss_Start+0x6380:24), 0x0000
	ldw (Payload_Bss_Start+0x636c:24), 0x0000
	ldw (Payload_Bss_Start+0x6374:24), 0x0000
	ldw (Payload_Bss_Start+0x6366:24), 0x0000
	ldw (Payload_Bss_Start+0x6368:24), 0x0000
	ldw (Payload_Bss_Start+0x6362:24), 0x0040
	ldw (Payload_Bss_Start+0x636a:24), 0x0000
	ldw (Payload_Bss_Start+0x635c:24), 0x0000
	ldw (Payload_Bss_Start+0x636e:24), 0xff7f
	ld bc, (Payload_Bss_Start+0x24ec:24)
	ld (Payload_Bss_Start+0x6370:24), bc
	ld bc, (Payload_Bss_Start+0x24ec:24)
	ld (Payload_Bss_Start+0x6372:24), bc
	ld bc, (Payload_Bss_Start+0x24ee:24)
	add bc, bc
	lda xde, (Voice_OutputLevel_Table:24)
	ld	bc, (xde+bc)
	add bc, bc
	ld (Payload_Bss_Start+0x635a:24), bc
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4245:24)
	ldw	(xbc+wa), 0xf000
	ret

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
Voice_LoadPitchTable_Ch:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), c
	ld (xsp + 8), a
	ld a, (xsp + 8)
	extz wa
	ld bc, 1:i3
	call DSP_AlgoType_Dispatch2
	extz xhl
	ld a, (xsp + 6)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 8
	cp xhl, 0x2C
	jr nc, Voice_LoadPitchTable_Ch_NoClamp
	ldw (Payload_Bss_Start+0x6392:24), 0x002c
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x254f:24)
	ldw	(xbc+wa), 0x002c
	jr Voice_LoadPitchTable_Ch_ScanLoop

; Scaled value already >= 0x2C: store it unclamped.
Voice_LoadPitchTable_Ch_NoClamp:
	ld wa, hl
	ld (Payload_Bss_Start+0x6392:24), wa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x254f:24)
	ld	(xbc+wa), hl

; Second parameter (Dispatch1 * table_0x010DCE[C]) and the output-list build.
Voice_LoadPitchTable_Ch_ScanLoop:
	ld a, (xsp + 8)
	extz wa
	ld bc, 1:i3
	call DSP_AlgoType_Dispatch1
	extz xhl
	ld a, (xsp + 6)
	extz wa
	lda xbc, (Voice_PitchDepth_Scale:24)
	ld	a, (xbc+wa)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 8
	ld wa, hl
	ld (Payload_Bss_Start+0x6396:24), wa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x254d:24)
	ld	(xbc+wa), hl
	ld a, (xsp + 8)
	extz wa
	ldw bc, 0xD
	ld de, 0:i3
	call Voice_BuildOutputList
	ld (xsp + 2), xhl
	ld iz, 0:i3
	jr Voice_LoadPitchTable_Ch_LoopCheck

; Per-voice broadcast via ToneGen_WriteExtParams_56.
Voice_LoadPitchTable_Ch_LoopBody:
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 2)
	ld wa, (xwa)
	ld w, 0x0:opc
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56
	inc 1, iz

; Continue while the list entry's low byte is < 0x80.
Voice_LoadPitchTable_Ch_LoopCheck:
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 2)
	ld wa, (xwa)
	and wa, 0xFF
	cp wa, 0x80
	jr c, Voice_LoadPitchTable_Ch_LoopBody
	popw iz
	inc 8, xsp
	ret

; Voice_LoadPitchTable_All(A = part index). The ramp-position-independent form of
; Voice_LoadPitchTable_Ch: stores the raw DSP_AlgoType_Dispatch2/Dispatch1 results to
; 0x045208 and 0x04520C (no scaling, no per-part write-back) and broadcasts them with the
; same ToneGen_WriteExtParams_56 loop.
; Sole caller: Voice_ToneTableRamp_Up, when the pitch ramp has reached its ceiling.
Voice_LoadPitchTable_All:
	dec 8, xsp
	ld (xsp + 6), a
	ld a, (xsp + 6)
	extz wa
	ld bc, 1:i3
	call DSP_AlgoType_Dispatch2
	ld (Payload_Bss_Start+0x6392:24), hl
	ld a, (xsp + 6)
	extz wa
	ld bc, 1:i3
	call DSP_AlgoType_Dispatch1
	ld (Payload_Bss_Start+0x6396:24), hl
	ld a, (xsp + 6)
	extz wa
	ldw bc, 0xD
	ld de, 0:i3
	call Voice_BuildOutputList
	ld (xsp), xhl
	ldw (xsp + 4), 0x0
	jr Voice_LoadPitchTable_All_LoopCheck

; Per-voice broadcast body.
Voice_LoadPitchTable_All_LoopBody:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	ld w, 0x0:opc
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56
	incw 1, (xsp + 4)

; Continue while the list entry's low byte is < 0x80.
Voice_LoadPitchTable_All_LoopCheck:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	and wa, 0xFF
	cp wa, 0x80
	jr c, Voice_LoadPitchTable_All_LoopBody
	inc 8, xsp
	ret

; Voice_LoadFilterTable_Ch(A = part index, C = ramp position). Same shape as
; Voice_LoadPitchTable_Ch for the filter parameter set: DSP_AlgoType_Dispatch2(part, 0)
; scaled by C, floored at 0x1C, into 0x04520A and 0x0413C1 + part*0x11F;
; DSP_AlgoType_Dispatch1(part, 0) scaled by table_0x010ECE[C] into 0x04520E and
; 0x0413BF + part*0x11F; broadcast with Voice_BuildOutputList(part, 0x0C, 0) and
; ToneGen_WriteExtParams_56b.
Voice_LoadFilterTable_Ch:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), c
	ld (xsp + 8), a
	ld a, (xsp + 8)
	extz wa
	ld bc, 0:i3
	call DSP_AlgoType_Dispatch2
	extz xhl
	ld a, (xsp + 6)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 8
	cp xhl, 0x1C
	jr nc, Voice_LoadFilterTable_Ch_NoClamp
	ldw (Payload_Bss_Start+0x6394:24), 0x001c
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x254b:24)
	ldw	(xbc+wa), 0x001c
	jr Voice_LoadFilterTable_Ch_ScanFilter

; Scaled value already >= 0x1C: store unclamped.
Voice_LoadFilterTable_Ch_NoClamp:
	ld wa, hl
	ld (Payload_Bss_Start+0x6394:24), wa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x254b:24)
	ld	(xbc+wa), hl

; Second filter parameter and the output-list build.
Voice_LoadFilterTable_Ch_ScanFilter:
	ld a, (xsp + 8)
	extz wa
	ld bc, 0:i3
	call DSP_AlgoType_Dispatch1
	extz xhl
	ld a, (xsp + 6)
	extz wa
	lda xbc, (Voice_FilterDepth_Scale:24)
	ld	a, (xbc+wa)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 8
	ld wa, hl
	ld (Payload_Bss_Start+0x6398:24), wa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2549:24)
	ld	(xbc+wa), hl
	ld a, (xsp + 8)
	extz wa
	ldw bc, 0xC
	ld de, 0:i3
	call Voice_BuildOutputList
	ld (xsp + 2), xhl
	ld iz, 0:i3
	jr Voice_LoadFilterTable_Ch_LoopCheck

; Per-voice broadcast via ToneGen_WriteExtParams_56b.
Voice_LoadFilterTable_Ch_LoopBody:
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 2)
	ld wa, (xwa)
	ld w, 0x0:opc
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56b
	inc 1, iz

; Continue while the list entry's low byte is < 0x80.
Voice_LoadFilterTable_Ch_LoopCheck:
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 2)
	ld wa, (xwa)
	and wa, 0xFF
	cp wa, 0x80
	jr c, Voice_LoadFilterTable_Ch_LoopBody
	popw iz
	inc 8, xsp
	ret

; Voice_LoadFilterTable_All(A = part index). Unscaled counterpart of
; Voice_LoadFilterTable_Ch; writes 0x04520A / 0x04520E and broadcasts with
; ToneGen_WriteExtParams_56b. Sole caller: Voice_ToneTableRamp_Up_CheckFilter.
Voice_LoadFilterTable_All:
	dec 8, xsp
	ld (xsp + 6), a
	ld a, (xsp + 6)
	extz wa
	ld bc, 0:i3
	call DSP_AlgoType_Dispatch2
	ld (Payload_Bss_Start+0x6394:24), hl
	ld a, (xsp + 6)
	extz wa
	ld bc, 0:i3
	call DSP_AlgoType_Dispatch1
	ld (Payload_Bss_Start+0x6398:24), hl
	ld a, (xsp + 6)
	extz wa
	ldw bc, 0xC
	ld de, 0:i3
	call Voice_BuildOutputList
	ld (xsp), xhl
	ldw (xsp + 4), 0x0
	jr Voice_LoadFilterTable_All_LoopCheck

; Per-voice broadcast body.
Voice_LoadFilterTable_All_LoopBody:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	ld w, 0x0:opc
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56b
	incw 1, (xsp + 4)

; Continue while the list entry's low byte is < 0x80.
Voice_LoadFilterTable_All_LoopCheck:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	and wa, 0xFF
	cp wa, 0x80
	jr c, Voice_LoadFilterTable_All_LoopBody
	inc 8, xsp
	ret

; Voice_LoadToneTable_Ch(A = part index, C = ramp position). Third member of the family.
; Uses DSP_ChanFreq_WritePacket2(part) as its source value, scales it by C, floors at
; 0x1C, stores to 0x045206 and to 0x0413C9 + part*0x11F, then broadcasts with
; Voice_BuildOutputList(part, 0x10, 0) and ToneGen_WriteExtParams_15_Alt.
; Note its list terminator differs: the loop runs while (entry & 0xFF) < 0x40, not 0x80.
Voice_LoadToneTable_Ch:
	lda xsp, (xsp - 10)
	ld (xsp + 6), c
	ld (xsp + 8), a
	ld a, (xsp + 8)
	extz wa
	call DSP_ChanFreq_WritePacket2
	extz xhl
	ld a, (xsp + 6)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 8
	cp xhl, 0x1C
	jr nc, Voice_LoadToneTable_Ch_NoClamp
	ldw (Payload_Bss_Start+0x6390:24), 0x001c
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2553:24)
	ldw	(xbc+wa), 0x001c
	jr Voice_LoadToneTable_Ch_ScanLoop

; Scaled value already >= 0x1C: store unclamped.
Voice_LoadToneTable_Ch_NoClamp:
	ld wa, hl
	ld (Payload_Bss_Start+0x6390:24), wa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2553:24)
	ld	(xbc+wa), hl

; Build the output list for mask 0x10.
Voice_LoadToneTable_Ch_ScanLoop:
	ld a, (xsp + 8)
	extz wa
	ldw bc, 0x10
	ld de, 0:i3
	call Voice_BuildOutputList
	ld (xsp), xhl
	ldw (xsp + 4), 0x0
	jr Voice_LoadToneTable_Ch_LoopCheck

; Per-voice broadcast via ToneGen_WriteExtParams_15_Alt.
Voice_LoadToneTable_Ch_LoopBody:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	ld w, 0x0:opc
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_15_Alt
	incw 1, (xsp + 4)

; Continue while the list entry's low byte is < 0x40.
Voice_LoadToneTable_Ch_LoopCheck:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	and wa, 0xFF
	cp wa, 0x40
	jr c, Voice_LoadToneTable_Ch_LoopBody
	lda xsp, (xsp + 10)
	ret

; Voice_LoadToneTable_All(A = part index). Unscaled counterpart of
; Voice_LoadToneTable_Ch. Sole caller: Voice_ToneTableRamp_Up_CheckFilter.
Voice_LoadToneTable_All:
	dec 8, xsp
	ld (xsp + 6), a
	ld a, (xsp + 6)
	extz wa
	call DSP_ChanFreq_WritePacket2
	ld (Payload_Bss_Start+0x6390:24), hl
	ld a, (xsp + 6)
	extz wa
	ldw bc, 0x10
	ld de, 0:i3
	call Voice_BuildOutputList
	ld (xsp), xhl
	ldw (xsp + 4), 0x0
	jr Voice_LoadToneTable_All_LoopCheck

; Per-voice broadcast body.
Voice_LoadToneTable_All_LoopBody:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	ld w, 0x0:opc
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_15_Alt
	incw 1, (xsp + 4)

; Continue while the list entry's low byte is < 0x40.
Voice_LoadToneTable_All_LoopCheck:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	add xwa, (xsp)
	ld wa, (xwa)
	and wa, 0xFF
	cp wa, 0x40
	jr c, Voice_LoadToneTable_All_LoopBody
	inc 8, xsp
	ret

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
Voice_ToneTableRamp_Up:
	dec 4, xsp
	push xiz
	ld xiz, xbc
	ld (xsp + 6), a
	cp (xiz + 100), 0x4F
	jr c, Voice_ToneTableRamp_Up_Increment
	setm 3, (xiz + 99)
	ld a, (xsp + 6)
	extz wa
	calr Voice_LoadPitchTable_All
	jr Voice_ToneTableRamp_Up_CheckFilter

; Pitch ramp not yet at 0x4F: ++position, clear flag bit 3, push the new value.
Voice_ToneTableRamp_Up_Increment:
	incm8 1, (xiz + 100)
	resm 3, (xiz + 99)
	ld a, (xiz + 100)
	ld (xsp + 4), a
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_ToneRampPitch_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadPitchTable_Ch

; Filter ramp: at 0x96 -> Voice_LoadFilterTable_All + Voice_LoadToneTable_All.
Voice_ToneTableRamp_Up_CheckFilter:
	cp (xiz + 101), 0x96
	jr c, Voice_ToneTableRamp_Up_FilterIncrement
	ld a, (xsp + 6)
	extz wa
	calr Voice_LoadFilterTable_All
	ld a, (xsp + 6)
	extz wa
	calr Voice_LoadToneTable_All
	jr Voice_ToneTableRamp_Up_Done

; ++filter position, clear flag bit 3, push table_0x010DB4[pos/6] to both the filter and
; tone parameter sets.
Voice_ToneTableRamp_Up_FilterIncrement:
	incm8 1, (xiz + 101)
	resm 3, (xiz + 99)
	ld a, (xiz + 101)
	extz wa
	div a, 0x6
	ld (xsp + 4), a
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadFilterTable_Ch
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadToneTable_Ch

; Restore and return.
Voice_ToneTableRamp_Up_Done:
	pop xiz
	inc 4, xsp
	ret

; Voice_ToneTableRamp_Down(A = part index, XBC = part record). The mirror of
; Voice_ToneTableRamp_Up: when +100 is already 0 it sets flag bit 4 and skips to the
; filter half; otherwise it decrements +100, clears bit 4, and pushes
; table_0x010DB4[+100 >> 1]. The filter half decrements +101 and pushes
; table_0x010DB4[+101 / 5] to both the filter and tone parameter sets.
; Sole caller: Audio_Tick_ServiceVoices_B_LFO_CheckRampDown.
; ⚠ The two halves index the SAME 26-entry table 0x010DB4 with different scales -- >>1
; (max 0x4F/2 = 39) and /5 (max 0x96/5 = 30) -- both of which exceed the table's 26
; entries and read into the adjacent table at 0x010DCE. See [UNCERTAIN].
Voice_ToneTableRamp_Down:
	dec 4, xsp
	push xiz
	ld xiz, xbc
	ld (xsp + 6), a
	cp (xiz + 100), 0x0
	jr nz, Voice_ToneTableRamp_Down_Decrement
	setm 4, (xiz + 99)
	jr Voice_ToneTableRamp_Down_CheckFilter

; Pitch ramp above 0: --position, clear flag bit 4, push table_0x010DB4[pos >> 1].
Voice_ToneTableRamp_Down_Decrement:
	decm8 1, (xiz + 100)
	resm 4, (xiz + 99)
	ld a, (xiz + 100)
	srl a, 1
	ld (xsp + 4), a
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadPitchTable_Ch

; Filter ramp: return if already 0, else --position and push table_0x010DB4[pos / 5].
Voice_ToneTableRamp_Down_CheckFilter:
	cp (xiz + 101), 0x0
	jr z, Voice_ToneTableRamp_Down_Done
	decm8 1, (xiz + 101)
	resm 4, (xiz + 99)
	ld a, (xiz + 101)
	extz wa
	div a, 0x5
	ld (xsp + 4), a
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadFilterTable_Ch
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadToneTable_Ch

; Restore and return.
Voice_ToneTableRamp_Down_Done:
	pop xiz
	inc 4, xsp
	ret

; Voice_ToneTableApply_Pitch(A = part index, XBC = part record). Jumps the ramp straight
; to the position that matches the current pitch value, instead of stepping.
; Clears flag bits 3 and 4 of +99, reads L = table_0x010D64[+100], then searches DOWNWARD
; from index 0x19 for the largest index whose table_0x010DB4 entry is <= L. That index
; becomes the new +100; +101 is rescaled from the /6 domain into the /5 domain
; ((+101 / 6) is discarded and the found index * 5 is stored). Finally it pushes all
; three parameter sets with Voice_LoadPitchTable_Ch, Voice_LoadFilterTable_Ch and
; Voice_LoadToneTable_Ch.
; Sole caller: Audio_Tick_ServiceVoices_B_LFO_RampDown.
Voice_ToneTableApply_Pitch:
	dec 6, xsp
	pushw_erp 0xFA
	ld (xsp + 2), xbc
	ld (xsp + 6), a
	ld xwa, (xsp + 2)
	andmi8 (xwa + 99), 0xE7
	ld xwa, (xsp + 2)
	ld a, (xwa + 100)
	extz wa
	lda xbc, (Voice_ToneRampPitch_Curve:24)
	ld	l, (xbc+wa)
	ldi_erpb 0xFB, 0x19
	jr Voice_ToneTableApply_Pitch_Loop

; Search step: decrement the candidate index.
Voice_ToneTableApply_Pitch_Decrement:
	dec1b_erp 0xFB

; Search test: continue while L < table_0x010DB4[index]. The loop has no explicit lower
; bound; it is bounded only by table_0x010DB4[0] == 0x00, which no unsigned L can be
; below, so index 0 always terminates it.
Voice_ToneTableApply_Pitch_Loop:
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	cp	l, (xbc+wa)
	jr c, Voice_ToneTableApply_Pitch_Decrement
	ld xwa, (xsp + 2)
	ldto_berp C, 0xFB
	ld (xwa + 100), c
	ld a, (xsp + 6)
	ld e, a
	extz de
	ld a, l
	extz wa
	lda xbc, (Voice_ToneRampPitch_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadPitchTable_Ch
	ld xwa, (xsp + 2)
	ld l, (xwa + 101)
	ld a, l
	extz wa
	div a, 0x6
	ld l, a
	ldfr_berp L, 0xFB
	ld a, l
	mul a, 0x5
	ld l, a
	ld xwa, (xsp + 2)
	ld (xwa + 101), l
	ld a, (xsp + 6)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadFilterTable_Ch
	ld a, (xsp + 6)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadToneTable_Ch
	popw_erp 0xFA
	inc 6, xsp
	ret

; Voice_ToneTableApply_Filter(A = part index, XBC = part record). The mirror of
; Voice_ToneTableApply_Pitch: reads E = table_0x010DB4[+100 >> 1] and searches UPWARD
; from index 0 for the first index whose table_0x010D64 entry is >= E. That index becomes
; +100; +101 is rescaled from the /5 domain into the /6 domain (index * 6). Then pushes
; all three parameter sets with the three _Ch broadcasters.
; Sole caller: Audio_Tick_ServiceVoices_B_LFO_ApplyFilter.
Voice_ToneTableApply_Filter:
	dec 6, xsp
	pushw_erp 0xFA
	ld (xsp + 2), xbc
	ld (xsp + 6), a
	ld xwa, (xsp + 2)
	andmi8 (xwa + 99), 0xE7
	ld xwa, (xsp + 2)
	ld a, (xwa + 100)
	srl a, 1
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	e, (xbc+wa)
	ldib_erp 0xFB, 0
	jr Voice_ToneTableApply_Filter_Loop

; Search step: increment the candidate index.
Voice_ToneTableApply_Filter_Increment:
	inc1b_erp 0xFB

; Search test: continue while E > table_0x010D64[index] (unsigned). The loop has no
; explicit upper bound; it is bounded only by the fact that table_0x010D64 reaches 0xFF
; at index 78 of its 80 entries.
Voice_ToneTableApply_Filter_Loop:
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampPitch_Curve:24)
	cp	e, (xbc+wa)
	jr ugt, Voice_ToneTableApply_Filter_Increment
	ld xwa, (xsp + 2)
	ldto_berp C, 0xFB
	ld (xwa + 100), c
	ld a, (xsp + 6)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadPitchTable_Ch
	ld xwa, (xsp + 2)
	ld e, (xwa + 101)
	ld a, e
	extz wa
	div a, 0x5
	ld e, a
	ldfr_berp E, 0xFB
	ld a, e
	mul a, 0x6
	ld e, a
	ld xwa, (xsp + 2)
	ld (xwa + 101), e
	ld a, (xsp + 6)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadFilterTable_Ch
	ld a, (xsp + 6)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (Voice_ToneRampFilter_Curve:24)
	ld	c, (xbc+wa)
	ld wa, de
	calr Voice_LoadToneTable_Ch
	popw_erp 0xFA
	inc 6, xsp
	ret

Audio_Tick_ServiceVoices_A:
	dec 4, xsp
	push xiz
	calr Voice_UpdateAllLFO
	call Voice_Query_AllChannels
	lda xwa, (xhl + 5)
	ld (xsp + 4), xwa
	cp (xwa), 0x40
	jr nc, Audio_Tick_ServiceVoices_A_Done

; Body of Audio_Tick_ServiceVoices_A (entry 0x027A46, already named -- left alone).
; That routine is the EVEN phase of the audio tick: it calls Voice_UpdateAllLFO once,
; then Voice_Query_AllChannels to obtain the list of sounding slot indices at (XHL+5), and
; walks it. XIZ is loaded here as 0x04308E + slot*0x47 (the voice-slot record base and
; stride; the LLVM source spells the instruction as the raw-encoding pseudo-op
; "lda_dri XIZ, 0x07,0xE4,0xE0", which unidasm decodes as "lda XIZ,XBC+WA").
; Per slot: if bit 15 of tonerec[+10] is set and (slot+47 & 0x8080) is non-zero, call
; Voice_Step_DelayTimers; if the bit is clear and the timers are armed, release the slot
; outright (Voice_Clear_HoldBit + Voice_Reload_Levels, slot+47 = 0).
; The routine's remaining labels (_ClearSlot 0x027A91, _NextSlot 0x027AB3,
; _Done 0x027AC0) fall past this region's upper boundary.
Audio_Tick_ServiceVoices_A_Loop:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	lda	xiz, (xbc+wa)
	ld xwa, (xiz + 35)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_A_ClearSlot
	ld wa, (xiz + 47)
	extz xwa
	and xwa, 0x8080
	jr z, Audio_Tick_ServiceVoices_A_NextSlot
	ld xwa, xiz
	calr Voice_Step_DelayTimers
	jr Audio_Tick_ServiceVoices_A_NextSlot

; Release path of Audio_Tick_ServiceVoices_A (entry 0x027A46, just below this region).
; Reached when the word at [voice+0x23]+0x0A has bit 15 CLEAR, i.e. the voice's tone record
; says the note is not still being held by the envelope.  If (voice+0x2F) & 0x8080 is non-zero
; (a note-off or a portamento-off request is pending) the voice is handed back:
;   call Voice_Clear_HoldBit (0x022587), call Voice_Reload_Levels (0x02CD71), then (voice+0x2F)=0.
; If neither request bit is set the voice is left alone and the walk continues.
; This is one of only two places in the whole sub-CPU where a sounding voice is returned to
; the free pool during normal play; the other is Audio_Tick_ServiceVoices_B below.
Audio_Tick_ServiceVoices_A_ClearSlot:
	ld wa, (xiz + 47)
	extz xwa
	and xwa, 0x8080
	jr z, Audio_Tick_ServiceVoices_A_NextSlot
	ld a, (xiz)
	extz wa
	call Voice_Clear_HoldBit
	ld a, (xiz)
	extz wa
	call Voice_Reload_Levels
	ldw (xiz + 47), 0x0

; Advance the per-part voice-index cursor by 1 and loop while *cursor < 0x40 (0x40 = list end).
Audio_Tick_ServiceVoices_A_NextSlot:
	ld xwa, 1:i3
	add (xsp + 4), xwa
	ld xwa, (xsp + 4)
	cp (xwa), 0x40
	jr c, Audio_Tick_ServiceVoices_A_Loop

; Restore XIZ and return.
Audio_Tick_ServiceVoices_A_Done:
	pop xiz
	inc 4, xsp
	ret

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
Audio_Tick_ServiceVoices_B:
	dec 4, xsp
	push xiz
	calr Voice_TickNoteDecay
	calr Pitch_Bend_Ramp_Tick
	ld wa, (Voice_GlobalFlags:24)
	bit 10, wa
	jrl z, Audio_Tick_ServiceVoices_B_LoopB_Start
	call Voice_Query_AllChannels
	lda xwa, (xhl + 5)
	ld (xsp + 4), xwa
	cp (xwa), 0x40
	jrl nc, Audio_Tick_ServiceVoices_B_ScanLFO

; Loop A body: full update including the tone-generator pitch and pan re-writes.
Audio_Tick_ServiceVoices_B_LoopA:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	lda	xiz, (xbc+wa)
	ld wa, (xiz + 1)
	bit 10, wa
	jr z, Audio_Tick_ServiceVoices_B_CheckPortaA
	ld xwa, xiz
	calr Pitch_Emit_Reg400
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteVoicePitch

; Load the tone record pointer from voice+0x23 and test bit 15 of its +0x0A word.
Audio_Tick_ServiceVoices_B_CheckPortaA:
	ld xwa, (xiz + 35)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_B_ClearNoteOffA
	ld wa, (xiz + 47)
	extz xwa
	and xwa, 0x8080
	jr z, Audio_Tick_ServiceVoices_B_CheckPortamento2A
	ld xwa, xiz
	calr Voice_Step_DelayTimers
	jr Audio_Tick_ServiceVoices_B_NextSlotA

; Note-off not pending: test the portamento-active word (voice+0x31) bit 15.
Audio_Tick_ServiceVoices_B_CheckPortamento2A:
	ld wa, (xiz + 49)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_B_NextSlotA
	ld xwa, xiz
	calr Voice_Step_ExprRamp
	jr Audio_Tick_ServiceVoices_B_NextSlotA

; Tone record says "not held": release the voice if (voice+0x2F) & 0x8080, then zero it.
Audio_Tick_ServiceVoices_B_ClearNoteOffA:
	ld wa, (xiz + 47)
	extz xwa
	and xwa, 0x8080
	jr z, Audio_Tick_ServiceVoices_B_ClearPorta2A
	ld a, (xiz)
	extz wa
	call Voice_Clear_HoldBit
	ld a, (xiz)
	extz wa
	call Voice_Reload_Levels
	ldw (xiz + 47), 0x0
	jr Audio_Tick_ServiceVoices_B_NextSlotA

; Same, driven by the portamento word (voice+0x31) instead; zeroes (voice+0x31).
Audio_Tick_ServiceVoices_B_ClearPorta2A:
	ld wa, (xiz + 49)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_B_NextSlotA
	ld a, (xiz)
	extz wa
	call Voice_Clear_HoldBit
	ld a, (xiz)
	extz wa
	call Voice_Reload_Levels
	ldw (xiz + 49), 0x0

; Advance the loop-A cursor; loop while *cursor < 0x40.
Audio_Tick_ServiceVoices_B_NextSlotA:
	ld xwa, 1:i3
	add (xsp + 4), xwa
	ld xwa, (xsp + 4)
	cp (xwa), 0x40
	jrl c, Audio_Tick_ServiceVoices_B_LoopA
	jrl Audio_Tick_ServiceVoices_B_ScanLFO

; Entry to loop B (global flag 0x041343 bit 10 clear): re-fetch the part voice list.
Audio_Tick_ServiceVoices_B_LoopB_Start:
	call Voice_Query_AllChannels
	lda xwa, (xhl + 5)
	ld (xsp + 4), xwa
	cp (xwa), 0x40
	jrl nc, Audio_Tick_ServiceVoices_B_ScanLFO

; Loop B body: retire/portamento bookkeeping only, no TG register writes.
Audio_Tick_ServiceVoices_B_LoopB:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	lda	xiz, (xbc+wa)
	ld xwa, (xiz + 35)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_B_ClearNoteOffB
	ld wa, (xiz + 47)
	extz xwa
	and xwa, 0x8080
	jr z, Audio_Tick_ServiceVoices_B_CheckPortamento2B
	ld xwa, xiz
	calr Voice_Step_DelayTimers
	jr Audio_Tick_ServiceVoices_B_NextSlotB

; CheckPortamento2B of Audio_Tick_ServiceVoices_B.
Audio_Tick_ServiceVoices_B_CheckPortamento2B:
	ld wa, (xiz + 49)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_B_NextSlotB
	ld xwa, xiz
	calr Voice_Step_ExprRamp
	jr Audio_Tick_ServiceVoices_B_NextSlotB

; ClearNoteOffB of Audio_Tick_ServiceVoices_B.
Audio_Tick_ServiceVoices_B_ClearNoteOffB:
	ld wa, (xiz + 47)
	extz xwa
	and xwa, 0x8080
	jr z, Audio_Tick_ServiceVoices_B_ClearPorta2B
	ld a, (xiz)
	extz wa
	call Voice_Clear_HoldBit
	ld a, (xiz)
	extz wa
	call Voice_Reload_Levels
	ldw (xiz + 47), 0x0
	jr Audio_Tick_ServiceVoices_B_NextSlotB

; ClearPorta2B of Audio_Tick_ServiceVoices_B.
Audio_Tick_ServiceVoices_B_ClearPorta2B:
	ld wa, (xiz + 49)
	extz xwa
	bit 15, wa
	jr z, Audio_Tick_ServiceVoices_B_NextSlotB
	ld a, (xiz)
	extz wa
	call Voice_Clear_HoldBit
	ld a, (xiz)
	extz wa
	call Voice_Reload_Levels
	ldw (xiz + 49), 0x0

; Loop-B counterparts of the loop-A labels above; identical logic minus the hardware writes.
Audio_Tick_ServiceVoices_B_NextSlotB:
	ld xwa, 1:i3
	add (xsp + 4), xwa
	ld xwa, (xsp + 4)
	cp (xwa), 0x40
	jrl c, Audio_Tick_ServiceVoices_B_LoopB

; Second phase: iterate parts 0..0x19 (stride 0x11F from 0x041368) and drive each part's
; tone-table ramp state machine from the byte at part+0x63.
Audio_Tick_ServiceVoices_B_ScanLFO:
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x1A
	jr nc, Audio_Tick_ServiceVoices_B_Done

; Decode part+0x63: b0 = enabled, b1/b2/b3/b4 select ramp-up / apply-filter / ramp-down /
; apply-pitch.  Calls Voice_ToneTableRamp_Up 0x027798, _Down 0x02783D,
; Voice_ToneTableApply_Filter 0x027987, _Pitch 0x0278CB.
Audio_Tick_ServiceVoices_B_LFOLoopBody:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)
	ld a, (xbc + 99)
	bit 0, a
	jr z, Audio_Tick_ServiceVoices_B_LFONextSlot
	bit 1, a
	jr z, Audio_Tick_ServiceVoices_B_LFO_CheckRampDown
	bit 2, a
	jr z, Audio_Tick_ServiceVoices_B_LFO_ApplyFilter
	bit 3, a
	jr nz, Audio_Tick_ServiceVoices_B_LFONextSlot
	ldto_berp A, 0xFB
	extz wa
	calr Voice_ToneTableRamp_Up
	jr Audio_Tick_ServiceVoices_B_LFONextSlot

; Sets bit 2 of part+0x63 and calls Voice_ToneTableApply_Filter.
Audio_Tick_ServiceVoices_B_LFO_ApplyFilter:
	setm 2, (xbc + 99)
	ldto_berp A, 0xFB
	extz wa
	calr Voice_ToneTableApply_Filter
	jr Audio_Tick_ServiceVoices_B_LFONextSlot

; CheckRampDown of Voice_UpdateAllNoteStates_LFO.
Audio_Tick_ServiceVoices_B_LFO_CheckRampDown:
	bit 2, a
	jr nz, Audio_Tick_ServiceVoices_B_LFO_RampDown
	bit 4, a
	jr nz, Audio_Tick_ServiceVoices_B_LFONextSlot
	ldto_berp A, 0xFB
	extz wa
	calr Voice_ToneTableRamp_Down
	jr Audio_Tick_ServiceVoices_B_LFONextSlot

; Clears bit 2 of part+0x63 and calls Voice_ToneTableApply_Pitch.
Audio_Tick_ServiceVoices_B_LFO_RampDown:
	resm 2, (xbc + 99)
	ldto_berp A, 0xFB
	extz wa
	calr Voice_ToneTableApply_Pitch

; LFONextSlot of Audio_Tick_ServiceVoices_B.
Audio_Tick_ServiceVoices_B_LFONextSlot:
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x1A
	jr c, Audio_Tick_ServiceVoices_B_LFOLoopBody

; exit path of Audio_Tick_ServiceVoices_B.
Audio_Tick_ServiceVoices_B_Done:
	pop xiz
	inc 4, xsp
	ret

; WA = part index.  ORs 0x0020 into the part flags word at part+0x02 (0x04136A + idx*0x11F).
; Called once per part from Voice_ResetAllControllers.
Voice_SetLFO_ActiveFlag:
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	orw	(xbc+wa), 0x2000
	ret

; WA = part index.  ANDs 0xFFDF into the same word.  Inverse of the above.
Voice_ClearLFO_ActiveFlag:
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	andw	(xbc+wa), 0xdfff
	ret

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
Voice_DSP_OutputConfig:
	lda	xsp, (xsp-10)
	ld	(xsp+6), c
	ld	(xsp+8), a
	cp8_imm_rid8	xsp, 0x06, 0x00	; cp (XSP+0x06),0x00
	jr	nz, Voice_DSP_OutputConfig_Skip
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	ld	c, a
	extz	bc
	ld	wa, de
	call	DSP_AlgoType_Dispatch1
	ld	(Payload_Bss_Start+0x6398:24), hl
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	extz	wa
	or	wa, 12
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp), xhl
	ldw	(xsp+4), 0x0000	; ld (XSP+0x04),0x0000
	jr	Voice_DSP_OutputConfig_Join
Voice_DSP_OutputConfig_Loop:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	ld	w, 0:opc
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteReg0640
	incw	1, (xsp+4)
Voice_DSP_OutputConfig_Join:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jr	c, Voice_DSP_OutputConfig_Loop
	jr	Voice_DSP_OutputConfig_Epilogue
Voice_DSP_OutputConfig_Skip:
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	ld	c, a
	extz	bc
	ld	wa, de
	call	DSP_AlgoType_Dispatch1
	ld	(Payload_Bss_Start+0x6396:24), hl
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	extz	wa
	or	wa, 12
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp), xhl
	ldw	(xsp+4), 0x0000	; ld (XSP+0x04),0x0000
	jr	Voice_DSP_OutputConfig_Join2
Voice_DSP_OutputConfig_Loop2:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	ld	w, 0:opc
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParam_600
	incw	1, (xsp+4)
Voice_DSP_OutputConfig_Join2:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jr	c, Voice_DSP_OutputConfig_Loop2
Voice_DSP_OutputConfig_Epilogue:
	lda	xsp, (xsp+10)
	ret
; ----------------------------------------------------------------------------
; Voice_DSP_OutputConfig2 - Configure voice-to-DSP output routing (type 2)
; Entry: A = voice number, C = channel
; Notes: Same algorithm as Voice_DSP_OutputConfig with different table offsets
; ----------------------------------------------------------------------------
; NOT PRESENT in symbols/subcpu_symbols_reference.txt -- add it.
; Same body as Voice_DSP_OutputConfig but targets shadow words 0x04520A / 0x045208.
Voice_DSP_OutputConfig2:
	lda	xsp, (xsp-10)
	ld	(xsp+6), c
	ld	(xsp+8), a
	cp8_imm_rid8	xsp, 0x06, 0x00	; cp (XSP+0x06),0x00
	jr	nz, Voice_DSP_OutputConfig2_Skip
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	ld	c, a
	extz	bc
	ld	wa, de
	call	DSP_AlgoType_Dispatch2
	ld	(Payload_Bss_Start+0x6394:24), hl
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	extz	wa
	or	wa, 12
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp), xhl
	ldw	(xsp+4), 0x0000	; ld (XSP+0x04),0x0000
	jr	Voice_DSP_OutputConfig2_Join
Voice_DSP_OutputConfig2_Loop:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	ld	w, 0:opc
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_Write_ExtParam_05C0_Strobe
	incw	1, (xsp+4)
Voice_DSP_OutputConfig2_Join:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jr	c, Voice_DSP_OutputConfig2_Loop
	jr	Voice_DSP_OutputConfig2_Epilogue
Voice_DSP_OutputConfig2_Skip:
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	ld	c, a
	extz	bc
	ld	wa, de
	call	DSP_AlgoType_Dispatch2
	ld	(Payload_Bss_Start+0x6392:24), hl
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xsp+6)
	extz	wa
	or	wa, 12
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp), xhl
	ldw	(xsp+4), 0x0000	; ld (XSP+0x04),0x0000
	jr	Voice_DSP_OutputConfig2_Join2
Voice_DSP_OutputConfig2_Loop2:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	ld	w, 0:opc
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParams_56_Alt
	incw	1, (xsp+4)
Voice_DSP_OutputConfig2_Join2:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jr	c, Voice_DSP_OutputConfig2_Loop2
Voice_DSP_OutputConfig2_Epilogue:
	lda	xsp, (xsp+10)
	ret
; ----------------------------------------------------------------------------
; Voice_DSP_SimpleCopy - Simple voice-to-DSP parameter copy
; Entry: A = voice number
; Notes: Calls DSP function at 0x033B8B, stores to 0x045204
;        Iterates voice output list (max 64 entries)
; ----------------------------------------------------------------------------
; NOT PRESENT in symbols/subcpu_symbols_reference.txt -- add it.
; A = voice.  Calls 0x033B8B, stores to 0x045204, iterates the voice output list (<= 64).
Voice_DSP_SimpleCopy:
	dec	8, xsp
	ld	(xsp+6), a
	ld	a, (xsp+6)
	extz	wa
	call	DSP_ChanFreq_WritePacket1
	ld	(Payload_Bss_Start+0x638e:24), hl
	ld	a, (xsp+6)
	extz	wa
	ldw	bc, 16
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp), xhl
	ldw	(xsp+4), 0x0000	; ld (XSP+0x04),0x0000
	jr	Voice_DSP_SimpleCopy_Join
Voice_DSP_SimpleCopy_Loop:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	ld	w, 0:opc
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParam_1C0_Single
	incw	1, (xsp+4)
Voice_DSP_SimpleCopy_Join:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 64
	jr	c, Voice_DSP_SimpleCopy_Loop
	inc	8, xsp
	ret
; ----------------------------------------------------------------------------
; Voice_DSP_SimpleCopy2 - Simple voice-to-DSP parameter copy (type 2)
; Entry: A = voice number
; Notes: Same algorithm as Voice_DSP_SimpleCopy with different offsets
; ----------------------------------------------------------------------------
; NOT PRESENT in symbols/subcpu_symbols_reference.txt -- add it.
; As above with target 0x045206 and callee 0x033C6B.
Voice_DSP_SimpleCopy2:
	dec	8, xsp
	ld	(xsp+6), a
	ld	a, (xsp+6)
	extz	wa
	call	DSP_ChanFreq_WritePacket2
	ld	(Payload_Bss_Start+0x6390:24), hl
	ld	a, (xsp+6)
	extz	wa
	ldw	bc, 16
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp), xhl
	ldw	(xsp+4), 0x0000	; ld (XSP+0x04),0x0000
	jr	Voice_DSP_SimpleCopy2_Join
Voice_DSP_SimpleCopy2_Loop:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	ld	w, 0:opc
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParams_15_Alt
	incw	1, (xsp+4)
Voice_DSP_SimpleCopy2_Join:
	ld	wa, (xsp+4)
	extz	xwa
	add	xwa, xwa
	add32_src_ri	xsp, xwa	; add XWA,(XSP)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 64
	jr	c, Voice_DSP_SimpleCopy2_Loop
	inc	8, xsp
	ret

; Writes ONE tone-generator register: latch = voice + 0x0400 (register 0x10 = PITCH),
; data = word at XBC+0x0E (normally the staging record 0x0451CC).
; Entry WA = voice number 0..0x3F, XBC = source record.  Clobbers nothing (XIZ saved).
; Caller: Pitch_Refresh_Sounding_Voices/Pitch_Refresh_Sounding_Voices (0x028D4C) and the sustain
; retrigger scan.  These four writers were prefixed DSP_WriteVoiceParam_*, which was wrong:
; they drive the TONE GENERATOR at 0x100000/0x100002, never IC311 at 0x130000.
ToneGen_WriteVoice_Long:
	push xiz
	ld xiz, xbc
	res	7, (P6:8)
	add wa, 0x400
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 14)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoice_Long_NopGap

; The mandatory 3-nop settling gap after the data write, entered by a `jr` to the next
; instruction.  Present after every single TG write in this region -- it is timing, not filler.
ToneGen_WriteVoice_Long_NopGap:
	nop
	nop
	nop
	pop xiz
	ret

; latch = voice + 0x0080 (register 0x02 = AMPLITUDE / level), data = word at XBC+0x04 with
; bit 15 forcibly cleared.  Called from Voice_AllVoices_WriteAmplitude, i.e. this is the
; register that CC 7 (volume) and CC 11 (expression) ultimately reach.
ToneGen_WriteVoice_Short:
	push xiz
	ld xiz, xbc
	res	7, (P6:8)
	add wa, 0x80
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 4)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoice_Short_NopGap

; NopGap of ToneGen_WriteVoice_Short.
ToneGen_WriteVoice_Short_NopGap:
	nop
	nop
	nop
	pop xiz
	ret

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
ToneGen_WriteVoice_Direct:
	pushw iz
	ld iz, bc
	res	7, (P6:8)
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld (ToneGen_RegDataPort:24), iz
	jr ToneGen_WriteVoice_Direct_NopGap

; NopGap of ToneGen_WriteVoice_Direct.
ToneGen_WriteVoice_Direct_NopGap:
	nop
	nop
	nop
	popw iz
	ret

; Six-register burst for one voice.  WA = voice, XBC = staging record.
; latch/source pairs, in program order:
;   0x0840 (reg 0x21) <- +0x2E   0x0940 (reg 0x25) <- +0x32   0x0A00 (reg 0x28) <- +0x36
;   0x0800 (reg 0x20) <- +0x2C   0x0900 (reg 0x24) <- +0x30   0x09C0 (reg 0x27) <- +0x34
; i.e. three (even,odd) register pairs, matching the three Voice_Calc_LevelPair_EGA/2/3
; calls that precede it in Voice_AllNotes_SustainRetrigger_BranchC.
ToneGen_WriteVoice_6Words:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 46)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoice_6Words_Word2

; Word2 of ToneGen_WriteVoice_6Words.
ToneGen_WriteVoice_6Words_Word2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x940
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 50)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote6ch_NopCont1

; NopCont1: settling gap plus the next address/data pair of ToneGen_WriteNote6ch.
ToneGen_WriteNote6ch_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xA00
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 54)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote6ch_NopCont2

; NopCont2: settling gap plus the next address/data pair of ToneGen_WriteNote6ch.
ToneGen_WriteNote6ch_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 44)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote6ch_NopCont3

; NopCont3: settling gap plus the next address/data pair of ToneGen_WriteNote6ch.
ToneGen_WriteNote6ch_NopCont3:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x900
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 48)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote6ch_NopCont4

; NopCont4: settling gap plus the next address/data pair of ToneGen_WriteNote6ch.
ToneGen_WriteNote6ch_NopCont4:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x9C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 52)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote6ch_NopCont5

; The five continuation points of the six-word burst; each is the settling gap plus the next
; address/data pair.  Note the existing names call this "6ch" while the code is 6 REGISTERS
; of ONE voice -- see [UNCERTAIN].
ToneGen_WriteNote6ch_NopCont5:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Two-register variant: latch 0x0840 (reg 0x21) <- XBC+0x2E, latch 0x0800 (reg 0x20) <- +0x2C.
; Same entry convention as ToneGen_WriteVoice_6Words.  Used where only the first volume/EG
; pair needs refreshing (Voice_AllNotes_SustainRetrigger branches E and F).
ToneGen_WriteNote2ch:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 46)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote2ch_NopCont1

; NopCont1: settling gap plus the next address/data pair of ToneGen_WriteNote2ch.
ToneGen_WriteNote2ch_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 44)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteNote2ch_NopCont2

; NopCont2: settling gap plus the next address/data pair of ToneGen_WriteNote2ch.
ToneGen_WriteNote2ch_NopCont2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; --- 0x0280FE-0x028838  VoiceCC_DataTable_0280FE -- was MISLABELLED, now fully code
; All 1851 bytes are TLCS-900H instructions, byte-for-byte (round-trip verified against
; kn5000_subprogram_v142.rom).  Most of this span had already been converted from `.byte` by
; an earlier pass; the last 134 bytes (AudioMod_Scale_To_Part_1C/1B) resisted the automated
; convert because llvm-mc's own disassembler cannot DECODE the `st_rrb`/register-indexed
; forms it can ENCODE -- MAME unidasm framing plus a hand round trip closed them 2026-09-02.
; It contains 21 subroutines, every one of them reached by `calr` from named code or from the
; 0x028F75 block.  The 21 entry points are proposed individually below.  Nothing in here is data.
; ⚠ RENAME PROPOSAL, NOT A PLACEHOLDER FILL: this address already carries the real name
; VoiceCC_DataTable_0280FE.  I have left that name alone; applying this one is a decision for
; the maintainer.  See the matching [UNCERTAIN] at the end.
; WA = voice 0..0x3F, XBC = source record.  Writes TG register 0x21 (latch = voice + 0x0840)
; with the word at XBC+0x2E.  Single-register writer, same 5-step strobe as all the others.
VoiceCC_DataTable_0280FE:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 2112
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+46)
	ld	(ToneGen_RegDataPort:24), wa
	jr	VoiceCC_DataTable_0280FE_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
VoiceCC_DataTable_0280FE_Next:
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
ToneGen_WriteVoice_TvfPair:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xbc
	ld	iz, wa
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 256
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+8)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_TvfPair_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_TvfPair_Next:
	nop
	nop
	nop
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 320
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+10)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_TvfPair_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_TvfPair_Next2:
	nop
	nop
	nop
	popw	iz
	inc	4, xsp
	ret
; WA = voice, XBC = source record.  Writes register 0x21 (voice+0x0840) from XBC+0x1A and
; register 0x22 (voice+0x0880) from XBC+0x1C.  Called after Voice_WriteChPanShift (0x02591D)
; and Voice_WriteChPanShift2 (0x025B6F), so the pair is the pan-shift/detune result, but the
; exact meaning of registers 0x21/0x22 is not proven here.
ToneGen_WriteVoice_Reg21_Reg22:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xbc
	ld	iz, wa
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 2112
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+26)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg21_Reg22_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg21_Reg22_Next:
	nop
	nop
	nop
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 2176
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+28)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg21_Reg22_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg21_Reg22_Next2:
	nop
	nop
	nop
	popw	iz
	inc	4, xsp
	ret
; WA = voice, XBC = source record.  Writes register 0x06 (latch = voice + 0x0180) from
; XBC+0x0C.  Register 6 is the per-voice ENVELOPE LEVEL -- the MAME memory map already
; documents latch 0x0180+ch as the envelope-level read-back address, and this is the write
; side of the same register.
ToneGen_WriteVoice_EnvLevel:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 384
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+12)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_EnvLevel_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_EnvLevel_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Writes register 0x11 (latch voice+0x0440) from XBC+0x10.
ToneGen_WriteVoice_Reg11:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1088
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+16)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg11_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg11_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Writes register 0x13 (latch voice+0x04C0) from XBC+0x14.
ToneGen_WriteVoice_Reg13:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1216
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+20)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg13_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg13_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Writes register 0x18 (latch voice+0x0600) from XBC+0x40.
ToneGen_WriteVoice_Reg18:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1536
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+64)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg18_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg18_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Writes register 0x16 (latch voice+0x0580) from XBC+0x3C.
ToneGen_WriteVoice_Reg16:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1408
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+60)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg16_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg16_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Writes register 0x07 (latch voice+0x01C0) from XBC+0x38.
ToneGen_WriteVoice_Reg07:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 448
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+56)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg07_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg07_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Writes register 0x15 (latch voice+0x0540) from XBC+0x3A.
ToneGen_WriteVoice_Reg15:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1344
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+58)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg15_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg15_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Range-split writer.  If WA < 0x40 it writes register 0x07 from XBC+0x38 (the normal 64
; voices); otherwise it writes register 0x18 from XBC+0x42.  Proof that the tone generator
; has addressable slots beyond voice 0x3F for some register groups, and that the software
; deliberately re-targets them.
ToneGen_WriteVoice_Reg07_Or_Reg18:
	push	xiz
	ld	xiz, xbc
	cp	wa, 64
	jr	nc, ToneGen_WriteVoice_Reg07_Or_Reg18_Skip
	res	7, (P6:8)
	add	wa, 448
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+56)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg07_Or_Reg18_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg07_Or_Reg18_Next:
	nop
	nop
	nop
	jr	ToneGen_WriteVoice_Reg07_Or_Reg18_Epilogue
ToneGen_WriteVoice_Reg07_Or_Reg18_Skip:
	res	7, (P6:8)
	add	wa, 1536
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+66)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg07_Or_Reg18_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg07_Or_Reg18_Next2:
	nop
	nop
	nop
ToneGen_WriteVoice_Reg07_Or_Reg18_Epilogue:
	pop	xiz
	ret
; Same shape: WA < 0x40 -> register 0x15 from XBC+0x3A, else register 0x16 from XBC+0x3E.
ToneGen_WriteVoice_Reg15_Or_Reg16:
	push	xiz
	ld	xiz, xbc
	cp	wa, 64
	jr	nc, ToneGen_WriteVoice_Reg15_Or_Reg16_Skip
	res	7, (P6:8)
	add	wa, 1344
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+58)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg15_Or_Reg16_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg15_Or_Reg16_Next:
	nop
	nop
	nop
	jr	ToneGen_WriteVoice_Reg15_Or_Reg16_Epilogue
ToneGen_WriteVoice_Reg15_Or_Reg16_Skip:
	res	7, (P6:8)
	add	wa, 1408
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+62)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg15_Or_Reg16_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg15_Or_Reg16_Next2:
	nop
	nop
	nop
ToneGen_WriteVoice_Reg15_Or_Reg16_Epilogue:
	pop	xiz
	ret
; A = part index, C = a bus mask, XDE and XIX = bit patterns to set/clear, one word on the
; stack.  For each of the 4 output buses w = 0..3 it reads two 4-byte mask tables at
; 0x00F6D7 and 0x00F6DB, tests bit (1<<w) of C against each, and then sets or clears bits in
; the word at  0x041368 + part*0x11F + 0x6E + w*0x25 + 0x18  (i.e. output-slot record w,
; field +0x18) using OR / AND-with-complement.  Returns with `retd 2`.
; This is the routine that turns a "send this modulation to buses X" request into the
; per-slot enable bitmap.
AudioMod_Apply_BusRouting:
	pushw	iz
	ld	ix, (xsp+6)
	ld	w, 0:opc
	cp	w, 4:i3
	jrl	nc, AudioMod_Apply_BusRouting_Epilogue
AudioMod_Apply_BusRouting_Loop:
	ld	l, w
	extz	hl
	lda	xiy, (AudioMod_BusRouting_EnableBits:24)
	ld	l, (xiy+hl)
	and	l, c
	jrl	z, AudioMod_Apply_BusRouting_Skip2
	ld	l, w
	extz	hl
	lda	xiy, (AudioMod_BusRouting_OrIXBits:24)
	ld	l, (xiy+hl)
	and	l, c
	jr	z, AudioMod_Apply_BusRouting_Skip
	ld	l, w
	extz	hl
	muls	hl, 37
	ld	iz, hl
	add	iz, 110
	ld	l, a
	extz	hl
	muls	hl, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xhl
	add	xhl, xiy
	lda	xhl, (xhl+iz)	; lda XHL,XHL+IZ
	ld	iy, de
	or	iy, ix
	or	(xhl+24), iy
	jrl	AudioMod_Apply_BusRouting_Join
AudioMod_Apply_BusRouting_Skip:
	ld	l, w
	extz	hl
	muls	hl, 37
	ld	iz, hl
	add	iz, 110
	ld	l, a
	extz	hl
	muls	hl, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xhl
	add	xhl, xiy
	lda	xiy, (xhl+iz)	; lda XIY,XHL+IZ
	ld	hl, ix
	cpl	hl
	and	(xiy+24), hl
	ld	l, w
	extz	hl
	muls	hl, 37
	ld	iz, hl
	add	iz, 110
	ld	l, a
	extz	hl
	muls	hl, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xhl
	add	xhl, xiy
	lda	xhl, (xhl+iz)	; lda XHL,XHL+IZ
	or	(xhl+24), de
	jr	AudioMod_Apply_BusRouting_Join
AudioMod_Apply_BusRouting_Skip2:
	ld	l, w
	extz	hl
	muls	hl, 37
	ld	iz, hl
	add	iz, 110
	ld	l, a
	extz	hl
	muls	hl, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xhl
	add	xhl, xiy
	lda	xiy, (xhl+iz)	; lda XIY,XHL+IZ
	ld	hl, de
	or	hl, ix
	cpl	hl
	and	(xiy+24), hl
AudioMod_Apply_BusRouting_Join:
	inc	1, w
	cp	w, 4:i3
	jrl	c, AudioMod_Apply_BusRouting_Loop
AudioMod_Apply_BusRouting_Epilogue:
	popw	iz
	retd	2
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
; Int_SignedDiv_AltEntry (0x03DC5F) and stored as a word at 0x041385 + part*0x11F
; (part+0x1D).
AudioMod_Apply_Porta_Curve:
	dec	2, xsp
	ld	(xsp), a
	bit	7, (xde+1)	; bit 7,(XDE+0x01)
	jr	z, AudioMod_Apply_Porta_Curve_Skip2
	ld	hl, bc
	exts	xhl
	sub	xhl, 8192
	jr	AudioMod_Apply_Porta_Curve_Join
AudioMod_Apply_Porta_Curve_Skip2:
	ld	hl, bc
	exts	xhl
	sra	xhl, 1
AudioMod_Apply_Porta_Curve_Join:
	ld	a, (xde+2)
	ld	xbc, 0:i3
	ld	c, a
	ld	xwa, xhl
	call	Math_Multiply32
	sra	xhl, 6
	ld	a, (xsp)
	extz	wa
	sub	wa, 16
	cp	wa, 0:i3
	jr	lt, AudioMod_Apply_Porta_Curve_Skip
	cp	wa, 9
	jr	gt, AudioMod_Apply_Porta_Curve_Skip
	add	wa, wa
	lda	xix, (AudioMod_PortaCurve_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda	xix, (AudioMod_Porta_Curve_JumpBase:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
; Base address of the 10-entry computed jump inside AudioMod_Apply_Porta_Curve; offsets come
; from the word table at 0x00F6DF.  Entry 0 (this address) triples then shifts left 2.
AudioMod_Porta_Curve_JumpBase:
	ld	xwa, xhl
	add	xhl, xhl
	add	xhl, xwa
	sla	xhl, 2
	jr	AudioMod_Apply_Porta_Curve_Join2
AudioMod_Apply_Porta_Curve_Skip:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2505:24)
	ld	a, (xbc+wa)
	ld	xbc, 0:i3
	ld	c, a
	ld	xwa, xhl
	call	Math_Multiply32
AudioMod_Apply_Porta_Curve_Join2:
	sla	xhl, 9
	cp	xhl, 0
	jr	le, AudioMod_Apply_Porta_Curve_Skip3
	ld	xwa, xhl
	ld	xbc, 16384
	call	Int_SignedDiv_AltEntry
	jr	AudioMod_Apply_Porta_Curve_Join3
AudioMod_Apply_Porta_Curve_Skip3:
	ld	xwa, xhl
	ld	xbc, 16383
	call	Int_SignedDiv_AltEntry
AudioMod_Apply_Porta_Curve_Join3:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x250f:24)
	ld	(xbc+wa), hl
	inc	2, xsp
	ret
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
AudioMod_Apply_Slot_Field2A:
	pushw	iz
	ld	xix, xde
	ld	l, (xsp+6)
	ld	w, (xsp+8)
	bit	7, (xix+1)	; bit 7,(XIX+0x01)
	jr	z, AudioMod_Apply_Slot_Field2A_Join
	cp	c, 64
	jr	ule, AudioMod_Apply_Slot_Field2A_Skip
	sub	c, 64
	ld	e, c
	add	c, e
	jr	AudioMod_Apply_Slot_Field2A_Join
AudioMod_Apply_Slot_Field2A_Skip:
	ld	c, 0:opc
AudioMod_Apply_Slot_Field2A_Join:
	cp	c, 0:i3
	jr	z, AudioMod_Apply_Slot_Field2A_Skip2
	ld	e, w
	extz	de
	ld	iy, de
	sla	iy, 2
	ld	e, l
	extz	de
	sla	de, 4
	ld	iz, de
	add	iz, iy
	ld	e, a
	extz	de
	muls	de, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xde
	add	xde, xiy
	lda	xde, (xde+iz)	; lda XDE,XDE+IZ
	ld	e, (xde+40)
	and	e, 85
	ld	h, e
	ld	e, (xix)
	and	e, 85
	ld	b, e
	ld	e, h
	or	e, b
	ld	h, e
	ld	e, (xix)
	and	e, 170
	ld	b, e
	ld	e, w
	extz	de
	ld	iy, de
	sla	iy, 2
	ld	e, l
	extz	de
	sla	de, 4
	ld	iz, de
	add	iz, iy
	ld	e, a
	extz	de
	muls	de, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xde
	add	xde, xiy
	lda	xiy, (xde+iz)	; lda XIY,XDE+IZ
	ld	e, h
	or	e, b
	ld	(xiy+40), e
	jr	AudioMod_Apply_Slot_Field2A_Join2
AudioMod_Apply_Slot_Field2A_Skip2:
	ld	e, w
	extz	de
	ld	iy, de
	sla	iy, 2
	ld	e, l
	extz	de
	sla	de, 4
	ld	iz, de
	add	iz, iy
	ld	e, a
	extz	de
	muls	de, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xde
	add	xde, xiy
	lda	xde, (xde+iz)	; lda XDE,XDE+IZ
	ld	(xde+40), 0
AudioMod_Apply_Slot_Field2A_Join2:
	ldfr_berp	c, 0xf4	; ld IYL,C
	extz	iy
	ld	e, (xix+2)
	ldfr_berp	e, 0xf0	; ld IXL,E
	extz	ix
	ld	de, iy
	mul	xde, ix
	ld	iy, de
	srl	iy, 6
	jr	nz, AudioMod_Apply_Slot_Field2A_Skip3
	cp	c, 0:i3
	jr	z, AudioMod_Apply_Slot_Field2A_Skip3
	ld	iy, 1:i3
AudioMod_Apply_Slot_Field2A_Skip3:
	ld	c, w
	extz	bc
	ld	de, bc
	sla	de, 2
	ld	c, l
	extz	bc
	sla	bc, 4
	ld	hl, bc
	add	hl, de
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xbc, (xwa+hl)	; lda XBC,XWA+HL
	ld_erpb_rr	a, 0xf4	; ld A,IYL
	ld	(xbc+42), a
	popw	iz
	retd	4
; Byte-for-byte the same algorithm as AudioMod_Apply_Slot_Field2A except that the result is
; stored at slot+0x29 instead of slot+0x2A.  Also returns with `retd 4` (at 0x028825).
; Six callers, all of them dispatch handlers inside the 0x028F75 block.
AudioMod_Apply_Slot_Field29:
	pushw	iz
	ld	xix, xde
	ld	l, (xsp+6)
	ld	w, (xsp+8)
	bit	7, (xix+1)	; bit 7,(XIX+0x01)
	jr	z, AudioMod_Apply_Slot_Field29_Join
	cp	c, 64
	jr	ule, AudioMod_Apply_Slot_Field29_Skip
	sub	c, 64
	ld	e, c
	add	c, e
	jr	AudioMod_Apply_Slot_Field29_Join
AudioMod_Apply_Slot_Field29_Skip:
	ld	c, 0:opc
AudioMod_Apply_Slot_Field29_Join:
	cp	c, 0:i3
	jr	z, AudioMod_Apply_Slot_Field29_Skip2
	ld	e, w
	extz	de
	ld	iy, de
	sla	iy, 2
	ld	e, l
	extz	de
	sla	de, 4
	ld	iz, de
	add	iz, iy
	ld	e, a
	extz	de
	muls	de, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xde
	add	xde, xiy
	lda	xde, (xde+iz)	; lda XDE,XDE+IZ
	ld	e, (xde+40)
	and	e, 85
	ld	h, e
	ld	e, (xix)
	and	e, 85
	ld	b, e
	ld	e, h
	or	e, b
	ld	h, e
	ld	e, (xix)
	and	e, 170
	ld	b, e
	ld	e, w
	extz	de
	ld	iy, de
	sla	iy, 2
	ld	e, l
	extz	de
	sla	de, 4
	ld	iz, de
	add	iz, iy
	ld	e, a
	extz	de
	muls	de, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xde
	add	xde, xiy
	lda	xiy, (xde+iz)	; lda XIY,XDE+IZ
	ld	e, h
	or	e, b
	ld	(xiy+40), e
	jr	AudioMod_Apply_Slot_Field29_Join2
AudioMod_Apply_Slot_Field29_Skip2:
	ld	e, w
	extz	de
	ld	iy, de
	sla	iy, 2
	ld	e, l
	extz	de
	sla	de, 4
	ld	iz, de
	add	iz, iy
	ld	e, a
	extz	de
	muls	de, 287
	lda	xiy, (Part_Record_Base:24)
	exts	xde
	add	xde, xiy
	lda	xde, (xde+iz)	; lda XDE,XDE+IZ
	ld	(xde+40), 0
AudioMod_Apply_Slot_Field29_Join2:
	ldfr_berp	c, 0xf4	; ld IYL,C
	extz	iy
	ld	e, (xix+2)
	ldfr_berp	e, 0xf0	; ld IXL,E
	extz	ix
	ld	de, iy
	mul	xde, ix
	ld	iy, de
	srl	iy, 6
	jr	nz, AudioMod_Apply_Slot_Field29_Skip3
	cp	c, 0:i3
	jr	z, AudioMod_Apply_Slot_Field29_Skip3
	ld	iy, 1:i3
AudioMod_Apply_Slot_Field29_Skip3:
	ld	c, w
	extz	bc
	ld	de, bc
	sla	de, 2
	ld	c, l
	extz	bc
	sla	bc, 4
	ld	hl, bc
	add	hl, de
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xbc, (xwa+hl)	; lda XBC,XWA+HL
	ld_erpb_rr	a, 0xf4	; ld A,IYL
	ld	(xbc+41), a
	popw	iz
	retd	4
; Eleven bytes, no prologue.  HL = min(max(WA, DE), BC), i.e. clamp WA to the inclusive
; range [DE, BC] using signed comparisons.  Tail utility of the 0x0280FE block.
Audio_Clamp_To_Range:
	cp	wa, de
	jr	ge, Audio_Clamp_To_Range_Skip
	ld	wa, de
	jr	Audio_Clamp_To_Range_Join
Audio_Clamp_To_Range_Skip:
	cp	wa, bc
	jr	le, Audio_Clamp_To_Range_Join
	ld	wa, bc
Audio_Clamp_To_Range_Join:
	ld	hl, wa
	ret

; Voice_CC_SetVolume -- CC 0x07: Store volume via lookup table
; Uses non-linear lookup table at ROM 0x011D16. Mute value: 0xFE00.
; WA = part index, BC = CC 7 value 0..0x7F.  Three-way behaviour selected by the global flag
; word 0x041343: bit 0 set and bit 1 set both map the value through the 128-entry word table
; at 0x011D16; otherwise the raw path stores (value - 0x7F).  Value 0 takes the mute path.
; Result is the word at 0x041374 + part*0x11F (part+0x0C).  Does not touch hardware -- the
; caller (Voice_CC_Volume) follows up with Voice_AllVoices_WriteAmplitude.
Voice_CC_SetVolume:
	cp c, 0:i3
	jr z, VoiceCC_SetVolume_Mute
	ld de, (Voice_GlobalFlags:24)
	bit 0, de
	jr z, VoiceCC_SetVolume_Bit1Set
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x24fe:24)
	ld a, c
	extz wa
	add wa, wa
	lda xbc, (Voice_CC_VolumeCurve:24)
	ld	wa, (xbc+wa)
	ld	(xhl+de), wa
	ret

; Bit1Set of VoiceCC_SetVolume.
VoiceCC_SetVolume_Bit1Set:
	ld de, (Voice_GlobalFlags:24)
	bit 1, de
	jr z, VoiceCC_SetVolume_RawSub
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x24fe:24)
	ld a, c
	extz wa
	add wa, wa
	lda xbc, (Voice_CC_VolumeCurve:24)
	ld	wa, (xbc+wa)
	ld	(xhl+de), wa
	ret

; RawSub of VoiceCC_SetVolume.
VoiceCC_SetVolume_RawSub:
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x24fe:24)
	ld a, c
	extz wa
	sub wa, 0x7F
	ld	(xhl+de), wa
	ret

; Stores 0xFE00 (full attenuation) into the part volume word.
VoiceCC_SetVolume_Mute:
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fe:24)
	ldw	(xbc+wa), 0xfe00
	ret

; Voice_CC_SetPan -- CC 0x0A: Store pan value at voice + 0x0E
; WA = part, C = CC 10 value.  Stores the byte at 0x041376 + part*0x11F (part+0x0E); the
; hardware side is done by EnvTranspose_UpdateLoop (0x032E1E) from Voice_CC_Pan.
Voice_CC_SetPan:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2500:24)
	ld	(xde+wa), c
	ret

; Voice_CC_SetExpression -- CC 0x0B: Store expression via lookup table
; Uses same lookup table as Volume (0x011D16). Mute value: 0xFE00.
; WA = part, BC = CC 11 value.  Structurally identical to Voice_CC_SetVolume (same 0x041343
; bit 0 / bit 1 selection, same 0x011D16 table) but the destination is the word at
; 0x041378 + part*0x11F (part+0x10).  Mute path writes 0xFE00.
Voice_CC_SetExpression:
	cp c, 0:i3
	jr z, VoiceCC_SetExpression_Mute
	ld de, (Voice_GlobalFlags:24)
	bit 0, de
	jr z, VoiceCC_SetExpression_Bit1Set
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x2502:24)
	ld a, c
	extz wa
	add wa, wa
	lda xbc, (Voice_CC_VolumeCurve:24)
	ld	wa, (xbc+wa)
	ld	(xhl+de), wa
	ret

; Bit1Set of VoiceCC_SetExpression.
VoiceCC_SetExpression_Bit1Set:
	ld de, (Voice_GlobalFlags:24)
	bit 1, de
	jr z, VoiceCC_SetExpression_RawSub
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x2502:24)
	ld a, c
	extz wa
	add wa, wa
	lda xbc, (Voice_CC_VolumeCurve:24)
	ld	wa, (xbc+wa)
	ld	(xhl+de), wa
	ret

; RawSub of VoiceCC_SetExpression.
VoiceCC_SetExpression_RawSub:
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x2502:24)
	ld a, c
	extz wa
	sub wa, 0x7F
	ld	(xhl+de), wa
	ret

; Mute of VoiceCC_SetExpression.
VoiceCC_SetExpression_Mute:
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2502:24)
	ldw	(xbc+wa), 0xfe00
	ret

; Voice_CC_SetSustain -- CC 0x40: Set/clear sustain bit 0 at voice+0x0A
; WA = part, BC = CC 64 value.  Sets (BC != 0) or clears bit 0 of the part flags word 2 at
; 0x041372 + part*0x11F (part+0x0A).
Voice_CC_SetSustain:
	cp c, 0:i3
	jr z, VoiceCC_SetSustain_ClearBit
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	orw	(xbc+wa), 0x0001
	ret

; ClearBit of VoiceCC_SetSustain.
VoiceCC_SetSustain_ClearBit:
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	andw	(xbc+wa), 0xfffe
	ret

; WA = part, C = the part's reverb send level.  Stores the byte at 0x041377 + part*0x11F (part+0x0F).
Voice_CC_SetReverbSend:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2501:24)
	ld	(xde+wa), c
	ret

; WA = part, C = the part's DSP-effect send level.  Stores the byte at 0x04137A + part*0x11F (part+0x12).
Voice_CC_SetDspEffectSend:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2504:24)
	ld	(xde+wa), c
	ret

; WA = part, BC = value.  Sets/clears bit 6 (0x0040) of part flags word 2 (part+0x0A).
Voice_CC_SetSostenutoFlag:
	cp c, 0:i3
	jr z, VoiceCC_SetSostenuto_ClearFlag
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	orw	(xbc+wa), 0x4000
	ret

; ClearFlag of VoiceCC_SetSostenuto.
VoiceCC_SetSostenuto_ClearFlag:
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	andw	(xbc+wa), 0xbfff
	ret

; WA = part, C = the part's BEND RANGE (main-CPU Lsw 0x080, 0..12; was read as a portamento rate).  Stores the
; byte at 0x04137B + part*0x11F (part+0x13).  This is the byte AudioMod_Apply_Porta_Curve falls back to.
Voice_CC_SetBendRange:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2505:24)
	ld	(xde+wa), c
	ret

; WA = part, C = the part's TUNING (main-CPU Lsw 0x081, 0..255 centred on 0x80).  Stores the word
; ((C - 0x80) * 2) at 0x04137C + part*0x11F (part+0x14); Voice_CC_Tuning then refreshes the sounding pitches.
Voice_CC_SetTuning:
	ld e, c
	extz de
	sub de, 0x80
	add de, de
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2506:24)
	ld	(xbc+wa), de
	ret

; WA = part, C = the part's KEY SHIFT (main-CPU Lsw 0x082, 52..76 = 64 +- 12 semitones).  Stores (C - 0x40) at
; 0x04137E + part*0x11F (part+0x16).
Voice_CC_SetKeyShift:
	ld e, c
	sub e, 0x40
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2508:24)
	ld	(xbc+wa), e
	ret

; Ordinary code, not data: if C != 0 stores +2 into the word at
; 0x041372 + part*0x11F, otherwise stores -3 (0xFFFD).  Two-valued, so "range" is a guess --
; what it really does is force a small signed constant into part flags word 2.
Voice_CC_SetModWheelRange:
	cp	c, 0:i3
	jr	z, Voice_CC_SetModWheelRange_Else
	extz	wa
	muls	wa, 0x11F
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	orw	(xbc+wa), 0x0002
	ret
Voice_CC_SetModWheelRange_Else:
	extz	wa
	muls	wa, 0x11F
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	andw	(xbc+wa), 0xfffd
	ret

; WA = part, C = CC 0x91 value.  Stores the byte at 0x04137F + part*0x11F (part+0x17): the part's own
; velocity-switch configuration, the per-part twin of the global byte 0x04134B (Voice_SetVelSwitchConfig,
; F0 50 91).  Its only readers are the Voice_Env_ApplyVelocity_Type0/_Type2 dispatchers (sub-cases 2 and 3):
; bit 3 (type 0/1) or bit 4 (type 2) set = do nothing, else bit 0 (case 2) or bit 0 with bit 1 clear
; (case 3) installs the patch's +0x2A octave-shift nibble.  Main-CPU sender: SwbtB2_Code9A_Listener (parts
; 0..2).  Was called "reverb depth" (no reader supports that), renamed 2026-10-31.
Voice_CC_SetVelSwitchConfig:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2509:24)
	ld	(xde+wa), c
	ret

; Voice_CC_SetGlidePedal -- CC 0x95 (GLIDE PEDAL, called chorus enable until 2026-10-17): set/clear bit 2 at voice+0x0A
; WA = part, BC = CC 0x95 value.  Sets/clears bit 2 (0x0004) of part flags word 2.
Voice_CC_SetGlidePedal:
	cp c, 0:i3
	jr z, VoiceCC_SetGlidePedal_ClearBit
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	orw	(xbc+wa), 0x0004
	ret

; ClearBit of VoiceCC_SetChorus.
VoiceCC_SetGlidePedal_ClearBit:
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	andw	(xbc+wa), 0xfffb
	ret

; Voice_CC_SetSustainLength -- CC 0x97 (SUSTAIN LENGTH, called chorus depth until 2026-10-17): store at voice+0x18
; WA = part, C = CC 0x97 value.  Stores the byte at 0x041380 + part*0x11F (part+0x18).
Voice_CC_SetSustainLength:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x250a:24)
	ld	(xde+wa), c
	ret

; WA = part, C = CC 0x9B value.  Stores the byte at 0x04138D + part*0x11F (part+0x25).  Its only reader is
; Voice_Apply_GateRouting, which patches the gate/control word of every voice of the part: low nibble 0 = force
; bits [11:9] to 7, 1 = leave them, 2 = force them to 1; high nibble 0x00 / 0x10 / 0x20 does the same to
; [14:12].  Reset value 1.  No main-CPU sender was found in v10 (the CC numbers above 0x7F cannot arrive
; from MIDI IN).  Was called "delay depth", renamed 2026-10-31.
Voice_CC_SetGateRoutingMode:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2517:24)
	ld	(xde+wa), c
	ret

; Voice_CC_SetKeyScaling -- CC 0x9C (KEY SCALING, called delay enable until 2026-10-17): set/clear bit 8 at voice+0x02
; WA = part, BC = CC 0x9C value.  Sets/clears bit 0 of the part flags word at
; 0x04136A + part*0x11F (part+0x02).
Voice_CC_SetKeyScaling:
	cp c, 0:i3
	jr z, VoiceCC_SetKeyScaling_ClearBit
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	orw	(xbc+wa), 0x0100
	ret

; ClearBit of VoiceCC_SetDelay.
VoiceCC_SetKeyScaling_ClearBit:
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	andw	(xbc+wa), 0xfeff
	ret

; WA = part, C = CC 0x9D value.  Stores the byte at 0x04138E + part*0x11F (part+0x26).  Its readers
; (Voice_Level_ClearAllOutputRegs, Voice1_UpdatePitch_WriteStereoField, Voice_Step_ExprRamp) choose the low 7
; bits of the voice's TG register 0x180 (pan on technics-docs/tone-generator.md, 0x40 = centre): 1 = 0x00,
; 2 = 0x7F, anything else = the voice's own value.  Reset value 0.  No main-CPU sender was found in v10.
; Was called "delay feedback", renamed 2026-10-31.
Voice_CC_SetTgPanMode:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2518:24)
	ld	(xde+wa), c
	ret

; A = mode.  A == 1 sets bit 0 of the global flag word 0x041343 and calls
; Voice_Reset_Engine (0x021ECB) with WA = 1; anything else clears bit 0 and calls it
; with WA = 0.  Then VoiceSlot_ClearAll (0x034B4B) and
; Voice_PerVoice_PortamentoPitchUpdate for parts 0..0x0F.
; ★ This is the one routine in the region that both writes a global mode bit AND drops the
; entire voice-slot allocation on the floor; see [UNCERTAIN]/findings.
Voice_SetPolyphonyMode:
	pushw_erp 0xFA
	cp a, 1:i3
	jr nz, Voice_SetPolyphonyMode_Else
	orw (Voice_GlobalFlags:24), 1
	ld wa, 1:i3
	call Voice_Reset_Engine
	jr Voice_SetPolyphonyMode_Apply

; Else of Voice_SetPolyphonyMode.
Voice_SetPolyphonyMode_Else:
	andw (Voice_GlobalFlags:24), 65534
	ld wa, 0:i3
	call Voice_Reset_Engine

; Apply of Voice_SetPolyphonyMode.
Voice_SetPolyphonyMode_Apply:
	call VoiceSlot_ClearAll
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x0F
	jr ugt, Voice_SetPolyphonyMode_LoopExit

; loop body of Voice_SetPolyphonyMode.
Voice_SetPolyphonyMode_LoopBody:
	ldto_berp A, 0xFB
	extz wa
	calr Voice_PerVoice_PortamentoPitchUpdate
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x0F
	jr ule, Voice_SetPolyphonyMode_LoopBody

; LoopExit of Voice_SetPolyphonyMode.
Voice_SetPolyphonyMode_LoopExit:
	popw_erp 0xFA
	ret

; A bare `ret`.  Reached from SysEx dispatch-table entry 1 and from
; Voice_ResetAllControllers_PostLoop with WA = 0x7F.  Deliberate no-op, not padding.
VoiceCC_Stub_Ret1:
	ret

; Second bare `ret`, dispatch entry 2, likewise called with WA = 0x7F.
VoiceCC_Stub_Ret2:
	ret

; A = raw value.  Stores sign-extended ((A - 0x40) * 2) as a word at 0x041347.
Voice_SetMasterTune:
	sub a, 0x40
	add a, a
	exts wa
	ld (Payload_Bss_Start+0x24d1:24), wa
	ret

; A = semitones.  Stores (sign-extended A) << 8 at 0x041349.
Voice_SetPitchBendRange:
	exts wa
	sla wa, 8
	ld (Payload_Bss_Start+0x24d3:24), wa
	ret

; A = 0 falls through into Voice_SetKeyShiftRange (disable).  Otherwise, if bit 12 of the
; global flag word 0x041343 is already set it returns; else it sets bit 11 (0x0800) and
; zeroes the word at 0x04135C.
Voice_SetKeyShiftEnable:
	cp a, 0:i3
	jr z, Voice_SetKeyShiftRange
	ld wa, (Voice_GlobalFlags:24)
	bit 12, wa
	ret nz
	orw (Voice_GlobalFlags:24), 2048
	ldw (Payload_Bss_Start+0x24e6:24), 0x0000
	ret

; Returns immediately unless global flag 0x041343 bit 12 is set.  Rewrites the flag word:
; clears bits 12/13 (mask 0xFFFF2FFF), sets bit 13, and then sets bit 15 if the word at
; 0x04135C is > 20, bit 14 otherwise.  Finally zeroes 0x04135C.
Voice_SetKeyShiftRange:
	ld wa, (Voice_GlobalFlags:24)
	bit 12, wa
	ret z
	ld wa, (Voice_GlobalFlags:24)
	extz xwa
	and xwa, 0xFFFF2FFF
	set 13, wa
	cpw (Payload_Bss_Start+0x24e6:24), 20
	jr ule, Voice_SetKeyShiftRange_BranchA
	set 15, wa
	jr Voice_SetKeyShiftRange_BranchB

; BranchA of Voice_SetKeyShiftRange.
Voice_SetKeyShiftRange_BranchA:
	set 14, wa

; BranchB of Voice_SetKeyShiftRange.
Voice_SetKeyShiftRange_BranchB:
	ld (Voice_GlobalFlags:24), wa
	ldw (Payload_Bss_Start+0x24e6:24), 0x0000
	ret

; A -> byte 0x04134D.  Reached from SysEx dispatch entry 6 and from
; Voice_ResetAllControllers with A = 0.  The reference file calls the getter
; ScaleTune_Get_Global_Mode; see [UNCERTAIN].
ScaleTune_Set_Global_Mode:
	ld (Payload_Bss_Start+0x24d7:24), a
	ret

ScaleTune_Get_Global_Mode:
	ld l, (Payload_Bss_Start+0x24d7:24)
	ret

; A = packed rhythm-mode byte from a SysEx message.  Decodes it into the 0x04135E block:
;   bit 3      -> 0x04135E = 3 (else 1)
;                 0x04135F = 1 unconditionally
;   bits 7..4  -> index x2 into the word table at 0x00F6F3, result -> 0x041360
;   bit 2      -> 0x041362 = 0x8000 (else 0xA000)
;   bits 1..0  -> 0x041364 = 0xC8 - ((A & 3) << 3)
; Pure state; no hardware touched here.
Voice_SetRhythmMode:
	bit 3, a
	jr z, Voice_SetRhythmMode_BranchA
	ld (Payload_Bss_Start+0x24e8:24), 0x03
	jr Voice_SetRhythmMode_BranchB

; BranchA of Voice_SetRhythmMode.
Voice_SetRhythmMode_BranchA:
	ld (Payload_Bss_Start+0x24e8:24), 0x01

; BranchB of Voice_SetRhythmMode.
Voice_SetRhythmMode_BranchB:
	ld (Payload_Bss_Start+0x24e9:24), 0x01
	ld c, a
	and c, 0xF0
	srl c, 4
	extz bc
	add bc, bc
	lda xde, (Voice_RhythmMode_ScalePitch_Table:24)
	ld	bc, (xde+bc)
	ld (Payload_Bss_Start+0x24ea:24), bc
	bit 2, a
	jr z, Voice_SetRhythmMode_BranchC
	ldw (Payload_Bss_Start+0x24ec:24), 0x8000
	jr Voice_SetRhythmMode_BranchD

; BranchC of Voice_SetRhythmMode.
Voice_SetRhythmMode_BranchC:
	ldw (Payload_Bss_Start+0x24ec:24), 0xa000

; BranchD of Voice_SetRhythmMode.
Voice_SetRhythmMode_BranchD:
	and a, 0x3
	sll a, 3
	ld c, a
	ld a, 0xC8:opc
	sub a, c
	extz wa
	ld (Payload_Bss_Start+0x24ee:24), wa
	ret

; A -> byte 0x04134B.  SysEx dispatch entry 0 (sub-command 0x91).
; That byte is read only by the Voice_Env_ApplyVelocity_* velocity-switch dispatchers (bits 0,
; 1, 3 and 4 select their predicates).  Renamed 2026-09-25 from Voice_SetParam_04134B.
Voice_SetVelSwitchConfig:
	ld (Payload_Bss_Start+0x24d5:24), a
	ret

; A == 0x7F sets bit 1 of the global flag word 0x041343, anything else clears it.
; Bit 1 is one of the two selectors Voice_CC_SetVolume / Voice_CC_SetExpression test.
Voice_SetCCMaxFlag:
	cp a, 0x7F
	jr nz, Voice_SetCCMaxFlag_Clear
	orw (Voice_GlobalFlags:24), 2
	ret

; Clear of Voice_SetCCMaxFlag.
Voice_SetCCMaxFlag_Clear:
	andw (Voice_GlobalFlags:24), 65533
	ret

; WA = index, C = value.  Stores (C - 0x80) at 0x041342 + (index + 0x0C), i.e. into the
; 12-byte array 0x04134E..0x041359.  Voice_ResetAllControllers zeroes exactly indices 0..0x0B,
; and 12 entries is one per pitch class -- which is why the reference file calls the reader
; ScaleTune_Get_User_Offset.  See [UNCERTAIN]: I believe the reference name is the correct
; one and "ChannelAssign" is wrong, but I have not renamed anything.
ScaleTune_Set_User_Offset:
	extz wa
	add wa, 0xC
	lda xde, (Payload_Bss_Start+0x24cc:24)
	sub c, 0x80
	ld	(xde+wa), c
	ret

ScaleTune_Get_User_Offset:
	extz wa
	add wa, 0xC
	lda xbc, (Payload_Bss_Start+0x24cc:24)
	ld	l, (xbc+wa)
	ret

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
Voice_AllVoices_UpdateVelocity:
	dec 2, xsp
	push xiz
	and a, 0xF
	ld (Payload_Bss_Start+0x24d6:24), a
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x1A
	jrl nc, Voice_AllVoices_UpdateVelocity_Exit

; loop head of Voice_AllVoices_UpdateVelocity.
Voice_AllVoices_UpdateVelocity_LoopStart:
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit 1, wa
	jrl z, Voice_AllVoices_UpdateVelocity_InnerStep
	ld a, (xsp + 4)
	extz wa
	call Voice_Query_PartVoices
	lda xwa, (xhl + 5)
	ld xiz, xwa
	cp (xiz), 0x40
	jrl nc, Voice_AllVoices_UpdateVelocity_InnerStep

; inner loop body of Voice_AllVoices_UpdateVelocity.
Voice_AllVoices_UpdateVelocity_InnerLoop:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x421c:24)
	ld	a, (xbc+wa)
	ld (xsp + 4), a
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x80
	jr z, Voice_AllVoices_UpdateVelocity_TypeB
	cp a, 0xC0
	jr z, Voice_AllVoices_UpdateVelocity_TypeA
	cp a, 0x40
	jr z, Voice_AllVoices_UpdateVelocity_TypeA
	cp a, 0:i3
	jr nz, Voice_AllVoices_UpdateVelocity_NextOuter

; TypeA case of Voice_AllVoices_UpdateVelocity.
Voice_AllVoices_UpdateVelocity_TypeA:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	exts xwa
	add xwa, xbc
	call Level_Build_Reg0C0
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	exts xwa
	add xwa, xbc
	call Voice_Build_GateCommand
	jr Voice_AllVoices_UpdateVelocity_NextOuter

; TypeB case of Voice_AllVoices_UpdateVelocity.
Voice_AllVoices_UpdateVelocity_TypeB:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	exts xwa
	add xwa, xbc
	call Voice_ComputePitchBend2
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	exts xwa
	add xwa, xbc
	call Voice_Build_GateCommand_NoPartial

; Calls ToneGen_ReadPitch_AndScale then advances the inner cursor.
Voice_AllVoices_UpdateVelocity_NextOuter:
	ld a, (xiz)
	extz wa
	call ToneGen_ReadPitch_AndScale
	inc 1, xiz
	cp (xiz), 0x40
	jrl c, Voice_AllVoices_UpdateVelocity_InnerLoop

; inner loop step of Voice_AllVoices_UpdateVelocity.
Voice_AllVoices_UpdateVelocity_InnerStep:
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x1A
	jrl c, Voice_AllVoices_UpdateVelocity_LoopStart

; common exit of Voice_AllVoices_UpdateVelocity.
Voice_AllVoices_UpdateVelocity_Exit:
	pop xiz
	inc 2, xsp
	ret

; A == 0 SETS bit 9 (0x0200) of the global flag word 0x041343; any other value clears it.
; The inverted sense makes the "MonoMode" reading doubtful -- see [UNCERTAIN].
ScaleTune_Set_Global_Enabled:
	cp a, 0:i3
	jr nz, ScaleTune_Set_Global_Enabled_Clear
	orw (Voice_GlobalFlags:24), 512
	ret

; Clear of ScaleTune_Set_Global_Enabled.
ScaleTune_Set_Global_Enabled_Clear:
	andw (Voice_GlobalFlags:24), 65023
	ret

; Returns HL = 0x041343 & 0x0200.  Getter for the bit the routine above writes.
ScaleTune_Is_Global_Enabled:
	ld hl, (Voice_GlobalFlags:24)
	and hl, 0x200
	ret

; XWA = the part record whose voice list starts at +5 (as returned by Voice_AllocateFor*).
; Walks the list; for each voice whose (voice+0x01) & 0x3C is 4, 8 or 0x20 it calls
; Pitch_Emit_Reg400 (0x023A4A), and for 0x10 it calls
; Voice_Pitch_WriteOutputReg_Secondary; in both cases it then calls
; ToneGen_WriteVoice_Long -- which writes TG register 0x10, the PITCH register.
; ★ It writes no pan register at all.  The reference file's Pitch_Refresh_Sounding_Voices is
; the accurate name; see [UNCERTAIN].
Pitch_Refresh_Sounding_Voices:
	dec 4, xsp
	push xiz
	lda xbc, (Payload_Bss_Start+0x4218:24)
	ld (xsp + 4), xbc
	inc 5, xwa
	ld xiz, xwa
	cp (xiz), 0x40
	jr nc, Pitch_Refresh_Sounding_Voices_Exit

; loop body of Pitch_Refresh_Sounding_Voices.
Pitch_Refresh_Sounding_Voices_LoopBody:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	ld bc, wa
	ld xwa, (xsp + 4)
	exts xbc
	add xbc, xwa
	ld wa, (xbc + 1)
	and wa, 0x3C
	cp wa, 0x10
	jr z, Pitch_Refresh_Sounding_Voices_BranchB
	cp wa, 0x20
	jr z, Pitch_Refresh_Sounding_Voices_BranchA
	cp wa, 0x8
	jr z, Pitch_Refresh_Sounding_Voices_BranchA
	cp wa, 4:i3
	jr nz, Pitch_Refresh_Sounding_Voices_LoopStep

; BranchA of Pitch_Refresh_Sounding_Voices.
Pitch_Refresh_Sounding_Voices_BranchA:
	ld xwa, xbc
	call Pitch_Emit_Reg400
	ld a, (xiz)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	calr ToneGen_WriteVoice_Long
	jr Pitch_Refresh_Sounding_Voices_LoopStep

; BranchB of Pitch_Refresh_Sounding_Voices.
Pitch_Refresh_Sounding_Voices_BranchB:
	ld xwa, xbc
	call Voice_Pitch_WriteOutputReg_Secondary
	ld a, (xiz)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	calr ToneGen_WriteVoice_Long

; loop step of Pitch_Refresh_Sounding_Voices.
Pitch_Refresh_Sounding_Voices_LoopStep:
	inc 1, xiz
	cp (xiz), 0x40
	jr c, Pitch_Refresh_Sounding_Voices_LoopBody

; common exit of Pitch_Refresh_Sounding_Voices.
Pitch_Refresh_Sounding_Voices_Exit:
	pop xiz
	inc 4, xsp
	ret

; XWA = part record (voice list at +5).  Same walk and same (voice+0x01)&0x3C classification
; as Pitch_Refresh_Sounding_Voices, but the hardware call is ToneGen_WriteVoice_Short, i.e. TG
; register 0x02 -- amplitude.  This is the routine Voice_CC_Volume and Voice_CC_Expression
; call to push a new CC 7 / CC 11 value out to every sounding voice of the part.
Voice_AllVoices_WriteAmplitude:
	dec 4, xsp
	push xiz
	lda xbc, (Payload_Bss_Start+0x4218:24)
	ld (xsp + 4), xbc
	inc 5, xwa
	ld xiz, xwa
	cp (xiz), 0x40
	jr nc, Voice_AllVoices_WriteAmplitude_Exit

; loop body of Voice_AllVoices_WriteAmplitude.
Voice_AllVoices_WriteAmplitude_LoopBody:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	ld bc, wa
	ld xwa, (xsp + 4)
	exts xbc
	add xbc, xwa
	ld wa, (xbc + 1)
	and wa, 0x3C
	cp wa, 0x10
	jr z, Voice_AllVoices_WriteAmplitude_BranchB
	cp wa, 0x20
	jr z, Voice_AllVoices_WriteAmplitude_BranchA
	cp wa, 0x8
	jr z, Voice_AllVoices_WriteAmplitude_BranchA
	cp wa, 4:i3
	jr nz, Voice_AllVoices_WriteAmplitude_LoopStep

; BranchA of Voice_AllVoices_WriteAmplitude.
Voice_AllVoices_WriteAmplitude_BranchA:
	ld xwa, xbc
	call Voice_ApplyPortamento
	jr Voice_AllVoices_WriteAmplitude_LoopStep

; BranchB of Voice_AllVoices_WriteAmplitude.
Voice_AllVoices_WriteAmplitude_BranchB:
	ld xwa, xbc
	call Voice_ApplyPortamento2

; loop step of Voice_AllVoices_WriteAmplitude.
Voice_AllVoices_WriteAmplitude_LoopStep:
	ld a, (xiz)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	calr ToneGen_WriteVoice_Short
	inc 1, xiz
	cp (xiz), 0x40
	jr c, Voice_AllVoices_WriteAmplitude_LoopBody

; common exit of Voice_AllVoices_WriteAmplitude.
Voice_AllVoices_WriteAmplitude_Exit:
	pop xiz
	inc 4, xsp
	ret

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
Voice_AllNotes_SustainRetrigger:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 12), c
	lda xbc, (Payload_Bss_Start+0x4218:24)
	ld (xsp + 4), xbc
	inc 5, xwa
	ld (xsp + 8), xwa
	cp (xwa), 0x40
	jrl nc, Voice_AllNotes_SustainRetrigger_Exit

; loop body of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_LoopBody:
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	muls wa, 0x47
	ld bc, wa
	ld xwa, (xsp + 4)
	lda	xiz, (xwa+bc)
	ld wa, (xiz + 1)
	and wa, 0x3C
	cp wa, 0x10
	jrl z, Voice_AllNotes_SustainRetrigger_BranchF
	cp wa, 0x20
	jr z, Voice_AllNotes_SustainRetrigger_BranchA
	cp wa, 0x8
	jr z, Voice_AllNotes_SustainRetrigger_BranchA
	cp wa, 4:i3
	jrl nz, Voice_AllNotes_SustainRetrigger_LoopStep

; BranchA of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_BranchA:
	ld wa, (xiz + 1)
	extz xwa
	bit 15, wa
	jr nz, Voice_AllNotes_SustainRetrigger_BranchB
	ld xwa, (xiz + 35)
	ld wa, (xwa + 10)
	bit 0, wa
	jr nz, Voice_AllNotes_SustainRetrigger_BranchD

; BranchB of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_BranchB:
	ld wa, (xiz + 1)
	bit 8, wa
	jr z, Voice_AllNotes_SustainRetrigger_BranchC
	ld xwa, xiz
	call Voice_Calc_LevelPair_EGA
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteSegRegs_SameLevel
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	ld bc, (xiz + 45)
	calr ToneGen_WriteVoice_Direct
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	call Voice_Clear_HoldBit
	andmi16 (xiz + 1), 0xFEFF
	jrl Voice_AllNotes_SustainRetrigger_LoopStep

; BranchC of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_BranchC:
	ld xwa, xiz
	call Voice_Calc_LevelPair_EGA
	ld xwa, xiz
	call Voice_Calc_LevelPair_EGB
	ld xwa, xiz
	call Voice_Calc_LevelPair_EGC
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	calr ToneGen_WriteVoice_6Words
	jr Voice_AllNotes_SustainRetrigger_LoopStep

; BranchD of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_BranchD:
	ld wa, (xiz + 1)
	bit 8, wa
	jr z, Voice_AllNotes_SustainRetrigger_BranchE
	ld xwa, xiz
	call Voice_Calc_LevelPair_EGA
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteSegRegs_SameLevel
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	ld bc, (xiz + 45)
	calr ToneGen_WriteVoice_Direct
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	call Voice_Clear_HoldBit
	andmi16 (xiz + 1), 0xFEFF
	jr Voice_AllNotes_SustainRetrigger_LoopStep

; BranchE of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_BranchE:
	ld wa, (xiz + 64)
	and wa, 0xFF
	jr nz, Voice_AllNotes_SustainRetrigger_LoopStep
	ld xwa, xiz
	call Voice_WriteVolume_SetFlag
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	calr ToneGen_WriteNote2ch
	jr Voice_AllNotes_SustainRetrigger_LoopStep

; BranchF of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_BranchF:
	cp (xsp + 12), 0x0
	jr z, Voice_AllNotes_SustainRetrigger_LoopStep
	ld xwa, xiz
	call Voice_WriteVolume_OrPan
	ld xwa, (xsp + 8)
	ld a, (xwa)
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	calr ToneGen_WriteNote2ch

; loop step of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_LoopStep:
	ld xwa, 1:i3
	add (xsp + 8), xwa
	ld xwa, (xsp + 8)
	cp (xwa), 0x40
	jrl c, Voice_AllNotes_SustainRetrigger_LoopBody

; common exit of Voice_AllNotes_SustainRetrigger.
Voice_AllNotes_SustainRetrigger_Exit:
	pop xiz
	lda xsp, (xsp + 10)
	ret

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
TVF_Refresh_Sounding_Voices:
	dec	4, xsp
	push	xiz
	lda	xbc, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+4), xbc
	inc	5, xwa
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	nc, VoiceCC_DataTable_028F75_Epilogue
VoiceCC_DataTable_028F75_Loop:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+4)
	exts	xbc
	add	xbc, xwa
	ld	wa, (xbc+1)
	and	wa, 60
	cp	wa, 8
	jr	z, VoiceCC_DataTable_028F75_Join
	cp	wa, 16
	jr	z, VoiceCC_DataTable_028F75_Skip2
	cp	wa, 32
	jr	z, VoiceCC_DataTable_028F75_Skip
	cp	wa, 4:i3
	jr	nz, VoiceCC_DataTable_028F75_Join
VoiceCC_DataTable_028F75_Skip:
	ld	xwa, xbc
	call	TVF_Emit_Registers
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_TvfPair
	jr	VoiceCC_DataTable_028F75_Join
VoiceCC_DataTable_028F75_Skip2:
	ld	xwa, xbc
	call	TVF_Emit_Registers_Type2
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_TvfPair
VoiceCC_DataTable_028F75_Join:
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, VoiceCC_DataTable_028F75_Loop
VoiceCC_DataTable_028F75_Epilogue:
	pop	xiz
	inc	4, xsp
	ret
; Same walk as above with two extra gates: bit 7 of (voice+0x05) must be set, and for class
; 0x10 also bit 5 of [voice+0x13]+0x0D.  Calls Voice_WriteChPanShift (0x02591D) or
; Voice_WriteChPanShift2 (0x025B6F) with BC = 1 and then
; ToneGen_WriteVoice_Reg21_Reg22 (registers 0x21/0x22).
AudioChannel_AllVoices_Update_PanShift:
	dec	4, xsp
	push	xiz
	lda	xbc, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+4), xbc
	inc	5, xwa
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	nc, AudioChannel_AllVoices_Update_PanShift_Epilogue
AudioChannel_AllVoices_Update_PanShift_Loop:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+4)
	exts	xbc
	add	xbc, xwa
	ld	wa, (xbc+1)
	and	wa, 60
	cp	wa, 8
	jr	z, AudioChannel_AllVoices_Update_PanShift_Join
	cp	wa, 16
	jr	z, AudioChannel_AllVoices_Update_PanShift_Skip2
	cp	wa, 32
	jr	z, AudioChannel_AllVoices_Update_PanShift_Skip
	cp	wa, 4:i3
	jr	nz, AudioChannel_AllVoices_Update_PanShift_Join
AudioChannel_AllVoices_Update_PanShift_Skip:
	bit	7, (xbc+5)	; bit 7,(XBC+0x05)
	jr	z, AudioChannel_AllVoices_Update_PanShift_Join
	ld	xwa, xbc
	ld	bc, 1:i3
	call	Voice_WriteChPanShift
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg21_Reg22
	jr	AudioChannel_AllVoices_Update_PanShift_Join
AudioChannel_AllVoices_Update_PanShift_Skip2:
	ld	xwa, (xbc+19)
	bit	5, (xwa+13)	; bit 5,(XWA+0x0d)
	jr	z, AudioChannel_AllVoices_Update_PanShift_Skip3
	bit	7, (xbc+5)	; bit 7,(XBC+0x05)
	jr	z, AudioChannel_AllVoices_Update_PanShift_Join
AudioChannel_AllVoices_Update_PanShift_Skip3:
	ld	xwa, xbc
	ld	bc, 1:i3
	call	Voice_WriteChPanShift2
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg21_Reg22
AudioChannel_AllVoices_Update_PanShift_Join:
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_AllVoices_Update_PanShift_Loop
AudioChannel_AllVoices_Update_PanShift_Epilogue:
	pop	xiz
	inc	4, xsp
	ret
; Third member of the same family; the ONLY interior address in either code blob that is
; reached by an absolute `call` (from 0x0304C1).  Uses `lda XIZ,XWA+BC` to form the voice
; pointer rather than the store-to-XIZ idiom of its siblings, and branches on the same
; (voice+0x01)&0x3C classes in a different order (0x10 first).
AudioChannel_AllVoices_Update_Variant3:
	dec	8, xsp
	push	xiz
	lda	xbc, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+4), xbc
	inc	5, xwa
	ld	(xsp+8), xwa
	cp8_imm_ri	xwa, 0x40	; cp (XWA),0x40
	jr	nc, AudioChannel_AllVoices_Update_Variant3_Epilogue
AudioChannel_AllVoices_Update_Variant3_Loop:
	ld	xwa, (xsp+8)
	ld	a, (xwa)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+4)
	lda	xiz, (xwa+bc)	; lda XIZ,XWA+BC
	ld	wa, (xiz+1)
	and	wa, 60
	cp	wa, 16
	jr	z, AudioChannel_AllVoices_Update_Variant3_Skip
	cp	wa, 8
	jr	z, AudioChannel_AllVoices_Update_Variant3_Join
	cp	wa, 32
	jr	z, AudioChannel_AllVoices_Update_Variant3_Join
	jr	AudioChannel_AllVoices_Update_Variant3_Join
AudioChannel_AllVoices_Update_Variant3_Skip:
	ld	xwa, (xiz+19)
	ld	xwa, xiz
	call	Voice_Calc_LevelPair_FixedAtk
	ld	xwa, xiz
	ld	bc, 0:i3
	call	Voice_WriteChPanShift2
	ld	xwa, (xsp+8)
	ld	a, (xwa)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg21_Reg22
AudioChannel_AllVoices_Update_Variant3_Join:
	ld	xwa, 1:i3
	add	(xsp+8), xwa
	ld	xwa, (xsp+8)
	cp8_imm_ri	xwa, 0x40	; cp (XWA),0x40
	jr	c, AudioChannel_AllVoices_Update_Variant3_Loop
AudioChannel_AllVoices_Update_Variant3_Epilogue:
	pop	xiz
	inc	8, xsp
	ret
; Handler for audio-channel command 1.  Reached by `jrl` from dispatch stub 0 (0x029E5B).
; Entry WA = value, BC = value2, XDE = the 3-byte routing descriptor.  Calls
; AudioMod_Apply_BusRouting / AudioMod_Apply_Porta_Curve in the 0x0280FE block.
AudioChannel_Handler_Cmd01:
	dec	2, xsp
	push	xiz
	ld	xiz, xde
	ld	(xsp+4), a
	ld	wa, bc
	extz	xwa
	bit	15, wa
	jr	z, AudioChannel_Handler_Cmd01_Skip
	res	15, bc
	jr	AudioChannel_Handler_Cmd01_Join
AudioChannel_Handler_Cmd01_Skip:
	sll	bc, 7
AudioChannel_Handler_Cmd01_Join:
	ld	a, (xsp+4)
	extz	wa
	ld	xde, xiz
	calr	AudioMod_Apply_Porta_Curve
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xiz)
	ld	c, a
	extz	bc
	pushw	32
	ld	wa, de
	ldw	de, 16
	calr	AudioMod_Apply_BusRouting
	ld	a, (xsp+4)
	extz	wa
	call	Voice_Query_PartVoices
	ld	xwa, xhl
	calr	Pitch_Refresh_Sounding_Voices
	pop	xiz
	inc	2, xsp
	ret
; Handler for audio-channel command 3.  Reached by `jrl` from dispatch stub 2 (0x029E65).
AudioChannel_Handler_Cmd03:
	dec	2, xsp
	push	xiz
	ld	xiz, xde
	ld	(xsp+4), a
	ld	a, (xsp+4)
	extz	wa
	extz	bc
	ld	xde, xiz
	calr	AudioMod_Scale_To_Part_1F
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xiz)
	ld	c, a
	extz	bc
	pushw	128
	ld	wa, de
	ldw	de, 64
	calr	AudioMod_Apply_BusRouting
	ld	a, (xsp+4)
	extz	wa
	call	Voice_Query_PartVoices
	ld	xwa, xhl
	calr	TVF_Refresh_Sounding_Voices
	pop	xiz
	inc	2, xsp
	ret
; Handler for audio-channel command 2.  Reached by `jrl` from dispatch stub 1 (0x029E60).
; Note the table order is 1, 2, 3 but the code order is CMD01, CMD03, CMD02.
AudioChannel_Handler_Cmd02:
	dec	6, xsp
	push	xiz
	ld	xiz, xde
	ld	(xsp+8), a
	ld	a, (xsp+8)
	extz	wa
	extz	bc
	ld	xde, xiz
	calr	AudioMod_Scale_To_LevelPairShift
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	a, (xiz)
	ld	c, a
	extz	bc
	pushw	512
	ld	wa, de
	ldw	de, 256
	calr	AudioMod_Apply_BusRouting
	ld	a, (xsp+8)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+16)
	and	a, 192
	cp	a, 192
	jr	z, AudioChannel_Handler_Cmd02_Join
	cp	a, 64
	jr	z, AudioChannel_Handler_Cmd02_Join
	cp	a, 128
	jr	z, AudioChannel_Handler_Cmd02_Skip
	cp	a, 0:i3
	jr	nz, AudioChannel_Handler_Cmd02_Join
	ld	a, (xsp+8)
	extz	wa
	call	Voice_Query_PartVoices_Mask7F
	ld	(xsp+4), xhl
	jr	AudioChannel_Handler_Cmd02_Join
AudioChannel_Handler_Cmd02_Skip:
	ld	a, (xsp+8)
	extz	wa
	call	Voice_Query_PartVoices
	ld	(xsp+4), xhl
AudioChannel_Handler_Cmd02_Join:
	ld	xwa, (xsp+4)
	calr	AudioChannel_AllVoices_Update_PanShift
	pop	xiz
	inc	6, xsp
	ret
; Shared body for audio-channel commands 4..7.  The four dispatch stubs at 0x029E6A,
; 0x029E75, 0x029E80 and 0x029E8B differ only in the sub-index 0..3 they `push` before the
; `calr`, so the pushed word is the handler's bus/slot selector.
; Entry: WA = value (zero-extended), BC = value2 (zero-extended), XDE = routing descriptor,
; (SP+n) = sub-index.
AudioChannel_Handler_Cmd04_07:
	lda	xsp, (xsp-10)
	push	xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+18)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 39
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xwa, (xwa+hl)	; lda XWA,XWA+HL
	cp8_imm_rid8	xwa, 0x03, 0x00	; cp (XWA+0x03),0x00
	jrl	nz, AudioChannel_Handler_Cmd04_07_Skip2
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	0
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field2A
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd04_07_Skip
AudioChannel_Handler_Cmd04_07_Loop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd04_07_Loop
AudioChannel_Handler_Cmd04_07_Skip:
	ld	a, (xsp+12)
	extz	wa
	call	Voice_Query_PartVoices
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	lda	xwa, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+6), xwa
	lda	xwa, (xhl+5)
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jrl	nc, AudioChannel_Handler_Cmd04_07_Epilogue
AudioChannel_Handler_Cmd04_07_Loop2:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+6)
	lda	xwa, (xwa+bc)	; lda XWA,XWA+BC
	call	ExtVoice_Build_SlotRegisters
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg11
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_Handler_Cmd04_07_Loop2
	jrl	AudioChannel_Handler_Cmd04_07_Epilogue
AudioChannel_Handler_Cmd04_07_Skip2:
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	0
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field2A
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd04_07_Skip3
AudioChannel_Handler_Cmd04_07_Loop3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd04_07_Loop3
AudioChannel_Handler_Cmd04_07_Skip3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	extz	wa
	ld	c, a
	extz	bc
	ld	wa, de
	ldw	de, 32
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0x0000	; ld (XSP+0x08),0x0000
	jrl	AudioChannel_Handler_Cmd04_07_Join2
AudioChannel_Handler_Cmd04_07_Loop4:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	iz, (xwa)
	lds_erpb	0xf9, 0	; ld IZH,0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)	; lda XBC,XBC+WA
	ld	a, (xsp+18)
	ld	e, a
	extz	de
	pushw	0
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	pushw	wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	cp8_imm_rid8	xsp, 0x0a, 0x00	; cp (XSP+0x0a),0x00
	jr	nz, AudioChannel_Handler_Cmd04_07_Skip4
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	ldw	(Payload_Bss_Start+0x6396:24), 0
	jr	AudioChannel_Handler_Cmd04_07_Join
AudioChannel_Handler_Cmd04_07_Skip4:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	call	EGEnv_Compute_A
	ld	(Payload_Bss_Start+0x6396:24), hl
AudioChannel_Handler_Cmd04_07_Join:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg18
	incw	1, (xsp+8)
AudioChannel_Handler_Cmd04_07_Join2:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jrl	c, AudioChannel_Handler_Cmd04_07_Loop4
AudioChannel_Handler_Cmd04_07_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	retd	2
; Shared body for commands 0x10..0x13; stubs at 0x029EF5/0x029F00/0x029F0B/0x029F16.
AudioChannel_Handler_Cmd10_13:
	lda	xsp, (xsp-10)
	push	xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+18)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 39
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xwa, (xwa+hl)	; lda XWA,XWA+HL
	cp8_imm_rid8	xwa, 0x02, 0x00	; cp (XWA+0x02),0x00
	jrl	nz, AudioChannel_Handler_Cmd10_13_Skip2
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	0
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field29
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write_Bit3
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd10_13_Skip
AudioChannel_Handler_Cmd10_13_Loop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd10_13_Loop
AudioChannel_Handler_Cmd10_13_Skip:
	ld	a, (xsp+12)
	extz	wa
	call	Voice_Query_PartVoices
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	lda	xwa, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+6), xwa
	lda	xwa, (xhl+5)
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jrl	nc, AudioChannel_Handler_Cmd10_13_Epilogue
AudioChannel_Handler_Cmd10_13_Loop2:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+6)
	lda	xwa, (xwa+bc)	; lda XWA,XWA+BC
	call	ExtVoice_Build_SlotRegisters
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg11
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_Handler_Cmd10_13_Loop2
	jrl	AudioChannel_Handler_Cmd10_13_Epilogue
AudioChannel_Handler_Cmd10_13_Skip2:
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	0
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field29
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write_Bit3
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd10_13_Skip3
AudioChannel_Handler_Cmd10_13_Loop3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd10_13_Loop3
AudioChannel_Handler_Cmd10_13_Skip3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	extz	wa
	ld	c, a
	extz	bc
	ld	wa, de
	ldw	de, 32
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0x0000	; ld (XSP+0x08),0x0000
	jrl	AudioChannel_Handler_Cmd10_13_Join2
AudioChannel_Handler_Cmd10_13_Loop4:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	iz, (xwa)
	lds_erpb	0xf9, 0	; ld IZH,0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)	; lda XBC,XBC+WA
	ld	a, (xsp+18)
	ld	e, a
	extz	de
	pushw	0
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	pushw	wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	cp8_imm_rid8	xsp, 0x0a, 0x00	; cp (XSP+0x0a),0x00
	jr	nz, AudioChannel_Handler_Cmd10_13_Skip4
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	ldw	(Payload_Bss_Start+0x6396:24), 0
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg18
	jr	AudioChannel_Handler_Cmd10_13_Join
AudioChannel_Handler_Cmd10_13_Skip4:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	call	EGEnv_Compute_A_Simple
	ld	(Payload_Bss_Start+0x6392:24), hl
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg16
AudioChannel_Handler_Cmd10_13_Join:
	incw	1, (xsp+8)
AudioChannel_Handler_Cmd10_13_Join2:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jrl	c, AudioChannel_Handler_Cmd10_13_Loop4
AudioChannel_Handler_Cmd10_13_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	retd	2
; Shared body for commands 8..0x0B; stubs at 0x029E96/0x029EA1/0x029EAC/0x029EB7.
AudioChannel_Handler_Cmd08_0B:
	lda	xsp, (xsp-10)
	push	xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+18)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 55
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xwa, (xwa+hl)	; lda XWA,XWA+HL
	cp8_imm_rid8	xwa, 0x03, 0x00	; cp (XWA+0x03),0x00
	jrl	nz, AudioChannel_Handler_Cmd08_0B_Skip2
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	1
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field2A
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd08_0B_Skip
AudioChannel_Handler_Cmd08_0B_Loop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 1:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd08_0B_Loop
AudioChannel_Handler_Cmd08_0B_Skip:
	ld	a, (xsp+12)
	extz	wa
	call	Voice_Query_PartVoices
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	lda	xwa, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+6), xwa
	lda	xwa, (xhl+5)
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jrl	nc, AudioChannel_Handler_Cmd08_0B_Epilogue
AudioChannel_Handler_Cmd08_0B_Loop2:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+6)
	lda	xwa, (xwa+bc)	; lda XWA,XWA+BC
	call	Voice_SubVoice_ComputeAndTrigger
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_EnvLevel
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_Handler_Cmd08_0B_Loop2
	jrl	AudioChannel_Handler_Cmd08_0B_Epilogue
AudioChannel_Handler_Cmd08_0B_Skip2:
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	1
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field2A
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd08_0B_Skip3
AudioChannel_Handler_Cmd08_0B_Loop3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 1:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd08_0B_Loop3
AudioChannel_Handler_Cmd08_0B_Skip3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	extz	wa
	set	2, wa
	ld	c, a
	extz	bc
	ld	wa, de
	ldw	de, 32
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0x0000	; ld (XSP+0x08),0x0000
	jrl	AudioChannel_Handler_Cmd08_0B_Join2
AudioChannel_Handler_Cmd08_0B_Loop4:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	iz, (xwa)
	lds_erpb	0xf9, 0	; ld IZH,0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)	; lda XBC,XBC+WA
	ld	a, (xsp+18)
	ld	e, a
	extz	de
	pushw	1
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	pushw	wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	cp8_imm_rid8	xsp, 0x0a, 0x00	; cp (XSP+0x0a),0x00
	jr	nz, AudioChannel_Handler_Cmd08_0B_Skip4
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	ldw	(Payload_Bss_Start+0x638e:24), 0
	jr	AudioChannel_Handler_Cmd08_0B_Join
AudioChannel_Handler_Cmd08_0B_Skip4:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	call	EGEnv_Compute_B
	ld	(Payload_Bss_Start+0x638e:24), hl
AudioChannel_Handler_Cmd08_0B_Join:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg07
	incw	1, (xsp+8)
AudioChannel_Handler_Cmd08_0B_Join2:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 64
	jrl	c, AudioChannel_Handler_Cmd08_0B_Loop4
AudioChannel_Handler_Cmd08_0B_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	retd	2
; Shared body for commands 0x14..0x17; stubs at 0x029F21/0x029F2C/0x029F37/0x029F42.
AudioChannel_Handler_Cmd14_17:
	lda	xsp, (xsp-10)
	push	xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+18)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 55
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xwa, (xwa+hl)	; lda XWA,XWA+HL
	cp8_imm_rid8	xwa, 0x02, 0x00	; cp (XWA+0x02),0x00
	jrl	nz, AudioChannel_Handler_Cmd14_17_Skip2
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	1
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field29
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write_Bit3
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd14_17_Skip
AudioChannel_Handler_Cmd14_17_Loop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 1:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd14_17_Loop
AudioChannel_Handler_Cmd14_17_Skip:
	ld	a, (xsp+12)
	extz	wa
	call	Voice_Query_PartVoices
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	lda	xwa, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+6), xwa
	lda	xwa, (xhl+5)
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jrl	nc, AudioChannel_Handler_Cmd14_17_Epilogue
AudioChannel_Handler_Cmd14_17_Loop2:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+6)
	lda	xwa, (xwa+bc)	; lda XWA,XWA+BC
	call	Voice_SubVoice_ComputeAndTrigger
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_EnvLevel
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_Handler_Cmd14_17_Loop2
	jrl	AudioChannel_Handler_Cmd14_17_Epilogue
AudioChannel_Handler_Cmd14_17_Skip2:
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	1
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field29
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write_Bit3
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd14_17_Skip3
AudioChannel_Handler_Cmd14_17_Loop3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 1:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd14_17_Loop3
AudioChannel_Handler_Cmd14_17_Skip3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	extz	wa
	set	2, wa
	ld	c, a
	extz	bc
	ld	wa, de
	ldw	de, 32
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0x0000	; ld (XSP+0x08),0x0000
	jrl	AudioChannel_Handler_Cmd14_17_Join2
AudioChannel_Handler_Cmd14_17_Loop4:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	iz, (xwa)
	lds_erpb	0xf9, 0	; ld IZH,0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)	; lda XBC,XBC+WA
	ld	a, (xsp+18)
	ld	e, a
	extz	de
	pushw	1
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	pushw	wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	cp8_imm_rid8	xsp, 0x0a, 0x00	; cp (XSP+0x0a),0x00
	jr	nz, AudioChannel_Handler_Cmd14_17_Skip4
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	ldw	(Payload_Bss_Start+0x638e:24), 0
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg07
	jr	AudioChannel_Handler_Cmd14_17_Join
AudioChannel_Handler_Cmd14_17_Skip4:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	call	EGEnv_Compute_B_Simple
	ld	(Payload_Bss_Start+0x6390:24), hl
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg15
AudioChannel_Handler_Cmd14_17_Join:
	incw	1, (xsp+8)
AudioChannel_Handler_Cmd14_17_Join2:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 64
	jrl	c, AudioChannel_Handler_Cmd14_17_Loop4
AudioChannel_Handler_Cmd14_17_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	retd	2
; Shared body for commands 0x0C..0x0F; stubs at 0x029EC9/0x029ED4/0x029EDF/0x029EEA.
AudioChannel_Handler_Cmd0C_0F:
	lda	xsp, (xsp-10)
	push	xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+18)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 71
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xwa, (xwa+hl)	; lda XWA,XWA+HL
	cp8_imm_rid8	xwa, 0x03, 0x00	; cp (XWA+0x03),0x00
	jrl	nz, AudioChannel_Handler_Cmd0C_0F_Skip2
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	2
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field2A
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd0C_0F_Skip
AudioChannel_Handler_Cmd0C_0F_Loop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 2:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd0C_0F_Loop
AudioChannel_Handler_Cmd0C_0F_Skip:
	ld	a, (xsp+12)
	extz	wa
	call	Voice_Query_PartVoices
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	lda	xwa, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+6), xwa
	lda	xwa, (xhl+5)
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jrl	nc, AudioChannel_Handler_Cmd0C_0F_Epilogue
AudioChannel_Handler_Cmd0C_0F_Loop2:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+6)
	lda	xwa, (xwa+bc)	; lda XWA,XWA+BC
	call	Voice2_UpdatePitch
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg13
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_Handler_Cmd0C_0F_Loop2
	jrl	AudioChannel_Handler_Cmd0C_0F_Epilogue
AudioChannel_Handler_Cmd0C_0F_Skip2:
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	2
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field2A
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd0C_0F_Skip3
AudioChannel_Handler_Cmd0C_0F_Loop3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 2:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd0C_0F_Loop3
AudioChannel_Handler_Cmd0C_0F_Skip3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	extz	wa
	set	3, wa
	ld	c, a
	extz	bc
	ld	wa, de
	ldw	de, 32
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0x0000	; ld (XSP+0x08),0x0000
	jrl	AudioChannel_Handler_Cmd0C_0F_Join2
AudioChannel_Handler_Cmd0C_0F_Loop4:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	iz, (xwa)
	lds_erpb	0xf9, 0	; ld IZH,0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)	; lda XBC,XBC+WA
	ld	a, (xsp+18)
	ld	e, a
	extz	de
	pushw	2
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	pushw	wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	cp8_imm_rid8	xsp, 0x0a, 0x00	; cp (XSP+0x0a),0x00
	jr	nz, AudioChannel_Handler_Cmd0C_0F_Skip4
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	ldw	(Payload_Bss_Start+0x638e:24), 0
	ldw	(Payload_Bss_Start+0x6398:24), 0
	jr	AudioChannel_Handler_Cmd0C_0F_Join
AudioChannel_Handler_Cmd0C_0F_Skip4:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	call	Voice_Freq_WriteLeft
AudioChannel_Handler_Cmd0C_0F_Join:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg07_Or_Reg18
	incw	1, (xsp+8)
AudioChannel_Handler_Cmd0C_0F_Join2:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jrl	c, AudioChannel_Handler_Cmd0C_0F_Loop4
AudioChannel_Handler_Cmd0C_0F_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	retd	2
; Shared body for commands 0x18..0x1B; stubs at 0x029F4D/0x029F58/0x029F63/0x029F6E.
; Command 0x1B is the last index the bound check in AudioChannel_Dispatch admits.
AudioChannel_Handler_Cmd18_1B:
	lda	xsp, (xsp-10)
	push	xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+18)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 71
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xbc
	lda	xwa, (xwa+hl)	; lda XWA,XWA+HL
	cp8_imm_rid8	xwa, 0x02, 0x00	; cp (XWA+0x02),0x00
	jrl	nz, AudioChannel_Handler_Cmd18_1B_Skip2
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	2
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field29
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write_Bit3
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd18_1B_Skip
AudioChannel_Handler_Cmd18_1B_Loop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 2:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd18_1B_Loop
AudioChannel_Handler_Cmd18_1B_Skip:
	ld	a, (xsp+12)
	extz	wa
	call	Voice_Query_PartVoices
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	lda	xwa, (Payload_Bss_Start+0x4218:24)
	ld	(xsp+6), xwa
	lda	xwa, (xhl+5)
	ld	xiz, xwa
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jrl	nc, AudioChannel_Handler_Cmd18_1B_Epilogue
AudioChannel_Handler_Cmd18_1B_Loop2:
	ld	a, (xiz)
	extz	wa
	muls	wa, 71
	ld	bc, wa
	ld	xwa, (xsp+6)
	lda	xwa, (xwa+bc)	; lda XWA,XWA+BC
	call	Voice2_UpdatePitch
	ld	a, (xiz)
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg13
	inc	1, xiz
	cp8_imm_ri	xiz, 0x40	; cp (XIZ),0x40
	jr	c, AudioChannel_Handler_Cmd18_1B_Loop2
	jrl	AudioChannel_Handler_Cmd18_1B_Epilogue
AudioChannel_Handler_Cmd18_1B_Skip2:
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+18)
	extz	wa
	pushw	wa
	pushw	2
	ld	wa, hl
	calr	AudioMod_Apply_Slot_Field29
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write_Bit3
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, AudioChannel_Handler_Cmd18_1B_Skip3
AudioChannel_Handler_Cmd18_1B_Loop3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 2:i3
	call	EFF_RoutingInit
	inc	1, iz
	cp	iz, 4:i3
	jr	c, AudioChannel_Handler_Cmd18_1B_Loop3
AudioChannel_Handler_Cmd18_1B_Skip3:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+18)
	extz	wa
	set	3, wa
	ld	c, a
	extz	bc
	ld	wa, de
	ldw	de, 32
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0x0000	; ld (XSP+0x08),0x0000
	jrl	AudioChannel_Handler_Cmd18_1B_Join2
AudioChannel_Handler_Cmd18_1B_Loop4:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	iz, (xwa)
	lds_erpb	0xf9, 0	; ld IZH,0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)	; lda XBC,XBC+WA
	ld	a, (xsp+18)
	ld	e, a
	extz	de
	pushw	2
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	pushw	wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	cp8_imm_rid8	xsp, 0x0a, 0x00	; cp (XSP+0x0a),0x00
	jr	nz, AudioChannel_Handler_Cmd18_1B_Skip4
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 0x08, 0x00	; or (XBC+WA),0x0008
	ldw	(Payload_Bss_Start+0x638e:24), 0
	ldw	(Payload_Bss_Start+0x6398:24), 0
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg07_Or_Reg18
	jr	AudioChannel_Handler_Cmd18_1B_Join
AudioChannel_Handler_Cmd18_1B_Skip4:
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	call	Voice_Freq_WriteRight
	ld_erpb_rr	a, 0xf8	; ld A,IZL
	extz	wa
	lda	xbc, (ToneGen_StagingBlock:24)
	calr	ToneGen_WriteVoice_Reg15_Or_Reg16
AudioChannel_Handler_Cmd18_1B_Join:
	incw	1, (xsp+8)
AudioChannel_Handler_Cmd18_1B_Join2:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jrl	c, AudioChannel_Handler_Cmd18_1B_Loop4
AudioChannel_Handler_Cmd18_1B_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	retd	2

; The modulation-routing dispatcher.  Entry XDE = a 3-byte routing descriptor; WA and BC
; carry the value pair.  Reads L = (XDE+1) & 0x3F, that is the DESTINATION COMMAND ID, and
; rejects it unless 1 <= id <= 0x1B.  index = id - 1, doubled, used to read a word from the
; offset table at 0x00F703; that offset is added to the stub-table base 0x029E5B and jumped
; to.  Bit 7 of (XDE+1) is NOT part of the id -- it is the bipolar flag the handlers test.
; Callers: Voice_ModWheel_Apply (twice), Voice_ChanPressure (twice), Voice_PitchBend
; (twice, as a tail `jrl`), and the 0x02A061 block.
AudioChannel_Dispatch:
	ld l, (xde + 1)
	and l, 0x3F
	extz hl
	dec 1, hl
	cp hl, 0:i3
	ret lt
	cp hl, 0x1A
	ret gt
	add hl, hl
	lda xix, (AudioChannel_CaseOffsets:24)
	ld	hl, (xix+hl)
	lda xix, (AudioChannel_DispatchTable:24)
	jp	t, (xix+hl)
; --- AudioChannel_DispatchTable: 25 handler stubs for audio channel commands ---
; Entry: WA = command parameter, BC = secondary parameter
; Each stub: zero-extends WA/BC, pushes channel index (0-3),
; calls a common audio handler via calr, then returns.
; First 3 entries redirect via jrl to alternate handler routines.
; Called from jump table indexed by HL.
; --- 0x029E5B-0x029F72  AudioChannel_DispatchTable
; 27 entries.  Entries 0..2 are 5 bytes each (`extz WA` + `jrl` to 0x0290E7 / 0x029172 /
; 0x029134).  Entries 3..26 are 11 bytes each:
;     extz WA ; extz BC ; push <sub-index 0..3> ; calr <handler> ; ret
; giving six handler bodies x four sub-indices.  Indexed indirectly through the word offset
; table at 0x00F703 (values 0x0000,0x0005,0x000A,0x000F, then +0x000B per entry).
AudioChannel_DispatchTable:
	extz	wa
	jrl	AudioChannel_Handler_Cmd01
AudioChannel_Stub_Cmd02:
	extz	wa
	jrl	AudioChannel_Handler_Cmd02
AudioChannel_Stub_Cmd03:
	extz	wa
	jrl	AudioChannel_Handler_Cmd03
AudioChannel_Stub_Cmd04:
	extz	wa
	extz	bc
	pushw	0
	calr	AudioChannel_Handler_Cmd04_07
	ret
AudioChannel_Stub_Cmd05:
	extz	wa
	extz	bc
	pushw	1
	calr	AudioChannel_Handler_Cmd04_07
	ret
AudioChannel_Stub_Cmd06:
	extz	wa
	extz	bc
	pushw	2
	calr	AudioChannel_Handler_Cmd04_07
	ret
AudioChannel_Stub_Cmd07:
	extz	wa
	extz	bc
	pushw	3
	calr	AudioChannel_Handler_Cmd04_07
	ret
AudioChannel_Stub_Cmd08:
	extz	wa
	extz	bc
	pushw	0
	calr	AudioChannel_Handler_Cmd08_0B
	ret
AudioChannel_Stub_Cmd09:
	extz	wa
	extz	bc
	pushw	1
	calr	AudioChannel_Handler_Cmd08_0B
	ret
AudioChannel_Stub_Cmd0A:
	extz	wa
	extz	bc
	pushw	2
	calr	AudioChannel_Handler_Cmd08_0B
	ret
AudioChannel_Stub_Cmd0B:
	extz	wa
	extz	bc
	pushw	3
	calr	AudioChannel_Handler_Cmd08_0B
	ret
AudioChannel_Stub_Cmd0C:
	extz	wa
	extz	bc
	pushw	0
	calr	AudioChannel_Handler_Cmd0C_0F
	ret
AudioChannel_Stub_Cmd0D:
	extz	wa
	extz	bc
	pushw	1
	calr	AudioChannel_Handler_Cmd0C_0F
	ret
AudioChannel_Stub_Cmd0E:
	extz	wa
	extz	bc
	pushw	2
	calr	AudioChannel_Handler_Cmd0C_0F
	ret
AudioChannel_Stub_Cmd0F:
	extz	wa
	extz	bc
	pushw	3
	calr	AudioChannel_Handler_Cmd0C_0F
	ret
AudioChannel_Stub_Cmd10:
	extz	wa
	extz	bc
	pushw	0
	calr	AudioChannel_Handler_Cmd10_13
	ret
AudioChannel_Stub_Cmd11:
	extz	wa
	extz	bc
	pushw	1
	calr	AudioChannel_Handler_Cmd10_13
	ret
AudioChannel_Stub_Cmd12:
	extz	wa
	extz	bc
	pushw	2
	calr	AudioChannel_Handler_Cmd10_13
	ret
AudioChannel_Stub_Cmd13:
	extz	wa
	extz	bc
	pushw	3
	calr	AudioChannel_Handler_Cmd10_13
	ret
AudioChannel_Stub_Cmd14:
	extz	wa
	extz	bc
	pushw	0
	calr	AudioChannel_Handler_Cmd14_17
	ret
AudioChannel_Stub_Cmd15:
	extz	wa
	extz	bc
	pushw	1
	calr	AudioChannel_Handler_Cmd14_17
	ret
AudioChannel_Stub_Cmd16:
	extz	wa
	extz	bc
	pushw	2
	calr	AudioChannel_Handler_Cmd14_17
	ret
AudioChannel_Stub_Cmd17:
	extz	wa
	extz	bc
	pushw	3
	calr	AudioChannel_Handler_Cmd14_17
	ret
AudioChannel_Stub_Cmd18:
	extz	wa
	extz	bc
	pushw	0
	calr	AudioChannel_Handler_Cmd18_1B
	ret
AudioChannel_Stub_Cmd19:
	extz	wa
	extz	bc
	pushw	1
	calr	AudioChannel_Handler_Cmd18_1B
	ret
AudioChannel_Stub_Cmd1A:
	extz	wa
	extz	bc
	pushw	2
	calr	AudioChannel_Handler_Cmd18_1B
	ret
AudioChannel_Stub_Cmd1B:
	extz	wa
	extz	bc
	pushw	3
	calr	AudioChannel_Handler_Cmd18_1B
	ret
	ret

; Entry WA = part index, BC = CC 1 value.  Follows the patch pointer at part+0x06
; (0x04136E + part*0x11F) and switches on (patch+0x10) & 0xC0:
;   0x80              -> stereo path: descriptors at patch+0x15 + 3*i, i = 0..1
;   0x40 / 0xC0       -> poly path:   descriptors at patch+0x17 + 3*i, i = 0..1
;   0x00              -> return
; Each iteration calls AudioChannel_Dispatch with XDE pointing at the 3-byte descriptor.
; So a patch declares, per modulation source, up to two destination commands with depths.
Voice_ModWheel_Apply:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 10), c
	ld (xsp + 12), a
	ld a, (xsp + 12)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x80
	jr z, Voice_ModWheel_Apply_StereoLoopA
	cp a, 0x40
	jr z, Voice_ModWheel_Apply_StereoPath
	cp a, 0xC0
	jr z, Voice_ModWheel_Apply_StereoPath
	cp a, 0:i3
	jrl nz, Voice_ModWheel_Apply_Exit

; StereoPath of Voice_ModWheel_Apply.
Voice_ModWheel_Apply_StereoPath:
	ldw (xsp + 8), 0x0
	cpw (xsp + 8), 0x2
	jrl nc, Voice_ModWheel_Apply_Exit

; PolyPath of Voice_ModWheel_Apply.
Voice_ModWheel_Apply_PolyPath:
	ld a, (xsp + 12)
	ldfr_berp A, 0xF4
	extz iy
	ld a, (xsp + 10)
	ldfr_berp A, 0xF0
	extz ix
	ld a, (xsp + 12)
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Part_PatchRecord_Ptr:24)
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	add xbc, 0x17
	ld xiz, xbc
	add	xiz, (xhl+de)
	ld wa, iy
	ld bc, ix
	ld xde, xiz
	calr AudioChannel_Dispatch
	incw 1, (xsp + 8)
	cpw (xsp + 8), 0x2
	jr c, Voice_ModWheel_Apply_PolyPath
	jr Voice_ModWheel_Apply_Exit

; StereoLoopA of Voice_ModWheel_Apply.
Voice_ModWheel_Apply_StereoLoopA:
	ld a, (xsp + 12)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0x0
	cpw (xsp + 8), 0x2
	jr nc, Voice_ModWheel_Apply_Exit

; StereoLoopB of Voice_ModWheel_Apply.
Voice_ModWheel_Apply_StereoLoopB:
	ld a, (xsp + 12)
	ldfr_berp A, 0xF0
	extz ix
	ld a, (xsp + 10)
	ld l, a
	extz hl
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	add xbc, 0x15
	ld xde, xbc
	add xde, (xsp + 4)
	ld wa, ix
	ld bc, hl
	calr AudioChannel_Dispatch
	incw 1, (xsp + 8)
	cpw (xsp + 8), 0x2
	jr c, Voice_ModWheel_Apply_StereoLoopB

; common exit of Voice_ModWheel_Apply.
Voice_ModWheel_Apply_Exit:
	pop xiz
	lda xsp, (xsp + 10)
	ret

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
VoiceModWheel_DataTable_02A061:
	dec	4, xsp
	push	qiz
	ld	(xsp+2), c
	ld	(xsp+4), a
	ld	a, (xsp+4)
	extz	wa
	muls	wa, 0x11F
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+16)
	and	a, 0xC0
	cp	a, 0x40
	jr	z, VoiceModWheel_DataTable_02A061_Check
	cp	a, 0xC0
	jr	z, VoiceModWheel_DataTable_02A061_Check
	cp	a, 0:i3
	jr	nz, VoiceModWheel_DataTable_02A061_Exit
VoiceModWheel_DataTable_02A061_Check:
	ldib_erp	0xfb, 0	; ld QIZH,0
	cpib_erp	0xfb, 2	; cp QIZH,2
	jr	nc, VoiceModWheel_DataTable_02A061_Exit
VoiceModWheel_DataTable_02A061_Loop:
	ld	a, (xsp+4)
	ld	l, a
	extz	hl
	ld	a, (xsp+2)
	ld	e, a
	extz	de
	ld	a, (xsp+4)
	extz	wa
	muls	wa, 0x11F
	ld	bc, wa
	lda	xix, (Part_PatchRecord_Ptr:24)
	ld_erpb_rr	a, 0xfb	; ld A,QIZH
	extz	wa
	muls	wa, 3
	ld	iy, wa
	add	iy, 0x1D
	ld	xwa, (xix+bc)
	lda	xix, (xwa+iy)	; lda XIX,XWA+IY
	ld	wa, hl
	ld	bc, de
	ld	xde, xix
	calr	AudioChannel_Dispatch
	inc1b_erp	0xfb	; inc 1,QIZH
	cpib_erp	0xfb, 2	; cp QIZH,2
	jr	c, VoiceModWheel_DataTable_02A061_Loop
VoiceModWheel_DataTable_02A061_Exit:
	pop	qiz
	inc	4, xsp
	ret

; A = part index, C = CC 0x5E value.  Reads the patch pointer at part+0x06 and takes a
; different path when (patch+0x10) & 0xC0 == 0xC0.  Updates the part's portamento state and
; then hands over to Voice_PortamentoSlots_WriteHW.
Voice_Portamento_OnHandler:
	dec 4, xsp
	ld (xsp), c
	ld (xsp + 2), a
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x80
	jr z, Voice_Portamento_OnHandler_Exit
	cp a, 0x40
	jr z, Voice_Portamento_OnHandler_Exit
	cp a, 0xC0
	jr z, Voice_Portamento_OnHandler_C0Mode
	cp a, 0:i3
	jr nz, Voice_Portamento_OnHandler_Exit

; C0Mode of Voice_Portamento_OnHandler.
Voice_Portamento_OnHandler_C0Mode:
	ld a, (xsp + 2)
	ld e, a
	extz de
	ld a, (xsp)
	ld c, a
	extz bc
	ld wa, de
	calr Voice_CC_SetSostenutoFlag
	ld a, (xsp + 2)
	extz wa
	ld bc, 1:i3
	call AlgoType_StateWrite
	ld a, (xsp + 2)
	ld e, a
	extz de
	ld a, (xsp)
	ld c, a
	extz bc
	ld wa, de
	call VoiceAlloc_WithRoutingFlag
	ld a, (xsp + 2)
	extz wa
	call Partial_Build_Present_Word
	ld a, (xsp + 2)
	extz wa
	call EnvTranspose_UpdateLoop
	ld a, (xsp + 2)
	extz wa
	call VoiceNoteParam_UpdateLoop
	ld a, (xsp + 2)
	extz wa
	call Voice_ActiveFlag_CheckAndLoad
	ld a, (xsp + 2)
	extz wa
	call Voice_SecondaryParam_Epilogue
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2558:24)
	ld	(xbc+wa), l

; common exit of Voice_Portamento_OnHandler.
Voice_Portamento_OnHandler_Exit:
	inc 4, xsp
	ret

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

