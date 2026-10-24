; LinkSelector1_NoAction: the bare `ret` (a padding byte) that LinkSelector1_Table [2] and [7] name -- link selectors 2 and 7
;   have no handler.
LinkSelector1_NoAction:
	ret                                                  ; F8E000  0e

; ---------------------------------------------------------------------
; Link_Init_DmaAndTimer -- points micro-DMA channel 2's DESTINATION and channel 3's
;                          SOURCE at the link port and programs timer 2
;
; Evidence: 0xF8E014 `ld XIX,0x007c0000` is pushed to 0xF8E01A `call
;           0xf8e6a2` = uDMA2_SetDest with 0xF8E011 `pushw 0x08` as the
;           mode, and to 0xF8E022 `call 0xf8e6bc` = uDMA3_SetSource with
;           0xF8E01E `pushw 0x00`; the timer is 0xF8E002 `res_dd8 0x02,
;           0x20` (TRUN), 0xF8E005 T23MOD=0x0E, 0xF8E008 INTETC23=0x56,
;           0xF8E00B INTE0AD=0x01, 0xF8E00E TREG2=0x05, with the SFR
;           names from include/tmp95c061_sfr.inc
; Unknown:  the two mode bytes. FINDINGS-memory-map.md reads DMAM0 =
;           0x00 as device-to-RAM and 0x08 as RAM-to-device for the
;           FDC's channel 0, which is the SAME register field on the
;           same part, so 0x08 here reads as RAM-to-device and 0x00 as
;           device-to-RAM -- ⚠ that is a transfer of a field meaning
;           between channels, not a second measurement
; Was `sub_F8E001`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_Init_DmaAndTimer:
	push XIX                                             ; F8E001  3c
	res	2, (TRUN:8)                                   ; F8E002  f0 20 b2
	ld (T23MOD:8), 0x0e:io                                      ; F8E005  08 28 0e
	ld (INTETC23:8), 0x56:io                                      ; F8E008  08 7a 56
	ld (INTE0AD:8), 0x01:io                                      ; F8E00B  08 70 01
	ld (TREG2:8), 0x05:io                                      ; F8E00E  08 26 05
	pushw 0x08                                           ; F8E011  0b 08 00
	ld XIX,0x007c0000                                    ; F8E014  44 00 00 7c 00
	push XIX                                             ; F8E019  3c
	call uDMA2_SetDest                                        ; F8E01A  1d a2 e6 f8
	pushw 0x00                                           ; F8E01E  0b 00 00
	push XIX                                             ; F8E021  3c
	call uDMA3_SetSource                                        ; F8E022  1d bc e6 f8
	inc 8,XSP                                            ; F8E026  ef 60
	inc 4,XSP                                            ; F8E028  ef 64
	pop XIX                                              ; F8E02A  5c
	ret                                                  ; F8E02B  0e
; ---------------------------------------------------------------------
; Link_SendBlockIn32ByteChunks -- splits a buffer into 0x20-byte pieces and sends each with
;                                 Link_SendCountedBlock
;
; Evidence: 0xF8E032 `ld XIX,(XIZ+0x0c)` is the buffer and 0xF8E035 `ld
;           HL,(XIZ+0x0a)` the byte count, which is the frame
;           Link_SendCountedBlock itself reads (+0x08 selector, +0x0a
;           count, +0x0c buffer); the loop at 0xF8E03A pushes 0x20 as
;           the count, adds 0x20 to the buffer at 0xF8E046 and subtracts
;           0x20 from the remainder at 0xF8E04F while 0xF8E053 `cp
;           HL,0x0020` says more than a chunk is left, then
;           0xF8E059-0xF8E062 sends the remainder in one final call. The
;           chunk size is the five-bit length field
;           Link_SendCountedBlock's own header derives (`(count - 1)` in
;           bits 4..0), and 0x20 is the largest count that fits it.
;           prom_b publishes it as T_Link_SendBlockIn32ByteChunks with 46 references
; Unknown:  what the selector at (XIZ+0x08) means to the far side -- the
;           same gap Link_SendCountedBlock's header states
; Was `sub_F8E02C`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Link_SendBlockIn32ByteChunks:
	link XIZ,0x0000                                      ; F8E02C  ee 0c 00 00
	pushw hl                                             ; F8E030  2b
	push XIX                                             ; F8E031  3c
	ld XIX,(XIZ+0x0c)                                    ; F8E032  ae 0c 24
	ld HL,(XIZ+0x0a)                                     ; F8E035  9e 0a 23
	jr .LF8E053                                          ; F8E038  68 19
.LF8E03A:
	push XIX                                             ; F8E03A  3c
	pushw 0x20                                           ; F8E03B  0b 20 00
	push 0x00                                            ; F8E03E  09 00
	push	(xiz+8)                                      ; F8E040  8e 08 04
	calr Link_SendCountedBlock                           ; F8E043  1e 26 00
	add XIX,0x00000020                                   ; F8E046  ec c8 20 00 00 00
	ldw bc, 0x20                                         ; F8E04C  31 20 00
	sub HL,BC                                            ; F8E04F  d9 a3
	inc 8,XSP                                            ; F8E051  ef 60
.LF8E053:
	cp HL,0x0020                                         ; F8E053  db cf 20 00
	jr ugt, .LF8E03A                                     ; F8E057  6b e1
	push XIX                                             ; F8E059  3c
	ld C,L                                               ; F8E05A  cf 8b
	pushw bc                                             ; F8E05C  29
	push 0x00                                            ; F8E05D  09 00
	push	(xiz+8)                                      ; F8E05F  8e 08 04
	calr Link_SendCountedBlock                           ; F8E062  1e 07 00
	inc 8,XSP                                            ; F8E065  ef 60
	pop XIX                                              ; F8E067  5c
	popw hl                                              ; F8E068  4b
	unlk XIZ                                             ; F8E069  ee 0d
	ret                                                  ; F8E06B  0e
; ---------------------------------------------------------------------
; Link_SendCountedBlock -- sends one command byte that CARRIES ITS OWN BYTE COUNT,
;                          then that many bytes by micro-DMA
;
; Evidence: the command byte is built by 0xF8E0A0 `ld L,H` / 0xF8E0A2
;           `dec 1,L` / 0xF8E0A4 `ld C,(XIZ+0x08)` / 0xF8E0A7 `sll
;           c,0x05` / 0xF8E0AA `or C,L`, so it is ((XIZ+0x08) << 5) |
;           ((XIZ+0x0a) - 1), and it is written by 0xF8E0AF `ld
;           XBC,0x007c0000` / 0xF8E0B7 `ld (XBC),A`; the same (XIZ+0x0a)
;           is the count pushed at 0xF8E0D7 before 0xF8E0DC `call
;           0xf8e6af` = uDMA2_SetSource, whose buffer is 0xF8E0D8 `ld
;           XBC,(XIZ+0x0c)`. 0xF8E076 `cps h,0x00` returns without
;           sending anything when the count is zero
; Unknown:  what the three-bit field at bits 7..5 selects.
;           notes/wave7_xref_tlcs900_family.py --link reads the low five
;           bits of a link command as (length - 1) on BOTH machines,
;           which agrees with the arithmetic here; the top three bits it
;           calls a selector and neither tree says what the selector
;           means
; Was `sub_F8E06C`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCountedBlock:
	link XIZ,0xfffe                                      ; F8E06C  ee 0c fe ff
	pushw hl                                             ; F8E070  2b
	pushw de                                             ; F8E071  2a
	pushw ix                                             ; F8E072  2c
	ld H,(XIZ+0x0a)                                      ; F8E073  8e 0a 26
	cp h, 0x00:i3                                          ; F8E076  ce d8
	jrl z, .LF8E0F8                                      ; F8E078  76 7d 00
	pushw 0x02                                           ; F8E07B  0b 02 00
	call T_Kernel_SemaWait_StackArg                      ; F8E07E  1d c4 2d f4
	ldw de, 0x00                                         ; F8E082  32 00 00
	popw bc                                              ; F8E085  49
.LF8E086:
	bit	3, (P7:8)                                   ; F8E086  f0 13 cb
	jr nz, .LF8E097                                      ; F8E089  6e 0c
	ld IX,DE                                             ; F8E08B  da 8c
	inc 1,DE                                             ; F8E08D  da 61
	cp IX,0x4e20                                         ; F8E08F  dc cf 20 4e
	jr ule, .LF8E086                                     ; F8E093  63 f1
	jr .LF8E0F0                                          ; F8E095  68 59
.LF8E097:
	res	0, (P7:8)                                   ; F8E097  f0 13 b0
	ld (Link_TxBurstsLeft:24), 0x01                             ; F8E09A  f2 d9 07 60 00 01
	ld L,H                                               ; F8E0A0  ce 8f
	dec 1,L                                              ; F8E0A2  cf 69
	ld C,(XIZ+0x08)                                      ; F8E0A4  8e 08 23
	sll c, 0x05                                          ; F8E0A7  cb ee 05
	or C,L                                               ; F8E0AA  cf e3
	ld (xiz-2), c                                        ; F8E0AC  be fe 43
	ld XBC,0x007c0000                                    ; F8E0AF  41 00 00 7c 00
	ld a, (xiz-2)                                        ; F8E0B4  8e fe 21
	ld (XBC),A                                           ; F8E0B7  b1 41
	ldw de, 0x00                                         ; F8E0B9  32 00 00
.LF8E0BC:
	bit	3, (P7:8)                                   ; F8E0BC  f0 13 cb
	jr z, .LF8E0D0                                       ; F8E0BF  66 0f
	ld IX,DE                                             ; F8E0C1  da 8c
	inc 1,DE                                             ; F8E0C3  da 61
	cp IX,0x4e20                                         ; F8E0C5  dc cf 20 4e
	jr ule, .LF8E0BC                                     ; F8E0C9  63 f1
	set	0, (P7:8)                                   ; F8E0CB  f0 13 b8
	jr .LF8E0F0                                          ; F8E0CE  68 20
.LF8E0D0:
	set	0, (P7:8)                                   ; F8E0D0  f0 13 b8
	ld C,H                                               ; F8E0D3  ce 8b
	extz BC                                              ; F8E0D5  d9 12
	pushw bc                                             ; F8E0D7  29
	ld XBC,(XIZ+0x0c)                                    ; F8E0D8  ae 0c 21
	push XBC                                             ; F8E0DB  39
	call uDMA2_SetSource                                        ; F8E0DC  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E0E0  08 7e 12
	set	2, (TRUN:8)                                   ; F8E0E3  f0 20 ba
	inc 6,XSP                                            ; F8E0E6  ef 66
.LF8E0E8:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E0E8  c2 d9 07 60 3f 00
	jr nz, .LF8E0E8                                      ; F8E0EE  6e f8
.LF8E0F0:
	pushw 0x02                                           ; F8E0F0  0b 02 00
	call T_Kernel_SemaSignal_StackArg                    ; F8E0F3  1d c0 2d f4
	popw bc                                              ; F8E0F7  49
.LF8E0F8:
	popw ix                                              ; F8E0F8  4c
	popw de                                              ; F8E0F9  4a
	popw hl                                              ; F8E0FA  4b
	unlk XIZ                                             ; F8E0FB  ee 0d
	ret                                                  ; F8E0FD  0e
; ---------------------------------------------------------------------
; Link_SendCommandE2 -- sends command 0xE2 followed by a ten-byte record it stages
;                       at 0x600793
;
; Evidence: 0xF8E12B `ld XBC,0x007c0000` / 0xF8E130 `ld (XBC),0xe2`; the
;           record is 0xF8E14D-0xF8E15B, which writes (XIZ+0x08) as a
;           longword at (XIX), (XIZ+0x0e) as a longword at (XIX+0x04)
;           and (XIZ+0x0c) as a word at (XIX+0x08) with XIX = 0xF8E105
;           `lda_24 xix,(0x600793)`; 4 + 4 + 2 = 10 and 0xF8E15E `pushw
;           0x0a` is the count handed to 0xF8E162 `call 0xf8e6af` =
;           uDMA2_SetSource. ★ THE THREE FIELDS ARE READ FROM THE TWO
;           CALLERS, not from this body: ExtBoard_Identify pushes
;           0x2640, then 0x000A, then 0x00C00000 (0xF82892, 0xF82898,
;           0xF8289B) and VersionScreen_Show pushes 0x2640, then 0x000B,
;           then 0x00FFFFF0 (0xF82A2F, 0xF82A35, 0xF82A38), both
;           immediately before this call, so (XIZ+0x08) is the REMOTE
;           address, (XIZ+0x0c) the LENGTH and (XIZ+0x0e) the LOCAL
;           buffer, and the record is +0 remote32, +4 local32, +8 len16
; Unknown:  what a 0xE2 MEANS to CPU 2. Both known callers use it to
;           READ and nothing here says a 0xE2 cannot also write. ⚠ Two
;           callers is two, not a census: the frame reading above is
;           what those two do, and a third caller could still pass the
;           fields in another order
; Was `sub_F8E0FE`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCommandE2:
	link XIZ,0x0000                                      ; F8E0FE  ee 0c 00 00
	pushw hl                                             ; F8E102  2b
	pushw de                                             ; F8E103  2a
	push XIX                                             ; F8E104  3c
	lda xix, (0x600793:24)                               ; F8E105  f2 93 07 60 34
	ldw hl, 0x00                                         ; F8E10A  33 00 00
	jr .LF8E11A                                          ; F8E10D  68 0b
.LF8E10F:
	ld DE,HL                                             ; F8E10F  db 8a
	inc 1,HL                                             ; F8E111  db 61
	cp DE,0x4e20                                         ; F8E113  da cf 20 4e
	jrl ugt, .LF8E17B                                    ; F8E117  7b 61 00
.LF8E11A:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E11A  c2 d9 07 60 3f 00
	jr nz, .LF8E10F                                      ; F8E120  6e ed
	res	0, (P7:8)                                   ; F8E122  f0 13 b0
	ld (Link_TxBurstsLeft:24), 0x01                             ; F8E125  f2 d9 07 60 00 01
	ld XBC,0x007c0000                                    ; F8E12B  41 00 00 7c 00
	ld (XBC),0xe2                                        ; F8E130  b1 00 e2
	ldw hl, 0x00                                         ; F8E133  33 00 00
.LF8E136:
	bit	3, (P7:8)                                   ; F8E136  f0 13 cb
	jr z, .LF8E14A                                       ; F8E139  66 0f
	ld DE,HL                                             ; F8E13B  db 8a
	inc 1,HL                                             ; F8E13D  db 61
	cp DE,0x4e20                                         ; F8E13F  da cf 20 4e
	jr ule, .LF8E136                                     ; F8E143  63 f1
	set	0, (P7:8)                                   ; F8E145  f0 13 b8
	jr .LF8E17B                                          ; F8E148  68 31
.LF8E14A:
	set	0, (P7:8)                                   ; F8E14A  f0 13 b8
	ld XBC,(XIZ+0x08)                                    ; F8E14D  ae 08 21
	ld (XIX),XBC                                         ; F8E150  b4 61
	ld XBC,(XIZ+0x0e)                                    ; F8E152  ae 0e 21
	ld (XIX+0x04),XBC                                    ; F8E155  bc 04 61
	ld BC,(XIZ+0x0c)                                     ; F8E158  9e 0c 21
	ld (XIX+0x08),BC                                     ; F8E15B  bc 08 51
	pushw 0x0a                                           ; F8E15E  0b 0a 00
	push XIX                                             ; F8E161  3c
	call uDMA2_SetSource                                        ; F8E162  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E166  08 7e 12
	set	2, (TRUN:8)                                   ; F8E169  f0 20 ba
	set	7, (0x00008a:24)                             ; F8E16C  f2 8a 00 00 bf
	inc 6,XSP                                            ; F8E171  ef 66
.LF8E173:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E173  c2 d9 07 60 3f 00
	jr nz, .LF8E173                                      ; F8E179  6e f8
.LF8E17B:
	pop XIX                                              ; F8E17B  5c
	popw de                                              ; F8E17C  4a
	popw hl                                              ; F8E17D  4b
	unlk XIZ                                             ; F8E17E  ee 0d
	ret                                                  ; F8E180  0e
; ---------------------------------------------------------------------
; Link_SendCommandAndLong -- sends a command byte ORed with 0xE0 and then one 32-bit
;                            argument
;
; Evidence: 0xF8E1A8 `ld D,(XIZ+0x0c)` / 0xF8E1AB `or D,0xe0` / 0xF8E1AE
;           `ld XBC,0x007c0000` / 0xF8E1B3 `ld (XBC),D`; the argument is
;           0xF8E1CF `ld XBC,(XIZ+0x08)` stored by 0xF8E1D2 `stl_da
;           (0x60079d),xbc` and sent as 0xF8E1D7 `pushw 0x04` bytes from
;           0xF8E1DA `lda_24 xwa,(0x60079d)` through 0xF8E1E0 `call
;           0xf8e6af` = uDMA2_SetSource
; Unknown:  which commands of the 0xE0..0xFF group take a longword, and
;           what it is
; Was `sub_F8E181`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCommandAndLong:
	link XIZ,0x0000                                      ; F8E181  ee 0c 00 00
	pushw hl                                             ; F8E185  2b
	pushw de                                             ; F8E186  2a
	ldw hl, 0x00                                         ; F8E187  33 00 00
	jr .LF8E197                                          ; F8E18A  68 0b
.LF8E18C:
	ld DE,HL                                             ; F8E18C  db 8a
	inc 1,HL                                             ; F8E18E  db 61
	cp DE,0x4e20                                         ; F8E190  da cf 20 4e
	jrl ugt, .LF8E1F9                                    ; F8E194  7b 62 00
.LF8E197:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E197  c2 d9 07 60 3f 00
	jr nz, .LF8E18C                                      ; F8E19D  6e ed
	res	0, (P7:8)                                   ; F8E19F  f0 13 b0
	ld (Link_TxBurstsLeft:24), 0x01                             ; F8E1A2  f2 d9 07 60 00 01
	ld D,(XIZ+0x0c)                                      ; F8E1A8  8e 0c 24
	or D,0xe0                                            ; F8E1AB  cc ce e0
	ld XBC,0x007c0000                                    ; F8E1AE  41 00 00 7c 00
	ld (XBC),D                                           ; F8E1B3  b1 44
	ldw hl, 0x00                                         ; F8E1B5  33 00 00
.LF8E1B8:
	bit	3, (P7:8)                                   ; F8E1B8  f0 13 cb
	jr z, .LF8E1CC                                       ; F8E1BB  66 0f
	ld DE,HL                                             ; F8E1BD  db 8a
	inc 1,HL                                             ; F8E1BF  db 61
	cp DE,0x4e20                                         ; F8E1C1  da cf 20 4e
	jr ule, .LF8E1B8                                     ; F8E1C5  63 f1
	set	0, (P7:8)                                   ; F8E1C7  f0 13 b8
	jr .LF8E1F9                                          ; F8E1CA  68 2d
.LF8E1CC:
	set	0, (P7:8)                                   ; F8E1CC  f0 13 b8
	ld XBC,(XIZ+0x08)                                    ; F8E1CF  ae 08 21
	ld (0x60079d:24), xbc                               ; F8E1D2  f2 9d 07 60 61
	pushw 0x04                                           ; F8E1D7  0b 04 00
	lda xwa, (0x60079d:24)                               ; F8E1DA  f2 9d 07 60 30
	push XWA                                             ; F8E1DF  38
	call uDMA2_SetSource                                        ; F8E1E0  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E1E4  08 7e 12
	set	2, (TRUN:8)                                   ; F8E1E7  f0 20 ba
	set	7, (0x00008a:24)                             ; F8E1EA  f2 8a 00 00 bf
	inc 6,XSP                                            ; F8E1EF  ef 66
.LF8E1F1:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E1F1  c2 d9 07 60 3f 00
	jr nz, .LF8E1F1                                      ; F8E1F7  6e f8
.LF8E1F9:
	popw de                                              ; F8E1F9  4a
	popw hl                                              ; F8E1FA  4b
	unlk XIZ                                             ; F8E1FB  ee 0d
	ret                                                  ; F8E1FD  0e
; ---------------------------------------------------------------------
; Link_SendCommand3_WaitTicks -- sends command 3 with a 32-bit argument, then spins for 20
;                                ticks
;
; Evidence: 0xF8E207 `pushw 0x03` and 0xF8E20A `ld XBC,(XIZ+0x08)` are
;           the command byte and the longword Link_SendCommandAndLong
;           reads at (XIZ+0x0c) and (XIZ+0x08); 0xF8E202 copies the tick
;           word (0x0080) into the frame and the loop at
;           0xF8E213-0xF8E21D re-reads it, subtracts the copy and
;           compares with 0x0014. It is the same shape as
;           Link_SendCommand5_WaitDone, which waits on a FLAG instead of
;           on the clock
; Unknown:  why this one waits on time rather than on the far side. The
;           byte on the wire is 3 | 0xE0 = 0xE3, because
;           Link_SendCommandAndLong ORs 0xE0 in; the NAME carries the
;           literal 3 that is in this body
; Was `sub_F8E1FE`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Link_SendCommand3_WaitTicks:
	link XIZ,0xfffe                                      ; F8E1FE  ee 0c fe ff
	ldw	(xiz-2), (Tick_Count)                            ; F8E202  be fe 16 80 00
	pushw 0x03                                           ; F8E207  0b 03 00
	ld XBC,(XIZ+0x08)                                    ; F8E20A  ae 08 21
	push XBC                                             ; F8E20D  39
	calr Link_SendCommandAndLong                         ; F8E20E  1e 70 ff
	inc 6,XSP                                            ; F8E211  ef 66
.LF8E213:
	ld	bc, (Tick_Count:8)                                 ; F8E213  d0 80 21
	sub	bc, (xiz-2)                                  ; F8E216  9e fe a1
	cp BC,0x0014                                         ; F8E219  d9 cf 14 00
	jr lt, .LF8E213                                      ; F8E21D  61 f4
	unlk XIZ                                             ; F8E21F  ee 0d
	ret                                                  ; F8E221  0e
; ---------------------------------------------------------------------
; Link_SendCommand5_WaitDone -- sends command 5 with a 32-bit argument through
;                               Link_SendCommandAndLong, then waits for the far side to
;                               clear bit 6 of (0x00008A)
;
; Evidence: 0xF8E230 `pushw 0x05` and 0xF8E233 `ld XBC,(XIZ+0x08)` are
;           pushed to 0xF8E237 `calr Link_SendCommandAndLong`, whose own
;           frame reads the longword at (XIZ+0x08) and the command byte
;           at (XIZ+0x0c) -- the two pushes in that order put them
;           exactly there, which is a second and independent check on
;           that routine's argument frame; 0xF8E22B `m_set 6, MD24,
;           0x00008a` arms the flag and 0xF8E23C `m_bit 6, MD24,
;           0x00008a` polls it; the timeout is 0xF8E243, 0xF8E246 and
;           0xF8E249, the tick counter at (0x0080) minus the copy taken
;           at 0xF8E226, compared with 0x09C4 = 2500; on timeout
;           0xF8E24F `ldio 0x7f, 0x00` clears DMA3V and 0xF8E265 `ldw
;           wa, 0xffff` is the return value, otherwise 0xF8E26A `sub
;           WA,WA` returns zero
; Unknown:  the byte that reaches the wire is 5 | 0xE0 = 0xE5, because
;           Link_SendCommandAndLong ORs 0xE0 in; the NAME carries the
;           literal 5 that is in this body and not the derived 0xE5.
;           What clears bit 6 of (0x00008A) is not in this body either
; Was `sub_F8E222`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCommand5_WaitDone:
	link XIZ,0xfffe                                      ; F8E222  ee 0c fe ff
	ldw	(xiz-2), (Tick_Count)                            ; F8E226  be fe 16 80 00
	set	6, (0x00008a:24)                             ; F8E22B  f2 8a 00 00 be
	pushw 0x05                                           ; F8E230  0b 05 00
	ld XBC,(XIZ+0x08)                                    ; F8E233  ae 08 21
	push XBC                                             ; F8E236  39
	calr Link_SendCommandAndLong                         ; F8E237  1e 47 ff
	inc 6,XSP                                            ; F8E23A  ef 66
.LF8E23C:
	bit	6, (0x00008a:24)                             ; F8E23C  f2 8a 00 00 ce
	jr z, .LF8E26A                                       ; F8E241  66 27
	ld	bc, (Tick_Count:8)                                 ; F8E243  d0 80 21
	sub	bc, (xiz-2)                                  ; F8E246  9e fe a1
	cp BC,0x09c4                                         ; F8E249  d9 cf c4 09
	jr le, .LF8E23C                                      ; F8E24D  62 ed
	ld (DMA3V:8), 0x00:io                                      ; F8E24F  08 7f 00
	ld (Link_CompletionSelector:24), 0x00                             ; F8E252  f2 da 07 60 00 00
	set	1, (P7:8)                                   ; F8E258  f0 13 b9
	res	7, (0x00008a:24)                             ; F8E25B  f2 8a 00 00 b7
	inc 0x01, (Link_HandshakeTimeouts:24)                           ; F8E260  c2 db 07 60 61
	ldw wa, 0xffff                                       ; F8E265  30 ff ff
	jr .LF8E26C                                          ; F8E268  68 02
.LF8E26A:
	sub WA,WA                                            ; F8E26A  d8 a0
.LF8E26C:
	unlk XIZ                                             ; F8E26C  ee 0d
	ret                                                  ; F8E26E  0e
; ---------------------------------------------------------------------
; Link_SendCommandE1 -- sends command 0xE1, then a six-byte header, then a second
;                       block whose pointer and length are inside that header
;
; Evidence: 0xF8E29C `ld XBC,0x007c0000` / 0xF8E2A1 `ld (XBC),0xe1`; the
;           header is 0xF8E2DA `pushw 0x06` from 0xF8E2DD `lda_24
;           xbc,(0x6007a1)` through 0xF8E2E3 `call 0xf8e6af`; the second
;           transfer is 0xF8E2FF `ld BC,(XIX+0x04)` as the count and
;           0xF8E303 `ld XBC,(XIX)` as the pointer through 0xF8E306
;           `call 0xf8e6af`, with XIX = 0xF8E276 `lda_24
;           xix,(0x600782)`; between them 0xF8E2EF waits for (0x6007D9)
;           to reach 1 and 0xF8E2F7 `ldb h,0xc8` spins 200 times
; Unknown:  what commands 0xE1, 0xE4 and 0xE7 mean to the far side. All
;           three routines have this identical shape and differ only in
;           the command byte and the staging address
; Was `sub_F8E26F`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCommandE1:
	link XIZ,0x0000                                      ; F8E26F  ee 0c 00 00
	pushw hl                                             ; F8E273  2b
	pushw de                                             ; F8E274  2a
	push XIX                                             ; F8E275  3c
	lda xix, (0x600782:24)                               ; F8E276  f2 82 07 60 34
	ldw hl, 0x00                                         ; F8E27B  33 00 00
	jr .LF8E28B                                          ; F8E27E  68 0b
.LF8E280:
	ld DE,HL                                             ; F8E280  db 8a
	inc 1,HL                                             ; F8E282  db 61
	cp DE,0x4e20                                         ; F8E284  da cf 20 4e
	jrl ugt, .LF8E31A                                    ; F8E288  7b 8f 00
.LF8E28B:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E28B  c2 d9 07 60 3f 00
	jr nz, .LF8E280                                      ; F8E291  6e ed
	res	0, (P7:8)                                   ; F8E293  f0 13 b0
	ld (Link_TxBurstsLeft:24), 0x02                             ; F8E296  f2 d9 07 60 00 02
	ld XBC,0x007c0000                                    ; F8E29C  41 00 00 7c 00
	ld (XBC),0xe1                                        ; F8E2A1  b1 00 e1
	ldw hl, 0x00                                         ; F8E2A4  33 00 00
.LF8E2A7:
	bit	3, (P7:8)                                   ; F8E2A7  f0 13 cb
	jr z, .LF8E2BC                                       ; F8E2AA  66 10
	ld DE,HL                                             ; F8E2AC  db 8a
	inc 1,HL                                             ; F8E2AE  db 61
	cp DE,0x4e20                                         ; F8E2B0  da cf 20 4e
	jr ule, .LF8E2A7                                     ; F8E2B4  63 f1
	set	0, (P7:8)                                   ; F8E2B6  f0 13 b8
	jrl .LF8E31A                                         ; F8E2B9  78 5e 00
.LF8E2BC:
	set	0, (P7:8)                                   ; F8E2BC  f0 13 b8
	ld XBC,(XIZ+0x08)                                    ; F8E2BF  ae 08 21
	ld (XIX),XBC                                         ; F8E2C2  b4 61
	ld XBC,(XIZ+0x0e)                                    ; F8E2C4  ae 0e 21
	ld (Link_TxDest:24), xbc                               ; F8E2C7  f2 a1 07 60 61
	ld BC,(XIZ+0x0c)                                     ; F8E2CC  9e 0c 21
	ld (XIX+0x04),BC                                     ; F8E2CF  bc 04 51
	ld BC,(XIZ+0x0c)                                     ; F8E2D2  9e 0c 21
	ld (Link_TxCount:24), bc                                ; F8E2D5  f2 a5 07 60 51
	pushw 0x06                                           ; F8E2DA  0b 06 00
	lda xbc, (Link_TxDest:24)                               ; F8E2DD  f2 a1 07 60 31
	push XBC                                             ; F8E2E2  39
	call uDMA2_SetSource                                        ; F8E2E3  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E2E7  08 7e 12
	set	2, (TRUN:8)                                   ; F8E2EA  f0 20 ba
	inc 6,XSP                                            ; F8E2ED  ef 66
.LF8E2EF:
	cp	(Link_TxBurstsLeft:24), 0x01                          ; F8E2EF  c2 d9 07 60 3f 01
	jr nz, .LF8E2EF                                      ; F8E2F5  6e f8
	ld h, 0xc8:opc                                          ; F8E2F7  26 c8
.LF8E2F9:
	dec 1,H                                              ; F8E2F9  ce 69
	cp h, 0x00:i3                                          ; F8E2FB  ce d8
	jr nz, .LF8E2F9                                      ; F8E2FD  6e fa
	ld BC,(XIX+0x04)                                     ; F8E2FF  9c 04 21
	pushw bc                                             ; F8E302  29
	ld XBC,(XIX)                                         ; F8E303  a4 21
	push XBC                                             ; F8E305  39
	call uDMA2_SetSource                                        ; F8E306  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E30A  08 7e 12
	set	2, (TRUN:8)                                   ; F8E30D  f0 20 ba
	inc 6,XSP                                            ; F8E310  ef 66
.LF8E312:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E312  c2 d9 07 60 3f 00
	jr nz, .LF8E312                                      ; F8E318  6e f8
.LF8E31A:
	pop XIX                                              ; F8E31A  5c
	popw de                                              ; F8E31B  4a
	popw hl                                              ; F8E31C  4b
	unlk XIZ                                             ; F8E31D  ee 0d
	ret                                                  ; F8E31F  0e
; ---------------------------------------------------------------------
; Link_SendCommandE4 -- sends command 0xE4, then a six-byte header staged at
;                       0x6007A7, then the block that header points at -- the same
;                       shape as Link_SendCommandE1
;
; Evidence: 0xF8E34D `ld XBC,0x007c0000` / 0xF8E352 `ld (XBC),0xe4`; the
;           header is 0xF8E38B `pushw 0x06` from 0xF8E38E `lda_24
;           xbc,(0x6007a7)` through 0xF8E394 `call 0xf8e6af`; the
;           payload is 0xF8E3B0 `ld BC,(XIX+0x04)` and 0xF8E3B4 `ld
;           XBC,(XIX)` through 0xF8E3B7 `call 0xf8e6af`
; Unknown:  the meaning of command 0xE4, as above
; Was `sub_F8E320`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCommandE4:
	link XIZ,0x0000                                      ; F8E320  ee 0c 00 00
	pushw hl                                             ; F8E324  2b
	pushw de                                             ; F8E325  2a
	push XIX                                             ; F8E326  3c
	lda xix, (0x600782:24)                               ; F8E327  f2 82 07 60 34
	ldw hl, 0x00                                         ; F8E32C  33 00 00
	jr .LF8E33C                                          ; F8E32F  68 0b
.LF8E331:
	ld DE,HL                                             ; F8E331  db 8a
	inc 1,HL                                             ; F8E333  db 61
	cp DE,0x4e20                                         ; F8E335  da cf 20 4e
	jrl ugt, .LF8E3CB                                    ; F8E339  7b 8f 00
.LF8E33C:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E33C  c2 d9 07 60 3f 00
	jr nz, .LF8E331                                      ; F8E342  6e ed
	res	0, (P7:8)                                   ; F8E344  f0 13 b0
	ld (Link_TxBurstsLeft:24), 0x02                             ; F8E347  f2 d9 07 60 00 02
	ld XBC,0x007c0000                                    ; F8E34D  41 00 00 7c 00
	ld (XBC),0xe4                                        ; F8E352  b1 00 e4
	ldw hl, 0x00                                         ; F8E355  33 00 00
.LF8E358:
	bit	3, (P7:8)                                   ; F8E358  f0 13 cb
	jr z, .LF8E36D                                       ; F8E35B  66 10
	ld DE,HL                                             ; F8E35D  db 8a
	inc 1,HL                                             ; F8E35F  db 61
	cp DE,0x4e20                                         ; F8E361  da cf 20 4e
	jr ule, .LF8E358                                     ; F8E365  63 f1
	set	0, (P7:8)                                   ; F8E367  f0 13 b8
	jrl .LF8E3CB                                         ; F8E36A  78 5e 00
.LF8E36D:
	set	0, (P7:8)                                   ; F8E36D  f0 13 b8
	ld XBC,(XIZ+0x08)                                    ; F8E370  ae 08 21
	ld (XIX),XBC                                         ; F8E373  b4 61
	ld XBC,(XIZ+0x0e)                                    ; F8E375  ae 0e 21
	ld (0x6007a7:24), xbc                               ; F8E378  f2 a7 07 60 61
	ld BC,(XIZ+0x0c)                                     ; F8E37D  9e 0c 21
	ld (XIX+0x04),BC                                     ; F8E380  bc 04 51
	ld BC,(XIZ+0x0c)                                     ; F8E383  9e 0c 21
	ld (0x6007ab:24), bc                                ; F8E386  f2 ab 07 60 51
	pushw 0x06                                           ; F8E38B  0b 06 00
	lda xbc, (0x6007a7:24)                               ; F8E38E  f2 a7 07 60 31
	push XBC                                             ; F8E393  39
	call uDMA2_SetSource                                        ; F8E394  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E398  08 7e 12
	set	2, (TRUN:8)                                   ; F8E39B  f0 20 ba
	inc 6,XSP                                            ; F8E39E  ef 66
.LF8E3A0:
	cp	(Link_TxBurstsLeft:24), 0x01                          ; F8E3A0  c2 d9 07 60 3f 01
	jr nz, .LF8E3A0                                      ; F8E3A6  6e f8
	ld h, 0xc8:opc                                          ; F8E3A8  26 c8
.LF8E3AA:
	dec 1,H                                              ; F8E3AA  ce 69
	cp h, 0x00:i3                                          ; F8E3AC  ce d8
	jr nz, .LF8E3AA                                      ; F8E3AE  6e fa
	ld BC,(XIX+0x04)                                     ; F8E3B0  9c 04 21
	pushw bc                                             ; F8E3B3  29
	ld XBC,(XIX)                                         ; F8E3B4  a4 21
	push XBC                                             ; F8E3B6  39
	call uDMA2_SetSource                                        ; F8E3B7  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E3BB  08 7e 12
	set	2, (TRUN:8)                                   ; F8E3BE  f0 20 ba
	inc 6,XSP                                            ; F8E3C1  ef 66
.LF8E3C3:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E3C3  c2 d9 07 60 3f 00
	jr nz, .LF8E3C3                                      ; F8E3C9  6e f8
.LF8E3CB:
	pop XIX                                              ; F8E3CB  5c
	popw de                                              ; F8E3CC  4a
	popw hl                                              ; F8E3CD  4b
	unlk XIZ                                             ; F8E3CE  ee 0d
	ret                                                  ; F8E3D0  0e
; ---------------------------------------------------------------------
; Link_SendCommandE7 -- sends command 0xE7, then a six-byte header staged at
;                       0x6007AD whose length field is FORCED to 0x0400, then that
;                       1024-byte block
;
; Evidence: 0xF8E3FE `ld XBC,0x007c0000` / 0xF8E403 `ld (XBC),0xe7`; the
;           length is 0xF8E42D `m_ld_mi16 MDD+r4, 0x04, 0x0400` and its
;           copy 0xF8E432 `stiw_da (0x6007b1),0x0400`, so unlike E1 and
;           E4 the caller does not choose it; the header is 0xF8E439
;           `pushw 0x06` from 0xF8E43C `lda_24 xbc,(0x6007ad)`, the
;           payload 0xF8E45E `ld BC,(XIX+0x04)` and 0xF8E462 `ld
;           XBC,(XIX)`
; Unknown:  the meaning of command 0xE7, and why its block is always 1
;           KiB
; Was `sub_F8E3D1`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Link_SendCommandE7:
	link XIZ,0x0000                                      ; F8E3D1  ee 0c 00 00
	pushw hl                                             ; F8E3D5  2b
	pushw de                                             ; F8E3D6  2a
	push XIX                                             ; F8E3D7  3c
	lda xix, (0x600782:24)                               ; F8E3D8  f2 82 07 60 34
	ldw hl, 0x00                                         ; F8E3DD  33 00 00
	jr .LF8E3ED                                          ; F8E3E0  68 0b
.LF8E3E2:
	ld DE,HL                                             ; F8E3E2  db 8a
	inc 1,HL                                             ; F8E3E4  db 61
	cp DE,0x4e20                                         ; F8E3E6  da cf 20 4e
	jrl ugt, .LF8E479                                    ; F8E3EA  7b 8c 00
.LF8E3ED:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E3ED  c2 d9 07 60 3f 00
	jr nz, .LF8E3E2                                      ; F8E3F3  6e ed
	res	0, (P7:8)                                   ; F8E3F5  f0 13 b0
	ld (Link_TxBurstsLeft:24), 0x02                             ; F8E3F8  f2 d9 07 60 00 02
	ld XBC,0x007c0000                                    ; F8E3FE  41 00 00 7c 00
	ld (XBC),0xe7                                        ; F8E403  b1 00 e7
	ldw hl, 0x00                                         ; F8E406  33 00 00
.LF8E409:
	bit	3, (P7:8)                                   ; F8E409  f0 13 cb
	jr z, .LF8E41D                                       ; F8E40C  66 0f
	ld DE,HL                                             ; F8E40E  db 8a
	inc 1,HL                                             ; F8E410  db 61
	cp DE,0x4e20                                         ; F8E412  da cf 20 4e
	jr ule, .LF8E409                                     ; F8E416  63 f1
	set	0, (P7:8)                                   ; F8E418  f0 13 b8
	jr .LF8E479                                          ; F8E41B  68 5c
.LF8E41D:
	set	0, (P7:8)                                   ; F8E41D  f0 13 b8
	ld XBC,(XIZ+0x08)                                    ; F8E420  ae 08 21
	ld (XIX),XBC                                         ; F8E423  b4 61
	ld XBC,(XIZ+0x0c)                                    ; F8E425  ae 0c 21
	ld (0x6007ad:24), xbc                               ; F8E428  f2 ad 07 60 61
	ldw	(xix+4), 0x0400                              ; F8E42D  bc 04 02 00 04
	ldw (0x6007b1:24), 0x0400                           ; F8E432  f2 b1 07 60 02 00 04
	pushw 0x06                                           ; F8E439  0b 06 00
	lda xbc, (0x6007ad:24)                               ; F8E43C  f2 ad 07 60 31
	push XBC                                             ; F8E441  39
	call uDMA2_SetSource                                        ; F8E442  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E446  08 7e 12
	set	2, (TRUN:8)                                   ; F8E449  f0 20 ba
	inc 6,XSP                                            ; F8E44C  ef 66
.LF8E44E:
	cp	(Link_TxBurstsLeft:24), 0x01                          ; F8E44E  c2 d9 07 60 3f 01
	jr nz, .LF8E44E                                      ; F8E454  6e f8
	ld h, 0xc8:opc                                          ; F8E456  26 c8
.LF8E458:
	dec 1,H                                              ; F8E458  ce 69
	cp h, 0x00:i3                                          ; F8E45A  ce d8
	jr nz, .LF8E458                                      ; F8E45C  6e fa
	ld BC,(XIX+0x04)                                     ; F8E45E  9c 04 21
	pushw bc                                             ; F8E461  29
	ld XBC,(XIX)                                         ; F8E462  a4 21
	push XBC                                             ; F8E464  39
	call uDMA2_SetSource                                        ; F8E465  1d af e6 f8
	ld (DMA2V:8), 0x12:io                                      ; F8E469  08 7e 12
	set	2, (TRUN:8)                                   ; F8E46C  f0 20 ba
	inc 6,XSP                                            ; F8E46F  ef 66
.LF8E471:
	cp	(Link_TxBurstsLeft:24), 0x00                          ; F8E471  c2 d9 07 60 3f 00
	jr nz, .LF8E471                                      ; F8E477  6e f8
.LF8E479:
	pop XIX                                              ; F8E479  5c
	popw de                                              ; F8E47A  4a
	popw hl                                              ; F8E47B  4b
	unlk XIZ                                             ; F8E47C  ee 0d
	ret                                                  ; F8E47E  0e

; ==============================================================================
; 0xF8E47F-0xF8E54E -- INT0: the inter-processor link, and INTTC2
; ==============================================================================
;
; ★ HOW A MESSAGE ARRIVES FROM THE OTHER PROCESSOR.  notes/FINDINGS-memory-map.md
;   lists 0x7C0000 as "inter-processor link port (strobe P7.0, busy P7.3)"
;   without saying what the protocol is.  This handler is the protocol's
;   receiving half, and the mechanism is worth stating plainly because it is
;   unusual:
;
;     1. the first byte of a message raises INT0.  This handler reads it from
;        0x7C0000, keeps a copy at (0x600780), and uses it as a COMMAND;
;     2. from the command it works out how many more bytes will follow and
;        where they should go, and programmes micro-DMA channel 3 with that
;        destination and count;
;     3. it then writes DMA3V = 0x0A.  0x0A << 2 = 0x28, which is INT0's own
;        vector -- `tlcs900_process_hdma` computes the trigger as
;        (DMAnV & 0x1F) << 2 (tmp95c061.cpp:353).  So every FURTHER byte of the
;        message is absorbed by the DMA engine without the CPU seeing it, and
;        the CPU next hears about the message when the transfer completes and
;        raises INTTC3;
;     4. (0x6007DA) is set on the way in to tell INTTC3 (0xF8E54F, not yet
;        converted) which message it is finishing.
;
;   COMMAND BYTE -> DESTINATION AND LENGTH, exactly as the code has it:
;     0xE1        6 bytes  -> 0x6007D3   (0x6007DA) = 2
;     0xE2       10 bytes  -> 0x600788   (0x6007DA) = 3
;     0xE6        no payload            (0x6007DA) = 0, and bit 6 of (0x8A)
;                                        is cleared
;     anything   (byte & 0x1F) + 1 bytes -> 0x6007B3   (0x6007DA) = 1
;     else
;   ⚠ What the commands MEAN is not established -- only their payload sizes and
;   where the payload lands.  Do not name them.
;
;   P7 (SFR 0x13) carries the handshake: bit 2 is tested on entry and, when set,
;   the interrupt is taken and dropped without touching the port at all; bit 1 is
;   cleared after the DMA is armed, on all three paths that arm one.
;
; ---------------------------------------------------------------------
; INT0_LinkByte -- a byte arrived on the inter-processor link at 0x7C0000
;
; Called from: vector slot 0x28 (0xFFFF28 holds 0x00F40EDC, a prom_b thunk whose
;          body is `jp 0xF8E47F`).  ⚠ Only while DMA3V is not pointing at 0x28 --
;          once this handler arms the DMA, the same interrupt goes to the DMA
;          engine instead, and does not reach here again until INTTC3 re-points
;          it.  That is the whole design.
; Inputs:  the byte at 0x7C0000; P7 bit 2
; Outputs: (0x600780) = the command byte; micro-DMA channel 3 armed; DMA3V =
;          0x0A; (0x6007DA) = the completion selector; P7 bit 1 cleared.
;          All five saved registers restored; exits with RETI.
; Evidence: the port is literal -- `ld XBC,0x007C0000` at 0xF8E48F then `ld
;          H,(XBC)` at 0xF8E494 -- and the byte read is stored at (0x600780)
;          immediately (0xF8E496) and then compared against 0xE1, 0xE2 and
;          0xE6 (0xF8E49F, 0xF8E4A5, 0xF8E4AB), which is what makes it a
;          COMMAND and not data. notes/prom_a_byte_checks.py pins that vector
;          slot 0x28 does not point at the hang, and that each of the four
;          arming sites really is `ldio DMA3V,0x0A`.
; Notes:   the four arming sites all reach uDMA3_SetDest (0xF8E6C9) by loading
;          its address into XIX and jumping, having pushed count, destination and
;          a return address -- a stack-argument call written as a tail jump so
;          the helper's `ret` lands back in this handler.
; ---------------------------------------------------------------------
INT0_LinkByte:
	push XBC                                      ; F8E47F  39
	pushw wa                                      ; F8E480  28
	push XIY                                      ; F8E481  3d
	pushw hl                                      ; F8E482  2b
	push XIX                                      ; F8E483  3c
	lda xix, (uDMA3_SetDest:24)                   ; F8E484  f2 c9 e6 f8 34   XIX = uDMA3_SetDest, called four different ways below
	bit	2, (P7:8)                            ; F8E489  f0 13 ca   P7 bit 2 -- when set, take the interrupt and do nothing
	jrl nz, INT0_Link__return                              ; F8E48C  7e 98 00
	ld XBC,0x007c0000                             ; F8E48F  41 00 00 7c 00   the inter-processor link port
	ld H,(XBC)                                    ; F8E494  81 26   read the command byte
	ld (Link_RxCommand:24), h                          ; F8E496  f2 80 07 60 46   and keep it
	ld C,H                                        ; F8E49B  ce 8b
	extz BC                                       ; F8E49D  d9 12
	cp BC,0x00e1                                  ; F8E49F  d9 cf e1 00
	jr z, INT0_Cmd_E1                                ; F8E4A3  66 0e
	cp BC,0x00e2                                  ; F8E4A5  d9 cf e2 00
	jr z, INT0_Cmd_E2                                ; F8E4A9  66 27
	cp BC,0x00e6                                  ; F8E4AB  d9 cf e6 00
	jr z, INT0_Cmd_E6                                ; F8E4AF  66 40
	jr INT0_Cmd_Other                                   ; F8E4B1  68 4b
INT0_Cmd_E1:
	ld (Link_CompletionSelector:24), 0x02                      ; F8E4B3  f2 da 07 60 00 02   (0x6007DA) = which completion path INTTC3 should take
	pushw 0x06                                    ; F8E4B9  0b 06 00   count = 6
	lda xbc, (Link_E1Dest:24)                        ; F8E4BC  f2 d3 07 60 31   destination = 0x6007D3
	push XBC                                      ; F8E4C1  39
	lda xiy, (.LF8E4CA:24)                        ; F8E4C2  f2 ca e4 f8 35   the return address for the stack-argument call
	push XIY                                      ; F8E4C7  3d
	jp (xix)                                      ; F8E4C8  b4 d8
.LF8E4CA:
	ld (DMA3V:8), 0x0a:io                               ; F8E4CA  08 7f 0a   DMA3V = 0x0A; 0x0A << 2 = 0x28 = INT0, so the DMA engine now
	res	1, (P7:8)                            ; F8E4CD  f0 13 b1   absorbs the rest of the message.  P7 bit 1 = the acknowledge line
	jr INT0_Link__drop_args                                   ; F8E4D0  68 53
INT0_Cmd_E2:
	ld (Link_CompletionSelector:24), 0x03                      ; F8E4D2  f2 da 07 60 00 03
	pushw 0x0a                                    ; F8E4D8  0b 0a 00   count = 10
	lda xbc, (Link_E2Payload:24)                        ; F8E4DB  f2 88 07 60 31   destination = 0x600788
	push XBC                                      ; F8E4E0  39
	lda xiy, (.LF8E4E9:24)                        ; F8E4E1  f2 e9 e4 f8 35
	push XIY                                      ; F8E4E6  3d
	jp (xix)                                      ; F8E4E7  b4 d8
.LF8E4E9:
	ld (DMA3V:8), 0x0a:io                               ; F8E4E9  08 7f 0a
	res	1, (P7:8)                            ; F8E4EC  f0 13 b1
	jr INT0_Link__drop_args                                   ; F8E4EF  68 34
INT0_Cmd_E6:
	ld (Link_CompletionSelector:24), 0x00                      ; F8E4F1  f2 da 07 60 00 00
	res	6, (0x00008a:24)                      ; F8E4F7  f2 8a 00 00 b6   0xE6 takes no payload at all
	jr INT0_Link__return                                   ; F8E4FC  68 29
INT0_Cmd_Other:
	ld (Link_CompletionSelector:24), 0x01                      ; F8E4FE  f2 da 07 60 00 01
	ld c, (Link_RxCommand:24)                          ; F8E504  c2 80 07 60 23   any other command: the low 5 bits are the payload LENGTH - 1
	and C,0x1f                                    ; F8E509  cb cc 1f
	extz BC                                       ; F8E50C  d9 12
	inc 1,BC                                      ; F8E50E  d9 61
	pushw bc                                      ; F8E510  29
	lda xbc, (Link_RxPayload:24)                        ; F8E511  f2 b3 07 60 31   destination = 0x6007B3
	push XBC                                      ; F8E516  39
	lda xiy, (.LF8E51F:24)                        ; F8E517  f2 1f e5 f8 35
	push XIY                                      ; F8E51C  3d
	jp (xix)                                      ; F8E51D  b4 d8
.LF8E51F:
	ld (DMA3V:8), 0x0a:io                               ; F8E51F  08 7f 0a
	res	1, (P7:8)                            ; F8E522  f0 13 b1
INT0_Link__drop_args:
	inc 6,XSP                                     ; F8E525  ef 66   drop the three pushed arguments
INT0_Link__return:
	pop XIX                                       ; F8E527  5c
	popw hl                                       ; F8E528  4b
	pop XIY                                       ; F8E529  5d
	popw wa                                       ; F8E52A  48
	pop XBC                                       ; F8E52B  59
	reti                                          ; F8E52C  07

; ---------------------------------------------------------------------
; INTTC2_uDMA2Done -- micro-DMA channel 2 finished its transfer
;
; Called from: vector slot 0x7C (0xFFFF7C holds 0x00F40EE4, a prom_b thunk whose
;          body is `jp 0xF8E52D`)
; Inputs:  (0x6007D9)
; Outputs: timer 2 stopped (TRUN bit 2), and (0x6007D9) stepped 2 -> 1 -> 0.
;          Returns with RETI having touched no registers at all.
; Evidence: the first instruction is the identification -- `res 2,(0x20)` at
;          0xF8E52D clears TRUN bit 2, i.e. stops the timer that PACES micro-
;          DMA channel 2, and no other peripheral is touched anywhere in the
;          handler. The channel number comes from the arming code rather than
;          from the slot name: 0xF8E166 is 08 7E 12 = `ldio DMA2V,0x12`, and
;          0x12 << 2 = 0x48 = the INTT2 vector, with `set 2,(0x20)` starting
;          the timer on the next instruction.
;          ⚠ the slot NAME "INTTC2" is the TLCS-900/H convention.
; Notes:   channel 2 is the one RESET's comment points at: 0xF8E166 writes
;          DMA2V = 0x12 (0x12 << 2 = 0x48 = INTT2) and starts timer 2, so the
;          timer paces the transfer and this handler stops it again.  The
;          (0x6007D9) countdown is what the arming code at 0xF8E173 spins on.
; ---------------------------------------------------------------------
INTTC2_uDMA2Done:
	res	2, (TRUN:8)                            ; F8E52D  f0 20 b2   TRUN bit 2 = stop timer 2, which is what triggers channel 2
	cp	(Link_TxBurstsLeft:24), 0x01                   ; F8E530  c2 d9 07 60 3f 01
	jr nz, INTTC2_uDMA2Done__try2                               ; F8E536  6e 08
	ld (Link_TxBurstsLeft:24), 0x00                      ; F8E538  f2 d9 07 60 00 00
	jr INTTC2_uDMA2Done__ret                                   ; F8E53E  68 0e
INTTC2_uDMA2Done__try2:
	cp	(Link_TxBurstsLeft:24), 0x02                   ; F8E540  c2 d9 07 60 3f 02
	jr nz, INTTC2_uDMA2Done__ret                               ; F8E546  6e 06
	ld (Link_TxBurstsLeft:24), 0x01                      ; F8E548  f2 d9 07 60 00 01
INTTC2_uDMA2Done__ret:
	reti                                          ; F8E54E  07

; ==============================================================================
; 0xF8E54F-0xF8E6A1 -- the inter-processor link, receive side
; ==============================================================================
;
; Three routines that finish what INT0_LinkByte (0xF8E47F, converted above)
; starts.  Together with the transmit block at 0xF8E0FE-0xF8E31F (still
; .incbin) they decode the whole protocol on the link port at 0x7C0000; see
; notes/FINDINGS-interprocessor-link.md, which this block extends.
;
; ★ THE 0xE1 / 0xE2 PAIR IS A REMOTE BLOCK READ, and that is not a guess -- the
;   four routines agree field for field:
;
;     * INT0_LinkByte puts an 0xE2 message's TEN payload bytes at 0x600788
;       (0xF8E4D2-0xF8E4E8, converted above).
;     * Link_ServiceTask below reads exactly those ten bytes back as three
;       fields -- long (0x600788), word (0x600790), long (0x60078C) -- and
;       passes them to the 0xE1 transmitter at 0xF8E26F.
;     * That transmitter (0xF8E2BC-0xF8E2FE, disassembled, not converted) sends
;       a SIX-byte header built as long (0x6007A1) = its XIZ+0x0E argument and
;       word (0x6007A5) = its XIZ+0x0C argument, then a second micro-DMA burst
;       of (XIX+4) bytes read from (XIX) -- the XIZ+0x0C count and the XIZ+0x08
;       address.
;     * INTTC3_LinkDmaDone below, selector 2, takes the SIX bytes an 0xE1
;       message left at 0x6007D3 and feeds long (0x6007D3) to DMAD3 and word
;       (0x6007D7) to DMAC3 -- destination then count, the same two fields in
;       the same order.
;
;   So: 0xE2 = "send me <count> bytes from <src>, and put them at <dst> in your
;   memory"; 0xE1 = "here is a block: <dst>, <count>, then the bytes".
;   ⚠ What the blocks CONTAIN is not established.
;
; Three RAM bytes are error counters, one per failure mode, and nothing in this
; block ever reads them -- they only count:
;   (0x6007DB)  the 0xE5/0xE6 handshake at 0xF8E222 timed out (2500 ticks)
;   (0x6007DC)  Link_ServiceTask's stall watchdog aborted a receive
;   (0x6007E1)  Link_WaitBlockDone timed out (500 ticks)

; ---------------------------------------------------------------------
; INTTC3_LinkDmaDone -- micro-DMA channel 3 finished: a link message has landed
;
; Called from: vector slot 0x80 (0xFFFF80 holds 0x00F40EE8, a prom_b thunk whose
;          body is `jp 0xF8E54F`).  Byte-checked with notes/prom_a_xref.py, which
;          finds that thunk and no other site naming this address.
; Inputs:  (0x6007DA), the selector INT0_LinkByte set from the command byte;
;          (0x600780) the command byte itself; the payload the DMA just wrote.
; Outputs: depends on the selector, see the four arms below.  XBC, WA, XIY and
;          QWA are saved and restored; exits with RETI.
; Evidence: the vector slot is the name.  "Channel 3" rather than any other
;          channel: INT0_LinkByte arms channel 3 (it calls uDMA3_SetDest at
;          0xF8E6C9) and writes DMA3V, and INTTC3 is that channel's
;          transfer-complete interrupt.
; Unknown:  what the eight commands dispatched through the prom_b table mean;
;          the meaning of bit 7 of (0x600792) beyond "Link_ServiceTask acts on
;          it"; why selector 0 (set for command 0xE6) reaches none of these arms
;          and simply returns.
; ---------------------------------------------------------------------
INTTC3_LinkDmaDone:
	push XBC                                      ; F8E54F  39
	pushw wa                                      ; F8E550  28
	push XIY                                      ; F8E551  3d
	push QWA                                      ; F8E552  d7 e2 04
	ld bc, (Link_CompletionSelector:24)                         ; F8E555  d2 da 07 60 21   the selector INT0 left behind
	extz BC                                       ; F8E55A  d9 12
	cp bc, 0x01:i3                                  ; F8E55C  d9 d9
	jr z, INTTC3_Sel1_GeneralCmd                  ; F8E55E  66 10
	cp bc, 0x02:i3                                  ; F8E560  d9 da
	jr z, INTTC3_Sel2_ArmPayload                  ; F8E562  66 49
	cp bc, 0x03:i3                                  ; F8E564  d9 db
	jr z, INTTC3_Sel3_ReadRequest                 ; F8E566  66 62
	cp bc, 0x04:i3                                  ; F8E568  d9 dc
	jrl z, INTTC3_Sel4_BlockDone                  ; F8E56A  76 73 00
	jrl INTTC3__return                            ; F8E56D  78 7e 00

; --- selector 1: any command that was not 0xE1/0xE2/0xE6 -----------------
; The payload is at 0x6007B3 and is (cmd & 0x1F) + 1 bytes long -- the same
; length rule INT0_LinkByte used to arm the DMA.  The command's TOP THREE BITS
; pick a handler from an eight-entry LE32 table at prom_b 0xF57D4F; the two
; arguments (address, then length) are pushed and the handler is entered with a
; stack-argument TAIL JUMP whose return address is the `stib_da` below.
;   idx 0 0x00F57C3F   idx 1 0x00F57C2D   idx 2 0x00F8E000   idx 3 0x00F57C50
;   idx 4 0x00F57C61   idx 5 0x00F57C97   idx 6 0x00F57C72   idx 7 0x00F8E000
; All eight have a 0x00 high byte and land inside 0xF00000-0xFFFFFF, which is
; what says the table really is eight entries wide and not longer.
INTTC3_Sel1_GeneralCmd:
	lda xbc, (Link_RxPayload:24)                        ; F8E570  f2 b3 07 60 31   arg 1: the payload buffer
	push XBC                                      ; F8E575  39
	ld a, (Link_RxCommand:24)                          ; F8E576  c2 80 07 60 21
	and A,0x1f                                    ; F8E57B  c9 cc 1f
	extz WA                                       ; F8E57E  d8 12
	inc 1,WA                                      ; F8E580  d8 61   arg 2: (cmd & 0x1F) + 1 = the length
	pushw wa                                      ; F8E582  28
	ld w, (Link_RxCommand:24)                          ; F8E583  c2 80 07 60 20
	srl w, 0x05                                   ; F8E588  c8 ef 05   the top three bits are the opcode
	ld C,W                                        ; F8E58B  c8 8b
	mul C,0x04                                    ; F8E58D  cb 08 04
	extz XBC                                      ; F8E590  e9 12
	add XBC,LinkSelector1_Table                   ; F8E592  e9 c8 4f 7d f5 00   prom_b, 8 x LE32
	ld XBC,(XBC)                                  ; F8E598  a1 21
	lda xiy, (INTTC3_Sel1__resume:24)             ; F8E59A  f2 a2 e5 f8 35
	push XIY                                      ; F8E59F  3d   the handler's `ret` lands there
	jp (xbc)                                      ; F8E5A0  b1 d8
INTTC3_Sel1__resume:
	ld (Link_CompletionSelector:24), 0x00                      ; F8E5A2  f2 da 07 60 00 00   the exchange is over
	set	1, (P7:8)                            ; F8E5A8  f0 13 b9   P7 bit 1 back to idle
	jr INTTC3__drop_args                          ; F8E5AB  68 19

; --- selector 2: an 0xE1 header arrived, so arm the DMA for its payload ---
; The six bytes at 0x6007D3 are {LE32 destination, LE16 count}; DMA3V = 0x0A
; re-points INT0's own vector at the DMA engine again so the block is absorbed
; without another interrupt, and selector 4 is what will see it finish.
INTTC3_Sel2_ArmPayload:
	ld bc, (Link_E1Count:24)                         ; F8E5AD  d2 d7 07 60 21   count
	pushw bc                                      ; F8E5B2  29
	ld xbc, (Link_E1Dest:24)                        ; F8E5B3  e2 d3 07 60 21   destination
	push XBC                                      ; F8E5B8  39
	call uDMA3_SetDest                            ; F8E5B9  1d c9 e6 f8   DMAD3 := dest, DMAC3 := count
	ld (DMA3V:8), 0x0a:io                              ; F8E5BD  08 7f 0a   0x0A << 2 = 0x28 = INT0
	ld (Link_CompletionSelector:24), 0x04                      ; F8E5C0  f2 da 07 60 00 04
INTTC3__drop_args:
	inc 6,XSP                                     ; F8E5C6  ef 66   drop the two pushed arguments
	jr INTTC3__return                             ; F8E5C8  68 24

; --- selector 3: an 0xE2 read request arrived --------------------------------
; The ten payload bytes are already at 0x600788.  This arm only flags them;
; Link_ServiceTask below is what answers, from the main-loop rota rather than
; from interrupt context.
INTTC3_Sel3_ReadRequest:
	ld (0x600781:24), 0xff                      ; F8E5CA  f2 81 07 60 00 ff
	ld (Link_CompletionSelector:24), 0x00                      ; F8E5D0  f2 da 07 60 00 00
	set	1, (P7:8)                            ; F8E5D6  f0 13 b9   P7 bit 1 back to idle
	set	7, (Link_PendingFlags:24)                      ; F8E5D9  f2 92 07 60 bf   "an 0xE2 is pending"
	jr INTTC3__return                             ; F8E5DE  68 0e

; --- selector 4: the payload of an 0xE1 block finished arriving --------------
INTTC3_Sel4_BlockDone:
	ld (Link_CompletionSelector:24), 0x00                      ; F8E5E0  f2 da 07 60 00 00
	res	7, (0x00008a:24)                      ; F8E5E6  f2 8a 00 00 b7   release Link_WaitBlockDone
	set	1, (P7:8)                            ; F8E5EB  f0 13 b9   P7 bit 1 back to idle
INTTC3__return:
	pop QWA                                       ; F8E5EE  d7 e2 05
	pop XIY                                       ; F8E5F1  5d
	popw wa                                       ; F8E5F2  48
	pop XBC                                       ; F8E5F3  59
	reti                                          ; F8E5F4  07

; A lone 0x0E-style pad, except that this image pads interrupt code with the
; one-byte RETI (0x07) rather than the one-byte RET: nothing jumps to 0xF8E5F5
; -- notes/prom_a_xref.py finds no site naming it -- and the next routine starts
; on the following byte.
	reti                                          ; F8E5F5  07

; ---------------------------------------------------------------------
; Link_ServiceTask -- the link's main-loop half: answer 0xE2, watchdog the DMA
;
; Called from: prom_b thunk 0xF40ED8 (`jp 0xF8E5F6`), which prom_a calls at
;          0xF82165 -- inside a `tset 5,(0x88)` arm of the main-loop rota, so
;          this runs once per pass of that rota and not in interrupt context.
;          notes/prom_a_xref.py finds that one thunk and that one call site.
; Inputs:  bit 7 of (0x600792); P7 (0x13) bit 1; DMAC3; (0x6007DF)
; Outputs: an 0xE1 block transfer when an 0xE2 was pending; (0x6007DD) the
;          stall count; (0x6007DF) the previous DMAC3 sample; on abort, DMA3V=0,
;          (0x6007DA)=0, P7 bit 1 set and (0x6007DC) incremented.  XIX saved.
; Evidence: two halves, each named by what it reads.  The first reads the three
;          fields of the 0xE2 record at 0x600788/0x60078C/0x600790 -- exactly
;          the ten bytes INT0_LinkByte stores for command 0xE2 -- and hands them
;          to the 0xE1 transmitter.  The second samples the channel-3 transfer
;          counter through uDMA3_GetCount (0xF8E6DA, converted below, which
;          reads control register 0x2C = DMAC3) and gives up when eleven
;          consecutive samples are equal.
; Unknown:  what the three fields address; why the interrupt level is raised to
;          6 for the flag test and dropped to 0 afterwards.
; ---------------------------------------------------------------------
Link_ServiceTask:
	push XIX                                      ; F8E5F6  3c
	lda xix, (0x6007dd:24)                        ; F8E5F7  f2 dd 07 60 34   XIX = &stall counter
	ei 0x06                                       ; F8E5FC  06 06
	bit	7, (Link_PendingFlags:24)                      ; F8E5FE  f2 92 07 60 cf   0xE2 pending?
	jr z, Link_ServiceTask__watchdog               ; F8E603  66 20
	res	7, (Link_PendingFlags:24)                      ; F8E605  f2 92 07 60 b7
	ei 0x00                                       ; F8E60A  06 00
	ld xbc, (Link_E2Payload+4:24)                        ; F8E60C  e2 8c 07 60 21   field 2: destination
	push XBC                                      ; F8E611  39
	ld bc, (Link_E2Payload+8:24)                         ; F8E612  d2 90 07 60 21   field 3: count
	pushw bc                                      ; F8E617  29
	ld xbc, (Link_E2Payload:24)                        ; F8E618  e2 88 07 60 21   field 1: source
	push XBC                                      ; F8E61D  39
	calr Link_SendCommandE1                    ; F8E61E  1e 4e fc   the 0xE1 block transmitter
	inc 8,XSP                                     ; F8E621  ef 60   +8
	inc 2,XSP                                     ; F8E623  ef 62   +2 = the 10 argument bytes
Link_ServiceTask__watchdog:
	ei 0x00                                       ; F8E625  06 00
	bit	1, (P7:8)                            ; F8E627  f0 13 c9   P7 bit 1 set = nothing in flight
	jr nz, Link_ServiceTask__idle                 ; F8E62A  6e 1e
	call uDMA3_GetCount                           ; F8E62C  1d da e6 f8   WA := DMAC3
	cp (Link_LastDmaCount:24), wa                      ; F8E630  d2 df 07 60 f8   same as last pass?
	jr nz, Link_ServiceTask__moved                ; F8E635  6e 04
	incw 0x01, (xix)                              ; F8E637  94 61   stalled: count it
	jr Link_ServiceTask__save                     ; F8E639  68 04
Link_ServiceTask__moved:
	ldw	(xix), 0x0000                         ; F8E63B  b4 02 00 00   progress: reset the count
Link_ServiceTask__save:
	call uDMA3_GetCount                           ; F8E63F  1d da e6 f8
	ld (Link_LastDmaCount:24), wa                         ; F8E643  f2 df 07 60 50
	jr Link_ServiceTask__check                    ; F8E648  68 04
Link_ServiceTask__idle:
	ldw	(xix), 0x0000                         ; F8E64A  b4 02 00 00
Link_ServiceTask__check:
	ld BC,(XIX)                                   ; F8E64E  94 21
	cp BC,0x000a                                  ; F8E650  d9 cf 0a 00
	jr ule, Link_ServiceTask__done                ; F8E654  63 15
	ldw	(xix), 0x0000                         ; F8E656  b4 02 00 00   eleven equal samples: abort
	ld (DMA3V:8), 0x00:io                              ; F8E65A  08 7f 00   un-point INT0 from the DMA engine
	ld (Link_CompletionSelector:24), 0x00                      ; F8E65D  f2 da 07 60 00 00
	set	1, (P7:8)                            ; F8E663  f0 13 b9   P7 bit 1 back to idle
	inc 0x01, (Link_StallAborts:24)                    ; F8E666  c2 dc 07 60 61   error counter
Link_ServiceTask__done:
	pop XIX                                       ; F8E66B  5c
	ret                                           ; F8E66C  0e

; ---------------------------------------------------------------------
; Link_WaitBlockDone -- block until the pending link transfer finishes
;
; Called from: prom_b thunk 0xF4123C (`jp 0xF8E66D`).  notes/prom_a_xref.py
;          finds 22 candidate `call 0xF4123C` sites in prom_a; they are an
;          opcode-anchored upper bound, not verified instruction boundaries.
;          Of those, FIFTEEN are real instructions in converted code --
;          0xFAABFB 0xFB24D7 0xFB256E 0xFB26D2 0xFB2769 0xFB6FD1 0xFC00BE
;          0xFC0188 0xFC1C62 0xFC20DF 0xFC219D 0xFE29EB 0xFE2A73 0xFE2B86
;          0xFE2BC6 -- enumerated exactly by notes/prom_a_converted_callers.py
;          (16 checks).  Fourteen of them wait after a T_F40EF0 packet build;
;          0xFB6FD1 does not, and what it waits on is unknown.
; Inputs:  bit 7 of (0x8A); the free-running tick counter (0x80), read 16-bit.
; Outputs: WA = 0 if the flag cleared in time, 0xFFFF if it did not.  On
;          timeout it also aborts the transfer: DMA3V = 0, (0x6007DA) = 0, P7
;          bit 1 set, bit 7 of (0x8A) cleared, (0x6007E1) incremented.  HL saved.
; Evidence: the flag is bit 7 of (0x8A), and a byte census of the five-byte
;          form `F2 8A 00 00 <op>` over prom_a and prom_b finds every site that
;          touches it: SET at 0xF8E16C and 0xF8E1EA -- both immediately after
;          micro-DMA channel 2 has been armed and timer 2 started, i.e. as an
;          outgoing transfer begins -- and CLEARED at 0xF8E25B, at
;          INTTC3_Sel4_BlockDone (0xF8E5E6) and here.  So the flag is "a link
;          transfer is outstanding" and this routine is the wait for it.
;          0x1F4 = 500 ticks of (0x80); INTT1_Tick (0xF82D0B) is what increments
;          (0x80), and notes/FINDINGS-system-clock.md derives its rate.
; Unknown:  which of the two SET sites the callers are actually waiting on --
;          this routine cannot tell them apart.
; ---------------------------------------------------------------------
Link_WaitBlockDone:
	pushw hl                                      ; F8E66D  2b
	ld	hl, (Tick_Count:8)                          ; F8E66E  d0 80 23   HL := the tick count at entry
Link_WaitBlockDone__poll:
	bit	7, (0x00008a:24)                      ; F8E671  f2 8a 00 00 cf
	jr z, Link_WaitBlockDone__ok                  ; F8E676  66 26
	ld	bc, (Tick_Count:8)                          ; F8E678  d0 80 21
	sub BC,HL                                     ; F8E67B  db a1
	cp BC,0x01f4                                  ; F8E67D  d9 cf f4 01   500 ticks
	jr le, Link_WaitBlockDone__poll               ; F8E681  62 ee
	ld (DMA3V:8), 0x00:io                              ; F8E683  08 7f 00
	ld (Link_CompletionSelector:24), 0x00                      ; F8E686  f2 da 07 60 00 00
	set	1, (P7:8)                            ; F8E68C  f0 13 b9
	res	7, (0x00008a:24)                      ; F8E68F  f2 8a 00 00 b7
	inc 0x01, (Link_BlockDoneTimeouts:24)                    ; F8E694  c2 e1 07 60 61   error counter
	ldw wa, 0xffff                                ; F8E699  30 ff ff   timed out
.LF8E69C:
	jr Link_WaitBlockDone__ret                    ; F8E69C  68 02
Link_WaitBlockDone__ok:
	sub WA,WA                                     ; F8E69E  d8 a0   WA = 0
Link_WaitBlockDone__ret:
	popw hl                                       ; F8E6A0  4b
	ret                                           ; F8E6A1  0e

; ==============================================================================
; 0xF8E6A2-0xF8E6F9 -- micro-DMA channel setup, and a word-at-a-time block copy
; ==============================================================================
;
; Eight one-line leaf routines around the TLCS-900 micro-DMA control registers.
; Their arguments come off the STACK, not in registers -- (XSP+4) is the first
; argument and (XSP+8) the second -- so they are compiler-called helpers, and the
; caller has to clean up (0xF8E171's `inc 6,XSP` is one such site).
;
; ⚠ THE SECOND ARGUMENT IS NOT THE SAME THING IN ALL FOUR SETTERS, and an
; earlier version of this block said it was ("the transfer count for the
; 'source' pair and the DMAM mode byte for the 'dest' pair" -- audit round 1,
; F8).  That holds for channel 2 and is exactly backwards for channel 3.  What
; each routine actually writes, read straight off the four bodies below:
;
;     routine            (XSP+4) ->        (XSP+8) ->
;     uDMA2_SetDest      DMAD2  0x18       DMAM2  0x2A   mode byte
;     uDMA2_SetSource    DMAS2  0x08       DMAC2  0x28   transfer count
;     uDMA3_SetSource    DMAS3  0x0C       DMAM3  0x2E   mode byte
;     uDMA3_SetDest      DMAD3  0x1C       DMAC3  0x2C   transfer count
;
; (control-register numbers as this file's own .equ block gives them, lines
; 367-382, and as they appear in the encoded third byte of every line below)
;
; So the mode byte rides with the SOURCE setter on channel 3 and with the
; DESTINATION setter on channel 2.  The names are taken from the first register
; each routine writes, which is the only part that is uniform.  Note also the
; operand widths agree with that table and not with the old sentence: the two
; mode writes load `C` (8-bit) and the two count writes load `BC` (16-bit).
;
; ⚠ WHICH CONTROL REGISTER IS WHICH is MAME's decode, not a databook:
; 900tbl.hxx:3931-4030 maps 0x00/0x04/0x08/0x0C to DMAS0-3, 0x10-0x1C to
; DMAD0-3, 0x20-0x2C to DMAC0-3 and 0x22-0x2E to DMAM0-3 for exactly this part
; family (the `// TMP96C141/TMP95C061/TMP95C063` cases).  The equates are in the
; macro prelude at the top of this file.
;
; CHANNEL 2 is the one RESET's comment already points at: 0xF8E166 arms it with
; `ldio DMA2V,0x12`, and 0x12 << 2 = 0x48 = INTT2, so timer 2 drives it.  Both
; channel 2 and channel 3 are set up from here.
;
; ---------------------------------------------------------------------
; uDMA2_SetDest / uDMA2_SetSource / uDMA3_SetSource / uDMA3_SetDest
; uDMA2_GetCount / uDMA3_GetCount / uDMA3_GetDest
;
; Called from: 0xF8E162 calls uDMA2_SetSource; INT0_LinkByte loads
;          `lda XIX,0xF8E6C9` at 0xF8E484 and reaches uDMA3_SetDest through
;          `jp (XIX)` -- see 0xF8E4C8/0xF8E4E7/0xF8E51D.  The rest not traced.
; Inputs:  (XSP+4) = a 32-bit address for the four setters, (XSP+8) = the second
;          argument.  ⚠ Which register that second argument lands in is
;          per-routine, not per-name -- see the table above the block.
; Outputs: the two named control registers per setter, the named one per getter.
;          BC/XBC clobbered.
; Evidence: every one of the seven names is mechanical AND machine-checked:
;          notes/prom_a_byte_checks.py reads the CONTROL-REGISTER NUMBER out
;          of the third byte of each `ldc` and asserts the pair each setter
;          writes ("uDMA2_SetDest: writes CR 0x18 then CR 0x2A", and so for
;          all four), plus that the two MODE setters take an 8-bit operand and
;          the two COUNT setters a 16-bit one -- which is what distinguishes
;          them from each other. The control-register numbers come from MAME
;          (900tbl.hxx:3931-4030), not from a databook this tree does not
;          have.
; Notes:   the names are mechanical: each is named for the FIRST control register
;          it writes, and the four setters each write exactly two.
; ---------------------------------------------------------------------
uDMA2_SetDest:
	ld XBC,(XSP+0x04)                             ; F8E6A2  af 04 21
	ldc_cr32	xbc, CR_DMAD2                 ; F8E6A5  e9 2e 18
	ld C,(XSP+0x08)                               ; F8E6A8  8f 08 23
	ldc_cr8	c, CR_DMAM2                           ; F8E6AB  cb 2e 2a
	ret                                           ; F8E6AE  0e
uDMA2_SetSource:
	ld XBC,(XSP+0x04)                             ; F8E6AF  af 04 21
	ldc_cr32	xbc, CR_DMAS2                 ; F8E6B2  e9 2e 08
	ld BC,(XSP+0x08)                              ; F8E6B5  9f 08 21
	ldc_cr16	bc, CR_DMAC2                  ; F8E6B8  d9 2e 28
	ret                                           ; F8E6BB  0e
uDMA3_SetSource:
	ld XBC,(XSP+0x04)                             ; F8E6BC  af 04 21
	ldc_cr32	xbc, CR_DMAS3                 ; F8E6BF  e9 2e 0c
	ld C,(XSP+0x08)                               ; F8E6C2  8f 08 23
	ldc_cr8	c, CR_DMAM3                           ; F8E6C5  cb 2e 2e
	ret                                           ; F8E6C8  0e
uDMA3_SetDest:
	ld XBC,(XSP+0x04)                             ; F8E6C9  af 04 21
	ldc_cr32	xbc, CR_DMAD3                 ; F8E6CC  e9 2e 1c
	ld BC,(XSP+0x08)                              ; F8E6CF  9f 08 21
	ldc_cr16	bc, CR_DMAC3                  ; F8E6D2  d9 2e 2c
	ret                                           ; F8E6D5  0e
uDMA2_GetCount:
	ldc_16_cr	wa, CR_DMAC2                  ; F8E6D6  d8 2f 28
	ret                                           ; F8E6D9  0e
uDMA3_GetCount:
	ldc_16_cr	wa, CR_DMAC3                  ; F8E6DA  d8 2f 2c
	ret                                           ; F8E6DD  0e
uDMA3_GetDest:
	ldc_32_cr	xiy, CR_DMAD3                 ; F8E6DE  ed 2f 1c
	ret                                           ; F8E6E1  0e

; ---------------------------------------------------------------------
; MemCopyWords -- copy (XSP+0x10) BYTES from (XSP+0x08) to (XSP+0x0C)
;
; Called from: not yet traced
; Inputs:  all three arguments on the stack; XIX = destination, XIY = source,
;          BC = byte count (the routine loads them itself)
; Outputs: the block copied.  XIX is preserved (pushed/popped); XIY, BC
;          clobbered.
; Evidence: the direction is fixed by the INSTRUCTION, not by the argument
;          order.  On the TLCS-900 the block moves take their destination from
;          XIX and their source from XIY: MAME decodes the 0x90-0x97 prefix
;          group with `m_p1_reg32 = get_reg32_current(m_op - 1)` and
;          `m_p2_reg32 = get_reg32_current(m_op)` (900tbl.hxx:5472-5473, and
;          `reg & 7` at :198), and `op_LDIRW` is `WRMEMW(*p1, RDMEMW(*p2))`
;          (:2514).  Prefix 0x95 therefore means p1 = XIX, p2 = XIY.  So
;          `ld XIY,(XSP+0x08)` at 0xF8E6E6 loads the SOURCE and
;          `ld XIX,(XSP+0x0C)` at 0xF8E6E9 the DESTINATION.
;          Cross-check inside this same file: TextShift_CopyAtoC (0xF904D5)
;          loads XIY = 0x256A (buffer A) and XIX = 0x258A (buffer C) and its
;          header reads "(0x258A..) = (0x256A..)" -- the same direction.
;
; ★ CORRECTED 2026-08-25.  Both the title line and the Inputs line had source
;   and destination THE WRONG WAY ROUND ("XIY = destination, XIX = source").
;   The byte gate cannot see this: the bytes are right, the sentence was not.
; Notes:   it is a word copy with a one-byte lead-in: if the count is odd it
;          does a single LDI first (`ldi85`, 0xF8E6F1, the byte-size form of the
;          same operand group), then halves the count and runs LDIRW.  Not
;          micro-DMA at all despite the company it keeps -- LDI/LDIRW are
;          ordinary block-transfer instructions.
; ---------------------------------------------------------------------
MemCopyWords:
	push XIX                                      ; F8E6E2  3c
	ld BC,(XSP+0x10)                              ; F8E6E3  9f 10 21
	ld XIY,(XSP+0x08)                             ; F8E6E6  af 08 25
	ld XIX,(XSP+0x0c)                             ; F8E6E9  af 0c 24
	bit 0x00,BC                                   ; F8E6EC  d9 33 00
	jr z, .LF8E6F3                                ; F8E6EF  66 02
	ldi85                                         ; F8E6F1  85 10
.LF8E6F3:
	srl bc, 0x01                                  ; F8E6F3  d9 ef 01
	ldirw                                         ; F8E6F6  95 11
	pop XIX                                       ; F8E6F8  5c
	ret                                           ; F8E6F9  0e
; ---------------------------------------------------------------------
; 0xF8E6FA-0xF8E77C (130 B) -- CONVERTED, see
; notes/FINDINGS-prom_a-f8e6fa-boundary.md.  0xF8E77C-0xF8E7CD (81 B)
; REMAINS .incbin below, refused: no reader in the ROM cites it and the
; apparent pointer table's own alignment breaks partway through.
; ★ SUPERSEDED 2026-09-02: those 81 bytes are converted.  "No reader" still
;   holds and is restated there.  "The alignment breaks" does not: there are
;   TWO tables on TWO grids with 13 bytes of identified residue between them.
;   See the block at 0xF8E77C.
; ---------------------------------------------------------------------
	ret                                           ; F8E6FA  0e
	push XIX                                      ; F8E6FB  3c
	ld BC,(XSP+0x10)                              ; F8E6FC  9f 10 21
	ld XIY,(XSP+0x08)                             ; F8E6FF  af 08 25
	ld XIX,(XSP+0x0c)                             ; F8E702  af 0c 24
	bit 0x00,BC                                   ; F8E705  d9 33 00
	jr z, .LF8E70C                                ; F8E708  66 02
	ldi85                                         ; F8E70A  85 10
.LF8E70C:
	srl bc, 0x01                                  ; F8E70C  d9 ef 01
	ldirw                                         ; F8E70F  95 11
	pop XIX                                       ; F8E711  5c
	ret                                           ; F8E712  0e
	jr c, .LF8E731                                ; F8E713  67 1c
	jr z, .LF8E723                                ; F8E715  66 0c
	add (xix-4), bc                               ; F8E717  9c fc 89
	lda	xix, (xix+de)                           ; F8E71A  f3 07 f0 e8 34
	ldir85                                        ; F8E71F  85 11
	jr .LF8E747                                   ; F8E721  68 24
.LF8E723:
	ldw (xix-4), 0x00                             ; F8E723  bc fc 02 00 00
	lda	xix, (xix+de)                           ; F8E728  f3 07 f0 e8 34
	ldir85                                        ; F8E72D  85 11
	jr .LF8E747                                   ; F8E72F  68 16
.LF8E731:
	lda	xix, (xix+de)                           ; F8E731  f3 07 f0 e8 34
	ld DE,BC                                      ; F8E736  d9 8a
	ld BC,WA                                      ; F8E738  d8 89
	sub DE,WA                                     ; F8E73A  d8 a2
	ldir85                                        ; F8E73C  85 11
	ld BC,DE                                      ; F8E73E  da 89
	ld XIX,XHL                                    ; F8E740  eb 8c
	ld (xix-4), de                                ; F8E742  bc fc 52
	ldir85                                        ; F8E745  85 11
.LF8E747:
	popw de                                       ; F8E747  4a
	pop XIX                                       ; F8E748  5c
	pop XHL                                       ; F8E749  5b
	ret                                           ; F8E74A  0e
	lda xiy, (ZeroInitData_F8E773:24)             ; F8E74B  f2 73 e7 f8 35
	lda xix, (Link_E1Dest:24)                        ; F8E750  f2 d3 07 60 34
	ld XBC,0x00000009                             ; F8E755  41 09 00 00 00
	ldir85                                        ; F8E75A  85 11
	ld XBC,0x00000053                             ; F8E75C  41 53 00 00 00
	lda xix, (Link_RxCommand:24)                        ; F8E761  f2 80 07 60 34
	xor WA,WA                                     ; F8E766  d8 d0
.LF8E768:
	ld (xix+), a                             ; F8E768  f5 f0 41
	sub BC,0x0001                                 ; F8E76B  d9 ca 01 00
	jr nz, .LF8E768                               ; F8E76F  6e f7
	ret                                           ; F8E771  0e
	reti                                          ; F8E772  07
ZeroInitData_F8E773:   ; 9 B, all zero -- LDIR source named by the
; init routine above: `lda XIY,(0xf8e773)` / `ld XBC,0x00000009`
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F8E773
; ---------------------------------------------------------------------
; 0xF8E77C-0xF8E7CD (81 B) -- TWO LE32 ADDRESS TABLES with 13 bytes of
; identified residue between them.  Converted 2026-09-02 by
; notes/gen_prom_a_f8e77c_tables.py; argument in
; notes/FINDINGS-prom_a-f8e6fa-boundary.md, extended this pass.
;
; ★ THIS OVERTURNS THE REFUSAL IN THAT FINDINGS FILE.  Its reason was that
;   "the following 'pointers' are off by ONE byte relative to a fixed 4-byte
;   grid".  They are not off by one: there are TWO tables on TWO grids with
;   13 bytes between them, and notes/prom_a_ptr_tables.py -- which knows
;   nothing about this file -- finds both:
;       0xF8E774  10 entries (the first two are 0x00000000, inside the
;                  9-byte zero pad that precedes the table)
;       0xF8E7A1  11 entries (the first two are 0x00000000, inside the
;                  9-byte zero pad that precedes the table)
;   The second table is simply not 4-aligned, which this ROM does elsewhere.
;
; ★ WHY RUNS THIS SHORT ARE BELIEVED.  The detector's `--null` control over
;   0xFB2000-0xFB8000 reports 5 runs, two of them 16 entries -- which looks
;   like a false-positive rate that would sink a 10-entry run.  It is not.
;   ALL FIVE control hits (0xFB2081, 0xFB3517, 0xFB42D1, 0xFB6240, 0xFB62F6)
;   are the FIRST ENTRY of a `.long` table already declared in this file.
;   The detector's false-positive count on code in the control is ZERO.
;
; Also pinned: the second table ends EXACTLY at 0xF8E7CD, where the
; byte-verified 51-byte 0x0E pad begins; all 17 values are addresses inside
; this module's own 0xF8E000-0xF8E70C; and the 13-byte gap is BYTE-IDENTICAL
; to 0xF8E76F-0xF8E77C -- the last four bytes of the init routine at 0xF8E74B
; plus the nine-byte LDIR source it names -- a string that occurs in prom_a
; exactly twice, here and there.  Residue of the same shape, not a broken
; record; the same slack seen at 0xFDFFDF-0xFE0000.
;
; ⚠ NOT ESTABLISHED.  No reader: a whole-image LE24/LE32 scan for 0xF8E77C
;   and 0xF8E7A9 finds zero hits.  And these are NOT routine-entry tables --
;   only 5 of the 17 values land on an instruction boundary, about what
;   chance gives here.  `AddrTable` names the record SHAPE (LE32 in-image
;   addresses), not a role; what they address is unknown.
;
; ⚠ WHERE THE SECOND TABLE'S LABEL GOES IS A CHOICE, NOT A MEASUREMENT.  The
;   detector's run starts at 0xF8E7A1 and its first two entries are zeros, so the
;   nine zero bytes at 0xF8E7A0 could be residue OR two NULL table slots plus one
;   pad byte.  For the FIRST table the same question has an answer: the init
;   routine at 0xF8E74B names its nine-byte LDIR source by address (0xF8E773) and
;   count (9), which forces 0xF8E77C.  For the second there is no such witness,
;   and 0xF8E7A9 is chosen only to mirror it.  The bytes are identical either
;   way; only the label moves.
; ---------------------------------------------------------------------
; census: stale -- nothing in the image reads it, and 5 of its 8 targets are mid-instruction, where no live entry can land.
AddrTable_F8E77C:   ; 8 entries
	.long 0x00f8e68b   ; F8E77C  [0]
	.long 0x00f8e67a   ; F8E780  [1]
	.long 0x00f8e000   ; F8E784  [2]
	.long .LF8E69C     ; F8E788  [3]  instruction boundary
	.long uDMA2_SetDest+11   ; F8E78C  [4]
	.long uDMA3_GetDest+0x1 ; F8E790  [5]
	.long 0x00f8e6be   ; F8E794  [6]
	.long 0x00f8e000   ; F8E798  [7]
; 0xF8E79C-0xF8E7A9 (13 B) -- RESIDUE, byte-identical to 0xF8E76F-0xF8E77C:
; `jr nz / ret / reti` closing the init routine at 0xF8E74B, then the
; nine-byte LDIR source that follows it.  Left as bytes on purpose: framing
; these four as instructions would assert a control path nothing reaches.
; census: stale -- AddrTable_F8E7A9 below: nothing in the image reads it, and 2 of its 9 targets are mid-instruction.
	.byte 0x6e, 0xf7, 0x0e, 0x07                         ; F8E79C
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; F8E7A0
AddrTable_F8E7A9:   ; 9 entries; ends exactly where the 0x0E pad begins
	.long uDMA3_GetCount ; F8E7A9  [0]  instruction boundary
	.long uDMA3_SetDest ; F8E7AD  [1]  instruction boundary
	.long Link_Init_DmaAndTimer ; F8E7B1  [2]  instruction boundary
	.long 0x00f8e6eb   ; F8E7B5  [3]
	.long 0x00f8e000   ; F8E7B9  [4]
	.long .LF8E70C     ; F8E7BD  [5]  instruction boundary
	.long 0x00f8e029   ; F8E7C1  [6]
	.long 0x00f8e000   ; F8E7C5  [7]
	.long 0x00f8e000   ; F8E7C9  [8]
; 0xF8E7CD-0xF8E7FF -- 51 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: verified against original_ROMs/wsa1_prom_a.ic12.
	.fill 51, 1, 0x0E
