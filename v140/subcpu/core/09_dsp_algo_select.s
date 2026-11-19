; =============================================================================
; DSP_AlgoSelect -- Select DSP algorithm for a voice slot
; =============================================================================
; Allocates a DSP algorithm slot in the voice structure array at 0x041368.
; Multiplies algo index by 0x11F (287 bytes per voice), sets bit 0 of flags
; to mark as allocated, configures the DSP processing chain.
; Validates algo sub-type < 0x28 (40); returns error code 2 on failure.
; Called from DSP_Cmd2B_AlgoSelect (sub-command 0x00 in Audio_Process_DSP).
; Input A = part, BC = algorithm number, XDE = one-byte status buffer.
; Rejects algorithm numbers >= 0x28 by writing status 2.  Otherwise, if the part is not yet
; allocated it allocates it exactly like VoiceAlloc_InitNewAllocation (set PART+0x00 bit 0,
; VoiceParam_FullSetup, WaveSel_Rebuild_PartCaches with PART+0x19 / PART+0x1A); if it already was
; allocated it instead calls DSP_AdjustVoiceParams.  Either way it then calls
; DSP_WriteAlgoBuffer (0x03522E) and DSP_VoiceState_Dispatch (0x035490) with WA = BC = 0xFF,
; writes status 0 and returns HL = 1.
; Callers: 0x031822 (DSP_SetCoeff_MasterConfig) and 0x035BEA (AUDIO_PROCESS_DSP).
DSP_AlgoSelect:	.include "includes/generated/cc900/DSP_AlgoSelect.s"	; C: cc900/dsp_algo_select_b_7j.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_AlgoSelect_AlreadyAllocated, DSP_AlgoSelect + 84
	.set	DSP_AlgoSelect_WriteAndDispatch, DSP_AlgoSelect + 96
	.set	DSP_AlgoSelect_InvalidParam, DSP_AlgoSelect + 126
	.set	DSP_AlgoSelect_Return, DSP_AlgoSelect + 132

; DSP_MixSendConfig -- Configure DSP mix/send routing
; Copies 0x11 bytes of routing data via ToneDB_Find_ToneRecord.
; Input XDE = destination buffer.  Calls ToneDB_Find_ToneRecord (0x03206F) and copies the
; first 0x11 bytes of the returned buffer into the caller's buffer.  Callers: 0x031847 and
; AUDIO_PROCESS_DSP at 0x035CB8.
DSP_MixSendConfig:	.include "includes/generated/cc900/DSP_MixSendConfig.s"	; C: cc900/dsp_algo_select_l_16a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_MixSendConfig_CopyLoop, DSP_MixSendConfig + 18
	.set	DSP_MixSendConfig_Return, DSP_MixSendConfig + 30

; ----------------------------------------------------------------------------
; DSP_RouteCoeffs_TypeA - Route DSP coefficients via type-A table
; Entry: WA = voice parameter (masked to 7 bits)
;        BC = channel/type packed (low 4 bits = channel, bits 6-7 = type)
; Notes: 4-way dispatch based on type bits to select coefficient table
;        Table offsets: 0x44/0x48/0x4C from routing config at (0x45314)
;        Computes index: (channel << 7 + voice) * 2
;        Copies 13 bytes from source to DSP buffer at 0x45210
; ----------------------------------------------------------------------------
; Input WA = a 7-bit index, BC = a selector whose bits 7:6 pick one of four descriptor
; pointers and whose bits 3:0 form the high part of a table index.
; Reads a long pointer from (0x045314)+0x44/+0x48/+0x4C (bits 7:6 = 0/1/2, and 3 aliases 0),
; adds the window base (0x045310), fetches a word at ((BC & 0x0F) << 7 | WA) * 2, and uses
; that word as a 16-byte-stride row index into the block at (0x045314)+0x50.  Copies 0x0D
; bytes of the selected row into the staging buffer at 0x045210+6.
; Caller: 0x031865.
DSP_RouteCoeffs_TypeA:	.include "includes/generated/cc900/DSP_RouteCoeffs_TypeA.s"	; C: cc900/dsp_algo_select.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_RouteCoeffs_TypeA_Sel1, DSP_RouteCoeffs_TypeA + 47
	.set	DSP_RouteCoeffs_TypeA_Sel2, DSP_RouteCoeffs_TypeA + 57
	.set	DSP_RouteCoeffs_TypeA_Sel3, DSP_RouteCoeffs_TypeA + 67
	.set	DSP_RouteCoeffs_TypeA_Fetch, DSP_RouteCoeffs_TypeA + 75
	.set	DSP_RouteCoeffs_TypeA_CopyLoop, DSP_RouteCoeffs_TypeA + 121
	.set	DSP_RouteCoeffs_TypeA_Epilogue, DSP_RouteCoeffs_TypeA + 161
; ----------------------------------------------------------------------------
; DSP_RouteCoeffs_TypeB - Route DSP coefficients via type-B table
; Entry: Same as TypeA
; Notes: Same algorithm as TypeA with different table offsets (0x58-0x64)
; ----------------------------------------------------------------------------
; Structural twin of DSP_RouteCoeffs_TypeA using the second descriptor set:
; pointers at (0x045314)+0x58/+0x5C/+0x60 and the row block at (0x045314)+0x64.
; Caller: 0x031883.  The ELF already carries this name; the reference file simply lacks the
; line, so this is an "add", not a supersede.
DSP_RouteCoeffs_TypeB:	.include "includes/generated/cc900/DSP_RouteCoeffs_TypeB.s"	; C: cc900/dsp_algo_select.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_RouteCoeffs_TypeB_Sel1, DSP_RouteCoeffs_TypeB + 47
	.set	DSP_RouteCoeffs_TypeB_Sel2, DSP_RouteCoeffs_TypeB + 57
	.set	DSP_RouteCoeffs_TypeB_Sel3, DSP_RouteCoeffs_TypeB + 67
	.set	DSP_RouteCoeffs_TypeB_Fetch, DSP_RouteCoeffs_TypeB + 75
	.set	DSP_RouteCoeffs_TypeB_CopyLoop, DSP_RouteCoeffs_TypeB + 121
	.set	DSP_RouteCoeffs_TypeB_Epilogue, DSP_RouteCoeffs_TypeB + 161
; ----------------------------------------------------------------------------
; DSP_CopyCoeffs_TypeA - Direct coefficient copy (type A)
; Entry: WA = voice parameter
; Notes: Direct copy without 4-way dispatch, uses offset 0x50
;        Copies 13 bytes from source to DSP buffer at 0x45210
; ----------------------------------------------------------------------------
; Input WA = row number.  Copies 0x0D bytes of that row out of the block at (0x045314)+0x50
; (16-byte stride, offset by the window base at 0x045310) into the staging buffer at
; 0x045210+6.  Same arithmetic as DSP_RouteCoeffs_TypeA but with the row supplied directly
; instead of looked up through a descriptor.  Caller: 0x0318A2.
DSP_CopyCoeffs_TypeA:	.include "includes/generated/cc900/DSP_CopyCoeffs_TypeA.s"	; C: cc900/dsp_algo_select.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_CopyCoeffs_TypeA_Loop, DSP_CopyCoeffs_TypeA + 25
	.set	DSP_CopyCoeffs_TypeA_Return, DSP_CopyCoeffs_TypeA + 65
; ----------------------------------------------------------------------------
; DSP_CopyCoeffs_TypeB - Direct coefficient copy (type B)
; Entry: WA = voice parameter
; Notes: Direct copy without 4-way dispatch, uses offset 0x64
;        Copies 13 bytes from source to DSP buffer at 0x45210
; ----------------------------------------------------------------------------
; The (0x045314)+0x64 flavour of DSP_CopyCoeffs_TypeA.  Caller: 0x0318C1.
DSP_CopyCoeffs_TypeB:	.include "includes/generated/cc900/DSP_CopyCoeffs_TypeB.s"	; C: cc900/dsp_algo_select.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_CopyCoeffs_TypeB_Loop, DSP_CopyCoeffs_TypeB + 25
	.set	DSP_CopyCoeffs_TypeB_Return, DSP_CopyCoeffs_TypeB + 65
; ----------------------------------------------------------------------------
; DSP_VoiceCoeffRoute - Voice-specific coefficient routing
; Entry: A = voice number, C = channel (low 4 bits)
; Notes: Looks up voice allocation at 0x41368 (voice * 287 + chan * 37 + 110)
;        Reads routing type from allocation entry byte 2 (bits 6-7)
;        4-way dispatch to select coefficient source table
;        Copies 13 coefficient bytes + 3 extra config bytes
;        Extra bytes: voice DE value (low, 0x00, high >> 8)
; ----------------------------------------------------------------------------
; Input A = part, C = slot (low nibble).  Resolves the slot descriptor at
; PART + 0x6E + slot*0x25 (long pointer), takes the row index from descriptor bytes +0x02
; (low 7 bits) and +0x03 (low nibble), selects a descriptor pointer from (0x045314)+0x44/
; +0x48/+0x4C according to bits 7:6 of descriptor+0x03, and copies 0x0D coefficient bytes
; plus three trailing bytes into 0x045210+6.  Caller: 0x0318DF.
DSP_VoiceCoeffRoute:	.include "includes/generated/cc900/DSP_VoiceCoeffRoute.s"	; C: cc900/dsp_algo_select_ap_24a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_VoiceCoeffRoute_Sel1, DSP_VoiceCoeffRoute + 177
	.set	DSP_VoiceCoeffRoute_Sel2, DSP_VoiceCoeffRoute + 187
	.set	DSP_VoiceCoeffRoute_Sel3, DSP_VoiceCoeffRoute + 197
	.set	DSP_VoiceCoeffRoute_Fetch, DSP_VoiceCoeffRoute + 205
	.set	DSP_VoiceCoeffRoute_CopyLoop, DSP_VoiceCoeffRoute + 251
	.set	DSP_VoiceCoeffRoute_Epilogue, DSP_VoiceCoeffRoute + 291
; ----------------------------------------------------------------------------
; DSP_VoiceCoeffRoute2 - Voice coefficient routing (variant 2)
; Entry: A = voice number, C = channel/type packed
; Notes: Similar to DSP_VoiceCoeffRoute but extracts both channel
;        and type from C (low 4 = channel, high 4 >> 4 = type)
;        Uses prevbank registers (D7 prefix) for extended operations
;        Multiple nested table lookups with different coefficient sets
;        Includes filter and vibrato coefficient routing
; ----------------------------------------------------------------------------
; Input A = part, C = packed (slot in the low nibble, sub-index in the high nibble).
; Follows the slot record's SECOND pointer (slotrec+0x04) and indexes it by
; sub-index*2 + 3 to obtain the row index, then does the DSP_VoiceCoeffRoute copy through the
; (0x045314)+0x58/+0x5C/+0x60 descriptor set and the +0x64 row block.  Caller: 0x0318FD.
DSP_VoiceCoeffRoute2:	.include "includes/generated/cc900/DSP_VoiceCoeffRoute2.s"	; C: cc900/dsp_algo_select_t_18c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_VoiceCoeffRoute2_Sel1, DSP_VoiceCoeffRoute2 + 240
	.set	DSP_VoiceCoeffRoute2_Sel2, DSP_VoiceCoeffRoute2 + 250
	.set	DSP_VoiceCoeffRoute2_Sel3, DSP_VoiceCoeffRoute2 + 260
	.set	DSP_VoiceCoeffRoute2_Fetch, DSP_VoiceCoeffRoute2 + 268
	.set	DSP_VoiceCoeffRoute2_CopyLoop, DSP_VoiceCoeffRoute2 + 316
	.set	DSP_VoiceCoeffRoute2_Epilogue, DSP_VoiceCoeffRoute2 + 356
; ----------------------------------------------------------------------------
; DSP_AlgoCoeffLookup - Algorithm-based coefficient table lookup
; Entry: A = algorithm number (0-4)
; Notes: 5-way dispatch based on algorithm (0-4) to select table
;        Tables at config offsets: 0x54, 0x70, 0x7C, 0x88-0x98
;        Reads entry count from byte 2 of selected table entry
;        Copies coefficient data to DSP buffer at 0x45210
; ----------------------------------------------------------------------------
; Input A = bank 0..4.  Selects one of five descriptor blocks hanging off (0x045314) and
; copies (block+0x02)+3 bytes of it into the staging buffer at 0x045210+6 -- i.e. the block
; carries its own length in its third byte.  Caller: 0x03190D.
DSP_AlgoCoeffLookup:
	cp	a, 4:i3
	jr	z, DSP_AlgoCoeffLookup_Bank4
	cp	a, 3:i3
	jr	z, DSP_AlgoCoeffLookup_Bank3
	cp	a, 2:i3
	jr	z, DSP_AlgoCoeffLookup_Bank2
	cp	a, 1:i3
	jr	z, DSP_AlgoCoeffLookup_Bank1
	cp	a, 0:i3
	jr	nz, DSP_AlgoCoeffLookup_BankDefault
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+84)
	jr	t, DSP_AlgoCoeffLookup_CopyLoop
; Bank 1 -> (0x045314)+0x68.
DSP_AlgoCoeffLookup_Bank1:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+104)
	jr	t, DSP_AlgoCoeffLookup_CopyLoop
; Bank 2 -> (0x045314)+0x0084.
DSP_AlgoCoeffLookup_Bank2:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+132)
	jr	t, DSP_AlgoCoeffLookup_CopyLoop
; Bank 3 -> (0x045314)+0x0090.
DSP_AlgoCoeffLookup_Bank3:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+144)
	jr	t, DSP_AlgoCoeffLookup_CopyLoop
; Bank 4 -> (0x045314)+0x0098.
DSP_AlgoCoeffLookup_Bank4:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+152)
	jr	t, DSP_AlgoCoeffLookup_CopyLoop
; Bank 0 or out of range -> (0x045314)+0x54.
DSP_AlgoCoeffLookup_BankDefault:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+84)
; Copies (block+0x02)+3 bytes from the selected block into 0x045210+6; the length is stored
; in the block's own third byte.
DSP_AlgoCoeffLookup_CopyLoop:
	ld	xwa, (ToneDB_RelBase:24)
	add	xwa, xix
	ld	xix, xwa
	ld	a, (xwa+2)
	inc	3, a
	ld	l, a
	extz	hl
	ld	de, 0:i3
	cp	de, hl
	ret	nc
DSP_AlgoCoeffLookup_Loop:
	ld	wa, de
	extz	xwa
	ld	xbc, xix
	add	xbc, xwa
	ld	wa, de
	inc	6, wa
	extz	xwa
	ld	xiy, Payload_Bss_Start+0x639a
	add	xiy, xwa
	ld	a, (xbc)
	ld	(xiy), a
	inc	1, de
	cp	de, hl
	jr	c, DSP_AlgoCoeffLookup_Loop
	ret

