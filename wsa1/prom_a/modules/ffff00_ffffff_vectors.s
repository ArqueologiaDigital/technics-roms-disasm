
; ==============================================================================
; 0xFFFF00 -- interrupt vector table
; ==============================================================================
;
; The TMP95C061 fetches every vector as a 32-bit little-endian word from
; 0xFFFF00 + offset (tmp95c061.cpp:560, `m_pc.d = RDMEML(0xffff00 + vector)`).
;
; What is CITED and what is CONVENTION:
;   0x00        cited -- the reset PC is fetched from 0xFFFF00
;               (tlcs900.cpp:215-217)
;   0x20        cited -- NMI, tmp95c061.cpp:505
;   0x28-0x80   cited -- names and offsets from tmp95c061_irq_vector_map[] at
;               tmp95c061.cpp:322-346
;   0x04-0x1C,  CONVENTION.  The names SWI1-SWI7 and INTWD are the usual
;   0x24        TLCS-900/H order; MAME does not name these slots and no
;               databook is available in these trees.  prom_c corroborates the
;               shape -- its 0x24 slot jumps back to its own reset entry (a
;               watchdog reboot) and its 0x04 slot does the same -- but that is
;               corroboration, not a citation.
;
VECTORS:
	.long RESET			; 0x00  RESET
	.long IRQ_UnusedVector_SWI1	; 0x04  SWI1
	.long IRQ_UnusedVector_SWI2	; 0x08  SWI2 / INTUNDEF
	.long IRQ_UnusedVector_SWI3	; 0x0C  SWI3
	.long IRQ_UnusedVector_SWI4	; 0x10  SWI4
	.long IRQ_UnusedVector_SWI5	; 0x14  SWI5
	.long IRQ_UnusedVector_SWI6	; 0x18  SWI6
	.long T_SWI7_ServiceCall_Dispatch ; 0x1C  SWI7 -> prom_b thunk `jp 0xF8E9A5` =
				;       SWI7_ServiceCall_Dispatch, the 64-slot
				;       graphics service call
	.long NMI_PowerFail_SaveAndHalt	; 0x20  NMI -- the power-fail handler
	.long INTWD_Reboot		; 0x24  INTWD -- jumps back to RESET
	.long T_INT0_LinkByte ; 0x28  INT0       -> prom_b thunk (file 0x40EDC:
				;                     `jp 0xF8E47F`)
	.long IRQ_UnusedVector_INT4	; 0x2C  INT4
	.long T_INT5_Dev7B_Receive_Alias ; 0x30  INT5
	.long T_INT6_SC1_PeerRequest ; 0x34  INT6
	.long IRQ_UnusedVector_Hang	; 0x38  INT7   ⚠ not a stub -- it HANGS
	.long IRQ_UnusedVector_Hang	; 0x3C  (reserved; MAME skips this slot)
	.long IRQ_UnusedVector_Hang	; 0x40  INTT0
	.long INTT1_Tick		; 0x44  INTT1 -- the periodic time base: MIDI
				;       active sensing, the (0xA1) tempo counter, the
				;       transport state machine and the (0x88) rota
	.long T_INTT2_Reti ; 0x48  INTT2      -> the micro-DMA 2 trigger armed
				;                     at 0xF8E166 (DMA2V = 0x12,
				;                     0x12<<2 = 0x48)
	.long T_INTT3_KernelTick ; 0x4C  INTT3
	.long INTTR4_SequencerTick	; 0x50  INTTR4 -- the musical time base:
				;       96 ticks per beat, three transports, and the
				;       24-per-beat MIDI clock
	.long IRQ_UnusedVector_Hang	; 0x54  INTTR5 -- worth knowing: the tempo
				;       code writes TREG5, so a reader expects this
				;       slot to matter.  It hangs.
	.long IRQ_UnusedVector_Hang	; 0x58  INTTR6
	.long IRQ_UnusedVector_Hang	; 0x5C  INTTR7
	.long T_MIDI_RX_Byte ; 0x60  INTRX0 -> prom_b thunk `jp 0xFA5496` =
				;       MIDI_RX_Byte
	.long T_MIDI_TX_Ready ; 0x64  INTTX0 -> prom_b thunk `jp 0xFA542F` =
				;       MIDI_TX_Ready
	.long T_INTRX1_SC1_Dispatch ; 0x68  INTRX1
	.long T_INTTX1_SC1_Dispatch ; 0x6C  INTTX1
	.long IRQ_UnusedVector_Hang	; 0x70  INTAD
	.long T_INTTC0_uDMA0Done_Alias ; 0x74  INTTC0
	.long IRQ_UnusedVector_Hang	; 0x78  INTTC1
	.long T_INTTC2_uDMA2Done ; 0x7C  INTTC2     -> micro-DMA 2 completion
	.long T_INTTC3_LinkDmaDone ; 0x80  INTTC3

; ==============================================================================
; 0xFFFF84-0xFFFFEF -- padding
; ==============================================================================
; 0x0E is the one-byte RET opcode, which is what this toolchain's images pad
; with.  In prom_c the byte at 0xFFFFEF is NOT padding -- it is a configuration
; byte holding fc in MHz.  Here it really is 0x0E, so CPU 1 does not use that
; mechanism; it takes the (0xFFFFF8) == 0x24 branch at 0xFA58FB instead.
	.fill 0x6C, 1, 0x0E

; ==============================================================================
; 0xFFFFF0 -- build tag
; ==============================================================================
; The byte at 0xFFFFF8 is the 0x02 separator inside this tag, and it is what the
; runtime UART init at 0xFA58FB compares against 0x24 to choose the baud divisor.
; prom_c and prom_d carry the same shape of tag; prom_b does not, which is one
; of the signs that prom_b is the low half of a contiguous image rather than an
; image in its own right.
BUILD_TAG:
	.ascii "wsaa_822"
MIDI_UART_Configure_Data:
	.byte 0x02
	.ascii	"s"
VersionScreen_Show_Data:	.ascii	"sf"
	.byte 0x00, 0x00, 0x00, 0x00
; ★ RENAMED 2026-08-30 from `end`.  It is an end-of-image marker -- the
; address one past the last byte -- and nothing in this tree references it,
; but prom_a and prom_b both called it `end` and they are ONE program in one
; address space, so the joined listing had two labels of that name for two
; different addresses.  Checked, not assumed: notes/maincpu_join_probe.py
; --selftest asserts nothing uses the symbol and that it is the last thing in
; each file.  ⚠ prom_c still spells it `end`; that image is another lane's.
prom_a_image_end:
