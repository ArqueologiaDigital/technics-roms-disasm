; =============================================================================
; Core: RESET, Initialization, Main Loop, Voice Management,
;       Tone Generation, DSP Protocol
; =============================================================================
RESET:
; New in v1.42: these five stores (0x17 bytes) are absent from v1.41, whose RESET begins at the
; WDMOD store below -- the insertion that moves every later v1.41 address down by 0x17.  They
; zero the micro-DMA start vectors of channels 0 and 2, the DMA request and burst registers,
; and INTCLR, before the port and timer set-up.
	ld (DMA0V:16), 0
	ld (DMA2V:16), 0
	ld (DMAR:16), 0
	ld (DMAB:16), 0
	ld (INTCLR:8), 0x00:io
	ld (WDMOD:16), 0
	ld (WDCR:16), 0xb1	; the watchdog disable code; with WDMOD.WDTE just cleared, this stops the watchdog
	ld (CLKMOD:16), 0x04
	ld (P1FC:8), 0xFF:io
	ld (P2FC:8), 0xFF:io
	ld (P3FC:8), 0xFF:io
	ld (P6:8), 0xFF:io
	ld (P6FC:8), 0x7F:io
	ld (P6CR:8), 0x80:io
	ld (P7:8), 0xFF:io
	ld (P7FC:8), 0x07:io
	ld (P7CR:8), 0x78:io
	ld (P8:8), 0x3B:io
	ld (P8FC:8), 0x3F:io
	ld (P8CR:8), 0xFF:io
	ld (PA:8), 0xFF:io
	ld (PAFC:8), 0x08:io
	ld (PB:8), 0xFF:io
	ld (PBFC:8), 0x1F:io
	ld (0x30:8), 0x03:io
	ld (PCFC:8), 0x00:io
	ld (PCCR:8), 0x02:io
	ld (PD:8), 0xFF:io
	ld (PDFC:8), 0x00:io
	ld (PDCR:8), 0x63:io
	ld (PE:8), 0xFE:io
	ld (PEFC:8), 0x00:io
	ld (PECR:8), 0x71:io
	ld (PF:8), 0xFF:io
	ld (PFFC:8), 0x70:io	;
	ld (PFCR:8), 0x15:io
	ld (PH:8), 0xFF:io
	ld (PHFC:8), 0x18:io
	ld (PHCR:8), 0x07:io
	ld (PZ:8), 0x00:io
	ld (PZCR:8), 0xFF:io
	ld (T01MOD:8), 0x1D:io
	ld (T23MOD:8), 0x1D:io
	ld (T02FFCR:8), 0x00:io
	ld (TREG0:8), 0x0A:io
	ld (TREG1:8), 0x14:io
	ld (TREG2:8), 0x40:io
	ld (TREG3:8), 0x20:io
	ld (TRDC:8), 0x00:io
	set	1, (T8RUN:8)
	ld (T4MOD:8), 0x05:io
	ld (T4FFCR:8), 0x00:io
	ld (T16CR:8), 0x00:io
	ld (T16RUN:8), 0x00:io
	set	7, (T16RUN:8)	; prescaler: run
	ld (323:16), 16
	ld (327:16), 17
	ld (331:16), 255
	ld (335:16), 0
	ld (339:16), 18
	ld (343:16), 19
	ld (322:16), 7
	ld (326:16), 3
	ld (330:16), 1
	ld (334:16), 31
	ld (338:16), 1
	ld (342:16), 1
	ld (SC0MOD:8), 0x01:io
	ld (SC0CR:8), 0x00:io
	and	(BR0CR:8), 0xcf
	and	(BR0CR:8), 0xf0
	ld (SC1MOD:8), 0x29:io	;receive-enable | 8-bit uart mode | serial transfer clock: baud-rate generator
	lda	xbc, (SC1MOD:8)
	ld a, (xbc)
	and a, 0xFC
	set 0, a
	ld (xbc), a
	ld (SC1CR:8), 0x00:io	; parity addition: disable
	and	(BR1CR:8), 0xcf	; T0 (4/fc)
	and	(BR1CR:8), 0xf0	; divide by 16
	ld (304:16), 255
	ld (305:16), 255
	ld (306:16), 3
	ld (357:16), 113
	ld (354:16), 139
	ld (355:16), 88
	res 4, (358:16)
	ld (320:16), 85
	ld (324:16), 85
	ld (328:16), 34
	ld (332:16), 34
	ld (336:16), 98
	ld (340:16), 102
	ld (321:16), 129
	ld (325:16), 129
	ld (329:16), 192
	ld (333:16), 138
	ld (337:16), 128
	ld (341:16), 129
	ld (IIMC:8), 0x00:io
	ld xwa, 0:i3
	ld (4160:16), xwa
	calr MemClear_DRAM_And_ExtRAM

PostReset_InitAudio:
	lda xwa, (Task1_StackTop:24)
	ld xsp, xwa
	call Kernel_InitRam
; ★ TASK 1 ENTRY POINT (0x01FAB1).  The `call` above never returns here in the ordinary way:
; record 1 of TaskSched_TaskDescriptorTable holds this address in its +0 (entry PC) field, and
; Kernel_StartTask(1) -- issued by Kernel_InitRam__install at the end of Kernel_InitRam --
; copies it into the saved-PC slot (+30) of a fresh 34-byte context frame built just below the
; record's stack top 0x04069A, the same value loaded into XSP two instructions up.
; Kernel_Dispatch then enters it through Kernel_ResumeTask (7 x pop, pop sr, ret),
; so everything from here on -- Audio_System_Init and Audio_Main_Loop -- runs as task 1,
; ready-queue priority 3.  The return address the `call` pushed is simply abandoned.
; Task1_StartAudioSystem: Entry PC of task 1 (TaskSched_TaskDescriptorTable record 1): arms the audio-tick interrupt
;   (INTET01 high nibble = INTT1 level 3), initialises the three ring buffers, enables interrupts, clears word 0x103C
;   and enters Audio_System_Init, which falls into Audio_Main_Loop. Basis: descriptor table + body.
Task1_StartAudioSystem:
	lda	xbc, (INTET01:8)
	ld a, (xbc)
	and a, 0x8F
	or a, 0x30
	ld (xbc), a
	calr Audio_InitRingBuffers
	ei 0
	ldw (4156:16), 0
	jr Audio_System_Init

