; =====================================================================
; 0xFAA000-0xFAD7FF -- the 0x60F0xx MESSAGE MODULE
;
; Chosen by notes/prom_a_call_graph.py --modules: T_F4078C-T_ParamMsg_RefreshMasksOnCtrlFieldChange was the
; highest-ranked UNCONVERTED prom_a directory module (x171 over 34 slots,
; targets 0xFAA418-0xFAC786), and T_PartSettings_ResetToDefault-T_Queue2E00_PostParam98Fields (x11) and T_F40774-T_F40784
; (x7) publish into the same span, so converting it whole retires three modules.
;
; MODULE EXTENT, and how it was established -- not by address arithmetic:
;   * 0xFA9E72-0xFA9FFF is 398 bytes of 0x0E (RET) padding and 0xFAD485-0xFAD800
;     INCLUSIVE is 892 more.  A module in this image sits between two such runs
;     (the same shape as 0xF84000 and 0xFE0000).  ★ The LAST of those 0x0E
;     bytes, 0xFAD800, is itself a published directory target (T_Evt2030_RunList) -- a
;     routine that is one `ret`.  This span therefore stops AT 0xFAD800 and
;     leaves that byte to the next module, which is why the `.fill` below is
;     890 and not 892: its first byte is inside the data block before it and
;     its last is the next module's.
;   * the pad runs are found by scanning, not assumed: every run of >= 6 equal
;     0x00/0x0E/0xFF bytes in 0xFA8000-0xFAE000 was listed before the span was
;     picked.
;
; WHAT IS IN IT
;   0xFAA000-0xFAA3FF  a stale copy of the bank's first 1 KiB -- see below
;   0xFAA400-0xFAC8E5  code: the phase vector ParamModule_PhaseVector, then
;                      34 published veneers over 0x60F000-0x60F1FF RAM,
;                      a command dispatcher, and four INLINE jump tables
;   0xFAC8E6-0xFAD485  data: two 256-entry tables, a 32-entry identity byte
;                      table, the 32 powers of two, and pointer tables into
;                      prom_b's 0xF3Fxxx
;   0xFAD485-0xFAD7FF  0x0E module padding
;
; ★ THE FOUR INLINE JUMP TABLES.  A linear disassembly of this span is NOT
; self-consistent as one run: notes/prom_a_linear_decode_check.py reports 8
; undecodable `db` bytes and three real callers landing mid-instruction.  Every
; one of them is the same shape -- a computed dispatch whose LE32 target table
; is emitted immediately after the `jp T,XBC` that reads it:
;
;     sub BC,<first case> / cp BC,<n> / jrl UGT,<default>
;     sll 0x02,BC / add XBC,<table> / ld XBC,(XBC) / jp T,XBC
;   <table>:  n+1 LE32 targets
;
; notes/prom_a_jumptables.py finds them from the ROM (it looks for the
; `ld XBC,(XBC) / jp T,XBC` pair with an `add XBC,imm32` whose immediate is the
; address of the next byte) and takes each ENTRY COUNT from the reader's OWN
; `cp BC,n`, never by eye.  Four in this span, thirteen in the whole image.
; With those four declared as data, each of the five remaining code sub-spans
; passes the decode check on its own; only 0xFAA000-0xFAB8B4 still reports
; callers into non-boundaries, and those three are the stale block below.
;
; ★★ 0xFAA000-0xFAA3FF IS AN OLDER COPY OF 0xFAA400-0xFAA7FF
; (and this is the reason the decode check cannot be made to pass over it).
; Corrected 2026-10-03: this said 0xFAA000-0xFAA417 and 0xFAA418-0xFAA82F.  Both blocks
; open with a five-slot vector, and 0xFAA400's is the LIVE one -- prom_b's pointer slot
; T_ParamModule_PhaseVector publishes it.  The copy's last instruction is cut off at 0xFAA3FF; decoded
; as one instruction with 0xFAA400, it had hidden the live vector's first slot.
;   * 0xFAA018-0xFAA3FF and 0xFAA418-0xFAA7FF are 1000 bytes that differ in
;     exactly TEN positions.  Measured, not sampled.
;   * eight of the ten are the low halves of FOUR `call` operands:
;         0xFAA029 call 0xFAADC2   |  0xFAA429 call 0xFAB658
;         0xFAA046 call 0xFAAE41   |  0xFAA446 call 0xFAB6D7
;         0xFAA06D call 0xFAAEE3   |  0xFAA46D call 0xFAB779
;         0xFAA08A call 0xFAAE92   |  0xFAA48A call 0xFAB728
;     every pair differs by EXACTLY 0x896.
;   * the other two are the middle bytes of two INTERNAL calls, and those
;     differ by exactly 0x400 -- the distance between the two copies -- so the
;     copy's self-references were relocated and its external ones were not.
;   * all four right-hand targets are published prom_b directory slots and all
;     four start with a `push` prologue.  THREE of the four left-hand targets
;     are two bytes INSIDE an instruction (0xFAADC0 `ld (0x60f080),0xba`,
;     0xFAAE3F `ld (XIZ+0xf2),XIY`, 0xFAAE90 `ld XBC,(XIZ+0xf2)`) -- checked
;     against a decode anchored on the published entry 0xFAAE2A, not on a
;     linear run.
;   * NOTHING PUBLISHES OR NAMES THE COPY: zero prom_b directory slots point
;     into 0xFAA000-0xFAA3FF, and of every `call`/`jp` literal in prom_a+prom_b
;     naming an address in it there are exactly TWO, both of them inside the
;     copy itself.  The live block has 37.
;   READING: an earlier build of the veneer bank, left in the ROM, carrying
;   pre-relocation addresses for the four routines it calls out to.  ⚠ That is
;   a reading.  What is ESTABLISHED is the ten-byte diff, the constant 0x896,
;   the three non-boundaries and the two-vs-thirty-seven reference counts.
;   Every one of those is re-derived by notes/prom_a_byte_checks.py, checks
;   named "stale veneer copy:".
;
; WHAT IS NOT ESTABLISHED: what the module is FOR.  It moves bytes between
; 0x60F000-0x60F1FF RAM and the prom_b directory; the four analysed dispatch
; tables index off a byte at (0x60F080) and off a caller's argument, and
; neither of those is traced to a source here.  Routine labels are therefore
; sub_XXXXXX except where a header below states its evidence.
; =====================================================================
; The stale vector: each slot holds the live slot's target (ParamModule_PhaseVector) minus how far that
; routine moved -- 0x400, the distance between the copies, for slots 0 and 2.
; census: stale -- nothing reaches this copy (no directory slot names it); 4 of its 5 targets are now mid-instruction.
ParamModule_PhaseVector_StaleCopy:
	jp	ParamModule_BootPhase0 - 0x400                                ; FAA000  1b 2a a4 fa
	jp	ParamModule_BootPhase1_MemoryIntact - 0x439                                ; FAA004  1b b7 a4 fa
	jp	ParamModule_BootPhase2_MemoryLost - 0x400                                ; FAA008  1b 82 a4 fa
	jp	ParamModule_BootPhase3 - 0x477                                ; FAA00C  1b d7 a4 fa
	jp	ParamModule_BootPhase4 - 0x439                                ; FAA010  1b b3 a4 fa
	ret                                                  ; FAA014  0e
	nop                                                  ; FAA015  00
	nop                                                  ; FAA016  00
	nop                                                  ; FAA017  00
	ld (0x60f160:24), hl                                ; FAA018  f2 60 f1 60 53
	ld (0x60f162:24), w                                 ; FAA01D  f2 62 f1 60 40
	push XWA                                             ; FAA022  38
	push XBC                                             ; FAA023  39
	push XDE                                             ; FAA024  3a
	push XHL                                             ; FAA025  3b
	push XIX                                             ; FAA026  3c
	push XIY                                             ; FAA027  3d
	push XIZ                                             ; FAA028  3e
; stale: the live twin at +0x400 calls SoundSel_ClampToProgramAndBank
	call	SoundSel_ClampToProgramAndBank - 0x896                              ; FAA029  1d c2 ad fa
	pop XIZ                                              ; FAA02D  5e
	pop XIY                                              ; FAA02E  5d
	pop XIX                                              ; FAA02F  5c
	pop XHL                                              ; FAA030  5b
	pop XDE                                              ; FAA031  5a
	pop XBC                                              ; FAA032  59
	pop XWA                                              ; FAA033  58
	ld hl, (0x60f164:24)                                ; FAA034  d2 64 f1 60 23
	ret                                                  ; FAA039  0e
; SoundSel_FromProgramAndBankRegs_StaleCopy: The stale copy of SoundSel_FromProgramAndBankRegs in the dead block
;   0xFAA018-0xFAA3FF: byte-identical to the live routine at +0x400 except the call displacement, which lands at
;   SoundSel_GroupMemberFromProgramAndBank - 0x896, not a routine start. Nothing reaches the copy. Basis: twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
SoundSel_FromProgramAndBankRegs_StaleCopy:
	ld (0x60f168:24), hl                                ; FAA03A  f2 68 f1 60 53
	push XWA                                             ; FAA03F  38
	push XBC                                             ; FAA040  39
	push XDE                                             ; FAA041  3a
	push XHL                                             ; FAA042  3b
	push XIX                                             ; FAA043  3c
	push XIY                                             ; FAA044  3d
	push XIZ                                             ; FAA045  3e
; stale: the live twin calls SoundSel_GroupMemberFromProgramAndBank
	call	SoundSel_GroupMemberFromProgramAndBank - 0x896                              ; FAA046  1d 41 ae fa
	pop XIZ                                              ; FAA04A  5e
	pop XIY                                              ; FAA04B  5d
	pop XIX                                              ; FAA04C  5c
	pop XHL                                              ; FAA04D  5b
	pop XDE                                              ; FAA04E  5a
	pop XBC                                              ; FAA04F  59
	pop XWA                                              ; FAA050  58
	ld hl, (0x60f16c:24)                                ; FAA051  d2 6c f1 60 23
	ld w, (0x60f16e:24)                                 ; FAA056  c2 6e f1 60 20
	ret                                                  ; FAA05B  0e
	ld (0x60f181:24), hl                                ; FAA05C  f2 81 f1 60 53
	ld (0x60f183:24), w                                 ; FAA061  f2 83 f1 60 40
	push XWA                                             ; FAA066  38
	push XBC                                             ; FAA067  39
	push XDE                                             ; FAA068  3a
	push XHL                                             ; FAA069  3b
	push XIX                                             ; FAA06A  3c
	push XIY                                             ; FAA06B  3d
	push XIZ                                             ; FAA06C  3e
; stale: the live twin calls CombiSel_ClampToNumberAndBank
	call	CombiSel_ClampToNumberAndBank - 0x896                              ; FAA06D  1d e3 ae fa
	pop XIZ                                              ; FAA071  5e
	pop XIY                                              ; FAA072  5d
	pop XIX                                              ; FAA073  5c
	pop XHL                                              ; FAA074  5b
	pop XDE                                              ; FAA075  5a
	pop XBC                                              ; FAA076  59
	pop XWA                                              ; FAA077  58
	ld hl, (0x60f185:24)                                ; FAA078  d2 85 f1 60 23
	ret                                                  ; FAA07D  0e
	ld (0x60f189:24), hl                                ; FAA07E  f2 89 f1 60 53
	push XWA                                             ; FAA083  38
	push XBC                                             ; FAA084  39
	push XDE                                             ; FAA085  3a
	push XHL                                             ; FAA086  3b
	push XIX                                             ; FAA087  3c
	push XIY                                             ; FAA088  3d
	push XIZ                                             ; FAA089  3e
; stale: the live twin calls CombiSel_GroupMemberFromNumberAndBank
	call	CombiSel_GroupMemberFromNumberAndBank - 0x896                              ; FAA08A  1d 92 ae fa
	pop XIZ                                              ; FAA08E  5e
	pop XIY                                              ; FAA08F  5d
	pop XIX                                              ; FAA090  5c
	pop XHL                                              ; FAA091  5b
	pop XDE                                              ; FAA092  5a
	pop XBC                                              ; FAA093  59
	pop XWA                                              ; FAA094  58
	ld hl, (0x60f18d:24)                                ; FAA095  d2 8d f1 60 23
	ld w, (0x60f18f:24)                                 ; FAA09A  c2 8f f1 60 20
	ret                                                  ; FAA09F  0e
; Queue2C00_PublishStagedIfPending_StaleCopy -- the stale copy of Queue2C00_PublishStagedIfPending @FAA4A0
;
; Evidence: 0xFAA018-0xFAA3FF is a copy of 0xFAA418-0xFAA7FF differing in
;          exactly ten bytes, established in
;          notes/FINDINGS-prom_a-message-module.md section 3a; this
;          routine's own body is byte-identical to its twin at +0x400.
;          Nothing publishes an entry into the copy: zero directory slots
;          point into it against 37 for the live block.
; Unknown: whether anything ever calls it.  The name asserts what the code
;          IS, not that it runs.
; ---------------------------------------------------------------------
Queue2C00_PublishStagedIfPending_StaleCopy:
	cp	(0x60f083:24), 0x00                          ; FAA0A0  c2 83 f0 60 3f 00
	jr z, .LFAA0FB                                       ; FAA0A6  66 53
	pushw wa                                             ; FAA0A8  28
	pushw hl                                             ; FAA0A9  2b
	push XIX                                             ; FAA0AA  3c
	ld hl, (0x60f000:24)                                ; FAA0AB  d2 00 f0 60 23
	cp HL,0x01fc                                         ; FAA0B0  db cf fc 01
	jr c, .LFAA0CA                                       ; FAA0B4  67 14
	push XWA                                             ; FAA0B6  38
	push XBC                                             ; FAA0B7  39
	push XDE                                             ; FAA0B8  3a
	push XHL                                             ; FAA0B9  3b
	push XIX                                             ; FAA0BA  3c
	push XIY                                             ; FAA0BB  3d
	push XIZ                                             ; FAA0BC  3e
	call T_Queue2C00_DrainPassAB                         ; FAA0BD  1d 18 00 f4
	pop XIZ                                              ; FAA0C1  5e
	pop XIY                                              ; FAA0C2  5d
	pop XIX                                              ; FAA0C3  5c
	pop XHL                                              ; FAA0C4  5b
	pop XDE                                              ; FAA0C5  5a
	pop XBC                                              ; FAA0C6  59
	pop XWA                                              ; FAA0C7  58
	xor HL,HL                                            ; FAA0C8  db d3
.LFAA0CA:
	ld XIX,0x00002c00                                    ; FAA0CA  44 00 2c 00 00
	ld wa, (0x60f080:24)                                ; FAA0CF  d2 80 f0 60 20
	ld	(xix+hl), wa                                 ; FAA0D4  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA0D9  db 62
	ld wa, (0x60f082:24)                                ; FAA0DB  d2 82 f0 60 20
	ld	(xix+hl), wa                                 ; FAA0E0  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA0E5  db 62
	ld	(xix+hl), 0xff                               ; FAA0E7  f3 07 f0 ec 00 ff
	ld (0x60f000:24), hl                                ; FAA0ED  f2 00 f0 60 53
	ld (0x60f083:24), 0x00                             ; FAA0F2  f2 83 f0 60 00 00
	pop XIX                                              ; FAA0F8  5c
	popw hl                                              ; FAA0F9  4b
	popw wa                                              ; FAA0FA  48
.LFAA0FB:
	ret                                                  ; FAA0FB  0e
	pushw wa                                             ; FAA0FC  28
	pushw hl                                             ; FAA0FD  2b
	push XIX                                             ; FAA0FE  3c
	ld hl, (0x60f000:24)                                ; FAA0FF  d2 00 f0 60 23
	cp HL,0x01fc                                         ; FAA104  db cf fc 01
	jr c, .LFAA0CA                                       ; FAA108  67 c0
	push XWA                                             ; FAA10A  38
	push XBC                                             ; FAA10B  39
	push XDE                                             ; FAA10C  3a
	push XHL                                             ; FAA10D  3b
	push XIX                                             ; FAA10E  3c
	push XIY                                             ; FAA10F  3d
	push XIZ                                             ; FAA110  3e
	call T_Queue2C00_DrainPassAB                         ; FAA111  1d 18 00 f4
	pop XIZ                                              ; FAA115  5e
	pop XIY                                              ; FAA116  5d
	pop XIX                                              ; FAA117  5c
	pop XHL                                              ; FAA118  5b
	pop XDE                                              ; FAA119  5a
	pop XBC                                              ; FAA11A  59
	pop XWA                                              ; FAA11B  58
	xor HL,HL                                            ; FAA11C  db d3
	ld XIX,0x00002c00                                    ; FAA11E  44 00 2c 00 00
	ld wa, (0x60f080:24)                                ; FAA123  d2 80 f0 60 20
	ld	(xix+hl), wa                                 ; FAA128  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA12D  db 62
	ld wa, (0x60f082:24)                                ; FAA12F  d2 82 f0 60 20
	ld	(xix+hl), wa                                 ; FAA134  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA139  db 62
	ld	(xix+hl), 0xff                               ; FAA13B  f3 07 f0 ec 00 ff
	ld (0x60f000:24), hl                                ; FAA141  f2 00 f0 60 53
	ld (0x60f083:24), 0x00                             ; FAA146  f2 83 f0 60 00 00
	pop XIX                                              ; FAA14C  5c
	popw hl                                              ; FAA14D  4b
	popw wa                                              ; FAA14E  48
	ret                                                  ; FAA14F  0e
	pushw wa                                             ; FAA150  28
	pushw hl                                             ; FAA151  2b
	push XIX                                             ; FAA152  3c
	ld hl, (0x60f000:24)                                ; FAA153  d2 00 f0 60 23
	cp HL,0x01fc                                         ; FAA158  db cf fc 01
	jr c, .LFAA172                                       ; FAA15C  67 14
	push XWA                                             ; FAA15E  38
	push XBC                                             ; FAA15F  39
	push XDE                                             ; FAA160  3a
	push XHL                                             ; FAA161  3b
	push XIX                                             ; FAA162  3c
	push XIY                                             ; FAA163  3d
	push XIZ                                             ; FAA164  3e
	call T_Queue2C00_DrainPassB                          ; FAA165  1d 38 00 f4
	pop XIZ                                              ; FAA169  5e
	pop XIY                                              ; FAA16A  5d
	pop XIX                                              ; FAA16B  5c
	pop XHL                                              ; FAA16C  5b
	pop XDE                                              ; FAA16D  5a
	pop XBC                                              ; FAA16E  59
	pop XWA                                              ; FAA16F  58
	xor HL,HL                                            ; FAA170  db d3
.LFAA172:
	ld XIX,0x00002c00                                    ; FAA172  44 00 2c 00 00
	ld wa, (0x60f080:24)                                ; FAA177  d2 80 f0 60 20
	ld	(xix+hl), wa                                 ; FAA17C  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA181  db 62
	ld wa, (0x60f082:24)                                ; FAA183  d2 82 f0 60 20
	ld	(xix+hl), wa                                 ; FAA188  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA18D  db 62
	ld	(xix+hl), 0xff                               ; FAA18F  f3 07 f0 ec 00 ff
	ld (0x60f000:24), hl                                ; FAA195  f2 00 f0 60 53
	ld (0x60f083:24), 0x00                             ; FAA19A  f2 83 f0 60 00 00
	pop XIX                                              ; FAA1A0  5c
	popw hl                                              ; FAA1A1  4b
	popw wa                                              ; FAA1A2  48
	ret                                                  ; FAA1A3  0e
	ret                                                  ; FAA1A4  0e
	ret                                                  ; FAA1A5  0e
	ret                                                  ; FAA1A6  0e
	push XIX                                             ; FAA1A7  3c
	pushw wa                                             ; FAA1A8  28
	push XHL                                             ; FAA1A9  3b
	cp d, 0x00:i3                                          ; FAA1AA  cc d8
	jr z, .LFAA1FA                                       ; FAA1AC  66 4c
	xor H,H                                              ; FAA1AE  ce d6
	ld L,C                                               ; FAA1B0  cb 8f
	sla hl, 0x02                                         ; FAA1B2  db ec 02
	ld xix, (IndexedTable_Base:24)                               ; FAA1B5  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA1BA  e3 07 f0 ec 24
	cp XIX,0xffffffff                                    ; FAA1BF  ec cf ff ff ff ff
	jr z, .LFAA1FA                                       ; FAA1C5  66 33
	xor H,H                                              ; FAA1C7  ce d6
	ld L,B                                               ; FAA1C9  ca 8f
	ld	a, (xix+hl)                                  ; FAA1CB  c3 07 f0 ec 21
	ld (0x60f08b:24), a                                 ; FAA1D0  f2 8b f0 60 41
	ld W,D                                               ; FAA1D5  cc 88
	xor W,0xff                                           ; FAA1D7  c8 cd ff
	and A,W                                              ; FAA1DA  c8 c1
	and E,D                                              ; FAA1DC  cc c5
	or A,E                                               ; FAA1DE  cd e1
	ld W,A                                               ; FAA1E0  c9 88
	xor w, (0x60f08b:24)                              ; FAA1E2  c2 8b f0 60 d0
	and W,D                                              ; FAA1E7  cc c0
	jr z, .LFAA1FA                                       ; FAA1E9  66 0f
	ld	(xix+hl), a                                  ; FAA1EB  f3 07 f0 ec 41
	ld (0x60f080:24), bc                                ; FAA1F0  f2 80 f0 60 51
	ld (0x60f082:24), wa                                ; FAA1F5  f2 82 f0 60 50
.LFAA1FA:
	pop XHL                                              ; FAA1FA  5b
	popw wa                                              ; FAA1FB  48
	pop XIX                                              ; FAA1FC  5c
	ret                                                  ; FAA1FD  0e
	ld (0x60f007:24), 0x00                             ; FAA1FE  f2 07 f0 60 00 00
; ParamChange_Notify_StaleCopy -- the stale copy of ParamChange_Notify @FAA604
;
; Evidence: 0xFAA018-0xFAA3FF is a copy of 0xFAA418-0xFAA7FF differing in
;          exactly ten bytes, established in
;          notes/FINDINGS-prom_a-message-module.md section 3a; this
;          routine's own body is byte-identical to its twin at +0x400.
;          Nothing publishes an entry into the copy: zero directory slots
;          point into it against 37 for the live block.
; Unknown: whether anything ever calls it.  The name asserts what the code
;          IS, not that it runs.
; ---------------------------------------------------------------------
ParamChange_Notify_StaleCopy:
	bit	0, (0x0922:16)                               ; FAA204  f1 22 09 c8
	jr z, .LFAA210                                       ; FAA208  66 06
	bit	1, (0x0922:16)                               ; FAA20A  f1 22 09 c9
	jr nz, .LFAA222                                      ; FAA20E  6e 12
.LFAA210:
	push XWA                                             ; FAA210  38
	push XBC                                             ; FAA211  39
	push XDE                                             ; FAA212  3a
	push XHL                                             ; FAA213  3b
	push XIX                                             ; FAA214  3c
	push XIY                                             ; FAA215  3d
	push XIZ                                             ; FAA216  3e
	call T_MidiOut_ParamChanged                          ; FAA217  1d 48 07 f4
	pop XIZ                                              ; FAA21B  5e
	pop XIY                                              ; FAA21C  5d
	pop XIX                                              ; FAA21D  5c
	pop XHL                                              ; FAA21E  5b
	pop XDE                                              ; FAA21F  5a
	pop XBC                                              ; FAA220  59
	pop XWA                                              ; FAA221  58
.LFAA222:
	ret                                                  ; FAA222  0e
	push XIX                                             ; FAA223  3c
	pushw wa                                             ; FAA224  28
	push XHL                                             ; FAA225  3b
	cp d, 0x00:i3                                          ; FAA226  cc d8
	jr z, .LFAA266                                       ; FAA228  66 3c
	xor H,H                                              ; FAA22A  ce d6
	ld L,C                                               ; FAA22C  cb 8f
	sla hl, 0x02                                         ; FAA22E  db ec 02
	ld xix, (IndexedTable_Base:24)                               ; FAA231  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA236  e3 07 f0 ec 24
	cp XIX,0xffffffff                                    ; FAA23B  ec cf ff ff ff ff
	jr z, .LFAA266                                       ; FAA241  66 23
	xor H,H                                              ; FAA243  ce d6
	ld L,B                                               ; FAA245  ca 8f
	ld	a, (xix+hl)                                  ; FAA247  c3 07 f0 ec 21
	ld W,D                                               ; FAA24C  cc 88
	xor W,0xff                                           ; FAA24E  c8 cd ff
	and A,W                                              ; FAA251  c8 c1
	and E,D                                              ; FAA253  cc c5
	or E,A                                               ; FAA255  c9 e5
	ld	(xix+hl), e                                  ; FAA257  f3 07 f0 ec 45
	ld (0x60f080:24), bc                                ; FAA25C  f2 80 f0 60 51
	ld (0x60f082:24), de                                ; FAA261  f2 82 f0 60 52
.LFAA266:
	pop XHL                                              ; FAA266  5b
	popw wa                                              ; FAA267  48
	pop XIX                                              ; FAA268  5c
	ret                                                  ; FAA269  0e
; ParamRecord_WriteFieldAndStage_StaleCopy -- the stale copy of ParamRecord_WriteFieldAndStage_Copy @FAA66A
;
; Evidence: 0xFAA018-0xFAA3FF is a copy of 0xFAA418-0xFAA7FF differing in
;          exactly ten bytes, established in
;          notes/FINDINGS-prom_a-message-module.md section 3a; this
;          routine's own body is byte-identical to its twin at +0x400.
;          Nothing publishes an entry into the copy: zero directory slots
;          point into it against 37 for the live block.
; Unknown: whether anything ever calls it.  The name asserts what the code
;          IS, not that it runs.
; ---------------------------------------------------------------------
ParamRecord_WriteFieldAndStage_StaleCopy:
	push XIX                                             ; FAA26A  3c
	pushw wa                                             ; FAA26B  28
	pushw hl                                             ; FAA26C  2b
	cp d, 0x00:i3                                          ; FAA26D  cc d8
	jr z, .LFAA2AD                                       ; FAA26F  66 3c
	xor H,H                                              ; FAA271  ce d6
	ld L,C                                               ; FAA273  cb 8f
	sla hl, 0x02                                         ; FAA275  db ec 02
	ld xix, (IndexedTable_Base:24)                               ; FAA278  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA27D  e3 07 f0 ec 24
	cp XIX,0xffffffff                                    ; FAA282  ec cf ff ff ff ff
	jr z, .LFAA2AD                                       ; FAA288  66 23
	xor H,H                                              ; FAA28A  ce d6
	ld L,B                                               ; FAA28C  ca 8f
	ld	a, (xix+hl)                                  ; FAA28E  c3 07 f0 ec 21
	ld W,D                                               ; FAA293  cc 88
	xor W,0xff                                           ; FAA295  c8 cd ff
	and A,W                                              ; FAA298  c8 c1
	and E,D                                              ; FAA29A  cc c5
	or E,A                                               ; FAA29C  c9 e5
	ld	(xix+hl), e                                  ; FAA29E  f3 07 f0 ec 45
	ld (0x60f080:24), bc                                ; FAA2A3  f2 80 f0 60 51
	ld (0x60f082:24), de                                ; FAA2A8  f2 82 f0 60 52
.LFAA2AD:
	popw hl                                              ; FAA2AD  4b
	popw wa                                              ; FAA2AE  48
	pop XIX                                              ; FAA2AF  5c
	ret                                                  ; FAA2B0  0e
	push XWA                                             ; FAA2B1  38
	push XBC                                             ; FAA2B2  39
	push XDE                                             ; FAA2B3  3a
	push XHL                                             ; FAA2B4  3b
	push XIX                                             ; FAA2B5  3c
	push XIY                                             ; FAA2B6  3d
	push XIZ                                             ; FAA2B7  3e
	bit	1, (0x60f021:24)                             ; FAA2B8  f2 21 f0 60 c9
	jr nz, .LFAA314                                      ; FAA2BD  6e 55
	ld (0x60f01d:24), c                                 ; FAA2BF  f2 1d f0 60 43
	xor H,H                                              ; FAA2C4  ce d6
	ld L,C                                               ; FAA2C6  cb 8f
	sla hl, 0x02                                         ; FAA2C8  db ec 02
	ld (0x60f174:24), hl                                ; FAA2CB  f2 74 f1 60 53
	ld xix, (IndexedTable_Base:24)                               ; FAA2D0  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA2D5  e3 07 f0 ec 24
	and (XIX+0x01),0x80                                  ; FAA2DA  8c 01 3c 80
	or (XIX+0x01),B                                      ; FAA2DE  8c 01 ea
	ld H,B                                               ; FAA2E1  ca 8e
	ld L,E                                               ; FAA2E3  cd 8f
	calr SoundSel_FromProgramAndBankRegs_StaleCopy                                      ; FAA2E5  1e 52 fd
	ld iy, (0x60f174:24)                                ; FAA2E8  d2 74 f1 60 25
	add IY,0x0080                                        ; FAA2ED  dd c8 80 00
	extz XIY                                             ; FAA2F1  ed 12
	add xiy, (IndexedTable_Base:24)                           ; FAA2F3  e2 18 f0 60 85
	ld XIY,(XIY)                                         ; FAA2F8  a5 25
	ld (XIY+0x1c),H                                      ; FAA2FA  bd 1c 46
	ld (XIY+0x1b),L                                      ; FAA2FD  bd 1b 47
	ld (XIY+0x1d),W                                      ; FAA300  bd 1d 40
	ld (XIX),E                                           ; FAA303  b4 45
	ld d, 0xff:opc                                          ; FAA305  24 ff
	ld (0x60f080:24), bc                                ; FAA307  f2 80 f0 60 51
	ld (0x60f082:24), de                                ; FAA30C  f2 82 f0 60 52
	calr Queue2C00_PublishStagedIfPending_StaleCopy                                      ; FAA311  1e 8c fd
.LFAA314:
	pop XIZ                                              ; FAA314  5e
	pop XIY                                              ; FAA315  5d
	pop XIX                                              ; FAA316  5c
	pop XHL                                              ; FAA317  5b
	pop XDE                                              ; FAA318  5a
	pop XBC                                              ; FAA319  59
	pop XWA                                              ; FAA31A  58
	ret                                                  ; FAA31B  0e
	ret                                                  ; FAA31C  0e
	ret                                                  ; FAA31D  0e
	ret                                                  ; FAA31E  0e
	pushw de                                             ; FAA31F  2a
	bit	7, (0x24f1:16)                               ; FAA320  f1 f1 24 cf
	jr z, .LFAA340                                       ; FAA324  66 1a
	and	(0x24f1:16), 0x7f                            ; FAA326  c1 f1 24 3c 7f
	ldw (0x60f080:24), 0xb0                             ; FAA32B  f2 80 f0 60 02 b0 00
	ld e, (0x24f1:16)                                   ; FAA332  c1 f1 24 25
	ld d, 0x7f:opc                                          ; FAA336  24 7f
	ld (0x60f082:24), de                                ; FAA338  f2 82 f0 60 52
	calr Queue2C00_PublishStagedIfPending_StaleCopy                                      ; FAA33D  1e 60 fd
.LFAA340:
	popw de                                              ; FAA340  4a
	ret                                                  ; FAA341  0e
	bit	2, (MidiCfg_ModeBits:16)                               ; FAA342  f1 32 7f ca
	jr nz, .LFAA3AA                                      ; FAA346  6e 62
	push XWA                                             ; FAA348  38
	push XBC                                             ; FAA349  39
	push XDE                                             ; FAA34A  3a
	ld XDE,0x00007ee2                                    ; FAA34B  42 e2 7e 00 00
	ld	wa, (xde+0:8)                                ; FAA350  9a 00 20
	and WA,0x01ff                                        ; FAA353  d8 cc ff 01
	cp WA,0x0028                                         ; FAA357  d8 cf 28 00
	jr c, .LFAA363                                       ; FAA35B  67 06
	cp WA,0x012c                                         ; FAA35D  d8 cf 2c 01
	jr ule, .LFAA36E                                     ; FAA361  63 0b
.LFAA363:
	andw	(xde+0:8), 0xfe00                    ; FAA363  9a 00 3c 00 fe
	ldw wa, 0x78                                         ; FAA368  30 78 00
	ld	(xde+0:8), a                                 ; FAA36B  ba 00 41
.LFAA36E:
	ld (0x60f800:24), wa                                ; FAA36E  f2 00 f8 60 50
	ldw de, 0x40                                         ; FAA373  32 40 00
	mul xwa, de                                         ; FAA376  da 40
	ld XDE,0x08583b00                                    ; FAA378  42 00 3b 58 08
	div xde, wa                                         ; FAA37D  d8 52
	ld XBC,XDE                                           ; FAA37F  ea 89
	srl xbc, 16                                        ; FAA381  e9 ef 00
	srl wa, 0x01                                         ; FAA384  d8 ef 01
	cp BC,WA                                             ; FAA387  d8 f1
	jr c, .LFAA38D                                       ; FAA389  67 02
	inc 1,DE                                             ; FAA38B  da 61
.LFAA38D:
	ld	(TREG5L:8), de                                     ; FAA38D  f0 32 52
	bit	4, (MidiCfg_ModeBits:16)                               ; FAA390  f1 32 7f cc
	jr nz, .LFAA3A1                                      ; FAA394  6e 0b
	bit	4, (0x60f020:24)                             ; FAA396  f2 20 f0 60 cc
	jr nz, .LFAA3A1                                      ; FAA39B  6e 04
	call T_SysExTx_Tempo                                        ; FAA39D  1d ec 08 f4
.LFAA3A1:
	and	(0x60f020:24), 0xef                          ; FAA3A1  c2 20 f0 60 3c ef
	pop XDE                                              ; FAA3A7  5a
	pop XBC                                              ; FAA3A8  59
	pop XWA                                              ; FAA3A9  58
.LFAA3AA:
	ret                                                  ; FAA3AA  0e
	ret                                                  ; FAA3AB  0e
	ret                                                  ; FAA3AC  0e
	push XIZ                                             ; FAA3AD  3e
	push XIX                                             ; FAA3AE  3c
	push XHL                                             ; FAA3AF  3b
	push XDE                                             ; FAA3B0  3a
	ld bc, (0x60f177:24)                                ; FAA3B1  d2 77 f1 60 21
	ld de, (0x60f179:24)                                ; FAA3B6  d2 79 f1 60 22
	call ParamRecord_WriteFieldAndStage_StaleCopy                                      ; FAA3BB  1d 6a a2 fa
	pop XDE                                              ; FAA3BF  5a
	pop XHL                                              ; FAA3C0  5b
	pop XIX                                              ; FAA3C1  5c
	pop XIZ                                              ; FAA3C2  5e
	ret                                                  ; FAA3C3  0e
	ld (0x60f007:24), 0x00                             ; FAA3C4  f2 07 f0 60 00 00
	push XWA                                             ; FAA3CA  38
	push XBC                                             ; FAA3CB  39
	push XDE                                             ; FAA3CC  3a
	push XHL                                             ; FAA3CD  3b
	push XIX                                             ; FAA3CE  3c
	push XIY                                             ; FAA3CF  3d
	push XIZ                                             ; FAA3D0  3e
	ld bc, (0x60f177:24)                                ; FAA3D1  d2 77 f1 60 21
	ld de, (0x60f179:24)                                ; FAA3D6  d2 79 f1 60 22
	call ParamChange_Notify_StaleCopy                                      ; FAA3DB  1d 04 a2 fa
	pop XIZ                                              ; FAA3DF  5e
	pop XIY                                              ; FAA3E0  5d
	pop XIX                                              ; FAA3E1  5c
	pop XHL                                              ; FAA3E2  5b
	pop XDE                                              ; FAA3E3  5a
	pop XBC                                              ; FAA3E4  59
	pop XWA                                              ; FAA3E5  58
	ret                                                  ; FAA3E6  0e
	push XIZ                                             ; FAA3E7  3e
	push XIX                                             ; FAA3E8  3c
	push XHL                                             ; FAA3E9  3b
	push XDE                                             ; FAA3EA  3a
	ld a, (0x60f160:24)                                 ; FAA3EB  c2 60 f1 60 21
	ld w, (0x60f162:24)                                 ; FAA3F0  c2 62 f1 60 20
	ld b, (0x60f01c:24)                                 ; FAA3F5  c2 1c f0 60 22
	call T_SoundGroup_MaxMemberIndex_Get                 ; FAA3FA  1d 1c 10 f4
; The stale copy ends at the 1 KiB boundary in the middle of an instruction: these are the first two bytes
; of `ld (0x60f176:24), a`, whose complete twin is at 0xFAA7FE.
	.byte	0xf2, 0x76                                      ; FAA3FE  f2 76
; ---------------------------------------------------------------------
; ParamModule_PhaseVector -- this module's boot phase vector, five `jp` slots and a `ret`.
; Evidence: ModuleInitDirectory_F82641[11] = T_ParamModule_PhaseVector, whose word in prom_b is `.long ParamModule_PhaseVector`;
;          the walker calls vector + phase.  SysExSession_OnAbort_SystemPartMidi also reads that word, adds 8 and jumps: slot 2.
;          Was decoded as `tset 0,(0x2a1b76)` + `swi 2`, the copy's cut-off instruction run on into it.
; ---------------------------------------------------------------------
ParamModule_PhaseVector:
	jp	ParamModule_BootPhase0                                        ; FAA400  1b 2a a8 fa
	jp ParamModule_BootPhase1_MemoryIntact                                        ; FAA404  1b f0 a8 fa
	jp ParamModule_BootPhase2_MemoryLost                                        ; FAA408  1b 82 a8 fa
	jp ParamModule_BootPhase3                                        ; FAA40C  1b 4e a9 fa
	jp ParamModule_BootPhase4                                        ; FAA410  1b ec a8 fa
	ret                                                  ; FAA414  0e
	nop                                                  ; FAA415  00
	nop                                                  ; FAA416  00
	nop                                                  ; FAA417  00
; SoundSel_ClampToProgramAndBankRegs: Register form of SoundSel_ClampToProgramAndBank: L = group, H = member, W = bank
;   code in (stored at 0x60F160..62), part in (0x60F01C); returns HL = (0x60F164) -- L = program, H = bank; all other
;   registers kept. Twin of SoundSel_FromProgramAndBankRegs. Callers: GroupSoundDisplayHold_DrawMemberNames (then
;   SoundName_Lookup) and ParamApply_PartProgNormal (rec[0] = L, rec[1] = H). Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
SoundSel_ClampToProgramAndBankRegs:
	ld (0x60f160:24), hl                                ; FAA418  f2 60 f1 60 53
	ld (0x60f162:24), w                                 ; FAA41D  f2 62 f1 60 40
	push XWA                                             ; FAA422  38
	push XBC                                             ; FAA423  39
	push XDE                                             ; FAA424  3a
	push XHL                                             ; FAA425  3b
	push XIX                                             ; FAA426  3c
	push XIY                                             ; FAA427  3d
	push XIZ                                             ; FAA428  3e
	call SoundSel_ClampToProgramAndBank                                      ; FAA429  1d 58 b6 fa
	pop XIZ                                              ; FAA42D  5e
	pop XIY                                              ; FAA42E  5d
	pop XIX                                              ; FAA42F  5c
	pop XHL                                              ; FAA430  5b
	pop XDE                                              ; FAA431  5a
	pop XBC                                              ; FAA432  59
	pop XWA                                              ; FAA433  58
	ld hl, (0x60f164:24)                                ; FAA434  d2 64 f1 60 23
	ret                                                  ; FAA439  0e
; SoundSel_FromProgramAndBankRegs: Register form of SoundSel_FromProgramAndBank: L = program, H = bank in, part in
;   (0x60F01D); returns L = group, H = member, W = bank code, all other registers kept (conversion skipped when the
;   part > 0x1F). Callers store L/H/W at the part record's +0x3B..+0x3D. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
SoundSel_FromProgramAndBankRegs:
	ld (0x60f168:24), hl                                ; FAA43A  f2 68 f1 60 53
	push XWA                                             ; FAA43F  38
	push XBC                                             ; FAA440  39
	push XDE                                             ; FAA441  3a
	push XHL                                             ; FAA442  3b
	push XIX                                             ; FAA443  3c
	push XIY                                             ; FAA444  3d
	push XIZ                                             ; FAA445  3e
	call SoundSel_GroupMemberFromProgramAndBank                                      ; FAA446  1d d7 b6 fa
	pop XIZ                                              ; FAA44A  5e
	pop XIY                                              ; FAA44B  5d
	pop XIX                                              ; FAA44C  5c
	pop XHL                                              ; FAA44D  5b
	pop XDE                                              ; FAA44E  5a
	pop XBC                                              ; FAA44F  59
	pop XWA                                              ; FAA450  58
	ld hl, (0x60f16c:24)                                ; FAA451  d2 6c f1 60 23
	ld w, (0x60f16e:24)                                 ; FAA456  c2 6e f1 60 20
	ret                                                  ; FAA45B  0e
; CombiSel_ClampToNumberAndBankRegs: Register form of CombiSel_ClampToNumberAndBank: L = group, H = member, W = bank
;   in (stored at 0x60F181..0x60F183; the caller sets (0x60F17F) = 0x98), returns HL = (0x60F185) -- L = combination
;   number, H = bank; all other registers kept. COMBI twin of SoundSel_ClampToProgramAndBankRegs. Caller:
;   GroupCombiDisplayHold_DrawMemberNames (then CombiName_Lookup). Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
CombiSel_ClampToNumberAndBankRegs:
	ld (0x60f181:24), hl                                ; FAA45C  f2 81 f1 60 53
	ld (0x60f183:24), w                                 ; FAA461  f2 83 f1 60 40
	push XWA                                             ; FAA466  38
	push XBC                                             ; FAA467  39
	push XDE                                             ; FAA468  3a
	push XHL                                             ; FAA469  3b
	push XIX                                             ; FAA46A  3c
	push XIY                                             ; FAA46B  3d
	push XIZ                                             ; FAA46C  3e
	call CombiSel_ClampToNumberAndBank                                      ; FAA46D  1d 79 b7 fa
	pop XIZ                                              ; FAA471  5e
	pop XIY                                              ; FAA472  5d
	pop XIX                                              ; FAA473  5c
	pop XHL                                              ; FAA474  5b
	pop XDE                                              ; FAA475  5a
	pop XBC                                              ; FAA476  59
	pop XWA                                              ; FAA477  58
	ld hl, (0x60f185:24)                                ; FAA478  d2 85 f1 60 23
	ret                                                  ; FAA47D  0e
sub_FAA47E:
	ld (0x60f189:24), hl                                ; FAA47E  f2 89 f1 60 53
	push XWA                                             ; FAA483  38
	push XBC                                             ; FAA484  39
	push XDE                                             ; FAA485  3a
	push XHL                                             ; FAA486  3b
	push XIX                                             ; FAA487  3c
	push XIY                                             ; FAA488  3d
	push XIZ                                             ; FAA489  3e
	call CombiSel_GroupMemberFromNumberAndBank                                      ; FAA48A  1d 28 b7 fa
	pop XIZ                                              ; FAA48E  5e
	pop XIY                                              ; FAA48F  5d
	pop XIX                                              ; FAA490  5c
	pop XHL                                              ; FAA491  5b
	pop XDE                                              ; FAA492  5a
	pop XBC                                              ; FAA493  59
	pop XWA                                              ; FAA494  58
	ld hl, (0x60f18d:24)                                ; FAA495  d2 8d f1 60 23
	ld w, (0x60f18f:24)                                 ; FAA49A  c2 8f f1 60 20
	ret                                                  ; FAA49F  0e
; ---------------------------------------------------------------------
; Queue2C00_PublishStagedIfPending -- append the staged 4-byte record at
;                           (0x60F080..0x60F083) to the 0x2C00 queue, but
;                           only when (0x60F083) is non-zero
;
; Called from: prom_b directory slot T_Queue2C00_PublishStagedIfPending (T_F407B4).
; Body:    return at once when (0x60F083) == 0.  Otherwise: if the queue
;          cursor (0x60F000) has reached 0x01FC, drain the queue through
;          T_Queue2C00_DrainPassAB (T_F40018) and restart the cursor at 0; then store (0x60F080) and
;          (0x60F082) as two 16-bit words at 0x2C00 + cursor, write 0xFF
;          one past, advance the cursor by 4 and clear (0x60F083).
; Evidence: `cp (0x60f083),0x00` at 0xFAA4A0, `cp HL,0x01fc` at 0xFAA4B0,
;          `call 0xf40018` at 0xFAA4BD, `ld XIX,0x00002c00` at 0xFAA4CA,
;          `ld (0x60f000),HL` at 0xFAA4ED, `ld (0x60f083),0x00` at
;          0xFAA4F2.  The record shape -- four bytes plus an 0xFF one past
;          and a cursor step of 4 -- is the shape Queue2C00_AppendRegs
;          (0xF86A81) already documents for the same buffer and the same
;          cursor cell, and T_Queue2C00_DrainPassAB (T_F40018) is sub_F823AC, which empties 0x2C00
;          and rezeroes (0x60F000).
; Note:    (0x60F083) is the record's mask byte, so "a mask of 0" is what
;          "nothing staged" means here; the writers that stage a record
;          (ParamRecord_WriteFieldAndStage and the ParamApply_ entries in
;          the 0xFAD800 module) all set it last.
; ---------------------------------------------------------------------
Queue2C00_PublishStagedIfPending:
	cp	(0x60f083:24), 0x00                          ; FAA4A0  c2 83 f0 60 3f 00
	jr z, .LFAA4FB                                       ; FAA4A6  66 53
	pushw wa                                             ; FAA4A8  28
	pushw hl                                             ; FAA4A9  2b
	push XIX                                             ; FAA4AA  3c
	ld hl, (0x60f000:24)                                ; FAA4AB  d2 00 f0 60 23
	cp HL,0x01fc                                         ; FAA4B0  db cf fc 01
	jr c, .LFAA4CA                                       ; FAA4B4  67 14
	push XWA                                             ; FAA4B6  38
	push XBC                                             ; FAA4B7  39
	push XDE                                             ; FAA4B8  3a
	push XHL                                             ; FAA4B9  3b
	push XIX                                             ; FAA4BA  3c
	push XIY                                             ; FAA4BB  3d
	push XIZ                                             ; FAA4BC  3e
	call T_Queue2C00_DrainPassAB                         ; FAA4BD  1d 18 00 f4
	pop XIZ                                              ; FAA4C1  5e
	pop XIY                                              ; FAA4C2  5d
	pop XIX                                              ; FAA4C3  5c
	pop XHL                                              ; FAA4C4  5b
	pop XDE                                              ; FAA4C5  5a
	pop XBC                                              ; FAA4C6  59
	pop XWA                                              ; FAA4C7  58
	xor HL,HL                                            ; FAA4C8  db d3
.LFAA4CA:
	ld XIX,0x00002c00                                    ; FAA4CA  44 00 2c 00 00
	ld wa, (0x60f080:24)                                ; FAA4CF  d2 80 f0 60 20
	ld	(xix+hl), wa                                 ; FAA4D4  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA4D9  db 62
	ld wa, (0x60f082:24)                                ; FAA4DB  d2 82 f0 60 20
	ld	(xix+hl), wa                                 ; FAA4E0  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA4E5  db 62
	ld	(xix+hl), 0xff                               ; FAA4E7  f3 07 f0 ec 00 ff
	ld (0x60f000:24), hl                                ; FAA4ED  f2 00 f0 60 53
	ld (0x60f083:24), 0x00                             ; FAA4F2  f2 83 f0 60 00 00
	pop XIX                                              ; FAA4F8  5c
	popw hl                                              ; FAA4F9  4b
	popw wa                                              ; FAA4FA  48
.LFAA4FB:
	ret                                                  ; FAA4FB  0e
; ---------------------------------------------------------------------
; Queue2C00_PublishStaged -- the same, with no (0x60F083) test
;
; Called from: `call` at 0xFABE9D in Queue2C00_FanOutToPartMask_Publish.
;          ★ CORRECTED 2026-09-25 (lane proma): this said "no directory slot
;          and no proven call site found ... nothing does"; the call became
;          visible when 0xFABE9D's operand was symbolised (check M8).  No
;          directory slot names it.
; Body:    identical to Queue2C00_PublishStagedIfPending from its second
;          instruction on, including the same `jr c` into that routine's
;          own tail at 0xFAA4CA, and then a SECOND copy of the same tail
;          inline at 0xFAA51E.
; Evidence: `jr C,0xfaa4ca` at 0xFAA508 targets the other routine's body;
;          `ld XIX,0x00002c00` appears twice, at 0xFAA4CA and 0xFAA51E.
; ---------------------------------------------------------------------
Queue2C00_PublishStaged:
	pushw wa                                             ; FAA4FC  28
	pushw hl                                             ; FAA4FD  2b
	push XIX                                             ; FAA4FE  3c
	ld hl, (0x60f000:24)                                ; FAA4FF  d2 00 f0 60 23
	cp HL,0x01fc                                         ; FAA504  db cf fc 01
	jr c, .LFAA4CA                                       ; FAA508  67 c0
	push XWA                                             ; FAA50A  38
	push XBC                                             ; FAA50B  39
	push XDE                                             ; FAA50C  3a
	push XHL                                             ; FAA50D  3b
	push XIX                                             ; FAA50E  3c
	push XIY                                             ; FAA50F  3d
	push XIZ                                             ; FAA510  3e
	call T_Queue2C00_DrainPassAB                         ; FAA511  1d 18 00 f4
	pop XIZ                                              ; FAA515  5e
	pop XIY                                              ; FAA516  5d
	pop XIX                                              ; FAA517  5c
	pop XHL                                              ; FAA518  5b
	pop XDE                                              ; FAA519  5a
	pop XBC                                              ; FAA51A  59
	pop XWA                                              ; FAA51B  58
	xor HL,HL                                            ; FAA51C  db d3
	ld XIX,0x00002c00                                    ; FAA51E  44 00 2c 00 00
	ld wa, (0x60f080:24)                                ; FAA523  d2 80 f0 60 20
	ld	(xix+hl), wa                                 ; FAA528  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA52D  db 62
	ld wa, (0x60f082:24)                                ; FAA52F  d2 82 f0 60 20
	ld	(xix+hl), wa                                 ; FAA534  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA539  db 62
	ld	(xix+hl), 0xff                               ; FAA53B  f3 07 f0 ec 00 ff
	ld (0x60f000:24), hl                                ; FAA541  f2 00 f0 60 53
	ld (0x60f083:24), 0x00                             ; FAA546  f2 83 f0 60 00 00
	pop XIX                                              ; FAA54C  5c
	popw hl                                              ; FAA54D  4b
	popw wa                                              ; FAA54E  48
	ret                                                  ; FAA54F  0e
; ---------------------------------------------------------------------
; Queue2C00_PublishStagedDrainPassB -- the same again, draining through
;                           Queue2C00_DrainPassB instead of
;                           Queue2C00_DrainPassAB
;
; Called from: prom_b directory slot T_Queue2C00_PublishStagedDrainPassB (T_F407B8).
; Evidence: `call 0xf40038` at 0xFAA565 where the other two call
;          0xf40018.  T_Queue2C00_DrainPassAB (T_F40018) is Queue2C00_DrainPassAB and T_Queue2C00_DrainPassB (T_F40038) is
;          Queue2C00_DrainPassB; the only difference between those two is
;          the `call 0xf40f5c` -- UiEventList_RunPassA -- that the second
;          omits.  So what this entry point skips is PASS A over the
;          queue, and nothing else.
; ⚠ CORRECTION: an earlier header of this same pass called this routine
;          `Queue2C00_PublishStagedDrainQuiet` and said `the difference is
;          one notification`.  It is not a notification; T_UiEventList_RunPassA (T_F40F5C) is
;          UiEventList_RunPassA, which prom_a already names, and the
;          earlier header simply had not looked it up.
; ---------------------------------------------------------------------
Queue2C00_PublishStagedDrainPassB:
	pushw wa                                             ; FAA550  28
	pushw hl                                             ; FAA551  2b
	push XIX                                             ; FAA552  3c
	ld hl, (0x60f000:24)                                ; FAA553  d2 00 f0 60 23
	cp HL,0x01fc                                         ; FAA558  db cf fc 01
	jr c, .LFAA572                                       ; FAA55C  67 14
	push XWA                                             ; FAA55E  38
	push XBC                                             ; FAA55F  39
	push XDE                                             ; FAA560  3a
	push XHL                                             ; FAA561  3b
	push XIX                                             ; FAA562  3c
	push XIY                                             ; FAA563  3d
	push XIZ                                             ; FAA564  3e
	call T_Queue2C00_DrainPassB                          ; FAA565  1d 38 00 f4
	pop XIZ                                              ; FAA569  5e
	pop XIY                                              ; FAA56A  5d
	pop XIX                                              ; FAA56B  5c
	pop XHL                                              ; FAA56C  5b
	pop XDE                                              ; FAA56D  5a
	pop XBC                                              ; FAA56E  59
	pop XWA                                              ; FAA56F  58
	xor HL,HL                                            ; FAA570  db d3
.LFAA572:
	ld XIX,0x00002c00                                    ; FAA572  44 00 2c 00 00
	ld wa, (0x60f080:24)                                ; FAA577  d2 80 f0 60 20
	ld	(xix+hl), wa                                 ; FAA57C  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA581  db 62
	ld wa, (0x60f082:24)                                ; FAA583  d2 82 f0 60 20
	ld	(xix+hl), wa                                 ; FAA588  f3 07 f0 ec 50
	inc 2,HL                                             ; FAA58D  db 62
	ld	(xix+hl), 0xff                               ; FAA58F  f3 07 f0 ec 00 ff
	ld (0x60f000:24), hl                                ; FAA595  f2 00 f0 60 53
	ld (0x60f083:24), 0x00                             ; FAA59A  f2 83 f0 60 00 00
	pop XIX                                              ; FAA5A0  5c
	popw hl                                              ; FAA5A1  4b
	popw wa                                              ; FAA5A2  48
	ret                                                  ; FAA5A3  0e
T_F407BC_Nop:
	ret                                                  ; FAA5A4  0e
T_F407C0_Nop:
	ret                                                  ; FAA5A5  0e
T_F407C8_Nop:
	ret                                                  ; FAA5A6  0e
; ---------------------------------------------------------------------
; ParamRecord_WriteFieldIfChanged -- the same masked write as
;                           ParamRecord_WriteFieldAndStage, staged ONLY
;                           when the masked bits actually change
;
; Called from: no directory slot; it sits between sub_FAA4FC's tail and
;          ParamChange_NotifyClearSource and had no label at all.
; Body:    as ParamRecord_WriteFieldAndStage, except that the old byte is
;          saved to (0x60F08B), the new one is XORed against it and ANDed
;          with D, and the store and the staging are skipped when that
;          comes out zero.
; Evidence: `ld (0x60f08b),A` at 0xFAA5D0, `xor W,(0x60f08b)` at 0xFAA5E2,
;          `and W,D` at 0xFAA5E7, `jr Z,0xfaa5fa` at 0xFAA5E9 -- the jump
;          that skips both `ld (XIX+HL),A` and the two staging stores.
; ---------------------------------------------------------------------
ParamRecord_WriteFieldIfChanged:
	push XIX                                             ; FAA5A7  3c
	pushw wa                                             ; FAA5A8  28
	push XHL                                             ; FAA5A9  3b
	cp d, 0x00:i3                                          ; FAA5AA  cc d8
	jr z, .LFAA5FA                                       ; FAA5AC  66 4c
	xor H,H                                              ; FAA5AE  ce d6
	ld L,C                                               ; FAA5B0  cb 8f
	sla hl, 0x02                                         ; FAA5B2  db ec 02
	ld xix, (IndexedTable_Base:24)                               ; FAA5B5  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA5BA  e3 07 f0 ec 24
	cp XIX,0xffffffff                                    ; FAA5BF  ec cf ff ff ff ff
	jr z, .LFAA5FA                                       ; FAA5C5  66 33
	xor H,H                                              ; FAA5C7  ce d6
	ld L,B                                               ; FAA5C9  ca 8f
	ld	a, (xix+hl)                                  ; FAA5CB  c3 07 f0 ec 21
	ld (0x60f08b:24), a                                 ; FAA5D0  f2 8b f0 60 41
	ld W,D                                               ; FAA5D5  cc 88
	xor W,0xff                                           ; FAA5D7  c8 cd ff
	and A,W                                              ; FAA5DA  c8 c1
	and E,D                                              ; FAA5DC  cc c5
	or A,E                                               ; FAA5DE  cd e1
	ld W,A                                               ; FAA5E0  c9 88
	xor w, (0x60f08b:24)                              ; FAA5E2  c2 8b f0 60 d0
	and W,D                                              ; FAA5E7  cc c0
	jr z, .LFAA5FA                                       ; FAA5E9  66 0f
	ld	(xix+hl), a                                  ; FAA5EB  f3 07 f0 ec 41
	ld (0x60f080:24), bc                                ; FAA5F0  f2 80 f0 60 51
	ld (0x60f082:24), wa                                ; FAA5F5  f2 82 f0 60 50
.LFAA5FA:
	pop XHL                                              ; FAA5FA  5b
	popw wa                                              ; FAA5FB  48
	pop XIX                                              ; FAA5FC  5c
	ret                                                  ; FAA5FD  0e
; ---------------------------------------------------------------------
; ParamChange_NotifyClearSource -- clear (0x60F007), then notify
;
; Called from: prom_b directory slot T_ParamChange_NotifyClearSource (T_F407CC), and it is the target of
;          all eleven Evt2030_ClassXX_Fwd forwarders.
; Body:    `ld (0x60f007),0x00` and then falls straight into
;          ParamChange_Notify -- the two are one routine with two entry
;          points, which is why the directory publishes both.
; Evidence: `ld (0x60f007),0x00` at 0xFAA5FE is five bytes and 0xFAA604 is
;          the next address; the forwarders are `call 0xf407cc / ret`.
; Note:    (0x60F007) is the byte MidiOut_ParamChanged clears bit 7 of on
;          its way out (`res 7,(0x60f007)` at 0xFA7123), and the byte
;          ParamReset_SixParamsForIndex sets before each of its six posts.
;          So it is a per-call source/flags byte and this entry is the
;          "no source" one.  What its bits SELECT is not established.
; ---------------------------------------------------------------------
ParamChange_NotifyClearSource:
	ld (0x60f007:24), 0x00                             ; FAA5FE  f2 07 f0 60 00 00
; ---------------------------------------------------------------------
; ParamChange_Notify -- hand the register-face parameter change to
;                           MidiOut_ParamChanged, unless it is gated off
;
; Called from: prom_b directory slot T_ParamChange_Notify (T_F407D0), and by falling in from
;          ParamChange_NotifyClearSource.
; Body:    return when bit 0 of (0x0922) is set AND bit 1 is clear;
;          otherwise save all seven register pairs, `call 0xf40748`, and
;          restore them.
; Evidence: `bit 0,(0x0922)` at 0xFAA604 and `bit 1,(0x0922)` at 0xFAA60A;
;          T_MidiOut_ParamChanged (T_F40748) is MidiOut_ParamChanged (prom_a 0xFA70F5), already
;          named, and that routine opens with the SAME two bit tests on
;          the SAME cell -- so the gate is duplicated, not delegated.
; ---------------------------------------------------------------------
ParamChange_Notify:
	bit	0, (0x0922:16)                               ; FAA604  f1 22 09 c8
	jr z, .LFAA610                                       ; FAA608  66 06
	bit	1, (0x0922:16)                               ; FAA60A  f1 22 09 c9
	jr nz, .LFAA622                                      ; FAA60E  6e 12
.LFAA610:
	push XWA                                             ; FAA610  38
	push XBC                                             ; FAA611  39
	push XDE                                             ; FAA612  3a
	push XHL                                             ; FAA613  3b
	push XIX                                             ; FAA614  3c
	push XIY                                             ; FAA615  3d
	push XIZ                                             ; FAA616  3e
	call T_MidiOut_ParamChanged                          ; FAA617  1d 48 07 f4
	pop XIZ                                              ; FAA61B  5e
	pop XIY                                              ; FAA61C  5d
	pop XIX                                              ; FAA61D  5c
	pop XHL                                              ; FAA61E  5b
	pop XDE                                              ; FAA61F  5a
	pop XBC                                              ; FAA620  59
	pop XWA                                              ; FAA621  58
.LFAA622:
	ret                                                  ; FAA622  0e
; ---------------------------------------------------------------------
; ParamRecord_WriteFieldAndStage -- write masked bits into one byte of a
;                           parameter's record and stage the change
;
; Called from: prom_b directory slot T_ParamRecord_WriteFieldAndStage (T_F407D4).
; Inputs:  C = the parameter number, B = the byte offset inside that
;          parameter's record, E = the new value, D = the bit mask.
; Body:    return when D == 0; XIX = ParamNumber_RecordPtrs[C] through
;          (0x60F018); return when that entry is 0xFFFFFFFF; then
;          (XIX+B) = ((XIX+B) & ~D) | (E & D), and finally
;          (0x60F080) = BC and (0x60F082) = DE, i.e. the four staged bytes
;          {C, B, E, D} that Queue2C00_PublishStagedIfPending publishes.
; Evidence: `cp D,0` at 0xFAA626, `ld XIX,(0x60f018)` at 0xFAA631,
;          `cp XIX,0xffffffff` at 0xFAA63B, `xor W,0xff / and A,W /
;          and E,D / or E,A` at 0xFAA64E-0xFAA655, `ld (XIX+HL),E` at
;          0xFAA657, `ld (0x60f080),BC` at 0xFAA65C.
; ★ THE STAGED RECORD IS THE SAME FOUR BYTES the 0x2030 list, the 0x2C00
;          queue and the 0x2E00 queue all carry: List2030_AppendRegs
;          (0xF86AC7) stores {E,D,A,W} and the Evt2030 runner reads byte
;          +0 as the parameter number and hands +1..+3 to the handler in
;          B, E and D.
; ---------------------------------------------------------------------
ParamRecord_WriteFieldAndStage:
	push XIX                                             ; FAA623  3c
	pushw wa                                             ; FAA624  28
	push XHL                                             ; FAA625  3b
	cp d, 0x00:i3                                          ; FAA626  cc d8
	jr z, .LFAA666                                       ; FAA628  66 3c
	xor H,H                                              ; FAA62A  ce d6
	ld L,C                                               ; FAA62C  cb 8f
	sla hl, 0x02                                         ; FAA62E  db ec 02
	ld xix, (IndexedTable_Base:24)                               ; FAA631  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA636  e3 07 f0 ec 24
	cp XIX,0xffffffff                                    ; FAA63B  ec cf ff ff ff ff
	jr z, .LFAA666                                       ; FAA641  66 23
	xor H,H                                              ; FAA643  ce d6
	ld L,B                                               ; FAA645  ca 8f
	ld	a, (xix+hl)                                  ; FAA647  c3 07 f0 ec 21
	ld W,D                                               ; FAA64C  cc 88
	xor W,0xff                                           ; FAA64E  c8 cd ff
	and A,W                                              ; FAA651  c8 c1
	and E,D                                              ; FAA653  cc c5
	or E,A                                               ; FAA655  c9 e5
	ld	(xix+hl), e                                  ; FAA657  f3 07 f0 ec 45
	ld (0x60f080:24), bc                                ; FAA65C  f2 80 f0 60 51
	ld (0x60f082:24), de                                ; FAA661  f2 82 f0 60 52
.LFAA666:
	pop XHL                                              ; FAA666  5b
	popw wa                                              ; FAA667  48
	pop XIX                                              ; FAA668  5c
	ret                                                  ; FAA669  0e
; ---------------------------------------------------------------------
; ParamRecord_WriteFieldAndStage_Copy -- a second copy of the routine
;                           above, published as its own directory slot
;
; Called from: prom_b directory slot T_ParamRecord_WriteFieldAndStage_Copy (T_F407D8).
; ★ BORROWED NAME, WITH THE DIFF: 0xFAA623 and 0xFAA66A are 71 bytes with
;          exactly TWO differing -- offset +2 (0x3B `push XHL` against
;          0x2B `push HL`) and offset +67 (0x5B `pop XHL` against 0x4B
;          `pop HL`).  Every other byte, including both `jr` displacements,
;          is identical, so the two routines differ only in whether the
;          saved HL is 32 or 16 bits wide.  Check C1 recomputes the length
;          and the differing count and prints both offsets.
; Unknown:  why the firmware publishes both.  Nothing here explains it.
; ---------------------------------------------------------------------
ParamRecord_WriteFieldAndStage_Copy:
	push XIX                                             ; FAA66A  3c
	pushw wa                                             ; FAA66B  28
	pushw hl                                             ; FAA66C  2b
	cp d, 0x00:i3                                          ; FAA66D  cc d8
	jr z, .LFAA6AD                                       ; FAA66F  66 3c
	xor H,H                                              ; FAA671  ce d6
	ld L,C                                               ; FAA673  cb 8f
	sla hl, 0x02                                         ; FAA675  db ec 02
	ld xix, (IndexedTable_Base:24)                               ; FAA678  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA67D  e3 07 f0 ec 24
	cp XIX,0xffffffff                                    ; FAA682  ec cf ff ff ff ff
	jr z, .LFAA6AD                                       ; FAA688  66 23
	xor H,H                                              ; FAA68A  ce d6
	ld L,B                                               ; FAA68C  ca 8f
	ld	a, (xix+hl)                                  ; FAA68E  c3 07 f0 ec 21
	ld W,D                                               ; FAA693  cc 88
	xor W,0xff                                           ; FAA695  c8 cd ff
	and A,W                                              ; FAA698  c8 c1
	and E,D                                              ; FAA69A  cc c5
	or E,A                                               ; FAA69C  c9 e5
	ld	(xix+hl), e                                  ; FAA69E  f3 07 f0 ec 45
	ld (0x60f080:24), bc                                ; FAA6A3  f2 80 f0 60 51
	ld (0x60f082:24), de                                ; FAA6A8  f2 82 f0 60 52
.LFAA6AD:
	popw hl                                              ; FAA6AD  4b
	popw wa                                              ; FAA6AE  48
	pop XIX                                              ; FAA6AF  5c
	ret                                                  ; FAA6B0  0e
sub_FAA6B1:
	push XWA                                             ; FAA6B1  38
	push XBC                                             ; FAA6B2  39
	push XDE                                             ; FAA6B3  3a
	push XHL                                             ; FAA6B4  3b
	push XIX                                             ; FAA6B5  3c
	push XIY                                             ; FAA6B6  3d
	push XIZ                                             ; FAA6B7  3e
	bit	1, (0x60f021:24)                             ; FAA6B8  f2 21 f0 60 c9
	jr nz, .LFAA714                                      ; FAA6BD  6e 55
	ld (0x60f01d:24), c                                 ; FAA6BF  f2 1d f0 60 43
	xor H,H                                              ; FAA6C4  ce d6
	ld L,C                                               ; FAA6C6  cb 8f
	sla hl, 0x02                                         ; FAA6C8  db ec 02
	ld (0x60f174:24), hl                                ; FAA6CB  f2 74 f1 60 53
	ld xix, (IndexedTable_Base:24)                               ; FAA6D0  e2 18 f0 60 24
	ld	xix, (xix+hl)                                ; FAA6D5  e3 07 f0 ec 24
	and (XIX+0x01),0x80                                  ; FAA6DA  8c 01 3c 80
	or (XIX+0x01),B                                      ; FAA6DE  8c 01 ea
	ld H,B                                               ; FAA6E1  ca 8e
	ld L,E                                               ; FAA6E3  cd 8f
	calr SoundSel_FromProgramAndBankRegs                                      ; FAA6E5  1e 52 fd
	ld iy, (0x60f174:24)                                ; FAA6E8  d2 74 f1 60 25
	add IY,0x0080                                        ; FAA6ED  dd c8 80 00
	extz XIY                                             ; FAA6F1  ed 12
	add xiy, (IndexedTable_Base:24)                           ; FAA6F3  e2 18 f0 60 85
	ld XIY,(XIY)                                         ; FAA6F8  a5 25
	ld (XIY+0x1c),H                                      ; FAA6FA  bd 1c 46
	ld (XIY+0x1b),L                                      ; FAA6FD  bd 1b 47
	ld (XIY+0x1d),W                                      ; FAA700  bd 1d 40
	ld (XIX),E                                           ; FAA703  b4 45
	ld d, 0xff:opc                                          ; FAA705  24 ff
	ld (0x60f080:24), bc                                ; FAA707  f2 80 f0 60 51
	ld (0x60f082:24), de                                ; FAA70C  f2 82 f0 60 52
	calr Queue2C00_PublishStagedIfPending                                      ; FAA711  1e 8c fd
.LFAA714:
	pop XIZ                                              ; FAA714  5e
	pop XIY                                              ; FAA715  5d
	pop XIX                                              ; FAA716  5c
	pop XHL                                              ; FAA717  5b
	pop XDE                                              ; FAA718  5a
	pop XBC                                              ; FAA719  59
	pop XWA                                              ; FAA71A  58
	ret                                                  ; FAA71B  0e
T_F407E0_Nop:
	ret                                                  ; FAA71C  0e
T_F407E8_Nop:
	ret                                                  ; FAA71D  0e
T_F407E4_Nop:
	ret                                                  ; FAA71E  0e
; ParamB0_PublishField0IfPending: When (0x24F1) bit 7 (pending) is set: clears it and publishes {0xB0, 0, (0x24F1),
;   0x7F} -- parameter 0xB0, field 0 -- through Queue2C00_PublishStagedIfPending. ParamShadow_SetField3's 0xB0 arm
;   stores (0x24F1) and calls it (T_ParamB0_PublishField0IfPending); ParamB0_PublishPendingFields is the two-field version. Caveat: FlushAll /
;   SeqEvt_ShadowExpression write (0x24F0) before calling. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
ParamB0_PublishField0IfPending:
	pushw de                                             ; FAA71F  2a
	bit	7, (0x24f1:16)                               ; FAA720  f1 f1 24 cf
	jr z, .LFAA740                                       ; FAA724  66 1a
	and	(0x24f1:16), 0x7f                            ; FAA726  c1 f1 24 3c 7f
	ldw (0x60f080:24), 0xb0                             ; FAA72B  f2 80 f0 60 02 b0 00
	ld e, (0x24f1:16)                                   ; FAA732  c1 f1 24 25
	ld d, 0x7f:opc                                          ; FAA736  24 7f
	ld (0x60f082:24), de                                ; FAA738  f2 82 f0 60 52
	calr Queue2C00_PublishStagedIfPending                                      ; FAA73D  1e 60 fd
.LFAA740:
	popw de                                              ; FAA740  4a
	ret                                                  ; FAA741  0e
; Tempo_ApplyBpm: unless MidiCfg_ModeBits bit 2: the BPM in the low 9 bits of (0x7EE2), reset to 120 when outside 40..300,
;   to (0x60F800); TREG5 = 140,000,000 / (64 * BPM), rounded (FINDINGS-system-clock.md, lever B -- which quotes the
;   byte-identical stale copy at 0xFAA342); then SysExTx_Tempo through T_SysExTx_Tempo unless MidiCfg_ModeBits bit 4 or
;   (0x60F020) bit 4, which it clears.  18 call sites, among them List2030_Tempo_Apply and ParamModule_BootPhase1.
Tempo_ApplyBpm:
	bit	2, (MidiCfg_ModeBits:16)                               ; FAA742  f1 32 7f ca
	jr nz, .LFAA7AA                                      ; FAA746  6e 62
	push XWA                                             ; FAA748  38
	push XBC                                             ; FAA749  39
	push XDE                                             ; FAA74A  3a
	ld XDE,0x00007ee2                                    ; FAA74B  42 e2 7e 00 00
	ld	wa, (xde+0:8)                                ; FAA750  9a 00 20
	and WA,0x01ff                                        ; FAA753  d8 cc ff 01
	cp WA,0x0028                                         ; FAA757  d8 cf 28 00
	jr c, .LFAA763                                       ; FAA75B  67 06
	cp WA,0x012c                                         ; FAA75D  d8 cf 2c 01
	jr ule, .LFAA76E                                     ; FAA761  63 0b
.LFAA763:
	andw	(xde+0:8), 0xfe00                    ; FAA763  9a 00 3c 00 fe
	ldw wa, 0x78                                         ; FAA768  30 78 00
	ld	(xde+0:8), a                                 ; FAA76B  ba 00 41
.LFAA76E:
	ld (0x60f800:24), wa                                ; FAA76E  f2 00 f8 60 50
	ldw de, 0x40                                         ; FAA773  32 40 00
	mul xwa, de                                         ; FAA776  da 40
	ld XDE,0x08583b00                                    ; FAA778  42 00 3b 58 08
	div xde, wa                                         ; FAA77D  d8 52
	ld XBC,XDE                                           ; FAA77F  ea 89
	srl xbc, 16                                        ; FAA781  e9 ef 00
	srl wa, 0x01                                         ; FAA784  d8 ef 01
	cp BC,WA                                             ; FAA787  d8 f1
	jr c, .LFAA78D                                       ; FAA789  67 02
	inc 1,DE                                             ; FAA78B  da 61
.LFAA78D:
	ld	(TREG5L:8), de                                     ; FAA78D  f0 32 52
	bit	4, (MidiCfg_ModeBits:16)                               ; FAA790  f1 32 7f cc
	jr nz, .LFAA7A1                                      ; FAA794  6e 0b
	bit	4, (0x60f020:24)                             ; FAA796  f2 20 f0 60 cc
	jr nz, .LFAA7A1                                      ; FAA79B  6e 04
	call T_SysExTx_Tempo                                        ; FAA79D  1d ec 08 f4
.LFAA7A1:
	and	(0x60f020:24), 0xef                          ; FAA7A1  c2 20 f0 60 3c ef
	pop XDE                                              ; FAA7A7  5a
	pop XBC                                              ; FAA7A8  59
	pop XWA                                              ; FAA7A9  58
.LFAA7AA:
	ret                                                  ; FAA7AA  0e
T_F407A4_Nop:
	ret                                                  ; FAA7AB  0e
	ret                                                  ; FAA7AC  0e
	push XIZ                                             ; FAA7AD  3e
	push XIX                                             ; FAA7AE  3c
	push XHL                                             ; FAA7AF  3b
	push XDE                                             ; FAA7B0  3a
	ld bc, (0x60f177:24)                                ; FAA7B1  d2 77 f1 60 21
	ld de, (0x60f179:24)                                ; FAA7B6  d2 79 f1 60 22
	call ParamRecord_WriteFieldAndStage_Copy                                      ; FAA7BB  1d 6a a6 fa
	pop XDE                                              ; FAA7BF  5a
	pop XHL                                              ; FAA7C0  5b
	pop XIX                                              ; FAA7C1  5c
	pop XIZ                                              ; FAA7C2  5e
	ret                                                  ; FAA7C3  0e
; ParamChange_NotifyStagedClearSource: Memory-argument face of ParamChange_NotifyClearSource: (0x60F007) = 0, then
;   ParamChange_Notify with BC/DE read from the staged record at 0x60F177..0x60F17A, all registers preserved. Caller:
;   List2030_ParamB0_Apply, which stages {0xB0, 0, value, mask} there first. Basis: caller + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
ParamChange_NotifyStagedClearSource:
	ld (0x60f007:24), 0x00                             ; FAA7C4  f2 07 f0 60 00 00
	push XWA                                             ; FAA7CA  38
	push XBC                                             ; FAA7CB  39
	push XDE                                             ; FAA7CC  3a
	push XHL                                             ; FAA7CD  3b
	push XIX                                             ; FAA7CE  3c
	push XIY                                             ; FAA7CF  3d
	push XIZ                                             ; FAA7D0  3e
	ld bc, (0x60f177:24)                                ; FAA7D1  d2 77 f1 60 21
	ld de, (0x60f179:24)                                ; FAA7D6  d2 79 f1 60 22
	call ParamChange_Notify                                      ; FAA7DB  1d 04 a6 fa
	pop XIZ                                              ; FAA7DF  5e
	pop XIY                                              ; FAA7E0  5d
	pop XIX                                              ; FAA7E1  5c
	pop XHL                                              ; FAA7E2  5b
	pop XDE                                              ; FAA7E3  5a
	pop XBC                                              ; FAA7E4  59
	pop XWA                                              ; FAA7E5  58
	ret                                                  ; FAA7E6  0e
; SoundSel_StoreRequestGroupMaxMember: (0x60F176) := T_SoundGroup_MaxMemberIndex_Get for the clamp request's group
;   (0x60F160), bank (0x60F162) and part (0x60F01C), registers kept; SoundSel_ClampToProgramAndBank then clamps the
;   member against it. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
SoundSel_StoreRequestGroupMaxMember:
	push XIZ                                             ; FAA7E7  3e
	push XIX                                             ; FAA7E8  3c
	push XHL                                             ; FAA7E9  3b
	push XDE                                             ; FAA7EA  3a
	ld a, (0x60f160:24)                                 ; FAA7EB  c2 60 f1 60 21
	ld w, (0x60f162:24)                                 ; FAA7F0  c2 62 f1 60 20
	ld b, (0x60f01c:24)                                 ; FAA7F5  c2 1c f0 60 22
	call T_SoundGroup_MaxMemberIndex_Get                 ; FAA7FA  1d 1c 10 f4
	ld (0x60f176:24), a                                 ; FAA7FE  f2 76 f1 60 41
	pop XDE                                              ; FAA803  5a
	pop XHL                                              ; FAA804  5b
	pop XIX                                              ; FAA805  5c
	pop XIZ                                              ; FAA806  5e
	ret                                                  ; FAA807  0e
; CombiSel_StoreRequestGroupMaxMember: COMBI twin of SoundSel_StoreRequestGroupMaxMember: (0x60F176) :=
;   T_SoundGroup_MaxMemberIndex_GetToneCopy for group (0x60F181), bank (0x60F183) and selector (0x60F17F) (0x98 =
;   combinations), registers kept; CombiSel_ClampToNumberAndBank clamps the member with it. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
CombiSel_StoreRequestGroupMaxMember:
	push XIZ                                             ; FAA808  3e
	push XIX                                             ; FAA809  3c
	push XHL                                             ; FAA80A  3b
	push XDE                                             ; FAA80B  3a
	ld a, (0x60f181:24)                                 ; FAA80C  c2 81 f1 60 21
	ld w, (0x60f183:24)                                 ; FAA811  c2 83 f1 60 20
	ld b, (0x60f17f:24)                                 ; FAA816  c2 7f f1 60 22
	call T_SoundGroup_MaxMemberIndex_GetToneCopy         ; FAA81B  1d 34 10 f4
	ld (0x60f176:24), a                                 ; FAA81F  f2 76 f1 60 41
	pop XDE                                              ; FAA824  5a
	pop XHL                                              ; FAA825  5b
	pop XIX                                              ; FAA826  5c
	pop XIZ                                              ; FAA827  5e
	ret                                                  ; FAA828  0e
	ret                                                  ; FAA829  0e
; ParamModule_BootPhase0: module 11's boot phase 0 handler -- ModuleInitDirectory_F82641[11]'s vector 0xFAA400, slot 0
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
ParamModule_BootPhase0:
	pushw hl                                             ; FAA82A  2b
	ld h, 0xff:opc                                          ; FAA82B  26 ff
	ld (0x2000:16), h                                   ; FAA82D  f1 00 20 46
	ld (0x2030:16), h                                   ; FAA831  f1 30 20 46
	ld (0x2c00:16), h                                   ; FAA835  f1 00 2c 46
	ldw (0x60f000:24), 0x00                             ; FAA839  f2 00 f0 60 02 00 00
	ldw (0x60f002:24), 0x00                             ; FAA840  f2 02 f0 60 02 00 00
	ld (0x2e00:16), h                                   ; FAA847  f1 00 2e 46
	ldw (0x60f004:24), 0x00                             ; FAA84B  f2 04 f0 60 02 00 00
	ldw (0x60f08c:24), 0x00                             ; FAA852  f2 8c f0 60 02 00 00
	ld (0x60f030:24), h                                 ; FAA859  f2 30 f0 60 46
	ld (0x60f300:24), h                                 ; FAA85E  f2 00 f3 60 46
	ld (0x60f308:24), h                                 ; FAA863  f2 08 f3 60 46
	ld (0x60f330:24), h                                 ; FAA868  f2 30 f3 60 46
	ld (0x60f01e:24), 0x7f                             ; FAA86D  f2 1e f0 60 00 7f
	lda xbc, (ParamNumber_RecordPtrs:24)                 ; FAA873  f2 ea cd fa 31
	ld (IndexedTable_Base:24), xbc                               ; FAA878  f2 18 f0 60 61
	calr Mode_InitSavedPartBlocks_Nop                                      ; FAA87D  1e 8e 03
	popw hl                                              ; FAA880  4b
	ret                                                  ; FAA881  0e
; ParamModule_BootPhase2_MemoryLost: module 11's boot phase 2 handler -- ModuleInitDirectory_F82641[11]'s vector 0xFAA400, slot 2
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
ParamModule_BootPhase2_MemoryLost:
	pushw hl                                             ; FAA882  2b
	ld	c, (0x97:8)                                      ; FAA883  c0 97 23
	and C,0x10                                           ; FAA886  cb cc 10
	jr nz, .LFAA894                                      ; FAA889  6e 09
	ld (0x60f2d8:24), 0x01                             ; FAA88B  f2 d8 f2 60 00 01
	calr ParamImage_LoadFactoryDefaults                                      ; FAA891  1e 94 02
.LFAA894:
	push XDE                                             ; FAA894  3a
	push XHL                                             ; FAA895  3b
	push XIX                                             ; FAA896  3c
	push XIZ                                             ; FAA897  3e
	call T_ParamImage_ApplyAndMaskTable_Entry                                        ; FAA898  1d 20 02 f4
	call T_ParamImage_SanitizeAllAndHook_Entry                                        ; FAA89C  1d 1c 02 f4
	call T_F401D4                                        ; FAA8A0  1d d4 01 f4
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FAA8A4  1d 24 02 f4
	pop XIZ                                              ; FAA8A8  5e
	pop XIX                                              ; FAA8A9  5c
	pop XHL                                              ; FAA8AA  5b
	pop XDE                                              ; FAA8AB  5a
	calr ParamImage_PostAllAsChangeEvents                                      ; FAA8AC  1e 06 02
	call Tempo_ApplyBpm                                      ; FAA8AF  1d 42 a7 fa
	ld h, 0x00:opc                                          ; FAA8B3  26 00
.LFAA8B5:
	pushw 0x7f                                           ; FAA8B5  0b 7f 00
	ld L,H                                               ; FAA8B8  ce 8f
	pushw hl                                             ; FAA8BA  2b
	calr ParamNumber_GetRecordPtr                                          ; FAA8BB  1e ec 1f
	ld C,(XIY+0x01)                                      ; FAA8BE  8d 01 23
	popw wa                                              ; FAA8C1  48
	pushw bc                                             ; FAA8C2  29
	pushw 0x01                                           ; FAA8C3  0b 01 00
	pushw hl                                             ; FAA8C6  2b
	call T_PendingEventQueue_AppendStackArgs                                        ; FAA8C7  1d 18 1b f4
	inc 8,XSP                                            ; FAA8CB  ef 60
	pushw 0xff                                           ; FAA8CD  0b ff 00
	pushw hl                                             ; FAA8D0  2b
	calr ParamNumber_GetRecordPtr                                          ; FAA8D1  1e d6 1f
	ld C,(XIY)                                           ; FAA8D4  85 23
	popw wa                                              ; FAA8D6  48
	pushw bc                                             ; FAA8D7  29
	pushw 0x00                                           ; FAA8D8  0b 00 00
	pushw hl                                             ; FAA8DB  2b
	call T_PendingEventQueue_AppendStackArgs                                        ; FAA8DC  1d 18 1b f4
	ld H,L                                               ; FAA8E0  cf 8e
	inc 1,H                                              ; FAA8E2  ce 61
	inc 8,XSP                                            ; FAA8E4  ef 60
	cp h, 0x07:i3                                          ; FAA8E6  ce df
	jr ule, .LFAA8B5                                     ; FAA8E8  63 cb
	popw hl                                              ; FAA8EA  4b
	ret                                                  ; FAA8EB  0e
; ParamModule_BootPhase4: module 11's boot phase 4 handler -- ModuleInitDirectory_F82641[11]'s vector 0xFAA400, slot 4
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
ParamModule_BootPhase4:
	calr ParamModule_BootPhase2_MemoryLost                                      ; FAA8EC  1e 93 ff
	ret                                                  ; FAA8EF  0e
; ParamModule_BootPhase1_MemoryIntact: module 11's boot phase 1 handler -- ModuleInitDirectory_F82641[11]'s vector 0xFAA400, slot 1
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
ParamModule_BootPhase1_MemoryIntact:
	pushw hl                                             ; FAA8F0  2b
	push XDE                                             ; FAA8F1  3a
	push XHL                                             ; FAA8F2  3b
	push XIX                                             ; FAA8F3  3c
	push XIZ                                             ; FAA8F4  3e
	call T_ParamImage_ApplyAndMaskTable_Entry                                        ; FAA8F5  1d 20 02 f4
	call T_ParamImage_SanitizeAllAndHook_Entry                                        ; FAA8F9  1d 1c 02 f4
	call T_F401D4                                        ; FAA8FD  1d d4 01 f4
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FAA901  1d 24 02 f4
	pop XIZ                                              ; FAA905  5e
	pop XIX                                              ; FAA906  5c
	pop XHL                                              ; FAA907  5b
	pop XDE                                              ; FAA908  5a
	calr ParamImage_PostAllAsChangeEvents                                      ; FAA909  1e a9 01
	call Tempo_ApplyBpm                                      ; FAA90C  1d 42 a7 fa
	set	5, (0x60f021:24)                             ; FAA910  f2 21 f0 60 bd
	ld h, 0x00:opc                                          ; FAA915  26 00
.LFAA917:
	pushw 0x7f                                           ; FAA917  0b 7f 00
	ld L,H                                               ; FAA91A  ce 8f
	pushw hl                                             ; FAA91C  2b
	calr ParamNumber_GetRecordPtr                                          ; FAA91D  1e 8a 1f
	ld C,(XIY+0x01)                                      ; FAA920  8d 01 23
	popw wa                                              ; FAA923  48
	pushw bc                                             ; FAA924  29
	pushw 0x01                                           ; FAA925  0b 01 00
	pushw hl                                             ; FAA928  2b
	call T_PendingEventQueue_AppendStackArgs                                        ; FAA929  1d 18 1b f4
	inc 8,XSP                                            ; FAA92D  ef 60
	pushw 0xff                                           ; FAA92F  0b ff 00
	pushw hl                                             ; FAA932  2b
	calr ParamNumber_GetRecordPtr                                          ; FAA933  1e 74 1f
	ld C,(XIY)                                           ; FAA936  85 23
	popw wa                                              ; FAA938  48
	pushw bc                                             ; FAA939  29
	pushw 0x00                                           ; FAA93A  0b 00 00
	pushw hl                                             ; FAA93D  2b
	call T_PendingEventQueue_AppendStackArgs                                        ; FAA93E  1d 18 1b f4
	ld H,L                                               ; FAA942  cf 8e
	inc 1,H                                              ; FAA944  ce 61
	inc 8,XSP                                            ; FAA946  ef 60
	cp h, 0x07:i3                                          ; FAA948  ce df
	jr ule, .LFAA917                                     ; FAA94A  63 cb
	popw hl                                              ; FAA94C  4b
	ret                                                  ; FAA94D  0e
; ParamModule_BootPhase3: module 11's boot phase 3 handler -- ModuleInitDirectory_F82641[11]'s vector 0xFAA400, slot 3
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
ParamModule_BootPhase3:
	lda xbc, (ParamNumber_RecordPtrs:24)                 ; FAA94E  f2 ea cd fa 31
	ld (IndexedTable_Base:24), xbc                               ; FAA953  f2 18 f0 60 61
	cp	(0x60f2d8:24), 0x00                          ; FAA958  c2 d8 f2 60 3f 00
	jr z, .LFAA963                                       ; FAA95E  66 03
	calr Mode_InitSavedPartBlocks                                      ; FAA960  1e 50 02
.LFAA963:
	calr PartControllers_ResetAllParts                                      ; FAA963  1e b3 03
	ret                                                  ; FAA966  0e
; MidiSettings_ResetToDefault: what INITIAL item 3 MIDI SETTING runs (screen and SysEx) (notes/FINDINGS-prom_a-initial.md)
MidiSettings_ResetToDefault:
	link XIZ,0xfff6                                      ; FAA967  ee 0c f6 ff
	pushw hl                                             ; FAA96B  2b
	pushw de                                             ; FAA96C  2a
	push XIX                                             ; FAA96D  3c
	ld h, (0x7f4d:16)                                   ; FAA96E  c1 4d 7f 26
	ld C,H                                               ; FAA972  ce 8b
	and C,0x04                                           ; FAA974  cb cc 04
	jr z, .LFAA999                                       ; FAA977  66 20
	ld L,H                                               ; FAA979  ce 8f
	res 0x02,L                                           ; FAA97B  cf 30 02
	ld (0x7f4d:16), l                                   ; FAA97E  f1 4d 7f 47
	pushw 0x04                                           ; FAA982  0b 04 00
	pushw hl                                             ; FAA985  2b
	pushw 0x03                                           ; FAA986  0b 03 00
	pushw 0x91                                           ; FAA989  0b 91 00
	calr Queue2C00_Append4DrainWhenFull                                      ; FAA98C  1e 31 03
	set	5, (0x60f021:24)                             ; FAA98F  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAA994  1e 84 01
	inc 8,XSP                                            ; FAA997  ef 60
.LFAA999:
	ld l, 0x00:opc                                          ; FAA999  27 00
	ldw de, 0x00                                         ; FAA99B  32 00 00
.LFAA99E:
	pushw hl                                             ; FAA99E  2b
	calr ParamNumber_GetRecordPtr                                          ; FAA99F  1e 08 1f
	ld XIX,XIY                                           ; FAA9A2  ed 8c
	ld BC,DE                                             ; FAA9A4  da 89
	extz XBC                                             ; FAA9A6  e9 12
	add XBC,ParamNumber_DefaultRecordPtrs                              ; FAA9A8  e9 c8 8a d2 fa 00
	ld XBC,(XBC)                                         ; FAA9AE  a1 21
	inc 2,XBC                                            ; FAA9B0  e9 62
	ld (xiz-4), xbc                                      ; FAA9B2  be fc 61
	ld h, 0x0d:opc                                          ; FAA9B5  26 0d
	popw bc                                              ; FAA9B7  49
.LFAA9B8:
	ld C,H                                               ; FAA9B8  ce 8b
	extz BC                                              ; FAA9BA  d9 12
	extz XBC                                             ; FAA9BC  e9 12
	ld (xiz-8), xbc                                      ; FAA9BE  be f8 61
	add	xbc, (xiz-4)                                 ; FAA9C1  ae fc 81
	ld A,(XBC)                                           ; FAA9C4  81 21
	ld (xiz-10), a                                       ; FAA9C6  be f6 41
	ld XBC,XIX                                           ; FAA9C9  ec 89
	add	xbc, (xiz-8)                                 ; FAA9CB  ae f8 81
	ld (XBC),A                                           ; FAA9CE  b1 41
	pushw 0xff                                           ; FAA9D0  0b ff 00
	push 0x00                                            ; FAA9D3  09 00
	push	(xiz-10)                                     ; FAA9D5  8e f6 04
	push 0x00                                            ; FAA9D8  09 00
	push H                                               ; FAA9DA  ce 04
	pushw hl                                             ; FAA9DC  2b
	calr Queue2C00_Append4DrainWhenFull                                      ; FAA9DD  1e e0 02
	inc 1,H                                              ; FAA9E0  ce 61
	inc 8,XSP                                            ; FAA9E2  ef 60
	cp H,0x15                                            ; FAA9E4  ce cf 15
	jr ule, .LFAA9B8                                     ; FAA9E7  63 cf
	inc 4,DE                                             ; FAA9E9  da 64
	inc 1,L                                              ; FAA9EB  cf 61
	cp L,0x1f                                            ; FAA9ED  cf cf 1f
	jr ule, .LFAA99E                                     ; FAA9F0  63 ac
	lda xix, (0x7f30:16)                                ; FAA9F2  f1 30 7f 34
	lda xbc, (Rec_F3FD10:24)                             ; FAA9F6  f2 10 fd f3 31
	ld (xiz-4), xbc                                      ; FAA9FB  be fc 61
.LFAA9FE:
	lda xbc, (0x7f48:16)                                ; FAA9FE  f1 48 7f 31
	ld (xiz-8), xbc                                      ; FAAA02  be f8 61
	ld XWA,XIX                                           ; FAAA05  ec 88
	cp XWA,XBC                                           ; FAAA07  e9 f0
	jr nc, .LFAAA1D                                      ; FAAA09  6f 12
	ld xbc, (xiz-4)                                      ; FAAA0B  ae fc 21
	ld A,(XBC)                                           ; FAAA0E  81 21
	ld (XIX),A                                           ; FAAA10  b4 41
	inc 1,XIX                                            ; FAAA12  ec 61
	sub XBC,XBC                                          ; FAAA14  e9 a1
	inc 1,XBC                                            ; FAAA16  e9 61
	add (xiz-4), xbc                                     ; FAAA18  ae fc 89
	jr .LFAA9FE                                          ; FAAA1B  68 e1
.LFAAA1D:
	set	1, (0x7fc0:16)                               ; FAAA1D  f1 c0 7f b9
	lda xix, (MidiCfg_ModeBits:16)                                ; FAAA21  f1 32 7f 34
	ld h, 0x00:opc                                          ; FAAA25  26 00
.LFAAA27:
	lda xbc, (0x7f48:16)                                ; FAAA27  f1 48 7f 31
	ld (xiz-8), xbc                                      ; FAAA2B  be f8 61
	ld XWA,XIX                                           ; FAAA2E  ec 88
	cp XWA,XBC                                           ; FAAA30  e9 f0
	jr nc, .LFAAA4C                                      ; FAAA32  6f 18
	pushw 0xff                                           ; FAAA34  0b ff 00
	ld C,(XIX)                                           ; FAAA37  84 23
	pushw bc                                             ; FAAA39  29
	push 0x00                                            ; FAAA3A  09 00
	push H                                               ; FAAA3C  ce 04
	pushw 0x80                                           ; FAAA3E  0b 80 00
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAA41  1e 7c 02
	inc 1,XIX                                            ; FAAA44  ec 61
	inc 1,H                                              ; FAAA46  ce 61
	inc 8,XSP                                            ; FAAA48  ef 60
	jr .LFAAA27                                          ; FAAA4A  68 db
.LFAAA4C:
	cp	(Variant_Flag:8), 0x02                               ; FAAA4C  c0 c4 3f 02
	jr nz, .LFAAA7D                                      ; FAAA50  6e 2b
	ld (MidiCfg_InOutMode:16), 0x00                                 ; FAAA52  f1 35 7f 00 00
	cp	(UI_ScreenLatch:16), 0x6a                            ; FAAA57  c1 7a 20 3f 6a
	jr nz, .LFAAA65                                      ; FAAA5C  6e 07
	ld (MidiCfg_InOutMode:16), 0x01                                 ; FAAA5E  f1 35 7f 00 01
	jr .LFAAA69                                          ; FAAA63  68 04
.LFAAA65:
	set	1, (MidiCfg_InOutMode:16)                               ; FAAA65  f1 35 7f b9
.LFAAA69:
	pushw 0xff                                           ; FAAA69  0b ff 00
	push 0x00                                            ; FAAA6C  09 00
	push	(MidiCfg_InOutMode:16)                                  ; FAAA6E  c1 35 7f 04
	pushw 0x03                                           ; FAAA72  0b 03 00
	pushw 0x80                                           ; FAAA75  0b 80 00
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAA78  1e 45 02
	inc 8,XSP                                            ; FAAA7B  ef 60
.LFAAA7D:
	push XDE                                             ; FAAA7D  3a
	push XHL                                             ; FAAA7E  3b
	push XIX                                             ; FAAA7F  3c
	push XIZ                                             ; FAAA80  3e
	call T_Queue2C00_DrainPassB                          ; FAAA81  1d 38 00 f4
	pop XIZ                                              ; FAAA85  5e
	pop XIX                                              ; FAAA86  5c
	pop XHL                                              ; FAAA87  5b
	pop XDE                                              ; FAAA88  5a
	pop XIX                                              ; FAAA89  5c
	popw de                                              ; FAAA8A  4a
	popw hl                                              ; FAAA8B  4b
	unlk XIZ                                             ; FAAA8C  ee 0d
	ret                                                  ; FAAA8E  0e
sub_FAAA8F:
	calr ParamImage_LoadFactoryDefaults                                      ; FAAA8F  1e 96 00
	calr Mode_InitSavedPartBlocks                                      ; FAAA92  1e 1e 01
	push XDE                                             ; FAAA95  3a
	push XHL                                             ; FAAA96  3b
	push XIX                                             ; FAAA97  3c
	push XIZ                                             ; FAAA98  3e
	call T_ParamImage_SanitizeAllAndHook_Entry                                        ; FAAA99  1d 1c 02 f4
	call T_F401D4                                        ; FAAA9D  1d d4 01 f4
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FAAAA1  1d 24 02 f4
	pop XIZ                                              ; FAAAA5  5e
	pop XIX                                              ; FAAAA6  5c
	pop XHL                                              ; FAAAA7  5b
	pop XDE                                              ; FAAAA8  5a
	calr ParamImage_PostAllAsChangeEvents                                      ; FAAAA9  1e 09 00
	call Tempo_ApplyBpm                                      ; FAAAAC  1d 42 a7 fa
	ret                                                  ; FAAAB0  0e
; ParamImage_PostAllAsChangeEvents_Call: calls ParamImage_PostAllAsChangeEvents and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
ParamImage_PostAllAsChangeEvents_Call:
	calr ParamImage_PostAllAsChangeEvents                                      ; FAAAB1  1e 01 00
	ret                                                  ; FAAAB4  0e
; ParamImage_PostAllAsChangeEvents: Posts {0x91, 3, (0x7F4D), 0xFF}, then every byte of the parameter image
;   0x7620..0x7F7E as change events {record, byte, value, 0xFF} into the 0x2C00 queue, draining it. Run by both
;   ParamModule boot phases after the ParamImage_* steps and by the test-mode selector. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
ParamImage_PostAllAsChangeEvents:
	link XIZ,0xfffc                                      ; FAAAB5  ee 0c fc ff
	pushw hl                                             ; FAAAB9  2b
	push XIX                                             ; FAAABA  3c
	pushw 0xff                                           ; FAAABB  0b ff 00
	ld c, (0x7f4d:16)                                   ; FAAABE  c1 4d 7f 23
	pushw bc                                             ; FAAAC2  29
	pushw 0x03                                           ; FAAAC3  0b 03 00
	pushw 0x91                                           ; FAAAC6  0b 91 00
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAAC9  1e f4 01
	set	5, (0x60f021:24)                             ; FAAACC  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAAAD1  1e 47 00
	lda xix, (Combination_Current:16)                                ; FAAAD4  f1 20 76 34
	inc 8,XSP                                            ; FAAAD8  ef 60
.LFAAADA:
	lda xbc, (0x7f7e:16)                                ; FAAADA  f1 7e 7f 31
	ld (xiz-4), xbc                                      ; FAAADE  be fc 61
	ld XWA,XIX                                           ; FAAAE1  ec 88
	cp XWA,XBC                                           ; FAAAE3  e9 f0
	jr nc, .LFAAB0E                                      ; FAAAE5  6f 27
; (sub_FAAAE7 removed 2026-10-04: no code names it and the line above falls through into it -- part of ParamImage_PostAllAsChangeEvents;
;  notes/prom_a_stray_label_removal.py)
	ld H,(XIX)                                           ; FAAAE7  84 26
	cp H,0xff                                            ; FAAAE9  ce cf ff
	jr nz, .LFAAAF2                                      ; FAAAEC  6e 04
	inc 2,XIX                                            ; FAAAEE  ec 62
	jr .LFAAADA                                          ; FAAAF0  68 e8
.LFAAAF2:
	push XIX                                             ; FAAAF2  3c
	cp H,0x1f                                            ; FAAAF3  ce cf 1f
	jr ugt, .LFAAAFD                                     ; FAAAF6  6b 05
	calr ParamImage_PostPartRecordAsChangeEvents                                      ; FAAAF8  1e 14 01
	jr .LFAAB00                                          ; FAAAFB  68 03
.LFAAAFD:
	calr ParamImage_PostRecordAsChangeEvents                                      ; FAAAFD  1e 7d 01
.LFAAB00:
	pop XIY                                              ; FAAB00  5d
	ld C,(XIX+0x01)                                      ; FAAB01  8c 01 23
	extz BC                                              ; FAAB04  d9 12
	extz XBC                                             ; FAAB06  e9 12
	inc 2,XBC                                            ; FAAB08  e9 62
	add XIX,XBC                                          ; FAAB0A  e9 84
	jr .LFAAADA                                          ; FAAB0C  68 cc
.LFAAB0E:
	set	5, (0x60f021:24)                             ; FAAB0E  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAAB13  1e 05 00
	pop XIX                                              ; FAAB16  5c
	popw hl                                              ; FAAB17  4b
	unlk XIZ                                             ; FAAB18  ee 0d
	ret                                                  ; FAAB1A  0e
Queue2C00_DrainPassB_SaveRegs2:
	push XDE                                             ; FAAB1B  3a
	push XHL                                             ; FAAB1C  3b
	push XIX                                             ; FAAB1D  3c
	push XIZ                                             ; FAAB1E  3e
	call T_Queue2C00_DrainPassB                          ; FAAB1F  1d 38 00 f4
	pop XIZ                                              ; FAAB23  5e
	pop XIX                                              ; FAAB24  5c
	pop XHL                                              ; FAAB25  5b
	pop XDE                                              ; FAAB26  5a
	ret                                                  ; FAAB27  0e
; ParamImage_LoadFactoryDefaults: Copies the factory-default record stream at 0xF3F400 (prom_b Default_Record78 ...)
;   byte for byte over RAM 0x7620..0x7F7F, sets MidiCfg_InOutMode on variant 2 (1 on screen 0x6A, else bit 1), clears
;   (0x7FC2) bit 0, sets (0x7FC0) bit 1, clears (0x7FD6) bits 0-1, and runs DspEffect_ApplyAlgorithmDefaults for
;   blocks 0x61..0x63 with their algorithms (0x7642)/(0x7662)/(0x7682). Basis: callers + body + data -- the memory-
;   lost boot phase and the power-on test-mode chord that also posts every parameter. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
ParamImage_LoadFactoryDefaults:
	link XIZ,0xfff8                                      ; FAAB28  ee 0c f8 ff
	push XIX                                             ; FAAB2C  3c
	lda xix, (Combination_Current:16)                                ; FAAB2D  f1 20 76 34
	lda xbc, (Rec_F3F400:24)                             ; FAAB31  f2 00 f4 f3 31
	ld (xiz-8), xbc                                      ; FAAB36  be f8 61
	ldw wa, 0x7f7e                                       ; FAAB39  30 7e 7f
	inc 1,WA                                             ; FAAB3C  d8 61
	extz XWA                                             ; FAAB3E  e8 12
	ld (xiz-4), xwa                                      ; FAAB40  be fc 60
.LFAAB43:
	ld XBC,XIX                                           ; FAAB43  ec 89
	cp	xbc, (xiz-4)                                 ; FAAB45  ae fc f1
	jr ugt, .LFAAB5C                                     ; FAAB48  6b 12
	ld xbc, (xiz-8)                                      ; FAAB4A  ae f8 21
	ld A,(XBC)                                           ; FAAB4D  81 21
	ld (XIX),A                                           ; FAAB4F  b4 41
	inc 1,XIX                                            ; FAAB51  ec 61
	sub XBC,XBC                                          ; FAAB53  e9 a1
	inc 1,XBC                                            ; FAAB55  e9 61
	add (xiz-8), xbc                                     ; FAAB57  ae f8 89
	jr .LFAAB43                                          ; FAAB5A  68 e7
.LFAAB5C:
	cp	(Variant_Flag:8), 0x02                               ; FAAB5C  c0 c4 3f 02
	jr nz, .LFAAB79                                      ; FAAB60  6e 17
	ld (MidiCfg_InOutMode:16), 0x00                                 ; FAAB62  f1 35 7f 00 00
	cp	(UI_ScreenLatch:16), 0x6a                            ; FAAB67  c1 7a 20 3f 6a
	jr nz, .LFAAB75                                      ; FAAB6C  6e 07
	ld (MidiCfg_InOutMode:16), 0x01                                 ; FAAB6E  f1 35 7f 00 01
	jr .LFAAB79                                          ; FAAB73  68 04
.LFAAB75:
	set	1, (MidiCfg_InOutMode:16)                               ; FAAB75  f1 35 7f b9
.LFAAB79:
	res	0, (0x7fc2:16)                               ; FAAB79  f1 c2 7f b0
	set	1, (0x7fc0:16)                               ; FAAB7D  f1 c0 7f b9
	and	(0x7fd6:16), 0xfc                            ; FAAB81  c1 d6 7f 3c fc
	ld c, (0x7642:16)                                   ; FAAB86  c1 42 76 23
	pushw bc                                             ; FAAB8A  29
	pushw 0x61                                           ; FAAB8B  0b 61 00
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FAAB8E  1d 58 2f f4
	ld c, (0x7662:16)                                   ; FAAB92  c1 62 76 23
	pushw bc                                             ; FAAB96  29
	pushw 0x62                                           ; FAAB97  0b 62 00
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FAAB9A  1d 58 2f f4
	ld c, (0x7682:16)                                   ; FAAB9E  c1 82 76 23
	pushw bc                                             ; FAABA2  29
	pushw 0x63                                           ; FAABA3  0b 63 00
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FAABA6  1d 58 2f f4
	inc 8,XSP                                            ; FAABAA  ef 60
	inc 4,XSP                                            ; FAABAC  ef 64
	pop XIX                                              ; FAABAE  5c
	unlk XIZ                                             ; FAABAF  ee 0d
	ret                                                  ; FAABB1  0e
	ret                                                  ; FAABB2  0e
; Mode_InitSavedPartBlocks: Combination_Current -> 0x7000 (the sound-mode save of Mode_SwitchToCombination) and CPU
;   2's first preset combination record (PromC_PresetBank_Records, 0x2C0 bytes, link 0xE2) -> 0x7300 (the combination-
;   mode block); (0x60F2D8) := 0. Run by INITIAL TOTAL, after ParamImage_LoadFactoryDefaults, and in boot phase 3 when
;   phase 2 lost memory and set (0x60F2D8). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
Mode_InitSavedPartBlocks:
	link XIZ,0xfff8                                      ; FAABB3  ee 0c f8 ff
	pushw hl                                             ; FAABB7  2b
	push XIX                                             ; FAABB8  3c
	lda xbc, (0x7000:16)                                ; FAABB9  f1 00 70 31
	ld (xiz-8), xbc                                      ; FAABBD  be f8 61
	lda xix, (Combination_Current:16)                                ; FAABC0  f1 20 76 34
	ldw wa, 0x78de                                       ; FAABC4  30 de 78
; (sub_FAABC7 removed 2026-10-04: no code names it and the line above falls through into it -- part of Mode_InitSavedPartBlocks;
;  notes/prom_a_stray_label_removal.py)
	inc 2,WA                                             ; FAABC7  d8 62
	extz XWA                                             ; FAABC9  e8 12
	ld (xiz-4), xwa                                      ; FAABCB  be fc 60
.LFAABCE:
	ld XBC,XIX                                           ; FAABCE  ec 89
	cp	xbc, (xiz-4)                                 ; FAABD0  ae fc f1
	jr ugt, .LFAABE9                                     ; FAABD3  6b 14
	ld C,(XIX)                                           ; FAABD5  84 23
	ld H,C                                               ; FAABD7  cb 8e
; (sub_FAABD9 removed 2026-10-04: no code names it and the line above falls through into it -- part of Mode_InitSavedPartBlocks;
;  notes/prom_a_stray_label_removal.py)
	ld xbc, (xiz-8)                                      ; FAABD9  ae f8 21
	ld (XBC),H                                           ; FAABDC  b1 46
	sub XBC,XBC                                          ; FAABDE  e9 a1
	inc 1,XBC                                            ; FAABE0  e9 61
	add (xiz-8), xbc                                     ; FAABE2  ae f8 89
	add XIX,XBC                                          ; FAABE5  e9 84
	jr .LFAABCE                                          ; FAABE7  68 e5
.LFAABE9:
	lda xbc, (0x7300:16)                                ; FAABE9  f1 00 73 31
	push XBC                                             ; FAABED  39
	pushw 0x02c0                                         ; FAABEE  0b c0 02
	ld XWA,PromC_PresetBank_Records                                     ; FAABF1  40 00 03 f8 00
	push XWA                                             ; FAABF6  38
	call T_Link_SendCommandE2                            ; FAABF7  1d f0 0e f4
	call T_Link_WaitBlockDone                            ; FAABFB  1d 3c 12 f4
	ld (0x60f2d8:24), 0x00                             ; FAABFF  f2 d8 f2 60 00 00
	inc 8,XSP                                            ; FAAC05  ef 60
	inc 2,XSP                                            ; FAAC07  ef 62
	pop XIX                                              ; FAAC09  5c
	popw hl                                              ; FAAC0A  4b
	unlk XIZ                                             ; FAAC0B  ee 0d
	ret                                                  ; FAAC0D  0e
Mode_InitSavedPartBlocks_Nop:
	ret                                                  ; FAAC0E  0e
; ParamImage_PostPartRecordAsChangeEvents: For one parameter-image record {id, length, data} with id <= 0x1F posts
;   data byte 1, then byte 0, then bytes 2.. as change events {id, i, value, 0xFF} into the 0x2C00 queue.
;   ParamImage_PostRecordAsChangeEvents' twin for the part records (ids 0..0x1F); also posts a part record
;   PartSettings_ResetToDefault rewrote. Basis: callers + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
ParamImage_PostPartRecordAsChangeEvents:
	link XIZ,0xfffc                                      ; FAAC0F  ee 0c fc ff
	pushw hl                                             ; FAAC13  2b
	pushw de                                             ; FAAC14  2a
	push XIX                                             ; FAAC15  3c
	ld XIX,(XIZ+0x08)                                    ; FAAC16  ae 08 24
	ld D,(XIX)                                           ; FAAC19  84 24
	ld E,(XIX+0x01)                                      ; FAAC1B  8c 01 25
	ld XBC,XIX                                           ; FAAC1E  ec 89
	inc 2,XBC                                            ; FAAC20  e9 62
	ld (xiz-4), xbc                                      ; FAAC22  be fc 61
	pushw 0xff                                           ; FAAC25  0b ff 00
	ld A,(XBC+0x01)                                      ; FAAC28  89 01 21
	pushw wa                                             ; FAAC2B  28
	pushw 0x01                                           ; FAAC2C  0b 01 00
	push 0x00                                            ; FAAC2F  09 00
	push D                                               ; FAAC31  cc 04
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAC33  1e 8a 00
	pushw 0xff                                           ; FAAC36  0b ff 00
	ld xbc, (xiz-4)                                      ; FAAC39  ae fc 21
	ld A,(XBC)                                           ; FAAC3C  81 21
	pushw wa                                             ; FAAC3E  28
	pushw 0x00                                           ; FAAC3F  0b 00 00
	push 0x00                                            ; FAAC42  09 00
	push D                                               ; FAAC44  cc 04
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAC46  1e 77 00
	ld L,E                                               ; FAAC49  cd 8f
	dec 4,L                                              ; FAAC4B  cf 6c
	ld h, 0x02:opc                                          ; FAAC4D  26 02
	ld xix, (xiz-4)                                      ; FAAC4F  ae fc 24
	inc 2,XIX                                            ; FAAC52  ec 62
	inc 8,XSP                                            ; FAAC54  ef 60
	inc 8,XSP                                            ; FAAC56  ef 60
	jr .LFAAC73                                          ; FAAC58  68 19
.LFAAC5A:
	pushw 0xff                                           ; FAAC5A  0b ff 00
	ld C,(XIX)                                           ; FAAC5D  84 23
	pushw bc                                             ; FAAC5F  29
	push 0x00                                            ; FAAC60  09 00
	push H                                               ; FAAC62  ce 04
	push 0x00                                            ; FAAC64  09 00
	push D                                               ; FAAC66  cc 04
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAC68  1e 55 00
	dec 1,L                                              ; FAAC6B  cf 69
	inc 1,H                                              ; FAAC6D  ce 61
	inc 1,XIX                                            ; FAAC6F  ec 61
	inc 8,XSP                                            ; FAAC71  ef 60
.LFAAC73:
	cp l, 0x00:i3                                          ; FAAC73  cf d8
	jr nz, .LFAAC5A                                      ; FAAC75  6e e3
	pop XIX                                              ; FAAC77  5c
	popw de                                              ; FAAC78  4a
	popw hl                                              ; FAAC79  4b
	unlk XIZ                                             ; FAAC7A  ee 0d
	ret                                                  ; FAAC7C  0e
; ParamImage_PostRecordAsChangeEvents: For one parameter-image record {id, length, data...} (arg): posts each data
;   byte i as change event {id, i, value, 0xFF} into the 0x2C00 queue (Queue2C00_Append4DrainWhenFull), skipping byte 3 of record 0x91.
;   Used per record id > 0x1F by ParamImage_PostAllAsChangeEvents and after Part/SystemSettings_ResetToDefault rewrite
;   a record. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
ParamImage_PostRecordAsChangeEvents:
	link XIZ,0x0000                                      ; FAAC7D  ee 0c 00 00
	pushw hl                                             ; FAAC81  2b
	pushw de                                             ; FAAC82  2a
	push XIX                                             ; FAAC83  3c
	ld XIX,(XIZ+0x08)                                    ; FAAC84  ae 08 24
	ld D,(XIX)                                           ; FAAC87  84 24
	ld L,(XIX+0x01)                                      ; FAAC89  8c 01 27
	dec 2,L                                              ; FAAC8C  cf 6a
	ld h, 0x00:opc                                          ; FAAC8E  26 00
	inc 2,XIX                                            ; FAAC90  ec 62
	jr .LFAACB6                                          ; FAAC92  68 22
.LFAAC94:
	cp D,0x91                                            ; FAAC94  cc cf 91
	jr nz, .LFAAC9D                                      ; FAAC97  6e 04
	cp h, 0x03:i3                                          ; FAAC99  ce db
	jr z, .LFAACB0                                       ; FAAC9B  66 13
.LFAAC9D:
	pushw 0xff                                           ; FAAC9D  0b ff 00
	ld C,(XIX)                                           ; FAACA0  84 23
	pushw bc                                             ; FAACA2  29
	push 0x00                                            ; FAACA3  09 00
	push H                                               ; FAACA5  ce 04
	push 0x00                                            ; FAACA7  09 00
	push D                                               ; FAACA9  cc 04
	calr Queue2C00_Append4DrainWhenFull                                      ; FAACAB  1e 12 00
	inc 8,XSP                                            ; FAACAE  ef 60
.LFAACB0:
	dec 1,L                                              ; FAACB0  cf 69
	inc 1,H                                              ; FAACB2  ce 61
	inc 1,XIX                                            ; FAACB4  ec 61
.LFAACB6:
	cp l, 0x00:i3                                          ; FAACB6  cf d8
	jr nz, .LFAAC94                                      ; FAACB8  6e da
	pop XIX                                              ; FAACBA  5c
	popw de                                              ; FAACBB  4a
	popw hl                                              ; FAACBC  4b
	unlk XIZ                                             ; FAACBD  ee 0d
	ret                                                  ; FAACBF  0e
; Queue2C00_Append4DrainWhenFull: Appends {arg0, arg1, arg2, arg3} (four 16-bit stack slots) + 0xFF at 0x2C00 +
;   (0x60F000) and advances the cursor by 4; at 0x1FC it sets (0x60F021) bit 5, drains
;   (Queue2C00_DrainPassB_SaveRegs2) and zeroes the cursor. Change-event poster of the reset/post-all routines. Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
Queue2C00_Append4DrainWhenFull:
	link XIZ,0xfffc                                      ; FAACC0  ee 0c fc ff
	pushw hl                                             ; FAACC4  2b
	push XIX                                             ; FAACC5  3c
	lda xix, (0x60f000:24)                               ; FAACC6  f2 00 f0 60 34
	ld HL,(XIX)                                          ; FAACCB  94 23
	ldw bc, 0x2c00                                       ; FAACCD  31 00 2c
	add BC,HL                                            ; FAACD0  db 81
	extz XBC                                             ; FAACD2  e9 12
	ld (xiz-4), xbc                                      ; FAACD4  be fc 61
	ld A,(XIZ+0x08)                                      ; FAACD7  8e 08 21
	ld (XBC),A                                           ; FAACDA  b1 41
	ld xbc, (xiz-4)                                      ; FAACDC  ae fc 21
	ld A,(XIZ+0x0a)                                      ; FAACDF  8e 0a 21
	ld (XBC+0x01),A                                      ; FAACE2  b9 01 41
	ld xbc, (xiz-4)                                      ; FAACE5  ae fc 21
	ld A,(XIZ+0x0c)                                      ; FAACE8  8e 0c 21
	ld (XBC+0x02),A                                      ; FAACEB  b9 02 41
	ld xbc, (xiz-4)                                      ; FAACEE  ae fc 21
	ld A,(XIZ+0x0e)                                      ; FAACF1  8e 0e 21
	ld (XBC+0x03),A                                      ; FAACF4  b9 03 41
	ld xbc, (xiz-4)                                      ; FAACF7  ae fc 21
	ld (XBC+0x04),0xff                                   ; FAACFA  b9 04 00 ff
	incw 0x04, (xix)                                     ; FAACFE  94 64
	ld BC,(XIX)                                          ; FAAD00  94 21
	cp BC,0x01fc                                         ; FAAD02  d9 cf fc 01
	jr c, .LFAAD14                                       ; FAAD06  67 0c
	set	5, (0x60f021:24)                             ; FAAD08  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAAD0D  1e 0b fe
	ldw	(xix), 0x0000                                ; FAAD10  b4 02 00 00
.LFAAD14:
	pop XIX                                              ; FAAD14  5c
	popw hl                                              ; FAAD15  4b
	unlk XIZ                                             ; FAAD16  ee 0d
	ret                                                  ; FAAD18  0e
; PartControllers_ResetAllParts: For parts 0..31 queues (Queue2C00, Queue2C00_AppendStagedDrainPassB) the per-part controller events at
;   their defaults: 0xB1 pitch bend 00 40 (centre), 0xB2 modulation 0, 0xBC breath 0, 0xB3 expression 0x7F, 0xB4
;   channel pressure 0, 0xB8-0xBB GP1-4 0x40, 0xB5 sustain 0, 0xBD foot 0; then drains pass B. Run by
;   ParamModule_BootPhase3 and SystemSettings_ResetToDefault. Basis: callers + body + the UiListB class handlers.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
PartControllers_ResetAllParts:
	pushw hl                                             ; FAAD19  2b
	pushw de                                             ; FAAD1A  2a
	push XIX                                             ; FAAD1B  3c
	ld h, 0x00:opc                                          ; FAAD1C  26 00
	lda xix, (0x60f082:24)                               ; FAAD1E  f2 82 f0 60 34
.LFAAD23:
	ld (0x60f080:24), 0xb1                             ; FAAD23  f2 80 f0 60 00 b1
	ld L,H                                               ; FAAD29  ce 8f
	ld (0x60f081:24), l                                 ; FAAD2B  f2 81 f0 60 47
	ld (XIX),0x00                                        ; FAAD30  b4 00 00
	ld d, 0x40:opc                                          ; FAAD33  24 40
	ld (0x60f083:24), d                                 ; FAAD35  f2 83 f0 60 44
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAAD3A  1e f6 04
	ld (0x60f080:24), 0xb2                             ; FAAD3D  f2 80 f0 60 00 b2
	ld (0x60f081:24), l                                 ; FAAD43  f2 81 f0 60 47
	ld (XIX),0x00                                        ; FAAD48  b4 00 00
	ld e, 0x7f:opc                                          ; FAAD4B  25 7f
	ld (0x60f083:24), e                                 ; FAAD4D  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAAD52  1e de 04
	ld (0x60f080:24), 0xbc                             ; FAAD55  f2 80 f0 60 00 bc
	ld (0x60f081:24), l                                 ; FAAD5B  f2 81 f0 60 47
	ld (XIX),0x00                                        ; FAAD60  b4 00 00
	ld (0x60f083:24), e                                 ; FAAD63  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAAD68  1e c8 04
	ld (0x60f080:24), 0xb3                             ; FAAD6B  f2 80 f0 60 00 b3
	ld (0x60f081:24), l                                 ; FAAD71  f2 81 f0 60 47
	ld (XIX),E                                           ; FAAD76  b4 45
	ld (0x60f083:24), e                                 ; FAAD78  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAAD7D  1e b3 04
	ld (0x60f080:24), 0xb4                             ; FAAD80  f2 80 f0 60 00 b4
	ld (0x60f081:24), l                                 ; FAAD86  f2 81 f0 60 47
	ld (XIX),0x00                                        ; FAAD8B  b4 00 00
	ld (0x60f083:24), e                                 ; FAAD8E  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAAD93  1e 9d 04
	ld (0x60f080:24), 0xb8                             ; FAAD96  f2 80 f0 60 00 b8
	ld (0x60f081:24), l                                 ; FAAD9C  f2 81 f0 60 47
	ld (XIX),D                                           ; FAADA1  b4 44
	ld (0x60f083:24), e                                 ; FAADA3  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAADA8  1e 88 04
	ld (0x60f080:24), 0xb9                             ; FAADAB  f2 80 f0 60 00 b9
	ld (0x60f081:24), l                                 ; FAADB1  f2 81 f0 60 47
	ld (XIX),D                                           ; FAADB6  b4 44
	ld (0x60f083:24), e                                 ; FAADB8  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAADBD  1e 73 04
	ld (0x60f080:24), 0xba                             ; FAADC0  f2 80 f0 60 00 ba
	ld (0x60f081:24), l                                 ; FAADC6  f2 81 f0 60 47
	ld (XIX),D                                           ; FAADCB  b4 44
	ld (0x60f083:24), e                                 ; FAADCD  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAADD2  1e 5e 04
	ld (0x60f080:24), 0xbb                             ; FAADD5  f2 80 f0 60 00 bb
	ld (0x60f081:24), l                                 ; FAADDB  f2 81 f0 60 47
	ld (XIX),D                                           ; FAADE0  b4 44
	ld (0x60f083:24), e                                 ; FAADE2  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAADE7  1e 49 04
	ld (0x60f080:24), 0xb5                             ; FAADEA  f2 80 f0 60 00 b5
	ld (0x60f081:24), l                                 ; FAADF0  f2 81 f0 60 47
	ld (XIX),0x00                                        ; FAADF5  b4 00 00
	ld (0x60f083:24), e                                 ; FAADF8  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAADFD  1e 33 04
	ld (0x60f080:24), 0xbd                             ; FAAE00  f2 80 f0 60 00 bd
	ld (0x60f081:24), l                                 ; FAAE06  f2 81 f0 60 47
	ld (XIX),0x00                                        ; FAAE0B  b4 00 00
	ld (0x60f083:24), e                                 ; FAAE0E  f2 83 f0 60 45
	calr Queue2C00_AppendStagedDrainPassB                                      ; FAAE13  1e 1d 04
	inc 1,H                                              ; FAAE16  ce 61
	cp H,0x1f                                            ; FAAE18  ce cf 1f
	jrl ule, .LFAAD23                                    ; FAAE1B  73 05 ff
	set	5, (0x60f021:24)                             ; FAAE1E  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAAE23  1e f5 fc
	pop XIX                                              ; FAAE26  5c
	popw de                                              ; FAAE27  4a
	popw hl                                              ; FAAE28  4b
	ret                                                  ; FAAE29  0e
; PartSettings_ResetToDefault: what INITIAL item 1 PART SETTING runs (screen and SysEx): loops over the PART parameter records from 0x20 (notes/FINDINGS-prom_a-initial.md)
PartSettings_ResetToDefault:
	link XIZ,0xffec                                      ; FAAE2A  ee 0c ec ff
	pushw hl                                             ; FAAE2E  2b
	pushw de                                             ; FAAE2F  2a
	push XIX                                             ; FAAE30  3c
	ld l, 0x00:opc                                          ; FAAE31  27 00
	ldw de, 0x00                                         ; FAAE33  32 00 00
	ldw	(xiz-10), 0x0020                             ; FAAE36  be f6 02 20 00
.LFAAE3B:
	pushw hl                                             ; FAAE3B  2b
	calr ParamNumber_GetRecordPtr                                          ; FAAE3C  1e 6b 1a
	ld (xiz-14), xiy                                     ; FAAE3F  be f2 65
	ld BC,DE                                             ; FAAE42  da 89
	extz XBC                                             ; FAAE44  e9 12
	add XBC,ParamNumber_DefaultRecordPtrs                              ; FAAE46  e9 c8 8a d2 fa 00
	ld XBC,(XBC)                                         ; FAAE4C  a1 21
	ld XIX,XBC                                           ; FAAE4E  e9 8c
	ld h, 0x00:opc                                          ; FAAE50  26 00
	inc 1,XBC                                            ; FAAE52  e9 61
	ld (xiz-8), xbc                                      ; FAAE54  be f8 61
	sub XWA,XWA                                          ; FAAE57  e8 a0
	inc 2,XWA                                            ; FAAE59  e8 62
	ld (xiz-4), xwa                                      ; FAAE5B  be fc 60
	inc 2,XSP                                            ; FAAE5E  ef 62
.LFAAE60:
	ld xbc, (xiz-8)                                      ; FAAE60  ae f8 21
	ld A,(XBC)                                           ; FAAE63  81 21
	cp H,A                                               ; FAAE65  c9 f6
	jr nc, .LFAAE90                                      ; FAAE67  6f 27
	ld xwa, (xiz-4)                                      ; FAAE69  ae fc 20
	ld (xiz-18), xwa                                     ; FAAE6C  be ee 60
	add XWA,XIX                                          ; FAAE6F  ec 80
	ld C,(XWA)                                           ; FAAE71  80 23
	ld (xiz-20), c                                       ; FAAE73  be ec 43
	ld C,H                                               ; FAAE76  ce 8b
	extz BC                                              ; FAAE78  d9 12
	extz XBC                                             ; FAAE7A  e9 12
	add	xbc, (xiz-14)                                ; FAAE7C  ae f2 81
	ld w, (xiz-20)                                       ; FAAE7F  8e ec 20
	ld (XBC),W                                           ; FAAE82  b1 40
	ld xbc, (xiz-18)                                     ; FAAE84  ae ee 21
	inc 1,XBC                                            ; FAAE87  e9 61
	ld (xiz-4), xbc                                      ; FAAE89  be fc 61
	inc 1,H                                              ; FAAE8C  ce 61
	jr .LFAAE60                                          ; FAAE8E  68 d0
.LFAAE90:
	ld xbc, (xiz-14)                                     ; FAAE90  ae f2 21
	dec 2,XBC                                            ; FAAE93  e9 6a
	push XBC                                             ; FAAE95  39
	calr ParamImage_PostPartRecordAsChangeEvents                                      ; FAAE96  1e 76 fd
	ld c, (xiz-10)                                       ; FAAE99  8e f6 23
	pushw bc                                             ; FAAE9C  29
	calr ParamNumber_GetRecordPtr                                          ; FAAE9D  1e 0a 1a
	ld (xiz-14), xiy                                     ; FAAEA0  be f2 65
	ld BC,DE                                             ; FAAEA3  da 89
	extz XBC                                             ; FAAEA5  e9 12
	add XBC,ParamNumber_DefaultRecordPtrs+0x80                         ; FAAEA7  e9 c8 0a d3 fa 00
	ld XBC,(XBC)                                         ; FAAEAD  a1 21
	ld XIX,XBC                                           ; FAAEAF  e9 8c
	ld h, 0x00:opc                                          ; FAAEB1  26 00
	inc 1,XBC                                            ; FAAEB3  e9 61
	ld (xiz-8), xbc                                      ; FAAEB5  be f8 61
	sub XWA,XWA                                          ; FAAEB8  e8 a0
	inc 2,XWA                                            ; FAAEBA  e8 62
	ld (xiz-4), xwa                                      ; FAAEBC  be fc 60
	inc 6,XSP                                            ; FAAEBF  ef 66
.LFAAEC1:
	ld xbc, (xiz-8)                                      ; FAAEC1  ae f8 21
	ld A,(XBC)                                           ; FAAEC4  81 21
	cp H,A                                               ; FAAEC6  c9 f6
	jr nc, .LFAAEF1                                      ; FAAEC8  6f 27
	ld xwa, (xiz-4)                                      ; FAAECA  ae fc 20
	ld (xiz-18), xwa                                     ; FAAECD  be ee 60
	add XWA,XIX                                          ; FAAED0  ec 80
	ld C,(XWA)                                           ; FAAED2  80 23
	ld (xiz-20), c                                       ; FAAED4  be ec 43
	ld C,H                                               ; FAAED7  ce 8b
	extz BC                                              ; FAAED9  d9 12
	extz XBC                                             ; FAAEDB  e9 12
	add	xbc, (xiz-14)                                ; FAAEDD  ae f2 81
	ld w, (xiz-20)                                       ; FAAEE0  8e ec 20
	ld (XBC),W                                           ; FAAEE3  b1 40
	ld xbc, (xiz-18)                                     ; FAAEE5  ae ee 21
	inc 1,XBC                                            ; FAAEE8  e9 61
	ld (xiz-4), xbc                                      ; FAAEEA  be fc 61
	inc 1,H                                              ; FAAEED  ce 61
	jr .LFAAEC1                                          ; FAAEEF  68 d0
.LFAAEF1:
	ld xbc, (xiz-14)                                     ; FAAEF1  ae f2 21
	dec 2,XBC                                            ; FAAEF4  e9 6a
	push XBC                                             ; FAAEF6  39
	calr ParamImage_PostRecordAsChangeEvents                                      ; FAAEF7  1e 83 fd
	inc 4,DE                                             ; FAAEFA  da 64
	incw 0x01, (xiz-10)                                  ; FAAEFC  9e f6 61
	inc 1,L                                              ; FAAEFF  cf 61
	pop XIY                                              ; FAAF01  5d
	cp L,0x1f                                            ; FAAF02  cf cf 1f
	jrl ule, .LFAAE3B                                    ; FAAF05  73 33 ff
	set	5, (0x60f021:24)                             ; FAAF08  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAAF0D  1e 0b fc
	lda xbc, (0x76a0:16)                                ; FAAF10  f1 a0 76 31
	ld (xiz-14), xbc                                     ; FAAF14  be f2 61
	ldw hl, Combination_Current                                       ; FAAF17  33 20 76
	ldw wa, 0x76a0                                       ; FAAF1A  30 a0 76
	ld DE,WA                                             ; FAAF1D  d8 8a
	sub DE,HL                                            ; FAAF1F  db a2
	ldw wa, 0x7000                                       ; FAAF21  30 00 70
	add WA,DE                                            ; FAAF24  da 80
	extz XWA                                             ; FAAF26  e8 12
	ld XIX,XWA                                           ; FAAF28  e8 8c
	ldw bc, 0x7300                                       ; FAAF2A  31 00 73
	add BC,DE                                            ; FAAF2D  da 81
	extz XBC                                             ; FAAF2F  e9 12
	ld (xiz-4), xbc                                      ; FAAF31  be fc 61
.LFAAF34:
	lda xbc, (0x78a0:16)                                ; FAAF34  f1 a0 78 31
	ld (xiz-18), xbc                                     ; FAAF38  be ee 61
	ld xwa, (xiz-14)                                     ; FAAF3B  ae f2 20
	cp XWA,XBC                                           ; FAAF3E  e9 f0
	jr nc, .LFAAF63                                      ; FAAF40  6f 21
	ld xbc, (xiz-14)                                     ; FAAF42  ae f2 21
	ld A,(XBC)                                           ; FAAF45  81 21
	ld (XIX),A                                           ; FAAF47  b4 41
	ld xbc, (xiz-14)                                     ; FAAF49  ae f2 21
	ld A,(XBC)                                           ; FAAF4C  81 21
	ld H,A                                               ; FAAF4E  c9 8e
	ld xwa, (xiz-4)                                      ; FAAF50  ae fc 20
	ld (XWA),H                                           ; FAAF53  b0 46
	sub XBC,XBC                                          ; FAAF55  e9 a1
	inc 1,XBC                                            ; FAAF57  e9 61
	add (xiz-14), xbc                                    ; FAAF59  ae f2 89
	add XIX,XBC                                          ; FAAF5C  e9 84
	add (xiz-4), xbc                                     ; FAAF5E  ae fc 89
	jr .LFAAF34                                          ; FAAF61  68 d1
.LFAAF63:
	pushw 0x7f                                           ; FAAF63  0b 7f 00
	ld c, (0x76a3:16)                                   ; FAAF66  c1 a3 76 23
	pushw bc                                             ; FAAF6A  29
	pushw 0x01                                           ; FAAF6B  0b 01 00
	pushw 0x00                                           ; FAAF6E  0b 00 00
	call T_PendingEventQueue_AppendStackArgs                                        ; FAAF71  1d 18 1b f4
	pushw 0xff                                           ; FAAF75  0b ff 00
	ld c, (0x76a2:16)                                   ; FAAF78  c1 a2 76 23
	pushw bc                                             ; FAAF7C  29
	pushw 0x00                                           ; FAAF7D  0b 00 00
	pushw 0x00                                           ; FAAF80  0b 00 00
	call T_PendingEventQueue_AppendStackArgs                                        ; FAAF83  1d 18 1b f4
	inc 8,XSP                                            ; FAAF87  ef 60
	inc 8,XSP                                            ; FAAF89  ef 60
	pop XIX                                              ; FAAF8B  5c
	popw de                                              ; FAAF8C  4a
	popw hl                                              ; FAAF8D  4b
	unlk XIZ                                             ; FAAF8E  ee 0d
	ret                                                  ; FAAF90  0e
; ---------------------------------------------------------------------
; SystemSettings_ResetToDefault -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_b T_SystemSettings_ResetToDefault (`jp`)
;          prom_a sub_FB3C34 (`call` through T_SystemSettings_ResetToDefault) at 0xFB3DD7
;
;     0xFAAFCE loads 0xFAD38A, where the ROM reads:
;        "x`abc"
;     0xFAB031 loads 0xFAD38A, where the ROM reads:
;        "x`abc"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; SystemSettings_ResetToDefault: what INITIAL item 2 SYSTEM runs (screen and SysEx) (notes/FINDINGS-prom_a-initial.md)
SystemSettings_ResetToDefault:
	link XIZ,0xffe6                                      ; FAAF91  ee 0c e6 ff
	pushw hl                                             ; FAAF95  2b
	pushw de                                             ; FAAF96  2a
	push XIX                                             ; FAAF97  3c
	ld h, (0x7f4d:16)                                   ; FAAF98  c1 4d 7f 26
	ld C,H                                               ; FAAF9C  ce 8b
	and C,0x04                                           ; FAAF9E  cb cc 04
	jr z, .LFAAFC3                                       ; FAAFA1  66 20
	ld L,H                                               ; FAAFA3  ce 8f
	res 0x02,L                                           ; FAAFA5  cf 30 02
	ld (0x7f4d:16), l                                   ; FAAFA8  f1 4d 7f 47
	pushw 0x04                                           ; FAAFAC  0b 04 00
	pushw hl                                             ; FAAFAF  2b
	pushw 0x03                                           ; FAAFB0  0b 03 00
	pushw 0x91                                           ; FAAFB3  0b 91 00
	calr Queue2C00_Append4DrainWhenFull                                      ; FAAFB6  1e 07 fd
	set	5, (0x60f021:24)                             ; FAAFB9  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAAFBE  1e 5a fb
	inc 8,XSP                                            ; FAAFC1  ef 60
.LFAAFC3:
	ld h, 0x00:opc                                          ; FAAFC3  26 00
	ldw de, 0x00                                         ; FAAFC5  32 00 00
.LFAAFC8:
	ld C,H                                               ; FAAFC8  ce 8b
	extz BC                                              ; FAAFCA  d9 12
	extz XBC                                             ; FAAFCC  e9 12
	add XBC,ByteTable_FAD38A                             ; FAAFCE  e9 c8 8a d3 fa 00
	ld A,(XBC)                                           ; FAAFD4  81 21
	pushw wa                                             ; FAAFD6  28
	calr ParamNumber_GetRecordPtr                                          ; FAAFD7  1e d0 18
	ld XIX,XIY                                           ; FAAFDA  ed 8c
	ld BC,DE                                             ; FAAFDC  da 89
	extz XBC                                             ; FAAFDE  e9 12
	add XBC,PtrTable_FAD397                              ; FAAFE0  e9 c8 97 d3 fa 00
	ld XBC,(XBC)                                         ; FAAFE6  a1 21
	ld (xiz-8), xbc                                      ; FAAFE8  be f8 61
	ld l, 0x00:opc                                          ; FAAFEB  27 00
	inc 1,XBC                                            ; FAAFED  e9 61
	ld (xiz-12), xbc                                     ; FAAFEF  be f4 61
	sub XWA,XWA                                          ; FAAFF2  e8 a0
	inc 2,XWA                                            ; FAAFF4  e8 62
	ld (xiz-4), xwa                                      ; FAAFF6  be fc 60
	inc 2,XSP                                            ; FAAFF9  ef 62
.LFAAFFB:
	ld xbc, (xiz-12)                                     ; FAAFFB  ae f4 21
	ld A,(XBC)                                           ; FAAFFE  81 21
	cp L,A                                               ; FAB000  c9 f7
	jr nc, .LFAB02B                                      ; FAB002  6f 27
	ld xwa, (xiz-4)                                      ; FAB004  ae fc 20
	ld (xiz-24), xwa                                     ; FAB007  be e8 60
	add	xwa, (xiz-8)                                 ; FAB00A  ae f8 80
	ld C,(XWA)                                           ; FAB00D  80 23
	ld (xiz-26), c                                       ; FAB00F  be e6 43
	ld C,L                                               ; FAB012  cf 8b
	extz BC                                              ; FAB014  d9 12
	extz XBC                                             ; FAB016  e9 12
	add XBC,XIX                                          ; FAB018  ec 81
	ld w, (xiz-26)                                       ; FAB01A  8e e6 20
	ld (XBC),W                                           ; FAB01D  b1 40
	ld xbc, (xiz-24)                                     ; FAB01F  ae e8 21
	inc 1,XBC                                            ; FAB022  e9 61
	ld (xiz-4), xbc                                      ; FAB024  be fc 61
	inc 1,L                                              ; FAB027  cf 61
	jr .LFAAFFB                                          ; FAB029  68 d0
.LFAB02B:
	ld C,H                                               ; FAB02B  ce 8b
	extz BC                                              ; FAB02D  d9 12
	extz XBC                                             ; FAB02F  e9 12
	add XBC,ByteTable_FAD38A                             ; FAB031  e9 c8 8a d3 fa 00
	ld A,(XBC)                                           ; FAB037  81 21
	extz WA                                              ; FAB039  d8 12
	cp WA,0x0061                                         ; FAB03B  d8 cf 61 00
	jr z, .LFAB04F                                       ; FAB03F  66 0e
	cp WA,0x0062                                         ; FAB041  d8 cf 62 00
	jr z, .LFAB059                                       ; FAB045  66 12
	cp WA,0x0063                                         ; FAB047  d8 cf 63 00
	jr z, .LFAB063                                       ; FAB04B  66 16
	jr .LFAB070                                          ; FAB04D  68 21
.LFAB04F:
	ld c, (0x7642:16)                                   ; FAB04F  c1 42 76 23
	pushw bc                                             ; FAB053  29
	pushw 0x61                                           ; FAB054  0b 61 00
	jr .LFAB06B                                          ; FAB057  68 12
.LFAB059:
	ld c, (0x7662:16)                                   ; FAB059  c1 62 76 23
	pushw bc                                             ; FAB05D  29
	pushw 0x62                                           ; FAB05E  0b 62 00
	jr .LFAB06B                                          ; FAB061  68 08
.LFAB063:
	ld c, (0x7682:16)                                   ; FAB063  c1 82 76 23
	pushw bc                                             ; FAB067  29
	pushw 0x63                                           ; FAB068  0b 63 00
.LFAB06B:
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FAB06B  1d 58 2f f4
	pop XIY                                              ; FAB06F  5d
.LFAB070:
	ld XBC,XIX                                           ; FAB070  ec 89
	dec 2,XBC                                            ; FAB072  e9 6a
	push XBC                                             ; FAB074  39
	calr ParamImage_PostRecordAsChangeEvents                                      ; FAB075  1e 05 fc
	inc 4,DE                                             ; FAB078  da 64
	inc 1,H                                              ; FAB07A  ce 61
	pop XIY                                              ; FAB07C  5d
	cp H,0x0d                                            ; FAB07D  ce cf 0d
	jrl c, .LFAAFC8                                      ; FAB080  77 45 ff
	cp	(Variant_Flag:8), 0x02                               ; FAB083  c0 c4 3f 02
	jr nz, .LFAB0B4                                      ; FAB087  6e 2b
	ld (MidiCfg_InOutMode:16), 0x00                                 ; FAB089  f1 35 7f 00 00
	cp	(UI_ScreenLatch:16), 0x6a                            ; FAB08E  c1 7a 20 3f 6a
	jr nz, .LFAB09C                                      ; FAB093  6e 07
	ld (MidiCfg_InOutMode:16), 0x01                                 ; FAB095  f1 35 7f 00 01
	jr .LFAB0A0                                          ; FAB09A  68 04
.LFAB09C:
	set	1, (MidiCfg_InOutMode:16)                               ; FAB09C  f1 35 7f b9
.LFAB0A0:
	pushw 0xff                                           ; FAB0A0  0b ff 00
	push 0x00                                            ; FAB0A3  09 00
	push	(MidiCfg_InOutMode:16)                                  ; FAB0A5  c1 35 7f 04
	pushw 0x03                                           ; FAB0A9  0b 03 00
	pushw 0x80                                           ; FAB0AC  0b 80 00
	calr Queue2C00_Append4DrainWhenFull                                      ; FAB0AF  1e 0e fc
	inc 8,XSP                                            ; FAB0B2  ef 60
.LFAB0B4:
	res	0, (0x7fc2:16)                               ; FAB0B4  f1 c2 7f b0
	set	1, (0x7fc0:16)                               ; FAB0B8  f1 c0 7f b9
	and	(0x7fd6:16), 0xfc                            ; FAB0BC  c1 d6 7f 3c fc
	set	5, (0x60f021:24)                             ; FAB0C1  f2 21 f0 60 bd
	calr Queue2C00_DrainPassB_SaveRegs2                                      ; FAB0C6  1e 52 fa
	calr PartControllers_ResetAllParts                                      ; FAB0C9  1e 4d fc
	call Tempo_ApplyBpm                                      ; FAB0CC  1d 42 a7 fa
	lda xix, (Combination_Current:16)                                ; FAB0D0  f1 20 76 34
	lda xbc, (0x7000:16)                                ; FAB0D4  f1 00 70 31
	ld (xiz-16), xbc                                     ; FAB0D8  be f0 61
	lda xwa, (0x7300:16)                                ; FAB0DB  f1 00 73 30
	ld (xiz-20), xwa                                     ; FAB0DF  be ec 60
.LFAB0E2:
	lda xbc, (0x76a0:16)                                ; FAB0E2  f1 a0 76 31
	ld (xiz-24), xbc                                     ; FAB0E6  be e8 61
	ld XWA,XIX                                           ; FAB0E9  ec 88
	cp XWA,XBC                                           ; FAB0EB  e9 f0
	jr nc, .LFAB10F                                      ; FAB0ED  6f 20
	ld C,(XIX)                                           ; FAB0EF  84 23
	ld H,C                                               ; FAB0F1  cb 8e
	ld xbc, (xiz-16)                                     ; FAB0F3  ae f0 21
	ld (XBC),H                                           ; FAB0F6  b1 46
	ld C,(XIX)                                           ; FAB0F8  84 23
	ld H,C                                               ; FAB0FA  cb 8e
	ld xbc, (xiz-20)                                     ; FAB0FC  ae ec 21
	ld (XBC),H                                           ; FAB0FF  b1 46
	inc 1,XIX                                            ; FAB101  ec 61
	sub XBC,XBC                                          ; FAB103  e9 a1
	inc 1,XBC                                            ; FAB105  e9 61
	add (xiz-16), xbc                                    ; FAB107  ae f0 89
	add (xiz-20), xbc                                    ; FAB10A  ae ec 89
	jr .LFAB0E2                                          ; FAB10D  68 d3
.LFAB10F:
	lda xix, (0x78a0:16)                                ; FAB10F  f1 a0 78 34
	ldw hl, Combination_Current                                       ; FAB113  33 20 76
	ldw bc, 0x78a0                                       ; FAB116  31 a0 78
	ld DE,BC                                             ; FAB119  d9 8a
	sub DE,HL                                            ; FAB11B  db a2
	ldw bc, 0x7000                                       ; FAB11D  31 00 70
	add BC,DE                                            ; FAB120  da 81
	extz XBC                                             ; FAB122  e9 12
	ld (xiz-16), xbc                                     ; FAB124  be f0 61
	ldw wa, 0x7300                                       ; FAB127  30 00 73
	add WA,DE                                            ; FAB12A  da 80
	extz XWA                                             ; FAB12C  e8 12
	ld (xiz-20), xwa                                     ; FAB12E  be ec 60
.LFAB131:
	lda xbc, (0x78de:16)                                ; FAB131  f1 de 78 31
	ld (xiz-24), xbc                                     ; FAB135  be e8 61
	ld XWA,XIX                                           ; FAB138  ec 88
	cp XWA,XBC                                           ; FAB13A  e9 f0
	jr nc, .LFAB15E                                      ; FAB13C  6f 20
	ld C,(XIX)                                           ; FAB13E  84 23
	ld H,C                                               ; FAB140  cb 8e
	ld xbc, (xiz-16)                                     ; FAB142  ae f0 21
	ld (XBC),H                                           ; FAB145  b1 46
	ld C,(XIX)                                           ; FAB147  84 23
	ld H,C                                               ; FAB149  cb 8e
	ld xbc, (xiz-20)                                     ; FAB14B  ae ec 21
	ld (XBC),H                                           ; FAB14E  b1 46
	inc 1,XIX                                            ; FAB150  ec 61
	sub XBC,XBC                                          ; FAB152  e9 a1
	inc 1,XBC                                            ; FAB154  e9 61
	add (xiz-16), xbc                                    ; FAB156  ae f0 89
	add (xiz-20), xbc                                    ; FAB159  ae ec 89
	jr .LFAB131                                          ; FAB15C  68 d3
.LFAB15E:
	pop XIX                                              ; FAB15E  5c
	popw de                                              ; FAB15F  4a
	popw hl                                              ; FAB160  4b
	unlk XIZ                                             ; FAB161  ee 0d
	ret                                                  ; FAB163  0e
; ---------------------------------------------------------------------
; List2030_LoadRecord -- copy the list record at 0x2030 + (0x60F08C) into the
;          module's working cells and step the cursor over it.
; Called from: List2030_TranslateToQueue2C00 (`calr` at 0xFAB844).
; Body:    byte 0, the parameter NUMBER -> (0x60F080), and
;          ParamNumber_RecordPtrs[number] (via ParamNumber_GetRecordPtr) -> (0x60F084);
;          byte 1, the CLASS -> (0x60F088) and (0x60F081); byte 2, the
;          VALUE -> (0x60F089); byte 3, the MASK -> (0x60F08A); (0x60F082)
;          and (0x60F083) zeroed.  (0x60F080..0x60F083) is the staged record
;          Queue2C00_AppendStagedIfPending emits.
; Evidence: `ld H,(XBC+0x2030) / ld (0x60F080),H` at 0xFAB170-0xFAB175 and
;          three more `(XBC+0x2030)` loads at 0xFAB18C, 0xFAB1A5, 0xFAB1BD,
;          each after a cursor step.  (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
List2030_LoadRecord:
	push XHL                                             ; FAB164  3b
	push XDE                                             ; FAB165  3a
	push XIX                                             ; FAB166  3c
	lda xix, (0x60f08c:24)                               ; FAB167  f2 8c f0 60 34
	ld BC,(XIX)                                          ; FAB16C  94 21
	extz XBC                                             ; FAB16E  e9 12
	ld H,(XBC+0x2030)                                    ; FAB170  c3 e5 30 20 26
	ld (0x60f080:24), h                                 ; FAB175  f2 80 f0 60 46
	push 0x00                                            ; FAB17A  09 00
	push H                                               ; FAB17C  ce 04
	calr ParamNumber_GetRecordPtr                                          ; FAB17E  1e 29 17
	ld (0x60f084:24), xiy                               ; FAB181  f2 84 f0 60 65
	incw 0x01, (xix)                                     ; FAB186  94 61
	ld BC,(XIX)                                          ; FAB188  94 21
	extz XBC                                             ; FAB18A  e9 12
	ld H,(XBC+0x2030)                                    ; FAB18C  c3 e5 30 20 26
	ld (0x60f088:24), h                                 ; FAB191  f2 88 f0 60 46
	ld (0x60f081:24), h                                 ; FAB196  f2 81 f0 60 46
	ld BC,(XIX)                                          ; FAB19B  94 21
	ld HL,BC                                             ; FAB19D  d9 8b
	inc 1,HL                                             ; FAB19F  db 61
	ld (XIX),HL                                          ; FAB1A1  b4 53
	extz XHL                                             ; FAB1A3  eb 12
	ld C,(XHL+0x2030)                                    ; FAB1A5  c3 ed 30 20 23
	ld (0x60f089:24), c                                 ; FAB1AA  f2 89 f0 60 43
	ld (0x60f082:24), 0x00                             ; FAB1AF  f2 82 f0 60 00 00
	ld DE,HL                                             ; FAB1B5  db 8a
	inc 1,DE                                             ; FAB1B7  da 61
	ld (XIX),DE                                          ; FAB1B9  b4 52
	extz XDE                                             ; FAB1BB  ea 12
	ld C,(XDE+0x2030)                                    ; FAB1BD  c3 e9 30 20 23
	ld (0x60f08a:24), c                                 ; FAB1C2  f2 8a f0 60 43
	ld (0x60f083:24), 0x00                             ; FAB1C7  f2 83 f0 60 00 00
	ld BC,DE                                             ; FAB1CD  da 89
	inc 1,BC                                             ; FAB1CF  d9 61
	ld (XIX),BC                                          ; FAB1D1  b4 51
	popw bc                                              ; FAB1D3  49
	pop XIX                                              ; FAB1D4  5c
	pop XDE                                              ; FAB1D5  5a
	pop XHL                                              ; FAB1D6  5b
	ret                                                  ; FAB1D7  0e
; ParamRecord_LoadOldByte: (0x60F08B) = the current byte of the parameter record (ParamNumber_GetRecordPtr of (0x60F080)) at
;   the class offset (0x60F088) -- the "old byte" the List2030 dispatchers compare against; nothing when there is no record.
ParamRecord_LoadOldByte:
	link XIZ,0xfffc                                      ; FAB1D8  ee 0c fc ff
	push XIX                                             ; FAB1DC  3c
	push 0x00                                            ; FAB1DD  09 00
	push	(0x60f080:24)                                ; FAB1DF  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB1E4  1e c3 16
	ld XIX,XIY                                           ; FAB1E7  ed 8c
	sub XBC,XBC                                          ; FAB1E9  e9 a1
	dec 1,XBC                                            ; FAB1EB  e9 69
	ld (xiz-4), xbc                                      ; FAB1ED  be fc 61
	popw wa                                              ; FAB1F0  48
	cp XIY,XBC                                           ; FAB1F1  e9 f5
	jr z, .LFAB207                                       ; FAB1F3  66 12
	ld bc, (0x60f088:24)                                ; FAB1F5  d2 88 f0 60 21
	extz BC                                              ; FAB1FA  d9 12
	extz XBC                                             ; FAB1FC  e9 12
	add XBC,XIX                                          ; FAB1FE  ec 81
	ld A,(XBC)                                           ; FAB200  81 21
	ld (0x60f08b:24), a                                 ; FAB202  f2 8b f0 60 41
.LFAB207:
	pop XIX                                              ; FAB207  5c
	unlk XIZ                                             ; FAB208  ee 0d
	ret                                                  ; FAB20A  0e
; ---------------------------------------------------------------------
; Queue2C00_AppendStagedIfPending -- this module's byte-wise copy of
;          Queue2C00_PublishStagedIfPending: nothing if the staged mask
;          (0x60F083) is 0; otherwise drain the 0x2C00 queue when its cursor
;          (0x60F000) has reached 0x1FC, then Queue2C00_AppendStaged.
; Called from: 23 `calr` sites in this module, among them the fan-out
;          loop Queue2C00_FanOutToPartMask.
; Evidence: `cp (0x60F083),0` at 0xFAB20B, `cp (0x60F000),0x1FC` at 0xFAB213,
;          `call T_Queue2C00_DrainPassAB` at 0xFAB220.  (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
Queue2C00_AppendStagedIfPending:
	cp	(0x60f083:24), 0x00                          ; FAB20B  c2 83 f0 60 3f 00
	jr z, .LFAB232                                       ; FAB211  66 1f
	cpw	(0x60f000:24), 0x01fc                        ; FAB213  d2 00 f0 60 3f fc 01
	jr c, .LFAB22F                                       ; FAB21A  67 13
	push XDE                                             ; FAB21C  3a
	push XHL                                             ; FAB21D  3b
	push XIX                                             ; FAB21E  3c
	push XIZ                                             ; FAB21F  3e
	call T_Queue2C00_DrainPassAB                         ; FAB220  1d 18 00 f4
	pop XIZ                                              ; FAB224  5e
	pop XIX                                              ; FAB225  5c
	pop XHL                                              ; FAB226  5b
	pop XDE                                              ; FAB227  5a
	ldw (0x60f000:24), 0x00                             ; FAB228  f2 00 f0 60 02 00 00
.LFAB22F:
	calr Queue2C00_AppendStaged                                          ; FAB22F  1e 14 16
.LFAB232:
	ret                                                  ; FAB232  0e
; Queue2C00_AppendStagedDrainPassB: Appends the staged record (0x60F080..0x60F083) to the 0x2C00 queue
;   unconditionally; when the cursor (0x60F000) has reached 0x1FC it first drains with T_Queue2C00_DrainPassB (no pass
;   A) and restarts the cursor. Local twin of Queue2C00_PublishStagedDrainPassB, as Queue2C00_AppendStagedIfPending is
;   of the IfPending one. Caller: PartControllers_ResetAllParts x11. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
Queue2C00_AppendStagedDrainPassB:
	cpw	(0x60f000:24), 0x01fc                        ; FAB233  d2 00 f0 60 3f fc 01
	jr c, .LFAB24F                                       ; FAB23A  67 13
	push XDE                                             ; FAB23C  3a
	push XHL                                             ; FAB23D  3b
	push XIX                                             ; FAB23E  3c
	push XIZ                                             ; FAB23F  3e
	call T_Queue2C00_DrainPassB                          ; FAB240  1d 38 00 f4
	pop XIZ                                              ; FAB244  5e
	pop XIX                                              ; FAB245  5c
	pop XHL                                              ; FAB246  5b
	pop XDE                                              ; FAB247  5a
	ldw (0x60f000:24), 0x00                             ; FAB248  f2 00 f0 60 02 00 00
.LFAB24F:
	calr Queue2C00_AppendStaged                                          ; FAB24F  1e f4 15
	ret                                                  ; FAB252  0e
sub_FAB253:
	link XIZ,0xfffc                                      ; FAB253  ee 0c fc ff
	pushw hl                                             ; FAB257  2b
	push XIX                                             ; FAB258  3c
	ld C,(XIZ+0x08)                                      ; FAB259  8e 08 23
	and c, (0x60f08a:24)                              ; FAB25C  c2 8a f0 60 c3
	jr z, .LFAB2C2                                       ; FAB261  66 5f
	ld c, (0x60f08a:24)                                 ; FAB263  c2 8a f0 60 23
	and c, (0x60f089:24)                              ; FAB268  c2 89 f0 60 c3
	jr z, .LFAB2C2                                       ; FAB26D  66 53
	push 0x00                                            ; FAB26F  09 00
	push	(0x60f080:24)                                ; FAB271  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB276  1e 31 16
	ld XIX,XIY                                           ; FAB279  ed 8c
	sub XBC,XBC                                          ; FAB27B  e9 a1
	dec 1,XBC                                            ; FAB27D  e9 69
	ld (xiz-4), xbc                                      ; FAB27F  be fc 61
	popw wa                                              ; FAB282  48
	cp XIY,XBC                                           ; FAB283  e9 f5
	jr z, .LFAB2C2                                       ; FAB285  66 3b
	ld bc, (0x60f088:24)                                ; FAB287  d2 88 f0 60 21
	extz BC                                              ; FAB28C  d9 12
	extz XBC                                             ; FAB28E  e9 12
	add XIX,XBC                                          ; FAB290  e9 84
	ld c, (0x60f08a:24)                                 ; FAB292  c2 8a f0 60 23
	and c, (0x60f089:24)                              ; FAB297  c2 89 f0 60 c3
	xor (XIX),C                                          ; FAB29C  84 db
	ld C,(XIX)                                           ; FAB29E  84 23
	cp	c, (0x60f08b:24)                             ; FAB2A0  c2 8b f0 60 f3
	jr z, .LFAB2C2                                       ; FAB2A5  66 1b
	ld C,(XIX)                                           ; FAB2A7  84 23
	xor c, (0x60f08b:24)                              ; FAB2A9  c2 8b f0 60 d3
	and C,(XIZ+0x08)                                     ; FAB2AE  8e 08 c3
	or (0x60f083:24), c                               ; FAB2B1  c2 83 f0 60 eb
	ld H,(XIX)                                           ; FAB2B6  84 26
	ld (0x60f08b:24), h                                 ; FAB2B8  f2 8b f0 60 46
	ld (0x60f082:24), h                                 ; FAB2BD  f2 82 f0 60 46
.LFAB2C2:
	pop XIX                                              ; FAB2C2  5c
	popw hl                                              ; FAB2C3  4b
	unlk XIZ                                             ; FAB2C4  ee 0d
	ret                                                  ; FAB2C6  0e
	link XIZ,0xfffc                                      ; FAB2C7  ee 0c fc ff
	pushw hl                                             ; FAB2CB  2b
	pushw de                                             ; FAB2CC  2a
	push XIX                                             ; FAB2CD  3c
	ld L,(XIZ+0x08)                                      ; FAB2CE  8e 08 27
	ld C,L                                               ; FAB2D1  cf 8b
	and c, (0x60f08a:24)                              ; FAB2D3  c2 8a f0 60 c3
	jr z, .LFAB331                                       ; FAB2D8  66 57
	ld C,L                                               ; FAB2DA  cf 8b
	and c, (0x60f089:24)                              ; FAB2DC  c2 89 f0 60 c3
	jr z, .LFAB331                                       ; FAB2E1  66 4e
	push 0x00                                            ; FAB2E3  09 00
	push	(0x60f080:24)                                ; FAB2E5  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB2EA  1e bd 15
	ld XIX,XIY                                           ; FAB2ED  ed 8c
	sub XBC,XBC                                          ; FAB2EF  e9 a1
	dec 1,XBC                                            ; FAB2F1  e9 69
	ld (xiz-4), xbc                                      ; FAB2F3  be fc 61
	popw wa                                              ; FAB2F6  48
	cp XIY,XBC                                           ; FAB2F7  e9 f5
	jr z, .LFAB331                                       ; FAB2F9  66 36
	ld bc, (0x60f088:24)                                ; FAB2FB  d2 88 f0 60 21
	extz BC                                              ; FAB300  d9 12
	extz XBC                                             ; FAB302  e9 12
	add XIX,XBC                                          ; FAB304  e9 84
	ld C,L                                               ; FAB306  cf 8b
	cpl C                                                ; FAB308  cb 06
	ld D,C                                               ; FAB30A  cb 8c
	ld H,(XIX)                                           ; FAB30C  84 26
	and H,C                                              ; FAB30E  cb c6
	ld c, (0x60f089:24)                                 ; FAB310  c2 89 f0 60 23
	or H,C                                               ; FAB315  cb e6
	cp	h, (0x60f08b:24)                             ; FAB317  c2 8b f0 60 f6
	jr z, .LFAB331                                       ; FAB31C  66 13
	ld (XIX),H                                           ; FAB31E  b4 46
	ld (0x60f08b:24), h                                 ; FAB320  f2 8b f0 60 46
	ld (0x60f082:24), h                                 ; FAB325  f2 82 f0 60 46
	ld C,L                                               ; FAB32A  cf 8b
	or (0x60f083:24), c                               ; FAB32C  c2 83 f0 60 eb
.LFAB331:
	pop XIX                                              ; FAB331  5c
	popw de                                              ; FAB332  4a
	popw hl                                              ; FAB333  4b
	unlk XIZ                                             ; FAB334  ee 0d
	ret                                                  ; FAB336  0e
; ParamRecord_MergeFieldIfChanged(mask): when mask & (0x60F08A): byte = ParamNumber_RecordPtrs[(0x60F080)] + (0x60F088); new = (byte & ~mask) | (0x60F089);
;   unless new == (0x60F08B): store it, (0x60F08B) = (0x60F082) = new, (0x60F083) |= mask.  (Callers: the List2030_*_Apply family.)
ParamRecord_MergeFieldIfChanged:
	link XIZ,0xfffc                                      ; FAB337  ee 0c fc ff
	pushw hl                                             ; FAB33B  2b
	pushw de                                             ; FAB33C  2a
	push XIX                                             ; FAB33D  3c
	ld L,(XIZ+0x08)                                      ; FAB33E  8e 08 27
	ld C,L                                               ; FAB341  cf 8b
	and c, (0x60f08a:24)                              ; FAB343  c2 8a f0 60 c3
	jr z, .LFAB398                                       ; FAB348  66 4e
	push 0x00                                            ; FAB34A  09 00
	push	(0x60f080:24)                                ; FAB34C  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB351  1e 56 15
	ld XIX,XIY                                           ; FAB354  ed 8c
	sub XBC,XBC                                          ; FAB356  e9 a1
	dec 1,XBC                                            ; FAB358  e9 69
	ld (xiz-4), xbc                                      ; FAB35A  be fc 61
	popw wa                                              ; FAB35D  48
	cp XIY,XBC                                           ; FAB35E  e9 f5
	jr z, .LFAB398                                       ; FAB360  66 36
	ld bc, (0x60f088:24)                                ; FAB362  d2 88 f0 60 21
	extz BC                                              ; FAB367  d9 12
	extz XBC                                             ; FAB369  e9 12
	add XIX,XBC                                          ; FAB36B  e9 84
	ld C,L                                               ; FAB36D  cf 8b
	cpl C                                                ; FAB36F  cb 06
	ld D,C                                               ; FAB371  cb 8c
	ld H,(XIX)                                           ; FAB373  84 26
	and H,C                                              ; FAB375  cb c6
	ld c, (0x60f089:24)                                 ; FAB377  c2 89 f0 60 23
	or H,C                                               ; FAB37C  cb e6
	cp	h, (0x60f08b:24)                             ; FAB37E  c2 8b f0 60 f6
	jr z, .LFAB398                                       ; FAB383  66 13
	ld (XIX),H                                           ; FAB385  b4 46
	ld (0x60f08b:24), h                                 ; FAB387  f2 8b f0 60 46
	ld (0x60f082:24), h                                 ; FAB38C  f2 82 f0 60 46
	ld C,L                                               ; FAB391  cf 8b
	or (0x60f083:24), c                               ; FAB393  c2 83 f0 60 eb
.LFAB398:
	pop XIX                                              ; FAB398  5c
	popw de                                              ; FAB399  4a
	popw hl                                              ; FAB39A  4b
	unlk XIZ                                             ; FAB39B  ee 0d
	ret                                                  ; FAB39D  0e
	link XIZ,0xfffc                                      ; FAB39E  ee 0c fc ff
	pushw hl                                             ; FAB3A2  2b
	pushw de                                             ; FAB3A3  2a
	push XIX                                             ; FAB3A4  3c
	ld D,(XIZ+0x08)                                      ; FAB3A5  8e 08 24
	ld C,D                                               ; FAB3A8  cc 8b
	and c, (0x60f08a:24)                              ; FAB3AA  c2 8a f0 60 c3
	jr z, .LFAB40A                                       ; FAB3AF  66 59
	ld C,D                                               ; FAB3B1  cc 8b
	and c, (0x60f089:24)                              ; FAB3B3  c2 89 f0 60 c3
	jr z, .LFAB40A                                       ; FAB3B8  66 50
	push 0x00                                            ; FAB3BA  09 00
	push	(0x60f080:24)                                ; FAB3BC  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB3C1  1e e6 14
	ld XIX,XIY                                           ; FAB3C4  ed 8c
	sub XBC,XBC                                          ; FAB3C6  e9 a1
	dec 1,XBC                                            ; FAB3C8  e9 69
	ld (xiz-4), xbc                                      ; FAB3CA  be fc 61
	popw wa                                              ; FAB3CD  48
	cp XIY,XBC                                           ; FAB3CE  e9 f5
	jr z, .LFAB40A                                       ; FAB3D0  66 38
	ld bc, (0x60f088:24)                                ; FAB3D2  d2 88 f0 60 21
	extz BC                                              ; FAB3D7  d9 12
	extz XBC                                             ; FAB3D9  e9 12
	add XIX,XBC                                          ; FAB3DB  e9 84
	ld C,D                                               ; FAB3DD  cc 8b
	cpl C                                                ; FAB3DF  cb 06
	ld L,C                                               ; FAB3E1  cb 8f
	ld H,(XIX)                                           ; FAB3E3  84 26
	and H,C                                              ; FAB3E5  cb c6
	ld a, (0x60f089:24)                                 ; FAB3E7  c2 89 f0 60 21
	or H,A                                               ; FAB3EC  c9 e6
	cp	h, (0x60f08b:24)                             ; FAB3EE  c2 8b f0 60 f6
	jr nz, .LFAB3F7                                      ; FAB3F3  6e 02
	and H,C                                              ; FAB3F5  cb c6
.LFAB3F7:
	ld (XIX),H                                           ; FAB3F7  b4 46
	ld (0x60f08b:24), h                                 ; FAB3F9  f2 8b f0 60 46
	ld (0x60f082:24), h                                 ; FAB3FE  f2 82 f0 60 46
	ld C,D                                               ; FAB403  cc 8b
	or (0x60f083:24), c                               ; FAB405  c2 83 f0 60 eb
.LFAB40A:
	pop XIX                                              ; FAB40A  5c
	popw de                                              ; FAB40B  4a
	popw hl                                              ; FAB40C  4b
	unlk XIZ                                             ; FAB40D  ee 0d
	ret                                                  ; FAB40F  0e
sub_FAB410:
	link XIZ,0xfffc                                      ; FAB410  ee 0c fc ff
	pushw hl                                             ; FAB414  2b
	pushw de                                             ; FAB415  2a
	push XIX                                             ; FAB416  3c
	ld D,(XIZ+0x0a)                                      ; FAB417  8e 0a 24
	ld C,(XIZ+0x08)                                      ; FAB41A  8e 08 23
	and c, (0x60f08a:24)                              ; FAB41D  c2 8a f0 60 c3
	jrl z, .LFAB495                                      ; FAB422  76 70 00
	ld C,(XIZ+0x08)                                      ; FAB425  8e 08 23
	and c, (0x60f089:24)                              ; FAB428  c2 89 f0 60 c3
	jr z, .LFAB495                                       ; FAB42D  66 66
	push 0x00                                            ; FAB42F  09 00
	push	(0x60f080:24)                                ; FAB431  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB436  1e 71 14
	ld XIX,XIY                                           ; FAB439  ed 8c
	sub XBC,XBC                                          ; FAB43B  e9 a1
	dec 1,XBC                                            ; FAB43D  e9 69
	ld (xiz-4), xbc                                      ; FAB43F  be fc 61
	popw wa                                              ; FAB442  48
	cp XIY,XBC                                           ; FAB443  e9 f5
	jr z, .LFAB495                                       ; FAB445  66 4e
	ld bc, (0x60f088:24)                                ; FAB447  d2 88 f0 60 21
	extz BC                                              ; FAB44C  d9 12
	extz XBC                                             ; FAB44E  e9 12
	add XIX,XBC                                          ; FAB450  e9 84
	ld H,(XIX)                                           ; FAB452  84 26
	ld C,D                                               ; FAB454  cc 8b
	and H,C                                              ; FAB456  cb c6
	ld L,H                                               ; FAB458  ce 8f
	add l, (0x60f0b4:24)                              ; FAB45A  c2 b4 f0 60 87
	cp	l, (0x60f0b5:24)                             ; FAB45F  c2 b5 f0 60 f7
	jr nc, .LFAB46A                                      ; FAB464  6f 04
	ld H,L                                               ; FAB466  cf 8e
	jr .LFAB46F                                          ; FAB468  68 05
.LFAB46A:
	ld h, (0x60f0b6:24)                                 ; FAB46A  c2 b6 f0 60 26
.LFAB46F:
	ld C,D                                               ; FAB46F  cc 8b
	cpl C                                                ; FAB471  cb 06
	ld L,C                                               ; FAB473  cb 8f
	ld A,(XIX)                                           ; FAB475  84 21
	and C,A                                              ; FAB477  c9 c3
	or H,C                                               ; FAB479  cb e6
	cp	h, (0x60f08b:24)                             ; FAB47B  c2 8b f0 60 f6
	jr z, .LFAB495                                       ; FAB480  66 13
	ld (XIX),H                                           ; FAB482  b4 46
	ld (0x60f08b:24), h                                 ; FAB484  f2 8b f0 60 46
	ld (0x60f082:24), h                                 ; FAB489  f2 82 f0 60 46
	ld C,D                                               ; FAB48E  cc 8b
	or (0x60f083:24), c                               ; FAB490  c2 83 f0 60 eb
.LFAB495:
	pop XIX                                              ; FAB495  5c
	popw de                                              ; FAB496  4a
	popw hl                                              ; FAB497  4b
	unlk XIZ                                             ; FAB498  ee 0d
	ret                                                  ; FAB49A  0e
sub_FAB49B:
	link XIZ,0xfffc                                      ; FAB49B  ee 0c fc ff
	pushw hl                                             ; FAB49F  2b
	pushw de                                             ; FAB4A0  2a
	push XIX                                             ; FAB4A1  3c
	ld H,(XIZ+0x08)                                      ; FAB4A2  8e 08 26
	ld C,H                                               ; FAB4A5  ce 8b
	and c, (0x60f08a:24)                              ; FAB4A7  c2 8a f0 60 c3
	jr z, .LFAB4FE                                       ; FAB4AC  66 50
	push 0x00                                            ; FAB4AE  09 00
	push	(0x60f080:24)                                ; FAB4B0  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB4B5  1e f2 13
	ld XIX,XIY                                           ; FAB4B8  ed 8c
	sub XBC,XBC                                          ; FAB4BA  e9 a1
	dec 1,XBC                                            ; FAB4BC  e9 69
	ld (xiz-4), xbc                                      ; FAB4BE  be fc 61
	popw wa                                              ; FAB4C1  48
	cp XIY,XBC                                           ; FAB4C2  e9 f5
	jr z, .LFAB4FE                                       ; FAB4C4  66 38
	ld bc, (0x60f088:24)                                ; FAB4C6  d2 88 f0 60 21
	extz BC                                              ; FAB4CB  d9 12
	extz XBC                                             ; FAB4CD  e9 12
	add XBC,XIX                                          ; FAB4CF  ec 81
	ld (xiz-4), xbc                                      ; FAB4D1  be fc 61
	ld A,H                                               ; FAB4D4  ce 89
	cpl A                                                ; FAB4D6  c9 06
	ld L,A                                               ; FAB4D8  c9 8f
	ld W,(XBC)                                           ; FAB4DA  81 20
	ld D,W                                               ; FAB4DC  c8 8c
	and D,A                                              ; FAB4DE  c9 c4
	ld A,H                                               ; FAB4E0  ce 89
	and a, (0x60f089:24)                              ; FAB4E2  c2 89 f0 60 c1
	ld L,A                                               ; FAB4E7  c9 8f
	or L,D                                               ; FAB4E9  cc e7
	ld (XBC),L                                           ; FAB4EB  b1 47
	ld (0x60f08b:24), l                                 ; FAB4ED  f2 8b f0 60 47
	ld (0x60f082:24), l                                 ; FAB4F2  f2 82 f0 60 47
	ld C,H                                               ; FAB4F7  ce 8b
	or (0x60f083:24), c                               ; FAB4F9  c2 83 f0 60 eb
.LFAB4FE:
	pop XIX                                              ; FAB4FE  5c
	popw de                                              ; FAB4FF  4a
	popw hl                                              ; FAB500  4b
	unlk XIZ                                             ; FAB501  ee 0d
	ret                                                  ; FAB503  0e
	link XIZ,0xfffc                                      ; FAB504  ee 0c fc ff
	pushw hl                                             ; FAB508  2b
	pushw de                                             ; FAB509  2a
	push XIX                                             ; FAB50A  3c
	ld D,(XIZ+0x0e)                                      ; FAB50B  8e 0e 24
	cp d, 0x00:i3                                          ; FAB50E  cc d8
	jr z, .LFAB570                                       ; FAB510  66 5e
	push 0x00                                            ; FAB512  09 00
	push	(xiz+8)                                      ; FAB514  8e 08 04
	calr ParamNumber_GetRecordPtr                                          ; FAB517  1e 90 13
	ld XIX,XIY                                           ; FAB51A  ed 8c
	sub XBC,XBC                                          ; FAB51C  e9 a1
	dec 1,XBC                                            ; FAB51E  e9 69
	ld (xiz-4), xbc                                      ; FAB520  be fc 61
	popw wa                                              ; FAB523  48
	cp XIY,XBC                                           ; FAB524  e9 f5
	jr z, .LFAB570                                       ; FAB526  66 48
	ld BC,(XIZ+0x0a)                                     ; FAB528  9e 0a 21
	extz BC                                              ; FAB52B  d9 12
	extz XBC                                             ; FAB52D  e9 12
	add XIX,XBC                                          ; FAB52F  e9 84
	ld E,(XIX)                                           ; FAB531  84 25
	ld (0x60f08b:24), e                                 ; FAB533  f2 8b f0 60 45
	ld C,D                                               ; FAB538  cc 8b
	and C,(XIZ+0x0c)                                     ; FAB53A  8e 0c c3
	ld (xiz-2), c                                        ; FAB53D  be fe 43
	ld A,D                                               ; FAB540  cc 89
	cpl A                                                ; FAB542  c9 06
	ld H,A                                               ; FAB544  c9 8e
	and H,E                                              ; FAB546  cd c6
	or H,C                                               ; FAB548  cb e6
	ld L,E                                               ; FAB54A  cd 8f
	xor L,H                                              ; FAB54C  ce d7
	ld C,D                                               ; FAB54E  cc 8b
	and L,C                                              ; FAB550  cb c7
	jr z, .LFAB570                                       ; FAB552  66 1c
	ld (XIX),H                                           ; FAB554  b4 46
	ld C,(XIZ+0x08)                                      ; FAB556  8e 08 23
	ld (0x60f080:24), c                                 ; FAB559  f2 80 f0 60 43
	ld A,(XIZ+0x0a)                                      ; FAB55E  8e 0a 21
	ld (0x60f081:24), a                                 ; FAB561  f2 81 f0 60 41
	ld (0x60f082:24), h                                 ; FAB566  f2 82 f0 60 46
	ld (0x60f083:24), l                                 ; FAB56B  f2 83 f0 60 47
.LFAB570:
	pop XIX                                              ; FAB570  5c
	popw de                                              ; FAB571  4a
	popw hl                                              ; FAB572  4b
	unlk XIZ                                             ; FAB573  ee 0d
	ret                                                  ; FAB575  0e
	link XIZ,0xfff8                                      ; FAB576  ee 0c f8 ff
	pushw hl                                             ; FAB57A  2b
	pushw de                                             ; FAB57B  2a
	push XIX                                             ; FAB57C  3c
	ld L,(XIZ+0x0e)                                      ; FAB57D  8e 0e 27
	cp l, 0x00:i3                                          ; FAB580  cf d8
	jr z, .LFAB5E3                                       ; FAB582  66 5f
	push 0x00                                            ; FAB584  09 00
	push	(xiz+8)                                      ; FAB586  8e 08 04
	calr ParamNumber_GetRecordPtr                                          ; FAB589  1e 1e 13
	ld XIX,XIY                                           ; FAB58C  ed 8c
	sub XBC,XBC                                          ; FAB58E  e9 a1
	dec 1,XBC                                            ; FAB590  e9 69
	ld (xiz-8), xbc                                      ; FAB592  be f8 61
	popw wa                                              ; FAB595  48
	cp XIY,XBC                                           ; FAB596  e9 f5
	jr z, .LFAB5E3                                       ; FAB598  66 49
	ld BC,(XIZ+0x0a)                                     ; FAB59A  9e 0a 21
	extz BC                                              ; FAB59D  d9 12
	extz XBC                                             ; FAB59F  e9 12
	ld (xiz-8), xbc                                      ; FAB5A1  be f8 61
	add XIX,XBC                                          ; FAB5A4  e9 84
	add XBC,XIX                                          ; FAB5A6  ec 81
	ld (xiz-4), xbc                                      ; FAB5A8  be fc 61
	ld D,(XBC)                                           ; FAB5AB  81 24
	ld (0x60f08b:24), d                                 ; FAB5AD  f2 8b f0 60 44
	ld E,L                                               ; FAB5B2  cf 8d
	and E,(XIZ+0x0c)                                     ; FAB5B4  8e 0c c5
	ld A,L                                               ; FAB5B7  cf 89
	cpl A                                                ; FAB5B9  c9 06
	ld H,A                                               ; FAB5BB  c9 8e
	and H,D                                              ; FAB5BD  cc c6
	ld A,E                                               ; FAB5BF  cd 89
	or H,A                                               ; FAB5C1  c9 e6
	cp H,D                                               ; FAB5C3  cc f6
	jr z, .LFAB5E3                                       ; FAB5C5  66 1c
	ld (XBC),H                                           ; FAB5C7  b1 46
	ld C,(XIZ+0x08)                                      ; FAB5C9  8e 08 23
	ld (0x60f080:24), c                                 ; FAB5CC  f2 80 f0 60 43
	ld A,(XIZ+0x0a)                                      ; FAB5D1  8e 0a 21
	ld (0x60f081:24), a                                 ; FAB5D4  f2 81 f0 60 41
	ld (0x60f082:24), h                                 ; FAB5D9  f2 82 f0 60 46
	ld (0x60f083:24), l                                 ; FAB5DE  f2 83 f0 60 47
.LFAB5E3:
	pop XIX                                              ; FAB5E3  5c
	popw de                                              ; FAB5E4  4a
	popw hl                                              ; FAB5E5  4b
	unlk XIZ                                             ; FAB5E6  ee 0d
	ret                                                  ; FAB5E8  0e
T_F407A8_Nop:
	ret                                                  ; FAB5E9  0e
T_F407A0_Nop:
	ret                                                  ; FAB5EA  0e
; ParamB0_PublishPendingFields: The two-field ParamB0_PublishField0IfPending: for field 0 ((0x24F1)) and field 1
;   ((0x24F0)) whose bit 7 (pending) is set, clears the bit and queues {0xB0, field, value, 0x7F} through
;   Queue2C00_AppendStagedIfPending. List2030_ParamB0_Apply runs it after marking (0x24F1) pending;
;   Seq_PublishPendingParamB0 at rewind / stop. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
ParamB0_PublishPendingFields:
	push XIX                                             ; FAB5EB  3c
	lda xix, (0x24f0:16)                                ; FAB5EC  f1 f0 24 34
	ld c, (0x24f1:16)                                   ; FAB5F0  c1 f1 24 23
	and C,0x80                                           ; FAB5F4  cb cc 80
	jr z, .LFAB61B                                       ; FAB5F7  66 22
	res	7, (0x24f1:16)                               ; FAB5F9  f1 f1 24 b7
	ld (0x60f080:24), 0xb0                             ; FAB5FD  f2 80 f0 60 00 b0
	ld (0x60f081:24), 0x00                             ; FAB603  f2 81 f0 60 00 00
	ld c, (0x24f1:16)                                   ; FAB609  c1 f1 24 23
	ld (0x60f082:24), c                                 ; FAB60D  f2 82 f0 60 43
	ld (0x60f083:24), 0x7f                             ; FAB612  f2 83 f0 60 00 7f
	calr Queue2C00_AppendStagedIfPending                                      ; FAB618  1e f0 fb
.LFAB61B:
	ld C,(XIX)                                           ; FAB61B  84 23
	and C,0x80                                           ; FAB61D  cb cc 80
	jr z, .LFAB641                                       ; FAB620  66 1f
	and (XIX),0x7f                                       ; FAB622  84 3c 7f
	ld (0x60f080:24), 0xb0                             ; FAB625  f2 80 f0 60 00 b0
	ld (0x60f081:24), 0x01                             ; FAB62B  f2 81 f0 60 00 01
	ld C,(XIX)                                           ; FAB631  84 23
	ld (0x60f082:24), c                                 ; FAB633  f2 82 f0 60 43
	ld (0x60f083:24), 0x7f                             ; FAB638  f2 83 f0 60 00 7f
	calr Queue2C00_AppendStagedIfPending                                      ; FAB63E  1e ca fb
.LFAB641:
	pop XIX                                              ; FAB641  5c
	ret                                                  ; FAB642  0e
; ProgramChangeMode_OnEvent: T_ProgramChangeMode_OnEvent, UiListB_Class80: byte 0 of the MIDI system record with PROGRAM CHANGE MODE's bits (mask 0x03) changed:
;   calls T_F407C4_Nop, a bare ret.
ProgramChangeMode_OnEvent:
	cp	(UiEvent_Byte1:16), 0x00                            ; FAB643  c1 b8 20 3f 00
	jr nz, .LFAB656                                      ; FAB648  6e 0c
	ld c, (UiEvent_Byte3:16)                                   ; FAB64A  c1 ba 20 23
; (sub_FAB64E removed 2026-10-04: no code names it and the line above falls through into it -- part of ProgramChangeMode_OnEvent;
;  notes/prom_a_stray_label_removal.py)
	and C,0x03                                           ; FAB64E  cb cc 03
	jr z, .LFAB656                                       ; FAB651  66 03
	calr T_F407C4_Nop                                      ; FAB653  1e 01 00
.LFAB656:
	ret                                                  ; FAB656  0e
T_F407C4_Nop:
	ret                                                  ; FAB657  0e
; SoundSel_ClampToProgramAndBank: T_SoundSel_ClampToProgramAndBank entry: clamps the request at 0x60F160 (group <= 15, member <= the group
;   maximum) and converts it with T_SoundSel_ToProgramAndBank into (0x60F164)/(0x60F165). SoundName_CopyToBuffer and
;   the SOUND COPY / RE-MAP requests call it first. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_a.json)
SoundSel_ClampToProgramAndBank:
	pushw hl                                             ; FAB658  2b
	push XIX                                             ; FAB659  3c
	lda xix, (0x60f160:24)                               ; FAB65A  f2 60 f1 60 34
	cp	(0x60f01c:24), 0x1f                          ; FAB65F  c2 1c f0 60 3f 1f
	jr ugt, .LFAB6D4                                     ; FAB665  6b 6d
	ld bc, (0x60f01c:24)                                ; FAB667  d2 1c f0 60 21
	extz BC                                              ; FAB66C  d9 12
	extz XBC                                             ; FAB66E  e9 12
	add XBC,Bytes_0F_FAD3CB                              ; FAB670  e9 c8 cb d3 fa 00
	ld H,(XBC)                                           ; FAB676  81 26
	ld A,(XIX)                                           ; FAB678  84 21
	cp A,H                                               ; FAB67A  ce f1
	jr ule, .LFAB681                                     ; FAB67C  63 03
	ld (XIX),0x00                                        ; FAB67E  b4 00 00
.LFAB681:
	call SoundSel_StoreRequestGroupMaxMember                                      ; FAB681  1d e7 a7 fa
	ld C,(XIX+0x01)                                      ; FAB685  8c 01 23
	cp	c, (0x60f176:24)                             ; FAB688  c2 76 f1 60 f3
	jr ule, .LFAB693                                     ; FAB68D  63 04
	ld (XIX+0x01),0x00                                   ; FAB68F  bc 01 00 00
.LFAB693:
	ld C,(XIX)                                           ; FAB693  84 23
	ld (SoundConv_Arg0:24), c                                 ; FAB695  f2 10 f0 60 43
	ld C,(XIX+0x01)                                      ; FAB69A  8c 01 23
	ld (SoundConv_Arg1:24), c                                 ; FAB69D  f2 11 f0 60 43
	ld c, (0x60f01c:24)                                 ; FAB6A2  c2 1c f0 60 23
	ld (SoundConv_Arg2:24), c                                 ; FAB6A7  f2 12 f0 60 43
	ld C,(XIX+0x02)                                      ; FAB6AC  8c 02 23
	ld (SoundConv_Arg3:24), c                                 ; FAB6AF  f2 13 f0 60 43
	push XDE                                             ; FAB6B4  3a
	push XHL                                             ; FAB6B5  3b
	push XIX                                             ; FAB6B6  3c
	push XIZ                                             ; FAB6B7  3e
	call T_SoundSel_ToProgramAndBank                                        ; FAB6B8  1d fc 0f f4
	pop XIZ                                              ; FAB6BC  5e
	pop XIX                                              ; FAB6BD  5c
	pop XHL                                              ; FAB6BE  5b
	pop XDE                                              ; FAB6BF  5a
	ld c, (SoundConv_Result0:24)                                 ; FAB6C0  c2 14 f0 60 23
	ld (0x60f164:24), c                                 ; FAB6C5  f2 64 f1 60 43
	ld c, (SoundConv_Result1:24)                                 ; FAB6CA  c2 15 f0 60 23
	ld (0x60f165:24), c                                 ; FAB6CF  f2 65 f1 60 43
.LFAB6D4:
	pop XIX                                              ; FAB6D4  5c
	popw hl                                              ; FAB6D5  4b
	ret                                                  ; FAB6D6  0e
; SoundSel_GroupMemberFromProgramAndBank: When the part (0x60F01D) <= 0x1F: converts program (0x60F168) and bank
;   (0x60F169) with T_SoundSel_FromProgramAndBank into group / member / bank code at (0x60F16C..0x60F16E). Memory form
;   called by SoundSel_FromProgramAndBankRegs; the SOUND twin of CombiSel_GroupMemberFromNumberAndBank. Basis: caller
;   + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
SoundSel_GroupMemberFromProgramAndBank:
	push XIX                                             ; FAB6D7  3c
	lda xix, (0x60f16c:24)                               ; FAB6D8  f2 6c f1 60 34
	cp	(0x60f01d:24), 0x1f                          ; FAB6DD  c2 1d f0 60 3f 1f
	jr ugt, .LFAB726                                     ; FAB6E3  6b 41
	ld c, (0x60f168:24)                                 ; FAB6E5  c2 68 f1 60 23
	ld (SoundConv_Arg0:24), c                                 ; FAB6EA  f2 10 f0 60 43
	ld c, (0x60f169:24)                                 ; FAB6EF  c2 69 f1 60 23
	ld (SoundConv_Arg1:24), c                                 ; FAB6F4  f2 11 f0 60 43
	ld c, (0x60f01d:24)                                 ; FAB6F9  c2 1d f0 60 23
	ld (SoundConv_Arg2:24), c                                 ; FAB6FE  f2 12 f0 60 43
	push XDE                                             ; FAB703  3a
	push XHL                                             ; FAB704  3b
	push XIX                                             ; FAB705  3c
	push XIZ                                             ; FAB706  3e
	call T_SoundSel_FromProgramAndBank                                        ; FAB707  1d 00 10 f4
	pop XIZ                                              ; FAB70B  5e
	pop XIX                                              ; FAB70C  5c
	pop XHL                                              ; FAB70D  5b
	pop XDE                                              ; FAB70E  5a
	ld c, (SoundConv_Result0:24)                                 ; FAB70F  c2 14 f0 60 23
	ld (XIX),C                                           ; FAB714  b4 43
	ld c, (SoundConv_Result1:24)                                 ; FAB716  c2 15 f0 60 23
	ld (XIX+0x01),C                                      ; FAB71B  bc 01 43
	ld c, (SoundConv_Result2:24)                                 ; FAB71E  c2 16 f0 60 23
	ld (XIX+0x02),C                                      ; FAB723  bc 02 43
.LFAB726:
	pop XIX                                              ; FAB726  5c
	ret                                                  ; FAB727  0e
; CombiSel_GroupMemberFromNumberAndBank: When (0x60F180) = 0x98: converts the combination number and bank at
;   (0x60F189)/(0x60F18A) with T_CombiSel_FromNumberAndBank into group / member / bank code at (0x60F18D..0x60F18F);
;   the combination twin of SoundSel_GroupMemberFromProgramAndBank (SoundSel_FromProgramAndBankRegs' memory form). The SysEx setters of
;   COMBINATION NUMBER and BANK and of COMBINATION WRITE REQUEST fill the inputs, call it through T_CombiSel_GroupMemberFromNumberAndBank and store
;   (0x60F18D)/(0x60F18E) as fields 6/7 of record 0x98. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
CombiSel_GroupMemberFromNumberAndBank:
	push XIX                                             ; FAB728  3c
	lda xix, (0x60f18d:24)                               ; FAB729  f2 8d f1 60 34
	cp	(0x60f180:24), 0x98                          ; FAB72E  c2 80 f1 60 3f 98
	jr nz, .LFAB777                                      ; FAB734  6e 41
	ld c, (0x60f189:24)                                 ; FAB736  c2 89 f1 60 23
	ld (SoundConv_Arg0:24), c                                 ; FAB73B  f2 10 f0 60 43
	ld c, (0x60f18a:24)                                 ; FAB740  c2 8a f1 60 23
	ld (SoundConv_Arg1:24), c                                 ; FAB745  f2 11 f0 60 43
	ld c, (0x60f180:24)                                 ; FAB74A  c2 80 f1 60 23
	ld (SoundConv_Arg2:24), c                                 ; FAB74F  f2 12 f0 60 43
	push XDE                                             ; FAB754  3a
	push XHL                                             ; FAB755  3b
	push XIX                                             ; FAB756  3c
	push XIZ                                             ; FAB757  3e
	call T_CombiSel_FromNumberAndBank                                        ; FAB758  1d 28 10 f4
	pop XIZ                                              ; FAB75C  5e
	pop XIX                                              ; FAB75D  5c
	pop XHL                                              ; FAB75E  5b
	pop XDE                                              ; FAB75F  5a
	ld c, (SoundConv_Result0:24)                                 ; FAB760  c2 14 f0 60 23
	ld (XIX),C                                           ; FAB765  b4 43
	ld c, (SoundConv_Result1:24)                                 ; FAB767  c2 15 f0 60 23
	ld (XIX+0x01),C                                      ; FAB76C  bc 01 43
	ld c, (SoundConv_Result2:24)                                 ; FAB76F  c2 16 f0 60 23
	ld (XIX+0x02),C                                      ; FAB774  bc 02 43
.LFAB777:
	pop XIX                                              ; FAB777  5c
	ret                                                  ; FAB778  0e
; CombiSel_ClampToNumberAndBank: T_CombiSel_ClampToNumberAndBank entry, the combination twin: when (0x60F17F) = 0x98, clamps 0x60F181/182 and
;   converts with T_CombiSel_ToNumberAndBank into (0x60F185)/(0x60F186). CombiName_CopyToBuffer,
;   CombinationCopy_RefreshIfCurrentCombi and ReMapEdit call it. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_a.json)
CombiSel_ClampToNumberAndBank:
	push XIX                                             ; FAB779  3c
	lda xix, (0x60f181:24)                               ; FAB77A  f2 81 f1 60 34
	cp	(0x60f17f:24), 0x98                          ; FAB77F  c2 7f f1 60 3f 98
	jr nz, .LFAB7E4                                      ; FAB785  6e 5d
	ld C,(XIX)                                           ; FAB787  84 23
	cp C,0x0f                                            ; FAB789  cb cf 0f
	jr ule, .LFAB791                                     ; FAB78C  63 03
	ld (XIX),0x00                                        ; FAB78E  b4 00 00
.LFAB791:
	call CombiSel_StoreRequestGroupMaxMember                                      ; FAB791  1d 08 a8 fa
	ld C,(XIX+0x01)                                      ; FAB795  8c 01 23
	cp	c, (0x60f176:24)                             ; FAB798  c2 76 f1 60 f3
	jr ule, .LFAB7A3                                     ; FAB79D  63 04
	ld (XIX+0x01),0x00                                   ; FAB79F  bc 01 00 00
.LFAB7A3:
	ld C,(XIX)                                           ; FAB7A3  84 23
	ld (SoundConv_Arg0:24), c                                 ; FAB7A5  f2 10 f0 60 43
	ld C,(XIX+0x01)                                      ; FAB7AA  8c 01 23
	ld (SoundConv_Arg1:24), c                                 ; FAB7AD  f2 11 f0 60 43
	ld c, (0x60f17f:24)                                 ; FAB7B2  c2 7f f1 60 23
	ld (SoundConv_Arg2:24), c                                 ; FAB7B7  f2 12 f0 60 43
	ld C,(XIX+0x02)                                      ; FAB7BC  8c 02 23
	ld (SoundConv_Arg3:24), c                                 ; FAB7BF  f2 13 f0 60 43
	push XDE                                             ; FAB7C4  3a
	push XHL                                             ; FAB7C5  3b
	push XIX                                             ; FAB7C6  3c
	push XIZ                                             ; FAB7C7  3e
	call T_CombiSel_ToNumberAndBank                                        ; FAB7C8  1d 24 10 f4
	pop XIZ                                              ; FAB7CC  5e
	pop XIX                                              ; FAB7CD  5c
	pop XHL                                              ; FAB7CE  5b
	pop XDE                                              ; FAB7CF  5a
	ld c, (SoundConv_Result0:24)                                 ; FAB7D0  c2 14 f0 60 23
	ld (0x60f185:24), c                                 ; FAB7D5  f2 85 f1 60 43
	ld c, (SoundConv_Result1:24)                                 ; FAB7DA  c2 15 f0 60 23
	ld (0x60f186:24), c                                 ; FAB7DF  f2 86 f1 60 43
.LFAB7E4:
	pop XIX                                              ; FAB7E4  5c
	ret                                                  ; FAB7E5  0e
; List2030_ProcessEvents: When the 0x2030 event list is not empty: clears (0x60F0C6) bit 0, points IndexedTable_Base
;   at ParamNumber_RecordPtrs, List2030_TranslateToQueue2C00, then hands the new queue records to SeqBuf_PickRecordPartMask
;   (T_F41F30), SeqBuf_EncodeQueue2C00, Evt2030_RunList and SysExTx_EmitStagedParams, and clears (0x60F020) bit 1.
;   Called (T_List2030_ProcessEvents) by MainTask_RunUiPassC just before it empties the list. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
List2030_ProcessEvents:
	ld c, (0x2030:16)                                   ; FAB7E6  c1 30 20 23
	cp C,0xff                                            ; FAB7EA  cb cf ff
	jr z, .LFAB81E                                       ; FAB7ED  66 2f
	res	0, (0x60f0c6:24)                             ; FAB7EF  f2 c6 f0 60 b0
	lda xbc, (ParamNumber_RecordPtrs:24)                 ; FAB7F4  f2 ea cd fa 31
; (sub_FAB7F9 removed 2026-10-04: no code names it and the line above falls through into it -- part of List2030_ProcessEvents;
;  notes/prom_a_stray_label_removal.py)
	ld (IndexedTable_Base:24), xbc                               ; FAB7F9  f2 18 f0 60 61
	calr List2030_TranslateToQueue2C00                                      ; FAB7FE  1e 1e 00
	push XDE                                             ; FAB801  3a
	push XHL                                             ; FAB802  3b
	push XIX                                             ; FAB803  3c
	push XIZ                                             ; FAB804  3e
	call T_F41F30                                        ; FAB805  1d 30 1f f4
	call T_F41F34                                        ; FAB809  1d 34 1f f4
	call T_Evt2030_RunList                                        ; FAB80D  1d 50 08 f4
	call T_SysExTx_EmitStagedParams                                        ; FAB811  1d 00 09 f4
	pop XIZ                                              ; FAB815  5e
	pop XIX                                              ; FAB816  5c
	pop XHL                                              ; FAB817  5b
	pop XDE                                              ; FAB818  5a
	res	1, (0x60f020:24)                             ; FAB819  f2 20 f0 60 b1
.LFAB81E:
	ret                                                  ; FAB81E  0e
; ---------------------------------------------------------------------
; List2030_TranslateToQueue2C00 -- turn each record of the 0xFF-terminated
;          4-byte list at RAM 0x2030 into records of the queue at RAM 0x2C00,
;          dispatching on the record's parameter NUMBER.
; Called from: List2030_ProcessEvents (`calr` at 0xFAB7FE), which first checks (0x2030)
;          is not 0xFF and sets (0x60F018) = ParamNumber_RecordPtrs.
; Body:    (0x60F08C) = 0 is the list cursor.  Per record: stop on 0xFF;
;          List2030_LoadRecord; `ld C,4 / mul BC,(0x60F080)` and call
;          Dispatch_By_60F080[number] with 0xFAB860 pushed as its return.
;          Whenever the queue cursor (0x60F000) has reached 0x1FC the queue
;          is drained (T_Queue2C00_DrainPassAB) and (0x60F002) zeroed.  At
;          the end bit 4 of (0x60F021) is cleared, 0xFF is written at
;          0x2C00 + (0x60F000) and (0x60F01E) = 0x7F.
; (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
List2030_TranslateToQueue2C00:
	push XIX                                             ; FAB81F  3c
	lda xix, (0x60f000:24)                               ; FAB820  f2 00 f0 60 34
	ldw (0x60f08c:24), 0x00                             ; FAB825  f2 8c f0 60 02 00 00
	ld BC,(XIX)                                          ; FAB82C  94 21
	ld (0x60f002:24), bc                                ; FAB82E  f2 02 f0 60 51
.LFAB833:
	ld bc, (0x60f08c:24)                                ; FAB833  d2 8c f0 60 21
	extz XBC                                             ; FAB838  e9 12
	ld A,(XBC+0x2030)                                    ; FAB83A  c3 e5 30 20 21
	cp A,0xff                                            ; FAB83F  c9 cf ff
	jr z, .LFAB87D                                       ; FAB842  66 39
	calr List2030_LoadRecord                                      ; FAB844  1e 1d f9
	ld c, 0x04:opc                                          ; FAB847  23 04
	mul	bc, (0x60f080:24)                            ; FAB849  c2 80 f0 60 43
	extz XBC                                             ; FAB84E  e9 12
	add XBC,Dispatch_By_60F080                           ; FAB850  e9 c8 ea c8 fa 00
	ld XBC,(XBC)                                         ; FAB856  a1 21
	lda xiy, (.LFAB860:24)                               ; FAB858  f2 60 b8 fa 35
	push XIY                                             ; FAB85D  3d
	jp (xbc)                                             ; FAB85E  b1 d8
.LFAB860:
	ld BC,(XIX)                                          ; FAB860  94 21
	cp BC,0x01fc                                         ; FAB862  d9 cf fc 01
	jr c, .LFAB833                                       ; FAB866  67 cb
	push XDE                                             ; FAB868  3a
	push XHL                                             ; FAB869  3b
	push XIX                                             ; FAB86A  3c
	push XIZ                                             ; FAB86B  3e
	call T_Queue2C00_DrainPassAB                         ; FAB86C  1d 18 00 f4
	pop XIZ                                              ; FAB870  5e
	pop XIX                                              ; FAB871  5c
	pop XHL                                              ; FAB872  5b
	pop XDE                                              ; FAB873  5a
	ldw (0x60f002:24), 0x00                             ; FAB874  f2 02 f0 60 02 00 00
	jr .LFAB833                                          ; FAB87B  68 b6
.LFAB87D:
	res	4, (0x60f021:24)                             ; FAB87D  f2 21 f0 60 b4
	ld BC,(XIX)                                          ; FAB882  94 21
	extz XBC                                             ; FAB884  e9 12
	ld (XBC+0x2c00),0xff                                 ; FAB886  f3 e5 00 2c 00 ff
	ld (0x60f01e:24), 0x7f                             ; FAB88C  f2 1e f0 60 00 7f
	pop XIX                                              ; FAB892  5c
	ret                                                  ; FAB893  0e
; List2030_Part00to1F_Dispatch: the 0x2030-list handler for parameter numbers 0x00-0x1F (Dispatch_By_60F080 entries 0-31: the
;   number is the part): dispatches again on the record's CLASS (0x60F088) through List2030_PartFieldHandlers -- the sibling of
;   List2030_Part20to3F_Dispatch (Dispatch_By_60F080's own header).
List2030_Part00to1F_Dispatch:   ; entry: named by 32 `.long` operands, first at 0xFAC8EA
	calr ParamRecord_LoadOldByte                                      ; FAB894  1e 41 f9
	ld bc, (0x60f088:24)                                ; FAB897  d2 88 f0 60 21
	extz BC                                              ; FAB89C  d9 12
	extz XBC                                             ; FAB89E  e9 12
	cp BC,0x000b                                         ; FAB8A0  d9 cf 0b 00
	jrl ugt, .LFAB914                                        ; FAB8A4  7b 6d 00
	sll bc, 0x02                                         ; FAB8A7  d9 ee 02
	add XBC,List2030_PartFieldHandlers                             ; FAB8AA  e9 c8 b4 b8 fa 00
; ---------------------------------------------------------------------
; the reader of List2030_PartFieldHandlers
;
; Called from: this is not a routine entry; it is the tail of the code that
;          begins at 0xFAB894.  No site names 0xFAB8B0 -- it carries a label
;          only because notes/gen_prom_a_block.py labels every address some
;          opcode-anchored scan names, and that scan's `jr` rows are mostly
;          coincidence.
; Inputs:  (0x60F088), an 8-bit selector, zero-extended into BC.
; Outputs: control transfers to List2030_PartFieldHandlers[selector]; selectors above
;          0x0B take the `jrl UGT,0xFAB914` two instructions earlier.
; Evidence: `cp BC,0x000b` at 0xFAB8A0 then `sll 0x02,BC`, `add XBC,0x00FAB8B4`,
;          `ld XBC,(XBC)`, `jp T,XBC`.
; ---------------------------------------------------------------------
; (sub_FAB8B0 removed 2026-10-04: no code names it and the line above falls through into it -- part of List2030_Part00to1F_Dispatch;
;  notes/prom_a_stray_label_removal.py)
	ld XBC,(XBC)                                         ; FAB8B0  a1 21
	jp (xbc)                                             ; FAB8B2  b1 d8
; ---------------------------------------------------------------------
; List2030_PartFieldHandlers -- 12 LE32 branch targets
;
; Read by: ONE site, the `add XBC,0x00FAB8B4 / ld XBC,(XBC) / jp T,XBC` at
;          0xFAB8AA-0xFAB8B2.  Nothing calls a table.
; Inputs:  BC = selector * 4, selector = (0x60F088).
; ENTRY COUNT 12, and how it is established: the reader's OWN `cp BC,0x000b`
;          at 0xFAB8A0 -- 0x0B is the last index it lets through, so 12 entries.
;          Not counted by eye.  ★ LAST-ENTRY TEST: 0xFAB8B4 + 12*4 = 0xFAB8E4,
;          which is where the linear decode resynchronises; 11 or 13 entries
;          land at 0xFAB8E0 or 0xFAB8E8 and neither is an instruction boundary.
;          Re-derived by notes/prom_a_jumptables.py.
; Selector: (0x60F088) is byte 1, the CLASS, of the list record
;          (List2030_LoadRecord), and for numbers 0x00-0x1F the class names
;          the part attribute: MidiOut_ParamClassTable, indexed by the same
;          class, is 0 MidiOut_ProgramChange, 3 MidiOut_CC07_Volume, 5/6/7 the
;          effect depths, 8 MidiOut_CC0A_Pan, 9-11 the three RPN tunings,
;          and the MIDI-in tables confirm classes 3, 5, 6, 7 and 8.
; ★ 2026-09-25 (lane proma): this line said "Unknown: what the selector at
;          (0x60F088) means".  What each entry here DOES with it is still
;          not decoded.
; Evidence: the fixed reader shape in the ten bytes before the base
;          (`add XBC,0x00FAB8B4 / ld XBC,(XBC) / jp T,XBC`) plus the count
;          taken from its own `cp BC`; both re-derived by
;          notes/prom_a_byte_checks.py and notes/prom_a_jumptables.py.
; ---------------------------------------------------------------------
; List2030_PartFieldHandlers: List2030_Part00to1F_Dispatch's switch on the record CLASS (0x60F088), the byte index
;   0..11 in a part's first record: 0 PROGRAM CHANGE & BANK, 3 VOLUME, 5-7 effect sends, 8 PAN, 9-11 tunings. Basis:
;   table index (record byte, the SysEx descriptors and MidiOut_ParamClassTable) + its named arms. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
List2030_PartFieldHandlers:
	.long List2030_PartProgramChange_Apply_Call                                 ; FAB8B4  [  0]
	.long .LFAB914                                   ; FAB8B8  [  1]
	.long .LFAB914                                   ; FAB8BC  [  2]
	.long List2030_PartVolume_Apply_Call                                 ; FAB8C0  [  3]
	.long sub_FAB8EE                                 ; FAB8C4  [  4]
	.long List2030_PartEffect3Depth_Apply_Call                                 ; FAB8C8  [  5]
	.long List2030_PartEffect4Depth_Apply_Call                                 ; FAB8CC  [  6]
	.long List2030_PartEffect1Depth_Apply_Call                                 ; FAB8D0  [  7]
	.long List2030_PartPan_Apply_Call                                 ; FAB8D4  [  8]
	.long List2030_PartCoarseTune_Apply_Call                                 ; FAB8D8  [  9]
	.long List2030_PartFineTune_Apply_Call                                 ; FAB8DC  [ 10]
	.long List2030_PartBendRange_Apply_Call                                 ; FAB8E0  [ 11]
; List2030_PartProgramChange_Apply_Call: List2030_PartFieldHandlers[0] (record byte 0, PROGRAM CHANGE & BANK): `calr`
;   the class-0 apply routine (SoundSel_ClampToProgramAndBank, then the part's sound bytes) and `jr` to the shared ret
;   -- the shape of List2030_PartVolume_Apply_Call. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
List2030_PartProgramChange_Apply_Call:   ; entry: List2030_PartFieldHandlers[0], class 0
	calr sub_FAB915                                      ; FAB8E4  1e 2e 00
	jr .LFAB914                                          ; FAB8E7  68 2b
; List2030_PartVolume_Apply_Call: List2030_PartFieldHandlers[3]: `calr List2030_PartVolume_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartVolume_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8C0
	calr List2030_PartVolume_Apply                                      ; FAB8E9  1e 11 01
	jr .LFAB914                                          ; FAB8EC  68 26
sub_FAB8EE:   ; entry: named by 1 `.long` operand, first at 0xFAB8C4
	calr sub_FABA08                                      ; FAB8EE  1e 17 01
	jr .LFAB914                                          ; FAB8F1  68 21
; List2030_PartEffect3Depth_Apply_Call: List2030_PartFieldHandlers[5]: `calr List2030_PartEffect3Depth_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartEffect3Depth_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8C8
	calr List2030_PartEffect3Depth_Apply                                      ; FAB8F3  1e ba 01
	jr .LFAB914                                          ; FAB8F6  68 1c
; List2030_PartEffect4Depth_Apply_Call: List2030_PartFieldHandlers[6]: `calr List2030_PartEffect4Depth_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartEffect4Depth_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8CC
	calr List2030_PartEffect4Depth_Apply                                      ; FAB8F8  1e c0 01
	jr .LFAB914                                          ; FAB8FB  68 17
; List2030_PartEffect1Depth_Apply_Call: List2030_PartFieldHandlers[7]: `calr List2030_PartEffect1Depth_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartEffect1Depth_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8D0
	calr List2030_PartEffect1Depth_Apply                                      ; FAB8FD  1e c6 01
	jr .LFAB914                                          ; FAB900  68 12
; List2030_PartPan_Apply_Call: List2030_PartFieldHandlers[8]: `calr List2030_PartPan_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartPan_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8D4
	calr List2030_PartPan_Apply                                      ; FAB902  1e cc 01
	jr .LFAB914                                          ; FAB905  68 0d
; List2030_PartCoarseTune_Apply_Call: List2030_PartFieldHandlers[9]: `calr List2030_PartCoarseTune_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartCoarseTune_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8D8
	calr List2030_PartCoarseTune_Apply                                      ; FAB907  1e d2 01
	jr .LFAB914                                          ; FAB90A  68 08
; List2030_PartFineTune_Apply_Call: List2030_PartFieldHandlers[10]: `calr List2030_PartFineTune_Apply / jr` to the table's shared `ret` -- the shape of class 11's
;   List2030_PartBendRange_Apply_Call.
List2030_PartFineTune_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8DC
	calr List2030_PartFineTune_Apply                                      ; FAB90C  1e d8 01
	jr .LFAB914                                          ; FAB90F  68 03
List2030_PartBendRange_Apply_Call:   ; entry: named by 1 `.long` operand, first at 0xFAB8E0
	calr List2030_PartBendRange_Apply                                      ; FAB911  1e de 01
.LFAB914:
	ret                                                  ; FAB914  0e
sub_FAB915:
	link XIZ,0xfffc                                      ; FAB915  ee 0c fc ff
	pushw hl                                             ; FAB919  2b
	push XIX                                             ; FAB91A  3c
	ld c, (0x60f021:24)                                 ; FAB91B  c2 21 f0 60 23
	and C,0x10                                           ; FAB920  cb cc 10
	jr nz, .LFAB937                                      ; FAB923  6e 12
	ld c, (0x60f089:24)                                 ; FAB925  c2 89 f0 60 23
	ld (0x60f0d0:24), c                                 ; FAB92A  f2 d0 f0 60 43
	set	4, (0x60f021:24)                             ; FAB92F  f2 21 f0 60 bc
	jrl .LFAB9F8                                         ; FAB934  78 c1 00
.LFAB937:
	res	4, (0x60f021:24)                             ; FAB937  f2 21 f0 60 b4
	ld c, (0x60f080:24)                                 ; FAB93C  c2 80 f0 60 23
	ld (0x60f01c:24), c                                 ; FAB941  f2 1c f0 60 43
	ld a, (0x60f089:24)                                 ; FAB946  c2 89 f0 60 21
	ld (0x60f160:24), a                                 ; FAB94B  f2 60 f1 60 41
	ld c, (0x60f08a:24)                                 ; FAB950  c2 8a f0 60 23
	ld (0x60f161:24), c                                 ; FAB955  f2 61 f1 60 43
	ld c, (0x60f0d0:24)                                 ; FAB95A  c2 d0 f0 60 23
	ld (0x60f162:24), c                                 ; FAB95F  f2 62 f1 60 43
	calr SoundSel_ClampToProgramAndBank                                          ; FAB964  1e f1 fc
	push 0x00                                            ; FAB967  09 00
	push	(0x60f080:24)                                ; FAB969  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FAB96E  1e 39 0f
	ld XIX,XIY                                           ; FAB971  ed 8c
	sub XBC,XBC                                          ; FAB973  e9 a1
	dec 1,XBC                                            ; FAB975  e9 69
	ld (xiz-4), xbc                                      ; FAB977  be fc 61
	popw wa                                              ; FAB97A  48
	cp XIY,XBC                                           ; FAB97B  e9 f5
	jrl z, .LFAB9F8                                      ; FAB97D  76 78 00
	ld c, (0x60f164:24)                                 ; FAB980  c2 64 f1 60 23
	ld (XIX),C                                           ; FAB985  b4 43
	ld XBC,XIX                                           ; FAB987  ec 89
	inc 1,XBC                                            ; FAB989  e9 61
	ld (xiz-4), xbc                                      ; FAB98B  be fc 61
	and (XBC),0x80                                       ; FAB98E  81 3c 80
	ld xbc, (xiz-4)                                      ; FAB991  ae fc 21
	ld H,(XBC)                                           ; FAB994  81 26
	ld a, (0x60f165:24)                                 ; FAB996  c2 65 f1 60 21
	or A,H                                               ; FAB99B  ce e1
	ld (XBC),A                                           ; FAB99D  b1 41
	ld c, (0x60f080:24)                                 ; FAB99F  c2 80 f0 60 23
	set 0x05,C                                           ; FAB9A4  cb 31 05
	pushw bc                                             ; FAB9A7  29
	calr ParamNumber_GetRecordPtr                                          ; FAB9A8  1e ff 0e
	ld XIX,XIY                                           ; FAB9AB  ed 8c
	ld c, (0x60f089:24)                                 ; FAB9AD  c2 89 f0 60 23
	ld (XIY+0x1b),C                                      ; FAB9B2  bd 1b 43
	ld c, (0x60f08a:24)                                 ; FAB9B5  c2 8a f0 60 23
	ld (XIX+0x1c),C                                      ; FAB9BA  bc 1c 43
	ld c, (0x60f0d0:24)                                 ; FAB9BD  c2 d0 f0 60 23
	ld (XIX+0x1d),C                                      ; FAB9C2  bc 1d 43
	ld (0x60f081:24), 0x01                             ; FAB9C5  f2 81 f0 60 00 01
	ld c, (0x60f165:24)                                 ; FAB9CB  c2 65 f1 60 23
	ld (0x60f082:24), c                                 ; FAB9D0  f2 82 f0 60 43
	ld (0x60f083:24), 0x7f                             ; FAB9D5  f2 83 f0 60 00 7f
	calr Queue2C00_AppendStagedIfPending                                          ; FAB9DB  1e 2d f8
	ld (0x60f081:24), 0x00                             ; FAB9DE  f2 81 f0 60 00 00
	ld c, (0x60f164:24)                                 ; FAB9E4  c2 64 f1 60 23
	ld (0x60f082:24), c                                 ; FAB9E9  f2 82 f0 60 43
	ld (0x60f083:24), 0xff                             ; FAB9EE  f2 83 f0 60 00 ff
	calr Queue2C00_AppendStagedIfPending                                          ; FAB9F4  1e 14 f8
	popw bc                                              ; FAB9F7  49
.LFAB9F8:
	pop XIX                                              ; FAB9F8  5c
	popw hl                                              ; FAB9F9  4b
	unlk XIZ                                             ; FAB9FA  ee 0d
	ret                                                  ; FAB9FC  0e
; List2030_PartVolume_Apply -- class 3 of a part (number 0x00-0x1F) record in the RAM 0x2030 list: write the 7-bit value into byte 3 of that part's record when it changed, and queue the change to 0x2C00
; Evidence: List2030_PartFieldHandlers[3] (reached by `calr` at 0xFAB8E9), which is indexed by the record CLASS (0x60F088); MidiOut_ParamClassTable[3], indexed by the same class byte of the same 4-byte record, is MidiOut_CC07_Volume.
; Body: `pushw 0x7f / calr ParamRecord_MergeFieldIfChanged / calr Queue2C00_AppendStagedIfPending` (0xFAB9FD-0xFABA03).  ParamRecord_MergeFieldIfChanged merges (0x60F089) under the pushed mask into ParamNumber_RecordPtrs[(0x60F080)] + class, compares with the old byte (0x60F08B) and only then stores, stages and ORs the mask into (0x60F083).
; The six siblings 0xFABAB0-0xFABAF2 are byte-identical except for the pushed mask.
List2030_PartVolume_Apply:
	pushw 0x7f                                           ; FAB9FD  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABA00  1e 34 f9
	calr Queue2C00_AppendStagedIfPending                                          ; FABA03  1e 05 f8
	popw bc                                              ; FABA06  49
	ret                                                  ; FABA07  0e
sub_FABA08:
	link XIZ,0xfffc                                      ; FABA08  ee 0c fc ff
	pushw hl                                             ; FABA0C  2b
	push XIX                                             ; FABA0D  3c
	lda xix, (0x60f08a:24)                               ; FABA0E  f2 8a f0 60 34
	ld xbc, (0x60f084:24)                               ; FABA13  e2 84 f0 60 21
	ld A,(XBC)                                           ; FABA18  81 21
	cp A,0xff                                            ; FABA1A  c9 cf ff
	jr c, .LFABA28                                       ; FABA1D  67 09
	and	(0x60f089:24), 0xb7                          ; FABA1F  c2 89 f0 60 3c b7
	and (XIX),0xb7                                       ; FABA25  84 3c b7
.LFABA28:
	ld xbc, (0x60f084:24)                               ; FABA28  e2 84 f0 60 21
	ld (xiz-4), xbc                                      ; FABA2D  be fc 61
	ld A,(XBC)                                           ; FABA30  81 21
	cp A,0x80                                            ; FABA32  c9 cf 80
	jr c, .LFABA46                                       ; FABA35  67 0f
	ld A,(XBC+0x01)                                      ; FABA37  89 01 21
	cp a, 0x07:i3                                          ; FABA3A  c9 df
	jr nz, .LFABA46                                      ; FABA3C  6e 08
	res	6, (0x60f089:24)                             ; FABA3E  f2 89 f0 60 b6
	and (XIX),0xbf                                       ; FABA43  84 3c bf
.LFABA46:
	ld c, (0x60f020:24)                                 ; FABA46  c2 20 f0 60 23
	and C,0x02                                           ; FABA4B  cb cc 02
	jr z, .LFABA5C                                       ; FABA4E  66 0c
	pushw 0x08                                           ; FABA50  0b 08 00
	calr sub_FAB49B                                          ; FABA53  1e 45 fa
	popw bc                                              ; FABA56  49
	pushw 0x40                                           ; FABA57  0b 40 00
	jr .LFABA5F                                          ; FABA5A  68 03
.LFABA5C:
	pushw 0x48                                           ; FABA5C  0b 48 00
.LFABA5F:
	calr sub_FAB253                                          ; FABA5F  1e f1 f7
	ld C,(XIX)                                           ; FABA62  84 23
	and C,0x03                                           ; FABA64  cb cc 03
	popw wa                                              ; FABA67  48
	jr z, .LFABAA8                                       ; FABA68  66 3e
	cp	(0x60f089:24), 0x02                          ; FABA6A  c2 89 f0 60 3f 02
	jr nz, .LFABA8C                                      ; FABA70  6e 1a
	ld (0x60f0b4:24), 0x01                             ; FABA72  f2 b4 f0 60 00 01
	ld (0x60f0b5:24), 0x08                             ; FABA78  f2 b5 f0 60 00 08
	ld (0x60f0b6:24), 0x07                             ; FABA7E  f2 b6 f0 60 00 07
	pushw 0x07                                           ; FABA84  0b 07 00
	pushw 0x02                                           ; FABA87  0b 02 00
	jr .LFABAA4                                          ; FABA8A  68 18
.LFABA8C:
	ld h, 0xff:opc                                          ; FABA8C  26 ff
	ld (0x60f0b4:24), h                                 ; FABA8E  f2 b4 f0 60 46
	ld (0x60f0b5:24), h                                 ; FABA93  f2 b5 f0 60 46
	ld (0x60f0b6:24), 0x00                             ; FABA98  f2 b6 f0 60 00 00
	pushw 0x07                                           ; FABA9E  0b 07 00
	pushw 0x01                                           ; FABAA1  0b 01 00
.LFABAA4:
	calr sub_FAB410                                          ; FABAA4  1e 69 f9
	pop XIY                                              ; FABAA7  5d
.LFABAA8:
	calr Queue2C00_AppendStagedIfPending                                          ; FABAA8  1e 60 f7
	pop XIX                                              ; FABAAB  5c
	popw hl                                              ; FABAAC  4b
	unlk XIZ                                             ; FABAAD  ee 0d
	ret                                                  ; FABAAF  0e
; List2030_PartEffect3Depth_Apply -- class 5 of a part record in the 0x2030 list: write the 7-bit value into byte 5 of the part's record when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[5] (calr at 0xFAB8F3); MidiOut_ParamClassTable[5] on the same class byte is MidiOut_CC5D_Effect3Depth.  Body `pushw 0x7f / calr ParamRecord_MergeFieldIfChanged / calr Queue2C00_AppendStagedIfPending`, as List2030_PartVolume_Apply.
List2030_PartEffect3Depth_Apply:
	pushw 0x7f                                           ; FABAB0  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABAB3  1e 81 f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABAB6  1e 52 f7
	popw bc                                              ; FABAB9  49
	ret                                                  ; FABABA  0e
; List2030_PartEffect4Depth_Apply -- class 6 of a part record in the 0x2030 list: write the 7-bit value into byte 6 when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[6] (calr at 0xFAB8F8); MidiOut_ParamClassTable[6] is MidiOut_CC5E_Effect4Depth.  Body as List2030_PartVolume_Apply, mask 0x7F.
List2030_PartEffect4Depth_Apply:
	pushw 0x7f                                           ; FABABB  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABABE  1e 76 f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABAC1  1e 47 f7
	popw bc                                              ; FABAC4  49
	ret                                                  ; FABAC5  0e
; List2030_PartEffect1Depth_Apply -- class 7 of a part record in the 0x2030 list: write the 7-bit value into byte 7 when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[7] (calr at 0xFAB8FD); MidiOut_ParamClassTable[7] is MidiOut_CC5B_Effect1Depth.  Body as List2030_PartVolume_Apply, mask 0x7F.
List2030_PartEffect1Depth_Apply:
	pushw 0x7f                                           ; FABAC6  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABAC9  1e 6b f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABACC  1e 3c f7
	popw bc                                              ; FABACF  49
	ret                                                  ; FABAD0  0e
; List2030_PartPan_Apply -- class 8 of a part record in the 0x2030 list: write the 7-bit value into byte 8 when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[8] (calr at 0xFAB902); MidiOut_ParamClassTable[8] is MidiOut_CC0A_Pan.  Body as List2030_PartVolume_Apply, mask 0x7F.
List2030_PartPan_Apply:
	pushw 0x7f                                           ; FABAD1  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABAD4  1e 60 f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABAD7  1e 31 f7
	popw bc                                              ; FABADA  49
	ret                                                  ; FABADB  0e
; List2030_PartCoarseTune_Apply -- class 9 of a part record in the 0x2030 list: write the 7-bit value into byte 9 when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[9] (calr at 0xFAB907); MidiOut_ParamClassTable[9] is MidiOut_Rpn02_CoarseTune.  Body as List2030_PartVolume_Apply, mask 0x7F.
List2030_PartCoarseTune_Apply:
	pushw 0x7f                                           ; FABADC  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABADF  1e 55 f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABAE2  1e 26 f7
	popw bc                                              ; FABAE5  49
	ret                                                  ; FABAE6  0e
; List2030_PartFineTune_Apply -- class 10 of a part record in the 0x2030 list: write the full 8-bit value into byte 0x0A when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[10] (calr at 0xFAB90C); MidiOut_ParamClassTable[10] is MidiOut_Rpn01_FineTune.  It is the ONLY sibling that pushes mask 0x00FF (0xFABAE7), matching MidiOut_Rpn01_FineTune's `and A,0xff` on the staged mask and the 0xFF mask KeyValueList_A00 gives key {part, 0x0A}.
List2030_PartFineTune_Apply:
	pushw 0xff                                           ; FABAE7  0b ff 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABAEA  1e 4a f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABAED  1e 1b f7
	popw bc                                              ; FABAF0  49
	ret                                                  ; FABAF1  0e
; List2030_PartBendRange_Apply -- class 11 of a part record in the 0x2030 list: write the 7-bit value into byte 0x0B when it changed, and queue it to 0x2C00
; Evidence: List2030_PartFieldHandlers[11] (calr at 0xFAB911); MidiOut_ParamClassTable[11] is MidiOut_Rpn00_PitchBendRange.  Body as List2030_PartVolume_Apply, mask 0x7F.
List2030_PartBendRange_Apply:
	pushw 0x7f                                           ; FABAF2  0b 7f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABAF5  1e 3f f8
	calr Queue2C00_AppendStagedIfPending                                          ; FABAF8  1e 10 f7
	popw bc                                              ; FABAFB  49
	ret                                                  ; FABAFC  0e
; List2030_Part20to3F_Dispatch -- 0x2030-list handler for parameter numbers 0x20-0x3F, the second 0x20-byte half of each part record: dispatch classes 0x18, 0x19, 0x1A
; Evidence: Dispatch_By_60F080 entries 32-63 all hold it; ParamNumber_RecordPtrs[0x20+i] == [i] + 0x20 (that table's pin 3).  Body: calr ParamRecord_LoadOldByte (old byte -> (0x60F08B)), then `cp BC,0x18/0x19/0x1A` at 0xFABB07-0xFABB13 -> List2030_Field18_SetAllParts / List2030_PartField19_Apply / List2030_PartField1A_Apply; other classes do nothing.
; Evt2030_Class20to3F accepts exactly the same three classes.
List2030_Part20to3F_Dispatch:   ; entry: named by 32 `.long` operands, first at 0xFAC96A
	calr ParamRecord_LoadOldByte                                          ; FABAFD  1e d8 f6
	ld bc, (0x60f088:24)                                ; FABB00  d2 88 f0 60 21
	extz BC                                              ; FABB05  d9 12
	cp BC,0x0018                                         ; FABB07  d9 cf 18 00
	jr z, .LFABB1B                                       ; FABB0B  66 0e
	cp BC,0x0019                                         ; FABB0D  d9 cf 19 00
	jr z, .LFABB20                                       ; FABB11  66 0d
	cp BC,0x001a                                         ; FABB13  d9 cf 1a 00
	jr z, .LFABB25                                       ; FABB17  66 0c
	jr .LFABB28                                          ; FABB19  68 0d
.LFABB1B:
	calr List2030_Field18_SetAllParts                                      ; FABB1B  1e 0b 00
	jr .LFABB28                                          ; FABB1E  68 08
.LFABB20:
	calr List2030_PartField19_Apply                                      ; FABB20  1e 24 00
	jr .LFABB28                                          ; FABB23  68 03
.LFABB25:
	calr List2030_PartField1A_Apply                                      ; FABB25  1e 2a 00
.LFABB28:
	ret                                                  ; FABB28  0e
; List2030_Field18_SetAllParts -- class 0x18 of a second-half part record: apply the record's bit 0 to byte 0x18 of ALL 32 second-half records (numbers 0x20-0x3F), queuing each change to 0x2C00
; Evidence: loop `ld H,0x20` .. `cp H,0x3f / jr ule` at 0xFABB2A-0xFABB43, each pass storing H to (0x60F080), then ParamRecord_LoadOldByte, ParamRecord_MergeFieldIfChanged with mask 0x0001 and Queue2C00_AppendStagedIfPending.
; KeyValueList_A/B give key {0x20+i, 0x18} mask 0x01; ParamRecord_SetPartsField18Bit0 performs the same sweep from a stack argument.  Evt2030_Class20to3F's tail uses bit 0 of +0x18 to choose between fields +0x19 and +0x1A.
List2030_Field18_SetAllParts:
	pushw hl                                             ; FABB29  2b
	ld h, 0x20:opc                                          ; FABB2A  26 20
.LFABB2C:
	ld (0x60f080:24), h                                 ; FABB2C  f2 80 f0 60 46
	calr ParamRecord_LoadOldByte                                          ; FABB31  1e a4 f6
	pushw 0x01                                           ; FABB34  0b 01 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABB37  1e fd f7
	calr Queue2C00_AppendStagedIfPending                                          ; FABB3A  1e ce f6
	inc 1,H                                              ; FABB3D  ce 61
	popw bc                                              ; FABB3F  49
	cp H,0x3f                                            ; FABB40  ce cf 3f
	jr ule, .LFABB2C                                     ; FABB43  63 e7
	popw hl                                              ; FABB45  4b
	ret                                                  ; FABB46  0e
; List2030_PartField19_Apply -- class 0x19 of a second-half part record: write the 6-bit value into byte 0x19 when it changed, and queue it to 0x2C00
; Evidence: called only by List2030_Part20to3F_Dispatch for class 0x19 (`cp BC,0x0019` at 0xFABB0D); body `pushw 0x3f / calr ParamRecord_MergeFieldIfChanged / calr Queue2C00_AppendStagedIfPending`.  KeyValueList_A/B give key {0x20+i, 0x19} mask 0x3F, and Evt2030_Class20to3F reads (XIX+0x19) & 0x3F through BitMaskToOrdinal6, i.e. a one-hot of six.
List2030_PartField19_Apply:
	pushw 0x3f                                           ; FABB47  0b 3f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABB4A  1e ea f7
	calr Queue2C00_AppendStagedIfPending                                          ; FABB4D  1e bb f6
	popw bc                                              ; FABB50  49
	ret                                                  ; FABB51  0e
; List2030_PartField1A_Apply -- class 0x1A of a second-half part record: write the 6-bit value into byte 0x1A when it changed, and queue it to 0x2C00
; Evidence: called only by List2030_Part20to3F_Dispatch for class 0x1A (`cp BC,0x001a` at 0xFABB13); body `pushw 0x3f / calr ParamRecord_MergeFieldIfChanged / calr Queue2C00_AppendStagedIfPending`.  KeyValueList_A/B give key {0x20+i, 0x1A} mask 0x3F; Evt2030_Class20to3F reads (XIX+0x1a) & 0x3F when bit 0 of +0x18 is set.
List2030_PartField1A_Apply:
	pushw 0x3f                                           ; FABB52  0b 3f 00
	calr ParamRecord_MergeFieldIfChanged                                          ; FABB55  1e df f7
	calr Queue2C00_AppendStagedIfPending                                          ; FABB58  1e b0 f6
	popw bc                                              ; FABB5B  49
	ret                                                  ; FABB5C  0e
Dispatch_By_60F080_Nop68:   ; entry: named by 3 `.long` operands, first at 0xFAC9FA
	ret                                                  ; FABB5D  0e
	ret                                                  ; FABB5E  0e
	ret                                                  ; FABB5F  0e
Dispatch_By_60F080_Nop72:   ; entry: named by 1 `.long` operand, first at 0xFACA0A
	ret                                                  ; FABB60  0e
; List2030_Tempo_Dispatch -- 0x2030-list handler for parameter 0x7A, the tempo: class 0 goes to List2030_Tempo_Apply, any other class is ignored
; Evidence: Dispatch_By_60F080[122] (0xFACAD2) is its only reference; `cp bc,0 / jr z` at 0xFABB6B after calr ParamRecord_LoadOldByte.  Parameter 0x7A's record is RAM 0x7EE2 (ParamNumber_RecordPtrs[122]), whose 9-bit value Tempo_ApplyBpm clamps to 0x28..0x12C with default 0x78 (40..300 BPM, 120) -- the tempo notes/sysex-probes/README.md pins three ways.
List2030_Tempo_Dispatch:   ; entry: named by 1 `.long` operand, first at 0xFACAD2
	calr ParamRecord_LoadOldByte                                          ; FABB61  1e 74 f6
	ld bc, (0x60f088:24)                                ; FABB64  d2 88 f0 60 21
	extz BC                                              ; FABB69  d9 12
	cp bc, 0x00:i3                                         ; FABB6B  d9 d8
	jr z, .LFABB71                                       ; FABB6D  66 02
	jr .LFABB74                                          ; FABB6F  68 03
.LFABB71:
	calr List2030_Tempo_Apply                                      ; FABB71  1e 01 00
.LFABB74:
	ret                                                  ; FABB74  0e
; List2030_Tempo_Apply -- store a new tempo into parameter 0x7A's record (RAM 0x7EE2) when it differs, queue both bytes to 0x2C00 and reprogram the tempo timer
; Evidence: `lda XIX,0x7ee2` at 0xFABB76; compares (0x60F089)/(0x60F08A) with (XIX)/(XIX+1) at 0xFABB7C/0xFABB88 and returns when both match; otherwise stores both, stages {0x7A,0,rec[0],0xFF} and {0x7A,1,rec[1],0x01} (0xFABBA4-0xFABBC6) and calls Tempo_ApplyBpm at 0xFABBC9.
; Tempo_ApplyBpm reads (0x7EE2)&0x1FF, clamps it to 40..300 (default 120) and writes 0x08583B00/(tempo*64) to TREG5 (`st_dd8w DE,0x32`; 0x32 = TREG5L in tmp95c061_sfr.inc) unless bit 2 of (0x7F32), the external-clock bit, is set.
List2030_Tempo_Apply:
	push XIX                                             ; FABB75  3c
	lda xix, (0x7ee2:16)                                ; FABB76  f1 e2 7e 34
	ld C,(XIX)                                           ; FABB7A  84 23
	cp	c, (0x60f089:24)                             ; FABB7C  c2 89 f0 60 f3
	jr nz, .LFABB8F                                      ; FABB81  6e 0c
	extz XIX                                             ; FABB83  ec 12
	ld C,(XIX+0x01)                                      ; FABB85  8c 01 23
	cp	c, (0x60f08a:24)                             ; FABB88  c2 8a f0 60 f3
	jr z, .LFABBCD                                       ; FABB8D  66 3e
.LFABB8F:
	ld c, (0x60f089:24)                                 ; FABB8F  c2 89 f0 60 23
	ld (XIX),C                                           ; FABB94  b4 43
	ld c, (0x60f08a:24)                                 ; FABB96  c2 8a f0 60 23
	ld (XIX+0x01),C                                      ; FABB9B  bc 01 43
	ld BC,IX                                             ; FABB9E  dc 89
	extz XBC                                             ; FABBA0  e9 12
	ld A,(XBC)                                           ; FABBA2  81 21
	ld (0x60f082:24), a                                 ; FABBA4  f2 82 f0 60 41
	ld (0x60f083:24), 0xff                             ; FABBA9  f2 83 f0 60 00 ff
	calr Queue2C00_AppendStagedIfPending                                          ; FABBAF  1e 59 f6
	ld (0x60f081:24), 0x01                             ; FABBB2  f2 81 f0 60 00 01
	ld C,(XIX+0x01)                                      ; FABBB8  8c 01 23
	ld (0x60f082:24), c                                 ; FABBBB  f2 82 f0 60 43
	ld (0x60f083:24), 0x01                             ; FABBC0  f2 83 f0 60 00 01
	calr Queue2C00_AppendStagedIfPending                                          ; FABBC6  1e 42 f6
	call Tempo_ApplyBpm                                      ; FABBC9  1d 42 a7 fa
.LFABBCD:
	pop XIX                                              ; FABBCD  5c
	ret                                                  ; FABBCE  0e
Dispatch_By_60F080_Nop144:   ; entry: named by 1 `.long` operand, first at 0xFACB2A
	ret                                                  ; FABBCF  0e
Dispatch_By_60F080_Nop145:   ; entry: named by 1 `.long` operand, first at 0xFACB2E
	ret                                                  ; FABBD0  0e
	ret                                                  ; FABBD1  0e
Dispatch_By_60F080_Nop96:   ; entry: named by 1 `.long` operand, first at 0xFACA6A
	ret                                                  ; FABBD2  0e
	ret                                                  ; FABBD3  0e
Dispatch_By_60F080_Nop112:   ; entry: named by 1 `.long` operand, first at 0xFACAAA
	ret                                                  ; FABBD4  0e
Dispatch_By_60F080_Nop114:   ; entry: named by 1 `.long` operand, first at 0xFACAB2
	ret                                                  ; FABBD5  0e
T_F407F0_Nop:
	ret                                                  ; FABBD6  0e
; List2030_Param98_Dispatch -- 0x2030-list handler for parameter 0x98: class 1 goes to List2030_Param98_ApplyProgram, other classes are ignored
; Evidence: Dispatch_By_60F080[152] (0xFACB4A) is its only reference; `cp bc,1 / jr z` at 0xFABBE1 after calr ParamRecord_LoadOldByte.  Parameter 0x98's record is RAM 0x7F02 (ParamNumber_RecordPtrs[152]).
List2030_Param98_Dispatch:   ; entry: named by 1 `.long` operand, first at 0xFACB4A
	calr ParamRecord_LoadOldByte                                          ; FABBD7  1e fe f5
	ld bc, (0x60f088:24)                                ; FABBDA  d2 88 f0 60 21
	extz BC                                              ; FABBDF  d9 12
	cp bc, 0x01:i3                                         ; FABBE1  d9 d9
	jr z, .LFABBE7                                       ; FABBE3  66 02
	jr .LFABBEA                                          ; FABBE5  68 03
.LFABBE7:
	calr List2030_Param98_ApplyProgram                                      ; FABBE7  1e 01 00
.LFABBEA:
	ret                                                  ; FABBEA  0e
; List2030_Param98_ApplyProgram -- the parameter-0x98 twin of the part program-change handler sub_FAB915: stash the first value, then on the second pass write record 0x7F02's program fields and queue them to 0x2C00
; Evidence: same two-pass gate as sub_FAB915 (bit 4 of (0x60F021) at 0xFABBF1: pass 1 saves (0x60F089) to (0x60F0D0) and sets it, pass 2 clears it); then CombiSel_ClampToNumberAndBank (SoundSel_ClampToProgramAndBank in the part twin), ParamNumber_GetRecordPtr compared with 0x7F02 (0xFABC49-0xFABC51), and stores (XIX+1)&0x80|(0x60F185), (XIX+2)&0xC0|(0x60F186), (XIX+6..8) = value/mask/(0x60F0D0).
; Queues {0x98,2,(0x60F186),0x3F} and {0x98,1,(0x60F185),0x7F} (0xFABC9E-0xFABCCD).  Program reading: sub_FAB915 is List2030_PartFieldHandlers[0], class 0, whose outbound twin is MidiOut_ParamClassTable[0] = MidiOut_ProgramChange; and the Evt2030 handler of 0x98 class 1 runs only when SINGLE CH PROG CHANGE is COMBI (bit 3 of (0x7F32)).
List2030_Param98_ApplyProgram:
	link XIZ,0xfff8                                      ; FABBEB  ee 0c f8 ff
	pushw hl                                             ; FABBEF  2b
	push XIX                                             ; FABBF0  3c
	ld c, (0x60f021:24)                                 ; FABBF1  c2 21 f0 60 23
	and C,0x10                                           ; FABBF6  cb cc 10
	jr nz, .LFABC0D                                      ; FABBF9  6e 12
	ld c, (0x60f089:24)                                 ; FABBFB  c2 89 f0 60 23
	ld (0x60f0d0:24), c                                 ; FABC00  f2 d0 f0 60 43
	set	4, (0x60f021:24)                             ; FABC05  f2 21 f0 60 bc
	jrl .LFABCD0                                         ; FABC0A  78 c3 00
.LFABC0D:
	res	4, (0x60f021:24)                             ; FABC0D  f2 21 f0 60 b4
	ld c, (0x60f080:24)                                 ; FABC12  c2 80 f0 60 23
	ld (0x60f17f:24), c                                 ; FABC17  f2 7f f1 60 43
	ld a, (0x60f089:24)                                 ; FABC1C  c2 89 f0 60 21
	ld (0x60f181:24), a                                 ; FABC21  f2 81 f1 60 41
	ld c, (0x60f08a:24)                                 ; FABC26  c2 8a f0 60 23
	ld (0x60f182:24), c                                 ; FABC2B  f2 82 f1 60 43
	ld c, (0x60f0d0:24)                                 ; FABC30  c2 d0 f0 60 23
	ld (0x60f183:24), c                                 ; FABC35  f2 83 f1 60 43
	calr CombiSel_ClampToNumberAndBank                                          ; FABC3A  1e 3c fb
	push 0x00                                            ; FABC3D  09 00
	push	(0x60f080:24)                                ; FABC3F  c2 80 f0 60 04
	calr ParamNumber_GetRecordPtr                                          ; FABC44  1e 63 0c
	ld XIX,XIY                                           ; FABC47  ed 8c
	lda xbc, (0x7f02:16)                                ; FABC49  f1 02 7f 31
	ld (xiz-4), xbc                                      ; FABC4D  be fc 61
	popw wa                                              ; FABC50  48
	cp XIY,XBC                                           ; FABC51  e9 f5
	jrl nz, .LFABCD0                                     ; FABC53  7e 7a 00
	ld XBC,XIX                                           ; FABC56  ec 89
	inc 1,XBC                                            ; FABC58  e9 61
	ld (xiz-4), xbc                                      ; FABC5A  be fc 61
	and (XBC),0x80                                       ; FABC5D  81 3c 80
	ld xbc, (xiz-4)                                      ; FABC60  ae fc 21
	ld H,(XBC)                                           ; FABC63  81 26
	ld a, (0x60f185:24)                                 ; FABC65  c2 85 f1 60 21
	or A,H                                               ; FABC6A  ce e1
	ld (XBC),A                                           ; FABC6C  b1 41
	ld XBC,XIX                                           ; FABC6E  ec 89
	inc 2,XBC                                            ; FABC70  e9 62
	ld (xiz-8), xbc                                      ; FABC72  be f8 61
	and (XBC),0xc0                                       ; FABC75  81 3c c0
	ld xbc, (xiz-8)                                      ; FABC78  ae f8 21
	ld H,(XBC)                                           ; FABC7B  81 26
	ld a, (0x60f186:24)                                 ; FABC7D  c2 86 f1 60 21
	or A,H                                               ; FABC82  ce e1
	ld (XBC),A                                           ; FABC84  b1 41
	ld c, (0x60f089:24)                                 ; FABC86  c2 89 f0 60 23
	ld (XIX+0x06),C                                      ; FABC8B  bc 06 43
	ld c, (0x60f08a:24)                                 ; FABC8E  c2 8a f0 60 23
	ld (XIX+0x07),C                                      ; FABC93  bc 07 43
	ld c, (0x60f0d0:24)                                 ; FABC96  c2 d0 f0 60 23
	ld (XIX+0x08),C                                      ; FABC9B  bc 08 43
	ld (0x60f081:24), 0x02                             ; FABC9E  f2 81 f0 60 00 02
	ld c, (0x60f186:24)                                 ; FABCA4  c2 86 f1 60 23
	ld (0x60f082:24), c                                 ; FABCA9  f2 82 f0 60 43
	ld (0x60f083:24), 0x3f                             ; FABCAE  f2 83 f0 60 00 3f
	calr Queue2C00_AppendStagedIfPending                                          ; FABCB4  1e 54 f5
	ld (0x60f081:24), 0x01                             ; FABCB7  f2 81 f0 60 00 01
	ld c, (0x60f185:24)                                 ; FABCBD  c2 85 f1 60 23
	ld (0x60f082:24), c                                 ; FABCC2  f2 82 f0 60 43
	ld (0x60f083:24), 0x7f                             ; FABCC7  f2 83 f0 60 00 7f
	calr Queue2C00_AppendStagedIfPending                                          ; FABCCD  1e 3b f5
.LFABCD0:
	pop XIX                                              ; FABCD0  5c
	popw hl                                              ; FABCD1  4b
	unlk XIZ                                             ; FABCD2  ee 0d
	ret                                                  ; FABCD4  0e
	ret                                                  ; FABCD5  0e
	ret                                                  ; FABCD6  0e
; List2030_ParamA8_PassThrough -- 0x2030-list handler for parameter 0xA8: copy the record's value and mask into the staged record unchanged and queue it to 0x2C00, with no record write
; Evidence: Dispatch_By_60F080[168] (0xFACB8A) is its only reference; `ld (0x60f082),(0x60f089) / ld (0x60f083),(0x60f08a) / calr Queue2C00_AppendStagedIfPending` at 0xFABCD7-0xFABCEB.  ParamNumber_RecordPtrs[0xA8] is empty.
List2030_ParamA8_PassThrough:   ; entry: named by 1 `.long` operand, first at 0xFACB8A
	ld c, (0x60f089:24)                                 ; FABCD7  c2 89 f0 60 23
	ld (0x60f082:24), c                                 ; FABCDC  f2 82 f0 60 43
	ld a, (0x60f08a:24)                                 ; FABCE1  c2 8a f0 60 21
	ld (0x60f083:24), a                                 ; FABCE6  f2 83 f0 60 41
	calr Queue2C00_AppendStagedIfPending                                          ; FABCEB  1e 1d f5
	ret                                                  ; FABCEE  0e
; List2030_ParamB0_Dispatch -- 0x2030-list handler for parameter 0xB0: class 0 goes to List2030_ParamB0_Apply, other classes are ignored
; Evidence: Dispatch_By_60F080[176] (0xFACBAA) is its only reference; `cp bc,0 / jr z` at 0xFABCF6.  What parameter 0xB0 is stays open: MidiOut_ParamNumberTable[0xB0] is a bare `ret` (ParamShadow_SetExpression's note).
List2030_ParamB0_Dispatch:   ; entry: named by 1 `.long` operand, first at 0xFACBAA
	ld bc, (0x60f088:24)                                ; FABCEF  d2 88 f0 60 21
	extz BC                                              ; FABCF4  d9 12
	cp bc, 0x00:i3                                         ; FABCF6  d9 d8
	jr z, .LFABCFC                                       ; FABCF8  66 02
	jr .LFABCFF                                          ; FABCFA  68 03
.LFABCFC:
	calr List2030_ParamB0_Apply                                      ; FABCFC  1e 01 00
.LFABCFF:
	ret                                                  ; FABCFF  0e
; List2030_ParamB0_Apply -- set (0x24F1) to the cooked control value (0x24F3) with bit 7 as pending flag, queue the pending 0xB0 bytes, then stage {0xB0,0,value,mask} at (0x60F177) and hand it to ParamChange_Notify
; Evidence: `ld C,(0x24f3) / set 7,C / ld (0x24f1),C` at 0xFABD00-0xFABD07; calr ParamB0_PublishPendingFields (queues {0xB0,0,(0x24F1),0x7F} and {0xB0,1,(0x24F0),0x7F} for whichever has bit 7); stores to 0x60F177..0x60F17A and `call ParamChange_NotifyStagedClearSource` (BC/DE from 0x60F177 -> ParamChange_Notify) at 0xFABD2E.  (0x24F3) is cooked slot 3.3 of Ctrl_Normalise's RAM bank.
List2030_ParamB0_Apply:
	ld c, (0x24f3:16)                                   ; FABD00  c1 f3 24 23
	set 0x07,C                                           ; FABD04  cb 31 07
	ld (0x24f1:16), c                                   ; FABD07  f1 f1 24 43
	calr ParamB0_PublishPendingFields                                          ; FABD0B  1e dd f8
	ld (0x60f177:24), 0xb0                             ; FABD0E  f2 77 f1 60 00 b0
	ld (0x60f178:24), 0x00                             ; FABD14  f2 78 f1 60 00 00
	ld c, (0x60f089:24)                                 ; FABD1A  c2 89 f0 60 23
	ld (0x60f179:24), c                                 ; FABD1F  f2 79 f1 60 43
	ld a, (0x60f08a:24)                                 ; FABD24  c2 8a f0 60 21
	ld (0x60f17a:24), a                                 ; FABD29  f2 7a f1 60 41
	call ParamChange_NotifyStagedClearSource                                      ; FABD2E  1d c4 a7 fa
	ret                                                  ; FABD32  0e
; Seq_PublishPendingParamB0: Clears (0x34D8) bit 7 and runs ParamB0_PublishPendingFields, the two-field ParamB0_PublishField0IfPending:
;   each of parameter 0xB0's fields 0 ((0x24F1)) and 1 ((0x24F0)) whose bit-7 pending flag is set is cleared and
;   published as {0xB0, field, value, 0x7F}. The last call (prom_b slot T_Seq_PublishPendingParamB0) of Seq_RewindOnRequest's rewind and
;   of Seq_StopWhenTracksEnded's stop, each of which clears (0x34D8) bit 7 just before. Basis: callers + body + twin
;   header. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
Seq_PublishPendingParamB0:
	res	7, (0x34d8:16)                               ; FABD33  f1 d8 34 b7
	calr ParamB0_PublishPendingFields                                          ; FABD37  1e b1 f8
	ret                                                  ; FABD3A  0e
; ---------------------------------------------------------------------
; ParamMsg_B1_PitchBend .. ParamMsg_B3_CC0B_Expression -- the eleven MIDI
;          controller entries of Dispatch_By_60F080, 0xFABD3B-0xFABE2A.
; Each:    if bit 5 of (0x7F36) is clear, push the 32-bit part mask held in
;          one RAM cell and fan the record out over it
;          (Queue2C00_FanOutToPartMask; the _Publish variant for 0xB1).
;          ParamMsg_B3 and ParamMsg_B5 also copy the value to (0x60F191) /
;          (0x60F192).
;   0xB1  ParamMsg_B1_PitchBend         cell 0x60F280
;   0xB2  ParamMsg_B2_CC01_Modulation   cell 0x60F284
;   0xB3  ParamMsg_B3_CC0B_Expression   cell 0x60F2A8
;   0xB4  ParamMsg_B4_ChannelPressure   cell 0x60F28C
;   0xB5  ParamMsg_B5_CC40_Hold         cell 0x60F294
;   0xB8  ParamMsg_B8_CC10_RTCreatX     cell 0x60F298
;   0xB9  ParamMsg_B9_CC11_RTCreatY     cell 0x60F29C
;   0xBA  ParamMsg_BA_CC12_RTCtrlX      cell 0x60F2A0
;   0xBB  ParamMsg_BB_CC13_RTCtrlY      cell 0x60F2A4
;   0xBC  ParamMsg_BC_CC02_Modulation2  cell 0x60F288
;   0xBD  ParamMsg_BD_CC04_CtrlPedal    cell 0x60F290
; ★ Number -> controller is pinned twice: the MIDI-in table named for the
;          controller holds that number in every record (check M5), and
;          MidiOut_ParamNumberTable[number] is the MidiOut_ handler of the
;          same controller.  MidiIn_ControlRecordHandlers loads the SAME
;          cell for each number (check M4): two readers of eleven cells.
; ⚠ What bit 5 of (0x7F36) switches off is not established.
; (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
ParamMsg_B1_PitchBend:   ; entry: named by 1 `.long` operand, first at 0xFACBAE
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABD3B  c1 36 7f 23
	and C,0x20                                           ; FABD3F  cb cc 20
	jr nz, .LFABD4E                                      ; FABD42  6e 0a
	ld xbc, (ParamMsg_PartMask_PitchBend:24)                               ; FABD44  e2 80 f2 60 21
	push XBC                                             ; FABD49  39
	calr Queue2C00_FanOutToPartMask_Publish                                      ; FABD4A  1e 22 01
	pop XIY                                              ; FABD4D  5d
.LFABD4E:
	ret                                                  ; FABD4E  0e
ParamMsg_B2_CC01_Modulation:   ; entry: named by 1 `.long` operand, first at 0xFACBB2
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABD4F  c1 36 7f 23
	and C,0x20                                           ; FABD53  cb cc 20
	jr nz, .LFABD62                                      ; FABD56  6e 0a
	ld xbc, (ParamMsg_PartMask_Modulation:24)                               ; FABD58  e2 84 f2 60 21
	push XBC                                             ; FABD5D  39
	calr Queue2C00_FanOutToPartMask                                      ; FABD5E  1e ca 00
	pop XIY                                              ; FABD61  5d
.LFABD62:
	ret                                                  ; FABD62  0e
ParamMsg_BC_CC02_Modulation2:   ; entry: named by 1 `.long` operand, first at 0xFACBDA
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABD63  c1 36 7f 23
	and C,0x20                                           ; FABD67  cb cc 20
	jr nz, .LFABD76                                      ; FABD6A  6e 0a
	ld xbc, (ParamMsg_PartMask_Modulation2:24)                               ; FABD6C  e2 88 f2 60 21
	push XBC                                             ; FABD71  39
	calr Queue2C00_FanOutToPartMask                                      ; FABD72  1e b6 00
	pop XIY                                              ; FABD75  5d
.LFABD76:
	ret                                                  ; FABD76  0e
ParamMsg_B4_ChannelPressure:   ; entry: named by 1 `.long` operand, first at 0xFACBBA
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABD77  c1 36 7f 23
	and C,0x20                                           ; FABD7B  cb cc 20
	jr nz, .LFABD8A                                      ; FABD7E  6e 0a
	ld xbc, (ParamMsg_PartMask_ChannelPressure:24)                               ; FABD80  e2 8c f2 60 21
	push XBC                                             ; FABD85  39
	calr Queue2C00_FanOutToPartMask                                      ; FABD86  1e a2 00
	pop XIY                                              ; FABD89  5d
.LFABD8A:
	ret                                                  ; FABD8A  0e
ParamMsg_BD_CC04_CtrlPedal:   ; entry: named by 1 `.long` operand, first at 0xFACBDE
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABD8B  c1 36 7f 23
	and C,0x20                                           ; FABD8F  cb cc 20
	jr nz, .LFABD9E                                      ; FABD92  6e 0a
	ld xbc, (ParamMsg_PartMask_CtrlPedal:24)                               ; FABD94  e2 90 f2 60 21
	push XBC                                             ; FABD99  39
	calr Queue2C00_FanOutToPartMask                                      ; FABD9A  1e 8e 00
	pop XIY                                              ; FABD9D  5d
.LFABD9E:
	ret                                                  ; FABD9E  0e
ParamMsg_B5_CC40_Hold:   ; entry: named by 1 `.long` operand, first at 0xFACBBE
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABD9F  c1 36 7f 23
	and C,0x20                                           ; FABDA3  cb cc 20
	jr nz, .LFABDBC                                      ; FABDA6  6e 14
	ld xbc, (ParamMsg_PartMask_Hold:24)                               ; FABDA8  e2 94 f2 60 21
	push XBC                                             ; FABDAD  39
	calr Queue2C00_FanOutToPartMask                                      ; FABDAE  1e 7a 00
	ld c, (0x60f089:24)                                 ; FABDB1  c2 89 f0 60 23
	ld (0x60f192:24), c                                 ; FABDB6  f2 92 f1 60 43
	pop XIY                                              ; FABDBB  5d
.LFABDBC:
	ret                                                  ; FABDBC  0e
ParamMsg_B8_CC10_RTCreatX:   ; entry: named by 1 `.long` operand, first at 0xFACBCA
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABDBD  c1 36 7f 23
	and C,0x20                                           ; FABDC1  cb cc 20
	jr nz, .LFABDD0                                      ; FABDC4  6e 0a
	ld xbc, (ParamMsg_PartMask_RTCreatX:24)                               ; FABDC6  e2 98 f2 60 21
	push XBC                                             ; FABDCB  39
	calr Queue2C00_FanOutToPartMask                                      ; FABDCC  1e 5c 00
	pop XIY                                              ; FABDCF  5d
.LFABDD0:
	ret                                                  ; FABDD0  0e
ParamMsg_B9_CC11_RTCreatY:   ; entry: named by 1 `.long` operand, first at 0xFACBCE
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABDD1  c1 36 7f 23
	and C,0x20                                           ; FABDD5  cb cc 20
	jr nz, .LFABDE4                                      ; FABDD8  6e 0a
	ld xbc, (ParamMsg_PartMask_RTCreatY:24)                               ; FABDDA  e2 9c f2 60 21
	push XBC                                             ; FABDDF  39
	calr Queue2C00_FanOutToPartMask                                      ; FABDE0  1e 48 00
	pop XIY                                              ; FABDE3  5d
.LFABDE4:
	ret                                                  ; FABDE4  0e
ParamMsg_BA_CC12_RTCtrlX:   ; entry: named by 1 `.long` operand, first at 0xFACBD2
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABDE5  c1 36 7f 23
	and C,0x20                                           ; FABDE9  cb cc 20
	jr nz, .LFABDF8                                      ; FABDEC  6e 0a
	ld xbc, (ParamMsg_PartMask_RTCtrlX:24)                               ; FABDEE  e2 a0 f2 60 21
	push XBC                                             ; FABDF3  39
	calr Queue2C00_FanOutToPartMask                                      ; FABDF4  1e 34 00
	pop XIY                                              ; FABDF7  5d
.LFABDF8:
	ret                                                  ; FABDF8  0e
ParamMsg_BB_CC13_RTCtrlY:   ; entry: named by 1 `.long` operand, first at 0xFACBD6
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABDF9  c1 36 7f 23
	and C,0x20                                           ; FABDFD  cb cc 20
	jr nz, .LFABE0C                                      ; FABE00  6e 0a
	ld xbc, (ParamMsg_PartMask_RTCtrlY:24)                               ; FABE02  e2 a4 f2 60 21
	push XBC                                             ; FABE07  39
	calr Queue2C00_FanOutToPartMask                                      ; FABE08  1e 20 00
	pop XIY                                              ; FABE0B  5d
.LFABE0C:
	ret                                                  ; FABE0C  0e
ParamMsg_B3_CC0B_Expression:   ; entry: named by 1 `.long` operand, first at 0xFACBB6
	ld c, (MidiCfg_SingleChannel:16)                                   ; FABE0D  c1 36 7f 23
	and C,0x20                                           ; FABE11  cb cc 20
	jr nz, .LFABE2A                                      ; FABE14  6e 14
	ld xbc, (ParamMsg_PartMask_Expression:24)                               ; FABE16  e2 a8 f2 60 21
	push XBC                                             ; FABE1B  39
	calr Queue2C00_FanOutToPartMask                                      ; FABE1C  1e 0c 00
	ld c, (0x60f089:24)                                 ; FABE1F  c2 89 f0 60 23
	ld (0x60f191:24), c                                 ; FABE24  f2 91 f1 60 43
	pop XIY                                              ; FABE29  5d
.LFABE2A:
	ret                                                  ; FABE2A  0e
; ---------------------------------------------------------------------
; Queue2C00_FanOutToPartMask -- emit the current record once per set bit of
;          a 32-bit mask, with the bit's index as the record's CLASS.
; Inputs:  (XIZ+8) = the mask, pushed by the caller.
; Body:    for H = 0..31, low bit first: if set, (0x60F081) = H, (0x60F082)
;          = the value (0x60F089), (0x60F083) = the mask (0x60F08A), then
;          Queue2C00_AppendStagedIfPending.
; Called from: ten of the eleven ParamMsg_ controller entries below, and the
;          common tail of MidiIn_ControlRecordHandlers (0xFABFD9).
; ★ The index is a PART: for these numbers every MIDI-in table puts the
;          part in the class byte (check M5), so a controller record goes
;          out once per part whose bit is set.  (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
Queue2C00_FanOutToPartMask:
	link XIZ,0x0000                                      ; FABE2B  ee 0c 00 00
	pushw hl                                             ; FABE2F  2b
	push XIX                                             ; FABE30  3c
	ld XIX,(XIZ+0x08)                                    ; FABE31  ae 08 24
	ld h, 0x00:opc                                          ; FABE34  26 00
.LFABE36:
	ld XBC,XIX                                           ; FABE36  ec 89
	and XBC,0x00000001                                   ; FABE38  e9 cc 01 00 00 00
	jr z, .LFABE5C                                       ; FABE3E  66 1c
	ld (0x60f081:24), h                                 ; FABE40  f2 81 f0 60 46
	ld c, (0x60f089:24)                                 ; FABE45  c2 89 f0 60 23
	ld (0x60f082:24), c                                 ; FABE4A  f2 82 f0 60 43
	ld a, (0x60f08a:24)                                 ; FABE4F  c2 8a f0 60 21
	ld (0x60f083:24), a                                 ; FABE54  f2 83 f0 60 41
	calr Queue2C00_AppendStagedIfPending                                          ; FABE59  1e af f3
.LFABE5C:
	inc 1,H                                              ; FABE5C  ce 61
	ld XIY,XIX                                           ; FABE5E  ec 8d
	srl xiy, 0x01                                        ; FABE60  ed ef 01
	ld XIX,XIY                                           ; FABE63  ed 8c
	cp H,0x1f                                            ; FABE65  ce cf 1f
	jr ule, .LFABE36                                     ; FABE68  63 cc
	pop XIX                                              ; FABE6A  5c
	popw hl                                              ; FABE6B  4b
	unlk XIZ                                             ; FABE6C  ee 0d
	ret                                                  ; FABE6E  0e
; ---------------------------------------------------------------------
; Queue2C00_FanOutToPartMask_Publish -- Queue2C00_FanOutToPartMask with
;          Queue2C00_PublishStaged (no zero-mask test) instead of
;          Queue2C00_AppendStagedIfPending, the `call` at 0xFABE9D.
; Called from: ParamMsg_B1_PitchBend (0xFABD4A) and the 0xB1 arm of
;          MidiIn_ControlRecord_Dispatch (0xFABF26) -- pitch bend only.
; (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
Queue2C00_FanOutToPartMask_Publish:
	link XIZ,0x0000                                      ; FABE6F  ee 0c 00 00
	pushw hl                                             ; FABE73  2b
	push XIX                                             ; FABE74  3c
	ld XIX,(XIZ+0x08)                                    ; FABE75  ae 08 24
	ld h, 0x00:opc                                          ; FABE78  26 00
.LFABE7A:
	ld XBC,XIX                                           ; FABE7A  ec 89
	and XBC,0x00000001                                   ; FABE7C  e9 cc 01 00 00 00
	jr z, .LFABEA1                                       ; FABE82  66 1d
	ld (0x60f081:24), h                                 ; FABE84  f2 81 f0 60 46
	ld c, (0x60f089:24)                                 ; FABE89  c2 89 f0 60 23
	ld (0x60f082:24), c                                 ; FABE8E  f2 82 f0 60 43
	ld a, (0x60f08a:24)                                 ; FABE93  c2 8a f0 60 21
	ld (0x60f083:24), a                                 ; FABE98  f2 83 f0 60 41
	call Queue2C00_PublishStaged                                      ; FABE9D  1d fc a4 fa
.LFABEA1:
	inc 1,H                                              ; FABEA1  ce 61
	ld XIY,XIX                                           ; FABEA3  ec 8d
	srl xiy, 0x01                                        ; FABEA5  ed ef 01
	ld XIX,XIY                                           ; FABEA8  ed 8c
	cp H,0x1f                                            ; FABEAA  ce cf 1f
	jr ule, .LFABE7A                                     ; FABEAD  63 cb
	pop XIX                                              ; FABEAF  5c
	popw hl                                              ; FABEB0  4b
	unlk XIZ                                             ; FABEB1  ee 0d
	ret                                                  ; FABEB3  0e
; Queue2E00_FanOutToPartMask -- Queue2C00_FanOutToPartMask's twin for the PENDING queue 0x2E00: for each set bit H of the 32-bit mask at (XIZ+8), append {(0x60F080), H, (0x60F089), (0x60F08A)}
; Evidence: the same H=0..0x1F / `srl 1,XIY` loop as Queue2C00_FanOutToPartMask (0xFABEBD-0xFABEF4); the append is `call T_PendingEventQueue_AppendStackArgs` at 0xFABEE2, i.e. prom_b `jp sub_F8BC08` -> `calr sub_F8BF07`, which loads E/D/A/W from (XIZ+0x0C/0x0E/0x10/0x12) and calls T_Queue2E00_AppendRegs.
; Called from: the eleven ParamMsg_ResyncParts_* arms of JumpTable_FAC3BF.
Queue2E00_FanOutToPartMask:
	link XIZ,0x0000                                      ; FABEB4  ee 0c 00 00
	pushw hl                                             ; FABEB8  2b
	push XIX                                             ; FABEB9  3c
	ld XIX,(XIZ+0x08)                                    ; FABEBA  ae 08 24
	ld h, 0x00:opc                                          ; FABEBD  26 00
.LFABEBF:
	ld XBC,XIX                                           ; FABEBF  ec 89
	and XBC,0x00000001                                   ; FABEC1  e9 cc 01 00 00 00
	jr z, .LFABEE8                                       ; FABEC7  66 1f
	push 0x00                                            ; FABEC9  09 00
	push	(0x60f08a:24)                                ; FABECB  c2 8a f0 60 04
	push 0x00                                            ; FABED0  09 00
	push	(0x60f089:24)                                ; FABED2  c2 89 f0 60 04
	push 0x00                                            ; FABED7  09 00
	push H                                               ; FABED9  ce 04
	push 0x00                                            ; FABEDB  09 00
	push	(0x60f080:24)                                ; FABEDD  c2 80 f0 60 04
	call T_PendingEventQueue_AppendStackArgs                                        ; FABEE2  1d 18 1b f4
	inc 8,XSP                                            ; FABEE6  ef 60
.LFABEE8:
	inc 1,H                                              ; FABEE8  ce 61
	ld XIY,XIX                                           ; FABEEA  ec 8d
	srl xiy, 0x01                                        ; FABEEC  ed ef 01
	ld XIX,XIY                                           ; FABEEF  ed 8c
	cp H,0x1f                                            ; FABEF1  ce cf 1f
sub_FABEF4:
	jr ule, .LFABEBF                                     ; FABEF4  63 c9
	pop XIX                                              ; FABEF6  5c
	popw hl                                              ; FABEF7  4b
	unlk XIZ                                             ; FABEF8  ee 0d
	ret                                                  ; FABEFA  0e
; ---------------------------------------------------------------------
; MidiIn_ControlRecord_Dispatch -- dispatches a control record on its first byte: 0xB1 stages
;                                  three of its fields and publishes them, 0xB2..0xBD index a
;                                  twelve-entry jump table
;
; Evidence: 0xFABF01 `ld XBC,(XIZ+0x08)` takes the record pointer from
;           the frame and 0xFABF04 `ld H,(XBC)` its first byte; 0xFABF06
;           `cp H,0xb1` is the special case, whose arm copies (XBC+0x02)
;           and (XBC+0x03) to (0x60F089) and (0x60F08A) at
;           0xFABF18/0xFABF20 and calls 0xFABE6F, the routine that
;           reaches Queue2C00_PublishStaged; every other value goes
;           through 0xFABF32 `sub BC,0x00b2` and 0xFABF36 `cp BC,0x000b`
;           into JumpTable_FABF4A, which this listing already documents
;           as twelve entries with first case 0xB2. prom_b publishes it
;           as T_MidiIn_ControlRecord_Dispatch with 21 references, and ELEVEN of its
;           content-named callers are MIDI controller handlers --
;           MidiIn_CC01, CC02, CC04, CC0B, CC10, CC11, CC12, CC13, CC40,
;           MidiIn_ChannelPressure and MidiIn_PitchBend -- which is what
;           the `MidiIn_` prefix claims and all it claims
; ★ CORRECTED 2026-09-25 (lane proma).  This said "Unknown: what a record
;           IS ... the twelve jump-table arms are not decoded here".  The
;           record is the 4-byte parameter-change record the MIDI-in
;           controller handlers build at RAM 0x1950 -- [number] [class]
;           [value] [mask], see MidiIn_CC01_ParamTable's header -- so its
;           first byte is the parameter number, and the MIDI-in tables pin
;           all eleven of 0xB1-0xB5 / 0xB8-0xBD to their controllers.  Each
;           arm loads its number's 32-bit part mask (the MidiIn_CtrlRec_
;           labels) and the common tail fans the record out over it with
;           Queue2C00_FanOutToPartMask -- the same cells, number for
;           number, that the ParamMsg_ entries of Dispatch_By_60F080 use
;           (check M4).  0xB6/0xB7 take the skip arm.
; (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; Was `sub_FABEFB`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
MidiIn_ControlRecord_Dispatch:
	link XIZ,0x0000                                      ; FABEFB  ee 0c 00 00
	pushw hl                                             ; FABEFF  2b
	push XIX                                             ; FABF00  3c
	ld XBC,(XIZ+0x08)                                    ; FABF01  ae 08 21
	ld H,(XBC)                                           ; FABF04  81 26
	cp H,0xb1                                            ; FABF06  ce cf b1
	jr nz, .LFABF2C                                      ; FABF09  6e 21
	ld xix, (ParamMsg_PartMask_PitchBend:24)                               ; FABF0B  e2 80 f2 60 24
	ld (0x60f080:24), h                                 ; FABF10  f2 80 f0 60 46
	ld A,(XBC+0x02)                                      ; FABF15  89 02 21
	ld (0x60f089:24), a                                 ; FABF18  f2 89 f0 60 41
	ld W,(XBC+0x03)                                      ; FABF1D  89 03 20
	ld (0x60f08a:24), w                                 ; FABF20  f2 8a f0 60 40
	push XIX                                             ; FABF25  3c
	calr Queue2C00_FanOutToPartMask_Publish                                      ; FABF26  1e 46 ff
	jrl MidiIn_ControlRecordHandlers_Code_Join                                             ; FABF29  78 b0 00
.LFABF2C:
	ld C,H                                               ; FABF2C  ce 8b
	extz BC                                              ; FABF2E  d9 12
	extz XBC                                             ; FABF30  e9 12
	sub BC,0x00b2                                        ; FABF32  d9 ca b2 00
	cp BC,0x000b                                         ; FABF36  d9 cf 0b 00
	jrl ugt, MidiIn_ControlRecordHandlers_Code_Skip                                        ; FABF3A  7b a0 00
	sll bc, 0x02                                         ; FABF3D  d9 ee 02
	add XBC,MidiIn_ControlRecordHandlers                 ; FABF40  e9 c8 4a bf fa 00
	ld XBC,(XBC)                                         ; FABF46  a1 21
	jp (xbc)                                             ; FABF48  b1 d8
; ---------------------------------------------------------------------
; MidiIn_ControlRecordHandlers -- 12 LE32 branch targets, first case 0xB2
;
; Read by: ONE site, the `add XBC,0x00FABF4A / ld XBC,(XBC) / jp T,XBC` at
;          0xFABF40-0xFABF48.
; Inputs:  BC = (selector - 0xB2) * 4; the `sub BC,0x00b2` at 0xFABF32 is what
;          makes 0xB2 the first case.
; ENTRY COUNT 12: the reader's own `cp BC,0x000b` at 0xFABF36.  ★ LAST-ENTRY
;          TEST: 0xFABF4A + 12*4 = 0xFABF7A, where the decode resynchronises.
;          Selectors outside 0xB2..0xBD take `jrl UGT,0xFABFDD`.
; Evidence: the fixed reader shape in the ten bytes before the base plus the
;          count from its own `cp BC,0x000B`; re-derived by
;          notes/prom_a_byte_checks.py and notes/prom_a_jumptables.py.
; ★ Renamed from `JumpTable_FABF4A` in round 10 (framed -> content) by notes/prom_a_census_round8.py:
; its one reader is now named: MidiIn_ControlRecord_Dispatch reaches
; it at 0xFABF40 with (record byte - 0xB2) * 4, so the twelve entries
; ARE the handlers of a control record and the name can say so instead
; of naming the address. Entry count, first case and last-entry test
; are unchanged and stay in the header above
; ---------------------------------------------------------------------
MidiIn_ControlRecordHandlers:
	.long MidiIn_CtrlRec_B2_CC01_Modulation                                 ; FABF4A  [  0]
	.long MidiIn_CtrlRec_B3_CC0B_Expression                                 ; FABF4E  [  1]
	.long MidiIn_CtrlRec_B4_ChannelPressure                                 ; FABF52  [  2]
	.long MidiIn_CtrlRec_B5_CC40_Hold                                 ; FABF56  [  3]
	.long MidiIn_ControlRecordHandlers_Code_Skip     ; FABF5A  [  4]
	.long MidiIn_ControlRecordHandlers_Code_Skip     ; FABF5E  [  5]
	.long MidiIn_CtrlRec_B8_CC10_RTCreatX                                 ; FABF62  [  6]
	.long MidiIn_CtrlRec_B9_CC11_RTCreatY                                 ; FABF66  [  7]
	.long MidiIn_CtrlRec_BA_CC12_RTCtrlX                                 ; FABF6A  [  8]
	.long MidiIn_CtrlRec_BB_CC13_RTCtrlY                                 ; FABF6E  [  9]
	.long MidiIn_CtrlRec_BC_CC02_Modulation2                                 ; FABF72  [ 10]
	.long MidiIn_CtrlRec_BD_CC04_CtrlPedal                                 ; FABF76  [ 11]
MidiIn_CtrlRec_B2_CC01_Modulation:   ; entry: named by 1 `.long` operand, first at 0xFABF4A
	ld xix, (ParamMsg_PartMask_Modulation:24)                               ; FABF7A  e2 84 f2 60 24
	jr .LFABFBE                                          ; FABF7F  68 3d
MidiIn_CtrlRec_BC_CC02_Modulation2:   ; entry: named by 1 `.long` operand, first at 0xFABF72
	ld xix, (ParamMsg_PartMask_Modulation2:24)                               ; FABF81  e2 88 f2 60 24
	jr .LFABFBE                                          ; FABF86  68 36
MidiIn_CtrlRec_B8_CC10_RTCreatX:   ; entry: named by 1 `.long` operand, first at 0xFABF62
	ld xix, (ParamMsg_PartMask_RTCreatX:24)                               ; FABF88  e2 98 f2 60 24
	jr .LFABFBE                                          ; FABF8D  68 2f
MidiIn_CtrlRec_B9_CC11_RTCreatY:   ; entry: named by 1 `.long` operand, first at 0xFABF66
	ld xix, (ParamMsg_PartMask_RTCreatY:24)                               ; FABF8F  e2 9c f2 60 24
	jr .LFABFBE                                          ; FABF94  68 28
MidiIn_CtrlRec_BA_CC12_RTCtrlX:   ; entry: named by 1 `.long` operand, first at 0xFABF6A
	ld xix, (ParamMsg_PartMask_RTCtrlX:24)                               ; FABF96  e2 a0 f2 60 24
	jr .LFABFBE                                          ; FABF9B  68 21
MidiIn_CtrlRec_BB_CC13_RTCtrlY:   ; entry: named by 1 `.long` operand, first at 0xFABF6E
	ld xix, (ParamMsg_PartMask_RTCtrlY:24)                               ; FABF9D  e2 a4 f2 60 24
	jr .LFABFBE                                          ; FABFA2  68 1a
MidiIn_CtrlRec_B4_ChannelPressure:   ; entry: named by 1 `.long` operand, first at 0xFABF52
	ld xix, (ParamMsg_PartMask_ChannelPressure:24)                               ; FABFA4  e2 8c f2 60 24
	jr .LFABFBE                                          ; FABFA9  68 13
MidiIn_CtrlRec_BD_CC04_CtrlPedal:   ; entry: named by 1 `.long` operand, first at 0xFABF76
	ld xix, (ParamMsg_PartMask_CtrlPedal:24)                               ; FABFAB  e2 90 f2 60 24
	jr .LFABFBE                                          ; FABFB0  68 0c
MidiIn_CtrlRec_B5_CC40_Hold:   ; entry: named by 1 `.long` operand, first at 0xFABF56
	ld xix, (ParamMsg_PartMask_Hold:24)                               ; FABFB2  e2 94 f2 60 24
	jr .LFABFBE                                          ; FABFB7  68 05
MidiIn_CtrlRec_B3_CC0B_Expression:   ; entry: named by 1 `.long` operand, first at 0xFABF4E
	ld xix, (ParamMsg_PartMask_Expression:24)                               ; FABFB9  e2 a8 f2 60 24
.LFABFBE:
	ld XBC,(XIZ+0x08)                                    ; FABFBE  ae 08 21
	ld A,(XBC)                                           ; FABFC1  81 21
	ld (0x60f080:24), a                                 ; FABFC3  f2 80 f0 60 41
	ld W,(XBC+0x02)                                      ; FABFC8  89 02 20
	ld (0x60f089:24), w                                 ; FABFCB  f2 89 f0 60 40
	ld A,(XBC+0x03)                                      ; FABFD0  89 03 21
	ld (0x60f08a:24), a                                 ; FABFD3  f2 8a f0 60 41
	push XIX                                             ; FABFD8  3c
	calr Queue2C00_FanOutToPartMask                                          ; FABFD9  1e 4f fe
MidiIn_ControlRecordHandlers_Code_Join:
	pop XIY                                              ; FABFDC  5d
MidiIn_ControlRecordHandlers_Code_Skip:
	pop XIX                                              ; FABFDD  5c
	popw hl                                              ; FABFDE  4b
	unlk XIZ                                             ; FABFDF  ee 0d
	ret                                                  ; FABFE1  0e
; ParamMsg_RefreshPartMasks -- recompute the eleven per-controller part masks and make MIDI out / MIDI in catch up
; Evidence: `or (0x60f0c6),1` at 0xFABFE8, calr ParamMsg_ComputePartMasks, `and (XIX),0xfe`, then `call T_MidiOut_ResyncChangedParts` at 0xFABFF5 -- prom_a MidiOut_ResyncChangedParts, the MidiOut 'send everything again' entry that ends in MidiIn_RebuildPartLists.
; Called from: prom_b directory slot T_ParamMsg_RefreshPartMasks (call at 0xFC6198) and ParamMsg_RefreshMasksOnCtrlFieldChange (0xFAC7BF).
ParamMsg_RefreshPartMasks:
	push XIX                                             ; FABFE2  3c
	lda xix, (0x60f0c6:24)                               ; FABFE3  f2 c6 f0 60 34
	or	(xix), 0x01                                  ; FABFE8  84 3e 01
	calr ParamMsg_ComputePartMasks                                      ; FABFEB  1e 0c 01
	and (XIX),0xfe                                       ; FABFEE  84 3c fe
	push XDE                                             ; FABFF1  3a
	push XHL                                             ; FABFF2  3b
	push XIX                                             ; FABFF3  3c
	push XIZ                                             ; FABFF4  3e
	call T_MidiOut_ResyncChangedParts                                        ; FABFF5  1d 60 07 f4
	pop XIZ                                              ; FABFF9  5e
	pop XIX                                              ; FABFFA  5c
	pop XHL                                              ; FABFFB  5b
	pop XDE                                              ; FABFFC  5a
	pop XIX                                              ; FABFFD  5c
	ret                                                  ; FABFFE  0e
; ParamMsg_ResendTwoAssignedCtrls -- re-dispatch the current values of cooked control slots (0x2503) and (0x2504) as control records for the controllers assigned in (0x7F27) and (0x7F28)
; Evidence: the 4-byte local record is initialised from Gap_FAC8E6 (`ld XBC,(0xfac8e6)` at 0xFAC007, bytes {0,0,0,0x7F}); byte 0 := ParamMsg_NumberForController((0x7F27)), byte 2 := (0x2503) & 0x7F, then MidiIn_ControlRecord_Dispatch (0xFAC024); again with (0x7F28)/(0x2504) at 0xFAC027-0xFAC03C.
; MidiOut's sub_FA7E37 pairs the same two cells with the same two assignment bytes.  Called from: prom_b directory slot T_ParamMsg_ResendTwoAssignedCtrls; no converted caller found.
ParamMsg_ResendTwoAssignedCtrls:
	link XIZ,0xfffc                                      ; FABFFF  ee 0c fc ff
	push XIX                                             ; FAC003  3c
	lda xix, (xiz-4)                                     ; FAC004  be fc 34
	ld xbc, (Gap_FAC8E6:24)                               ; FAC007  e2 e6 c8 fa 21
	ld (xiz-4), xbc                                      ; FAC00C  be fc 61
	ld a, (0x7f27:16)                                   ; FAC00F  c1 27 7f 21
	pushw wa                                             ; FAC013  28
	calr ParamMsg_NumberForController                                      ; FAC014  1e 74 02
	ld (XIX),A                                           ; FAC017  b4 41
	ld c, (0x2503:16)                                   ; FAC019  c1 03 25 23
	res 0x07,C                                           ; FAC01D  cb 30 07
	ld (XIX+0x02),C                                      ; FAC020  bc 02 43
	push XIX                                             ; FAC023  3c
	calr MidiIn_ControlRecord_Dispatch                                          ; FAC024  1e d4 fe
	ld c, (0x7f28:16)                                   ; FAC027  c1 28 7f 23
	pushw bc                                             ; FAC02B  29
	calr ParamMsg_NumberForController                                      ; FAC02C  1e 5c 02
	ld (XIX),A                                           ; FAC02F  b4 41
	ld c, (0x2504:16)                                   ; FAC031  c1 04 25 23
	res 0x07,C                                           ; FAC035  cb 30 07
	ld (XIX+0x02),C                                      ; FAC038  bc 02 43
	push XIX                                             ; FAC03B  3c
	calr MidiIn_ControlRecord_Dispatch                                          ; FAC03C  1e bc fe
	inc 8,XSP                                            ; FAC03F  ef 60
	inc 4,XSP                                            ; FAC041  ef 64
	pop XIX                                              ; FAC043  5c
	unlk XIZ                                             ; FAC044  ee 0d
	ret                                                  ; FAC046  0e
	push XIX                                             ; FAC047  3c
	lda xix, (.LFAC391:24)                               ; FAC048  f2 91 c3 fa 34
	lda xbc, (0x24f4:16)                                ; FAC04D  f1 f4 24 31
	push XBC                                             ; FAC051  39
	pushw 0xb1                                           ; FAC052  0b b1 00
	lda xiy, (.LFAC05D:24)                               ; FAC055  f2 5d c0 fa 35
	push XIY                                             ; FAC05A  3d
	jp (xix)                                             ; FAC05B  b4 d8
.LFAC05D:
	pushw 0xb2                                           ; FAC05D  0b b2 00
	calr Ctrl_CookedCellForNumber                                      ; FAC060  1e a0 02
	inc 8,XSP                                            ; FAC063  ef 60
	push XIY                                             ; FAC065  3d
	ld c, (0x7f23:16)                                   ; FAC066  c1 23 7f 23
	pushw bc                                             ; FAC06A  29
	calr ParamMsg_NumberForController                                      ; FAC06B  1e 1d 02
	popw bc                                              ; FAC06E  49
	pushw wa                                             ; FAC06F  28
	lda xiy, (.LFAC078:24)                               ; FAC070  f2 78 c0 fa 35
	push XIY                                             ; FAC075  3d
	jp (xix)                                             ; FAC076  b4 d8
.LFAC078:
	pushw 0xbc                                           ; FAC078  0b bc 00
	calr Ctrl_CookedCellForNumber                                      ; FAC07B  1e 85 02
	inc 8,XSP                                            ; FAC07E  ef 60
	push XIY                                             ; FAC080  3d
	ld c, (0x7f24:16)                                   ; FAC081  c1 24 7f 23
	pushw bc                                             ; FAC085  29
	calr ParamMsg_NumberForController                                      ; FAC086  1e 02 02
	popw bc                                              ; FAC089  49
	pushw wa                                             ; FAC08A  28
	lda xiy, (.LFAC093:24)                               ; FAC08B  f2 93 c0 fa 35
	push XIY                                             ; FAC090  3d
	jp (xix)                                             ; FAC091  b4 d8
.LFAC093:
	pushw 0xba                                           ; FAC093  0b ba 00
	calr Ctrl_CookedCellForNumber                                      ; FAC096  1e 6a 02
	inc 8,XSP                                            ; FAC099  ef 60
	push XIY                                             ; FAC09B  3d
	ld c, (0x7f29:16)                                   ; FAC09C  c1 29 7f 23
	pushw bc                                             ; FAC0A0  29
	calr ParamMsg_NumberForController                                      ; FAC0A1  1e e7 01
	popw bc                                              ; FAC0A4  49
	pushw wa                                             ; FAC0A5  28
	lda xiy, (.LFAC0AE:24)                               ; FAC0A6  f2 ae c0 fa 35
	push XIY                                             ; FAC0AB  3d
	jp (xix)                                             ; FAC0AC  b4 d8
.LFAC0AE:
	pushw 0xbb                                           ; FAC0AE  0b bb 00
	calr Ctrl_CookedCellForNumber                                      ; FAC0B1  1e 4f 02
	inc 8,XSP                                            ; FAC0B4  ef 60
	push XIY                                             ; FAC0B6  3d
	ld c, (0x7f2a:16)                                   ; FAC0B7  c1 2a 7f 23
	pushw bc                                             ; FAC0BB  29
	calr ParamMsg_NumberForController                                      ; FAC0BC  1e cc 01
	popw bc                                              ; FAC0BF  49
	pushw wa                                             ; FAC0C0  28
	lda xiy, (.LFAC0C9:24)                               ; FAC0C1  f2 c9 c0 fa 35
	push XIY                                             ; FAC0C6  3d
	jp (xix)                                             ; FAC0C7  b4 d8
.LFAC0C9:
	lda xbc, (0x24ff:16)                                ; FAC0C9  f1 ff 24 31
	push XBC                                             ; FAC0CD  39
	pushw 0xb4                                           ; FAC0CE  0b b4 00
	lda xiy, (.LFAC0D9:24)                               ; FAC0D1  f2 d9 c0 fa 35
	push XIY                                             ; FAC0D6  3d
	jp (xix)                                             ; FAC0D7  b4 d8
.LFAC0D9:
	pushw 0xbd                                           ; FAC0D9  0b bd 00
	calr Ctrl_CookedCellForNumber                                      ; FAC0DC  1e 24 02
	inc 8,XSP                                            ; FAC0DF  ef 60
	inc 6,XSP                                            ; FAC0E1  ef 66
	push XIY                                             ; FAC0E3  3d
	ld c, (0x7f14:16)                                   ; FAC0E4  c1 14 7f 23
	pushw bc                                             ; FAC0E8  29
	calr ParamMsg_NumberForController                                      ; FAC0E9  1e 9f 01
	popw bc                                              ; FAC0EC  49
	pushw wa                                             ; FAC0ED  28
	lda xiy, (.LFAC0F6:24)                               ; FAC0EE  f2 f6 c0 fa 35
	push XIY                                             ; FAC0F3  3d
	jp (xix)                                             ; FAC0F4  b4 d8
.LFAC0F6:
	inc 6,XSP                                            ; FAC0F6  ef 66
	pop XIX                                              ; FAC0F8  5c
	ret                                                  ; FAC0F9  0e
; ParamMsg_ComputePartMasks -- save the eleven 32-bit per-controller part masks at 0x60F280..0x60F2A8 to 0x60F2AC.., clear them and rebuild them from the part records
; Evidence: copy-and-zero loop 0xFAC100-0xFAC12F (XIX up to 0x60F2A8); then for each part H with bit H of (0x4C06) set and bit 5 of first-half byte +0x0D clear, BitMask32_Table[H] is ORed into a cell per bit of the second-half record (ParamNumber_GetRecordPtr(H|0x20)):
; +0x0B b6 -> F280 (B1), +0x0C b1 -> F284 (B2), +0x0E b4 -> F288 (BC), +0x0B b5 -> F28C (B4), +0x0E b5 -> F290 (BD), +0x0C b0 -> F294 (B5), +0x0E b0..b3 -> F298..F2A4 (B8..BB), and F2A8 (B3) unconditionally (0xFAC13F-0xFAC283).
; Cell -> number: the table in ParamMsg_B1_PitchBend's header.  Called only from ParamMsg_RefreshPartMasks.
ParamMsg_ComputePartMasks:
	link XIZ,0xfff4                                      ; FAC0FA  ee 0c f4 ff
	pushw hl                                             ; FAC0FE  2b
	push XIX                                             ; FAC0FF  3c
	lda xix, (ParamMsg_PartMask_PitchBend:24)                               ; FAC100  f2 80 f2 60 34
	lda xbc, (ParamMsg_PartMaskPrev_PitchBend:24)                               ; FAC105  f2 ac f2 60 31
	ld (xiz-4), xbc                                      ; FAC10A  be fc 61
.LFAC10D:
	lda xbc, (ParamMsg_PartMask_Expression:24)                               ; FAC10D  f2 a8 f2 60 31
	ld (xiz-12), xbc                                     ; FAC112  be f4 61
	ld XWA,XIX                                           ; FAC115  ec 88
	cp XWA,XBC                                           ; FAC117  e9 f0
	jr ugt, .LFAC131                                     ; FAC119  6b 16
	ld XBC,(XIX)                                         ; FAC11B  a4 21
	ld xwa, (xiz-4)                                      ; FAC11D  ae fc 20
	ld (XWA),XBC                                         ; FAC120  b0 61
	sub XBC,XBC                                          ; FAC122  e9 a1
	ld (XIX),XBC                                         ; FAC124  b4 61
	inc 4,XIX                                            ; FAC126  ec 64
	sub XBC,XBC                                          ; FAC128  e9 a1
	inc 4,XBC                                            ; FAC12A  e9 64
	add (xiz-4), xbc                                     ; FAC12C  ae fc 89
	jr .LFAC10D                                          ; FAC12F  68 dc
.LFAC131:
	ld xbc, (NoteRouting_ActivePartMask:16)                                 ; FAC131  e1 06 4c 21
	ld (xiz-8), xbc                                      ; FAC135  be f8 61
	ld XIX,0x00000000                                    ; FAC138  44 00 00 00 00
	ld h, 0x00:opc                                          ; FAC13D  26 00
.LFAC13F:
	ld xbc, (xiz-8)                                      ; FAC13F  ae f8 21
	and XBC,0x00000001                                   ; FAC142  e9 cc 01 00 00 00
	jrl z, .LFAC273                                      ; FAC148  76 28 01
	push 0x00                                            ; FAC14B  09 00
	push H                                               ; FAC14D  ce 04
	calr ParamNumber_GetRecordPtr                                          ; FAC14F  1e 58 07
	ld (xiz-12), xiy                                     ; FAC152  be f4 65
	ld C,H                                               ; FAC155  ce 8b
	set 0x05,C                                           ; FAC157  cb 31 05
	pushw bc                                             ; FAC15A  29
	calr ParamNumber_GetRecordPtr                                          ; FAC15B  1e 4c 07
	ld (xiz-4), xiy                                      ; FAC15E  be fc 65
	ld xbc, (xiz-12)                                     ; FAC161  ae f4 21
	ld A,(XBC+0x0d)                                      ; FAC164  89 0d 21
	and A,0x20                                           ; FAC167  c9 cc 20
	pop XBC                                              ; FAC16A  59
	jrl nz, .LFAC273                                     ; FAC16B  7e 05 01
	ld C,(XIY+0x0b)                                      ; FAC16E  8d 0b 23
	and C,0x40                                           ; FAC171  cb cc 40
	jr z, .LFAC184                                       ; FAC174  66 0e
	lda xbc, (BitMask32_Table:24)                        ; FAC176  f2 0a d2 fa 31
	add XBC,XIX                                          ; FAC17B  ec 81
	ld XWA,(XBC)                                         ; FAC17D  a1 20
	or	(ParamMsg_PartMask_PitchBend:24), xwa                   ; FAC17F  e2 80 f2 60 e8
.LFAC184:
	ld xbc, (xiz-4)                                      ; FAC184  ae fc 21
	ld A,(XBC+0x0c)                                      ; FAC187  89 0c 21
	and A,0x02                                           ; FAC18A  c9 cc 02
	jr z, .LFAC19D                                       ; FAC18D  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC18F  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC194  ec 80
	ld XIY,(XWA)                                         ; FAC196  a0 25
	or (ParamMsg_PartMask_Modulation),xiy                                    ; FAC198  e2 84 f2 60 ed   or (0x60f284),XIY
.LFAC19D:
	ld xbc, (xiz-4)                                      ; FAC19D  ae fc 21
	ld A,(XBC+0x0e)                                      ; FAC1A0  89 0e 21
	and A,0x10                                           ; FAC1A3  c9 cc 10
	jr z, .LFAC1B6                                       ; FAC1A6  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC1A8  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC1AD  ec 80
	ld XIY,(XWA)                                         ; FAC1AF  a0 25
	or (ParamMsg_PartMask_Modulation2),xiy                                    ; FAC1B1  e2 88 f2 60 ed   or (0x60f288),XIY
.LFAC1B6:
	ld xbc, (xiz-4)                                      ; FAC1B6  ae fc 21
	ld A,(XBC+0x0b)                                      ; FAC1B9  89 0b 21
	and A,0x20                                           ; FAC1BC  c9 cc 20
	jr z, .LFAC1CF                                       ; FAC1BF  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC1C1  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC1C6  ec 80
	ld XIY,(XWA)                                         ; FAC1C8  a0 25
	or (ParamMsg_PartMask_ChannelPressure),xiy                                    ; FAC1CA  e2 8c f2 60 ed   or (0x60f28c),XIY
.LFAC1CF:
	ld xbc, (xiz-4)                                      ; FAC1CF  ae fc 21
	ld A,(XBC+0x0e)                                      ; FAC1D2  89 0e 21
	and A,0x20                                           ; FAC1D5  c9 cc 20
	jr z, .LFAC1E8                                       ; FAC1D8  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC1DA  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC1DF  ec 80
	ld XIY,(XWA)                                         ; FAC1E1  a0 25
	or (ParamMsg_PartMask_CtrlPedal),xiy                                    ; FAC1E3  e2 90 f2 60 ed   or (0x60f290),XIY
.LFAC1E8:
	ld xbc, (xiz-4)                                      ; FAC1E8  ae fc 21
	ld A,(XBC+0x0c)                                      ; FAC1EB  89 0c 21
	and A,0x01                                           ; FAC1EE  c9 cc 01
	jr z, .LFAC201                                       ; FAC1F1  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC1F3  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC1F8  ec 80
	ld XIY,(XWA)                                         ; FAC1FA  a0 25
	or (ParamMsg_PartMask_Hold),xiy                                    ; FAC1FC  e2 94 f2 60 ed   or (0x60f294),XIY
.LFAC201:
	ld xbc, (xiz-4)                                      ; FAC201  ae fc 21
	ld A,(XBC+0x0e)                                      ; FAC204  89 0e 21
	and A,0x01                                           ; FAC207  c9 cc 01
	jr z, .LFAC21A                                       ; FAC20A  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC20C  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC211  ec 80
	ld XIY,(XWA)                                         ; FAC213  a0 25
	or (ParamMsg_PartMask_RTCreatX),xiy                                    ; FAC215  e2 98 f2 60 ed   or (0x60f298),XIY
.LFAC21A:
	ld xbc, (xiz-4)                                      ; FAC21A  ae fc 21
	ld A,(XBC+0x0e)                                      ; FAC21D  89 0e 21
	and A,0x02                                           ; FAC220  c9 cc 02
	jr z, .LFAC233                                       ; FAC223  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC225  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC22A  ec 80
	ld XIY,(XWA)                                         ; FAC22C  a0 25
	or (ParamMsg_PartMask_RTCreatY),xiy                                    ; FAC22E  e2 9c f2 60 ed   or (0x60f29c),XIY
.LFAC233:
	ld xbc, (xiz-4)                                      ; FAC233  ae fc 21
	ld A,(XBC+0x0e)                                      ; FAC236  89 0e 21
	and A,0x04                                           ; FAC239  c9 cc 04
	jr z, .LFAC24C                                       ; FAC23C  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC23E  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC243  ec 80
	ld XIY,(XWA)                                         ; FAC245  a0 25
	or (ParamMsg_PartMask_RTCtrlX),xiy                                    ; FAC247  e2 a0 f2 60 ed   or (0x60f2a0),XIY
.LFAC24C:
	ld xbc, (xiz-4)                                      ; FAC24C  ae fc 21
	ld A,(XBC+0x0e)                                      ; FAC24F  89 0e 21
	and A,0x08                                           ; FAC252  c9 cc 08
	jr z, .LFAC265                                       ; FAC255  66 0e
	lda xwa, (BitMask32_Table:24)                        ; FAC257  f2 0a d2 fa 30
	add XWA,XIX                                          ; FAC25C  ec 80
	ld XIY,(XWA)                                         ; FAC25E  a0 25
	or (ParamMsg_PartMask_RTCtrlY),xiy                                    ; FAC260  e2 a4 f2 60 ed   or (0x60f2a4),XIY
.LFAC265:
	lda xbc, (BitMask32_Table:24)                        ; FAC265  f2 0a d2 fa 31
	add XBC,XIX                                          ; FAC26A  ec 81
	ld XWA,(XBC)                                         ; FAC26C  a1 20
	or	(ParamMsg_PartMask_Expression:24), xwa                   ; FAC26E  e2 a8 f2 60 e8
.LFAC273:
	inc 4,XIX                                            ; FAC273  ec 64
	inc 1,H                                              ; FAC275  ce 61
	ld xiy, (xiz-8)                                      ; FAC277  ae f8 25
	srl xiy, 0x01                                        ; FAC27A  ed ef 01
	ld (xiz-8), xiy                                      ; FAC27D  be f8 65
	cp H,0x1f                                            ; FAC280  ce cf 1f
	jrl ule, .LFAC13F                                    ; FAC283  73 b9 fe
	pop XIX                                              ; FAC286  5c
	popw hl                                              ; FAC287  4b
	unlk XIZ                                             ; FAC288  ee 0d
	ret                                                  ; FAC28A  0e
; ParamMsg_NumberForController -- map a controller number (stack word) to its parameter number in A: 1->0xB2, 2->0xBC, 4->0xBD, 0x0B->0xB3, 0x10..0x13->0xB8..0xBB, 0x40->0xB5, 0x81->0xB4, 0x82->0xB1, anything else 0xFF
; Evidence: the compare chain at 0xFAC294-0xFAC2CA and the `ld A,0xbN` arms at 0xFAC2D2-0xFAC2FE.  Every pair agrees with the controller already named on ParamMsg_B1..ParamMsg_BD (e.g. ParamMsg_BA_CC12_RTCtrlX for 0x12); 0x81/0x82 are this table's pseudo-numbers for channel pressure and pitch bend.
; Called from: ParamMsg_ResendTwoAssignedCtrls and the unlabelled routine at 0xFAC047.
ParamMsg_NumberForController:
	link XIZ,0x0000                                      ; FAC28B  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FAC28F  9e 08 21
	extz BC                                              ; FAC292  d9 12
	cp bc, 0x01:i3                                         ; FAC294  d9 d9
	jr z, .LFAC2D6                                       ; FAC296  66 3e
	cp bc, 0x02:i3                                         ; FAC298  d9 da
	jr z, .LFAC2DA                                       ; FAC29A  66 3e
	cp bc, 0x04:i3                                         ; FAC29C  d9 dc
	jr z, .LFAC2DE                                       ; FAC29E  66 3e
	cp BC,0x000b                                         ; FAC2A0  d9 cf 0b 00
	jr z, .LFAC2E2                                       ; FAC2A4  66 3c
	cp BC,0x0010                                         ; FAC2A6  d9 cf 10 00
	jr z, .LFAC2E6                                       ; FAC2AA  66 3a
	cp BC,0x0011                                         ; FAC2AC  d9 cf 11 00
	jr z, .LFAC2EA                                       ; FAC2B0  66 38
	cp BC,0x0012                                         ; FAC2B2  d9 cf 12 00
	jr z, .LFAC2EE                                       ; FAC2B6  66 36
	cp BC,0x0013                                         ; FAC2B8  d9 cf 13 00
	jr z, .LFAC2F2                                       ; FAC2BC  66 34
	cp BC,0x0040                                         ; FAC2BE  d9 cf 40 00
	jr z, .LFAC2F6                                       ; FAC2C2  66 32
	cp BC,0x0081                                         ; FAC2C4  d9 cf 81 00
	jr z, .LFAC2FA                                       ; FAC2C8  66 30
	cp BC,0x0082                                         ; FAC2CA  d9 cf 82 00
	jr z, .LFAC2D2                                       ; FAC2CE  66 02
	jr .LFAC2FE                                          ; FAC2D0  68 2c
.LFAC2D2:
	ld a, 0xb1:opc                                          ; FAC2D2  21 b1
	jr .LFAC300                                          ; FAC2D4  68 2a
.LFAC2D6:
	ld a, 0xb2:opc                                          ; FAC2D6  21 b2
	jr .LFAC300                                          ; FAC2D8  68 26
.LFAC2DA:
	ld a, 0xbc:opc                                          ; FAC2DA  21 bc
	jr .LFAC300                                          ; FAC2DC  68 22
.LFAC2DE:
	ld a, 0xbd:opc                                          ; FAC2DE  21 bd
	jr .LFAC300                                          ; FAC2E0  68 1e
.LFAC2E2:
	ld a, 0xb3:opc                                          ; FAC2E2  21 b3
	jr .LFAC300                                          ; FAC2E4  68 1a
.LFAC2E6:
	ld a, 0xb8:opc                                          ; FAC2E6  21 b8
	jr .LFAC300                                          ; FAC2E8  68 16
.LFAC2EA:
	ld a, 0xb9:opc                                          ; FAC2EA  21 b9
	jr .LFAC300                                          ; FAC2EC  68 12
.LFAC2EE:
	ld a, 0xba:opc                                          ; FAC2EE  21 ba
	jr .LFAC300                                          ; FAC2F0  68 0e
.LFAC2F2:
	ld a, 0xbb:opc                                          ; FAC2F2  21 bb
	jr .LFAC300                                          ; FAC2F4  68 0a
.LFAC2F6:
	ld a, 0xb5:opc                                          ; FAC2F6  21 b5
	jr .LFAC300                                          ; FAC2F8  68 06
.LFAC2FA:
	ld a, 0xb4:opc                                          ; FAC2FA  21 b4
	jr .LFAC300                                          ; FAC2FC  68 02
.LFAC2FE:
	ld a, 0xff:opc                                          ; FAC2FE  21 ff
.LFAC300:
	unlk XIZ                                             ; FAC300  ee 0d
	ret                                                  ; FAC302  0e
; Ctrl_CookedCellForNumber -- return in XIY the address of the cooked control value (Ctrl_Normalise's RAM bank) that feeds parameter number (XIZ+8), 0xB1..0xBD
; Evidence: `sub BC,0x00b1 / cp BC,0x000c` at 0xFAC30E-0xFAC312 then Ctrl_CookedCellNumberHandlers; the arms load 0x24F4 (B1), 0x24FF (B4), 0x2503..0x2506 (B8..BB), 0x24F6 (BC), 0x24F2 (BD), and the default arm 0x24F5 (B2, B3, B5..B7).  All ten are listed as cooked values in Ctrl_Normalise's header.
; Used by the unlabelled routine at 0xFAC047, which hands each cell to the JumpTable_FAC3BF dispatcher at 0xFAC391.
Ctrl_CookedCellForNumber:
	link XIZ,0x0000                                      ; FAC303  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FAC307  9e 08 21
	extz BC                                              ; FAC30A  d9 12
	extz XBC                                             ; FAC30C  e9 12
	sub BC,0x00b1                                        ; FAC30E  d9 ca b1 00
	cp BC,0x000c                                         ; FAC312  d9 cf 0c 00
	jrl ugt, Ctrl_CookedCellFor_Default                                        ; FAC316  7b 71 00
	sll bc, 0x02                                         ; FAC319  d9 ee 02
	add XBC,Ctrl_CookedCellNumberHandlers                             ; FAC31C  e9 c8 26 c3 fa 00
	ld XBC,(XBC)                                         ; FAC322  a1 21
	jp (xbc)                                             ; FAC324  b1 d8
; ---------------------------------------------------------------------
; Ctrl_CookedCellNumberHandlers -- 13 LE32 branch targets, first case 0xB1
;
; Read by: ONE site, the `add XBC,0x00FAC326 / ld XBC,(XBC) / jp T,XBC` at
;          0xFAC31C-0xFAC324.
; Inputs:  BC = (selector - 0xB1) * 4, selector = the byte at (XIZ+0x08).
; ENTRY COUNT 13: the reader's own `cp BC,0x000c` at 0xFAC312.  ★ LAST-ENTRY
;          TEST: 0xFAC326 + 13*4 = 0xFAC35A, and the byte there is
;          `f1 f4 24 35` = `lda XIY,0x24f4`, the next instruction of the
;          routine; 12 entries would end at 0xFAC356 and 14 at 0xFAC35E, and
;          neither is an instruction boundary.  This is the pair the selftest
;          of notes/prom_a_jumptables.py asserts, with both negative controls.
; Evidence: the fixed reader shape in the ten bytes before the base plus the
;          count from its own `cp BC,0x000C`, and the last-entry test above;
;          re-derived by notes/prom_a_byte_checks.py and
;          notes/prom_a_jumptables.py (whose selftest is this table).
; ---------------------------------------------------------------------
; Ctrl_CookedCellNumberHandlers: Ctrl_CookedCellForNumber's switch on parameter number - 0xB1 (0xB1..0xBD): each arm
;   loads XIY = that number's cooked control cell; numbers with no cell of their own take Ctrl_CookedCellFor_Default.
;   Basis: table index (the reader's `sub BC,0xB1`) + its named arms. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
Ctrl_CookedCellNumberHandlers:
	.long Ctrl_CookedCellFor_B1                                 ; FAC326  [  0]
	.long Ctrl_CookedCellFor_Default                 ; FAC32A  [  1]
	.long Ctrl_CookedCellFor_Default                 ; FAC32E  [  2]
	.long Ctrl_CookedCellFor_B4                                 ; FAC332  [  3]
	.long Ctrl_CookedCellFor_Default                 ; FAC336  [  4]
	.long Ctrl_CookedCellFor_Default                 ; FAC33A  [  5]
	.long Ctrl_CookedCellFor_Default                 ; FAC33E  [  6]
	.long Ctrl_CookedCellFor_B8                                 ; FAC342  [  7]
	.long Ctrl_CookedCellFor_B9                                 ; FAC346  [  8]
	.long Ctrl_CookedCellFor_BA                                 ; FAC34A  [  9]
	.long Ctrl_CookedCellFor_BB                                 ; FAC34E  [ 10]
	.long Ctrl_CookedCellFor_BC                                 ; FAC352  [ 11]
	.long Ctrl_CookedCellFor_BD                                 ; FAC356  [ 12]
; Ctrl_CookedCellFor_B1 -- Ctrl_CookedCellNumberHandlers[0] (number 0xB1): XIY = 0x24F4, then the shared `unlk/ret` of Ctrl_CookedCellForNumber
; Evidence: `lda XIY,0x24f4` at 0xFAC35A; 0x24F4 is cooked slot 3.1 (curve 0xF89CB4, idle 0x80) in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_B1:   ; entry: named by 1 `.long` operand, first at 0xFAC326
	lda xiy, (0x24f4:16)                                ; FAC35A  f1 f4 24 35
	jr .LFAC38E                                          ; FAC35E  68 2e
; Ctrl_CookedCellFor_BC -- Ctrl_CookedCellNumberHandlers[11] (number 0xBC): XIY = 0x24F6, then the shared `unlk/ret`
; Evidence: `lda XIY,0x24f6` at 0xFAC360; 0x24F6 is cooked slot 3.2 in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_BC:   ; entry: named by 1 `.long` operand, first at 0xFAC352
	lda xiy, (0x24f6:16)                                ; FAC360  f1 f6 24 35
	jr .LFAC38E                                          ; FAC364  68 28
; Ctrl_CookedCellFor_BD -- Ctrl_CookedCellNumberHandlers[12] (number 0xBD): XIY = 0x24F2, then the shared `unlk/ret`
; Evidence: `lda XIY,0x24f2` at 0xFAC366; 0x24F2 is cooked slot 0.3 (the inverted raw byte) in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_BD:   ; entry: named by 1 `.long` operand, first at 0xFAC356
	lda xiy, (0x24f2:16)                                ; FAC366  f1 f2 24 35
	jr .LFAC38E                                          ; FAC36A  68 22
; Ctrl_CookedCellFor_B8 -- Ctrl_CookedCellNumberHandlers[7] (number 0xB8): XIY = 0x2503, then the shared `unlk/ret`
; Evidence: `lda XIY,0x2503` at 0xFAC36C; 0x2503 is cooked slot 0.4 in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_B8:   ; entry: named by 1 `.long` operand, first at 0xFAC342
	lda xiy, (0x2503:16)                                ; FAC36C  f1 03 25 35
	jr .LFAC38E                                          ; FAC370  68 1c
; Ctrl_CookedCellFor_B9 -- Ctrl_CookedCellNumberHandlers[8] (number 0xB9): XIY = 0x2504, then the shared `unlk/ret`
; Evidence: `lda XIY,0x2504` at 0xFAC372; 0x2504 is cooked slot 0.5 in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_B9:   ; entry: named by 1 `.long` operand, first at 0xFAC346
	lda xiy, (0x2504:16)                                ; FAC372  f1 04 25 35
	jr .LFAC38E                                          ; FAC376  68 16
; Ctrl_CookedCellFor_BA -- Ctrl_CookedCellNumberHandlers[9] (number 0xBA): XIY = 0x2505, then the shared `unlk/ret`
; Evidence: `lda XIY,0x2505` at 0xFAC378; 0x2505 is cooked slot 0.0 in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_BA:   ; entry: named by 1 `.long` operand, first at 0xFAC34A
	lda xiy, (0x2505:16)                                ; FAC378  f1 05 25 35
	jr .LFAC38E                                          ; FAC37C  68 10
; Ctrl_CookedCellFor_BB -- Ctrl_CookedCellNumberHandlers[10] (number 0xBB): XIY = 0x2506, then the shared `unlk/ret`
; Evidence: `lda XIY,0x2506` at 0xFAC37E; 0x2506 is cooked slot 0.1 in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_BB:   ; entry: named by 1 `.long` operand, first at 0xFAC34E
	lda xiy, (0x2506:16)                                ; FAC37E  f1 06 25 35
	jr .LFAC38E                                          ; FAC382  68 0a
; Ctrl_CookedCellFor_B4 -- Ctrl_CookedCellNumberHandlers[3] (number 0xB4): XIY = 0x24FF, then the shared `unlk/ret`
; Evidence: `lda XIY,0x24ff` at 0xFAC384; 0x24FF is cooked slot 0.2, the calibrated channel, in Ctrl_Normalise's slot table.
Ctrl_CookedCellFor_B4:   ; entry: named by 1 `.long` operand, first at 0xFAC332
	lda xiy, (0x24ff:16)                                ; FAC384  f1 ff 24 35
	jr .LFAC38E                                          ; FAC388  68 04
; Ctrl_CookedCellFor_Default: Ctrl_CookedCellNumberHandlers' default arm (numbers 0xB2, 0xB3, 0xB5..0xB7, and out-of-
;   range): XIY = 0x24F5, the shared cooked cell, then Ctrl_CookedCellForNumber's unlk/ret. Basis: table index + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
Ctrl_CookedCellFor_Default:
	lda xiy, (0x24f5:16)                                ; FAC38A  f1 f5 24 35
.LFAC38E:
	unlk XIZ                                             ; FAC38E  ee 0d
	ret                                                  ; FAC390  0e
.LFAC391:
	link XIZ,0x0000                                      ; FAC391  ee 0c 00 00
	pushw hl                                             ; FAC395  2b
	pushw de                                             ; FAC396  2a
	push XIX                                             ; FAC397  3c
	ld C,(XIZ+0x08)                                      ; FAC398  8e 08 23
	ld (0x60f080:24), c                                 ; FAC39B  f2 80 f0 60 43
	ld BC,(XIZ+0x08)                                     ; FAC3A0  9e 08 21
	extz BC                                              ; FAC3A3  d9 12
	extz XBC                                             ; FAC3A5  e9 12
	sub BC,0x00b1                                        ; FAC3A7  d9 ca b1 00
	cp BC,0x000c                                         ; FAC3AB  d9 cf 0c 00
	jrl ugt, .LFAC780                                      ; FAC3AF  7b ce 03
	sll bc, 0x02                                         ; FAC3B2  d9 ee 02
	add XBC,JumpTable_FAC3BF                             ; FAC3B5  e9 c8 bf c3 fa 00
	ld XBC,(XBC)                                         ; FAC3BB  a1 21
	jp (xbc)                                             ; FAC3BD  b1 d8
; ---------------------------------------------------------------------
; JumpTable_FAC3BF -- 13 LE32 branch targets, first case 0xB1
;
; Read by: ONE site, the `add XBC,0x00FAC3BF / ld XBC,(XBC) / jp T,XBC` at
;          0xFAC3B5-0xFAC3BD.
; Inputs:  BC = (selector - 0xB1) * 4, selector = the byte at (XIZ+0x08),
;          which this routine also stores to (0x60F080) on entry.
; ENTRY COUNT 13: the reader's own `cp BC,0x000c` at 0xFAC3AB.  ★ LAST-ENTRY
;          TEST: 0xFAC3BF + 13*4 = 0xFAC3F3, where the decode resumes with
;          `ld XIX,(0x60f280)`.  Out-of-range selectors take
;          `jrl UGT,0xFAC780`.
; Evidence: the fixed reader shape in the ten bytes before the base plus the
;          count from its own `cp BC,0x000C`, and the last-entry test above;
;          re-derived by notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
JumpTable_FAC3BF:
	.long ParamMsg_ResyncParts_B1_PitchBend                                 ; FAC3BF  [  0]
	.long ParamMsg_ResyncParts_B2_CC01_Modulation                                 ; FAC3C3  [  1]
	.long ParamMsg_ResyncParts_B3_CC0B_Expression                                 ; FAC3C7  [  2]
	.long ParamMsg_ResyncParts_B4_ChannelPressure                                 ; FAC3CB  [  3]
	.long ParamMsg_ResyncParts_B5_CC40_Hold                                 ; FAC3CF  [  4]
	.long .LFAC780                                   ; FAC3D3  [  5]
	.long .LFAC780                                   ; FAC3D7  [  6]
	.long ParamMsg_ResyncParts_B8_CC10_RTCreatX                                 ; FAC3DB  [  7]
	.long ParamMsg_ResyncParts_B9_CC11_RTCreatY                                 ; FAC3DF  [  8]
	.long ParamMsg_ResyncParts_BA_CC12_RTCtrlX                                 ; FAC3E3  [  9]
	.long ParamMsg_ResyncParts_BB_CC13_RTCtrlY                                 ; FAC3E7  [ 10]
	.long ParamMsg_ResyncParts_BC_CC02_Modulation2                                 ; FAC3EB  [ 11]
	.long ParamMsg_ResyncParts_BD_CC04_CtrlPedal                                 ; FAC3EF  [ 12]
; ParamMsg_ResyncParts_B1_PitchBend -- JumpTable_FAC3BF[0] (number 0xB1), run after the part masks were recomputed: post the pitch-bend centre to parts that LOST 0xB1 and the current value to parts that GAINED it, both into the 0x2E00 queue
; Evidence: lost = (new ^ old) & old over (0x60F280)/(0x60F2AC) at 0xFAC3F3-0xFAC3FF, posted with value 0x00 / mask 0x40 (LE 0x4000, the centre MidiOut_ChangeRecord_PitchBend also uses) through Queue2E00_FanOutToPartMask; gained = (old ^ new) & new at 0xFAC414-0xFAC41E, value from the cooked cell at (XIZ+0x0A) split into LSB/MSB, clamped to 0x7F/0x7F at 0xFAC445.
; (0x60F280) is ParamMsg_B1_PitchBend's part-mask cell.
ParamMsg_ResyncParts_B1_PitchBend:   ; entry: named by 1 `.long` operand, first at 0xFAC3BF
	ld xix, (ParamMsg_PartMask_PitchBend:24)                               ; FAC3F3  e2 80 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_PitchBend:24)                               ; FAC3F8  e2 ac f2 60 21
	xor XIX,XBC                                          ; FAC3FD  e9 d4
	and XIX,XBC                                          ; FAC3FF  e9 c4
	jr z, .LFAC414                                       ; FAC401  66 11
	ld (0x60f089:24), 0x00                             ; FAC403  f2 89 f0 60 00 00
	ld (0x60f08a:24), 0x40                             ; FAC409  f2 8a f0 60 00 40
	push XIX                                             ; FAC40F  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC410  1e a1 fa
	pop XIY                                              ; FAC413  5d
.LFAC414:
	ld xbc, (ParamMsg_PartMaskPrev_PitchBend:24)                               ; FAC414  e2 ac f2 60 21
	xor	xbc, (ParamMsg_PartMask_PitchBend:24)                           ; FAC419  e2 80 f2 60 d1
	and	xbc, (ParamMsg_PartMask_PitchBend:24)                           ; FAC41E  e2 80 f2 60 c1
	jrl z, .LFAC780                                      ; FAC423  76 5a 03
	ld XBC,(XIZ+0x0a)                                    ; FAC426  ae 0a 21
	ld H,(XBC)                                           ; FAC429  81 26
	ld W,H                                               ; FAC42B  ce 88
	srl w, 0x01                                          ; FAC42D  c8 ef 01
	res 0x07,W                                           ; FAC430  c8 30 07
	ld E,W                                               ; FAC433  c8 8d
	extz DE                                              ; FAC435  da 12
	ld W,H                                               ; FAC437  ce 88
	sll w, 0x06                                          ; FAC439  c8 ee 06
	and W,0x40                                           ; FAC43C  c8 cc 40
	ld A,W                                               ; FAC43F  c8 89
	extz WA                                              ; FAC441  d8 12
	add WA,DE                                            ; FAC443  da 80
	cp WA,0x7f40                                         ; FAC445  d8 cf 40 7f
	jr c, .LFAC459                                       ; FAC449  67 0e
	ld h, 0x7f:opc                                          ; FAC44B  26 7f
	ld (0x60f089:24), h                                 ; FAC44D  f2 89 f0 60 46
	ld (0x60f08a:24), h                                 ; FAC452  f2 8a f0 60 46
	jr .LFAC477                                          ; FAC457  68 1e
.LFAC459:
	ld c, (0x24f4:16)                                   ; FAC459  c1 f4 24 23
	sll c, 0x06                                          ; FAC45D  cb ee 06
	and C,0x40                                           ; FAC460  cb cc 40
	ld (0x60f089:24), c                                 ; FAC463  f2 89 f0 60 43
	ld b, (0x24f4:16)                                   ; FAC468  c1 f4 24 22
	srl b, 0x01                                          ; FAC46C  ca ef 01
	res 0x07,B                                           ; FAC46F  ca 30 07
	ld (0x60f08a:24), b                                 ; FAC472  f2 8a f0 60 42
.LFAC477:
	ld xbc, (ParamMsg_PartMaskPrev_PitchBend:24)                               ; FAC477  e2 ac f2 60 21
	xor	xbc, (ParamMsg_PartMask_PitchBend:24)                           ; FAC47C  e2 80 f2 60 d1
	and	xbc, (ParamMsg_PartMask_PitchBend:24)                           ; FAC481  e2 80 f2 60 c1
	push XBC                                             ; FAC486  39
	jrl .LFAC77C                                         ; FAC487  78 f2 02
; ParamMsg_ResyncParts_B2_CC01_Modulation -- JumpTable_FAC3BF[1] (number 0xB2): post 0 to parts that lost 0xB2 and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F284)/(0x60F2B0) at 0xFAC48A-0xFAC4B5, reset value 0x00 mask 0x7F, Queue2E00_FanOutToPartMask; (0x60F284) is ParamMsg_B2_CC01_Modulation's cell.
ParamMsg_ResyncParts_B2_CC01_Modulation:   ; entry: named by 1 `.long` operand, first at 0xFAC3C3
	ld xix, (ParamMsg_PartMask_Modulation:24)                               ; FAC48A  e2 84 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_Modulation:24)                               ; FAC48F  e2 b0 f2 60 21
	xor XIX,XBC                                          ; FAC494  e9 d4
	and XIX,XBC                                          ; FAC496  e9 c4
	jr z, .LFAC4AB                                       ; FAC498  66 11
	ld (0x60f089:24), 0x00                             ; FAC49A  f2 89 f0 60 00 00
	ld (0x60f08a:24), 0x7f                             ; FAC4A0  f2 8a f0 60 00 7f
	push XIX                                             ; FAC4A6  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC4A7  1e 0a fa
	pop XIY                                              ; FAC4AA  5d
.LFAC4AB:
	ld xbc, (ParamMsg_PartMaskPrev_Modulation:24)                               ; FAC4AB  e2 b0 f2 60 21
	xor	xbc, (ParamMsg_PartMask_Modulation:24)                           ; FAC4B0  e2 84 f2 60 d1
	and	xbc, (ParamMsg_PartMask_Modulation:24)                           ; FAC4B5  e2 84 f2 60 c1
	ld XIX,XBC                                           ; FAC4BA  e9 8c
	jrl z, .LFAC780                                      ; FAC4BC  76 c1 02
	ld XWA,(XIZ+0x0a)                                    ; FAC4BF  ae 0a 20
	ld C,(XWA)                                           ; FAC4C2  80 23
	res 0x07,C                                           ; FAC4C4  cb 30 07
	ld (0x60f089:24), c                                 ; FAC4C7  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC4CC  f2 8a f0 60 00 7f
	push XIX                                             ; FAC4D2  3c
	jrl .LFAC77C                                         ; FAC4D3  78 a6 02
; ParamMsg_ResyncParts_BC_CC02_Modulation2 -- JumpTable_FAC3BF[11] (number 0xBC): post 0x40 to parts that lost 0xBC and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F288)/(0x60F2B4) at 0xFAC4D6-0xFAC501, reset value 0x40 mask 0x7F, Queue2E00_FanOutToPartMask; (0x60F288) is ParamMsg_BC_CC02_Modulation2's cell.
ParamMsg_ResyncParts_BC_CC02_Modulation2:   ; entry: named by 1 `.long` operand, first at 0xFAC3EB
	ld xix, (ParamMsg_PartMask_Modulation2:24)                               ; FAC4D6  e2 88 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_Modulation2:24)                               ; FAC4DB  e2 b4 f2 60 21
	xor XIX,XBC                                          ; FAC4E0  e9 d4
	and XIX,XBC                                          ; FAC4E2  e9 c4
	jr z, .LFAC4F7                                       ; FAC4E4  66 11
	ld (0x60f089:24), 0x40                             ; FAC4E6  f2 89 f0 60 00 40
	ld (0x60f08a:24), 0x7f                             ; FAC4EC  f2 8a f0 60 00 7f
	push XIX                                             ; FAC4F2  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC4F3  1e be f9
	pop XIY                                              ; FAC4F6  5d
.LFAC4F7:
	ld xbc, (ParamMsg_PartMaskPrev_Modulation2:24)                               ; FAC4F7  e2 b4 f2 60 21
	xor	xbc, (ParamMsg_PartMask_Modulation2:24)                           ; FAC4FC  e2 88 f2 60 d1
	and	xbc, (ParamMsg_PartMask_Modulation2:24)                           ; FAC501  e2 88 f2 60 c1
	ld XIX,XBC                                           ; FAC506  e9 8c
	jrl z, .LFAC780                                      ; FAC508  76 75 02
	ld XWA,(XIZ+0x0a)                                    ; FAC50B  ae 0a 20
	ld C,(XWA)                                           ; FAC50E  80 23
	res 0x07,C                                           ; FAC510  cb 30 07
	ld (0x60f089:24), c                                 ; FAC513  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC518  f2 8a f0 60 00 7f
	push XIX                                             ; FAC51E  3c
	jrl .LFAC77C                                         ; FAC51F  78 5a 02
; ParamMsg_ResyncParts_B8_CC10_RTCreatX -- JumpTable_FAC3BF[7] (number 0xB8): post 0x40 to parts that lost 0xB8 and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F298)/(0x60F2C4) at 0xFAC522-0xFAC54D, reset 0x40 mask 0x7F, Queue2E00_FanOutToPartMask; (0x60F298) is ParamMsg_B8_CC10_RTCreatX's cell.
ParamMsg_ResyncParts_B8_CC10_RTCreatX:   ; entry: named by 1 `.long` operand, first at 0xFAC3DB
	ld xix, (ParamMsg_PartMask_RTCreatX:24)                               ; FAC522  e2 98 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_RTCreatX:24)                               ; FAC527  e2 c4 f2 60 21
	xor XIX,XBC                                          ; FAC52C  e9 d4
	and XIX,XBC                                          ; FAC52E  e9 c4
	jr z, .LFAC543                                       ; FAC530  66 11
	ld (0x60f089:24), 0x40                             ; FAC532  f2 89 f0 60 00 40
	ld (0x60f08a:24), 0x7f                             ; FAC538  f2 8a f0 60 00 7f
	push XIX                                             ; FAC53E  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC53F  1e 72 f9
	pop XIY                                              ; FAC542  5d
.LFAC543:
	ld xbc, (ParamMsg_PartMaskPrev_RTCreatX:24)                               ; FAC543  e2 c4 f2 60 21
	xor	xbc, (ParamMsg_PartMask_RTCreatX:24)                           ; FAC548  e2 98 f2 60 d1
	and	xbc, (ParamMsg_PartMask_RTCreatX:24)                           ; FAC54D  e2 98 f2 60 c1
	ld XIX,XBC                                           ; FAC552  e9 8c
	jrl z, .LFAC780                                      ; FAC554  76 29 02
	ld XWA,(XIZ+0x0a)                                    ; FAC557  ae 0a 20
	ld C,(XWA)                                           ; FAC55A  80 23
	res 0x07,C                                           ; FAC55C  cb 30 07
	ld (0x60f089:24), c                                 ; FAC55F  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC564  f2 8a f0 60 00 7f
	push XIX                                             ; FAC56A  3c
	jrl .LFAC77C                                         ; FAC56B  78 0e 02
; ParamMsg_ResyncParts_B9_CC11_RTCreatY -- JumpTable_FAC3BF[8] (number 0xB9): post 0x40 to parts that lost 0xB9 and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F29C)/(0x60F2C8) at 0xFAC56E-0xFAC599, reset 0x40 mask 0x7F; (0x60F29C) is ParamMsg_B9_CC11_RTCreatY's cell.
ParamMsg_ResyncParts_B9_CC11_RTCreatY:   ; entry: named by 1 `.long` operand, first at 0xFAC3DF
	ld xix, (ParamMsg_PartMask_RTCreatY:24)                               ; FAC56E  e2 9c f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_RTCreatY:24)                               ; FAC573  e2 c8 f2 60 21
	xor XIX,XBC                                          ; FAC578  e9 d4
	and XIX,XBC                                          ; FAC57A  e9 c4
	jr z, .LFAC58F                                       ; FAC57C  66 11
	ld (0x60f089:24), 0x40                             ; FAC57E  f2 89 f0 60 00 40
	ld (0x60f08a:24), 0x7f                             ; FAC584  f2 8a f0 60 00 7f
	push XIX                                             ; FAC58A  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC58B  1e 26 f9
	pop XIY                                              ; FAC58E  5d
.LFAC58F:
	ld xbc, (ParamMsg_PartMaskPrev_RTCreatY:24)                               ; FAC58F  e2 c8 f2 60 21
	xor	xbc, (ParamMsg_PartMask_RTCreatY:24)                           ; FAC594  e2 9c f2 60 d1
	and	xbc, (ParamMsg_PartMask_RTCreatY:24)                           ; FAC599  e2 9c f2 60 c1
	ld XIX,XBC                                           ; FAC59E  e9 8c
	jrl z, .LFAC780                                      ; FAC5A0  76 dd 01
	ld XWA,(XIZ+0x0a)                                    ; FAC5A3  ae 0a 20
	ld C,(XWA)                                           ; FAC5A6  80 23
	res 0x07,C                                           ; FAC5A8  cb 30 07
	ld (0x60f089:24), c                                 ; FAC5AB  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC5B0  f2 8a f0 60 00 7f
	push XIX                                             ; FAC5B6  3c
	jrl .LFAC77C                                         ; FAC5B7  78 c2 01
; ParamMsg_ResyncParts_BA_CC12_RTCtrlX -- JumpTable_FAC3BF[9] (number 0xBA): post 0x40 to parts that lost 0xBA and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F2A0)/(0x60F2CC) at 0xFAC5BA-0xFAC5E5, reset 0x40 mask 0x7F; (0x60F2A0) is ParamMsg_BA_CC12_RTCtrlX's cell.
ParamMsg_ResyncParts_BA_CC12_RTCtrlX:   ; entry: named by 1 `.long` operand, first at 0xFAC3E3
	ld xix, (ParamMsg_PartMask_RTCtrlX:24)                               ; FAC5BA  e2 a0 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_RTCtrlX:24)                               ; FAC5BF  e2 cc f2 60 21
	xor XIX,XBC                                          ; FAC5C4  e9 d4
	and XIX,XBC                                          ; FAC5C6  e9 c4
	jr z, .LFAC5DB                                       ; FAC5C8  66 11
	ld (0x60f089:24), 0x40                             ; FAC5CA  f2 89 f0 60 00 40
	ld (0x60f08a:24), 0x7f                             ; FAC5D0  f2 8a f0 60 00 7f
	push XIX                                             ; FAC5D6  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC5D7  1e da f8
	pop XIY                                              ; FAC5DA  5d
.LFAC5DB:
	ld xbc, (ParamMsg_PartMaskPrev_RTCtrlX:24)                               ; FAC5DB  e2 cc f2 60 21
	xor	xbc, (ParamMsg_PartMask_RTCtrlX:24)                           ; FAC5E0  e2 a0 f2 60 d1
	and	xbc, (ParamMsg_PartMask_RTCtrlX:24)                           ; FAC5E5  e2 a0 f2 60 c1
	ld XIX,XBC                                           ; FAC5EA  e9 8c
	jrl z, .LFAC780                                      ; FAC5EC  76 91 01
	ld XWA,(XIZ+0x0a)                                    ; FAC5EF  ae 0a 20
	ld C,(XWA)                                           ; FAC5F2  80 23
	res 0x07,C                                           ; FAC5F4  cb 30 07
	ld (0x60f089:24), c                                 ; FAC5F7  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC5FC  f2 8a f0 60 00 7f
	push XIX                                             ; FAC602  3c
	jrl .LFAC77C                                         ; FAC603  78 76 01
; ParamMsg_ResyncParts_BB_CC13_RTCtrlY -- JumpTable_FAC3BF[10] (number 0xBB): post 0x40 to parts that lost 0xBB and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F2A4)/(0x60F2D0) at 0xFAC606-0xFAC631, reset 0x40 mask 0x7F; (0x60F2A4) is ParamMsg_BB_CC13_RTCtrlY's cell.
ParamMsg_ResyncParts_BB_CC13_RTCtrlY:   ; entry: named by 1 `.long` operand, first at 0xFAC3E7
	ld xix, (ParamMsg_PartMask_RTCtrlY:24)                               ; FAC606  e2 a4 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_RTCtrlY:24)                               ; FAC60B  e2 d0 f2 60 21
	xor XIX,XBC                                          ; FAC610  e9 d4
	and XIX,XBC                                          ; FAC612  e9 c4
	jr z, .LFAC627                                       ; FAC614  66 11
	ld (0x60f089:24), 0x40                             ; FAC616  f2 89 f0 60 00 40
	ld (0x60f08a:24), 0x7f                             ; FAC61C  f2 8a f0 60 00 7f
	push XIX                                             ; FAC622  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC623  1e 8e f8
	pop XIY                                              ; FAC626  5d
.LFAC627:
	ld xbc, (ParamMsg_PartMaskPrev_RTCtrlY:24)                               ; FAC627  e2 d0 f2 60 21
	xor	xbc, (ParamMsg_PartMask_RTCtrlY:24)                           ; FAC62C  e2 a4 f2 60 d1
	and	xbc, (ParamMsg_PartMask_RTCtrlY:24)                           ; FAC631  e2 a4 f2 60 c1
	ld XIX,XBC                                           ; FAC636  e9 8c
	jrl z, .LFAC780                                      ; FAC638  76 45 01
	ld XWA,(XIZ+0x0a)                                    ; FAC63B  ae 0a 20
	ld C,(XWA)                                           ; FAC63E  80 23
	res 0x07,C                                           ; FAC640  cb 30 07
	ld (0x60f089:24), c                                 ; FAC643  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC648  f2 8a f0 60 00 7f
	push XIX                                             ; FAC64E  3c
	jrl .LFAC77C                                         ; FAC64F  78 2a 01
; ParamMsg_ResyncParts_B4_ChannelPressure -- JumpTable_FAC3BF[3] (number 0xB4): post 0 to parts that lost 0xB4 and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F28C)/(0x60F2B8) at 0xFAC652-0xFAC67D, reset 0x00 mask 0x7F; (0x60F28C) is ParamMsg_B4_ChannelPressure's cell.
ParamMsg_ResyncParts_B4_ChannelPressure:   ; entry: named by 1 `.long` operand, first at 0xFAC3CB
	ld xix, (ParamMsg_PartMask_ChannelPressure:24)                               ; FAC652  e2 8c f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_ChannelPressure:24)                               ; FAC657  e2 b8 f2 60 21
	xor XIX,XBC                                          ; FAC65C  e9 d4
	and XIX,XBC                                          ; FAC65E  e9 c4
	jr z, .LFAC673                                       ; FAC660  66 11
	ld (0x60f089:24), 0x00                             ; FAC662  f2 89 f0 60 00 00
	ld (0x60f08a:24), 0x7f                             ; FAC668  f2 8a f0 60 00 7f
	push XIX                                             ; FAC66E  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC66F  1e 42 f8
	pop XIY                                              ; FAC672  5d
.LFAC673:
	ld xbc, (ParamMsg_PartMaskPrev_ChannelPressure:24)                               ; FAC673  e2 b8 f2 60 21
	xor	xbc, (ParamMsg_PartMask_ChannelPressure:24)                           ; FAC678  e2 8c f2 60 d1
	and	xbc, (ParamMsg_PartMask_ChannelPressure:24)                           ; FAC67D  e2 8c f2 60 c1
	ld XIX,XBC                                           ; FAC682  e9 8c
	jrl z, .LFAC780                                      ; FAC684  76 f9 00
	ld XWA,(XIZ+0x0a)                                    ; FAC687  ae 0a 20
	ld C,(XWA)                                           ; FAC68A  80 23
	res 0x07,C                                           ; FAC68C  cb 30 07
	ld (0x60f089:24), c                                 ; FAC68F  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC694  f2 8a f0 60 00 7f
	push XIX                                             ; FAC69A  3c
	jrl .LFAC77C                                         ; FAC69B  78 de 00
; ParamMsg_ResyncParts_BD_CC04_CtrlPedal -- JumpTable_FAC3BF[12] (number 0xBD): post 0 to parts that lost 0xBD and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F290)/(0x60F2BC) at 0xFAC69E-0xFAC6C9, reset 0x00 mask 0x7F; (0x60F290) is ParamMsg_BD_CC04_CtrlPedal's cell.
ParamMsg_ResyncParts_BD_CC04_CtrlPedal:   ; entry: named by 1 `.long` operand, first at 0xFAC3EF
	ld xix, (ParamMsg_PartMask_CtrlPedal:24)                               ; FAC69E  e2 90 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_CtrlPedal:24)                               ; FAC6A3  e2 bc f2 60 21
	xor XIX,XBC                                          ; FAC6A8  e9 d4
	and XIX,XBC                                          ; FAC6AA  e9 c4
	jr z, .LFAC6BF                                       ; FAC6AC  66 11
	ld (0x60f089:24), 0x00                             ; FAC6AE  f2 89 f0 60 00 00
	ld (0x60f08a:24), 0x7f                             ; FAC6B4  f2 8a f0 60 00 7f
	push XIX                                             ; FAC6BA  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC6BB  1e f6 f7
	pop XIY                                              ; FAC6BE  5d
.LFAC6BF:
	ld xbc, (ParamMsg_PartMaskPrev_CtrlPedal:24)                               ; FAC6BF  e2 bc f2 60 21
	xor	xbc, (ParamMsg_PartMask_CtrlPedal:24)                           ; FAC6C4  e2 90 f2 60 d1
	and	xbc, (ParamMsg_PartMask_CtrlPedal:24)                           ; FAC6C9  e2 90 f2 60 c1
	ld XIX,XBC                                           ; FAC6CE  e9 8c
	jrl z, .LFAC780                                      ; FAC6D0  76 ad 00
	ld XWA,(XIZ+0x0a)                                    ; FAC6D3  ae 0a 20
	ld C,(XWA)                                           ; FAC6D6  80 23
	res 0x07,C                                           ; FAC6D8  cb 30 07
	ld (0x60f089:24), c                                 ; FAC6DB  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC6E0  f2 8a f0 60 00 7f
	push XIX                                             ; FAC6E6  3c
	jrl .LFAC77C                                         ; FAC6E7  78 92 00
; ParamMsg_ResyncParts_B5_CC40_Hold -- JumpTable_FAC3BF[4] (number 0xB5): post 0 to parts that lost 0xB5 and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F294)/(0x60F2C0) at 0xFAC6EA-0xFAC715, reset 0x00 mask 0x7F; (0x60F294) is ParamMsg_B5_CC40_Hold's cell.
ParamMsg_ResyncParts_B5_CC40_Hold:   ; entry: named by 1 `.long` operand, first at 0xFAC3CF
	ld xix, (ParamMsg_PartMask_Hold:24)                               ; FAC6EA  e2 94 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_Hold:24)                               ; FAC6EF  e2 c0 f2 60 21
	xor XIX,XBC                                          ; FAC6F4  e9 d4
	and XIX,XBC                                          ; FAC6F6  e9 c4
	jr z, .LFAC70B                                       ; FAC6F8  66 11
	ld (0x60f089:24), 0x00                             ; FAC6FA  f2 89 f0 60 00 00
	ld (0x60f08a:24), 0x7f                             ; FAC700  f2 8a f0 60 00 7f
	push XIX                                             ; FAC706  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC707  1e aa f7
	pop XIY                                              ; FAC70A  5d
.LFAC70B:
	ld xbc, (ParamMsg_PartMaskPrev_Hold:24)                               ; FAC70B  e2 c0 f2 60 21
	xor	xbc, (ParamMsg_PartMask_Hold:24)                           ; FAC710  e2 94 f2 60 d1
	and	xbc, (ParamMsg_PartMask_Hold:24)                           ; FAC715  e2 94 f2 60 c1
	ld XIX,XBC                                           ; FAC71A  e9 8c
	jr z, .LFAC780                                       ; FAC71C  66 62
	ld XWA,(XIZ+0x0a)                                    ; FAC71E  ae 0a 20
	ld C,(XWA)                                           ; FAC721  80 23
	res 0x07,C                                           ; FAC723  cb 30 07
	ld (0x60f089:24), c                                 ; FAC726  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC72B  f2 8a f0 60 00 7f
	push XIX                                             ; FAC731  3c
	jr .LFAC77C                                          ; FAC732  68 48
; ParamMsg_ResyncParts_B3_CC0B_Expression -- JumpTable_FAC3BF[2] (number 0xB3): post 0x7F to parts that lost 0xB3 and the cooked value (XIZ+0x0A)&0x7F to parts that gained it, into the 0x2E00 queue
; Evidence: lost/gained from (0x60F2A8)/(0x60F2D4) at 0xFAC734-0xFAC75F, reset value 0x7F mask 0x7F (`ld H,0x7f` at 0xFAC744); (0x60F2A8) is ParamMsg_B3_CC0B_Expression's cell.  The label sub_FAC74B sits inside this arm.
ParamMsg_ResyncParts_B3_CC0B_Expression:   ; entry: named by 1 `.long` operand, first at 0xFAC3C7
	ld xix, (ParamMsg_PartMask_Expression:24)                               ; FAC734  e2 a8 f2 60 24
	ld xbc, (ParamMsg_PartMaskPrev_Expression:24)                               ; FAC739  e2 d4 f2 60 21
	xor XIX,XBC                                          ; FAC73E  e9 d4
	and XIX,XBC                                          ; FAC740  e9 c4
	jr z, .LFAC755                                       ; FAC742  66 11
	ld h, 0x7f:opc                                          ; FAC744  26 7f
	ld (0x60f089:24), h                                 ; FAC746  f2 89 f0 60 46
; (sub_FAC74B removed 2026-10-04: no code names it and the line above falls through into it -- part of ParamMsg_ResyncParts_B3_CC0B_Expression;
;  notes/prom_a_stray_label_removal.py)
	ld (0x60f08a:24), h                                 ; FAC74B  f2 8a f0 60 46
	push XIX                                             ; FAC750  3c
	calr Queue2E00_FanOutToPartMask                                          ; FAC751  1e 60 f7
	pop XIY                                              ; FAC754  5d
.LFAC755:
	ld xbc, (ParamMsg_PartMaskPrev_Expression:24)                               ; FAC755  e2 d4 f2 60 21
	xor	xbc, (ParamMsg_PartMask_Expression:24)                           ; FAC75A  e2 a8 f2 60 d1
	and	xbc, (ParamMsg_PartMask_Expression:24)                           ; FAC75F  e2 a8 f2 60 c1
	ld XIX,XBC                                           ; FAC764  e9 8c
	jr z, .LFAC780                                       ; FAC766  66 18
	ld XWA,(XIZ+0x0a)                                    ; FAC768  ae 0a 20
	ld C,(XWA)                                           ; FAC76B  80 23
	res 0x07,C                                           ; FAC76D  cb 30 07
	ld (0x60f089:24), c                                 ; FAC770  f2 89 f0 60 43
	ld (0x60f08a:24), 0x7f                             ; FAC775  f2 8a f0 60 00 7f
	push XIX                                             ; FAC77B  3c
.LFAC77C:
	calr Queue2E00_FanOutToPartMask                                          ; FAC77C  1e 35 f7
	pop XIY                                              ; FAC77F  5d
.LFAC780:
	pop XIX                                              ; FAC780  5c
	popw de                                              ; FAC781  4a
	popw hl                                              ; FAC782  4b
	unlk XIZ                                             ; FAC783  ee 0d
	ret                                                  ; FAC785  0e
; ParamMsg_RefreshMasksOnCtrlFieldChange -- UiEventList handler: run ParamMsg_RefreshPartMasks when the posted change touches a part-record field that ParamMsg_ComputePartMasks reads
; Evidence: L = (0x20BB) (record byte 0, the number) and H = (0x20B8) (byte 1, the class), per the UiEventList payload layout; numbers 0x00-0x1F need class 0x0D and bit 5 of the mask (0x20BA), numbers 0x20-0x3F need class 0x0B..0x0E and a non-zero mask (0xFAC787-0xFAC7BD) -- the same bits ParamMsg_ComputePartMasks tests.
; Called from: directory slot T_ParamMsg_RefreshMasksOnCtrlFieldChange, named in the handler lists at 0xF881B2, 0xF881DA, 0xF881FE, 0xF88222, 0xF88246, 0xF8826A.
ParamMsg_RefreshMasksOnCtrlFieldChange:
	pushw hl                                             ; FAC786  2b
	ld l, (UiEvent_Class:16)                                   ; FAC787  c1 bb 20 27
	ld h, (UiEvent_Byte1:16)                                   ; FAC78B  c1 b8 20 26
	cp L,0x1f                                            ; FAC78F  cf cf 1f
	jr ugt, .LFAC7A4                                     ; FAC792  6b 10
	cp H,0x0d                                            ; FAC794  ce cf 0d
	jr nz, .LFAC7C2                                      ; FAC797  6e 29
	ld c, (UiEvent_Byte3:16)                                   ; FAC799  c1 ba 20 23
	and C,0x20                                           ; FAC79D  cb cc 20
	jr z, .LFAC7C2                                       ; FAC7A0  66 20
	jr .LFAC7BF                                          ; FAC7A2  68 1b
.LFAC7A4:
	cp L,0x20                                            ; FAC7A4  cf cf 20
	jr c, .LFAC7C2                                       ; FAC7A7  67 19
	cp L,0x3f                                            ; FAC7A9  cf cf 3f
	jr ugt, .LFAC7C2                                     ; FAC7AC  6b 14
	cp H,0x0b                                            ; FAC7AE  ce cf 0b
	jr c, .LFAC7C2                                       ; FAC7B1  67 0f
	cp H,0x0e                                            ; FAC7B3  ce cf 0e
	jr ugt, .LFAC7C2                                     ; FAC7B6  6b 0a
	cp	(UiEvent_Byte3:16), 0x00                            ; FAC7B8  c1 ba 20 3f 00
	jr z, .LFAC7C2                                       ; FAC7BD  66 03
.LFAC7BF:
	calr ParamMsg_RefreshPartMasks                                          ; FAC7BF  1e 20 f8
.LFAC7C2:
	popw hl                                              ; FAC7C2  4b
	ret                                                  ; FAC7C3  0e
; ParamRecord_SetPartsField18Bit0 -- set bit 0 of byte 0x18 of every second-half part record (numbers 0x20-0x3F) to bit 0 of the stack argument, queuing each to 0x2C00
; Evidence: loop L = 0x20..0x3F at 0xFAC7CA-0xFAC808: XIX = ParamNumber_GetRecordPtr(L) + 0x18, `and (XIX),0xfe / or C,H`, stage {L,0x18,(XIX),0x01}, Queue2C00_AppendStagedIfPending.  Same field and mask as List2030_Field18_SetAllParts.
; Called from: directory slot T_ParamRecord_SetPartsField18Bit0 (three PanelOpTable_FCF773 handlers, 0xFD06EE, 0xFD074A, 0xFD07AF).
ParamRecord_SetPartsField18Bit0:
	link XIZ,0x0000                                      ; FAC7C4  ee 0c 00 00
	pushw hl                                             ; FAC7C8  2b
	push XIX                                             ; FAC7C9  3c
	ld l, 0x20:opc                                          ; FAC7CA  27 20
	ld H,(XIZ+0x08)                                      ; FAC7CC  8e 08 26
	and H,0x01                                           ; FAC7CF  ce cc 01
.LFAC7D2:
	pushw hl                                             ; FAC7D2  2b
	calr ParamNumber_GetRecordPtr                                      ; FAC7D3  1e d4 00
	ld XIX,XIY                                           ; FAC7D6  ed 8c
	add XIX,0x00000018                                   ; FAC7D8  ec c8 18 00 00 00
	and (XIX),0xfe                                       ; FAC7DE  84 3c fe
	ld C,(XIX)                                           ; FAC7E1  84 23
	or C,H                                               ; FAC7E3  ce e3
	ld (XIX),C                                           ; FAC7E5  b4 43
	ld (0x60f080:24), l                                 ; FAC7E7  f2 80 f0 60 47
	ld (0x60f081:24), 0x18                             ; FAC7EC  f2 81 f0 60 00 18
	ld C,(XIX)                                           ; FAC7F2  84 23
	ld (0x60f082:24), c                                 ; FAC7F4  f2 82 f0 60 43
	ld (0x60f083:24), 0x01                             ; FAC7F9  f2 83 f0 60 00 01
	calr Queue2C00_AppendStagedIfPending                                          ; FAC7FF  1e 09 ea
	inc 1,L                                              ; FAC802  cf 61
	popw bc                                              ; FAC804  49
	cp L,0x3f                                            ; FAC805  cf cf 3f
	jr ule, .LFAC7D2                                     ; FAC808  63 c8
	pop XIX                                              ; FAC80A  5c
	popw hl                                              ; FAC80B  4b
	unlk XIZ                                             ; FAC80C  ee 0d
	ret                                                  ; FAC80E  0e
; Queue2E00_PostParam98Fields -- if bit 4 of parameter 0x98's record byte (0x7F02) is set, append {0x98,2,(0x7F04),0x3F} and {0x98,1,(0x7F03),0x7F} to the pending queue 0x2E00
; Evidence: `and C,0x10` on (0x7F02) at 0xFAC816; two `call T_PendingEventQueue_AppendStackArgs` (the Queue2E00 stack veneer) at 0xFAC82A and 0xFAC83B.  Evt2030_Param98Tech_Notify reads the same two bytes with the same masks.
; Called from: directory slot T_Queue2E00_PostParam98Fields (0xF9FEC8, 0xFE20D4, prom_b 0xF48F09).
Queue2E00_PostParam98Fields:
	push XIX                                             ; FAC80F  3c
	lda xix, (0x7f02:16)                                ; FAC810  f1 02 7f 34
	ld C,(XIX)                                           ; FAC814  84 23
	and C,0x10                                           ; FAC816  cb cc 10
	jr z, .LFAC843                                       ; FAC819  66 28
	pushw 0x3f                                           ; FAC81B  0b 3f 00
	extz XIX                                             ; FAC81E  ec 12
	ld C,(XIX+0x02)                                      ; FAC820  8c 02 23
	pushw bc                                             ; FAC823  29
	pushw 0x02                                           ; FAC824  0b 02 00
	pushw 0x98                                           ; FAC827  0b 98 00
	call T_PendingEventQueue_AppendStackArgs                                        ; FAC82A  1d 18 1b f4
	pushw 0x7f                                           ; FAC82E  0b 7f 00
	ld C,(XIX+0x01)                                      ; FAC831  8c 01 23
	pushw bc                                             ; FAC834  29
	pushw 0x01                                           ; FAC835  0b 01 00
	pushw 0x98                                           ; FAC838  0b 98 00
	call T_PendingEventQueue_AppendStackArgs                                        ; FAC83B  1d 18 1b f4
	inc 8,XSP                                            ; FAC83F  ef 60
	inc 8,XSP                                            ; FAC841  ef 60
.LFAC843:
	pop XIX                                              ; FAC843  5c
	ret                                                  ; FAC844  0e
Dispatch_By_60F080_Nop64:   ; entry: named by 232 `.long` operands, first at 0xFAC9EA
	ret                                                  ; FAC845  0e
; ---------------------------------------------------------------------
; Queue2C00_AppendStaged -- store the staged record (0x60F080), (0x60F081),
;          (0x60F082), (0x60F083) as four bytes at 0x2C00 + (0x60F000),
;          advance the cursor by 4, write 0xFF after them, clear (0x60F083).
; Called from: Queue2C00_AppendStagedIfPending (0xFAB22F) and 0xFAB24F.
; Notes:   same buffer, cursor and terminator as the word-wise tail of
;          Queue2C00_PublishStagedIfPending (0xFAA4CA).  (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
Queue2C00_AppendStaged:
	push XHL                                             ; FAC846  3b
	push XDE                                             ; FAC847  3a
	push XIX                                             ; FAC848  3c
	lda xix, (0x60f000:24)                               ; FAC849  f2 00 f0 60 34
	ld BC,(XIX)                                          ; FAC84E  94 21
	extz XBC                                             ; FAC850  e9 12
	ld a, (0x60f080:24)                                 ; FAC852  c2 80 f0 60 21
	ld (XBC+0x2c00),A                                    ; FAC857  f3 e5 00 2c 41
	incw 0x01, (xix)                                     ; FAC85C  94 61
	ld BC,(XIX)                                          ; FAC85E  94 21
	extz XBC                                             ; FAC860  e9 12
	ld a, (0x60f081:24)                                 ; FAC862  c2 81 f0 60 21
	ld (XBC+0x2c00),A                                    ; FAC867  f3 e5 00 2c 41
	ld BC,(XIX)                                          ; FAC86C  94 21
	ld HL,BC                                             ; FAC86E  d9 8b
	inc 1,HL                                             ; FAC870  db 61
	ld (XIX),HL                                          ; FAC872  b4 53
	extz XHL                                             ; FAC874  eb 12
	ld c, (0x60f082:24)                                 ; FAC876  c2 82 f0 60 23
	ld (XHL+0x2c00),C                                    ; FAC87B  f3 ed 00 2c 43
	ld DE,HL                                             ; FAC880  db 8a
	inc 1,DE                                             ; FAC882  da 61
	ld (XIX),DE                                          ; FAC884  b4 52
	extz XDE                                             ; FAC886  ea 12
	ld c, (0x60f083:24)                                 ; FAC888  c2 83 f0 60 23
	ld (XDE+0x2c00),C                                    ; FAC88D  f3 e9 00 2c 43
	ld HL,DE                                             ; FAC892  da 8b
	inc 1,HL                                             ; FAC894  db 61
	ld (XIX),HL                                          ; FAC896  b4 53
	extz XHL                                             ; FAC898  eb 12
	ld (XHL+0x2c00),0xff                                 ; FAC89A  f3 ed 00 2c 00 ff
	ld (0x60f083:24), 0x00                             ; FAC8A0  f2 83 f0 60 00 00
	pop XIX                                              ; FAC8A6  5c
	pop XDE                                              ; FAC8A7  5a
	pop XHL                                              ; FAC8A8  5b
	ret                                                  ; FAC8A9  0e
; ParamNumber_GetRecordPtr -- XIY = ParamNumber_RecordPtrs[(XIZ+8)], 0xFFFFFFFF when the parameter number has no record
; Evidence: `ld C,0x04 / mul BC,(XIZ+0x08) / add XBC,ParamNumber_RecordPtrs / ld XBC,(XBC) / ld XIY,XBC` at 0xFAC8AE-0xFAC8BD.  15 callers, among them List2030_LoadRecord, ParamRecord_MergeFieldIfChanged and ParamMsg_ComputePartMasks; each compares the result with 0xFFFFFFFF.
; Note: the unlabelled routine at 0xFAC8C2 that follows returns 0x60F0E0 + 4*n for n <= 0x1F and -1 otherwise.
ParamNumber_GetRecordPtr:
	link XIZ,0x0000                                      ; FAC8AA  ee 0c 00 00
	ld c, 0x04:opc                                          ; FAC8AE  23 04
	mul	bc, (xiz+8)                                  ; FAC8B0  8e 08 43
	extz XBC                                             ; FAC8B3  e9 12
	add XBC,ParamNumber_RecordPtrs                       ; FAC8B5  e9 c8 ea cd fa 00
	ld XBC,(XBC)                                         ; FAC8BB  a1 21
	ld XIY,XBC                                           ; FAC8BD  e9 8d
	unlk XIZ                                             ; FAC8BF  ee 0d
	ret                                                  ; FAC8C1  0e
	link XIZ,0x0000                                      ; FAC8C2  ee 0c 00 00
	cp (XIZ+0x08),0x1f                                   ; FAC8C6  8e 08 3f 1f
	jr ugt, .LFAC8DD                                     ; FAC8CA  6b 11
	ld c, 0x04:opc                                          ; FAC8CC  23 04
	mul	bc, (xiz+8)                                  ; FAC8CE  8e 08 43
	extz XBC                                             ; FAC8D1  e9 12
	add XBC,0x0060f0e0                                   ; FAC8D3  e9 c8 e0 f0 60 00
	ld XIY,XBC                                           ; FAC8D9  e9 8d
	jr .LFAC8E3                                          ; FAC8DB  68 06
.LFAC8DD:
	sub XBC,XBC                                          ; FAC8DD  e9 a1
	dec 1,XBC                                            ; FAC8DF  e9 69
	ld XIY,XBC                                           ; FAC8E1  e9 8d
.LFAC8E3:
	unlk XIZ                                             ; FAC8E3  ee 0d
	ret                                                  ; FAC8E5  0e
; ---------------------------------------------------------------------
; Gap_FAC8E6 -- four bytes between the last routine and Dispatch_By_60F080
;
; 0xFAC8E5 is the `ret` of the routine at 0xFAC8C2 and 0xFAC8EA is the first
; entry of Dispatch_By_60F080 (which the reader at 0xFAB850 names as a 32-bit
; immediate, so its address is not in doubt).  These four bytes -- 00 00 00 7F
; -- are what is left in between.
; Unknown: what they are.  They are emitted as `.byte` and NOT decoded: no site
;          in prom_a or prom_b names 0xFAC8E6..0xFAC8E9, and three 0x00s
;          followed by a 0x7F is not a shape this tree can identify.
; Evidence: for the NAME, only its position -- 0xFAC8E5 is a `ret` (0x0E) and
;          0xFAC8EA is named as a 32-bit immediate by the reader at 0xFAB850.
;          The name claims a gap and nothing else, which is all that is known.
; ---------------------------------------------------------------------
Gap_FAC8E6:
	.byte 0x00, 0x00, 0x00, 0x7f                                              ; FAC8E6
; ---------------------------------------------------------------------
; Dispatch_By_60F080 -- 256 LE32 handler addresses, indexed by the byte (0x60F080)
;
; Read by: ONE site, 0xFAB847-0xFAB85E:
;            ld C,0x04 / mul BC,(0x60f080) / extz XBC
;            add XBC,0x00FAC8EA / ld XBC,(XBC)
;            lda XIY,0xFAB860 / push XIY / jp T,XBC
;          -- so the entry is CALLED, not jumped to: the `push XIY` puts
;          0xFAB860 on the stack as the handler's return address, and 0xFAB860
;          is the next instruction of the loop.
; Inputs:  the byte at (0x60F080).
; Outputs: control (and a return) to entry[byte].
; ENTRY COUNT 256, and how it is established: `mul BC,(0x60f080)` multiplies C
;          by an 8-BIT memory operand, so the index cannot exceed 0xFF and
;          BC cannot exceed 0x3FC.  256 entries is the reader's whole reach --
;          it is not a count of what "looks like" a table.
;          ★ LAST-ENTRY TEST: index 255 is at 0xFAC8EA + 1020 = 0xFACCE6, and
;          the 64 words that follow (0xFACCEA-0xFACDE9) are all the same value,
;          0x00FAC845 -- see Dispatch_By_60F080__Tail.  So the reachable table
;          ends exactly where a run of identical filler words begins.
; Evidence for the entries being addresses: all 256 lie in 0xF80000-0xFFFFFF;
;          25 distinct values; 168 of the 256 are 0x00FAC845, and the byte at
;          0xFAC845 is 0x0E = `ret`, i.e. the default handler does nothing.
;          The other 24 distinct handlers lie in 0xFAB894-0xFABE0D, inside this
;          module -- nine of them (types 0x44-0x46, 0x48, 0x60, 0x70, 0x72, 0x90,
;          0x91) are a lone `ret` too, so only 15 do anything.
;          All five numbers come from notes/prom_a_byte_checks.py, checks named
;          "Dispatch_By_60F080:".
; Index:   (0x60F080) is written by other code in this module too -- 0xFAC39B
;          is `ld (0x60F080),C` with C loaded from (XIZ+0x08) three bytes
;          earlier -- but for THIS reader it is traced:
; ★ CORRECTED 2026-09-25 (lane proma).  This paragraph said the byte's
;          values were "not traced to a source here" and that what a command
;          byte MEANS is unknown.  The loop around the reader,
;          List2030_TranslateToQueue2C00, calls List2030_LoadRecord first,
;          which copies byte 0 of the current record of the RAM 0x2030 list
;          into (0x60F080).  So the index is that record's PARAMETER NUMBER,
;          the number space of Evt2030_ClassHandlers and
;          MidiOut_ParamNumberTable.  What the populated entries serve:
;   0x00-0x1F  List2030_Part00to1F_Dispatch -- part parameters (number = the part); it
;              dispatches again on the record's CLASS, List2030_PartFieldHandlers
;   0x20-0x3F  List2030_Part20to3F_Dispatch -- the other half of each part record
;              (ParamNumber_RecordPtrs, pin 3)
;   0x7A, 0x98, 0xA8, 0xB0 -- one handler each (0xFABB61, 0xFABBD7, 0xFABCD7,
;              0xFABCEF), not decoded here
;   0x44-0x46, 0x48, 0x60, 0x70, 0x72, 0x90, 0x91 -- EMPTY handlers, a lone `ret`
;              each (0xFABB5D/60/CF/D0/D2/D4/D5; checked against the ROM), i.e.
;              ignored like the other 168
;   0xB1-0xB5, 0xB8-0xBD -- the eleven MIDI controllers, ParamMsg_B1_PitchBend
;              and its block header
;   the other 168 numbers: Dispatch_By_60F080_Nop64, one `ret`.
; (checks M1-M8: notes/proma-2026-09-25/gen_param_list_headers.py)
; ---------------------------------------------------------------------
Dispatch_By_60F080:
	.long List2030_Part00to1F_Dispatch                                 ; FAC8EA  [  0]
	.long List2030_Part00to1F_Dispatch                                 ; FAC8EE  [  1]
	.long List2030_Part00to1F_Dispatch                                 ; FAC8F2  [  2]
	.long List2030_Part00to1F_Dispatch                                 ; FAC8F6  [  3]
	.long List2030_Part00to1F_Dispatch                                 ; FAC8FA  [  4]
	.long List2030_Part00to1F_Dispatch                                 ; FAC8FE  [  5]
	.long List2030_Part00to1F_Dispatch                                 ; FAC902  [  6]
	.long List2030_Part00to1F_Dispatch                                 ; FAC906  [  7]
	.long List2030_Part00to1F_Dispatch                                 ; FAC90A  [  8]
	.long List2030_Part00to1F_Dispatch                                 ; FAC90E  [  9]
	.long List2030_Part00to1F_Dispatch                                 ; FAC912  [ 10]
	.long List2030_Part00to1F_Dispatch                                 ; FAC916  [ 11]
	.long List2030_Part00to1F_Dispatch                                 ; FAC91A  [ 12]
	.long List2030_Part00to1F_Dispatch                                 ; FAC91E  [ 13]
	.long List2030_Part00to1F_Dispatch                                 ; FAC922  [ 14]
	.long List2030_Part00to1F_Dispatch                                 ; FAC926  [ 15]
	.long List2030_Part00to1F_Dispatch                                 ; FAC92A  [ 16]
	.long List2030_Part00to1F_Dispatch                                 ; FAC92E  [ 17]
	.long List2030_Part00to1F_Dispatch                                 ; FAC932  [ 18]
	.long List2030_Part00to1F_Dispatch                                 ; FAC936  [ 19]
	.long List2030_Part00to1F_Dispatch                                 ; FAC93A  [ 20]
	.long List2030_Part00to1F_Dispatch                                 ; FAC93E  [ 21]
	.long List2030_Part00to1F_Dispatch                                 ; FAC942  [ 22]
	.long List2030_Part00to1F_Dispatch                                 ; FAC946  [ 23]
	.long List2030_Part00to1F_Dispatch                                 ; FAC94A  [ 24]
	.long List2030_Part00to1F_Dispatch                                 ; FAC94E  [ 25]
	.long List2030_Part00to1F_Dispatch                                 ; FAC952  [ 26]
	.long List2030_Part00to1F_Dispatch                                 ; FAC956  [ 27]
	.long List2030_Part00to1F_Dispatch                                 ; FAC95A  [ 28]
	.long List2030_Part00to1F_Dispatch                                 ; FAC95E  [ 29]
	.long List2030_Part00to1F_Dispatch                                 ; FAC962  [ 30]
	.long List2030_Part00to1F_Dispatch                                 ; FAC966  [ 31]
	.long List2030_Part20to3F_Dispatch                                 ; FAC96A  [ 32]
	.long List2030_Part20to3F_Dispatch                                 ; FAC96E  [ 33]
	.long List2030_Part20to3F_Dispatch                                 ; FAC972  [ 34]
	.long List2030_Part20to3F_Dispatch                                 ; FAC976  [ 35]
	.long List2030_Part20to3F_Dispatch                                 ; FAC97A  [ 36]
	.long List2030_Part20to3F_Dispatch                                 ; FAC97E  [ 37]
	.long List2030_Part20to3F_Dispatch                                 ; FAC982  [ 38]
	.long List2030_Part20to3F_Dispatch                                 ; FAC986  [ 39]
	.long List2030_Part20to3F_Dispatch                                 ; FAC98A  [ 40]
	.long List2030_Part20to3F_Dispatch                                 ; FAC98E  [ 41]
	.long List2030_Part20to3F_Dispatch                                 ; FAC992  [ 42]
	.long List2030_Part20to3F_Dispatch                                 ; FAC996  [ 43]
	.long List2030_Part20to3F_Dispatch                                 ; FAC99A  [ 44]
	.long List2030_Part20to3F_Dispatch                                 ; FAC99E  [ 45]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9A2  [ 46]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9A6  [ 47]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9AA  [ 48]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9AE  [ 49]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9B2  [ 50]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9B6  [ 51]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9BA  [ 52]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9BE  [ 53]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9C2  [ 54]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9C6  [ 55]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9CA  [ 56]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9CE  [ 57]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9D2  [ 58]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9D6  [ 59]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9DA  [ 60]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9DE  [ 61]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9E2  [ 62]
	.long List2030_Part20to3F_Dispatch                                 ; FAC9E6  [ 63]
	.long Dispatch_By_60F080_Nop64                                 ; FAC9EA  [ 64]
	.long Dispatch_By_60F080_Nop64                                 ; FAC9EE  [ 65]
	.long Dispatch_By_60F080_Nop64                                 ; FAC9F2  [ 66]
	.long Dispatch_By_60F080_Nop64                                 ; FAC9F6  [ 67]
	.long Dispatch_By_60F080_Nop68                                 ; FAC9FA  [ 68]
	.long Dispatch_By_60F080_Nop68                                 ; FAC9FE  [ 69]
	.long Dispatch_By_60F080_Nop68                                 ; FACA02  [ 70]
	.long Dispatch_By_60F080_Nop64                                 ; FACA06  [ 71]
	.long Dispatch_By_60F080_Nop72                                 ; FACA0A  [ 72]
	.long Dispatch_By_60F080_Nop64                                 ; FACA0E  [ 73]
	.long Dispatch_By_60F080_Nop64                                 ; FACA12  [ 74]
	.long Dispatch_By_60F080_Nop64                                 ; FACA16  [ 75]
	.long Dispatch_By_60F080_Nop64                                 ; FACA1A  [ 76]
	.long Dispatch_By_60F080_Nop64                                 ; FACA1E  [ 77]
	.long Dispatch_By_60F080_Nop64                                 ; FACA22  [ 78]
	.long Dispatch_By_60F080_Nop64                                 ; FACA26  [ 79]
	.long Dispatch_By_60F080_Nop64                                 ; FACA2A  [ 80]
	.long Dispatch_By_60F080_Nop64                                 ; FACA2E  [ 81]
	.long Dispatch_By_60F080_Nop64                                 ; FACA32  [ 82]
	.long Dispatch_By_60F080_Nop64                                 ; FACA36  [ 83]
	.long Dispatch_By_60F080_Nop64                                 ; FACA3A  [ 84]
	.long Dispatch_By_60F080_Nop64                                 ; FACA3E  [ 85]
	.long Dispatch_By_60F080_Nop64                                 ; FACA42  [ 86]
	.long Dispatch_By_60F080_Nop64                                 ; FACA46  [ 87]
	.long Dispatch_By_60F080_Nop64                                 ; FACA4A  [ 88]
	.long Dispatch_By_60F080_Nop64                                 ; FACA4E  [ 89]
	.long Dispatch_By_60F080_Nop64                                 ; FACA52  [ 90]
	.long Dispatch_By_60F080_Nop64                                 ; FACA56  [ 91]
	.long Dispatch_By_60F080_Nop64                                 ; FACA5A  [ 92]
	.long Dispatch_By_60F080_Nop64                                 ; FACA5E  [ 93]
	.long Dispatch_By_60F080_Nop64                                 ; FACA62  [ 94]
	.long Dispatch_By_60F080_Nop64                                 ; FACA66  [ 95]
	.long Dispatch_By_60F080_Nop96                                 ; FACA6A  [ 96]
	.long Dispatch_By_60F080_Nop64                                 ; FACA6E  [ 97]
	.long Dispatch_By_60F080_Nop64                                 ; FACA72  [ 98]
	.long Dispatch_By_60F080_Nop64                                 ; FACA76  [ 99]
	.long Dispatch_By_60F080_Nop64                                 ; FACA7A  [100]
	.long Dispatch_By_60F080_Nop64                                 ; FACA7E  [101]
	.long Dispatch_By_60F080_Nop64                                 ; FACA82  [102]
	.long Dispatch_By_60F080_Nop64                                 ; FACA86  [103]
	.long Dispatch_By_60F080_Nop64                                 ; FACA8A  [104]
	.long Dispatch_By_60F080_Nop64                                 ; FACA8E  [105]
	.long Dispatch_By_60F080_Nop64                                 ; FACA92  [106]
	.long Dispatch_By_60F080_Nop64                                 ; FACA96  [107]
	.long Dispatch_By_60F080_Nop64                                 ; FACA9A  [108]
	.long Dispatch_By_60F080_Nop64                                 ; FACA9E  [109]
	.long Dispatch_By_60F080_Nop64                                 ; FACAA2  [110]
	.long Dispatch_By_60F080_Nop64                                 ; FACAA6  [111]
	.long Dispatch_By_60F080_Nop112                                 ; FACAAA  [112]
	.long Dispatch_By_60F080_Nop64                                 ; FACAAE  [113]
	.long Dispatch_By_60F080_Nop114                                 ; FACAB2  [114]
	.long Dispatch_By_60F080_Nop64                                 ; FACAB6  [115]
	.long Dispatch_By_60F080_Nop64                                 ; FACABA  [116]
	.long Dispatch_By_60F080_Nop64                                 ; FACABE  [117]
	.long Dispatch_By_60F080_Nop64                                 ; FACAC2  [118]
	.long Dispatch_By_60F080_Nop64                                 ; FACAC6  [119]
	.long Dispatch_By_60F080_Nop64                                 ; FACACA  [120]
	.long Dispatch_By_60F080_Nop64                                 ; FACACE  [121]
	.long List2030_Tempo_Dispatch                                 ; FACAD2  [122]
	.long Dispatch_By_60F080_Nop64                                 ; FACAD6  [123]
	.long Dispatch_By_60F080_Nop64                                 ; FACADA  [124]
	.long Dispatch_By_60F080_Nop64                                 ; FACADE  [125]
	.long Dispatch_By_60F080_Nop64                                 ; FACAE2  [126]
	.long Dispatch_By_60F080_Nop64                                 ; FACAE6  [127]
	.long Dispatch_By_60F080_Nop64                                 ; FACAEA  [128]
	.long Dispatch_By_60F080_Nop64                                 ; FACAEE  [129]
	.long Dispatch_By_60F080_Nop64                                 ; FACAF2  [130]
	.long Dispatch_By_60F080_Nop64                                 ; FACAF6  [131]
	.long Dispatch_By_60F080_Nop64                                 ; FACAFA  [132]
	.long Dispatch_By_60F080_Nop64                                 ; FACAFE  [133]
	.long Dispatch_By_60F080_Nop64                                 ; FACB02  [134]
	.long Dispatch_By_60F080_Nop64                                 ; FACB06  [135]
	.long Dispatch_By_60F080_Nop64                                 ; FACB0A  [136]
	.long Dispatch_By_60F080_Nop64                                 ; FACB0E  [137]
	.long Dispatch_By_60F080_Nop64                                 ; FACB12  [138]
	.long Dispatch_By_60F080_Nop64                                 ; FACB16  [139]
	.long Dispatch_By_60F080_Nop64                                 ; FACB1A  [140]
	.long Dispatch_By_60F080_Nop64                                 ; FACB1E  [141]
	.long Dispatch_By_60F080_Nop64                                 ; FACB22  [142]
	.long Dispatch_By_60F080_Nop64                                 ; FACB26  [143]
	.long Dispatch_By_60F080_Nop144                                 ; FACB2A  [144]
	.long Dispatch_By_60F080_Nop145                                 ; FACB2E  [145]
	.long Dispatch_By_60F080_Nop64                                 ; FACB32  [146]
	.long Dispatch_By_60F080_Nop64                                 ; FACB36  [147]
	.long Dispatch_By_60F080_Nop64                                 ; FACB3A  [148]
	.long Dispatch_By_60F080_Nop64                                 ; FACB3E  [149]
	.long Dispatch_By_60F080_Nop64                                 ; FACB42  [150]
	.long Dispatch_By_60F080_Nop64                                 ; FACB46  [151]
	.long List2030_Param98_Dispatch                                 ; FACB4A  [152]
	.long Dispatch_By_60F080_Nop64                                 ; FACB4E  [153]
	.long Dispatch_By_60F080_Nop64                                 ; FACB52  [154]
	.long Dispatch_By_60F080_Nop64                                 ; FACB56  [155]
	.long Dispatch_By_60F080_Nop64                                 ; FACB5A  [156]
	.long Dispatch_By_60F080_Nop64                                 ; FACB5E  [157]
	.long Dispatch_By_60F080_Nop64                                 ; FACB62  [158]
	.long Dispatch_By_60F080_Nop64                                 ; FACB66  [159]
	.long Dispatch_By_60F080_Nop64                                 ; FACB6A  [160]
	.long Dispatch_By_60F080_Nop64                                 ; FACB6E  [161]
	.long Dispatch_By_60F080_Nop64                                 ; FACB72  [162]
	.long Dispatch_By_60F080_Nop64                                 ; FACB76  [163]
	.long Dispatch_By_60F080_Nop64                                 ; FACB7A  [164]
	.long Dispatch_By_60F080_Nop64                                 ; FACB7E  [165]
	.long Dispatch_By_60F080_Nop64                                 ; FACB82  [166]
	.long Dispatch_By_60F080_Nop64                                 ; FACB86  [167]
	.long List2030_ParamA8_PassThrough                                 ; FACB8A  [168]
	.long Dispatch_By_60F080_Nop64                                 ; FACB8E  [169]
	.long Dispatch_By_60F080_Nop64                                 ; FACB92  [170]
	.long Dispatch_By_60F080_Nop64                                 ; FACB96  [171]
	.long Dispatch_By_60F080_Nop64                                 ; FACB9A  [172]
	.long Dispatch_By_60F080_Nop64                                 ; FACB9E  [173]
	.long Dispatch_By_60F080_Nop64                                 ; FACBA2  [174]
	.long Dispatch_By_60F080_Nop64                                 ; FACBA6  [175]
	.long List2030_ParamB0_Dispatch                                 ; FACBAA  [176]
	.long ParamMsg_B1_PitchBend                                 ; FACBAE  [177]
	.long ParamMsg_B2_CC01_Modulation                                 ; FACBB2  [178]
	.long ParamMsg_B3_CC0B_Expression                                 ; FACBB6  [179]
	.long ParamMsg_B4_ChannelPressure                                 ; FACBBA  [180]
	.long ParamMsg_B5_CC40_Hold                                 ; FACBBE  [181]
	.long Dispatch_By_60F080_Nop64                                 ; FACBC2  [182]
	.long Dispatch_By_60F080_Nop64                                 ; FACBC6  [183]
	.long ParamMsg_B8_CC10_RTCreatX                                 ; FACBCA  [184]
	.long ParamMsg_B9_CC11_RTCreatY                                 ; FACBCE  [185]
	.long ParamMsg_BA_CC12_RTCtrlX                                 ; FACBD2  [186]
	.long ParamMsg_BB_CC13_RTCtrlY                                 ; FACBD6  [187]
	.long ParamMsg_BC_CC02_Modulation2                                 ; FACBDA  [188]
	.long ParamMsg_BD_CC04_CtrlPedal                                 ; FACBDE  [189]
	.long Dispatch_By_60F080_Nop64                                 ; FACBE2  [190]
	.long Dispatch_By_60F080_Nop64                                 ; FACBE6  [191]
	.long Dispatch_By_60F080_Nop64                                 ; FACBEA  [192]
	.long Dispatch_By_60F080_Nop64                                 ; FACBEE  [193]
	.long Dispatch_By_60F080_Nop64                                 ; FACBF2  [194]
	.long Dispatch_By_60F080_Nop64                                 ; FACBF6  [195]
	.long Dispatch_By_60F080_Nop64                                 ; FACBFA  [196]
	.long Dispatch_By_60F080_Nop64                                 ; FACBFE  [197]
	.long Dispatch_By_60F080_Nop64                                 ; FACC02  [198]
	.long Dispatch_By_60F080_Nop64                                 ; FACC06  [199]
	.long Dispatch_By_60F080_Nop64                                 ; FACC0A  [200]
	.long Dispatch_By_60F080_Nop64                                 ; FACC0E  [201]
	.long Dispatch_By_60F080_Nop64                                 ; FACC12  [202]
	.long Dispatch_By_60F080_Nop64                                 ; FACC16  [203]
	.long Dispatch_By_60F080_Nop64                                 ; FACC1A  [204]
	.long Dispatch_By_60F080_Nop64                                 ; FACC1E  [205]
	.long Dispatch_By_60F080_Nop64                                 ; FACC22  [206]
	.long Dispatch_By_60F080_Nop64                                 ; FACC26  [207]
	.long Dispatch_By_60F080_Nop64                                 ; FACC2A  [208]
	.long Dispatch_By_60F080_Nop64                                 ; FACC2E  [209]
	.long Dispatch_By_60F080_Nop64                                 ; FACC32  [210]
	.long Dispatch_By_60F080_Nop64                                 ; FACC36  [211]
	.long Dispatch_By_60F080_Nop64                                 ; FACC3A  [212]
	.long Dispatch_By_60F080_Nop64                                 ; FACC3E  [213]
	.long Dispatch_By_60F080_Nop64                                 ; FACC42  [214]
	.long Dispatch_By_60F080_Nop64                                 ; FACC46  [215]
	.long Dispatch_By_60F080_Nop64                                 ; FACC4A  [216]
	.long Dispatch_By_60F080_Nop64                                 ; FACC4E  [217]
	.long Dispatch_By_60F080_Nop64                                 ; FACC52  [218]
	.long Dispatch_By_60F080_Nop64                                 ; FACC56  [219]
	.long Dispatch_By_60F080_Nop64                                 ; FACC5A  [220]
	.long Dispatch_By_60F080_Nop64                                 ; FACC5E  [221]
	.long Dispatch_By_60F080_Nop64                                 ; FACC62  [222]
	.long Dispatch_By_60F080_Nop64                                 ; FACC66  [223]
	.long Dispatch_By_60F080_Nop64                                 ; FACC6A  [224]
	.long Dispatch_By_60F080_Nop64                                 ; FACC6E  [225]
	.long Dispatch_By_60F080_Nop64                                 ; FACC72  [226]
	.long Dispatch_By_60F080_Nop64                                 ; FACC76  [227]
	.long Dispatch_By_60F080_Nop64                                 ; FACC7A  [228]
	.long Dispatch_By_60F080_Nop64                                 ; FACC7E  [229]
	.long Dispatch_By_60F080_Nop64                                 ; FACC82  [230]
	.long Dispatch_By_60F080_Nop64                                 ; FACC86  [231]
	.long Dispatch_By_60F080_Nop64                                 ; FACC8A  [232]
	.long Dispatch_By_60F080_Nop64                                 ; FACC8E  [233]
	.long Dispatch_By_60F080_Nop64                                 ; FACC92  [234]
	.long Dispatch_By_60F080_Nop64                                 ; FACC96  [235]
	.long Dispatch_By_60F080_Nop64                                 ; FACC9A  [236]
	.long Dispatch_By_60F080_Nop64                                 ; FACC9E  [237]
	.long Dispatch_By_60F080_Nop64                                 ; FACCA2  [238]
	.long Dispatch_By_60F080_Nop64                                 ; FACCA6  [239]
	.long Dispatch_By_60F080_Nop64                                 ; FACCAA  [240]
	.long Dispatch_By_60F080_Nop64                                 ; FACCAE  [241]
	.long Dispatch_By_60F080_Nop64                                 ; FACCB2  [242]
	.long Dispatch_By_60F080_Nop64                                 ; FACCB6  [243]
	.long Dispatch_By_60F080_Nop64                                 ; FACCBA  [244]
	.long Dispatch_By_60F080_Nop64                                 ; FACCBE  [245]
	.long Dispatch_By_60F080_Nop64                                 ; FACCC2  [246]
	.long Dispatch_By_60F080_Nop64                                 ; FACCC6  [247]
	.long Dispatch_By_60F080_Nop64                                 ; FACCCA  [248]
	.long Dispatch_By_60F080_Nop64                                 ; FACCCE  [249]
	.long Dispatch_By_60F080_Nop64                                 ; FACCD2  [250]
	.long Dispatch_By_60F080_Nop64                                 ; FACCD6  [251]
	.long Dispatch_By_60F080_Nop64                                 ; FACCDA  [252]
	.long Dispatch_By_60F080_Nop64                                 ; FACCDE  [253]
	.long Dispatch_By_60F080_Nop64                                 ; FACCE2  [254]
	.long Dispatch_By_60F080_Nop64                                 ; FACCE6  [255]
; ---------------------------------------------------------------------
; Dispatch_By_60F080__Tail -- 64 more words, ALL 0x00FAC845, unreachable
;
; These 64 LE32 words sit between the last reachable entry of
; Dispatch_By_60F080 (index 255, at 0xFACCE6) and the first entry of
; ParamNumber_RecordPtrs (0xFACDEA, which its own reader names as a 32-bit
; immediate).  Every one of them is 0x00FAC845, the address of the bare `ret`
; that 168 of the reachable entries also hold.
; Evidence: `set(words) == {0x00FAC845}` over the whole 64, checked byte by
;          byte in notes/prom_a_byte_checks.py, not sampled.
; ⚠ Whether the assembler emitted a 320-entry table of which only 256 can be
;   reached, or a 256-entry table followed by filler, is NOT established: the
;   bytes are identical either way.  What is established is that no index the
;   reader can form reaches them.
; ---------------------------------------------------------------------
Dispatch_By_60F080__Tail:
	.long Dispatch_By_60F080_Nop64                                 ; FACCEA  [  0]
	.long Dispatch_By_60F080_Nop64                                 ; FACCEE  [  1]
	.long Dispatch_By_60F080_Nop64                                 ; FACCF2  [  2]
	.long Dispatch_By_60F080_Nop64                                 ; FACCF6  [  3]
	.long Dispatch_By_60F080_Nop64                                 ; FACCFA  [  4]
	.long Dispatch_By_60F080_Nop64                                 ; FACCFE  [  5]
	.long Dispatch_By_60F080_Nop64                                 ; FACD02  [  6]
	.long Dispatch_By_60F080_Nop64                                 ; FACD06  [  7]
	.long Dispatch_By_60F080_Nop64                                 ; FACD0A  [  8]
	.long Dispatch_By_60F080_Nop64                                 ; FACD0E  [  9]
	.long Dispatch_By_60F080_Nop64                                 ; FACD12  [ 10]
	.long Dispatch_By_60F080_Nop64                                 ; FACD16  [ 11]
	.long Dispatch_By_60F080_Nop64                                 ; FACD1A  [ 12]
	.long Dispatch_By_60F080_Nop64                                 ; FACD1E  [ 13]
	.long Dispatch_By_60F080_Nop64                                 ; FACD22  [ 14]
	.long Dispatch_By_60F080_Nop64                                 ; FACD26  [ 15]
	.long Dispatch_By_60F080_Nop64                                 ; FACD2A  [ 16]
	.long Dispatch_By_60F080_Nop64                                 ; FACD2E  [ 17]
	.long Dispatch_By_60F080_Nop64                                 ; FACD32  [ 18]
	.long Dispatch_By_60F080_Nop64                                 ; FACD36  [ 19]
	.long Dispatch_By_60F080_Nop64                                 ; FACD3A  [ 20]
	.long Dispatch_By_60F080_Nop64                                 ; FACD3E  [ 21]
	.long Dispatch_By_60F080_Nop64                                 ; FACD42  [ 22]
	.long Dispatch_By_60F080_Nop64                                 ; FACD46  [ 23]
	.long Dispatch_By_60F080_Nop64                                 ; FACD4A  [ 24]
	.long Dispatch_By_60F080_Nop64                                 ; FACD4E  [ 25]
	.long Dispatch_By_60F080_Nop64                                 ; FACD52  [ 26]
	.long Dispatch_By_60F080_Nop64                                 ; FACD56  [ 27]
	.long Dispatch_By_60F080_Nop64                                 ; FACD5A  [ 28]
	.long Dispatch_By_60F080_Nop64                                 ; FACD5E  [ 29]
	.long Dispatch_By_60F080_Nop64                                 ; FACD62  [ 30]
	.long Dispatch_By_60F080_Nop64                                 ; FACD66  [ 31]
	.long Dispatch_By_60F080_Nop64                                 ; FACD6A  [ 32]
	.long Dispatch_By_60F080_Nop64                                 ; FACD6E  [ 33]
	.long Dispatch_By_60F080_Nop64                                 ; FACD72  [ 34]
	.long Dispatch_By_60F080_Nop64                                 ; FACD76  [ 35]
	.long Dispatch_By_60F080_Nop64                                 ; FACD7A  [ 36]
	.long Dispatch_By_60F080_Nop64                                 ; FACD7E  [ 37]
	.long Dispatch_By_60F080_Nop64                                 ; FACD82  [ 38]
	.long Dispatch_By_60F080_Nop64                                 ; FACD86  [ 39]
	.long Dispatch_By_60F080_Nop64                                 ; FACD8A  [ 40]
	.long Dispatch_By_60F080_Nop64                                 ; FACD8E  [ 41]
	.long Dispatch_By_60F080_Nop64                                 ; FACD92  [ 42]
	.long Dispatch_By_60F080_Nop64                                 ; FACD96  [ 43]
	.long Dispatch_By_60F080_Nop64                                 ; FACD9A  [ 44]
	.long Dispatch_By_60F080_Nop64                                 ; FACD9E  [ 45]
	.long Dispatch_By_60F080_Nop64                                 ; FACDA2  [ 46]
	.long Dispatch_By_60F080_Nop64                                 ; FACDA6  [ 47]
	.long Dispatch_By_60F080_Nop64                                 ; FACDAA  [ 48]
	.long Dispatch_By_60F080_Nop64                                 ; FACDAE  [ 49]
	.long Dispatch_By_60F080_Nop64                                 ; FACDB2  [ 50]
	.long Dispatch_By_60F080_Nop64                                 ; FACDB6  [ 51]
	.long Dispatch_By_60F080_Nop64                                 ; FACDBA  [ 52]
	.long Dispatch_By_60F080_Nop64                                 ; FACDBE  [ 53]
	.long Dispatch_By_60F080_Nop64                                 ; FACDC2  [ 54]
	.long Dispatch_By_60F080_Nop64                                 ; FACDC6  [ 55]
	.long Dispatch_By_60F080_Nop64                                 ; FACDCA  [ 56]
	.long Dispatch_By_60F080_Nop64                                 ; FACDCE  [ 57]
	.long Dispatch_By_60F080_Nop64                                 ; FACDD2  [ 58]
	.long Dispatch_By_60F080_Nop64                                 ; FACDD6  [ 59]
	.long Dispatch_By_60F080_Nop64                                 ; FACDDA  [ 60]
	.long Dispatch_By_60F080_Nop64                                 ; FACDDE  [ 61]
	.long Dispatch_By_60F080_Nop64                                 ; FACDE2  [ 62]
	.long Dispatch_By_60F080_Nop64                                 ; FACDE6  [ 63]
; ---------------------------------------------------------------------
; ParamNumber_RecordPtrs -- 256 LE32 words: the WORK-RAM address of the
;                           record that parameter number k's fields live
;                           in, or 0xFFFFFFFF when k has no record
;
; ★ THIS REPLACES THE NAME `Lookup32_By_Arg8` AND CORRECTS ITS HEADER.
;          That header said `Unknown: what the 16-bit values ARE.  They
;          are NOT addresses in any image of this machine ... and
;          0xFFFFFFFF reads as "absent" but nothing in the module tests
;          for it.`  Both halves are wrong:
;            * the values are 16-bit WORK-RAM addresses, the same form
;              prom_b's RamPtrTable_F7554D header already describes;
;            * `cp XIX,0xffffffff` at 0xFAA5BF, 0xFAA63B and 0xFAA682
;              tests a fetched entry for exactly that value and skips the
;              whole operation when it matches.
;          The old header's shape facts -- 256 entries, 1024 bytes, 179
;          empty, values in 0x7622..0x7F5A -- are re-derived here and all
;          four still hold.
; Read by: (0x60F018) holds this table's base.  Three instructions load
;          it -- `lda XBC,0xfacdea` at 0xFAA873, 0xFAA94E and 0xFAB7F4 --
;          and every reader of (0x60F018) therefore reads THIS table,
;          including prom_b's IndexedTable_GetPtr (0xF55321) and
;          IndexedTable_GetByte (0xF5533C), whose own headers say
;          `Unknown: what the table holds and who writes 0x60F018`.
;          The reader the old header named, 0xFAC8AA, is one of several.
; ★ Evidence, four independent pins, all re-derived by
;          notes/prom_a_understanding_round4.py --table:
;          1. entry[k] + 0x0D == MidiOut_PartRecordPtrs_00[k] for all 32
;             of that already-named table's entries, last included.  So
;             entries 0x00-0x1F ARE the 32 part records, given at their
;             base rather than at the +0x0D channel byte.
;          2. entries 0x00-0x1F step by 0x40 with one step of 0x80 after
;             index 7 -- the same irregularity MidiOut_PartRecordPtrs_00's
;             header records for itself.
;          3. entry[0x20+i] == entry[i] + 0x20 for all 32, which is why
;             Evt2030_ClassHandlers routes 0x00-0x1F and 0x20-0x3F to two
;             different handlers: they are two halves of one 0x40 record.
;          4. entry[0x80] == 0x7F32, and (0x7F32) is the byte whose bit 2
;             MIDI_RT_ExternalOff already names; prom_b 0xF6F858 writes
;             its low two bits and then posts {0x80, 0, value, 0x03}.
; Unknown:  the field layout inside a record.  Only three offsets are
;          established anywhere in the tree: +0x0D (the MIDI channel,
;          from MidiIn_BuildChannelRouteTable) and +0x1B..+0x1D (written
;          by 0xFAA6B1).  The 0x40-byte size is a step, not a proof.
; ★ 2026-09-25 (lane proma): three AND/OR patch lists add more touched offsets
;          (not meanings): PatchList_RecordField0C clears the low three bits
;          of +0x0C and sets +0x0D to the record's own index k (so a part's
;          default channel byte is its index), and PatchList_RecordBytes2B
;          AND/OR-patches the twelve bytes +0x2B..+0x36 of every record --
;          both applied by the T_F40840 module at 0xFB1800.
; ---------------------------------------------------------------------
ParamNumber_RecordPtrs:
	.long 0x000076a2                                 ; FACDEA  [  0]
	.long 0x000076e2                                 ; FACDEE  [  1]
	.long 0x00007722                                 ; FACDF2  [  2]
	.long 0x00007762                                 ; FACDF6  [  3]
	.long 0x000077a2                                 ; FACDFA  [  4]
	.long 0x000077e2                                 ; FACDFE  [  5]
	.long 0x00007822                                 ; FACE02  [  6]
	.long 0x00007862                                 ; FACE06  [  7]
	.long 0x000078e2                                 ; FACE0A  [  8]
	.long 0x00007922                                 ; FACE0E  [  9]
	.long 0x00007962                                 ; FACE12  [ 10]
	.long 0x000079a2                                 ; FACE16  [ 11]
	.long 0x000079e2                                 ; FACE1A  [ 12]
	.long 0x00007a22                                 ; FACE1E  [ 13]
	.long 0x00007a62                                 ; FACE22  [ 14]
	.long 0x00007aa2                                 ; FACE26  [ 15]
	.long 0x00007ae2                                 ; FACE2A  [ 16]
	.long 0x00007b22                                 ; FACE2E  [ 17]
	.long 0x00007b62                                 ; FACE32  [ 18]
	.long 0x00007ba2                                 ; FACE36  [ 19]
	.long 0x00007be2                                 ; FACE3A  [ 20]
	.long 0x00007c22                                 ; FACE3E  [ 21]
	.long 0x00007c62                                 ; FACE42  [ 22]
	.long 0x00007ca2                                 ; FACE46  [ 23]
	.long 0x00007ce2                                 ; FACE4A  [ 24]
	.long 0x00007d22                                 ; FACE4E  [ 25]
	.long 0x00007d62                                 ; FACE52  [ 26]
	.long 0x00007da2                                 ; FACE56  [ 27]
	.long 0x00007de2                                 ; FACE5A  [ 28]
	.long 0x00007e22                                 ; FACE5E  [ 29]
	.long 0x00007e62                                 ; FACE62  [ 30]
	.long 0x00007ea2                                 ; FACE66  [ 31]
	.long 0x000076c2                                 ; FACE6A  [ 32]
	.long 0x00007702                                 ; FACE6E  [ 33]
	.long 0x00007742                                 ; FACE72  [ 34]
	.long 0x00007782                                 ; FACE76  [ 35]
	.long 0x000077c2                                 ; FACE7A  [ 36]
	.long 0x00007802                                 ; FACE7E  [ 37]
	.long 0x00007842                                 ; FACE82  [ 38]
	.long 0x00007882                                 ; FACE86  [ 39]
	.long 0x00007902                                 ; FACE8A  [ 40]
	.long 0x00007942                                 ; FACE8E  [ 41]
	.long 0x00007982                                 ; FACE92  [ 42]
	.long 0x000079c2                                 ; FACE96  [ 43]
	.long 0x00007a02                                 ; FACE9A  [ 44]
	.long 0x00007a42                                 ; FACE9E  [ 45]
	.long 0x00007a82                                 ; FACEA2  [ 46]
	.long 0x00007ac2                                 ; FACEA6  [ 47]
	.long 0x00007b02                                 ; FACEAA  [ 48]
	.long 0x00007b42                                 ; FACEAE  [ 49]
	.long 0x00007b82                                 ; FACEB2  [ 50]
	.long 0x00007bc2                                 ; FACEB6  [ 51]
	.long 0x00007c02                                 ; FACEBA  [ 52]
	.long 0x00007c42                                 ; FACEBE  [ 53]
	.long 0x00007c82                                 ; FACEC2  [ 54]
	.long 0x00007cc2                                 ; FACEC6  [ 55]
	.long 0x00007d02                                 ; FACECA  [ 56]
	.long 0x00007d42                                 ; FACECE  [ 57]
	.long 0x00007d82                                 ; FACED2  [ 58]
	.long 0x00007dc2                                 ; FACED6  [ 59]
	.long 0x00007e02                                 ; FACEDA  [ 60]
	.long 0x00007e42                                 ; FACEDE  [ 61]
	.long 0x00007e82                                 ; FACEE2  [ 62]
	.long 0x00007ec2                                 ; FACEE6  [ 63]
	.long 0xffffffff                                 ; FACEEA  [ 64]
	.long 0xffffffff                                 ; FACEEE  [ 65]
	.long 0xffffffff                                 ; FACEF2  [ 66]
	.long 0xffffffff                                 ; FACEF6  [ 67]
	.long 0xffffffff                                 ; FACEFA  [ 68]
	.long 0xffffffff                                 ; FACEFE  [ 69]
	.long 0xffffffff                                 ; FACF02  [ 70]
	.long 0xffffffff                                 ; FACF06  [ 71]
	.long 0xffffffff                                 ; FACF0A  [ 72]
	.long 0xffffffff                                 ; FACF0E  [ 73]
	.long 0xffffffff                                 ; FACF12  [ 74]
	.long 0xffffffff                                 ; FACF16  [ 75]
	.long 0xffffffff                                 ; FACF1A  [ 76]
	.long 0xffffffff                                 ; FACF1E  [ 77]
	.long 0xffffffff                                 ; FACF22  [ 78]
	.long 0xffffffff                                 ; FACF26  [ 79]
	.long 0xffffffff                                 ; FACF2A  [ 80]
	.long 0xffffffff                                 ; FACF2E  [ 81]
	.long 0xffffffff                                 ; FACF32  [ 82]
	.long 0xffffffff                                 ; FACF36  [ 83]
	.long 0xffffffff                                 ; FACF3A  [ 84]
	.long 0xffffffff                                 ; FACF3E  [ 85]
	.long 0xffffffff                                 ; FACF42  [ 86]
	.long 0xffffffff                                 ; FACF46  [ 87]
	.long 0xffffffff                                 ; FACF4A  [ 88]
	.long 0xffffffff                                 ; FACF4E  [ 89]
	.long 0xffffffff                                 ; FACF52  [ 90]
	.long 0xffffffff                                 ; FACF56  [ 91]
	.long 0xffffffff                                 ; FACF5A  [ 92]
	.long 0xffffffff                                 ; FACF5E  [ 93]
	.long 0xffffffff                                 ; FACF62  [ 94]
	.long 0xffffffff                                 ; FACF66  [ 95]
	.long 0x00007634                                 ; FACF6A  [ 96]
	.long 0x00007642                                 ; FACF6E  [ 97]
	.long 0x00007662                                 ; FACF72  [ 98]
	.long 0x00007682                                 ; FACF76  [ 99]
	.long 0xffffffff                                 ; FACF7A  [100]
	.long 0xffffffff                                 ; FACF7E  [101]
	.long 0xffffffff                                 ; FACF82  [102]
	.long 0xffffffff                                 ; FACF86  [103]
	.long 0xffffffff                                 ; FACF8A  [104]
	.long 0xffffffff                                 ; FACF8E  [105]
	.long 0xffffffff                                 ; FACF92  [106]
	.long 0xffffffff                                 ; FACF96  [107]
	.long 0xffffffff                                 ; FACF9A  [108]
	.long 0xffffffff                                 ; FACF9E  [109]
	.long 0xffffffff                                 ; FACFA2  [110]
	.long 0xffffffff                                 ; FACFA6  [111]
	.long 0xffffffff                                 ; FACFAA  [112]
	.long 0xffffffff                                 ; FACFAE  [113]
	.long 0xffffffff                                 ; FACFB2  [114]
	.long 0xffffffff                                 ; FACFB6  [115]
	.long 0xffffffff                                 ; FACFBA  [116]
	.long 0xffffffff                                 ; FACFBE  [117]
	.long 0xffffffff                                 ; FACFC2  [118]
	.long 0xffffffff                                 ; FACFC6  [119]
	.long 0x00007622                                 ; FACFCA  [120]
	.long 0x000078b2                                 ; FACFCE  [121]
	.long 0x00007ee2                                 ; FACFD2  [122]
	.long 0xffffffff                                 ; FACFD6  [123]
	.long 0xffffffff                                 ; FACFDA  [124]
	.long 0xffffffff                                 ; FACFDE  [125]
	.long 0xffffffff                                 ; FACFE2  [126]
	.long 0xffffffff                                 ; FACFE6  [127]
	.long 0x00007f32                                 ; FACFEA  [128]
	.long 0xffffffff                                 ; FACFEE  [129]
	.long 0xffffffff                                 ; FACFF2  [130]
	.long 0xffffffff                                 ; FACFF6  [131]
	.long 0xffffffff                                 ; FACFFA  [132]
	.long 0xffffffff                                 ; FACFFE  [133]
	.long 0xffffffff                                 ; FAD002  [134]
	.long 0xffffffff                                 ; FAD006  [135]
	.long 0xffffffff                                 ; FAD00A  [136]
	.long 0xffffffff                                 ; FAD00E  [137]
	.long 0xffffffff                                 ; FAD012  [138]
	.long 0xffffffff                                 ; FAD016  [139]
	.long 0xffffffff                                 ; FAD01A  [140]
	.long 0xffffffff                                 ; FAD01E  [141]
	.long 0xffffffff                                 ; FAD022  [142]
	.long 0xffffffff                                 ; FAD026  [143]
	.long 0xffffffff                                 ; FAD02A  [144]
	.long 0x00007f4a                                 ; FAD02E  [145]
	.long 0x000078a2                                 ; FAD032  [146]
	.long 0x00007f5a                                 ; FAD036  [147]
	.long 0xffffffff                                 ; FAD03A  [148]
	.long 0xffffffff                                 ; FAD03E  [149]
	.long 0xffffffff                                 ; FAD042  [150]
	.long 0xffffffff                                 ; FAD046  [151]
	.long 0x00007f02                                 ; FAD04A  [152]
	.long 0x00007f12                                 ; FAD04E  [153]
	.long 0xffffffff                                 ; FAD052  [154]
	.long 0xffffffff                                 ; FAD056  [155]
	.long 0xffffffff                                 ; FAD05A  [156]
	.long 0xffffffff                                 ; FAD05E  [157]
	.long 0xffffffff                                 ; FAD062  [158]
	.long 0xffffffff                                 ; FAD066  [159]
	.long 0xffffffff                                 ; FAD06A  [160]
	.long 0xffffffff                                 ; FAD06E  [161]
	.long 0xffffffff                                 ; FAD072  [162]
	.long 0xffffffff                                 ; FAD076  [163]
	.long 0xffffffff                                 ; FAD07A  [164]
	.long 0xffffffff                                 ; FAD07E  [165]
	.long 0xffffffff                                 ; FAD082  [166]
	.long 0xffffffff                                 ; FAD086  [167]
	.long 0xffffffff                                 ; FAD08A  [168]
	.long 0xffffffff                                 ; FAD08E  [169]
	.long 0xffffffff                                 ; FAD092  [170]
	.long 0xffffffff                                 ; FAD096  [171]
	.long 0xffffffff                                 ; FAD09A  [172]
	.long 0xffffffff                                 ; FAD09E  [173]
	.long 0xffffffff                                 ; FAD0A2  [174]
	.long 0xffffffff                                 ; FAD0A6  [175]
	.long 0xffffffff                                 ; FAD0AA  [176]
	.long 0xffffffff                                 ; FAD0AE  [177]
	.long 0xffffffff                                 ; FAD0B2  [178]
	.long 0xffffffff                                 ; FAD0B6  [179]
	.long 0xffffffff                                 ; FAD0BA  [180]
	.long 0xffffffff                                 ; FAD0BE  [181]
	.long 0xffffffff                                 ; FAD0C2  [182]
	.long 0xffffffff                                 ; FAD0C6  [183]
	.long 0xffffffff                                 ; FAD0CA  [184]
	.long 0xffffffff                                 ; FAD0CE  [185]
	.long 0xffffffff                                 ; FAD0D2  [186]
	.long 0xffffffff                                 ; FAD0D6  [187]
	.long 0xffffffff                                 ; FAD0DA  [188]
	.long 0xffffffff                                 ; FAD0DE  [189]
	.long 0xffffffff                                 ; FAD0E2  [190]
	.long 0xffffffff                                 ; FAD0E6  [191]
	.long 0xffffffff                                 ; FAD0EA  [192]
	.long 0xffffffff                                 ; FAD0EE  [193]
	.long 0xffffffff                                 ; FAD0F2  [194]
	.long 0xffffffff                                 ; FAD0F6  [195]
	.long 0xffffffff                                 ; FAD0FA  [196]
	.long 0xffffffff                                 ; FAD0FE  [197]
	.long 0xffffffff                                 ; FAD102  [198]
	.long 0xffffffff                                 ; FAD106  [199]
	.long 0xffffffff                                 ; FAD10A  [200]
	.long 0xffffffff                                 ; FAD10E  [201]
	.long 0xffffffff                                 ; FAD112  [202]
	.long 0xffffffff                                 ; FAD116  [203]
	.long 0xffffffff                                 ; FAD11A  [204]
	.long 0xffffffff                                 ; FAD11E  [205]
	.long 0xffffffff                                 ; FAD122  [206]
	.long 0xffffffff                                 ; FAD126  [207]
	.long 0xffffffff                                 ; FAD12A  [208]
	.long 0xffffffff                                 ; FAD12E  [209]
	.long 0xffffffff                                 ; FAD132  [210]
	.long 0xffffffff                                 ; FAD136  [211]
	.long 0xffffffff                                 ; FAD13A  [212]
	.long 0xffffffff                                 ; FAD13E  [213]
	.long 0xffffffff                                 ; FAD142  [214]
	.long 0xffffffff                                 ; FAD146  [215]
	.long 0xffffffff                                 ; FAD14A  [216]
	.long 0xffffffff                                 ; FAD14E  [217]
	.long 0xffffffff                                 ; FAD152  [218]
	.long 0xffffffff                                 ; FAD156  [219]
	.long 0xffffffff                                 ; FAD15A  [220]
	.long 0xffffffff                                 ; FAD15E  [221]
	.long 0xffffffff                                 ; FAD162  [222]
	.long 0xffffffff                                 ; FAD166  [223]
	.long 0xffffffff                                 ; FAD16A  [224]
	.long 0xffffffff                                 ; FAD16E  [225]
	.long 0xffffffff                                 ; FAD172  [226]
	.long 0xffffffff                                 ; FAD176  [227]
	.long 0xffffffff                                 ; FAD17A  [228]
	.long 0xffffffff                                 ; FAD17E  [229]
	.long 0xffffffff                                 ; FAD182  [230]
	.long 0xffffffff                                 ; FAD186  [231]
	.long 0xffffffff                                 ; FAD18A  [232]
	.long 0xffffffff                                 ; FAD18E  [233]
	.long 0xffffffff                                 ; FAD192  [234]
	.long 0xffffffff                                 ; FAD196  [235]
	.long 0xffffffff                                 ; FAD19A  [236]
	.long 0xffffffff                                 ; FAD19E  [237]
	.long 0xffffffff                                 ; FAD1A2  [238]
	.long 0xffffffff                                 ; FAD1A6  [239]
	.long 0xffffffff                                 ; FAD1AA  [240]
	.long 0xffffffff                                 ; FAD1AE  [241]
	.long 0xffffffff                                 ; FAD1B2  [242]
	.long 0xffffffff                                 ; FAD1B6  [243]
	.long 0xffffffff                                 ; FAD1BA  [244]
	.long 0xffffffff                                 ; FAD1BE  [245]
	.long 0xffffffff                                 ; FAD1C2  [246]
	.long 0xffffffff                                 ; FAD1C6  [247]
	.long 0xffffffff                                 ; FAD1CA  [248]
	.long 0xffffffff                                 ; FAD1CE  [249]
	.long 0xffffffff                                 ; FAD1D2  [250]
	.long 0xffffffff                                 ; FAD1D6  [251]
	.long 0xffffffff                                 ; FAD1DA  [252]
	.long 0xffffffff                                 ; FAD1DE  [253]
	.long 0xffffffff                                 ; FAD1E2  [254]
	.long 0xffffffff                                 ; FAD1E6  [255]
; ---------------------------------------------------------------------
; Bytes_00_to_1F -- 32 bytes, 0x00 0x01 ... 0x1F
;
; Read by: NOTHING FOUND.  No `call`/`jp`/`lda`/24-bit memory operand and no
;          LE32 pointer anywhere in prom_a or prom_b names 0xFAD1EA -- a
;          searched negative, and the search is the one described in
;          notes/prom_a_byte_checks.py (the 3-byte little-endian address at
;          every offset of both images), not a single spelling.
; Layout:  one byte per entry, 32 entries, value == index.
; Evidence: `list(bytes) == list(range(32))`, checked whole.
; ENTRY COUNT 32: both ends are pinned by something other than this table --
;          0xFAD1EA is ParamNumber_RecordPtrs's last-entry boundary (above) and
;          0xFAD20A is BitMask32_Table's base, which its eleven readers name as
;          a 32-bit immediate.
; Unknown:  what it is for.  An identity table is what a compiler emits for a
;          switch whose cases happen to be dense, but nothing here reads it.
; ---------------------------------------------------------------------
Bytes_00_to_1F:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FAD1EA
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FAD1FA
; ---------------------------------------------------------------------
; BitMask32_Table -- the 32 powers of two, 1 << k for k = 0..31
;
; Read by: ELEVEN sites, all in this module, 0xFAC176 to 0xFAC265.  Two spell
;          the base `lda XBC,0xFAD20A` (op 0x31) and nine `lda XWA,0xFAD20A`
;          (op 0x30); each is immediately followed by an `add` that indexes it
;          and a load of the 32-bit word, e.g.
;            0xFAC18F  lda XWA,0xFAD20A / add XWA,XIX / ld XIY,(XWA)
;                      / or (0x60F284),XIY
;          XIX carries an already-scaled offset, so the index is k and the
;          value read is the k-th bit.  The eleven differ only in which word of
;          a flag block at 0x60F280.. they OR into.
; Layout:  32 LE32 entries, entry k = 1 << k.
; Evidence: `[le32(k) for k in range(32)] == [1 << k for k in range(32)]`,
;          checked whole rather than at the ends; entry 31 is 0x80000000.
; ENTRY COUNT 32: the table is exactly 128 bytes between two independently
;          pinned addresses -- 0xFAD20A, named as an immediate by all eleven
;          readers, and 0xFAD28A, named as an immediate by the two readers of
;          the pointer table that follows.  ★ LAST-ENTRY TEST: entry 31 =
;          0x80000000 is the largest a 32-bit shift can produce, and the four
;          bytes after it are 0x00F3F480, an address, not 0x00000000.
; Purpose:  the value is OR'd into a 32-bit flag word at (0x60F280), so this is
;          a bit-set-by-index helper for that word.
; ---------------------------------------------------------------------
BitMask32_Table:
	.long 0x00000001                                 ; FAD20A  [  0]
	.long 0x00000002                                 ; FAD20E  [  1]
	.long 0x00000004                                 ; FAD212  [  2]
	.long 0x00000008                                 ; FAD216  [  3]
	.long 0x00000010                                 ; FAD21A  [  4]
	.long 0x00000020                                 ; FAD21E  [  5]
	.long 0x00000040                                 ; FAD222  [  6]
	.long 0x00000080                                 ; FAD226  [  7]
	.long 0x00000100                                 ; FAD22A  [  8]
	.long 0x00000200                                 ; FAD22E  [  9]
	.long 0x00000400                                 ; FAD232  [ 10]
	.long 0x00000800                                 ; FAD236  [ 11]
	.long 0x00001000                                 ; FAD23A  [ 12]
	.long 0x00002000                                 ; FAD23E  [ 13]
	.long 0x00004000                                 ; FAD242  [ 14]
	.long 0x00008000                                 ; FAD246  [ 15]
	.long 0x00010000                                 ; FAD24A  [ 16]
	.long 0x00020000                                 ; FAD24E  [ 17]
	.long 0x00040000                                 ; FAD252  [ 18]
	.long 0x00080000                                 ; FAD256  [ 19]
	.long 0x00100000                                 ; FAD25A  [ 20]
	.long 0x00200000                                 ; FAD25E  [ 21]
	.long 0x00400000                                 ; FAD262  [ 22]
	.long 0x00800000                                 ; FAD266  [ 23]
	.long 0x01000000                                 ; FAD26A  [ 24]
	.long 0x02000000                                 ; FAD26E  [ 25]
	.long 0x04000000                                 ; FAD272  [ 26]
	.long 0x08000000                                 ; FAD276  [ 27]
	.long 0x10000000                                 ; FAD27A  [ 28]
	.long 0x20000000                                 ; FAD27E  [ 29]
	.long 0x40000000                                 ; FAD282  [ 30]
	.long 0x80000000                                 ; FAD286  [ 31]
; ---------------------------------------------------------------------
; ParamNumber_DefaultRecordPtrs -- 64 LE32 addresses inside prom_b, stepping by 0x40
;          (was ParamNumber_DefaultRecordPtrs): the default record of each parameter number.
;
; Read by: TWO sites, both `add XBC,0x00FAD28A / ld XBC,(XBC)` -- 0xFAA9A8 and
;          0xFAAE46 -- so a 32-bit value indexed by an already-scaled register.
; Evidence: all 64 entries lie in 0xF00000-0xF7FFFF, i.e. prom_b, which is the
;          other half of the same 1 MiB program image (see this file's banner).
;          The first three are 0x00F3F480, 0x00F3F4C0, 0x00F3F500.
; ENTRY COUNT 64, and how it is established: BOTH ENDS are named by a reader as
;          a 32-bit immediate and neither is read off this table -- 0xFAD28A by
;          the two sites above, and 0xFAD38A by `add XBC,0x00FAD38A` at
;          0xFAAFCE and 0xFAB031, which is the base of the byte table below.
;          (0xFAD38A - 0xFAD28A) / 4 = 64.  ★ LAST-ENTRY TEST: entry 63 is
;          0x00F3FCA0 and the four bytes after it are 78 60 61 62 -- not an
;          address, and the start of a run of small bytes.
; WHAT THE ENTRIES ARE -- established 2026-09-25 (lane proma), checks D1-D3 of
;          notes/proma-2026-09-25/gen_default_records.py: entry[n] is the ROM
;          DEFAULT of the RAM record ParamNumber_RecordPtrs[n].  The two tables
;          move in lockstep, entry[n] = ParamNumber_RecordPtrs[n] + 0xF37DDE for
;          all 64 (the +0x80 jump after part 7 and the +0x20 second halves
;          included); the prom_b record at entry[n] is `[op][len][payload]`
;          (prom_b's 0xF3F400 module framing) with op == n and len == 0x1E;
;          and both readers copy payload bytes into the RAM record of the same
;          number -- PartSettings_ResetToDefault all `len` bytes from +2 (numbers 0x00-0x1F,
;          then 0x20-0x3F through +0x80), MidiSettings_ResetToDefault bytes 0x0D..0x15 of the
;          32 first halves.  So prom_b 0xF3F480-0xF3FCBF is the part records'
;          factory defaults.
; ★ CORRECTED: the two lines this replaces said what lives at 0xF3Fxxx was
;          open and that nothing here reads through the pointer; both readers
;          above do.
; ---------------------------------------------------------------------
ParamNumber_DefaultRecordPtrs:
	.long Rec_F3F480                                 ; FAD28A  [  0]
	.long Rec_F3F4C0                                 ; FAD28E  [  1]
	.long Rec_F3F500                                 ; FAD292  [  2]
	.long Rec_F3F540                                 ; FAD296  [  3]
	.long Rec_F3F580                                 ; FAD29A  [  4]
	.long Rec_F3F5C0                                 ; FAD29E  [  5]
	.long Rec_F3F600                                 ; FAD2A2  [  6]
	.long Rec_F3F640                                 ; FAD2A6  [  7]
	.long Rec_F3F6C0                                 ; FAD2AA  [  8]
	.long Rec_F3F700                                 ; FAD2AE  [  9]
	.long Rec_F3F740                                 ; FAD2B2  [ 10]
	.long Rec_F3F780                                 ; FAD2B6  [ 11]
	.long Rec_F3F7C0                                 ; FAD2BA  [ 12]
	.long Rec_F3F800                                 ; FAD2BE  [ 13]
	.long Rec_F3F840                                 ; FAD2C2  [ 14]
	.long Rec_F3F880                                 ; FAD2C6  [ 15]
	.long Rec_F3F8C0                                 ; FAD2CA  [ 16]
	.long Rec_F3F900                                 ; FAD2CE  [ 17]
	.long Rec_F3F940                                 ; FAD2D2  [ 18]
	.long Rec_F3F980                                 ; FAD2D6  [ 19]
	.long Rec_F3F9C0                                 ; FAD2DA  [ 20]
	.long Rec_F3FA00                                 ; FAD2DE  [ 21]
	.long Rec_F3FA40                                 ; FAD2E2  [ 22]
	.long Rec_F3FA80                                 ; FAD2E6  [ 23]
	.long Rec_F3FAC0                                 ; FAD2EA  [ 24]
	.long Rec_F3FB00                                 ; FAD2EE  [ 25]
	.long Rec_F3FB40                                 ; FAD2F2  [ 26]
	.long Rec_F3FB80                                 ; FAD2F6  [ 27]
	.long Rec_F3FBC0                                 ; FAD2FA  [ 28]
	.long Rec_F3FC00                                 ; FAD2FE  [ 29]
	.long Rec_F3FC40                                 ; FAD302  [ 30]
	.long Rec_F3FC80                                 ; FAD306  [ 31]
	.long Rec_F3F4A0                                 ; FAD30A  [ 32]
	.long Rec_F3F4E0                                 ; FAD30E  [ 33]
	.long Rec_F3F520                                 ; FAD312  [ 34]
	.long Rec_F3F560                                 ; FAD316  [ 35]
	.long Rec_F3F5A0                                 ; FAD31A  [ 36]
	.long Rec_F3F5E0                                 ; FAD31E  [ 37]
	.long Rec_F3F620                                 ; FAD322  [ 38]
	.long Rec_F3F660                                 ; FAD326  [ 39]
	.long Rec_F3F6E0                                 ; FAD32A  [ 40]
	.long Rec_F3F720                                 ; FAD32E  [ 41]
	.long Rec_F3F760                                 ; FAD332  [ 42]
	.long Rec_F3F7A0                                 ; FAD336  [ 43]
	.long Rec_F3F7E0                                 ; FAD33A  [ 44]
	.long Rec_F3F820                                 ; FAD33E  [ 45]
	.long Rec_F3F860                                 ; FAD342  [ 46]
	.long Rec_F3F8A0                                 ; FAD346  [ 47]
	.long Rec_F3F8E0                                 ; FAD34A  [ 48]
	.long Rec_F3F920                                 ; FAD34E  [ 49]
	.long Rec_F3F960                                 ; FAD352  [ 50]
	.long Rec_F3F9A0                                 ; FAD356  [ 51]
	.long Rec_F3F9E0                                 ; FAD35A  [ 52]
	.long Rec_F3FA20                                 ; FAD35E  [ 53]
	.long Rec_F3FA60                                 ; FAD362  [ 54]
	.long Rec_F3FAA0                                 ; FAD366  [ 55]
	.long Rec_F3FAE0                                 ; FAD36A  [ 56]
	.long Rec_F3FB20                                 ; FAD36E  [ 57]
	.long Rec_F3FB60                                 ; FAD372  [ 58]
	.long Rec_F3FBA0                                 ; FAD376  [ 59]
	.long Rec_F3FBE0                                 ; FAD37A  [ 60]
	.long Rec_F3FC20                                 ; FAD37E  [ 61]
	.long Rec_F3FC60                                 ; FAD382  [ 62]
	.long Rec_F3FCA0                                 ; FAD386  [ 63]
; ---------------------------------------------------------------------
; ByteTable_FAD38A -- 13 bytes: 78 60 61 62 63 92 79 7A 98 99 80 91 93
;
; Read by: TWO sites, `add XBC,0x00FAD38A / ld A,(XBC)` at 0xFAAFCE and the
;          same shape at 0xFAB031 -- a BYTE fetch, which is why this block is
;          `.byte` and not `.long`.
; ENTRY COUNT 13: 0xFAD397, the first byte after it, is itself named as a
;          32-bit immediate by `add XBC,0x00FAD397` at 0xFAAFE0 -- so the end
;          is fixed by another reader, not by where the values stop looking
;          like bytes.  ★ LAST-ENTRY TEST: entry 12 is 0x93 and the four bytes
;          at 0xFAD397 are 00 F4 F3 00 = the address 0x00F3F400.
; Unknown:  what the thirteen values select.  They are not ASCII, not indices
;          0..12, and not sorted.
; Evidence: BOTH ENDS are named by readers -- `add XBC,0x00FAD38A / ld A,(XBC)`
;          at 0xFAAFCE and 0xFAB031 for the base, `add XBC,0x00FAD397` at
;          0xFAAFE0 for the end -- and the fetch is a BYTE fetch, which is what
;          the name says.  Checked in notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
ByteTable_FAD38A:
	.byte 0x78, 0x60, 0x61, 0x62, 0x63, 0x92, 0x79, 0x7a, 0x98, 0x99, 0x80, 0x91, 0x93  ; FAD38A
; ---------------------------------------------------------------------
; PtrTable_FAD397 -- 13 LE32 addresses inside prom_b
;
; Read by: ONE site, `add XBC,0x00FAD397 / ld XBC,(XBC)` at 0xFAAFE0, four
;          instructions after the byte table above is read -- so the two are
;          indexed together, thirteen entries each.
; Evidence: all 13 entries lie in prom_b; 0x00F3F400, 0x00F3F412, 0x00F3F420,
;          0x00F3F440, 0x00F3F460, 0x00F3F680, 0x00F3F690, 0x00F3FCC0,
;          0x00F3FCE0, 0x00F3FCF0, 0x00F3FD10, 0x00F3FD28, 0x00F3FD38.
; ENTRY COUNT 13: 0xFAD3CB, the byte after the last entry, is named as a
;          32-bit immediate by `add XBC,0x00FAD3CB / ld H,(XBC)` at 0xFAB670 --
;          again an independent reader.  (0xFAD3CB - 0xFAD397) / 4 = 13, the
;          same count as ByteTable_FAD38A.  ★ LAST-ENTRY TEST: entry 12 is
;          0x00F3FD38 and the byte at 0xFAD3CB is 0x0F, which is not part of
;          any address in this table.
; ---------------------------------------------------------------------
PtrTable_FAD397:
	.long Rec_F3F400                                 ; FAD397  [  0]
	.long Rec_F3F412                                 ; FAD39B  [  1]
	.long Rec_F3F420                                 ; FAD39F  [  2]
	.long Rec_F3F440                                 ; FAD3A3  [  3]
	.long Rec_F3F460                                 ; FAD3A7  [  4]
	.long Rec_F3F680                                 ; FAD3AB  [  5]
	.long Rec_F3F690                                 ; FAD3AF  [  6]
	.long Rec_F3FCC0                                 ; FAD3B3  [  7]
	.long Rec_F3FCE0                                 ; FAD3B7  [  8]
	.long Rec_F3FCF0                                 ; FAD3BB  [  9]
	.long Rec_F3FD10                                 ; FAD3BF  [ 10]
	.long Rec_F3FD28                                 ; FAD3C3  [ 11]
	.long Rec_F3FD38                                 ; FAD3C7  [ 12]
; ---------------------------------------------------------------------
; Bytes_0F_FAD3CB -- 32 bytes, every one of them 0x0F
;
; Read by: ONE site, `add XBC,0x00FAD3CB / ld H,(XBC)` at 0xFAB670; the value
;          is then compared against (XIX) and, if (XIX) is greater, (XIX) is
;          zeroed -- so it is a per-index CEILING, and every index's ceiling is
;          the same, 15.
; Evidence: set(bytes) == {0x0F} over the whole 32, checked byte by byte.
; ENTRY COUNT 32: the run of 0x0F is exactly 32 bytes long and the byte after
;          it, 0xFAD3EB, is 0x00.  ⚠ Unlike the three tables above, this end is
;          established by the DATA and not by a second reader, because nothing
;          names 0xFAD3EB.
; ---------------------------------------------------------------------
Bytes_0F_FAD3CB:
	.byte 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f  ; FAD3CB
	.byte 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f  ; FAD3DB
; ---------------------------------------------------------------------
; DuplicateTail_FAD3EB -- 154 bytes that are a byte-for-byte COPY of
;                         0xFAD351-0xFAD3EA, and nothing names any of them
;
; ★ THE SECOND DUPLICATE IN THIS MODULE.  0xFAD3EB-0xFAD484 and
; 0xFAD351-0xFAD3EA are 154 identical bytes, delta 0x9A; the match is maximal
; in both directions (0xFAD3EA/0xFAD484 differ: 0x00 against 0x0E, and 0x0E is
; the first byte of the module's padding).
;
; What that copy contains, read as the original's structure: the last 14 of
; ParamNumber_DefaultRecordPtrs's 64 entries (0x00F3F960 ... 0x00F3FCA0), then all 13 bytes
; of ByteTable_FAD38A, then all 13 entries of PtrTable_FAD397, then 32 more
; 0x0F bytes.  ⚠ That is the ORIGINAL's framing carried over, not a framing
; derived here: NOTHING NAMES 0xFAD3EB, 0xFAD3EC, 0xFAD424, 0xFAD431 or
; 0xFAD465 -- searched over prom_a and prom_b for the 3-byte little-endian
; address at every offset, which covers `call`, `jp`, `lda`, a bare LE32
; pointer and any 24-bit memory operand.  The three tables above are each named
; by a reader; none of the copies is.  So this block is emitted as `.byte`,
; with no entry counts claimed for it.
;
; The last byte, 0xFAD485 = 0x0E, is the first byte of the module's 891-byte
; 0x0E pad and is inside this block only because notes/gen_prom_a_block.py
; hands the first byte of a 0x0E run back to the CODE before it, and what
; precedes this run is data.  The `.fill` below is therefore 890 bytes, not
; 891; both numbers describe the same ROM.
;
; Read together with the veneer-bank duplicate in this file's banner, the
; module contains TWO regions that are copies of material it also holds
; elsewhere and that nothing names.  Whether one mechanism produced both is
; NOT established here.
; Evidence: `A[0xFAD3EB:+154] == A[0xFAD351:+154]` and the match is maximal in
;          both directions, and no LE24 mention of any address inside the copy
;          exists in prom_a or prom_b.  Both in notes/prom_a_byte_checks.py,
;          checks named "DuplicateTail_FAD3EB:".
; ---------------------------------------------------------------------
DuplicateTail_FAD3EB:
	.byte 0x00, 0x60, 0xf9, 0xf3, 0x00, 0xa0, 0xf9, 0xf3, 0x00, 0xe0, 0xf9, 0xf3, 0x00, 0x20, 0xfa, 0xf3  ; FAD3EB
	.byte 0x00, 0x60, 0xfa, 0xf3, 0x00, 0xa0, 0xfa, 0xf3, 0x00, 0xe0, 0xfa, 0xf3, 0x00, 0x20, 0xfb, 0xf3  ; FAD3FB
	.byte 0x00, 0x60, 0xfb, 0xf3, 0x00, 0xa0, 0xfb, 0xf3, 0x00, 0xe0, 0xfb, 0xf3, 0x00, 0x20, 0xfc, 0xf3  ; FAD40B
	.byte 0x00, 0x60, 0xfc, 0xf3, 0x00, 0xa0, 0xfc, 0xf3, 0x00, 0x78, 0x60, 0x61, 0x62, 0x63, 0x92, 0x79  ; FAD41B
	.byte 0x7a, 0x98, 0x99, 0x80, 0x91, 0x93, 0x00, 0xf4, 0xf3, 0x00, 0x12, 0xf4, 0xf3, 0x00, 0x20, 0xf4  ; FAD42B
	.byte 0xf3, 0x00, 0x40, 0xf4, 0xf3, 0x00, 0x60, 0xf4, 0xf3, 0x00, 0x80, 0xf6, 0xf3, 0x00, 0x90, 0xf6  ; FAD43B
	.byte 0xf3, 0x00, 0xc0, 0xfc, 0xf3, 0x00, 0xe0, 0xfc, 0xf3, 0x00, 0xf0, 0xfc, 0xf3, 0x00, 0x10, 0xfd  ; FAD44B
	.byte 0xf3, 0x00, 0x28, 0xfd, 0xf3, 0x00, 0x38, 0xfd, 0xf3, 0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f  ; FAD45B
	.byte 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f  ; FAD46B
	.byte 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0e    ; FAD47B

; 0xFAD486-0xFAD7FF -- 890 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 890, 1, 0x0E
