; ============================================================================
; AUDIO SYSTEM INITIALIZATION
; Main initialization routine for all audio subsystems:
;   - Inter-CPU communication setup
;   - Serial port ring buffers
;   - DSP chip configuration (dual DSPs at 0x00130000)
;   - Tone generator initialization (at 0x00110000)
; ============================================================================
Audio_System_Init:	; 01FACBh
	pushw iz
	call InterCPU_Latch_Setup	; Setup inter-CPU comms via latches
	call INIT_RING_BUFFERS	; Initialize serial port #1 ring buffers
	call DSP_System_Init	; Initialize DSP state buffers, toggle reset signals
	call DSP2_Init	; Initialize DSP2 (second DSP chip)
	call DSP_Init_Channels	; Write channel config to DSP at 0x00130000
	call ToneGen_Init	; Initialize tone generator at 0x00110000
	ei 0	; Enable interrupts

Audio_Main_Loop:
	bit 5, (4158:16)
	jr z, AudioLoop_UnmuteAfterBoot
	res 5, (4158:16)

; One-shot post-boot UNMUTE, not a watchdog (it was called AudioLoop_CheckWatchdog).
; The 32-bit tick counter at 0x1040 only ever counts up -- nothing resets it and nothing is
; kicked here -- so once it passes 1000 ticks this simply sets PE bit 0 (SFR 0x38), the bit
; MUTE_AND_HALT (0x01FBF4) clears, and every later pass re-sets an already-set bit.
AudioLoop_UnmuteAfterBoot:
	ld xwa, (4160:16)
	cp xwa, 0x3E8
	jr ule, AudioLoop_CheckPeriodicReinit
	set	0, (PE:8)	; unmute (?) (here I'm assuming "MUTE" it is an active low signal)

AudioLoop_CheckPeriodicReinit:
	bit 1, (4158:16)
	jr z, AudioLoop_CallProcessors
	res 1, (4158:16)
	call Cmd_Check_E2_Pending
	call Audio_Process_Init
	ld wa, (AudioLoop_ReinitCounter:16)
	ld bc, wa
	inc 1, wa
	ld (AudioLoop_ReinitCounter:16), wa
	cp bc, 0xA
	jr lt, AudioLoop_DecrementDelay
	ldw (AudioLoop_ReinitCounter:16), 0

AudioLoop_DecrementDelay:
	cp iz, 0:i3
	jr z, AudioLoop_CallProcessors
	dec 1, iz

AudioLoop_CallProcessors:
	call ToneGen_Process_Notes
	call MIDI_Dispatch
	call Audio_Process_DSP
	call Audio_Process_Final
	jr Audio_Main_Loop


Timer_AudioTick_Handler:
	pushw bc
	push xwa
	push xix
	ld xwa, 1:i3
	add (4160:16), xwa
	ld a, (AudioTick_Phase:16)
	ld c, a
	inc 1, a
	ld (AudioTick_Phase:16), a
	extz bc
	cp bc, 0:i3
	jr mi, AudioTick_Done
	cp bc, 5:i3
	jr gt, AudioTick_Done
	add bc, bc
	lda xix, (AudioTick_CaseOffsets:24)
	ld	bc, (xix+bc)
	lda xix, (Audio_PlayNote_Variant_1:24)
	jp	t, (xix+bc)


Audio_PlayNote_Variant_1:
	set 4, (4158:16)
	ld a, 0x1:opc
	jr AudioTick_StoreTick

Audio_PlayNote_Variant_2:
	ld a, 0x3:opc
	jr AudioTick_StoreTick

Audio_PlayNote_Variant_3:
	ld a, 0x2:opc
	jr AudioTick_StoreTick

AudioTick_Variant_4:
	set 4, (4158:16)
	ld a, 0x0:opc
	jr AudioTick_StoreTick

AudioTick_Variant_5:
	ld a, 0x3:opc

AudioTick_StoreTick:
	scf
	stcfa_dd16 0x3E, 0x10
	jr AudioTick_Done

AudioTick_Variant_6:
	set 2, (4158:16)
	ld (AudioTick_Phase:16), 0
	ld a, (AudioTick_Phase6Count:16)
	inc 1, a
	ld (AudioTick_Phase6Count:16), a
	cp a, 0x8
	jr c, AudioTick_Done
	set 5, (4158:16)
	ld (AudioTick_Phase6Count:16), 0

AudioTick_Done:
	pop xix
	pop xwa
	popw bc
	reti


EMPTY_HANDLER:	; 01FBBC
	reti


EMPTY_HANDLER_WITH_RESET:	; 01FBBD
	jrl RESET
	reti


; Cross-ROM constants: two cells of the sub-CPU BOOT ROM (IC30), not of this payload.  In
; subcpu/boot/kn5000_subcpu_boot.s they are the init flag and the 4 x u32 channel table that
; the boot ROM's own TONE_GEN_CHANNEL_INIT (0xFF8437) reads; both are dumped bytes there
; (flag = 00 00, table = 4 x 00 04 00 00).
; (Labelled there, since 2026-09-25, ToneGen_ChannelInit_Flag and ToneGen_ChannelInit_Config;
; the sink named SUB_FEC1 further down this file is DEBUG_OUTPUT_CHAR_STUB there now.)
	.equ	BootROM_ChannelInitFlag, 0xFFFEEE
	.equ	BootROM_ChannelConfigTable, 0xFFFEF0

; RENAMED from PrevBank_RegHelper -- nothing here touches a register bank.  This is the
; payload's copy of the boot ROM's TONE_GEN_CHANNEL_INIT (0xFF8437), instruction for
; instruction apart from two details: it tests the flag as a BYTE (`cp (flag),0xFF`, the boot
; ROM uses a word compare against 0xFFFF), and it passes a POINTER to the table entry
; (XBC = BootROM_ChannelConfigTable + 4*ch) where the boot ROM loads the entry's value.
; If the flag byte is 0xFF, for ch = 0..3 (counter in QIZH): DSP_Write_Channel(A = ch,
; XBC = &table[ch]), which writes 8 bytes from XBC to the 0x130000 register window.  With the
; dumped flag value 0x00 the loop is skipped.  No caller found: no 24-bit occurrence of
; 0x01FBC1 in the image and no symbolic branch to it.  (Branches were left numeric by the
; symboliser's R3 guard because of the `halt` below; resolved here by hand from unidasm.)
DSP_Init_Channels_FromBootTable:
	push qiz
	cp	(BootROM_ChannelInitFlag:24), 0xff
	jr	nz, DSP_Init_Channels_FromBootTable_Done
	ldib_erp	251, 0
DSP_Init_Channels_FromBootTable_Loop:
	ldto_berp	a, 251
	extz	wa
	ldto_berp	c, 251
	extz	bc
	sla	bc, 2
	extz	xbc
	add	xbc, BootROM_ChannelConfigTable
	call	DSP_Write_Channel
	incb_erp	251, 1
	cpib_erp	251, 4
	jr	c, DSP_Init_Channels_FromBootTable_Loop
DSP_Init_Channels_FromBootTable_Done:
	pop qiz
	ret


; NMI handler (via IntTramp_NMI).  The same three instructions as the boot ROM's HALT_LOOP
; (0xFF8490): clear PE bit 0, then HALT forever -- the `jr t` below re-enters the HALT after
; any wake-up.  CORRECTED: that `jr t` (0x01FBF8) used to sit under the label
; Timer_StatusHelper as the first instruction of an unrelated routine; it belongs here, and
; Timer_StatusHelper now starts at 0x01FBFA.
MUTE_AND_HALT:	; 01FBF4
	res	0, (PE:8)	; mute (?) (here I'm assuming "MUTE" it is an active low signal)
MUTE_AND_HALT_Halt:
	halt
	jr	t, MUTE_AND_HALT_Halt


; HL = zero-extended byte at 0x103A.  No caller found (no 24-bit occurrence of 0x01FBFA and no
; symbolic branch to it).
Timer_StatusHelper:
	ld	l, (4154:16)
	extz	hl
	ret


MemClear_DRAM_And_ExtRAM:
	ld xde, Payload_Bss_Start
	ld xbc, Payload_Bss_Size
	ld ix, bc
	srl xbc, 1
	jr z, MemClear_DRAM_OddByte
	ld xhl, xde
	ldw (xde+), 0x0000
	dec 1, xbc
	or xbc, xbc
	jr z, MemClear_DRAM_OddByte
	ldirw93
	cpiw_erp 0xE6, 0
	jr z, MemClear_DRAM_OddByte
	ldto_werp WA, 0xE6

MemClear_DRAM_BulkLoop:
	ldirw93
	djnz16 wa, MemClear_DRAM_BulkLoop

MemClear_DRAM_OddByte:
	bit 0, ix
	jr z, MemClear_ExtRAM
	ld (xde), 0x0

MemClear_ExtRAM:
	ld xde, 0x600
	ld xbc, 0x44CB
	ld ix, bc
	srl xbc, 1
	jr z, MemClear_ExtRAM_OddByte
	ld xhl, xde
	ldw (xde+), 0x0000
	dec 1, xbc
	or xbc, xbc
	jr z, MemClear_ExtRAM_OddByte
	ldirw93
	cpiw_erp 0xE6, 0
	jr z, MemClear_ExtRAM_OddByte
	ldto_werp WA, 0xE6

MemClear_ExtRAM_BulkLoop:
	ldirw93
	djnz16 wa, MemClear_ExtRAM_BulkLoop

MemClear_ExtRAM_OddByte:
	bit 0, ix
	jr z, MemClear_ExtRAM_Finish
	ld (xde), 0x0

MemClear_ExtRAM_Finish:
	jrl PostReset_InitAudio
	ret


; ★ TASK 2 ENTRY POINT (0x01FC6F) -- was `Const_0x0E: .byte 0x0e`; 0x0E is the RET opcode and
; this byte is CODE, not a constant.  Evidence: record 2 of TaskSched_TaskDescriptorTable
; holds 0x0001FC6F in its +0 (entry PC) field, which Kernel_StartTask would copy into the
; saved-PC slot of task 2's context frame.  Task 2 is never spawned in v1.42: the only
; Kernel_StartTask call sites are Kernel_InitRam__install (A = 1) and
; DSP_State_DmaLoadPresets (A = 3), and no numeric branch operand left in this image targets
; 0x01FFFD.  So this is an unused task slot whose body is a bare RET (if it ever ran, the RET
; would pop the first long above its fresh stack top 0x040C20, not a return address).
; Task2_NeverSpawned: Entry PC of task 2 (TaskSched_TaskDescriptorTable record 2), a bare RET: Kernel_StartTask is
;   only ever called with task 1 and task 3, so this slot is unused in v1.42. Basis: descriptor table + the SpawnTask
;   call sites.
Task2_NeverSpawned:
	ret


Audio_InitRingBuffers:
	call RingBuf_Init_1K
	call RingBuf_Init_256
	jp RingBuf_Init_512


Audio_CmdHandler_20_3F:
	ld hl, 0:i3
	ret

Audio_CmdHandler_40_5F:
	ld c, (xsp + 4)
	ld a, c
	dec 1, c
	cp a, 0:i3
	jr z, AudioCmd_40_5F_Done

AudioCmd_40_5F_SkipLoop:
	ld a, c
	dec 1, c
	cp a, 0:i3
	jr nz, AudioCmd_40_5F_SkipLoop

AudioCmd_40_5F_Done:
	ld hl, 0:i3
	ret

; ----------------------------------------------------------------------------
; DSP_Init_Channels - Initialize DSP channel configuration
; Entry: None
; Exit:  None
; Notes: MEANT to write the pattern 0x5A5A5A5A to the 8 registers of each of the 4 channels of
;        the 0x130000 block, then 0x01 to each channel's register ch*0x20+0x1F.  Only the second
;        half works: see the CORRECTION under DSP_Write_Channel.  The block's owning chip is not
;        identified (subcpu/boot/kn5000_subcpu_boot.s, TONE_GEN_BASE).
; ----------------------------------------------------------------------------
DSP_Init_Channels:	; 01FC95h
	link	xiz, 0xfff8
	xor xwa, xwa
	ld xwa, 0x5A5A5A5A	; Test pattern
	ld (xiz - 8), xwa	; Local buffer[0-3]
	ld (xiz - 4), xwa	; Local buffer[4-7]
	lda xwa, (xiz - 8)	; Pointer to test data
	push xwa
	ld bc, 0:i3	; Channel 0
	calr DSP_Write_Channel
	pop xwa
	push xwa
	ld bc, 1:i3	; Channel 1
	calr DSP_Write_Channel
	pop xwa
	push xwa
	ld bc, 2:i3	; Channel 2
	calr DSP_Write_Channel
	pop xwa
	push xwa
	ld bc, 3:i3	; Channel 3
	calr DSP_Write_Channel
	pop xwa
	; The loop below sets W := A and writes XWA (32 bits) per channel: the mode register number
	; twice, then the constant upper half 0x0101; A starts at 0x1F and steps by 0x20.
.equ DSP_ChannelModeInitWord, 0x0101001f
	ld xbc, 0x130000	; DSP register base
	ld xwa, DSP_ChannelModeInitWord
	ld d, 0x4:opc	; 4 channels

DSP_Init_Channels_Loop:
	ld w, a
	ld (xbc), xwa	; Write to DSP register
	add a, 0x20	; Next channel (0x20 spacing)
	djnz8 d, DSP_Init_Channels_Loop
	unlk	xiz
	ret

; ----------------------------------------------------------------------------
; DSP_Write_Channel - Write 8 bytes of config data to a DSP channel
; Entry: XWA = pointer to 8 bytes of channel data
;        BC  = channel number (0-3)
; Exit:  None
; Notes: Calculates channel register address from channel number
;        Writes 8 sequential bytes to DSP at 0x00130000 + offset
; ----------------------------------------------------------------------------
; CORRECTION (2026-09-25, from the instructions): the entry registers above are swapped.  The
; code takes the CHANNEL in A (`sll a,5 / set 4,a` -> register index ch*32 + 0x10) and the
; 8-byte SOURCE in XBC (`ld e,(xbc+)`); XWA's upper bytes and BC are not read as such.
; DSP_Init_Channels_FromBootTable calls it that way (A = ch, XBC = &table[ch]).  Note that
; DSP_Init_Channels above passes the pattern pointer in XWA and the channel in BC -- taken
; literally, each of its four calls selects the register group from the low byte of the
; pointer and reads 8 bytes from address BC = 0..3.  MEASURED in MAME 2026-10-31
; (notes/open4-kn5000-b/hwaudio/probes/subcpu_130000_writes.txt): all four calls write registers
; 0x10-0x17 (the pointer's low byte selects channel 0), with data 0x00 read from SFR addresses
; 0-10, and the 0x5A5A5A5A pattern never reaches the block.  The mode loop below then writes
; 0x1F1F / 0x0101 as two 16-bit stores per channel: latch 0x1F/0x3F/0x5F/0x7F, data 0x01.
; Over a cold boot these 72 writes (at 4.993 s) and the boot ROM's 72 same-shaped ones are
; the only accesses to 0x130000-0x130003; nothing reads the block.
DSP_Write_Channel:	; 01FCDEh
	pushw de
	sll a, 5	; Channel * 32 (register spacing)
	set 4, a	; Add 0x10 offset
	ld xhl, 0x130000	; DSP register base
	ld d, 0x8:opc	; 8 bytes per channel

DSP_Write_Channel_Loop:
	ld (xhl), a	; Write register address
	ld E, (xbc+)	; Get next data byte
	ld (xhl + 2), e	; Write data value
	inc 1, a	; Next register
	djnz8 d, DSP_Write_Channel_Loop
	popw de
	ret


; ----------------------------------------------------------------------------
; DSP_WriteAllChannelRegs - Write register data to all 4 DSP channels
; Entry: XBC/XDE = channel data, prevbank QBC/QDE = additional data
; Notes: Calls DSP_WriteChannelRegs_Inner for channels 0-3
;        Each call writes 8 sequential DSP registers via 0x130000
; ----------------------------------------------------------------------------
DSP_WriteAllChannelRegs:
	push xbc
	push xde
	pushw 1				; Channel 1
	calr DSP_WriteChannelRegs_Inner
	ld xbc, (xsp + 10)		; Reload saved XBC
	ld xde, xiz
	pushw 0				; Channel 0
	calr DSP_WriteChannelRegs_Inner
	ld xbc, xwa
	ld xde, xhl
	pushw 2				; Channel 2
	calr DSP_WriteChannelRegs_Inner
	ld xbc, xix
	ld xde, xiy
	pushw 3				; Channel 3
	calr DSP_WriteChannelRegs_Inner
	inc 8, xsp			; Clean 4x pushw from stack
	pop xde
	pop xbc
	ret

; ----------------------------------------------------------------------------
; DSP_WriteChannelRegs_Inner - Write 8 register values to one DSP channel
; Entry: Stack+12 = channel number (0-3)
;        BC = data bytes 0-1, DE = data bytes 4-5
;        Prevbank QBC = data bytes 2-3, prevbank QDE = data bytes 6-7
; Notes: Register address = channel * 32 + 0x10
;        Writes via memory-mapped DSP I/O: addr to (xiy), data to (xiy+2)
; ----------------------------------------------------------------------------
DSP_WriteChannelRegs_Inner:
	push xiy
	pushw wa
	pushw bc
	ld a, (xsp + 12)		; Channel number
	sll a, 5			; * 32
	set 4, a			; + 0x10
	ld xiy, 0x130000		; DSP register base
	ld (xiy), a			; Reg addr [0]
	ld (xiy + 2), c			; Write data C
	inc 1, a
	ld (xiy), a			; Reg addr [1]
	ld (xiy + 2), b			; Write data B
	inc 1, a
	ld (xiy), a			; Reg addr [2]
	ld	bc, qbc
	ld (xiy + 2), c			; Write prevbank C
	inc 1, a
	ld (xiy), a			; Reg addr [3]
	ld (xiy + 2), b			; Write prevbank B
	inc 1, a
	ld (xiy), a			; Reg addr [4]
	ld (xiy + 2), e			; Write data E
	inc 1, a
	ld (xiy), a			; Reg addr [5]
	ld (xiy + 2), d			; Write data D
	inc 1, a
	ld (xiy), a			; Reg addr [6]
	ld	bc, qde
	ld (xiy + 2), c			; Write prevbank DE.low
	inc 1, a
	ld (xiy), a			; Reg addr [7]
	ld (xiy + 2), b			; Write prevbank DE.high
	popw bc
	popw wa
	pop xiy
	ret

; ----------------------------------------------------------------------------
; DSP_BlockCopyWords - Block copy words from (XHL) to destination
; Entry: XWA = dest base (saved to XIX), XBC = src base (saved to XIY)
;        DE = source reg, BC (after ld) = word count for ldirw
; Notes: ldirw copies BC words from (XHL+) to (XIX+)
; ----------------------------------------------------------------------------
DSP_BlockCopyWords:
	ld xix, xwa
	ld xiy, xbc
	ld bc, de
	ldirw				; Block transfer: (XHL+) -> (XIX+), BC words
	ret

; ----------------------------------------------------------------------------
; DSP_FillMemWords - Fill memory with word value
; Entry: XWA = dest pointer, BC = fill value, DE = count
; Notes: ld (xwa+),bc stores BC then increments XWA
; ----------------------------------------------------------------------------
DSP_FillMemWords:
	ld	(xwa+), bc
	djnz16 de, DSP_FillMemWords
	ret

; ----------------------------------------------------------------------------
; DSP_ChecksumRange - Compute checksum of 32-bit words in memory range
; Entry: XWA = start address, XBC = byte count
; Exit:  HL = one's complement checksum
; Notes: Sums all 32-bit values, then complements result
; ----------------------------------------------------------------------------
DSP_ChecksumRange:
	xor xhl, xhl			; Accumulator = 0
	extz xbc			; Zero-extend count
	add xbc, xwa			; XBC = end address
DSP_ChecksumRange_Loop:
	add	xhl, (xwa+)	; add xhl, (xwa+)  (add + auto-increment)
	cp xwa, xbc			; Reached end?
	jr lt, DSP_ChecksumRange_Loop
	cpl hl				; One's complement
	ret

