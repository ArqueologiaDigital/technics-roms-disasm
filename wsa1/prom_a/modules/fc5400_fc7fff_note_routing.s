; =====================================================================
; 0xFC5400-0xFC6FFF -- the second module of this round
;
; Chosen by notes/prom_a_call_graph.py --modules: after the 0xFAA000 module was
; converted, T_F411B4-T_F411EC (x65 over 15 slots, targets 0xFC546A-0xFC5B25)
; was the highest-ranked unconverted module whose span passes the decode check.
;
; EXTENT: 0xFC52F8-0xFC53FF is 264 bytes of 0x0E and 0xFC6844-0xFC6FFF is 1980
; more, so the module is what lies between two pad runs -- the same criterion
; used for 0xFAA000 above, and found by the same scan.
;
; DECODE STATUS, per notes/prom_a_linear_decode_check.py:
;   0xFC5400-0xFC59DB  self-consistent  (11 directory slots, all on boundaries)
;   0xFC59DB-0xFC5A03  NoteRouting_MidiSystemByteCases, declared as data
;   0xFC5A03-0xFC64A5  self-consistent  (4 directory slots, all on boundaries)
;   0xFC64A5-0xFC6844  data: five tables, four of them named by a reader
;   0xFC6844-0xFC6FFF  0x0E padding
; Run over the whole module in one piece it reports 33 `db` bytes and FAILS;
; split at the declared data it passes on both code halves.  That split is the
; claim this block makes, and it is the thing to re-run if anything here is
; doubted.
;
; ⚠ WHY THE NEIGHBOURING MODULE IS NOT HERE.  0xFC0000-0xFC25EC (x94 over 39
; slots, the higher-ranked target) was examined and LEFT: its linear decode
; reports 60 `db` bytes and, worse, EIGHT published directory slots that are not
; instruction boundaries (0xFC0427, 0xFC043D, 0xFC0452-0xFC0454, 0xFC2155,
; 0xFC2213, 0xFC2222).  It holds at least an 8-byte-record table at
; 0xFC0890-0xFC0990 (32 records of {LE32 RAM address 0x600+8k, LE16 mask
; 1<<(k&15), byte k, 0x0E}) and the ASCII labels "Combi Group Name" and
; "EXT Silent Group" at 0xFC2135.  Converting it
; means resolving those eight slots first; guessing the boundaries would put
; invented instructions in the file and the byte gate would not notice.
; =====================================================================
; NoteRouting_PhaseVector: the address in slot 0xF411B0, ModuleInitDirectory_F82641[21]: a phase vector.  Phase 0 jumps to NoteRouting_InitRam
;   and then NoteRouting_InitDefaults; phases 1..5 are bare rets.
NoteRouting_PhaseVector:
	jp NoteRouting_PhaseVector_Join                                        ; FC5400  1b 18 54 fc
	ret                                                  ; FC5404  0e
	nop                                                  ; FC5405  00
	nop                                                  ; FC5406  00
	nop                                                  ; FC5407  00
	ret                                                  ; FC5408  0e
	nop                                                  ; FC5409  00
	nop                                                  ; FC540A  00
	nop                                                  ; FC540B  00
	ret                                                  ; FC540C  0e
	nop                                                  ; FC540D  00
	nop                                                  ; FC540E  00
	nop                                                  ; FC540F  00
	ret                                                  ; FC5410  0e
	nop                                                  ; FC5411  00
	nop                                                  ; FC5412  00
	nop                                                  ; FC5413  00
	ret                                                  ; FC5414  0e
	nop                                                  ; FC5415  00
	nop                                                  ; FC5416  00
	nop                                                  ; FC5417  00
NoteRouting_PhaseVector_Join:
	calr NoteRouting_InitRam                                      ; FC5418  1e 05 00
	call NoteRouting_InitDefaults                                      ; FC541B  1d 93 63 fc
	ret                                                  ; FC541F  0e
; NoteRouting_InitRam: an empty data copy (0 bytes from Bytes_00_to_1F_FC64A5 to address 0), the 3 bytes at 0x4C20 zeroed, and the
;   0x784 bytes from NoteRouting (0x602200..0x602983, the block and its previous copy) filled with 0xFF.
NoteRouting_InitRam:
	ld XBC,0x00000000                                    ; FC5420  41 00 00 00 00
	and XBC,XBC                                          ; FC5425  e9 c1
	jr z, .LFC5435                                       ; FC5427  66 0c
	lda xiy, (Bytes_00_to_1F_FC64A5:24)                  ; FC5429  f2 a5 64 fc 35
	lda xix, (0x00:24)                                   ; FC542E  f2 00 00 00 34
	ldir85                                               ; FC5433  85 11
.LFC5435:
	ld XBC,0x00000003                                    ; FC5435  41 03 00 00 00
	and XBC,XBC                                          ; FC543A  e9 c1
	jr z, .LFC544E                                       ; FC543C  66 10
	lda xix, (0x4c20:24)                                 ; FC543E  f2 20 4c 00 34
	xor WA,WA                                            ; FC5443  d8 d0
.LFC5445:
	ld (xix+), a                                    ; FC5445  f5 f0 41
	sub BC,0x0001                                        ; FC5448  d9 ca 01 00
	jr nz, .LFC5445                                      ; FC544C  6e f7
.LFC544E:
	ld XBC,0x00000784                                    ; FC544E  41 84 07 00 00
	and XBC,XBC                                          ; FC5453  e9 c1
	jr z, .LFC5468                                       ; FC5455  66 11
	lda xix, (NoteRouting:24)                               ; FC5457  f2 00 22 60 34
	ldw wa, 0xffff                                       ; FC545C  30 ff ff
.LFC545F:
	ld (xix+), a                                    ; FC545F  f5 f0 41
	sub BC,0x0001                                        ; FC5462  d9 ca 01 00
	jr nz, .LFC545F                                      ; FC5466  6e f7
.LFC5468:
	ret                                                  ; FC5468  0e
	ret                                                  ; FC5469  0e
; NoteRouting_RebuildIfPending: T_NoteRouting_RebuildIfPending, in UiEventPassB_TailList (run after the pass-B event lists): when NoteRouting_ChangeFlags bit 15 is set --
;   the parameter-event handlers set it -- block +0 = (0x4C22) | (0x4C21), NoteRouting_BuildByPanelMode[PanelMode]
;   with 0 unless that is the stub .LFC5C6C, NoteRouting_UpdateActivePartMask, NoteRouting_CommitChanges.  The bit
;   it clears first is bit 7 of 0x4C01, not of 0x4C05 (0xFC5479); the commit clears the whole word anyway.
NoteRouting_RebuildIfPending:
	link XIZ,0xfffc                                      ; FC546A  ee 0c fc ff
	push XIX                                             ; FC546E  3c
	ld bc, (NoteRouting_ChangeFlags:16)                                 ; FC546F  d1 04 4c 21
	and BC,0x8000                                        ; FC5473  d9 cc 00 80
	jr z, .LFC54C2                                       ; FC5477  66 49
	res	7, (0x4c01:16)                               ; FC5479  f1 01 4c b7
	ld c, (0x4c22:24)                                   ; FC547D  c2 22 4c 00 23
	or c, (0x4c21:24)                                 ; FC5482  c2 21 4c 00 e3
	ld (NoteRouting:24), c                                 ; FC5487  f2 00 22 60 43
	ld c, 0x04:opc                                          ; FC548C  23 04
	mul	bc, (PanelMode:16)                              ; FC548E  c1 78 20 43
	extz XBC                                             ; FC5492  e9 12
	add XBC,NoteRouting_BuildByPanelMode                            ; FC5494  e9 c8 46 65 fc 00
	ld XBC,(XBC)                                         ; FC549A  a1 21
	ld XIX,XBC                                           ; FC549C  e9 8c
	ld (xiz-4), xbc                                      ; FC549E  be fc 61
	lda xwa, (.LFC5C6C:24)                               ; FC54A1  f2 6c 5c fc 30
	cp XBC,XWA                                           ; FC54A6  e8 f1
	jr z, .LFC54C2                                       ; FC54A8  66 18
	pushw 0x00                                           ; FC54AA  0b 00 00
	lda xiy, (.LFC54B5:24)                               ; FC54AD  f2 b5 54 fc 35
	push XIY                                             ; FC54B2  3d
	jp (xix)                                             ; FC54B3  b4 d8
.LFC54B5:
	call NoteRouting_UpdateActivePartMask                                      ; FC54B5  1d 53 61 fc
	call NoteRouting_RebuildStep_Nop                                      ; FC54B9  1d a5 61 fc
	call NoteRouting_CommitChanges                                      ; FC54BD  1d 7c 5c fc
	popw bc                                              ; FC54C1  49
.LFC54C2:
	pop XIX                                              ; FC54C2  5c
	unlk XIZ                                             ; FC54C3  ee 0d
	ret                                                  ; FC54C5  0e
; NoteRouting_RebuildForSong: T_NoteRouting_RebuildForSong (BStore_BootPhase3, SongSelectName_Leave, ScreenEnter_CyclePlayEditScreen): NoteRouting_BuildTrackRouting first, then
;   block +0 = (0x4C22) | (0x4C21), NoteRouting_BuildByPanelMode[PanelMode] with 0, NoteRouting_UpdateActivePartMask,
;   NoteRouting_CommitChanges.
NoteRouting_RebuildForSong:
	link XIZ,0xfffc                                      ; FC54C6  ee 0c fc ff
	push XIX                                             ; FC54CA  3c
	call NoteRouting_BuildTrackRouting                                      ; FC54CB  1d a6 61 fc
	ld c, (0x4c22:24)                                   ; FC54CF  c2 22 4c 00 23
	or c, (0x4c21:24)                                 ; FC54D4  c2 21 4c 00 e3
	ld (NoteRouting:24), c                                 ; FC54D9  f2 00 22 60 43
	ld c, 0x04:opc                                          ; FC54DE  23 04
	mul	bc, (PanelMode:16)                              ; FC54E0  c1 78 20 43
	extz XBC                                             ; FC54E4  e9 12
	add XBC,NoteRouting_BuildByPanelMode                            ; FC54E6  e9 c8 46 65 fc 00
	ld XBC,(XBC)                                         ; FC54EC  a1 21
	ld XIX,XBC                                           ; FC54EE  e9 8c
	ld (xiz-4), xbc                                      ; FC54F0  be fc 61
	lda xwa, (.LFC5C6C:24)                               ; FC54F3  f2 6c 5c fc 30
	cp XBC,XWA                                           ; FC54F8  e8 f1
	jr z, .LFC5514                                       ; FC54FA  66 18
	pushw 0x00                                           ; FC54FC  0b 00 00
	lda xiy, (.LFC5507:24)                               ; FC54FF  f2 07 55 fc 35
	push XIY                                             ; FC5504  3d
	jp (xix)                                             ; FC5505  b4 d8
.LFC5507:
	call NoteRouting_UpdateActivePartMask                                      ; FC5507  1d 53 61 fc
	call NoteRouting_RebuildStep_Nop                                      ; FC550B  1d a5 61 fc
	call NoteRouting_CommitChanges                                      ; FC550F  1d 7c 5c fc
	popw bc                                              ; FC5513  49
.LFC5514:
	pop XIX                                              ; FC5514  5c
	unlk XIZ                                             ; FC5515  ee 0d
	ret                                                  ; FC5517  0e
; NoteRouting_Rebuild: T_NoteRouting_Rebuild (CombinationMode_StepSelectedPart, ModeLeave_SeqPlay, MainTask_PhaseVector): the same without
;   NoteRouting_BuildTrackRouting, the per-mode builder called with 1.
NoteRouting_Rebuild:
	link XIZ,0xfffc                                      ; FC5518  ee 0c fc ff
	push XIX                                             ; FC551C  3c
	ld c, (0x4c22:24)                                   ; FC551D  c2 22 4c 00 23
	or c, (0x4c21:24)                                 ; FC5522  c2 21 4c 00 e3
	ld (NoteRouting:24), c                                 ; FC5527  f2 00 22 60 43
	ld c, 0x04:opc                                          ; FC552C  23 04
	mul	bc, (PanelMode:16)                              ; FC552E  c1 78 20 43
	extz XBC                                             ; FC5532  e9 12
	add XBC,NoteRouting_BuildByPanelMode                            ; FC5534  e9 c8 46 65 fc 00
	ld XBC,(XBC)                                         ; FC553A  a1 21
	ld XIX,XBC                                           ; FC553C  e9 8c
	ld (xiz-4), xbc                                      ; FC553E  be fc 61
	lda xwa, (.LFC5C6C:24)                               ; FC5541  f2 6c 5c fc 30
	cp XBC,XWA                                           ; FC5546  e8 f1
	jr z, .LFC5562                                       ; FC5548  66 18
	pushw 0x01                                           ; FC554A  0b 01 00
	lda xiy, (.LFC5555:24)                               ; FC554D  f2 55 55 fc 35
	push XIY                                             ; FC5552  3d
	jp (xix)                                             ; FC5553  b4 d8
.LFC5555:
	call NoteRouting_UpdateActivePartMask                                      ; FC5555  1d 53 61 fc
	call NoteRouting_RebuildStep_Nop                                      ; FC5559  1d a5 61 fc
	call NoteRouting_CommitChanges                                      ; FC555D  1d 7c 5c fc
	popw bc                                              ; FC5561  49
.LFC5562:
	pop XIX                                              ; FC5562  5c
	unlk XIZ                                             ; FC5563  ee 0d
	ret                                                  ; FC5565  0e
; NoteRouting_SetSoloAndRebuild: T_NoteRouting_SetSoloAndRebuild: (0x602498) bit 5 = the argument (LcdKeyRow1_CombinationMode_Page2 -- the SOLO key --,
;   ScreenLeaveBody_CombinationMode, CombiEdit_CompareOn), then the rebuild with 0.
NoteRouting_SetSoloAndRebuild:
	link XIZ,0xfffc                                      ; FC5566  ee 0c fc ff
	push XIX                                             ; FC556A  3c
	cp (XIZ+0x08),0x00                                   ; FC556B  8e 08 3f 00
	jr nz, .LFC557A                                      ; FC556F  6e 09
	andw	(NoteRouting_Mode:24), 0xffdf                ; FC5571  d2 98 24 60 3c df ff
	jr .LFC5581                                          ; FC5578  68 07
.LFC557A:
	orw	(NoteRouting_Mode:24), 0x0020                ; FC557A  d2 98 24 60 3e 20 00
.LFC5581:
	ld c, (0x4c22:24)                                   ; FC5581  c2 22 4c 00 23
	or c, (0x4c21:24)                                 ; FC5586  c2 21 4c 00 e3
	ld (NoteRouting:24), c                                 ; FC558B  f2 00 22 60 43
	ld c, 0x04:opc                                          ; FC5590  23 04
	mul	bc, (PanelMode:16)                              ; FC5592  c1 78 20 43
	extz XBC                                             ; FC5596  e9 12
	add XBC,NoteRouting_BuildByPanelMode                            ; FC5598  e9 c8 46 65 fc 00
	ld XBC,(XBC)                                         ; FC559E  a1 21
	ld XIX,XBC                                           ; FC55A0  e9 8c
	ld (xiz-4), xbc                                      ; FC55A2  be fc 61
	lda xwa, (.LFC5C6C:24)                               ; FC55A5  f2 6c 5c fc 30
	cp XBC,XWA                                           ; FC55AA  e8 f1
	jr z, .LFC55C6                                       ; FC55AC  66 18
	pushw 0x00                                           ; FC55AE  0b 00 00
	lda xiy, (.LFC55B9:24)                               ; FC55B1  f2 b9 55 fc 35
	push XIY                                             ; FC55B6  3d
	jp (xix)                                             ; FC55B7  b4 d8
.LFC55B9:
	call NoteRouting_UpdateActivePartMask                                      ; FC55B9  1d 53 61 fc
	call NoteRouting_RebuildStep_Nop                                      ; FC55BD  1d a5 61 fc
	call NoteRouting_CommitChanges                                      ; FC55C1  1d 7c 5c fc
	popw bc                                              ; FC55C5  49
.LFC55C6:
	pop XIX                                              ; FC55C6  5c
	unlk XIZ                                             ; FC55C7  ee 0d
	ret                                                  ; FC55C9  0e
; NoteRouting_OnPartMidiEvent: T_NoteRouting_OnPartMidiEvent, the pass-B handler of event classes 0x00-0x1F: the 32 parts' first parameter record (the class picks the
;   part through Bytes_00_to_1F_x3_FC65C6+0x40; payload: byte index, new value, changed bits -- see
;   notes/sysex-probes/README.md).  Byte 0 (PROGRAM CHANGE & BANK): the part's three record pointers reset
;   (T_NoteRouting_DefaultRecordPtrs), ChangeFlags bit 15.  Byte 13: bits 0-4 BASIC CHANNEL -> block +0x22 + part, pointers reset, flags
;   0x8020; bit 5 LOCAL CONTROL -> tone-generator record bit 5 = NOT the bit, parts 0-7 also in (0x4C21), flags
;   0x8004; bit 6 MIDI OUT SETTING -> MIDI record bit 5 = NOT the bit, (0x4C22), 0x8020; bit 7 MIDI IN SETTING ->
;   MIDI record bit 6 = NOT the bit, 0x8020.  Byte 12 is ignored.  Names: param_names.json, PART offsets 0 and 13.
NoteRouting_OnPartMidiEvent:
	link XIZ,0xffee                                      ; FC55CA  ee 0c ee ff
	pushw hl                                             ; FC55CE  2b
	pushw de                                             ; FC55CF  2a
	push XIX                                             ; FC55D0  3c
	ldw de, 0x8020                                       ; FC55D1  32 20 80
	ld l, (UiEvent_Class:16)                                   ; FC55D4  c1 bb 20 27
	ld C,L                                               ; FC55D8  cf 8b
	extz BC                                              ; FC55DA  d9 12
	extz XBC                                             ; FC55DC  e9 12
	add XBC,Bytes_00_to_1F_x3_FC65C6+0x40                ; FC55DE  e9 c8 06 66 fc 00
	ld H,(XBC)                                           ; FC55E4  81 26
	ld bc, (UiEvent_Byte1:16)                                 ; FC55E6  d1 b8 20 21
	extz BC                                              ; FC55EA  d9 12
	cp bc, 0x00:i3                                         ; FC55EC  d9 d8
	jr z, .LFC5600                                       ; FC55EE  66 10
	cp BC,0x000c                                         ; FC55F0  d9 cf 0c 00
	jrl z, .LFC57EA                                      ; FC55F4  76 f3 01
	cp BC,0x000d                                         ; FC55F7  d9 cf 0d 00
	jr z, .LFC5667                                       ; FC55FB  66 6a
	jrl .LFC57EA                                         ; FC55FD  78 ea 01
.LFC5600:
	ld c, (UiEvent_Byte3:16)                                   ; FC5600  c1 ba 20 23
	and C,0xff                                           ; FC5604  cb cc ff
	jrl z, .LFC57EA                                      ; FC5607  76 e0 01
	pushw hl                                             ; FC560A  2b
	lda xbc, (xiz-12)                                    ; FC560B  be f4 31
	push XBC                                             ; FC560E  39
	call T_NoteRouting_DefaultRecordPtrs                                        ; FC560F  1d dc 13 f4
	ld xbc, (xiz-12)                                     ; FC5613  ae f4 21
	ld XIX,XBC                                           ; FC5616  e9 8c
	ld a, 0x06:opc                                          ; FC5618  21 06
	mul wa, h                                          ; FC561A  ce 41
	extz XWA                                             ; FC561C  e8 12
	add XWA,0x00000094                                   ; FC561E  e8 c8 94 00 00 00
	add XWA,NoteRouting                                   ; FC5624  e8 c8 00 22 60 00
	ld (XWA),XBC                                         ; FC562A  b0 61
	ld xbc, (xiz-8)                                      ; FC562C  ae f8 21
	ld XIX,XBC                                           ; FC562F  e9 8c
	ld a, 0x0a:opc                                          ; FC5631  21 0a
	mul wa, h                                          ; FC5633  ce 41
	extz XWA                                             ; FC5635  e8 12
	ld (xiz-16), xwa                                     ; FC5637  be f0 60
	add XWA,0x00000154                                   ; FC563A  e8 c8 54 01 00 00
	add XWA,NoteRouting                                   ; FC5640  e8 c8 00 22 60 00
	ld (XWA),XBC                                         ; FC5646  b0 61
	ld xbc, (xiz-4)                                      ; FC5648  ae fc 21
	ld XIX,XBC                                           ; FC564B  e9 8c
	ld xwa, (xiz-16)                                     ; FC564D  ae f0 20
	add XWA,0x00000158                                   ; FC5650  e8 c8 58 01 00 00
	add XWA,NoteRouting                                   ; FC5656  e8 c8 00 22 60 00
	ld (XWA),XBC                                         ; FC565C  b0 61
	set	7, (0x4c05:16)                               ; FC565E  f1 05 4c bf
	inc 6,XSP                                            ; FC5662  ef 66
	jrl .LFC57EA                                         ; FC5664  78 83 01
.LFC5667:
	ld c, (UiEvent_Byte3:16)                                   ; FC5667  c1 ba 20 23
	and C,0x1f                                           ; FC566B  cb cc 1f
	jr z, .LFC56D4                                       ; FC566E  66 64
	ld c, (UiEvent_Byte2:16)                                   ; FC5670  c1 b9 20 23
	and C,0x1f                                           ; FC5674  cb cc 1f
	ld (xiz-14), c                                       ; FC5677  be f2 43
	ld C,H                                               ; FC567A  ce 8b
	extz BC                                              ; FC567C  d9 12
	extz XBC                                             ; FC567E  e9 12
	add XBC,0x00000022                                   ; FC5680  e9 c8 22 00 00 00
	add XBC,NoteRouting                                   ; FC5686  e9 c8 00 22 60 00
	ld a, (xiz-14)                                       ; FC568C  8e f2 21
	ld (XBC),A                                           ; FC568F  b1 41
	pushw hl                                             ; FC5691  2b
	lda xbc, (xiz-12)                                    ; FC5692  be f4 31
	push XBC                                             ; FC5695  39
	call T_NoteRouting_DefaultRecordPtrs                                        ; FC5696  1d dc 13 f4
	ld xbc, (xiz-8)                                      ; FC569A  ae f8 21
	ld XIX,XBC                                           ; FC569D  e9 8c
	ld a, 0x0a:opc                                          ; FC569F  21 0a
	mul wa, h                                          ; FC56A1  ce 41
	extz XWA                                             ; FC56A3  e8 12
	ld (xiz-18), xwa                                     ; FC56A5  be ee 60
	add XWA,0x00000154                                   ; FC56A8  e8 c8 54 01 00 00
	add XWA,NoteRouting                                   ; FC56AE  e8 c8 00 22 60 00
	ld (XWA),XBC                                         ; FC56B4  b0 61
	ld xbc, (xiz-4)                                      ; FC56B6  ae fc 21
	ld XIX,XBC                                           ; FC56B9  e9 8c
	ld xwa, (xiz-18)                                     ; FC56BB  ae ee 20
	add XWA,0x00000158                                   ; FC56BE  e8 c8 58 01 00 00
	add XWA,NoteRouting                                   ; FC56C4  e8 c8 00 22 60 00
	ld (XWA),XBC                                         ; FC56CA  b0 61
	ld BC,DE                                             ; FC56CC  da 89
	or	(NoteRouting_ChangeFlags:16), bc                      ; FC56CE  d1 04 4c e9
	inc 6,XSP                                            ; FC56D2  ef 66
.LFC56D4:
	ld c, (UiEvent_Byte3:16)                                   ; FC56D4  c1 ba 20 23
	and C,0x20                                           ; FC56D8  cb cc 20
	jr z, .LFC5746                                       ; FC56DB  66 69
	ld c, (UiEvent_Byte2:16)                                   ; FC56DD  c1 b9 20 23
	and C,0x20                                           ; FC56E1  cb cc 20
	jr z, .LFC5715                                       ; FC56E4  66 2f
	ld c, 0x06:opc                                          ; FC56E6  23 06
	mul bc, h                                          ; FC56E8  ce 43
	extz XBC                                             ; FC56EA  e9 12
	add XBC,0x00000092                                   ; FC56EC  e9 c8 92 00 00 00
	add XBC,NoteRouting                                   ; FC56F2  e9 c8 00 22 60 00
	res 5,(XBC)                                          ; FC56F8  b1 b5
	cp h, 0x07:i3                                          ; FC56FA  ce df
	jr ugt, .LFC5740                                     ; FC56FC  6b 42
	ld c, 0x04:opc                                          ; FC56FE  23 04
	mul bc, h                                          ; FC5700  ce 43
	extz XBC                                             ; FC5702  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC5704  e9 c8 c6 64 fc 00
	ld A,(XBC)                                           ; FC570A  81 21
	cpl A                                                ; FC570C  c9 06
	and (0x4c21:24), a                                ; FC570E  c2 21 4c 00 c9
	jr .LFC5740                                          ; FC5713  68 2b
.LFC5715:
	ld c, 0x06:opc                                          ; FC5715  23 06
	mul bc, h                                          ; FC5717  ce 43
	extz XBC                                             ; FC5719  e9 12
	add XBC,0x00000092                                   ; FC571B  e9 c8 92 00 00 00
	add XBC,NoteRouting                                   ; FC5721  e9 c8 00 22 60 00
	set 5,(XBC)                                          ; FC5727  b1 bd
	cp h, 0x07:i3                                          ; FC5729  ce df
	jr ugt, .LFC5740                                     ; FC572B  6b 13
	ld c, 0x04:opc                                          ; FC572D  23 04
	mul bc, h                                          ; FC572F  ce 43
	extz XBC                                             ; FC5731  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC5733  e9 c8 c6 64 fc 00
	ld A,(XBC)                                           ; FC5739  81 21
	or (0x4c21:24), a                                 ; FC573B  c2 21 4c 00 e9
.LFC5740:
	orw	(NoteRouting_ChangeFlags:16), 0x8004                  ; FC5740  d1 04 4c 3e 04 80
.LFC5746:
	ld c, (UiEvent_Byte3:16)                                   ; FC5746  c1 ba 20 23
	and C,0x40                                           ; FC574A  cb cc 40
	jr z, .LFC57B8                                       ; FC574D  66 69
	ld c, (UiEvent_Byte2:16)                                   ; FC574F  c1 b9 20 23
	and C,0x40                                           ; FC5753  cb cc 40
	jr z, .LFC5787                                       ; FC5756  66 2f
	ld c, 0x0a:opc                                          ; FC5758  23 0a
	mul bc, h                                          ; FC575A  ce 43
	extz XBC                                             ; FC575C  e9 12
	add XBC,0x00000152                                   ; FC575E  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC5764  e9 c8 00 22 60 00
	res 5,(XBC)                                          ; FC576A  b1 b5
	cp h, 0x07:i3                                          ; FC576C  ce df
	jr ugt, .LFC57B2                                     ; FC576E  6b 42
	ld c, 0x04:opc                                          ; FC5770  23 04
	mul bc, h                                          ; FC5772  ce 43
	extz XBC                                             ; FC5774  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC5776  e9 c8 c6 64 fc 00
	ld A,(XBC)                                           ; FC577C  81 21
	cpl A                                                ; FC577E  c9 06
	and (0x4c22:24), a                                ; FC5780  c2 22 4c 00 c9
	jr .LFC57B2                                          ; FC5785  68 2b
.LFC5787:
	ld c, 0x0a:opc                                          ; FC5787  23 0a
	mul bc, h                                          ; FC5789  ce 43
	extz XBC                                             ; FC578B  e9 12
	add XBC,0x00000152                                   ; FC578D  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC5793  e9 c8 00 22 60 00
	set 5,(XBC)                                          ; FC5799  b1 bd
	cp h, 0x07:i3                                          ; FC579B  ce df
	jr ugt, .LFC57B2                                     ; FC579D  6b 13
	ld c, 0x04:opc                                          ; FC579F  23 04
	mul bc, h                                          ; FC57A1  ce 43
	extz XBC                                             ; FC57A3  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC57A5  e9 c8 c6 64 fc 00
	ld A,(XBC)                                           ; FC57AB  81 21
	or (0x4c22:24), a                                 ; FC57AD  c2 22 4c 00 e9
.LFC57B2:
	ld BC,DE                                             ; FC57B2  da 89
	or	(NoteRouting_ChangeFlags:16), bc                      ; FC57B4  d1 04 4c e9
.LFC57B8:
	ld c, (UiEvent_Byte3:16)                                   ; FC57B8  c1 ba 20 23
	and C,0x80                                           ; FC57BC  cb cc 80
	jr z, .LFC57EA                                       ; FC57BF  66 29
	ld c, 0x0a:opc                                          ; FC57C1  23 0a
	mul bc, h                                          ; FC57C3  ce 43
	extz XBC                                             ; FC57C5  e9 12
	add XBC,0x00000152                                   ; FC57C7  e9 c8 52 01 00 00
	ld XIX,XBC                                           ; FC57CD  e9 8c
	add XIX,NoteRouting                                   ; FC57CF  ec c8 00 22 60 00
	ld c, (UiEvent_Byte2:16)                                   ; FC57D5  c1 b9 20 23
	and C,0x80                                           ; FC57D9  cb cc 80
	jr z, .LFC57E2                                       ; FC57DC  66 04
	res 6,(XIX)                                          ; FC57DE  b4 b6
	jr .LFC57E4                                          ; FC57E0  68 02
.LFC57E2:
	set 6,(XIX)                                          ; FC57E2  b4 be
.LFC57E4:
	ld BC,DE                                             ; FC57E4  da 89
	or	(NoteRouting_ChangeFlags:16), bc                      ; FC57E6  d1 04 4c e9
.LFC57EA:
	pop XIX                                              ; FC57EA  5c
	popw de                                              ; FC57EB  4a
	popw hl                                              ; FC57EC  4b
	unlk XIZ                                             ; FC57ED  ee 0d
	ret                                                  ; FC57EF  0e
; NoteRouting_OnPartPlayParamEvent: T_NoteRouting_OnPartPlayParamEvent, classes 0x20-0x3F, the parts' second record (SysEx rec 32).  Byte 5 VELOCITY OFFSET -> tone-generator
;   record +1 = value - 0x18.  Byte 6 ASSIGN MODE -> record bit 6 = (value == 1), the mono bit
;   PartFrame_SendToToneGen tests.  Bytes 7 / 8 / 9 / 10 KEY LAYER LOW / HIGH and VELOCITY LAYER LOW / HIGH -> range
;   record +2 / +1 / +4 / +3, parts 0-7 only.  Byte 23 MIDI OUT KEY TRANSPOSE -> MIDI record +1 = value - 0x40.
;   Each sets ChangeFlags bit 15.
NoteRouting_OnPartPlayParamEvent:
	pushw hl                                             ; FC57F0  2b
	pushw de                                             ; FC57F1  2a
	push XIX                                             ; FC57F2  3c
	ld d, (UiEvent_Byte3:16)                                   ; FC57F3  c1 ba 20 24
	ld l, (UiEvent_Byte2:16)                                   ; FC57F7  c1 b9 20 27
	ld c, (UiEvent_Class:16)                                   ; FC57FB  c1 bb 20 23
	and C,0x1f                                           ; FC57FF  cb cc 1f
	extz BC                                              ; FC5802  d9 12
	extz XBC                                             ; FC5804  e9 12
	add XBC,Bytes_00_to_1F_x3_FC65C6+0x40                ; FC5806  e9 c8 06 66 fc 00
	ld H,(XBC)                                           ; FC580C  81 26
	ld bc, (UiEvent_Byte1:16)                                 ; FC580E  d1 b8 20 21
	extz BC                                              ; FC5812  d9 12
	cp bc, 0x05:i3                                         ; FC5814  d9 dd
	jr z, .LFC5840                                       ; FC5816  66 28
	cp bc, 0x06:i3                                         ; FC5818  d9 de
	jr z, .LFC5869                                       ; FC581A  66 4d
	cp bc, 0x07:i3                                         ; FC581C  d9 df
	jrl z, .LFC5898                                      ; FC581E  76 77 00
	cp BC,0x0008                                         ; FC5821  d9 cf 08 00
	jrl z, .LFC58C3                                      ; FC5825  76 9b 00
	cp BC,0x0009                                         ; FC5828  d9 cf 09 00
	jrl z, .LFC58EE                                      ; FC582C  76 bf 00
	cp BC,0x000a                                         ; FC582F  d9 cf 0a 00
	jrl z, .LFC5917                                      ; FC5833  76 e1 00
	cp BC,0x0017                                         ; FC5836  d9 cf 17 00
	jrl z, .LFC593F                                      ; FC583A  76 02 01
	jrl .LFC5968                                         ; FC583D  78 28 01
.LFC5840:
	ld C,D                                               ; FC5840  cc 8b
	and C,0xff                                           ; FC5842  cb cc ff
	jrl z, .LFC5968                                      ; FC5845  76 20 01
	ld C,L                                               ; FC5848  cf 8b
	and C,0xff                                           ; FC584A  cb cc ff
	ld E,C                                               ; FC584D  cb 8d
	sub E,0x18                                           ; FC584F  cd ca 18
	ld c, 0x06:opc                                          ; FC5852  23 06
	mul bc, h                                          ; FC5854  ce 43
	extz XBC                                             ; FC5856  e9 12
	add XBC,0x00000093                                   ; FC5858  e9 c8 93 00 00 00
	add XBC,NoteRouting                                   ; FC585E  e9 c8 00 22 60 00
	ld (XBC),E                                           ; FC5864  b1 45
	jrl .LFC5964                                         ; FC5866  78 fb 00
.LFC5869:
	ld C,D                                               ; FC5869  cc 8b
	and C,0x0f                                           ; FC586B  cb cc 0f
	jrl z, .LFC5968                                      ; FC586E  76 f7 00
	ld E,L                                               ; FC5871  cf 8d
	and E,0x0f                                           ; FC5873  cd cc 0f
	ld c, 0x06:opc                                          ; FC5876  23 06
	mul bc, h                                          ; FC5878  ce 43
	extz XBC                                             ; FC587A  e9 12
	add XBC,0x00000092                                   ; FC587C  e9 c8 92 00 00 00
	ld XIX,XBC                                           ; FC5882  e9 8c
	add XIX,NoteRouting                                   ; FC5884  ec c8 00 22 60 00
	cp e, 0x01:i3                                          ; FC588A  cd d9
	jr nz, .LFC5893                                      ; FC588C  6e 05
	set 6,(XIX)                                          ; FC588E  b4 be
	jrl .LFC5964                                         ; FC5890  78 d1 00
.LFC5893:
	res 6,(XIX)                                          ; FC5893  b4 b6
	jrl .LFC5964                                         ; FC5895  78 cc 00
.LFC5898:
	cp h, 0x07:i3                                          ; FC5898  ce df
	jrl ugt, .LFC5968                                    ; FC589A  7b cb 00
	ld C,D                                               ; FC589D  cc 8b
	res 0x07,C                                           ; FC589F  cb 30 07
	cp c, 0x00:i3                                          ; FC58A2  cb d8
	jrl z, .LFC5968                                      ; FC58A4  76 c1 00
	ld E,L                                               ; FC58A7  cf 8d
	res 0x07,E                                           ; FC58A9  cd 30 07
	ld c, 0x06:opc                                          ; FC58AC  23 06
	mul bc, h                                          ; FC58AE  ce 43
	extz XBC                                             ; FC58B0  e9 12
	add XBC,0x00000064                                   ; FC58B2  e9 c8 64 00 00 00
	add XBC,NoteRouting                                   ; FC58B8  e9 c8 00 22 60 00
	ld (XBC),E                                           ; FC58BE  b1 45
	jrl .LFC5964                                         ; FC58C0  78 a1 00
.LFC58C3:
	cp h, 0x07:i3                                          ; FC58C3  ce df
	jrl ugt, .LFC5968                                    ; FC58C5  7b a0 00
	ld C,D                                               ; FC58C8  cc 8b
	res 0x07,C                                           ; FC58CA  cb 30 07
	cp c, 0x00:i3                                          ; FC58CD  cb d8
	jrl z, .LFC5968                                      ; FC58CF  76 96 00
	ld E,L                                               ; FC58D2  cf 8d
	res 0x07,E                                           ; FC58D4  cd 30 07
	ld c, 0x06:opc                                          ; FC58D7  23 06
	mul bc, h                                          ; FC58D9  ce 43
	extz XBC                                             ; FC58DB  e9 12
	add XBC,0x00000063                                   ; FC58DD  e9 c8 63 00 00 00
	add XBC,NoteRouting                                   ; FC58E3  e9 c8 00 22 60 00
	ld (XBC),E                                           ; FC58E9  b1 45
	jrl .LFC5964                                         ; FC58EB  78 76 00
.LFC58EE:
	cp h, 0x07:i3                                          ; FC58EE  ce df
	jrl ugt, .LFC5968                                    ; FC58F0  7b 75 00
	ld C,D                                               ; FC58F3  cc 8b
	res 0x07,C                                           ; FC58F5  cb 30 07
	cp c, 0x00:i3                                          ; FC58F8  cb d8
	jr z, .LFC5968                                       ; FC58FA  66 6c
	ld E,L                                               ; FC58FC  cf 8d
	res 0x07,E                                           ; FC58FE  cd 30 07
	ld c, 0x06:opc                                          ; FC5901  23 06
	mul bc, h                                          ; FC5903  ce 43
	extz XBC                                             ; FC5905  e9 12
	add XBC,0x00000066                                   ; FC5907  e9 c8 66 00 00 00
	add XBC,NoteRouting                                   ; FC590D  e9 c8 00 22 60 00
	ld (XBC),E                                           ; FC5913  b1 45
	jr .LFC5964                                          ; FC5915  68 4d
.LFC5917:
	cp h, 0x07:i3                                          ; FC5917  ce df
	jr ugt, .LFC5968                                     ; FC5919  6b 4d
	ld C,D                                               ; FC591B  cc 8b
	res 0x07,C                                           ; FC591D  cb 30 07
	cp c, 0x00:i3                                          ; FC5920  cb d8
	jr z, .LFC5968                                       ; FC5922  66 44
	ld E,L                                               ; FC5924  cf 8d
	res 0x07,E                                           ; FC5926  cd 30 07
	ld c, 0x06:opc                                          ; FC5929  23 06
	mul bc, h                                          ; FC592B  ce 43
	extz XBC                                             ; FC592D  e9 12
	add XBC,0x00000065                                   ; FC592F  e9 c8 65 00 00 00
	add XBC,NoteRouting                                   ; FC5935  e9 c8 00 22 60 00
	ld (XBC),E                                           ; FC593B  b1 45
	jr .LFC5964                                          ; FC593D  68 25
.LFC593F:
	ld C,D                                               ; FC593F  cc 8b
	and C,0xff                                           ; FC5941  cb cc ff
	jr z, .LFC5968                                       ; FC5944  66 22
	ld C,L                                               ; FC5946  cf 8b
	and C,0xff                                           ; FC5948  cb cc ff
	ld E,C                                               ; FC594B  cb 8d
	sub E,0x40                                           ; FC594D  cd ca 40
	ld c, 0x0a:opc                                          ; FC5950  23 0a
	mul bc, h                                          ; FC5952  ce 43
	extz XBC                                             ; FC5954  e9 12
	add XBC,0x00000153                                   ; FC5956  e9 c8 53 01 00 00
	add XBC,NoteRouting                                   ; FC595C  e9 c8 00 22 60 00
	ld (XBC),E                                           ; FC5962  b1 45
.LFC5964:
	set	7, (0x4c05:16)                               ; FC5964  f1 05 4c bf
.LFC5968:
	pop XIX                                              ; FC5968  5c
	popw de                                              ; FC5969  4a
	popw hl                                              ; FC596A  4b
	ret                                                  ; FC596B  0e
T_F411E8_Nop:
	ret                                                  ; FC596C  0e
T_F411C8_Nop:
	ret                                                  ; FC596D  0e
T_F411CC_Nop:
	ret                                                  ; FC596E  0e
; NoteRouting_OnPlayModeRequest: T_NoteRouting_OnPlayModeRequest, class 0x98 byte 0 (PLAY MODE REQUEST, the high nibble): NoteRouting_Mode bit 4 = (nibble == 1);
;   ChangeFlags bit 15.
NoteRouting_OnPlayModeRequest:
	push XIX                                             ; FC596F  3c
	lda xix, (NoteRouting:24)                               ; FC5970  f2 00 22 60 34
	ld bc, (UiEvent_Byte1:16)                                 ; FC5975  d1 b8 20 21
	extz BC                                              ; FC5979  d9 12
	cp bc, 0x00:i3                                         ; FC597B  d9 d8
	jr z, .LFC5981                                       ; FC597D  66 02
	jr .LFC59AA                                          ; FC597F  68 29
.LFC5981:
	ld c, (UiEvent_Byte3:16)                                   ; FC5981  c1 ba 20 23
	and C,0xf0                                           ; FC5985  cb cc f0
	jr z, .LFC59A6                                       ; FC5988  66 1c
	ld c, (UiEvent_Byte2:16)                                   ; FC598A  c1 b9 20 23
	and C,0xf0                                           ; FC598E  cb cc f0
	cp C,0x10                                            ; FC5991  cb cf 10
	jr nz, .LFC599F                                      ; FC5994  6e 09
	orw	(xix+664), 0x0010                    ; FC5996  d3 f1 98 02 3e 10 00
	jr .LFC59A6                                          ; FC599D  68 07
.LFC599F:
	andw	(xix+664), 0xffef                    ; FC599F  d3 f1 98 02 3c ef ff
.LFC59A6:
	set	7, (0x4c05:16)                               ; FC59A6  f1 05 4c bf
.LFC59AA:
	pop XIX                                              ; FC59AA  5c
	ret                                                  ; FC59AB  0e
; NoteRouting_OnMidiSystemEvent: T_NoteRouting_OnMidiSystemEvent, class 0x80 -- the MIDI system record (PROGRAM CHANGE MODE, MIDI INPUT / OUTPUT MODE, SINGLE CHANNEL,
;   LOCAL TOTAL): the byte index 0..9 through NoteRouting_MidiSystemByteCases (3, 4 and 9 have handlers) with
;   L = the new value, H = the changed bits, DE = 0x8020.
NoteRouting_OnMidiSystemEvent:
	pushw hl                                             ; FC59AC  2b
	pushw de                                             ; FC59AD  2a
	push XIX                                             ; FC59AE  3c
	lda xix, (NoteRouting:24)                               ; FC59AF  f2 00 22 60 34
	ldw de, 0x8020                                       ; FC59B4  32 20 80
	ld l, (UiEvent_Byte2:16)                                   ; FC59B7  c1 b9 20 27
	ld h, (UiEvent_Byte3:16)                                   ; FC59BB  c1 ba 20 26
	ld bc, (UiEvent_Byte1:16)                                 ; FC59BF  d1 b8 20 21
	extz BC                                              ; FC59C3  d9 12
	extz XBC                                             ; FC59C5  e9 12
	cp BC,0x0009                                         ; FC59C7  d9 cf 09 00
	jrl ugt, .LFC5AC6                                        ; FC59CB  7b f8 00
	sll bc, 0x02                                         ; FC59CE  d9 ee 02
	add XBC,NoteRouting_MidiSystemByteCases                             ; FC59D1  e9 c8 db 59 fc 00
	ld XBC,(XBC)                                         ; FC59D7  a1 21
	jp (xbc)                                             ; FC59D9  b1 d8
; ---------------------------------------------------------------------
; NoteRouting_MidiSystemByteCases -- 10 LE32 branch targets
;
; Read by: ONE site, `add XBC,0x00FC59DB / ld XBC,(XBC) / jp T,XBC` at
;          0xFC59D1-0xFC59D9.
; ENTRY COUNT 10: the reader's OWN `cp BC,0x0009`; selectors above 9 take
;          `jrl UGT,0xFC5AC6`.  ★ LAST-ENTRY TEST: 0xFC59DB + 10*4 = 0xFC5A03,
;          and 0xFC5400-0xFC59DB and 0xFC5A03-0xFC64A5 are each self-consistent
;          under notes/prom_a_linear_decode_check.py while the union is not --
;          9 or 11 entries would put the split somewhere that does not decode.
;          Found and counted by notes/prom_a_jumptables.py.
; Evidence: the fixed reader shape in the ten bytes before the base plus the
;          count from its own `cp BC,0x0009`; re-derived by
;          notes/prom_a_byte_checks.py and notes/prom_a_jumptables.py.
; ---------------------------------------------------------------------
; NoteRouting_MidiSystemByteCases: event class 0x80's byte index 0..9; 3 (MIDI INPUT / OUTPUT MODE), 4 (SINGLE
;   CHANNEL, LOCAL TOTAL) and 9 have handlers, the rest return.
NoteRouting_MidiSystemByteCases:
	.long .LFC5AC6                                   ; FC59DB  [  0]
	.long .LFC5AC6                                   ; FC59DF  [  1]
	.long .LFC5AC6                                   ; FC59E3  [  2]
	.long NoteRouting_SetMidiInOutModes                                 ; FC59E7  [  3]
	.long NoteRouting_SetSingleChannelAndLocal                                 ; FC59EB  [  4]
	.long .LFC5AC6                                   ; FC59EF  [  5]
	.long .LFC5AC6                                   ; FC59F3  [  6]
	.long .LFC5AC6                                   ; FC59F7  [  7]
	.long .LFC5AC6                                   ; FC59FB  [  8]
	.long NoteRouting_OnMidiSystemByte9                                 ; FC59FF  [  9]
; NoteRouting_SetMidiInOutModes: class 0x80 byte 3: MIDI INPUT MODE (low nibble 0 / 1 / 2) -> NoteRouting_MidiFlags bits 6-7 = 00 / 01 / 10;
;   MIDI OUTPUT MODE (high nibble 0 / 1) -> bit 5; ChangeFlags |= 0x8020.
NoteRouting_SetMidiInOutModes:   ; entry: named by 1 `.long` operand, first at 0xFC59E7
	ld C,H                                               ; FC5A03  ce 8b
	and C,0x0f                                           ; FC5A05  cb cc 0f
	jr z, .LFC5A47                                       ; FC5A08  66 3d
	ld C,L                                               ; FC5A0A  cf 8b
	and C,0x0f                                           ; FC5A0C  cb cc 0f
	extz BC                                              ; FC5A0F  d9 12
	cp bc, 0x00:i3                                         ; FC5A11  d9 d8
	jr z, .LFC5A1F                                       ; FC5A13  66 0a
	cp bc, 0x01:i3                                         ; FC5A15  d9 d9
	jr z, .LFC5A2B                                       ; FC5A17  66 12
	cp bc, 0x02:i3                                         ; FC5A19  d9 da
	jr z, .LFC5A37                                       ; FC5A1B  66 1a
	jr .LFC5A47                                          ; FC5A1D  68 28
.LFC5A1F:
	res 6,(XIX+0x0293)                                   ; FC5A1F  f3 f1 93 02 b6
	res 7,(XIX+0x0293)                                   ; FC5A24  f3 f1 93 02 b7
	jr .LFC5A41                                          ; FC5A29  68 16
.LFC5A2B:
	set 6,(XIX+0x0293)                                   ; FC5A2B  f3 f1 93 02 be
	res 7,(XIX+0x0293)                                   ; FC5A30  f3 f1 93 02 b7
	jr .LFC5A41                                          ; FC5A35  68 0a
.LFC5A37:
	res 6,(XIX+0x0293)                                   ; FC5A37  f3 f1 93 02 b6
	set 7,(XIX+0x0293)                                   ; FC5A3C  f3 f1 93 02 bf
.LFC5A41:
	ld BC,DE                                             ; FC5A41  da 89
	or	(NoteRouting_ChangeFlags:16), bc                      ; FC5A43  d1 04 4c e9
.LFC5A47:
	ld C,H                                               ; FC5A47  ce 8b
	and C,0xf0                                           ; FC5A49  cb cc f0
	jrl z, .LFC5AC6                                      ; FC5A4C  76 77 00
	ld C,L                                               ; FC5A4F  cf 8b
	and C,0xf0                                           ; FC5A51  cb cc f0
	extz BC                                              ; FC5A54  d9 12
	cp bc, 0x00:i3                                         ; FC5A56  d9 d8
	jr z, .LFC5A63                                       ; FC5A58  66 09
	cp BC,0x0010                                         ; FC5A5A  d9 cf 10 00
	jr z, .LFC5A6A                                       ; FC5A5E  66 0a
	jrl .LFC5AC6                                         ; FC5A60  78 63 00
.LFC5A63:
	res 5,(XIX+0x0293)                                   ; FC5A63  f3 f1 93 02 b5
	jr .LFC5A6F                                          ; FC5A68  68 05
.LFC5A6A:
	set 5,(XIX+0x0293)                                   ; FC5A6A  f3 f1 93 02 bd
.LFC5A6F:
	ld BC,DE                                             ; FC5A6F  da 89
	or	(NoteRouting_ChangeFlags:16), bc                      ; FC5A71  d1 04 4c e9
	jr .LFC5AC6                                          ; FC5A75  68 4f
; NoteRouting_SetSingleChannelAndLocal: class 0x80 byte 4: SINGLE CHANNEL (bits 0-4) -> NoteRouting_SingleChannel, ChangeFlags |= 0x8020; LOCAL TOTAL
;   (bit 5) -> NoteRouting_Mode bit 9 (no tone-generator output), with no change flag.
NoteRouting_SetSingleChannelAndLocal:   ; entry: named by 1 `.long` operand, first at 0xFC59EB
	ld C,H                                               ; FC5A77  ce 8b
	and C,0x1f                                           ; FC5A79  cb cc 1f
	jr z, .LFC5A8E                                       ; FC5A7C  66 10
	ld C,L                                               ; FC5A7E  cf 8b
	and C,0x1f                                           ; FC5A80  cb cc 1f
	ld (XIX+0x0292),C                                    ; FC5A83  f3 f1 92 02 43
	ld BC,DE                                             ; FC5A88  da 89
	or	(NoteRouting_ChangeFlags:16), bc                      ; FC5A8A  d1 04 4c e9
.LFC5A8E:
	ld C,H                                               ; FC5A8E  ce 8b
	and C,0xe0                                           ; FC5A90  cb cc e0
	jr z, .LFC5AC6                                       ; FC5A93  66 31
	ld C,L                                               ; FC5A95  cf 8b
	and C,0x20                                           ; FC5A97  cb cc 20
	jr z, .LFC5AA5                                       ; FC5A9A  66 09
	orw	(xix+664), 0x0200                    ; FC5A9C  d3 f1 98 02 3e 00 02
	jr .LFC5AC6                                          ; FC5AA3  68 21
.LFC5AA5:
	andw	(xix+664), 0xfdff                    ; FC5AA5  d3 f1 98 02 3c ff fd
	jr .LFC5AC6                                          ; FC5AAC  68 18
; NoteRouting_OnMidiSystemByte9: class 0x80 byte 9, bit 7 -> NoteRouting_ChangeFlags bit 3 (set or clear).  No SysEx descriptor names byte 9.
NoteRouting_OnMidiSystemByte9:   ; entry: named by 1 `.long` operand, first at 0xFC59FF
	ld C,H                                               ; FC5AAE  ce 8b
	and C,0x80                                           ; FC5AB0  cb cc 80
	jr z, .LFC5AC6                                       ; FC5AB3  66 11
	ld C,L                                               ; FC5AB5  cf 8b
	and C,0x80                                           ; FC5AB7  cb cc 80
	jr z, .LFC5AC2                                       ; FC5ABA  66 06
	set	3, (NoteRouting_ChangeFlags:16)                               ; FC5ABC  f1 04 4c bb
	jr .LFC5AC6                                          ; FC5AC0  68 04
.LFC5AC2:
	res	3, (NoteRouting_ChangeFlags:16)                               ; FC5AC2  f1 04 4c b3
.LFC5AC6:
	pop XIX                                              ; FC5AC6  5c
	popw de                                              ; FC5AC7  4a
	popw hl                                              ; FC5AC8  4b
	ret                                                  ; FC5AC9  0e
T_F411D8_Nop:
	ret                                                  ; FC5ACA  0e
T_F411DC_Nop:
	ret                                                  ; FC5ACB  0e
; NoteRouting_SetMidiOutPorts: T_NoteRouting_SetMidiOutPorts, class 0xA8 byte 0x10: bit 0 -> NoteRouting_MidiFlags bit 4 (port A allowed) = NOT the bit, bit 1 ->
;   bit 3 (port B) = NOT the bit; ChangeFlags bit 15.
NoteRouting_SetMidiOutPorts:
	push XIX                                             ; FC5ACC  3c
	lda xix, (NoteRouting_ChangeFlags:16)                                ; FC5ACD  f1 04 4c 34
	ld bc, (UiEvent_Byte1:16)                                 ; FC5AD1  d1 b8 20 21
	extz BC                                              ; FC5AD5  d9 12
	cp BC,0x0010                                         ; FC5AD7  d9 cf 10 00
	jr z, .LFC5ADF                                       ; FC5ADB  66 02
	jr .LFC5B23                                          ; FC5ADD  68 44
.LFC5ADF:
	ld c, (UiEvent_Byte3:16)                                   ; FC5ADF  c1 ba 20 23
	and C,0x01                                           ; FC5AE3  cb cc 01
	jr z, .LFC5B01                                       ; FC5AE6  66 19
	ld c, (UiEvent_Byte2:16)                                   ; FC5AE8  c1 b9 20 23
	and C,0x01                                           ; FC5AEC  cb cc 01
	jr z, .LFC5AF8                                       ; FC5AEF  66 07
	res	4, (NoteRouting_MidiFlags:24)                             ; FC5AF1  f2 93 24 60 b4
	jr .LFC5AFD                                          ; FC5AF6  68 05
.LFC5AF8:
	set	4, (NoteRouting_MidiFlags:24)                             ; FC5AF8  f2 93 24 60 bc
.LFC5AFD:
	orw	(xix), 0x8000                        ; FC5AFD  94 3e 00 80
.LFC5B01:
	ld c, (UiEvent_Byte3:16)                                   ; FC5B01  c1 ba 20 23
	and C,0x02                                           ; FC5B05  cb cc 02
	jr z, .LFC5B23                                       ; FC5B08  66 19
	ld c, (UiEvent_Byte2:16)                                   ; FC5B0A  c1 b9 20 23
	and C,0x02                                           ; FC5B0E  cb cc 02
	jr z, .LFC5B1A                                       ; FC5B11  66 07
	res	3, (NoteRouting_MidiFlags:24)                             ; FC5B13  f2 93 24 60 b3
	jr .LFC5B1F                                          ; FC5B18  68 05
.LFC5B1A:
	set	3, (NoteRouting_MidiFlags:24)                             ; FC5B1A  f2 93 24 60 bb
.LFC5B1F:
	orw	(xix), 0x8000                        ; FC5B1F  94 3e 00 80
.LFC5B23:
	pop XIX                                              ; FC5B23  5c
	ret                                                  ; FC5B24  0e
T_F411E4_Nop:
	ret                                                  ; FC5B25  0e
; NoteRouting_KeyboardToSelectedPart: the default builder (modes 0-2, 4, 8, 10-12, 14-16, 18, 19, 22: SOUND, COMBINATION, SEQ PLAY, SYSTEM, MIDI ...):
;   block +1 = the part UI_PartIndex selects (Bytes_00_to_1F_x3_FC65C6 + 0x40); with block +0x298 bit 4 and a part
;   below 8, block +0 = its bit (bit 5) and +1 = 0xFF instead; NoteRouting_ChangeFlags |= 3.
NoteRouting_KeyboardToSelectedPart:
	pushw hl                                             ; FC5B26  2b
	pushw de                                             ; FC5B27  2a
	push XIX                                             ; FC5B28  3c
	lda xix, (NoteRouting:24)                               ; FC5B29  f2 00 22 60 34
	ld DE,(XIX+0x0298)                                   ; FC5B2E  d3 f1 98 02 22
	ld BC,DE                                             ; FC5B33  da 89
	and BC,0x0010                                        ; FC5B35  d9 cc 10 00
	jr z, .LFC5B6D                                       ; FC5B39  66 32
	ld c, (UI_PartIndex:16)                                   ; FC5B3B  c1 50 22 23
	extz BC                                              ; FC5B3F  d9 12
	extz XBC                                             ; FC5B41  e9 12
	add XBC,Bytes_00_to_1F_x3_FC65C6+0x40                ; FC5B43  e9 c8 06 66 fc 00
	ld H,(XBC)                                           ; FC5B49  81 26
	cp h, 0x07:i3                                          ; FC5B4B  ce df
	jr ugt, .LFC5B6D                                     ; FC5B4D  6b 1e
	ld BC,DE                                             ; FC5B4F  da 89
	and BC,0x0020                                        ; FC5B51  d9 cc 20 00
	jr z, .LFC5B67                                       ; FC5B55  66 10
	ld c, 0x04:opc                                          ; FC5B57  23 04
	mul bc, h                                          ; FC5B59  ce 43
	extz XBC                                             ; FC5B5B  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC5B5D  e9 c8 c6 64 fc 00
	ld A,(XBC)                                           ; FC5B63  81 21
	ld (XIX),A                                           ; FC5B65  b4 41
.LFC5B67:
	ld (XIX+0x01),0xff                                   ; FC5B67  bc 01 00 ff
	jr .LFC5B80                                          ; FC5B6B  68 13
.LFC5B6D:
	ld c, (UI_PartIndex:16)                                   ; FC5B6D  c1 50 22 23
	extz BC                                              ; FC5B71  d9 12
	extz XBC                                             ; FC5B73  e9 12
	add XBC,Bytes_00_to_1F_x3_FC65C6+0x40                ; FC5B75  e9 c8 06 66 fc 00
	ld A,(XBC)                                           ; FC5B7B  81 21
	ld (XIX+0x01),A                                      ; FC5B7D  bc 01 41
.LFC5B80:
	orw	(NoteRouting_ChangeFlags:16), 0x0003                  ; FC5B80  d1 04 4c 3e 03 00
	pop XIX                                              ; FC5B86  5c
	popw de                                              ; FC5B87  4a
	popw hl                                              ; FC5B88  4b
	ret                                                  ; FC5B89  0e
; NoteRouting_BuildForSequencerModes: modes 3, 5, 6, 7 (Sequencer, Realtime Record, Step Record, Edit): with NoteRouting_Mode bit 6, block +1 =
;   (0x4C20) and flag bit 1; otherwise NoteRouting_KeyboardToSelectedPart.
NoteRouting_BuildForSequencerModes:   ; entry: named by 4 `.long` operands, first at 0xFC6552
	link XIZ,0x0000                                      ; FC5B8A  ee 0c 00 00
	ld bc, (NoteRouting_Mode:24)                                ; FC5B8E  d2 98 24 60 21
	and BC,0x0040                                        ; FC5B93  d9 cc 40 00
	jr z, .LFC5BA9                                       ; FC5B97  66 10
	ld c, (0x4c20:24)                                   ; FC5B99  c2 20 4c 00 23
	ld (0x602201:24), c                                 ; FC5B9E  f2 01 22 60 43
	set	1, (NoteRouting_ChangeFlags:16)                               ; FC5BA3  f1 04 4c b9
	jr .LFC5BB2                                          ; FC5BA7  68 09
.LFC5BA9:
	push 0x00                                            ; FC5BA9  09 00
	push	(xiz+8)                                      ; FC5BAB  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5BAE  1e 75 ff
	popw bc                                              ; FC5BB1  49
.LFC5BB2:
	unlk XIZ                                             ; FC5BB2  ee 0d
	ret                                                  ; FC5BB4  0e
; NoteRouting_BuildForMode13: mode 13: NoteRouting_Mode |= 4, then NoteRouting_KeyboardToSelectedPart.
NoteRouting_BuildForMode13:   ; entry: named by 1 `.long` operand, first at 0xFC657A
	link XIZ,0x0000                                      ; FC5BB5  ee 0c 00 00
	orw	(NoteRouting_Mode:24), 0x0004                ; FC5BB9  d2 98 24 60 3e 04 00
	push 0x00                                            ; FC5BC0  09 00
	push	(xiz+8)                                      ; FC5BC2  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5BC5  1e 5e ff
	popw bc                                              ; FC5BC8  49
	unlk XIZ                                             ; FC5BC9  ee 0d
	ret                                                  ; FC5BCB  0e
; NoteRouting_BuildForCombiEditPart: mode 9 (CombiEditPart): on screens 0x61 / 0x63, block +1 = the part UI_PartIndex selects, flag bit 1; otherwise
;   NoteRouting_KeyboardToSelectedPart.
NoteRouting_BuildForCombiEditPart:   ; entry: named by 1 `.long` operand, first at 0xFC656A
	link XIZ,0x0000                                      ; FC5BCC  ee 0c 00 00
	pushw hl                                             ; FC5BD0  2b
	cp	(UI_ScreenLatch:16), 0x61                            ; FC5BD1  c1 7a 20 3f 61
	jr z, .LFC5BDF                                       ; FC5BD6  66 07
	cp	(UI_ScreenLatch:16), 0x63                            ; FC5BD8  c1 7a 20 3f 63
	jr nz, .LFC5BFF                                      ; FC5BDD  6e 20
.LFC5BDF:
	ld c, (UI_PartIndex:16)                                   ; FC5BDF  c1 50 22 23
	extz BC                                              ; FC5BE3  d9 12
	extz XBC                                             ; FC5BE5  e9 12
	add XBC,Bytes_00_to_1F_x3_FC65C6                     ; FC5BE7  e9 c8 c6 65 fc 00
	ld H,(XBC)                                           ; FC5BED  81 26
	ld (0x602201:24), h                                 ; FC5BEF  f2 01 22 60 46
	cp H,0xff                                            ; FC5BF4  ce cf ff
	jr z, .LFC5BFF                                       ; FC5BF7  66 06
	set	1, (NoteRouting_ChangeFlags:16)                               ; FC5BF9  f1 04 4c b9
	jr .LFC5C08                                          ; FC5BFD  68 09
.LFC5BFF:
	push 0x00                                            ; FC5BFF  09 00
	push	(xiz+8)                                      ; FC5C01  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5C04  1e 1f ff
	popw bc                                              ; FC5C07  49
.LFC5C08:
	popw hl                                              ; FC5C08  4b
	unlk XIZ                                             ; FC5C09  ee 0d
	ret                                                  ; FC5C0B  0e
	link XIZ,0x0000                                      ; FC5C0C  ee 0c 00 00
	pushw hl                                             ; FC5C10  2b
	cp	(UI_ScreenLatch:16), 0x72                            ; FC5C11  c1 7a 20 3f 72
	jr z, .LFC5C1F                                       ; FC5C16  66 07
	cp	(UI_ScreenLatch:16), 0x71                            ; FC5C18  c1 7a 20 3f 71
	jr nz, .LFC5C3F                                      ; FC5C1D  6e 20
.LFC5C1F:
	ld bc, (0x2098:16)                                 ; FC5C1F  d1 98 20 21
	extz BC                                              ; FC5C23  d9 12
	extz XBC                                             ; FC5C25  e9 12
	add XBC,Bytes_00_to_1F_x3_FC65C6+0x20                ; FC5C27  e9 c8 e6 65 fc 00
	ld H,(XBC)                                           ; FC5C2D  81 26
	ld (0x602201:24), h                                 ; FC5C2F  f2 01 22 60 46
	cp H,0xff                                            ; FC5C34  ce cf ff
	jr z, .LFC5C3F                                       ; FC5C37  66 06
	set	1, (NoteRouting_ChangeFlags:16)                               ; FC5C39  f1 04 4c b9
	jr .LFC5C48                                          ; FC5C3D  68 09
.LFC5C3F:
	push 0x00                                            ; FC5C3F  09 00
	push	(xiz+8)                                      ; FC5C41  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5C44  1e df fe
	popw bc                                              ; FC5C47  49
.LFC5C48:
	popw hl                                              ; FC5C48  4b
	unlk XIZ                                             ; FC5C49  ee 0d
	ret                                                  ; FC5C4B  0e
; NoteRouting_BuildForSoundCopy: modes 20 / 21 (SoundCopy): NoteRouting_KeyboardToSelectedPart.
NoteRouting_BuildForSoundCopy:   ; entry: named by 2 `.long` operands, first at 0xFC6596
	link XIZ,0x0000                                      ; FC5C4C  ee 0c 00 00
	push 0x00                                            ; FC5C50  09 00
	push	(xiz+8)                                      ; FC5C52  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5C55  1e ce fe
	popw bc                                              ; FC5C58  49
	unlk XIZ                                             ; FC5C59  ee 0d
	ret                                                  ; FC5C5B  0e
; NoteRouting_BuildForModes23To27: modes 23-27: NoteRouting_KeyboardToSelectedPart.
NoteRouting_BuildForModes23To27:   ; entry: named by 5 `.long` operands, first at 0xFC65A2
	link XIZ,0x0000                                      ; FC5C5C  ee 0c 00 00
	push 0x00                                            ; FC5C60  09 00
	push	(xiz+8)                                      ; FC5C62  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5C65  1e be fe
	popw bc                                              ; FC5C68  49
	unlk XIZ                                             ; FC5C69  ee 0d
	ret                                                  ; FC5C6B  0e
.LFC5C6C:
	link XIZ,0x0000                                      ; FC5C6C  ee 0c 00 00
	push 0x00                                            ; FC5C70  09 00
	push	(xiz+8)                                      ; FC5C72  8e 08 04
	calr NoteRouting_KeyboardToSelectedPart                                      ; FC5C75  1e ae fe
	popw bc                                              ; FC5C78  49
	unlk XIZ                                             ; FC5C79  ee 0d
	ret                                                  ; FC5C7B  0e
; NoteRouting_CommitChanges: by (0x4C04): bits 0xA0 NoteRouting_QueueMidiInChanges, 0xC0 NoteRouting_QueueTrackChanges, 0x20 NoteRouting_QueueMidiOutSchemeChange and NoteRouting_QueuePartTransmitChanges, 0x40 NoteRouting_QueueTrackPartChanges; then
;   T_NoteRouting_ApplyQueuedChanges, the 0x29A-byte block copied to 0x602600, (0x4C04) = 0.
; CORRECTED 2026-10-04 (was NoteRouting_RebuildOutputs): it rebuilds no outputs.  The NoteRouting_Queue* routines compare the block with
;   NoteRouting_Previous and queue one note-release record per difference (NoteChange_HandlerTable's kinds), the
;   queue is applied (T_NoteRouting_ApplyQueuedChanges = NoteRouting_ApplyQueuedChanges), then the block becomes the previous one and
;   NoteRouting_ChangeFlags (0x4C04) is cleared.
NoteRouting_CommitChanges:
	push XIX                                             ; FC5C7C  3c
	lda xix, (NoteRouting_ChangeFlags:16)                                ; FC5C7D  f1 04 4c 34
	ldw (NoteRouting_ChangeCount:24), 0x00                             ; FC5C81  f2 00 2a 60 02 00 00
	ld BC,(XIX)                                          ; FC5C88  94 21
	and BC,0x00a0                                        ; FC5C8A  d9 cc a0 00
	jr z, .LFC5C93                                       ; FC5C8E  66 03
	calr NoteRouting_QueueMidiInChanges                                      ; FC5C90  1e 9d 00
.LFC5C93:
	ld BC,(XIX)                                          ; FC5C93  94 21
	and BC,0x00c0                                        ; FC5C95  d9 cc c0 00
	jr z, .LFC5C9E                                       ; FC5C99  66 03
	calr NoteRouting_QueueTrackChanges                                      ; FC5C9B  1e 7b 02
.LFC5C9E:
	ld BC,(XIX)                                          ; FC5C9E  94 21
	and BC,0x0020                                        ; FC5CA0  d9 cc 20 00
	jr z, .LFC5CA9                                       ; FC5CA4  66 03
	calr NoteRouting_QueueMidiOutSchemeChange                                      ; FC5CA6  1e 03 03
.LFC5CA9:
	ld BC,(XIX)                                          ; FC5CA9  94 21
	and BC,0x0020                                        ; FC5CAB  d9 cc 20 00
	jr z, .LFC5CB4                                       ; FC5CAF  66 03
	calr NoteRouting_QueuePartTransmitChanges                                      ; FC5CB1  1e b1 03
.LFC5CB4:
	ld BC,(XIX)                                          ; FC5CB4  94 21
	and BC,0x0040                                        ; FC5CB6  d9 cc 40 00
	jr z, .LFC5CBF                                       ; FC5CBA  66 03
	calr NoteRouting_QueueTrackPartChanges                                      ; FC5CBC  1e 50 04
.LFC5CBF:
	call T_NoteRouting_ApplyQueuedChanges                                        ; FC5CBF  1d d4 13 f4
	push XIX                                             ; FC5CC3  3c
	ldw bc, 0x014d                                       ; FC5CC4  31 4d 01
	lda xiy, (NoteRouting:24)                               ; FC5CC7  f2 00 22 60 35
	lda xix, (NoteRouting_Previous:24)                               ; FC5CCC  f2 00 26 60 34
	ldirw                                                ; FC5CD1  95 11
	pop XIX                                              ; FC5CD3  5c
	ldw	(xix), 0x0000                                ; FC5CD4  b4 02 00 00
	pop XIX                                              ; FC5CD8  5c
	ret                                                  ; FC5CD9  0e
; NoteRouting_QueueChange: (kind, a, b, c): appends the 4-byte record kind / a / b / c to NoteRouting_ChangeQueue (0x602A02) and counts it in
;   NoteRouting_ChangeCount (0x602A00); when the count is already above 0x7F the queue is applied first (T_NoteRouting_ApplyQueuedChanges).
;   Its callers compare NoteRouting with NoteRouting_Previous.
NoteRouting_QueueChange:
	link XIZ,0xfffc                                      ; FC5CDA  ee 0c fc ff
	push XIX                                             ; FC5CDE  3c
	lda xix, (NoteRouting_ChangeQueue:24)                               ; FC5CDF  f2 02 2a 60 34
	cpw	(NoteRouting_ChangeCount:24), 0x007f                        ; FC5CE4  d2 00 2a 60 3f 7f 00
	jr ule, .LFC5CF1                                     ; FC5CEB  63 04
	call T_NoteRouting_ApplyQueuedChanges                                        ; FC5CED  1d d4 13 f4
.LFC5CF1:
	ldw bc, 0x04                                         ; FC5CF1  31 04 00
	mul	xbc, (NoteRouting_ChangeCount:24)                           ; FC5CF4  d2 00 2a 60 41
	ld (xiz-4), xbc                                      ; FC5CF9  be fc 61
	add XBC,XIX                                          ; FC5CFC  ec 81
	ld A,(XIZ+0x08)                                      ; FC5CFE  8e 08 21
	ld (XBC),A                                           ; FC5D01  b1 41
	ld xbc, (xiz-4)                                      ; FC5D03  ae fc 21
	inc 1,XBC                                            ; FC5D06  e9 61
; (sub_FC5D08 removed 2026-10-04: no code names it and the line above falls through into it -- part of NoteRouting_QueueChange;
;  notes/prom_a_stray_label_removal.py)
	add XBC,XIX                                          ; FC5D08  ec 81
	ld A,(XIZ+0x0a)                                      ; FC5D0A  8e 0a 21
	ld (XBC),A                                           ; FC5D0D  b1 41
	ld xbc, (xiz-4)                                      ; FC5D0F  ae fc 21
	inc 2,XBC                                            ; FC5D12  e9 62
	add XBC,XIX                                          ; FC5D14  ec 81
	ld A,(XIZ+0x0c)                                      ; FC5D16  8e 0c 21
	ld (XBC),A                                           ; FC5D19  b1 41
	ld xbc, (xiz-4)                                      ; FC5D1B  ae fc 21
	inc 3,XBC                                            ; FC5D1E  e9 63
	add XBC,XIX                                          ; FC5D20  ec 81
	ld A,(XIZ+0x0e)                                      ; FC5D22  8e 0e 21
	ld (XBC),A                                           ; FC5D25  b1 41
	incw 0x01, (NoteRouting_ChangeCount:24)                          ; FC5D27  d2 00 2a 60 61
	pop XIX                                              ; FC5D2C  5c
	unlk XIZ                                             ; FC5D2D  ee 0d
	ret                                                  ; FC5D2F  0e
; NoteRouting_QueueMidiInChanges: (NoteRouting_ChangeFlags bit 5): when the MIDI IN mode (NoteRouting_MidiFlags bits 6-7) or NoteRouting_SingleChannel
;   changed, a kind-7 record per channel whose MIDI IN path changes (1 = it took the note-list path before, 0 = the
;   per-channel path); then for each of the 32 parts kind 0 (part, new, old) when its channel (+0x22) changed, or
;   kind 0 (part, 0xFF, channel) when its receive bit (record +0x152 bit 6) changed.
NoteRouting_QueueMidiInChanges:
	link XIZ,0xfff4                                      ; FC5D30  ee 0c f4 ff
	pushw hl                                             ; FC5D34  2b
	pushw de                                             ; FC5D35  2a
	push XIX                                             ; FC5D36  3c
	ld bc, (NoteRouting_ChangeFlags:16)                                 ; FC5D37  d1 04 4c 21
	and BC,0x0020                                        ; FC5D3B  d9 cc 20 00
	jrl z, .LFC5F13                                      ; FC5D3F  76 d1 01
	ld c, (NoteRouting_PreviousMidiFlags:24)                                 ; FC5D42  c2 93 28 60 23
	and C,0xc0                                           ; FC5D47  cb cc c0
	srl c, 0x06                                          ; FC5D4A  cb ef 06
	ld H,C                                               ; FC5D4D  cb 8e
	ld a, (NoteRouting_MidiFlags:24)                                 ; FC5D4F  c2 93 24 60 21
	and A,0xc0                                           ; FC5D54  c9 cc c0
	srl a, 0x06                                          ; FC5D57  c9 ef 06
	cp A,C                                               ; FC5D5A  cb f1
	jrl z, .LFC5E33                                      ; FC5D5C  76 d4 00
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC5D5F  c2 93 24 60 23
	and C,0xc0                                           ; FC5D64  cb cc c0
	srl c, 0x06                                          ; FC5D67  cb ef 06
	cp c, 0x02:i3                                          ; FC5D6A  cb da
	jr nz, .LFC5DB2                                      ; FC5D6C  6e 44
	ldw hl, 0x00                                         ; FC5D6E  33 00 00
.LFC5D71:
	ld c, (NoteRouting_PreviousSingleChannel:24)                                 ; FC5D71  c2 92 28 60 23
	extz BC                                              ; FC5D76  d9 12
	cp BC,HL                                             ; FC5D78  db f1
	jr nz, .LFC5D96                                      ; FC5D7A  6e 1a
	ld c, (NoteRouting_PreviousMidiFlags:24)                                 ; FC5D7C  c2 93 28 60 23
	and C,0xc0                                           ; FC5D81  cb cc c0
	srl c, 0x06                                          ; FC5D84  cb ef 06
; (sub_FC5D87 removed 2026-10-04: no code names it and the line above falls through into it -- part of NoteRouting_QueueMidiInChanges;
;  notes/prom_a_stray_label_removal.py)
	cp c, 0x01:i3                                          ; FC5D87  cb d9
	jr nz, .LFC5D96                                      ; FC5D89  6e 0b
	ld C,L                                               ; FC5D8B  cf 8b
	pushw bc                                             ; FC5D8D  29
	pushw 0xff                                           ; FC5D8E  0b ff 00
	pushw 0x01                                           ; FC5D91  0b 01 00
	jr .LFC5D9F                                          ; FC5D94  68 09
.LFC5D96:
	ld C,L                                               ; FC5D96  cf 8b
	pushw bc                                             ; FC5D98  29
	pushw 0xff                                           ; FC5D99  0b ff 00
	pushw 0x00                                           ; FC5D9C  0b 00 00
.LFC5D9F:
	pushw 0x07                                           ; FC5D9F  0b 07 00
	calr NoteRouting_QueueChange                                      ; FC5DA2  1e 35 ff
	inc 1,HL                                             ; FC5DA5  db 61
	inc 8,XSP                                            ; FC5DA7  ef 60
	cp HL,0x0020                                         ; FC5DA9  db cf 20 00
	jr c, .LFC5D71                                       ; FC5DAD  67 c2
	jrl .LFC5E33                                         ; FC5DAF  78 81 00
.LFC5DB2:
	ld c, (NoteRouting_PreviousMidiFlags:24)                                 ; FC5DB2  c2 93 28 60 23
	and C,0xc0                                           ; FC5DB7  cb cc c0
	srl c, 0x06                                          ; FC5DBA  cb ef 06
	cp c, 0x02:i3                                          ; FC5DBD  cb da
	jr nz, .LFC5DDF                                      ; FC5DBF  6e 1e
	ld h, 0x00:opc                                          ; FC5DC1  26 00
.LFC5DC3:
	ld L,H                                               ; FC5DC3  ce 8f
	pushw hl                                             ; FC5DC5  2b
	pushw 0xff                                           ; FC5DC6  0b ff 00
	pushw 0x01                                           ; FC5DC9  0b 01 00
	pushw 0x07                                           ; FC5DCC  0b 07 00
	calr NoteRouting_QueueChange                                      ; FC5DCF  1e 08 ff
	ld H,L                                               ; FC5DD2  cf 8e
	inc 1,H                                              ; FC5DD4  ce 61
	inc 8,XSP                                            ; FC5DD6  ef 60
	cp H,0x20                                            ; FC5DD8  ce cf 20
	jr c, .LFC5DC3                                       ; FC5DDB  67 e6
	jr .LFC5E33                                          ; FC5DDD  68 54
.LFC5DDF:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC5DDF  c2 93 24 60 23
	and C,0xc0                                           ; FC5DE4  cb cc c0
	srl c, 0x06                                          ; FC5DE7  cb ef 06
	cp c, 0x01:i3                                          ; FC5DEA  cb d9
	jr nz, .LFC5E06                                      ; FC5DEC  6e 18
	ld c, (NoteRouting_PreviousMidiFlags:24)                                 ; FC5DEE  c2 93 28 60 23
	and C,0xc0                                           ; FC5DF3  cb cc c0
	jr nz, .LFC5E06                                      ; FC5DF6  6e 0e
	ld c, (NoteRouting_PreviousSingleChannel:24)                                 ; FC5DF8  c2 92 28 60 23
	pushw bc                                             ; FC5DFD  29
	pushw 0xff                                           ; FC5DFE  0b ff 00
	pushw 0x00                                           ; FC5E01  0b 00 00
	jr .LFC5E2B                                          ; FC5E04  68 25
.LFC5E06:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC5E06  c2 93 24 60 23
	and C,0xc0                                           ; FC5E0B  cb cc c0
	jr nz, .LFC5E33                                      ; FC5E0E  6e 23
	ld c, (NoteRouting_PreviousMidiFlags:24)                                 ; FC5E10  c2 93 28 60 23
	and C,0xc0                                           ; FC5E15  cb cc c0
	srl c, 0x06                                          ; FC5E18  cb ef 06
	cp c, 0x01:i3                                          ; FC5E1B  cb d9
	jr nz, .LFC5E33                                      ; FC5E1D  6e 14
	ld c, (NoteRouting_PreviousSingleChannel:24)                                 ; FC5E1F  c2 92 28 60 23
	pushw bc                                             ; FC5E24  29
	pushw 0xff                                           ; FC5E25  0b ff 00
	pushw 0x01                                           ; FC5E28  0b 01 00
.LFC5E2B:
	pushw 0x07                                           ; FC5E2B  0b 07 00
	calr NoteRouting_QueueChange                                      ; FC5E2E  1e a9 fe
	inc 8,XSP                                            ; FC5E31  ef 60
.LFC5E33:
	ld h, (NoteRouting_PreviousSingleChannel:24)                                 ; FC5E33  c2 92 28 60 26
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC5E38  c2 92 24 60 23
	cp C,H                                               ; FC5E3D  ce f3
	jr z, .LFC5E76                                       ; FC5E3F  66 35
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC5E41  c2 93 24 60 23
	and C,0xc0                                           ; FC5E46  cb cc c0
	srl c, 0x06                                          ; FC5E49  cb ef 06
	cp c, 0x01:i3                                          ; FC5E4C  cb d9
	jr nz, .LFC5E76                                      ; FC5E4E  6e 26
	push 0x00                                            ; FC5E50  09 00
	push H                                               ; FC5E52  ce 04
	pushw 0xff                                           ; FC5E54  0b ff 00
	pushw 0x01                                           ; FC5E57  0b 01 00
	pushw 0x07                                           ; FC5E5A  0b 07 00
	calr NoteRouting_QueueChange                                      ; FC5E5D  1e 7a fe
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC5E60  c2 92 24 60 23
	pushw bc                                             ; FC5E65  29
	pushw 0xff                                           ; FC5E66  0b ff 00
	pushw 0x00                                           ; FC5E69  0b 00 00
	pushw 0x07                                           ; FC5E6C  0b 07 00
	calr NoteRouting_QueueChange                                      ; FC5E6F  1e 68 fe
	inc 8,XSP                                            ; FC5E72  ef 60
	inc 8,XSP                                            ; FC5E74  ef 60
.LFC5E76:
	ld XIX,0x00000022                                    ; FC5E76  44 22 00 00 00
	sub XBC,XBC                                          ; FC5E7B  e9 a1
	ld (xiz-4), xbc                                      ; FC5E7D  be fc 61
	ld h, 0x00:opc                                          ; FC5E80  26 00
.LFC5E82:
	lda xbc, (NoteRouting_Previous:24)                               ; FC5E82  f2 00 26 60 31
	add XBC,XIX                                          ; FC5E87  ec 81
	ld D,(XBC)                                           ; FC5E89  81 24
	lda xbc, (NoteRouting:24)                               ; FC5E8B  f2 00 22 60 31
	add XBC,XIX                                          ; FC5E90  ec 81
	ld L,(XBC)                                           ; FC5E92  81 27
	ld (xiz-8), xix                                      ; FC5E94  be f8 64
	cp L,D                                               ; FC5E97  cc f7
	jr z, .LFC5EA9                                       ; FC5E99  66 0e
	lda xbc, (NoteRouting_Previous:24)                               ; FC5E9B  f2 00 26 60 31
	add	xbc, (xiz-8)                                 ; FC5EA0  ae f8 81
	ld A,(XBC)                                           ; FC5EA3  81 21
	pushw wa                                             ; FC5EA5  28
	pushw hl                                             ; FC5EA6  2b
	jr .LFC5EF5                                          ; FC5EA7  68 4c
.LFC5EA9:
	lda xbc, (NoteRouting:24)                               ; FC5EA9  f2 00 22 60 31
	add	xbc, (xiz-8)                                 ; FC5EAE  ae f8 81
	ld A,(XBC)                                           ; FC5EB1  81 21
	cp A,0xff                                            ; FC5EB3  c9 cf ff
	jr z, .LFC5F01                                       ; FC5EB6  66 49
	ld xbc, (xiz-4)                                      ; FC5EB8  ae fc 21
	add XBC,0x00000152                                   ; FC5EBB  e9 c8 52 01 00 00
	ld (xiz-12), xbc                                     ; FC5EC1  be f4 61
	add XBC,NoteRouting_Previous                                   ; FC5EC4  e9 c8 00 26 60 00
	ld A,(XBC)                                           ; FC5ECA  81 21
	and A,0x40                                           ; FC5ECC  c9 cc 40
	srl a, 0x06                                          ; FC5ECF  c9 ef 06
	ld L,A                                               ; FC5ED2  c9 8f
	lda xbc, (NoteRouting:24)                               ; FC5ED4  f2 00 22 60 31
	add	xbc, (xiz-12)                                ; FC5ED9  ae f4 81
	ld W,(XBC)                                           ; FC5EDC  81 20
	and W,0x40                                           ; FC5EDE  c8 cc 40
	srl w, 0x06                                          ; FC5EE1  c8 ef 06
	cp W,A                                               ; FC5EE4  c9 f0
	jr z, .LFC5F01                                       ; FC5EE6  66 19
	lda xbc, (NoteRouting:24)                               ; FC5EE8  f2 00 22 60 31
	add XBC,XIX                                          ; FC5EED  ec 81
	ld A,(XBC)                                           ; FC5EEF  81 21
	pushw wa                                             ; FC5EF1  28
	pushw 0xff                                           ; FC5EF2  0b ff 00
.LFC5EF5:
	push 0x00                                            ; FC5EF5  09 00
	push H                                               ; FC5EF7  ce 04
	pushw 0x00                                           ; FC5EF9  0b 00 00
	calr NoteRouting_QueueChange                                      ; FC5EFC  1e db fd
	inc 8,XSP                                            ; FC5EFF  ef 60
.LFC5F01:
	inc 1,XIX                                            ; FC5F01  ec 61
	ld XBC,0x0000000a                                    ; FC5F03  41 0a 00 00 00
	add (xiz-4), xbc                                     ; FC5F08  ae fc 89
	inc 1,H                                              ; FC5F0B  ce 61
	cp H,0x20                                            ; FC5F0D  ce cf 20
	jrl c, .LFC5E82                                      ; FC5F10  77 6f ff
.LFC5F13:
	pop XIX                                              ; FC5F13  5c
	popw de                                              ; FC5F14  4a
	popw hl                                              ; FC5F15  4b
	unlk XIZ                                             ; FC5F16  ee 0d
	ret                                                  ; FC5F18  0e
; NoteRouting_QueueTrackChanges: (NoteRouting_ChangeFlags bit 6 or 7): for each of the 16 tracks, kind 2 (track, new, old) when its MIDI OUT
;   channel (+0x52, low 5 bits) changed and kind 3 (track, new, old) when its part (+0x42, low 5 bits) changed.
NoteRouting_QueueTrackChanges:
	link XIZ,0xfffc                                      ; FC5F19  ee 0c fc ff
	pushw hl                                             ; FC5F1D  2b
	pushw de                                             ; FC5F1E  2a
	push XIX                                             ; FC5F1F  3c
	ld bc, (NoteRouting_ChangeFlags:16)                                 ; FC5F20  d1 04 4c 21
	and BC,0x00c0                                        ; FC5F24  d9 cc c0 00
	jrl z, .LFC5FA6                                      ; FC5F28  76 7b 00
	ld XBC,0x00000052                                    ; FC5F2B  41 52 00 00 00
	ld (xiz-4), xbc                                      ; FC5F30  be fc 61
	ld XIX,0x00000042                                    ; FC5F33  44 42 00 00 00
	ld d, 0x00:opc                                          ; FC5F38  24 00
.LFC5F3A:
	lda xbc, (NoteRouting_Previous:24)                               ; FC5F3A  f2 00 26 60 31
	add	xbc, (xiz-4)                                 ; FC5F3F  ae fc 81
	ld H,(XBC)                                           ; FC5F42  81 26
	and H,0x1f                                           ; FC5F44  ce cc 1f
	lda xbc, (NoteRouting:24)                               ; FC5F47  f2 00 22 60 31
	add	xbc, (xiz-4)                                 ; FC5F4C  ae fc 81
	ld L,(XBC)                                           ; FC5F4F  81 27
	and L,0x1f                                           ; FC5F51  cf cc 1f
	cp L,H                                               ; FC5F54  ce f7
	jr z, .LFC5F69                                       ; FC5F56  66 11
	push 0x00                                            ; FC5F58  09 00
	push H                                               ; FC5F5A  ce 04
	pushw hl                                             ; FC5F5C  2b
	push 0x00                                            ; FC5F5D  09 00
	push D                                               ; FC5F5F  cc 04
	pushw 0x02                                           ; FC5F61  0b 02 00
	calr NoteRouting_QueueChange                                      ; FC5F64  1e 73 fd
	inc 8,XSP                                            ; FC5F67  ef 60
.LFC5F69:
	lda xbc, (NoteRouting_Previous:24)                               ; FC5F69  f2 00 26 60 31
	add XBC,XIX                                          ; FC5F6E  ec 81
	ld H,(XBC)                                           ; FC5F70  81 26
	and H,0x1f                                           ; FC5F72  ce cc 1f
	lda xbc, (NoteRouting:24)                               ; FC5F75  f2 00 22 60 31
	add XBC,XIX                                          ; FC5F7A  ec 81
	ld L,(XBC)                                           ; FC5F7C  81 27
	and L,0x1f                                           ; FC5F7E  cf cc 1f
	cp L,H                                               ; FC5F81  ce f7
	jr z, .LFC5F96                                       ; FC5F83  66 11
	push 0x00                                            ; FC5F85  09 00
	push H                                               ; FC5F87  ce 04
	pushw hl                                             ; FC5F89  2b
	push 0x00                                            ; FC5F8A  09 00
	push D                                               ; FC5F8C  cc 04
	pushw 0x03                                           ; FC5F8E  0b 03 00
	calr NoteRouting_QueueChange                                      ; FC5F91  1e 46 fd
	inc 8,XSP                                            ; FC5F94  ef 60
.LFC5F96:
	sub XBC,XBC                                          ; FC5F96  e9 a1
	inc 1,XBC                                            ; FC5F98  e9 61
	add (xiz-4), xbc                                     ; FC5F9A  ae fc 89
	add XIX,XBC                                          ; FC5F9D  e9 84
	add D,C                                              ; FC5F9F  cb 84
	cp D,0x10                                            ; FC5FA1  cc cf 10
	jr c, .LFC5F3A                                       ; FC5FA4  67 94
.LFC5FA6:
	pop XIX                                              ; FC5FA6  5c
	popw de                                              ; FC5FA7  4a
	popw hl                                              ; FC5FA8  4b
	unlk XIZ                                             ; FC5FA9  ee 0d
	ret                                                  ; FC5FAB  0e
; NoteRouting_QueueMidiOutSchemeChange: (bit 5): kind 8 (previous bit 5, 0xFF, previous NoteRouting_SingleChannel) when NoteRouting_MidiFlags bit 5
;   changed, or when the channel changed while bit 5 is set.
NoteRouting_QueueMidiOutSchemeChange:
	pushw hl                                             ; FC5FAC  2b
	push XIX                                             ; FC5FAD  3c
	lda xix, (NoteRouting_Previous:24)                               ; FC5FAE  f2 00 26 60 34
	ld C,(XIX+0x0293)                                    ; FC5FB3  c3 f1 93 02 23
	and C,0x20                                           ; FC5FB8  cb cc 20
	srl c, 0x05                                          ; FC5FBB  cb ef 05
	ld H,C                                               ; FC5FBE  cb 8e
	ld a, (NoteRouting_MidiFlags:24)                                 ; FC5FC0  c2 93 24 60 21
	and A,0x20                                           ; FC5FC5  c9 cc 20
	srl a, 0x05                                          ; FC5FC8  c9 ef 05
	cp A,C                                               ; FC5FCB  cb f1
	jr z, .LFC5FFB                                       ; FC5FCD  66 2c
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC5FCF  f2 93 24 60 cd
	jr z, .LFC5FEB                                       ; FC5FD4  66 15
	bit 5,(XIX+0x0293)                                   ; FC5FD6  f3 f1 93 02 cd
	jr nz, .LFC5FEB                                      ; FC5FDB  6e 0e
	ld C,(XIX+0x0292)                                    ; FC5FDD  c3 f1 92 02 23
	pushw bc                                             ; FC5FE2  29
	pushw 0xff                                           ; FC5FE3  0b ff 00
	pushw 0x00                                           ; FC5FE6  0b 00 00
	jr .LFC601C                                          ; FC5FE9  68 31
.LFC5FEB:
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC5FEB  f2 93 24 60 cd
	jr nz, .LFC6024                                      ; FC5FF0  6e 32
	bit 5,(XIX+0x0293)                                   ; FC5FF2  f3 f1 93 02 cd
	jr z, .LFC6024                                       ; FC5FF7  66 2b
	jr .LFC6010                                          ; FC5FF9  68 15
.LFC5FFB:
	ld H,(XIX+0x0292)                                    ; FC5FFB  c3 f1 92 02 26
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC6000  c2 92 24 60 23
	cp C,H                                               ; FC6005  ce f3
	jr z, .LFC6024                                       ; FC6007  66 1b
	bit 5,(XIX+0x0293)                                   ; FC6009  f3 f1 93 02 cd
	jr z, .LFC6024                                       ; FC600E  66 14
.LFC6010:
	ld C,(XIX+0x0292)                                    ; FC6010  c3 f1 92 02 23
	pushw bc                                             ; FC6015  29
	pushw 0xff                                           ; FC6016  0b ff 00
	pushw 0x01                                           ; FC6019  0b 01 00
.LFC601C:
	pushw 0x08                                           ; FC601C  0b 08 00
	calr NoteRouting_QueueChange                                      ; FC601F  1e b8 fc
	inc 8,XSP                                            ; FC6022  ef 60
.LFC6024:
	pop XIX                                              ; FC6024  5c
	popw hl                                              ; FC6025  4b
	ret                                                  ; FC6026  0e
; NoteRouting_QueueToneGenPartChanges: for each of the 32 parts, kind 4 (part, new, old) when its tone-generator part (block +0x02) changed.  Nothing
;   calls it: neither ROM holds 27 60 FC (a 24-bit pointer, call or jp to it) and no prom_a calr reaches it.  Kind 4's
;   handler is a bare ret (NoteChange_PartToneGen_Nop).
NoteRouting_QueueToneGenPartChanges:
	pushw hl                                             ; FC6027  2b
	pushw de                                             ; FC6028  2a
	push XIX                                             ; FC6029  3c
	ld XIX,0x00000002                                    ; FC602A  44 02 00 00 00
	ld h, 0x00:opc                                          ; FC602F  26 00
.LFC6031:
	lda xbc, (NoteRouting_Previous:24)                               ; FC6031  f2 00 26 60 31
	add XBC,XIX                                          ; FC6036  ec 81
	ld L,(XBC)                                           ; FC6038  81 27
	lda xbc, (NoteRouting:24)                               ; FC603A  f2 00 22 60 31
	add XBC,XIX                                          ; FC603F  ec 81
	ld D,(XBC)                                           ; FC6041  81 24
	cp D,L                                               ; FC6043  cf f4
	jr z, .LFC6058                                       ; FC6045  66 11
	pushw hl                                             ; FC6047  2b
	push 0x00                                            ; FC6048  09 00
	push D                                               ; FC604A  cc 04
	push 0x00                                            ; FC604C  09 00
	push H                                               ; FC604E  ce 04
; (sub_FC6050 removed 2026-10-04: no code names it and the line above falls through into it -- part of NoteRouting_QueueMidiOutSchemeChange;
;  notes/prom_a_stray_label_removal.py)
	pushw 0x04                                           ; FC6050  0b 04 00
	calr NoteRouting_QueueChange                                      ; FC6053  1e 84 fc
	inc 8,XSP                                            ; FC6056  ef 60
.LFC6058:
	inc 1,XIX                                            ; FC6058  ec 61
	inc 1,H                                              ; FC605A  ce 61
	cp H,0x20                                            ; FC605C  ce cf 20
	jr c, .LFC6031                                       ; FC605F  67 d0
	pop XIX                                              ; FC6061  5c
	popw de                                              ; FC6062  4a
	popw hl                                              ; FC6063  4b
	ret                                                  ; FC6064  0e
; NoteRouting_QueuePartTransmitChanges: (bit 5): for each of the 32 parts, kind 5 (part, new, old) when its channel (+0x22) changed, or kind 5
;   (part, 0xFF, channel) when its transmit bit (record +0x152 bit 5) changed.
NoteRouting_QueuePartTransmitChanges:
	link XIZ,0xfff4                                      ; FC6065  ee 0c f4 ff
	pushw hl                                             ; FC6069  2b
	pushw de                                             ; FC606A  2a
	push XIX                                             ; FC606B  3c
	ld XIX,0x00000022                                    ; FC606C  44 22 00 00 00
	sub XBC,XBC                                          ; FC6071  e9 a1
	ld (xiz-4), xbc                                      ; FC6073  be fc 61
	ld h, 0x00:opc                                          ; FC6076  26 00
.LFC6078:
	lda xbc, (NoteRouting_Previous:24)                               ; FC6078  f2 00 26 60 31
	add XBC,XIX                                          ; FC607D  ec 81
	ld D,(XBC)                                           ; FC607F  81 24
	lda xbc, (NoteRouting:24)                               ; FC6081  f2 00 22 60 31
	add XBC,XIX                                          ; FC6086  ec 81
	ld L,(XBC)                                           ; FC6088  81 27
	ld (xiz-8), xix                                      ; FC608A  be f8 64
	cp L,D                                               ; FC608D  cc f7
	jr z, .LFC609F                                       ; FC608F  66 0e
	lda xbc, (NoteRouting_Previous:24)                               ; FC6091  f2 00 26 60 31
	add	xbc, (xiz-8)                                 ; FC6096  ae f8 81
	ld A,(XBC)                                           ; FC6099  81 21
	pushw wa                                             ; FC609B  28
	pushw hl                                             ; FC609C  2b
	jr .LFC60EB                                          ; FC609D  68 4c
.LFC609F:
	lda xbc, (NoteRouting:24)                               ; FC609F  f2 00 22 60 31
	add	xbc, (xiz-8)                                 ; FC60A4  ae f8 81
	ld A,(XBC)                                           ; FC60A7  81 21
	cp A,0xff                                            ; FC60A9  c9 cf ff
	jr z, .LFC60F7                                       ; FC60AC  66 49
	ld xbc, (xiz-4)                                      ; FC60AE  ae fc 21
	add XBC,0x00000152                                   ; FC60B1  e9 c8 52 01 00 00
	ld (xiz-12), xbc                                     ; FC60B7  be f4 61
	add XBC,NoteRouting_Previous                                   ; FC60BA  e9 c8 00 26 60 00
	ld A,(XBC)                                           ; FC60C0  81 21
	and A,0x20                                           ; FC60C2  c9 cc 20
	srl a, 0x05                                          ; FC60C5  c9 ef 05
	ld L,A                                               ; FC60C8  c9 8f
	lda xbc, (NoteRouting:24)                               ; FC60CA  f2 00 22 60 31
	add	xbc, (xiz-12)                                ; FC60CF  ae f4 81
	ld W,(XBC)                                           ; FC60D2  81 20
	and W,0x20                                           ; FC60D4  c8 cc 20
	srl w, 0x05                                          ; FC60D7  c8 ef 05
	cp W,A                                               ; FC60DA  c9 f0
	jr z, .LFC60F7                                       ; FC60DC  66 19
	lda xbc, (NoteRouting:24)                               ; FC60DE  f2 00 22 60 31
	add XBC,XIX                                          ; FC60E3  ec 81
	ld A,(XBC)                                           ; FC60E5  81 21
	pushw wa                                             ; FC60E7  28
	pushw 0xff                                           ; FC60E8  0b ff 00
.LFC60EB:
	push 0x00                                            ; FC60EB  09 00
	push H                                               ; FC60ED  ce 04
	pushw 0x05                                           ; FC60EF  0b 05 00
	calr NoteRouting_QueueChange                                      ; FC60F2  1e e5 fb
	inc 8,XSP                                            ; FC60F5  ef 60
.LFC60F7:
	inc 1,XIX                                            ; FC60F7  ec 61
	ld XBC,0x0000000a                                    ; FC60F9  41 0a 00 00 00
	add (xiz-4), xbc                                     ; FC60FE  ae fc 89
	inc 1,H                                              ; FC6101  ce 61
	cp H,0x20                                            ; FC6103  ce cf 20
	jrl c, .LFC6078                                      ; FC6106  77 6f ff
	pop XIX                                              ; FC6109  5c
	popw de                                              ; FC610A  4a
	popw hl                                              ; FC610B  4b
	unlk XIZ                                             ; FC610C  ee 0d
	ret                                                  ; FC610E  0e
; NoteRouting_QueueTrackPartChanges: (bit 6): for each of the 16 tracks, kind 6 (track, new, old) when its part (+0x42, low 5 bits) changed.
NoteRouting_QueueTrackPartChanges:
	pushw hl                                             ; FC610F  2b
	pushw de                                             ; FC6110  2a
	push XIX                                             ; FC6111  3c
	ld XIX,0x00000042                                    ; FC6112  44 42 00 00 00
	ld h, 0x00:opc                                          ; FC6117  26 00
.LFC6119:
	lda xbc, (NoteRouting_Previous:24)                               ; FC6119  f2 00 26 60 31
	add XBC,XIX                                          ; FC611E  ec 81
	ld L,(XBC)                                           ; FC6120  81 27
	and L,0x1f                                           ; FC6122  cf cc 1f
	lda xbc, (NoteRouting:24)                               ; FC6125  f2 00 22 60 31
	add XBC,XIX                                          ; FC612A  ec 81
	ld D,(XBC)                                           ; FC612C  81 24
	and D,0x1f                                           ; FC612E  cc cc 1f
	cp D,L                                               ; FC6131  cf f4
	jr z, .LFC6146                                       ; FC6133  66 11
	pushw hl                                             ; FC6135  2b
	push 0x00                                            ; FC6136  09 00
	push D                                               ; FC6138  cc 04
	push 0x00                                            ; FC613A  09 00
	push H                                               ; FC613C  ce 04
	pushw 0x06                                           ; FC613E  0b 06 00
	calr NoteRouting_QueueChange                                      ; FC6141  1e 96 fb
	inc 8,XSP                                            ; FC6144  ef 60
.LFC6146:
	inc 1,XIX                                            ; FC6146  ec 61
	inc 1,H                                              ; FC6148  ce 61
	cp H,0x10                                            ; FC614A  ce cf 10
	jr c, .LFC6119                                       ; FC614D  67 ca
	pop XIX                                              ; FC614F  5c
	popw de                                              ; FC6150  4a
	popw hl                                              ; FC6151  4b
	ret                                                  ; FC6152  0e
; NoteRouting_UpdateActivePartMask: (0x4C06) = BitMask32_Table_FC64C6[block +1], or block +0 when +1 is 0xFF; when it changed,
;   T_ParamMsg_RefreshPartMasks.
NoteRouting_UpdateActivePartMask:
	link XIZ,0xfffc                                      ; FC6153  ee 0c fc ff
	pushw hl                                             ; FC6157  2b
	push XIX                                             ; FC6158  3c
	lda xix, (NoteRouting_ActivePartMask:16)                                ; FC6159  f1 06 4c 34
	ld XBC,(XIX)                                         ; FC615D  a4 21
	ld (xiz-4), xbc                                      ; FC615F  be fc 61
	sub XWA,XWA                                          ; FC6162  e8 a0
	ld (XIX),XWA                                         ; FC6164  b4 60
	ld h, (0x602201:24)                                 ; FC6166  c2 01 22 60 26
	cp H,0xff                                            ; FC616B  ce cf ff
	jr nz, .LFC617D                                      ; FC616E  6e 0d
	ld c, (NoteRouting:24)                                 ; FC6170  c2 00 22 60 23
	extz BC                                              ; FC6175  d9 12
	extz XBC                                             ; FC6177  e9 12
	ld (XIX),XBC                                         ; FC6179  b4 61
	jr .LFC618D                                          ; FC617B  68 10
.LFC617D:
	ld c, 0x04:opc                                          ; FC617D  23 04
	mul bc, h                                          ; FC617F  ce 43
	extz XBC                                             ; FC6181  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC6183  e9 c8 c6 64 fc 00
	ld XBC,(XBC)                                         ; FC6189  a1 21
	ld (XIX),XBC                                         ; FC618B  b4 61
.LFC618D:
	ld XBC,(XIX)                                         ; FC618D  a4 21
	cp	xbc, (xiz-4)                                 ; FC618F  ae fc f1
	jr z, .LFC61A0                                       ; FC6192  66 0c
	push XDE                                             ; FC6194  3a
	push XHL                                             ; FC6195  3b
	push XIX                                             ; FC6196  3c
	push XIZ                                             ; FC6197  3e
	call T_ParamMsg_RefreshPartMasks                                        ; FC6198  1d 98 07 f4
	pop XIZ                                              ; FC619C  5e
	pop XIX                                              ; FC619D  5c
	pop XHL                                              ; FC619E  5b
	pop XDE                                              ; FC619F  5a
.LFC61A0:
	pop XIX                                              ; FC61A0  5c
	popw hl                                              ; FC61A1  4b
	unlk XIZ                                             ; FC61A2  ee 0d
	ret                                                  ; FC61A4  0e
NoteRouting_RebuildStep_Nop:
	ret                                                  ; FC61A5  0e
; NoteRouting_BuildTrackRouting: the 16 tracks' entries for the song: block +0x42 + t = the track's part (BStore_TrackToPart through
;   Bytes_00_to_1F_FC64A5) and +0x52 + t = its MIDI OUT channel (0x603433 + t, 0x20 -> 0xFF), else 0xFF.  A track is
;   routed for playback while NoteRouting_Mode bit 8 ((0x133A) | (0x60341E) nonzero) and its bit is in that mask, and
;   for recording (part | 0x80, the first such part's code in (0x4C20)) while bit 7 ((0x1336) | (0x3000)).
;   ChangeFlags |= 0xC0 per track.
NoteRouting_BuildTrackRouting:
	link XIZ,0xffeb                                      ; FC61A6  ee 0c eb ff
	pushw hl                                             ; FC61AA  2b
	pushw de                                             ; FC61AB  2a
	push XIX                                             ; FC61AC  3c
	ldw	(xiz-16), 0x0000                             ; FC61AD  be f0 02 00 00
	andw	(NoteRouting_Mode:24), 0xfe3f                ; FC61B2  d2 98 24 60 3c 3f fe
	ld (0x4c20:24), 0xff                               ; FC61B9  f2 20 4c 00 00 ff
	ld hl, (0x133a:16)                                 ; FC61BF  d1 3a 13 23
	ld bc, (0x60341e:24)                                ; FC61C3  d2 1e 34 60 21
	or BC,HL                                             ; FC61C8  db e1
	ld (xiz-18), bc                                      ; FC61CA  be ee 51
	jr z, .LFC61D8                                       ; FC61CD  66 09
	orw	(NoteRouting_Mode:24), 0x0100                ; FC61CF  d2 98 24 60 3e 00 01
	jr .LFC61DF                                          ; FC61D6  68 07
.LFC61D8:
	andw	(NoteRouting_Mode:24), 0xfeff                ; FC61D8  d2 98 24 60 3c ff fe
.LFC61DF:
	ld hl, (0x1336:16)                                 ; FC61DF  d1 36 13 23
	ld bc, (0x3000:16)                                 ; FC61E3  d1 00 30 21
	or BC,HL                                             ; FC61E7  db e1
	ld (xiz-20), bc                                      ; FC61E9  be ec 51
	jr z, .LFC61F7                                       ; FC61EC  66 09
	orw	(NoteRouting_Mode:24), 0x0080                ; FC61EE  d2 98 24 60 3e 80 00
	jr .LFC61FE                                          ; FC61F5  68 07
.LFC61F7:
	andw	(NoteRouting_Mode:24), 0xff7f                ; FC61F7  d2 98 24 60 3c 7f ff
.LFC61FE:
	ld (xiz-21), 0x00                                    ; FC61FE  be eb 00 00
	ld bc, (xiz-20)                                      ; FC6202  9e ec 21
	or	bc, (xiz-18)                                 ; FC6205  9e ee e1
	extz XBC                                             ; FC6208  e9 12
	ld (xiz-14), xbc                                     ; FC620A  be f2 61
	ldw de, 0x00                                         ; FC620D  32 00 00
	ld XWA,0x00000042                                    ; FC6210  40 42 00 00 00
	ld (xiz-10), xwa                                     ; FC6215  be f6 60
	ld XIY,0x00000052                                    ; FC6218  45 52 00 00 00
	ld (xiz-6), xiy                                      ; FC621D  be fa 65
.LFC6220:
	ld ix, (xiz-21)                                      ; FC6220  9e eb 24
	extz IX                                              ; FC6223  dc 12
	extz XIX                                             ; FC6225  ec 12
	lda xbc, (BStore_TrackToPart:24)                               ; FC6227  f2 22 34 60 31
	add XBC,XIX                                          ; FC622C  ec 81
	ld L,(XBC)                                           ; FC622E  81 27
	lda xbc, (0x603433:24)                               ; FC6230  f2 33 34 60 31
	add XBC,XIX                                          ; FC6235  ec 81
	ld H,(XBC)                                           ; FC6237  81 26
	cp H,0x20                                            ; FC6239  ce cf 20
	jr nz, .LFC6244                                      ; FC623C  6e 06
	ld (xiz-1), 0xff                                     ; FC623E  be ff 00 ff
	jr .LFC6247                                          ; FC6242  68 03
.LFC6244:
	ld (xiz-1), h                                        ; FC6244  be ff 46
.LFC6247:
	ld C,L                                               ; FC6247  cf 8b
	extz BC                                              ; FC6249  d9 12
	extz XBC                                             ; FC624B  e9 12
	add XBC,Bytes_00_to_1F_FC64A5                        ; FC624D  e9 c8 a5 64 fc 00
	ld A,(XBC)                                           ; FC6253  81 21
	cp A,0xff                                            ; FC6255  c9 cf ff
	jr z, .LFC626D                                       ; FC6258  66 13
	ld BC,DE                                             ; FC625A  da 89
	extz XBC                                             ; FC625C  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC625E  e9 c8 c6 64 fc 00
	ld XBC,(XBC)                                         ; FC6264  a1 21
	ld XIX,XBC                                           ; FC6266  e9 8c
	and	xbc, (xiz-14)                                ; FC6268  ae f2 c1
; (sub_FC626B removed 2026-10-04: no code names it and the line above falls through into it -- part of NoteRouting_BuildTrackRouting;
;  notes/prom_a_stray_label_removal.py)
	jr nz, .LFC6286                                      ; FC626B  6e 19
.LFC626D:
	lda xbc, (NoteRouting:24)                               ; FC626D  f2 00 22 60 31
	add	xbc, (xiz-10)                                ; FC6272  ae f6 81
	ld (XBC),0xff                                        ; FC6275  b1 00 ff
	lda xbc, (NoteRouting:24)                               ; FC6278  f2 00 22 60 31
	add	xbc, (xiz-6)                                 ; FC627D  ae fa 81
	ld (XBC),0xff                                        ; FC6280  b1 00 ff
	jrl .LFC6343                                         ; FC6283  78 bd 00
.LFC6286:
	ld bc, (NoteRouting_Mode:24)                                ; FC6286  d2 98 24 60 21
	and BC,0x0100                                        ; FC628B  d9 cc 00 01
	jr z, .LFC62E8                                       ; FC628F  66 57
	ld bc, (xiz-18)                                      ; FC6291  9e ee 21
	extz XBC                                             ; FC6294  e9 12
	and XBC,XIX                                          ; FC6296  ec c1
	jr z, .LFC62E8                                       ; FC6298  66 4e
	cp	(UI_ScreenLatch:16), 0x0e                            ; FC629A  c1 7a 20 3f 0e
	jr nz, .LFC62AD                                      ; FC629F  6e 0c
	ld bc, (0x1072:16)                                 ; FC62A1  d1 72 10 21
	extz XBC                                             ; FC62A5  e9 12
	and XBC,XIX                                          ; FC62A7  ec c1
	jr z, .LFC62D0                                       ; FC62A9  66 25
	jr .LFC62B6                                          ; FC62AB  68 09
.LFC62AD:
	ld XBC,XIX                                           ; FC62AD  ec 89
	and	xbc, (0x603454:24)                           ; FC62AF  e2 54 34 60 c1
	jr z, .LFC62D0                                       ; FC62B4  66 1a
.LFC62B6:
	ld C,L                                               ; FC62B6  cf 8b
	extz BC                                              ; FC62B8  d9 12
	extz XBC                                             ; FC62BA  e9 12
	add XBC,Bytes_00_to_1F_FC64A5                        ; FC62BC  e9 c8 a5 64 fc 00
	ld A,(XBC)                                           ; FC62C2  81 21
	lda xbc, (NoteRouting:24)                               ; FC62C4  f2 00 22 60 31
	add	xbc, (xiz-10)                                ; FC62C9  ae f6 81
	ld (XBC),A                                           ; FC62CC  b1 41
	jr .LFC62DB                                          ; FC62CE  68 0b
.LFC62D0:
	lda xbc, (NoteRouting:24)                               ; FC62D0  f2 00 22 60 31
	add	xbc, (xiz-10)                                ; FC62D5  ae f6 81
	ld (XBC),0xff                                        ; FC62D8  b1 00 ff
.LFC62DB:
	lda xbc, (NoteRouting:24)                               ; FC62DB  f2 00 22 60 31
	add	xbc, (xiz-6)                                 ; FC62E0  ae fa 81
	ld a, (xiz-1)                                        ; FC62E3  8e ff 21
	ld (XBC),A                                           ; FC62E6  b1 41
.LFC62E8:
	ld bc, (NoteRouting_Mode:24)                                ; FC62E8  d2 98 24 60 21
	and BC,0x0080                                        ; FC62ED  d9 cc 80 00
	jr z, .LFC6343                                       ; FC62F1  66 50
	ld BC,DE                                             ; FC62F3  da 89
	extz XBC                                             ; FC62F5  e9 12
	add XBC,BitMask32_Table_FC64C6                       ; FC62F7  e9 c8 c6 64 fc 00
	ld XBC,(XBC)                                         ; FC62FD  a1 21
	ld XIX,XBC                                           ; FC62FF  e9 8c
	ld wa, (xiz-20)                                      ; FC6301  9e ec 20
	extz XWA                                             ; FC6304  e8 12
	and XWA,XBC                                          ; FC6306  e9 c0
	jr z, .LFC6343                                       ; FC6308  66 39
	incw 0x01, (xiz-16)                                  ; FC630A  9e f0 61
	cp	(0x004c20:24), 0xff                          ; FC630D  c2 20 4c 00 3f ff
	jr nz, .LFC6328                                      ; FC6313  6e 13
	ld C,L                                               ; FC6315  cf 8b
	extz BC                                              ; FC6317  d9 12
	extz XBC                                             ; FC6319  e9 12
	add XBC,Bytes_00_to_1F_FC64A5                        ; FC631B  e9 c8 a5 64 fc 00
	ld A,(XBC)                                           ; FC6321  81 21
	ld (0x4c20:24), a                                   ; FC6323  f2 20 4c 00 41
.LFC6328:
	ld C,L                                               ; FC6328  cf 8b
	extz BC                                              ; FC632A  d9 12
	extz XBC                                             ; FC632C  e9 12
	add XBC,Bytes_00_to_1F_FC64A5                        ; FC632E  e9 c8 a5 64 fc 00
	ld A,(XBC)                                           ; FC6334  81 21
	set 0x07,A                                           ; FC6336  c9 31 07
	lda xbc, (NoteRouting:24)                               ; FC6339  f2 00 22 60 31
	add	xbc, (xiz-10)                                ; FC633E  ae f6 81
	ld (XBC),A                                           ; FC6341  b1 41
.LFC6343:
	orw	(NoteRouting_ChangeFlags:16), 0x00c0                  ; FC6343  d1 04 4c 3e c0 00
	inc 4,DE                                             ; FC6349  da 64
	sub XBC,XBC                                          ; FC634B  e9 a1
	inc 1,XBC                                            ; FC634D  e9 61
	add (xiz-10), xbc                                    ; FC634F  ae f6 89
	add (xiz-6), xbc                                     ; FC6352  ae fa 89
	add (xiz-21), c                                      ; FC6355  8e eb 8b
	cp	(xiz-21), 0x10                               ; FC6358  8e eb 3f 10
	jrl c, .LFC6220                                      ; FC635C  77 c1 fe
	cpw	(xiz-16), 0x0000                             ; FC635F  9e f0 3f 00 00
	jr z, .LFC637F                                       ; FC6364  66 19
	orw	(NoteRouting_Mode:24), 0x0040                ; FC6366  d2 98 24 60 3e 40 00
	ld c, (0x34d4:16)                                   ; FC636D  c1 d4 34 23
	and C,0x08                                           ; FC6371  cb cc 08
	jr z, .LFC6386                                       ; FC6374  66 10
	andw	(NoteRouting_Mode:24), 0xff7f                ; FC6376  d2 98 24 60 3c 7f ff
	jr .LFC6386                                          ; FC637D  68 07
.LFC637F:
	andw	(NoteRouting_Mode:24), 0xffbf                ; FC637F  d2 98 24 60 3c bf ff
.LFC6386:
	pop XIX                                              ; FC6386  5c
	popw de                                              ; FC6387  4a
	popw hl                                              ; FC6388  4b
	unlk XIZ                                             ; FC6389  ee 0d
	ret                                                  ; FC638B  0e
	ret                                                  ; FC638C  0e
	ret                                                  ; FC638D  0e
	ret                                                  ; FC638E  0e
	ret                                                  ; FC638F  0e
	ret                                                  ; FC6390  0e
	ret                                                  ; FC6391  0e
	ret                                                  ; FC6392  0e
; NoteRouting_InitDefaults: each of the 32 parts plays tone-generator part = itself.  Its tone-generator record has bits 6-7 clear, velocity
;   offset (+1) 0 and pointer (+2) 0x602ACA.  Its MIDI record has bits 5 and 6 set (transmit, receive), bit 7 clear,
;   transpose (+1) 0 and pointers (+2, +6) 0x602ACA.  Then MIDI INPUT / OUTPUT MODE 0, NoteRouting_SingleChannel 0,
;   both MIDI OUT ports allowed, 0x602494 (32-bit) = 0, NoteRouting_Mode = 0.
NoteRouting_InitDefaults:
	link XIZ,0xffdc                                      ; FC6393  ee 0c dc ff
	pushw hl                                             ; FC6397  2b
	push XIX                                             ; FC6398  3c
	sub XBC,XBC                                          ; FC6399  e9 a1
	ld (xiz-8), xbc                                      ; FC639B  be f8 61
	sub XWA,XWA                                          ; FC639E  e8 a0
	ld (xiz-4), xwa                                      ; FC63A0  be fc 60
	ld XIX,0x00000002                                    ; FC63A3  44 02 00 00 00
	ld h, 0x00:opc                                          ; FC63A8  26 00
.LFC63AA:
	ld xbc, (xiz-8)                                      ; FC63AA  ae f8 21
	ld (xiz-12), xbc                                     ; FC63AD  be f4 61
	ld (xiz-16), xbc                                     ; FC63B0  be f0 61
	add XBC,0x00000092                                   ; FC63B3  e9 c8 92 00 00 00
	add XBC,NoteRouting                                   ; FC63B9  e9 c8 00 22 60 00
	ld (xiz-20), xbc                                     ; FC63BF  be ec 61
	res 7,(XBC)                                          ; FC63C2  b1 b7
	res 6,(XBC)                                          ; FC63C4  b1 b6
	ld xbc, (xiz-16)                                     ; FC63C6  ae f0 21
	add XBC,0x00000093                                   ; FC63C9  e9 c8 93 00 00 00
	add XBC,NoteRouting                                   ; FC63CF  e9 c8 00 22 60 00
	ld (XBC),0x00                                        ; FC63D5  b1 00 00
	ld xbc, (xiz-16)                                     ; FC63D8  ae f0 21
	add XBC,0x00000094                                   ; FC63DB  e9 c8 94 00 00 00
	add XBC,NoteRouting                                   ; FC63E1  e9 c8 00 22 60 00
	lda xwa, (0x602aca:24)                               ; FC63E7  f2 ca 2a 60 30
	ld (XBC),XWA                                         ; FC63EC  b1 60
	ld xbc, (xiz-4)                                      ; FC63EE  ae fc 21
	ld (xiz-24), xbc                                     ; FC63F1  be e8 61
	ld (xiz-28), xbc                                     ; FC63F4  be e4 61
	add XBC,0x00000152                                   ; FC63F7  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC63FD  e9 c8 00 22 60 00
	ld (xiz-32), xbc                                     ; FC6403  be e0 61
	res 7,(XBC)                                          ; FC6406  b1 b7
	set 6,(XBC)                                          ; FC6408  b1 be
	set 5,(XBC)                                          ; FC640A  b1 bd
	ld xbc, (xiz-28)                                     ; FC640C  ae e4 21
	add XBC,0x00000153                                   ; FC640F  e9 c8 53 01 00 00
	add XBC,NoteRouting                                   ; FC6415  e9 c8 00 22 60 00
	ld (XBC),0x00                                        ; FC641B  b1 00 00
	ld xbc, (xiz-28)                                     ; FC641E  ae e4 21
	add XBC,0x00000154                                   ; FC6421  e9 c8 54 01 00 00
	add XBC,NoteRouting                                   ; FC6427  e9 c8 00 22 60 00
	lda xwa, (0x602aca:24)                               ; FC642D  f2 ca 2a 60 30
	ld (XBC),XWA                                         ; FC6432  b1 60
	ld xbc, (xiz-28)                                     ; FC6434  ae e4 21
	add XBC,0x00000158                                   ; FC6437  e9 c8 58 01 00 00
	add XBC,NoteRouting                                   ; FC643D  e9 c8 00 22 60 00
	lda xwa, (0x602aca:24)                               ; FC6443  f2 ca 2a 60 30
	ld (XBC),XWA                                         ; FC6448  b1 60
	ld L,H                                               ; FC644A  ce 8f
	ld (xiz-36), xix                                     ; FC644C  be dc 64
	lda xbc, (NoteRouting:24)                               ; FC644F  f2 00 22 60 31
	add	xbc, (xiz-36)                                ; FC6454  ae dc 81
	ld (XBC),L                                           ; FC6457  b1 47
	ld xbc, (xiz-12)                                     ; FC6459  ae f4 21
	inc 6,XBC                                            ; FC645C  e9 66
	ld (xiz-8), xbc                                      ; FC645E  be f8 61
	ld xwa, (xiz-24)                                     ; FC6461  ae e8 20
	add XWA,0x0000000a                                   ; FC6464  e8 c8 0a 00 00 00
	ld (xiz-4), xwa                                      ; FC646A  be fc 60
	ld xix, (xiz-36)                                     ; FC646D  ae dc 24
	inc 1,XIX                                            ; FC6470  ec 61
	ld H,L                                               ; FC6472  cf 8e
	inc 1,H                                              ; FC6474  ce 61
	cp H,0x20                                            ; FC6476  ce cf 20
	jrl c, .LFC63AA                                      ; FC6479  77 2e ff
	and	(NoteRouting_MidiFlags:24), 0x1f                          ; FC647C  c2 93 24 60 3c 1f
	ld (NoteRouting_SingleChannel:24), 0x00                             ; FC6482  f2 92 24 60 00 00
	set	3, (NoteRouting_MidiFlags:24)                             ; FC6488  f2 93 24 60 bb
	set	4, (NoteRouting_MidiFlags:24)                             ; FC648D  f2 93 24 60 bc
	sub XBC,XBC                                          ; FC6492  e9 a1
	ld (0x602494:24), xbc                               ; FC6494  f2 94 24 60 61
	ldw (NoteRouting_Mode:24), 0x00                             ; FC6499  f2 98 24 60 02 00 00
	pop XIX                                              ; FC64A0  5c
	popw hl                                              ; FC64A1  4b
	unlk XIZ                                             ; FC64A2  ee 0d
	ret                                                  ; FC64A4  0e
; ---------------------------------------------------------------------
; Bytes_00_to_1F_FC64A5 -- 32 bytes 0x00..0x1F, then one 0xFF
;
; Read by: FIVE sites, all in this module -- `lda XIY,0x00FC64A5` at 0xFC5429
;          and `add XBC,0x00FC64A5` at 0xFC624E, 0xFC62BD, 0xFC631C, 0xFC632F.
;          A BYTE table: the add-form readers fetch with `ld A,(XBC)`.
; Evidence: `list(bytes[0:32]) == list(range(32))`, checked whole.
; ENTRY COUNT 32: the byte after the run is 0xFF, and the byte after THAT,
;          0xFC64C6, is named as a 32-bit immediate by eight separate readers
;          (it is BitMask32_Table_FC64C6's base) -- so the end is pinned by
;          other code, not by where the ascending run stops.
; ⚠ The single 0xFF at 0xFC64C5 is inside this block because it is not part of
;   either table.  Whether it is a terminator or alignment is NOT established.
; ---------------------------------------------------------------------
Bytes_00_to_1F_FC64A5:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FC64A5
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FC64B5
	.byte 0xff                                                                ; FC64C5
; ---------------------------------------------------------------------
; BitMask32_Table_FC64C6 -- the 32 powers of two, a SECOND copy
;
; Read by: EIGHT sites, all `add XBC,0x00FC64C6` -- 0xFC5705, 0xFC5734,
;          0xFC5777, 0xFC57A6, 0xFC5B5E, 0xFC6184, 0xFC625F, 0xFC62F8.
; Layout:  32 LE32 entries, entry k = 1 << k.
; Evidence: `[le32(k) for k in range(32)] == [1 << k for k in range(32)]`,
;          checked whole; entry 31 is 0x80000000.
; ENTRY COUNT 32: 128 bytes between two independently named addresses --
;          0xFC64C6 (eight readers) and 0xFC6546 (four readers, it is
;          NoteRouting_BuildByPanelMode's base).
; ★ This is a SECOND, independent copy of the same 128 bytes that
;   BitMask32_Table at 0xFAD20A holds; the two are byte-identical and each is
;   read only by sites inside its own module.  A shared constant table
;   duplicated per module is what a linker with per-module literal pools
;   produces; nothing here proves that, and the two tables are documented
;   separately for that reason.
; ---------------------------------------------------------------------
BitMask32_Table_FC64C6:
	.long 0x00000001                                 ; FC64C6  [  0]
	.long 0x00000002                                 ; FC64CA  [  1]
	.long 0x00000004                                 ; FC64CE  [  2]
	.long 0x00000008                                 ; FC64D2  [  3]
	.long 0x00000010                                 ; FC64D6  [  4]
	.long 0x00000020                                 ; FC64DA  [  5]
	.long 0x00000040                                 ; FC64DE  [  6]
	.long 0x00000080                                 ; FC64E2  [  7]
	.long 0x00000100                                 ; FC64E6  [  8]
	.long 0x00000200                                 ; FC64EA  [  9]
	.long 0x00000400                                 ; FC64EE  [ 10]
	.long 0x00000800                                 ; FC64F2  [ 11]
	.long 0x00001000                                 ; FC64F6  [ 12]
	.long 0x00002000                                 ; FC64FA  [ 13]
	.long 0x00004000                                 ; FC64FE  [ 14]
	.long 0x00008000                                 ; FC6502  [ 15]
	.long 0x00010000                                 ; FC6506  [ 16]
	.long 0x00020000                                 ; FC650A  [ 17]
	.long 0x00040000                                 ; FC650E  [ 18]
	.long 0x00080000                                 ; FC6512  [ 19]
	.long 0x00100000                                 ; FC6516  [ 20]
	.long 0x00200000                                 ; FC651A  [ 21]
	.long 0x00400000                                 ; FC651E  [ 22]
	.long 0x00800000                                 ; FC6522  [ 23]
	.long 0x01000000                                 ; FC6526  [ 24]
	.long 0x02000000                                 ; FC652A  [ 25]
	.long 0x04000000                                 ; FC652E  [ 26]
	.long 0x08000000                                 ; FC6532  [ 27]
	.long 0x10000000                                 ; FC6536  [ 28]
	.long 0x20000000                                 ; FC653A  [ 29]
	.long 0x40000000                                 ; FC653E  [ 30]
	.long 0x80000000                                 ; FC6542  [ 31]
; ---------------------------------------------------------------------
; NoteRouting_BuildByPanelMode -- 32 LE32 handler addresses, only 7 of them distinct
;
; Read by: FOUR sites, all `add XBC,0x00FC6546` -- 0xFC5495, 0xFC54E7,
;          0xFC5535, 0xFC5599.
; Evidence: all 32 entries lie in 0xFC5B26-0xFC5C6C, i.e. inside this module's
;          own code; 7 distinct values.  Counted, not eyeballed.
; ENTRY COUNT 32: 128 bytes between 0xFC6546 (four readers) and 0xFC65C6,
;          which is named as a 32-bit immediate by the reader at 0xFC5BE7
;          (`add XBC,0x00FC65C6`, e9 c8 c6 65 fc 00).  ⚠ This line said 0xFC5BE8
;          until 2026-08-25 -- one byte past the instruction, on the first byte
;          of its operand.  Found by
;          `notes/prom_a_audit_callsites.py --evidence`.
;          ★ LAST-ENTRY TEST: entry 31 is at 0xFC65C2 and the four bytes at
;          0xFC65C6 are 00 01 02 03 -- the start of an ascending byte run, not
;          an address.
; ---------------------------------------------------------------------
; NoteRouting_BuildByPanelMode: the per-mode routing builders, indexed by PanelMode (NoteRouting_Rebuild*; notes/prom_ab_read_names_2026_10_04.py)
NoteRouting_BuildByPanelMode:
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6546  [  0]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC654A  [  1]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC654E  [  2]
	.long NoteRouting_BuildForSequencerModes                                 ; FC6552  [  3]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6556  [  4]
	.long NoteRouting_BuildForSequencerModes                                 ; FC655A  [  5]
	.long NoteRouting_BuildForSequencerModes                                 ; FC655E  [  6]
	.long NoteRouting_BuildForSequencerModes                                 ; FC6562  [  7]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6566  [  8]
	.long NoteRouting_BuildForCombiEditPart                                 ; FC656A  [  9]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC656E  [ 10]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6572  [ 11]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6576  [ 12]
	.long NoteRouting_BuildForMode13                                 ; FC657A  [ 13]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC657E  [ 14]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6582  [ 15]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6586  [ 16]
	.long .LFC5C6C                                   ; FC658A  [ 17]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC658E  [ 18]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC6592  [ 19]
	.long NoteRouting_BuildForSoundCopy                                 ; FC6596  [ 20]
	.long NoteRouting_BuildForSoundCopy                                 ; FC659A  [ 21]
	.long NoteRouting_KeyboardToSelectedPart                                 ; FC659E  [ 22]
	.long NoteRouting_BuildForModes23To27                                 ; FC65A2  [ 23]
	.long NoteRouting_BuildForModes23To27                                 ; FC65A6  [ 24]
	.long NoteRouting_BuildForModes23To27                                 ; FC65AA  [ 25]
	.long NoteRouting_BuildForModes23To27                                 ; FC65AE  [ 26]
	.long NoteRouting_BuildForModes23To27                                 ; FC65B2  [ 27]
	.long .LFC5C6C                                   ; FC65B6  [ 28]
	.long .LFC5C6C                                   ; FC65BA  [ 29]
	.long .LFC5C6C                                   ; FC65BE  [ 30]
	.long .LFC5C6C                                   ; FC65C2  [ 31]
; ---------------------------------------------------------------------
; Bytes_00_to_1F_x3_FC65C6 -- 0x00..0x1F, three times over
;
; Read by: ONE site, `add XBC,0x00FC65C6` at 0xFC5BE8.
; Evidence: bytes[0:32] == bytes[32:64] == bytes[64:96] == range(32), checked
;          whole rather than at the ends.
; ENTRY COUNT 96 bytes = 3 x 32: the run of ascending 32-byte blocks stops
;          after the third, and the four bytes at 0xFC6626 are A2 76 00 00 =
;          0x000076A2, which is the first of a different table.
; ⚠ Why three identical blocks: NOT established.  A per-index table whose three
;   sections happen to be identity is what a generated table looks like when
;   nothing has been remapped yet, but nothing here shows that.
; ---------------------------------------------------------------------
Bytes_00_to_1F_x3_FC65C6:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FC65C6
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FC65D6
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FC65E6
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FC65F6
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FC6606
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FC6616
; ---------------------------------------------------------------------
; MixedTables_FC6626 -- 543 bytes, LE32 values then two short byte runs
;
; Read by: NOTHING FOUND names 0xFC6626, 0xFC6800 or 0xFC6816 -- searched over
;          prom_a and prom_b for the 3-byte little-endian address at every
;          offset, which covers `call`, `jp`, `lda`, a bare LE32 pointer and any
;          24-bit memory operand.  Every other table in this module is named by
;          at least one reader; this one is not, which is why it is one `.byte`
;          block with no entry count claimed.
; What the bytes are: 32-bit little-endian values 0x000076A2, 0x000076E2,
;          0x00007722 ... stepping by 0x40 -- the SAME family of 16-bit
;          quantities that ParamNumber_RecordPtrs (0xFACDEA, the other
;          module) holds: 16-bit WORK-RAM addresses, 0x76A2 + 0x40*k being
;          parameter number k's record.  ⚠ That is established for THAT table
;          only (see its header); what THIS block, which nothing reads, is for
;          is still open.  Interrupted by short byte
;          runs at 0xFC6800 (00 01 02 03 00 FD FE FF FB FC FD FE FF 00 01 02 03
;          04 05 06) and again at 0xFC6830, which read as small signed deltas.
; The last byte, 0xFC6844 = 0x0E, is the first byte of the module's 1980-byte
;          pad and is in this block only because notes/gen_prom_a_block.py hands
;          the first byte of a 0x0E run back to the CODE before it, and what
;          precedes this run is data.  The `.fill` is therefore 1979 bytes.
; Evidence: for the NAME, the byte content only -- LE32 values stepping by 0x40
;          interrupted by two short byte runs.  No reader names the base, so
;          "MixedTables" is deliberately the weakest name in this module and no
;          entry count is claimed.  The searched negative is checked in
;          notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
MixedTables_FC6626:
	.byte 0xa2, 0x76, 0x00, 0x00, 0xe2, 0x76, 0x00, 0x00, 0x22, 0x77, 0x00, 0x00, 0x62, 0x77, 0x00, 0x00  ; FC6626
	.byte 0xa2, 0x77, 0x00, 0x00, 0xe2, 0x77, 0x00, 0x00, 0x22, 0x78, 0x00, 0x00, 0x62, 0x78, 0x00, 0x00  ; FC6636
	.byte 0xe2, 0x78, 0x00, 0x00, 0x22, 0x79, 0x00, 0x00, 0x62, 0x79, 0x00, 0x00, 0xa2, 0x79, 0x00, 0x00  ; FC6646
	.byte 0xe2, 0x79, 0x00, 0x00, 0x22, 0x7a, 0x00, 0x00, 0x62, 0x7a, 0x00, 0x00, 0xa2, 0x7a, 0x00, 0x00  ; FC6656
	.byte 0xe2, 0x7a, 0x00, 0x00, 0x22, 0x7b, 0x00, 0x00, 0x62, 0x7b, 0x00, 0x00, 0xa2, 0x7b, 0x00, 0x00  ; FC6666
	.byte 0xe2, 0x7b, 0x00, 0x00, 0x22, 0x7c, 0x00, 0x00, 0x62, 0x7c, 0x00, 0x00, 0xa2, 0x7c, 0x00, 0x00  ; FC6676
	.byte 0xe2, 0x7c, 0x00, 0x00, 0x22, 0x7d, 0x00, 0x00, 0x62, 0x7d, 0x00, 0x00, 0xa2, 0x7d, 0x00, 0x00  ; FC6686
	.byte 0xe2, 0x7d, 0x00, 0x00, 0x22, 0x7e, 0x00, 0x00, 0x62, 0x7e, 0x00, 0x00, 0xa2, 0x7e, 0x00, 0x00  ; FC6696
	.byte 0x00, 0x01, 0x02, 0x03, 0x00, 0xfd, 0xfe, 0xff, 0xfb, 0xfc, 0xfd, 0xfe, 0xff, 0x00, 0x01, 0x02  ; FC66A6
	.byte 0x03, 0x04, 0x05, 0x06, 0x22, 0x7b, 0x00, 0x00, 0x62, 0x7b, 0x00, 0x00, 0xa2, 0x7b, 0x00, 0x00  ; FC66B6
	.byte 0xe2, 0x7b, 0x00, 0x00, 0x22, 0x7c, 0x00, 0x00, 0x62, 0x7c, 0x00, 0x00, 0xa2, 0x7c, 0x00, 0x00  ; FC66C6
	.byte 0xe2, 0x7c, 0x00, 0x00, 0x22, 0x7d, 0x00, 0x00, 0x62, 0x7d, 0x00, 0x00, 0xa2, 0x7d, 0x00, 0x00  ; FC66D6
	.byte 0xe2, 0x7d, 0x00, 0x00, 0x22, 0x7e, 0x00, 0x00, 0x62, 0x7e, 0x00, 0x00, 0xa2, 0x7e, 0x00, 0x00  ; FC66E6
	.byte 0x00, 0x01, 0x02, 0x03, 0x00, 0xfd, 0xfe, 0xff, 0xfb, 0xfc, 0xfd, 0xfe, 0xff, 0x00, 0x01, 0x02  ; FC66F6
	.byte 0x03, 0x04, 0x05, 0x06, 0xa5, 0x5c, 0xfc, 0x00, 0xa5, 0x5c, 0xfc, 0x00, 0xb5, 0x5c, 0xfc, 0x00  ; FC6706
	.byte 0xb5, 0x5c, 0xfc, 0x00, 0xb5, 0x5c, 0xfc, 0x00, 0xb5, 0x5c, 0xfc, 0x00, 0x00, 0x01, 0x02, 0x03  ; FC6716
	.byte 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13  ; FC6726
	.byte 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x00, 0x01, 0x02, 0x03  ; FC6736
	.byte 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13  ; FC6746
	.byte 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x00, 0x01, 0x02, 0x03  ; FC6756
	.byte 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13  ; FC6766
	.byte 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0xa2, 0x76, 0x00, 0x00  ; FC6776
	.byte 0xe2, 0x76, 0x00, 0x00, 0x22, 0x77, 0x00, 0x00, 0x62, 0x77, 0x00, 0x00, 0xa2, 0x77, 0x00, 0x00  ; FC6786
	.byte 0xe2, 0x77, 0x00, 0x00, 0x22, 0x78, 0x00, 0x00, 0x62, 0x78, 0x00, 0x00, 0xe2, 0x78, 0x00, 0x00  ; FC6796
	.byte 0x22, 0x79, 0x00, 0x00, 0x62, 0x79, 0x00, 0x00, 0xa2, 0x79, 0x00, 0x00, 0xe2, 0x79, 0x00, 0x00  ; FC67A6
	.byte 0x22, 0x7a, 0x00, 0x00, 0x62, 0x7a, 0x00, 0x00, 0xa2, 0x7a, 0x00, 0x00, 0xe2, 0x7a, 0x00, 0x00  ; FC67B6
	.byte 0x22, 0x7b, 0x00, 0x00, 0x62, 0x7b, 0x00, 0x00, 0xa2, 0x7b, 0x00, 0x00, 0xe2, 0x7b, 0x00, 0x00  ; FC67C6
	.byte 0x22, 0x7c, 0x00, 0x00, 0x62, 0x7c, 0x00, 0x00, 0xa2, 0x7c, 0x00, 0x00, 0xe2, 0x7c, 0x00, 0x00  ; FC67D6
	.byte 0x22, 0x7d, 0x00, 0x00, 0x62, 0x7d, 0x00, 0x00, 0xa2, 0x7d, 0x00, 0x00, 0xe2, 0x7d, 0x00, 0x00  ; FC67E6
	.byte 0x22, 0x7e, 0x00, 0x00, 0x62, 0x7e, 0x00, 0x00, 0xa2, 0x7e, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03  ; FC67F6
	.byte 0x00, 0xfd, 0xfe, 0xff, 0xfb, 0xfc, 0xfd, 0xfe, 0xff, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06  ; FC6806
	.byte 0x00, 0x00, 0x62, 0x7d, 0x00, 0x00, 0xa2, 0x7d, 0x00, 0x00, 0xe2, 0x7d, 0x00, 0x00, 0x22, 0x7e  ; FC6816
	.byte 0x00, 0x00, 0x62, 0x7e, 0x00, 0x00, 0xa2, 0x7e, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x00, 0xfd  ; FC6826
	.byte 0xfe, 0xff, 0xfb, 0xfc, 0xfd, 0xfe, 0xff, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x0e  ; FC6836

; 0xFC6845-0xFC6FFF -- 1979 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 1979, 1, 0x0E

; 0xFC7000-0xFC7FFF -- 4096 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 4096, 1, 0x0E
