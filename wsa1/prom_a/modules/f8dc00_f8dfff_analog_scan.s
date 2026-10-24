
; AnalogScan_PhaseVector: the boot phase vector of module 6 -- ModuleInitDirectory_F82641 reaches it; the walker calls slot k (4 bytes)
;   for boot phase k (notes/prom_a_module_boot_phase_names.py).  2026-10-04.
AnalogScan_PhaseVector:
	jp AnalogScan_InitSoftChannels                       ; F8DC00  1b 18 dc f8
	ret                                                  ; F8DC04  0e
	nop                                                  ; F8DC05  00
	nop                                                  ; F8DC06  00
	nop                                                  ; F8DC07  00
	ret                                                  ; F8DC08  0e
	nop                                                  ; F8DC09  00
	nop                                                  ; F8DC0A  00
	nop                                                  ; F8DC0B  00
	ret                                                  ; F8DC0C  0e
	nop                                                  ; F8DC0D  00
	nop                                                  ; F8DC0E  00
	nop                                                  ; F8DC0F  00
	ret                                                  ; F8DC10  0e
	nop                                                  ; F8DC11  00
	nop                                                  ; F8DC12  00
	nop                                                  ; F8DC13  00
	ret                                                  ; F8DC14  0e
	nop                                                  ; F8DC15  00
	nop                                                  ; F8DC16  00
	nop                                                  ; F8DC17  00
; ---------------------------------------------------------------------
; AnalogScan_InitSoftChannels -- park channels 4 and 5 at mid scale
;
; Called from: `jp 0xF8DC18` at 0xF8DC00, the module's first published entry.
; Inputs:  none.  Outputs: (0x600000) = (0x600001) = 0x80.
; Evidence: two stores of the same immediate 0x80 to the two addresses that
;          AnalogScan_SoftChannel4 and _SoftChannel5 read.  0x80 is mid scale
;          for the 8-bit values the other four channels produce.
; ---------------------------------------------------------------------
AnalogScan_InitSoftChannels:
	ld a, 0x80:opc                                          ; F8DC18  21 80
	ld (0x600000:24), a                                 ; F8DC1A  f2 00 00 60 41
	ld (0x600001:24), a                                 ; F8DC1F  f2 01 00 60 41
	ret                                                  ; F8DC24  0e
; ---------------------------------------------------------------------
; AnalogScan_All -- one pass over all six channels
;
; Called from: not traced; the module's entry veneers are at 0xF8DC00-0xF8DC17.
; Inputs:  none.
; Outputs: as the six channel routines.
; Evidence: six `calr`s in order, the four A/D ones guarded by
;          `cp (0xC4),0x02 / jr Z`, which skips them and runs only the two soft
;          channels.  What (0xC4) == 2 means is not established.
; ---------------------------------------------------------------------
AnalogScan_All:
	cp	(Variant_Flag:8), 0x02                               ; F8DC25  c0 c4 3f 02
	jr z, .LF8DC37                                       ; F8DC29  66 0c
	calr AnalogScan_AdChannel0                                      ; F8DC2B  1e 10 00
	calr AnalogScan_AdChannel1                                      ; F8DC2E  1e 40 00
	calr AnalogScan_AdChannel2                                      ; F8DC31  1e 70 00
	calr AnalogScan_AdChannel3                                      ; F8DC34  1e a0 00
.LF8DC37:
	calr AnalogScan_RamChannel4                                      ; F8DC37  1e 13 01
	calr AnalogScan_RamChannel5                                      ; F8DC3A  1e 25 01
	ret                                                  ; F8DC3D  0e
; AnalogScan_AdChannel0 -- scan A/D channel 0: deadband, normalise, latch the cooked value if it moved
; Evidence: `ld WA,(0x60)` = ADREG0L/ADREG0H (include/tmp95c061_sfr.inc), `srl 8,WA` keeps the high byte;
;   AnalogScan_Hysteresis with last/state at (0x28E0/0x28E1); on accept `ld W,0 / call T_Ctrl_Normalise` and, carry
;   set, (0x28EE) = A | 0x80. Called by AnalogScan_All, skipped when (0xC4) = 2.
AnalogScan_AdChannel0:
	ld	wa, (0x60:8)                                 ; F8DC3E  d0 60 20
	srl wa, 0x08                                         ; F8DC41  d8 ef 08
	ld w, (AnalogScan_HystState:16)                                   ; F8DC44  c1 e0 28 20
	ld c, (AnalogScan_HystState+1:16)                                   ; F8DC48  c1 e1 28 23
	calr AnalogScan_Hysteresis                           ; F8DC4C  1e bb 00
	ld (AnalogScan_HystState+1:16), c                                   ; F8DC4F  f1 e1 28 43
	bit 0x03,C                                           ; F8DC53  cb 33 03
	jr z, .LF8DC70                                       ; F8DC56  66 18
	and	(AnalogScan_HystState+1:16), 0xf7                            ; F8DC58  c1 e1 28 3c f7
	ld (AnalogScan_HystState:16), a                                   ; F8DC5D  f1 e0 28 41
	ld w, 0x00:opc                                          ; F8DC61  20 00
	call T_Ctrl_Normalise                                ; F8DC63  1d f0 05 f4
	jr nc, .LF8DC70                                      ; F8DC67  6f 07
	or A,0x80                                            ; F8DC69  c9 ce 80
	ld (AnalogScan_Cooked+2:16), a                                   ; F8DC6C  f1 ee 28 41
.LF8DC70:
	ret                                                  ; F8DC70  0e
; AnalogScan_AdChannel1 -- scan A/D channel 1: deadband, normalise, latch the cooked value if it moved
; Evidence: `ld WA,(0x62)` = ADREG1L/ADREG1H (include/tmp95c061_sfr.inc), `srl 8,WA` keeps the high byte;
;   AnalogScan_Hysteresis with last/state at (0x28E2/0x28E3); on accept `ld W,1 / call T_Ctrl_Normalise` and, carry
;   set, (0x28EF) = A | 0x80. Called by AnalogScan_All, skipped when (0xC4) = 2.
AnalogScan_AdChannel1:
	ld	wa, (0x62:8)                                 ; F8DC71  d0 62 20
	srl wa, 0x08                                         ; F8DC74  d8 ef 08
	ld w, (AnalogScan_HystState+2:16)                                   ; F8DC77  c1 e2 28 20
	ld c, (AnalogScan_HystState+3:16)                                   ; F8DC7B  c1 e3 28 23
	calr AnalogScan_Hysteresis                           ; F8DC7F  1e 88 00
	ld (AnalogScan_HystState+3:16), c                                   ; F8DC82  f1 e3 28 43
	bit 0x03,C                                           ; F8DC86  cb 33 03
	jr z, .LF8DCA3                                       ; F8DC89  66 18
	and	(AnalogScan_HystState+3:16), 0xf7                            ; F8DC8B  c1 e3 28 3c f7
	ld (AnalogScan_HystState+2:16), a                                   ; F8DC90  f1 e2 28 41
	ld w, 0x01:opc                                          ; F8DC94  20 01
	call T_Ctrl_Normalise                                ; F8DC96  1d f0 05 f4
	jr nc, .LF8DCA3                                      ; F8DC9A  6f 07
	or A,0x80                                            ; F8DC9C  c9 ce 80
	ld (AnalogScan_Cooked+3:16), a                                   ; F8DC9F  f1 ef 28 41
.LF8DCA3:
	ret                                                  ; F8DCA3  0e
; AnalogScan_AdChannel2 -- scan A/D channel 2: deadband, normalise, latch the cooked value if it moved
; Evidence: `ld WA,(0x64)` = ADREG2L/ADREG2H (include/tmp95c061_sfr.inc), `srl 8,WA` keeps the high byte;
;   AnalogScan_Hysteresis with last/state at (0x28E4/0x28E5); on accept `ld W,2 / call T_Ctrl_Normalise` and, carry
;   set, (0x28F0) = A | 0x80. Called by AnalogScan_All, skipped when (0xC4) = 2.
AnalogScan_AdChannel2:
	ld	wa, (0x64:8)                                 ; F8DCA4  d0 64 20
	srl wa, 0x08                                         ; F8DCA7  d8 ef 08
	ld w, (AnalogScan_HystState+4:16)                                   ; F8DCAA  c1 e4 28 20
	ld c, (AnalogScan_HystState+5:16)                                   ; F8DCAE  c1 e5 28 23
	calr AnalogScan_Hysteresis                           ; F8DCB2  1e 55 00
	ld (AnalogScan_HystState+5:16), c                                   ; F8DCB5  f1 e5 28 43
	bit 0x03,C                                           ; F8DCB9  cb 33 03
	jr z, .LF8DCD6                                       ; F8DCBC  66 18
	and	(AnalogScan_HystState+5:16), 0xf7                            ; F8DCBE  c1 e5 28 3c f7
	ld (AnalogScan_HystState+4:16), a                                   ; F8DCC3  f1 e4 28 41
	ld w, 0x02:opc                                          ; F8DCC7  20 02
	call T_Ctrl_Normalise                                ; F8DCC9  1d f0 05 f4
	jr nc, .LF8DCD6                                      ; F8DCCD  6f 07
	or A,0x80                                            ; F8DCCF  c9 ce 80
	ld (AnalogScan_Cooked+4:16), a                                   ; F8DCD2  f1 f0 28 41
.LF8DCD6:
	ret                                                  ; F8DCD6  0e
; AnalogScan_AdChannel3 -- scan A/D channel 3: deadband, normalise, latch the cooked value if it moved
; Evidence: `ld WA,(0x66)` = ADREG3L/ADREG3H (include/tmp95c061_sfr.inc), `srl 8,WA` keeps the high byte;
;   AnalogScan_Hysteresis with last/state at (0x28E6/0x28E7); on accept `ld W,3 / call T_Ctrl_Normalise` and, carry
;   set, (0x28F1) = A | 0x80. Called by AnalogScan_All, skipped when (0xC4) = 2.
AnalogScan_AdChannel3:
	ld	wa, (0x66:8)                                 ; F8DCD7  d0 66 20
	srl wa, 0x08                                         ; F8DCDA  d8 ef 08
	ld w, (AnalogScan_HystState+6:16)                                   ; F8DCDD  c1 e6 28 20
	ld c, (AnalogScan_HystState+7:16)                                   ; F8DCE1  c1 e7 28 23
	calr AnalogScan_Hysteresis                           ; F8DCE5  1e 22 00
	ld (AnalogScan_HystState+7:16), c                                   ; F8DCE8  f1 e7 28 43
	bit 0x03,C                                           ; F8DCEC  cb 33 03
	jr z, .LF8DD09                                       ; F8DCEF  66 18
	and	(AnalogScan_HystState+7:16), 0xf7                            ; F8DCF1  c1 e7 28 3c f7
	ld (AnalogScan_HystState+6:16), a                                   ; F8DCF6  f1 e6 28 41
	ld w, 0x03:opc                                          ; F8DCFA  20 03
	call T_Ctrl_Normalise                                ; F8DCFC  1d f0 05 f4
	jr nc, .LF8DD09                                      ; F8DD00  6f 07
	or A,0x80                                            ; F8DD02  c9 ce 80
	ld (AnalogScan_Cooked+5:16), a                                   ; F8DD05  f1 f1 28 41
.LF8DD09:
	ret                                                  ; F8DD09  0e
; ---------------------------------------------------------------------
; AnalogScan_Hysteresis -- the deadband filter every channel shares
;
; Called from: all six channel routines, by `calr`, and nothing else.
; Inputs:  A = the new reading, W = the last accepted one, C = the state byte.
; Outputs: C updated; A = the value to accept when bit 3 of C is set.
; Evidence: the routine takes |A - W| by ordering the two with `cp A,W` and an
;          `ex A,W`, then branches on `cp A,2` and `cp A,6` -- so 0..2 is the
;          deadband, 3..6 the intermediate band and 7 and above an immediate
;          accept.  The state byte's low two bits are a direction that the
;          intermediate arm compares with `xor C,0x03`, bit 2 is set by the
;          arm that does not accept, and bit 3 is the "accept this" flag the
;          callers test with `bit 0x03,C`.
; Unknown: the exact intent of the direction bits.  What is established is which
;          bits each arm writes, not what a UI does with them.
; ---------------------------------------------------------------------
AnalogScan_Hysteresis:
	ld E,A                                               ; F8DD0A  c9 8d
	cp A,W                                               ; F8DD0C  c8 f1
	jr ugt, .LF8DD12                                     ; F8DD0E  6b 02
	ex8 a, w                                             ; F8DD10  c8 b9
.LF8DD12:
	sub A,W                                              ; F8DD12  c8 a1
	cp a, 0x02:i3                                          ; F8DD14  c9 da
	jr ule, AnalogState_MaskOffLow3Bits                                   ; F8DD16  63 31
	cp a, 0x06:i3                                          ; F8DD18  c9 de
	jr ule, .LF8DD35                                     ; F8DD1A  63 19
	xor C,0x03                                           ; F8DD1C  cb cd 03
	jr nz, .LF8DD2B                                      ; F8DD1F  6e 0a
	ld A,E                                               ; F8DD21  cd 89
	or C,0x08                                            ; F8DD23  cb ce 08
	and C,0xf8                                           ; F8DD26  cb cc f8
	jr .LF8DD4C                                          ; F8DD29  68 21
.LF8DD2B:
	xor C,0x03                                           ; F8DD2B  cb cd 03
	inc 1,C                                              ; F8DD2E  cb 61
	and C,0xfb                                           ; F8DD30  cb cc fb
	jr .LF8DD4C                                          ; F8DD33  68 17
.LF8DD35:
	bit 0x02,C                                           ; F8DD35  cb 33 02
	jr z, .LF8DD44                                       ; F8DD38  66 0a
	ld A,E                                               ; F8DD3A  cd 89
	or C,0x08                                            ; F8DD3C  cb ce 08
	and C,0xf8                                           ; F8DD3F  cb cc f8
	jr .LF8DD4C                                          ; F8DD42  68 08
.LF8DD44:
	or C,0x04                                            ; F8DD44  cb ce 04
	jr .LF8DD4C                                          ; F8DD47  68 03
; ---------------------------------------------------------------------
; AnalogState_MaskOffLow3Bits -- clears the low three bits of C and returns
;
; Evidence: the routine is one instruction, 0xF8DD49 `and C,0xf8`, and a
;           `ret`. Its one caller is AnalogScan_Hysteresis.
; ⚠ CORRECTED IN ROUND 10: this header used to conclude "so the value being
;           coarsened is an analog reading". It is NOT. The register masked is
;           C, and AnalogScan_Hysteresis's OWN header calls C the STATE byte --
;           the reading is in A. The label's first line and its evidence line
;           contradicted each other, and the name said the wrong one.
; Unknown:  what the low three bits of the state byte mean, and why three.
;           AnalogScan_Hysteresis's threshold is not read here
; Was `sub_F8DD49`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
AnalogState_MaskOffLow3Bits:
	and C,0xf8                                           ; F8DD49  cb cc f8
.LF8DD4C:
	ret                                                  ; F8DD4C  0e
; AnalogScan_RamChannel4 -- normalise the RAM-fed channel 4 at (0x600000) and latch it if it moved
; Evidence: `ld A,(0x600000) / ld W,0x04 / call T_Ctrl_Normalise / jr nc` then (0x28EC) = A | 0x80
;   (0xF8DD4D-0xF8DD5D). (0x600000) is parked at 0x80 by AnalogScan_InitSoftChannels and
;   PanelAction_ResetAssignableCtrls and written by prom_b Ring601850_PutBlock_LeadB0_StoreNext.
;   AnalogScan_InitSoftChannels' header calls this routine "AnalogScan_SoftChannel4".
AnalogScan_RamChannel4:
	ld a, (0x600000:24)                                 ; F8DD4D  c2 00 00 60 21
	ld w, 0x04:opc                                          ; F8DD52  20 04
	call T_Ctrl_Normalise                                ; F8DD54  1d f0 05 f4
	jr nc, .LF8DD61                                      ; F8DD58  6f 07
	or A,0x80                                            ; F8DD5A  c9 ce 80
	ld (AnalogScan_Cooked:16), a                                   ; F8DD5D  f1 ec 28 41
.LF8DD61:
	ret                                                  ; F8DD61  0e
; AnalogScan_RamChannel5 -- normalise the RAM-fed channel 5 at (0x600001) and latch it if it moved
; Evidence: `ld A,(0x600001) / ld W,0x05 / call T_Ctrl_Normalise` then (0x28ED) = A | 0x80; (0x600001) written by
;   prom_b Ring601850_PutBlock_LeadB1_StoreNext, parked at 0x80 by AnalogScan_InitSoftChannels.  0xF8DDD1-0xF8DDE5 is
;   a byte-identical unlabelled copy (see AnalogScan_All's module header).
AnalogScan_RamChannel5:
	ld a, (0x600001:24)                                 ; F8DD62  c2 01 00 60 21
	ld w, 0x05:opc                                          ; F8DD67  20 05
	call T_Ctrl_Normalise                                ; F8DD69  1d f0 05 f4
	jr nc, .LF8DD76                                      ; F8DD6D  6f 07
	or A,0x80                                            ; F8DD6F  c9 ce 80
	ld (AnalogScan_Cooked+1:16), a                                   ; F8DD72  f1 ed 28 41
.LF8DD76:
	ret                                                  ; F8DD76  0e
	ld XBC,0xc88dc90e                                    ; F8DD77  41 0e c9 8d c8
	bit	0, (0x026b:16)                               ; F8DD7C  f1 6b 02 c8
	stcf	1, (xbc-56)                                  ; F8DD80  b9 c8 a1
	cp a, 0x02:i3                                          ; F8DD83  c9 da
	jr ule, .LF8DDB8                                     ; F8DD85  63 31
	cp a, 0x06:i3                                          ; F8DD87  c9 de
	jr ule, .LF8DDA4                                     ; F8DD89  63 19
	xor C,0x03                                           ; F8DD8B  cb cd 03
	jr nz, .LF8DD9A                                      ; F8DD8E  6e 0a
	ld A,E                                               ; F8DD90  cd 89
	or C,0x08                                            ; F8DD92  cb ce 08
	and C,0xf8                                           ; F8DD95  cb cc f8
	jr .LF8DDBB                                          ; F8DD98  68 21
.LF8DD9A:
	xor C,0x03                                           ; F8DD9A  cb cd 03
	inc 1,C                                              ; F8DD9D  cb 61
	and C,0xfb                                           ; F8DD9F  cb cc fb
	jr .LF8DDBB                                          ; F8DDA2  68 17
.LF8DDA4:
	bit 0x02,C                                           ; F8DDA4  cb 33 02
	jr z, .LF8DDB3                                       ; F8DDA7  66 0a
	ld A,E                                               ; F8DDA9  cd 89
	or C,0x08                                            ; F8DDAB  cb ce 08
	and C,0xf8                                           ; F8DDAE  cb cc f8
	jr .LF8DDBB                                          ; F8DDB1  68 08
.LF8DDB3:
	or C,0x04                                            ; F8DDB3  cb ce 04
	jr .LF8DDBB                                          ; F8DDB6  68 03
.LF8DDB8:
	and C,0xf8                                           ; F8DDB8  cb cc f8
.LF8DDBB:
	ret                                                  ; F8DDBB  0e
	ld a, (0x600000:24)                                 ; F8DDBC  c2 00 00 60 21
	ld w, 0x04:opc                                          ; F8DDC1  20 04
	call T_Ctrl_Normalise                                ; F8DDC3  1d f0 05 f4
	jr nc, .LF8DDD0                                      ; F8DDC7  6f 07
	or A,0x80                                            ; F8DDC9  c9 ce 80
	ld (AnalogScan_Cooked:16), a                                   ; F8DDCC  f1 ec 28 41
.LF8DDD0:
	ret                                                  ; F8DDD0  0e
	ld a, (0x600001:24)                                 ; F8DDD1  c2 01 00 60 21
	ld w, 0x05:opc                                          ; F8DDD6  20 05
	call T_Ctrl_Normalise                                ; F8DDD8  1d f0 05 f4
	jr nc, .LF8DDE5                                      ; F8DDDC  6f 07
	or A,0x80                                            ; F8DDDE  c9 ce 80
	ld (AnalogScan_Cooked+1:16), a                                   ; F8DDE1  f1 ed 28 41
.LF8DDE5:
	ret                                                  ; F8DDE5  0e

; 0xF8DDE6-0xF8E000 -- 539 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
; 2026-10-04: split 538 + 1.  The last pad byte, 0xF8E000, is the target of prom_b LinkSelector1_Table
;   entries [2] and [7] (the link's selector-1 dispatch, indexed by a command's top three bits): those two
;   selectors land on this `ret` and do nothing.  It is labelled so the table can name it.

; 0xF8DDE6-0xF8DFFF -- 538 bytes of 0x0E (RET), the pad above less its last byte (LinkSelector1_NoAction).
	.fill 538, 1, 0x0E
