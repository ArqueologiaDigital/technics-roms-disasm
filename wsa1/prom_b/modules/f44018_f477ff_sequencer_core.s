
; ==============================================================================
; 0xF44018-0xF477FF -- THE MODULE THAT OPENS IMMEDIATELY AFTER THE THUNK TABLE
;   64 thunk slots, three adjacent runs, and the highest summed reference count
;   of any group in the image
; ==============================================================================
;
; WHY THIS BLOCK.  notes/prom_b_module_frontier.py ranks T_F409C0-T_F40A30,
; T_F40A3C-T_F40A64 and T_F40A6C-T_F40AC8 -- three ADJACENT runs, all pointing
; into this one range -- with a summed reference upper bound of 81 + 41 + 7 = 129,
; the highest of any group in prom_b.  T_Seq_RequestRewind -> 0xF4542D (x24) and
; T_F40A1C -> 0xF44367 (x15) are both in notes/prom_b_call_graph.py's top ten
; unconverted targets.  64 SLOTS point in here, resolving to 62 distinct TARGETS
; -- two slots share a target with another.  Both numbers are derived by --checks,
; and stating which unit a number is in is not pedantry here: the first draft of
; this file compared the slot count 64 against the target count and failed, and
; the repair guessed 66 slots and failed again.
;
; ⚠ WHERE THE EDGES COME FROM.  Neither is the decode's opinion:
;   START 0xF44018 is the first byte AFTER the 0xF40000 thunk table, whose extent
;         is fixed by scripts/analysis/prom_b_thunk_table.py and which this file
;         already converts.
;   END   0xF47800 is itself a thunk target (T_BStore_StepCursorToNextLeadByte) -- an address the linker
;         chose -- and the 5,867 bytes in front of it are pure 0x0E.
; Between them the two code segments decode with ZERO undecodable bytes and each
; ends exactly on its segment boundary.
;
; THE TWO DATA OBJECTS
;
;   0xF45E9A  Dispatch_3629 -- 5 pointers on (0x3629).  Length fixed twice:
;             entries [3] and [4] BOTH hold 0xF45EAE, the byte immediately after
;             the table, and a sixth entry would read a non-address.  ⚠ [3] and
;             [4] are DEAD -- a whole-image decode finds (0x3629) written only
;             with 0, 1 and 2.
;
;   0xF46074  WorkspaceDefaults -- 161 bytes seeding the banked 3 KiB workspace
;             at 0x00603400 that notes/FINDINGS-prom_b-block-store.md derives.
;             ⚠ Only the first two blocks' lengths are established (8 bytes each,
;             one a byte loop and one a WORD loop); the rest of the partition is
;             stated as unknown rather than guessed, because an automated read of
;             those loops got one of the two lengths wrong.
;
; ⚠ WHAT IS NOT ESTABLISHED.  What any of the 128 routines DO.  They are
; `sub_XXXXXX` with a computed header claiming only the entry point.
;
; REGENERATE:  python3 notes/gen_prom_b_f44018_module.py
; CHECKS:      python3 notes/gen_prom_b_f44018_module.py --checks
; ==============================================================================


; --------------------------------------------------------------------------
; SeqRecord_TerminateTrackAtCursor_Veneer
; Called from: T_SeqRecord_TerminateTrackAtCursor_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_TerminateTrackAtCursor_Veneer holds `jp 0x00F44018`, and 0xF44018 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_TerminateTrackAtCursor_Veneer: jumps to SeqRecord_TerminateTrackAtCursor (notes/prom_ab_wrapper_names.py; DERIVATIVE)
SeqRecord_TerminateTrackAtCursor_Veneer:		; <- T_SeqRecord_TerminateTrackAtCursor_Veneer
	jrl	SeqRecord_TerminateTrackAtCursor	; F44018  jrl T,0xf458fe

; --------------------------------------------------------------------------
; SeqRecord_SetRecordedTracksPlaying_Veneer
; Called from: T_SeqRecord_SetRecordedTracksPlaying_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_SetRecordedTracksPlaying_Veneer holds `jp 0x00F4401B`, and 0xF4401B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SetRecordedTracksPlaying_Veneer: jumps to SeqRecord_SetRecordedTracksPlaying (notes/prom_ab_wrapper_names.py; DERIVATIVE)
SeqRecord_SetRecordedTracksPlaying_Veneer:		; <- T_SeqRecord_SetRecordedTracksPlaying_Veneer
	jrl	SeqRecord_SetRecordedTracksPlaying	; F4401B  jrl T,0xf45942

; --------------------------------------------------------------------------
; Seq_StopAll_Veneer
; Called from: T_Seq_StopAll_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_Seq_StopAll_Veneer holds `jp 0x00F4401E`, and 0xF4401E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_StopAll_Veneer: jumps to Seq_StopAll (notes/prom_ab_wrapper_names.py; DERIVATIVE)
Seq_StopAll_Veneer:		; <- T_Seq_StopAll_Veneer
	jrl	Seq_StopAll	; F4401E  jrl T,0xf455cc

; --------------------------------------------------------------------------
; Var34D1_SetBits20_Veneer
; Called from: T_Var34D1_SetBits20_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_Var34D1_SetBits20_Veneer holds `jp 0x00F44021`, and 0xF44021 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Var34D1_SetBits20_Veneer: a jump to Var34D1_SetBits20 -- `jrl Var34D1_SetBits20`.
Var34D1_SetBits20_Veneer:		; <- T_Var34D1_SetBits20_Veneer
	jrl	Var34D1_SetBits20	; F44021  jrl T,0xf45fc4

; --------------------------------------------------------------------------
; sub_F44024
; Called from: T_F40A84 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40A84 holds `jp 0x00F44024`, and 0xF44024 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44024:		; <- T_F40A84
	jrl	sub_F45F4B	; F44024  jrl T,0xf45f4b

; --------------------------------------------------------------------------
; MidiOut_SendSongPosition_Veneer
; Called from: T_MidiOut_SendSongPosition_Veneer (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_MidiOut_SendSongPosition_Veneer holds `jp 0x00F44027`, and 0xF44027 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiOut_SendSongPosition_Veneer: jumps to MidiOut_SendSongPosition (notes/prom_ab_wrapper_names.py; DERIVATIVE)
MidiOut_SendSongPosition_Veneer:		; <- T_MidiOut_SendSongPosition_Veneer
	jrl	MidiOut_SendSongPosition	; F44027  jrl T,0xf44ca7

; --------------------------------------------------------------------------
; SeqBufRing_Discard_Veneer
; Called from: T_SeqBufRing_Discard_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqBufRing_Discard_Veneer holds `jp 0x00F4402A`, and 0xF4402A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqBufRing_Discard_Veneer: a jump to SeqBufRing_Discard -- `jrl SeqBufRing_Discard`.
SeqBufRing_Discard_Veneer:		; <- T_SeqBufRing_Discard_Veneer
	jrl	SeqBufRing_Discard	; F4402A  jrl T,0xf45975

; --------------------------------------------------------------------------
; sub_F4402D
; Called from: T_F40A44 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40A44 holds `jp 0x00F4402D`, and 0xF4402D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4402D:		; <- T_F40A44
	jrl	sub_F4598A	; F4402D  jrl T,0xf4598a

; --------------------------------------------------------------------------
; TimedEventRing_Discard_Veneer
; Called from: T_TimedEventRing_Discard_Veneer (x0); in-module: 0xF4476F
; Touches: nothing with an absolute address
; Evidence: thunk slot T_TimedEventRing_Discard_Veneer holds `jp 0x00F44030`, and 0xF44030 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TimedEventRing_Discard_Veneer: a jump to TimedEventRing_Discard -- `jrl TimedEventRing_Discard`.
TimedEventRing_Discard_Veneer:		; <- T_TimedEventRing_Discard_Veneer
	jrl	TimedEventRing_Discard	; F44030  jrl T,0xf45b0a

; --------------------------------------------------------------------------
; Seq_RewindToStart_Veneer
; Called from: T_Seq_RewindToStart_Veneer (x0); in-module: 0xF446C8
; Touches: nothing with an absolute address
; Evidence: thunk slot T_Seq_RewindToStart_Veneer holds `jp 0x00F44033`, and 0xF44033 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RewindToStart_Veneer: jumps to Seq_RewindToStart (notes/prom_ab_wrapper_names.py; DERIVATIVE)
Seq_RewindToStart_Veneer:		; <- T_Seq_RewindToStart_Veneer
	jrl	Seq_RewindToStart	; F44033  jrl T,0xf45b1f

; --------------------------------------------------------------------------
; SeqTrack_QueueNoteOffAndBendCentre_Veneer
; Called from: T_SeqTrack_QueueNoteOffAndBendCentre_Veneer (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqTrack_QueueNoteOffAndBendCentre_Veneer holds `jp 0x00F44036`, and 0xF44036 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_QueueNoteOffAndBendCentre_Veneer: jumps to SeqTrack_QueueNoteOffAndBendCentre (notes/prom_ab_wrapper_names.py; DERIVATIVE)
SeqTrack_QueueNoteOffAndBendCentre_Veneer:		; <- T_SeqTrack_QueueNoteOffAndBendCentre_Veneer
	jrl	SeqTrack_QueueNoteOffAndBendCentre	; F44036  jrl T,0xf45b6e

; --------------------------------------------------------------------------
; Nop_CallsEmptyDirectorySlot_Veneer
; Called from: T_Nop_CallsEmptyDirectorySlot_Veneer (x1); in-module: 0xF44773
; Touches: nothing with an absolute address
; Evidence: thunk slot T_Nop_CallsEmptyDirectorySlot_Veneer holds `jp 0x00F44039`, and 0xF44039 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
Nop_CallsEmptyDirectorySlot_Veneer:		; <- T_Nop_CallsEmptyDirectorySlot_Veneer
	jrl	Nop_CallsEmptyDirectorySlot	; F44039  jrl T,0xf45d04

; --------------------------------------------------------------------------
; Seq_LocateNowIfPending_Veneer
; Called from: T_Seq_LocateNowIfPending_Veneer (x0); in-module: 0xF44858 0xF4486F
; Touches: nothing with an absolute address
; Evidence: thunk slot T_Seq_LocateNowIfPending_Veneer holds `jp 0x00F4403C`, and 0xF4403C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_LocateNowIfPending_Veneer: `jrl` to Seq_LocateNowIfPending: when the delayed-locate countdown (0x0C05) bit 7 is armed it
;   cancels it ((0x0C05) := 0), locates every track to the current measure at once (Seq_LocateToCurrentMeasure),
;   releases all track notes, resets the playing-slot controllers (T_F41F18) and runs Seq_ResetPositionOnRequest.
;   Seq_RewindOnRequest's cycle path sets (0x3552) to the cycle start and (0x0C05) bit 7 just before calling it; the
;   countdown is otherwise run by Seq_DelayedLocateToMeasure_Call. Basis: caller + body (target read). (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
Seq_LocateNowIfPending_Veneer:		; <- T_Seq_LocateNowIfPending_Veneer
	jrl	Seq_LocateNowIfPending	; F4403C  jrl T,0xf44c37

; --------------------------------------------------------------------------
; SeqRecord_ResetSlotLists_Veneer
; Called from: T_SeqRecord_ResetSlotLists_Veneer (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_ResetSlotLists_Veneer holds `jp 0x00F4403F`, and 0xF4403F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_ResetSlotLists_Veneer: jumps to SeqRecord_ResetSlotLists (notes/prom_ab_wrapper_names.py; DERIVATIVE)
SeqRecord_ResetSlotLists_Veneer:		; <- T_SeqRecord_ResetSlotLists_Veneer
	jrl	SeqRecord_ResetSlotLists	; F4403F  jrl T,0xf45263

; --------------------------------------------------------------------------
; BStore_BootPhase0
; Called from: T_BStore_BootPhase0 (x0)
; Touches:   |  0x003604
; Calls:   sub_F45E49
; Evidence: thunk slot T_BStore_BootPhase0 holds `jp 0x00F44042`, and 0xF44042 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_BootPhase0: module 19's boot phase 0 handler -- ModuleInitDirectory_F82641[19]'s vector 0xF44000, slot 0
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
BStore_BootPhase0:		; <- T_BStore_BootPhase0
	push	xix	; F44042  push XIX
	push	xiy	; F44043  push XIY
	push	xhl	; F44044  push XHL
	push	xwa	; F44045  push XWA
	ld	xiy, BStore_HeapBase	; F44046  ld XIY,0x00003604
	xor	hl, hl	; F4404B  xor HL,HL
	jr	z, BStore_BootPhase0_Skip	; F4404D  jr Z,0xf44070
	jr	BStore_BootPhase0_Join	; F4404F  jr T,0xf4408d
	ld	xix, WorkspaceDefaults + 0x16	; F44051  ld XIX,0x00f4608a
	ld	xwa, (xix+hl)	; F44056  ld XWA,(XIX+HL)
	ld	(xiy+hl), xwa	; F4405B  ld (XIY+HL),XWA
	add	hl, 4	; F44060  add HL,0x0004
	ld	wa, (xix+hl)	; F44064  ld WA,(XIX+HL)
	ld	(xiy+hl), wa	; F44069  ld (XIY+HL),WA
	jr	BStore_BootPhase0_Join	; F4406E  jr T,0xf4408d
BStore_BootPhase0_Skip:
	ld	xix, WorkspaceDefaults + 0x10	; F44070  ld XIX,0x00f46084
	ld	xwa, (xix+hl)	; F44075  ld XWA,(XIX+HL)
	ld	(xiy+hl), xwa	; F4407A  ld (XIY+HL),XWA
	add	hl, 4	; F4407F  add HL,0x0004
	ld	wa, (xix+hl)	; F44083  ld WA,(XIX+HL)
	ld	(xiy+hl), wa	; F44088  ld (XIY+HL),WA
BStore_BootPhase0_Join:
	calr	sub_F45E49	; F4408D  calr 0xf45e49
	pop	xwa	; F44090  pop XWA
	pop	xhl	; F44091  pop XHL
	pop	xiy	; F44092  pop XIY
	pop	xix	; F44093  pop XIX
	ret	; F44094  ret

; --------------------------------------------------------------------------
; BStore_BootPhase2And4
; Called from: T_F44008 (x0), T_F44010 (x0)
; Touches: nothing with an absolute address
; Calls:   BStore_ResetWorkspaceToDefault T_BStore_Workspace_StoreParamImage BStore_CopyWorkspaceToAllBanks
; Evidence: thunk slot T_F44008 holds `jp 0x00F44095`, and 0xF44095 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_BootPhase2And4: module 19's boot phase 2/4 handler -- ModuleInitDirectory_F82641[19]'s vector 0xF44000, slots 2, 4
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
BStore_BootPhase2And4:		; <- T_F44008, T_F44010
	calr	BStore_ResetWorkspaceToDefault	; F44095  calr 0xf44260
	call	T_BStore_Workspace_StoreParamImage	; F44098  call 0xf42574
	calr	BStore_CopyWorkspaceToAllBanks	; F4409C  calr 0xf440a0
	ret	; F4409F  ret

; --------------------------------------------------------------------------
; BStore_CopyWorkspaceToAllBanks
; Called from: T_BStore_CopyWorkspaceToAllBanks (x0); in-module: 0xF4409C 0xF455A9
; Touches:   |  0x603400 0x610000
; Evidence: thunk slot T_BStore_CopyWorkspaceToAllBanks holds `jp 0x00F440A0`, and 0xF440A0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CopyWorkspaceToAllBanks: Copies the 0xC00-byte song workspace at 0x603400 into each of the ten bank copies at
;   0x610000 + n*0xC00 (n = 0..9), 0x600 words per bank (ldirw). Basis: callers + body -- runs right after the
;   workspace reset (BStore_ResetWorkspaceToDefault) in both of its callers. (notes/naming-pilot-2026-10-06/proposals_wave2_d.json)
BStore_CopyWorkspaceToAllBanks:		; <- T_BStore_CopyWorkspaceToAllBanks
	xor	xwa, xwa	; F440A0  xor XWA,XWA
BStore_CopyWorkspaceToAllBanks_Loop:
	ldw	bc, 1536	; F440A2  ld BC,0x0600
	ld	xhl, 6304768	; F440A5  ld XHL,0x00603400
	ld	xde, 6356992	; F440AA  ld XDE,0x00610000
	push	xwa	; F440AF  push XWA
	mul	wa, 3072	; F440B0  mul WA,0x0c00
	lda	xde, (xde+wa)	; F440B4  lda XDE,XDE+WA
	pop	xwa	; F440B9  pop XWA
	ldirw93	; F440BA  ldirw
	inc	1, a	; F440BC  inc 1,A
	cp	a, 10	; F440BE  cp A,0x0a
	jr	c, BStore_CopyWorkspaceToAllBanks_Loop	; F440C1  jr C,0xf440a2
	ret	; F440C3  ret

; --------------------------------------------------------------------------
; BStore_BootPhase3
; Called from: T_BStore_BootPhase3 (x0)
; Touches: (0x34D3) (0x3552) (0x360A) (0x360C)
; Calls:   TimedEventRing_Discard SeqBufRing_Discard Seq_RequestRewind T_BStore_LoadGeometry_Call T_SongEdit_ResetJobFields T_BStore_LatchHeapBase_Veneer
;          sub_F44505 T_NoteRouting_RebuildForSong BStore_CopyByteD6ToAllBanks BStore_ClearPasswordProtectedBanks T_EditScreen_BootPhase2And4 SeqCycle_ResetSettings +1
;          more
; Evidence: thunk slot T_BStore_BootPhase3 holds `jp 0x00F440C4`, and 0xF440C4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_BootPhase3: module 19's boot phase 3 handler -- ModuleInitDirectory_F82641[19]'s vector 0xF44000, slot 3
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
BStore_BootPhase3:		; <- T_BStore_BootPhase3
	cp	(Variant_Flag:8), 0x02	; F440C4  cp (0xc4),0x02
	jr	nz, BStore_BootPhase3_Skip	; F440C8  jr NZ,0xf440d7
	xor	xwa, xwa	; F440CA  xor XWA,XWA
	ld	(6304798:24), xwa	; F440CC  ld (0x60341e),XWA
	calr	TimedEventRing_Discard	; F440D1  calr 0xf45b0a
	calr	SeqBufRing_Discard	; F440D4  calr 0xf45975
BStore_BootPhase3_Skip:
	ldw	(13650:16), 1	; F440D7  ld (0x3552),0x0001
	ld	xwa, (6304798:24)	; F440DD  ld XWA,(0x60341e)
	ld	(13836:16), xwa	; F440E2  ld (0x360c),XWA
	calr	Seq_RequestRewind	; F440E6  calr 0xf4542d
	bit	0, (0x34d3:16)	; F440E9  bit 0,(0x34d3)
	jr	z, BStore_BootPhase3_Skip2	; F440ED  jr Z,0xf440f4
	or	(0x34d3:16), 0x04	; F440EF  or (0x34d3),0x04
BStore_BootPhase3_Skip2:
	call	T_BStore_LoadGeometry_Call	; F440F4  call 0xf427fc
	call	T_SongEdit_ResetJobFields	; F440F8  call 0xf427b8
	call	T_BStore_LatchHeapBase_Veneer	; F440FC  call 0xf42890
	calr	sub_F44505	; F44100  calr 0xf44505
	call	T_NoteRouting_RebuildForSong	; F44103  call 0xf411b8
	ld	(6304982:24), 0	; F44107  ld (0x6034d6),0x00
	calr	BStore_CopyByteD6ToAllBanks	; F4410D  calr 0xf44143
	ld	a, (6304981:24)	; F44110  ld A,(0x6034d5)
	ld	(BStore_CurrentBank:16), a	; F44115  ld (0x360a),A
	ld	xwa, (13836:16)	; F44119  ld XWA,(0x360c)
	push	xwa	; F4411D  push XWA
	calr	BStore_ClearPasswordProtectedBanks	; F4411E  calr 0xf441ab
	pop	xwa	; F44121  pop XWA
	ld	(13836:16), xwa	; F44122  ld (0x360c),XWA
	call	T_EditScreen_BootPhase2And4	; F44126  call 0xf40300
	calr	SeqCycle_ResetSettings	; F4412A  calr 0xf44237
	calr	Seq_ApplySongBeatsPerBar	; F4412D  calr 0xf44131
	ret	; F44130  ret

; --------------------------------------------------------------------------
; Seq_ApplySongBeatsPerBar
; Called from: T_Seq_ApplySongBeatsPerBar (x6); in-module: 0xF4412D 0xF442B4
; Touches: (0x0DE3)
; Evidence: thunk slot T_Seq_ApplySongBeatsPerBar holds `jp 0x00F44131`, and 0xF44131 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ApplySongBeatsPerBar: Copies the song's beats per bar (workspace 0x6034D7) to TransportA_BeatsPerBar, (0xC3) and
;   the TIME SIG. field (0x0DE3). Run after a song is loaded or reset: BStore_BootPhase3, SeqFile_Load(AllBanks),
;   S0ngSelectName_LoadSongFromBank, and BStore_ResetWorkspaceToDefault right after 0x6034D7 := 4. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_e.json)
Seq_ApplySongBeatsPerBar:		; <- T_Seq_ApplySongBeatsPerBar
	ld	a, (6304983:24)	; F44131  ld A,(0x6034d7)
	ld	(TransportA_BeatsPerBar:24), a	; F44136  ld (0x605000),A
	ld	(0xc3:8), a	; F4413B  ld (0xc3),A
	ld	(3555:16), a	; F4413E  ld (0x0de3),A
	ret	; F44142  ret

; --------------------------------------------------------------------------
; BStore_CopyByteD6ToAllBanks
; Called from: in-module: 0xF4410D
; Touches:   |  0x6034C8 0x6034D6 0x610000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44143 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CopyByteD6ToAllBanks: Copies workspace byte +0xD6 (0x6034D6) to the same offset of all ten bank images (bank
;   n at 0x610000 + n*0xC00), keeping that byte identical in every bank. BStore_BootPhase3 zeroes (0x6034D6) and then
;   calls it; BStore_CopyChainStateToAllBanks ends with the same loop. What the byte holds is not established. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
BStore_CopyByteD6ToAllBanks:
	push	xwa	; F44143  push XWA
	push	xix	; F44144  push XIX
	push	xiy	; F44145  push XIY
	push	xbc	; F44146  push XBC
	push	xde	; F44147  push XDE
	xor	xwa, xwa	; F44148  xor XWA,XWA
BStore_CopyByteD6ToAllBanks_Loop:
	ldw	bc, 1	; F4414A  ld BC,0x0001
	ld	de, wa	; F4414D  ld DE,WA
	mul	de, 3072	; F4414F  mul DE,0x0c00
	ld	xix, 6356992	; F44153  ld XIX,0x00610000
	lda	xix, (xix+de)	; F44158  lda XIX,XIX+DE
	lda	xix, (xix+214)	; F4415D  lda XIX,XIX+0x00d6
	ld	xiy, 6304982	; F44162  ld XIY,0x006034d6
	ldir85	; F44167  ldir
	inc	1, wa	; F44169  inc 1,WA
	cp	wa, 10	; F4416B  cp WA,0x000a
	jr	c, BStore_CopyByteD6ToAllBanks_Loop	; F4416F  jr C,0xf4414a
	pop	xde	; F44171  pop XDE
	pop	xbc	; F44172  pop XBC
	pop	xiy	; F44173  pop XIY
	pop	xix	; F44174  pop XIX
	pop	xwa	; F44175  pop XWA
	ret	; F44176  ret
	push	xwa	; F44177  push XWA
	push	xix	; F44178  push XIX
	push	xiy	; F44179  push XIY
	push	xbc	; F4417A  push XBC
	push	xde	; F4417B  push XDE
	xor	xwa, xwa	; F4417C  xor XWA,XWA
BStore_CopyByteD6ToAllBanks_Loop2:
	ldw	bc, 2	; F4417E  ld BC,0x0002
	ld	de, wa	; F44181  ld DE,WA
	mul	de, 3072	; F44183  mul DE,0x0c00
	ld	xix, 6356992	; F44187  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4418C  lda XIX,XIX+DE
	lda	xix, (xix+200)	; F44191  lda XIX,XIX+0x00c8
	ld	xiy, 6304968	; F44196  ld XIY,0x006034c8
	ldir85	; F4419B  ldir
	inc	1, wa	; F4419D  inc 1,WA
	cp	wa, 10	; F4419F  cp WA,0x000a
	jr	c, BStore_CopyByteD6ToAllBanks_Loop2	; F441A3  jr C,0xf4417e
	pop	xde	; F441A5  pop XDE
	pop	xbc	; F441A6  pop XBC
	pop	xiy	; F441A7  pop XIY
	pop	xix	; F441A8  pop XIX
	pop	xwa	; F441A9  pop XWA
	ret	; F441AA  ret

; --------------------------------------------------------------------------
; BStore_ClearPasswordProtectedBanks
; Called from: in-module: 0xF4411E
; Touches: (0x0E43) (0x360A)  |  0x603400 0x610000
; Calls:   T_BStore_MoveWorkspaceToNextBank T_SongClear_ClearCurrentBank
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF441AB is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ClearPasswordProtectedBanks: BStore_BootPhase3's: saves the workspace to its bank, then for banks 0..9 (BStore_MoveWorkspaceToNextBank)
;   runs SongClear_ClearCurrentBank wherever the password word (0x60341C) is non-zero, and zeroes it; then
;   restores the current bank.
BStore_ClearPasswordProtectedBanks:
	xor	wa, wa	; F441AB  xor WA,WA
	ld	a, (BStore_CurrentBank:16)	; F441AD  ld A,(0x360a)
	ld	(3651:16), a	; F441B1  ld (0x0e43),A
	ldw	bc, 1536	; F441B5  ld BC,0x0600
	ld	xhl, 6304768	; F441B8  ld XHL,0x00603400
	ld	xde, 6356992	; F441BD  ld XDE,0x00610000
	mul	wa, 3072	; F441C2  mul WA,0x0c00
	lda	xde, (xde+wa)	; F441C6  lda XDE,XDE+WA
	ldirw93	; F441CB  ldirw
	xor	a, a	; F441CD  xor A,A
BStore_ClearPasswordProtectedBanks_Join:
	ld	(BStore_CurrentBank:16), a	; F441CF  ld (0x360a),A
	cp	(BStore_CurrentBank:16), 0x0a	; F441D3  cp (0x360a),0x0a
	jr	nc, BStore_ClearPasswordProtectedBanks_Skip2	; F441D8  jr NC,0xf441fa
	push_a	; F441DA  push A
	call	T_BStore_MoveWorkspaceToNextBank	; F441DB  call 0xf42830
	pop_a	; F441DF  pop A
	cpw	(BStore_Password:24), 0x0000	; F441E0  cp (0x60341c),0x0000
	jr	z, BStore_ClearPasswordProtectedBanks_Skip	; F441E7  jr Z,0xf441f6
	push_a	; F441E9  push A
	call	T_SongClear_ClearCurrentBank	; F441EA  call 0xf42708
	pop_a	; F441EE  pop A
	ldw	(BStore_Password:24), 0	; F441EF  ld (0x60341c),0x0000
BStore_ClearPasswordProtectedBanks_Skip:
	inc	1, a	; F441F6  inc 1,A
	jr	BStore_ClearPasswordProtectedBanks_Join	; F441F8  jr T,0xf441cf
BStore_ClearPasswordProtectedBanks_Skip2:
	dec	1, a	; F441FA  dec 1,A
	ldw	bc, 1536	; F441FC  ld BC,0x0600
	ld	xhl, 6304768	; F441FF  ld XHL,0x00603400
	ld	xde, 6356992	; F44204  ld XDE,0x00610000
	mul	wa, 3072	; F44209  mul WA,0x0c00
	lda	xde, (xde+wa)	; F4420D  lda XDE,XDE+WA
	ldirw93	; F44212  ldirw
	xor	wa, wa	; F44214  xor WA,WA
	ld	a, (3651:16)	; F44216  ld A,(0x0e43)
	ld	(BStore_CurrentBank:16), a	; F4421A  ld (0x360a),A
	ldw	bc, 1536	; F4421E  ld BC,0x0600
	ld	xde, 6304768	; F44221  ld XDE,0x00603400
	ld	xhl, 6356992	; F44226  ld XHL,0x00610000
	mul	wa, 3072	; F4422B  mul WA,0x0c00
	lda	xhl, (xhl+wa)	; F4422F  lda XHL,XHL+WA
	ldirw93	; F44234  ldirw
	ret	; F44236  ret

; --------------------------------------------------------------------------
; SeqCycle_ResetSettings
; Called from: in-module: 0xF4412A 0xF442B7
; Touches: (0x360B) (0x361E) (0x3620) (0x3622) (0x3624) (0x3627) (0x36CE)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44237 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_ResetSettings: CYCLE PLAY range (0x361E/0x3620) and CYCLE RECORD range (0x3622/0x3624) := measure 1..1,
;   both CYCLE switches ((0x360B) bits 0/1) off, both screens' field cursors (0x3627, 0x36CE) := 0. Last step of
;   BStore_BootPhase3 and of BStore_ResetWorkspaceToDefault. Basis: callers + body + the CYCLE screens' StageValues
;   routines. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
SeqCycle_ResetSettings:
	ldw	(13854:16), 1	; F44237  ld (0x361e),0x0001
	ldw	(13856:16), 1	; F4423D  ld (0x3620),0x0001
	ldw	(13858:16), 1	; F44243  ld (0x3622),0x0001
	ldw	(13860:16), 1	; F44249  ld (0x3624),0x0001
	and	(0x360b:16), 0xfc	; F4424F  and (0x360b),0xfc
	ld	(13863:16), 0	; F44254  ld (0x3627),0x00
	ld	(14030:16), 0	; F44259  ld (0x36ce),0x00
	ret	; F4425E  ret

; --------------------------------------------------------------------------
; T_F44004_Nop
; Called from: T_F44004 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F44004 holds `jp 0x00F4425F`, and 0xF4425F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F44004_Nop after what reaches it
;          (was sub_F4425F; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F44004_Nop:		; <- T_F44004
	ret	; F4425F  ret

; --------------------------------------------------------------------------
; BStore_ResetWorkspaceToDefault
; Called from: in-module: 0xF44095 0xF455A0
; Touches: (0x20A9) (0x34D9) (0x3552) (0x360A) (0x360C)
; Calls:   BStore_LoadGmTrackDefaults BStore_LoadNonGmTrackDefaults BStore_ResetWorkspaceFields sub_F443CC T_BStore_ClearSongStore T_F40CB4
;          T_NoteRouting_RebuildForSong BStore_SongName_LoadDefault Seq_ApplySongBeatsPerBar SeqCycle_ResetSettings T_EditScreen_BootPhase2And4
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44260 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ResetWorkspaceToDefault: Resets the song workspace: BStore_Password 0, track-to-part defaults by GM mode,
;   (0x603454) -1, playing-track mask (0x60341E) and (0x360C) 0, BStore_SongName_LoadDefault, (0x6034D5) and
;   BStore_CurrentBank 0, measure 1, beats per bar 4 applied, EditScreen boot. First step of BStore_BootPhase2And4 and
;   Sequencer_ResetToDefault (INITIAL item 6). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_e.json)
BStore_ResetWorkspaceToDefault:
	ldw	(BStore_Password:24), 0	; F44260  ld (0x60341c),0x0000
	calr	BStore_LoadGmTrackDefaults	; F44267  calr 0xf45d19
	calr	BStore_LoadNonGmTrackDefaults	; F4426A  calr 0xf45d80
	ld	xwa, 4294967295	; F4426D  ld XWA,0xffffffff
	ld	(6304852:24), xwa	; F44272  ld (0x603454),XWA
	calr	BStore_ResetWorkspaceFields	; F44277  calr 0xf44367
	calr	sub_F443CC	; F4427A  calr 0xf443cc
	call	T_BStore_ClearSongStore	; F4427D  call 0xf40c70
	xor	xwa, xwa	; F44281  xor XWA,XWA
	ld	(6304798:24), xwa	; F44283  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F44288  ld (0x360c),XWA
	call	T_F40CB4	; F4428C  call 0xf40cb4
	call	T_NoteRouting_RebuildForSong	; F44290  call 0xf411b8
	ld	(13529:16), 0	; F44294  ld (0x34d9),0x00
	calr	BStore_SongName_LoadDefault	; F44299  calr 0xf442c4
	ld	(6304981:24), 0	; F4429C  ld (0x6034d5),0x00
	ld	(BStore_CurrentBank:16), 0	; F442A2  ld (0x360a),0x00
	ldw	(13650:16), 1	; F442A7  ld (0x3552),0x0001
	ld	a, 4:opc	; F442AD  ld A,0x04
	ld	(6304983:24), a	; F442AF  ld (0x6034d7),A
	calr	Seq_ApplySongBeatsPerBar	; F442B4  calr 0xf44131
	calr	SeqCycle_ResetSettings	; F442B7  calr 0xf44237
	call	T_EditScreen_BootPhase2And4	; F442BA  call 0xf40300
	and	(0x20a9:16), 0xfe	; F442BE  and (0x20a9),0xfe
	ret	; F442C3  ret

; --------------------------------------------------------------------------
; BStore_SongName_LoadDefault
; Called from: in-module: 0xF44299
; Touches:   |  0x6034CA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF442C4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SongName_LoadDefault: ldirw of 3 words from WorkspaceDefaults + 0x71 to BStore_SongName, the 6-character song name, preserving
;   XIX/XIY/BC; called from BStore_ResetWorkspaceToDefault.  Basis: body (named RAM).
BStore_SongName_LoadDefault:
	push	xix	; F442C4  push XIX
	push	xiy	; F442C5  push XIY
	pushw	bc	; F442C6  push BC
	ldw	bc, 3	; F442C7  ld BC,0x0003
	ld	xix, BStore_SongName	; F442CA  ld XIX,0x006034ca
	ld	xiy, WorkspaceDefaults + 0x71	; F442CF  ld XIY,0x00f460e5
	ldirw	; F442D4  ldirw
	popw	bc	; F442D6  pop BC
	pop	xiy	; F442D7  pop XIY
	pop	xix	; F442D8  pop XIX
	ret	; F442D9  ret

; --------------------------------------------------------------------------
; BStore_TrackOutChannel_LoadDefaults
; Called from: in-module: 0xF443D7 0xF45D90
; Touches:   |  0x603400 0x603414 0x603433 0x603446
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF442DA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_TrackOutChannel_LoadDefaults: The 17 per-track bytes 0x603433..0x603443 -- each track's MIDI OUT channel per
;   NoteRouting_BuildTrackRouting (0x20 = none) -- := WorkspaceDefaults + 0x3E (all 0x20), or + 0x4F (0..15, then
;   0x20) when (0x6034C7) bit 1. BStore_LoadNonGmTrackDefaults calls it after BStore_TrackToPart_LoadDefaults, and the
;   workspace-reset step sub_F443CC calls it; the GM twin sub_F45E14 uses + 0x3E / + 0x60. Basis: callers + body +
;   reader + twin. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
BStore_TrackOutChannel_LoadDefaults:
	push	xix	; F442DA  push XIX
	ld	xhl, 6304819	; F442DB  ld XHL,0x00603433
	xor	iy, iy	; F442E0  xor IY,IY
BStore_TrackOutChannel_LoadDefaults_Loop:
	ld	a, (6304967:24)	; F442E2  ld A,(0x6034c7)
	and	a, 2	; F442E7  and A,0x02
	jr	nz, BStore_TrackOutChannel_LoadDefaults_Skip	; F442EA  jr NZ,0xf442f8
	ld	xix, WorkspaceDefaults + 0x3E	; F442EC  ld XIX,0x00f460b2
	ld	a, (xix+iy)	; F442F1  ld A,(XIX+IY)
	jr	BStore_TrackOutChannel_LoadDefaults_Join	; F442F6  jr T,0xf44302
BStore_TrackOutChannel_LoadDefaults_Skip:
	ld	xix, WorkspaceDefaults + 0x4F	; F442F8  ld XIX,0x00f460c3
	ld	a, (xix+iy)	; F442FD  ld A,(XIX+IY)
BStore_TrackOutChannel_LoadDefaults_Join:
	ld	(xhl+iy), a	; F44302  ld (XHL+IY),A
	inc	1, iy	; F44307  inc 1,IY
	cp	iy, 17	; F44309  cp IY,0x0011
	jr	c, BStore_TrackOutChannel_LoadDefaults_Loop	; F4430D  jr C,0xf442e2
	pop	xix	; F4430F  pop XIX
	ret	; F44310  ret
	push	xix	; F44311  push XIX
	ld	xhl, 6304768	; F44312  ld XHL,0x00603400
	xor	iy, iy	; F44317  xor IY,IY
BStore_TrackOutChannel_LoadDefaults_Loop2:
	ld	xix, WorkspaceDefaults	; F44319  ld XIX,0x00f46074
	ld	a, (xix+iy)	; F4431E  ld A,(XIX+IY)
	ld	(xhl+iy), a	; F44323  ld (XHL+IY),A
	inc	1, iy	; F44328  inc 1,IY
	cp	iy, 7:i3	; F4432A  cp IY,7
	jr	ule, BStore_TrackOutChannel_LoadDefaults_Loop2	; F4432C  jr ULE,0xf44319
	ld	a, 0:opc	; F4432E  ld A,0x00
	ld	(xhl+iy), a	; F44330  ld (XHL+IY),A
	ld	xhl, 6304788	; F44335  ld XHL,0x00603414
	xor	iy, iy	; F4433A  xor IY,IY
BStore_TrackOutChannel_LoadDefaults_Loop3:
	ld	xix, WorkspaceDefaults + 0x8	; F4433C  ld XIX,0x00f4607c
	ld	wa, (xix+iy)	; F44341  ld WA,(XIX+IY)
	ld	(xhl+iy), wa	; F44346  ld (XHL+IY),WA
	add	iy, 2	; F4434B  add IY,0x0002
	cp	iy, 8	; F4434F  cp IY,0x0008
	jr	c, BStore_TrackOutChannel_LoadDefaults_Loop3	; F44353  jr C,0xf4433c
	ld	xix, 6304838	; F44355  ld XIX,0x00603446
	xor	wa, wa	; F4435A  xor WA,WA
	ldw	bc, 6	; F4435C  ld BC,0x0006
	ld	(xix+), wa	; F4435F  ld (XIX+),WA
	djnz16	bc, -6	; F44362  djnz BC,0xf4435f
	pop	xix	; F44365  pop XIX
	ret	; F44366  ret

; --------------------------------------------------------------------------
; BStore_ResetWorkspaceFields
; Called from: T_F40A1C (x15), T_F40A8C (x1); in-module: 0xF44277
; Touches: (0x7F4D)  |  0x603400 0x603414 0x603446
; Evidence: thunk slot T_F40A1C holds `jp 0x00F44367`, and 0xF44367 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ResetWorkspaceFields: Resets part of the song workspace from WorkspaceDefaults: bytes +0x00..+0x07
;   (0x5A5A5A5A 00 04 00 00) and +0x08 = 0, words +0x14..+0x1A, words +0x46..+0x50 cleared, and +0xC6 = 0xFF when
;   (0x7F4D) bit 2 else 0. Basis: callers + body -- run after a bank clear (SongClear_ClearBank), at STEP RECORD leave
;   and from BStore_WriteCursorByte; BStore_ResetWorkspaceToDefault's full reset calls it too. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
BStore_ResetWorkspaceFields:		; <- T_F40A1C, T_F40A8C
	push	xix	; F44367  push XIX
	ld	xhl, 6304768	; F44368  ld XHL,0x00603400
	xor	iy, iy	; F4436D  xor IY,IY
BStore_ResetWorkspaceFields_Loop:
	ld	xix, WorkspaceDefaults	; F4436F  ld XIX,0x00f46074
	ld	a, (xix+iy)	; F44374  ld A,(XIX+IY)
	ld	(xhl+iy), a	; F44379  ld (XHL+IY),A
	inc	1, iy	; F4437E  inc 1,IY
	cp	iy, 7:i3	; F44380  cp IY,7
	jr	ule, BStore_ResetWorkspaceFields_Loop	; F44382  jr ULE,0xf4436f
	ld	a, 0:opc	; F44384  ld A,0x00
	ld	(xhl+iy), a	; F44386  ld (XHL+IY),A
	ld	xhl, 6304788	; F4438B  ld XHL,0x00603414
	xor	iy, iy	; F44390  xor IY,IY
BStore_ResetWorkspaceFields_Loop2:
	ld	xix, WorkspaceDefaults + 0x8	; F44392  ld XIX,0x00f4607c
	ld	wa, (xix+iy)	; F44397  ld WA,(XIX+IY)
	ld	(xhl+iy), wa	; F4439C  ld (XHL+IY),WA
	add	iy, 2	; F443A1  add IY,0x0002
	cp	iy, 8	; F443A5  cp IY,0x0008
	jr	c, BStore_ResetWorkspaceFields_Loop2	; F443A9  jr C,0xf44392
	ld	xix, 6304838	; F443AB  ld XIX,0x00603446
	xor	wa, wa	; F443B0  xor WA,WA
	ldw	bc, 6	; F443B2  ld BC,0x0006
	ld	(xix+), wa	; F443B5  ld (XIX+),WA
	djnz16	bc, -6	; F443B8  djnz BC,0xf443b5
	ld	a, 0:opc	; F443BB  ld A,0x00
	bit	2, (0x7f4d:16)	; F443BD  bit 2,(0x7f4d)
	jr	z, BStore_ResetWorkspaceFields_Skip	; F443C1  jr Z,0xf443c5
	ld	a, 255:opc	; F443C3  ld A,0xff
BStore_ResetWorkspaceFields_Skip:
	ld	(6304966:24), a	; F443C5  ld (0x6034c6),A
	pop	xix	; F443CA  pop XIX
	ret	; F443CB  ret

; --------------------------------------------------------------------------
; sub_F443CC
; Called from: in-module: 0xF4427A
; Touches: (0x7F4D)
; Calls:   sub_F45E14 BStore_TrackOutChannel_LoadDefaults T_F42824
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF443CC is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F443CC:
	bit	2, (0x7f4d:16)	; F443CC  bit 2,(0x7f4d)
	jr	z, sub_F443CC_Skip	; F443D0  jr Z,0xf443d7
	calr	sub_F45E14	; F443D2  calr 0xf45e14
	jr	sub_F443CC_Join	; F443D5  jr T,0xf443da
sub_F443CC_Skip:
	calr	BStore_TrackOutChannel_LoadDefaults	; F443D7  calr 0xf442da
sub_F443CC_Join:
	ld	xwa, 4294967295	; F443DA  ld XWA,0xffffffff
	ld	(6304852:24), xwa	; F443DF  ld (0x603454),XWA
	ld	(6304856:24), 0	; F443E4  ld (0x603458),0x00
	ld	(6304857:24), 1	; F443EA  ld (0x603459),0x01
	ld	(6304858:24), 2	; F443F0  ld (0x60345a),0x02
	ld	(6304859:24), 3	; F443F6  ld (0x60345b),0x03
	ld	(6304860:24), 1	; F443FC  ld (0x60345c),0x01
	ldw	(6304861:24), 1	; F44402  ld (0x60345d),0x0001
	ldw	(6304863:24), 1	; F44409  ld (0x60345f),0x0001
	ld	(6304865:24), 1	; F44410  ld (0x603461),0x01
	ldw	(6304866:24), 1	; F44416  ld (0x603462),0x0001
	ldw	(6304868:24), 1	; F4441D  ld (0x603464),0x0001
	ld	(6304870:24), 0	; F44424  ld (0x603466),0x00
	ld	(6304871:24), 1	; F4442A  ld (0x603467),0x01
	ldw	(6304872:24), 1	; F44430  ld (0x603468),0x0001
	ldw	(6304874:24), 1	; F44437  ld (0x60346a),0x0001
	ld	(6304876:24), 1	; F4443E  ld (0x60346c),0x01
	ldw	(6304877:24), 1	; F44444  ld (0x60346d),0x0001
	ld	(6304879:24), 1	; F4444B  ld (0x60346f),0x01
	ldw	(6304880:24), 1	; F44451  ld (0x603470),0x0001
	ldw	(6304882:24), 1	; F44458  ld (0x603472),0x0001
	ld	(6304884:24), 1	; F4445F  ld (0x603474),0x01
	ldw	(6304885:24), 1	; F44465  ld (0x603475),0x0001
	ld	(6304887:24), 0	; F4446C  ld (0x603477),0x00
	ldw	(6304888:24), 1	; F44472  ld (0x603478),0x0001
	ldw	(6304890:24), 1	; F44479  ld (0x60347a),0x0001
	ld	(6304892:24), 2	; F44480  ld (0x60347c),0x02
	ld	(6304893:24), 0	; F44486  ld (0x60347d),0x00
	ld	(6304945:24), 1	; F4448C  ld (0x6034b1),0x01
	ldw	(6304946:24), 1	; F44492  ld (0x6034b2),0x0001
	ldw	(6304948:24), 1	; F44499  ld (0x6034b4),0x0001
	ld	(6304950:24), 0	; F444A0  ld (0x6034b6),0x00
	ld	(6304951:24), 0	; F444A6  ld (0x6034b7),0x00
	ld	(6304956:24), 0	; F444AC  ld (0x6034bc),0x00
	ld	(6304957:24), 0	; F444B2  ld (0x6034bd),0x00
	ld	(6304958:24), 0	; F444B8  ld (0x6034be),0x00
	ld	(6304959:24), 0	; F444BE  ld (0x6034bf),0x00
	ldw	(6304961:24), 1	; F444C4  ld (0x6034c1),0x0001
	ldw	(6304963:24), 2	; F444CB  ld (0x6034c3),0x0002
	ld	(6304965:24), 0	; F444D2  ld (0x6034c5),0x00
	ldw	(6304968:24), 0	; F444D8  ld (0x6034c8),0x0000
	call	T_F42824	; F444DF  call 0xf42824
	ret	; F444E3  ret

; --------------------------------------------------------------------------
; BStore_TrackToPart_LoadDefaults
; Called from: in-module: 0xF45D8D
; Touches:   |  0x603422
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF444E4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_TrackToPart_LoadDefaults: copies 17 bytes from WorkspaceDefaults + 0x1C to BStore_TrackToPart (index 0..16; the RAM note documents 16);
;   called from BStore_LoadNonGmTrackDefaults.  Basis: body (named RAM).
BStore_TrackToPart_LoadDefaults:
	push	xix	; F444E4  push XIX
	ld	xhl, BStore_TrackToPart	; F444E5  ld XHL,0x00603422
	xor	iy, iy	; F444EA  xor IY,IY
	ld	xix, WorkspaceDefaults + 0x1C	; F444EC  ld XIX,0x00f46090
BStore_TrackToPart_LoadDefaults_Loop:
	ld	a, (xix+iy)	; F444F1  ld A,(XIX+IY)
	ld	(xhl+iy), a	; F444F6  ld (XHL+IY),A
	inc	1, iy	; F444FB  inc 1,IY
	cp	iy, 17	; F444FD  cp IY,0x0011
	jr	c, BStore_TrackToPart_LoadDefaults_Loop	; F44501  jr C,0xf444f1
	pop	xix	; F44503  pop XIX
	ret	; F44504  ret

; --------------------------------------------------------------------------
; sub_F44505
; Called from: in-module: 0xF44100
; Touches: (0x34BB)
; Calls:   Seq_RebuildPlayingSet SeqTrackCursors_RewindPlaying
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44505 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44505:
	and	(0x34bb:16), 0xf7	; F44505  and (0x34bb),0xf7
	calr	Seq_RebuildPlayingSet	; F4450A  calr 0xf459d9
	and	(0x34bb:16), 0xfe	; F4450D  and (0x34bb),0xfe
	calr	SeqTrackCursors_RewindPlaying	; F44512  calr 0xf44516
	ret	; F44515  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_RewindPlaying
; Called from: in-module: 0xF44512 0xF44BE1
; Touches: (0x349A) (0x349C) (0x349F)  |  0x003460 0x003482
; Calls:   T_CycleRecord_CheckIsRecordTrack T_BStore_DirEntryHeadAtIY
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44516 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_RewindPlaying: For each track t 0..16 in the playing set (0x349A)/(0x349C) that T_CycleRecord_CheckIsRecordTrack
;   (CycleRecord_CheckIsRecordTrack) does not exclude -- it returns 0 for the cycle-record track (0x36D6) while cycle recording -- sets
;   the saved track cursor 0x3460[t]/0x3482[t] := (head block of t's chain from T_BStore_DirEntryHeadAtIY, the directory word at
;   0x603500 + 3t; offset 5). One of Seq_ResetPositionToSongStart's per-track re-arm calls; SeqCycle_LocateToStart
;   inlines the same loop for a measure-1 cycle start. Basis: caller + body + twin loop. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
SeqTrackCursors_RewindPlaying:
	ld	(13471:16), 0	; F44516  ld (0x349f),0x00
	xor	iy, iy	; F4451B  xor IY,IY
	xor	ix, ix	; F4451D  xor IX,IX
SeqTrackCursors_RewindPlaying_Loop:
	xor	bc, bc	; F4451F  xor BC,BC
	ld	c, (13471:16)	; F44521  ld C,(0x349f)
	call	T_CycleRecord_CheckIsRecordTrack	; F44525  call 0xf40be4
	cp	a, 0:i3	; F44529  cp A,0
	jr	z, SeqTrackCursors_RewindPlaying_Skip2	; F4452B  jr Z,0xf4456e
	cp	c, 16	; F4452D  cp C,0x10
	jr	nc, SeqTrackCursors_RewindPlaying_Skip	; F44530  jr NC,0xf4453f
	ld	iz, (13466:16)	; F44532  ld IZ,(0x349a)
	ld	a, c	; F44536  ld A,C
	scf	; F44538  scf
	xorcf_a_16	iz	; F44539  xorcf A,IZ
	jr	c, SeqTrackCursors_RewindPlaying_Skip2	; F4453B  jr C,0xf4456e
	jr	SeqTrackCursors_RewindPlaying_Join	; F4453D  jr T,0xf4454d
SeqTrackCursors_RewindPlaying_Skip:
	ld	iz, (13468:16)	; F4453F  ld IZ,(0x349c)
	ld	a, c	; F44543  ld A,C
	sub	a, 16	; F44545  sub A,0x10
	scf	; F44548  scf
	xorcf_a_16	iz	; F44549  xorcf A,IZ
	jr	c, SeqTrackCursors_RewindPlaying_Skip2	; F4454B  jr C,0xf4456e
SeqTrackCursors_RewindPlaying_Join:
	push	xix	; F4454D  push XIX
	push	xiy	; F4454E  push XIY
	call	T_BStore_DirEntryHeadAtIY	; F4454F  call 0xf40b4c
	pop	xiy	; F44553  pop XIY
	pop	xix	; F44554  pop XIX
	ld	xhl, 13408	; F44555  ld XHL,0x00003460
	ld	(xhl+ix), wa	; F4455A  ld (XHL+IX),WA
	ld	xhl, 13442	; F4455F  ld XHL,0x00003482
	ex16	iy, bc	; F44564  ex IY,BC
	ld	(xhl+iy), 0x05	; F44566  ld (XHL+IY),0x05
	ex16	iy, bc	; F4456C  ex IY,BC
SeqTrackCursors_RewindPlaying_Skip2:
	add	iy, 3	; F4456E  add IY,0x0003
	add	ix, 2	; F44572  add IX,0x0002
	inc	1, (13471:16)	; F44576  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F4457A  cp (0x349f),0x11
	jr	c, SeqTrackCursors_RewindPlaying_Loop	; F4457F  jr C,0xf4451f
	ret	; F44581  ret

; --------------------------------------------------------------------------
; Seq_MainLoopService
; Called from: T_Seq_MainLoopService (x2)
; Touches: (0x207A) (0x207C) (0x2095) (0x3000) (0x349F) (0x34B2) (0x34D4)
;          (0x34D9) (0x3738) (0x373A) +1 more
; Calls:   CountIn_RebuildRoutingOnLastBeat Seq_RewindOnRequest Seq_RestoreSongParamsOnRequest Seq_CountDownMidiStartIgnore sub_F4495A T_Seq_DelayedLocateToMeasure_Call
;          Seq_ShowMemoryFullOnRequest Seq_LocateToSongPosition SeqRecord_HandleTransportBStartStop T_SeqRecord_DrainEventRing Seq_StopWhenTracksEnded Seq_StopPlaybackOnRequest
;          +1 more
; Evidence: thunk slot T_Seq_MainLoopService holds `jp 0x00F44582`, and 0xF44582 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_MainLoopService: The sequencer's once-per-pass service: on Variant_Flag 2 zeroes the playing-track mask
;   (0x60341E) and record mask (0x3000); runs the request consumers CountIn_RebuildRoutingOnLastBeat, Seq_RewindOnRequest ((0x34D3) bit 0,
;   Seq_RequestRewind's flag), Seq_LocateToSongPosition, Seq_StopPlaybackOnRequest ((0x34D2) bit 1) and others, then
;   SeqTrack_QueueSwitchOffEvents for each track 0..16 set in (0x3738)/(0x373A); ends (0x34B2) := (0x60341E). Called at the end of every
;   MainTask_Loop pass and by Transport_StopWhileRecording. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
Seq_MainLoopService:		; <- T_Seq_MainLoopService
	cp	(Variant_Flag:8), 0x02	; F44582  cp (0xc4),0x02
	jr	nz, Seq_MainLoopService_Skip3	; F44586  jr NZ,0xf44593
	xor	xwa, xwa	; F44588  xor XWA,XWA
	ld	(6304798:24), xwa	; F4458A  ld (0x60341e),XWA
	ld	(12288:16), xwa	; F4458F  ld (0x3000),XWA
Seq_MainLoopService_Skip3:
	bit	2, (TransportB_State:8)	; F44593  bit 2,(0x96)
	jr	nz, Seq_MainLoopService_Skip5	; F44596  jr NZ,0xf445bc
	cp	(UI_ScreenId:16), 0x06	; F44598  cp (0x207c),0x06
	jr	z, Seq_MainLoopService_Skip4	; F4459D  jr Z,0xf445a6
	cp	(UI_ScreenLatch:16), 0x08	; F4459F  cp (0x207a),0x08
	jr	nz, Seq_MainLoopService_Skip5	; F445A4  jr NZ,0xf445bc
Seq_MainLoopService_Skip4:
	bit	2, (MidiCfg_ModeBits:16)	; F445A6  bit 2,(0x7f32)
	jr	z, Seq_MainLoopService_Skip5	; F445AA  jr Z,0xf445bc
	bit	0, (0x34d9:16)	; F445AC  bit 0,(0x34d9)
	jr	z, Seq_MainLoopService_Skip5	; F445B0  jr Z,0xf445bc
	and	(0x34d9:16), 0xfe	; F445B2  and (0x34d9),0xfe
	or	(UI_ScreenFlags:16), 0x10	; F445B7  or (0x2095),0x10
Seq_MainLoopService_Skip5:
	calr	CountIn_RebuildRoutingOnLastBeat	; F445BC  calr 0xf44623
	calr	Seq_RewindOnRequest	; F445BF  calr 0xf44809
	calr	Seq_RestoreSongParamsOnRequest	; F445C2  calr 0xf4491c
	calr	Seq_CountDownMidiStartIgnore	; F445C5  calr 0xf4493e
	calr	sub_F4495A	; F445C8  calr 0xf4495a
	call	T_Seq_DelayedLocateToMeasure_Call	; F445CB  call 0xf40d14
	calr	Seq_ShowMemoryFullOnRequest	; F445CF  calr 0xf45fca
	and	(0x34d4:16), 0x7f	; F445D2  and (0x34d4),0x7f
	calr	Seq_LocateToSongPosition	; F445D7  calr 0xf4466d
	calr	SeqRecord_HandleTransportBStartStop	; F445DA  calr 0xf44964
	call	T_SeqRecord_DrainEventRing	; F445DD  call 0xf40bd0
	calr	Seq_StopWhenTracksEnded	; F445E1  calr 0xf44d94
	calr	Seq_StopPlaybackOnRequest	; F445E4  calr 0xf44e6b
	ld	c, 0:opc	; F445E7  ld C,0x00
Seq_MainLoopService_Loop2:
	ld	(13471:16), c	; F445E9  ld (0x349f),C
	cp	c, 16	; F445ED  cp C,0x10
	jr	nc, Seq_MainLoopService_Skip6	; F445F0  jr NC,0xf445ff
	ld	iz, (14136:16)	; F445F2  ld IZ,(0x3738)
	ld	a, c	; F445F6  ld A,C
	scf	; F445F8  scf
	xorcf_a_16	iz	; F445F9  xorcf A,IZ
	jr	c, Seq_MainLoopService_Skip7	; F445FB  jr C,0xf44612
	jr	Seq_MainLoopService_Join2	; F445FD  jr T,0xf4460d
Seq_MainLoopService_Skip6:
	ld	iz, (14138:16)	; F445FF  ld IZ,(0x373a)
	ld	a, c	; F44603  ld A,C
	sub	a, 16	; F44605  sub A,0x10
	scf	; F44608  scf
	xorcf_a_16	iz	; F44609  xorcf A,IZ
	jr	c, Seq_MainLoopService_Skip7	; F4460B  jr C,0xf44612
Seq_MainLoopService_Join2:
	pushw	bc	; F4460D  push BC
	calr	SeqTrack_QueueSwitchOffEvents	; F4460E  calr 0xf44e8e
	popw	bc	; F44611  pop BC
Seq_MainLoopService_Skip7:
	inc	1, c	; F44612  inc 1,C
	cp	c, 17	; F44614  cp C,0x11
	jr	ule, Seq_MainLoopService_Loop2	; F44617  jr ULE,0xf445e9
	ld	xwa, (6304798:24)	; F44619  ld XWA,(0x60341e)
	ld	(13490:16), xwa	; F4461E  ld (0x34b2),XWA
	ret	; F44622  ret

; --------------------------------------------------------------------------
; CountIn_RebuildRoutingOnLastBeat
; Called from: in-module: 0xF445BC
; Touches: (0x207A) (0x3456) (0x34D4) (0x34D9) (0x3552)
; Calls:   T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44623 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CountIn_RebuildRoutingOnLastBeat: In the last count-in bar ((0x3552) = 0x8001, (0x34D9) bit 1), on its final beat
;   past tick 0x47, with (0x34D4) bit 3 set and UI_ScreenLatch not 9/10: Seq_BeatTick := 0, (0x3456) :=
;   TransportB_Beat, (0x34D4) bit 3 := 0 -- the bit NoteRouting_BuildTrackRouting reads to clear NoteRouting_Mode bit
;   7 -- and T_NoteRouting_RebuildForSong. First consumer in Seq_MainLoopService. Basis: caller + body + count-in
;   encoding. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
CountIn_RebuildRoutingOnLastBeat:
	ld	a, (UI_ScreenLatch:16)	; F44623  ld A,(0x207a)
	cp	a, 9	; F44627  cp A,0x09
	jr	z, CountIn_RebuildRoutingOnLastBeat_Return	; F4462A  jr Z,0xf4466c
	cp	a, 10	; F4462C  cp A,0x0a
	jr	z, CountIn_RebuildRoutingOnLastBeat_Return	; F4462F  jr Z,0xf4466c
	bit	3, (0x34d4:16)	; F44631  bit 3,(0x34d4)
	jr	z, CountIn_RebuildRoutingOnLastBeat_Return	; F44635  jr Z,0xf4466c
	bit	1, (0x34d9:16)	; F44637  bit 1,(0x34d9)
	jr	z, CountIn_RebuildRoutingOnLastBeat_Return	; F4463B  jr Z,0xf4466c
	cpw	(0x3552:16), 0x8001	; F4463D  cp (0x3552),0x8001
	jr	nz, CountIn_RebuildRoutingOnLastBeat_Return	; F44643  jr NZ,0xf4466c
	ld	a, (TransportA_BeatsPerBar:24)	; F44645  ld A,(0x605000)
	dec	1, a	; F4464A  dec 1,A
	cp	a, (TransportA_Beat:8)	; F4464C  cp A,(0x8c)
	jr	nz, CountIn_RebuildRoutingOnLastBeat_Return	; F4464F  jr NZ,0xf4466c
	cp	(TransportA_Tick:8), 0x47	; F44651  cp (0x8b),0x47
	jr	ule, CountIn_RebuildRoutingOnLastBeat_Return	; F44655  jr ULE,0xf4466c
	xor	wa, wa	; F44657  xor WA,WA
	ld	(Seq_BeatTick:8), a	; F44659  ld (0x93),A
	ld	wa, (TransportB_Beat:8)	; F4465C  ld WA,(0x91)
	ld	(13398:16), wa	; F4465F  ld (0x3456),WA
	and	(0x34d4:16), 0xf7	; F44663  and (0x34d4),0xf7
	call	T_NoteRouting_RebuildForSong	; F44668  call 0xf411b8
CountIn_RebuildRoutingOnLastBeat_Return:
	ret	; F4466C  ret

; --------------------------------------------------------------------------
; Seq_LocateToSongPosition
; Called from: in-module: 0xF445D7
; Touches: (0x0C55) (0x0D4A) (0x207C) (0x3456) (0x3458) (0x345E) (0x349A)
;          (0x349C) (0x349F) (0x34BB) +3 more  |  0x000000
; Calls:   Seq_RewindToStart_Veneer SeqMasterTrack_UpdateActive T_BStore_SeekChainToBeat SeqScreen_RepaintIfPlayOrRecord Seq_SeekTrackToBeatTick T_SeqTrackCursors_SaveTrack
;          TimedEventRing_Discard_Veneer Nop_CallsEmptyDirectorySlot_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4466D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_LocateToSongPosition: from the sequencer tick (Seq_MainLoopService): when MidiIn_SongPositionHi bit 7 is set -- MidiIn_SongPosition stored a
;   received 0xF2 -- while (0x60341E) has tracks and transport B is stopped: TransportB_Beat = the 14-bit position
;   >> 2 (sixteenths to beats) and Seq_BeatTick = WorkspaceDefaults+0x77[position & 3] -- the bytes 0 / 24 / 48 / 72,
;   a sixteenth at 96 ticks a beat.  Position 0 goes to Seq_RewindToStart_Veneer; any other locates each of the 17 tracks
;   (T_BStore_SeekChainToBeat per track, Seq_SeekTrackToBeatTick) and collects the located ones in (0x349A) / (0x349C).  The pending bit is cleared
;   at the end.  Basis: body + the writer's header (MidiIn_SongPosition).
Seq_LocateToSongPosition:
	bit	7, (MidiIn_SongPositionHi:8)	; F4466D  bit 7,(0xa5)
	jrl	z, Seq_LocateToSongPosition_Join2	; F44670  jrl Z,0xf4477a
	ld	xwa, (6304798:24)	; F44673  ld XWA,(0x60341e)
	cp	xwa, 0	; F44678  cp XWA,0x00000000
	jrl	z, Seq_LocateToSongPosition_Join2	; F4467E  jrl Z,0xf4477a
	bit	2, (TransportB_State:8)	; F44681  bit 2,(0x96)
	jrl	nz, Seq_LocateToSongPosition_Join2	; F44684  jrl NZ,0xf4477a
	ld	w, (MidiIn_SongPositionHi:8)	; F44687  ld W,(0xa5)
	ld	a, (MidiIn_SongPositionLo:8)	; F4468A  ld A,(0xa4)
	and	a, 127	; F4468D  and A,0x7f
	rrc	w	; F44690  rrc 0x01,W
	jr	nc, Seq_LocateToSongPosition_Skip	; F44693  jr NC,0xf44698
	or	a, 128	; F44695  or A,0x80
Seq_LocateToSongPosition_Skip:
	and	w, 63	; F44698  and W,0x3f
	ld	c, a	; F4469B  ld C,A
	and	c, 3	; F4469D  and C,0x03
	srl	wa, 2	; F446A0  srl 0x02,WA
	ld	(TransportB_Beat:8), wa	; F446A3  ld (0x91),WA
	ld	(3157:16), wa	; F446A6  ld (0x0c55),WA
	xor	b, b	; F446AA  xor B,B
	ld	iy, bc	; F446AC  ld IY,BC
	ld	xix, WorkspaceDefaults + 0x77	; F446AE  ld XIX,0x00f460eb
	ld	a, (xix+iy)	; F446B3  ld A,(XIX+IY)
	ld	(Seq_BeatTick:8), a	; F446B8  ld (0x93),A
	cpw	(TransportB_Beat:8), 0x0000	; F446BB  cp (0x91),0x0000
	jr	nz, Seq_LocateToSongPosition_Skip2	; F446C0  jr NZ,0xf446cf
	cp	(Seq_BeatTick:8), 0x00	; F446C2  cp (0x93),0x00
	jr	nz, Seq_LocateToSongPosition_Skip2	; F446C6  jr NZ,0xf446cf
	call	Seq_RewindToStart_Veneer	; F446C8  call 0xf44033
	jrl	Seq_LocateToSongPosition_Join2	; F446CC  jrl T,0xf4477a
Seq_LocateToSongPosition_Skip2:
	xor	xde, xde	; F446CF  xor XDE,XDE
	ld	(13466:16), xde	; F446D1  ld (0x349a),XDE
	calr	SeqMasterTrack_UpdateActive	; F446D5  calr 0xf455e6
	ld	(13471:16), 0	; F446D8  ld (0x349f),0x00
Seq_LocateToSongPosition_Loop:
	ld	a, (13471:16)	; F446DD  ld A,(0x349f)
	inc	1, a	; F446E1  inc 1,A
	pushw	wa	; F446E3  push WA
	call	T_BStore_SeekChainToBeat	; F446E4  call 0xf40c90
	cp	(BStore_ErrorCode:16), 0x00	; F446E8  cp (0x0d4a),0x00
	jr	nz, Seq_LocateToSongPosition_Skip5	; F446ED  jr NZ,0xf4474d
	ld	(13400:16), a	; F446EF  ld (0x3458),A
	ld	(BStore_CursorOffset:16), iy	; F446F3  ld (0x345e),IY
	ld	(13650:16), de	; F446F7  ld (0x3552),DE
	xor	b, b	; F446FB  xor B,B
	ld	wa, (TransportB_Beat:8)	; F446FD  ld WA,(0x91)
	sub	wa, bc	; F44700  sub WA,BC
	ld	(13398:16), wa	; F44702  ld (0x3456),WA
	cp	(UI_ScreenId:16), 0x12	; F44706  cp (0x207c),0x12
	jr	nz, Seq_LocateToSongPosition_Skip3	; F4470B  jr NZ,0xf44710
	calr	SeqScreen_RepaintIfPlayOrRecord	; F4470D  calr 0xf45fe5
Seq_LocateToSongPosition_Skip3:
	ld	a, (Seq_BeatTick:8)	; F44710  ld A,(0x93)
	ld	(13643:16), a	; F44713  ld (0x354b),A
	calr	Seq_SeekTrackToBeatTick	; F44717  calr 0xf4477f
	cp	(BStore_ErrorCode:16), 0x00	; F4471A  cp (0x0d4a),0x00
	jr	nz, Seq_LocateToSongPosition_Skip5	; F4471F  jr NZ,0xf4474d
	ld	c, (13471:16)	; F44721  ld C,(0x349f)
	cp	c, 16	; F44725  cp C,0x10
	jr	nc, Seq_LocateToSongPosition_Skip4	; F44728  jr NC,0xf44739
	ld	iz, (13466:16)	; F4472A  ld IZ,(0x349a)
	ld	a, c	; F4472E  ld A,C
	scf	; F44730  scf
	stcf_a_16	iz	; F44731  stcf A,IZ
	ld	(13466:16), iz	; F44733  ld (0x349a),IZ
	jr	Seq_LocateToSongPosition_Join	; F44737  jr T,0xf44749
Seq_LocateToSongPosition_Skip4:
	ld	iz, (13468:16)	; F44739  ld IZ,(0x349c)
	ld	a, c	; F4473D  ld A,C
	sub	a, 16	; F4473F  sub A,0x10
	scf	; F44742  scf
	stcf_a_16	iz	; F44743  stcf A,IZ
	ld	(13468:16), iz	; F44745  ld (0x349c),IZ
Seq_LocateToSongPosition_Join:
	call	T_SeqTrackCursors_SaveTrack	; F44749  call 0xf40b54
Seq_LocateToSongPosition_Skip5:
	popw	wa	; F4474D  pop WA
	inc	1, (13471:16)	; F4474E  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F44752  cp (0x349f),0x11
	jr	c, Seq_LocateToSongPosition_Loop	; F44757  jr C,0xf446dd
	ld	xwa, (13466:16)	; F44759  ld XWA,(0x349a)
	cp	xwa, 0	; F4475D  cp XWA,0x00000000
	jr	z, Seq_LocateToSongPosition_Skip6	; F44763  jr Z,0xf44777
	or	(0x34bb:16), 0x08	; F44765  or (0x34bb),0x08
	or	(0x34d4:16), 0x10	; F4476A  or (0x34d4),0x10
	call	TimedEventRing_Discard_Veneer	; F4476F  call 0xf44030
	call	Nop_CallsEmptyDirectorySlot_Veneer	; F44773  call 0xf44039
Seq_LocateToSongPosition_Skip6:
	ld	(168:8), 0:io	; F44777  ld (0xa8),0x00
Seq_LocateToSongPosition_Join2:
	and	(MidiIn_SongPositionHi:8), 0x7f	; F4477A  and (0xa5),0x7f
	ret	; F4477E  ret

; --------------------------------------------------------------------------
; Seq_SeekTrackToBeatTick
; Called from: in-module: 0xF44717
; Touches: (0x0D4A) (0x345C) (0x345E) (0x354B)
; Calls:   T_BStore_ReadCursorByte T_BStore_StepCursorOneByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4477F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_SeekTrackToBeatTick: With the track cursor at the start of a beat: leaves it on the first event whose tick byte
;   (the byte after its status byte) is >= (0x354B), or on the beat's closing 0x81 marker; BStore_ErrorCode := 1 when
;   the 0x82 end tag comes first. Seq_LocateToSongPosition sets (0x354B) = Seq_BeatTick and calls it per track after
;   seeking the beat. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
Seq_SeekTrackToBeatTick:
	ld	(BStore_ErrorCode:16), 0	; F4477F  ld (0x0d4a),0x00
	cp	(0x354b:16), 0x00	; F44784  cp (0x354b),0x00
	jr	nz, Seq_SeekTrackToBeatTick_Skip	; F44789  jr NZ,0xf4479b
	call	T_BStore_ReadCursorByte	; F4478B  call 0xf40c54
	cp	a, 130	; F4478F  cp A,0x82
	jr	z, Seq_SeekTrackToBeatTick_Skip3	; F44792  jr Z,0xf44803
	cp	a, 129	; F44794  cp A,0x81
	jr	nz, Seq_SeekTrackToBeatTick_Return	; F44797  jr NZ,0xf44808
	jr	Seq_SeekTrackToBeatTick_Join2	; F44799  jr T,0xf447a4
Seq_SeekTrackToBeatTick_Skip:
	call	T_BStore_ReadCursorByte	; F4479B  call 0xf40c54
Seq_SeekTrackToBeatTick_Join:
	cp	a, 129	; F4479F  cp A,0x81
	jr	nz, Seq_SeekTrackToBeatTick_Skip2	; F447A2  jr NZ,0xf447c7
Seq_SeekTrackToBeatTick_Join2:
	ld	de, (BStore_CursorBlock:16)	; F447A4  ld DE,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F447A8  ld BC,(0x345e)
	pushw	de	; F447AC  push DE
	pushw	bc	; F447AD  push BC
	call	T_BStore_StepCursorOneByte	; F447AE  call 0xf40c50
	call	T_BStore_ReadCursorByte	; F447B2  call 0xf40c54
	popw	bc	; F447B6  pop BC
	popw	de	; F447B7  pop DE
	cp	a, 130	; F447B8  cp A,0x82
	jr	z, Seq_SeekTrackToBeatTick_Skip3	; F447BB  jr Z,0xf44803
	ld	(BStore_CursorBlock:16), de	; F447BD  ld (0x345c),DE
	ld	(BStore_CursorOffset:16), bc	; F447C1  ld (0x345e),BC
	jr	Seq_SeekTrackToBeatTick_Return	; F447C5  jr T,0xf44808
Seq_SeekTrackToBeatTick_Skip2:
	cp	a, 130	; F447C7  cp A,0x82
	jr	z, Seq_SeekTrackToBeatTick_Skip3	; F447CA  jr Z,0xf44803
	ld	de, (BStore_CursorBlock:16)	; F447CC  ld DE,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F447D0  ld BC,(0x345e)
	pushw	de	; F447D4  push DE
	pushw	bc	; F447D5  push BC
	call	T_BStore_StepCursorOneByte	; F447D6  call 0xf40c50
	call	T_BStore_ReadCursorByte	; F447DA  call 0xf40c54
	popw	bc	; F447DE  pop BC
	popw	de	; F447DF  pop DE
	cp	a, (0x354b:16)	; F447E0  cp A,(0x354b)
	jr	c, Seq_SeekTrackToBeatTick_Loop	; F447E4  jr C,0xf447f0
	ld	(BStore_CursorBlock:16), de	; F447E6  ld (0x345c),DE
	ld	(BStore_CursorOffset:16), bc	; F447EA  ld (0x345e),BC
	jr	Seq_SeekTrackToBeatTick_Return	; F447EE  jr T,0xf44808
Seq_SeekTrackToBeatTick_Loop:
	pushw	de	; F447F0  push DE
	pushw	bc	; F447F1  push BC
	call	T_BStore_StepCursorOneByte	; F447F2  call 0xf40c50
	call	T_BStore_ReadCursorByte	; F447F6  call 0xf40c54
	popw	bc	; F447FA  pop BC
	popw	de	; F447FB  pop DE
	bit	7, a	; F447FC  bit 0x07,A
	jr	z, Seq_SeekTrackToBeatTick_Loop	; F447FF  jr Z,0xf447f0
	jr	Seq_SeekTrackToBeatTick_Join	; F44801  jr T,0xf4479f
Seq_SeekTrackToBeatTick_Skip3:
	ld	(BStore_ErrorCode:16), 1	; F44803  ld (0x0d4a),0x01
Seq_SeekTrackToBeatTick_Return:
	ret	; F44808  ret

; --------------------------------------------------------------------------
; Seq_RewindOnRequest
; Called from: in-module: 0xF445BF
; Touches: (0x0C05) (0x207A) (0x2095) (0x3000) (0x34D3) (0x34D8) (0x3552)
;          (0x361E) (0x3622)  |  0x000000
; Calls:   SeqCycle_CheckOn Seq_LocateNowIfPending_Veneer T_F42578 Seq_ApplyStoredSongTempo Seq_RewindToStart MidiOut_SendSongPosition
;          T_Seq_PublishPendingParamB0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44809 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RewindOnRequest: Consumes Seq_RequestRewind's (0x34D3) bit 0: dropped while transport A or B runs or tracks are
;   record-armed; with a cycle on (SeqCycle_CheckOn = 0) the current measure goes to the cycle start ((0x3622) on the record
;   screens 6/8, (0x361E) when past it), otherwise Seq_RewindToStart and the per-track re-arm (MidiOut_SendSongPosition). Called
;   each pass by Seq_MainLoopService. Basis: caller + body + Seq_RequestRewind header. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
Seq_RewindOnRequest:
	bit	0, (0x34d3:16)	; F44809  bit 0,(0x34d3)
	jrl	z, Seq_RewindOnRequest_Return	; F4480D  jrl Z,0xf448a2
	and	(0x34d3:16), 0xfe	; F44810  and (0x34d3),0xfe
	bit	2, (TransportB_State:8)	; F44815  bit 2,(0x96)
	jrl	nz, Seq_RewindOnRequest_Return	; F44818  jrl NZ,0xf448a2
	ld	xwa, (12288:16)	; F4481B  ld XWA,(0x3000)
	cp	xwa, 0	; F4481F  cp XWA,0x00000000
	jr	nz, Seq_RewindOnRequest_Return	; F44825  jr NZ,0xf448a2
	bit	2, (TransportA_State:8)	; F44827  bit 2,(0x94)
	jr	nz, Seq_RewindOnRequest_Return	; F4482A  jr NZ,0xf448a2
	calr	SeqCycle_CheckOn	; F4482C  calr 0xf448c6
	cp	a, 0:i3	; F4482F  cp A,0
	jr	nz, Seq_RewindOnRequest_Skip2	; F44831  jr NZ,0xf44875
	cp	(UI_ScreenLatch:16), 0x06	; F44833  cp (0x207a),0x06
	jr	z, Seq_RewindOnRequest_Skip	; F44838  jr Z,0xf4485e
	cp	(UI_ScreenLatch:16), 0x08	; F4483A  cp (0x207a),0x08
	jr	z, Seq_RewindOnRequest_Skip	; F4483F  jr Z,0xf4485e
	ld	wa, (13854:16)	; F44841  ld WA,(0x361e)
	cp	(0x3552:16), wa	; F44845  cp (0x3552),WA
	jr	le, Seq_RewindOnRequest_Skip2	; F44849  jr LE,0xf44875
	ld	(13650:16), wa	; F4484B  ld (0x3552),WA
	or	(UI_ScreenFlags:16), 0x10	; F4484F  or (0x2095),0x10
	set	7, (0x0c05:16)	; F44854  set 7,(0x0c05)
	call	Seq_LocateNowIfPending_Veneer	; F44858  call 0xf4403c
	jr	Seq_RewindOnRequest_Return	; F4485C  jr T,0xf448a2
Seq_RewindOnRequest_Skip:
	ld	wa, (13858:16)	; F4485E  ld WA,(0x3622)
	ld	(13650:16), wa	; F44862  ld (0x3552),WA
	or	(UI_ScreenFlags:16), 0x10	; F44866  or (0x2095),0x10
	set	7, (0x0c05:16)	; F4486B  set 7,(0x0c05)
	call	Seq_LocateNowIfPending_Veneer	; F4486F  call 0xf4403c
	jr	Seq_RewindOnRequest_Return	; F44873  jr T,0xf448a2
Seq_RewindOnRequest_Skip2:
	bit	2, (0x34d3:16)	; F44875  bit 2,(0x34d3)
	jr	z, Seq_RewindOnRequest_Skip3	; F44879  jr Z,0xf44882
	and	(0x34d3:16), 0xfb	; F4487B  and (0x34d3),0xfb
	jr	Seq_RewindOnRequest_Join	; F44880  jr T,0xf44886
Seq_RewindOnRequest_Skip3:
	call	T_F42578	; F44882  call 0xf42578
Seq_RewindOnRequest_Join:
	cp	(UI_ScreenLatch:16), 0x0d	; F44886  cp (0x207a),0x0d
	jr	nz, Seq_RewindOnRequest_Skip4	; F4488B  jr NZ,0xf44890
	calr	Seq_ApplyStoredSongTempo	; F4488D  calr 0xf448a3
Seq_RewindOnRequest_Skip4:
	calr	Seq_RewindToStart	; F44890  calr 0xf45b1f
	calr	MidiOut_SendSongPosition	; F44893  calr 0xf44ca7
	ld	(168:8), 0:io	; F44896  ld (0xa8),0x00
	and	(0x34d8:16), 0x7f	; F44899  and (0x34d8),0x7f
	call	T_Seq_PublishPendingParamB0	; F4489E  call 0xf40784
Seq_RewindOnRequest_Return:
	ret	; F448A2  ret

; --------------------------------------------------------------------------
; Seq_ApplyStoredSongTempo
; Called from: in-module: 0xF4488D 0xF45144
; Touches: (0x7EE2)  |  0x0008C2 0x603620
; Calls:   T_Queue2E00_AppendRegs T_Tempo_ApplyBpm
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF448A3 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ApplyStoredSongTempo: Tempo (0x7EE2) := the word at 0x603620 + 0x8C2 (the song's stored parameter image, same
;   offset as in the main image), queued as a key-0x7A change (Queue2E00_AppendRegs E 0x7A, D 0, W 0xFF), then
;   Tempo_ApplyBpm. Seq_ApplyLoadedSongSetup runs it on the SEQUENCER MEDLEY latch with Medley_Source 0. Basis:
;   callers + body + the ParamImageAlt header. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
Seq_ApplyStoredSongTempo:
	ld	xhl, 6305312	; F448A3  ld XHL,0x00603620
	ld	xwa, 2242	; F448A8  ld XWA,0x000008c2
	add	xhl, xwa	; F448AD  add XHL,XWA
	ld	wa, (xhl)	; F448AF  ld WA,(XHL)
	pushw	wa	; F448B1  push WA
	ld	e, 122:opc	; F448B2  ld E,0x7a
	ld	d, 0:opc	; F448B4  ld D,0x00
	ld	w, 255:opc	; F448B6  ld W,0xff
	call	T_Queue2E00_AppendRegs	; F448B8  call 0xf40f3c
	popw	wa	; F448BC  pop WA
	ld	(32482:16), wa	; F448BD  ld (0x7ee2),WA
	call	T_Tempo_ApplyBpm	; F448C1  call 0xf40794
	ret	; F448C5  ret

; --------------------------------------------------------------------------
; SeqCycle_CheckOn
; Called from: T_SeqCycle_CheckOn (x3); in-module: 0xF4482C 0xF44DF5 0xF45F56
; Touches: (0x207A) (0x360B)
; Evidence: thunk slot T_SeqCycle_CheckOn holds `jp 0x00F448C6`, and 0xF448C6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_CheckOn: A := 0 when the latched screen's CYCLE is on -- always on the cycle-play edit screens 0x26 / 0x29,
;   on SEQ PLAY 0x12 / CYCLE PLAY 0x14 when the CYCLE PLAY switch ((0x360B) bit 0) is on, on screens 6 / 8 when the
;   CYCLE RECORD switch (bit 1) is on -- else A := 0xFF. Seq_RewindOnRequest and Seq_StopWhenTracksEnded take their
;   cycle path on A == 0; CycleRecord_CheckOn is the record-screen-only twin. Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SeqCycle_CheckOn:		; <- T_SeqCycle_CheckOn
	xor	a, a	; F448C6  xor A,A
	cp	(UI_ScreenLatch:16), 0x26	; F448C8  cp (0x207a),0x26
	jr	z, SeqCycle_CheckOn_Return	; F448CD  jr Z,0xf44902
	cp	(UI_ScreenLatch:16), 0x29	; F448CF  cp (0x207a),0x29
	jr	z, SeqCycle_CheckOn_Return	; F448D4  jr Z,0xf44902
	cp	(UI_ScreenLatch:16), 0x12	; F448D6  cp (0x207a),0x12
	jr	z, SeqCycle_CheckOn_Skip	; F448DB  jr Z,0xf448e4
	cp	(UI_ScreenLatch:16), 0x14	; F448DD  cp (0x207a),0x14
	jr	nz, SeqCycle_CheckOn_Skip2	; F448E2  jr NZ,0xf448ec
SeqCycle_CheckOn_Skip:
	bit	0, (0x360b:16)	; F448E4  bit 0,(0x360b)
	jr	nz, SeqCycle_CheckOn_Return	; F448E8  jr NZ,0xf44902
	jr	SeqCycle_CheckOn_Join	; F448EA  jr T,0xf44900
SeqCycle_CheckOn_Skip2:
	cp	(UI_ScreenLatch:16), 0x06	; F448EC  cp (0x207a),0x06
	jr	z, SeqCycle_CheckOn_Skip3	; F448F1  jr Z,0xf448fa
	cp	(UI_ScreenLatch:16), 0x08	; F448F3  cp (0x207a),0x08
	jr	nz, SeqCycle_CheckOn_Join	; F448F8  jr NZ,0xf44900
SeqCycle_CheckOn_Skip3:
	bit	1, (0x360b:16)	; F448FA  bit 1,(0x360b)
	jr	nz, SeqCycle_CheckOn_Return	; F448FE  jr NZ,0xf44902
SeqCycle_CheckOn_Join:
	ld	a, 255:opc	; F44900  ld A,0xff
SeqCycle_CheckOn_Return:
	ret	; F44902  ret

; --------------------------------------------------------------------------
; CycleRecord_CheckOnPreviousScreen
; Called from: in-module: 0xF45389 0xF4539E
; Touches: (0x207B) (0x360B)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44903 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CheckOnPreviousScreen: CycleRecord_CheckOn on UI_ScreenLatch_Previous: A := 0 when the previously
;   latched screen was 6 or 8 and the CYCLE RECORD switch ((0x360B) bit 1) is on, else A := 0xFF. SeqRecord_EndTake
;   uses it in both arms to choose the cycle-record cleanup (SeqRecord_RestoreCursorBaseline /
;   CycleRecord_FreeRecordChain / SeqRecord_FreeTakeChain2, or T_CycleRecord_CommitTake) over the normal one. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
CycleRecord_CheckOnPreviousScreen:
	xor	a, a	; F44903  xor A,A
	cp	(UI_ScreenLatch_Previous:16), 0x06	; F44905  cp (0x207b),0x06
	jr	z, CycleRecord_CheckOnPreviousScreen_Skip	; F4490A  jr Z,0xf44913
	cp	(UI_ScreenLatch_Previous:16), 0x08	; F4490C  cp (0x207b),0x08
	jr	nz, CycleRecord_CheckOnPreviousScreen_Skip2	; F44911  jr NZ,0xf44919
CycleRecord_CheckOnPreviousScreen_Skip:
	bit	1, (0x360b:16)	; F44913  bit 1,(0x360b)
	jr	nz, CycleRecord_CheckOnPreviousScreen_Return	; F44917  jr NZ,0xf4491b
CycleRecord_CheckOnPreviousScreen_Skip2:
	ld	a, 255:opc	; F44919  ld A,0xff
CycleRecord_CheckOnPreviousScreen_Return:
	ret	; F4491B  ret

; --------------------------------------------------------------------------
; Seq_RestoreSongParamsOnRequest
; Called from: in-module: 0xF445C2
; Touches: (0x34D2)  |  0x000000
; Calls:   T_F42578
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4491C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RestoreSongParamsOnRequest: Consumer of (0x34D2) bit 0, which SeqRecord_SetRecordedTracksPlaying and T_SeqRecord_EndTake (run by
;   RealtimeRecord_Disarm) set when a take ends: with tracks playing ((0x60341E) != 0) it waits while transport C runs
;   ((0x95) bit 2), then runs T_F42578 -- the song parameter-image restore Seq_ApplyLoadedSongSetup also calls -- and
;   clears the bit (at once when no track plays). Called on every Seq_MainLoopService pass. Basis: caller + body +
;   setters. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
Seq_RestoreSongParamsOnRequest:
	bit	0, (0x34d2:16)	; F4491C  bit 0,(0x34d2)
	jr	z, Seq_RestoreSongParamsOnRequest_Return	; F44920  jr Z,0xf4493d
	ld	xwa, (6304798:24)	; F44922  ld XWA,(0x60341e)
	cp	xwa, 0	; F44927  cp XWA,0x00000000
	jr	z, Seq_RestoreSongParamsOnRequest_Skip	; F4492D  jr Z,0xf44938
	bit	2, (TransportC_State:8)	; F4492F  bit 2,(0x95)
	jr	nz, Seq_RestoreSongParamsOnRequest_Return	; F44932  jr NZ,0xf4493d
	call	T_F42578	; F44934  call 0xf42578
Seq_RestoreSongParamsOnRequest_Skip:
	and	(0x34d2:16), 0xfe	; F44938  and (0x34d2),0xfe
Seq_RestoreSongParamsOnRequest_Return:
	ret	; F4493D  ret

; --------------------------------------------------------------------------
; Seq_CountDownMidiStartIgnore
; Called from: in-module: 0xF445C5
; Touches: (0x34BB) (0x3550)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4493E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_CountDownMidiStartIgnore: While (0x3550) bit 7 is set, decrements it once per sequencer pass; at 0x80 it clears
;   (0x3550) and (0x34BB) bit 2, the flag that makes the MIDI-in path ignore 0xFA/0xFB. sub_F44C51 arms it with 0x82
;   when it sets that bit itself, so that ignore lasts two passes. Called by Seq_MainLoopService. Basis: caller + body
;   + the arming site. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
Seq_CountDownMidiStartIgnore:
	bit	7, (0x3550:16)	; F4493E  bit 7,(0x3550)
	jr	z, Seq_CountDownMidiStartIgnore_Return	; F44942  jr Z,0xf44959
	dec	1, (13648:16)	; F44944  dec 1,(0x3550)
	cp	(0x3550:16), 0x80	; F44948  cp (0x3550),0x80
	jr	nz, Seq_CountDownMidiStartIgnore_Return	; F4494D  jr NZ,0xf44959
	ld	(13648:16), 0	; F4494F  ld (0x3550),0x00
	and	(0x34bb:16), 0xfb	; F44954  and (0x34bb),0xfb
Seq_CountDownMidiStartIgnore_Return:
	ret	; F44959  ret

; --------------------------------------------------------------------------
; sub_F4495A
; Called from: in-module: 0xF445C8
; Touches: (0x34DA)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4495A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4495A:
	push	xiy	; F4495A  push XIY
	ld	(13530:16), 0	; F4495B  ld (0x34da),0x00
	jr	sub_F4495A_Epilogue	; F44960  jr T,0xf44962
sub_F4495A_Epilogue:
	pop	xiy	; F44962  pop XIY
	ret	; F44963  ret

; --------------------------------------------------------------------------
; SeqRecord_HandleTransportBStartStop
; Called from: in-module: 0xF445DA
; Touches: (0x225A) (0x3000) (0x3004) (0x345A) (0x34D4) (0x34D9) (0x3552)
;          (0x360B)  |  0x000000
; Calls:   sub_F4598A SeqRecord_EndTake T_NoteRouting_RebuildForSong SeqRecord_BeginTakeOnTransportStart T_BStore_Workspace_StoreParamImage sub_F44A3B
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44964 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_HandleTransportBStartStop: Every pass latches TransportB_State into (0x345A) and clears its bits 1 and 4
;   (the just-started / STOPPED marks MIDI_RT_Received writes as 0x06 / 0x10) under DI; only with record tracks armed
;   ((0x3000) != 0) does it act on them: (0x3004) set + STOPPED edge -> SeqRecord_EndTake, else started edge -> note-routing
;   rebuild + SeqRecord_BeginTakeOnTransportStart; ends with sub_F44A3B. One step of Seq_MainLoopService. Basis: caller + body + state-bit
;   layout. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SeqRecord_HandleTransportBStartStop:
	calr	sub_F4598A	; F44964  calr 0xf4598a
	ei	6	; F44967  ei 0x06
	ld	a, (TransportB_State:8)	; F44969  ld A,(0x96)
	ld	(13402:16), a	; F4496C  ld (0x345a),A
	and	(TransportB_State:8), 0xed	; F44970  and (0x96),0xed
	ei	0	; F44974  ei 0x00
	ld	xwa, (12288:16)	; F44976  ld XWA,(0x3000)
	cp	xwa, 0	; F4497A  cp XWA,0x00000000
	jr	nz, SeqRecord_HandleTransportBStartStop_Skip	; F44980  jr NZ,0xf4498a
	and	(0x34d9:16), 0xfd	; F44982  and (0x34d9),0xfd
	jrl	SeqRecord_HandleTransportBStartStop_Join	; F44987  jrl T,0xf44a37
SeqRecord_HandleTransportBStartStop_Skip:
	ld	xwa, (12292:16)	; F4498A  ld XWA,(0x3004)
	cp	xwa, 0	; F4498E  cp XWA,0x00000000
	jr	z, SeqRecord_HandleTransportBStartStop_Skip3	; F44994  jr Z,0xf449ae
	bit	4, (0x345a:16)	; F44996  bit 4,(0x345a)
	jr	z, SeqRecord_HandleTransportBStartStop_Skip2	; F4499A  jr Z,0xf4499f
	calr	SeqRecord_EndTake	; F4499C  calr 0xf45348
SeqRecord_HandleTransportBStartStop_Skip2:
	bit	0, (0x34d9:16)	; F4499F  bit 0,(0x34d9)
	jrl	z, SeqRecord_HandleTransportBStartStop_Join	; F449A3  jrl Z,0xf44a37
	or	(0x34d9:16), 0x02	; F449A6  or (0x34d9),0x02
	jrl	SeqRecord_HandleTransportBStartStop_Join	; F449AB  jrl T,0xf44a37
SeqRecord_HandleTransportBStartStop_Skip3:
	ld	a, (13529:16)	; F449AE  ld A,(0x34d9)
	and	(0x34d9:16), 0xfd	; F449B2  and (0x34d9),0xfd
	bit	0, (0x34d9:16)	; F449B7  bit 0,(0x34d9)
	jr	z, SeqRecord_HandleTransportBStartStop_Skip4	; F449BB  jr Z,0xf449c2
	or	(0x34d9:16), 0x02	; F449BD  or (0x34d9),0x02
SeqRecord_HandleTransportBStartStop_Skip4:
	xor	a, (13529:16)	; F449C2  xor A,(0x34d9)
	bit	1, a	; F449C6  bit 0x01,A
	jr	z, SeqRecord_HandleTransportBStartStop_Skip7	; F449C9  jr Z,0xf449ea
	bit	1, (0x360b:16)	; F449CB  bit 1,(0x360b)
	jr	nz, SeqRecord_HandleTransportBStartStop_Skip5	; F449CF  jr NZ,0xf449d6
	or	(0x34d4:16), 0x10	; F449D1  or (0x34d4),0x10
SeqRecord_HandleTransportBStartStop_Skip5:
	and	(0x34d4:16), 0xf7	; F449D6  and (0x34d4),0xf7
	bit	1, (0x34d9:16)	; F449DB  bit 1,(0x34d9)
	jr	z, SeqRecord_HandleTransportBStartStop_Skip6	; F449DF  jr Z,0xf449e6
	or	(0x34d4:16), 0x08	; F449E1  or (0x34d4),0x08
SeqRecord_HandleTransportBStartStop_Skip6:
	call	T_NoteRouting_RebuildForSong	; F449E6  call 0xf411b8
SeqRecord_HandleTransportBStartStop_Skip7:
	cpw	(0x3552:16), 0x8001	; F449EA  cp (0x3552),0x8001
	jr	z, SeqRecord_HandleTransportBStartStop_Skip8	; F449F0  jr Z,0xf44a01
	bit	1, (0x360b:16)	; F449F2  bit 1,(0x360b)
	jr	z, SeqRecord_HandleTransportBStartStop_Skip8	; F449F6  jr Z,0xf44a01
	or	(0x34d4:16), 0x08	; F449F8  or (0x34d4),0x08
	call	T_NoteRouting_RebuildForSong	; F449FD  call 0xf411b8
SeqRecord_HandleTransportBStartStop_Skip8:
	bit	1, (0x345a:16)	; F44A01  bit 1,(0x345a)
	jr	z, SeqRecord_HandleTransportBStartStop_Skip11	; F44A05  jr Z,0xf44a28
	bit	1, (0x34d9:16)	; F44A07  bit 1,(0x34d9)
	jr	nz, SeqRecord_HandleTransportBStartStop_Skip9	; F44A0B  jr NZ,0xf44a1a
	ld	xwa, (6304798:24)	; F44A0D  ld XWA,(0x60341e)
	cp	xwa, 0	; F44A12  cp XWA,0x00000000
	jr	z, SeqRecord_HandleTransportBStartStop_Skip10	; F44A18  jr Z,0xf44a23
SeqRecord_HandleTransportBStartStop_Skip9:
	and	(0x34d4:16), 0xf7	; F44A1A  and (0x34d4),0xf7
	call	T_NoteRouting_RebuildForSong	; F44A1F  call 0xf411b8
SeqRecord_HandleTransportBStartStop_Skip10:
	calr	SeqRecord_BeginTakeOnTransportStart	; F44A23  calr 0xf44ada
	jr	SeqRecord_HandleTransportBStartStop_Join	; F44A26  jr T,0xf44a37
SeqRecord_HandleTransportBStartStop_Skip11:
	bit	6, (0x225a:16)	; F44A28  bit 6,(0x225a)
	jr	z, SeqRecord_HandleTransportBStartStop_Join	; F44A2C  jr Z,0xf44a37
	and	(0x225a:16), 0xbf	; F44A2E  and (0x225a),0xbf
	call	T_BStore_Workspace_StoreParamImage	; F44A33  call 0xf42574
SeqRecord_HandleTransportBStartStop_Join:
	calr	sub_F44A3B	; F44A37  calr 0xf44a3b
	ret	; F44A3A  ret

; --------------------------------------------------------------------------
; sub_F44A3B
; Called from: in-module: 0xF44A37
; Touches: (0x0E35) (0x0E36) (0x220B) (0x2215) (0x3008) (0x345A) (0x34BB)
;          (0x34D0) (0x34D4)  |  0x000000
; Calls:   Seq_ResetPositionOnRequest sub_F44C15 sub_F44C51 sub_F44CEA T_Medley_NormFileCommand T_Medley_AdvanceInternalSong
;          T_Transport_StopAllRunning
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44A3B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44A3B:
	calr	Seq_ResetPositionOnRequest	; F44A3B  calr 0xf44b2d
	ld	xwa, (6304798:24)	; F44A3E  ld XWA,(0x60341e)
	cp	xwa, 0	; F44A43  cp XWA,0x00000000
	jr	z, sub_F44A3B_Skip	; F44A49  jr Z,0xf44a54
	bit	1, (0x345a:16)	; F44A4B  bit 1,(0x345a)
	jr	z, sub_F44A3B_Skip	; F44A4F  jr Z,0xf44a54
	calr	sub_F44C15	; F44A51  calr 0xf44c15
sub_F44A3B_Skip:
	and	(0x34bb:16), 0xef	; F44A54  and (0x34bb),0xef
	ld	xwa, (12296:16)	; F44A59  ld XWA,(0x3008)
	cp	xwa, 0	; F44A5D  cp XWA,0x00000000
	jr	z, sub_F44A3B_Skip2	; F44A63  jr Z,0xf44a6e
	bit	4, (0x345a:16)	; F44A65  bit 4,(0x345a)
	jr	z, sub_F44A3B_Skip2	; F44A69  jr Z,0xf44a6e
	calr	sub_F44C51	; F44A6B  calr 0xf44c51
sub_F44A3B_Skip2:
	calr	sub_F44CEA	; F44A6E  calr 0xf44cea
	bit	2, (0x34d0:16)	; F44A71  bit 2,(0x34d0)
	jr	z, sub_F44A3B_Skip3	; F44A75  jr Z,0xf44a98
	cp	(Medley_Source:16), 0x01	; F44A77  cp (0x220b),0x01
	jr	nz, sub_F44A3B_Skip3	; F44A7C  jr NZ,0xf44a98
	cp	(Medley_FileType:16), 0x00	; F44A7E  cp (0x0e35),0x00
	jr	nz, sub_F44A3B_Skip3	; F44A83  jr NZ,0xf44a98
	cp	(0x2215:16), 0x00	; F44A85  cp (0x2215),0x00
	jr	z, sub_F44A3B_Skip3	; F44A8A  jr Z,0xf44a98
	ld	w, 4:opc	; F44A8C  ld W,0x04
	ld	(3638:16), w	; F44A8E  ld (0x0e36),W
	call	T_Medley_NormFileCommand	; F44A92  call 0xf4257c
	jr	sub_F44A3B_Return	; F44A96  jr T,0xf44ad9
sub_F44A3B_Skip3:
	bit	2, (0x34d4:16)	; F44A98  bit 2,(0x34d4)
	jr	z, sub_F44A3B_Return	; F44A9C  jr Z,0xf44ad9
	and	(0x34d4:16), 0xfb	; F44A9E  and (0x34d4),0xfb
	call	T_Medley_AdvanceInternalSong	; F44AA3  call 0xf43024
	bit	2, (0x34d0:16)	; F44AA7  bit 2,(0x34d0)
	jr	z, sub_F44A3B_Return	; F44AAB  jr Z,0xf44ad9
	call	T_Transport_StopAllRunning	; F44AAD  call 0xf409ac
	ldw	bc, 61440	; F44AB1  ld BC,0xf000
	bit	2, (TransportC_State:8)	; F44AB4  bit 2,(0x95)
	jr	z, sub_F44A3B_Skip4	; F44AB7  jr Z,0xf44abf
	nop	; F44AB9  nop
	nop	; F44ABA  nop
	nop	; F44ABB  nop
	djnz16	bc, -11	; F44ABC  djnz BC,0xf44ab4
sub_F44A3B_Skip4:
	cp	(Medley_Source:16), 0x01	; F44ABF  cp (0x220b),0x01
	jr	nz, sub_F44A3B_Return	; F44AC4  jr NZ,0xf44ad9
	cp	(Medley_FileType:16), 0x00	; F44AC6  cp (0x0e35),0x00
	jr	nz, sub_F44A3B_Return	; F44ACB  jr NZ,0xf44ad9
	ld	w, 3:opc	; F44ACD  ld W,0x03
	ld	(3638:16), w	; F44ACF  ld (0x0e36),W
	call	T_Medley_NormFileCommand	; F44AD3  call 0xf4257c
	jr	sub_F44A3B_Return	; F44AD7  jr T,0xf44ad9
sub_F44A3B_Return:
	ret	; F44AD9  ret

; --------------------------------------------------------------------------
; SeqRecord_BeginTakeOnTransportStart
; Called from: in-module: 0xF44A23
; Touches: (0x34D9) (0x3614)
; Calls:   Var20A9_SetBits01 SeqRecord_BeginTake
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44ADA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_BeginTakeOnTransportStart: Var20A9_SetBits01, (0x3614) bit 0, then SeqRecord_BeginTake -- the same three
;   steps SeqRecord_StartIfEventQueued takes when a take starts; its trailing (0x34D9) bit-1 test branches to the same
;   ret. SeqRecord_HandleTransportBStartStop runs it on transport B's just-started edge ((0x345A) bit 1) with record
;   tracks armed and no take begun ((0x3004) = 0). Basis: caller + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
SeqRecord_BeginTakeOnTransportStart:
	calr	Var20A9_SetBits01	; F44ADA  calr 0xf45fae
	or	(0x3614:16), 0x01	; F44ADD  or (0x3614),0x01
	calr	SeqRecord_BeginTake	; F44AE2  calr 0xf45761
	bit	1, (0x34d9:16)	; F44AE5  bit 1,(0x34d9)
	jr	z, SeqRecord_BeginTakeOnTransportStart_Return	; F44AE9  jr Z,0xf44aed
	jr	SeqRecord_BeginTakeOnTransportStart_Return	; F44AEB  jr T,0xf44aed
SeqRecord_BeginTakeOnTransportStart_Return:
	ret	; F44AED  ret

; --------------------------------------------------------------------------
; Seq_SetTrackBeatsFromTransportB
; Called from: T_Seq_SetTrackBeatsFromTransportB (x11); in-module: 0xF45EC8 0xF45F0F
; Touches: (0x345B) (0x34BB)  |  0x0033EA
; Evidence: thunk slot T_Seq_SetTrackBeatsFromTransportB holds `jp 0x00F44AEE`, and 0xF44AEE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_SetTrackBeatsFromTransportB: If (0x34BB) bit 3 (set by the locate paths, cleared by Seq_RewindToStart): (0x345B)
;   := Seq_BeatTick and all 17 per-track words at 0x33EA := TransportB_Beat; else TransportB_Beat, Seq_BeatTick,
;   (0x345B) and the 17 words := 0. Always the third call of the cycle-arming triple (after
;   SeqCycle_CaptureEndCursors, SeqCycle_LocateToStart). Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
Seq_SetTrackBeatsFromTransportB:		; <- T_Seq_SetTrackBeatsFromTransportB
	bit	3, (0x34bb:16)	; F44AEE  bit 3,(0x34bb)
	jr	z, Seq_SetTrackBeatsFromTransportB_Skip	; F44AF2  jr Z,0xf44b0f
	ld	a, (Seq_BeatTick:8)	; F44AF4  ld A,(0x93)
	ld	(13403:16), a	; F44AF7  ld (0x345b),A
	ld	wa, (TransportB_Beat:8)	; F44AFB  ld WA,(0x91)
	ld	xix, 13290	; F44AFE  ld XIX,0x000033ea
	xor	bc, bc	; F44B03  xor BC,BC
	ld	c, 17:opc	; F44B05  ld C,0x11
	ld	(xix+), wa	; F44B07  ld (XIX+),WA
	djnz16	bc, -6	; F44B0A  djnz BC,0xf44b07
	jr	Seq_SetTrackBeatsFromTransportB_Return	; F44B0D  jr T,0xf44b2c
Seq_SetTrackBeatsFromTransportB_Skip:
	ld	(13403:16), 0	; F44B0F  ld (0x345b),0x00
	ldw	(TransportB_Beat:8), 0:io	; F44B14  ld (0x91),0x0000
	ld	(Seq_BeatTick:8), 0:io	; F44B18  ld (0x93),0x00
	xor	wa, wa	; F44B1B  xor WA,WA
	ld	xix, 13290	; F44B1D  ld XIX,0x000033ea
	xor	bc, bc	; F44B22  xor BC,BC
	ld	c, 17:opc	; F44B24  ld C,0x11
	ld	(xix+), wa	; F44B26  ld (XIX+),WA
	djnz16	bc, -6	; F44B29  djnz BC,0xf44b26
Seq_SetTrackBeatsFromTransportB_Return:
	ret	; F44B2C  ret

; --------------------------------------------------------------------------
; Seq_ResetPositionOnRequest
; Called from: T_Seq_ResetPositionOnRequest (x2); in-module: 0xF44A3B 0xF44C4D
; Touches: (0x345B) (0x34BB) (0x34D2) (0x34D4) (0x355A)  |  0x000000
;          0x0033EA
; Calls:   TimedEventRing_Discard sub_F44BE8 Seq_ResetPositionToSongStart
; Evidence: thunk slot T_Seq_ResetPositionOnRequest holds `jp 0x00F44B2D`, and 0xF44B2D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ResetPositionOnRequest: Consumes the position request (0x34D4) bit 4: with no track playing it only clears it
;   and the locate flag ((0x34BB) bit 3); otherwise, unless a song-parameter restore is pending ((0x34D2) bit 0),
;   transport B runs or (0x34D4) bit 6 is set, it clears the bit and either re-arms at the located position ((0x34BB)
;   bit 3: per-track beat words := TransportB_Beat, TimedEventRing_Discard, sub_F44BE8) or calls
;   Seq_ResetPositionToSongStart. Run every sequencer pass via sub_F44A3B and directly by CycleRecord_RestartPass
;   (T_Seq_ResetPositionOnRequest). Basis: callers + body + setter headers. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
Seq_ResetPositionOnRequest:		; <- T_Seq_ResetPositionOnRequest
	ld	xwa, (6304798:24)	; F44B2D  ld XWA,(0x60341e)
	cp	xwa, 0	; F44B32  cp XWA,0x00000000
	jr	nz, Seq_ResetPositionOnRequest_Skip	; F44B38  jr NZ,0xf44b46
	and	(0x34bb:16), 0xf7	; F44B3A  and (0x34bb),0xf7
	and	(0x34d4:16), 0xef	; F44B3F  and (0x34d4),0xef
	jr	Seq_ResetPositionOnRequest_Return	; F44B44  jr T,0xf44b94
Seq_ResetPositionOnRequest_Skip:
	bit	0, (0x34d2:16)	; F44B46  bit 0,(0x34d2)
	jr	nz, Seq_ResetPositionOnRequest_Return	; F44B4A  jr NZ,0xf44b94
	bit	2, (TransportB_State:8)	; F44B4C  bit 2,(0x96)
	jr	nz, Seq_ResetPositionOnRequest_Return	; F44B4F  jr NZ,0xf44b94
	bit	6, (0x34d4:16)	; F44B51  bit 6,(0x34d4)
	jr	nz, Seq_ResetPositionOnRequest_Return	; F44B55  jr NZ,0xf44b94
	bit	4, (0x34d4:16)	; F44B57  bit 4,(0x34d4)
	jr	z, Seq_ResetPositionOnRequest_Return	; F44B5B  jr Z,0xf44b94
	and	(0x34d4:16), 0xef	; F44B5D  and (0x34d4),0xef
	bit	3, (0x34bb:16)	; F44B62  bit 3,(0x34bb)
	jr	z, Seq_ResetPositionOnRequest_Skip2	; F44B66  jr Z,0xf44b91
	ld	a, (Seq_BeatTick:8)	; F44B68  ld A,(0x93)
	ld	(13403:16), a	; F44B6B  ld (0x345b),A
	ld	wa, (TransportB_Beat:8)	; F44B6F  ld WA,(0x91)
	ld	xix, 13290	; F44B72  ld XIX,0x000033ea
	xor	bc, bc	; F44B77  xor BC,BC
	ld	c, 17:opc	; F44B79  ld C,0x11
	ld	(xix+), wa	; F44B7B  ld (XIX+),WA
	djnz16	bc, -6	; F44B7E  djnz BC,0xf44b7b
	ld	(168:8), 0:io	; F44B81  ld (0xa8),0x00
	calr	TimedEventRing_Discard	; F44B84  calr 0xf45b0a
	or	(0x355a:16), 0x02	; F44B87  or (0x355a),0x02
	calr	sub_F44BE8	; F44B8C  calr 0xf44be8
	jr	Seq_ResetPositionOnRequest_Return	; F44B8F  jr T,0xf44b94
Seq_ResetPositionOnRequest_Skip2:
	calr	Seq_ResetPositionToSongStart	; F44B91  calr 0xf44b95
Seq_ResetPositionOnRequest_Return:
	ret	; F44B94  ret

; --------------------------------------------------------------------------
; Seq_ResetPositionToSongStart
; Called from: in-module: 0xF44B91 0xF4510E 0xF45B44
; Touches: (0x3456) (0x3458) (0x345B) (0x34D0) (0x34D9) (0x3552)  |
;          0x0033EA
; Calls:   SeqScreen_RepaintIfPlayOrRecord TimedEventRing_Discard Seq_ResetTrackExpressionToFull sub_F4598A SeqTrackCursors_RewindPlaying sub_F44BE8
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44B95 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ResetPositionToSongStart: Song position := the start: (0x345B), TransportB_Beat, Seq_BeatTick and the 17 per-
;   track beat words at 0x33EA := 0, (0x3458) := TransportA_BeatsPerBar, (0x3456) := 0, current measure (0x3552) := 1
;   unless (0x34D9) b1; then TimedEventRing_Discard and the per-track re-arm calls. The shared tail of
;   Seq_RewindToStart and Seq_RewindAfterSongLoad. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
Seq_ResetPositionToSongStart:
	ld	(13403:16), 0	; F44B95  ld (0x345b),0x00
	ldw	(TransportB_Beat:8), 0:io	; F44B9A  ld (0x91),0x0000
	ld	(Seq_BeatTick:8), 0:io	; F44B9E  ld (0x93),0x00
	xor	wa, wa	; F44BA1  xor WA,WA
	ld	xix, 13290	; F44BA3  ld XIX,0x000033ea
	xor	bc, bc	; F44BA8  xor BC,BC
	ld	c, 17:opc	; F44BAA  ld C,0x11
	ld	(xix+), wa	; F44BAC  ld (XIX+),WA
	djnz16	bc, -6	; F44BAF  djnz BC,0xf44bac
	ld	a, (TransportA_BeatsPerBar:24)	; F44BB2  ld A,(0x605000)
	ld	(13400:16), a	; F44BB7  ld (0x3458),A
	ldw	(13398:16), 0	; F44BBB  ld (0x3456),0x0000
	bit	1, (0x34d9:16)	; F44BC1  bit 1,(0x34d9)
	jr	nz, Seq_ResetPositionToSongStart_Skip	; F44BC5  jr NZ,0xf44bd0
	ldw	(13650:16), 1	; F44BC7  ld (0x3552),0x0001
	calr	SeqScreen_RepaintIfPlayOrRecord	; F44BCD  calr 0xf45fe5
Seq_ResetPositionToSongStart_Skip:
	calr	TimedEventRing_Discard	; F44BD0  calr 0xf45b0a
	calr	Seq_ResetTrackExpressionToFull	; F44BD3  calr 0xf45d9b
	ld	(168:8), 0:io	; F44BD6  ld (0xa8),0x00
	or	(0x34d0:16), 0x10	; F44BD9  or (0x34d0),0x10
	calr	sub_F4598A	; F44BDE  calr 0xf4598a
	calr	SeqTrackCursors_RewindPlaying	; F44BE1  calr 0xf44516
	calr	sub_F44BE8	; F44BE4  calr 0xf44be8
	ret	; F44BE7  ret

; --------------------------------------------------------------------------
; sub_F44BE8
; Called from: in-module: 0xF44B8C 0xF44BE4
; Touches: (0x3008) (0x349A) (0x34BB) (0x34D0) (0x355A)
; Calls:   sub_F4517B T_F40B48
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44BE8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44BE8:
	calr	sub_F4517B	; F44BE8  calr 0xf4517b
	ld	xwa, (12296:16)	; F44BEB  ld XWA,(0x3008)
	push	xwa	; F44BEF  push XWA
	ld	xwa, (13466:16)	; F44BF0  ld XWA,(0x349a)
	ld	(12296:16), xwa	; F44BF4  ld (0x3008),XWA
	call	T_F40B48	; F44BF8  call 0xf40b48
	pop	xwa	; F44BFC  pop XWA
	ld	(12296:16), xwa	; F44BFD  ld (0x3008),XWA
	and	(0x34d0:16), 0xef	; F44C01  and (0x34d0),0xef
	and	(0x355a:16), 0xfd	; F44C06  and (0x355a),0xfd
	ld	a, (13499:16)	; F44C0B  ld A,(0x34bb)
	bit	3, a	; F44C0F  bit 0x03,A
	jr	nz, sub_F44BE8_Return	; F44C12  jr NZ,0xf44c14
sub_F44BE8_Return:
	ret	; F44C14  ret

; --------------------------------------------------------------------------
; sub_F44C15
; Called from: in-module: 0xF44A51
; Touches: (0x2075) (0x3008) (0x349A) (0x34BB) (0x34D4) (0x3731)
; Calls:   Seq_LocateNowIfPending UiScreenFlags_SetRepaintInPlace
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44C15 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44C15:
	res	1, (0x3731:16)	; F44C15  res 1,(0x3731)
	ld	(UI_RequestBits:16), 0	; F44C19  ld (0x2075),0x00
	calr	Seq_LocateNowIfPending	; F44C1E  calr 0xf44c37
	ld	xwa, (13466:16)	; F44C21  ld XWA,(0x349a)
	ld	(12296:16), xwa	; F44C25  ld (0x3008),XWA
	and	(0x34d4:16), 0xfb	; F44C29  and (0x34d4),0xfb
	calr	UiScreenFlags_SetRepaintInPlace	; F44C2E  calr 0xf46015
	or	(0x34bb:16), 0x08	; F44C31  or (0x34bb),0x08
	ret	; F44C36  ret

; --------------------------------------------------------------------------
; Seq_LocateNowIfPending
; Called from: in-module: 0xF44C1E
; Touches: (0x0C05)
; Calls:   Seq_LocateToCurrentMeasure T_PartNotes_ReleaseAllTrackNotes T_F41F18 Seq_ResetPositionOnRequest
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44C37 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_LocateNowIfPending: When the delayed-locate countdown (0x0C05) bit 7 is armed: (0x0C05) := 0,
;   Seq_LocateToCurrentMeasure, T_PartNotes_ReleaseAllTrackNotes, T_F41F18, Seq_ResetPositionOnRequest. The body
;   behind Seq_LocateNowIfPending_Veneer (Seq_RewindOnRequest's cycle path sets bit 7 just before). Basis: caller
;   (veneer header) + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
Seq_LocateNowIfPending:
	bit	7, (0x0c05:16)	; F44C37  bit 7,(0x0c05)
	jr	z, Seq_LocateNowIfPending_Return	; F44C3B  jr Z,0xf44c50
	ld	(3077:16), 0	; F44C3D  ld (0x0c05),0x00
	calr	Seq_LocateToCurrentMeasure	; F44C42  calr 0xf45bd3
	call	T_PartNotes_ReleaseAllTrackNotes	; F44C45  call 0xf413c8
	call	T_F41F18	; F44C49  call 0xf41f18
	calr	Seq_ResetPositionOnRequest	; F44C4D  calr 0xf44b2d
Seq_LocateNowIfPending_Return:
	ret	; F44C50  ret

; --------------------------------------------------------------------------
; sub_F44C51
; Called from: in-module: 0xF44A6B
; Touches: (0x207A) (0x3008) (0x349A) (0x34BB) (0x34D1) (0x34D2) (0x34D8)
;          (0x3550)
; Calls:   T_PartNotes_ReleaseAllTrackNotes T_F41F18 MidiOut_SendSongPosition T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44C51 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44C51:
	bit	7, (0x34d8:16)	; F44C51  bit 7,(0x34d8)
	jr	nz, sub_F44C51_Skip	; F44C55  jr NZ,0xf44c5c
	and	(0x34d1:16), 0xbf	; F44C57  and (0x34d1),0xbf
sub_F44C51_Skip:
	and	(0x34d8:16), 0x7f	; F44C5C  and (0x34d8),0x7f
	call	T_PartNotes_ReleaseAllTrackNotes	; F44C61  call 0xf413c8
	call	T_F41F18	; F44C65  call 0xf41f18
	or	(0x34d2:16), 0x08	; F44C69  or (0x34d2),0x08
	ld	xwa, (12296:16)	; F44C6E  ld XWA,(0x3008)
	ld	(13466:16), xwa	; F44C72  ld (0x349a),XWA
	cp	(UI_ScreenLatch:16), 0x13	; F44C76  cp (0x207a),0x13
	jr	nz, sub_F44C51_Skip2	; F44C7B  jr NZ,0xf44c7f
	jr	sub_F44C51_Join	; F44C7D  jr T,0xf44c91
sub_F44C51_Skip2:
	bit	2, (0x34bb:16)	; F44C7F  bit 2,(0x34bb)
	jr	nz, sub_F44C51_Skip3	; F44C83  jr NZ,0xf44c8f
	or	(0x34bb:16), 0x04	; F44C85  or (0x34bb),0x04
	ld	(13648:16), 130	; F44C8A  ld (0x3550),0x82
sub_F44C51_Skip3:
	jr	sub_F44C51_Join2	; F44C8F  jr T,0xf44c9c
sub_F44C51_Join:
	or	(0x34bb:16), 0x10	; F44C91  or (0x34bb),0x10
	xor	xwa, xwa	; F44C96  xor XWA,XWA
	ld	(12296:16), xwa	; F44C98  ld (0x3008),XWA
sub_F44C51_Join2:
	calr	MidiOut_SendSongPosition	; F44C9C  calr 0xf44ca7
	ld	(168:8), 0:io	; F44C9F  ld (0xa8),0x00
	call	T_NoteRouting_RebuildForSong	; F44CA2  call 0xf411b8
	ret	; F44CA6  ret

; --------------------------------------------------------------------------
; MidiOut_SendSongPosition
; Called from: in-module: 0xF44893 0xF44C9C 0xF45C0F 0xF45C93
; Touches: (0x0922) (0x7F34)
; Calls:   T_MidiOut_PutByteA_SetStatus T_MidiOut_PutByteA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44CA7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiOut_SendSongPosition: Transmits MIDI Song Position Pointer F2 <lsb> <msb>, position = TransportB_Beat x 4 +
;   Seq_BeatTick / 24 (sixteenths), when (0x7F34) bit 2 is set -- the bit that also gates receiving Song Position and
;   0xFA/0xFB/0xFC -- and (0x0922) bit 0 is clear. Seq_LocateToCurrentMeasure calls it after every locate. Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
MidiOut_SendSongPosition:
	bit	0, (0x0922:16)	; F44CA7  bit 0,(0x0922)
	jr	nz, MidiOut_SendSongPosition_Return	; F44CAB  jr NZ,0xf44ce9
	bit	2, (MidiFilter_Realtime:16)	; F44CAD  bit 2,(0x7f34)
	jr	z, MidiOut_SendSongPosition_Return	; F44CB1  jr Z,0xf44ce9
	ld	de, (TransportB_Beat:8)	; F44CB3  ld DE,(0x91)
	sla	de, 2	; F44CB6  sla 0x02,DE
	xor	w, w	; F44CB9  xor W,W
	ld	a, (Seq_BeatTick:8)	; F44CBB  ld A,(0x93)
	ld	c, 24:opc	; F44CBE  ld C,0x18
	div	wa, c	; F44CC0  div WA,C
	xor	w, w	; F44CC2  xor W,W
	add	wa, de	; F44CC4  add WA,DE
	ld	c, a	; F44CC6  ld C,A
	and	c, 127	; F44CC8  and C,0x7f
	rlc	wa	; F44CCB  rlc 0x01,WA
	and	w, 127	; F44CCE  and W,0x7f
	ld	b, w	; F44CD1  ld B,W
	pushw	bc	; F44CD3  push BC
	ld	a, 242:opc	; F44CD4  ld A,0xf2
	call	T_MidiOut_PutByteA_SetStatus	; F44CD6  call 0xf4074c
	popw	bc	; F44CDA  pop BC
	pushw	bc	; F44CDB  push BC
	ld	a, c	; F44CDC  ld A,C
	call	T_MidiOut_PutByteA	; F44CDE  call 0xf40750
	popw	bc	; F44CE2  pop BC
	ld	a, b	; F44CE3  ld A,B
	call	T_MidiOut_PutByteA	; F44CE5  call 0xf40750
MidiOut_SendSongPosition_Return:
	ret	; F44CE9  ret

; --------------------------------------------------------------------------
; sub_F44CEA
; Called from: in-module: 0xF44A6E
; Touches: (0x207A) (0x3459) (0x345A) (0x34D9) (0x3552) (0x36D4)
; Calls:   SeqScreen_RepaintIfPlayOrRecord sub_F45F19
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44CEA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44CEA:
	bit	2, (TransportB_State:8)	; F44CEA  bit 2,(0x96)
	jr	z, sub_F44CEA_Skip	; F44CED  jr Z,0xf44cf1
	jr	sub_F44CEA_Join	; F44CEF  jr T,0xf44d2b
sub_F44CEA_Skip:
	bit	1, (0x34d9:16)	; F44CF1  bit 1,(0x34d9)
	jr	z, sub_F44CEA_Skip3	; F44CF5  jr Z,0xf44d36
	bit	7, (0x34d9:16)	; F44CF7  bit 7,(0x34d9)
	jr	z, sub_F44CEA_Skip2	; F44CFB  jr Z,0xf44d1e
	bit	2, (0x345a:16)	; F44CFD  bit 2,(0x345a)
	jr	nz, sub_F44CEA_Join	; F44D01  jr NZ,0xf44d2b
	cp	(0x3459:16), 0x00	; F44D03  cp (0x3459),0x00
	jrl	nz, sub_F44CEA_Join2	; F44D08  jrl NZ,0xf44d7a
	cp	(TransportA_Bar:24), 0x01	; F44D0B  cp (0x605002),0x01
	jr	nz, sub_F44CEA_Join2	; F44D11  jr NZ,0xf44d7a
	ldw	(13650:16), 32769	; F44D13  ld (0x3552),0x8001
	calr	SeqScreen_RepaintIfPlayOrRecord	; F44D19  calr 0xf45fe5
	jr	sub_F44CEA_Join2	; F44D1C  jr T,0xf44d7a
sub_F44CEA_Skip2:
	ld	wa, (13650:16)	; F44D1E  ld WA,(0x3552)
	ld	(14036:16), wa	; F44D22  ld (0x36d4),WA
	calr	SeqScreen_RepaintIfPlayOrRecord	; F44D26  calr 0xf45fe5
	jr	sub_F44CEA_Join2	; F44D29  jr T,0xf44d7a
sub_F44CEA_Join:
	bit	1, (0x345a:16)	; F44D2B  bit 1,(0x345a)
	jr	nz, sub_F44CEA_Skip4	; F44D2F  jr NZ,0xf44d3c
sub_F44CEA_Loop:
	calr	sub_F45F19	; F44D31  calr 0xf45f19
	jr	sub_F44CEA_Join2	; F44D34  jr T,0xf44d7a
sub_F44CEA_Skip3:
	bit	7, (0x34d9:16)	; F44D36  bit 7,(0x34d9)
	jr	z, sub_F44CEA_Loop	; F44D3A  jr Z,0xf44d31
sub_F44CEA_Skip4:
	bit	1, (0x34d9:16)	; F44D3C  bit 1,(0x34d9)
	jr	z, sub_F44CEA_Join2	; F44D40  jr Z,0xf44d7a
	ld	wa, (14036:16)	; F44D42  ld WA,(0x36d4)
	ld	(13650:16), wa	; F44D46  ld (0x3552),WA
	cp	(UI_ScreenLatch:16), 0x0a	; F44D4A  cp (0x207a),0x0a
	jr	nz, sub_F44CEA_Skip5	; F44D4F  jr NZ,0xf44d63
	ld	wa, (6304961:24)	; F44D51  ld WA,(0x6034c1)
	cp	(6304968:24), wa	; F44D56  cp (0x6034c8),WA
	jr	c, sub_F44CEA_Skip5	; F44D5B  jr C,0xf44d63
	ldw	(13650:16), 1	; F44D5D  ld (0x3552),0x0001
sub_F44CEA_Skip5:
	calr	SeqScreen_RepaintIfPlayOrRecord	; F44D63  calr 0xf45fe5
	jr	sub_F44CEA_Join2	; F44D66  jr T,0xf44d7a
	ld	iz, (13650:16)	; F44D68  ld IZ,(0x3552)
	and	iz, 32768	; F44D6C  and IZ,0x8000
	jr	z, sub_F44CEA_Join2	; F44D70  jr Z,0xf44d7a
	ld	wa, (14036:16)	; F44D72  ld WA,(0x36d4)
	ld	(13650:16), wa	; F44D76  ld (0x3552),WA
sub_F44CEA_Join2:
	and	(0x34d9:16), 0x7f	; F44D7A  and (0x34d9),0x7f
	bit	1, (0x34d9:16)	; F44D7F  bit 1,(0x34d9)
	jr	z, sub_F44CEA_Skip6	; F44D83  jr Z,0xf44d8a
	or	(0x34d9:16), 0x80	; F44D85  or (0x34d9),0x80
sub_F44CEA_Skip6:
	ld	a, (TransportA_Bar:24)	; F44D8A  ld A,(0x605002)
	ld	(13401:16), a	; F44D8F  ld (0x3459),A
	ret	; F44D93  ret

; --------------------------------------------------------------------------
; Seq_StopWhenTracksEnded
; Called from: in-module: 0xF445E1
; Touches: (0x207A) (0x3000) (0x3008) (0x300C) (0x34BB) (0x34D0) (0x34D2)
;          (0x34D4) (0x34D8) (0x34DA) +3 more  |  0x000000
; Calls:   T_Transport_StopAllRunning T_TransportB_Stop SeqCycle_CheckOn TimedEvents_QueueRoutingRebuild T_Seq_PublishPendingParamB0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44D94 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_StopWhenTracksEnded: While nothing records ((0x3000) = 0): when a playing track still had data last pass
;   ((0x300C) & (0x60341E)) and none has now ((0x3008) & (0x60341E); TimedEvents_ClearEndedTrackBits clears a track's
;   bit at its end-of-chain tag), clears both masks and stops the transport; unless a cycle is on and the measure is
;   within its end ((0x3620), (0x3624) on the record screens) it also sets (0x34D4) bit 4 and queues timed events
;   0x88, 0x7F (TimedEvents_QueueRoutingRebuild). Always ends (0x300C) := (0x3008). Called each pass by Seq_MainLoopService. Basis: caller
;   + body + writer header. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
Seq_StopWhenTracksEnded:
	ld	xwa, (12288:16)	; F44D94  ld XWA,(0x3000)
	cp	xwa, 0	; F44D98  cp XWA,0x00000000
	jr	z, Seq_StopWhenTracksEnded_Skip	; F44D9E  jr Z,0xf44da3
	jrl	Seq_StopWhenTracksEnded_Join3	; F44DA0  jrl T,0xf44e4a
Seq_StopWhenTracksEnded_Skip:
	ld	xbc, (12300:16)	; F44DA3  ld XBC,(0x300c)
	and	xbc, (0x60341e:24)	; F44DA7  and XBC,(0x60341e)
	ld	xde, (12296:16)	; F44DAC  ld XDE,(0x3008)
	and	xde, (0x60341e:24)	; F44DB0  and XDE,(0x60341e)
	cp	xbc, 0	; F44DB5  cp XBC,0x00000000
	jrl	z, Seq_StopWhenTracksEnded_Join3	; F44DBB  jrl Z,0xf44e4a
	cp	xde, 0	; F44DBE  cp XDE,0x00000000
	jrl	nz, Seq_StopWhenTracksEnded_Join3	; F44DC4  jrl NZ,0xf44e4a
	xor	xwa, xwa	; F44DC7  xor XWA,XWA
	ld	(12300:16), xwa	; F44DC9  ld (0x300c),XWA
	ld	(12296:16), xwa	; F44DCD  ld (0x3008),XWA
	bit	4, (0x34bb:16)	; F44DD1  bit 4,(0x34bb)
	jr	nz, Seq_StopWhenTracksEnded_Skip2	; F44DD5  jr NZ,0xf44ddc
	or	(0x34d4:16), 0x04	; F44DD7  or (0x34d4),0x04
Seq_StopWhenTracksEnded_Skip2:
	bit	3, (TransportA_State:8)	; F44DDC  bit 3,(0x94)
	jr	nz, Seq_StopWhenTracksEnded_Skip3	; F44DDF  jr NZ,0xf44de6
	bit	2, (TransportA_State:8)	; F44DE1  bit 2,(0x94)
	jr	nz, Seq_StopWhenTracksEnded_Skip4	; F44DE4  jr NZ,0xf44dec
Seq_StopWhenTracksEnded_Skip3:
	call	T_Transport_StopAllRunning	; F44DE6  call 0xf409ac
	jr	Seq_StopWhenTracksEnded_Join	; F44DEA  jr T,0xf44df0
Seq_StopWhenTracksEnded_Skip4:
	call	T_TransportB_Stop	; F44DEC  call 0xf409a8
Seq_StopWhenTracksEnded_Join:
	ld	(13530:16), 0	; F44DF0  ld (0x34da),0x00
	calr	SeqCycle_CheckOn	; F44DF5  calr 0xf448c6
	cp	a, 0:i3	; F44DF8  cp A,0
	jr	nz, Seq_StopWhenTracksEnded_Skip6	; F44DFA  jr NZ,0xf44e22
	cp	(UI_ScreenLatch:16), 0x06	; F44DFC  cp (0x207a),0x06
	jr	z, Seq_StopWhenTracksEnded_Skip5	; F44E01  jr Z,0xf44e16
	cp	(UI_ScreenLatch:16), 0x08	; F44E03  cp (0x207a),0x08
	jr	z, Seq_StopWhenTracksEnded_Skip5	; F44E08  jr Z,0xf44e16
	ld	wa, (13650:16)	; F44E0A  ld WA,(0x3552)
	cp	wa, (0x3620:16)	; F44E0E  cp WA,(0x3620)
	jr	ugt, Seq_StopWhenTracksEnded_Skip6	; F44E12  jr UGT,0xf44e22
	jr	Seq_StopWhenTracksEnded_Join3	; F44E14  jr T,0xf44e4a
Seq_StopWhenTracksEnded_Skip5:
	ld	wa, (13650:16)	; F44E16  ld WA,(0x3552)
	cp	wa, (0x3624:16)	; F44E1A  cp WA,(0x3624)
	jr	ugt, Seq_StopWhenTracksEnded_Skip6	; F44E1E  jr UGT,0xf44e22
	jr	Seq_StopWhenTracksEnded_Join3	; F44E20  jr T,0xf44e4a
Seq_StopWhenTracksEnded_Skip6:
	or	(0x34d4:16), 0x10	; F44E22  or (0x34d4),0x10
	and	(0x34bb:16), 0xf7	; F44E27  and (0x34bb),0xf7
	bit	3, (0x34d2:16)	; F44E2C  bit 3,(0x34d2)
	jr	nz, Seq_StopWhenTracksEnded_Skip7	; F44E30  jr NZ,0xf44e3c
	or	(0x34d4:16), 0x40	; F44E32  or (0x34d4),0x40
	or	(0x34d0:16), 0x02	; F44E37  or (0x34d0),0x02
Seq_StopWhenTracksEnded_Skip7:
	calr	TimedEvents_QueueRoutingRebuild	; F44E3C  calr 0xf44e58
	jr	Seq_StopWhenTracksEnded_Join2	; F44E3F  jr T,0xf44e41
Seq_StopWhenTracksEnded_Join2:
	and	(0x34d8:16), 0x7f	; F44E41  and (0x34d8),0x7f
	call	T_Seq_PublishPendingParamB0	; F44E46  call 0xf40784
Seq_StopWhenTracksEnded_Join3:
	ld	xwa, (12296:16)	; F44E4A  ld XWA,(0x3008)
	ld	(12300:16), xwa	; F44E4E  ld (0x300c),XWA
	and	(0x34d2:16), 0xf7	; F44E52  and (0x34d2),0xf7
	ret	; F44E57  ret

; --------------------------------------------------------------------------
; TimedEvents_QueueRoutingRebuild
; Called from: in-module: 0xF44E3C
; Touches: nothing with an absolute address
; Calls:   T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44E58 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TimedEvents_QueueRoutingRebuild: Puts {0x88, 0x7F} into the timed-event ring (T_TimedEventRing_Put twice):
;   TimedEvents_ClassifyStatus gives status 0x88 class 2, which TimedEvents_DispatchDueRun hands to
;   T_NoteRouting_Rebuild (0x7F is not a tick stamp; stamps are < 0x60). Seq_StopWhenTracksEnded queues it when the
;   song has run out outside a cycle. Basis: caller + body + ring consumer. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
TimedEvents_QueueRoutingRebuild:
	ld	a, 136:opc	; F44E58  ld A,0x88
	pushw	wa	; F44E5A  push WA
	call	T_TimedEventRing_Put	; F44E5B  call 0xf41d64
	inc	2, xsp	; F44E5F  inc 2,XSP
	ld	a, 127:opc	; F44E61  ld A,0x7f
	pushw	wa	; F44E63  push WA
	call	T_TimedEventRing_Put	; F44E64  call 0xf41d64
	inc	2, xsp	; F44E68  inc 2,XSP
	ret	; F44E6A  ret

; --------------------------------------------------------------------------
; Seq_StopPlaybackOnRequest
; Called from: in-module: 0xF445E4 0xF44EED 0xF44F24 0xF44FC6 0xF44FFD
; Touches: (0x34D2)
; Calls:   T_PartNotes_ReleaseAllTrackNotes T_F41F18 T_F40CB4 T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF44E6B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_StopPlaybackOnRequest: (0x34D2) bit 1 taken and cleared: T_PartNotes_ReleaseAllTrackNotes, T_F41F18 (SeqEvt_ResetPlayingSlotControllers),
;   the playing-track mask (0x60341E) = 0, T_F40CB4 (a bare ret), T_NoteRouting_RebuildForSong.  Basis: body.
Seq_StopPlaybackOnRequest:
	bit	1, (0x34d2:16)	; F44E6B  bit 1,(0x34d2)
	jr	z, Seq_StopPlaybackOnRequest_Return	; F44E6F  jr Z,0xf44e8d
	and	(0x34d2:16), 0xfd	; F44E71  and (0x34d2),0xfd
	call	T_PartNotes_ReleaseAllTrackNotes	; F44E76  call 0xf413c8
	call	T_F41F18	; F44E7A  call 0xf41f18
	xor	xwa, xwa	; F44E7E  xor XWA,XWA
	ld	(6304798:24), xwa	; F44E80  ld (0x60341e),XWA
	call	T_F40CB4	; F44E85  call 0xf40cb4
	call	T_NoteRouting_RebuildForSong	; F44E89  call 0xf411b8
Seq_StopPlaybackOnRequest_Return:
	ret	; F44E8D  ret

; --------------------------------------------------------------------------
; SeqTrack_QueueSwitchOffEvents
; Called from: T_SeqTrack_QueueSwitchOffEvents (x0); in-module: 0xF4460E 0xF45338
; Touches: (0x3008) (0x349F) (0x34D2) (0x3738) (0x373A)  |  0x000000
;          0x600800
; Calls:   Seq_StopPlaybackOnRequest TimedEventRing_Discard sub_F454B3 SeqTrack_QueueNoteOffAndBendCentre sub_F450B2
; Evidence: thunk slot T_SeqTrack_QueueSwitchOffEvents holds `jp 0x00F44E8E`, and 0xF44E8E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_QueueSwitchOffEvents: For track (0x349F) being switched off during playback: when the timed-event ring has
;   at least 29 free bytes ((0x600808)), clears its pending bit in (0x3738)/(0x373A) and queues its ring events
;   (sub_F454B3, SeqTrack_QueueNoteOffAndBendCentre, sub_F450B2); otherwise sets that bit so Seq_MainLoopService retries it. When no track is
;   left playing ((0x60341E) = 0) it stops playback and empties the ring. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
SeqTrack_QueueSwitchOffEvents:		; <- T_SeqTrack_QueueSwitchOffEvents
	ld	xhl, 6293504	; F44E8E  ld XHL,0x00600800
	ld	iy, (xhl+8)	; F44E93  ld IY,(XHL+0x08)
	cp	iy, 29	; F44E96  cp IY,0x001d
	jr	nc, SeqTrack_QueueSwitchOffEvents_Skip2	; F44E9A  jr NC,0xf44f02
	ld	c, (13471:16)	; F44E9C  ld C,(0x349f)
	cp	c, 16	; F44EA0  cp C,0x10
	jr	nc, SeqTrack_QueueSwitchOffEvents_Skip	; F44EA3  jr NC,0xf44eb4
	ld	iz, (14136:16)	; F44EA5  ld IZ,(0x3738)
	ld	a, c	; F44EA9  ld A,C
	scf	; F44EAB  scf
	stcf_a_16	iz	; F44EAC  stcf A,IZ
	ld	(14136:16), iz	; F44EAE  ld (0x3738),IZ
	jr	SeqTrack_QueueSwitchOffEvents_Join	; F44EB2  jr T,0xf44ec4
SeqTrack_QueueSwitchOffEvents_Skip:
	ld	iz, (14138:16)	; F44EB4  ld IZ,(0x373a)
	ld	a, c	; F44EB8  ld A,C
	sub	a, 16	; F44EBA  sub A,0x10
	scf	; F44EBD  scf
	stcf_a_16	iz	; F44EBE  stcf A,IZ
	ld	(14138:16), iz	; F44EC0  ld (0x373a),IZ
SeqTrack_QueueSwitchOffEvents_Join:
	bit	2, (TransportB_State:8)	; F44EC4  bit 2,(0x96)
	jrl	nz, SeqTrack_QueueSwitchOffEvents_Return	; F44EC7  jrl NZ,0xf44f66
	ld	xwa, (6304798:24)	; F44ECA  ld XWA,(0x60341e)
	cp	xwa, 0	; F44ECF  cp XWA,0x00000000
	jrl	nz, SeqTrack_QueueSwitchOffEvents_Return	; F44ED5  jrl NZ,0xf44f66
	xor	xwa, xwa	; F44ED8  xor XWA,XWA
	ld	(12296:16), xwa	; F44EDA  ld (0x3008),XWA
	or	(0x34d2:16), 0x02	; F44EDE  or (0x34d2),0x02
	ld	xwa, 4294967295	; F44EE3  ld XWA,0xffffffff
	ld	(6304798:24), xwa	; F44EE8  ld (0x60341e),XWA
	calr	Seq_StopPlaybackOnRequest	; F44EED  calr 0xf44e6b
	xor	xwa, xwa	; F44EF0  xor XWA,XWA
	ld	(6304798:24), xwa	; F44EF2  ld (0x60341e),XWA
	calr	TimedEventRing_Discard	; F44EF7  calr 0xf45b0a
	xor	xwa, xwa	; F44EFA  xor XWA,XWA
	ld	(14136:16), xwa	; F44EFC  ld (0x3738),XWA
	jr	SeqTrack_QueueSwitchOffEvents_Return	; F44F00  jr T,0xf44f66
SeqTrack_QueueSwitchOffEvents_Skip2:
	ld	xwa, (6304798:24)	; F44F02  ld XWA,(0x60341e)
	cp	xwa, 0	; F44F07  cp XWA,0x00000000
	jr	nz, SeqTrack_QueueSwitchOffEvents_Skip3	; F44F0D  jr NZ,0xf44f39
	xor	xwa, xwa	; F44F0F  xor XWA,XWA
	ld	(12296:16), xwa	; F44F11  ld (0x3008),XWA
	or	(0x34d2:16), 0x02	; F44F15  or (0x34d2),0x02
	ld	xwa, 4294967295	; F44F1A  ld XWA,0xffffffff
	ld	(6304798:24), xwa	; F44F1F  ld (0x60341e),XWA
	calr	Seq_StopPlaybackOnRequest	; F44F24  calr 0xf44e6b
	xor	xwa, xwa	; F44F27  xor XWA,XWA
	ld	(6304798:24), xwa	; F44F29  ld (0x60341e),XWA
	calr	TimedEventRing_Discard	; F44F2E  calr 0xf45b0a
	xor	xwa, xwa	; F44F31  xor XWA,XWA
	ld	(14136:16), xwa	; F44F33  ld (0x3738),XWA
	jr	SeqTrack_QueueSwitchOffEvents_Return	; F44F37  jr T,0xf44f66
SeqTrack_QueueSwitchOffEvents_Skip3:
	cp	c, 16	; F44F39  cp C,0x10
	jr	nc, SeqTrack_QueueSwitchOffEvents_Skip4	; F44F3C  jr NC,0xf44f4d
	ld	iz, (14136:16)	; F44F3E  ld IZ,(0x3738)
	ld	a, c	; F44F42  ld A,C
	rcf	; F44F44  rcf
	stcf_a_16	iz	; F44F45  stcf A,IZ
	ld	(14136:16), iz	; F44F47  ld (0x3738),IZ
	jr	SeqTrack_QueueSwitchOffEvents_Join2	; F44F4B  jr T,0xf44f5d
SeqTrack_QueueSwitchOffEvents_Skip4:
	ld	iz, (14138:16)	; F44F4D  ld IZ,(0x373a)
	ld	a, c	; F44F51  ld A,C
	sub	a, 16	; F44F53  sub A,0x10
	rcf	; F44F56  rcf
	stcf_a_16	iz	; F44F57  stcf A,IZ
	ld	(14138:16), iz	; F44F59  ld (0x373a),IZ
SeqTrack_QueueSwitchOffEvents_Join2:
	calr	sub_F454B3	; F44F5D  calr 0xf454b3
	calr	SeqTrack_QueueNoteOffAndBendCentre	; F44F60  calr 0xf45b6e
	calr	sub_F450B2	; F44F63  calr 0xf450b2
SeqTrack_QueueSwitchOffEvents_Return:
	ret	; F44F66  ret

; --------------------------------------------------------------------------
; sub_F44F67
; Called from: T_F40ABC (x2)
; Touches: (0x3008) (0x349F) (0x34D2) (0x3738) (0x373A)  |  0x000000
;          0x600800
; Calls:   Seq_StopPlaybackOnRequest TimedEventRing_Discard sub_F454B3 SeqTrack_QueueNoteOffAndBendCentre
; Evidence: thunk slot T_F40ABC holds `jp 0x00F44F67`, and 0xF44F67 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F44F67:		; <- T_F40ABC
	ld	xhl, 6293504	; F44F67  ld XHL,0x00600800
	ld	iy, (xhl+8)	; F44F6C  ld IY,(XHL+0x08)
	cp	iy, 29	; F44F6F  cp IY,0x001d
	jr	nc, sub_F44E8E_Skip6	; F44F73  jr NC,0xf44fdb
	ld	c, (13471:16)	; F44F75  ld C,(0x349f)
	cp	c, 16	; F44F79  cp C,0x10
	jr	nc, sub_F44E8E_Skip5	; F44F7C  jr NC,0xf44f8d
	ld	iz, (14136:16)	; F44F7E  ld IZ,(0x3738)
	ld	a, c	; F44F82  ld A,C
	scf	; F44F84  scf
	stcf_a_16	iz	; F44F85  stcf A,IZ
	ld	(14136:16), iz	; F44F87  ld (0x3738),IZ
	jr	sub_F44E8E_Join3	; F44F8B  jr T,0xf44f9d
sub_F44E8E_Skip5:
	ld	iz, (14138:16)	; F44F8D  ld IZ,(0x373a)
	ld	a, c	; F44F91  ld A,C
	sub	a, 16	; F44F93  sub A,0x10
	scf	; F44F96  scf
	stcf_a_16	iz	; F44F97  stcf A,IZ
	ld	(14138:16), iz	; F44F99  ld (0x373a),IZ
sub_F44E8E_Join3:
	bit	2, (TransportB_State:8)	; F44F9D  bit 2,(0x96)
	jrl	nz, sub_F44E8E_Return2	; F44FA0  jrl NZ,0xf4503c
	ld	xwa, (6304798:24)	; F44FA3  ld XWA,(0x60341e)
	cp	xwa, 0	; F44FA8  cp XWA,0x00000000
	jrl	nz, sub_F44E8E_Return2	; F44FAE  jrl NZ,0xf4503c
	xor	xwa, xwa	; F44FB1  xor XWA,XWA
	ld	(12296:16), xwa	; F44FB3  ld (0x3008),XWA
	or	(0x34d2:16), 0x02	; F44FB7  or (0x34d2),0x02
	ld	xwa, 4294967295	; F44FBC  ld XWA,0xffffffff
	ld	(6304798:24), xwa	; F44FC1  ld (0x60341e),XWA
	calr	Seq_StopPlaybackOnRequest	; F44FC6  calr 0xf44e6b
	xor	xwa, xwa	; F44FC9  xor XWA,XWA
	ld	(6304798:24), xwa	; F44FCB  ld (0x60341e),XWA
	calr	TimedEventRing_Discard	; F44FD0  calr 0xf45b0a
	xor	xwa, xwa	; F44FD3  xor XWA,XWA
	ld	(14136:16), xwa	; F44FD5  ld (0x3738),XWA
	jr	sub_F44E8E_Return2	; F44FD9  jr T,0xf4503c
sub_F44E8E_Skip6:
	ld	xwa, (6304798:24)	; F44FDB  ld XWA,(0x60341e)
	cp	xwa, 0	; F44FE0  cp XWA,0x00000000
	jr	nz, sub_F44E8E_Skip7	; F44FE6  jr NZ,0xf45012
	xor	xwa, xwa	; F44FE8  xor XWA,XWA
	ld	(12296:16), xwa	; F44FEA  ld (0x3008),XWA
	or	(0x34d2:16), 0x02	; F44FEE  or (0x34d2),0x02
	ld	xwa, 4294967295	; F44FF3  ld XWA,0xffffffff
	ld	(6304798:24), xwa	; F44FF8  ld (0x60341e),XWA
	calr	Seq_StopPlaybackOnRequest	; F44FFD  calr 0xf44e6b
	xor	xwa, xwa	; F45000  xor XWA,XWA
	ld	(6304798:24), xwa	; F45002  ld (0x60341e),XWA
	calr	TimedEventRing_Discard	; F45007  calr 0xf45b0a
	xor	xwa, xwa	; F4500A  xor XWA,XWA
	ld	(14136:16), xwa	; F4500C  ld (0x3738),XWA
	jr	sub_F44E8E_Return2	; F45010  jr T,0xf4503c
sub_F44E8E_Skip7:
	cp	c, 16	; F45012  cp C,0x10
	jr	nc, sub_F44E8E_Skip8	; F45015  jr NC,0xf45026
	ld	iz, (14136:16)	; F45017  ld IZ,(0x3738)
	ld	a, c	; F4501B  ld A,C
	rcf	; F4501D  rcf
	stcf_a_16	iz	; F4501E  stcf A,IZ
	ld	(14136:16), iz	; F45020  ld (0x3738),IZ
	jr	sub_F44E8E_Join4	; F45024  jr T,0xf45036
sub_F44E8E_Skip8:
	ld	iz, (14138:16)	; F45026  ld IZ,(0x373a)
	ld	a, c	; F4502A  ld A,C
	sub	a, 16	; F4502C  sub A,0x10
	rcf	; F4502F  rcf
	stcf_a_16	iz	; F45030  stcf A,IZ
	ld	(14138:16), iz	; F45032  ld (0x373a),IZ
sub_F44E8E_Join4:
	calr	sub_F454B3	; F45036  calr 0xf454b3
	calr	SeqTrack_QueueNoteOffAndBendCentre	; F45039  calr 0xf45b6e
sub_F44E8E_Return2:
	ret	; F4503C  ret

; --------------------------------------------------------------------------
; sub_F4503D
; Called from: in-module: 0xF450F2
; Touches: (0x3616) (0x3617) (0x3618) (0x3619) (0x361A) (0x361B) (0x361C)
; Calls:   T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4503D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4503D:
	ld	a, (13846:16)	; F4503D  ld A,(0x3616)
	bit	7, (0x361a:16)	; F45041  bit 7,(0x361a)
	jr	z, sub_F4503D_Skip	; F45045  jr Z,0xf4504e
	set	0, a	; F45047  set 0x00,A
	res	7, (0x361a:16)	; F4504A  res 7,(0x361a)
sub_F4503D_Skip:
	bit	7, (0x361b:16)	; F4504E  bit 7,(0x361b)
	jr	z, sub_F4503D_Skip2	; F45052  jr Z,0xf4505b
	set	1, a	; F45054  set 0x01,A
	res	7, (0x361b:16)	; F45057  res 7,(0x361b)
sub_F4503D_Skip2:
	bit	7, (0x3618:16)	; F4505B  bit 7,(0x3618)
	jr	z, sub_F4503D_Skip3	; F4505F  jr Z,0xf45068
	set	2, a	; F45061  set 0x02,A
	res	7, (0x3618:16)	; F45064  res 7,(0x3618)
sub_F4503D_Skip3:
	pushw	wa	; F45068  push WA
	call	T_TimedEventRing_Put	; F45069  call 0xf41d64
	inc	2, xsp	; F4506D  inc 2,XSP
	ld	a, (13847:16)	; F4506F  ld A,(0x3617)
	pushw	wa	; F45073  push WA
	call	T_TimedEventRing_Put	; F45074  call 0xf41d64
	inc	2, xsp	; F45078  inc 2,XSP
	ld	a, (13848:16)	; F4507A  ld A,(0x3618)
	pushw	wa	; F4507E  push WA
	call	T_TimedEventRing_Put	; F4507F  call 0xf41d64
	inc	2, xsp	; F45083  inc 2,XSP
	ld	a, (13849:16)	; F45085  ld A,(0x3619)
	pushw	wa	; F45089  push WA
	call	T_TimedEventRing_Put	; F4508A  call 0xf41d64
	inc	2, xsp	; F4508E  inc 2,XSP
	ld	a, (13850:16)	; F45090  ld A,(0x361a)
	pushw	wa	; F45094  push WA
	call	T_TimedEventRing_Put	; F45095  call 0xf41d64
	inc	2, xsp	; F45099  inc 2,XSP
	ld	a, (13851:16)	; F4509B  ld A,(0x361b)
	pushw	wa	; F4509F  push WA
	call	T_TimedEventRing_Put	; F450A0  call 0xf41d64
	inc	2, xsp	; F450A4  inc 2,XSP
	ld	a, (13852:16)	; F450A6  ld A,(0x361c)
	pushw	wa	; F450AA  push WA
	call	T_TimedEventRing_Put	; F450AB  call 0xf41d64
	inc	2, xsp	; F450AF  inc 2,XSP
	ret	; F450B1  ret

; --------------------------------------------------------------------------
; sub_F450B2
; Called from: T_F40A4C (x0); in-module: 0xF44F63
; Touches: (0x349F) (0x3616) (0x3617) (0x3618) (0x3619) (0x361A) (0x361B)
;          (0x361C)  |  0x603422
; Calls:   T_F40BD4 sub_F4503D
; Evidence: thunk slot T_F40A4C holds `jp 0x00F450B2`, and 0xF450B2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F450B2:		; <- T_F40A4C
	xor	wa, wa	; F450B2  xor WA,WA
	ld	a, (13471:16)	; F450B4  ld A,(0x349f)
	ld	iy, wa	; F450B8  ld IY,WA
	ld	xix, BStore_TrackToPart	; F450BA  ld XIX,0x00603422
	ld	a, (xix+iy)	; F450BF  ld A,(XIX+IY)
	cp	a, 32	; F450C4  cp A,0x20
	jr	z, sub_F450B2_Return	; F450C7  jr Z,0xf450f6
	ld	(13846:16), 176	; F450C9  ld (0x3616),0xb0
	ld	(13847:16), 127	; F450CE  ld (0x3617),0x7f
	call	T_F40BD4	; F450D3  call 0xf40bd4
	ld	(13848:16), a	; F450D7  ld (0x3618),A
	ld	(13849:16), 4	; F450DB  ld (0x3619),0x04
	ld	(13850:16), 0	; F450E0  ld (0x361a),0x00
	ld	(13851:16), 8	; F450E5  ld (0x361b),0x08
	ld	a, (13471:16)	; F450EA  ld A,(0x349f)
	ld	(13852:16), a	; F450EE  ld (0x361c),A
	call	sub_F4503D	; F450F2  call 0xf4503d
sub_F450B2_Return:
	ret	; F450F6  ret

; --------------------------------------------------------------------------
; Seq_RewindAfterSongLoad
; Called from: T_Seq_RewindAfterSongLoad (x4)
; Touches: (0x3008) (0x300C) (0x34BB) (0x34D4)
; Calls:   Seq_ApplyLoadedSongSetup Seq_ResetPositionToSongStart sub_F4598A T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_Seq_RewindAfterSongLoad holds `jp 0x00F450F7`, and 0xF450F7 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RewindAfterSongLoad: Zeroes (0x3008)/(0x300C), Seq_ApplyLoadedSongSetup, clears (0x34BB) b3 and (0x34D4) b2, Seq_ResetPositionToSongStart (beat
;   counters 0, measure 1, TimedEventRing_Discard), sub_F4598A, NoteRouting_RebuildForSong: Seq_RewindToStart's steps
;   plus the route rebuild. Called right after SeqFile_Load / SeqFile_LoadAllBanks load a song and by Medley_Tick
;   before the next INT song starts. Basis: callers + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_e.json)
Seq_RewindAfterSongLoad:		; <- T_Seq_RewindAfterSongLoad
	xor	xwa, xwa	; F450F7  xor XWA,XWA
	ld	(12296:16), xwa	; F450F9  ld (0x3008),XWA
	ld	(12300:16), xwa	; F450FD  ld (0x300c),XWA
	calr	Seq_ApplyLoadedSongSetup	; F45101  calr 0xf45119
	and	(0x34bb:16), 0xf7	; F45104  and (0x34bb),0xf7
	and	(0x34d4:16), 0xfb	; F45109  and (0x34d4),0xfb
	calr	Seq_ResetPositionToSongStart	; F4510E  calr 0xf44b95
	calr	sub_F4598A	; F45111  calr 0xf4598a
	call	T_NoteRouting_RebuildForSong	; F45114  call 0xf411b8
	ret	; F45118  ret

; --------------------------------------------------------------------------
; Seq_ApplyLoadedSongSetup
; Called from: in-module: 0xF45101
; Touches: (0x124C) (0x207A) (0x220B) (0x34BB) (0x7F4D)  |  0x000000
; Calls:   sub_F4598A T_F40CB4 T_F42578 Seq_ApplyStoredSongTempo T_Queue2C00_AppendRegs T_Queue2C00_DrainPassAB
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45119 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ApplyLoadedSongSetup: After a song load, when its playing-track mask (0x60341E) is non-zero: restores the song's
;   stored parameter image (T_F42578), on the SEQUENCER MEDLEY latch with source 0 applies its stored tempo
;   (Seq_ApplyStoredSongTempo), and sets GM mode (0x7F4D) bit 2 from the song's GM flag (0x6034C6 == 0xFF), posting the record-0x91
;   byte-3 bit-2 event. First clears (0x34BB) bit 3 and runs sub_F4598A. Run by Seq_RewindAfterSongLoad. Basis: caller
;   + body + the store twin. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
Seq_ApplyLoadedSongSetup:
	and	(0x34bb:16), 0xf7	; F45119  and (0x34bb),0xf7
	calr	sub_F4598A	; F4511E  calr 0xf4598a
	call	T_F40CB4	; F45121  call 0xf40cb4
	ld	xwa, (6304798:24)	; F45125  ld XWA,(0x60341e)
	cp	xwa, 0	; F4512A  cp XWA,0x00000000
	jr	z, Seq_ApplyLoadedSongSetup_Return	; F45130  jr Z,0xf4517a
	call	T_F42578	; F45132  call 0xf42578
	cp	(UI_ScreenLatch:16), 0x13	; F45136  cp (0x207a),0x13
	jr	nz, Seq_ApplyLoadedSongSetup_Skip	; F4513B  jr NZ,0xf45147
	cp	(Medley_Source:16), 0x00	; F4513D  cp (0x220b),0x00
	jr	nz, Seq_ApplyLoadedSongSetup_Skip	; F45142  jr NZ,0xf45147
	calr	Seq_ApplyStoredSongTempo	; F45144  calr 0xf448a3
Seq_ApplyLoadedSongSetup_Skip:
	cp	(0x6034c6:24), 0xff	; F45147  cp (0x6034c6),0xff
	jr	z, Seq_ApplyLoadedSongSetup_Skip2	; F4514D  jr Z,0xf45156
	and	(0x7f4d:16), 0xfb	; F4514F  and (0x7f4d),0xfb
	jr	Seq_ApplyLoadedSongSetup_Join	; F45154  jr T,0xf4515b
Seq_ApplyLoadedSongSetup_Skip2:
	or	(0x7f4d:16), 0x04	; F45156  or (0x7f4d),0x04
Seq_ApplyLoadedSongSetup_Join:
	ld	(4684:16), 1	; F4515B  ld (0x124c),0x01
	ld	e, 145:opc	; F45160  ld E,0x91
	ld	d, 3:opc	; F45162  ld D,0x03
	ld	w, 4:opc	; F45164  ld W,0x04
	xor	a, a	; F45166  xor A,A
	cp	(0x6034c6:24), 0xff	; F45168  cp (0x6034c6),0xff
	jr	nz, Seq_ApplyLoadedSongSetup_Skip3	; F4516E  jr NZ,0xf45172
	ld	a, 4:opc	; F45170  ld A,0x04
Seq_ApplyLoadedSongSetup_Skip3:
	call	T_Queue2C00_AppendRegs	; F45172  call 0xf40f38
	call	T_Queue2C00_DrainPassAB	; F45176  call 0xf40018
Seq_ApplyLoadedSongSetup_Return:
	ret	; F4517A  ret

; --------------------------------------------------------------------------
; sub_F4517B
; Called from: in-module: 0xF44BE8
; Touches:   |  0x003015 0x003038 0x00325A
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4517B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4517B:
	push	xhl	; F4517B  push XHL
	push	xiy	; F4517C  push XIY
	pushw	bc	; F4517D  push BC
	ld	xhl, 12309	; F4517E  ld XHL,0x00003015
	ld	(xhl), 1	; F45183  ld (XHL),0x01
	xor	iy, iy	; F45186  xor IY,IY
	ld	xhl, 12344	; F45188  ld XHL,0x00003038
sub_F45119_Loop:
	ldw	(xhl+iy), 0x0000	; F4518D  ld (XHL+IY),0x0000
	add	iy, 2	; F45194  add IY,0x0002
	cp	iy, 34	; F45198  cp IY,0x0022
	jr	c, sub_F45119_Loop	; F4519C  jr C,0xf4518d
	xor	iy, iy	; F4519E  xor IY,IY
	xor	bc, bc	; F451A0  xor BC,BC
	ld	xhl, 12890	; F451A2  ld XHL,0x0000325a
sub_F45119_Loop2:
	ld	xiz, xhl	; F451A7  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F451A9  lda XIZ,XIZ+IY
	ld	(xiz+4), c	; F451AE  ld (XIZ+0x04),C
	inc	1, c	; F451B1  inc 1,C
	add	iy, 6	; F451B3  add IY,0x0006
	cp	iy, 384	; F451B7  cp IY,0x0180
	jr	c, sub_F45119_Loop2	; F451BB  jr C,0xf451a7
	xor	iy, iy	; F451BD  xor IY,IY
	ld	c, 2:opc	; F451BF  ld C,0x02
sub_F45119_Loop3:
	ld	xiz, xhl	; F451C1  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F451C3  lda XIZ,XIZ+IY
	ld	(xiz+5), c	; F451C8  ld (XIZ+0x05),C
	inc	1, c	; F451CB  inc 1,C
	add	iy, 6	; F451CD  add IY,0x0006
	cp	iy, 378	; F451D1  cp IY,0x017a
	jr	c, sub_F45119_Loop3	; F451D5  jr C,0xf451c1
	ld	xiz, xhl	; F451D7  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F451D9  lda XIZ,XIZ+IY
	ld	(xiz+5), 255	; F451DE  ld (XIZ+0x05),0xff
	popw	bc	; F451E2  pop BC
	pop	xiy	; F451E3  pop XIY
	pop	xhl	; F451E4  pop XHL
	ret	; F451E5  ret

; --------------------------------------------------------------------------
; SeqRecord_RewindForTake
; Called from: T_SeqRecord_RewindForTake (x4)
; Touches: (0x3008) (0x3456) (0x3458) (0x34BB) (0x34D4) (0x34D9) (0x3552)
;          (0x360B) (0x36D4)  |  0x000000
; Calls:   SeqRecord_ResetSlotLists SeqScreen_RepaintIfPlayOrRecord TimedEventRing_Discard T_NoteRouting_RebuildForSong SeqBufRing_Discard T_BStore_Workspace_StoreParamImage
; Evidence: thunk slot T_SeqRecord_RewindForTake holds `jp 0x00F451E6`, and 0xF451E6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_RewindForTake: Puts realtime recording back at the song start: SeqRecord_ResetSlotLists (re-links the 64-entry list at
;   0x305A), (0x3008) := 0, measure (0x3552) := 1, beat/tick and (0x3456) := 0, (0x3458) := TransportA_BeatsPerBar,
;   locate flag cleared, count-in re-armed from its setting ((0x34D9) bit 0 -> bit 1, (0x36D4) := 1), (0x34D4) bits
;   3/4 when tracks play (else TimedEventRing_Discard), routing rebuilt, SeqBufRing_Discard, parameter image stored.
;   Called (T_SeqRecord_RewindForTake) by SeqRecord_DisarmTrack in REALTIME RECORD, by RealtimeRecord_Arm's body RealtimeRecord_ArmAtFirstMeasure, by
;   SeqRecord_ArmTrack and sub_F4A661. Basis: callers + body + CountIn_ToggleEnable header. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
SeqRecord_RewindForTake:		; <- T_SeqRecord_RewindForTake
	calr	SeqRecord_ResetSlotLists	; F451E6  calr 0xf45263
	xor	xwa, xwa	; F451E9  xor XWA,XWA
	ld	(12296:16), xwa	; F451EB  ld (0x3008),XWA
	ldw	(13650:16), 1	; F451EF  ld (0x3552),0x0001
	and	(0x34d4:16), 0xf7	; F451F5  and (0x34d4),0xf7
	and	(0x34d9:16), 0x79	; F451FA  and (0x34d9),0x79
	bit	0, (0x34d9:16)	; F451FF  bit 0,(0x34d9)
	jr	z, SeqRecord_RewindForTake_Skip4	; F45203  jr Z,0xf45217
	or	(0x34d9:16), 0x02	; F45205  or (0x34d9),0x02
	or	(0x34d4:16), 0x08	; F4520A  or (0x34d4),0x08
	ld	wa, (13650:16)	; F4520F  ld WA,(0x3552)
	ld	(14036:16), wa	; F45213  ld (0x36d4),WA
SeqRecord_RewindForTake_Skip4:
	bit	1, (0x360b:16)	; F45217  bit 1,(0x360b)
	jr	z, SeqRecord_RewindForTake_Skip5	; F4521B  jr Z,0xf45222
	or	(0x34d4:16), 0x08	; F4521D  or (0x34d4),0x08
SeqRecord_RewindForTake_Skip5:
	ldw	(13398:16), 0	; F45222  ld (0x3456),0x0000
	calr	SeqScreen_RepaintIfPlayOrRecord	; F45228  calr 0xf45fe5
	and	(0x34bb:16), 0xf7	; F4522B  and (0x34bb),0xf7
	ldw	(TransportB_Beat:8), 0:io	; F45230  ld (0x91),0x0000
	ld	(Seq_BeatTick:8), 0:io	; F45234  ld (0x93),0x00
	ld	a, (TransportA_BeatsPerBar:24)	; F45237  ld A,(0x605000)
	ld	(13400:16), a	; F4523C  ld (0x3458),A
	ld	xwa, (6304798:24)	; F45240  ld XWA,(0x60341e)
	cp	xwa, 0	; F45245  cp XWA,0x00000000
	jr	z, SeqRecord_RewindForTake_Skip6	; F4524B  jr Z,0xf45254
	or	(0x34d4:16), 0x18	; F4524D  or (0x34d4),0x18
	jr	SeqRecord_RewindForTake_Join2	; F45252  jr T,0xf45257
SeqRecord_RewindForTake_Skip6:
	calr	TimedEventRing_Discard	; F45254  calr 0xf45b0a
SeqRecord_RewindForTake_Join2:
	call	T_NoteRouting_RebuildForSong	; F45257  call 0xf411b8
	calr	SeqBufRing_Discard	; F4525B  calr 0xf45975
	call	T_BStore_Workspace_StoreParamImage	; F4525E  call 0xf42574
	ret	; F45262  ret

; --------------------------------------------------------------------------
; SeqRecord_ResetSlotLists
; Called from: in-module: 0xF451E6
; Touches:   |  0x003014 0x003016 0x00305A
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45263 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_ResetSlotLists: Resets the record module's slot lists: 64 eight-byte slots at 0x305A doubly linked into
;   one free list (+6 prev, +7 next, 1-based, 0xFF ends it), free head (0x3014) := 1, and the 17 per-track (head,
;   tail) byte pairs at 0x3016 := 0. First step of SeqRecord_RewindForTake (also via T_SeqRecord_ResetSlotLists_Veneer). What a slot holds is
;   not read here. Basis: caller + body + list users. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
SeqRecord_ResetSlotLists:
	push	xhl	; F45263  push XHL
	pushw	iy	; F45264  push IY
	pushw	bc	; F45265  push BC
	ld	xhl, 12308	; F45266  ld XHL,0x00003014
	ld	(xhl), 1	; F4526B  ld (XHL),0x01
	xor	iy, iy	; F4526E  xor IY,IY
	ld	xhl, 12310	; F45270  ld XHL,0x00003016
SeqRecord_ResetSlotLists_Loop:
	ldw	(xhl+iy), 0x0000	; F45275  ld (XHL+IY),0x0000
	add	iy, 2	; F4527C  add IY,0x0002
	cp	iy, 34	; F45280  cp IY,0x0022
	jr	c, SeqRecord_ResetSlotLists_Loop	; F45284  jr C,0xf45275
	xor	iy, iy	; F45286  xor IY,IY
	xor	c, c	; F45288  xor C,C
	ld	xhl, 12378	; F4528A  ld XHL,0x0000305a
SeqRecord_ResetSlotLists_Loop2:
	ld	xiz, xhl	; F4528F  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F45291  lda XIZ,XIZ+IY
	ld	(xiz+6), c	; F45296  ld (XIZ+0x06),C
	inc	1, c	; F45299  inc 1,C
	add	iy, 8	; F4529B  add IY,0x0008
	cp	iy, 512	; F4529F  cp IY,0x0200
	jr	c, SeqRecord_ResetSlotLists_Loop2	; F452A3  jr C,0xf4528f
	xor	iy, iy	; F452A5  xor IY,IY
	ld	c, 2:opc	; F452A7  ld C,0x02
	ld	xhl, 12378	; F452A9  ld XHL,0x0000305a
SeqRecord_ResetSlotLists_Loop3:
	ld	xiz, xhl	; F452AE  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F452B0  lda XIZ,XIZ+IY
	ld	(xiz+7), c	; F452B5  ld (XIZ+0x07),C
	inc	1, c	; F452B8  inc 1,C
	add	iy, 8	; F452BA  add IY,0x0008
	cp	iy, 504	; F452BE  cp IY,0x01f8
	jr	c, SeqRecord_ResetSlotLists_Loop3	; F452C2  jr C,0xf452ae
	ld	xiz, xhl	; F452C4  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F452C6  lda XIZ,XIZ+IY
	ld	(xiz+7), 255	; F452CB  ld (XIZ+0x07),0xff
	popw	bc	; F452CF  pop BC
	popw	iy	; F452D0  pop IY
	pop	xhl	; F452D1  pop XHL
	ret	; F452D2  ret

; --------------------------------------------------------------------------
; SeqTrack_CompletePlayOff
; Called from: T_SeqTrack_CompletePlayOff (x2)
; Touches: (0x3008) (0x300C) (0x349F) (0x34D1)  |  0x000000
; Calls:   TimedEventRing_Discard T_NoteRouting_RebuildForSong SeqTrack_QueueSwitchOffEvents
; Evidence: thunk slot T_SeqTrack_CompletePlayOff holds `jp 0x00F452D3`, and 0xF452D3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_CompletePlayOff: XWA = the bit of the track losing PLAY: with transport B stopped it clears that bit from
;   (0x3008)/(0x300C) (and, when no track is left playing, both masks, (0x34D1) bit 7 and the timed-event ring) and
;   rebuilds the note routing; with transport B running it runs SeqTrack_QueueSwitchOffEvents for each track in the
;   mask. The last call (T_SeqTrack_CompletePlayOff) of SeqTrack_PlayOffWhileStopped and SeqTrack_SwitchPlayOffWhileRunning. Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SeqTrack_CompletePlayOff:		; <- T_SeqTrack_CompletePlayOff
	bit	2, (TransportB_State:8)	; F452D3  bit 2,(0x96)
	jr	nz, SeqTrack_CompletePlayOff_Skip2	; F452D6  jr NZ,0xf4530a
	cpl	wa	; F452D8  cpl WA
	cpl	qwa	; F452DA  cpl QWA
	and	(0x3008:16), xwa	; F452DD  and (0x3008),XWA
	and	(0x300c:16), xwa	; F452E1  and (0x300c),XWA
	ld	xwa, (6304798:24)	; F452E5  ld XWA,(0x60341e)
	cp	xwa, 0	; F452EA  cp XWA,0x00000000
	jr	nz, SeqTrack_CompletePlayOff_Skip	; F452F0  jr NZ,0xf45304
	xor	xwa, xwa	; F452F2  xor XWA,XWA
	ld	(12296:16), xwa	; F452F4  ld (0x3008),XWA
	ld	(12300:16), xwa	; F452F8  ld (0x300c),XWA
	and	(0x34d1:16), 0x7f	; F452FC  and (0x34d1),0x7f
	calr	TimedEventRing_Discard	; F45301  calr 0xf45b0a
SeqTrack_CompletePlayOff_Skip:
	call	T_NoteRouting_RebuildForSong	; F45304  call 0xf411b8
	jr	SeqTrack_CompletePlayOff_Return	; F45308  jr T,0xf45347
SeqTrack_CompletePlayOff_Skip2:
	ld	(13471:16), 0	; F4530A  ld (0x349f),0x00
SeqTrack_CompletePlayOff_Loop4:
	ld	c, (13471:16)	; F4530F  ld C,(0x349f)
	cp	c, 16	; F45313  cp C,0x10
	jr	nc, SeqTrack_CompletePlayOff_Skip3	; F45316  jr NC,0xf45325
	ld	iz, wa	; F45318  ld IZ,WA
	ld	a, c	; F4531A  ld A,C
	scf	; F4531C  scf
	xorcf_a_16	iz	; F4531D  xorcf A,IZ
	ld	wa, iz	; F4531F  ld WA,IZ
	jr	c, SeqTrack_CompletePlayOff_Skip4	; F45321  jr C,0xf4533c
	jr	SeqTrack_CompletePlayOff_Join	; F45323  jr T,0xf45337
SeqTrack_CompletePlayOff_Skip3:
	pushw	wa	; F45325  push WA
	ld	iz, qwa	; F45326  ld IZ,QWA
	ld	a, c	; F45329  ld A,C
	sub	a, 16	; F4532B  sub A,0x10
	scf	; F4532E  scf
	xorcf_a_16	iz	; F4532F  xorcf A,IZ
	ld	qwa, iz	; F45331  ld QWA,IZ
	popw	wa	; F45334  pop WA
	jr	c, SeqTrack_CompletePlayOff_Skip4	; F45335  jr C,0xf4533c
SeqTrack_CompletePlayOff_Join:
	push	xwa	; F45337  push XWA
	calr	SeqTrack_QueueSwitchOffEvents	; F45338  calr 0xf44e8e
	pop	xwa	; F4533B  pop XWA
SeqTrack_CompletePlayOff_Skip4:
	inc	1, (13471:16)	; F4533C  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F45340  cp (0x349f),0x11
	jr	c, SeqTrack_CompletePlayOff_Loop4	; F45345  jr C,0xf4530f
SeqTrack_CompletePlayOff_Return:
	ret	; F45347  ret

; --------------------------------------------------------------------------
; SeqRecord_EndTake
; Called from: T_SeqRecord_EndTake (x1); in-module: 0xF4499C
; Touches: (0x3000) (0x3004) (0x3008) (0x300C) (0x34D0) (0x34D2) (0x34D4)
;          (0x34D9) (0x3552) (0x3610) +1 more  |  0x000000
; Calls:   T_NoteRouting_RebuildForSong CycleRecord_CheckOnPreviousScreen T_SeqRecord_RestoreCursorBaseline T_CycleRecord_FreeRecordChain T_SeqRecord_FreeTakeChain2 T_CycleRecord_CommitTake T_SeqRecord_DrainEventRingAtTakeEnd
;          SeqRecord_TerminateTakeTracks SeqRecord_SetRecordedTracksPlaying Seq_RebuildPlayingSet T_Transport_StopAllRunning UiRequest_Post08
; Evidence: thunk slot T_SeqRecord_EndTake holds `jp 0x00F45348`, and 0xF45348 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_EndTake: Ends realtime recording: with tracks armed ((0x3000)) the current measure := (0x3610); with no
;   take begun ((0x3004) = 0) it only disarms ((0x3000)/(0x3008)/(0x300C) := 0, NoteRouting_RebuildForSong;
;   T_SeqRecord_RestoreCursorBaseline/BF4/BF8 on a cycle-record pass); after a take it closes the recorded tracks (SeqRecord_TerminateTakeTracks, or T_CycleRecord_CommitTake on
;   cycle record), merges the record mask into the playing mask (SeqRecord_SetRecordedTracksPlaying), requests the parameter restore ((0x34D2)
;   bit 0), Transport_StopAllRunning, and UiRequest_Post08 unless (0x3614) bit 1. RealtimeRecord_Disarm (T_SeqRecord_EndTake) and
;   SeqRecord_HandleTransportBStartStop call it. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
SeqRecord_EndTake:		; <- T_SeqRecord_EndTake
	ld	xwa, (12288:16)	; F45348  ld XWA,(0x3000)
	cp	xwa, 0	; F4534C  cp XWA,0x00000000
	jr	z, SeqRecord_EndTake_Skip	; F45352  jr Z,0xf4535c
	ld	wa, (13840:16)	; F45354  ld WA,(0x3610)
	ld	(13650:16), wa	; F45358  ld (0x3552),WA
SeqRecord_EndTake_Skip:
	ld	xwa, (12292:16)	; F4535C  ld XWA,(0x3004)
	cp	xwa, 0	; F45360  cp XWA,0x00000000
	jr	nz, SeqRecord_EndTake_Skip2	; F45366  jr NZ,0xf4539e
	and	(0x34d9:16), 0x79	; F45368  and (0x34d9),0x79
	and	(0x34d4:16), 0xf7	; F4536D  and (0x34d4),0xf7
	or	(0x34d0:16), 0x02	; F45372  or (0x34d0),0x02
	xor	xwa, xwa	; F45377  xor XWA,XWA
	ld	(12296:16), xwa	; F45379  ld (0x3008),XWA
	ld	(12300:16), xwa	; F4537D  ld (0x300c),XWA
	ld	(12288:16), xwa	; F45381  ld (0x3000),XWA
	call	T_NoteRouting_RebuildForSong	; F45385  call 0xf411b8
	calr	CycleRecord_CheckOnPreviousScreen	; F45389  calr 0xf44903
	cp	a, 0:i3	; F4538C  cp A,0
	jr	nz, SeqRecord_EndTake_Join2	; F4538E  jr NZ,0xf453e4
	call	T_SeqRecord_RestoreCursorBaseline	; F45390  call 0xf40c04
	call	T_CycleRecord_FreeRecordChain	; F45394  call 0xf40bf4
	call	T_SeqRecord_FreeTakeChain2	; F45398  call 0xf40bf8
	jr	SeqRecord_EndTake_Join2	; F4539C  jr T,0xf453e4
SeqRecord_EndTake_Skip2:
	calr	CycleRecord_CheckOnPreviousScreen	; F4539E  calr 0xf44903
	cp	a, 0:i3	; F453A1  cp A,0
	jr	nz, SeqRecord_EndTake_Skip3	; F453A3  jr NZ,0xf453ab
	call	T_CycleRecord_CommitTake	; F453A5  call 0xf40bf0
	jr	SeqRecord_EndTake_Join	; F453A9  jr T,0xf453b2
SeqRecord_EndTake_Skip3:
	call	T_SeqRecord_DrainEventRingAtTakeEnd	; F453AB  call 0xf40bcc
	calr	SeqRecord_TerminateTakeTracks	; F453AF  calr 0xf453e9
SeqRecord_EndTake_Join:
	and	(0x34d4:16), 0xf7	; F453B2  and (0x34d4),0xf7
	calr	SeqRecord_SetRecordedTracksPlaying	; F453B7  calr 0xf45942
	calr	Seq_RebuildPlayingSet	; F453BA  calr 0xf459d9
	xor	xwa, xwa	; F453BD  xor XWA,XWA
	ld	(12296:16), xwa	; F453BF  ld (0x3008),XWA
	or	(0x34d2:16), 0x08	; F453C3  or (0x34d2),0x08
	or	(0x34d0:16), 0x02	; F453C8  or (0x34d0),0x02
	and	(0x34d9:16), 0x79	; F453CD  and (0x34d9),0x79
	or	(0x34d2:16), 0x01	; F453D2  or (0x34d2),0x01
	call	T_Transport_StopAllRunning	; F453D7  call 0xf409ac
	bit	1, (0x3614:16)	; F453DB  bit 1,(0x3614)
	jr	nz, SeqRecord_EndTake_Join2	; F453DF  jr NZ,0xf453e4
	calr	UiRequest_Post08	; F453E1  calr 0xf46026
SeqRecord_EndTake_Join2:
	res	1, (0x3614:16)	; F453E4  res 1,(0x3614)
	ret	; F453E8  ret

; --------------------------------------------------------------------------
; SeqRecord_TerminateTakeTracks
; Called from: in-module: 0xF453AF 0xF45D15
; Touches: (0x3004) (0x3006) (0x349F)
; Calls:   T_SeqRecord_LoadTakeCursor_Veneer SeqRecord_TerminateTrackAtCursor T_SeqRecord_SaveTakeCursor_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF453E9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_TerminateTakeTracks: For each track 0..16 set in the take mask (0x3004)/(0x3006): T_SeqRecord_LoadTakeCursor_Veneer, SeqRecord_TerminateTrackAtCursor
;   (writes a 0x81 beat mark and the 0x82 end tag at the cursor and saves the cursor as the track's directory entry
;   0x60347E/0x6034A0) and T_SeqRecord_SaveTakeCursor_Veneer with C = the track. The pass SeqRecord_TerminateTracksIfRecording runs when
;   recording; SeqRecord_EndTake runs it too. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SeqRecord_TerminateTakeTracks:
	ld	(13471:16), 0	; F453E9  ld (0x349f),0x00
SeqRecord_TerminateTakeTracks_Loop:
	ld	c, (13471:16)	; F453EE  ld C,(0x349f)
	cp	c, 16	; F453F2  cp C,0x10
	jr	nc, SeqRecord_TerminateTakeTracks_Skip	; F453F5  jr NC,0xf45404
	ld	iz, (12292:16)	; F453F7  ld IZ,(0x3004)
	ld	a, c	; F453FB  ld A,C
	scf	; F453FD  scf
	xorcf_a_16	iz	; F453FE  xorcf A,IZ
	jr	c, SeqRecord_TerminateTakeTracks_Skip2	; F45400  jr C,0xf45421
	jr	SeqRecord_TerminateTakeTracks_Join	; F45402  jr T,0xf45412
SeqRecord_TerminateTakeTracks_Skip:
	ld	iz, (12294:16)	; F45404  ld IZ,(0x3006)
	ld	a, c	; F45408  ld A,C
	sub	a, 16	; F4540A  sub A,0x10
	scf	; F4540D  scf
	xorcf_a_16	iz	; F4540E  xorcf A,IZ
	jr	c, SeqRecord_TerminateTakeTracks_Skip2	; F45410  jr C,0xf45421
SeqRecord_TerminateTakeTracks_Join:
	call	T_SeqRecord_LoadTakeCursor_Veneer	; F45412  call 0xf40bc0
	calr	SeqRecord_TerminateTrackAtCursor	; F45416  calr 0xf458fe
	ld	c, (13471:16)	; F45419  ld C,(0x349f)
	call	T_SeqRecord_SaveTakeCursor_Veneer	; F4541D  call 0xf40bc4
SeqRecord_TerminateTakeTracks_Skip2:
	inc	1, (13471:16)	; F45421  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F45425  cp (0x349f),0x11
	jr	c, SeqRecord_TerminateTakeTracks_Loop	; F4542A  jr C,0xf453ee
	ret	; F4542C  ret

; --------------------------------------------------------------------------
; Seq_RequestRewind
; Called from: T_Seq_RequestRewind (x24); in-module: 0xF440E6
; Touches: (0x34D3)  |  0x000000
; Evidence: thunk slot T_Seq_RequestRewind holds `jp 0x00F4542D`, and 0xF4542D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RequestRewind: If any track plays ((0x60341E) non-zero) and transport B is stopped, sets (0x34D3) bit 0; the
;   sequencer tick (Seq_MainLoopService -> Seq_RewindOnRequest) consumes it and moves to the cycle start measure or calls
;   Seq_RewindToStart. Called after the song changes: edit-job OnLeave handlers, song load, SMF read. Basis: callers +
;   body + consumer. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
Seq_RequestRewind:		; <- T_Seq_RequestRewind
	ld	xwa, (6304798:24)	; F4542D  ld XWA,(0x60341e)
	cp	xwa, 0	; F45432  cp XWA,0x00000000
	jr	z, Seq_RequestRewind_Return	; F45438  jr Z,0xf45444
	bit	2, (TransportB_State:8)	; F4543A  bit 2,(0x96)
	jr	nz, Seq_RequestRewind_Return	; F4543D  jr NZ,0xf45444
	or	(0x34d3:16), 0x01	; F4543F  or (0x34d3),0x01
Seq_RequestRewind_Return:
	ret	; F45444  ret

; --------------------------------------------------------------------------
; Seq_RewindOnMidiStart
; Called from: T_Seq_RewindOnMidiStart (x1)
; Touches: (0x34D0)  |  0x000000
; Calls:   Seq_RewindToStart
; Evidence: thunk slot T_Seq_RewindOnMidiStart holds `jp 0x00F45445`, and 0xF45445 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RewindOnMidiStart: When tracks play ((0x60341E) non-zero) Seq_RewindToStart; then clears (0x34D0) bit 5, the
;   flag MIDI_RT_Start sets on a received MIDI Start (0xFA). TimedEvents_Service runs it, followed by
;   MIDI_Clock_CatchUpIfAnySlot, whenever it finds that bit set. Basis: caller + body + the flag's setter.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
Seq_RewindOnMidiStart:		; <- T_Seq_RewindOnMidiStart
	ld	xwa, (6304798:24)	; F45445  ld XWA,(0x60341e)
	cp	xwa, 0	; F4544A  cp XWA,0x00000000
	jr	z, Seq_RewindOnMidiStart_Skip	; F45450  jr Z,0xf45455
	calr	Seq_RewindToStart	; F45452  calr 0xf45b1f
Seq_RewindOnMidiStart_Skip:
	and	(0x34d0:16), 0xdf	; F45455  and (0x34d0),0xdf
	ret	; F4545A  ret

; --------------------------------------------------------------------------
; Seq_StopAll_Call
; Called from: T_Seq_StopAll_Call (x0)
; Touches: nothing with an absolute address
; Calls:   Seq_StopAll
; Evidence: thunk slot T_Seq_StopAll_Call holds `jp 0x00F4545B`, and 0xF4545B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_StopAll_Call: calls Seq_StopAll and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
Seq_StopAll_Call:		; <- T_Seq_StopAll_Call
	calr	Seq_StopAll	; F4545B  calr 0xf455cc
	ret	; F4545E  ret

; --------------------------------------------------------------------------
; BStore_TrackToPart_SaveBackup
; Called from: T_BStore_TrackToPart_SaveBackup (x1)
; Touches: nothing with an absolute address
; Calls:   BStore_TrackToPart_CopyToBackup
; Evidence: thunk slot T_BStore_TrackToPart_SaveBackup holds `jp 0x00F4545F`, and 0xF4545F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_TrackToPart_SaveBackup: `calr` to BStore_TrackToPart_CopyToBackup (+ `ret`), which copies the 17-byte BStore_TrackToPart map
;   (0x603422) to its backup at 0x34BC (`ldir`, XIX = 0x34BC destination, XIY = 0x603422 source). Slot T_BStore_TrackToPart_SaveBackup;
;   MidiFileDirectPlay_SaveTrackToPartMap calls it with registers saved. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
BStore_TrackToPart_SaveBackup:		; <- T_BStore_TrackToPart_SaveBackup
	calr	BStore_TrackToPart_CopyToBackup	; F4545F  calr 0xf45463
	ret	; F45462  ret

; --------------------------------------------------------------------------
; BStore_TrackToPart_CopyToBackup
; Called from: in-module: 0xF4545F
; Touches:   |  0x0034BC 0x603422
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45463 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_TrackToPart_CopyToBackup: Copies the 17-byte BStore_TrackToPart map (0x603422) to its backup at 0x34BC (ldir,
;   C = 17). The whole body of BStore_TrackToPart_SaveBackup (calr + ret). Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_a11.json)
BStore_TrackToPart_CopyToBackup:
	ld	xix, 13500	; F45463  ld XIX,0x000034bc
	ld	xiy, BStore_TrackToPart	; F45468  ld XIY,0x00603422
	xor	bc, bc	; F4546D  xor BC,BC
	ld	c, 17:opc	; F4546F  ld C,0x11
	ldir85	; F45471  ldir
	ret	; F45473  ret

; --------------------------------------------------------------------------
; BStore_TrackToPart_RestoreBackup
; Called from: T_BStore_TrackToPart_RestoreBackup (x1)
; Touches: nothing with an absolute address
; Calls:   BStore_TrackToPart_CopyFromBackup
; Evidence: thunk slot T_BStore_TrackToPart_RestoreBackup holds `jp 0x00F45474`, and 0xF45474 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_TrackToPart_RestoreBackup: `calr` to BStore_TrackToPart_CopyFromBackup (+ `ret`), which copies the 17-byte backup at 0x34BC back
;   into BStore_TrackToPart (0x603422) (`ldir`, XIX = 0x603422 destination). Slot T_BStore_TrackToPart_RestoreBackup;
;   MidiFileDirectPlay_RestoreTrackToPartMap calls it; inverse of BStore_TrackToPart_SaveBackup. Basis: caller + body
;   + inverse. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
BStore_TrackToPart_RestoreBackup:		; <- T_BStore_TrackToPart_RestoreBackup
	calr	BStore_TrackToPart_CopyFromBackup	; F45474  calr 0xf45478
	ret	; F45477  ret

; --------------------------------------------------------------------------
; BStore_TrackToPart_CopyFromBackup
; Called from: in-module: 0xF45474
; Touches:   |  0x0034BC 0x603422
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45478 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_TrackToPart_CopyFromBackup: Copies the 17-byte backup at 0x34BC back into BStore_TrackToPart (0x603422)
;   (ldir, C = 17); inverse of BStore_TrackToPart_CopyToBackup and the whole body of BStore_TrackToPart_RestoreBackup.
;   Basis: caller + body + inverse. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
BStore_TrackToPart_CopyFromBackup:
	ld	xiy, 13500	; F45478  ld XIY,0x000034bc
	ld	xix, BStore_TrackToPart	; F4547D  ld XIX,0x00603422
	xor	bc, bc	; F45482  xor BC,BC
	ld	c, 17:opc	; F45484  ld C,0x11
	ldir85	; F45486  ldir
	ret	; F45488  ret

; --------------------------------------------------------------------------
; Seq_RestoreTrackMaskAndRewind
; Called from: T_Seq_RestoreTrackMaskAndRewind (x2)
; Touches: (0x3010)  |  0x000000
; Calls:   T_F40CB4 Seq_RewindToStart T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_Seq_RestoreTrackMaskAndRewind holds `jp 0x00F45489`, and 0xF45489 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RestoreTrackMaskAndRewind: Song track mask (0x60341E) := the copy in (0x3010) that Seq_SaveTrackMaskAndStopAll saved; when non-
;   zero, Seq_RewindToStart and NoteRouting_RebuildForSong. The Leave half of screen 0xF43040 (via
;   BStore_AppendBytes_Join4_Veneer, which then clears (0x34BB) b2); its Enter half saves the mask and stops
;   transports. Basis: callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
Seq_RestoreTrackMaskAndRewind:		; <- T_Seq_RestoreTrackMaskAndRewind
	ld	xwa, (12304:16)	; F45489  ld XWA,(0x3010)
	ld	(6304798:24), xwa	; F4548D  ld (0x60341e),XWA
	call	T_F40CB4	; F45492  call 0xf40cb4
	cp	xwa, 0	; F45496  cp XWA,0x00000000
	jr	z, sub_F45478_Return	; F4549C  jr Z,0xf454a5
	calr	Seq_RewindToStart	; F4549E  calr 0xf45b1f
	call	T_NoteRouting_RebuildForSong	; F454A1  call 0xf411b8
sub_F45478_Return:
	ret	; F454A5  ret

; --------------------------------------------------------------------------
; Seq_SaveTrackMaskAndStopAll
; Called from: T_Seq_SaveTrackMaskAndStopAll (x2)
; Touches: (0x3010)
; Calls:   Seq_StopAll
; Evidence: thunk slot T_Seq_SaveTrackMaskAndStopAll holds `jp 0x00F454A6`, and 0xF454A6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_SaveTrackMaskAndStopAll: (0x3010) := the playing-track mask (0x60341E), then Seq_StopAll:
;   Transport_StopAllRunning, (0x3008)/(0x300C) := 0, TimedEventRing_Discard, (0x34D2) bit 1, (0xA8) := 0. Reached
;   from ModeEnter_Edit; the leave path's Seq_RestoreTrackMaskAndRewind (T_Seq_RestoreTrackMaskAndRewind) restores the mask from (0x3010) and rewinds. Basis:
;   caller chain + body + undo twin. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
Seq_SaveTrackMaskAndStopAll:		; <- T_Seq_SaveTrackMaskAndStopAll
	ld	xwa, (6304798:24)	; F454A6  ld XWA,(0x60341e)
	ld	(12304:16), xwa	; F454AB  ld (0x3010),XWA
	calr	Seq_StopAll	; F454AF  calr 0xf455cc
	ret	; F454B2  ret

; --------------------------------------------------------------------------
; sub_F454B3
; Called from: T_F40A50 (x0); in-module: 0xF44F5D 0xF45036
; Touches: (0x33DA) (0x33DB) (0x33DC) (0x349F)  |  0x003015 0x003038
; Calls:   T_F40B58
; Evidence: thunk slot T_F40A50 holds `jp 0x00F454B3`, and 0xF454B3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F454B3:		; <- T_F40A50
	push	xhl	; F454B3  push XHL
	pushw	iy	; F454B4  push IY
	pushw	bc	; F454B5  push BC
	xor	iy, iy	; F454B6  xor IY,IY
	xor	bc, bc	; F454B8  xor BC,BC
	ld	c, (13471:16)	; F454BA  ld C,(0x349f)
	ld	iy, bc	; F454BE  ld IY,BC
	sla	iy, 1	; F454C0  sla 0x01,IY
	ld	xhl, 12344	; F454C3  ld XHL,0x00003038
	ld	c, (xhl+iy)	; F454C8  ld C,(XHL+IY)
	cp	c, 0:i3	; F454CD  cp C,0
	jr	z, sub_F454B3_Epilogue	; F454CF  jr Z,0xf45520
	ld	(13274:16), c	; F454D1  ld (0x33da),C
	ld	(xhl+iy), 0x00	; F454D5  ld (XHL+IY),0x00
	ld	xiz, xhl	; F454DB  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F454DD  lda XIZ,XIZ+IY
	ld	c, (xiz+1)	; F454E2  ld C,(XIZ+0x01)
	ld	(13275:16), c	; F454E5  ld (0x33db),C
	ld	(xiz+1), 0	; F454E9  ld (XIZ+0x01),0x00
	ld	xhl, 12309	; F454ED  ld XHL,0x00003015
	ld	c, (xhl)	; F454F2  ld C,(XHL)
	ld	(13276:16), c	; F454F4  ld (0x33dc),C
	ld	c, (13274:16)	; F454F8  ld C,(0x33da)
	ld	(xhl), c	; F454FC  ld (XHL),C
	xor	hl, hl	; F454FE  xor HL,HL
	ld	l, (13276:16)	; F45500  ld L,(0x33dc)
	call	T_F40B58	; F45504  call 0xf40b58
	ld	c, (13275:16)	; F45508  ld C,(0x33db)
	ld	(xhl+4), c	; F4550C  ld (XHL+0x04),C
	xor	hl, hl	; F4550F  xor HL,HL
	ld	l, (13275:16)	; F45511  ld L,(0x33db)
	call	T_F40B58	; F45515  call 0xf40b58
	ld	c, (13276:16)	; F45519  ld C,(0x33dc)
	ld	(xhl+5), c	; F4551D  ld (XHL+0x05),C
sub_F454B3_Epilogue:
	popw	bc	; F45520  pop BC
	popw	iy	; F45521  pop IY
	pop	xhl	; F45522  pop XHL
	ret	; F45523  ret

; --------------------------------------------------------------------------
; TimedEvents_ClearEndedTrackBits
; Called from: T_TimedEvents_ClearEndedTrackBits (x1)
; Touches: (0x3008) (0x300A) (0x349A) (0x349C)  |  0x600800
; Calls:   T_TimedEventRing_ReadNext_Veneer T_TimedEventRing_SkipByte_Veneer
; Evidence: thunk slot T_TimedEvents_ClearEndedTrackBits holds `jp 0x00F45524`, and 0xF45524 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TimedEvents_ClearEndedTrackBits: Class-3 consumer of TimedEvents_DispatchDueRun (status 0x82, the block store's end-
;   of-chain tag): for each {0x82, n} in the run clears bit n of (0x3008)/(0x300A) and of (0x349A)/(0x349C) (n >= 16
;   in the second word), until the run end (ring+4); a run not starting with 0x82 is skipped (read index := run end).
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
TimedEvents_ClearEndedTrackBits:		; <- T_TimedEvents_ClearEndedTrackBits
	push	xwa	; F45524  push XWA
	push	xbc	; F45525  push XBC
	push	xde	; F45526  push XDE
	push	xhl	; F45527  push XHL
	push	xix	; F45528  push XIX
	push	xiy	; F45529  push XIY
	push	xiz	; F4552A  push XIZ
	ld	xhl, 6293504	; F4552B  ld XHL,0x00600800
sub_F454B3_Loop:
	call	T_TimedEventRing_ReadNext_Veneer	; F45530  call 0xf40c7c
	cp	a, 130	; F45534  cp A,0x82
	jr	nz, sub_F454B3_Skip3	; F45537  jr NZ,0xf45592
	call	T_TimedEventRing_SkipByte_Veneer	; F45539  call 0xf40c80
	call	T_TimedEventRing_ReadNext_Veneer	; F4553D  call 0xf40c7c
	ld	c, a	; F45541  ld C,A
	cp	c, 16	; F45543  cp C,0x10
	jr	nc, sub_F454B3_Skip	; F45546  jr NC,0xf45557
	ld	iz, (12296:16)	; F45548  ld IZ,(0x3008)
	ld	a, c	; F4554C  ld A,C
	rcf	; F4554E  rcf
	stcf_a_16	iz	; F4554F  stcf A,IZ
	ld	(12296:16), iz	; F45551  ld (0x3008),IZ
	jr	sub_F454B3_Join	; F45555  jr T,0xf45567
sub_F454B3_Skip:
	ld	iz, (12298:16)	; F45557  ld IZ,(0x300a)
	ld	a, c	; F4555B  ld A,C
	sub	a, 16	; F4555D  sub A,0x10
	rcf	; F45560  rcf
	stcf_a_16	iz	; F45561  stcf A,IZ
	ld	(12298:16), iz	; F45563  ld (0x300a),IZ
sub_F454B3_Join:
	cp	c, 16	; F45567  cp C,0x10
	jr	nc, sub_F454B3_Skip2	; F4556A  jr NC,0xf4557b
	ld	iz, (13466:16)	; F4556C  ld IZ,(0x349a)
	ld	a, c	; F45570  ld A,C
	rcf	; F45572  rcf
	stcf_a_16	iz	; F45573  stcf A,IZ
	ld	(13466:16), iz	; F45575  ld (0x349a),IZ
	jr	sub_F454B3_Join2	; F45579  jr T,0xf4558b
sub_F454B3_Skip2:
	ld	iz, (13468:16)	; F4557B  ld IZ,(0x349c)
	ld	a, c	; F4557F  ld A,C
	sub	a, 16	; F45581  sub A,0x10
	rcf	; F45584  rcf
	stcf_a_16	iz	; F45585  stcf A,IZ
	ld	(13468:16), iz	; F45587  ld (0x349c),IZ
sub_F454B3_Join2:
	cp	iy, (xhl+4)	; F4558B  cp IY,(XHL+0x04)
	jr	nz, sub_F454B3_Loop	; F4558E  jr NZ,0xf45530
	jr	sub_F454B3_Epilogue2	; F45590  jr T,0xf45598
sub_F454B3_Skip3:
	ld	wa, (xhl+4)	; F45592  ld WA,(XHL+0x04)
	ld	(xhl+2), wa	; F45595  ld (XHL+0x02),WA
sub_F454B3_Epilogue2:
	pop	xiz	; F45598  pop XIZ
	pop	xiy	; F45599  pop XIY
	pop	xix	; F4559A  pop XIX
	pop	xhl	; F4559B  pop XHL
	pop	xde	; F4559C  pop XDE
	pop	xbc	; F4559D  pop XBC
	pop	xwa	; F4559E  pop XWA
	ret	; F4559F  ret

; --------------------------------------------------------------------------
; Sequencer_ResetToDefault
; Called from: T_Sequencer_ResetToDefault (x2)
; Touches: (0x7EE2)
; Calls:   BStore_ResetWorkspaceToDefault BStore_CopyWorkspaceToAllBanks T_Queue2E00_AppendRegs T_Tempo_ApplyBpm
; Evidence: thunk slot T_Sequencer_ResetToDefault holds `jp 0x00F455A0`, and 0xF455A0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Sequencer_ResetToDefault: what INITIAL item 6 SEQUENCER runs (screen and SysEx): block store reset, tempo 120 (notes/FINDINGS-prom_a-initial.md)
Sequencer_ResetToDefault:		; <- T_Sequencer_ResetToDefault
	calr	BStore_ResetWorkspaceToDefault	; F455A0  calr 0xf44260
	ld	(6304982:24), 0	; F455A3  ld (0x6034d6),0x00
	calr	BStore_CopyWorkspaceToAllBanks	; F455A9  calr 0xf440a0
	ldw	wa, 120	; F455AC  ld WA,0x0078
	ld	e, 122:opc	; F455AF  ld E,0x7a
	ld	d, 0:opc	; F455B1  ld D,0x00
	ld	w, 255:opc	; F455B3  ld W,0xff
	call	T_Queue2E00_AppendRegs	; F455B5  call 0xf40f3c
	ldw	wa, 120	; F455B9  ld WA,0x0078
	ld	(32482:16), wa	; F455BC  ld (0x7ee2),WA
	call	T_Tempo_ApplyBpm	; F455C0  call 0xf40794
	ret	; F455C4  ret

; --------------------------------------------------------------------------
; sub_F455C5
; Called from: T_F40A20 (x3)
; Touches: nothing with an absolute address
; Calls:   SeqMasterTrack_UpdateActive Seq_StopAll
; Evidence: thunk slot T_F40A20 holds `jp 0x00F455C5`, and 0xF455C5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F455C5:		; <- T_F40A20
	calr	SeqMasterTrack_UpdateActive	; F455C5  calr 0xf455e6
	calr	Seq_StopAll	; F455C8  calr 0xf455cc
	ret	; F455CB  ret

; --------------------------------------------------------------------------
; Seq_StopAll
; Called from: in-module: 0xF4545B 0xF454AF 0xF455C8
; Touches: (0x3008) (0x300C) (0x34D2)
; Calls:   T_Transport_StopAllRunning TimedEventRing_Discard
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF455CC is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_StopAll: Stops every transport (T_Transport_StopAllRunning), zeroes the track-data masks (0x3008)/(0x300C),
;   discards the timed-event ring, posts the playback-stop request (0x34D2) bit 1 that Seq_StopPlaybackOnRequest
;   consumes, and (0xA8) := 0. The 'StopAll' of Seq_SaveTrackMaskAndStopAll (ModeEnter_Edit), also reached through the
;   slots T_Seq_StopAll_Veneer, T_Seq_StopAll_Call and T_F40A20. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
Seq_StopAll:
	call	T_Transport_StopAllRunning	; F455CC  call 0xf409ac
	xor	xwa, xwa	; F455D0  xor XWA,XWA
	ld	(12296:16), xwa	; F455D2  ld (0x3008),XWA
	ld	(12300:16), xwa	; F455D6  ld (0x300c),XWA
	calr	TimedEventRing_Discard	; F455DA  calr 0xf45b0a
	or	(0x34d2:16), 0x02	; F455DD  or (0x34d2),0x02
	ld	(168:8), 0:io	; F455E2  ld (0xa8),0x00
	ret	; F455E5  ret

; --------------------------------------------------------------------------
; SeqMasterTrack_UpdateActive
; Called from: T_SeqMasterTrack_UpdateActive (x5); in-module: 0xF446D5 0xF455C5 0xF45C18 0xF45CD1
; Touches: (0x0C8A) (0x0E4F) (0x0E51) (0x3752)  |  0x603422 0x603500
; Evidence: thunk slot T_SeqMasterTrack_UpdateActive holds `jp 0x00F455E6`, and 0xF455E6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqMasterTrack_UpdateActive: Finds the track whose BStore_TrackToPart entry is 0x20 (the master track's part; the
;   identity map gives it to track 17); if it is in the song's track mask, MASTER is ON ((0x3752) = 1) and its
;   directory entry is in use: (0x0E51) := track + 1, (0x0E4F) |= 1, (0x0C8A) |= 4; otherwise those bits cleared and W
;   = 0. Called by Seq_LocateToSongPosition, the measure locate Seq_LocateToCurrentMeasure and the edit seeks (T_SeqMasterTrack_UpdateActive). Basis:
;   caller + body + flag owners. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
SeqMasterTrack_UpdateActive:		; <- T_SeqMasterTrack_UpdateActive
	ld	xix, BStore_TrackToPart	; F455E6  ld XIX,0x00603422
	xor	bc, bc	; F455EB  xor BC,BC
	ld	c, 17:opc	; F455ED  ld C,0x11
	ld	a, 32:opc	; F455EF  ld A,0x20
	cp	a, (xix+)	; F455F1  cp A,(XIX+)
	jr	z, SeqMasterTrack_UpdateActive_Skip	; F455F4  jr Z,0xf455fb
	djnz16	bc, -8	; F455F6  djnz BC,0xf455f1
	jr	SeqMasterTrack_UpdateActive_Join3	; F455F9  jr T,0xf4565d
SeqMasterTrack_UpdateActive_Skip:
	xor	wa, wa	; F455FB  xor WA,WA
	ld	a, 17:opc	; F455FD  ld A,0x11
	sub	wa, bc	; F455FF  sub WA,BC
	ld	c, a	; F45601  ld C,A
	cp	c, 16	; F45603  cp C,0x10
	jr	nc, SeqMasterTrack_UpdateActive_Skip2	; F45606  jr NC,0xf45618
	pushw	wa	; F45608  push WA
	ld	iz, (6304798:24)	; F45609  ld IZ,(0x60341e)
	ld	a, c	; F4560E  ld A,C
	scf	; F45610  scf
	xorcf_a_16	iz	; F45611  xorcf A,IZ
	popw	wa	; F45613  pop WA
	jr	c, SeqMasterTrack_UpdateActive_Join3	; F45614  jr C,0xf4565d
	jr	SeqMasterTrack_UpdateActive_Join	; F45616  jr T,0xf45629
SeqMasterTrack_UpdateActive_Skip2:
	pushw	wa	; F45618  push WA
	ld	iz, (6304800:24)	; F45619  ld IZ,(0x603420)
	ld	a, c	; F4561E  ld A,C
	sub	a, 16	; F45620  sub A,0x10
	scf	; F45623  scf
	xorcf_a_16	iz	; F45624  xorcf A,IZ
	popw	wa	; F45626  pop WA
	jr	c, SeqMasterTrack_UpdateActive_Join3	; F45627  jr C,0xf4565d
SeqMasterTrack_UpdateActive_Join:
	cp	(0x3752:16), 0x01	; F45629  cp (0x3752),0x01
	jr	nz, SeqMasterTrack_UpdateActive_Join3	; F4562E  jr NZ,0xf4565d
	pushw	wa	; F45630  push WA
	ld	xhl, 6305024	; F45631  ld XHL,0x00603500
	ld	c, 3:opc	; F45636  ld C,0x03
	mul	wa, c	; F45638  mul WA,C
	ld	iy, wa	; F4563A  ld IY,WA
	bit	7, (xhl+iy)	; F4563C  bit 7,(XHL+IY)
	jr	z, SeqMasterTrack_UpdateActive_Skip3	; F45641  jr Z,0xf45646
	popw	wa	; F45643  pop WA
	jr	SeqMasterTrack_UpdateActive_Join2	; F45644  jr T,0xf45649
SeqMasterTrack_UpdateActive_Skip3:
	popw	wa	; F45646  pop WA
	jr	SeqMasterTrack_UpdateActive_Join3	; F45647  jr T,0xf4565d
SeqMasterTrack_UpdateActive_Join2:
	inc	1, a	; F45649  inc 1,A
	ld	w, a	; F4564B  ld W,A
	ld	(3665:16), w	; F4564D  ld (0x0e51),W
	or	(0x0e4f:16), 0x01	; F45651  or (0x0e4f),0x01
	or	(0x0c8a:16), 0x04	; F45656  or (0x0c8a),0x04
	jr	SeqMasterTrack_UpdateActive_Return	; F4565B  jr T,0xf45669
SeqMasterTrack_UpdateActive_Join3:
	and	(0x0e4f:16), 0xfe	; F4565D  and (0x0e4f),0xfe
	and	(0x0c8a:16), 0xfb	; F45662  and (0x0c8a),0xfb
	xor	w, w	; F45667  xor W,W
SeqMasterTrack_UpdateActive_Return:
	ret	; F45669  ret

; --------------------------------------------------------------------------
; SeqMasterTrack_UpdateActiveFromSavedMask
; Called from: T_SeqMasterTrack_UpdateActiveFromSavedMask (x1)
; Touches: (0x0C8A) (0x0E4F) (0x0E51) (0x360C) (0x360E) (0x3752)  |
;          0x603422 0x603500
; Evidence: thunk slot T_SeqMasterTrack_UpdateActiveFromSavedMask holds `jp 0x00F4566A`, and 0xF4566A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqMasterTrack_UpdateActiveFromSavedMask: SeqMasterTrack_UpdateActive with the SAVED playing-track mask
;   (0x360C)/(0x360E) instead of (0x60341E): finds the track mapped to part 0x20 in BStore_TrackToPart; if its bit is
;   set there, MASTER is ON ((0x3752) = 1) and its directory entry is in use, W := track + 1, (0x0E51) := W, (0x0E4F)
;   |= 1, (0x0C8A) |= 4; otherwise those bits cleared and W = 0. Run by EditScreen_FindMasterTrack. Basis: caller +
;   body + twin. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SeqMasterTrack_UpdateActiveFromSavedMask:		; <- T_SeqMasterTrack_UpdateActiveFromSavedMask
	ld	xix, BStore_TrackToPart	; F4566A  ld XIX,0x00603422
	xor	bc, bc	; F4566F  xor BC,BC
	ld	c, 17:opc	; F45671  ld C,0x11
	ld	a, 32:opc	; F45673  ld A,0x20
	cp	a, (xix+)	; F45675  cp A,(XIX+)
	jr	z, SeqMasterTrack_UpdateActiveFromSavedMask_Skip4	; F45678  jr Z,0xf4567f
	djnz16	bc, -8	; F4567A  djnz BC,0xf45675
	jr	SeqMasterTrack_UpdateActiveFromSavedMask_Join6	; F4567D  jr T,0xf456df
SeqMasterTrack_UpdateActiveFromSavedMask_Skip4:
	xor	wa, wa	; F4567F  xor WA,WA
	ld	a, 17:opc	; F45681  ld A,0x11
	sub	wa, bc	; F45683  sub WA,BC
	ld	c, a	; F45685  ld C,A
	cp	c, 16	; F45687  cp C,0x10
	jr	nc, SeqMasterTrack_UpdateActiveFromSavedMask_Skip5	; F4568A  jr NC,0xf4569b
	pushw	wa	; F4568C  push WA
	ld	iz, (13836:16)	; F4568D  ld IZ,(0x360c)
	ld	a, c	; F45691  ld A,C
	scf	; F45693  scf
	xorcf_a_16	iz	; F45694  xorcf A,IZ
	popw	wa	; F45696  pop WA
	jr	c, SeqMasterTrack_UpdateActiveFromSavedMask_Join6	; F45697  jr C,0xf456df
	jr	SeqMasterTrack_UpdateActiveFromSavedMask_Join4	; F45699  jr T,0xf456ab
SeqMasterTrack_UpdateActiveFromSavedMask_Skip5:
	pushw	wa	; F4569B  push WA
	ld	iz, (13838:16)	; F4569C  ld IZ,(0x360e)
	ld	a, c	; F456A0  ld A,C
	sub	a, 16	; F456A2  sub A,0x10
	scf	; F456A5  scf
	xorcf_a_16	iz	; F456A6  xorcf A,IZ
	popw	wa	; F456A8  pop WA
	jr	c, SeqMasterTrack_UpdateActiveFromSavedMask_Join6	; F456A9  jr C,0xf456df
SeqMasterTrack_UpdateActiveFromSavedMask_Join4:
	cp	(0x3752:16), 0x01	; F456AB  cp (0x3752),0x01
	jr	nz, SeqMasterTrack_UpdateActiveFromSavedMask_Join6	; F456B0  jr NZ,0xf456df
	pushw	wa	; F456B2  push WA
	ld	xhl, 6305024	; F456B3  ld XHL,0x00603500
	ld	c, 3:opc	; F456B8  ld C,0x03
	mul	wa, c	; F456BA  mul WA,C
	ld	iy, wa	; F456BC  ld IY,WA
	bit	7, (xhl+iy)	; F456BE  bit 7,(XHL+IY)
	jr	z, SeqMasterTrack_UpdateActiveFromSavedMask_Skip6	; F456C3  jr Z,0xf456c8
	popw	wa	; F456C5  pop WA
	jr	SeqMasterTrack_UpdateActiveFromSavedMask_Join5	; F456C6  jr T,0xf456cb
SeqMasterTrack_UpdateActiveFromSavedMask_Skip6:
	popw	wa	; F456C8  pop WA
	jr	SeqMasterTrack_UpdateActiveFromSavedMask_Join6	; F456C9  jr T,0xf456df
SeqMasterTrack_UpdateActiveFromSavedMask_Join5:
	inc	1, a	; F456CB  inc 1,A
	ld	w, a	; F456CD  ld W,A
	ld	(3665:16), w	; F456CF  ld (0x0e51),W
	or	(0x0e4f:16), 0x01	; F456D3  or (0x0e4f),0x01
	or	(0x0c8a:16), 0x04	; F456D8  or (0x0c8a),0x04
	jr	SeqMasterTrack_UpdateActiveFromSavedMask_Return2	; F456DD  jr T,0xf456eb
SeqMasterTrack_UpdateActiveFromSavedMask_Join6:
	and	(0x0e4f:16), 0xfe	; F456DF  and (0x0e4f),0xfe
	and	(0x0c8a:16), 0xfb	; F456E4  and (0x0c8a),0xfb
	xor	w, w	; F456E9  xor W,W
SeqMasterTrack_UpdateActiveFromSavedMask_Return2:
	ret	; F456EB  ret

; --------------------------------------------------------------------------
; SeqRecord_StartOnFirstEvent
; Called from: T_SeqRecord_StartOnFirstEvent (x2)
; Touches: nothing with an absolute address
; Calls:   SeqRecord_StartIfEventQueued
; Evidence: thunk slot T_SeqRecord_StartOnFirstEvent holds `jp 0x00F456EC`, and 0xF456EC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_StartOnFirstEvent: SeqRecord_StartIfEventQueued: when no track plays, tracks are armed ((0x3000) != 0), transport B is idle,
;   recording has not begun ((0x3004) == 0) and the sequencer buffer ring holds an event: SeqRecord_BeginTake starts the take
;   ((0x3004) := (0x3000)), then beat/tick := 0 and T_Transport_StartAllFromZero. Called by the event encoders' tail
;   after an event is queued. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
SeqRecord_StartOnFirstEvent:		; <- T_SeqRecord_StartOnFirstEvent
	calr	SeqRecord_StartIfEventQueued	; F456EC  calr 0xf456f0
	ret	; F456EF  ret

; --------------------------------------------------------------------------
; SeqRecord_StartIfEventQueued
; Called from: in-module: 0xF456EC
; Touches: (0x3000) (0x3004) (0x34D4) (0x3614) (0x7F32)  |  0x000000
; Calls:   T_SeqBufRing_IsEmpty SeqRecord_BeginTake Var20A9_SetBits01 T_Transport_StartAllFromZero Transport_PromoteStartsToRunning
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF456F0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_StartIfEventQueued: The body behind the SeqRecord_StartOnFirstEvent stub: when no track plays ((0x60341E)
;   = 0), tracks are armed ((0x3000) != 0), transport B is idle ((0x96) & 5 = 0), no take has begun ((0x3004) = 0) and
;   SeqBufRing holds an event, SeqRecord_BeginTake starts the take; if (0x3004) is then set: Var20A9_SetBits01, (0x3614) bit 0,
;   beat/tick := 0 under ei 6, T_Transport_StartAllFromZero, and Transport_PromoteStartsToRunning when MidiCfg_ModeBits bit 2. Basis: caller
;   + body. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
SeqRecord_StartIfEventQueued:
	ld	xwa, (6304798:24)	; F456F0  ld XWA,(0x60341e)
	cp	xwa, 0	; F456F5  cp XWA,0x00000000
	jr	nz, SeqRecord_StartIfEventQueued_Return	; F456FB  jr NZ,0xf45760
	ld	xwa, (12288:16)	; F456FD  ld XWA,(0x3000)
	cp	xwa, 0	; F45701  cp XWA,0x00000000
	jr	z, SeqRecord_StartIfEventQueued_Return	; F45707  jr Z,0xf45760
	ld	a, (TransportB_State:8)	; F45709  ld A,(0x96)
	and	a, 5	; F4570C  and A,0x05
	jr	z, SeqRecord_StartIfEventQueued_Skip	; F4570F  jr Z,0xf45713
	jr	SeqRecord_StartIfEventQueued_Return	; F45711  jr T,0xf45760
SeqRecord_StartIfEventQueued_Skip:
	ld	xwa, (12292:16)	; F45713  ld XWA,(0x3004)
	cp	xwa, 0	; F45717  cp XWA,0x00000000
	jr	nz, SeqRecord_StartIfEventQueued_Return	; F4571D  jr NZ,0xf45760
	and	(0x34d4:16), 0xfd	; F4571F  and (0x34d4),0xfd
	call	T_SeqBufRing_IsEmpty	; F45724  call 0xf41d90
	cp	wa, 0:i3	; F45728  cp WA,0
	jr	z, SeqRecord_StartIfEventQueued_Return	; F4572A  jr Z,0xf45760
	or	(0x34d4:16), 0x02	; F4572C  or (0x34d4),0x02
	calr	SeqRecord_BeginTake	; F45731  calr 0xf45761
	ld	xwa, (12292:16)	; F45734  ld XWA,(0x3004)
	cp	xwa, 0	; F45738  cp XWA,0x00000000
	jr	z, SeqRecord_StartIfEventQueued_Return	; F4573E  jr Z,0xf45760
	calr	Var20A9_SetBits01	; F45740  calr 0xf45fae
	or	(0x3614:16), 0x01	; F45743  or (0x3614),0x01
	ei	6	; F45748  ei 0x06
	ldw	(TransportB_Beat:8), 0:io	; F4574A  ld (0x91),0x0000
	ld	(Seq_BeatTick:8), 0:io	; F4574E  ld (0x93),0x00
	ei	0	; F45751  ei 0x00
	call	T_Transport_StartAllFromZero	; F45753  call 0xf409b4
	bit	2, (MidiCfg_ModeBits:16)	; F45757  bit 2,(0x7f32)
	jr	z, SeqRecord_StartIfEventQueued_Return	; F4575B  jr Z,0xf45760
	calr	Transport_PromoteStartsToRunning	; F4575D  calr 0xf458ea
SeqRecord_StartIfEventQueued_Return:
	ret	; F45760  ret

; --------------------------------------------------------------------------
; SeqRecord_BeginTake
; Called from: in-module: 0xF44AE2 0xF45731
; Touches: (0x0C70) (0x3000) (0x3004) (0x3006) (0x349F) (0x34D0) (0x34D2)
;          (0x3552) (0x3610) (0x36D4) +2 more
; Calls:   T_CycleRecord_CheckIsRecordTrack T_BStore_ClearTrackIfInRange T_SongMemory_UpdateFreePercent SeqRecord_AllocTakeChains
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45761 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_BeginTake: Starts a realtime-record take: (0x3759) := the song's default time signature (0x6034D7),
;   (0x3610) := the current measure (1 for the count-in values 0x8001/0x8002), (0x34D2) bit 7 set, take mask (0x3004)
;   := armed mask (0x3000); for each take track except the cycle-record track, T_BStore_ClearTrackIfInRange with (0x0C70) = track + 1;
;   then SongMemory_UpdateFreePercent and SeqRecord_AllocTakeChains. SeqRecord_StartIfEventQueued ("starts the take") and
;   SeqRecord_BeginTakeOnTransportStart call it. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
SeqRecord_BeginTake:
	ld	a, (6304983:24)	; F45761  ld A,(0x6034d7)
	ld	(14169:16), a	; F45766  ld (0x3759),A
	ld	wa, (13650:16)	; F4576A  ld WA,(0x3552)
	cp	wa, 32770	; F4576E  cp WA,0x8002
	jr	z, SeqRecord_BeginTake_Skip	; F45772  jr Z,0xf4577a
	cp	wa, 32769	; F45774  cp WA,0x8001
	jr	nz, SeqRecord_BeginTake_Skip2	; F45778  jr NZ,0xf4577d
SeqRecord_BeginTake_Skip:
	ldw	wa, 1	; F4577A  ld WA,0x0001
SeqRecord_BeginTake_Skip2:
	ld	(13840:16), wa	; F4577D  ld (0x3610),WA
	or	(0x34d2:16), 0x80	; F45781  or (0x34d2),0x80
	ld	xwa, (12288:16)	; F45786  ld XWA,(0x3000)
	ld	(12292:16), xwa	; F4578A  ld (0x3004),XWA
	ld	(13471:16), 0	; F4578E  ld (0x349f),0x00
SeqRecord_BeginTake_Loop:
	call	T_CycleRecord_CheckIsRecordTrack	; F45793  call 0xf40be4
	cp	a, 0:i3	; F45797  cp A,0
	jr	z, SeqRecord_BeginTake_Skip4	; F45799  jr Z,0xf457cb
	ld	c, (13471:16)	; F4579B  ld C,(0x349f)
	cp	c, 16	; F4579F  cp C,0x10
	jr	nc, SeqRecord_BeginTake_Skip3	; F457A2  jr NC,0xf457b1
	ld	iz, (12292:16)	; F457A4  ld IZ,(0x3004)
	ld	a, c	; F457A8  ld A,C
	scf	; F457AA  scf
	xorcf_a_16	iz	; F457AB  xorcf A,IZ
	jr	c, SeqRecord_BeginTake_Skip4	; F457AD  jr C,0xf457cb
	jr	SeqRecord_BeginTake_Join	; F457AF  jr T,0xf457bf
SeqRecord_BeginTake_Skip3:
	ld	iz, (12294:16)	; F457B1  ld IZ,(0x3006)
	ld	a, c	; F457B5  ld A,C
	sub	a, 16	; F457B7  sub A,0x10
	scf	; F457BA  scf
	xorcf_a_16	iz	; F457BB  xorcf A,IZ
	jr	c, SeqRecord_BeginTake_Skip4	; F457BD  jr C,0xf457cb
SeqRecord_BeginTake_Join:
	ld	a, c	; F457BF  ld A,C
	inc	1, a	; F457C1  inc 1,A
	ld	(3184:16), a	; F457C3  ld (0x0c70),A
	call	T_BStore_ClearTrackIfInRange	; F457C7  call 0xf40c74
SeqRecord_BeginTake_Skip4:
	inc	1, (13471:16)	; F457CB  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F457CF  cp (0x349f),0x11
	jr	c, SeqRecord_BeginTake_Loop	; F457D4  jr C,0xf45793
	call	T_SongMemory_UpdateFreePercent	; F457D6  call 0xf40d00
	calr	SeqRecord_AllocTakeChains	; F457DA  calr 0xf45812
	and	(0x34d0:16), 0xf7	; F457DD  and (0x34d0),0xf7
	ld	a, (14038:16)	; F457E2  ld A,(0x36d6)
	ld	(13471:16), a	; F457E6  ld (0x349f),A
	call	T_CycleRecord_CheckIsRecordTrack	; F457EA  call 0xf40be4
	cp	a, 0:i3	; F457EE  cp A,0
	jr	z, SeqRecord_BeginTake_Return	; F457F0  jr Z,0xf45811
	cpw	(0x3552:16), 0x8001	; F457F2  cp (0x3552),0x8001
	jr	nz, SeqRecord_BeginTake_Skip5	; F457F8  jr NZ,0xf45804
	cpw	(0x36d4:16), 0x0001	; F457FA  cp (0x36d4),0x0001
	jr	z, SeqRecord_BeginTake_Skip6	; F45800  jr Z,0xf4580c
	jr	SeqRecord_BeginTake_Return	; F45802  jr T,0xf45811
SeqRecord_BeginTake_Skip5:
	cpw	(0x3552:16), 0x0001	; F45804  cp (0x3552),0x0001
	jr	nz, SeqRecord_BeginTake_Return	; F4580A  jr NZ,0xf45811
SeqRecord_BeginTake_Skip6:
	or	(0x34d0:16), 0x08	; F4580C  or (0x34d0),0x08
SeqRecord_BeginTake_Return:
	ret	; F45811  ret

; --------------------------------------------------------------------------
; SeqRecord_AllocTakeChains
; Called from: in-module: 0xF457DA
; Touches: (0x20A9) (0x3000) (0x3004) (0x3006) (0x349F) (0x34D1) (0x3608)  |
;          0x00340C 0x00342E 0x603500
; Calls:   T_CycleRecord_CheckIsRecordTrack T_BStore_AllocBlock_B_Veneer T_BStore_BlockAddrFromHL T_NoteRouting_RebuildForSong T_SeqRecord_SoundAlert_Veneer Var34D1_SetBits20
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45812 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_AllocTakeChains: Take start: for each take track (bit set in (0x3004)/(0x3006), not the cycle-record
;   track) allocates a fresh block (bit 7, prev 0, next 0xFFFF), makes it the track's directory head (entry in use)
;   and points the take cursor 0x340C[t] / 0x342E[t] at it, offset 5. Out of blocks: take cancelled ((0x3000),
;   (0x3004) := 0), routing rebuilt, memory-full posted (Var34D1_SetBits20, (0x34D1) bit 4). Last step of
;   SeqRecord_BeginTake after it cleared those tracks. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
SeqRecord_AllocTakeChains:
	ld	(13471:16), 0	; F45812  ld (0x349f),0x00
	xor	iy, iy	; F45817  xor IY,IY
	xor	ix, ix	; F45819  xor IX,IX
SeqRecord_AllocTakeChains_Loop:
	push	xiy	; F4581B  push XIY
	push	xix	; F4581C  push XIX
	call	T_CycleRecord_CheckIsRecordTrack	; F4581D  call 0xf40be4
	pop	xix	; F45821  pop XIX
	pop	xiy	; F45822  pop XIY
	cp	a, 0:i3	; F45823  cp A,0
	jrl	z, SeqRecord_AllocTakeChains_Skip2	; F45825  jrl Z,0xf458b4
	ld	c, (13471:16)	; F45828  ld C,(0x349f)
	cp	c, 16	; F4582C  cp C,0x10
	jr	nc, SeqRecord_AllocTakeChains_Skip	; F4582F  jr NC,0xf4583e
	ld	iz, (12292:16)	; F45831  ld IZ,(0x3004)
	ld	a, c	; F45835  ld A,C
	scf	; F45837  scf
	xorcf_a_16	iz	; F45838  xorcf A,IZ
	jr	c, SeqRecord_AllocTakeChains_Skip2	; F4583A  jr C,0xf458b4
	jr	SeqRecord_AllocTakeChains_Join	; F4583C  jr T,0xf4584c
SeqRecord_AllocTakeChains_Skip:
	ld	iz, (12294:16)	; F4583E  ld IZ,(0x3006)
	ld	a, c	; F45842  ld A,C
	sub	a, 16	; F45844  sub A,0x10
	scf	; F45847  scf
	xorcf_a_16	iz	; F45848  xorcf A,IZ
	jr	c, SeqRecord_AllocTakeChains_Skip2	; F4584A  jr C,0xf458b4
SeqRecord_AllocTakeChains_Join:
	cpw	(BStore_FreeCount:24), 0x0000	; F4584C  cp (0x6034ba),0x0000
	jr	z, SeqRecord_AllocTakeChains_Skip3	; F45853  jr Z,0xf458ca
	push	xiy	; F45855  push XIY
	push	xix	; F45856  push XIX
	call	T_BStore_AllocBlock_B_Veneer	; F45857  call 0xf40c88
	ld	wa, ix	; F4585B  ld WA,IX
	pop	xix	; F4585D  pop XIX
	pop	xiy	; F4585E  pop XIY
	ld	bc, (BStore_BlockCount:16)	; F4585F  ld BC,(0x3608)
	cp	wa, bc	; F45863  cp WA,BC
	jr	ugt, SeqRecord_AllocTakeChains_Skip3	; F45865  jr UGT,0xf458ca
	cp	wa, 0:i3	; F45867  cp WA,0
	jr	z, SeqRecord_AllocTakeChains_Skip3	; F45869  jr Z,0xf458ca
	pushw	wa	; F4586B  push WA
	ld	hl, wa	; F4586C  ld HL,WA
	call	T_BStore_BlockAddrFromHL	; F4586E  call 0xf40c84
	or	(xhl), 0x80	; F45872  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F45875  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F4587A  ld (XHL+0x03),0xffff
	popw	wa	; F4587F  pop WA
	ld	xhl, 6305024	; F45880  ld XHL,0x00603500
	or	(xhl+iy), 0x80	; F45885  or (XHL+IY),0x80
	ld	xiz, xhl	; F4588B  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F4588D  lda XIZ,XIZ+IY
	ld	(xiz+1), wa	; F45892  ld (XIZ+0x01),WA
	ld	xhl, 13324	; F45895  ld XHL,0x0000340c
	ld	(xhl+ix), wa	; F4589A  ld (XHL+IX),WA
	ld	xhl, 13358	; F4589F  ld XHL,0x0000342e
	xor	bc, bc	; F458A4  xor BC,BC
	ld	c, (13471:16)	; F458A6  ld C,(0x349f)
	push	xiy	; F458AA  push XIY
	ld	iy, bc	; F458AB  ld IY,BC
	ld	(xhl+iy), 0x05	; F458AD  ld (XHL+IY),0x05
	pop	xiy	; F458B3  pop XIY
SeqRecord_AllocTakeChains_Skip2:
	add	iy, 3	; F458B4  add IY,0x0003
	add	ix, 2	; F458B8  add IX,0x0002
	inc	1, (13471:16)	; F458BC  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F458C0  cp (0x349f),0x11
	jrl	c, SeqRecord_AllocTakeChains_Loop	; F458C5  jrl C,0xf4581b
	jr	SeqRecord_AllocTakeChains_Return	; F458C8  jr T,0xf458e9
SeqRecord_AllocTakeChains_Skip3:
	xor	xwa, xwa	; F458CA  xor XWA,XWA
	ld	(12288:16), xwa	; F458CC  ld (0x3000),XWA
	ld	(12292:16), xwa	; F458D0  ld (0x3004),XWA
	call	T_NoteRouting_RebuildForSong	; F458D4  call 0xf411b8
	call	T_SeqRecord_SoundAlert_Veneer	; F458D8  call 0xf40bc8
	calr	Var34D1_SetBits20	; F458DC  calr 0xf45fc4
	and	(0x20a9:16), 0xfe	; F458DF  and (0x20a9),0xfe
	or	(0x34d1:16), 0x10	; F458E4  or (0x34d1),0x10
SeqRecord_AllocTakeChains_Return:
	ret	; F458E9  ret

; --------------------------------------------------------------------------
; Transport_PromoteStartsToRunning
; Called from: in-module: 0xF4575D
; Touches: nothing with an absolute address
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF458EA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transport_PromoteStartsToRunning: TransportC_State := 6 and TransportA/B_State := 6 where bit 0 (start request) is
;   set -- the request-to-running step INTTR4_SequencerTick and _Alt make once C runs, done at once.
;   SeqRecord_StartIfEventQueued calls it after T_Transport_StartAllFromZero when MidiCfg_ModeBits bit 2 (the bit that
;   swaps in INTTR4_SequencerTick_Alt). Basis: caller + body + interrupt twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
Transport_PromoteStartsToRunning:
	ld	(TransportC_State:8), 6:io	; F458EA  ld (0x95),0x06
	bit	0, (TransportA_State:8)	; F458ED  bit 0,(0x94)
	jr	z, Transport_PromoteStartsToRunning_Skip	; F458F0  jr Z,0xf458f5
	ld	(TransportA_State:8), 6:io	; F458F2  ld (0x94),0x06
Transport_PromoteStartsToRunning_Skip:
	bit	0, (TransportB_State:8)	; F458F5  bit 0,(0x96)
	jr	z, Transport_PromoteStartsToRunning_Return	; F458F8  jr Z,0xf458fd
	ld	(TransportB_State:8), 6:io	; F458FA  ld (0x96),0x06
Transport_PromoteStartsToRunning_Return:
	ret	; F458FD  ret

; --------------------------------------------------------------------------
; SeqRecord_TerminateTrackAtCursor
; Called from: in-module: 0xF45416
; Touches: (0x345C) (0x345E) (0x349F)  |  0x60347E 0x6034A0
; Calls:   T_BStore_WriteCursorByte T_BStore_AdvanceCursorForWrite_B
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF458FE is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_TerminateTrackAtCursor: At the take cursor: writes a 0x81 beat mark, steps (T_BStore_AdvanceCursorForWrite_B), writes the 0x82 end
;   tag, cuts the block's next link (+3 := 0xFFFF), saves that position as track (0x349F)'s end cursor
;   0x60347E[t]/0x6034A0[t], steps again. The per-track body of SeqRecord_TerminateTakeTracks, between its take-cursor
;   load (T_SeqRecord_LoadTakeCursor_Veneer) and save (T_SeqRecord_SaveTakeCursor_Veneer). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_TerminateTrackAtCursor:
	ld	a, 129:opc	; F458FE  ld A,0x81
	call	T_BStore_WriteCursorByte	; F45900  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F45904  call 0xf40c64
	ld	a, 130:opc	; F45908  ld A,0x82
	call	T_BStore_WriteCursorByte	; F4590A  call 0xf40c58
	ldw	(xhl+3), 0xffff	; F4590E  ld (XHL+0x03),0xffff
	xor	hl, hl	; F45913  xor HL,HL
	ld	l, (13471:16)	; F45915  ld L,(0x349f)
	sla	hl, 1	; F45919  sla 0x01,HL
	ld	xix, 6304894	; F4591C  ld XIX,0x0060347e
	ld	wa, (BStore_CursorBlock:16)	; F45921  ld WA,(0x345c)
	ld	(xix+hl), wa	; F45925  ld (XIX+HL),WA
	srl	hl, 1	; F4592A  srl 0x01,HL
	ld	wa, (BStore_CursorOffset:16)	; F4592D  ld WA,(0x345e)
	ld	xiz, 6304928	; F45931  ld XIZ,0x006034a0
	lda	xiz, (xiz+hl)	; F45936  lda XIZ,XIZ+HL
	ld	(xiz), a	; F4593B  ld (XIZ),A
	call	T_BStore_AdvanceCursorForWrite_B	; F4593D  call 0xf40c64
	ret	; F45941  ret

; --------------------------------------------------------------------------
; SeqRecord_SetRecordedTracksPlaying
; Called from: in-module: 0xF453B7
; Touches: (0x3000) (0x3004) (0x34BB) (0x34D0) (0x34D2) (0x34D4)
; Calls:   T_F40CB4 TimedEventRing_Discard T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45942 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SetRecordedTracksPlaying: After a take: the playing-track mask (0x60341E) |= the record mask (0x3000);
;   record mask and take mask (0x3004) := 0; (0x34D2) b0 (the song-param restore request), (0x34D4) |= 0x10, (0x34BB)
;   b3 cleared, TimedEventRing_Discard, (0x34D0) |= 2, NoteRouting_RebuildForSong. SeqRecord_EndTake's 'merges the
;   record mask into the playing mask' step. Basis: caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_SetRecordedTracksPlaying:
	ld	xwa, (12288:16)	; F45942  ld XWA,(0x3000)
	or	(0x60341e:24), xwa	; F45946  or (0x60341e),XWA
	call	T_F40CB4	; F4594B  call 0xf40cb4
	xor	xwa, xwa	; F4594F  xor XWA,XWA
	ld	(12288:16), xwa	; F45951  ld (0x3000),XWA
	ld	(12292:16), xwa	; F45955  ld (0x3004),XWA
	or	(0x34d2:16), 0x01	; F45959  or (0x34d2),0x01
	or	(0x34d4:16), 0x10	; F4595E  or (0x34d4),0x10
	and	(0x34bb:16), 0xf7	; F45963  and (0x34bb),0xf7
	calr	TimedEventRing_Discard	; F45968  calr 0xf45b0a
	or	(0x34d0:16), 0x02	; F4596B  or (0x34d0),0x02
	call	T_NoteRouting_RebuildForSong	; F45970  call 0xf411b8
	ret	; F45974  ret

; --------------------------------------------------------------------------
; SeqBufRing_Discard
; Called from: T_SeqBufRing_Discard (x2); in-module: 0xF440D4 0xF4525B
; Touches:   |  0x600A0A
; Evidence: thunk slot T_SeqBufRing_Discard holds `jp 0x00F45975`, and 0xF45975 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqBufRing_Discard: at interrupt level 6: the control block 0x600A0A of SeqBuf_Ring (0x600A14) gets its +2 index = its +6 index and its
;   +8 count = 0x1FF -- the 0x200-byte sequencer ring emptied, the same three stores as TimedEventRing_Discard.
SeqBufRing_Discard:		; <- T_SeqBufRing_Discard
	ei	6	; F45975  ei 0x06
	ld	xhl, 6294026	; F45977  ld XHL,0x00600a0a
	ld	wa, (xhl+6)	; F4597C  ld WA,(XHL+0x06)
	ld	(xhl+2), wa	; F4597F  ld (XHL+0x02),WA
	ldw	(xhl+8), 0x01ff	; F45982  ld (XHL+0x08),0x01ff
	ei	0	; F45987  ei 0x00
	ret	; F45989  ret

; --------------------------------------------------------------------------
; sub_F4598A
; Called from: in-module: 0xF44964 0xF44BDE 0xF45111 0xF4511E
; Touches: (0x34D0)
; Calls:   sub_F459AA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4598A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4598A:
	and	(TransportC_State:8), 0xed	; F4598A  and (0x95),0xed
	and	(TransportA_State:8), 0xed	; F4598E  and (0x94),0xed
	bit	5, (0x34d0:16)	; F45992  bit 5,(0x34d0)
	jr	nz, sub_F4598A_Skip2	; F45996  jr NZ,0xf459a6
	bit	2, (TransportB_State:8)	; F45998  bit 2,(0x96)
	jr	z, sub_F4598A_Skip	; F4599B  jr Z,0xf4599f
	jr	sub_F4598A_Return	; F4599D  jr T,0xf459a9
sub_F4598A_Skip:
	bit	2, (TransportA_State:8)	; F4599F  bit 2,(0x94)
	jr	z, sub_F4598A_Skip2	; F459A2  jr Z,0xf459a6
	jr	sub_F4598A_Return	; F459A4  jr T,0xf459a9
sub_F4598A_Skip2:
	calr	sub_F459AA	; F459A6  calr 0xf459aa
sub_F4598A_Return:
	ret	; F459A9  ret

; --------------------------------------------------------------------------
; sub_F459AA
; Called from: in-module: 0xF459A6 0xF45B3F 0xF45B68
; Touches: (0x3000) (0x349A) (0x34BB)  |  0x000000
; Calls:   Seq_RebuildPlayingSet
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF459AA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F459AA:
	ld	xwa, (6304798:24)	; F459AA  ld XWA,(0x60341e)
	cp	xwa, 0	; F459AF  cp XWA,0x00000000
	jr	z, sub_F459AA_Skip	; F459B5  jr Z,0xf459bc
	calr	Seq_RebuildPlayingSet	; F459B7  calr 0xf459d9
	jr	sub_F459AA_Return	; F459BA  jr T,0xf459d8
sub_F459AA_Skip:
	xor	xwa, xwa	; F459BC  xor XWA,XWA
	ld	(13466:16), xwa	; F459BE  ld (0x349a),XWA
	and	(0x34bb:16), 0xfe	; F459C2  and (0x34bb),0xfe
	ld	xde, (12288:16)	; F459C7  ld XDE,(0x3000)
	cp	xde, 0	; F459CB  cp XDE,0x00000000
	jr	z, sub_F459AA_Return	; F459D1  jr Z,0xf459d8
	or	(0x34bb:16), 0x01	; F459D3  or (0x34bb),0x01
sub_F459AA_Return:
	ret	; F459D8  ret

; --------------------------------------------------------------------------
; Seq_RebuildPlayingSet
; Called from: in-module: 0xF4450A 0xF453BA 0xF459B7
; Touches: (0x3000) (0x3002) (0x349A) (0x349C) (0x349F) (0x34BB) (0x36D6)  |
;          0x000000 0x01FFFF 0x603500
; Calls:   T_CycleRecord_CheckIsRecordTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF459D9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RebuildPlayingSet: Rebuilds the playing set (0x349A)/(0x349C) that SeqTrackCursors_RewindPlaying walks: unless a
;   locate built it ((0x34BB) b3), = tracks whose directory entry 0x603500 is in use, minus the record mask, &
;   0x1FFFF; (0x34BB) b0 = set or armed non-empty; (0x36D6) := lowest armed track, added back when
;   CycleRecord_CheckIsRecordTrack = 0. Basis: callers + body + consumer. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
Seq_RebuildPlayingSet:
	bit	3, (0x34bb:16)	; F459D9  bit 3,(0x34bb)
	jr	z, Seq_RebuildPlayingSet_Skip	; F459DD  jr Z,0xf459f9
	and	(0x34bb:16), 0xfe	; F459DF  and (0x34bb),0xfe
	ld	xde, (13466:16)	; F459E4  ld XDE,(0x349a)
	cp	xde, 0	; F459E8  cp XDE,0x00000000
	jrl	z, Seq_RebuildPlayingSet_Join2	; F459EE  jrl Z,0xf45a9a
	or	(0x34bb:16), 0x01	; F459F1  or (0x34bb),0x01
	jrl	Seq_RebuildPlayingSet_Join2	; F459F6  jrl T,0xf45a9a
Seq_RebuildPlayingSet_Skip:
	xor	xwa, xwa	; F459F9  xor XWA,XWA
	ld	(13466:16), xwa	; F459FB  ld (0x349a),XWA
	or	(0x34bb:16), 0x01	; F459FF  or (0x34bb),0x01
	ld	xix, 6305024	; F45A04  ld XIX,0x00603500
	ld	c, 0:opc	; F45A09  ld C,0x00
Seq_RebuildPlayingSet_Loop2:
	ld	a, (xix)	; F45A0B  ld A,(XIX)
	bit	7, a	; F45A0D  bit 0x07,A
	jr	z, Seq_RebuildPlayingSet_Skip3	; F45A10  jr Z,0xf45a58
	cp	c, 16	; F45A12  cp C,0x10
	jr	nc, Seq_RebuildPlayingSet_Skip2	; F45A15  jr NC,0xf45a26
	ld	iz, (13466:16)	; F45A17  ld IZ,(0x349a)
	ld	a, c	; F45A1B  ld A,C
	scf	; F45A1D  scf
	stcf_a_16	iz	; F45A1E  stcf A,IZ
	ld	(13466:16), iz	; F45A20  ld (0x349a),IZ
	jr	Seq_RebuildPlayingSet_Join	; F45A24  jr T,0xf45a36
Seq_RebuildPlayingSet_Skip2:
	ld	iz, (13468:16)	; F45A26  ld IZ,(0x349c)
	ld	a, c	; F45A2A  ld A,C
	sub	a, 16	; F45A2C  sub A,0x10
	scf	; F45A2F  scf
	stcf_a_16	iz	; F45A30  stcf A,IZ
	ld	(13468:16), iz	; F45A32  ld (0x349c),IZ
Seq_RebuildPlayingSet_Join:
	cp	c, 16	; F45A36  cp C,0x10
	jr	nc, Seq_RebuildPlayingSet_Skip7	; F45A39  jr NC,0xf45a49
	ld	iz, (6304798:24)	; F45A3B  ld IZ,(0x60341e)
	ld	a, c	; F45A40  ld A,C
	scf	; F45A42  scf
	xorcf_a_16	iz	; F45A43  xorcf A,IZ
	jr	c, Seq_RebuildPlayingSet_Skip3	; F45A45  jr C,0xf45a58
	jr	Seq_RebuildPlayingSet_Skip3	; F45A47  jr T,0xf45a58
Seq_RebuildPlayingSet_Skip7:
	ld	iz, (6304800:24)	; F45A49  ld IZ,(0x603420)
	ld	a, c	; F45A4E  ld A,C
	sub	a, 16	; F45A50  sub A,0x10
	scf	; F45A53  scf
	xorcf_a_16	iz	; F45A54  xorcf A,IZ
	jr	c, Seq_RebuildPlayingSet_Skip3	; F45A56  jr C,0xf45a58
Seq_RebuildPlayingSet_Skip3:
	add	ix, 3	; F45A58  add IX,0x0003
	inc	1, c	; F45A5C  inc 1,C
	cp	c, 17	; F45A5E  cp C,0x11
	jr	c, Seq_RebuildPlayingSet_Loop2	; F45A61  jr C,0xf45a0b
	ld	xwa, (12288:16)	; F45A63  ld XWA,(0x3000)
	xor	xwa, 4294967295	; F45A67  xor XWA,0xffffffff
	and	xwa, (0x349a:16)	; F45A6D  and XWA,(0x349a)
	and	xwa, 131071	; F45A71  and XWA,0x0001ffff
	and	(0x60341e:24), 0xff	; F45A77  and (0x60341e),0xff
	ld	(13466:16), xwa	; F45A7D  ld (0x349a),XWA
	ld	xde, (12288:16)	; F45A81  ld XDE,(0x3000)
	cp	xde, 0	; F45A85  cp XDE,0x00000000
	jr	nz, Seq_RebuildPlayingSet_Join2	; F45A8B  jr NZ,0xf45a9a
	cp	xwa, 0	; F45A8D  cp XWA,0x00000000
	jr	nz, Seq_RebuildPlayingSet_Join2	; F45A93  jr NZ,0xf45a9a
	and	(0x34bb:16), 0xfe	; F45A95  and (0x34bb),0xfe
Seq_RebuildPlayingSet_Join2:
	ld	xwa, (12288:16)	; F45A9A  ld XWA,(0x3000)
	cp	xwa, 0	; F45A9E  cp XWA,0x00000000
	jr	z, Seq_RebuildPlayingSet_Return	; F45AA4  jr Z,0xf45b09
	xor	wa, wa	; F45AA6  xor WA,WA
Seq_RebuildPlayingSet_Loop:
	cp	a, 16	; F45AA8  cp A,0x10
	jr	nc, Seq_RebuildPlayingSet_Skip4	; F45AAB  jr NC,0xf45ab8
	ld	iz, (12288:16)	; F45AAD  ld IZ,(0x3000)
	scf	; F45AB1  scf
	xorcf_a_16	iz	; F45AB2  xorcf A,IZ
	jr	c, Seq_RebuildPlayingSet_Skip5	; F45AB4  jr C,0xf45acc
	jr	Seq_RebuildPlayingSet_Join3	; F45AB6  jr T,0xf45ac6
Seq_RebuildPlayingSet_Skip4:
	pushw	wa	; F45AB8  push WA
	ld	iz, (12290:16)	; F45AB9  ld IZ,(0x3002)
	sub	a, 16	; F45ABD  sub A,0x10
	scf	; F45AC0  scf
	xorcf_a_16	iz	; F45AC1  xorcf A,IZ
	popw	wa	; F45AC3  pop WA
	jr	c, Seq_RebuildPlayingSet_Skip5	; F45AC4  jr C,0xf45acc
Seq_RebuildPlayingSet_Join3:
	ld	(14038:16), a	; F45AC6  ld (0x36d6),A
	jr	Seq_RebuildPlayingSet_Join4	; F45ACA  jr T,0xf45ad3
Seq_RebuildPlayingSet_Skip5:
	inc	1, a	; F45ACC  inc 1,A
	cp	a, 17	; F45ACE  cp A,0x11
	jr	c, Seq_RebuildPlayingSet_Loop	; F45AD1  jr C,0xf45aa8
Seq_RebuildPlayingSet_Join4:
	ld	c, (14038:16)	; F45AD3  ld C,(0x36d6)
	ld	(13471:16), c	; F45AD7  ld (0x349f),C
	call	T_CycleRecord_CheckIsRecordTrack	; F45ADB  call 0xf40be4
	cp	a, 0:i3	; F45ADF  cp A,0
	jr	nz, Seq_RebuildPlayingSet_Return	; F45AE1  jr NZ,0xf45b09
	ld	a, (14038:16)	; F45AE3  ld A,(0x36d6)
	cp	a, 16	; F45AE7  cp A,0x10
	jr	nc, Seq_RebuildPlayingSet_Skip6	; F45AEA  jr NC,0xf45af9
	ld	de, (13466:16)	; F45AEC  ld DE,(0x349a)
	scf	; F45AF0  scf
	stcf_a_16	de	; F45AF1  stcf A,DE
	ld	(13466:16), de	; F45AF3  ld (0x349a),DE
	jr	Seq_RebuildPlayingSet_Return	; F45AF7  jr T,0xf45b09
Seq_RebuildPlayingSet_Skip6:
	pushw	wa	; F45AF9  push WA
	ld	de, (13468:16)	; F45AFA  ld DE,(0x349c)
	sub	a, 16	; F45AFE  sub A,0x10
	scf	; F45B01  scf
	stcf_a_16	de	; F45B02  stcf A,DE
	ld	(13468:16), de	; F45B04  ld (0x349c),DE
	popw	wa	; F45B08  pop WA
Seq_RebuildPlayingSet_Return:
	ret	; F45B09  ret

; --------------------------------------------------------------------------
; TimedEventRing_Discard
; Called from: T_TimedEventRing_Discard (x8); in-module: 0xF440D1 0xF44B84 0xF44BD0 0xF44EF7
;              0xF44F2E 0xF44FD0 0xF45007 0xF45254 +4 more
; Touches:   |  0x600800
; Evidence: thunk slot T_TimedEventRing_Discard holds `jp 0x00F45B0A`, and 0xF45B0A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TimedEventRing_Discard: at interrupt level 6: the ring control block 0x600800's put index (+6) = its get index (+2) and the count (+8) =
;   0x1FF -- the 0x200-byte TimedEvents_Ring emptied (the block's layout: TimedEventRing_* in prom_a).
TimedEventRing_Discard:		; <- T_TimedEventRing_Discard
	ei	6	; F45B0A  ei 0x06
	ld	xhl, 6293504	; F45B0C  ld XHL,0x00600800
	ld	wa, (xhl+2)	; F45B11  ld WA,(XHL+0x02)
	ld	(xhl+6), wa	; F45B14  ld (XHL+0x06),WA
	ldw	(xhl+8), 0x01ff	; F45B17  ld (XHL+0x08),0x01ff
	ei	0	; F45B1C  ei 0x00
	ret	; F45B1E  ret

; --------------------------------------------------------------------------
; Seq_RewindToStart
; Called from: in-module: 0xF44890 0xF45452 0xF4549E 0xF45C07
; Touches: (0x3008) (0x300C) (0x34BB) (0x34D0)
; Calls:   sub_F459AA Seq_ResetPositionToSongStart
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45B1F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RewindToStart: under ei 6 TransportB_Beat = 0 and Seq_BeatTick = 0; unless (0x34D0) bit 5, the 32-bit (0x3008) and (0x300C) = 0;
;   (0x34BB) bit 3 cleared, sub_F459AA, Seq_ResetPositionToSongStart.  Seq_LocateToSongPosition calls it (through the veneer
;   Seq_RewindToStart_Veneer) for a received position of 0.  Basis: body + caller.
Seq_RewindToStart:
	ei	6	; F45B1F  ei 0x06
	ldw	(TransportB_Beat:8), 0:io	; F45B21  ld (0x91),0x0000
	ld	(Seq_BeatTick:8), 0:io	; F45B25  ld (0x93),0x00
	ei	0	; F45B28  ei 0x00
	bit	5, (0x34d0:16)	; F45B2A  bit 5,(0x34d0)
	jr	nz, Seq_RewindToStart_Skip	; F45B2E  jr NZ,0xf45b3a
	xor	xwa, xwa	; F45B30  xor XWA,XWA
	ld	(12300:16), xwa	; F45B32  ld (0x300c),XWA
	ld	(12296:16), xwa	; F45B36  ld (0x3008),XWA
Seq_RewindToStart_Skip:
	and	(0x34bb:16), 0xf7	; F45B3A  and (0x34bb),0xf7
	calr	sub_F459AA	; F45B3F  calr 0xf459aa
	jr	Seq_RewindToStart_Join	; F45B42  jr T,0xf45b44
Seq_RewindToStart_Join:
	calr	Seq_ResetPositionToSongStart	; F45B44  calr 0xf44b95
	ret	; F45B47  ret

; --------------------------------------------------------------------------
; SeqCycle_RewindToStart
; Called from: in-module: 0xF45C0C
; Touches: (0x3008) (0x300C) (0x34BB) (0x34D0)
; Calls:   sub_F459AA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45B48 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_RewindToStart: Seq_RewindToStart without its Seq_ResetPositionToSongStart tail: TransportB_Beat and
;   Seq_BeatTick := 0 under ei 6, (0x3008)/(0x300C) := 0 unless (0x34D0) bit 5, (0x34BB) bit 3 cleared, sub_F459AA.
;   Seq_LocateToCurrentMeasure takes it instead of Seq_RewindToStart in the cycle variant ((0x3735) bit 0, set by
;   SeqCycle_LocateTracksToCurrentMeasure) for measure <= 1 or a count-in. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
SeqCycle_RewindToStart:
	ei	6	; F45B48  ei 0x06
	ldw	(TransportB_Beat:8), 0:io	; F45B4A  ld (0x91),0x0000
	ld	(Seq_BeatTick:8), 0:io	; F45B4E  ld (0x93),0x00
	ei	0	; F45B51  ei 0x00
	bit	5, (0x34d0:16)	; F45B53  bit 5,(0x34d0)
	jr	nz, SeqCycle_RewindToStart_Skip	; F45B57  jr NZ,0xf45b63
	xor	xwa, xwa	; F45B59  xor XWA,XWA
	ld	(12300:16), xwa	; F45B5B  ld (0x300c),XWA
	ld	(12296:16), xwa	; F45B5F  ld (0x3008),XWA
SeqCycle_RewindToStart_Skip:
	and	(0x34bb:16), 0xf7	; F45B63  and (0x34bb),0xf7
	calr	sub_F459AA	; F45B68  calr 0xf459aa
	jr	SeqCycle_RewindToStart_Return	; F45B6B  jr T,0xf45b6d
SeqCycle_RewindToStart_Return:
	ret	; F45B6D  ret

; --------------------------------------------------------------------------
; SeqTrack_QueueNoteOffAndBendCentre
; Called from: in-module: 0xF44F60 0xF45039
; Touches: (0x349F)
; Calls:   T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45B6E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_QueueNoteOffAndBendCentre: Puts two records for track (0x349F) into the timed-event ring: {0x90, 0x7F, 0,
;   0, t} (note 0, velocity 0) and {0xD2, 0x7F, 0x00, 0x40, t} -- song code 0xD2 = pitch bend (SmfEvent_PitchBend) at
;   the centre 0x00 0x40 (as SeqEvt_ResetPlayingSlotControllers). Part of SeqTrack_QueueSwitchOffEvents' track switch-
;   off events, also in its twin sub_F44F67. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
SeqTrack_QueueNoteOffAndBendCentre:
	ld	a, 144:opc	; F45B6E  ld A,0x90
	pushw	wa	; F45B70  push WA
	call	T_TimedEventRing_Put	; F45B71  call 0xf41d64
	inc	2, xsp	; F45B75  inc 2,XSP
	ld	a, 127:opc	; F45B77  ld A,0x7f
	pushw	wa	; F45B79  push WA
	call	T_TimedEventRing_Put	; F45B7A  call 0xf41d64
	inc	2, xsp	; F45B7E  inc 2,XSP
	xor	a, a	; F45B80  xor A,A
	pushw	wa	; F45B82  push WA
	call	T_TimedEventRing_Put	; F45B83  call 0xf41d64
	inc	2, xsp	; F45B87  inc 2,XSP
	xor	a, a	; F45B89  xor A,A
	pushw	wa	; F45B8B  push WA
	call	T_TimedEventRing_Put	; F45B8C  call 0xf41d64
	inc	2, xsp	; F45B90  inc 2,XSP
	ld	a, (13471:16)	; F45B92  ld A,(0x349f)
	pushw	wa	; F45B96  push WA
	call	T_TimedEventRing_Put	; F45B97  call 0xf41d64
	inc	2, xsp	; F45B9B  inc 2,XSP
	ld	a, 210:opc	; F45B9D  ld A,0xd2
	pushw	wa	; F45B9F  push WA
	call	T_TimedEventRing_Put	; F45BA0  call 0xf41d64
	inc	2, xsp	; F45BA4  inc 2,XSP
	ld	a, 127:opc	; F45BA6  ld A,0x7f
	pushw	wa	; F45BA8  push WA
	call	T_TimedEventRing_Put	; F45BA9  call 0xf41d64
	inc	2, xsp	; F45BAD  inc 2,XSP
	ld	a, 0:opc	; F45BAF  ld A,0x00
	pushw	wa	; F45BB1  push WA
	call	T_TimedEventRing_Put	; F45BB2  call 0xf41d64
	inc	2, xsp	; F45BB6  inc 2,XSP
	ld	a, 64:opc	; F45BB8  ld A,0x40
	pushw	wa	; F45BBA  push WA
	call	T_TimedEventRing_Put	; F45BBB  call 0xf41d64
	inc	2, xsp	; F45BBF  inc 2,XSP
	ld	a, (13471:16)	; F45BC1  ld A,(0x349f)
	pushw	wa	; F45BC5  push WA
	call	T_TimedEventRing_Put	; F45BC6  call 0xf41d64
	inc	2, xsp	; F45BCA  inc 2,XSP
	ret	; F45BCC  ret

; --------------------------------------------------------------------------
; SeqCycle_LocateTracksToCurrentMeasure
; Called from: T_SeqCycle_LocateTracksToCurrentMeasure (x1)
; Touches: (0x3735)
; Evidence: thunk slot T_SeqCycle_LocateTracksToCurrentMeasure holds `jp 0x00F45BCD`, and 0xF45BCD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_LocateTracksToCurrentMeasure: (0x3735) bit 0 := 1, then Seq_LocateToCurrentMeasure's body: every track sought to the
;   current measure (0x3552) by BStore_SeekChainToMeasure, beats per bar / beat latched, located tracks in
;   (0x349A)/(0x349C), (0x34BB) b3 set; measure 1 or a count-in rewinds instead. Bit 0 picks the cycle variants
;   (SeqCycle_RewindToStart, (0x3759)). SeqCycle_LocateToStart's 'locates every track there'. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
SeqCycle_LocateTracksToCurrentMeasure:		; <- T_SeqCycle_LocateTracksToCurrentMeasure
	set	0, (0x3735:16)	; F45BCD  set 0,(0x3735)
	jr	Seq_LocateToCurrentMeasure_Join	; F45BD1  jr T,0xf45bd7

; --------------------------------------------------------------------------
; Seq_LocateToCurrentMeasure
; Called from: T_Seq_LocateToCurrentMeasure (x1); in-module: 0xF44C42
; Touches: (0x0C90) (0x0D4A) (0x3456) (0x3458) (0x345E) (0x349A) (0x349C)
;          (0x349F) (0x34BB) (0x34D4) +6 more  |  0x000000
; Calls:   Seq_RewindToStart SeqCycle_RewindToStart MidiOut_SendSongPosition SeqMasterTrack_UpdateActive T_BStore_SeekChainToMeasure T_SeqTrackCursors_SaveTrack
;          TimedEventRing_Discard Nop_CallsEmptyDirectorySlot
; Evidence: thunk slot T_Seq_LocateToCurrentMeasure holds `jp 0x00F45BD3`, and 0xF45BD3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_LocateToCurrentMeasure: Locates every track to the current measure (0x3552): measure <= 1 rewinds
;   (Seq_RewindToStart), else each of the 17 tracks is sought there (T_BStore_SeekChainToMeasure, master track from
;   SeqMasterTrack_UpdateActive), beats per bar and TransportB_Beat set, located tracks collected in (0x349A)/(0x349C) -> (0x36C6),
;   (0x34BB) bit 3 set. SeqCycle_LocateToStart enters at SeqCycle_LocateTracksToCurrentMeasure. Basis: body + entry twin + sibling.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
Seq_LocateToCurrentMeasure:		; <- T_Seq_LocateToCurrentMeasure
	res	0, (0x3735:16)	; F45BD3  res 0,(0x3735)
Seq_LocateToCurrentMeasure_Join:
	bit	0, (0x34d9:16)	; F45BD7  bit 0,(0x34d9)
	jr	z, Seq_LocateToCurrentMeasure_Skip	; F45BDB  jr Z,0xf45be5
	ld	wa, (13650:16)	; F45BDD  ld WA,(0x3552)
	ld	(14036:16), wa	; F45BE1  ld (0x36d4),WA
Seq_LocateToCurrentMeasure_Skip:
	xor	xwa, xwa	; F45BE5  xor XWA,XWA
	ld	(13466:16), xwa	; F45BE7  ld (0x349a),XWA
	ld	(13471:16), 0	; F45BEB  ld (0x349f),0x00
	ld	wa, (13650:16)	; F45BF0  ld WA,(0x3552)
	ld	(3216:16), wa	; F45BF4  ld (0x0c90),WA
	bit	7, w	; F45BF8  bit 0x07,W
	jr	nz, Seq_LocateToCurrentMeasure_Skip2	; F45BFB  jr NZ,0xf45c01
	cp	wa, 1:i3	; F45BFD  cp WA,1
	jr	nz, Seq_LocateToCurrentMeasure_Skip4	; F45BFF  jr NZ,0xf45c18
Seq_LocateToCurrentMeasure_Skip2:
	bit	0, (0x3735:16)	; F45C01  bit 0,(0x3735)
	jr	nz, Seq_LocateToCurrentMeasure_Skip3	; F45C05  jr NZ,0xf45c0c
	calr	Seq_RewindToStart	; F45C07  calr 0xf45b1f
	jr	Seq_LocateToCurrentMeasure_Join2	; F45C0A  jr T,0xf45c0f
Seq_LocateToCurrentMeasure_Skip3:
	calr	SeqCycle_RewindToStart	; F45C0C  calr 0xf45b48
Seq_LocateToCurrentMeasure_Join2:
	calr	MidiOut_SendSongPosition	; F45C0F  calr 0xf44ca7
	ld	(168:8), 0:io	; F45C12  ld (0xa8),0x00
	jrl	Seq_LocateToCurrentMeasure_Join4	; F45C15  jrl T,0xf45cb6
Seq_LocateToCurrentMeasure_Skip4:
	calr	SeqMasterTrack_UpdateActive	; F45C18  calr 0xf455e6
Seq_LocateToCurrentMeasure_Loop:
	ld	a, (13471:16)	; F45C1B  ld A,(0x349f)
	inc	1, a	; F45C1F  inc 1,A
	pushw	wa	; F45C21  push WA
	call	T_BStore_SeekChainToMeasure	; F45C22  call 0xf40c5c
	cp	(BStore_ErrorCode:16), 0x00	; F45C26  cp (0x0d4a),0x00
	jr	nz, Seq_LocateToCurrentMeasure_Skip7	; F45C2B  jr NZ,0xf45c82
	ld	(13400:16), a	; F45C2D  ld (0x3458),A
	ld	(TransportA_BeatsPerBar:24), a	; F45C31  ld (0x605000),A
	ld	(0xc3:8), a	; F45C36  ld (0xc3),A
	ld	(6304983:24), a	; F45C39  ld (0x6034d7),A
	bit	0, (0x3735:16)	; F45C3E  bit 0,(0x3735)
	jr	z, Seq_LocateToCurrentMeasure_Skip5	; F45C42  jr Z,0xf45c48
	ld	(14169:16), a	; F45C44  ld (0x3759),A
Seq_LocateToCurrentMeasure_Skip5:
	ld	(BStore_CursorOffset:16), iy	; F45C48  ld (0x345e),IY
	ld	(TransportB_Beat:8), ix	; F45C4C  ld (0x91),IX
	ld	(13398:16), ix	; F45C4F  ld (0x3456),IX
	ld	(Seq_BeatTick:8), 0:io	; F45C53  ld (0x93),0x00
	ld	c, (13471:16)	; F45C56  ld C,(0x349f)
	cp	c, 16	; F45C5A  cp C,0x10
	jr	nc, Seq_LocateToCurrentMeasure_Skip6	; F45C5D  jr NC,0xf45c6e
	ld	iz, (13466:16)	; F45C5F  ld IZ,(0x349a)
	ld	a, c	; F45C63  ld A,C
	scf	; F45C65  scf
	stcf_a_16	iz	; F45C66  stcf A,IZ
	ld	(13466:16), iz	; F45C68  ld (0x349a),IZ
	jr	Seq_LocateToCurrentMeasure_Join3	; F45C6C  jr T,0xf45c7e
Seq_LocateToCurrentMeasure_Skip6:
	ld	iz, (13468:16)	; F45C6E  ld IZ,(0x349c)
	ld	a, c	; F45C72  ld A,C
	sub	a, 16	; F45C74  sub A,0x10
	scf	; F45C77  scf
	stcf_a_16	iz	; F45C78  stcf A,IZ
	ld	(13468:16), iz	; F45C7A  ld (0x349c),IZ
Seq_LocateToCurrentMeasure_Join3:
	call	T_SeqTrackCursors_SaveTrack	; F45C7E  call 0xf40b54
Seq_LocateToCurrentMeasure_Skip7:
	popw	wa	; F45C82  pop WA
	inc	1, (13471:16)	; F45C83  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F45C87  cp (0x349f),0x11
	jr	c, Seq_LocateToCurrentMeasure_Loop	; F45C8C  jr C,0xf45c1b
	or	(0x34bb:16), 0x08	; F45C8E  or (0x34bb),0x08
	calr	MidiOut_SendSongPosition	; F45C93  calr 0xf44ca7
	ld	(168:8), 0:io	; F45C96  ld (0xa8),0x00
	ld	xwa, (13466:16)	; F45C99  ld XWA,(0x349a)
	cp	xwa, 0	; F45C9D  cp XWA,0x00000000
	jr	z, Seq_LocateToCurrentMeasure_Join4	; F45CA3  jr Z,0xf45cb6
	calr	TimedEventRing_Discard	; F45CA5  calr 0xf45b0a
	or	(0x34d4:16), 0x10	; F45CA8  or (0x34d4),0x10
	bit	0, (0x3735:16)	; F45CAD  bit 0,(0x3735)
	jr	nz, Seq_LocateToCurrentMeasure_Join4	; F45CB1  jr NZ,0xf45cb6
	calr	Nop_CallsEmptyDirectorySlot	; F45CB3  calr 0xf45d04
Seq_LocateToCurrentMeasure_Join4:
	and	(0x34bb:16), 0xfb	; F45CB6  and (0x34bb),0xfb
	ld	xwa, (13466:16)	; F45CBB  ld XWA,(0x349a)
	ld	(14022:16), xwa	; F45CBF  ld (0x36c6),XWA
	ret	; F45CC3  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_LocateAllToCurrentMeasure
; Called from: T_SeqTrackCursors_LocateAllToCurrentMeasure (x3)
; Touches: (0x0C90) (0x0D4A) (0x345E) (0x349F) (0x34BB) (0x3552)
; Calls:   SeqMasterTrack_UpdateActive T_BStore_SeekChainToMeasure T_SeqTrackCursors_SaveTrack
; Evidence: thunk slot T_SeqTrackCursors_LocateAllToCurrentMeasure holds `jp 0x00F45CC4`, and 0xF45CC4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_LocateAllToCurrentMeasure: Seeks each of the 17 tracks' chains (track + 1) to the current measure
;   (0x3552) with BStore_SeekChainToMeasure (meter source chosen first by SeqMasterTrack_UpdateActive) and stores the cursor as that
;   track's saved cursor (0x3460/0x3482 via SeqTrackCursors_SaveTrack); a track whose seek fails keeps its cursor. Clears (0x34BB)
;   bit 2. SeqCycle_CaptureEndCursors runs it to locate to CYCLE END + 1. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_i.json)
SeqTrackCursors_LocateAllToCurrentMeasure:		; <- T_SeqTrackCursors_LocateAllToCurrentMeasure
	ld	(13471:16), 0	; F45CC4  ld (0x349f),0x00
	ld	wa, (13650:16)	; F45CC9  ld WA,(0x3552)
	ld	(3216:16), wa	; F45CCD  ld (0x0c90),WA
	calr	SeqMasterTrack_UpdateActive	; F45CD1  calr 0xf455e6
SeqTrackCursors_LocateAllToCurrentMeasure_Loop2:
	ld	a, (13471:16)	; F45CD4  ld A,(0x349f)
	inc	1, a	; F45CD8  inc 1,A
	pushw	wa	; F45CDA  push WA
	call	T_BStore_SeekChainToMeasure	; F45CDB  call 0xf40c5c
	cp	(BStore_ErrorCode:16), 0x00	; F45CDF  cp (0x0d4a),0x00
	jr	nz, SeqTrackCursors_LocateAllToCurrentMeasure_Skip8	; F45CE4  jr NZ,0xf45cf2
	ld	(BStore_CursorOffset:16), iy	; F45CE6  ld (0x345e),IY
	ld	c, (13471:16)	; F45CEA  ld C,(0x349f)
	call	T_SeqTrackCursors_SaveTrack	; F45CEE  call 0xf40b54
SeqTrackCursors_LocateAllToCurrentMeasure_Skip8:
	popw	wa	; F45CF2  pop WA
	inc	1, (13471:16)	; F45CF3  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F45CF7  cp (0x349f),0x11
	jr	c, SeqTrackCursors_LocateAllToCurrentMeasure_Loop2	; F45CFC  jr C,0xf45cd4
	and	(0x34bb:16), 0xfb	; F45CFE  and (0x34bb),0xfb
	ret	; F45D03  ret

; --------------------------------------------------------------------------
; Nop_CallsEmptyDirectorySlot -- prom_b 0xF45D04.  Five bytes, and it does nothing.
; Called from: in-module: 0xF45CB3
; Touches: nothing with an absolute address
; Calls:   T_F414E0
;   `call 0xF414E0` then `ret`.  0xF414E0 is a slot of the 0xF40000
;   directory and its four bytes are `0E 0E 0E 0E`; 0x0E is RET
;   (mame dasm900.cpp:1267).  So the call returns immediately and the
;   routine returns.  No register, no memory and no device is touched;
;   the only effect is the push and pop of a return address.
; Evidence: prom_b file 0x45D04 = `1d e0 14 f4 0e`, file 0x414E0 = `0e`.
;           notes/prom_b_thunks_round6.py --fillcalls re-reads both and
;           shows this is the ONLY decoded call into any of the 2,100
;           fill slots -- one site, so an observation, not a mechanism.
; Unknown: what it was FOR.  A stubbed-out feature is the obvious guess
;          and is NOT asserted; the name states what the code does.
; --------------------------------------------------------------------------
Nop_CallsEmptyDirectorySlot:
	call	T_F414E0_Empty	; F45D04  call 0xf414e0
	ret	; F45D08  ret

; --------------------------------------------------------------------------
; SeqRecord_TerminateTracksIfRecording
; Called from: T_SeqRecord_TerminateTracksIfRecording (x1)
; Touches: (0x3000)  |  0x000000
; Calls:   SeqRecord_TerminateTakeTracks
; Evidence: thunk slot T_SeqRecord_TerminateTracksIfRecording holds `jp 0x00F45D09`, and 0xF45D09 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_TerminateTracksIfRecording: If the record mask (0x3000) is non-zero, SeqRecord_TerminateTakeTracks: for each track in
;   (0x3004)/(0x3006), T_SeqRecord_LoadTakeCursor_Veneer, SeqRecord_TerminateTrackAtCursor -- a 0x81 beat mark and the 0x82 end tag at its cursor, the cursor saved
;   as the track's entry in 0x60347E / 0x6034A0 -- and T_SeqRecord_SaveTakeCursor_Veneer; SeqRecord_EndTake (T_SeqRecord_EndTake, which RealtimeRecord_Disarm
;   calls) runs the same pass. NMI_PowerFail_SaveAndHalt calls it, so a song being recorded is closed before the
;   power-fail checksums. Basis: caller + body + the tag meanings. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
SeqRecord_TerminateTracksIfRecording:		; <- T_SeqRecord_TerminateTracksIfRecording
	ld	xwa, (12288:16)	; F45D09  ld XWA,(0x3000)
	cp	xwa, 0	; F45D0D  cp XWA,0x00000000
	jr	z, Nop_CallsEmptyDirectorySlot_Return	; F45D13  jr Z,0xf45d18
	calr	SeqRecord_TerminateTakeTracks	; F45D15  calr 0xf453e9
Nop_CallsEmptyDirectorySlot_Return:
	ret	; F45D18  ret

; --------------------------------------------------------------------------
; BStore_LoadGmTrackDefaults
; Called from: T_BStore_LoadGmTrackDefaults (x0); in-module: 0xF44267
; Touches: (0x7F4D)  |  0x603422 0x603433
; Evidence: thunk slot T_BStore_LoadGmTrackDefaults holds `jp 0x00F45D19`, and 0xF45D19 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_LoadGmTrackDefaults: GM mode ((0x7F4D) bit 2) only: BStore_TrackToPart[0..16] := WorkspaceDefaults+0x2D and
;   workspace +0x33[0..16] := WorkspaceDefaults+0x3E, or +0x60 when (0x6034C7) bit 1. The non-GM twin BStore_LoadNonGmTrackDefaults (bit
;   clear) uses +0x1C (BStore_TrackToPart_LoadDefaults) and BStore_TrackOutChannel_LoadDefaults. The first step of
;   BStore_ResetWorkspaceToDefault ('track-to-part defaults by GM mode'). Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
BStore_LoadGmTrackDefaults:		; <- T_BStore_LoadGmTrackDefaults
	bit	2, (0x7f4d:16)	; F45D19  bit 2,(0x7f4d)
	jr	z, BStore_LoadGmTrackDefaults_Return	; F45D1D  jr Z,0xf45d7f
	push	xwa	; F45D1F  push XWA
	push	xbc	; F45D20  push XBC
	push	xde	; F45D21  push XDE
	push	xhl	; F45D22  push XHL
	push	xix	; F45D23  push XIX
	push	xiy	; F45D24  push XIY
	push	xiz	; F45D25  push XIZ
	ld	xhl, BStore_TrackToPart	; F45D26  ld XHL,0x00603422
	xor	iy, iy	; F45D2B  xor IY,IY
BStore_LoadGmTrackDefaults_Loop:
	ld	xix, WorkspaceDefaults + 0x2D	; F45D2D  ld XIX,0x00f460a1
	ld	a, (xix+iy)	; F45D32  ld A,(XIX+IY)
	ld	(xhl+iy), a	; F45D37  ld (XHL+IY),A
	inc	1, iy	; F45D3C  inc 1,IY
	cp	iy, 17	; F45D3E  cp IY,0x0011
	jr	c, BStore_LoadGmTrackDefaults_Loop	; F45D42  jr C,0xf45d2d
	ld	xhl, 6304819	; F45D44  ld XHL,0x00603433
	xor	iy, iy	; F45D49  xor IY,IY
BStore_LoadGmTrackDefaults_Loop2:
	ld	a, (6304967:24)	; F45D4B  ld A,(0x6034c7)
	and	a, 2	; F45D50  and A,0x02
	jr	nz, BStore_LoadGmTrackDefaults_Skip	; F45D53  jr NZ,0xf45d61
	ld	xix, WorkspaceDefaults + 0x3E	; F45D55  ld XIX,0x00f460b2
	ld	a, (xix+iy)	; F45D5A  ld A,(XIX+IY)
	jr	BStore_LoadGmTrackDefaults_Join	; F45D5F  jr T,0xf45d6b
BStore_LoadGmTrackDefaults_Skip:
	ld	xix, WorkspaceDefaults + 0x60	; F45D61  ld XIX,0x00f460d4
	ld	a, (xix+iy)	; F45D66  ld A,(XIX+IY)
BStore_LoadGmTrackDefaults_Join:
	ld	(xhl+iy), a	; F45D6B  ld (XHL+IY),A
	inc	1, iy	; F45D70  inc 1,IY
	cp	iy, 17	; F45D72  cp IY,0x0011
	jr	c, BStore_LoadGmTrackDefaults_Loop2	; F45D76  jr C,0xf45d4b
	pop	xiz	; F45D78  pop XIZ
	pop	xiy	; F45D79  pop XIY
	pop	xix	; F45D7A  pop XIX
	pop	xhl	; F45D7B  pop XHL
	pop	xde	; F45D7C  pop XDE
	pop	xbc	; F45D7D  pop XBC
	pop	xwa	; F45D7E  pop XWA
BStore_LoadGmTrackDefaults_Return:
	ret	; F45D7F  ret

; --------------------------------------------------------------------------
; BStore_LoadNonGmTrackDefaults
; Called from: T_BStore_LoadNonGmTrackDefaults (x0); in-module: 0xF4426A
; Touches: (0x7F4D)
; Calls:   BStore_TrackToPart_LoadDefaults BStore_TrackOutChannel_LoadDefaults
; Evidence: thunk slot T_BStore_LoadNonGmTrackDefaults holds `jp 0x00F45D80`, and 0xF45D80 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_LoadNonGmTrackDefaults: Unless GM mode ((0x7F4D) bit 2): BStore_TrackToPart_LoadDefaults (17 bytes from
;   WorkspaceDefaults + 0x1C) and BStore_TrackOutChannel_LoadDefaults (17 bytes at 0x603433 from WorkspaceDefaults + 0x3E, or + 0x4F when
;   (0x6034C7) bit 1), all registers saved. Its GM twin BStore_LoadGmTrackDefaults runs only when that bit is set;
;   BStore_ResetWorkspaceToDefault runs both. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
BStore_LoadNonGmTrackDefaults:		; <- T_BStore_LoadNonGmTrackDefaults
	bit	2, (0x7f4d:16)	; F45D80  bit 2,(0x7f4d)
	jr	nz, BStore_LoadNonGmTrackDefaults_Return	; F45D84  jr NZ,0xf45d9a
	push	xwa	; F45D86  push XWA
	push	xbc	; F45D87  push XBC
	push	xde	; F45D88  push XDE
	push	xhl	; F45D89  push XHL
	push	xix	; F45D8A  push XIX
	push	xiy	; F45D8B  push XIY
	push	xiz	; F45D8C  push XIZ
	calr	BStore_TrackToPart_LoadDefaults	; F45D8D  calr 0xf444e4
	calr	BStore_TrackOutChannel_LoadDefaults	; F45D90  calr 0xf442da
	pop	xiz	; F45D93  pop XIZ
	pop	xiy	; F45D94  pop XIY
	pop	xix	; F45D95  pop XIX
	pop	xhl	; F45D96  pop XHL
	pop	xde	; F45D97  pop XDE
	pop	xbc	; F45D98  pop XBC
	pop	xwa	; F45D99  pop XWA
BStore_LoadNonGmTrackDefaults_Return:
	ret	; F45D9A  ret

; --------------------------------------------------------------------------
; Seq_ResetTrackExpressionToFull
; Called from: in-module: 0xF44BD3
; Touches: (0x349F) (0x34BB)  |  0x603422
; Calls:   T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45D9B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ResetTrackExpressionToFull: Unless (0x34BB) bit 3: for each track 0..16 in the playing mask
;   (0x60341E)/(0x603420) that is not the master track (BStore_TrackToPart byte 0x20, Seq_FindMasterTrack's marker),
;   puts the expression event {0xD3, tick 0, value 0x7F, track} -- SeqBuf_PutExpressionEvent's layout, which
;   SeqEvt_ShadowExpression plays -- into the timed-event ring. Seq_ResetPositionToSongStart's only call to it:
;   expression back to full at the song start. Basis: caller + body + event layout. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
Seq_ResetTrackExpressionToFull:
	push	xwa	; F45D9B  push XWA
	push	xbc	; F45D9C  push XBC
	push	xde	; F45D9D  push XDE
	push	xhl	; F45D9E  push XHL
	push	xix	; F45D9F  push XIX
	push	xiy	; F45DA0  push XIY
	push	xiz	; F45DA1  push XIZ
	bit	3, (0x34bb:16)	; F45DA2  bit 3,(0x34bb)
	jr	nz, Seq_ResetTrackExpressionToFull_Epilogue	; F45DA6  jr NZ,0xf45e0c
	xor	bc, bc	; F45DA8  xor BC,BC
Seq_ResetTrackExpressionToFull_Loop:
	ld	(13471:16), c	; F45DAA  ld (0x349f),C
	cp	c, 16	; F45DAE  cp C,0x10
	jr	nc, Seq_ResetTrackExpressionToFull_Skip	; F45DB1  jr NC,0xf45dc1
	ld	iz, (6304798:24)	; F45DB3  ld IZ,(0x60341e)
	ld	a, c	; F45DB8  ld A,C
	scf	; F45DBA  scf
	xorcf_a_16	iz	; F45DBB  xorcf A,IZ
	jr	c, Seq_ResetTrackExpressionToFull_Skip2	; F45DBD  jr C,0xf45e05
	jr	Seq_ResetTrackExpressionToFull_Join	; F45DBF  jr T,0xf45dd0
Seq_ResetTrackExpressionToFull_Skip:
	ld	iz, (6304800:24)	; F45DC1  ld IZ,(0x603420)
	ld	a, c	; F45DC6  ld A,C
	sub	a, 16	; F45DC8  sub A,0x10
	scf	; F45DCB  scf
	xorcf_a_16	iz	; F45DCC  xorcf A,IZ
	jr	c, Seq_ResetTrackExpressionToFull_Skip2	; F45DCE  jr C,0xf45e05
Seq_ResetTrackExpressionToFull_Join:
	ld	iy, bc	; F45DD0  ld IY,BC
	ld	xix, BStore_TrackToPart	; F45DD2  ld XIX,0x00603422
	cp	(xix+iy), 0x20	; F45DD7  cp (XIX+IY),0x20
	jr	z, Seq_ResetTrackExpressionToFull_Skip2	; F45DDD  jr Z,0xf45e05
	ld	a, 211:opc	; F45DDF  ld A,0xd3
	pushw	wa	; F45DE1  push WA
	call	T_TimedEventRing_Put	; F45DE2  call 0xf41d64
	inc	2, xsp	; F45DE6  inc 2,XSP
	ld	a, 0:opc	; F45DE8  ld A,0x00
	pushw	wa	; F45DEA  push WA
	call	T_TimedEventRing_Put	; F45DEB  call 0xf41d64
	inc	2, xsp	; F45DEF  inc 2,XSP
	ld	a, 127:opc	; F45DF1  ld A,0x7f
	pushw	wa	; F45DF3  push WA
	call	T_TimedEventRing_Put	; F45DF4  call 0xf41d64
	inc	2, xsp	; F45DF8  inc 2,XSP
	ld	a, (13471:16)	; F45DFA  ld A,(0x349f)
	pushw	wa	; F45DFE  push WA
	call	T_TimedEventRing_Put	; F45DFF  call 0xf41d64
	inc	2, xsp	; F45E03  inc 2,XSP
Seq_ResetTrackExpressionToFull_Skip2:
	inc	1, c	; F45E05  inc 1,C
	cp	c, 17	; F45E07  cp C,0x11
	jr	c, Seq_ResetTrackExpressionToFull_Loop	; F45E0A  jr C,0xf45daa
Seq_ResetTrackExpressionToFull_Epilogue:
	pop	xiz	; F45E0C  pop XIZ
	pop	xiy	; F45E0D  pop XIY
	pop	xix	; F45E0E  pop XIX
	pop	xhl	; F45E0F  pop XHL
	pop	xde	; F45E10  pop XDE
	pop	xbc	; F45E11  pop XBC
	pop	xwa	; F45E12  pop XWA
	ret	; F45E13  ret

; --------------------------------------------------------------------------
; sub_F45E14
; Called from: in-module: 0xF443D2
; Touches:   |  0x603433
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45E14 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F45E14:
	ld	xhl, 6304819	; F45E14  ld XHL,0x00603433
	xor	iy, iy	; F45E19  xor IY,IY
sub_F45E14_Loop:
	ld	a, (6304967:24)	; F45E1B  ld A,(0x6034c7)
	and	a, 2	; F45E20  and A,0x02
	jr	nz, sub_F45E14_Skip	; F45E23  jr NZ,0xf45e31
	ld	xix, WorkspaceDefaults + 0x3E	; F45E25  ld XIX,0x00f460b2
	ld	a, (xix+iy)	; F45E2A  ld A,(XIX+IY)
	jr	sub_F45E14_Join	; F45E2F  jr T,0xf45e3b
sub_F45E14_Skip:
	ld	xix, WorkspaceDefaults + 0x60	; F45E31  ld XIX,0x00f460d4
	ld	a, (xix+iy)	; F45E36  ld A,(XIX+IY)
sub_F45E14_Join:
	ld	(xhl+iy), a	; F45E3B  ld (XHL+IY),A
	inc	1, iy	; F45E40  inc 1,IY
	cp	iy, 17	; F45E42  cp IY,0x0011
	jr	c, sub_F45E14_Loop	; F45E46  jr C,0xf45e1b
	ret	; F45E48  ret

; --------------------------------------------------------------------------
; sub_F45E49
; Called from: in-module: 0xF4408D
; Touches: nothing with an absolute address
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45E49 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F45E49:
	and	(0x6034c7:24), 0xfd	; F45E49  and (0x6034c7),0xfd
	jr	sub_F45E49_Join	; F45E4F  jr T,0xf45e51
sub_F45E49_Join:
	or	(0x6034c7:24), 0x02	; F45E51  or (0x6034c7),0x02
	ret	; F45E57  ret

; --------------------------------------------------------------------------
; SeqCycle_TickDeferredAction
; Called from: T_SeqCycle_TickDeferredAction (x1)
; Touches: nothing with an absolute address
; Calls:   SeqCycle_CountDownDeferredAction SeqCycle_RunDueDeferredAction
; Evidence: thunk slot T_SeqCycle_TickDeferredAction holds `jp 0x00F45E58`, and 0xF45E58 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_TickDeferredAction: The cycle screens' deferred-action timer: counts (0x3628) down while bit 7 is set and
;   above 0x80 (SeqCycle_CountDownDeferredAction); at 0x80 clears it and runs Dispatch_3629[(0x3629)] -- 0 relocate to the cycle start, 1
;   capture the end cursors, 2 both (SeqCycle_RunDueDeferredAction). Run by EditScreen_Tick (slot T_SeqCycle_TickDeferredAction) after its own two timers; the
;   CYCLE PLAY / CYCLE RECORD measure editors arm it 3 ticks ahead (0x83). Basis: caller + body + table + writers.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
SeqCycle_TickDeferredAction:		; <- T_SeqCycle_TickDeferredAction
	calr	SeqCycle_CountDownDeferredAction	; F45E58  calr 0xf45e5f
	calr	SeqCycle_RunDueDeferredAction	; F45E5B  calr 0xf45e76
	ret	; F45E5E  ret

; --------------------------------------------------------------------------
; SeqCycle_CountDownDeferredAction
; Called from: in-module: 0xF45E58
; Touches: (0x3628)  |  0x003628
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45E5F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_CountDownDeferredAction: Counts the cycle screens' deferred-action timer (0x3628) down by one while bit 7
;   is set and it is above 0x80. First step of SeqCycle_TickDeferredAction (header: counts (0x3628) down while bit 7
;   is set and above 0x80). Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
SeqCycle_CountDownDeferredAction:
	bit	7, (0x3628:16)	; F45E5F  bit 7,(0x3628)
	jr	nz, SeqCycle_CountDownDeferredAction_Skip	; F45E63  jr NZ,0xf45e67
	jr	SeqCycle_CountDownDeferredAction_Return	; F45E65  jr T,0xf45e75
SeqCycle_CountDownDeferredAction_Skip:
	ld	xix, 13864	; F45E67  ld XIX,0x00003628
	cp	(xix), 0x80	; F45E6C  cp (XIX),0x80
	jr	nz, SeqCycle_CountDownDeferredAction_Skip2	; F45E6F  jr NZ,0xf45e73
	jr	SeqCycle_CountDownDeferredAction_Return	; F45E71  jr T,0xf45e75
SeqCycle_CountDownDeferredAction_Skip2:
	decm8	1, (xix)	; F45E73  dec 1,(XIX)
SeqCycle_CountDownDeferredAction_Return:
	ret	; F45E75  ret

; --------------------------------------------------------------------------
; SeqCycle_RunDueDeferredAction
; Called from: in-module: 0xF45E5B
; Touches: (0x3629)  |  0x003628
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45E76 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_RunDueDeferredAction: When the deferred-action timer (0x3628) has reached 0x80: clears it and calls
;   Dispatch_3629[(0x3629)] (0 SeqCycle_ApplyStartMeasureChange, 1 SeqCycle_OnEndMeasureChanged, 2
;   SeqCycle_RelocateStartAndEnd). Second step of SeqCycle_TickDeferredAction. Basis: caller header + body + table.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
SeqCycle_RunDueDeferredAction:
	ld	xix, 13864	; F45E76  ld XIX,0x00003628
	cp	(xix), 0x80	; F45E7B  cp (XIX),0x80
	jr	z, SeqCycle_RunDueDeferredAction_Skip	; F45E7E  jr Z,0xf45e82
	jr	SeqCycle_RunDueDeferredAction_Return	; F45E80  jr T,0xf45e99
SeqCycle_RunDueDeferredAction_Skip:
	ld	(xix), 0	; F45E82  ld (XIX),0x00
	xor	xwa, xwa	; F45E85  xor XWA,XWA
	ld	xix, Dispatch_3629	; F45E87  ld XIX,0x00f45e9a
	ld	a, (13865:16)	; F45E8C  ld A,(0x3629)
	sll	xwa, 2	; F45E90  sll 0x02,XWA
	add	xix, xwa	; F45E93  add XIX,XWA
	ld	xix, (xix)	; F45E95  ld XIX,(XIX)
	call	(xix)	; F45E97  call T,XIX
SeqCycle_RunDueDeferredAction_Return:
	ret	; F45E99  ret

; --------------------------------------------------------------------------
; Dispatch_3629 -- 5 pointers, dispatched on (0x3629).
; Read by: one site: the `ld XIX,0x00F45E9A` at 0xF45E87 (a byte scan for
;          the address reports 0xF45E88, that instruction's OPERAND field,
;          one byte in), then `ld A,(0x3629)` / `sll 0x02,XWA` / `add
;          XIX,XWA` / `ld XIX,(XIX)` / `call XIX` at 0xF45E8C-0xF45E97.
; Entry count: 5, and it is fixed TWICE, neither time by dividing a byte
;              extent by a guess.  (a) entries [3] and [4] BOTH hold
;              0xF45EAE, which is the byte immediately after the table, so
;              the table cannot reach past it.  (b) a sixth entry would read
;              0xCA96F00E, which is not an address in this image.
; ⚠ Entries [3] and [4] are DEAD: they point at the instruction the reader
;                                 would fall into anyway.  A whole-image
;                                 linear decode finds (0x3629) written only
;                                 with 0, 1 and 2 (at 0xF569CB, 0xF569F4,
;                                 0xF56A59 and nine more) and compared only
;                                 with 2, so nothing found selects [3] or
;                                 [4].  That is an upper-bound scan over a
;                                 linear decode of the whole image, not a
;                                 proof that no other writer exists.
; Evidence: the five words read out of the ROM; every one of them is an
;           instruction boundary of this transcription, re-asserted on every
;           emit.  The reader's five instructions are quoted above from the
;           same transcription.
; Unknown: what (0x3629) means, and what its three live arms do.
; --------------------------------------------------------------------------
Dispatch_3629:
	.long	SeqCycle_ApplyStartMeasureChange	; [0] -> SeqCycle_ApplyStartMeasureChange
	.long	SeqCycle_OnEndMeasureChanged	; [1] -> SeqCycle_OnEndMeasureChanged
	.long	SeqCycle_RelocateStartAndEnd	; [2] -> SeqCycle_RelocateStartAndEnd
	.long	Dispatch_3629_Nop3	; [3] -> Dispatch_3629_Nop3
	.long	Dispatch_3629_Nop3	; [4] -> Dispatch_3629_Nop3


; --------------------------------------------------------------------------
; Dispatch_3629_Nop3
; Called from: dispatch entry Dispatch_3629[3, 4]
; Touches: nothing with an absolute address
; Evidence: the label is here because it is the address BOTH
;           Dispatch_3629[3] and [4] hold, and the byte immediately after
;           that table -- so it is where the table ends and the code
;           resumes; the address is an instruction boundary of this
;           transcription (re-asserted on every emit)
; Purpose: none -- the entry is a lone `ret`.  Named Dispatch_3629_Nop3 after what reaches it
;          (was sub_F45EAE; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
Dispatch_3629_Nop3:
	ret	; F45EAE  ret

; --------------------------------------------------------------------------
; SeqCycle_ApplyStartMeasureChange
; Called from: dispatch entry Dispatch_3629[0]
; Touches: (0x349F) (0x36D6)
; Calls:   T_CycleRecord_CheckIsRecordTrack T_SeqCycle_LocateToStart Seq_SetTrackBeatsFromTransportB T_CycleRecord_RestartPass
; Evidence: 0xF45EAF is stored in Dispatch_3629, whose reader ends `ld
;           XIX,(XIX) / call XIX`, and it is an instruction boundary of this
;           transcription.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_ApplyStartMeasureChange: Dispatch_3629[0], the deferred step after a CYCLE START measure edit ((0x3629) =
;   0): while transport B is stopped, for track (0x36D6): if CycleRecord_CheckIsRecordTrack says it is not the cycle-record take track,
;   SeqCycle_LocateToStart + Seq_SetTrackBeatsFromTransportB; else T_CycleRecord_RestartPass (CycleRecord_RestartPass, the cycle-record re-setup).
;   [1] (end edited) and [2] (both) are its siblings. Basis: table index + selector writers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
SeqCycle_ApplyStartMeasureChange:
	bit	2, (TransportB_State:8)	; F45EAF  bit 2,(0x96)
	jr	nz, SeqCycle_ApplyStartMeasureChange_Return	; F45EB2  jr NZ,0xf45ed1
	ld	a, (14038:16)	; F45EB4  ld A,(0x36d6)
	ld	(13471:16), a	; F45EB8  ld (0x349f),A
	call	T_CycleRecord_CheckIsRecordTrack	; F45EBC  call 0xf40be4
	cp	a, 0:i3	; F45EC0  cp A,0
	jr	z, SeqCycle_ApplyStartMeasureChange_Skip	; F45EC2  jr Z,0xf45ecd
	call	T_SeqCycle_LocateToStart	; F45EC4  call 0xf40b5c
	calr	Seq_SetTrackBeatsFromTransportB	; F45EC8  calr 0xf44aee
	jr	SeqCycle_ApplyStartMeasureChange_Return	; F45ECB  jr T,0xf45ed1
SeqCycle_ApplyStartMeasureChange_Skip:
	call	T_CycleRecord_RestartPass	; F45ECD  call 0xf40c00
SeqCycle_ApplyStartMeasureChange_Return:
	ret	; F45ED1  ret

; --------------------------------------------------------------------------
; SeqCycle_OnEndMeasureChanged
; Called from: dispatch entry Dispatch_3629[1]
; Touches: (0x349F) (0x36D6)
; Calls:   T_CycleRecord_CheckIsRecordTrack T_SeqCycle_CaptureEndCursors T_CycleRecord_RestartPass
; Evidence: 0xF45ED2 is stored in Dispatch_3629, whose reader ends `ld
;           XIX,(XIX) / call XIX`, and it is an instruction boundary of this
;           transcription.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_OnEndMeasureChanged: Dispatch_3629 arm 1, run when the (0x3628) countdown expires after a cycle screen's
;   END measure was stepped ((0x3629) := 1 next to incw (0x3624) / (0x3620)): with transport B stopped,
;   T_SeqCycle_CaptureEndCursors re-captures the cycle-end cursors; during a cycle-record take (T_CycleRecord_CheckIsRecordTrack = 0 for the
;   record track (0x36D6)) it re-runs T_CycleRecord_RestartPass, the set-up behind CycleRecord_SetUpRecordTrack, instead. Arm 0 (start
;   changed) locates to the start, arm 2 (both) does both. Basis: table index (the writers) + body + sibling arms.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
SeqCycle_OnEndMeasureChanged:
	bit	2, (TransportB_State:8)	; F45ED2  bit 2,(0x96)
	jr	nz, SeqCycle_OnEndMeasureChanged_Return	; F45ED5  jr NZ,0xf45ef1
	ld	a, (14038:16)	; F45ED7  ld A,(0x36d6)
	ld	(13471:16), a	; F45EDB  ld (0x349f),A
	call	T_CycleRecord_CheckIsRecordTrack	; F45EDF  call 0xf40be4
	cp	a, 0:i3	; F45EE3  cp A,0
	jr	z, SeqCycle_OnEndMeasureChanged_Skip	; F45EE5  jr Z,0xf45eed
	call	T_SeqCycle_CaptureEndCursors	; F45EE7  call 0xf40b60
	jr	SeqCycle_OnEndMeasureChanged_Return	; F45EEB  jr T,0xf45ef1
SeqCycle_OnEndMeasureChanged_Skip:
	call	T_CycleRecord_RestartPass	; F45EED  call 0xf40c00
SeqCycle_OnEndMeasureChanged_Return:
	ret	; F45EF1  ret

; --------------------------------------------------------------------------
; SeqCycle_RelocateStartAndEnd
; Called from: dispatch entry Dispatch_3629[2]
; Touches: (0x349F) (0x36D6)
; Calls:   T_CycleRecord_CheckIsRecordTrack T_SeqCycle_LocateToStart T_SeqCycle_CaptureEndCursors Seq_SetTrackBeatsFromTransportB T_CycleRecord_RestartPass
; Evidence: 0xF45EF2 is stored in Dispatch_3629, whose reader ends `ld
;           XIX,(XIX) / call XIX`, and it is an instruction boundary of this
;           transcription.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_RelocateStartAndEnd: Arm 2 of Dispatch_3629, run by SeqCycle_RunDueDeferredAction when the (0x3628) countdown reaches 0x80.
;   With transport B stopped and (0x349F) := (0x36D6): unless CycleRecord_CheckIsRecordTrack (T_CycleRecord_CheckIsRecordTrack) returns 0 -- a cycle-record take
;   armed on that track, which runs CycleRecord_RestartPass (T_CycleRecord_RestartPass) instead -- relocates to the cycle start, recaptures the end
;   cursors and re-latches the track beats. The CYCLE RECORD start editor arms it after forcing END := START. Basis:
;   table index + body + setter. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SeqCycle_RelocateStartAndEnd:
	bit	2, (TransportB_State:8)	; F45EF2  bit 2,(0x96)
	jr	nz, SeqCycle_RelocateStartAndEnd_Return	; F45EF5  jr NZ,0xf45f18
	ld	a, (14038:16)	; F45EF7  ld A,(0x36d6)
	ld	(13471:16), a	; F45EFB  ld (0x349f),A
	call	T_CycleRecord_CheckIsRecordTrack	; F45EFF  call 0xf40be4
	cp	a, 0:i3	; F45F03  cp A,0
	jr	z, SeqCycle_RelocateStartAndEnd_Skip	; F45F05  jr Z,0xf45f14
	call	T_SeqCycle_LocateToStart	; F45F07  call 0xf40b5c
	call	T_SeqCycle_CaptureEndCursors	; F45F0B  call 0xf40b60
	calr	Seq_SetTrackBeatsFromTransportB	; F45F0F  calr 0xf44aee
	jr	SeqCycle_RelocateStartAndEnd_Return	; F45F12  jr T,0xf45f18
SeqCycle_RelocateStartAndEnd_Skip:
	call	T_CycleRecord_RestartPass	; F45F14  call 0xf40c00
SeqCycle_RelocateStartAndEnd_Return:
	ret	; F45F18  ret

; --------------------------------------------------------------------------
; sub_F45F19
; Called from: in-module: 0xF44D31
; Touches: (0x3004) (0x3008) (0x3456) (0x3458)  |  0x000000
; Calls:   sub_F45F4B
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45F19 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F45F19:
	ld	xwa, (12292:16)	; F45F19  ld XWA,(0x3004)
	cp	xwa, 0	; F45F1D  cp XWA,0x00000000
	jr	nz, sub_F45F19_Skip	; F45F23  jr NZ,0xf45f31
	ld	xwa, (12296:16)	; F45F25  ld XWA,(0x3008)
	cp	xwa, 0	; F45F29  cp XWA,0x00000000
	jr	z, sub_F45F19_Return	; F45F2F  jr Z,0xf45f4a
sub_F45F19_Skip:
	ld	wa, (TransportB_Beat:8)	; F45F31  ld WA,(0x91)
	cp	wa, (0x3456:16)	; F45F34  cp WA,(0x3456)
	jr	c, sub_F45F19_Return	; F45F38  jr C,0xf45f4a
	ld	wa, (TransportB_Beat:8)	; F45F3A  ld WA,(0x91)
	sub	wa, (0x3456:16)	; F45F3D  sub WA,(0x3456)
	cp	(13400:16), a	; F45F41  cp (0x3458),A
	jr	ugt, sub_F45F19_Return	; F45F45  jr UGT,0xf45f4a
	calr	sub_F45F4B	; F45F47  calr 0xf45f4b
sub_F45F19_Return:
	ret	; F45F4A  ret

; --------------------------------------------------------------------------
; sub_F45F4B
; Called from: in-module: 0xF45F47
; Touches: (0x207A) (0x3456) (0x34B8) (0x3552) (0x361E) (0x3620) (0x3622)
;          (0x3624) (0x3731)
; Calls:   sub_F4603C SeqCycle_CheckOn SeqScreen_RepaintIfPlayOrRecord
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45F4B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F45F4B:
	calr	sub_F4603C	; F45F4B  calr 0xf4603c
	cpw	(0x3552:16), 0x03e7	; F45F4E  cp (0x3552),0x03e7
	jr	nc, sub_F45F4B_Skip3	; F45F54  jr NC,0xf45fa6
	calr	SeqCycle_CheckOn	; F45F56  calr 0xf448c6
	cp	a, 0:i3	; F45F59  cp A,0
	jr	nz, sub_F45F4B_Skip2	; F45F5B  jr NZ,0xf45f9b
	cp	(UI_ScreenLatch:16), 0x06	; F45F5D  cp (0x207a),0x06
	jr	z, sub_F45F4B_Skip	; F45F62  jr Z,0xf45f7f
	cp	(UI_ScreenLatch:16), 0x08	; F45F64  cp (0x207a),0x08
	jr	z, sub_F45F4B_Skip	; F45F69  jr Z,0xf45f7f
	ld	wa, (13856:16)	; F45F6B  ld WA,(0x3620)
	cp	(0x3552:16), wa	; F45F6F  cp (0x3552),WA
	jr	nz, sub_F45F4B_Skip2	; F45F73  jr NZ,0xf45f9b
	ld	wa, (13854:16)	; F45F75  ld WA,(0x361e)
	ld	(13650:16), wa	; F45F79  ld (0x3552),WA
	jr	sub_F45F4B_Join	; F45F7D  jr T,0xf45f9f
sub_F45F4B_Skip:
	res	0, (0x3731:16)	; F45F7F  res 0,(0x3731)
	ld	wa, (13860:16)	; F45F83  ld WA,(0x3624)
	cp	(0x3552:16), wa	; F45F87  cp (0x3552),WA
	jr	nz, sub_F45F4B_Skip2	; F45F8B  jr NZ,0xf45f9b
	ld	wa, (13858:16)	; F45F8D  ld WA,(0x3622)
	ld	(13650:16), wa	; F45F91  ld (0x3552),WA
	set	4, (0x34b8:16)	; F45F95  set 4,(0x34b8)
	jr	sub_F45F4B_Join	; F45F99  jr T,0xf45f9f
sub_F45F4B_Skip2:
	incw	1, (13650:16)	; F45F9B  incw 1,(0x3552)
sub_F45F4B_Join:
	ld	wa, (13650:16)	; F45F9F  ld WA,(0x3552)
	calr	SeqScreen_RepaintIfPlayOrRecord	; F45FA3  calr 0xf45fe5
sub_F45F4B_Skip3:
	ld	wa, (TransportB_Beat:8)	; F45FA6  ld WA,(0x91)
	ld	(13398:16), wa	; F45FA9  ld (0x3456),WA
	ret	; F45FAD  ret

; --------------------------------------------------------------------------
; Var20A9_SetBits01
; Called from: T_Var20A9_SetBits01 (x0); in-module: 0xF44ADA 0xF45740
; Touches: (0x20A9)
; Evidence: thunk slot T_Var20A9_SetBits01 holds `jp 0x00F45FAE`, and 0xF45FAE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Var20A9_SetBits01: m_or_mi8 MB16, 0x20a9, 0x01 (single-cell template; the cell's meaning is not established unless it is named)
Var20A9_SetBits01:		; <- T_Var20A9_SetBits01
	or	(0x20a9:16), 0x01	; F45FAE  or (0x20a9),0x01
	ret	; F45FB3  ret

; --------------------------------------------------------------------------
; UiStatus_ShowMessage0E
; Called from: T_UiStatus_ShowMessage0E (x3)
; Touches: (0x2070) (0x2071) (0x2880)
; Evidence: thunk slot T_UiStatus_ShowMessage0E holds `jp 0x00F45FB4`, and 0xF45FB4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; UiStatus_ShowMessage0E: UI_StatusCode = 14, UI_Request = 0xAB, UI_Request_Hi |= 0x40 (the status-message request SysExDump_ShowStatusMessage also makes).
UiStatus_ShowMessage0E:		; <- T_UiStatus_ShowMessage0E
	ld	(UI_StatusCode:16), 14	; F45FB4  ld (0x2880),0x0e
	ld	(UI_Request:16), 171	; F45FB9  ld (0x2070),0xab
	or	(UI_Request_Hi:16), 0x40	; F45FBE  or (0x2071),0x40
	ret	; F45FC3  ret

; --------------------------------------------------------------------------
; Var34D1_SetBits20
; Called from: T_Var34D1_SetBits20 (x2); in-module: 0xF458DC
; Touches: (0x34D1)
; Evidence: thunk slot T_Var34D1_SetBits20 holds `jp 0x00F45FC4`, and 0xF45FC4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Var34D1_SetBits20: m_or_mi8 MB16, 0x34d1, 0x20 (single-cell template; the cell's meaning is not established unless it is named)
Var34D1_SetBits20:		; <- T_Var34D1_SetBits20
	or	(0x34d1:16), 0x20	; F45FC4  or (0x34d1),0x20
	ret	; F45FC9  ret

; --------------------------------------------------------------------------
; Seq_ShowMemoryFullOnRequest
; Called from: in-module: 0xF445CF
; Touches: (0x2070) (0x2071) (0x2880) (0x34D1)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF45FCA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_ShowMemoryFullOnRequest: Consumes (0x34D1) bit 5 (Var34D1_SetBits20, posted by EditScreen_FlagMemoryFull and by
;   SeqRecord_AllocTakeChains when the block store runs out): clears it, UI_StatusCode := 0x0F and UI_Request := 0x40AB -- the song-
;   memory-full message pair. Called each pass by Seq_MainLoopService. Basis: caller + body + producers.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
Seq_ShowMemoryFullOnRequest:
	bit	5, (0x34d1:16)	; F45FCA  bit 5,(0x34d1)
	jr	z, Seq_ShowMemoryFullOnRequest_Return	; F45FCE  jr Z,0xf45fe4
	and	(0x34d1:16), 0xdf	; F45FD0  and (0x34d1),0xdf
	ld	(UI_StatusCode:16), 15	; F45FD5  ld (0x2880),0x0f
	ld	(UI_Request:16), 171	; F45FDA  ld (0x2070),0xab
	or	(UI_Request_Hi:16), 0x40	; F45FDF  or (0x2071),0x40
Seq_ShowMemoryFullOnRequest_Return:
	ret	; F45FE4  ret

; --------------------------------------------------------------------------
; SeqScreen_RepaintIfPlayOrRecord
; Called from: T_SeqScreen_RepaintIfPlayOrRecord (x0); in-module: 0xF4470D 0xF44BCD 0xF44D19 0xF44D26
;              0xF44D63 0xF45228 0xF45FA3
; Touches: (0x207C)
; Calls:   UiScreenFlags_SetRepaintInPlace
; Evidence: thunk slot T_SeqScreen_RepaintIfPlayOrRecord holds `jp 0x00F45FE5`, and 0xF45FE5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqScreen_RepaintIfPlayOrRecord: Sets UI_ScreenFlags bit 4 (repaint in place, through UiScreenFlags_SetRepaintInPlace) when UI_ScreenId
;   is one of the six screens that show the song position: 0x06 REALTIME RECORD, 0x08 CYCLE RECORD, 0x12 SEQ PLAY,
;   0x14 CYCLE PLAY and the cycle-play screens 0x26 / 0x29 of NOTE / DRUM EDIT. Run after the position moves:
;   Seq_LocateToSongPosition, Seq_ResetPositionToSongStart and the count-in bar code sub_F44CEA. Basis: callers + body
;   + screen-id table. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
SeqScreen_RepaintIfPlayOrRecord:		; <- T_SeqScreen_RepaintIfPlayOrRecord
	cp	(UI_ScreenId:16), 0x26	; F45FE5  cp (0x207c),0x26
	jr	z, SeqScreen_RepaintIfPlayOrRecord_Skip	; F45FEA  jr Z,0xf46011
	cp	(UI_ScreenId:16), 0x29	; F45FEC  cp (0x207c),0x29
	jr	z, SeqScreen_RepaintIfPlayOrRecord_Skip	; F45FF1  jr Z,0xf46011
	cp	(UI_ScreenId:16), 0x12	; F45FF3  cp (0x207c),0x12
	jr	z, SeqScreen_RepaintIfPlayOrRecord_Skip	; F45FF8  jr Z,0xf46011
	cp	(UI_ScreenId:16), 0x14	; F45FFA  cp (0x207c),0x14
	jr	z, SeqScreen_RepaintIfPlayOrRecord_Skip	; F45FFF  jr Z,0xf46011
	cp	(UI_ScreenId:16), 0x06	; F46001  cp (0x207c),0x06
	jr	z, SeqScreen_RepaintIfPlayOrRecord_Skip	; F46006  jr Z,0xf46011
	cp	(UI_ScreenId:16), 0x08	; F46008  cp (0x207c),0x08
	jr	z, SeqScreen_RepaintIfPlayOrRecord_Skip	; F4600D  jr Z,0xf46011
	jr	SeqScreen_RepaintIfPlayOrRecord_Return	; F4600F  jr T,0xf46014
SeqScreen_RepaintIfPlayOrRecord_Skip:
	calr	UiScreenFlags_SetRepaintInPlace	; F46011  calr 0xf46015
SeqScreen_RepaintIfPlayOrRecord_Return:
	ret	; F46014  ret

; --------------------------------------------------------------------------
; UiScreenFlags_SetRepaintInPlace
; Called from: T_UiScreenFlags_SetRepaintInPlace (x0); in-module: 0xF44C2E 0xF46011 0xF46037
; Touches: (0x2070) (0x2071) (0x2095)
; Evidence: thunk slot T_UiScreenFlags_SetRepaintInPlace holds `jp 0x00F46015`, and 0xF46015 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; UiScreenFlags_SetRepaintInPlace: UI_ScreenFlags |= 0x10 -- bit 4, "repaint in place" (the ENTER methods test it to
;   repaint values without a full redraw). CountIn_SetMeasureToFirstBar runs it after changing the current measure;
;   also called by sub_F44C15 and SeqScreen_RepaintIfPlayOrRecord. Basis: callers + body + RAM name. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
UiScreenFlags_SetRepaintInPlace:		; <- T_UiScreenFlags_SetRepaintInPlace
	or	(UI_ScreenFlags:16), 0x10	; F46015  or (0x2095),0x10
	ret	; F4601A  ret
	ld	(UI_Request:16), 1	; F4601B  ld (0x2070),0x01
	or	(UI_Request_Hi:16), 0x02	; F46020  or (0x2071),0x02
	ret	; F46025  ret

; --------------------------------------------------------------------------
; UiRequest_Post08
; Called from: in-module: 0xF453E1
; Touches: (0x2070) (0x2071)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF46026 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; UiRequest_Post08: UI_Request = 8, UI_Request_Hi |= 0x02.
UiRequest_Post08:
	ld	(UI_Request:16), 8	; F46026  ld (0x2070),0x08
	or	(UI_Request_Hi:16), 0x02	; F4602B  or (0x2071),0x02
	ret	; F46030  ret

; --------------------------------------------------------------------------
; CountIn_SetMeasureToFirstBar
; Called from: T_CountIn_SetMeasureToFirstBar (x2)
; Touches: (0x3552)
; Calls:   UiScreenFlags_SetRepaintInPlace
; Evidence: thunk slot T_CountIn_SetMeasureToFirstBar holds `jp 0x00F46031`, and 0xF46031 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CountIn_SetMeasureToFirstBar: Current measure (0x3552) := 0x8002 (bit 15 = count-in) and UI_ScreenFlags bit 4
;   (repaint in place, UiScreenFlags_SetRepaintInPlace). Run by the count-in branch of both Transport_StartAll* starts; sub_F44CEA later
;   sets 0x8001 at TransportA_Bar 1 and restores the real measure from (0x36D4). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
CountIn_SetMeasureToFirstBar:		; <- T_CountIn_SetMeasureToFirstBar
	ldw	(13650:16), 32770	; F46031  ld (0x3552),0x8002
	call	UiScreenFlags_SetRepaintInPlace	; F46037  call 0xf46015
	ret	; F4603B  ret

; --------------------------------------------------------------------------
; sub_F4603C
; Called from: T_F40AC0 (x1); in-module: 0xF45F4B
; Touches: (0x0DE3) (0x3458) (0x3754)
; Evidence: thunk slot T_F40AC0 holds `jp 0x00F4603C`, and 0xF4603C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4603C:		; <- T_F40AC0
	bit	7, (0x3754:16)	; F4603C  bit 7,(0x3754)
	jr	z, sub_F4603C_Return	; F46040  jr Z,0xf46073
	and	(0x3754:16), 0x7f	; F46042  and (0x3754),0x7f
	ld	a, (14164:16)	; F46047  ld A,(0x3754)
	inc	1, a	; F4604B  inc 1,A
	ld	(TransportA_BeatsPerBar:24), a	; F4604D  ld (0x605000),A
	ld	(13400:16), a	; F46052  ld (0x3458),A
	ld	(3555:16), a	; F46056  ld (0x0de3),A
	ld	(6304983:24), a	; F4605A  ld (0x6034d7),A
	bit	2, (TransportA_State:8)	; F4605F  bit 2,(0x94)
	jr	z, sub_F4603C_Skip	; F46062  jr Z,0xf46070
	cp	(TransportA_Beat:8), 0x00	; F46064  cp (0x8c),0x00
	jr	nz, sub_F4603C_Return	; F46068  jr NZ,0xf46073
	cp	(TransportA_Tick:8), 0x5f	; F4606A  cp (0x8b),0x5f
	jr	nc, sub_F4603C_Return	; F4606E  jr NC,0xf46073
sub_F4603C_Skip:
	ld	(0xc3:8), a	; F46070  ld (0xc3),A
sub_F4603C_Return:
	ret	; F46073  ret

; --------------------------------------------------------------------------
; WorkspaceDefaults -- 161 bytes, the source of the copy loops that seed the
;                      banked 3 KiB workspace at 0x00603400 -- the same
;                      workspace notes/FINDINGS-prom_b-block-store.md
;                      derives.
; Extent: 0xF46074-0xF46114.  The start is where the last code segment's
;         decode ends; the end is where 5,867 bytes of 0x0E begin, and
;         0xF46114 is the byte before them and is 0x48, NOT 0x0E -- so
;         unlike most pad boundaries in this image there is no `ret`-versus-
;         padding ambiguity here.
; Read by: 15 `ld XIX,0x00F460xx` sites in this module: 0xF44051 (src
;          0xF4608A), 0xF44070 (src 0xF46084), 0xF442EC (src 0xF460B2),
;          0xF442F8 (src 0xF460C3), 0xF44319 (src 0xF46074), 0xF4433C (src
;          0xF4607C), 0xF4436F (src 0xF46074), 0xF44392 (src 0xF4607C),
;          0xF444EC (src 0xF46090), 0xF446AE (src 0xF460EB), 0xF45D2D (src
;          0xF460A1), 0xF45D55 (src 0xF460B2), 0xF45D61 (src 0xF460D4),
;          0xF45E25 (src 0xF460B2), 0xF45E31 (src 0xF460D4).
; Two blocks are ESTABLISHED, by reading their loops verbatim: 0xF46074 ->
;                                                              0x00603400,
;                                                              EIGHT bytes
;                                                              (`ld
;                                                              A,(XIX+IY)` /
;                                                              `ld
;                                                              (XHL+IY),A` /
;                                                              `inc 1,IY` /
;                                                              `cp IY,7` /
;                                                              `jr ULE`, so
;                                                              IY takes
;                                                              0..7), from
;                                                              the sites at
;                                                              0xF44319 and
;                                                              0xF4436F; and
;                                                              0xF4607C ->
;                                                              0x00603414,
;                                                              also EIGHT
;                                                              bytes but a
;                                                              WORD loop
;                                                              (`ld
;                                                              WA,(XIX+IY)`
;                                                              / `add
;                                                              IY,0x0002` /
;                                                              `cp
;                                                              IY,0x0008` /
;                                                              `jr C`), from
;                                                              0xF4433C.
; ⚠ NOT ESTABLISHED: how the other 13 bytes are partitioned.  The loops in
;                    this module differ in stride (byte and word) and in
;                    bound form (`cp IY,n / jr ULE` and `cp IY,n / jr C`),
;                    and the two do not mean the same count; an automated
;                    read of them gave NINE bytes for the 0xF4607C block
;                    where the instructions say eight.  Rather than ship a
;                    partition that a mechanical reader got wrong once, the
;                    object is emitted as one labelled run of bytes and the
;                    gap is stated.
; Evidence: the 15 `ld XIX` sites are read out of this transcription's own
;           decoded comments, and the destination 0x00603400 comes from the
;           `ld XHL,0x00603400` two instructions in front of the first of
;           them.  All 161 bytes are re-read from the ROM on every emit.
; Unknown: what the fields mean.
; --------------------------------------------------------------------------
WorkspaceDefaults:
	.byte	0x5A, 0x5A, 0x5A, 0x5A, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x20, 0x00, 0x00, 0x0A	; F46074  [0..15]
	.byte	0x00, 0x78, 0x61, 0x00, 0x0C, 0x05, 0x00, 0x78, 0x61, 0x00, 0x0C, 0x05, 0x00, 0x01, 0x02, 0x03	; F46084  [16..31]
	.byte	0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20, 0x00, 0x01, 0x02	; F46094  [32..47]
	.byte	0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20, 0x20, 0x20	; F460A4  [48..63]
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x00	; F460B4  [64..79]
	.byte	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20	; F460C4  [80..95]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F460D4  [96..111]
	.byte	0x20, 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0x00, 0x18, 0x30, 0x48, 0x06, 0x07, 0x08, 0x09, 0x0A	; F460E4  [112..127]
	.byte	0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09	; F460F4  [128..143]
	.byte	0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20, 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0x00, 0x18, 0x30	; F46104  [144..159]
	.byte	0x48	; F46114  [160..160]

	.fill	5867, 1, 0x0E	; F46115-F477FF  `ret` padding (asserted pure 0x0E)
