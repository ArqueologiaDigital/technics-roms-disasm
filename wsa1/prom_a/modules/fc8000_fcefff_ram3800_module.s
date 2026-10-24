
; ==============================================================================
; 0xFC8000-0xFCEFFF -- the RAM-0x3800 MODULE: its own C-runtime initialiser, a
; 2,918-byte data image, and a client of seven of CPU 1's ring buffers
; ==============================================================================
;
; CHOSEN by notes/prom_a_call_graph.py --modules: T_F413B4-T_F41400 (20 slots,
; reference upper bound 52 SUMMED OVER THE MODULE -- no single slot is near it;
; the busiest is T_PartNotes_ReleaseAllTrackNotes at 11) is prom_a's third-ranked unconverted module and
; all 20 of its targets land here.  18,558 substantive bytes; the 10,113-byte 0x0E
; run that follows is emitted as `.fill` and is NOT part of that figure.
;
; ITS BOUNDS ARE THE ROM'S: 0xFC7000-0xFC7FFF is 4,096 bytes of 0x0E and
; 0xFCC87F-0xFCEFFF is 10,113 more (0xFCC87E itself is this module's own last
; `ret`).  Both are `.fill` now, not `.incbin` -- the 2026-09-01 parallel push
; retired the earlier per-round call to leave known-uniform pad as `.incbin`
; rather than "inflate a filler column for nothing": today's goal is every
; byte in real source, and source_coverage.py already reports filler and
; substantive separately, so a verified `.fill` cannot be mistaken for
; understanding.
;
; ★ IT CARRIES ITS OWN C-RUNTIME INITIALISER, and that is what makes the rest of
; the module readable.  0xFC8020 is four blocks of the shape a linker emits:
;
;     ld XBC,0x00000b66 ; and XBC,XBC ; jr Z,+
;     lda XIY,0xfcb3d3 ; lda XIX,0x003800 ; ldir      2,918 bytes of .data
;     ld XBC,0x00000000 ; and XBC,XBC ; jr Z,+
;     lda XIX,0x000000 ; xor WA,WA ; ld (XIX+),A ...  0 bytes of .bss
;     ld XBC,0x000000a0 ; and XBC,XBC ; jr Z,+
;     lda XIY,0xfcbf39 ; lda XIX,0x602054 ; ldir        160 bytes of .data
;     ld XBC,0x00000054 ; and XBC,XBC ; jr Z,+
;     lda XIX,0x602000 ; xor WA,WA ; ld (XIX+),A ...    84 bytes of .bss
;
;   The `and XBC,XBC ; jr Z` guards are the give-away: a hand-written loop does
;   not test a constant it just loaded.  So the module's RAM is 0x003800-0x004365
;   and 0x602000-0x6020F3, and its ROM data image is 0xFCB3D3-0xFCBFD8 -- both
;   read off the immediates, not guessed.  The 24-bit RAM addresses this module
;   names most often (0x602493 twenty times, 0x602492 seven, 0x602498 six,
;   0x6022BD six) are consistent with the second image but lie past its end, so
;   they are .bss the initialiser does not clear or a neighbour's.
;
; ★ AND IT PUBLISHES A SECOND, SHORTER COPY OF THAT INITIALISER.  0xFC807D is
;   byte-identical to 0xFC8020 over 46 bytes -- exactly the .data-image and the
;   empty-.bss blocks -- and then returns instead of going on to the 0x602054
;   pair.  46 is maximal: byte 47 is 0x41 there and 0x0E here.  It is the SHORT
;   copy that the directory publishes -- as T_Ram3800_InitDataImage (T_F413D0) -- while 0xFC8020, the full
;   one, is reached only by `calr` from the module's own entry.  So a caller can
;   reset the 0x3800 image WITHOUT touching 0x602000.
;   ⚠ Corrected before it shipped: this paragraph first said T_MidiInA_ProcessRing and called
;   it the module's highest reference count.  T_MidiInA_ProcessRing is the module's FIRST
;   slot and it targets 0xFC80E2; T_Ram3800_InitDataImage (T_F413D0) is the one that targets 0xFC807D, and
;   its reference upper bound is 1.  The module's busiest single slot is
;   T_PartNotes_ReleaseAllTrackNotes at 11, targeting 0xFC8CE0.  52 is the module TOTAL, which is what
;   `--modules` ranks by.
;
; WHAT IT TALKS TO.  Every external call is through the prom_b directory, and
; all but three targets are already converted in this file, so they can be named
; rather than guessed:
;
;   T_TimedEventRing_ScanRewind (T_F41D74)/T_TimedEventRing_Scan (T_F41D78)  TimedEventRing_ScanRewind / _Scan       1 + 5 calls
;   T_SeqBufRing_PutBlock (T_F41D8C)           SeqBufRing_PutBlock                 1
;   T_MidiInARing_ScanRewind (T_F41DBC)/T_MidiInARing_Scan (T_F41DC0)  MidiInARing_ScanRewind / _Scan       1 + 3
;   T_MidiInBRing_ScanRewind (T_F41DE0)/T_MidiInBRing_Scan (T_F41DE4)  MidiInBRing_ScanRewind / _Scan       1 + 3
;   T_Ring601432_PutBlock (T_F41DF8)           Ring601432_PutBlock                 3
;   T_Ring60153C_PutBlock (T_F41E1C)           Ring60153C_PutBlock                 3
;   T_Ring601850_Get (T_F41E5C)           Ring601850_Get                      2
;   T_MIDI_PostSendWork (T_F40724)           MIDI_PostSendWork (prom_a 0xFA590F)  3
;   T_Link_SendBlockIn32ByteChunks           prom_a 0xF8E02C, the 0x7C0000 link block sender  10
;   T_Queue2E00_AppendRegs (T_F40F3C)           prom_a 0xF86AA3, still `.incbin`     1
;
;   Seven distinct ring instances, three of them scanned (non-consuming reads)
;   and three written by block -- the shape of something that PARSES one stream
;   and EMITS into others.  With MIDI_PostSendWork and the link sender beside
;   them, this module sits between CPU 1's ring layer and CPU 2.
;
; WHAT IS **NOT** ESTABLISHED, and is left as `sub_XXXXXX` on purpose:
;   * ~~what the 2,918-byte image at 0x003800 contains~~ -- ESTABLISHED
;     2026-09-25: the module indexes it with literal strides of 13 and 15, and
;     the layout (budgets, queue/list heads, node pools) is in its own header,
;     Ram3800_DataImage below.  The 160-byte image at 0x602054 likewise.
;   * which ring carries what.  The names above are the ring OBJECTS' names,
;     from notes/FINDINGS-prom_a-ring-buffers.md; they say which RAM object is
;     touched, not what travels through it.
;   * the module's own purpose.  The prefix `Ram3800_` is address-derived on
;     purpose.
;
; ⚠ ONE BYTE IS NOT ACCOUNTED FOR.  0xFCC06A, the byte immediately after
; Ram3800_RecordPtrTable, is 0xEE, and 0xEE is the XIZ prefix of the 32-bit
; register group -- `EE 02` is not an instruction unidasm can decode.  The
; listing therefore resumes code at 0xFCC06B, from where the decode is clean all
; the way to the pad and every in-span `call` target is a boundary of it.  ⚠ But
; 0xFCC06B is NOT PINNED as the start: decodes begun at 0xFCC06C, 0xFCC06E and
; 0xFCC070 resynchronise and are equally clean, and no site in prom_a or prom_b
; names any address in 0xFCC06A-0xFCC880 except the four in-span `call`s -- two
; targets, 0xFCC502 and 0xFCC573, each called twice.  (The reference scan also
; returns one site OUTSIDE, a `calr` at 0xFC61C4 reaching 0xFCC1FB; 0xFC61C4 is
; not an instruction -- it is the second byte of `ldw_da bc,(0x60341e)` at
; 0xFC61C3, already converted in this file -- so it is an opcode coincidence and
; is recorded as one rather than left out.)  The byte gate is indifferent --
; whatever is decoded is re-assembled -- but a reader should not take 0xFCC06B
; for a routine entry.
; ---------------------------------------------------------------------
; Ram3800_Start_Entry -- a PURE WRAPPER for Ram3800_Start: it IS that
; routine, so it is named for it.  Its whole extent is
; a single unconditional `jp`, which cannot fall through,
; so the routine is that one instruction.
; Evidence: the `jp` at 0xFC8000 targets 0xFC8018, which carries the
;          label Ram3800_Start.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Ram3800_Start_Entry:
	jp Ram3800_Start                                     ; FC8000  1b 18 80 fc
	ret                                                  ; FC8004  0e
	nop                                                  ; FC8005  00
	nop                                                  ; FC8006  00
	nop                                                  ; FC8007  00
	ret                                                  ; FC8008  0e
	nop                                                  ; FC8009  00
	nop                                                  ; FC800A  00
	nop                                                  ; FC800B  00
	ret                                                  ; FC800C  0e
	nop                                                  ; FC800D  00
	nop                                                  ; FC800E  00
	nop                                                  ; FC800F  00
	ret                                                  ; FC8010  0e
	nop                                                  ; FC8011  00
	nop                                                  ; FC8012  00
	nop                                                  ; FC8013  00
	ret                                                  ; FC8014  0e
	nop                                                  ; FC8015  00
	nop                                                  ; FC8016  00
	nop                                                  ; FC8017  00
; ---------------------------------------------------------------------
; Ram3800_Start -- initialise, then run
;
; Called from: the module's own entry veneer at 0xFC8000 (`jp 0xFC8018`).  It is
;          the ONLY live slot of the six 4-byte entries at 0xFC8000: the other
;          five are `ret` followed by three 0x00.
; Inputs:  none.  Outputs: none of its own.
; Evidence: the whole routine is `calr 0xfc8020 / call 0xfc80e1 / ret`.
; Unknown: what 0xFC80E1 is; it keeps its address label.
; ---------------------------------------------------------------------
Ram3800_Start:
	calr Ram3800_InitAll                                 ; FC8018  1e 05 00
	call Ram3800_Start_Nop                                      ; FC801B  1d e1 80 fc
	ret                                                  ; FC801F  0e
; ---------------------------------------------------------------------
; Ram3800_InitAll -- the module's C-runtime initialiser, all four blocks
;
; Called from: Ram3800_Start, by `calr`, and nothing else.
; Inputs:  none.
; Outputs: RAM 0x003800-0x004365 loaded from ROM 0xFCB3D3; RAM 0x602054-0x6020F3
;          loaded from ROM 0xFCBF39; RAM 0x602000-0x602053 zeroed.  The third
;          block, a zero-fill at address 0, has length 0 and is skipped by its
;          own guard.
; Evidence: the four blocks are quoted in the module header above; every length,
;          source and destination is a literal operand of an `ld XBC,imm32` or
;          `lda XIY/XIX,imm`, and each block is guarded by `and XBC,XBC / jr Z`
;          over the constant it just loaded.  All twelve immediates are checks
;          in notes/prom_a_fc8000_module_check.py.
; Unknown: why the third block exists with a length of zero.  A linker that
;          emits the block unconditionally and fills in a computed size is the
;          obvious reading, and it is a reading, not evidence.
; ---------------------------------------------------------------------
Ram3800_InitAll:
	ld XBC,0x00000b66                                    ; FC8020  41 66 0b 00 00
	and XBC,XBC                                          ; FC8025  e9 c1
	jr z, .LFC8035                                       ; FC8027  66 0c
	lda xiy, (Ram3800_DataImage:24)                      ; FC8029  f2 d3 b3 fc 35
	lda xix, (PartNote_Budget:24)                                 ; FC802E  f2 00 38 00 34
	ldir85                                               ; FC8033  85 11
.LFC8035:
	ld XBC,0x00000000                                    ; FC8035  41 00 00 00 00
	and XBC,XBC                                          ; FC803A  e9 c1
	jr z, .LFC804E                                       ; FC803C  66 10
	lda xix, (0x00:24)                                   ; FC803E  f2 00 00 00 34
	xor WA,WA                                            ; FC8043  d8 d0
.LFC8045:
	ld (xix+), a                                    ; FC8045  f5 f0 41
	sub BC,0x0001                                        ; FC8048  d9 ca 01 00
	jr nz, .LFC8045                                      ; FC804C  6e f7
.LFC804E:
	ld XBC,0x000000a0                                    ; FC804E  41 a0 00 00 00
	and XBC,XBC                                          ; FC8053  e9 c1
	jr z, .LFC8063                                       ; FC8055  66 0c
	lda xiy, (Ram602054_DataImage:24)                    ; FC8057  f2 39 bf fc 35
	lda xix, (Part_VoiceMasks:24)                               ; FC805C  f2 54 20 60 34
	ldir85                                               ; FC8061  85 11
.LFC8063:
	ld XBC,0x00000054                                    ; FC8063  41 54 00 00 00
	and XBC,XBC                                          ; FC8068  e9 c1
	jr z, .LFC807C                                       ; FC806A  66 10
	lda xix, (NoteSend_MsgBuffer:24)                               ; FC806C  f2 00 20 60 34
	xor WA,WA                                            ; FC8071  d8 d0
.LFC8073:
	ld (xix+), a                                    ; FC8073  f5 f0 41
	sub BC,0x0001                                        ; FC8076  d9 ca 01 00
	jr nz, .LFC8073                                      ; FC807A  6e f7
.LFC807C:
	ret                                                  ; FC807C  0e
; ---------------------------------------------------------------------
; Ram3800_InitDataImage -- reload the 0x3800 image only, and return
;
; Called from: directory slot T_Ram3800_InitDataImage (T_F413D0) (reference upper bound 1).  ⚠ NOT
;          T_MidiInA_ProcessRing, which is this module's first slot and targets 0xFC80E2;
;          and 52 is the whole module's summed bound, not this entry's.
; Inputs:  none.  Outputs: RAM 0x003800-0x004365 reloaded from ROM 0xFCB3D3.
; Evidence: byte-identical to Ram3800_InitAll over 46 bytes and no further --
;          byte 47 is 0x41 (`ld XBC,0x000000a0`, the next block) there and 0x0E
;          (`ret`) here.  Both figures are checked.
; Unknown: who calls it and when.  T_MidiInA_ProcessRing's 52 is an opcode-anchored upper
;          bound, not a call count.
; ---------------------------------------------------------------------
Ram3800_InitDataImage:
	ld XBC,0x00000b66                                    ; FC807D  41 66 0b 00 00
	and XBC,XBC                                          ; FC8082  e9 c1
	jr z, .LFC8092                                       ; FC8084  66 0c
	lda xiy, (Ram3800_DataImage:24)                      ; FC8086  f2 d3 b3 fc 35
	lda xix, (PartNote_Budget:24)                                 ; FC808B  f2 00 38 00 34
	ldir85                                               ; FC8090  85 11
.LFC8092:
	ld XBC,0x00000000                                    ; FC8092  41 00 00 00 00
	and XBC,XBC                                          ; FC8097  e9 c1
	jr z, .LFC80AB                                       ; FC8099  66 10
	lda xix, (0x00:24)                                   ; FC809B  f2 00 00 00 34
	xor WA,WA                                            ; FC80A0  d8 d0
.LFC80A2:
	ld (xix+), a                                    ; FC80A2  f5 f0 41
	sub BC,0x0001                                        ; FC80A5  d9 ca 01 00
	jr nz, .LFC80A2                                      ; FC80A9  6e f7
.LFC80AB:
	ret                                                  ; FC80AB  0e
; SeqRecord_StartOnFirstEvent_SaveRegs: Saves XIX / XIZ / XHL / XDE around T_SeqRecord_StartOnFirstEvent and returns.
;   Called by PartFrame_RecordToSeqBuf after T_SeqBuf_FlushStaged. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
SeqRecord_StartOnFirstEvent_SaveRegs:
	push XIX                                             ; FC80AC  3c
	push XIZ                                             ; FC80AD  3e
	push XHL                                             ; FC80AE  3b
	push XDE                                             ; FC80AF  3a
	call T_SeqRecord_StartOnFirstEvent                                        ; FC80B0  1d 24 0a f4
	pop XDE                                              ; FC80B4  5a
	pop XHL                                              ; FC80B5  5b
	pop XIZ                                              ; FC80B6  5e
	pop XIX                                              ; FC80B7  5c
	ret                                                  ; FC80B8  0e
	push XIZ                                             ; FC80B9  3e
	ld XIZ,XSP                                           ; FC80BA  ef 8e
	push XIX                                             ; FC80BC  3c
	push XHL                                             ; FC80BD  3b
	push XDE                                             ; FC80BE  3a
	ld BC,(XIZ+0x08)                                     ; FC80BF  9e 08 21
	ld E,C                                               ; FC80C2  cb 8d
	ld BC,(XIZ+0x0a)                                     ; FC80C4  9e 0a 21
	ld D,C                                               ; FC80C7  cb 8c
	ld BC,(XIZ+0x0c)                                     ; FC80C9  9e 0c 21
	ld A,C                                               ; FC80CC  cb 89
	ld BC,(XIZ+0x0e)                                     ; FC80CE  9e 0e 21
	ld W,C                                               ; FC80D1  cb 88
	call T_Queue2E00_AppendRegs                          ; FC80D3  1d 3c 0f f4
	pop XDE                                              ; FC80D7  5a
	pop XHL                                              ; FC80D8  5b
	pop XIX                                              ; FC80D9  5c
	pop XIZ                                              ; FC80DA  5e
	ret                                                  ; FC80DB  0e
T_F413E4_Nop:
	ret                                                  ; FC80DC  0e
T_F413E8_Nop:
	ret                                                  ; FC80DD  0e
T_F413EC_Nop:
	ret                                                  ; FC80DE  0e
T_F413F0_Nop:
	ret                                                  ; FC80DF  0e
T_F413F4_Nop:
	ret                                                  ; FC80E0  0e
Ram3800_Start_Nop:
	ret                                                  ; FC80E1  0e
; MidiInA_ProcessRing: T_MidiInA_ProcessRing: T_MidiInARing_ScanRewind, then MidiInA_GatherFrame in a loop; a 0x90 frame through the note stages
;   (MidiFrame_ToNoteFrame, NoteList_ApplyFrame, NoteFrame_SelectForPart ...), a 0xB0 frame through the control-change path.
MidiInA_ProcessRing:
	link XIZ,0xfd2c                                      ; FC80E2  ee 0c 2c fd
	pushw hl                                             ; FC80E6  2b
	pushw de                                             ; FC80E7  2a
	push XIX                                             ; FC80E8  3c
	call T_MidiInARing_ScanRewind                         ; FC80E9  1d bc 1d f4
	ld (xiz-6), 0x00                                     ; FC80ED  be fa 00 00
.LFC80F1:
	lda xbc, (xiz-302)                                   ; FC80F1  f3 f9 d2 fe 31
	push XBC                                             ; FC80F6  39
	lda xwa, (xiz-6)                                     ; FC80F7  be fa 30
	push XWA                                             ; FC80FA  38
	call MidiInA_GatherFrame                                      ; FC80FB  1d 5c 91 fc
	inc 8,XSP                                            ; FC80FF  ef 60
	cp a, 0x00:i3                                          ; FC8101  c9 d8
	jrl z, .LFC8442                                      ; FC8103  76 3c 03
	ld c, (xiz-301)                                      ; FC8106  c3 f9 d3 fe 23
	extz BC                                              ; FC810B  d9 12
	cp BC,0x0090                                         ; FC810D  d9 cf 90 00
	jr z, .LFC811C                                       ; FC8111  66 09
	cp BC,0x00b0                                         ; FC8113  d9 cf b0 00
	jrl z, .LFC82B7                                      ; FC8117  76 9d 01
	jr .LFC80F1                                          ; FC811A  68 d5
.LFC811C:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC811C  c2 93 24 60 23
	and C,0xc0                                           ; FC8121  cb cc c0
	srl c, 0x06                                          ; FC8124  cb ef 06
	cp c, 0x01:i3                                          ; FC8127  cb d9
	jr nz, .LFC8139                                      ; FC8129  6e 0e
	ld h, (xiz-299)                                      ; FC812B  c3 f9 d5 fe 26
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC8130  c2 92 24 60 23
	cp C,H                                               ; FC8135  ce f3
	jr z, .LFC8149                                       ; FC8137  66 10
.LFC8139:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC8139  c2 93 24 60 23
	and C,0xc0                                           ; FC813E  cb cc c0
	srl c, 0x06                                          ; FC8141  cb ef 06
	cp c, 0x02:i3                                          ; FC8144  cb da
	jrl nz, .LFC8222                                     ; FC8146  7e d9 00
.LFC8149:
	lda xbc, (xiz-416)                                   ; FC8149  f3 f9 60 fe 31
	push XBC                                             ; FC814E  39
	lda xwa, (xiz-302)                                   ; FC814F  f3 f9 d2 fe 30
	push XWA                                             ; FC8154  38
	call MidiFrame_ToNoteFrame                                      ; FC8155  1d 69 b2 fc
	lda xbc, (NoteRouting:24)                               ; FC8159  f2 00 22 60 31
	push XBC                                             ; FC815E  39
	lda xwa, (xiz-416)                                   ; FC815F  f3 f9 60 fe 30
	push XWA                                             ; FC8164  38
	call NoteList_ApplyFrame                                      ; FC8165  1d 1d 9c fc
	ld XIX,XIY                                           ; FC8169  ed 8c
	ld d, 0x00:opc                                          ; FC816B  24 00
	inc 8,XSP                                            ; FC816D  ef 60
	inc 8,XSP                                            ; FC816F  ef 60
.LFC8171:
	ld XBC,XIX                                           ; FC8171  ec 89
	or XBC,XBC                                           ; FC8173  e9 e1
	jrl z, .LFC80F1                                      ; FC8175  76 79 ff
	and XBC,0x00000001                                   ; FC8178  e9 cc 01 00 00 00
	jrl z, .LFC8210                                      ; FC817E  76 8f 00
	push 0x00                                            ; FC8181  09 00
	push D                                               ; FC8183  cc 04
	lda xbc, (NoteRouting:24)                               ; FC8185  f2 00 22 60 31
	push XBC                                             ; FC818A  39
	lda xwa, (xiz-416)                                   ; FC818B  f3 f9 60 fe 30
	push XWA                                             ; FC8190  38
	lda xiy, (xiz-712)                                   ; FC8191  f3 f9 38 fd 35
	push XIY                                             ; FC8196  3d
	call NoteFrame_SelectForPart                                      ; FC8197  1d a3 9e fc
	inc 8,XSP                                            ; FC819B  ef 60
	inc 6,XSP                                            ; FC819D  ef 66
	cp a, 0x00:i3                                          ; FC819F  c9 d8
	jr z, .LFC8210                                       ; FC81A1  66 6d
	push 0x00                                            ; FC81A3  09 00
	push D                                               ; FC81A5  cc 04
	lda xbc, (NoteRouting:24)                               ; FC81A7  f2 00 22 60 31
	push XBC                                             ; FC81AC  39
	lda xwa, (xiz-724)                                   ; FC81AD  f3 f9 2c fd 30
	push XWA                                             ; FC81B2  38
	call NoteRouting_ForPartFromMidiIn                                      ; FC81B3  1d c9 af fc
	push 0x00                                            ; FC81B7  09 00
	push D                                               ; FC81B9  cc 04
	lda xbc, (xiz-724)                                   ; FC81BB  f3 f9 2c fd 31
	push XBC                                             ; FC81C0  39
	lda xwa, (xiz-712)                                   ; FC81C1  f3 f9 38 fd 30
	push XWA                                             ; FC81C6  38
	call PartNotes_ApplyFrame                                      ; FC81C7  1d 8b 9f fc
	ld E,A                                               ; FC81CB  c9 8d
	and A,0x01                                           ; FC81CD  c9 cc 01
	add XSP,0x00000014                                   ; FC81D0  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC81D6  c9 d8
	jr z, .LFC81E5                                       ; FC81D8  66 0b
	lda xbc, (xiz-712)                                   ; FC81DA  f3 f9 38 fd 31
	push XBC                                             ; FC81DF  39
	call PartFrame_SendToToneGen                                      ; FC81E0  1d bb a6 fc
	pop XIY                                              ; FC81E4  5d
.LFC81E5:
	ld C,E                                               ; FC81E5  cd 8b
	and C,0x02                                           ; FC81E7  cb cc 02
	jr z, .LFC81FE                                       ; FC81EA  66 12
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC81EC  f2 93 24 60 cd
	jr nz, .LFC81FE                                      ; FC81F1  6e 0b
	lda xbc, (xiz-712)                                   ; FC81F3  f3 f9 38 fd 31
	push XBC                                             ; FC81F8  39
	call PartFrame_SendToMidiOut                                      ; FC81F9  1d 98 aa fc
	pop XIY                                              ; FC81FD  5d
.LFC81FE:
	ld C,E                                               ; FC81FE  cd 8b
	and C,0x04                                           ; FC8200  cb cc 04
	jr z, .LFC8210                                       ; FC8203  66 0b
	lda xbc, (xiz-712)                                   ; FC8205  f3 f9 38 fd 31
	push XBC                                             ; FC820A  39
	call PartFrame_RecordToSeqBuf                                      ; FC820B  1d aa ac fc
	pop XIY                                              ; FC820F  5d
.LFC8210:
	inc 1,D                                              ; FC8210  cc 61
	ld XIY,XIX                                           ; FC8212  ec 8d
	srl xiy, 0x01                                        ; FC8214  ed ef 01
	ld XIX,XIY                                           ; FC8217  ed 8c
	cp D,0x20                                            ; FC8219  cc cf 20
	jrl c, .LFC8171                                      ; FC821C  77 52 ff
	jrl .LFC80F1                                         ; FC821F  78 cf fe
.LFC8222:
	ld d, 0x00:opc                                          ; FC8222  24 00
	ld XIX,0x00000022                                    ; FC8224  44 22 00 00 00
	ldw hl, 0x00                                         ; FC8229  33 00 00
.LFC822C:
	lda xbc, (NoteRouting:24)                               ; FC822C  f2 00 22 60 31
	add XBC,XIX                                          ; FC8231  ec 81
	ld E,(XBC)                                           ; FC8233  81 25
	ld a, (xiz-299)                                      ; FC8235  c3 f9 d5 fe 21
	cp E,A                                               ; FC823A  c9 f5
	jr nz, .LFC82A6                                      ; FC823C  6e 68
	ld BC,HL                                             ; FC823E  db 89
	extz XBC                                             ; FC8240  e9 12
	add XBC,0x00000152                                   ; FC8242  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC8248  e9 c8 00 22 60 00
	bit 6,(XBC)                                          ; FC824E  b1 ce
	jr z, .LFC82A6                                       ; FC8250  66 54
	push 0x00                                            ; FC8252  09 00
	push D                                               ; FC8254  cc 04
	lda xbc, (NoteRouting:24)                               ; FC8256  f2 00 22 60 31
	push XBC                                             ; FC825B  39
	lda xwa, (xiz-724)                                   ; FC825C  f3 f9 2c fd 30
	push XWA                                             ; FC8261  38
	call NoteRouting_ForReceivingPart                                      ; FC8262  1d 26 b1 fc
	push 0x00                                            ; FC8266  09 00
	push D                                               ; FC8268  cc 04
	lda xbc, (xiz-724)                                   ; FC826A  f3 f9 2c fd 31
	push XBC                                             ; FC826F  39
	lda xwa, (xiz-302)                                   ; FC8270  f3 f9 d2 fe 30
	push XWA                                             ; FC8275  38
	call PartNotes_ApplyFrame                                      ; FC8276  1d 8b 9f fc
	ld E,A                                               ; FC827A  c9 8d
	and A,0x01                                           ; FC827C  c9 cc 01
	add XSP,0x00000014                                   ; FC827F  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC8285  c9 d8
	jr z, .LFC8294                                       ; FC8287  66 0b
	lda xbc, (xiz-302)                                   ; FC8289  f3 f9 d2 fe 31
	push XBC                                             ; FC828E  39
	call PartFrame_SendToToneGen                                      ; FC828F  1d bb a6 fc
	pop XIY                                              ; FC8293  5d
.LFC8294:
	ld C,E                                               ; FC8294  cd 8b
	and C,0x04                                           ; FC8296  cb cc 04
	jr z, .LFC82A6                                       ; FC8299  66 0b
	lda xbc, (xiz-302)                                   ; FC829B  f3 f9 d2 fe 31
	push XBC                                             ; FC82A0  39
	call PartFrame_RecordToSeqBuf                                      ; FC82A1  1d aa ac fc
	pop XIY                                              ; FC82A5  5d
.LFC82A6:
	inc 1,XIX                                            ; FC82A6  ec 61
	add HL,0x000a                                        ; FC82A8  db c8 0a 00
	inc 1,D                                              ; FC82AC  cc 61
	cp D,0x20                                            ; FC82AE  cc cf 20
	jrl c, .LFC822C                                      ; FC82B1  77 78 ff
	jrl .LFC80F1                                         ; FC82B4  78 3a fe
.LFC82B7:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC82B7  c2 93 24 60 23
	and C,0xc0                                           ; FC82BC  cb cc c0
	srl c, 0x06                                          ; FC82BF  cb ef 06
	cp c, 0x01:i3                                          ; FC82C2  cb d9
	jr nz, .LFC82D4                                      ; FC82C4  6e 0e
	ld h, (xiz-299)                                      ; FC82C6  c3 f9 d5 fe 26
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC82CB  c2 92 24 60 23
	cp C,H                                               ; FC82D0  ce f3
	jr z, .LFC82E4                                       ; FC82D2  66 10
.LFC82D4:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC82D4  c2 93 24 60 23
	and C,0xc0                                           ; FC82D9  cb cc c0
	srl c, 0x06                                          ; FC82DC  cb ef 06
	cp c, 0x02:i3                                          ; FC82DF  cb da
	jrl nz, .LFC83BB                                     ; FC82E1  7e d7 00
.LFC82E4:
	lda xbc, (xiz-416)                                   ; FC82E4  f3 f9 60 fe 31
	push XBC                                             ; FC82E9  39
	lda xwa, (xiz-302)                                   ; FC82EA  f3 f9 d2 fe 30
	push XWA                                             ; FC82EF  38
	call MidiFrame_ToNoteFrame                                      ; FC82F0  1d 69 b2 fc
	lda xbc, (xiz-416)                                   ; FC82F4  f3 f9 60 fe 31
	push XBC                                             ; FC82F9  39
	call NoteList_BuildReleaseAllFrame                                      ; FC82FA  1d 46 9e fc
	extz WA                                              ; FC82FE  d8 12
	extz XWA                                             ; FC8300  e8 12
	ld XIX,XWA                                           ; FC8302  e8 8c
	ld d, 0x00:opc                                          ; FC8304  24 00
	inc 8,XSP                                            ; FC8306  ef 60
	inc 4,XSP                                            ; FC8308  ef 64
.LFC830A:
	ld XBC,XIX                                           ; FC830A  ec 89
	or XBC,XBC                                           ; FC830C  e9 e1
	jrl z, .LFC80F1                                      ; FC830E  76 e0 fd
	and XBC,0x00000001                                   ; FC8311  e9 cc 01 00 00 00
	jrl z, .LFC83A9                                      ; FC8317  76 8f 00
	push 0x00                                            ; FC831A  09 00
	push D                                               ; FC831C  cc 04
	lda xbc, (NoteRouting:24)                               ; FC831E  f2 00 22 60 31
	push XBC                                             ; FC8323  39
	lda xwa, (xiz-416)                                   ; FC8324  f3 f9 60 fe 30
	push XWA                                             ; FC8329  38
	lda xiy, (xiz-712)                                   ; FC832A  f3 f9 38 fd 35
	push XIY                                             ; FC832F  3d
	call NoteFrame_SelectForPart                                      ; FC8330  1d a3 9e fc
	inc 8,XSP                                            ; FC8334  ef 60
	inc 6,XSP                                            ; FC8336  ef 66
	cp a, 0x00:i3                                          ; FC8338  c9 d8
	jr z, .LFC83A9                                       ; FC833A  66 6d
	push 0x00                                            ; FC833C  09 00
	push D                                               ; FC833E  cc 04
	lda xbc, (NoteRouting:24)                               ; FC8340  f2 00 22 60 31
	push XBC                                             ; FC8345  39
	lda xwa, (xiz-724)                                   ; FC8346  f3 f9 2c fd 30
	push XWA                                             ; FC834B  38
	call NoteRouting_ForPartFromMidiIn                                      ; FC834C  1d c9 af fc
	push 0x00                                            ; FC8350  09 00
	push D                                               ; FC8352  cc 04
	lda xbc, (xiz-724)                                   ; FC8354  f3 f9 2c fd 31
	push XBC                                             ; FC8359  39
	lda xwa, (xiz-712)                                   ; FC835A  f3 f9 38 fd 30
	push XWA                                             ; FC835F  38
	call PartNotes_ApplyFrame                                      ; FC8360  1d 8b 9f fc
	ld E,A                                               ; FC8364  c9 8d
	and A,0x01                                           ; FC8366  c9 cc 01
	add XSP,0x00000014                                   ; FC8369  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC836F  c9 d8
	jr z, .LFC837E                                       ; FC8371  66 0b
	lda xbc, (xiz-712)                                   ; FC8373  f3 f9 38 fd 31
	push XBC                                             ; FC8378  39
	call PartFrame_SendToToneGen                                      ; FC8379  1d bb a6 fc
	pop XIY                                              ; FC837D  5d
.LFC837E:
	ld C,E                                               ; FC837E  cd 8b
	and C,0x02                                           ; FC8380  cb cc 02
	jr z, .LFC8397                                       ; FC8383  66 12
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC8385  f2 93 24 60 cd
	jr nz, .LFC8397                                      ; FC838A  6e 0b
	lda xbc, (xiz-712)                                   ; FC838C  f3 f9 38 fd 31
	push XBC                                             ; FC8391  39
	call PartFrame_SendToMidiOut                                      ; FC8392  1d 98 aa fc
	pop XIY                                              ; FC8396  5d
.LFC8397:
	ld C,E                                               ; FC8397  cd 8b
	and C,0x04                                           ; FC8399  cb cc 04
	jr z, .LFC83A9                                       ; FC839C  66 0b
	lda xbc, (xiz-712)                                   ; FC839E  f3 f9 38 fd 31
	push XBC                                             ; FC83A3  39
	call PartFrame_RecordToSeqBuf                                      ; FC83A4  1d aa ac fc
	pop XIY                                              ; FC83A8  5d
.LFC83A9:
	inc 1,D                                              ; FC83A9  cc 61
	ld XIY,XIX                                           ; FC83AB  ec 8d
	srl xiy, 0x01                                        ; FC83AD  ed ef 01
	ld XIX,XIY                                           ; FC83B0  ed 8c
	cp D,0x20                                            ; FC83B2  cc cf 20
	jrl c, .LFC830A                                      ; FC83B5  77 52 ff
	jrl .LFC80F1                                         ; FC83B8  78 36 fd
.LFC83BB:
	ld d, 0x00:opc                                          ; FC83BB  24 00
	ld (xiz-302), 0x00                                   ; FC83BD  f3 f9 d2 fe 00 00
	ld XIX,0x00000022                                    ; FC83C3  44 22 00 00 00
	ldw hl, 0x00                                         ; FC83C8  33 00 00
.LFC83CB:
	lda xbc, (NoteRouting:24)                               ; FC83CB  f2 00 22 60 31
	add XBC,XIX                                          ; FC83D0  ec 81
	ld E,(XBC)                                           ; FC83D2  81 25
	ld a, (xiz-299)                                      ; FC83D4  c3 f9 d5 fe 21
	cp E,A                                               ; FC83D9  c9 f5
	jr nz, .LFC842C                                      ; FC83DB  6e 4f
	ld BC,HL                                             ; FC83DD  db 89
	extz XBC                                             ; FC83DF  e9 12
	add XBC,0x00000152                                   ; FC83E1  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC83E7  e9 c8 00 22 60 00
	bit 6,(XBC)                                          ; FC83ED  b1 ce
	jr z, .LFC842C                                       ; FC83EF  66 3b
	push 0x00                                            ; FC83F1  09 00
	push D                                               ; FC83F3  cc 04
	pushw 0x07                                           ; FC83F5  0b 07 00
	lda xbc, (xiz-302)                                   ; FC83F8  f3 f9 d2 fe 31
	push XBC                                             ; FC83FD  39
	call PartNotes_BuildReleaseFrame                                      ; FC83FE  1d 75 a4 fc
	ld E,A                                               ; FC8402  c9 8d
	inc 8,XSP                                            ; FC8404  ef 60
	cp a, 0x00:i3                                          ; FC8406  c9 d8
	jr z, .LFC842C                                       ; FC8408  66 22
	and A,0x01                                           ; FC840A  c9 cc 01
	jr z, .LFC841A                                       ; FC840D  66 0b
	lda xbc, (xiz-302)                                   ; FC840F  f3 f9 d2 fe 31
	push XBC                                             ; FC8414  39
	call PartFrame_SendToToneGen                                      ; FC8415  1d bb a6 fc
	pop XIY                                              ; FC8419  5d
.LFC841A:
	ld C,E                                               ; FC841A  cd 8b
	and C,0x04                                           ; FC841C  cb cc 04
	jr z, .LFC842C                                       ; FC841F  66 0b
	lda xbc, (xiz-302)                                   ; FC8421  f3 f9 d2 fe 31
	push XBC                                             ; FC8426  39
	call PartFrame_RecordToSeqBuf                                      ; FC8427  1d aa ac fc
	pop XIY                                              ; FC842B  5d
.LFC842C:
	inc 1,XIX                                            ; FC842C  ec 61
	add HL,0x000a                                        ; FC842E  db c8 0a 00
	inc 1,D                                              ; FC8432  cc 61
	ld (xiz-302), 0x00                                   ; FC8434  f3 f9 d2 fe 00 00
	cp D,0x20                                            ; FC843A  cc cf 20
	jr c, .LFC83CB                                       ; FC843D  67 8c
	jrl .LFC80F1                                         ; FC843F  78 af fc
.LFC8442:
	pop XIX                                              ; FC8442  5c
	popw de                                              ; FC8443  4a
	popw hl                                              ; FC8444  4b
	unlk XIZ                                             ; FC8445  ee 0d
	ret                                                  ; FC8447  0e
; MidiInB_ProcessRing: the same for MIDI IN B (T_MidiInBRing_ScanRewind, MidiInB_GatherFrame).
MidiInB_ProcessRing:
	link XIZ,0xfd2c                                      ; FC8448  ee 0c 2c fd
	pushw hl                                             ; FC844C  2b
	pushw de                                             ; FC844D  2a
	push XIX                                             ; FC844E  3c
	call T_MidiInBRing_ScanRewind                         ; FC844F  1d e0 1d f4
	ld (xiz-6), 0x00                                     ; FC8453  be fa 00 00
.LFC8457:
	lda xbc, (xiz-302)                                   ; FC8457  f3 f9 d2 fe 31
	push XBC                                             ; FC845C  39
	lda xwa, (xiz-6)                                     ; FC845D  be fa 30
	push XWA                                             ; FC8460  38
	call MidiInB_GatherFrame                                      ; FC8461  1d 43 93 fc
	inc 8,XSP                                            ; FC8465  ef 60
	cp a, 0x00:i3                                          ; FC8467  c9 d8
	jrl z, .LFC87A8                                      ; FC8469  76 3c 03
	ld c, (xiz-301)                                      ; FC846C  c3 f9 d3 fe 23
	extz BC                                              ; FC8471  d9 12
	cp BC,0x0090                                         ; FC8473  d9 cf 90 00
	jr z, .LFC8482                                       ; FC8477  66 09
	cp BC,0x00b0                                         ; FC8479  d9 cf b0 00
	jrl z, .LFC861D                                      ; FC847D  76 9d 01
	jr .LFC8457                                          ; FC8480  68 d5
.LFC8482:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC8482  c2 93 24 60 23
	and C,0xc0                                           ; FC8487  cb cc c0
	srl c, 0x06                                          ; FC848A  cb ef 06
	cp c, 0x01:i3                                          ; FC848D  cb d9
	jr nz, .LFC849F                                      ; FC848F  6e 0e
	ld h, (xiz-299)                                      ; FC8491  c3 f9 d5 fe 26
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC8496  c2 92 24 60 23
	cp C,H                                               ; FC849B  ce f3
	jr z, .LFC84AF                                       ; FC849D  66 10
.LFC849F:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC849F  c2 93 24 60 23
	and C,0xc0                                           ; FC84A4  cb cc c0
	srl c, 0x06                                          ; FC84A7  cb ef 06
	cp c, 0x02:i3                                          ; FC84AA  cb da
	jrl nz, .LFC8588                                     ; FC84AC  7e d9 00
.LFC84AF:
	lda xbc, (xiz-416)                                   ; FC84AF  f3 f9 60 fe 31
	push XBC                                             ; FC84B4  39
	lda xwa, (xiz-302)                                   ; FC84B5  f3 f9 d2 fe 30
	push XWA                                             ; FC84BA  38
	call MidiFrame_ToNoteFrame                                      ; FC84BB  1d 69 b2 fc
	lda xbc, (NoteRouting:24)                               ; FC84BF  f2 00 22 60 31
	push XBC                                             ; FC84C4  39
	lda xwa, (xiz-416)                                   ; FC84C5  f3 f9 60 fe 30
	push XWA                                             ; FC84CA  38
	call NoteList_ApplyFrame                                      ; FC84CB  1d 1d 9c fc
	ld XIX,XIY                                           ; FC84CF  ed 8c
	ld d, 0x00:opc                                          ; FC84D1  24 00
	inc 8,XSP                                            ; FC84D3  ef 60
	inc 8,XSP                                            ; FC84D5  ef 60
.LFC84D7:
	ld XBC,XIX                                           ; FC84D7  ec 89
	or XBC,XBC                                           ; FC84D9  e9 e1
	jrl z, .LFC8457                                      ; FC84DB  76 79 ff
	and XBC,0x00000001                                   ; FC84DE  e9 cc 01 00 00 00
	jrl z, .LFC8576                                      ; FC84E4  76 8f 00
	push 0x00                                            ; FC84E7  09 00
	push D                                               ; FC84E9  cc 04
	lda xbc, (NoteRouting:24)                               ; FC84EB  f2 00 22 60 31
	push XBC                                             ; FC84F0  39
	lda xwa, (xiz-416)                                   ; FC84F1  f3 f9 60 fe 30
	push XWA                                             ; FC84F6  38
	lda xiy, (xiz-712)                                   ; FC84F7  f3 f9 38 fd 35
	push XIY                                             ; FC84FC  3d
	call NoteFrame_SelectForPart                                      ; FC84FD  1d a3 9e fc
	inc 8,XSP                                            ; FC8501  ef 60
	inc 6,XSP                                            ; FC8503  ef 66
	cp a, 0x00:i3                                          ; FC8505  c9 d8
	jr z, .LFC8576                                       ; FC8507  66 6d
	push 0x00                                            ; FC8509  09 00
	push D                                               ; FC850B  cc 04
	lda xbc, (NoteRouting:24)                               ; FC850D  f2 00 22 60 31
	push XBC                                             ; FC8512  39
	lda xwa, (xiz-724)                                   ; FC8513  f3 f9 2c fd 30
	push XWA                                             ; FC8518  38
	call NoteRouting_ForPartFromMidiIn                                      ; FC8519  1d c9 af fc
	push 0x00                                            ; FC851D  09 00
	push D                                               ; FC851F  cc 04
	lda xbc, (xiz-724)                                   ; FC8521  f3 f9 2c fd 31
	push XBC                                             ; FC8526  39
	lda xwa, (xiz-712)                                   ; FC8527  f3 f9 38 fd 30
	push XWA                                             ; FC852C  38
	call PartNotes_ApplyFrame                                      ; FC852D  1d 8b 9f fc
	ld E,A                                               ; FC8531  c9 8d
	and A,0x01                                           ; FC8533  c9 cc 01
	add XSP,0x00000014                                   ; FC8536  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC853C  c9 d8
	jr z, .LFC854B                                       ; FC853E  66 0b
	lda xbc, (xiz-712)                                   ; FC8540  f3 f9 38 fd 31
	push XBC                                             ; FC8545  39
	call PartFrame_SendToToneGen                                      ; FC8546  1d bb a6 fc
	pop XIY                                              ; FC854A  5d
.LFC854B:
	ld C,E                                               ; FC854B  cd 8b
	and C,0x02                                           ; FC854D  cb cc 02
	jr z, .LFC8564                                       ; FC8550  66 12
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC8552  f2 93 24 60 cd
	jr nz, .LFC8564                                      ; FC8557  6e 0b
	lda xbc, (xiz-712)                                   ; FC8559  f3 f9 38 fd 31
	push XBC                                             ; FC855E  39
	call PartFrame_SendToMidiOut                                      ; FC855F  1d 98 aa fc
	pop XIY                                              ; FC8563  5d
.LFC8564:
	ld C,E                                               ; FC8564  cd 8b
	and C,0x04                                           ; FC8566  cb cc 04
	jr z, .LFC8576                                       ; FC8569  66 0b
	lda xbc, (xiz-712)                                   ; FC856B  f3 f9 38 fd 31
	push XBC                                             ; FC8570  39
	call PartFrame_RecordToSeqBuf                                      ; FC8571  1d aa ac fc
	pop XIY                                              ; FC8575  5d
.LFC8576:
	inc 1,D                                              ; FC8576  cc 61
	ld XIY,XIX                                           ; FC8578  ec 8d
	srl xiy, 0x01                                        ; FC857A  ed ef 01
	ld XIX,XIY                                           ; FC857D  ed 8c
	cp D,0x20                                            ; FC857F  cc cf 20
	jrl c, .LFC84D7                                      ; FC8582  77 52 ff
	jrl .LFC8457                                         ; FC8585  78 cf fe
.LFC8588:
	ld d, 0x00:opc                                          ; FC8588  24 00
	ld XIX,0x00000022                                    ; FC858A  44 22 00 00 00
	ldw hl, 0x00                                         ; FC858F  33 00 00
.LFC8592:
	lda xbc, (NoteRouting:24)                               ; FC8592  f2 00 22 60 31
	add XBC,XIX                                          ; FC8597  ec 81
	ld E,(XBC)                                           ; FC8599  81 25
	ld a, (xiz-299)                                      ; FC859B  c3 f9 d5 fe 21
	cp E,A                                               ; FC85A0  c9 f5
	jr nz, .LFC860C                                      ; FC85A2  6e 68
	ld BC,HL                                             ; FC85A4  db 89
	extz XBC                                             ; FC85A6  e9 12
	add XBC,0x00000152                                   ; FC85A8  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC85AE  e9 c8 00 22 60 00
	bit 6,(XBC)                                          ; FC85B4  b1 ce
	jr z, .LFC860C                                       ; FC85B6  66 54
	push 0x00                                            ; FC85B8  09 00
	push D                                               ; FC85BA  cc 04
	lda xbc, (NoteRouting:24)                               ; FC85BC  f2 00 22 60 31
	push XBC                                             ; FC85C1  39
	lda xwa, (xiz-724)                                   ; FC85C2  f3 f9 2c fd 30
	push XWA                                             ; FC85C7  38
	call NoteRouting_ForReceivingPart                                      ; FC85C8  1d 26 b1 fc
	push 0x00                                            ; FC85CC  09 00
	push D                                               ; FC85CE  cc 04
	lda xbc, (xiz-724)                                   ; FC85D0  f3 f9 2c fd 31
	push XBC                                             ; FC85D5  39
	lda xwa, (xiz-302)                                   ; FC85D6  f3 f9 d2 fe 30
	push XWA                                             ; FC85DB  38
	call PartNotes_ApplyFrame                                      ; FC85DC  1d 8b 9f fc
	ld E,A                                               ; FC85E0  c9 8d
	and A,0x01                                           ; FC85E2  c9 cc 01
	add XSP,0x00000014                                   ; FC85E5  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC85EB  c9 d8
	jr z, .LFC85FA                                       ; FC85ED  66 0b
	lda xbc, (xiz-302)                                   ; FC85EF  f3 f9 d2 fe 31
	push XBC                                             ; FC85F4  39
	call PartFrame_SendToToneGen                                      ; FC85F5  1d bb a6 fc
	pop XIY                                              ; FC85F9  5d
.LFC85FA:
	ld C,E                                               ; FC85FA  cd 8b
	and C,0x04                                           ; FC85FC  cb cc 04
	jr z, .LFC860C                                       ; FC85FF  66 0b
	lda xbc, (xiz-302)                                   ; FC8601  f3 f9 d2 fe 31
	push XBC                                             ; FC8606  39
	call PartFrame_RecordToSeqBuf                                      ; FC8607  1d aa ac fc
	pop XIY                                              ; FC860B  5d
.LFC860C:
	inc 1,XIX                                            ; FC860C  ec 61
	add HL,0x000a                                        ; FC860E  db c8 0a 00
	inc 1,D                                              ; FC8612  cc 61
	cp D,0x20                                            ; FC8614  cc cf 20
	jrl c, .LFC8592                                      ; FC8617  77 78 ff
	jrl .LFC8457                                         ; FC861A  78 3a fe
.LFC861D:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC861D  c2 93 24 60 23
	and C,0xc0                                           ; FC8622  cb cc c0
	srl c, 0x06                                          ; FC8625  cb ef 06
	cp c, 0x01:i3                                          ; FC8628  cb d9
	jr nz, .LFC863A                                      ; FC862A  6e 0e
	ld h, (xiz-299)                                      ; FC862C  c3 f9 d5 fe 26
	ld c, (NoteRouting_SingleChannel:24)                                 ; FC8631  c2 92 24 60 23
	cp C,H                                               ; FC8636  ce f3
	jr z, .LFC864A                                       ; FC8638  66 10
.LFC863A:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC863A  c2 93 24 60 23
	and C,0xc0                                           ; FC863F  cb cc c0
	srl c, 0x06                                          ; FC8642  cb ef 06
	cp c, 0x02:i3                                          ; FC8645  cb da
	jrl nz, .LFC8721                                     ; FC8647  7e d7 00
.LFC864A:
	lda xbc, (xiz-416)                                   ; FC864A  f3 f9 60 fe 31
	push XBC                                             ; FC864F  39
	lda xwa, (xiz-302)                                   ; FC8650  f3 f9 d2 fe 30
	push XWA                                             ; FC8655  38
	call MidiFrame_ToNoteFrame                                      ; FC8656  1d 69 b2 fc
	lda xbc, (xiz-416)                                   ; FC865A  f3 f9 60 fe 31
	push XBC                                             ; FC865F  39
	call NoteList_BuildReleaseAllFrame                                      ; FC8660  1d 46 9e fc
	extz WA                                              ; FC8664  d8 12
	extz XWA                                             ; FC8666  e8 12
	ld XIX,XWA                                           ; FC8668  e8 8c
	ld d, 0x00:opc                                          ; FC866A  24 00
	inc 8,XSP                                            ; FC866C  ef 60
	inc 4,XSP                                            ; FC866E  ef 64
.LFC8670:
	ld XBC,XIX                                           ; FC8670  ec 89
	or XBC,XBC                                           ; FC8672  e9 e1
	jrl z, .LFC8457                                      ; FC8674  76 e0 fd
	and XBC,0x00000001                                   ; FC8677  e9 cc 01 00 00 00
	jrl z, .LFC870F                                      ; FC867D  76 8f 00
	push 0x00                                            ; FC8680  09 00
	push D                                               ; FC8682  cc 04
	lda xbc, (NoteRouting:24)                               ; FC8684  f2 00 22 60 31
	push XBC                                             ; FC8689  39
	lda xwa, (xiz-416)                                   ; FC868A  f3 f9 60 fe 30
	push XWA                                             ; FC868F  38
	lda xiy, (xiz-712)                                   ; FC8690  f3 f9 38 fd 35
	push XIY                                             ; FC8695  3d
	call NoteFrame_SelectForPart                                      ; FC8696  1d a3 9e fc
	inc 8,XSP                                            ; FC869A  ef 60
	inc 6,XSP                                            ; FC869C  ef 66
	cp a, 0x00:i3                                          ; FC869E  c9 d8
	jr z, .LFC870F                                       ; FC86A0  66 6d
	push 0x00                                            ; FC86A2  09 00
	push D                                               ; FC86A4  cc 04
	lda xbc, (NoteRouting:24)                               ; FC86A6  f2 00 22 60 31
	push XBC                                             ; FC86AB  39
	lda xwa, (xiz-724)                                   ; FC86AC  f3 f9 2c fd 30
	push XWA                                             ; FC86B1  38
	call NoteRouting_ForPartFromMidiIn                                      ; FC86B2  1d c9 af fc
	push 0x00                                            ; FC86B6  09 00
	push D                                               ; FC86B8  cc 04
	lda xbc, (xiz-724)                                   ; FC86BA  f3 f9 2c fd 31
	push XBC                                             ; FC86BF  39
	lda xwa, (xiz-712)                                   ; FC86C0  f3 f9 38 fd 30
	push XWA                                             ; FC86C5  38
	call PartNotes_ApplyFrame                                      ; FC86C6  1d 8b 9f fc
	ld E,A                                               ; FC86CA  c9 8d
	and A,0x01                                           ; FC86CC  c9 cc 01
	add XSP,0x00000014                                   ; FC86CF  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC86D5  c9 d8
	jr z, .LFC86E4                                       ; FC86D7  66 0b
	lda xbc, (xiz-712)                                   ; FC86D9  f3 f9 38 fd 31
	push XBC                                             ; FC86DE  39
	call PartFrame_SendToToneGen                                      ; FC86DF  1d bb a6 fc
	pop XIY                                              ; FC86E3  5d
.LFC86E4:
	ld C,E                                               ; FC86E4  cd 8b
	and C,0x02                                           ; FC86E6  cb cc 02
	jr z, .LFC86FD                                       ; FC86E9  66 12
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC86EB  f2 93 24 60 cd
	jr nz, .LFC86FD                                      ; FC86F0  6e 0b
	lda xbc, (xiz-712)                                   ; FC86F2  f3 f9 38 fd 31
	push XBC                                             ; FC86F7  39
	call PartFrame_SendToMidiOut                                      ; FC86F8  1d 98 aa fc
	pop XIY                                              ; FC86FC  5d
.LFC86FD:
	ld C,E                                               ; FC86FD  cd 8b
	and C,0x04                                           ; FC86FF  cb cc 04
	jr z, .LFC870F                                       ; FC8702  66 0b
	lda xbc, (xiz-712)                                   ; FC8704  f3 f9 38 fd 31
	push XBC                                             ; FC8709  39
	call PartFrame_RecordToSeqBuf                                      ; FC870A  1d aa ac fc
	pop XIY                                              ; FC870E  5d
.LFC870F:
	inc 1,D                                              ; FC870F  cc 61
	ld XIY,XIX                                           ; FC8711  ec 8d
	srl xiy, 0x01                                        ; FC8713  ed ef 01
	ld XIX,XIY                                           ; FC8716  ed 8c
	cp D,0x20                                            ; FC8718  cc cf 20
	jrl c, .LFC8670                                      ; FC871B  77 52 ff
	jrl .LFC8457                                         ; FC871E  78 36 fd
.LFC8721:
	ld d, 0x00:opc                                          ; FC8721  24 00
	ld (xiz-302), 0x00                                   ; FC8723  f3 f9 d2 fe 00 00
	ld XIX,0x00000022                                    ; FC8729  44 22 00 00 00
	ldw hl, 0x00                                         ; FC872E  33 00 00
.LFC8731:
	lda xbc, (NoteRouting:24)                               ; FC8731  f2 00 22 60 31
	add XBC,XIX                                          ; FC8736  ec 81
	ld E,(XBC)                                           ; FC8738  81 25
	ld a, (xiz-299)                                      ; FC873A  c3 f9 d5 fe 21
	cp E,A                                               ; FC873F  c9 f5
	jr nz, .LFC8792                                      ; FC8741  6e 4f
	ld BC,HL                                             ; FC8743  db 89
	extz XBC                                             ; FC8745  e9 12
	add XBC,0x00000152                                   ; FC8747  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC874D  e9 c8 00 22 60 00
	bit 6,(XBC)                                          ; FC8753  b1 ce
	jr z, .LFC8792                                       ; FC8755  66 3b
	push 0x00                                            ; FC8757  09 00
	push D                                               ; FC8759  cc 04
	pushw 0x07                                           ; FC875B  0b 07 00
	lda xbc, (xiz-302)                                   ; FC875E  f3 f9 d2 fe 31
	push XBC                                             ; FC8763  39
	call PartNotes_BuildReleaseFrame                                      ; FC8764  1d 75 a4 fc
	ld E,A                                               ; FC8768  c9 8d
	inc 8,XSP                                            ; FC876A  ef 60
	cp a, 0x00:i3                                          ; FC876C  c9 d8
	jr z, .LFC8792                                       ; FC876E  66 22
	and A,0x01                                           ; FC8770  c9 cc 01
	jr z, .LFC8780                                       ; FC8773  66 0b
	lda xbc, (xiz-302)                                   ; FC8775  f3 f9 d2 fe 31
	push XBC                                             ; FC877A  39
	call PartFrame_SendToToneGen                                      ; FC877B  1d bb a6 fc
	pop XIY                                              ; FC877F  5d
.LFC8780:
	ld C,E                                               ; FC8780  cd 8b
	and C,0x04                                           ; FC8782  cb cc 04
	jr z, .LFC8792                                       ; FC8785  66 0b
	lda xbc, (xiz-302)                                   ; FC8787  f3 f9 d2 fe 31
	push XBC                                             ; FC878C  39
	call PartFrame_RecordToSeqBuf                                      ; FC878D  1d aa ac fc
	pop XIY                                              ; FC8791  5d
.LFC8792:
	inc 1,XIX                                            ; FC8792  ec 61
	add HL,0x000a                                        ; FC8794  db c8 0a 00
	inc 1,D                                              ; FC8798  cc 61
	ld (xiz-302), 0x00                                   ; FC879A  f3 f9 d2 fe 00 00
	cp D,0x20                                            ; FC87A0  cc cf 20
	jr c, .LFC8731                                       ; FC87A3  67 8c
	jrl .LFC8457                                         ; FC87A5  78 af fc
.LFC87A8:
	pop XIX                                              ; FC87A8  5c
	popw de                                              ; FC87A9  4a
	popw hl                                              ; FC87AA  4b
	unlk XIZ                                             ; FC87AB  ee 0d
	ret                                                  ; FC87AD  0e
; Ring601850_ProcessNoteEvents: T_F413B8: Ring601850_GatherFrame in a loop, each frame through NoteList_ApplyFrame, NoteFrame_SelectForPart, NoteRouting_ForPart,
;   PartNotes_ApplyFrame, PartFrame_SendToToneGen.
Ring601850_ProcessNoteEvents:
	link XIZ,0xfe3a                                      ; FC87AE  ee 0c 3a fe
	pushw hl                                             ; FC87B2  2b
	pushw de                                             ; FC87B3  2a
	push XIX                                             ; FC87B4  3c
	ld (xiz-12), 0x80                                    ; FC87B5  be f4 00 80
.LFC87B9:
	lda xbc, (xiz-126)                                   ; FC87B9  be 82 31
	push XBC                                             ; FC87BC  39
	lda xwa, (xiz-12)                                    ; FC87BD  be f4 30
	push XWA                                             ; FC87C0  38
	call Ring601850_GatherFrame                                      ; FC87C1  1d 99 90 fc
	inc 8,XSP                                            ; FC87C5  ef 60
	cp a, 0x00:i3                                          ; FC87C7  c9 d8
	jrl z, .LFC895A                                      ; FC87C9  76 8e 01
	lda xbc, (NoteRouting:24)                               ; FC87CC  f2 00 22 60 31
	push XBC                                             ; FC87D1  39
	lda xwa, (xiz-126)                                   ; FC87D2  be 82 30
	push XWA                                             ; FC87D5  38
	call NoteList_ApplyFrame                                      ; FC87D6  1d 1d 9c fc
	ld XIX,XIY                                           ; FC87DA  ed 8c
	ld c, (xiz-126)                                      ; FC87DC  8e 82 23
	inc 8,XSP                                            ; FC87DF  ef 60
	cp c, 0x00:i3                                          ; FC87E1  cb d8
	jr z, .LFC87B9                                       ; FC87E3  66 d4
	ld h, 0x00:opc                                          ; FC87E5  26 00
.LFC87E7:
	ld XBC,XIX                                           ; FC87E7  ec 89
	or XBC,XBC                                           ; FC87E9  e9 e1
	jrl z, .LFC8893                                      ; FC87EB  76 a5 00
	and XBC,0x00000001                                   ; FC87EE  e9 cc 01 00 00 00
	jrl z, .LFC8884                                      ; FC87F4  76 8d 00
	push 0x00                                            ; FC87F7  09 00
	push H                                               ; FC87F9  ce 04
	lda xbc, (NoteRouting:24)                               ; FC87FB  f2 00 22 60 31
	push XBC                                             ; FC8800  39
	lda xwa, (xiz-126)                                   ; FC8801  be 82 30
	push XWA                                             ; FC8804  38
	lda xiy, (xiz-422)                                   ; FC8805  f3 f9 5a fe 35
	push XIY                                             ; FC880A  3d
	call NoteFrame_SelectForPart                                      ; FC880B  1d a3 9e fc
	inc 8,XSP                                            ; FC880F  ef 60
	inc 6,XSP                                            ; FC8811  ef 66
	cp a, 0x00:i3                                          ; FC8813  c9 d8
	jr z, .LFC8884                                       ; FC8815  66 6d
	push 0x00                                            ; FC8817  09 00
	push H                                               ; FC8819  ce 04
	lda xbc, (NoteRouting:24)                               ; FC881B  f2 00 22 60 31
	push XBC                                             ; FC8820  39
	lda xwa, (xiz-434)                                   ; FC8821  f3 f9 4e fe 30
	push XWA                                             ; FC8826  38
	call NoteRouting_ForPart                                      ; FC8827  1d 76 ae fc
	push 0x00                                            ; FC882B  09 00
	push H                                               ; FC882D  ce 04
	lda xbc, (xiz-434)                                   ; FC882F  f3 f9 4e fe 31
	push XBC                                             ; FC8834  39
	lda xwa, (xiz-422)                                   ; FC8835  f3 f9 5a fe 30
	push XWA                                             ; FC883A  38
	call PartNotes_ApplyFrame                                      ; FC883B  1d 8b 9f fc
	ld L,A                                               ; FC883F  c9 8f
	and A,0x01                                           ; FC8841  c9 cc 01
	add XSP,0x00000014                                   ; FC8844  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC884A  c9 d8
	jr z, .LFC8859                                       ; FC884C  66 0b
	lda xbc, (xiz-422)                                   ; FC884E  f3 f9 5a fe 31
	push XBC                                             ; FC8853  39
	call PartFrame_SendToToneGen                                      ; FC8854  1d bb a6 fc
	pop XIY                                              ; FC8858  5d
.LFC8859:
	ld C,L                                               ; FC8859  cf 8b
	and C,0x02                                           ; FC885B  cb cc 02
	jr z, .LFC8872                                       ; FC885E  66 12
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC8860  f2 93 24 60 cd
	jr nz, .LFC8872                                      ; FC8865  6e 0b
	lda xbc, (xiz-422)                                   ; FC8867  f3 f9 5a fe 31
	push XBC                                             ; FC886C  39
	call PartFrame_SendToMidiOut                                      ; FC886D  1d 98 aa fc
	pop XIY                                              ; FC8871  5d
.LFC8872:
	ld C,L                                               ; FC8872  cf 8b
	and C,0x04                                           ; FC8874  cb cc 04
	jr z, .LFC8884                                       ; FC8877  66 0b
	lda xbc, (xiz-422)                                   ; FC8879  f3 f9 5a fe 31
	push XBC                                             ; FC887E  39
	call PartFrame_RecordToSeqBuf                                      ; FC887F  1d aa ac fc
	pop XIY                                              ; FC8883  5d
.LFC8884:
	inc 1,H                                              ; FC8884  ce 61
	ld XIY,XIX                                           ; FC8886  ec 8d
	srl xiy, 0x01                                        ; FC8888  ed ef 01
	ld XIX,XIY                                           ; FC888B  ed 8c
	cp H,0x20                                            ; FC888D  ce cf 20
	jrl c, .LFC87E7                                      ; FC8890  77 54 ff
.LFC8893:
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC8893  f2 93 24 60 cd
	jrl z, .LFC87B9                                      ; FC8898  76 1e ff
	ld c, (xiz-126)                                      ; FC889B  8e 82 23
	ld (xiz-422), c                                      ; FC889E  f3 f9 5a fe 43
	ldw hl, 0x00                                         ; FC88A3  33 00 00
	ld c, (xiz-126)                                      ; FC88A6  8e 82 23
	ld (xiz-436), c                                      ; FC88A9  f3 f9 4c fe 43
	ld a, (NoteRouting_SingleChannel:24)                                 ; FC88AE  c2 92 24 60 21
	ld (xiz-1), a                                        ; FC88B3  be ff 41
	extz BC                                              ; FC88B6  d9 12
	ld DE,BC                                             ; FC88B8  d9 8a
	ld XIX,0x00000000                                    ; FC88BA  44 00 00 00 00
	sub XWA,XWA                                          ; FC88BF  e8 a0
	ld (xiz-6), xwa                                      ; FC88C1  be fa 60
.LFC88C4:
	cp HL,DE                                             ; FC88C4  da f3
	jrl nc, .LFC894C                                     ; FC88C6  7f 83 00
	ld (xiz-438), xix                                    ; FC88C9  f3 f9 4a fe 64
	ld xbc, (xiz-438)                                    ; FC88CE  e3 f9 4a fe 21
	ld (xiz-442), xbc                                    ; FC88D3  f3 f9 46 fe 61
	add XBC,0x0000000c                                   ; FC88D8  e9 c8 0c 00 00 00
	add XBC,XIZ                                          ; FC88DE  ee 81
	ld a, (xiz-1)                                        ; FC88E0  8e ff 21
	ld (xbc-422), a                                      ; FC88E3  f3 e5 5a fe 41
	ld xbc, (xiz-6)                                      ; FC88E8  ae fa 21
	ld (xiz-446), xbc                                    ; FC88EB  f3 f9 42 fe 61
	ld (xiz-450), xbc                                    ; FC88F0  f3 f9 3e fe 61
	inc 3,XBC                                            ; FC88F5  e9 63
	add XBC,XIZ                                          ; FC88F7  ee 81
	ld a, (xbc-126)                                      ; FC88F9  89 82 21
	ld (xiz-452), a                                      ; FC88FC  f3 f9 3c fe 41
	ld xbc, (xiz-442)                                    ; FC8901  e3 f9 46 fe 21
	add XBC,0x0000000d                                   ; FC8906  e9 c8 0d 00 00 00
	add XBC,XIZ                                          ; FC890C  ee 81
	ld (xbc-422), a                                      ; FC890E  f3 e5 5a fe 41
	ld xbc, (xiz-450)                                    ; FC8913  e3 f9 3e fe 21
	inc 4,XBC                                            ; FC8918  e9 64
	add XBC,XIZ                                          ; FC891A  ee 81
	ld a, (xbc-126)                                      ; FC891C  89 82 21
	ld (xiz-454), a                                      ; FC891F  f3 f9 3a fe 41
	ld xbc, (xiz-442)                                    ; FC8924  e3 f9 46 fe 21
	inc 8,XBC                                            ; FC8929  e9 60
	add XBC,XIZ                                          ; FC892B  ee 81
	ld (xbc-422), a                                      ; FC892D  f3 e5 5a fe 41
	ld xix, (xiz-438)                                    ; FC8932  e3 f9 4a fe 24
	add XIX,0x00000009                                   ; FC8937  ec c8 09 00 00 00
	ld xbc, (xiz-446)                                    ; FC893D  e3 f9 42 fe 21
	inc 7,XBC                                            ; FC8942  e9 67
	ld (xiz-6), xbc                                      ; FC8944  be fa 61
	inc 1,HL                                             ; FC8947  db 61
	jrl .LFC88C4                                         ; FC8949  78 78 ff
.LFC894C:
	lda xbc, (xiz-422)                                   ; FC894C  f3 f9 5a fe 31
	push XBC                                             ; FC8951  39
	call PartFrame_SendToMidiOut                                      ; FC8952  1d 98 aa fc
	pop XIY                                              ; FC8956  5d
	jrl .LFC87B9                                         ; FC8957  78 5f fe
.LFC895A:
	pop XIX                                              ; FC895A  5c
	popw de                                              ; FC895B  4a
	popw hl                                              ; FC895C  4b
	unlk XIZ                                             ; FC895D  ee 0d
	ret                                                  ; FC895F  0e
; TimedEvents_ProcessRing: T_TimedEvents_ProcessRing: T_TimedEventRing_ScanRewind, TimedEvents_GatherFrame in a loop; a 0x90 frame's channel mapped to a
;   part through 0x603422 (0xFF = skip), then NoteRouting_ForTrack, PartNotes_ApplyFrame, PartFrame_SendToToneGen; 0xB0 frames to the CC path.
TimedEvents_ProcessRing:
	link XIZ,0xfec6                                      ; FC8960  ee 0c c6 fe
	pushw hl                                             ; FC8964  2b
	push XIX                                             ; FC8965  3c
	lda xix, (xiz-314)                                   ; FC8966  f3 f9 c6 fe 34
	call T_TimedEventRing_ScanRewind                         ; FC896B  1d 74 1d f4
	ld (xiz-6), 0x00                                     ; FC896F  be fa 00 00
.LFC8973:
	push XIX                                             ; FC8973  3c
	lda xbc, (xiz-6)                                     ; FC8974  be fa 31
	push XBC                                             ; FC8977  39
	call TimedEvents_GatherFrame                                      ; FC8978  1d 28 95 fc
	inc 8,XSP                                            ; FC897C  ef 60
	cp a, 0x00:i3                                          ; FC897E  c9 d8
	jrl z, .LFC8A88                                      ; FC8980  76 05 01
	ld C,(XIX+0x01)                                      ; FC8983  8c 01 23
	extz BC                                              ; FC8986  d9 12
	cp BC,0x0090                                         ; FC8988  d9 cf 90 00
	jr z, .LFC8996                                       ; FC898C  66 08
	cp BC,0x00b0                                         ; FC898E  d9 cf b0 00
	jr z, .LFC89EB                                       ; FC8992  66 57
	jr .LFC8973                                          ; FC8994  68 dd
.LFC8996:
	ld L,(XIX+0x03)                                      ; FC8996  8c 03 27
	ld C,L                                               ; FC8999  cf 8b
	extz BC                                              ; FC899B  d9 12
	extz XBC                                             ; FC899D  e9 12
	add XBC,BStore_TrackToPart                                   ; FC899F  e9 c8 22 34 60 00
	ld H,(XBC)                                           ; FC89A5  81 26
	cp H,0xff                                            ; FC89A7  ce cf ff
	jr z, .LFC8973                                       ; FC89AA  66 c7
	pushw hl                                             ; FC89AC  2b
	push 0x00                                            ; FC89AD  09 00
	push H                                               ; FC89AF  ce 04
	lda xbc, (NoteRouting:24)                               ; FC89B1  f2 00 22 60 31
	push XBC                                             ; FC89B6  39
	lda xwa, (xiz-18)                                    ; FC89B7  be ee 30
	push XWA                                             ; FC89BA  38
	call NoteRouting_ForTrack                                      ; FC89BB  1d bb b1 fc
	push 0x00                                            ; FC89BF  09 00
	push H                                               ; FC89C1  ce 04
	lda xbc, (xiz-18)                                    ; FC89C3  be ee 31
	push XBC                                             ; FC89C6  39
	push XIX                                             ; FC89C7  3c
	call PartNotes_ApplyFrame                                      ; FC89C8  1d 8b 9f fc
	ld H,A                                               ; FC89CC  c9 8e
	and A,0x01                                           ; FC89CE  c9 cc 01
	add XSP,0x00000016                                   ; FC89D1  ef c8 16 00 00 00
	cp a, 0x00:i3                                          ; FC89D7  c9 d8
	jr z, .LFC89E1                                       ; FC89D9  66 06
	push XIX                                             ; FC89DB  3c
	call PartFrame_SendToToneGen                                      ; FC89DC  1d bb a6 fc
	pop XIY                                              ; FC89E0  5d
.LFC89E1:
	ld C,H                                               ; FC89E1  ce 8b
	and C,0x02                                           ; FC89E3  cb cc 02
	jr z, .LFC8973                                       ; FC89E6  66 8b
	jrl .LFC8A7F                                         ; FC89E8  78 94 00
.LFC89EB:
	ld H,(XIX+0x03)                                      ; FC89EB  8c 03 26
	cp H,0x7f                                            ; FC89EE  ce cf 7f
	jr nz, .LFC8A45                                      ; FC89F1  6e 52
	ld (XIX+0x03),0x00                                   ; FC89F3  bc 03 00 00
	jr .LFC8A40                                          ; FC89F7  68 47
.LFC89F9:
	ld H,(XIX+0x03)                                      ; FC89F9  8c 03 26
	cp H,0x10                                            ; FC89FC  ce cf 10
	jrl nc, .LFC8973                                     ; FC89FF  7f 71 ff
	ld C,H                                               ; FC8A02  ce 8b
	extz BC                                              ; FC8A04  d9 12
	extz XBC                                             ; FC8A06  e9 12
	add XBC,BStore_TrackToPart                                   ; FC8A08  e9 c8 22 34 60 00
	ld H,(XBC)                                           ; FC8A0E  81 26
	cp H,0xff                                            ; FC8A10  ce cf ff
	jr z, .LFC8A3D                                       ; FC8A13  66 28
	push 0x00                                            ; FC8A15  09 00
	push H                                               ; FC8A17  ce 04
	pushw 0x07                                           ; FC8A19  0b 07 00
	push XIX                                             ; FC8A1C  3c
	call PartNotes_BuildReleaseFrame                                      ; FC8A1D  1d 75 a4 fc
	ld H,A                                               ; FC8A21  c9 8e
	and A,0x01                                           ; FC8A23  c9 cc 01
	inc 8,XSP                                            ; FC8A26  ef 60
	jr z, .LFC8A30                                       ; FC8A28  66 06
	push XIX                                             ; FC8A2A  3c
	call PartFrame_SendToToneGen                                      ; FC8A2B  1d bb a6 fc
	pop XIY                                              ; FC8A2F  5d
.LFC8A30:
	ld C,H                                               ; FC8A30  ce 8b
	and C,0x02                                           ; FC8A32  cb cc 02
	jr z, .LFC8A3D                                       ; FC8A35  66 06
	push XIX                                             ; FC8A37  3c
	call PartFrame_SendToMidiOut                                      ; FC8A38  1d 98 aa fc
	pop XIY                                              ; FC8A3C  5d
.LFC8A3D:
	incm8 0x01, (xix+0x03)                               ; FC8A3D  8c 03 61
.LFC8A40:
	ld (XIX),0x00                                        ; FC8A40  b4 00 00
	jr .LFC89F9                                          ; FC8A43  68 b4
.LFC8A45:
	ld C,H                                               ; FC8A45  ce 8b
	extz BC                                              ; FC8A47  d9 12
	extz XBC                                             ; FC8A49  e9 12
	add XBC,BStore_TrackToPart                                   ; FC8A4B  e9 c8 22 34 60 00
	ld H,(XBC)                                           ; FC8A51  81 26
	cp H,0xff                                            ; FC8A53  ce cf ff
	jrl z, .LFC8973                                      ; FC8A56  76 1a ff
	ld (XIX),0x00                                        ; FC8A59  b4 00 00
	push 0x00                                            ; FC8A5C  09 00
	push H                                               ; FC8A5E  ce 04
	pushw 0x07                                           ; FC8A60  0b 07 00
	push XIX                                             ; FC8A63  3c
	call PartNotes_BuildReleaseFrame                                      ; FC8A64  1d 75 a4 fc
	ld H,A                                               ; FC8A68  c9 8e
	and A,0x01                                           ; FC8A6A  c9 cc 01
	inc 8,XSP                                            ; FC8A6D  ef 60
	jr z, .LFC8A77                                       ; FC8A6F  66 06
	push XIX                                             ; FC8A71  3c
	call PartFrame_SendToToneGen                                      ; FC8A72  1d bb a6 fc
	pop XIY                                              ; FC8A76  5d
.LFC8A77:
	ld C,H                                               ; FC8A77  ce 8b
	and C,0x02                                           ; FC8A79  cb cc 02
	jrl z, .LFC8973                                      ; FC8A7C  76 f4 fe
.LFC8A7F:
	push XIX                                             ; FC8A7F  3c
	call PartFrame_SendToMidiOut                                      ; FC8A80  1d 98 aa fc
	pop XIY                                              ; FC8A84  5d
	jrl .LFC8973                                         ; FC8A85  78 eb fe
.LFC8A88:
	pop XIX                                              ; FC8A88  5c
	popw hl                                              ; FC8A89  4b
	unlk XIZ                                             ; FC8A8A  ee 0d
	ret                                                  ; FC8A8C  0e
; PartNotes_ReleaseAllReceivedMidiIn: T_PartNotes_ReleaseAllReceivedMidiIn: for each channel 0..31, each part that receives on it (block +0x22 = the channel, record +0x152 bit 6)
;   releases its MIDI IN notes on it (PartNotes_BuildReleaseFrame, source 1, mask 7); the note-offs go to the tone
;   generator and the record buffer.  Six call sites, in MidiFilePlay_Stop, MainTask_PhaseVector,
;   Transport_StopAllRunning_SaveRegs2, LcdKeyRow1_SoundEditMemoryWrite, PartNotes_ReleaseReceivedOnScreenChange and Notes_ReleaseAllSources.
PartNotes_ReleaseAllReceivedMidiIn:
	link XIZ,0xfed8                                      ; FC8A8D  ee 0c d8 fe
	pushw hl                                             ; FC8A91  2b
	pushw de                                             ; FC8A92  2a
	push XIX                                             ; FC8A93  3c
	ld (xiz-294), 0x01                                   ; FC8A94  f3 f9 da fe 00 01
	ld (xiz-293), 0x00                                   ; FC8A9A  f3 f9 db fe 00 00
.LFC8AA0:
	ld c, (xiz-293)                                      ; FC8AA0  c3 f9 db fe 23
	cp C,0x20                                            ; FC8AA5  cb cf 20
	jrl nc, .LFC8B30                                     ; FC8AA8  7f 85 00
	ld e, 0x00:opc                                          ; FC8AAB  25 00
	ld (xiz-296), 0x00                                   ; FC8AAD  f3 f9 d8 fe 00 00
	ld XIX,0x00000022                                    ; FC8AB3  44 22 00 00 00
	ldw hl, 0x00                                         ; FC8AB8  33 00 00
.LFC8ABB:
	lda xbc, (NoteRouting:24)                               ; FC8ABB  f2 00 22 60 31
	add XBC,XIX                                          ; FC8AC0  ec 81
	ld D,(XBC)                                           ; FC8AC2  81 24
	ld a, (xiz-293)                                      ; FC8AC4  c3 f9 db fe 21
	cp D,A                                               ; FC8AC9  c9 f4
	jr nz, .LFC8B15                                      ; FC8ACB  6e 48
	ld BC,HL                                             ; FC8ACD  db 89
	extz XBC                                             ; FC8ACF  e9 12
	add XBC,0x00000152                                   ; FC8AD1  e9 c8 52 01 00 00
	add XBC,NoteRouting                                   ; FC8AD7  e9 c8 00 22 60 00
	bit 6,(XBC)                                          ; FC8ADD  b1 ce
	jr z, .LFC8B15                                       ; FC8ADF  66 34
	pushw de                                             ; FC8AE1  2a
	pushw 0x07                                           ; FC8AE2  0b 07 00
	lda xbc, (xiz-296)                                   ; FC8AE5  f3 f9 d8 fe 31
	push XBC                                             ; FC8AEA  39
	call PartNotes_BuildReleaseFrame                                      ; FC8AEB  1d 75 a4 fc
	ld D,A                                               ; FC8AEF  c9 8c
	and A,0x01                                           ; FC8AF1  c9 cc 01
	inc 8,XSP                                            ; FC8AF4  ef 60
	jr z, .LFC8B03                                       ; FC8AF6  66 0b
	lda xbc, (xiz-296)                                   ; FC8AF8  f3 f9 d8 fe 31
	push XBC                                             ; FC8AFD  39
	call PartFrame_SendToToneGen                                      ; FC8AFE  1d bb a6 fc
	pop XIY                                              ; FC8B02  5d
.LFC8B03:
	ld C,D                                               ; FC8B03  cc 8b
	and C,0x04                                           ; FC8B05  cb cc 04
	jr z, .LFC8B15                                       ; FC8B08  66 0b
	lda xbc, (xiz-296)                                   ; FC8B0A  f3 f9 d8 fe 31
	push XBC                                             ; FC8B0F  39
	call PartFrame_RecordToSeqBuf                                      ; FC8B10  1d aa ac fc
	pop XIY                                              ; FC8B14  5d
.LFC8B15:
	inc 1,XIX                                            ; FC8B15  ec 61
	add HL,0x000a                                        ; FC8B17  db c8 0a 00
	inc 1,E                                              ; FC8B1B  cd 61
	ld (xiz-296), 0x00                                   ; FC8B1D  f3 f9 d8 fe 00 00
	cp E,0x20                                            ; FC8B23  cd cf 20
	jr c, .LFC8ABB                                       ; FC8B26  67 93
	incm8 0x01, (xiz-293)                                ; FC8B28  c3 f9 db fe 61
	jrl .LFC8AA0                                         ; FC8B2D  78 70 ff
.LFC8B30:
	pop XIX                                              ; FC8B30  5c
	popw de                                              ; FC8B31  4a
	popw hl                                              ; FC8B32  4b
	unlk XIZ                                             ; FC8B33  ee 0d
	ret                                                  ; FC8B35  0e
; NoteList_ReleaseAllSource0: T_NoteList_ReleaseAllSource0: every note on source 0's note list becomes a note-off (NoteList_BuildReleaseAllFrame, source 0) and
;   leaves the list (NoteList_ApplyFrame); each part of the voice mask then takes it as a note frame does
;   (NoteFrame_SelectForPart, NoteRouting_ForPart, PartNotes_ApplyFrame, the three outputs).  In MIDI IN mode 1 the
;   note-offs also go out as one MIDI OUT frame.  Its entry +5 byte, which Ring601850_ProcessNoteEvents fills with
;   NoteRouting_SingleChannel, is here the part loop's counter (XIZ-5) (0xFC8C61).
NoteList_ReleaseAllSource0:
	link XIZ,0xfe40                                      ; FC8B36  ee 0c 40 fe
	pushw hl                                             ; FC8B3A  2b
	pushw de                                             ; FC8B3B  2a
	push XIX                                             ; FC8B3C  3c
	ld (xiz-120), 0x00                                   ; FC8B3D  be 88 00 00
	ld (xiz-119), 0x00                                   ; FC8B41  be 89 00 00
	lda xbc, (xiz-120)                                   ; FC8B45  be 88 31
	push XBC                                             ; FC8B48  39
	call NoteList_BuildReleaseAllFrame                                      ; FC8B49  1d 46 9e fc
	pop XIY                                              ; FC8B4D  5d
	cp a, 0x00:i3                                          ; FC8B4E  c9 d8
	jrl z, .LFC8CDA                                      ; FC8B50  76 87 01
	lda xbc, (NoteRouting:24)                               ; FC8B53  f2 00 22 60 31
	push XBC                                             ; FC8B58  39
	lda xwa, (xiz-120)                                   ; FC8B59  be 88 30
	push XWA                                             ; FC8B5C  38
	call NoteList_ApplyFrame                                      ; FC8B5D  1d 1d 9c fc
	ld XIX,XIY                                           ; FC8B61  ed 8c
	ld c, (xiz-120)                                      ; FC8B63  8e 88 23
	inc 8,XSP                                            ; FC8B66  ef 60
	cp c, 0x00:i3                                          ; FC8B68  cb d8
	jrl z, .LFC8CDA                                      ; FC8B6A  76 6d 01
	ld (xiz-5), 0x00                                     ; FC8B6D  be fb 00 00
.LFC8B71:
	ld XBC,XIX                                           ; FC8B71  ec 89
	or XBC,XBC                                           ; FC8B73  e9 e1
	jrl z, .LFC8C1B                                      ; FC8B75  76 a3 00
	and XBC,0x00000001                                   ; FC8B78  e9 cc 01 00 00 00
	jrl z, .LFC8C0A                                      ; FC8B7E  76 89 00
	push 0x00                                            ; FC8B81  09 00
	push	(xiz-5)                                      ; FC8B83  8e fb 04
	lda xbc, (NoteRouting:24)                               ; FC8B86  f2 00 22 60 31
	push XBC                                             ; FC8B8B  39
	lda xwa, (xiz-120)                                   ; FC8B8C  be 88 30
	push XWA                                             ; FC8B8F  38
	lda xiy, (xiz-416)                                   ; FC8B90  f3 f9 60 fe 35
	push XIY                                             ; FC8B95  3d
	call NoteFrame_SelectForPart                                      ; FC8B96  1d a3 9e fc
	inc 8,XSP                                            ; FC8B9A  ef 60
	inc 6,XSP                                            ; FC8B9C  ef 66
	cp a, 0x00:i3                                          ; FC8B9E  c9 d8
	jr z, .LFC8C0A                                       ; FC8BA0  66 68
	push 0x00                                            ; FC8BA2  09 00
	push	(xiz-5)                                      ; FC8BA4  8e fb 04
	lda xbc, (NoteRouting:24)                               ; FC8BA7  f2 00 22 60 31
	push XBC                                             ; FC8BAC  39
	lda xwa, (xiz-428)                                   ; FC8BAD  f3 f9 54 fe 30
	push XWA                                             ; FC8BB2  38
	call NoteRouting_ForPart                                      ; FC8BB3  1d 76 ae fc
	push 0x00                                            ; FC8BB7  09 00
	push	(xiz-5)                                      ; FC8BB9  8e fb 04
	lda xbc, (xiz-428)                                   ; FC8BBC  f3 f9 54 fe 31
	push XBC                                             ; FC8BC1  39
	lda xwa, (xiz-416)                                   ; FC8BC2  f3 f9 60 fe 30
	push XWA                                             ; FC8BC7  38
	call PartNotes_ApplyFrame                                      ; FC8BC8  1d 8b 9f fc
	ld H,A                                               ; FC8BCC  c9 8e
	and A,0x01                                           ; FC8BCE  c9 cc 01
	add XSP,0x00000014                                   ; FC8BD1  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC8BD7  c9 d8
	jr z, .LFC8BE6                                       ; FC8BD9  66 0b
	lda xbc, (xiz-416)                                   ; FC8BDB  f3 f9 60 fe 31
	push XBC                                             ; FC8BE0  39
	call PartFrame_SendToToneGen                                      ; FC8BE1  1d bb a6 fc
	pop XIY                                              ; FC8BE5  5d
.LFC8BE6:
	ld C,H                                               ; FC8BE6  ce 8b
	and C,0x02                                           ; FC8BE8  cb cc 02
	jr z, .LFC8BF8                                       ; FC8BEB  66 0b
	lda xbc, (xiz-416)                                   ; FC8BED  f3 f9 60 fe 31
	push XBC                                             ; FC8BF2  39
	call PartFrame_SendToMidiOut                                      ; FC8BF3  1d 98 aa fc
	pop XIY                                              ; FC8BF7  5d
.LFC8BF8:
	ld C,H                                               ; FC8BF8  ce 8b
	and C,0x04                                           ; FC8BFA  cb cc 04
	jr z, .LFC8C0A                                       ; FC8BFD  66 0b
	lda xbc, (xiz-416)                                   ; FC8BFF  f3 f9 60 fe 31
	push XBC                                             ; FC8C04  39
	call PartFrame_RecordToSeqBuf                                      ; FC8C05  1d aa ac fc
	pop XIY                                              ; FC8C09  5d
.LFC8C0A:
	incm8 0x01, (xiz-5)                                  ; FC8C0A  8e fb 61
	ld XIY,XIX                                           ; FC8C0D  ec 8d
	srl xiy, 0x01                                        ; FC8C0F  ed ef 01
	ld XIX,XIY                                           ; FC8C12  ed 8c
	cp	(xiz-5), 0x20                                ; FC8C14  8e fb 3f 20
	jrl c, .LFC8B71                                      ; FC8C18  77 56 ff
.LFC8C1B:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FC8C1B  c2 93 24 60 23
	and C,0xc0                                           ; FC8C20  cb cc c0
	srl c, 0x06                                          ; FC8C23  cb ef 06
	cp c, 0x01:i3                                          ; FC8C26  cb d9
	jrl nz, .LFC8CDA                                     ; FC8C28  7e af 00
	ld c, (xiz-120)                                      ; FC8C2B  8e 88 23
	ld (xiz-416), c                                      ; FC8C2E  f3 f9 60 fe 43
	ldw hl, 0x00                                         ; FC8C33  33 00 00
	ld c, (xiz-120)                                      ; FC8C36  8e 88 23
	extz BC                                              ; FC8C39  d9 12
	ld DE,BC                                             ; FC8C3B  d9 8a
	sub XWA,XWA                                          ; FC8C3D  e8 a0
	ld (xiz-4), xwa                                      ; FC8C3F  be fc 60
	ld XIX,0x00000000                                    ; FC8C42  44 00 00 00 00
.LFC8C47:
	cp HL,DE                                             ; FC8C47  da f3
	jrl nc, .LFC8CCF                                     ; FC8C49  7f 83 00
	ld xbc, (xiz-4)                                      ; FC8C4C  ae fc 21
	ld (xiz-432), xbc                                    ; FC8C4F  f3 f9 50 fe 61
	ld (xiz-436), xbc                                    ; FC8C54  f3 f9 4c fe 61
	add XBC,0x0000000c                                   ; FC8C59  e9 c8 0c 00 00 00
	add XBC,XIZ                                          ; FC8C5F  ee 81
	ld a, (xiz-5)                                        ; FC8C61  8e fb 21
	ld (xbc-416), a                                      ; FC8C64  f3 e5 60 fe 41
	ld (xiz-440), xix                                    ; FC8C69  f3 f9 48 fe 64
	ld xbc, (xiz-440)                                    ; FC8C6E  e3 f9 48 fe 21
	ld (xiz-444), xbc                                    ; FC8C73  f3 f9 44 fe 61
	inc 3,XBC                                            ; FC8C78  e9 63
	add XBC,XIZ                                          ; FC8C7A  ee 81
	ld a, (xbc-120)                                      ; FC8C7C  89 88 21
	ld (xiz-446), a                                      ; FC8C7F  f3 f9 42 fe 41
	ld xbc, (xiz-436)                                    ; FC8C84  e3 f9 4c fe 21
	add XBC,0x0000000d                                   ; FC8C89  e9 c8 0d 00 00 00
	add XBC,XIZ                                          ; FC8C8F  ee 81
	ld (xbc-416), a                                      ; FC8C91  f3 e5 60 fe 41
	ld xbc, (xiz-444)                                    ; FC8C96  e3 f9 44 fe 21
	inc 4,XBC                                            ; FC8C9B  e9 64
	add XBC,XIZ                                          ; FC8C9D  ee 81
	ld a, (xbc-120)                                      ; FC8C9F  89 88 21
	ld (xiz-448), a                                      ; FC8CA2  f3 f9 40 fe 41
	ld xbc, (xiz-436)                                    ; FC8CA7  e3 f9 4c fe 21
	inc 8,XBC                                            ; FC8CAC  e9 60
	add XBC,XIZ                                          ; FC8CAE  ee 81
	ld (xbc-416), a                                      ; FC8CB0  f3 e5 60 fe 41
	ld xbc, (xiz-432)                                    ; FC8CB5  e3 f9 50 fe 21
	add XBC,0x00000009                                   ; FC8CBA  e9 c8 09 00 00 00
	ld (xiz-4), xbc                                      ; FC8CC0  be fc 61
	ld xix, (xiz-440)                                    ; FC8CC3  e3 f9 48 fe 24
	inc 7,XIX                                            ; FC8CC8  ec 67
	inc 1,HL                                             ; FC8CCA  db 61
	jrl .LFC8C47                                         ; FC8CCC  78 78 ff
.LFC8CCF:
	lda xbc, (xiz-416)                                   ; FC8CCF  f3 f9 60 fe 31
	push XBC                                             ; FC8CD4  39
	call PartFrame_SendToMidiOut                                      ; FC8CD5  1d 98 aa fc
	pop XIY                                              ; FC8CD9  5d
.LFC8CDA:
	pop XIX                                              ; FC8CDA  5c
	popw de                                              ; FC8CDB  4a
	popw hl                                              ; FC8CDC  4b
	unlk XIZ                                             ; FC8CDD  ee 0d
	ret                                                  ; FC8CDF  0e
; PartNotes_ReleaseAllTrackNotes: T_PartNotes_ReleaseAllTrackNotes: for each of the 16 tracks that has a part (BStore_TrackToPart), the track's notes on it (source 2,
;   channel key = the track) become note-offs (PartNotes_BuildReleaseFrame, mask 7) sent to the tone generator and
;   MIDI OUT.  Eleven callers through the slot, among them MainTask_PanelTimersTick and MainTask_PhaseVector.
PartNotes_ReleaseAllTrackNotes:
	link XIZ,0xfed8                                      ; FC8CE0  ee 0c d8 fe
	pushw hl                                             ; FC8CE4  2b
	push XIX                                             ; FC8CE5  3c
	lda xix, (xiz-296)                                   ; FC8CE6  f3 f9 d8 fe 34
	ld (XIX+0x02),0x02                                   ; FC8CEB  bc 02 00 02
	ld (XIX+0x03),0x00                                   ; FC8CEF  bc 03 00 00
	jr .LFC8D3B                                          ; FC8CF3  68 46
.LFC8CF5:
	ld H,(XIX+0x03)                                      ; FC8CF5  8c 03 26
	cp H,0x10                                            ; FC8CF8  ce cf 10
	jr nc, .LFC8D40                                      ; FC8CFB  6f 43
	ld C,H                                               ; FC8CFD  ce 8b
	extz BC                                              ; FC8CFF  d9 12
	extz XBC                                             ; FC8D01  e9 12
	add XBC,BStore_TrackToPart                                   ; FC8D03  e9 c8 22 34 60 00
	ld H,(XBC)                                           ; FC8D09  81 26
	cp H,0xff                                            ; FC8D0B  ce cf ff
	jr z, .LFC8D38                                       ; FC8D0E  66 28
	push 0x00                                            ; FC8D10  09 00
	push H                                               ; FC8D12  ce 04
	pushw 0x07                                           ; FC8D14  0b 07 00
	push XIX                                             ; FC8D17  3c
	call PartNotes_BuildReleaseFrame                                      ; FC8D18  1d 75 a4 fc
	ld H,A                                               ; FC8D1C  c9 8e
	and A,0x01                                           ; FC8D1E  c9 cc 01
	inc 8,XSP                                            ; FC8D21  ef 60
	jr z, .LFC8D2B                                       ; FC8D23  66 06
	push XIX                                             ; FC8D25  3c
	call PartFrame_SendToToneGen                                      ; FC8D26  1d bb a6 fc
	pop XIY                                              ; FC8D2A  5d
.LFC8D2B:
	ld C,H                                               ; FC8D2B  ce 8b
	and C,0x02                                           ; FC8D2D  cb cc 02
	jr z, .LFC8D38                                       ; FC8D30  66 06
	push XIX                                             ; FC8D32  3c
	call PartFrame_SendToMidiOut                                      ; FC8D33  1d 98 aa fc
	pop XIY                                              ; FC8D37  5d
.LFC8D38:
	incm8 0x01, (xix+0x03)                               ; FC8D38  8c 03 61
.LFC8D3B:
	ld (XIX),0x00                                        ; FC8D3B  b4 00 00
	jr .LFC8CF5                                          ; FC8D3E  68 b5
.LFC8D40:
	pop XIX                                              ; FC8D40  5c
	popw hl                                              ; FC8D41  4b
	unlk XIZ                                             ; FC8D42  ee 0d
	ret                                                  ; FC8D44  0e
sub_FC8D45:
	calr sub_FC8D45_Nop                                          ; FC8D45  1e b6 01
	ret                                                  ; FC8D48  0e
; NoteRouting_ApplyQueuedChanges: T_NoteRouting_ApplyQueuedChanges: for each record of NoteRouting_ChangeQueue (NoteRouting_ChangeCount of them), the kind 0..8 through
;   NoteChange_HandlerTable with (record +1, +2, +3) -- a kind above 8 is skipped; then the count = 0.
NoteRouting_ApplyQueuedChanges:
	link XIZ,0xfffa                                      ; FC8D49  ee 0c fa ff
	pushw hl                                             ; FC8D4D  2b
	pushw de                                             ; FC8D4E  2a
	push XIX                                             ; FC8D4F  3c
	ldw	(xiz-2), 0x0000                              ; FC8D50  be fe 02 00 00
	cpw	(NoteRouting_ChangeCount:24), 0x0000                        ; FC8D55  d2 00 2a 60 3f 00 00
	jrl ule, NoteRouting_ApplyQueuedChanges_Return                                      ; FC8D5C  73 0f 01
	ld XIX,0x00000000                                    ; FC8D5F  44 00 00 00 00
NoteRouting_ApplyQueuedChanges_Loop:
	ld (xiz-6), xix                                      ; FC8D64  be fa 64
	lda xbc, (NoteRouting_ChangeQueue:24)                               ; FC8D67  f2 02 2a 60 31
	add	xbc, (xiz-6)                                 ; FC8D6C  ae fa 81
	ld E,(XBC)                                           ; FC8D6F  81 25
	ld xbc, (xiz-6)                                      ; FC8D71  ae fa 21
	inc 1,XBC                                            ; FC8D74  e9 61
	add XBC,NoteRouting_ChangeQueue                                   ; FC8D76  e9 c8 02 2a 60 00
	ld H,(XBC)                                           ; FC8D7C  81 26
	ld xbc, (xiz-6)                                      ; FC8D7E  ae fa 21
	inc 2,XBC                                            ; FC8D81  e9 62
	add XBC,NoteRouting_ChangeQueue                                   ; FC8D83  e9 c8 02 2a 60 00
	ld L,(XBC)                                           ; FC8D89  81 27
	ld xbc, (xiz-6)                                      ; FC8D8B  ae fa 21
	inc 3,XBC                                            ; FC8D8E  e9 63
	add XBC,NoteRouting_ChangeQueue                                   ; FC8D90  e9 c8 02 2a 60 00
	ld D,(XBC)                                           ; FC8D96  81 24
	ld C,E                                               ; FC8D98  cd 8b
	extz BC                                              ; FC8D9A  d9 12
	extz XBC                                             ; FC8D9C  e9 12
	cp BC,0x0008                                         ; FC8D9E  d9 cf 08 00
	jrl ugt, NoteRouting_ApplyQueuedChanges_Skip                                        ; FC8DA2  7b b9 00
	sll bc, 0x02                                         ; FC8DA5  d9 ee 02
	add XBC,NoteChange_HandlerTable                             ; FC8DA8  e9 c8 b2 8d fc 00
	ld XBC,(XBC)                                         ; FC8DAE  a1 21
	jp (xbc)                                             ; FC8DB0  b1 d8
; ---------------------------------------------------------------------
; NoteChange_HandlerTable -- 9 entries, read by the computed jump at 0xFC8DA8
;
; ENTRY COUNT = 9, taken from the READER's own bound and not by eye:
;   0xFC8D9E  cp BC,0x0008        indices 0..8
;   0xFC8DA2  jrl UGT,0xFC8E5E    out of range -> the default
;   0xFC8DA5  sll 0x02,BC         4 bytes per entry
;   0xFC8DA8  add XBC,0x00fc8db2  this label
;   0xFC8DAE  ld XBC,(XBC)
;   0xFC8DB0  jp T,XBC
; and the LAST-ENTRY TEST is the table's own end: 0xFC8DB2 + 9*4 = 0xFC8DD6,
; which is the VALUE of entry 0.  The table stops exactly where the code it
; jumps into begins.  notes/prom_a_jumptables.py finds it independently and
; agrees on all six numbers; it is the only inline jump table in this module.
; Evidence: as above, all six instructions checked as bytes in
;          notes/prom_a_fc8000_module_check.py.
; Unknown: what the nine arms select.
; ---------------------------------------------------------------------
; NoteChange_HandlerTable: the nine note-change kinds of NoteRouting_ChangeQueue, read by
;   NoteRouting_ApplyQueuedChanges -- notes/FINDINGS-prom_a-note-frames.md section 7.
NoteChange_HandlerTable:
	.long NoteChange_CasePartReceive                                 ; FC8DB2  [  0]
	.long NoteChange_Case1Unused                                 ; FC8DB6  [  1]
	.long NoteChange_CaseTrackMidiOut                                 ; FC8DBA  [  2]
	.long NoteChange_CaseTrackPart                                 ; FC8DBE  [  3]
	.long NoteChange_CasePartToneGen                                 ; FC8DC2  [  4]
	.long NoteChange_CasePartTransmit                                 ; FC8DC6  [  5]
	.long NoteChange_CaseTrackPartRecord                                 ; FC8DCA  [  6]
	.long NoteChange_CaseMidiInMode                                 ; FC8DCE  [  7]
	.long NoteChange_CaseMidiOutScheme                                 ; FC8DD2  [  8]
; NoteChange_CasePartReceive: NoteChange_HandlerTable[0]: NoteChange_ReleasePartReceivedNotes(record +1, +2, +3).
NoteChange_CasePartReceive:   ; entry: named by 1 `.long` operand, first at 0xFC8DB2
	push 0x00                                            ; FC8DD6  09 00
	push D                                               ; FC8DD8  cc 04
	pushw hl                                             ; FC8DDA  2b
	push 0x00                                            ; FC8DDB  09 00
	push H                                               ; FC8DDD  ce 04
	call NoteChange_ReleasePartReceivedNotes                                      ; FC8DDF  1d 27 97 fc
	jrl .LFC8E5C                                         ; FC8DE3  78 76 00
; NoteChange_Case1Unused: NoteChange_HandlerTable[1]: calls a bare ret (NoteChange_Kind1_Nop).  None of the queuers read queues kind 1.
NoteChange_Case1Unused:   ; entry: named by 1 `.long` operand, first at 0xFC8DB6
	push 0x00                                            ; FC8DE6  09 00
	push D                                               ; FC8DE8  cc 04
	pushw hl                                             ; FC8DEA  2b
	push 0x00                                            ; FC8DEB  09 00
	push H                                               ; FC8DED  ce 04
	call NoteChange_Kind1_Nop                                      ; FC8DEF  1d 26 97 fc
	jr .LFC8E5C                                          ; FC8DF3  68 67
; NoteChange_CaseTrackMidiOut: NoteChange_HandlerTable[2]: NoteChange_ReleaseTrackMidiOutNotes(record +1, +2, +3).
NoteChange_CaseTrackMidiOut:   ; entry: named by 1 `.long` operand, first at 0xFC8DBA
	push 0x00                                            ; FC8DF5  09 00
	push D                                               ; FC8DF7  cc 04
	pushw hl                                             ; FC8DF9  2b
	push 0x00                                            ; FC8DFA  09 00
	push H                                               ; FC8DFC  ce 04
	call NoteChange_ReleaseTrackMidiOutNotes                                      ; FC8DFE  1d f1 97 fc
	jr .LFC8E5C                                          ; FC8E02  68 58
; NoteChange_CaseTrackPart: NoteChange_HandlerTable[3]: NoteChange_ReleaseTrackNotesOfOldPart(record +1, +2, +3).
NoteChange_CaseTrackPart:   ; entry: named by 1 `.long` operand, first at 0xFC8DBE
	push 0x00                                            ; FC8E04  09 00
	push D                                               ; FC8E06  cc 04
	pushw hl                                             ; FC8E08  2b
	push 0x00                                            ; FC8E09  09 00
	push H                                               ; FC8E0B  ce 04
	call NoteChange_ReleaseTrackNotesOfOldPart                                      ; FC8E0D  1d 96 97 fc
	jr .LFC8E5C                                          ; FC8E11  68 49
; NoteChange_CasePartToneGen: NoteChange_HandlerTable[4]: calls a bare ret (NoteChange_PartToneGen_Nop).  Kind 4 is queued only by
;   NoteRouting_QueueToneGenPartChanges, which nothing calls.
NoteChange_CasePartToneGen:   ; entry: named by 1 `.long` operand, first at 0xFC8DC2
	push 0x00                                            ; FC8E13  09 00
	push D                                               ; FC8E15  cc 04
	pushw hl                                             ; FC8E17  2b
	push 0x00                                            ; FC8E18  09 00
	push H                                               ; FC8E1A  ce 04
	call NoteChange_PartToneGen_Nop                                      ; FC8E1C  1d 53 98 fc
	jr .LFC8E5C                                          ; FC8E20  68 3a
; NoteChange_CasePartTransmit: NoteChange_HandlerTable[5]: NoteChange_ReleasePartTransmittedNotes(record +1, +2, +3).
NoteChange_CasePartTransmit:   ; entry: named by 1 `.long` operand, first at 0xFC8DC6
	push 0x00                                            ; FC8E22  09 00
	push D                                               ; FC8E24  cc 04
	pushw hl                                             ; FC8E26  2b
	push 0x00                                            ; FC8E27  09 00
	push H                                               ; FC8E29  ce 04
	call NoteChange_ReleasePartTransmittedNotes                                      ; FC8E2B  1d 54 98 fc
	jr .LFC8E5C                                          ; FC8E2F  68 2b
; NoteChange_CaseTrackPartRecord: NoteChange_HandlerTable[6]: NoteChange_ReleaseRecordedNotesOfOldPart(record +1, +2, +3).
NoteChange_CaseTrackPartRecord:   ; entry: named by 1 `.long` operand, first at 0xFC8DCA
	push 0x00                                            ; FC8E31  09 00
	push D                                               ; FC8E33  cc 04
	pushw hl                                             ; FC8E35  2b
	push 0x00                                            ; FC8E36  09 00
	push H                                               ; FC8E38  ce 04
	call NoteChange_ReleaseRecordedNotesOfOldPart                                      ; FC8E3A  1d e7 98 fc
	jr .LFC8E5C                                          ; FC8E3E  68 1c
; NoteChange_CaseMidiInMode: NoteChange_HandlerTable[7]: NoteChange_ReleaseMidiInChannelNotes(record +1, +2, +3).
NoteChange_CaseMidiInMode:   ; entry: named by 1 `.long` operand, first at 0xFC8DCE
	push 0x00                                            ; FC8E40  09 00
	push D                                               ; FC8E42  cc 04
	pushw hl                                             ; FC8E44  2b
	push 0x00                                            ; FC8E45  09 00
	push H                                               ; FC8E47  ce 04
	call NoteChange_ReleaseMidiInChannelNotes                                      ; FC8E49  1d 33 99 fc
	jr .LFC8E5C                                          ; FC8E4D  68 0d
; NoteChange_CaseMidiOutScheme: NoteChange_HandlerTable[8]: NoteChange_ReleaseOldMidiOutScheme(record +1, +2, +3).
NoteChange_CaseMidiOutScheme:   ; entry: named by 1 `.long` operand, first at 0xFC8DD2
	push 0x00                                            ; FC8E4F  09 00
	push D                                               ; FC8E51  cc 04
	pushw hl                                             ; FC8E53  2b
	push 0x00                                            ; FC8E54  09 00
	push H                                               ; FC8E56  ce 04
	call NoteChange_ReleaseOldMidiOutScheme                                      ; FC8E58  1d a1 9a fc
.LFC8E5C:
	inc 6,XSP                                            ; FC8E5C  ef 66
NoteRouting_ApplyQueuedChanges_Skip:
	inc 4,XIX                                            ; FC8E5E  ec 64
	incw 0x01, (xiz-2)                                   ; FC8E60  9e fe 61
	ld bc, (xiz-2)                                       ; FC8E63  9e fe 21
	cp	bc, (NoteRouting_ChangeCount:24)                            ; FC8E66  d2 00 2a 60 f1
	jrl c, NoteRouting_ApplyQueuedChanges_Loop                                          ; FC8E6B  77 f6 fe
NoteRouting_ApplyQueuedChanges_Return:
	ldw (NoteRouting_ChangeCount:24), 0x00                             ; FC8E6E  f2 00 2a 60 02 00 00
	pop XIX                                              ; FC8E75  5c
	popw de                                              ; FC8E76  4a
	popw hl                                              ; FC8E77  4b
	unlk XIZ                                             ; FC8E78  ee 0d
	ret                                                  ; FC8E7A  0e
; PartNoteList_NextHeldNote: (part, source, selector) Iterator over a part's held-note list (PartNoteList_Heads, next
;   link at +0x0B): part != 0xFF starts at that part's head, 0xFF continues from (0x602050). Returns the node's byte
;   +2 / +5 / +8 (selector 0 / 1 / 2) and advances when the node's source (+0) equals the argument; 0xFF at the list
;   end or at a node of another source. PartNotes_GetCurrentPartHeldNote calls it twice. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
PartNoteList_NextHeldNote:
	link XIZ,0x0000                                      ; FC8E7B  ee 0c 00 00
	pushw hl                                             ; FC8E7F  2b
	push XIX                                             ; FC8E80  3c
	lda xix, (0x602050:24)                               ; FC8E81  f2 50 20 60 34
	cp (XIZ+0x08),0xff                                   ; FC8E86  8e 08 3f ff
	jr z, .LFC8EA4                                       ; FC8E8A  66 18
	ld c, 0x0f:opc                                          ; FC8E8C  23 0f
	mul	bc, (xiz+8)                                  ; FC8E8E  8e 08 43
	ld HL,BC                                             ; FC8E91  d9 8b
	ldw wa, PartNoteList_Heads                                       ; FC8E93  30 f7 39
	add WA,BC                                            ; FC8E96  d9 80
	ld (0x602052:24), wa                                ; FC8E98  f2 52 20 60 50
	extz XWA                                             ; FC8E9D  e8 12
	ld BC,(XWA+0x0b)                                     ; FC8E9F  98 0b 21
	ld (XIX),BC                                          ; FC8EA2  b4 51
.LFC8EA4:
	ld BC,(XIX)                                          ; FC8EA4  94 21
	cp	bc, (0x602052:24)                            ; FC8EA6  d2 52 20 60 f1
	jr z, .LFC8EF3                                       ; FC8EAB  66 46
	ld BC,(XIX)                                          ; FC8EAD  94 21
	extz XBC                                             ; FC8EAF  e9 12
	ld A,(XBC)                                           ; FC8EB1  81 21
	cp A,(XIZ+0x0a)                                      ; FC8EB3  8e 0a f1
	jr nz, .LFC8EF3                                      ; FC8EB6  6e 3b
	ld BC,(XIZ+0x0c)                                     ; FC8EB8  9e 0c 21
	extz BC                                              ; FC8EBB  d9 12
	cp bc, 0x00:i3                                         ; FC8EBD  d9 d8
	jr z, .LFC8ECB                                       ; FC8EBF  66 0a
	cp bc, 0x01:i3                                         ; FC8EC1  d9 d9
	jr z, .LFC8ED4                                       ; FC8EC3  66 0f
	cp bc, 0x02:i3                                         ; FC8EC5  d9 da
	jr z, .LFC8EDD                                       ; FC8EC7  66 14
	jr .LFC8EE6                                          ; FC8EC9  68 1b
.LFC8ECB:
	ld BC,(XIX)                                          ; FC8ECB  94 21
	extz XBC                                             ; FC8ECD  e9 12
	ld H,(XBC+0x02)                                      ; FC8ECF  89 02 26
	jr .LFC8EE8                                          ; FC8ED2  68 14
.LFC8ED4:
	ld BC,(XIX)                                          ; FC8ED4  94 21
	extz XBC                                             ; FC8ED6  e9 12
	ld H,(XBC+0x05)                                      ; FC8ED8  89 05 26
	jr .LFC8EE8                                          ; FC8EDB  68 0b
.LFC8EDD:
	ld BC,(XIX)                                          ; FC8EDD  94 21
	extz XBC                                             ; FC8EDF  e9 12
	ld H,(XBC+0x08)                                      ; FC8EE1  89 08 26
	jr .LFC8EE8                                          ; FC8EE4  68 02
.LFC8EE6:
	ld h, 0xff:opc                                          ; FC8EE6  26 ff
.LFC8EE8:
	ld BC,(XIX)                                          ; FC8EE8  94 21
	extz XBC                                             ; FC8EEA  e9 12
	ld WA,(XBC+0x0b)                                     ; FC8EEC  99 0b 20
	ld (XIX),WA                                          ; FC8EEF  b4 50
	jr .LFC8EF7                                          ; FC8EF1  68 04
.LFC8EF3:
	ld a, 0xff:opc                                          ; FC8EF3  21 ff
	jr .LFC8EF9                                          ; FC8EF5  68 02
.LFC8EF7:
	ld A,H                                               ; FC8EF7  ce 89
.LFC8EF9:
	pop XIX                                              ; FC8EF9  5c
	popw hl                                              ; FC8EFA  4b
	unlk XIZ                                             ; FC8EFB  ee 0d
	ret                                                  ; FC8EFD  0e
sub_FC8D45_Nop:
	ret                                                  ; FC8EFE  0e
	link XIZ,0xfff8                                      ; FC8EFF  ee 0c f8 ff
	pushw hl                                             ; FC8F03  2b
	pushw de                                             ; FC8F04  2a
	push XIX                                             ; FC8F05  3c
	ld XIX,0x00000000                                    ; FC8F06  44 00 00 00 00
	sub XBC,XBC                                          ; FC8F0B  e9 a1
	ld (xiz-4), xbc                                      ; FC8F0D  be fc 61
	ldw hl, 0x00                                         ; FC8F10  33 00 00
	ld XWA,(XIZ+0x08)                                    ; FC8F13  ae 08 20
	ld C,(XWA)                                           ; FC8F16  80 23
	extz BC                                              ; FC8F18  d9 12
	ld DE,BC                                             ; FC8F1A  d9 8a
.LFC8F1C:
	cp HL,DE                                             ; FC8F1C  da f3
	jr nc, .LFC8F39                                      ; FC8F1E  6f 19
	ld (xiz-8), xix                                      ; FC8F20  be f8 64
	ld xbc, (xiz-8)                                      ; FC8F23  ae f8 21
	inc 5,XBC                                            ; FC8F26  e9 65
	add XBC,(XIZ+0x08)                                   ; FC8F28  ae 08 81
	ld XWA,(XBC)                                         ; FC8F2B  a1 20
	or (xiz-4), xwa                                      ; FC8F2D  ae fc e8
	ld xix, (xiz-8)                                      ; FC8F30  ae f8 24
	inc 7,XIX                                            ; FC8F33  ec 67
	inc 1,HL                                             ; FC8F35  db 61
	jr .LFC8F1C                                          ; FC8F37  68 e3
.LFC8F39:
	ld XBC,(XIZ+0x0c)                                    ; FC8F39  ae 0c 21
	ld H,(XBC+0x01)                                      ; FC8F3C  89 01 26
	cp H,0xff                                            ; FC8F3F  ce cf ff
	jr nz, .LFC8F51                                      ; FC8F42  6e 0d
	ld A,(XBC)                                           ; FC8F44  81 21
	extz WA                                              ; FC8F46  d8 12
	extz XWA                                             ; FC8F48  e8 12
	or	xwa, (xiz-4)                                 ; FC8F4A  ae fc e0
	ld XIY,XWA                                           ; FC8F4D  e8 8d
	jr .LFC8F64                                          ; FC8F4F  68 13
.LFC8F51:
	ld c, 0x04:opc                                          ; FC8F51  23 04
	mul bc, h                                          ; FC8F53  ce 43
	extz XBC                                             ; FC8F55  e9 12
	add XBC,Part_VoiceMasks                                   ; FC8F57  e9 c8 54 20 60 00
	ld XBC,(XBC)                                         ; FC8F5D  a1 21
	or	xbc, (xiz-4)                                 ; FC8F5F  ae fc e1
	ld XIY,XBC                                           ; FC8F62  e9 8d
.LFC8F64:
	pop XIX                                              ; FC8F64  5c
	popw de                                              ; FC8F65  4a
	popw hl                                              ; FC8F66  4b
	unlk XIZ                                             ; FC8F67  ee 0d
	ret                                                  ; FC8F69  0e
	link XIZ,0xfffc                                      ; FC8F6A  ee 0c fc ff
	push XHL                                             ; FC8F6E  3b
	push XDE                                             ; FC8F6F  3a
	push XIX                                             ; FC8F70  3c
	ld XBC,(XIZ+0x08)                                    ; FC8F71  ae 08 21
	ld A,(XBC+0x01)                                      ; FC8F74  89 01 21
	mul A,0x0d                                           ; FC8F77  c9 08 0d
	ld HL,WA                                             ; FC8F7A  d8 8b
	ldw de, NoteList_Heads                                       ; FC8F7C  32 23 38
	add DE,WA                                            ; FC8F7F  d8 82
	ld XIX,XBC                                           ; FC8F81  e9 8c
	inc 2,XBC                                            ; FC8F83  e9 62
	ld XIX,XBC                                           ; FC8F85  e9 8c
.LFC8F87:
	ld XBC,(XIZ+0x08)                                    ; FC8F87  ae 08 21
	ld A,(XBC)                                           ; FC8F8A  81 21
	mul A,0x07                                           ; FC8F8C  c9 08 07
	extz XWA                                             ; FC8F8F  e8 12
	inc 2,XWA                                            ; FC8F91  e8 62
	add XBC,XWA                                          ; FC8F93  e8 81
	ld (xiz-4), xbc                                      ; FC8F95  be fc 61
	ld XWA,XIX                                           ; FC8F98  ec 88
	cp XWA,XBC                                           ; FC8F9A  e9 f0
	jr nc, .LFC8FD1                                      ; FC8F9C  6f 33
	ld C,(XIX+0x02)                                      ; FC8F9E  8c 02 23
	cp c, 0x00:i3                                          ; FC8FA1  cb d8
	jr z, .LFC8FCD                                       ; FC8FA3  66 28
	extz XDE                                             ; FC8FA5  ea 12
	ld HL,(XDE+0x0b)                                     ; FC8FA7  9a 0b 23
	jr .LFC8FC9                                          ; FC8FAA  68 1d
.LFC8FAC:
	ld C,(XIX)                                           ; FC8FAC  84 23
	ld (xiz-2), c                                        ; FC8FAE  be fe 43
	extz XHL                                             ; FC8FB1  eb 12
	ld A,(XHL+0x02)                                      ; FC8FB3  8b 02 21
	cp A,C                                               ; FC8FB6  cb f1
	jr nz, .LFC8FC4                                      ; FC8FB8  6e 0a
	ld XBC,(XIX+0x03)                                    ; FC8FBA  ac 03 21
	extz XHL                                             ; FC8FBD  eb 12
	ld (XHL+0x05),XBC                                    ; FC8FBF  bb 05 61
	jr .LFC8FCD                                          ; FC8FC2  68 09
.LFC8FC4:
	extz XHL                                             ; FC8FC4  eb 12
	ld HL,(XHL+0x0b)                                     ; FC8FC6  9b 0b 23
.LFC8FC9:
	cp HL,DE                                             ; FC8FC9  da f3
	jr nz, .LFC8FAC                                      ; FC8FCB  6e df
.LFC8FCD:
	inc 7,XIX                                            ; FC8FCD  ec 67
	jr .LFC8F87                                          ; FC8FCF  68 b6
.LFC8FD1:
	pop XIX                                              ; FC8FD1  5c
	pop XDE                                              ; FC8FD2  5a
	pop XHL                                              ; FC8FD3  5b
	unlk XIZ                                             ; FC8FD4  ee 0d
	ret                                                  ; FC8FD6  0e
; ToneGen_SendSoundSelNote: T_ToneGen_SendSoundSelNote (-, note, velocity): [0x90, SoundSel_Group | 0xF0, note, velocity] over the link
;   (T_Link_SendBlockIn32ByteChunks).  SineWaveCheck_ServiceSwitches plays notes 0x3C..0x3F with it, velocity 0x7F
;   while a switch is held and 0 on release.
ToneGen_SendSoundSelNote:
	link XIZ,0xfffc                                      ; FC8FD7  ee 0c fc ff
	push XIX                                             ; FC8FDB  3c
	lda xix, (NoteSend_MsgBuffer:24)                               ; FC8FDC  f2 00 20 60 34
	ld (XIX),0x90                                        ; FC8FE1  b4 00 90
	ld XBC,XIX                                           ; FC8FE4  ec 89
	inc 1,XBC                                            ; FC8FE6  e9 61
	ld (xiz-4), xbc                                      ; FC8FE8  be fc 61
	ld a, (SoundSel_Group:16)                                   ; FC8FEB  c1 69 21 21
	or A,0xf0                                            ; FC8FEF  c9 ce f0
	ld (XBC),A                                           ; FC8FF2  b1 41
	ld C,(XIZ+0x0a)                                      ; FC8FF4  8e 0a 23
	ld (XIX+0x02),C                                      ; FC8FF7  bc 02 43
	ld C,(XIZ+0x0c)                                      ; FC8FFA  8e 0c 23
	ld (XIX+0x03),C                                      ; FC8FFD  bc 03 43
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FC9000  f2 00 20 60 31
	push XBC                                             ; FC9005  39
	pushw 0x04                                           ; FC9006  0b 04 00
	pushw 0x00                                           ; FC9009  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC900C  1d d4 0e f4
	inc 8,XSP                                            ; FC9010  ef 60
	pop XIX                                              ; FC9012  5c
	unlk XIZ                                             ; FC9013  ee 0d
	ret                                                  ; FC9015  0e
; MidiOut_SendNote: T_MidiOut_SendNote (channel 0..31, note, velocity): the 3-byte message [0x90 | channel & 0x0F, note, velocity] on MIDI OUT A
;   (channels 0-15: Ring601432_PutBlock, MIDI_PostSendWork) or B (16-31: Ring60153C_PutBlock, _PortB), with
;   interrupts held at level 6.  SineWaveCheck_ServiceSwitches sends channel 0 with it.
MidiOut_SendNote:
	link XIZ,0xfffc                                      ; FC9016  ee 0c fc ff
	pushw hl                                             ; FC901A  2b
	push XIX                                             ; FC901B  3c
	ld H,(XIZ+0x08)                                      ; FC901C  8e 08 26
	lda xix, (NoteSend_MsgBuffer:24)                               ; FC901F  f2 00 20 60 34
	cp H,0x10                                            ; FC9024  ce cf 10
	jr nc, .LFC905E                                      ; FC9027  6f 35
	ld C,H                                               ; FC9029  ce 8b
	or C,0x90                                            ; FC902B  cb ce 90
	ld (XIX),C                                           ; FC902E  b4 43
	ld XBC,XIX                                           ; FC9030  ec 89
	inc 1,XBC                                            ; FC9032  e9 61
	ld (xiz-4), xbc                                      ; FC9034  be fc 61
	ld A,(XIZ+0x0a)                                      ; FC9037  8e 0a 21
	ld (XBC),A                                           ; FC903A  b1 41
	ld xbc, (xiz-4)                                      ; FC903C  ae fc 21
	ld A,(XIZ+0x0c)                                      ; FC903F  8e 0c 21
	ld (XBC+0x01),A                                      ; FC9042  b9 01 41
	ei 0x06                                              ; FC9045  06 06
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FC9047  f2 00 20 60 31
	push XBC                                             ; FC904C  39
	pushw 0x03                                           ; FC904D  0b 03 00
	call T_Ring601432_PutBlock                           ; FC9050  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FC9054  1d 24 07 f4
	inc 6,XSP                                            ; FC9058  ef 66
	ei 0x00                                              ; FC905A  06 00
	jr .LFC9094                                          ; FC905C  68 36
.LFC905E:
	ld C,H                                               ; FC905E  ce 8b
	and C,0x0f                                           ; FC9060  cb cc 0f
	or C,0x90                                            ; FC9063  cb ce 90
	ld (XIX),C                                           ; FC9066  b4 43
	ld XBC,XIX                                           ; FC9068  ec 89
	inc 1,XBC                                            ; FC906A  e9 61
	ld (xiz-4), xbc                                      ; FC906C  be fc 61
	ld A,(XIZ+0x0a)                                      ; FC906F  8e 0a 21
	ld (XBC),A                                           ; FC9072  b1 41
	ld xbc, (xiz-4)                                      ; FC9074  ae fc 21
	ld A,(XIZ+0x0c)                                      ; FC9077  8e 0c 21
	ld (XBC+0x01),A                                      ; FC907A  b9 01 41
	ei 0x06                                              ; FC907D  06 06
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FC907F  f2 00 20 60 31
	push XBC                                             ; FC9084  39
	pushw 0x03                                           ; FC9085  0b 03 00
	call T_Ring60153C_PutBlock                           ; FC9088  1d 1c 1e f4
	call T_MIDI_PostSendWork_PortB                       ; FC908C  1d 30 07 f4
	inc 6,XSP                                            ; FC9090  ef 66
	ei 0x00                                              ; FC9092  06 00
.LFC9094:
	pop XIX                                              ; FC9094  5c
	popw hl                                              ; FC9095  4b
	unlk XIZ                                             ; FC9096  ee 0d
	ret                                                  ; FC9098  0e
; Ring601850_GatherFrame: up to 16 (note, velocity) pairs from T_Ring601850_Get into the frame's entries; the pending record as above.
Ring601850_GatherFrame:
	link XIZ,0xfffc                                      ; FC9099  ee 0c fc ff
	pushw hl                                             ; FC909D  2b
	pushw de                                             ; FC909E  2a
	push XIX                                             ; FC909F  3c
	ld XIX,(XIZ+0x0c)                                    ; FC90A0  ae 0c 24
	inc 2,XIX                                            ; FC90A3  ec 62
	ld XBC,(XIZ+0x0c)                                    ; FC90A5  ae 0c 21
	ld (XBC+0x01),0x00                                   ; FC90A8  b9 01 00 00
	ld XBC,(XIZ+0x0c)                                    ; FC90AC  ae 0c 21
	ld (XBC),0x00                                        ; FC90AF  b1 00 00
	ld XBC,(XIZ+0x08)                                    ; FC90B2  ae 08 21
	ld A,(XBC)                                           ; FC90B5  81 21
	extz WA                                              ; FC90B7  d8 12
	cp WA,0x0080                                         ; FC90B9  d8 cf 80 00
	jr z, .LFC90E3                                       ; FC90BD  66 24
	cp WA,0x00ff                                         ; FC90BF  d8 cf ff 00
	jrl z, .LFC9151                                      ; FC90C3  76 8b 00
	ld XBC,(XIZ+0x08)                                    ; FC90C6  ae 08 21
	ld A,(XBC+0x03)                                      ; FC90C9  89 03 21
	ld (XIX),A                                           ; FC90CC  b4 41
	ld XBC,(XIZ+0x08)                                    ; FC90CE  ae 08 21
	ld A,(XBC+0x04)                                      ; FC90D1  89 04 21
	ld (XIX+0x02),A                                      ; FC90D4  bc 02 41
	sub XBC,XBC                                          ; FC90D7  e9 a1
	ld (XIX+0x03),XBC                                    ; FC90D9  bc 03 61
	inc 7,XIX                                            ; FC90DC  ec 67
	ld XBC,(XIZ+0x0c)                                    ; FC90DE  ae 0c 21
	incm8 0x01, (xbc)                                    ; FC90E1  81 61
.LFC90E3:
	ld XBC,(XIZ+0x08)                                    ; FC90E3  ae 08 21
	ld A,(XBC)                                           ; FC90E6  81 21
	cp A,0xff                                            ; FC90E8  c9 cf ff
	jrl z, .LFC9151                                      ; FC90EB  76 63 00
	call T_Ring601850_Get                                ; FC90EE  1d 5c 1e f4
	ld DE,WA                                             ; FC90F2  d8 8a
	cp WA,0xffff                                         ; FC90F4  d8 cf ff ff
	jr z, .LFC9106                                       ; FC90F8  66 0c
	call T_Ring601850_Get                                ; FC90FA  1d 5c 1e f4
	ld HL,WA                                             ; FC90FE  d8 8b
	cp WA,0xffff                                         ; FC9100  d8 cf ff ff
	jr nz, .LFC910E                                      ; FC9104  6e 08
.LFC9106:
	ld XBC,(XIZ+0x08)                                    ; FC9106  ae 08 21
	ld (XBC),0xff                                        ; FC9109  b1 00 ff
	jr .LFC9151                                          ; FC910C  68 43
.LFC910E:
	ld XBC,(XIZ+0x0c)                                    ; FC910E  ae 0c 21
	ld A,(XBC)                                           ; FC9111  81 21
	cp A,0x10                                            ; FC9113  c9 cf 10
	jr nc, .LFC912F                                      ; FC9116  6f 17
	ld A,E                                               ; FC9118  cd 89
	ld (XIX),A                                           ; FC911A  b4 41
	ld C,L                                               ; FC911C  cf 8b
	ld (XIX+0x02),C                                      ; FC911E  bc 02 43
	sub XBC,XBC                                          ; FC9121  e9 a1
	ld (XIX+0x03),XBC                                    ; FC9123  bc 03 61
	inc 7,XIX                                            ; FC9126  ec 67
	ld XBC,(XIZ+0x0c)                                    ; FC9128  ae 0c 21
	incm8 0x01, (xbc)                                    ; FC912B  81 61
	jr .LFC90E3                                          ; FC912D  68 b4
.LFC912F:
	ld C,E                                               ; FC912F  cd 8b
	ld (xiz-2), c                                        ; FC9131  be fe 43
	ld XBC,(XIZ+0x08)                                    ; FC9134  ae 08 21
	ld a, (xiz-2)                                        ; FC9137  8e fe 21
	ld (XBC+0x03),A                                      ; FC913A  b9 03 41
	ld C,L                                               ; FC913D  cf 8b
	ld (xiz-4), c                                        ; FC913F  be fc 43
	ld XBC,(XIZ+0x08)                                    ; FC9142  ae 08 21
	ld a, (xiz-4)                                        ; FC9145  8e fc 21
	ld (XBC+0x04),A                                      ; FC9148  b9 04 41
	ld XBC,(XIZ+0x08)                                    ; FC914B  ae 08 21
	ld (XBC),0x00                                        ; FC914E  b1 00 00
.LFC9151:
	ld XBC,(XIZ+0x0c)                                    ; FC9151  ae 0c 21
	ld A,(XBC)                                           ; FC9154  81 21
	pop XIX                                              ; FC9156  5c
	popw de                                              ; FC9157  4a
	popw hl                                              ; FC9158  4b
	unlk XIZ                                             ; FC9159  ee 0d
	ret                                                  ; FC915B  0e
; MidiInA_GatherFrame: (pending, frame): frame = {count, kind 0x90 / 0xB0, 1, channel, entries of 9 bytes from +7: note, velocity};
;   consecutive note on / off messages on one channel, up to 0x20, or one control change; a message on another
;   channel stays in the 5-byte pending record (0 = none, 0xFF = the ring is empty).  A = the entry count.
MidiInA_GatherFrame:
	link XIZ,0xfff8                                      ; FC915C  ee 0c f8 ff
	pushw hl                                             ; FC9160  2b
	pushw de                                             ; FC9161  2a
	push XIX                                             ; FC9162  3c
	ld XIX,(XIZ+0x0c)                                    ; FC9163  ae 0c 24
	inc 7,XIX                                            ; FC9166  ec 67
	ld XBC,(XIZ+0x0c)                                    ; FC9168  ae 0c 21
	ld (XBC),0x00                                        ; FC916B  b1 00 00
	ld XBC,(XIZ+0x08)                                    ; FC916E  ae 08 21
	ld H,(XBC)                                           ; FC9171  81 26
	ld A,H                                               ; FC9173  ce 89
	extz WA                                              ; FC9175  d8 12
	cp wa, 0x00:i3                                         ; FC9177  d8 d8
	jr z, .LFC91B9                                       ; FC9179  66 3e
	cp WA,0x00ff                                         ; FC917B  d8 cf ff 00
	jrl z, .LFC9338                                      ; FC917F  76 b6 01
	ld XBC,(XIZ+0x0c)                                    ; FC9182  ae 0c 21
	ld (XBC+0x01),H                                      ; FC9185  b9 01 46
	ld XBC,(XIZ+0x0c)                                    ; FC9188  ae 0c 21
	ld (XBC+0x02),0x01                                   ; FC918B  b9 02 00 01
	ld XBC,(XIZ+0x08)                                    ; FC918F  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9192  89 01 21
	ld H,A                                               ; FC9195  c9 8e
	ld XWA,(XIZ+0x0c)                                    ; FC9197  ae 0c 20
	ld (XWA+0x03),H                                      ; FC919A  b8 03 46
	ld XBC,(XIZ+0x08)                                    ; FC919D  ae 08 21
	ld A,(XBC+0x03)                                      ; FC91A0  89 03 21
	ld (XIX),A                                           ; FC91A3  b4 41
	ld XBC,(XIZ+0x08)                                    ; FC91A5  ae 08 21
	ld A,(XBC+0x04)                                      ; FC91A8  89 04 21
	ld (XIX+0x01),A                                      ; FC91AB  bc 01 41
	add XIX,0x00000009                                   ; FC91AE  ec c8 09 00 00 00
	ld XBC,(XIZ+0x0c)                                    ; FC91B4  ae 0c 21
	incm8 0x01, (xbc)                                    ; FC91B7  81 61
.LFC91B9:
	ld XBC,(XIZ+0x08)                                    ; FC91B9  ae 08 21
	ld A,(XBC)                                           ; FC91BC  81 21
	cp A,0xff                                            ; FC91BE  c9 cf ff
	jrl z, .LFC9338                                      ; FC91C1  76 74 01
	call T_MidiInARing_Scan                               ; FC91C4  1d c0 1d f4
	ld HL,WA                                             ; FC91C8  d8 8b
	ld (xiz-6), wa                                       ; FC91CA  be fa 50
	cp HL,0xffff                                         ; FC91CD  db cf ff ff
	jr z, .LFC91EE                                       ; FC91D1  66 1b
	call T_MidiInARing_Scan                               ; FC91D3  1d c0 1d f4
	ld DE,WA                                             ; FC91D7  d8 8a
	cp WA,0xffff                                         ; FC91D9  d8 cf ff ff
	jr z, .LFC91EE                                       ; FC91DD  66 0f
	call T_MidiInARing_Scan                               ; FC91DF  1d c0 1d f4
	ld HL,WA                                             ; FC91E3  d8 8b
	ld (xiz-4), wa                                       ; FC91E5  be fc 50
	cp HL,0xffff                                         ; FC91E8  db cf ff ff
	jr nz, .LFC91F7                                      ; FC91EC  6e 09
.LFC91EE:
	ld XBC,(XIZ+0x08)                                    ; FC91EE  ae 08 21
	ld (XBC),0xff                                        ; FC91F1  b1 00 ff
	jrl .LFC9338                                         ; FC91F4  78 41 01
.LFC91F7:
	ld l, (xiz-6)                                        ; FC91F7  8e fa 27
	ld H,L                                               ; FC91FA  cf 8e
	and H,0xf0                                           ; FC91FC  ce cc f0
	cp H,0xb0                                            ; FC91FF  ce cf b0
	jr nz, .LFC9252                                      ; FC9202  6e 4e
	ld XBC,(XIZ+0x0c)                                    ; FC9204  ae 0c 21
	ld A,(XBC)                                           ; FC9207  81 21
	ld (xiz-8), a                                        ; FC9209  be f8 41
	ld XWA,(XIZ+0x08)                                    ; FC920C  ae 08 20
	ld (XWA),0xb0                                        ; FC920F  b0 00 b0
	ld H,L                                               ; FC9212  cf 8e
	and H,0x0f                                           ; FC9214  ce cc 0f
	ld XBC,(XIZ+0x08)                                    ; FC9217  ae 08 21
	ld (XBC+0x01),H                                      ; FC921A  b9 01 46
	cp	(xiz-8), 0x00                                ; FC921D  8e f8 3f 00
	jr nz, .LFC923A                                      ; FC9221  6e 17
	ld XBC,(XIZ+0x0c)                                    ; FC9223  ae 0c 21
	ld (XBC+0x01),0xb0                                   ; FC9226  b9 01 00 b0
	ld XBC,(XIZ+0x0c)                                    ; FC922A  ae 0c 21
	ld (XBC+0x02),0x01                                   ; FC922D  b9 02 00 01
	ld XBC,(XIZ+0x0c)                                    ; FC9231  ae 0c 21
	ld (XBC+0x03),H                                      ; FC9234  b9 03 46
	jrl .LFC92EA                                         ; FC9237  78 b0 00
.LFC923A:
	ld C,E                                               ; FC923A  cd 8b
	ld H,C                                               ; FC923C  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC923E  ae 08 21
	ld (XBC+0x03),H                                      ; FC9241  b9 03 46
	ld c, (xiz-4)                                        ; FC9244  8e fc 23
	ld H,C                                               ; FC9247  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC9249  ae 08 21
	ld (XBC+0x04),H                                      ; FC924C  b9 04 46
	jrl .LFC9338                                         ; FC924F  78 e6 00
.LFC9252:
	ld XBC,(XIZ+0x0c)                                    ; FC9252  ae 0c 21
	ld A,(XBC)                                           ; FC9255  81 21
	ld (xiz-1), a                                        ; FC9257  be ff 41
	cp a, 0x00:i3                                          ; FC925A  c9 d8
	jr nz, .LFC92AF                                      ; FC925C  6e 51
	ld XWA,(XIZ+0x08)                                    ; FC925E  ae 08 20
	ld (XWA),0x90                                        ; FC9261  b0 00 90
	ld C,L                                               ; FC9264  cf 8b
	and C,0x0f                                           ; FC9266  cb cc 0f
	ld L,C                                               ; FC9269  cb 8f
	ld XBC,(XIZ+0x08)                                    ; FC926B  ae 08 21
	ld (XBC+0x01),L                                      ; FC926E  b9 01 47
	ld XBC,(XIZ+0x08)                                    ; FC9271  ae 08 21
	ld A,(XBC)                                           ; FC9274  81 21
	ld L,A                                               ; FC9276  c9 8f
	ld XWA,(XIZ+0x0c)                                    ; FC9278  ae 0c 20
	ld (XWA+0x01),L                                      ; FC927B  b8 01 47
	ld XBC,(XIZ+0x0c)                                    ; FC927E  ae 0c 21
	ld (XBC+0x02),0x01                                   ; FC9281  b9 02 00 01
	ld XBC,(XIZ+0x08)                                    ; FC9285  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9288  89 01 21
	ld L,A                                               ; FC928B  c9 8f
	ld XWA,(XIZ+0x0c)                                    ; FC928D  ae 0c 20
	ld (XWA+0x03),L                                      ; FC9290  b8 03 47
	ld C,E                                               ; FC9293  cd 8b
	ld (XIX),C                                           ; FC9295  b4 43
	cp H,0x80                                            ; FC9297  ce cf 80
	jr nz, .LFC92A1                                      ; FC929A  6e 05
	ldw hl, 0x00                                         ; FC929C  33 00 00
	jr .LFC92A8                                          ; FC929F  68 07
.LFC92A1:
	ld c, (xiz-4)                                        ; FC92A1  8e fc 23
	extz BC                                              ; FC92A4  d9 12
	ld HL,BC                                             ; FC92A6  d9 8b
.LFC92A8:
	ld C,L                                               ; FC92A8  cf 8b
	ld (XIX+0x01),C                                      ; FC92AA  bc 01 43
	jr .LFC92EA                                          ; FC92AD  68 3b
.LFC92AF:
	ld H,L                                               ; FC92AF  cf 8e
	and H,0x0f                                           ; FC92B1  ce cc 0f
	ld XBC,(XIZ+0x08)                                    ; FC92B4  ae 08 21
	ld A,(XBC+0x01)                                      ; FC92B7  89 01 21
	cp H,A                                               ; FC92BA  c9 f6
	jr nz, .LFC92F8                                      ; FC92BC  6e 3a
	ld A,(XBC)                                           ; FC92BE  81 21
	cp A,0xb0                                            ; FC92C0  c9 cf b0
	jr z, .LFC92F8                                       ; FC92C3  66 33
	cp	(xiz-1), 0x20                                ; FC92C5  8e ff 3f 20
	jr nc, .LFC92F8                                      ; FC92C9  6f 2d
	ld A,E                                               ; FC92CB  cd 89
	ld (XIX),A                                           ; FC92CD  b4 41
	ld C,L                                               ; FC92CF  cf 8b
	and C,0xf0                                           ; FC92D1  cb cc f0
	cp C,0x80                                            ; FC92D4  cb cf 80
	jr nz, .LFC92DE                                      ; FC92D7  6e 05
	ldw hl, 0x00                                         ; FC92D9  33 00 00
	jr .LFC92E5                                          ; FC92DC  68 07
.LFC92DE:
	ld c, (xiz-4)                                        ; FC92DE  8e fc 23
	extz BC                                              ; FC92E1  d9 12
	ld HL,BC                                             ; FC92E3  d9 8b
.LFC92E5:
	ld C,L                                               ; FC92E5  cf 8b
	ld (XIX+0x01),C                                      ; FC92E7  bc 01 43
.LFC92EA:
	add XIX,0x00000009                                   ; FC92EA  ec c8 09 00 00 00
	ld XBC,(XIZ+0x0c)                                    ; FC92F0  ae 0c 21
	incm8 0x01, (xbc)                                    ; FC92F3  81 61
	jrl .LFC91B9                                         ; FC92F5  78 c1 fe
.LFC92F8:
	ld XBC,(XIZ+0x08)                                    ; FC92F8  ae 08 21
	ld (XBC),0x90                                        ; FC92FB  b1 00 90
	ld h, (xiz-6)                                        ; FC92FE  8e fa 26
	ld C,H                                               ; FC9301  ce 8b
	and C,0x0f                                           ; FC9303  cb cc 0f
	ld L,C                                               ; FC9306  cb 8f
	ld XBC,(XIZ+0x08)                                    ; FC9308  ae 08 21
	ld (XBC+0x01),L                                      ; FC930B  b9 01 47
	ld C,E                                               ; FC930E  cd 8b
	ld L,C                                               ; FC9310  cb 8f
	ld XBC,(XIZ+0x08)                                    ; FC9312  ae 08 21
	ld (XBC+0x03),L                                      ; FC9315  b9 03 47
	ld C,H                                               ; FC9318  ce 8b
	and C,0xf0                                           ; FC931A  cb cc f0
	cp C,0x80                                            ; FC931D  cb cf 80
	jr nz, .LFC9327                                      ; FC9320  6e 05
	ldw hl, 0x00                                         ; FC9322  33 00 00
	jr .LFC932E                                          ; FC9325  68 07
.LFC9327:
	ld c, (xiz-4)                                        ; FC9327  8e fc 23
	extz BC                                              ; FC932A  d9 12
	ld HL,BC                                             ; FC932C  d9 8b
.LFC932E:
	ld C,L                                               ; FC932E  cf 8b
	ld D,C                                               ; FC9330  cb 8c
	ld XBC,(XIZ+0x08)                                    ; FC9332  ae 08 21
	ld (XBC+0x04),D                                      ; FC9335  b9 04 44
.LFC9338:
	ld XBC,(XIZ+0x0c)                                    ; FC9338  ae 0c 21
	ld A,(XBC)                                           ; FC933B  81 21
	pop XIX                                              ; FC933D  5c
	popw de                                              ; FC933E  4a
	popw hl                                              ; FC933F  4b
	unlk XIZ                                             ; FC9340  ee 0d
	ret                                                  ; FC9342  0e
; MidiInB_GatherFrame: MidiInA_GatherFrame for MIDI IN B (T_MidiInBRing_Scan).
MidiInB_GatherFrame:
	link XIZ,0xfff8                                      ; FC9343  ee 0c f8 ff
	pushw hl                                             ; FC9347  2b
	pushw de                                             ; FC9348  2a
	push XIX                                             ; FC9349  3c
	ld XIX,(XIZ+0x0c)                                    ; FC934A  ae 0c 24
	inc 7,XIX                                            ; FC934D  ec 67
	ld XBC,(XIZ+0x0c)                                    ; FC934F  ae 0c 21
	ld (XBC),0x00                                        ; FC9352  b1 00 00
	ld XBC,(XIZ+0x08)                                    ; FC9355  ae 08 21
	ld H,(XBC)                                           ; FC9358  81 26
	ld A,H                                               ; FC935A  ce 89
	extz WA                                              ; FC935C  d8 12
	cp wa, 0x00:i3                                         ; FC935E  d8 d8
	jr z, .LFC93A0                                       ; FC9360  66 3e
	cp WA,0x00ff                                         ; FC9362  d8 cf ff 00
	jrl z, .LFC951D                                      ; FC9366  76 b4 01
	ld XBC,(XIZ+0x0c)                                    ; FC9369  ae 0c 21
	ld (XBC+0x01),H                                      ; FC936C  b9 01 46
	ld XBC,(XIZ+0x0c)                                    ; FC936F  ae 0c 21
	ld (XBC+0x02),0x01                                   ; FC9372  b9 02 00 01
	ld XBC,(XIZ+0x08)                                    ; FC9376  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9379  89 01 21
	ld H,A                                               ; FC937C  c9 8e
	ld XWA,(XIZ+0x0c)                                    ; FC937E  ae 0c 20
	ld (XWA+0x03),H                                      ; FC9381  b8 03 46
	ld XBC,(XIZ+0x08)                                    ; FC9384  ae 08 21
	ld A,(XBC+0x03)                                      ; FC9387  89 03 21
	ld (XIX),A                                           ; FC938A  b4 41
	ld XBC,(XIZ+0x08)                                    ; FC938C  ae 08 21
	ld A,(XBC+0x04)                                      ; FC938F  89 04 21
	ld (XIX+0x01),A                                      ; FC9392  bc 01 41
	add XIX,0x00000009                                   ; FC9395  ec c8 09 00 00 00
	ld XBC,(XIZ+0x0c)                                    ; FC939B  ae 0c 21
	incm8 0x01, (xbc)                                    ; FC939E  81 61
.LFC93A0:
	ld XBC,(XIZ+0x08)                                    ; FC93A0  ae 08 21
	ld A,(XBC)                                           ; FC93A3  81 21
	cp A,0xff                                            ; FC93A5  c9 cf ff
	jrl z, .LFC951D                                      ; FC93A8  76 72 01
	call T_MidiInBRing_Scan                               ; FC93AB  1d e4 1d f4
	ld HL,WA                                             ; FC93AF  d8 8b
	ld (xiz-6), wa                                       ; FC93B1  be fa 50
	cp HL,0xffff                                         ; FC93B4  db cf ff ff
	jr z, .LFC93D5                                       ; FC93B8  66 1b
	call T_MidiInBRing_Scan                               ; FC93BA  1d e4 1d f4
	ld DE,WA                                             ; FC93BE  d8 8a
	cp WA,0xffff                                         ; FC93C0  d8 cf ff ff
	jr z, .LFC93D5                                       ; FC93C4  66 0f
	call T_MidiInBRing_Scan                               ; FC93C6  1d e4 1d f4
	ld HL,WA                                             ; FC93CA  d8 8b
	ld (xiz-4), wa                                       ; FC93CC  be fc 50
	cp HL,0xffff                                         ; FC93CF  db cf ff ff
	jr nz, .LFC93DE                                      ; FC93D3  6e 09
.LFC93D5:
	ld XBC,(XIZ+0x08)                                    ; FC93D5  ae 08 21
	ld (XBC),0xff                                        ; FC93D8  b1 00 ff
	jrl .LFC951D                                         ; FC93DB  78 3f 01
.LFC93DE:
	ld h, (xiz-6)                                        ; FC93DE  8e fa 26
	ld L,H                                               ; FC93E1  ce 8f
	and L,0xf0                                           ; FC93E3  cf cc f0
	cp L,0xb0                                            ; FC93E6  cf cf b0
	jr nz, .LFC9435                                      ; FC93E9  6e 4a
	ld XBC,(XIZ+0x0c)                                    ; FC93EB  ae 0c 21
	ld L,(XBC)                                           ; FC93EE  81 27
	ld XWA,(XIZ+0x08)                                    ; FC93F0  ae 08 20
	ld (XWA),0xb0                                        ; FC93F3  b0 00 b0
	and H,0x0f                                           ; FC93F6  ce cc 0f
	add H,0x10                                           ; FC93F9  ce c8 10
	ld XBC,(XIZ+0x08)                                    ; FC93FC  ae 08 21
	ld (XBC+0x01),H                                      ; FC93FF  b9 01 46
	cp l, 0x00:i3                                          ; FC9402  cf d8
	jr nz, .LFC941D                                      ; FC9404  6e 17
	ld XBC,(XIZ+0x0c)                                    ; FC9406  ae 0c 21
	ld (XBC+0x01),0xb0                                   ; FC9409  b9 01 00 b0
	ld XBC,(XIZ+0x0c)                                    ; FC940D  ae 0c 21
	ld (XBC+0x02),0x01                                   ; FC9410  b9 02 00 01
	ld XBC,(XIZ+0x0c)                                    ; FC9414  ae 0c 21
	ld (XBC+0x03),H                                      ; FC9417  b9 03 46
	jrl .LFC94CC                                         ; FC941A  78 af 00
.LFC941D:
	ld C,E                                               ; FC941D  cd 8b
	ld H,C                                               ; FC941F  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC9421  ae 08 21
	ld (XBC+0x03),H                                      ; FC9424  b9 03 46
	ld c, (xiz-4)                                        ; FC9427  8e fc 23
	ld H,C                                               ; FC942A  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC942C  ae 08 21
	ld (XBC+0x04),H                                      ; FC942F  b9 04 46
	jrl .LFC951D                                         ; FC9432  78 e8 00
.LFC9435:
	ld XBC,(XIZ+0x0c)                                    ; FC9435  ae 0c 21
	ld A,(XBC)                                           ; FC9438  81 21
	ld (xiz-1), a                                        ; FC943A  be ff 41
	cp a, 0x00:i3                                          ; FC943D  c9 d8
	jr nz, .LFC9491                                      ; FC943F  6e 50
	ld XWA,(XIZ+0x08)                                    ; FC9441  ae 08 20
	ld (XWA),0x90                                        ; FC9444  b0 00 90
	ld C,H                                               ; FC9447  ce 8b
	and C,0x0f                                           ; FC9449  cb cc 0f
	ld H,C                                               ; FC944C  cb 8e
	add H,0x10                                           ; FC944E  ce c8 10
	ld XBC,(XIZ+0x08)                                    ; FC9451  ae 08 21
	ld (XBC+0x01),H                                      ; FC9454  b9 01 46
	ld XBC,(XIZ+0x08)                                    ; FC9457  ae 08 21
	ld A,(XBC)                                           ; FC945A  81 21
	ld (xiz-8), a                                        ; FC945C  be f8 41
	ld XWA,(XIZ+0x0c)                                    ; FC945F  ae 0c 20
	ld c, (xiz-8)                                        ; FC9462  8e f8 23
	ld (XWA+0x01),C                                      ; FC9465  b8 01 43
	ld XBC,(XIZ+0x0c)                                    ; FC9468  ae 0c 21
	ld (XBC+0x02),0x01                                   ; FC946B  b9 02 00 01
	ld XBC,(XIZ+0x0c)                                    ; FC946F  ae 0c 21
	ld (XBC+0x03),H                                      ; FC9472  b9 03 46
	ld C,E                                               ; FC9475  cd 8b
	ld (XIX),C                                           ; FC9477  b4 43
	cp L,0x80                                            ; FC9479  cf cf 80
	jr nz, .LFC9483                                      ; FC947C  6e 05
	ldw hl, 0x00                                         ; FC947E  33 00 00
	jr .LFC948A                                          ; FC9481  68 07
.LFC9483:
	ld c, (xiz-4)                                        ; FC9483  8e fc 23
	extz BC                                              ; FC9486  d9 12
	ld HL,BC                                             ; FC9488  d9 8b
.LFC948A:
	ld C,L                                               ; FC948A  cf 8b
	ld (XIX+0x01),C                                      ; FC948C  bc 01 43
	jr .LFC94CC                                          ; FC948F  68 3b
.LFC9491:
	ld L,H                                               ; FC9491  ce 8f
	and L,0x0f                                           ; FC9493  cf cc 0f
	ld XBC,(XIZ+0x08)                                    ; FC9496  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9499  89 01 21
	cp L,A                                               ; FC949C  c9 f7
	jr nz, .LFC94DA                                      ; FC949E  6e 3a
	ld A,(XBC)                                           ; FC94A0  81 21
	cp A,0xb0                                            ; FC94A2  c9 cf b0
	jr z, .LFC94DA                                       ; FC94A5  66 33
	cp	(xiz-1), 0x20                                ; FC94A7  8e ff 3f 20
	jr nc, .LFC94DA                                      ; FC94AB  6f 2d
	ld A,E                                               ; FC94AD  cd 89
	ld (XIX),A                                           ; FC94AF  b4 41
	ld C,H                                               ; FC94B1  ce 8b
	and C,0xf0                                           ; FC94B3  cb cc f0
	cp C,0x80                                            ; FC94B6  cb cf 80
	jr nz, .LFC94C0                                      ; FC94B9  6e 05
	ldw hl, 0x00                                         ; FC94BB  33 00 00
	jr .LFC94C7                                          ; FC94BE  68 07
.LFC94C0:
	ld c, (xiz-4)                                        ; FC94C0  8e fc 23
	extz BC                                              ; FC94C3  d9 12
	ld HL,BC                                             ; FC94C5  d9 8b
.LFC94C7:
	ld C,L                                               ; FC94C7  cf 8b
	ld (XIX+0x01),C                                      ; FC94C9  bc 01 43
.LFC94CC:
	add XIX,0x00000009                                   ; FC94CC  ec c8 09 00 00 00
	ld XBC,(XIZ+0x0c)                                    ; FC94D2  ae 0c 21
	incm8 0x01, (xbc)                                    ; FC94D5  81 61
	jrl .LFC93A0                                         ; FC94D7  78 c6 fe
.LFC94DA:
	ld XBC,(XIZ+0x08)                                    ; FC94DA  ae 08 21
	ld (XBC),0x90                                        ; FC94DD  b1 00 90
	ld h, (xiz-6)                                        ; FC94E0  8e fa 26
	ld C,H                                               ; FC94E3  ce 8b
	and C,0x0f                                           ; FC94E5  cb cc 0f
	add C,0x10                                           ; FC94E8  cb c8 10
	ld L,C                                               ; FC94EB  cb 8f
	ld XBC,(XIZ+0x08)                                    ; FC94ED  ae 08 21
	ld (XBC+0x01),L                                      ; FC94F0  b9 01 47
	ld C,E                                               ; FC94F3  cd 8b
	ld L,C                                               ; FC94F5  cb 8f
	ld XBC,(XIZ+0x08)                                    ; FC94F7  ae 08 21
	ld (XBC+0x03),L                                      ; FC94FA  b9 03 47
	ld C,H                                               ; FC94FD  ce 8b
	and C,0xf0                                           ; FC94FF  cb cc f0
	cp C,0x80                                            ; FC9502  cb cf 80
	jr nz, .LFC950C                                      ; FC9505  6e 05
	ldw hl, 0x00                                         ; FC9507  33 00 00
	jr .LFC9513                                          ; FC950A  68 07
.LFC950C:
	ld c, (xiz-4)                                        ; FC950C  8e fc 23
	extz BC                                              ; FC950F  d9 12
	ld HL,BC                                             ; FC9511  d9 8b
.LFC9513:
	ld C,L                                               ; FC9513  cf 8b
	ld D,C                                               ; FC9515  cb 8c
	ld XBC,(XIZ+0x08)                                    ; FC9517  ae 08 21
	ld (XBC+0x04),D                                      ; FC951A  b9 04 44
.LFC951D:
	ld XBC,(XIZ+0x0c)                                    ; FC951D  ae 0c 21
	ld A,(XBC)                                           ; FC9520  81 21
	pop XIX                                              ; FC9522  5c
	popw de                                              ; FC9523  4a
	popw hl                                              ; FC9524  4b
	unlk XIZ                                             ; FC9525  ee 0d
	ret                                                  ; FC9527  0e
; TimedEvents_GatherFrame: MidiInA_GatherFrame's shape over T_TimedEventRing_Scan.
TimedEvents_GatherFrame:
	link XIZ,0xfff0                                      ; FC9528  ee 0c f0 ff
	pushw hl                                             ; FC952C  2b
	pushw de                                             ; FC952D  2a
	pushw ix                                             ; FC952E  2c
	ld XBC,(XIZ+0x0c)                                    ; FC952F  ae 0c 21
	inc 7,XBC                                            ; FC9532  e9 67
	ld (xiz-10), xbc                                     ; FC9534  be f6 61
	ld XWA,(XIZ+0x0c)                                    ; FC9537  ae 0c 20
	ld (XWA),0x00                                        ; FC953A  b0 00 00
	ld XBC,(XIZ+0x08)                                    ; FC953D  ae 08 21
	ld H,(XBC)                                           ; FC9540  81 26
	ld A,H                                               ; FC9542  ce 89
	extz WA                                              ; FC9544  d8 12
	cp wa, 0x00:i3                                         ; FC9546  d8 d8
	jr z, .LFC959B                                       ; FC9548  66 51
	cp WA,0x00ff                                         ; FC954A  d8 cf ff 00
	jrl z, .LFC971B                                      ; FC954E  76 ca 01
	ld C,H                                               ; FC9551  ce 8b
	res 0x03,C                                           ; FC9553  cb 30 03
	ld H,C                                               ; FC9556  cb 8e
	ld XBC,(XIZ+0x0c)                                    ; FC9558  ae 0c 21
	ld (XBC+0x01),H                                      ; FC955B  b9 01 46
	ld XBC,(XIZ+0x0c)                                    ; FC955E  ae 0c 21
	ld (XBC+0x02),0x02                                   ; FC9561  b9 02 00 02
	ld XBC,(XIZ+0x08)                                    ; FC9565  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9568  89 01 21
	ld H,A                                               ; FC956B  c9 8e
	ld XWA,(XIZ+0x0c)                                    ; FC956D  ae 0c 20
	ld (XWA+0x03),H                                      ; FC9570  b8 03 46
	ld XBC,(XIZ+0x08)                                    ; FC9573  ae 08 21
	ld A,(XBC+0x03)                                      ; FC9576  89 03 21
	ld H,A                                               ; FC9579  c9 8e
	ld xwa, (xiz-10)                                     ; FC957B  ae f6 20
	ld (XWA),H                                           ; FC957E  b0 46
	ld XBC,(XIZ+0x08)                                    ; FC9580  ae 08 21
	ld A,(XBC+0x04)                                      ; FC9583  89 04 21
	ld H,A                                               ; FC9586  c9 8e
	ld xwa, (xiz-10)                                     ; FC9588  ae f6 20
	ld (XWA+0x01),H                                      ; FC958B  b8 01 46
	ld XBC,0x00000009                                    ; FC958E  41 09 00 00 00
	add (xiz-10), xbc                                    ; FC9593  ae f6 89
	ld XWA,(XIZ+0x0c)                                    ; FC9596  ae 0c 20
	incm8 0x01, (xwa)                                    ; FC9599  80 61
.LFC959B:
	ld XBC,(XIZ+0x08)                                    ; FC959B  ae 08 21
	ld A,(XBC)                                           ; FC959E  81 21
	cp A,0xff                                            ; FC95A0  c9 cf ff
	jrl z, .LFC971B                                      ; FC95A3  76 75 01
	call T_TimedEventRing_Scan                               ; FC95A6  1d 78 1d f4
	ld HL,WA                                             ; FC95AA  d8 8b
	cp WA,0xffff                                         ; FC95AC  d8 cf ff ff
	jr z, .LFC95E8                                       ; FC95B0  66 36
	call T_TimedEventRing_Scan                               ; FC95B2  1d 78 1d f4
	ld IX,WA                                             ; FC95B6  d8 8c
	cp WA,0xffff                                         ; FC95B8  d8 cf ff ff
	jr z, .LFC95E8                                       ; FC95BC  66 2a
	call T_TimedEventRing_Scan                               ; FC95BE  1d 78 1d f4
	ld DE,WA                                             ; FC95C2  d8 8a
	ld (xiz-6), wa                                       ; FC95C4  be fa 50
	cp DE,0xffff                                         ; FC95C7  da cf ff ff
	jr z, .LFC95E8                                       ; FC95CB  66 1b
	call T_TimedEventRing_Scan                               ; FC95CD  1d 78 1d f4
	ld DE,WA                                             ; FC95D1  d8 8a
	ld (xiz-4), wa                                       ; FC95D3  be fc 50
	cp DE,0xffff                                         ; FC95D6  da cf ff ff
	jr z, .LFC95E8                                       ; FC95DA  66 0c
	call T_TimedEventRing_Scan                               ; FC95DC  1d 78 1d f4
	ld DE,WA                                             ; FC95E0  d8 8a
	cp WA,0xffff                                         ; FC95E2  d8 cf ff ff
	jr nz, .LFC95F1                                      ; FC95E6  6e 09
.LFC95E8:
	ld XBC,(XIZ+0x08)                                    ; FC95E8  ae 08 21
	ld (XBC),0xff                                        ; FC95EB  b1 00 ff
	jrl .LFC971B                                         ; FC95EE  78 2a 01
.LFC95F1:
	ld_erpb_rr c, 0xf0                                   ; FC95F1  c7 f0 8b   ld C,IXL
	cp C,0x7f                                            ; FC95F4  cb cf 7f
	jr nz, .LFC9647                                      ; FC95F7  6e 4e
	ld XBC,(XIZ+0x0c)                                    ; FC95F9  ae 0c 21
	ld A,(XBC)                                           ; FC95FC  81 21
	ld (xiz-12), a                                       ; FC95FE  be f4 41
	ld W,L                                               ; FC9601  cf 88
	and W,0x08                                           ; FC9603  c8 cc 08
	or W,0xb0                                            ; FC9606  c8 ce b0
	ld XIY,(XIZ+0x08)                                    ; FC9609  ae 08 25
	ld (XIY),W                                           ; FC960C  b5 40
	cp	(xiz-12), 0x00                               ; FC960E  8e f4 3f 00
	jrl nz, .LFC96FB                                     ; FC9612  7e e6 00
	ld C,E                                               ; FC9615  cd 8b
	ld H,C                                               ; FC9617  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC9619  ae 08 21
	ld (XBC+0x01),H                                      ; FC961C  b9 01 46
	ld XBC,(XIZ+0x08)                                    ; FC961F  ae 08 21
	ld A,(XBC)                                           ; FC9622  81 21
	res 0x03,A                                           ; FC9624  c9 30 03
	ld H,A                                               ; FC9627  c9 8e
	ld XWA,(XIZ+0x0c)                                    ; FC9629  ae 0c 20
	ld (XWA+0x01),H                                      ; FC962C  b8 01 46
	ld XBC,(XIZ+0x0c)                                    ; FC962F  ae 0c 21
	ld (XBC+0x02),0x02                                   ; FC9632  b9 02 00 02
	ld XBC,(XIZ+0x08)                                    ; FC9636  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9639  89 01 21
	ld H,A                                               ; FC963C  c9 8e
	ld XWA,(XIZ+0x0c)                                    ; FC963E  ae 0c 20
	ld (XWA+0x03),H                                      ; FC9641  b8 03 46
	jrl .LFC96D8                                         ; FC9644  78 91 00
.LFC9647:
	ld XBC,(XIZ+0x0c)                                    ; FC9647  ae 0c 21
	ld A,(XBC)                                           ; FC964A  81 21
	ld (xiz-1), a                                        ; FC964C  be ff 41
	cp a, 0x00:i3                                          ; FC964F  c9 d8
	jr nz, .LFC969D                                      ; FC9651  6e 4a
	ld W,L                                               ; FC9653  cf 88
	and W,0x08                                           ; FC9655  c8 cc 08
	or W,0x90                                            ; FC9658  c8 ce 90
	ld XIY,(XIZ+0x08)                                    ; FC965B  ae 08 25
	ld (XIY),W                                           ; FC965E  b5 40
	ld C,E                                               ; FC9660  cd 8b
	ld (xiz-12), c                                       ; FC9662  be f4 43
	ld XBC,(XIZ+0x08)                                    ; FC9665  ae 08 21
	ld a, (xiz-12)                                       ; FC9668  8e f4 21
	ld (XBC+0x01),A                                      ; FC966B  b9 01 41
	ld XBC,(XIZ+0x08)                                    ; FC966E  ae 08 21
	ld A,(XBC)                                           ; FC9671  81 21
	res 0x03,A                                           ; FC9673  c9 30 03
	ld (xiz-14), a                                       ; FC9676  be f2 41
	ld XWA,(XIZ+0x0c)                                    ; FC9679  ae 0c 20
	ld c, (xiz-14)                                       ; FC967C  8e f2 23
	ld (XWA+0x01),C                                      ; FC967F  b8 01 43
	ld XBC,(XIZ+0x0c)                                    ; FC9682  ae 0c 21
	ld (XBC+0x02),0x02                                   ; FC9685  b9 02 00 02
	ld XBC,(XIZ+0x08)                                    ; FC9689  ae 08 21
	ld A,(XBC+0x01)                                      ; FC968C  89 01 21
	ld (xiz-16), a                                       ; FC968F  be f0 41
	ld XWA,(XIZ+0x0c)                                    ; FC9692  ae 0c 20
	ld c, (xiz-16)                                       ; FC9695  8e f0 23
	ld (XWA+0x03),C                                      ; FC9698  b8 03 43
	jr .LFC96C3                                          ; FC969B  68 26
.LFC969D:
	ld (xiz-12), e                                       ; FC969D  be f4 45
	ld XBC,(XIZ+0x08)                                    ; FC96A0  ae 08 21
	ld A,(XBC+0x01)                                      ; FC96A3  89 01 21
	cp (xiz-12), a                                       ; FC96A6  8e f4 f9
	jr nz, .LFC96E8                                      ; FC96A9  6e 3d
	ld (xiz-12), l                                       ; FC96AB  be f4 47
	ld A,(XBC)                                           ; FC96AE  81 21
	ld (xiz-2), a                                        ; FC96B0  be fe 41
	cp (xiz-12), a                                       ; FC96B3  8e f4 f9
	jr nz, .LFC96E8                                      ; FC96B6  6e 30
	cp A,0xb0                                            ; FC96B8  c9 cf b0
	jr z, .LFC96E8                                       ; FC96BB  66 2b
	cp	(xiz-1), 0x20                                ; FC96BD  8e ff 3f 20
	jr nc, .LFC96E8                                      ; FC96C1  6f 25
.LFC96C3:
	ld c, (xiz-6)                                        ; FC96C3  8e fa 23
	ld H,C                                               ; FC96C6  cb 8e
	ld xbc, (xiz-10)                                     ; FC96C8  ae f6 21
	ld (XBC),H                                           ; FC96CB  b1 46
	ld c, (xiz-4)                                        ; FC96CD  8e fc 23
	ld H,C                                               ; FC96D0  cb 8e
	ld xbc, (xiz-10)                                     ; FC96D2  ae f6 21
	ld (XBC+0x01),H                                      ; FC96D5  b9 01 46
.LFC96D8:
	ld XBC,0x00000009                                    ; FC96D8  41 09 00 00 00
	add (xiz-10), xbc                                    ; FC96DD  ae f6 89
	ld XWA,(XIZ+0x0c)                                    ; FC96E0  ae 0c 20
	incm8 0x01, (xwa)                                    ; FC96E3  80 61
	jrl .LFC959B                                         ; FC96E5  78 b3 fe
.LFC96E8:
	ld C,L                                               ; FC96E8  cf 8b
	and C,0x08                                           ; FC96EA  cb cc 08
	or C,0x90                                            ; FC96ED  cb ce 90
	ld (xiz-12), c                                       ; FC96F0  be f4 43
	ld XBC,(XIZ+0x08)                                    ; FC96F3  ae 08 21
	ld a, (xiz-12)                                       ; FC96F6  8e f4 21
	ld (XBC),A                                           ; FC96F9  b1 41
.LFC96FB:
	ld C,E                                               ; FC96FB  cd 8b
	ld H,C                                               ; FC96FD  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC96FF  ae 08 21
	ld (XBC+0x01),H                                      ; FC9702  b9 01 46
	ld c, (xiz-6)                                        ; FC9705  8e fa 23
	ld H,C                                               ; FC9708  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC970A  ae 08 21
	ld (XBC+0x03),H                                      ; FC970D  b9 03 46
	ld c, (xiz-4)                                        ; FC9710  8e fc 23
	ld H,C                                               ; FC9713  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC9715  ae 08 21
	ld (XBC+0x04),H                                      ; FC9718  b9 04 46
.LFC971B:
	ld XBC,(XIZ+0x0c)                                    ; FC971B  ae 0c 21
	ld A,(XBC)                                           ; FC971E  81 21
	popw ix                                              ; FC9720  4c
	popw de                                              ; FC9721  4a
	popw hl                                              ; FC9722  4b
	unlk XIZ                                             ; FC9723  ee 0d
	ret                                                  ; FC9725  0e
NoteChange_Kind1_Nop:
	ret                                                  ; FC9726  0e
; NoteChange_ReleasePartReceivedNotes: kind 0 (part, new channel, old channel), queued when a part's MIDI channel (block +0x22) or its receive bit (bit 6
;   of its MIDI record, +0x152) changed: unless the old channel or the part is 0xFF, the part's notes from MIDI IN
;   (source 1) on the old channel become note-offs (PartNotes_BuildReleaseFrame, all three outputs) and go to the tone
;   generator / MIDI OUT / record buffer as its result selects.
NoteChange_ReleasePartReceivedNotes:
	link XIZ,0xfed8                                      ; FC9727  ee 0c d8 fe
	pushw hl                                             ; FC972B  2b
	push XIX                                             ; FC972C  3c
	lda xix, (xiz-296)                                   ; FC972D  f3 f9 d8 fe 34
	ld L,(XIZ+0x0c)                                      ; FC9732  8e 0c 27
	cp (XIZ+0x0a),0xff                                   ; FC9735  8e 0a 3f ff
	jr nz, .LFC9740                                      ; FC9739  6e 05
	cp L,0xff                                            ; FC973B  cf cf ff
	jr nz, .LFC974B                                      ; FC973E  6e 0b
.LFC9740:
	cp (XIZ+0x0a),0xff                                   ; FC9740  8e 0a 3f ff
	jr z, .LFC9791                                       ; FC9744  66 4b
	cp L,0xff                                            ; FC9746  cf cf ff
	jr z, .LFC9791                                       ; FC9749  66 46
.LFC974B:
	cp (XIZ+0x08),0xff                                   ; FC974B  8e 08 3f ff
	jr z, .LFC9791                                       ; FC974F  66 40
	ld (XIX+0x02),0x01                                   ; FC9751  bc 02 00 01
	ld (XIX+0x03),L                                      ; FC9755  bc 03 47
	ld (XIX),0x00                                        ; FC9758  b4 00 00
	push 0x00                                            ; FC975B  09 00
	push	(xiz+8)                                      ; FC975D  8e 08 04
	pushw 0x07                                           ; FC9760  0b 07 00
	push XIX                                             ; FC9763  3c
	call PartNotes_BuildReleaseFrame                                      ; FC9764  1d 75 a4 fc
	ld H,A                                               ; FC9768  c9 8e
	and A,0x01                                           ; FC976A  c9 cc 01
	inc 8,XSP                                            ; FC976D  ef 60
	jr z, .LFC9777                                       ; FC976F  66 06
	push XIX                                             ; FC9771  3c
	call PartFrame_SendToToneGen                                      ; FC9772  1d bb a6 fc
	pop XIY                                              ; FC9776  5d
.LFC9777:
	ld C,H                                               ; FC9777  ce 8b
	and C,0x02                                           ; FC9779  cb cc 02
	jr z, .LFC9784                                       ; FC977C  66 06
	push XIX                                             ; FC977E  3c
	call PartFrame_SendToMidiOut                                      ; FC977F  1d 98 aa fc
	pop XIY                                              ; FC9783  5d
.LFC9784:
	ld C,H                                               ; FC9784  ce 8b
	and C,0x04                                           ; FC9786  cb cc 04
	jr z, .LFC9791                                       ; FC9789  66 06
	push XIX                                             ; FC978B  3c
	call PartFrame_RecordToSeqBuf                                      ; FC978C  1d aa ac fc
	pop XIY                                              ; FC9790  5d
.LFC9791:
	pop XIX                                              ; FC9791  5c
	popw hl                                              ; FC9792  4b
	unlk XIZ                                             ; FC9793  ee 0d
	ret                                                  ; FC9795  0e
; NoteChange_ReleaseTrackNotesOfOldPart: kind 3 (track, new part, old part), queued when the part a track feeds (block +0x42, low 5 bits) changed: the
;   track's notes (source 2, channel key = the track) on the OLD part are released (mask 7) and the note-offs go to
;   the tone generator and MIDI OUT.
NoteChange_ReleaseTrackNotesOfOldPart:
	link XIZ,0xfed8                                      ; FC9796  ee 0c d8 fe
	pushw hl                                             ; FC979A  2b
	push XIX                                             ; FC979B  3c
	lda xix, (xiz-296)                                   ; FC979C  f3 f9 d8 fe 34
	ld L,(XIZ+0x0c)                                      ; FC97A1  8e 0c 27
	cp (XIZ+0x0a),0xff                                   ; FC97A4  8e 0a 3f ff
	jr z, .LFC97AF                                       ; FC97A8  66 05
	cp L,0xff                                            ; FC97AA  cf cf ff
	jr nz, .LFC97BA                                      ; FC97AD  6e 0b
.LFC97AF:
	cp (XIZ+0x0a),0xff                                   ; FC97AF  8e 0a 3f ff
	jr nz, .LFC97EC                                      ; FC97B3  6e 37
	cp L,0xff                                            ; FC97B5  cf cf ff
	jr z, .LFC97EC                                       ; FC97B8  66 32
.LFC97BA:
	ld (XIX+0x02),0x02                                   ; FC97BA  bc 02 00 02
	ld C,(XIZ+0x08)                                      ; FC97BE  8e 08 23
	ld (XIX+0x03),C                                      ; FC97C1  bc 03 43
	ld (XIX),0x00                                        ; FC97C4  b4 00 00
	pushw hl                                             ; FC97C7  2b
	pushw 0x07                                           ; FC97C8  0b 07 00
	push XIX                                             ; FC97CB  3c
	call PartNotes_BuildReleaseFrame                                      ; FC97CC  1d 75 a4 fc
	ld H,A                                               ; FC97D0  c9 8e
	and A,0x01                                           ; FC97D2  c9 cc 01
	inc 8,XSP                                            ; FC97D5  ef 60
	jr z, .LFC97DF                                       ; FC97D7  66 06
	push XIX                                             ; FC97D9  3c
	call PartFrame_SendToToneGen                                      ; FC97DA  1d bb a6 fc
	pop XIY                                              ; FC97DE  5d
.LFC97DF:
	ld C,H                                               ; FC97DF  ce 8b
	and C,0x02                                           ; FC97E1  cb cc 02
	jr z, .LFC97EC                                       ; FC97E4  66 06
	push XIX                                             ; FC97E6  3c
	call PartFrame_SendToMidiOut                                      ; FC97E7  1d 98 aa fc
	pop XIY                                              ; FC97EB  5d
.LFC97EC:
	pop XIX                                              ; FC97EC  5c
	popw hl                                              ; FC97ED  4b
	unlk XIZ                                             ; FC97EE  ee 0d
	ret                                                  ; FC97F0  0e
; NoteChange_ReleaseTrackMidiOutNotes: kind 2 (track, new channel, old channel), queued when a track's MIDI OUT channel (block +0x52) changed: unless
;   the old one is 0xFF, the track's notes (source 2, channel key = the track) on its part (BStore_TrackToPart) get
;   MIDI OUT note-offs (PartNotes_BuildReleaseFrame with mask 2, PartFrame_SendToMidiOut).
NoteChange_ReleaseTrackMidiOutNotes:
	link XIZ,0xfed8                                      ; FC97F1  ee 0c d8 fe
	pushw hl                                             ; FC97F5  2b
	push XIX                                             ; FC97F6  3c
	lda xix, (xiz-296)                                   ; FC97F7  f3 f9 d8 fe 34
	cp (XIZ+0x0a),0xff                                   ; FC97FC  8e 0a 3f ff
	jr z, .LFC9808                                       ; FC9800  66 06
	cp (XIZ+0x0c),0xff                                   ; FC9802  8e 0c 3f ff
	jr nz, .LFC9814                                      ; FC9806  6e 0c
.LFC9808:
	cp (XIZ+0x0a),0xff                                   ; FC9808  8e 0a 3f ff
	jr nz, .LFC984E                                      ; FC980C  6e 40
	cp (XIZ+0x0c),0xff                                   ; FC980E  8e 0c 3f ff
	jr z, .LFC984E                                       ; FC9812  66 3a
.LFC9814:
	ld BC,(XIZ+0x08)                                     ; FC9814  9e 08 21
	extz BC                                              ; FC9817  d9 12
	extz XBC                                             ; FC9819  e9 12
	add XBC,BStore_TrackToPart                                   ; FC981B  e9 c8 22 34 60 00
	ld H,(XBC)                                           ; FC9821  81 26
	cp H,0xff                                            ; FC9823  ce cf ff
	jr z, .LFC984E                                       ; FC9826  66 26
	ld (XIX+0x02),0x02                                   ; FC9828  bc 02 00 02
	ld C,(XIZ+0x08)                                      ; FC982C  8e 08 23
	ld (XIX+0x03),C                                      ; FC982F  bc 03 43
	ld (XIX),0x00                                        ; FC9832  b4 00 00
	push 0x00                                            ; FC9835  09 00
	push H                                               ; FC9837  ce 04
	pushw 0x02                                           ; FC9839  0b 02 00
	push XIX                                             ; FC983C  3c
	call PartNotes_BuildReleaseFrame                                      ; FC983D  1d 75 a4 fc
	and A,0x02                                           ; FC9841  c9 cc 02
	inc 8,XSP                                            ; FC9844  ef 60
	jr z, .LFC984E                                       ; FC9846  66 06
	push XIX                                             ; FC9848  3c
	call PartFrame_SendToMidiOut                                      ; FC9849  1d 98 aa fc
	pop XIY                                              ; FC984D  5d
.LFC984E:
	pop XIX                                              ; FC984E  5c
	popw hl                                              ; FC984F  4b
	unlk XIZ                                             ; FC9850  ee 0d
	ret                                                  ; FC9852  0e
NoteChange_PartToneGen_Nop:
	ret                                                  ; FC9853  0e
; NoteChange_ReleasePartTransmittedNotes: kind 5 (part, new channel, old channel), queued when a part's MIDI channel (+0x22) or its transmit bit (bit 5 of
;   its MIDI record) changed: unless the old channel or the part is 0xFF, the part's note-list notes -- sources 0 and 1,
;   whose channel key is the part itself (NoteFrame_SelectForPart writes it) -- get MIDI OUT note-offs (mask 2).
NoteChange_ReleasePartTransmittedNotes:
	link XIZ,0xfed8                                      ; FC9854  ee 0c d8 fe
	pushw hl                                             ; FC9858  2b
	pushw de                                             ; FC9859  2a
	push XIX                                             ; FC985A  3c
	lda xix, (xiz-296)                                   ; FC985B  f3 f9 d8 fe 34
	ld D,(XIZ+0x0c)                                      ; FC9860  8e 0c 24
	ld L,(XIZ+0x0a)                                      ; FC9863  8e 0a 27
	ld H,(XIZ+0x08)                                      ; FC9866  8e 08 26
	cp L,0xff                                            ; FC9869  cf cf ff
	jr z, .LFC9873                                       ; FC986C  66 05
	cp D,0xff                                            ; FC986E  cc cf ff
	jr nz, .LFC987D                                      ; FC9871  6e 0a
.LFC9873:
	cp L,0xff                                            ; FC9873  cf cf ff
	jr nz, .LFC98A5                                      ; FC9876  6e 2d
	cp D,0xff                                            ; FC9878  cc cf ff
	jr z, .LFC98A5                                       ; FC987B  66 28
.LFC987D:
	cp H,0xff                                            ; FC987D  ce cf ff
	jr z, .LFC98A5                                       ; FC9880  66 23
	ld (XIX+0x02),0x00                                   ; FC9882  bc 02 00 00
	ld (XIX+0x03),H                                      ; FC9886  bc 03 46
	ld (XIX),0x00                                        ; FC9889  b4 00 00
	push 0x00                                            ; FC988C  09 00
	push H                                               ; FC988E  ce 04
	pushw 0x02                                           ; FC9890  0b 02 00
	push XIX                                             ; FC9893  3c
	call PartNotes_BuildReleaseFrame                                      ; FC9894  1d 75 a4 fc
	and A,0x02                                           ; FC9898  c9 cc 02
	inc 8,XSP                                            ; FC989B  ef 60
	jr z, .LFC98A5                                       ; FC989D  66 06
	push XIX                                             ; FC989F  3c
	call PartFrame_SendToMidiOut                                      ; FC98A0  1d 98 aa fc
	pop XIY                                              ; FC98A4  5d
.LFC98A5:
	cp L,0xff                                            ; FC98A5  cf cf ff
	jr z, .LFC98AF                                       ; FC98A8  66 05
	cp D,0xff                                            ; FC98AA  cc cf ff
	jr nz, .LFC98B9                                      ; FC98AD  6e 0a
.LFC98AF:
	cp L,0xff                                            ; FC98AF  cf cf ff
	jr nz, .LFC98E1                                      ; FC98B2  6e 2d
	cp D,0xff                                            ; FC98B4  cc cf ff
	jr z, .LFC98E1                                       ; FC98B7  66 28
.LFC98B9:
	cp H,0xff                                            ; FC98B9  ce cf ff
	jr z, .LFC98E1                                       ; FC98BC  66 23
	ld (XIX+0x02),0x01                                   ; FC98BE  bc 02 00 01
	ld (XIX+0x03),H                                      ; FC98C2  bc 03 46
	ld (XIX),0x00                                        ; FC98C5  b4 00 00
	push 0x00                                            ; FC98C8  09 00
	push H                                               ; FC98CA  ce 04
	pushw 0x02                                           ; FC98CC  0b 02 00
	push XIX                                             ; FC98CF  3c
	call PartNotes_BuildReleaseFrame                                      ; FC98D0  1d 75 a4 fc
	and A,0x02                                           ; FC98D4  c9 cc 02
	inc 8,XSP                                            ; FC98D7  ef 60
	jr z, .LFC98E1                                       ; FC98D9  66 06
	push XIX                                             ; FC98DB  3c
	call PartFrame_SendToMidiOut                                      ; FC98DC  1d 98 aa fc
	pop XIY                                              ; FC98E0  5d
.LFC98E1:
	pop XIX                                              ; FC98E1  5c
	popw de                                              ; FC98E2  4a
	popw hl                                              ; FC98E3  4b
	unlk XIZ                                             ; FC98E4  ee 0d
	ret                                                  ; FC98E6  0e
; NoteChange_ReleaseRecordedNotesOfOldPart: kind 6 (track, new part, old part), queued when the part a track feeds changed: the old part's notes from any
;   source (frame source 0xFF) whose channel key is the old part get note-offs in the record buffer only (mask 4,
;   PartFrame_RecordToSeqBuf).
NoteChange_ReleaseRecordedNotesOfOldPart:
	link XIZ,0xfed8                                      ; FC98E7  ee 0c d8 fe
	pushw hl                                             ; FC98EB  2b
	push XIX                                             ; FC98EC  3c
	lda xix, (xiz-296)                                   ; FC98ED  f3 f9 d8 fe 34
	ld H,(XIZ+0x0c)                                      ; FC98F2  8e 0c 26
	cp (XIZ+0x0a),0xff                                   ; FC98F5  8e 0a 3f ff
	jr z, .LFC9900                                       ; FC98F9  66 05
	cp H,0xff                                            ; FC98FB  ce cf ff
	jr NZ,.LFC990B                                       ; FC98FE  6e 0b
.LFC9900:
	cp (XIZ+0x0a),0xff                                   ; FC9900  8e 0a 3f ff
	jr nz, .LFC992E                                      ; FC9904  6e 28
	cp H,0xff                                            ; FC9906  ce cf ff
	jr z, .LFC992E                                       ; FC9909  66 23
.LFC990B:
	ld (XIX+0x02),0xff                                   ; FC990B  bc 02 00 ff
	ld (XIX+0x03),H                                      ; FC990F  bc 03 46
	ld (XIX),0x00                                        ; FC9912  b4 00 00
	push 0x00                                            ; FC9915  09 00
	push H                                               ; FC9917  ce 04
	pushw 0x04                                           ; FC9919  0b 04 00
	push XIX                                             ; FC991C  3c
	call PartNotes_BuildReleaseFrame                                      ; FC991D  1d 75 a4 fc
	and A,0x04                                           ; FC9921  c9 cc 04
	inc 8,XSP                                            ; FC9924  ef 60
	jr z, .LFC992E                                       ; FC9926  66 06
	push XIX                                             ; FC9928  3c
	call PartFrame_RecordToSeqBuf                                      ; FC9929  1d aa ac fc
	pop XIY                                              ; FC992D  5d
.LFC992E:
	pop XIX                                              ; FC992E  5c
	popw hl                                              ; FC992F  4b
	unlk XIZ                                             ; FC9930  ee 0d
	ret                                                  ; FC9932  0e
; NoteChange_ReleaseMidiInChannelNotes: kind 7 (path, 0xFF, channel), queued when the MIDI IN mode (NoteRouting_MidiFlags bits 6-7) or
;   NoteRouting_SingleChannel changed.  Path 1: every note MIDI IN put on the note list (NoteList_BuildReleaseAllFrame,
;   source 1) is released through each part as NoteRouting_Previous routed it (NoteFrame_SelectForPart,
;   NoteRouting_ForPartFromMidiIn, PartNotes_ApplyFrame; the three outputs, MIDI OUT unless +0x293 bit 5).  Path 0:
;   each part that received on the channel (previous block: +0x22 = channel, record bit 6) releases its MIDI IN notes
;   on it (PartNotes_BuildReleaseFrame; tone generator and record buffer).
NoteChange_ReleaseMidiInChannelNotes:
	link XIZ,0xfe5a                                      ; FC9933  ee 0c 5a fe
	pushw hl                                             ; FC9937  2b
	pushw de                                             ; FC9938  2a
	push XIX                                             ; FC9939  3c
	cp (XIZ+0x08),0x01                                   ; FC993A  8e 08 3f 01
	jrl nz, .LFC9A09                                     ; FC993E  7e c8 00
	ld (xiz-113), 0x01                                   ; FC9941  be 8f 00 01
	ld (xiz-114), 0x00                                   ; FC9945  be 8e 00 00
	lda xbc, (xiz-114)                                   ; FC9949  be 8e 31
	push XBC                                             ; FC994C  39
	call NoteList_BuildReleaseAllFrame                                      ; FC994D  1d 46 9e fc
	extz WA                                              ; FC9951  d8 12
	extz XWA                                             ; FC9953  e8 12
	ld XIX,XWA                                           ; FC9955  e8 8c
	ld h, 0x00:opc                                          ; FC9957  26 00
	pop XIY                                              ; FC9959  5d
.LFC995A:
	ld XBC,XIX                                           ; FC995A  ec 89
	or XBC,XBC                                           ; FC995C  e9 e1
	jrl z, .LFC9A9B                                      ; FC995E  76 3a 01
	and XBC,0x00000001                                   ; FC9961  e9 cc 01 00 00 00
	jrl z, .LFC99F7                                      ; FC9967  76 8d 00
	push 0x00                                            ; FC996A  09 00
	push H                                               ; FC996C  ce 04
	lda xbc, (NoteRouting_Previous:24)                               ; FC996E  f2 00 26 60 31
	push XBC                                             ; FC9973  39
	lda xwa, (xiz-114)                                   ; FC9974  be 8e 30
	push XWA                                             ; FC9977  38
	lda xiy, (xiz-410)                                   ; FC9978  f3 f9 66 fe 35
	push XIY                                             ; FC997D  3d
	call NoteFrame_SelectForPart                                      ; FC997E  1d a3 9e fc
	inc 8,XSP                                            ; FC9982  ef 60
	inc 6,XSP                                            ; FC9984  ef 66
	cp a, 0x00:i3                                          ; FC9986  c9 d8
	jr z, .LFC99F7                                       ; FC9988  66 6d
	push 0x00                                            ; FC998A  09 00
	push H                                               ; FC998C  ce 04
	lda xbc, (NoteRouting_Previous:24)                               ; FC998E  f2 00 26 60 31
	push XBC                                             ; FC9993  39
	lda xwa, (xiz-422)                                   ; FC9994  f3 f9 5a fe 30
	push XWA                                             ; FC9999  38
	call NoteRouting_ForPartFromMidiIn                                      ; FC999A  1d c9 af fc
	push 0x00                                            ; FC999E  09 00
	push H                                               ; FC99A0  ce 04
	lda xbc, (xiz-422)                                   ; FC99A2  f3 f9 5a fe 31
	push XBC                                             ; FC99A7  39
	lda xwa, (xiz-410)                                   ; FC99A8  f3 f9 66 fe 30
	push XWA                                             ; FC99AD  38
	call PartNotes_ApplyFrame                                      ; FC99AE  1d 8b 9f fc
	ld L,A                                               ; FC99B2  c9 8f
	and A,0x01                                           ; FC99B4  c9 cc 01
	add XSP,0x00000014                                   ; FC99B7  ef c8 14 00 00 00
	cp a, 0x00:i3                                          ; FC99BD  c9 d8
	jr z, .LFC99CC                                       ; FC99BF  66 0b
	lda xbc, (xiz-410)                                   ; FC99C1  f3 f9 66 fe 31
	push XBC                                             ; FC99C6  39
	call PartFrame_SendToToneGen                                      ; FC99C7  1d bb a6 fc
	pop XIY                                              ; FC99CB  5d
.LFC99CC:
	ld C,L                                               ; FC99CC  cf 8b
	and C,0x02                                           ; FC99CE  cb cc 02
	jr z, .LFC99E5                                       ; FC99D1  66 12
	bit	5, (NoteRouting_MidiFlags:24)                             ; FC99D3  f2 93 24 60 cd
	jr nz, .LFC99E5                                      ; FC99D8  6e 0b
	lda xbc, (xiz-410)                                   ; FC99DA  f3 f9 66 fe 31
	push XBC                                             ; FC99DF  39
	call PartFrame_SendToMidiOut                                      ; FC99E0  1d 98 aa fc
	pop XIY                                              ; FC99E4  5d
.LFC99E5:
	ld C,L                                               ; FC99E5  cf 8b
	and C,0x04                                           ; FC99E7  cb cc 04
	jr z, .LFC99F7                                       ; FC99EA  66 0b
	lda xbc, (xiz-410)                                   ; FC99EC  f3 f9 66 fe 31
	push XBC                                             ; FC99F1  39
	call PartFrame_RecordToSeqBuf                                      ; FC99F2  1d aa ac fc
	pop XIY                                              ; FC99F6  5d
.LFC99F7:
	inc 1,H                                              ; FC99F7  ce 61
	ld XIY,XIX                                           ; FC99F9  ec 8d
	srl xiy, 0x01                                        ; FC99FB  ed ef 01
	ld XIX,XIY                                           ; FC99FE  ed 8c
	cp H,0x20                                            ; FC9A00  ce cf 20
	jrl c, .LFC995A                                      ; FC9A03  77 54 ff
	jrl .LFC9A9B                                         ; FC9A06  78 92 00
.LFC9A09:
	ld (xiz-408), 0x01                                   ; FC9A09  f3 f9 68 fe 00 01
	ld C,(XIZ+0x0c)                                      ; FC9A0F  8e 0c 23
	ld (xiz-407), c                                      ; FC9A12  f3 f9 69 fe 43
	ld (xiz-410), 0x00                                   ; FC9A17  f3 f9 66 fe 00 00
	ld h, 0x00:opc                                          ; FC9A1D  26 00
	ld XIX,0x00000022                                    ; FC9A1F  44 22 00 00 00
	ldw de, 0x00                                         ; FC9A24  32 00 00
.LFC9A27:
	lda xbc, (NoteRouting_Previous:24)                               ; FC9A27  f2 00 26 60 31
	add XBC,XIX                                          ; FC9A2C  ec 81
	ld L,(XBC)                                           ; FC9A2E  81 27
	ld a, (xiz-407)                                      ; FC9A30  c3 f9 69 fe 21
	cp L,A                                               ; FC9A35  c9 f7
	jr nz, .LFC9A8E                                      ; FC9A37  6e 55
	ld BC,DE                                             ; FC9A39  da 89
	extz XBC                                             ; FC9A3B  e9 12
	add XBC,0x00000152                                   ; FC9A3D  e9 c8 52 01 00 00
	add XBC,NoteRouting_Previous                                   ; FC9A43  e9 c8 00 26 60 00
	bit 6,(XBC)                                          ; FC9A49  b1 ce
	jr z, .LFC9A8E                                       ; FC9A4B  66 41
	ld (xiz-410), 0x00                                   ; FC9A4D  f3 f9 66 fe 00 00
	push 0x00                                            ; FC9A53  09 00
	push H                                               ; FC9A55  ce 04
	pushw 0x07                                           ; FC9A57  0b 07 00
	lda xbc, (xiz-410)                                   ; FC9A5A  f3 f9 66 fe 31
	push XBC                                             ; FC9A5F  39
	call PartNotes_BuildReleaseFrame                                      ; FC9A60  1d 75 a4 fc
	ld L,A                                               ; FC9A64  c9 8f
	inc 8,XSP                                            ; FC9A66  ef 60
	cp a, 0x00:i3                                          ; FC9A68  c9 d8
	jr z, .LFC9A8E                                       ; FC9A6A  66 22
	and A,0x01                                           ; FC9A6C  c9 cc 01
	jr z, .LFC9A7C                                       ; FC9A6F  66 0b
	lda xbc, (xiz-410)                                   ; FC9A71  f3 f9 66 fe 31
	push XBC                                             ; FC9A76  39
	call PartFrame_SendToToneGen                                      ; FC9A77  1d bb a6 fc
	pop XIY                                              ; FC9A7B  5d
.LFC9A7C:
	ld C,L                                               ; FC9A7C  cf 8b
	and C,0x04                                           ; FC9A7E  cb cc 04
	jr z, .LFC9A8E                                       ; FC9A81  66 0b
	lda xbc, (xiz-410)                                   ; FC9A83  f3 f9 66 fe 31
	push XBC                                             ; FC9A88  39
	call PartFrame_RecordToSeqBuf                                      ; FC9A89  1d aa ac fc
	pop XIY                                              ; FC9A8D  5d
.LFC9A8E:
	inc 1,XIX                                            ; FC9A8E  ec 61
	add DE,0x000a                                        ; FC9A90  da c8 0a 00
	inc 1,H                                              ; FC9A94  ce 61
	cp H,0x20                                            ; FC9A96  ce cf 20
	jr c, .LFC9A27                                       ; FC9A99  67 8c
.LFC9A9B:
	pop XIX                                              ; FC9A9B  5c
	popw de                                              ; FC9A9C  4a
	popw hl                                              ; FC9A9D  4b
	unlk XIZ                                             ; FC9A9E  ee 0d
	ret                                                  ; FC9AA0  0e
; NoteChange_ReleaseOldMidiOutScheme: kind 8 (old bit 5, 0xFF, old channel), queued when NoteRouting_MidiFlags bit 5 changed or NoteRouting_SingleChannel
;   changed while it stays set.  When source 0's note list holds notes: with 0 (MIDI OUT was per part) each part's
;   source-0 notes get MIDI OUT note-offs; with 1 (MIDI OUT carried source 0 on the one channel) the note list's
;   note-offs go out on the old channel (PartFrame_SendToMidiOut).  With 0, each part's source-1 notes then get MIDI
;   OUT note-offs too, when source 1's list holds notes.
NoteChange_ReleaseOldMidiOutScheme:
	link XIZ,0xfe4e                                      ; FC9AA1  ee 0c 4e fe
	pushw hl                                             ; FC9AA5  2b
	pushw de                                             ; FC9AA6  2a
	push XIX                                             ; FC9AA7  3c
	ld (xiz-118), 0x00                                   ; FC9AA8  be 8a 00 00
	ld (xiz-117), 0x00                                   ; FC9AAC  be 8b 00 00
	lda xbc, (xiz-118)                                   ; FC9AB0  be 8a 31
	push XBC                                             ; FC9AB3  39
	call NoteList_BuildReleaseAllFrame                                      ; FC9AB4  1d 46 9e fc
	pop XIY                                              ; FC9AB8  5d
	cp a, 0x00:i3                                          ; FC9AB9  c9 d8
	jrl z, .LFC9BB9                                      ; FC9ABB  76 fb 00
	cp (XIZ+0x08),0x00                                   ; FC9ABE  8e 08 3f 00
	jr nz, .LFC9B0A                                      ; FC9AC2  6e 46
	ld (xiz-412), 0x00                                   ; FC9AC4  f3 f9 64 fe 00 00
	ld (xiz-411), 0x00                                   ; FC9ACA  f3 f9 65 fe 00 00
	ld h, 0x00:opc                                          ; FC9AD0  26 00
.LFC9AD2:
	ld (xiz-414), 0x00                                   ; FC9AD2  f3 f9 62 fe 00 00
	push 0x00                                            ; FC9AD8  09 00
	push H                                               ; FC9ADA  ce 04
	pushw 0x02                                           ; FC9ADC  0b 02 00
	lda xbc, (xiz-414)                                   ; FC9ADF  f3 f9 62 fe 31
	push XBC                                             ; FC9AE4  39
	call PartNotes_BuildReleaseFrame                                      ; FC9AE5  1d 75 a4 fc
	and A,0x02                                           ; FC9AE9  c9 cc 02
	inc 8,XSP                                            ; FC9AEC  ef 60
	jr z, .LFC9AFB                                       ; FC9AEE  66 0b
	lda xbc, (xiz-414)                                   ; FC9AF0  f3 f9 62 fe 31
	push XBC                                             ; FC9AF5  39
	call PartFrame_SendToMidiOut                                      ; FC9AF6  1d 98 aa fc
	pop XIY                                              ; FC9AFA  5d
.LFC9AFB:
	inc 1,H                                              ; FC9AFB  ce 61
	incm8 0x01, (xiz-411)                                ; FC9AFD  c3 f9 65 fe 61
	cp H,0x20                                            ; FC9B02  ce cf 20
	jr c, .LFC9AD2                                       ; FC9B05  67 cb
	jrl .LFC9BB9                                         ; FC9B07  78 af 00
.LFC9B0A:
	ld c, (xiz-118)                                      ; FC9B0A  8e 8a 23
	ld (xiz-414), c                                      ; FC9B0D  f3 f9 62 fe 43
	ldw hl, 0x00                                         ; FC9B12  33 00 00
	ld c, (xiz-118)                                      ; FC9B15  8e 8a 23
	extz BC                                              ; FC9B18  d9 12
	ld DE,BC                                             ; FC9B1A  d9 8a
	sub XWA,XWA                                          ; FC9B1C  e8 a0
	ld (xiz-4), xwa                                      ; FC9B1E  be fc 60
	ld XIX,0x00000000                                    ; FC9B21  44 00 00 00 00
.LFC9B26:
	cp HL,DE                                             ; FC9B26  da f3
	jrl nc, .LFC9BAE                                     ; FC9B28  7f 83 00
	ld xbc, (xiz-4)                                      ; FC9B2B  ae fc 21
	ld (xiz-418), xbc                                    ; FC9B2E  f3 f9 5e fe 61
	ld (xiz-422), xbc                                    ; FC9B33  f3 f9 5a fe 61
	add XBC,0x0000000c                                   ; FC9B38  e9 c8 0c 00 00 00
	add XBC,XIZ                                          ; FC9B3E  ee 81
	ld A,(XIZ+0x0c)                                      ; FC9B40  8e 0c 21
	ld (xbc-414), a                                      ; FC9B43  f3 e5 62 fe 41
	ld (xiz-426), xix                                    ; FC9B48  f3 f9 56 fe 64
	ld xbc, (xiz-426)                                    ; FC9B4D  e3 f9 56 fe 21
	ld (xiz-430), xbc                                    ; FC9B52  f3 f9 52 fe 61
	inc 3,XBC                                            ; FC9B57  e9 63
	add XBC,XIZ                                          ; FC9B59  ee 81
	ld a, (xbc-118)                                      ; FC9B5B  89 8a 21
	ld (xiz-432), a                                      ; FC9B5E  f3 f9 50 fe 41
	ld xbc, (xiz-422)                                    ; FC9B63  e3 f9 5a fe 21
	add XBC,0x0000000d                                   ; FC9B68  e9 c8 0d 00 00 00
	add XBC,XIZ                                          ; FC9B6E  ee 81
	ld (xbc-414), a                                      ; FC9B70  f3 e5 62 fe 41
	ld xbc, (xiz-430)                                    ; FC9B75  e3 f9 52 fe 21
	inc 4,XBC                                            ; FC9B7A  e9 64
	add XBC,XIZ                                          ; FC9B7C  ee 81
	ld a, (xbc-118)                                      ; FC9B7E  89 8a 21
	ld (xiz-434), a                                      ; FC9B81  f3 f9 4e fe 41
	ld xbc, (xiz-422)                                    ; FC9B86  e3 f9 5a fe 21
	inc 8,XBC                                            ; FC9B8B  e9 60
	add XBC,XIZ                                          ; FC9B8D  ee 81
	ld (xbc-414), a                                      ; FC9B8F  f3 e5 62 fe 41
	ld xbc, (xiz-418)                                    ; FC9B94  e3 f9 5e fe 21
	add XBC,0x00000009                                   ; FC9B99  e9 c8 09 00 00 00
	ld (xiz-4), xbc                                      ; FC9B9F  be fc 61
	ld xix, (xiz-426)                                    ; FC9BA2  e3 f9 56 fe 24
	inc 7,XIX                                            ; FC9BA7  ec 67
	inc 1,HL                                             ; FC9BA9  db 61
	jrl .LFC9B26                                         ; FC9BAB  78 78 ff
.LFC9BAE:
	lda xbc, (xiz-414)                                   ; FC9BAE  f3 f9 62 fe 31
	push XBC                                             ; FC9BB3  39
	call PartFrame_SendToMidiOut                                      ; FC9BB4  1d 98 aa fc
	pop XIY                                              ; FC9BB8  5d
.LFC9BB9:
	ld (xiz-118), 0x00                                   ; FC9BB9  be 8a 00 00
	ld (xiz-117), 0x01                                   ; FC9BBD  be 8b 00 01
	lda xbc, (xiz-118)                                   ; FC9BC1  be 8a 31
	push XBC                                             ; FC9BC4  39
	call NoteList_BuildReleaseAllFrame                                      ; FC9BC5  1d 46 9e fc
	pop XIY                                              ; FC9BC9  5d
	cp a, 0x00:i3                                          ; FC9BCA  c9 d8
	jr z, .LFC9C17                                       ; FC9BCC  66 49
	cp (XIZ+0x08),0x00                                   ; FC9BCE  8e 08 3f 00
	jr nz, .LFC9C17                                      ; FC9BD2  6e 43
	ld (xiz-412), 0x01                                   ; FC9BD4  f3 f9 64 fe 00 01
	ld (xiz-411), 0x00                                   ; FC9BDA  f3 f9 65 fe 00 00
	ld h, 0x00:opc                                          ; FC9BE0  26 00
.LFC9BE2:
	ld (xiz-414), 0x00                                   ; FC9BE2  f3 f9 62 fe 00 00
	push 0x00                                            ; FC9BE8  09 00
	push H                                               ; FC9BEA  ce 04
	pushw 0x02                                           ; FC9BEC  0b 02 00
	lda xbc, (xiz-414)                                   ; FC9BEF  f3 f9 62 fe 31
	push XBC                                             ; FC9BF4  39
	call PartNotes_BuildReleaseFrame                                      ; FC9BF5  1d 75 a4 fc
	and A,0x02                                           ; FC9BF9  c9 cc 02
	inc 8,XSP                                            ; FC9BFC  ef 60
	jr Z,.LFC9C0B                                        ; FC9BFE  66 0b
	lda xbc, (xiz-414)                                   ; FC9C00  f3 f9 62 fe 31
	push XBC                                             ; FC9C05  39
	call PartFrame_SendToMidiOut                                      ; FC9C06  1d 98 aa fc
	pop XIY                                              ; FC9C0A  5d
.LFC9C0B:
	inc 1,H                                              ; FC9C0B  ce 61
	incm8 0x01, (xiz-411)                                ; FC9C0D  c3 f9 65 fe 61
	cp H,0x20                                            ; FC9C12  ce cf 20
	jr c, .LFC9BE2                                       ; FC9C15  67 cb
.LFC9C17:
	pop XIX                                              ; FC9C17  5c
	popw de                                              ; FC9C18  4a
	popw hl                                              ; FC9C19  4b
	unlk XIZ                                             ; FC9C1A  ee 0d
	ret                                                  ; FC9C1C  0e
; NoteList_ApplyFrame: (note frame, part block): for each entry -- velocity non-zero: a node from the free list (head 0x384A) when the
;   source's count (0x3820 + source) is above 0, the voice mask from the part block (0x602054 table), byte +1 from
;   Note_TransposeFoldOctaves, the node moved to the source's list (0x3823 + source x 13) and the entry copied into
;   it; velocity 0: the source's node with the same note moved back to the free list, its count + 1, its voice mask
;   ORed into the result; otherwise the entry = 0xFF, 0xFF.  XIY = the released voices.
NoteList_ApplyFrame:
	link XIZ,0xffe6                                      ; FC9C1D  ee 0c e6 ff
	push XHL                                             ; FC9C21  3b
	pushw de                                             ; FC9C22  2a
	push XIX                                             ; FC9C23  3c
	ld XBC,(XIZ+0x08)                                    ; FC9C24  ae 08 21
	ld E,(XBC+0x01)                                      ; FC9C27  89 01 25
	ld a, 0x0d:opc                                          ; FC9C2A  21 0d
	mul wa, e                                          ; FC9C2C  cd 41
	ld IX,WA                                             ; FC9C2E  d8 8c
	ldw bc, NoteList_Heads                                       ; FC9C30  31 23 38
	ld (xiz-20), bc                                      ; FC9C33  be ec 51
	add BC,WA                                            ; FC9C36  d8 81
	ld (xiz-8), bc                                       ; FC9C38  be f8 51
	ld wa, (xiz-20)                                      ; FC9C3B  9e ec 20
	add WA,0x0027                                        ; FC9C3E  d8 c8 27 00
	ld (xiz-10), wa                                      ; FC9C42  be f6 50
	sub XIY,XIY                                          ; FC9C45  ed a5
	ld (xiz-18), xiy                                     ; FC9C47  be ee 65
	ld XBC,(XIZ+0x0c)                                    ; FC9C4A  ae 0c 21
	ld H,(XBC+0x01)                                      ; FC9C4D  89 01 26
	cp H,0xff                                            ; FC9C50  ce cf ff
	jr nz, .LFC9C60                                      ; FC9C53  6e 0b
	ld A,(XBC)                                           ; FC9C55  81 21
	extz WA                                              ; FC9C57  d8 12
	extz XWA                                             ; FC9C59  e8 12
	ld (xiz-14), xwa                                     ; FC9C5B  be f2 60
	jr .LFC9C71                                          ; FC9C5E  68 11
.LFC9C60:
	ld c, 0x04:opc                                          ; FC9C60  23 04
	mul bc, h                                          ; FC9C62  ce 43
	extz XBC                                             ; FC9C64  e9 12
	add XBC,Part_VoiceMasks                                   ; FC9C66  e9 c8 54 20 60 00
	ld XBC,(XBC)                                         ; FC9C6C  a1 21
	ld (xiz-14), xbc                                     ; FC9C6E  be f2 61
.LFC9C71:
	ld XIX,(XIZ+0x08)                                    ; FC9C71  ae 08 24
	inc 2,XIX                                            ; FC9C74  ec 62
	ldw bc, 0x78b2                                       ; FC9C76  31 b2 78
	ld (xiz-2), bc                                       ; FC9C79  be fe 51
.LFC9C7C:
	ld XBC,(XIZ+0x08)                                    ; FC9C7C  ae 08 21
	ld A,(XBC)                                           ; FC9C7F  81 21
	mul A,0x07                                           ; FC9C81  c9 08 07
	extz XWA                                             ; FC9C84  e8 12
	inc 2,XWA                                            ; FC9C86  e8 62
	add XBC,XWA                                          ; FC9C88  e8 81
	ld (xiz-22), xbc                                     ; FC9C8A  be ea 61
	ld XWA,XIX                                           ; FC9C8D  ec 88
	cp XWA,XBC                                           ; FC9C8F  e9 f0
	jrl nc, .LFC9D60                                     ; FC9C91  7f cc 00
	ld C,(XIX+0x02)                                      ; FC9C94  8c 02 23
	cp c, 0x00:i3                                          ; FC9C97  cb d8
	jrl z, .LFC9D01                                      ; FC9C99  76 65 00
	ld hl, (xiz-10)                                      ; FC9C9C  9e f6 23
	extz XHL                                             ; FC9C9F  eb 12
	ld HL,(XHL+0x0b)                                     ; FC9CA1  9b 0b 23
	cp	hl, (xiz-10)                                 ; FC9CA4  9e f6 f3
	jrl z, .LFC9D54                                      ; FC9CA7  76 aa 00
	ld C,E                                               ; FC9CAA  cd 8b
	extz BC                                              ; FC9CAC  d9 12
	extz XBC                                             ; FC9CAE  e9 12
	ld (xiz-6), xbc                                      ; FC9CB0  be fa 61
	add XBC,NoteList_FreeCount                                   ; FC9CB3  e9 c8 20 38 00 00
	ld A,(XBC)                                           ; FC9CB9  81 21
	cp a, 0x00:i3                                          ; FC9CBB  c9 d8
	jrl le, .LFC9D54                                     ; FC9CBD  72 94 00
	ld xbc, (xiz-14)                                     ; FC9CC0  ae f2 21
	ld (XIX+0x03),XBC                                    ; FC9CC3  bc 03 61
	ld bc, (xiz-2)                                       ; FC9CC6  9e fe 21
	extz XBC                                             ; FC9CC9  e9 12
	ld A,(XBC)                                           ; FC9CCB  81 21
	res 0x07,A                                           ; FC9CCD  c9 30 07
	pushw wa                                             ; FC9CD0  28
	ld A,(XIX)                                           ; FC9CD1  84 21
	pushw wa                                             ; FC9CD3  28
	calr Note_TransposeFoldOctaves                                      ; FC9CD4  1e c4 10
	ld (XIX+0x01),A                                      ; FC9CD7  bc 01 41
	pushw	(xiz-8)                                      ; FC9CDA  9e f8 04
	pushw hl                                             ; FC9CDD  2b
	calr NoteList_MoveNode                                      ; FC9CDE  1e 8d 00
	lda xbc, (NoteList_FreeCount:24)                                 ; FC9CE1  f2 20 38 00 31
	add	xbc, (xiz-6)                                 ; FC9CE6  ae fa 81
	decm8 0x01, (xbc)                                    ; FC9CE9  81 69
	push XIX                                             ; FC9CEB  3c
	ld IX,HL                                             ; FC9CEC  db 8c
	extz XIX                                             ; FC9CEE  ec 12
	add IX,0x0002                                        ; FC9CF0  dc c8 02 00
	ld XIY,(XSP)                                         ; FC9CF4  a7 25
	ldw bc, 0x07                                         ; FC9CF6  31 07 00
	ldir85                                               ; FC9CF9  85 11
	pop XIX                                              ; FC9CFB  5c
	inc 8,XSP                                            ; FC9CFC  ef 60
	jrl .LFC9D5B                                         ; FC9CFE  78 5a 00
.LFC9D01:
	ld hl, (xiz-8)                                       ; FC9D01  9e f8 23
	extz XHL                                             ; FC9D04  eb 12
	ld HL,(XHL+0x0b)                                     ; FC9D06  9b 0b 23
	cp	hl, (xiz-8)                                  ; FC9D09  9e f8 f3
	jr z, .LFC9D23                                       ; FC9D0C  66 15
	ld D,(XIX)                                           ; FC9D0E  84 24
.LFC9D10:
	extz XHL                                             ; FC9D10  eb 12
	ld C,(XHL+0x02)                                      ; FC9D12  8b 02 23
	cp C,D                                               ; FC9D15  cc f3
	jr z, .LFC9D23                                       ; FC9D17  66 0a
	extz XHL                                             ; FC9D19  eb 12
	ld HL,(XHL+0x0b)                                     ; FC9D1B  9b 0b 23
	cp	hl, (xiz-8)                                  ; FC9D1E  9e f8 f3
	jr nz, .LFC9D10                                      ; FC9D21  6e ed
.LFC9D23:
	cp	hl, (xiz-8)                                  ; FC9D23  9e f8 f3
	jr z, .LFC9D54                                       ; FC9D26  66 2c
	extz XHL                                             ; FC9D28  eb 12
	ld XBC,(XHL+0x05)                                    ; FC9D2A  ab 05 21
	ld (XIX+0x03),XBC                                    ; FC9D2D  bc 03 61
	ld C,(XHL+0x03)                                      ; FC9D30  8b 03 23
	ld (XIX+0x01),C                                      ; FC9D33  bc 01 43
	ld XBC,(XHL+0x05)                                    ; FC9D36  ab 05 21
	or (xiz-18), xbc                                     ; FC9D39  ae ee e9
	pushw	(xiz-10)                                     ; FC9D3C  9e f6 04
	pushw hl                                             ; FC9D3F  2b
	calr NoteList_MoveNode                                      ; FC9D40  1e 2b 00
	ld C,E                                               ; FC9D43  cd 8b
	extz BC                                              ; FC9D45  d9 12
	extz XBC                                             ; FC9D47  e9 12
	add XBC,NoteList_FreeCount                                   ; FC9D49  e9 c8 20 38 00 00
	incm8 0x01, (xbc)                                    ; FC9D4F  81 61
	pop XIY                                              ; FC9D51  5d
	jr .LFC9D5B                                          ; FC9D52  68 07
.LFC9D54:
	ld (XIX),0xff                                        ; FC9D54  b4 00 ff
	ld (XIX+0x01),0xff                                   ; FC9D57  bc 01 00 ff
.LFC9D5B:
	inc 7,XIX                                            ; FC9D5B  ec 67
	jrl .LFC9C7C                                         ; FC9D5D  78 1c ff
.LFC9D60:
	ld xbc, (xiz-18)                                     ; FC9D60  ae ee 21
	or	xbc, (xiz-14)                                ; FC9D63  ae f2 e1
	ld XIY,XBC                                           ; FC9D66  e9 8d
	pop XIX                                              ; FC9D68  5c
	popw de                                              ; FC9D69  4a
	pop XHL                                              ; FC9D6A  5b
	unlk XIZ                                             ; FC9D6B  ee 0d
	ret                                                  ; FC9D6D  0e
; NoteList_MoveNode: (node, head): unlinks the 13-byte node (previous +9, next +0x0B) and links it in after the head.
NoteList_MoveNode:
	link XIZ,0xfffa                                      ; FC9D6E  ee 0c fa ff
	push XHL                                             ; FC9D72  3b
	push XDE                                             ; FC9D73  3a
	pushw ix                                             ; FC9D74  2c
	ld DE,(XIZ+0x0a)                                     ; FC9D75  9e 0a 22
	ld HL,(XIZ+0x08)                                     ; FC9D78  9e 08 23
	ldw ix, 0x0b                                         ; FC9D7B  34 0b 00
	extz XHL                                             ; FC9D7E  eb 12
	ld	bc, (xhl+ix)                                 ; FC9D80  d3 07 ec f0 21
	ld (xiz-2), bc                                       ; FC9D85  be fe 51
	ldw	(xiz-4), 0x0009                              ; FC9D88  be fc 02 09 00
	ld wa, (xiz-4)                                       ; FC9D8D  9e fc 20
	ld	iy, (xhl+wa)                                 ; FC9D90  d3 07 ec e0 25
	extz XIY                                             ; FC9D95  ed 12
	add IY,IX                                            ; FC9D97  dc 85
	ld (XIY),BC                                          ; FC9D99  b5 51
	ld bc, (xiz-4)                                       ; FC9D9B  9e fc 21
	ld	wa, (xhl+bc)                                 ; FC9D9E  d3 07 ec e4 20
	ld (xiz-6), wa                                       ; FC9DA3  be fa 50
	ld	iy, (xhl+ix)                                 ; FC9DA6  d3 07 ec f0 25
	extz XBC                                             ; FC9DAB  e9 12
	add BC,IY                                            ; FC9DAD  dd 81
	ld (XBC),WA                                          ; FC9DAF  b1 50
	extz XDE                                             ; FC9DB1  ea 12
	ld	bc, (xde+ix)                                 ; FC9DB3  d3 07 e8 f0 21
	ld WA,HL                                             ; FC9DB8  db 88
	extz XWA                                             ; FC9DBA  e8 12
	add WA,IX                                            ; FC9DBC  dc 80
	ld (XWA),BC                                          ; FC9DBE  b0 51
	ld BC,HL                                             ; FC9DC0  db 89
	extz XBC                                             ; FC9DC2  e9 12
	add	bc, (xiz-4)                                  ; FC9DC4  9e fc 81
	ld (XBC),DE                                          ; FC9DC7  b1 52
	ld	bc, (xde+ix)                                 ; FC9DC9  d3 07 e8 f0 21
	extz XBC                                             ; FC9DCE  e9 12
	add	bc, (xiz-4)                                  ; FC9DD0  9e fc 81
	ld (XBC),HL                                          ; FC9DD3  b1 53
	ld BC,DE                                             ; FC9DD5  da 89
	extz XBC                                             ; FC9DD7  e9 12
	add BC,IX                                            ; FC9DD9  dc 81
	ld (XBC),HL                                          ; FC9DDB  b1 53
	popw ix                                              ; FC9DDD  4c
	pop XDE                                              ; FC9DDE  5a
	pop XHL                                              ; FC9DDF  5b
	unlk XIZ                                             ; FC9DE0  ee 0d
	ret                                                  ; FC9DE2  0e
	link XIZ,0xfff4                                      ; FC9DE3  ee 0c f4 ff
	push XHL                                             ; FC9DE7  3b
	push XDE                                             ; FC9DE8  3a
	push XIX                                             ; FC9DE9  3c
	ld XBC,(XIZ+0x08)                                    ; FC9DEA  ae 08 21
	inc 2,XBC                                            ; FC9DED  e9 62
	ld (xiz-4), xbc                                      ; FC9DEF  be fc 61
	ld XWA,(XIZ+0x08)                                    ; FC9DF2  ae 08 20
	ld C,(XWA+0x01)                                      ; FC9DF5  88 01 23
	mul C,0x0d                                           ; FC9DF8  cb 08 0d
	ld (xiz-6), bc                                       ; FC9DFB  be fa 51
	ldw de, NoteList_Heads                                       ; FC9DFE  32 23 38
	add DE,BC                                            ; FC9E01  d9 82
	ld XIX,0x00000000                                    ; FC9E03  44 00 00 00 00
	extz XDE                                             ; FC9E08  ea 12
	ld HL,(XDE+0x09)                                     ; FC9E0A  9a 09 23
	jr .LFC9E37                                          ; FC9E0D  68 28
.LFC9E0F:
	push XIX                                             ; FC9E0F  3c
	ld xix, (xiz-4)                                      ; FC9E10  ae fc 24
	ld IY,HL                                             ; FC9E13  db 8d
	extz XIY                                             ; FC9E15  ed 12
	add IY,0x0002                                        ; FC9E17  dd c8 02 00
	ldw bc, 0x07                                         ; FC9E1B  31 07 00
	ldir85                                               ; FC9E1E  85 11
	pop XIX                                              ; FC9E20  5c
	extz XHL                                             ; FC9E21  eb 12
	ld XBC,(XHL+0x05)                                    ; FC9E23  ab 05 21
	or XIX,XBC                                           ; FC9E26  e9 e4
	ld HL,(XHL+0x09)                                     ; FC9E28  9b 09 23
	sub XBC,XBC                                          ; FC9E2B  e9 a1
	inc 7,XBC                                            ; FC9E2D  e9 67
	add (xiz-4), xbc                                     ; FC9E2F  ae fc 89
	ld XWA,(XIZ+0x08)                                    ; FC9E32  ae 08 20
	incm8 0x01, (xwa)                                    ; FC9E35  80 61
.LFC9E37:
	cp HL,DE                                             ; FC9E37  da f3
	jr nz, .LFC9E0F                                      ; FC9E39  6e d4
	ld_erpb_rr c, 0xf0                                   ; FC9E3B  c7 f0 8b   ld C,IXL
	ld A,C                                               ; FC9E3E  cb 89
	pop XIX                                              ; FC9E40  5c
	pop XDE                                              ; FC9E41  5a
	pop XHL                                              ; FC9E42  5b
	unlk XIZ                                             ; FC9E43  ee 0d
	ret                                                  ; FC9E45  0e
; NoteList_BuildReleaseAllFrame: (frame with the source at +1): every node of that source's list copied into the frame with velocity 0 -- a
;   note-off for each sounding note; A = the low byte of their ORed voice masks.
NoteList_BuildReleaseAllFrame:
	link XIZ,0xfff4                                      ; FC9E46  ee 0c f4 ff
	push XHL                                             ; FC9E4A  3b
	push XDE                                             ; FC9E4B  3a
	push XIX                                             ; FC9E4C  3c
	ld XIX,(XIZ+0x08)                                    ; FC9E4D  ae 08 24
	inc 2,XIX                                            ; FC9E50  ec 62
	ld XBC,(XIZ+0x08)                                    ; FC9E52  ae 08 21
	ld A,(XBC+0x01)                                      ; FC9E55  89 01 21
	mul A,0x0d                                           ; FC9E58  c9 08 0d
	ld (xiz-6), wa                                       ; FC9E5B  be fa 50
	ldw de, NoteList_Heads                                       ; FC9E5E  32 23 38
	add DE,WA                                            ; FC9E61  d8 82
	sub XWA,XWA                                          ; FC9E63  e8 a0
	ld (xiz-4), xwa                                      ; FC9E65  be fc 60
	extz XDE                                             ; FC9E68  ea 12
	ld HL,(XDE+0x09)                                     ; FC9E6A  9a 09 23
	jr .LFC9E94                                          ; FC9E6D  68 25
.LFC9E6F:
	push XIX                                             ; FC9E6F  3c
	ld IY,HL                                             ; FC9E70  db 8d
	extz XIY                                             ; FC9E72  ed 12
	add IY,0x0002                                        ; FC9E74  dd c8 02 00
	ldw bc, 0x07                                         ; FC9E78  31 07 00
	ldir85                                               ; FC9E7B  85 11
	pop XIX                                              ; FC9E7D  5c
	ld (XIX+0x02),0x00                                   ; FC9E7E  bc 02 00 00
	extz XHL                                             ; FC9E82  eb 12
	ld XBC,(XHL+0x05)                                    ; FC9E84  ab 05 21
	or (xiz-4), xbc                                      ; FC9E87  ae fc e9
	ld HL,(XHL+0x09)                                     ; FC9E8A  9b 09 23
	inc 7,XIX                                            ; FC9E8D  ec 67
	ld XBC,(XIZ+0x08)                                    ; FC9E8F  ae 08 21
	incm8 0x01, (xbc)                                    ; FC9E92  81 61
.LFC9E94:
	cp HL,DE                                             ; FC9E94  da f3
	jr nz, .LFC9E6F                                      ; FC9E96  6e d7
	ld c, (xiz-4)                                        ; FC9E98  8e fc 23
	ld A,C                                               ; FC9E9B  cb 89
	pop XIX                                              ; FC9E9D  5c
	pop XDE                                              ; FC9E9E  5a
	pop XHL                                              ; FC9E9F  5b
	unlk XIZ                                             ; FC9EA0  ee 0d
	ret                                                  ; FC9EA2  0e
; NoteFrame_SelectForPart: (out frame, note frame, part block, part): the entries whose voice mask overlaps 0x602054[part] and -- unless
;   the block's +1 is not 0xFF -- whose note and velocity lie within the part's range record (6 bytes at
;   +0x62 + part x 6: note low / high, velocity low / high) go to the out frame's +7 / +8; A = their count.
NoteFrame_SelectForPart:
	link XIZ,0xffee                                      ; FC9EA3  ee 0c ee ff
	pushw hl                                             ; FC9EA7  2b
	pushw de                                             ; FC9EA8  2a
	push XIX                                             ; FC9EA9  3c
	ld c, 0x06:opc                                          ; FC9EAA  23 06
	mul	bc, (xiz+20)                                 ; FC9EAC  8e 14 43
	extz XBC                                             ; FC9EAF  e9 12
	add XBC,0x00000062                                   ; FC9EB1  e9 c8 62 00 00 00
	add XBC,(XIZ+0x10)                                   ; FC9EB7  ae 10 81
	ld (xiz-12), xbc                                     ; FC9EBA  be f4 61
	ld XWA,(XIZ+0x0c)                                    ; FC9EBD  ae 0c 20
	ld C,(XWA+0x01)                                      ; FC9EC0  88 01 23
	ld H,C                                               ; FC9EC3  cb 8e
	ld XBC,(XIZ+0x08)                                    ; FC9EC5  ae 08 21
	ld (XBC+0x02),H                                      ; FC9EC8  b9 02 46
	ld XBC,(XIZ+0x08)                                    ; FC9ECB  ae 08 21
	ld A,(XIZ+0x14)                                      ; FC9ECE  8e 14 21
	ld (XBC+0x03),A                                      ; FC9ED1  b9 03 41
	ldw	(xiz-14), 0x0000                             ; FC9ED4  be f2 02 00 00
	ldw de, 0x00                                         ; FC9ED9  32 00 00
	ld c, 0x04:opc                                          ; FC9EDC  23 04
	mul	bc, (xiz+20)                                 ; FC9EDE  8e 14 43
	extz XBC                                             ; FC9EE1  e9 12
	ld (xiz-8), xbc                                      ; FC9EE3  be f8 61
	sub XWA,XWA                                          ; FC9EE6  e8 a0
	ld (xiz-4), xwa                                      ; FC9EE8  be fc 60
.LFC9EEB:
	ld XBC,(XIZ+0x0c)                                    ; FC9EEB  ae 0c 21
	ld A,(XBC)                                           ; FC9EEE  81 21
	extz WA                                              ; FC9EF0  d8 12
	cp DE,WA                                             ; FC9EF2  d8 f2
	jrl nc, .LFC9F7B                                     ; FC9EF4  7f 84 00
	ld xix, (xiz-4)                                      ; FC9EF7  ae fc 24
	ld XWA,XIX                                           ; FC9EFA  ec 88
	inc 5,XWA                                            ; FC9EFC  e8 65
	add XBC,XWA                                          ; FC9EFE  e8 81
	ld XIY,(XBC)                                         ; FC9F00  a1 25
	ld (xiz-18), xiy                                     ; FC9F02  be ee 65
	lda xbc, (Part_VoiceMasks:24)                               ; FC9F05  f2 54 20 60 31
	add	xbc, (xiz-8)                                 ; FC9F0A  ae f8 81
	ld XWA,(XBC)                                         ; FC9F0D  a1 20
	and XIY,XWA                                          ; FC9F0F  e8 c5
	jrl z, .LFC9F6F                                      ; FC9F11  76 5b 00
	ld XBC,XIX                                           ; FC9F14  ec 89
	inc 3,XBC                                            ; FC9F16  e9 63
	add XBC,(XIZ+0x0c)                                   ; FC9F18  ae 0c 81
	ld L,(XBC)                                           ; FC9F1B  81 27
	ld XBC,XIX                                           ; FC9F1D  ec 89
	inc 4,XBC                                            ; FC9F1F  e9 64
	add XBC,(XIZ+0x0c)                                   ; FC9F21  ae 0c 81
	ld H,(XBC)                                           ; FC9F24  81 26
	cp h, 0x00:i3                                          ; FC9F26  ce d8
	jr z, .LFC9F54                                       ; FC9F28  66 2a
	ld XBC,(XIZ+0x10)                                    ; FC9F2A  ae 10 21
	ld A,(XBC+0x01)                                      ; FC9F2D  89 01 21
	cp A,0xff                                            ; FC9F30  c9 cf ff
	jr nz, .LFC9F54                                      ; FC9F33  6e 1f
	ld xwa, (xiz-12)                                     ; FC9F35  ae f4 20
	ld C,(XWA+0x02)                                      ; FC9F38  88 02 23
	cp C,L                                               ; FC9F3B  cf f3
	jr ugt, .LFC9F6F                                     ; FC9F3D  6b 30
	ld C,(XWA+0x01)                                      ; FC9F3F  88 01 23
	cp L,C                                               ; FC9F42  cb f7
	jr ugt, .LFC9F6F                                     ; FC9F44  6b 29
	ld C,(XWA+0x04)                                      ; FC9F46  88 04 23
	cp C,H                                               ; FC9F49  ce f3
	jr ugt, .LFC9F6F                                     ; FC9F4B  6b 22
	ld C,(XWA+0x03)                                      ; FC9F4D  88 03 23
	cp H,C                                               ; FC9F50  cb f6
	jr ugt, .LFC9F6F                                     ; FC9F52  6b 1b
.LFC9F54:
	ldw bc, 0x09                                         ; FC9F54  31 09 00
	mul	xbc, (xiz-14)                                ; FC9F57  9e f2 41
	ld XIX,XBC                                           ; FC9F5A  e9 8c
	inc 7,XBC                                            ; FC9F5C  e9 67
	add XBC,(XIZ+0x08)                                   ; FC9F5E  ae 08 81
	ld (XBC),L                                           ; FC9F61  b1 47
	ld XBC,XIX                                           ; FC9F63  ec 89
	inc 8,XBC                                            ; FC9F65  e9 60
	add XBC,(XIZ+0x08)                                   ; FC9F67  ae 08 81
	ld (XBC),H                                           ; FC9F6A  b1 46
	incw 0x01, (xiz-14)                                  ; FC9F6C  9e f2 61
.LFC9F6F:
	sub XBC,XBC                                          ; FC9F6F  e9 a1
	inc 7,XBC                                            ; FC9F71  e9 67
	add (xiz-4), xbc                                     ; FC9F73  ae fc 89
	inc 1,DE                                             ; FC9F76  da 61
	jrl .LFC9EEB                                         ; FC9F78  78 70 ff
.LFC9F7B:
	ld h, (xiz-14)                                       ; FC9F7B  8e f2 26
	ld XBC,(XIZ+0x08)                                    ; FC9F7E  ae 08 21
	ld (XBC),H                                           ; FC9F81  b1 46
	ld A,H                                               ; FC9F83  ce 89
	pop XIX                                              ; FC9F85  5c
	popw de                                              ; FC9F86  4a
	popw hl                                              ; FC9F87  4b
	unlk XIZ                                             ; FC9F88  ee 0d
	ret                                                  ; FC9F8A  0e
; PartNotes_ApplyFrame: (frame, part block, part): per entry -- note-on: a 15-byte node from the pool (head 0x39F7 + 0x1E0) while
;   the part's budget (0x3800 + part) is above 0; up to three outputs from the part block: +0 with
;   PartNote_MapForToneGen / _ApplyVelocityOffset (result bit 0), +1 with PartNote_TransposeForMidiOut (bit 1),
;   +2 with the raw note (bit 2); the entry copied into the node, PartNoteList_MoveNode, budget - 1.  Note-off: the
;   part's node with the same note, source and channel copied back with velocity 0, the same bits, the node
;   freed, budget + 1.  A = the bits.
PartNotes_ApplyFrame:
	link XIZ,0xffef                                      ; FC9F8B  ee 0c ef ff
	pushw hl                                             ; FC9F8F  2b
	pushw de                                             ; FC9F90  2a
	push XIX                                             ; FC9F91  3c
	ld E,(XIZ+0x10)                                      ; FC9F92  8e 10 25
	ld c, 0x0f:opc                                          ; FC9F95  23 0f
	mul bc, e                                          ; FC9F97  cd 43
	ld HL,BC                                             ; FC9F99  d9 8b
	ldw wa, PartNoteList_Heads                                       ; FC9F9B  30 f7 39
	ld (xiz-9), wa                                       ; FC9F9E  be f7 50
	add WA,BC                                            ; FC9FA1  d9 80
	ld (xiz-4), wa                                       ; FC9FA3  be fc 50
	ld bc, (xiz-9)                                       ; FC9FA6  9e f7 21
	add BC,0x01e0                                        ; FC9FA9  d9 c8 e0 01
	ld (xiz-6), bc                                       ; FC9FAD  be fa 51
	ld (xiz-7), 0x00                                     ; FC9FB0  be f9 00 00
	ld XIY,(XIZ+0x08)                                    ; FC9FB4  ae 08 25
	ld (XIY+0x04),E                                      ; FC9FB7  bd 04 45
	ld XIX,(XIZ+0x08)                                    ; FC9FBA  ae 08 24
	inc 7,XIX                                            ; FC9FBD  ec 67
.LFC9FBF:
	ld XBC,(XIZ+0x08)                                    ; FC9FBF  ae 08 21
	ld A,(XBC)                                           ; FC9FC2  81 21
	mul A,0x09                                           ; FC9FC4  c9 08 09
	extz XWA                                             ; FC9FC7  e8 12
	inc 7,XWA                                            ; FC9FC9  e8 67
	add XBC,XWA                                          ; FC9FCB  e8 81
	ld (xiz-11), xbc                                     ; FC9FCD  be f5 61
	ld XWA,XIX                                           ; FC9FD0  ec 88
	cp XWA,XBC                                           ; FC9FD2  e9 f0
	jrl nc, .LFCA18B                                     ; FC9FD4  7f b4 01
	ld C,(XIX)                                           ; FC9FD7  84 23
	cp C,0xff                                            ; FC9FD9  cb cf ff
	jrl z, .LFCA182                                      ; FC9FDC  76 a3 01
	ld C,(XIX+0x01)                                      ; FC9FDF  8c 01 23
	cp c, 0x00:i3                                          ; FC9FE2  cb d8
	jrl z, .LFCA0D9                                      ; FC9FE4  76 f2 00
	ld bc, (xiz-6)                                       ; FC9FE7  9e fa 21
	extz XBC                                             ; FC9FEA  e9 12
	ld WA,(XBC+0x0d)                                     ; FC9FEC  99 0d 20
	ld (xiz-2), wa                                       ; FC9FEF  be fe 50
	cp WA,BC                                             ; FC9FF2  d9 f0
	jrl z, .LFCA176                                      ; FC9FF4  76 7f 01
	ldfr_berp e, 0xf4                                      ; FC9FF7  c7 f4 9d   ld IYL,E
	extz IY                                              ; FC9FFA  dd 12
	extz XIY                                             ; FC9FFC  ed 12
	add XIY,PartNote_Budget                                   ; FC9FFE  ed c8 00 38 00 00
	ld C,(XIY)                                           ; FCA004  85 23
	cp c, 0x00:i3                                          ; FCA006  cb d8
	jrl le, .LFCA176                                     ; FCA008  72 6b 01
	ld XBC,(XIZ+0x08)                                    ; FCA00B  ae 08 21
	ld A,(XBC+0x02)                                      ; FCA00E  89 02 21
	ld H,A                                               ; FCA011  c9 8e
	ld wa, (xiz-2)                                       ; FCA013  9e fe 20
	extz XWA                                             ; FCA016  e8 12
	ld (XWA),H                                           ; FCA018  b0 46
	ld XBC,(XIZ+0x08)                                    ; FCA01A  ae 08 21
	ld A,(XBC+0x03)                                      ; FCA01D  89 03 21
	ld H,A                                               ; FCA020  c9 8e
	ld wa, (xiz-2)                                       ; FCA022  9e fe 20
	extz XWA                                             ; FCA025  e8 12
	ld (XWA+0x01),H                                      ; FCA027  b8 01 46
	ld XBC,(XIZ+0x0c)                                    ; FCA02A  ae 0c 21
	ld H,(XBC)                                           ; FCA02D  81 26
	ld (XIX+0x02),H                                      ; FCA02F  bc 02 46
	cp H,0xff                                            ; FCA032  ce cf ff
	jr z, .LFCA064                                       ; FCA035  66 2d
	ld XBC,(XIZ+0x0c)                                    ; FCA037  ae 0c 21
	ld A,(XBC)                                           ; FCA03A  81 21
	pushw wa                                             ; FCA03C  28
	ld XWA,(XBC+0x03)                                    ; FCA03D  a9 03 20
	push XWA                                             ; FCA040  38
	ld A,(XIX)                                           ; FCA041  84 21
	pushw wa                                             ; FCA043  28
	calr PartNote_MapForToneGen                                      ; FCA044  1e 8e 0d
	ld (XIX+0x03),A                                      ; FCA047  bc 03 41
	ld XBC,(XIZ+0x0c)                                    ; FCA04A  ae 0c 21
	ld XWA,(XBC+0x03)                                    ; FCA04D  a9 03 20
	push XWA                                             ; FCA050  38
	ld A,(XIX+0x01)                                      ; FCA051  8c 01 21
	pushw wa                                             ; FCA054  28
	calr PartNote_ApplyVelocityOffset                                      ; FCA055  1e a2 0d
	ld (XIX+0x04),A                                      ; FCA058  bc 04 41
	set	0, (xiz-7)                                   ; FCA05B  be f9 b8
	inc 8,XSP                                            ; FCA05E  ef 60
	inc 6,XSP                                            ; FCA060  ef 66
	jr .LFCA068                                          ; FCA062  68 04
.LFCA064:
	ld (XIX+0x03),0xff                                   ; FCA064  bc 03 00 ff
.LFCA068:
	ld XBC,(XIZ+0x0c)                                    ; FCA068  ae 0c 21
	ld H,(XBC+0x01)                                      ; FCA06B  89 01 26
	ld (XIX+0x05),H                                      ; FCA06E  bc 05 46
	cp H,0xff                                            ; FCA071  ce cf ff
	jr z, .LFCA08D                                       ; FCA074  66 17
	ld XBC,(XIZ+0x0c)                                    ; FCA076  ae 0c 21
	ld XWA,(XBC+0x07)                                    ; FCA079  a9 07 20
	push XWA                                             ; FCA07C  38
	ld A,(XIX)                                           ; FCA07D  84 21
	pushw wa                                             ; FCA07F  28
	calr PartNote_TransposeForMidiOut                                      ; FCA080  1e aa 0d
	ld (XIX+0x06),A                                      ; FCA083  bc 06 41
	set	1, (xiz-7)                                   ; FCA086  be f9 b9
	inc 6,XSP                                            ; FCA089  ef 66
	jr .LFCA091                                          ; FCA08B  68 04
.LFCA08D:
	ld (XIX+0x06),0xff                                   ; FCA08D  bc 06 00 ff
.LFCA091:
	ld XBC,(XIZ+0x0c)                                    ; FCA091  ae 0c 21
	ld H,(XBC+0x02)                                      ; FCA094  89 02 26
	ld (XIX+0x07),H                                      ; FCA097  bc 07 46
	cp H,0xff                                            ; FCA09A  ce cf ff
	jr z, .LFCA0A9                                       ; FCA09D  66 0a
	ld C,(XIX)                                           ; FCA09F  84 23
	ld (XIX+0x08),C                                      ; FCA0A1  bc 08 43
	set	2, (xiz-7)                                   ; FCA0A4  be f9 ba
	jr .LFCA0AD                                          ; FCA0A7  68 04
.LFCA0A9:
	ld (XIX+0x08),0xff                                   ; FCA0A9  bc 08 00 ff
.LFCA0AD:
	push XIX                                             ; FCA0AD  3c
	ld ix, (xiz-2)                                       ; FCA0AE  9e fe 24
	extz XIX                                             ; FCA0B1  ec 12
	add IX,0x0002                                        ; FCA0B3  dc c8 02 00
	ld XIY,(XSP)                                         ; FCA0B7  a7 25
	ldw bc, 0x09                                         ; FCA0B9  31 09 00
	ldir85                                               ; FCA0BC  85 11
	pop XIX                                              ; FCA0BE  5c
	pushw	(xiz-4)                                      ; FCA0BF  9e fc 04
	pushw	(xiz-2)                                      ; FCA0C2  9e fe 04
	calr PartNoteList_MoveNode                                      ; FCA0C5  1e cc 00
	ld C,E                                               ; FCA0C8  cd 8b
	extz BC                                              ; FCA0CA  d9 12
	extz XBC                                             ; FCA0CC  e9 12
	add XBC,PartNote_Budget                                   ; FCA0CE  e9 c8 00 38 00 00
	decm8 0x01, (xbc)                                    ; FCA0D4  81 69
	jrl .LFCA173                                         ; FCA0D6  78 9a 00
.LFCA0D9:
	ld bc, (xiz-4)                                       ; FCA0D9  9e fc 21
	extz XBC                                             ; FCA0DC  e9 12
	ld WA,(XBC+0x0d)                                     ; FCA0DE  99 0d 20
	ld (xiz-2), wa                                       ; FCA0E1  be fe 50
	cp WA,BC                                             ; FCA0E4  d9 f0
	jr z, .LFCA11C                                       ; FCA0E6  66 34
	ld D,(XIX)                                           ; FCA0E8  84 24
	ld XIY,(XIZ+0x08)                                    ; FCA0EA  ae 08 25
	ld L,(XIY+0x02)                                      ; FCA0ED  8d 02 27
	ld H,(XIY+0x03)                                      ; FCA0F0  8d 03 26
.LFCA0F3:
	ld bc, (xiz-2)                                       ; FCA0F3  9e fe 21
	extz XBC                                             ; FCA0F6  e9 12
	ld A,(XBC+0x02)                                      ; FCA0F8  89 02 21
	cp A,D                                               ; FCA0FB  cc f1
	jr nz, .LFCA10C                                      ; FCA0FD  6e 0d
	ld A,(XBC)                                           ; FCA0FF  81 21
	cp A,L                                               ; FCA101  cf f1
	jr nz, .LFCA10C                                      ; FCA103  6e 07
	ld A,(XBC+0x01)                                      ; FCA105  89 01 21
	cp A,H                                               ; FCA108  ce f1
	jr z, .LFCA11C                                       ; FCA10A  66 10
.LFCA10C:
	ld bc, (xiz-2)                                       ; FCA10C  9e fe 21
	extz XBC                                             ; FCA10F  e9 12
	ld WA,(XBC+0x0d)                                     ; FCA111  99 0d 20
	ld (xiz-2), wa                                       ; FCA114  be fe 50
	cp	wa, (xiz-4)                                  ; FCA117  9e fc f0
	jr nz, .LFCA0F3                                      ; FCA11A  6e d7
.LFCA11C:
	ld bc, (xiz-2)                                       ; FCA11C  9e fe 21
	cp	bc, (xiz-4)                                  ; FCA11F  9e fc f1
	jr z, .LFCA176                                       ; FCA122  66 52
	push XIX                                             ; FCA124  3c
	ld IY,BC                                             ; FCA125  d9 8d
	extz XIY                                             ; FCA127  ed 12
	add IY,0x0002                                        ; FCA129  dd c8 02 00
	ldw bc, 0x09                                         ; FCA12D  31 09 00
	ldir85                                               ; FCA130  85 11
	pop XIX                                              ; FCA132  5c
	ld (XIX+0x01),0x00                                   ; FCA133  bc 01 00 00
	ld (XIX+0x04),0x00                                   ; FCA137  bc 04 00 00
	ld C,(XIX+0x03)                                      ; FCA13B  8c 03 23
	cp C,0xff                                            ; FCA13E  cb cf ff
	jr z, .LFCA146                                       ; FCA141  66 03
	set	0, (xiz-7)                                   ; FCA143  be f9 b8
.LFCA146:
	ld C,(XIX+0x06)                                      ; FCA146  8c 06 23
	cp C,0xff                                            ; FCA149  cb cf ff
	jr z, .LFCA151                                       ; FCA14C  66 03
	set	1, (xiz-7)                                   ; FCA14E  be f9 b9
.LFCA151:
	ld C,(XIX+0x08)                                      ; FCA151  8c 08 23
	cp C,0xff                                            ; FCA154  cb cf ff
	jr z, .LFCA15C                                       ; FCA157  66 03
	set	2, (xiz-7)                                   ; FCA159  be f9 ba
.LFCA15C:
	pushw	(xiz-6)                                      ; FCA15C  9e fa 04
	pushw	(xiz-2)                                      ; FCA15F  9e fe 04
	calr PartNoteList_MoveNode                                      ; FCA162  1e 2f 00
	ld C,E                                               ; FCA165  cd 8b
	extz BC                                              ; FCA167  d9 12
	extz XBC                                             ; FCA169  e9 12
	add XBC,PartNote_Budget                                   ; FCA16B  e9 c8 00 38 00 00
	incm8 0x01, (xbc)                                    ; FCA171  81 61
.LFCA173:
	pop XIY                                              ; FCA173  5d
	jr .LFCA182                                          ; FCA174  68 0c
.LFCA176:
	ld (XIX+0x03),0xff                                   ; FCA176  bc 03 00 ff
	ld (XIX+0x06),0xff                                   ; FCA17A  bc 06 00 ff
	ld (XIX+0x08),0xff                                   ; FCA17E  bc 08 00 ff
.LFCA182:
	add XIX,0x00000009                                   ; FCA182  ec c8 09 00 00 00
	jrl .LFC9FBF                                         ; FCA188  78 34 fe
.LFCA18B:
	ld a, (xiz-7)                                        ; FCA18B  8e f9 21
	pop XIX                                              ; FCA18E  5c
	popw de                                              ; FCA18F  4a
	popw hl                                              ; FCA190  4b
	unlk XIZ                                             ; FCA191  ee 0d
	ret                                                  ; FCA193  0e
; PartNoteList_MoveNode: NoteList_MoveNode for the 15-byte nodes (previous +0x0B, next +0x0D).
PartNoteList_MoveNode:
	link XIZ,0xfffa                                      ; FCA194  ee 0c fa ff
	push XHL                                             ; FCA198  3b
	push XDE                                             ; FCA199  3a
	pushw ix                                             ; FCA19A  2c
	ld DE,(XIZ+0x0a)                                     ; FCA19B  9e 0a 22
	ld HL,(XIZ+0x08)                                     ; FCA19E  9e 08 23
	ldw ix, 0x0d                                         ; FCA1A1  34 0d 00
	extz XHL                                             ; FCA1A4  eb 12
	ld	bc, (xhl+ix)                                 ; FCA1A6  d3 07 ec f0 21
	ld (xiz-2), bc                                       ; FCA1AB  be fe 51
	ldw	(xiz-4), 0x000b                              ; FCA1AE  be fc 02 0b 00
	ld wa, (xiz-4)                                       ; FCA1B3  9e fc 20
	ld	iy, (xhl+wa)                                 ; FCA1B6  d3 07 ec e0 25
	extz XIY                                             ; FCA1BB  ed 12
	add IY,IX                                            ; FCA1BD  dc 85
	ld (XIY),BC                                          ; FCA1BF  b5 51
	ld bc, (xiz-4)                                       ; FCA1C1  9e fc 21
	ld	wa, (xhl+bc)                                 ; FCA1C4  d3 07 ec e4 20
	ld (xiz-6), wa                                       ; FCA1C9  be fa 50
	ld	iy, (xhl+ix)                                 ; FCA1CC  d3 07 ec f0 25
	extz XBC                                             ; FCA1D1  e9 12
	add BC,IY                                            ; FCA1D3  dd 81
	ld (XBC),WA                                          ; FCA1D5  b1 50
	extz XDE                                             ; FCA1D7  ea 12
	ld	bc, (xde+ix)                                 ; FCA1D9  d3 07 e8 f0 21
	ld WA,HL                                             ; FCA1DE  db 88
	extz XWA                                             ; FCA1E0  e8 12
	add WA,IX                                            ; FCA1E2  dc 80
	ld (XWA),BC                                          ; FCA1E4  b0 51
	ld BC,HL                                             ; FCA1E6  db 89
	extz XBC                                             ; FCA1E8  e9 12
	add	bc, (xiz-4)                                  ; FCA1EA  9e fc 81
	ld (XBC),DE                                          ; FCA1ED  b1 52
	ld	bc, (xde+ix)                                 ; FCA1EF  d3 07 e8 f0 21
	extz XBC                                             ; FCA1F4  e9 12
	add	bc, (xiz-4)                                  ; FCA1F6  9e fc 81
	ld (XBC),HL                                          ; FCA1F9  b1 53
	ld BC,DE                                             ; FCA1FB  da 89
	extz XBC                                             ; FCA1FD  e9 12
	add BC,IX                                            ; FCA1FF  dc 81
	ld (XBC),HL                                          ; FCA201  b1 53
	popw ix                                              ; FCA203  4c
	pop XDE                                              ; FCA204  5a
	pop XHL                                              ; FCA205  5b
	unlk XIZ                                             ; FCA206  ee 0d
	ret                                                  ; FCA208  0e
	link XIZ,0xfffb                                      ; FCA209  ee 0c fb ff
	push XHL                                             ; FCA20D  3b
	push XDE                                             ; FCA20E  3a
	push XIX                                             ; FCA20F  3c
	ld c, 0x0f:opc                                          ; FCA210  23 0f
	mul	bc, (xiz+14)                                 ; FCA212  8e 0e 43
	ld (xiz-5), bc                                       ; FCA215  be fb 51
	ldw de, PartNoteList_Heads                                       ; FCA218  32 f7 39
	add DE,BC                                            ; FCA21B  d9 82
	extz XDE                                             ; FCA21D  ea 12
	ld HL,(XDE+0x0d)                                     ; FCA21F  9a 0d 23
	cp HL,DE                                             ; FCA222  da f3
	jr z, .LFCA26E                                       ; FCA224  66 48
	ld XIX,(XIZ+0x08)                                    ; FCA226  ae 08 24
	ld c, 0x09:opc                                          ; FCA229  23 09
	mul	bc, (xiz+12)                                 ; FCA22B  8e 0c 43
	ld (xiz-5), bc                                       ; FCA22E  be fb 51
	ld A,(XIX+0x03)                                      ; FCA231  8c 03 21
	ld (xiz-2), a                                        ; FCA234  be fe 41
	ld W,(XIX+0x02)                                      ; FCA237  8c 02 20
	ld (xiz-1), w                                        ; FCA23A  be ff 40
	extz XBC                                             ; FCA23D  e9 12
	inc 7,XBC                                            ; FCA23F  e9 67
	add XBC,XIX                                          ; FCA241  ec 81
	ld A,(XBC)                                           ; FCA243  81 21
	ld (xiz-3), a                                        ; FCA245  be fd 41
.LFCA248:
	extz XHL                                             ; FCA248  eb 12
	ld C,(XHL+0x02)                                      ; FCA24A  8b 02 23
	cp	c, (xiz-3)                                   ; FCA24D  8e fd f3
	jr nz, .LFCA265                                      ; FCA250  6e 13
	extz XHL                                             ; FCA252  eb 12
	ld C,(XHL+0x01)                                      ; FCA254  8b 01 23
	cp	c, (xiz-2)                                   ; FCA257  8e fe f3
	jr nz, .LFCA265                                      ; FCA25A  6e 09
	extz XHL                                             ; FCA25C  eb 12
	ld C,(XHL)                                           ; FCA25E  83 23
	cp	c, (xiz-1)                                   ; FCA260  8e ff f3
	jr z, .LFCA26E                                       ; FCA263  66 09
.LFCA265:
	extz XHL                                             ; FCA265  eb 12
	ld HL,(XHL+0x0d)                                     ; FCA267  9b 0d 23
	cp HL,DE                                             ; FCA26A  da f3
	jr nz, .LFCA248                                      ; FCA26C  6e da
.LFCA26E:
	ld WA,HL                                             ; FCA26E  db 88
	pop XIX                                              ; FCA270  5c
	pop XDE                                              ; FCA271  5a
	pop XHL                                              ; FCA272  5b
	unlk XIZ                                             ; FCA273  ee 0d
	ret                                                  ; FCA275  0e
; PartNotes_CollectFrame: (frame with a source at +2 -- 0xFF any -- and a channel key at +3, outputs mask, part): PartNotes_BuildReleaseFrame
;   without the release: each of the part's notes from that source with that key is copied into the frame as it is,
;   and A has bit 0 / 1 / 2 when one still sounds on that output.  A node already released on all three returns to
;   the pool and to PartNote_Budget.
PartNotes_CollectFrame:
	link XIZ,0xffee                                      ; FCA276  ee 0c ee ff
	pushw hl                                             ; FCA27A  2b
	pushw de                                             ; FCA27B  2a
	push XIX                                             ; FCA27C  3c
	ld c, 0x0f:opc                                          ; FCA27D  23 0f
	mul	bc, (xiz+14)                                 ; FCA27F  8e 0e 43
	ld HL,BC                                             ; FCA282  d9 8b
	ldw ix, PartNoteList_Heads                                       ; FCA284  34 f7 39
	add BC,IX                                            ; FCA287  dc 81
	ld (xiz-2), bc                                       ; FCA289  be fe 51
	ld WA,IX                                             ; FCA28C  dc 88
	add WA,0x01e0                                        ; FCA28E  d8 c8 e0 01
	ld (xiz-4), wa                                       ; FCA292  be fc 50
	ld XIY,(XIZ+0x08)                                    ; FCA295  ae 08 25
	inc 7,XIY                                            ; FCA298  ed 67
	ld (xiz-8), xiy                                      ; FCA29A  be f8 65
	ld e, 0x00:opc                                          ; FCA29D  25 00
	ld XBC,(XIZ+0x08)                                    ; FCA29F  ae 08 21
	ld A,(XIZ+0x0e)                                      ; FCA2A2  8e 0e 21
	ld (XBC+0x04),A                                      ; FCA2A5  b9 04 41
	ld XBC,(XIZ+0x08)                                    ; FCA2A8  ae 08 21
	ld A,(XBC+0x02)                                      ; FCA2AB  89 02 21
	cp A,0xff                                            ; FCA2AE  c9 cf ff
	jrl nz, .LFCA387                                     ; FCA2B1  7e d3 00
	ld ix, (xiz-2)                                       ; FCA2B4  9e fe 24
	extz XIX                                             ; FCA2B7  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA2B9  9c 0b 24
	cp	ix, (xiz-2)                                  ; FCA2BC  9e fe f4
	jrl z, .LFCA46D                                      ; FCA2BF  76 ab 01
	ld H,(XIZ+0x0c)                                      ; FCA2C2  8e 0c 26
	and H,0x01                                           ; FCA2C5  ce cc 01
	ld L,(XIZ+0x0c)                                      ; FCA2C8  8e 0c 27
	and L,0x02                                           ; FCA2CB  cf cc 02
	ld D,(XIZ+0x0c)                                      ; FCA2CE  8e 0c 24
	and D,0x04                                           ; FCA2D1  cc cc 04
.LFCA2D4:
	ld XBC,(XIZ+0x08)                                    ; FCA2D4  ae 08 21
	ld A,(XBC+0x03)                                      ; FCA2D7  89 03 21
	ld (xiz-10), a                                       ; FCA2DA  be f6 41
	extz XIX                                             ; FCA2DD  ec 12
	ld W,(XIX+0x01)                                      ; FCA2DF  8c 01 20
	cp W,A                                               ; FCA2E2  c9 f0
	jrl nz, .LFCA37E                                     ; FCA2E4  7e 97 00
	push XIX                                             ; FCA2E7  3c
	ld xix, (xiz-8)                                      ; FCA2E8  ae f8 24
	ld IY,(XSP)                                          ; FCA2EB  97 25
	extz XIY                                             ; FCA2ED  ed 12
	add IY,0x0002                                        ; FCA2EF  dd c8 02 00
	ldw bc, 0x09                                         ; FCA2F3  31 09 00
	ldir85                                               ; FCA2F6  85 11
	pop XIX                                              ; FCA2F8  5c
	cp h, 0x00:i3                                          ; FCA2F9  ce d8
	jr z, .LFCA30B                                       ; FCA2FB  66 0e
	ld xbc, (xiz-8)                                      ; FCA2FD  ae f8 21
	ld A,(XBC+0x03)                                      ; FCA300  89 03 21
	cp A,0xff                                            ; FCA303  c9 cf ff
	jr z, .LFCA30B                                       ; FCA306  66 03
	set 0x00,E                                           ; FCA308  cd 31 00
.LFCA30B:
	cp l, 0x00:i3                                          ; FCA30B  cf d8
	jr z, .LFCA31D                                       ; FCA30D  66 0e
	ld xbc, (xiz-8)                                      ; FCA30F  ae f8 21
	ld A,(XBC+0x06)                                      ; FCA312  89 06 21
	cp A,0xff                                            ; FCA315  c9 cf ff
	jr z, .LFCA31D                                       ; FCA318  66 03
	set 0x01,E                                           ; FCA31A  cd 31 01
.LFCA31D:
	cp d, 0x00:i3                                          ; FCA31D  cc d8
	jr z, .LFCA32F                                       ; FCA31F  66 0e
	ld xbc, (xiz-8)                                      ; FCA321  ae f8 21
	ld A,(XBC+0x08)                                      ; FCA324  89 08 21
	cp A,0xff                                            ; FCA327  c9 cf ff
	jr z, .LFCA32F                                       ; FCA32A  66 03
	set 0x02,E                                           ; FCA32C  cd 31 02
.LFCA32F:
	extz XIX                                             ; FCA32F  ec 12
	ld C,(XIX+0x05)                                      ; FCA331  8c 05 23
	cp C,0xff                                            ; FCA334  cb cf ff
	jr nz, .LFCA36C                                      ; FCA337  6e 33
	extz XIX                                             ; FCA339  ec 12
	ld C,(XIX+0x08)                                      ; FCA33B  8c 08 23
	cp C,0xff                                            ; FCA33E  cb cf ff
	jr nz, .LFCA36C                                      ; FCA341  6e 29
	extz XIX                                             ; FCA343  ec 12
	ld C,(XIX+0x0a)                                      ; FCA345  8c 0a 23
	cp C,0xff                                            ; FCA348  cb cf ff
	jr nz, .LFCA36C                                      ; FCA34B  6e 1f
	pushw	(xiz-4)                                      ; FCA34D  9e fc 04
	pushw ix                                             ; FCA350  2c
	calr PartNoteList_MoveNode                                      ; FCA351  1e 40 fe
	ld BC,(XIZ+0x0e)                                     ; FCA354  9e 0e 21
	extz BC                                              ; FCA357  d9 12
	extz XBC                                             ; FCA359  e9 12
	add XBC,PartNote_Budget                                   ; FCA35B  e9 c8 00 38 00 00
	incm8 0x01, (xbc)                                    ; FCA361  81 61
	ld ix, (xiz-2)                                       ; FCA363  9e fe 24
	ld IX,(XIX+0x0b)                                     ; FCA366  9c 0b 24
	pop XIY                                              ; FCA369  5d
	jr .LFCA371                                          ; FCA36A  68 05
.LFCA36C:
	extz XIX                                             ; FCA36C  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA36E  9c 0b 24
.LFCA371:
	ld XBC,0x00000009                                    ; FCA371  41 09 00 00 00
	add (xiz-8), xbc                                     ; FCA376  ae f8 89
	ld XWA,(XIZ+0x08)                                    ; FCA379  ae 08 20
	incm8 0x01, (xwa)                                    ; FCA37C  80 61
.LFCA37E:
	cp	ix, (xiz-2)                                  ; FCA37E  9e fe f4
	jrl nz, .LFCA2D4                                     ; FCA381  7e 50 ff
	jrl .LFCA46D                                         ; FCA384  78 e6 00
.LFCA387:
	ld ix, (xiz-2)                                       ; FCA387  9e fe 24
	extz XIX                                             ; FCA38A  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA38C  9c 0b 24
	cp	ix, (xiz-2)                                  ; FCA38F  9e fe f4
	jrl z, .LFCA46D                                      ; FCA392  76 d8 00
	ld H,(XIZ+0x0c)                                      ; FCA395  8e 0c 26
	and H,0x01                                           ; FCA398  ce cc 01
	ld L,(XIZ+0x0c)                                      ; FCA39B  8e 0c 27
	and L,0x02                                           ; FCA39E  cf cc 02
	ld D,(XIZ+0x0c)                                      ; FCA3A1  8e 0c 24
	and D,0x04                                           ; FCA3A4  cc cc 04
.LFCA3A7:
	ld XBC,(XIZ+0x08)                                    ; FCA3A7  ae 08 21
	ld A,(XBC+0x02)                                      ; FCA3AA  89 02 21
	ld (xiz-10), a                                       ; FCA3AD  be f6 41
	extz XIX                                             ; FCA3B0  ec 12
	ld W,(XIX)                                           ; FCA3B2  84 20
	cp W,A                                               ; FCA3B4  c9 f0
	jrl nz, .LFCA462                                     ; FCA3B6  7e a9 00
	ld A,(XBC+0x03)                                      ; FCA3B9  89 03 21
	ld (xiz-10), a                                       ; FCA3BC  be f6 41
	extz XIX                                             ; FCA3BF  ec 12
	ld W,(XIX+0x01)                                      ; FCA3C1  8c 01 20
	cp W,A                                               ; FCA3C4  c9 f0
	jrl nz, .LFCA462                                     ; FCA3C6  7e 99 00
	push XIX                                             ; FCA3C9  3c
	ld xix, (xiz-8)                                      ; FCA3CA  ae f8 24
	ld IY,(XSP)                                          ; FCA3CD  97 25
	extz XIY                                             ; FCA3CF  ed 12
	add IY,0x0002                                        ; FCA3D1  dd c8 02 00
	ldw bc, 0x09                                         ; FCA3D5  31 09 00
	ldir85                                               ; FCA3D8  85 11
	pop XIX                                              ; FCA3DA  5c
	cp h, 0x00:i3                                          ; FCA3DB  ce d8
	jr z, .LFCA3ED                                       ; FCA3DD  66 0e
	ld xbc, (xiz-8)                                      ; FCA3DF  ae f8 21
	ld A,(XBC+0x03)                                      ; FCA3E2  89 03 21
	cp A,0xff                                            ; FCA3E5  c9 cf ff
	jr z, .LFCA3ED                                       ; FCA3E8  66 03
	set 0x00,E                                           ; FCA3EA  cd 31 00
.LFCA3ED:
	cp l, 0x00:i3                                          ; FCA3ED  cf d8
	jr z, .LFCA3FF                                       ; FCA3EF  66 0e
	ld xbc, (xiz-8)                                      ; FCA3F1  ae f8 21
	ld A,(XBC+0x06)                                      ; FCA3F4  89 06 21
	cp A,0xff                                            ; FCA3F7  c9 cf ff
	jr z, .LFCA3FF                                       ; FCA3FA  66 03
	set 0x01,E                                           ; FCA3FC  cd 31 01
.LFCA3FF:
	cp d, 0x00:i3                                          ; FCA3FF  cc d8
	jr z, .LFCA411                                       ; FCA401  66 0e
	ld xbc, (xiz-8)                                      ; FCA403  ae f8 21
	ld A,(XBC+0x08)                                      ; FCA406  89 08 21
	cp A,0xff                                            ; FCA409  c9 cf ff
	jr z, .LFCA411                                       ; FCA40C  66 03
	set 0x02,E                                           ; FCA40E  cd 31 02
.LFCA411:
	extz XIX                                             ; FCA411  ec 12
	ld C,(XIX+0x05)                                      ; FCA413  8c 05 23
	cp C,0xff                                            ; FCA416  cb cf ff
	jr nz, .LFCA44E                                      ; FCA419  6e 33
	extz XIX                                             ; FCA41B  ec 12
	ld C,(XIX+0x08)                                      ; FCA41D  8c 08 23
	cp C,0xff                                            ; FCA420  cb cf ff
	jr nz, .LFCA44E                                      ; FCA423  6e 29
	extz XIX                                             ; FCA425  ec 12
	ld C,(XIX+0x0a)                                      ; FCA427  8c 0a 23
	cp C,0xff                                            ; FCA42A  cb cf ff
	jr nz, .LFCA44E                                      ; FCA42D  6e 1f
	pushw	(xiz-4)                                      ; FCA42F  9e fc 04
	pushw ix                                             ; FCA432  2c
	calr PartNoteList_MoveNode                                      ; FCA433  1e 5e fd
	ld BC,(XIZ+0x0e)                                     ; FCA436  9e 0e 21
	extz BC                                              ; FCA439  d9 12
	extz XBC                                             ; FCA43B  e9 12
	add XBC,PartNote_Budget                                   ; FCA43D  e9 c8 00 38 00 00
	incm8 0x01, (xbc)                                    ; FCA443  81 61
	ld ix, (xiz-2)                                       ; FCA445  9e fe 24
	ld IX,(XIX+0x0b)                                     ; FCA448  9c 0b 24
	pop XIY                                              ; FCA44B  5d
	jr .LFCA453                                          ; FCA44C  68 05
.LFCA44E:
	extz XIX                                             ; FCA44E  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA450  9c 0b 24
.LFCA453:
	ld XBC,0x00000009                                    ; FCA453  41 09 00 00 00
	add (xiz-8), xbc                                     ; FCA458  ae f8 89
	ld XWA,(XIZ+0x08)                                    ; FCA45B  ae 08 20
	incm8 0x01, (xwa)                                    ; FCA45E  80 61
	jr .LFCA467                                          ; FCA460  68 05
.LFCA462:
	extz XIX                                             ; FCA462  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA464  9c 0b 24
.LFCA467:
	cp	ix, (xiz-2)                                  ; FCA467  9e fe f4
	jrl nz, .LFCA3A7                                     ; FCA46A  7e 3a ff
.LFCA46D:
	ld A,E                                               ; FCA46D  cd 89
	pop XIX                                              ; FCA46F  5c
	popw de                                              ; FCA470  4a
	popw hl                                              ; FCA471  4b
	unlk XIZ                                             ; FCA472  ee 0d
	ret                                                  ; FCA474  0e
; PartNotes_BuildReleaseFrame: (frame with a source at +2 -- 0xFF any -- and a channel key at +3, outputs mask, part): each of the part's notes
;   (PartNoteList_Heads) from that source with that key goes into the frame as a note-off (velocity 0) and is marked
;   released (0xFF) on each output of the mask it still sounds on -- node +5 tone generator, +8 MIDI OUT, +0x0A
;   record; a node released on all three returns to the pool and to the part's PartNote_Budget.  A = the outputs the
;   frame must go to (bit 0 / 1 / 2).
PartNotes_BuildReleaseFrame:
	link XIZ,0xffee                                      ; FCA475  ee 0c ee ff
	pushw hl                                             ; FCA479  2b
	pushw de                                             ; FCA47A  2a
	push XIX                                             ; FCA47B  3c
	ld c, 0x0f:opc                                          ; FCA47C  23 0f
	mul	bc, (xiz+14)                                 ; FCA47E  8e 0e 43
	ld HL,BC                                             ; FCA481  d9 8b
	ldw ix, PartNoteList_Heads                                       ; FCA483  34 f7 39
	add BC,IX                                            ; FCA486  dc 81
	ld (xiz-2), bc                                       ; FCA488  be fe 51
	ld WA,IX                                             ; FCA48B  dc 88
	add WA,0x01e0                                        ; FCA48D  d8 c8 e0 01
	ld (xiz-4), wa                                       ; FCA491  be fc 50
	ld XIY,(XIZ+0x08)                                    ; FCA494  ae 08 25
	inc 7,XIY                                            ; FCA497  ed 67
	ld (xiz-8), xiy                                      ; FCA499  be f8 65
	ld e, 0x00:opc                                          ; FCA49C  25 00
	ld XBC,(XIZ+0x08)                                    ; FCA49E  ae 08 21
	ld A,(XIZ+0x0e)                                      ; FCA4A1  8e 0e 21
	ld (XBC+0x04),A                                      ; FCA4A4  b9 04 41
	ld XBC,(XIZ+0x08)                                    ; FCA4A7  ae 08 21
	ld A,(XBC+0x02)                                      ; FCA4AA  89 02 21
	cp A,0xff                                            ; FCA4AD  c9 cf ff
	jrl nz, .LFCA5AD                                     ; FCA4B0  7e fa 00
	ld ix, (xiz-2)                                       ; FCA4B3  9e fe 24
	extz XIX                                             ; FCA4B6  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA4B8  9c 0b 24
	cp	ix, (xiz-2)                                  ; FCA4BB  9e fe f4
	jrl z, .LFCA6B3                                      ; FCA4BE  76 f2 01
	ld H,(XIZ+0x0c)                                      ; FCA4C1  8e 0c 26
	and H,0x01                                           ; FCA4C4  ce cc 01
	ld L,(XIZ+0x0c)                                      ; FCA4C7  8e 0c 27
	and L,0x02                                           ; FCA4CA  cf cc 02
	ld D,(XIZ+0x0c)                                      ; FCA4CD  8e 0c 24
	and D,0x04                                           ; FCA4D0  cc cc 04
.LFCA4D3:
	ld XBC,(XIZ+0x08)                                    ; FCA4D3  ae 08 21
	ld A,(XBC+0x03)                                      ; FCA4D6  89 03 21
	ld (xiz-10), a                                       ; FCA4D9  be f6 41
	extz XIX                                             ; FCA4DC  ec 12
	ld W,(XIX+0x01)                                      ; FCA4DE  8c 01 20
	cp W,A                                               ; FCA4E1  c9 f0
	jrl nz, .LFCA59F                                     ; FCA4E3  7e b9 00
	push XIX                                             ; FCA4E6  3c
	ld xix, (xiz-8)                                      ; FCA4E7  ae f8 24
	ld IY,(XSP)                                          ; FCA4EA  97 25
	extz XIY                                             ; FCA4EC  ed 12
	add IY,0x0002                                        ; FCA4EE  dd c8 02 00
	ldw bc, 0x09                                         ; FCA4F2  31 09 00
	ldir85                                               ; FCA4F5  85 11
	pop XIX                                              ; FCA4F7  5c
	ld xbc, (xiz-8)                                      ; FCA4F8  ae f8 21
	ld (XBC+0x01),0x00                                   ; FCA4FB  b9 01 00 00
	ld xbc, (xiz-8)                                      ; FCA4FF  ae f8 21
	ld (XBC+0x04),0x00                                   ; FCA502  b9 04 00 00
	cp h, 0x00:i3                                          ; FCA506  ce d8
	jr z, .LFCA51E                                       ; FCA508  66 14
	ld xbc, (xiz-8)                                      ; FCA50A  ae f8 21
	ld A,(XBC+0x03)                                      ; FCA50D  89 03 21
	cp A,0xff                                            ; FCA510  c9 cf ff
	jr z, .LFCA51E                                       ; FCA513  66 09
	extz XIX                                             ; FCA515  ec 12
	ld (XIX+0x05),0xff                                   ; FCA517  bc 05 00 ff
	set 0x00,E                                           ; FCA51B  cd 31 00
.LFCA51E:
	cp l, 0x00:i3                                          ; FCA51E  cf d8
	jr z, .LFCA536                                       ; FCA520  66 14
	ld xbc, (xiz-8)                                      ; FCA522  ae f8 21
	ld A,(XBC+0x06)                                      ; FCA525  89 06 21
	cp A,0xff                                            ; FCA528  c9 cf ff
	jr z, .LFCA536                                       ; FCA52B  66 09
	extz XIX                                             ; FCA52D  ec 12
	ld (XIX+0x08),0xff                                   ; FCA52F  bc 08 00 ff
	set 0x01,E                                           ; FCA533  cd 31 01
.LFCA536:
	cp d, 0x00:i3                                          ; FCA536  cc d8
	jr z, .LFCA54E                                       ; FCA538  66 14
	ld xbc, (xiz-8)                                      ; FCA53A  ae f8 21
	ld A,(XBC+0x08)                                      ; FCA53D  89 08 21
	cp A,0xff                                            ; FCA540  c9 cf ff
	jr z, .LFCA54E                                       ; FCA543  66 09
	extz XIX                                             ; FCA545  ec 12
	ld (XIX+0x0a),0xff                                   ; FCA547  bc 0a 00 ff
	set 0x02,E                                           ; FCA54B  cd 31 02
.LFCA54E:
	extz XIX                                             ; FCA54E  ec 12
	ld C,(XIX+0x05)                                      ; FCA550  8c 05 23
	cp C,0xff                                            ; FCA553  cb cf ff
	jr nz, .LFCA58B                                      ; FCA556  6e 33
	extz XIX                                             ; FCA558  ec 12
	ld C,(XIX+0x08)                                      ; FCA55A  8c 08 23
	cp C,0xff                                            ; FCA55D  cb cf ff
	jr nz, .LFCA58B                                      ; FCA560  6e 29
	extz XIX                                             ; FCA562  ec 12
	ld C,(XIX+0x0a)                                      ; FCA564  8c 0a 23
	cp C,0xff                                            ; FCA567  cb cf ff
	jr nz, .LFCA58B                                      ; FCA56A  6e 1f
	pushw	(xiz-4)                                      ; FCA56C  9e fc 04
	pushw ix                                             ; FCA56F  2c
	calr PartNoteList_MoveNode                                      ; FCA570  1e 21 fc
	ld BC,(XIZ+0x0e)                                     ; FCA573  9e 0e 21
	extz BC                                              ; FCA576  d9 12
	extz XBC                                             ; FCA578  e9 12
	add XBC,PartNote_Budget                                   ; FCA57A  e9 c8 00 38 00 00
	incm8 0x01, (xbc)                                    ; FCA580  81 61
	ld ix, (xiz-2)                                       ; FCA582  9e fe 24
	ld IX,(XIX+0x0b)                                     ; FCA585  9c 0b 24
	pop XIY                                              ; FCA588  5d
	jr .LFCA590                                          ; FCA589  68 05
.LFCA58B:
	extz XIX                                             ; FCA58B  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA58D  9c 0b 24
.LFCA590:
	ld XBC,0x00000009                                    ; FCA590  41 09 00 00 00
	add (xiz-8), xbc                                     ; FCA595  ae f8 89
	ld XWA,(XIZ+0x08)                                    ; FCA598  ae 08 20
	incm8 0x01, (xwa)                                    ; FCA59B  80 61
	jr .LFCA5A4                                          ; FCA59D  68 05
.LFCA59F:
	extz XIX                                             ; FCA59F  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA5A1  9c 0b 24
.LFCA5A4:
	cp	ix, (xiz-2)                                  ; FCA5A4  9e fe f4
	jrl nz, .LFCA4D3                                     ; FCA5A7  7e 29 ff
	jrl .LFCA6B3                                         ; FCA5AA  78 06 01
.LFCA5AD:
	ld ix, (xiz-2)                                       ; FCA5AD  9e fe 24
	extz XIX                                             ; FCA5B0  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA5B2  9c 0b 24
	cp	ix, (xiz-2)                                  ; FCA5B5  9e fe f4
	jrl z, .LFCA6B3                                      ; FCA5B8  76 f8 00
	ld H,(XIZ+0x0c)                                      ; FCA5BB  8e 0c 26
	and H,0x01                                           ; FCA5BE  ce cc 01
	ld L,(XIZ+0x0c)                                      ; FCA5C1  8e 0c 27
	and L,0x02                                           ; FCA5C4  cf cc 02
	ld D,(XIZ+0x0c)                                      ; FCA5C7  8e 0c 24
	and D,0x04                                           ; FCA5CA  cc cc 04
.LFCA5CD:
	ld XBC,(XIZ+0x08)                                    ; FCA5CD  ae 08 21
	ld A,(XBC+0x02)                                      ; FCA5D0  89 02 21
	ld (xiz-10), a                                       ; FCA5D3  be f6 41
	extz XIX                                             ; FCA5D6  ec 12
	ld W,(XIX)                                           ; FCA5D8  84 20
	cp W,A                                               ; FCA5DA  c9 f0
	jrl nz, .LFCA6A8                                     ; FCA5DC  7e c9 00
	ld A,(XBC+0x03)                                      ; FCA5DF  89 03 21
	ld (xiz-10), a                                       ; FCA5E2  be f6 41
	extz XIX                                             ; FCA5E5  ec 12
	ld W,(XIX+0x01)                                      ; FCA5E7  8c 01 20
	cp W,A                                               ; FCA5EA  c9 f0
	jrl nz, .LFCA6A8                                     ; FCA5EC  7e b9 00
	push XIX                                             ; FCA5EF  3c
	ld xix, (xiz-8)                                      ; FCA5F0  ae f8 24
	ld IY,(XSP)                                          ; FCA5F3  97 25
	extz XIY                                             ; FCA5F5  ed 12
	add IY,0x0002                                        ; FCA5F7  dd c8 02 00
	ldw bc, 0x09                                         ; FCA5FB  31 09 00
	ldir85                                               ; FCA5FE  85 11
	pop XIX                                              ; FCA600  5c
	ld xbc, (xiz-8)                                      ; FCA601  ae f8 21
	ld (XBC+0x01),0x00                                   ; FCA604  b9 01 00 00
	ld xbc, (xiz-8)                                      ; FCA608  ae f8 21
	ld (XBC+0x04),0x00                                   ; FCA60B  b9 04 00 00
	cp h, 0x00:i3                                          ; FCA60F  ce d8
	jr z, .LFCA627                                       ; FCA611  66 14
	ld xbc, (xiz-8)                                      ; FCA613  ae f8 21
	ld A,(XBC+0x03)                                      ; FCA616  89 03 21
	cp A,0xff                                            ; FCA619  c9 cf ff
	jr z, .LFCA627                                       ; FCA61C  66 09
	extz XIX                                             ; FCA61E  ec 12
	ld (XIX+0x05),0xff                                   ; FCA620  bc 05 00 ff
	set 0x00,E                                           ; FCA624  cd 31 00
.LFCA627:
	cp l, 0x00:i3                                          ; FCA627  cf d8
	jr z, .LFCA63F                                       ; FCA629  66 14
	ld xbc, (xiz-8)                                      ; FCA62B  ae f8 21
	ld A,(XBC+0x06)                                      ; FCA62E  89 06 21
	cp A,0xff                                            ; FCA631  c9 cf ff
	jr z, .LFCA63F                                       ; FCA634  66 09
	extz XIX                                             ; FCA636  ec 12
	ld (XIX+0x08),0xff                                   ; FCA638  bc 08 00 ff
	set 0x01,E                                           ; FCA63C  cd 31 01
.LFCA63F:
	cp d, 0x00:i3                                          ; FCA63F  cc d8
	jr z, .LFCA657                                       ; FCA641  66 14
	ld xbc, (xiz-8)                                      ; FCA643  ae f8 21
	ld A,(XBC+0x08)                                      ; FCA646  89 08 21
	cp A,0xff                                            ; FCA649  c9 cf ff
	jr z, .LFCA657                                       ; FCA64C  66 09
	extz XIX                                             ; FCA64E  ec 12
	ld (XIX+0x0a),0xff                                   ; FCA650  bc 0a 00 ff
	set 0x02,E                                           ; FCA654  cd 31 02
.LFCA657:
	extz XIX                                             ; FCA657  ec 12
	ld C,(XIX+0x05)                                      ; FCA659  8c 05 23
	cp C,0xff                                            ; FCA65C  cb cf ff
	jr nz, .LFCA694                                      ; FCA65F  6e 33
	extz XIX                                             ; FCA661  ec 12
	ld C,(XIX+0x08)                                      ; FCA663  8c 08 23
	cp C,0xff                                            ; FCA666  cb cf ff
	jr nz, .LFCA694                                      ; FCA669  6e 29
	extz XIX                                             ; FCA66B  ec 12
	ld C,(XIX+0x0a)                                      ; FCA66D  8c 0a 23
	cp C,0xff                                            ; FCA670  cb cf ff
	jr nz, .LFCA694                                      ; FCA673  6e 1f
	pushw	(xiz-4)                                      ; FCA675  9e fc 04
	pushw ix                                             ; FCA678  2c
	calr PartNoteList_MoveNode                                      ; FCA679  1e 18 fb
	ld BC,(XIZ+0x0e)                                     ; FCA67C  9e 0e 21
	extz BC                                              ; FCA67F  d9 12
	extz XBC                                             ; FCA681  e9 12
	add XBC,PartNote_Budget                                   ; FCA683  e9 c8 00 38 00 00
	incm8 0x01, (xbc)                                    ; FCA689  81 61
	ld ix, (xiz-2)                                       ; FCA68B  9e fe 24
	ld IX,(XIX+0x0b)                                     ; FCA68E  9c 0b 24
	pop XIY                                              ; FCA691  5d
	jr .LFCA699                                          ; FCA692  68 05
.LFCA694:
	extz XIX                                             ; FCA694  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA696  9c 0b 24
.LFCA699:
	ld XBC,0x00000009                                    ; FCA699  41 09 00 00 00
	add (xiz-8), xbc                                     ; FCA69E  ae f8 89
	ld XWA,(XIZ+0x08)                                    ; FCA6A1  ae 08 20
	incm8 0x01, (xwa)                                    ; FCA6A4  80 61
	jr .LFCA6AD                                          ; FCA6A6  68 05
.LFCA6A8:
	extz XIX                                             ; FCA6A8  ec 12
	ld IX,(XIX+0x0b)                                     ; FCA6AA  9c 0b 24
.LFCA6AD:
	cp	ix, (xiz-2)                                  ; FCA6AD  9e fe f4
	jrl nz, .LFCA5CD                                     ; FCA6B0  7e 1a ff
.LFCA6B3:
	ld A,E                                               ; FCA6B3  cd 89
	pop XIX                                              ; FCA6B5  5c
	popw de                                              ; FCA6B6  4a
	popw hl                                              ; FCA6B7  4b
	unlk XIZ                                             ; FCA6B8  ee 0d
	ret                                                  ; FCA6BA  0e
; PartFrame_SendToToneGen: result bit 0 of PartNotes_ApplyFrame: the frame to the tone generator (over the link).
; 2026-10-04: per part, PartFrame_SendMonoToToneGen when the part's tone-generator record (block +0x92) has bit 6
;   and its PartToneGen_State is not 0xFF, else PartFrame_SendPolyToToneGen; their result is the new state.
PartFrame_SendToToneGen:
	link XIZ,0x0000                                      ; FCA6BB  ee 0c 00 00
	pushw hl                                             ; FCA6BF  2b
	push XIX                                             ; FCA6C0  3c
	ld XBC,(XIZ+0x08)                                    ; FCA6C1  ae 08 21
	ld H,(XBC+0x04)                                      ; FCA6C4  89 04 26
	ld a, 0x06:opc                                          ; FCA6C7  21 06
	mul wa, h                                          ; FCA6C9  ce 41
	extz XWA                                             ; FCA6CB  e8 12
	add XWA,0x00000092                                   ; FCA6CD  e8 c8 92 00 00 00
	add XWA,NoteRouting                                   ; FCA6D3  e8 c8 00 22 60 00
	bit 6,(XWA)                                          ; FCA6D9  b0 ce
	jr z, .LFCA709                                       ; FCA6DB  66 2c
	ld C,H                                               ; FCA6DD  ce 8b
	extz BC                                              ; FCA6DF  d9 12
	extz XBC                                             ; FCA6E1  e9 12
	ld XIX,XBC                                           ; FCA6E3  e9 8c
	add XBC,PartToneGen_State                                   ; FCA6E5  e9 c8 d4 20 60 00
	ld L,(XBC)                                           ; FCA6EB  81 27
	cp L,0xff                                            ; FCA6ED  cf cf ff
	jr z, .LFCA709                                       ; FCA6F0  66 17
	ld XBC,(XIZ+0x08)                                    ; FCA6F2  ae 08 21
	push XBC                                             ; FCA6F5  39
	pushw hl                                             ; FCA6F6  2b
	push 0x00                                            ; FCA6F7  09 00
	push H                                               ; FCA6F9  ce 04
	calr PartFrame_SendMonoToToneGen                                      ; FCA6FB  1e d6 01
	lda xbc, (PartToneGen_State:24)                               ; FCA6FE  f2 d4 20 60 31
	add XBC,XIX                                          ; FCA703  ec 81
	ld (XBC),A                                           ; FCA705  b1 41
	jr .LFCA731                                          ; FCA707  68 28
.LFCA709:
	ld XBC,(XIZ+0x08)                                    ; FCA709  ae 08 21
	push XBC                                             ; FCA70C  39
	ld A,H                                               ; FCA70D  ce 89
	extz WA                                              ; FCA70F  d8 12
	extz XWA                                             ; FCA711  e8 12
	ld XIX,XWA                                           ; FCA713  e8 8c
	add XWA,PartToneGen_State                                   ; FCA715  e8 c8 d4 20 60 00
	ld W,(XWA)                                           ; FCA71B  80 20
	push 0x00                                            ; FCA71D  09 00
	push W                                               ; FCA71F  c8 04
	push 0x00                                            ; FCA721  09 00
	push H                                               ; FCA723  ce 04
	calr PartFrame_SendPolyToToneGen                                      ; FCA725  1e 10 00
	lda xbc, (PartToneGen_State:24)                               ; FCA728  f2 d4 20 60 31
	add XBC,XIX                                          ; FCA72D  ec 81
	ld (XBC),A                                           ; FCA72F  b1 41
.LFCA731:
	inc 8,XSP                                            ; FCA731  ef 60
	pop XIX                                              ; FCA733  5c
	popw hl                                              ; FCA734  4b
	unlk XIZ                                             ; FCA735  ee 0d
	ret                                                  ; FCA737  0e
; PartFrame_SendPolyToToneGen: (part, state, frame): each entry's tone-generator note (entry +3) goes over the link as [0x90 (| 8), part, note,
;   velocity (+4)] and makes the state 0xFF; a note of 0xA0 sends [0xB0, part, 0x78, 0] instead (state 0x80) and 0xFF
;   is skipped.  When the part's note list is empty after a note went out, [0xB0, part, 0x7B, 0] follows and the
;   state is 0x80.  A = the new state.  On screen 0xDA the part byte is SoundSel_Group | 0xF0.  Status bit 3 is set
;   when (0x7F02) & 0xF0 is 0x10 and the frame came by the note-list path (source 0, or source 1 in mode 2 or on
;   NoteRouting_SingleChannel in mode 1); what it means on the link is not established.
PartFrame_SendPolyToToneGen:
	link XIZ,0xfff0                                      ; FCA738  ee 0c f0 ff
	pushw hl                                             ; FCA73C  2b
	pushw de                                             ; FCA73D  2a
	push XIX                                             ; FCA73E  3c
	ld e, 0x00:opc                                          ; FCA73F  25 00
	ld h, 0x00:opc                                          ; FCA741  26 00
	ld D,(XIZ+0x08)                                      ; FCA743  8e 08 24
	cp	(UI_ScreenLatch:16), 0xda                            ; FCA746  c1 7a 20 3f da
	jr nz, .LFCA754                                      ; FCA74B  6e 07
	ld d, (SoundSel_Group:16)                                   ; FCA74D  c1 69 21 24
	or D,0xf0                                            ; FCA751  cc ce f0
.LFCA754:
	ld c, (0x7f02:16)                                   ; FCA754  c1 02 7f 23
	extz BC                                              ; FCA758  d9 12
	and BC,0x00f0                                        ; FCA75A  d9 cc f0 00
	cp BC,0x0010                                         ; FCA75E  d9 cf 10 00
	jr nz, .LFCA79E                                      ; FCA762  6e 3a
	ld XBC,(XIZ+0x0c)                                    ; FCA764  ae 0c 21
	ld L,(XBC+0x02)                                      ; FCA767  89 02 27
	cp l, 0x00:i3                                          ; FCA76A  cf d8
	jr z, .LFCA79C                                       ; FCA76C  66 2e
	cp l, 0x01:i3                                          ; FCA76E  cf d9
	jr nz, .LFCA79E                                      ; FCA770  6e 2c
	ld a, (NoteRouting_MidiFlags:24)                                 ; FCA772  c2 93 24 60 21
	and A,0xc0                                           ; FCA777  c9 cc c0
	srl a, 0x06                                          ; FCA77A  c9 ef 06
	cp a, 0x01:i3                                          ; FCA77D  c9 d9
	jr nz, .LFCA78D                                      ; FCA77F  6e 0c
	ld L,(XBC+0x03)                                      ; FCA781  89 03 27
	ld a, (NoteRouting_SingleChannel:24)                                 ; FCA784  c2 92 24 60 21
	cp A,L                                               ; FCA789  cf f1
	jr z, .LFCA79C                                       ; FCA78B  66 0f
.LFCA78D:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FCA78D  c2 93 24 60 23
	and C,0xc0                                           ; FCA792  cb cc c0
	srl c, 0x06                                          ; FCA795  cb ef 06
	cp c, 0x02:i3                                          ; FCA798  cb da
	jr nz, .LFCA79E                                      ; FCA79A  6e 02
.LFCA79C:
	ld h, 0x08:opc                                          ; FCA79C  26 08
.LFCA79E:
	lda xix, (NoteSend_MsgBuffer:24)                               ; FCA79E  f2 00 20 60 34
	ld XBC,(XIZ+0x0c)                                    ; FCA7A3  ae 0c 21
	inc 7,XBC                                            ; FCA7A6  e9 67
	ld (xiz-4), xbc                                      ; FCA7A8  be fc 61
	ld L,H                                               ; FCA7AB  ce 8f
	or L,0x90                                            ; FCA7AD  cf ce 90
.LFCA7B0:
	ld XBC,(XIZ+0x0c)                                    ; FCA7B0  ae 0c 21
	ld A,(XBC)                                           ; FCA7B3  81 21
	mul A,0x09                                           ; FCA7B5  c9 08 09
	extz XWA                                             ; FCA7B8  e8 12
	inc 7,XWA                                            ; FCA7BA  e8 67
	add XBC,XWA                                          ; FCA7BC  e8 81
	ld (xiz-8), xbc                                      ; FCA7BE  be f8 61
; (sub_FCA7C1 removed 2026-10-04: no code names it and the line above falls through into it -- part of PartFrame_SendPolyToToneGen;
;  notes/prom_a_stray_label_removal.py)
	ld xwa, (xiz-4)                                      ; FCA7C1  ae fc 20
	cp XWA,XBC                                           ; FCA7C4  e9 f0
	jrl nc, .LFCA878                                     ; FCA7C6  7f af 00
	ld xbc, (xiz-4)                                      ; FCA7C9  ae fc 21
	ld H,(XBC+0x03)                                      ; FCA7CC  89 03 26
	ld A,H                                               ; FCA7CF  ce 89
	extz WA                                              ; FCA7D1  d8 12
	cp WA,0x00a0                                         ; FCA7D3  d8 cf a0 00
	jr z, .LFCA7E2                                       ; FCA7D7  66 09
	cp WA,0x00ff                                         ; FCA7D9  d8 cf ff 00
	jrl z, .LFCA86D                                      ; FCA7DD  76 8d 00
	jr .LFCA817                                          ; FCA7E0  68 35
.LFCA7E2:
	ld (XIX),0xb0                                        ; FCA7E2  b4 00 b0
	ld XBC,XIX                                           ; FCA7E5  ec 89
	inc 1,XBC                                            ; FCA7E7  e9 61
	ld (xiz-8), xbc                                      ; FCA7E9  be f8 61
	ld (XBC),D                                           ; FCA7EC  b1 44
	ld xbc, (xiz-8)                                      ; FCA7EE  ae f8 21
	ld (XBC+0x01),0x78                                   ; FCA7F1  b9 01 00 78
	ld xbc, (xiz-8)                                      ; FCA7F5  ae f8 21
	ld (XBC+0x02),0x00                                   ; FCA7F8  b9 02 00 00
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCA7FC  f2 00 20 60 31
	push XBC                                             ; FCA801  39
	pushw 0x04                                           ; FCA802  0b 04 00
	pushw 0x00                                           ; FCA805  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCA808  1d d4 0e f4
	lda xix, (NoteSend_MsgBuffer:24)                               ; FCA80C  f2 00 20 60 34
	ld (XIZ+0x0a),0x80                                   ; FCA811  be 0a 00 80
	jr .LFCA86B                                          ; FCA815  68 54
.LFCA817:
	cp H,0xff                                            ; FCA817  ce cf ff
	jr z, .LFCA86D                                       ; FCA81A  66 51
	ld (XIX),L                                           ; FCA81C  b4 47
	ld XBC,XIX                                           ; FCA81E  ec 89
	inc 1,XBC                                            ; FCA820  e9 61
	ld (xiz-8), xbc                                      ; FCA822  be f8 61
	ld (XBC),D                                           ; FCA825  b1 44
	ld xbc, (xiz-8)                                      ; FCA827  ae f8 21
	inc 1,XBC                                            ; FCA82A  e9 61
	ld (xiz-12), xbc                                     ; FCA82C  be f4 61
	ld xwa, (xiz-4)                                      ; FCA82F  ae fc 20
	ld C,(XWA+0x03)                                      ; FCA832  88 03 23
	ld H,C                                               ; FCA835  cb 8e
	ld xbc, (xiz-12)                                     ; FCA837  ae f4 21
	ld (XBC),H                                           ; FCA83A  b1 46
	ld xbc, (xiz-8)                                      ; FCA83C  ae f8 21
	inc 2,XBC                                            ; FCA83F  e9 62
	ld (xiz-16), xbc                                     ; FCA841  be f0 61
	ld xwa, (xiz-4)                                      ; FCA844  ae fc 20
	ld C,(XWA+0x04)                                      ; FCA847  88 04 23
	ld H,C                                               ; FCA84A  cb 8e
	ld xbc, (xiz-16)                                     ; FCA84C  ae f0 21
	ld (XBC),H                                           ; FCA84F  b1 46
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCA851  f2 00 20 60 31
	push XBC                                             ; FCA856  39
	pushw 0x04                                           ; FCA857  0b 04 00
	pushw 0x00                                           ; FCA85A  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCA85D  1d d4 0e f4
	lda xix, (NoteSend_MsgBuffer:24)                               ; FCA861  f2 00 20 60 34
	ld e, 0xff:opc                                          ; FCA866  25 ff
	ld (XIZ+0x0a),E                                      ; FCA868  be 0a 45
.LFCA86B:
	inc 8,XSP                                            ; FCA86B  ef 60
.LFCA86D:
	ld XBC,0x00000009                                    ; FCA86D  41 09 00 00 00
	add (xiz-4), xbc                                     ; FCA872  ae fc 89
	jrl .LFCA7B0                                         ; FCA875  78 38 ff
.LFCA878:
	ld c, 0x0f:opc                                          ; FCA878  23 0f
	mul	bc, (xiz+8)                                  ; FCA87A  8e 08 43
	ld HL,BC                                             ; FCA87D  d9 8b
	ldw wa, PartNoteList_Heads                                       ; FCA87F  30 f7 39
	add WA,BC                                            ; FCA882  d9 80
	ld (xiz-6), wa                                       ; FCA884  be fa 50
	add BC,0x000d                                        ; FCA887  d9 c8 0d 00
	extz XBC                                             ; FCA88B  e9 12
	ld IY,(XBC+PartNoteList_Heads)                                   ; FCA88D  d3 e5 f7 39 25
	cp IY,WA                                             ; FCA892  d8 f5
	jr nz, .LFCA8CB                                      ; FCA894  6e 35
	cp E,0xff                                            ; FCA896  cd cf ff
	jr nz, .LFCA8CB                                      ; FCA899  6e 30
	ld (XIX),0xb0                                        ; FCA89B  b4 00 b0
	ld XBC,XIX                                           ; FCA89E  ec 89
	inc 1,XBC                                            ; FCA8A0  e9 61
	ld (xiz-8), xbc                                      ; FCA8A2  be f8 61
	ld (XBC),D                                           ; FCA8A5  b1 44
	ld xbc, (xiz-8)                                      ; FCA8A7  ae f8 21
	ld (XBC+0x01),0x7b                                   ; FCA8AA  b9 01 00 7b
	ld xbc, (xiz-8)                                      ; FCA8AE  ae f8 21
	ld (XBC+0x02),0x00                                   ; FCA8B1  b9 02 00 00
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCA8B5  f2 00 20 60 31
	push XBC                                             ; FCA8BA  39
	pushw 0x04                                           ; FCA8BB  0b 04 00
	pushw 0x00                                           ; FCA8BE  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCA8C1  1d d4 0e f4
	inc 8,XSP                                            ; FCA8C5  ef 60
	ld a, 0x80:opc                                          ; FCA8C7  21 80
	jr .LFCA8CE                                          ; FCA8C9  68 03
.LFCA8CB:
	ld A,(XIZ+0x0a)                                      ; FCA8CB  8e 0a 21
.LFCA8CE:
	pop XIX                                              ; FCA8CE  5c
	popw de                                              ; FCA8CF  4a
	popw hl                                              ; FCA8D0  4b
	unlk XIZ                                             ; FCA8D1  ee 0d
	ret                                                  ; FCA8D3  0e
; PartFrame_SendMonoToToneGen: (part, state, frame), for a part whose tone-generator record has bit 6: one note at a time, the one at the tail of
;   the part's note list (head +0x0D).  State 0x80 (silent): a note-on for it.  A different note sounding: its note-off
;   and the new note-on in one 8-byte block.  List empty: the sounding note's note-off and [0xB0, part, 0x7B, 0].
;   A = the note now sounding, or 0x80.  The status byte is built as in PartFrame_SendPolyToToneGen.
PartFrame_SendMonoToToneGen:
	link XIZ,0xffee                                      ; FCA8D4  ee 0c ee ff
	push XHL                                             ; FCA8D8  3b
	push XDE                                             ; FCA8D9  3a
	push XIX                                             ; FCA8DA  3c
	ld c, 0x0f:opc                                          ; FCA8DB  23 0f
	mul	bc, (xiz+8)                                  ; FCA8DD  8e 08 43
	ld HL,BC                                             ; FCA8E0  d9 8b
	ldw ix, PartNoteList_Heads                                       ; FCA8E2  34 f7 39
	add IX,BC                                            ; FCA8E5  d9 84
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCA8E7  f2 00 20 60 31
	ld (xiz-4), xbc                                      ; FCA8EC  be fc 61
	ld A,(XIZ+0x08)                                      ; FCA8EF  8e 08 21
	ld (xiz-5), a                                        ; FCA8F2  be fb 41
	ld (xiz-6), 0x00                                     ; FCA8F5  be fa 00 00
	cp	(UI_ScreenLatch:16), 0xda                            ; FCA8F9  c1 7a 20 3f da
	jr NZ,.LFCA90A                                       ; FCA8FE  6e 0a
	ld w, (SoundSel_Group:16)                                   ; FCA900  c1 69 21 20
	or W,0xf0                                            ; FCA904  c8 ce f0
	ld (xiz-5), w                                        ; FCA907  be fb 40
.LFCA90A:
	ld c, (0x7f02:16)                                   ; FCA90A  c1 02 7f 23
	extz BC                                              ; FCA90E  d9 12
	and BC,0x00f0                                        ; FCA910  d9 cc f0 00
	cp BC,0x0010                                         ; FCA914  d9 cf 10 00
	jr nz, .LFCA95B                                      ; FCA918  6e 41
	ld XBC,(XIZ+0x0c)                                    ; FCA91A  ae 0c 21
	ld H,(XBC+0x02)                                      ; FCA91D  89 02 26
	cp h, 0x00:i3                                          ; FCA920  ce d8
	jr z, .LFCA952                                       ; FCA922  66 2e
	cp h, 0x01:i3                                          ; FCA924  ce d9
	jr nz, .LFCA95B                                      ; FCA926  6e 33
	ld a, (NoteRouting_MidiFlags:24)                                 ; FCA928  c2 93 24 60 21
	and A,0xc0                                           ; FCA92D  c9 cc c0
	srl a, 0x06                                          ; FCA930  c9 ef 06
	cp a, 0x01:i3                                          ; FCA933  c9 d9
	jr nz, .LFCA943                                      ; FCA935  6e 0c
	ld H,(XBC+0x03)                                      ; FCA937  89 03 26
	ld a, (NoteRouting_SingleChannel:24)                                 ; FCA93A  c2 92 24 60 21
	cp A,H                                               ; FCA93F  ce f1
	jr z, .LFCA952                                       ; FCA941  66 0f
.LFCA943:
	ld c, (NoteRouting_MidiFlags:24)                                 ; FCA943  c2 93 24 60 23
	and C,0xc0                                           ; FCA948  cb cc c0
	srl c, 0x06                                          ; FCA94B  cb ef 06
	cp c, 0x02:i3                                          ; FCA94E  cb da
	jr nz, .LFCA95B                                      ; FCA950  6e 09
.LFCA952:
	ld c, (xiz-5)                                        ; FCA952  8e fb 23
	set 0x03,C                                           ; FCA955  cb 31 03
	ld (xiz-6), c                                        ; FCA958  be fa 43
.LFCA95B:
	cp (XIZ+0x0a),0x80                                   ; FCA95B  8e 0a 3f 80
	jrl nz, .LFCA9CE                                     ; FCA95F  7e 6c 00
	extz XIX                                             ; FCA962  ec 12
	ld DE,(XIX+0x0d)                                     ; FCA964  9c 0d 22
	cp DE,IX                                             ; FCA967  dc f2
	jrl z, .LFCAA8F                                      ; FCA969  76 23 01
	ld HL,DE                                             ; FCA96C  da 8b
	extz XDE                                             ; FCA96E  ea 12
	ld C,(XDE+0x05)                                      ; FCA970  8a 05 23
	cp C,0xff                                            ; FCA973  cb cf ff
	jrl z, .LFCAA8F                                      ; FCA976  76 16 01
	ld c, (xiz-6)                                        ; FCA979  8e fa 23
	or C,0x90                                            ; FCA97C  cb ce 90
	ld D,C                                               ; FCA97F  cb 8c
	ld xbc, (xiz-4)                                      ; FCA981  ae fc 21
	ld (XBC),D                                           ; FCA984  b1 44
	ld xbc, (xiz-4)                                      ; FCA986  ae fc 21
	inc 1,XBC                                            ; FCA989  e9 61
	ld (xiz-10), xbc                                     ; FCA98B  be f6 61
	ld a, (xiz-5)                                        ; FCA98E  8e fb 21
	ld (XBC),A                                           ; FCA991  b1 41
	ld xbc, (xiz-10)                                     ; FCA993  ae f6 21
	inc 1,XBC                                            ; FCA996  e9 61
	ld (xiz-14), xbc                                     ; FCA998  be f2 61
	extz XHL                                             ; FCA99B  eb 12
	ld A,(XHL+0x05)                                      ; FCA99D  8b 05 21
	ld (XBC),A                                           ; FCA9A0  b1 41
	ld xbc, (xiz-10)                                     ; FCA9A2  ae f6 21
	inc 2,XBC                                            ; FCA9A5  e9 62
	ld (xiz-18), xbc                                     ; FCA9A7  be ee 61
	ld A,(XHL+0x06)                                      ; FCA9AA  8b 06 21
	ld (XBC),A                                           ; FCA9AD  b1 41
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCA9AF  f2 00 20 60 31
	push XBC                                             ; FCA9B4  39
	pushw 0x04                                           ; FCA9B5  0b 04 00
	pushw 0x00                                           ; FCA9B8  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCA9BB  1d d4 0e f4
	extz XIX                                             ; FCA9BF  ec 12
	ld BC,(XIX+0x0d)                                     ; FCA9C1  9c 0d 21
	extz XBC                                             ; FCA9C4  e9 12
	ld A,(XBC+0x05)                                      ; FCA9C6  89 05 21
	inc 8,XSP                                            ; FCA9C9  ef 60
	jrl .LFCAA92                                         ; FCA9CB  78 c4 00
.LFCA9CE:
	extz XIX                                             ; FCA9CE  ec 12
	ld DE,(XIX+0x0d)                                     ; FCA9D0  9c 0d 22
	cp DE,IX                                             ; FCA9D3  dc f2
	jrl z, .LFCAA46                                      ; FCA9D5  76 6e 00
	ld HL,DE                                             ; FCA9D8  da 8b
	extz XDE                                             ; FCA9DA  ea 12
	ld D,(XDE+0x05)                                      ; FCA9DC  8a 05 24
	cp D,0xff                                            ; FCA9DF  cc cf ff
	jrl z, .LFCAA8F                                      ; FCA9E2  76 aa 00
	cp D,(XIZ+0x0a)                                      ; FCA9E5  8e 0a f4
	jrl z, .LFCAA8F                                      ; FCA9E8  76 a4 00
	ld d, (xiz-6)                                        ; FCA9EB  8e fa 24
	or D,0x90                                            ; FCA9EE  cc ce 90
	ld xbc, (xiz-4)                                      ; FCA9F1  ae fc 21
	ld (XBC),D                                           ; FCA9F4  b1 44
	ld xix, (xiz-4)                                      ; FCA9F6  ae fc 24
	inc 1,XIX                                            ; FCA9F9  ec 61
	ld c, (xiz-5)                                        ; FCA9FB  8e fb 23
	ld (XIX),C                                           ; FCA9FE  b4 43
	ld C,(XIZ+0x0a)                                      ; FCAA00  8e 0a 23
	ld (XIX+0x01),C                                      ; FCAA03  bc 01 43
	ld (XIX+0x02),0x00                                   ; FCAA06  bc 02 00 00
	ld (XIX+0x03),D                                      ; FCAA0A  bc 03 44
	ld c, (xiz-5)                                        ; FCAA0D  8e fb 23
	ld (XIX+0x04),C                                      ; FCAA10  bc 04 43
	ld XBC,XIX                                           ; FCAA13  ec 89
	inc 5,XBC                                            ; FCAA15  e9 65
	ld (xiz-10), xbc                                     ; FCAA17  be f6 61
	extz XHL                                             ; FCAA1A  eb 12
	ld A,(XHL+0x05)                                      ; FCAA1C  8b 05 21
	ld (XBC),A                                           ; FCAA1F  b1 41
	ld XBC,XIX                                           ; FCAA21  ec 89
	inc 6,XBC                                            ; FCAA23  e9 66
	ld (xiz-14), xbc                                     ; FCAA25  be f2 61
	ld A,(XHL+0x06)                                      ; FCAA28  8b 06 21
	ld (XBC),A                                           ; FCAA2B  b1 41
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAA2D  f2 00 20 60 31
	push XBC                                             ; FCAA32  39
	pushw 0x08                                           ; FCAA33  0b 08 00
	pushw 0x00                                           ; FCAA36  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCAA39  1d d4 0e f4
	ld C,(XHL+0x05)                                      ; FCAA3D  8b 05 23
	inc 8,XSP                                            ; FCAA40  ef 60
	ld A,C                                               ; FCAA42  cb 89
	jr .LFCAA92                                          ; FCAA44  68 4c
.LFCAA46:
	ld c, (xiz-6)                                        ; FCAA46  8e fa 23
	or C,0x90                                            ; FCAA49  cb ce 90
	ld H,C                                               ; FCAA4C  cb 8e
	ld xbc, (xiz-4)                                      ; FCAA4E  ae fc 21
	ld (XBC),H                                           ; FCAA51  b1 46
	ld xix, (xiz-4)                                      ; FCAA53  ae fc 24
	inc 1,XIX                                            ; FCAA56  ec 61
	ld c, (xiz-5)                                        ; FCAA58  8e fb 23
	ld (XIX),C                                           ; FCAA5B  b4 43
	ld C,(XIZ+0x0a)                                      ; FCAA5D  8e 0a 23
	ld (XIX+0x01),C                                      ; FCAA60  bc 01 43
	ld (XIX+0x02),0x00                                   ; FCAA63  bc 02 00 00
	ld (XIX+0x03),0xb0                                   ; FCAA67  bc 03 00 b0
	ld c, (xiz-5)                                        ; FCAA6B  8e fb 23
	ld (XIX+0x04),C                                      ; FCAA6E  bc 04 43
	ld (XIX+0x05),0x7b                                   ; FCAA71  bc 05 00 7b
	ld (XIX+0x06),0x00                                   ; FCAA75  bc 06 00 00
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAA79  f2 00 20 60 31
	push XBC                                             ; FCAA7E  39
	pushw 0x08                                           ; FCAA7F  0b 08 00
	pushw 0x00                                           ; FCAA82  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCAA85  1d d4 0e f4
	inc 8,XSP                                            ; FCAA89  ef 60
	ld a, 0x80:opc                                          ; FCAA8B  21 80
	jr .LFCAA92                                          ; FCAA8D  68 03
.LFCAA8F:
	ld A,(XIZ+0x0a)                                      ; FCAA8F  8e 0a 21
.LFCAA92:
	pop XIX                                              ; FCAA92  5c
	pop XDE                                              ; FCAA93  5a
	pop XHL                                              ; FCAA94  5b
	unlk XIZ                                             ; FCAA95  ee 0d
	ret                                                  ; FCAA97  0e
; PartFrame_SendToMidiOut: result bit 1, unless (0x602493) bit 5: the frame to the MIDI OUT rings (T_Ring601432 / T_Ring60153C,
;   T_MIDI_PostSendWork).
PartFrame_SendToMidiOut:
	link XIZ,0xfff8                                      ; FCAA98  ee 0c f8 ff
	pushw hl                                             ; FCAA9C  2b
	pushw de                                             ; FCAA9D  2a
	push XIX                                             ; FCAA9E  3c
	lda xix, (NoteSend_MsgBuffer:24)                               ; FCAA9F  f2 00 20 60 34
	ld XBC,(XIZ+0x08)                                    ; FCAAA4  ae 08 21
	inc 7,XBC                                            ; FCAAA7  e9 67
	ld (xiz-4), xbc                                      ; FCAAA9  be fc 61
.LFCAAAC:
	ld XBC,(XIZ+0x08)                                    ; FCAAAC  ae 08 21
	ld A,(XBC)                                           ; FCAAAF  81 21
	mul A,0x09                                           ; FCAAB1  c9 08 09
	extz XWA                                             ; FCAAB4  e8 12
	inc 7,XWA                                            ; FCAAB6  e8 67
	add XBC,XWA                                          ; FCAAB8  e8 81
	ld (xiz-8), xbc                                      ; FCAABA  be f8 61
	ld xwa, (xiz-4)                                      ; FCAABD  ae fc 20
	cp XWA,XBC                                           ; FCAAC0  e9 f0
	jrl nc, .LFCABCB                                     ; FCAAC2  7f 06 01
	ld xbc, (xiz-4)                                      ; FCAAC5  ae fc 21
	ld A,(XBC+0x06)                                      ; FCAAC8  89 06 21
	cp A,0xff                                            ; FCAACB  c9 cf ff
	jrl z, .LFCABC0                                      ; FCAACE  76 ef 00
	ld H,(XBC+0x05)                                      ; FCAAD1  89 05 26
	cp H,0x10                                            ; FCAAD4  ce cf 10
	jrl nc, .LFCAB4B                                     ; FCAAD7  7f 71 00
	and H,0x0f                                           ; FCAADA  ce cc 0f
	or H,0x90                                            ; FCAADD  ce ce 90
	ld	a, (0x9b:8)                                      ; FCAAE0  c0 9b 21
	cp A,H                                               ; FCAAE3  ce f1
	jr z, .LFCAB11                                       ; FCAAE5  66 2a
	ld	(0x9b:8), h                                      ; FCAAE7  f0 9b 46
	ld (XIX),H                                           ; FCAAEA  b4 46
	ld XBC,XIX                                           ; FCAAEC  ec 89
	inc 1,XBC                                            ; FCAAEE  e9 61
	ld (xiz-8), xbc                                      ; FCAAF0  be f8 61
	ld xwa, (xiz-4)                                      ; FCAAF3  ae fc 20
	ld C,(XWA+0x06)                                      ; FCAAF6  88 06 23
	ld L,C                                               ; FCAAF9  cb 8f
	ld xbc, (xiz-8)                                      ; FCAAFB  ae f8 21
	ld (XBC),L                                           ; FCAAFE  b1 47
	ld xix, (xiz-8)                                      ; FCAB00  ae f8 24
	inc 1,XIX                                            ; FCAB03  ec 61
	ld xbc, (xiz-4)                                      ; FCAB05  ae fc 21
	ld A,(XBC+0x01)                                      ; FCAB08  89 01 21
	ld (XIX),A                                           ; FCAB0B  b4 41
	ld h, 0x03:opc                                          ; FCAB0D  26 03
	jr .LFCAB2F                                          ; FCAB0F  68 1e
.LFCAB11:
	ld xbc, (xiz-4)                                      ; FCAB11  ae fc 21
	ld A,(XBC+0x06)                                      ; FCAB14  89 06 21
	ld (XIX),A                                           ; FCAB17  b4 41
	ld XBC,XIX                                           ; FCAB19  ec 89
	inc 1,XBC                                            ; FCAB1B  e9 61
	ld (xiz-8), xbc                                      ; FCAB1D  be f8 61
	ld xwa, (xiz-4)                                      ; FCAB20  ae fc 20
	ld C,(XWA+0x01)                                      ; FCAB23  88 01 23
	ld L,C                                               ; FCAB26  cb 8f
	ld xbc, (xiz-8)                                      ; FCAB28  ae f8 21
	ld (XBC),L                                           ; FCAB2B  b1 47
	ld h, 0x02:opc                                          ; FCAB2D  26 02
.LFCAB2F:
	ei 0x06                                              ; FCAB2F  06 06
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAB31  f2 00 20 60 31
	push XBC                                             ; FCAB36  39
	ld A,H                                               ; FCAB37  ce 89
	extz WA                                              ; FCAB39  d8 12
	pushw wa                                             ; FCAB3B  28
	call T_Ring601432_PutBlock                           ; FCAB3C  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FCAB40  1d 24 07 f4
	inc 6,XSP                                            ; FCAB44  ef 66
	ei 0x00                                              ; FCAB46  06 00
	jrl .LFCABBB                                         ; FCAB48  78 70 00
.LFCAB4B:
	and H,0x0f                                           ; FCAB4B  ce cc 0f
	or H,0x90                                            ; FCAB4E  ce ce 90
	ld c, (0x091f:16)                                   ; FCAB51  c1 1f 09 23
	cp C,H                                               ; FCAB55  ce f3
	jr z, .LFCAB84                                       ; FCAB57  66 2b
	ld (0x091f:16), h                                   ; FCAB59  f1 1f 09 46
	ld (XIX),H                                           ; FCAB5D  b4 46
	ld XBC,XIX                                           ; FCAB5F  ec 89
	inc 1,XBC                                            ; FCAB61  e9 61
	ld (xiz-8), xbc                                      ; FCAB63  be f8 61
	ld xwa, (xiz-4)                                      ; FCAB66  ae fc 20
	ld C,(XWA+0x06)                                      ; FCAB69  88 06 23
	ld L,C                                               ; FCAB6C  cb 8f
	ld xbc, (xiz-8)                                      ; FCAB6E  ae f8 21
	ld (XBC),L                                           ; FCAB71  b1 47
	ld xix, (xiz-8)                                      ; FCAB73  ae f8 24
	inc 1,XIX                                            ; FCAB76  ec 61
	ld xbc, (xiz-4)                                      ; FCAB78  ae fc 21
	ld A,(XBC+0x01)                                      ; FCAB7B  89 01 21
	ld (XIX),A                                           ; FCAB7E  b4 41
	ld h, 0x03:opc                                          ; FCAB80  26 03
	jr .LFCABA2                                          ; FCAB82  68 1e
.LFCAB84:
	ld xbc, (xiz-4)                                      ; FCAB84  ae fc 21
	ld A,(XBC+0x06)                                      ; FCAB87  89 06 21
	ld (XIX),A                                           ; FCAB8A  b4 41
	ld XBC,XIX                                           ; FCAB8C  ec 89
	inc 1,XBC                                            ; FCAB8E  e9 61
	ld (xiz-8), xbc                                      ; FCAB90  be f8 61
	ld xwa, (xiz-4)                                      ; FCAB93  ae fc 20
	ld C,(XWA+0x01)                                      ; FCAB96  88 01 23
	ld L,C                                               ; FCAB99  cb 8f
	ld xbc, (xiz-8)                                      ; FCAB9B  ae f8 21
	ld (XBC),L                                           ; FCAB9E  b1 47
	ld h, 0x02:opc                                          ; FCABA0  26 02
.LFCABA2:
	ei 0x06                                              ; FCABA2  06 06
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCABA4  f2 00 20 60 31
	push XBC                                             ; FCABA9  39
	ld A,H                                               ; FCABAA  ce 89
	extz WA                                              ; FCABAC  d8 12
	pushw wa                                             ; FCABAE  28
	call T_Ring60153C_PutBlock                           ; FCABAF  1d 1c 1e f4
	call T_MIDI_PostSendWork_PortB                       ; FCABB3  1d 30 07 f4
	inc 6,XSP                                            ; FCABB7  ef 66
	ei 0x00                                              ; FCABB9  06 00
.LFCABBB:
	lda xix, (NoteSend_MsgBuffer:24)                               ; FCABBB  f2 00 20 60 34
.LFCABC0:
	ld XBC,0x00000009                                    ; FCABC0  41 09 00 00 00
	add (xiz-4), xbc                                     ; FCABC5  ae fc 89
	jrl .LFCAAAC                                         ; FCABC8  78 e1 fe
.LFCABCB:
	ld bc, (NoteRouting_Mode:24)                                ; FCABCB  d2 98 24 60 21
	and BC,0x0008                                        ; FCABD0  d9 cc 08 00
	jrl z, .LFCACA4                                      ; FCABD4  76 cd 00
	ld XBC,0x00000009                                    ; FCABD7  41 09 00 00 00
	sub (xiz-4), xbc                                     ; FCABDC  ae fc a9
	ld XWA,(XIZ+0x08)                                    ; FCABDF  ae 08 20
	ld C,(XWA+0x03)                                      ; FCABE2  88 03 23
	mul C,0x0f                                           ; FCABE5  cb 08 0f
	ld HL,BC                                             ; FCABE8  d9 8b
	ldw bc, PartNoteList_Heads                                       ; FCABEA  31 f7 39
	ld DE,BC                                             ; FCABED  d9 8a
	add DE,HL                                            ; FCABEF  db 82
	ld BC,HL                                             ; FCABF1  db 89
	add BC,0x000d                                        ; FCABF3  d9 c8 0d 00
	extz XBC                                             ; FCABF7  e9 12
	ld IY,(XBC+PartNoteList_Heads)                                   ; FCABF9  d3 e5 f7 39 25
	cp IY,DE                                             ; FCABFE  da f5
	jrl nz, .LFCACA4                                     ; FCAC00  7e a1 00
	ld xbc, (xiz-4)                                      ; FCAC03  ae fc 21
	ld H,(XBC+0x05)                                      ; FCAC06  89 05 26
	cp H,0x10                                            ; FCAC09  ce cf 10
	jr nc, .LFCAC59                                      ; FCAC0C  6f 4b
	and H,0x0f                                           ; FCAC0E  ce cc 0f
	or H,0xb0                                            ; FCAC11  ce ce b0
	ld	c, (0x9b:8)                                      ; FCAC14  c0 9b 23
	cp C,H                                               ; FCAC17  ce f3
	jr z, .LFCAC35                                       ; FCAC19  66 1a
	ld	(0x9b:8), h                                      ; FCAC1B  f0 9b 46
	ld (XIX),H                                           ; FCAC1E  b4 46
	ld XBC,XIX                                           ; FCAC20  ec 89
	inc 1,XBC                                            ; FCAC22  e9 61
	ld (xiz-8), xbc                                      ; FCAC24  be f8 61
	ld (XBC),0x7b                                        ; FCAC27  b1 00 7b
	ld xbc, (xiz-8)                                      ; FCAC2A  ae f8 21
	ld (XBC+0x01),0x00                                   ; FCAC2D  b9 01 00 00
	ld h, 0x03:opc                                          ; FCAC31  26 03
	jr .LFCAC3E                                          ; FCAC33  68 09
.LFCAC35:
	ld (XIX),0x7b                                        ; FCAC35  b4 00 7b
	ld (XIX+0x01),0x00                                   ; FCAC38  bc 01 00 00
	ld h, 0x02:opc                                          ; FCAC3C  26 02
.LFCAC3E:
	ei 0x06                                              ; FCAC3E  06 06
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAC40  f2 00 20 60 31
	push XBC                                             ; FCAC45  39
	ld A,H                                               ; FCAC46  ce 89
	extz WA                                              ; FCAC48  d8 12
	pushw wa                                             ; FCAC4A  28
	call T_Ring601432_PutBlock                           ; FCAC4B  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FCAC4F  1d 24 07 f4
	inc 6,XSP                                            ; FCAC53  ef 66
	ei 0x00                                              ; FCAC55  06 00
	jr .LFCACA4                                          ; FCAC57  68 4b
.LFCAC59:
	and H,0x0f                                           ; FCAC59  ce cc 0f
	or H,0xb0                                            ; FCAC5C  ce ce b0
	ld c, (0x091f:16)                                   ; FCAC5F  c1 1f 09 23
	cp C,H                                               ; FCAC63  ce f3
	jr z, .LFCAC82                                       ; FCAC65  66 1b
	ld (0x091f:16), h                                   ; FCAC67  f1 1f 09 46
	ld (XIX),H                                           ; FCAC6B  b4 46
	ld XBC,XIX                                           ; FCAC6D  ec 89
	inc 1,XBC                                            ; FCAC6F  e9 61
	ld (xiz-8), xbc                                      ; FCAC71  be f8 61
	ld (XBC),0x7b                                        ; FCAC74  b1 00 7b
	ld xbc, (xiz-8)                                      ; FCAC77  ae f8 21
	ld (XBC+0x01),0x00                                   ; FCAC7A  b9 01 00 00
	ld h, 0x03:opc                                          ; FCAC7E  26 03
	jr .LFCAC8B                                          ; FCAC80  68 09
.LFCAC82:
	ld (XIX),0x7b                                        ; FCAC82  b4 00 7b
	ld (XIX+0x01),0x00                                   ; FCAC85  bc 01 00 00
	ld h, 0x02:opc                                          ; FCAC89  26 02
.LFCAC8B:
	ei 0x06                                              ; FCAC8B  06 06
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAC8D  f2 00 20 60 31
	push XBC                                             ; FCAC92  39
	ld A,H                                               ; FCAC93  ce 89
	extz WA                                              ; FCAC95  d8 12
	pushw wa                                             ; FCAC97  28
	call T_Ring60153C_PutBlock                           ; FCAC98  1d 1c 1e f4
	call T_MIDI_PostSendWork_PortB                       ; FCAC9C  1d 30 07 f4
	inc 6,XSP                                            ; FCACA0  ef 66
	ei 0x00                                              ; FCACA2  06 00
.LFCACA4:
	pop XIX                                              ; FCACA4  5c
	popw de                                              ; FCACA5  4a
	popw hl                                              ; FCACA6  4b
	unlk XIZ                                             ; FCACA7  ee 0d
	ret                                                  ; FCACA9  0e
; PartFrame_RecordToSeqBuf: result bit 2: each entry as a 5-byte 0x90 event with Seq_BeatTick, staged at 0x602000 and put on SeqBufRing
;   (SeqBuf_Flags bit 0 set).
PartFrame_RecordToSeqBuf:
	link XIZ,0xffec                                      ; FCACAA  ee 0c ec ff
	pushw hl                                             ; FCACAE  2b
	pushw de                                             ; FCACAF  2a
	push XIX                                             ; FCACB0  3c
	ei 0x06                                              ; FCACB1  06 06
	set	0, (SeqBuf_Flags:8)                                   ; FCACB3  f0 aa b8
	ld	d, (Seq_BeatTick:8)                                      ; FCACB6  c0 93 24
	ei 0x00                                              ; FCACB9  06 00
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCACBB  f2 00 20 60 31
	ld (xiz-4), xbc                                      ; FCACC0  be fc 61
	ldw hl, 0x00                                         ; FCACC3  33 00 00
	ld XIX,(XIZ+0x08)                                    ; FCACC6  ae 08 24
	inc 7,XIX                                            ; FCACC9  ec 67
.LFCACCB:
	ld XBC,(XIZ+0x08)                                    ; FCACCB  ae 08 21
	ld A,(XBC)                                           ; FCACCE  81 21
	mul A,0x09                                           ; FCACD0  c9 08 09
	extz XWA                                             ; FCACD3  e8 12
	inc 7,XWA                                            ; FCACD5  e8 67
	add XBC,XWA                                          ; FCACD7  e8 81
	ld (xiz-8), xbc                                      ; FCACD9  be f8 61
	ld XWA,XIX                                           ; FCACDC  ec 88
	cp XWA,XBC                                           ; FCACDE  e9 f0
	jrl nc, .LFCAD6E                                     ; FCACE0  7f 8b 00
	ld C,(XIX+0x08)                                      ; FCACE3  8c 08 23
	cp C,0xff                                            ; FCACE6  cb cf ff
	jr z, .LFCAD2C                                       ; FCACE9  66 41
	ld xbc, (xiz-4)                                      ; FCACEB  ae fc 21
	ld (XBC),0x90                                        ; FCACEE  b1 00 90
	ld xbc, (xiz-4)                                      ; FCACF1  ae fc 21
	inc 1,XBC                                            ; FCACF4  e9 61
	ld (xiz-8), xbc                                      ; FCACF6  be f8 61
	ld (XBC),D                                           ; FCACF9  b1 44
	ld xbc, (xiz-8)                                      ; FCACFB  ae f8 21
	inc 1,XBC                                            ; FCACFE  e9 61
	ld (xiz-12), xbc                                     ; FCAD00  be f4 61
	ld A,(XIX+0x08)                                      ; FCAD03  8c 08 21
	ld (XBC),A                                           ; FCAD06  b1 41
	ld xbc, (xiz-8)                                      ; FCAD08  ae f8 21
	inc 2,XBC                                            ; FCAD0B  e9 62
	ld (xiz-16), xbc                                     ; FCAD0D  be f0 61
	ld A,(XIX+0x01)                                      ; FCAD10  8c 01 21
	ld (XBC),A                                           ; FCAD13  b1 41
	ld xbc, (xiz-8)                                      ; FCAD15  ae f8 21
	inc 3,XBC                                            ; FCAD18  e9 63
	ld (xiz-20), xbc                                     ; FCAD1A  be ec 61
	ld A,(XIX+0x07)                                      ; FCAD1D  8c 07 21
	ld (XBC),A                                           ; FCAD20  b1 41
	ld xbc, (xiz-8)                                      ; FCAD22  ae f8 21
	inc 4,XBC                                            ; FCAD25  e9 64
	ld (xiz-4), xbc                                      ; FCAD27  be fc 61
	inc 5,HL                                             ; FCAD2A  db 65
.LFCAD2C:
	cp hl, 0x00:i3                                         ; FCAD2C  db d8
	jr z, .LFCAD65                                       ; FCAD2E  66 35
	cp HL,0x001e                                         ; FCAD30  db cf 1e 00
	jr nc, .LFCAD4D                                      ; FCAD34  6f 17
	ld XBC,(XIZ+0x08)                                    ; FCAD36  ae 08 21
	ld A,(XBC)                                           ; FCAD39  81 21
	mul A,0x09                                           ; FCAD3B  c9 08 09
	extz XWA                                             ; FCAD3E  e8 12
	dec 2,XWA                                            ; FCAD40  e8 6a
	add XBC,XWA                                          ; FCAD42  e8 81
	ld (xiz-8), xbc                                      ; FCAD44  be f8 61
	ld XWA,XIX                                           ; FCAD47  ec 88
	cp XWA,XBC                                           ; FCAD49  e9 f0
	jr nz, .LFCAD65                                      ; FCAD4B  6e 18
.LFCAD4D:
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAD4D  f2 00 20 60 31
	push XBC                                             ; FCAD52  39
	pushw hl                                             ; FCAD53  2b
	call T_SeqBufRing_PutBlock                           ; FCAD54  1d 8c 1d f4
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCAD58  f2 00 20 60 31
	ld (xiz-4), xbc                                      ; FCAD5D  be fc 61
	ldw hl, 0x00                                         ; FCAD60  33 00 00
	inc 6,XSP                                            ; FCAD63  ef 66
.LFCAD65:
	add XIX,0x00000009                                   ; FCAD65  ec c8 09 00 00 00
	jrl .LFCACCB                                         ; FCAD6B  78 5d ff
.LFCAD6E:
	call T_SeqBuf_FlushStaged                                        ; FCAD6E  1d 24 00 f4
	call SeqRecord_StartOnFirstEvent_SaveRegs                                      ; FCAD72  1d ac 80 fc
	pop XIX                                              ; FCAD76  5c
	popw de                                              ; FCAD77  4a
	popw hl                                              ; FCAD78  4b
	unlk XIZ                                             ; FCAD79  ee 0d
	ret                                                  ; FCAD7B  0e
; NoteRouting_DefaultRecordPtrs: T_NoteRouting_DefaultRecordPtrs (out): the three 32-bit pointers at out +0 / +4 / +8 = 0x602ACA, the default output record.
;   NoteRouting_OnPartMidiEvent copies them to a part's tone-generator record +2 and MIDI record +2 / +6.
NoteRouting_DefaultRecordPtrs:
	link XIZ,0x0000                                      ; FCAD7C  ee 0c 00 00
	push XIX                                             ; FCAD80  3c
	lda xix, (0x602aca:24)                               ; FCAD81  f2 ca 2a 60 34
	ld XBC,(XIZ+0x08)                                    ; FCAD86  ae 08 21
	ld (XBC),XIX                                         ; FCAD89  b1 64
	ld XBC,(XIZ+0x08)                                    ; FCAD8B  ae 08 21
	ld (XBC+0x04),XIX                                    ; FCAD8E  b9 04 64
	ld XBC,(XIZ+0x08)                                    ; FCAD91  ae 08 21
	ld (XBC+0x08),XIX                                    ; FCAD94  b9 08 64
	pop XIX                                              ; FCAD97  5c
	unlk XIZ                                             ; FCAD98  ee 0d
	ret                                                  ; FCAD9A  0e
; Note_TransposeFoldOctaves: (note L, shift H): L + (H - 0x40), then 12 off or on until it lies in 0..0x7F.
Note_TransposeFoldOctaves:
	link XIZ,0x0000                                      ; FCAD9B  ee 0c 00 00
	pushw hl                                             ; FCAD9F  2b
	ld L,(XIZ+0x08)                                      ; FCADA0  8e 08 27
	ld H,(XIZ+0x0a)                                      ; FCADA3  8e 0a 26
	ld c, 0x40:opc                                          ; FCADA6  23 40
	sub H,C                                              ; FCADA8  cb a6
	jr z, .LFCADCF                                       ; FCADAA  66 23
	ld A,H                                               ; FCADAC  ce 89
	add L,A                                              ; FCADAE  c9 87
	cp L,0x7f                                            ; FCADB0  cf cf 7f
	jr ule, .LFCADCF                                     ; FCADB3  63 1a
	cp a, 0x00:i3                                          ; FCADB5  c9 d8
	jr le, .LFCADC6                                      ; FCADB7  62 0d
	jr .LFCADBF                                          ; FCADB9  68 04
.LFCADBB:
	ld c, 0x0c:opc                                          ; FCADBB  23 0c
	sub L,C                                              ; FCADBD  cb a7
.LFCADBF:
	cp L,0x7f                                            ; FCADBF  cf cf 7f
	jr ugt, .LFCADBB                                     ; FCADC2  6b f7
	jr .LFCADCF                                          ; FCADC4  68 09
.LFCADC6:
	cp l, 0x00:i3                                          ; FCADC6  cf d8
	jr ge, .LFCADCF                                      ; FCADC8  69 05
	add L,0x0c                                           ; FCADCA  cf c8 0c
	jr .LFCADC6                                          ; FCADCD  68 f7
.LFCADCF:
	ld A,L                                               ; FCADCF  cf 89
	popw hl                                              ; FCADD1  4b
	unlk XIZ                                             ; FCADD2  ee 0d
	ret                                                  ; FCADD4  0e
; PartNote_MapForToneGen: on screen 0x28 the note is EditCursor_Note; then T_DrumMap_MapNoteForPart_StackArgs with the part block's +0x0E -- the note the tone
;   generator gets.
PartNote_MapForToneGen:
	link XIZ,0x0000                                      ; FCADD5  ee 0c 00 00
	cp	(UI_ScreenLatch:16), 0x28                            ; FCADD9  c1 7a 20 3f 28
	jr nz, .LFCADE8                                      ; FCADDE  6e 08
	ld c, (EditCursor_Note:24)                                 ; FCADE0  c2 44 1f 60 23
	ld (XIZ+0x08),C                                      ; FCADE5  be 08 43
.LFCADE8:
	push 0x00                                            ; FCADE8  09 00
	push	(xiz+14)                                     ; FCADEA  8e 0e 04
	push 0x00                                            ; FCADED  09 00
	push	(xiz+8)                                      ; FCADEF  8e 08 04
	call T_DrumMap_MapNoteForPart_StackArgs                                        ; FCADF2  1d 44 10 f4
	pop XIY                                              ; FCADF6  5d
	unlk XIZ                                             ; FCADF7  ee 0d
	ret                                                  ; FCADF9  0e
; PartNote_ApplyVelocityOffset: velocity + the part block's signed offset (+1), clamped to 0 / 0x7F; unchanged when the offset is 0.
PartNote_ApplyVelocityOffset:
	link XIZ,0x0000                                      ; FCADFA  ee 0c 00 00
	pushw hl                                             ; FCADFE  2b
	pushw de                                             ; FCADFF  2a
	ld L,(XIZ+0x08)                                      ; FCAE00  8e 08 27
	ld XBC,(XIZ+0x0a)                                    ; FCAE03  ae 0a 21
	ld H,(XBC+0x01)                                      ; FCAE06  89 01 26
	cp h, 0x00:i3                                          ; FCAE09  ce d8
	jr z, .LFCAE26                                       ; FCAE0B  66 19
	ld D,L                                               ; FCAE0D  cf 8c
	ld A,(XBC+0x01)                                      ; FCAE0F  89 01 21
	ld L,A                                               ; FCAE12  c9 8f
	add L,D                                              ; FCAE14  cc 87
	cp l, 0x00:i3                                          ; FCAE16  cf d8
	jr ge, .LFCAE26                                      ; FCAE18  69 0c
	cp h, 0x00:i3                                          ; FCAE1A  ce d8
	jr lt, .LFCAE22                                      ; FCAE1C  61 04
	ld a, 0x7f:opc                                          ; FCAE1E  21 7f
	jr .LFCAE28                                          ; FCAE20  68 06
.LFCAE22:
	sub A,A                                              ; FCAE22  c9 a1
	jr .LFCAE28                                          ; FCAE24  68 02
.LFCAE26:
	ld A,L                                               ; FCAE26  cf 89
.LFCAE28:
	popw de                                              ; FCAE28  4a
	popw hl                                              ; FCAE29  4b
	unlk XIZ                                             ; FCAE2A  ee 0d
	ret                                                  ; FCAE2C  0e
; PartNote_TransposeForMidiOut: on screen 0x28 EditCursor_Note; otherwise the note + the block's transpose (+1), folded into 0..0x7F by
;   octaves.
PartNote_TransposeForMidiOut:
	link XIZ,0x0000                                      ; FCAE2D  ee 0c 00 00
	pushw hl                                             ; FCAE31  2b
	ld H,(XIZ+0x08)                                      ; FCAE32  8e 08 26
	ld XBC,(XIZ+0x0a)                                    ; FCAE35  ae 0a 21
	ld L,(XBC+0x01)                                      ; FCAE38  89 01 27
	cp	(UI_ScreenLatch:16), 0x28                            ; FCAE3B  c1 7a 20 3f 28
	jr nz, .LFCAE49                                      ; FCAE40  6e 07
	ld a, (EditCursor_Note:24)                                 ; FCAE42  c2 44 1f 60 21
	jr .LFCAE72                                          ; FCAE47  68 29
.LFCAE49:
	cp l, 0x00:i3                                          ; FCAE49  cf d8
	jr z, .LFCAE70                                       ; FCAE4B  66 23
	ld C,L                                               ; FCAE4D  cf 8b
	add H,C                                              ; FCAE4F  cb 86
	cp H,0x7f                                            ; FCAE51  ce cf 7f
	jr ule, .LFCAE70                                     ; FCAE54  63 1a
	cp c, 0x00:i3                                          ; FCAE56  cb d8
	jr le, .LFCAE67                                      ; FCAE58  62 0d
	jr .LFCAE60                                          ; FCAE5A  68 04
.LFCAE5C:
	ld c, 0x0c:opc                                          ; FCAE5C  23 0c
	sub H,C                                              ; FCAE5E  cb a6
.LFCAE60:
	cp H,0x7f                                            ; FCAE60  ce cf 7f
	jr ugt, .LFCAE5C                                     ; FCAE63  6b f7
	jr .LFCAE70                                          ; FCAE65  68 09
.LFCAE67:
	cp h, 0x00:i3                                          ; FCAE67  ce d8
	jr ge, .LFCAE70                                      ; FCAE69  69 05
	add H,0x0c                                           ; FCAE6B  ce c8 0c
	jr .LFCAE67                                          ; FCAE6E  68 f7
.LFCAE70:
	ld A,H                                               ; FCAE70  ce 89
.LFCAE72:
	popw hl                                              ; FCAE72  4b
	unlk XIZ                                             ; FCAE73  ee 0d
	ret                                                  ; FCAE75  0e
; NoteRouting_ForPart: (out, routing block, part D): out+0 = the tone-generator part (block +2 + D) when it is not 0xFF, block +0x298
;   bit 9 is clear and the part's record (+0x92 + 6 D) has bit 5 (or 0x602498 bit 6), with out+3 = that record;
;   out+1 = the MIDI OUT channel (+0x22 + D) when its port is allowed (+0x293 bit 4 for 0..15, bit 3 for 16..31)
;   and the part's MIDI record (+0x152 + 10 D) has bit 5, with out+7 = that record; out+2 = the track whose +0x42
;   entry is D | 0x80, only while 0x602498 bit 7; each missing output 0xFF with the default record 0x602ACA.
NoteRouting_ForPart:
	link XIZ,0x0000                                      ; FCAE76  ee 0c 00 00
	pushw hl                                             ; FCAE7A  2b
	pushw de                                             ; FCAE7B  2a
	push XIX                                             ; FCAE7C  3c
	ld XIX,(XIZ+0x08)                                    ; FCAE7D  ae 08 24
	ld D,(XIZ+0x10)                                      ; FCAE80  8e 10 24
	ld C,D                                               ; FCAE83  cc 8b
	extz BC                                              ; FCAE85  d9 12
	extz XBC                                             ; FCAE87  e9 12
	inc 2,XBC                                            ; FCAE89  e9 62
	add XBC,(XIZ+0x0c)                                   ; FCAE8B  ae 0c 81
	ld A,(XBC)                                           ; FCAE8E  81 21
	cp A,0xff                                            ; FCAE90  c9 cf ff
	jr z, .LFCAEE3                                       ; FCAE93  66 4e
	ld XBC,(XIZ+0x0c)                                    ; FCAE95  ae 0c 21
	ld WA,(XBC+0x0298)                                   ; FCAE98  d3 e5 98 02 20
	and WA,0x0200                                        ; FCAE9D  d8 cc 00 02
	jr nz, .LFCAEE3                                      ; FCAEA1  6e 40
	ld a, 0x06:opc                                          ; FCAEA3  21 06
	mul wa, d                                          ; FCAEA5  cc 41
	extz XWA                                             ; FCAEA7  e8 12
	add XWA,0x00000092                                   ; FCAEA9  e8 c8 92 00 00 00
	add XBC,XWA                                          ; FCAEAF  e8 81
	bit 5,(XBC)                                          ; FCAEB1  b1 cd
	jr nz, .LFCAEC0                                      ; FCAEB3  6e 0b
	ld bc, (NoteRouting_Mode:24)                                ; FCAEB5  d2 98 24 60 21
	and BC,0x0040                                        ; FCAEBA  d9 cc 40 00
	jr z, .LFCAEE3                                       ; FCAEBE  66 23
.LFCAEC0:
	ld C,D                                               ; FCAEC0  cc 8b
	extz BC                                              ; FCAEC2  d9 12
	extz XBC                                             ; FCAEC4  e9 12
	inc 2,XBC                                            ; FCAEC6  e9 62
	add XBC,(XIZ+0x0c)                                   ; FCAEC8  ae 0c 81
	ld A,(XBC)                                           ; FCAECB  81 21
	ld (XIX),A                                           ; FCAECD  b4 41
	ld c, 0x06:opc                                          ; FCAECF  23 06
	mul bc, d                                          ; FCAED1  cc 43
	extz XBC                                             ; FCAED3  e9 12
	add XBC,0x00000092                                   ; FCAED5  e9 c8 92 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCAEDB  ae 0c 81
	ld (XIX+0x03),XBC                                    ; FCAEDE  bc 03 61
	jr .LFCAEEE                                          ; FCAEE1  68 0b
.LFCAEE3:
	ld (XIX),0xff                                        ; FCAEE3  b4 00 ff
	lda xbc, (0x602aca:24)                               ; FCAEE6  f2 ca 2a 60 31
	ld (XIX+0x03),XBC                                    ; FCAEEB  bc 03 61
.LFCAEEE:
	ld XBC,(XIZ+0x0c)                                    ; FCAEEE  ae 0c 21
	bit 5,(XBC+0x0293)                                   ; FCAEF1  f3 e5 93 02 cd
	jrl nz, .LFCAF71                                     ; FCAEF6  7e 78 00
	ld A,D                                               ; FCAEF9  cc 89
	extz WA                                              ; FCAEFB  d8 12
	extz XWA                                             ; FCAEFD  e8 12
	add XWA,0x00000022                                   ; FCAEFF  e8 c8 22 00 00 00
	add XBC,XWA                                          ; FCAF05  e8 81
	ld H,(XBC)                                           ; FCAF07  81 26
	ld (XIX+0x01),H                                      ; FCAF09  bc 01 46
	cp h, 0x00:i3                                          ; FCAF0C  ce d8
	jr c, .LFCAF34                                       ; FCAF0E  67 24
	ld C,(XIX+0x01)                                      ; FCAF10  8c 01 23
	cp C,0x10                                            ; FCAF13  cb cf 10
	jr nc, .LFCAF34                                      ; FCAF16  6f 1c
	ld XBC,(XIZ+0x0c)                                    ; FCAF18  ae 0c 21
	bit 4,(XBC+0x0293)                                   ; FCAF1B  f3 e5 93 02 cc
	jr z, .LFCAF34                                       ; FCAF20  66 12
	ld a, 0x0a:opc                                          ; FCAF22  21 0a
	mul wa, d                                          ; FCAF24  cc 41
	extz XWA                                             ; FCAF26  e8 12
	add XWA,0x00000152                                   ; FCAF28  e8 c8 52 01 00 00
	add XBC,XWA                                          ; FCAF2E  e8 81
	bit 5,(XBC)                                          ; FCAF30  b1 cd
	jr nz, .LFCAF5D                                      ; FCAF32  6e 29
.LFCAF34:
	ld H,(XIX+0x01)                                      ; FCAF34  8c 01 26
	cp H,0x10                                            ; FCAF37  ce cf 10
	jr c, .LFCAF71                                       ; FCAF3A  67 35
	cp H,0x20                                            ; FCAF3C  ce cf 20
	jr nc, .LFCAF71                                      ; FCAF3F  6f 30
	ld XBC,(XIZ+0x0c)                                    ; FCAF41  ae 0c 21
	bit 3,(XBC+0x0293)                                   ; FCAF44  f3 e5 93 02 cb
	jr z, .LFCAF71                                       ; FCAF49  66 26
	ld a, 0x0a:opc                                          ; FCAF4B  21 0a
	mul wa, d                                          ; FCAF4D  cc 41
	extz XWA                                             ; FCAF4F  e8 12
	add XWA,0x00000152                                   ; FCAF51  e8 c8 52 01 00 00
	add XBC,XWA                                          ; FCAF57  e8 81
	bit 5,(XBC)                                          ; FCAF59  b1 cd
	jr z, .LFCAF71                                       ; FCAF5B  66 14
.LFCAF5D:
	ld c, 0x0a:opc                                          ; FCAF5D  23 0a
	mul bc, d                                          ; FCAF5F  cc 43
	extz XBC                                             ; FCAF61  e9 12
	add XBC,0x00000152                                   ; FCAF63  e9 c8 52 01 00 00
	add XBC,(XIZ+0x0c)                                   ; FCAF69  ae 0c 81
	ld (XIX+0x07),XBC                                    ; FCAF6C  bc 07 61
	jr .LFCAF7D                                          ; FCAF6F  68 0c
.LFCAF71:
	ld (XIX+0x01),0xff                                   ; FCAF71  bc 01 00 ff
	lda xbc, (0x602aca:24)                               ; FCAF75  f2 ca 2a 60 31
	ld (XIX+0x07),XBC                                    ; FCAF7A  bc 07 61
.LFCAF7D:
	ld bc, (NoteRouting_Mode:24)                                ; FCAF7D  d2 98 24 60 21
	and BC,0x0080                                        ; FCAF82  d9 cc 80 00
	jr z, .LFCAFBF                                       ; FCAF86  66 37
	ld (XIX+0x02),0x00                                   ; FCAF88  bc 02 00 00
	ld L,D                                               ; FCAF8C  cc 8f
	set 0x07,L                                           ; FCAF8E  cf 31 07
.LFCAF91:
	ld H,(XIX+0x02)                                      ; FCAF91  8c 02 26
	cp H,0x10                                            ; FCAF94  ce cf 10
	jr nc, .LFCAFB7                                      ; FCAF97  6f 1e
	ld C,H                                               ; FCAF99  ce 8b
	extz BC                                              ; FCAF9B  d9 12
	extz XBC                                             ; FCAF9D  e9 12
	add XBC,0x00000042                                   ; FCAF9F  e9 c8 42 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCAFA5  ae 0c 81
	ld A,(XBC)                                           ; FCAFA8  81 21
	cp A,L                                               ; FCAFAA  cf f1
	jr z, .LFCAFB7                                       ; FCAFAC  66 09
	ld A,H                                               ; FCAFAE  ce 89
	inc 1,A                                              ; FCAFB0  c9 61
	ld (XIX+0x02),A                                      ; FCAFB2  bc 02 41
	jr .LFCAF91                                          ; FCAFB5  68 da
.LFCAFB7:
	ld C,(XIX+0x02)                                      ; FCAFB7  8c 02 23
	cp C,0x10                                            ; FCAFBA  cb cf 10
	jr nz, .LFCAFC3                                      ; FCAFBD  6e 04
.LFCAFBF:
	ld (XIX+0x02),0xff                                   ; FCAFBF  bc 02 00 ff
.LFCAFC3:
	pop XIX                                              ; FCAFC3  5c
	popw de                                              ; FCAFC4  4a
	popw hl                                              ; FCAFC5  4b
	unlk XIZ                                             ; FCAFC6  ee 0d
	ret                                                  ; FCAFC8  0e
; NoteRouting_ForPartFromMidiIn: (out, routing block, part): NoteRouting_ForPart's tone-generator and recording-track outputs, but MIDI OUT (the
;   +0x22 channel with the port and record-bit-5 tests) only when Variant_Flag is 2, NoteRouting_MidiFlags bit 5 is
;   clear and the MIDI IN mode is 1.  The MIDI IN processors use it for notes on the note-list path.
NoteRouting_ForPartFromMidiIn:
	link XIZ,0x0000                                      ; FCAFC9  ee 0c 00 00
	pushw hl                                             ; FCAFCD  2b
	pushw de                                             ; FCAFCE  2a
	push XIX                                             ; FCAFCF  3c
	ld XIX,(XIZ+0x08)                                    ; FCAFD0  ae 08 24
	ld D,(XIZ+0x10)                                      ; FCAFD3  8e 10 24
	ld C,D                                               ; FCAFD6  cc 8b
	extz BC                                              ; FCAFD8  d9 12
	extz XBC                                             ; FCAFDA  e9 12
	inc 2,XBC                                            ; FCAFDC  e9 62
	add XBC,(XIZ+0x0c)                                   ; FCAFDE  ae 0c 81
	ld A,(XBC)                                           ; FCAFE1  81 21
	cp A,0xff                                            ; FCAFE3  c9 cf ff
	jr z, .LFCB029                                       ; FCAFE6  66 41
	ld c, 0x06:opc                                          ; FCAFE8  23 06
	mul bc, d                                          ; FCAFEA  cc 43
	extz XBC                                             ; FCAFEC  e9 12
	add XBC,0x00000092                                   ; FCAFEE  e9 c8 92 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCAFF4  ae 0c 81
	bit 5,(XBC)                                          ; FCAFF7  b1 cd
	jr nz, .LFCB006                                      ; FCAFF9  6e 0b
	ld bc, (NoteRouting_Mode:24)                                ; FCAFFB  d2 98 24 60 21
	and BC,0x0040                                        ; FCB000  d9 cc 40 00
	jr z, .LFCB029                                       ; FCB004  66 23
.LFCB006:
	ld C,D                                               ; FCB006  cc 8b
	extz BC                                              ; FCB008  d9 12
	extz XBC                                             ; FCB00A  e9 12
	inc 2,XBC                                            ; FCB00C  e9 62
	add XBC,(XIZ+0x0c)                                   ; FCB00E  ae 0c 81
	ld A,(XBC)                                           ; FCB011  81 21
	ld (XIX),A                                           ; FCB013  b4 41
	ld c, 0x06:opc                                          ; FCB015  23 06
	mul bc, d                                          ; FCB017  cc 43
	extz XBC                                             ; FCB019  e9 12
	add XBC,0x00000092                                   ; FCB01B  e9 c8 92 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB021  ae 0c 81
	ld (XIX+0x03),XBC                                    ; FCB024  bc 03 61
	jr .LFCB034                                          ; FCB027  68 0b
.LFCB029:
	ld (XIX),0xff                                        ; FCB029  b4 00 ff
	lda xbc, (0x602aca:24)                               ; FCB02C  f2 ca 2a 60 31
	ld (XIX+0x03),XBC                                    ; FCB031  bc 03 61
.LFCB034:
	cp	(Variant_Flag:8), 0x02                               ; FCB034  c0 c4 3f 02
	jrl nz, .LFCB0CE                                     ; FCB038  7e 93 00
	ld XBC,(XIZ+0x0c)                                    ; FCB03B  ae 0c 21
	bit 5,(XBC+0x0293)                                   ; FCB03E  f3 e5 93 02 cd
	jrl nz, .LFCB0CE                                     ; FCB043  7e 88 00
	ld A,(XBC+0x0293)                                    ; FCB046  c3 e5 93 02 21
	and A,0xc0                                           ; FCB04B  c9 cc c0
	srl a, 0x06                                          ; FCB04E  c9 ef 06
	cp a, 0x01:i3                                          ; FCB051  c9 d9
	jrl nz, .LFCB0CE                                     ; FCB053  7e 78 00
	ld A,D                                               ; FCB056  cc 89
	extz WA                                              ; FCB058  d8 12
	extz XWA                                             ; FCB05A  e8 12
	add XWA,0x00000022                                   ; FCB05C  e8 c8 22 00 00 00
	add XBC,XWA                                          ; FCB062  e8 81
	ld H,(XBC)                                           ; FCB064  81 26
	ld (XIX+0x01),H                                      ; FCB066  bc 01 46
	cp h, 0x00:i3                                          ; FCB069  ce d8
	jr c, .LFCB091                                       ; FCB06B  67 24
	ld C,(XIX+0x01)                                      ; FCB06D  8c 01 23
	cp C,0x10                                            ; FCB070  cb cf 10
	jr nc, .LFCB091                                      ; FCB073  6f 1c
	ld XBC,(XIZ+0x0c)                                    ; FCB075  ae 0c 21
	bit 4,(XBC+0x0293)                                   ; FCB078  f3 e5 93 02 cc
	jr z, .LFCB091                                       ; FCB07D  66 12
	ld a, 0x0a:opc                                          ; FCB07F  21 0a
	mul wa, d                                          ; FCB081  cc 41
	extz XWA                                             ; FCB083  e8 12
	add XWA,0x00000152                                   ; FCB085  e8 c8 52 01 00 00
	add XBC,XWA                                          ; FCB08B  e8 81
	bit 5,(XBC)                                          ; FCB08D  b1 cd
	jr nz, .LFCB0BA                                      ; FCB08F  6e 29
.LFCB091:
	ld H,(XIX+0x01)                                      ; FCB091  8c 01 26
	cp H,0x10                                            ; FCB094  ce cf 10
	jr c, .LFCB0CE                                       ; FCB097  67 35
	cp H,0x20                                            ; FCB099  ce cf 20
	jr nc, .LFCB0CE                                      ; FCB09C  6f 30
	ld XBC,(XIZ+0x0c)                                    ; FCB09E  ae 0c 21
	bit 3,(XBC+0x0293)                                   ; FCB0A1  f3 e5 93 02 cb
	jr z, .LFCB0CE                                       ; FCB0A6  66 26
	ld a, 0x0a:opc                                          ; FCB0A8  21 0a
	mul wa, d                                          ; FCB0AA  cc 41
	extz XWA                                             ; FCB0AC  e8 12
	add XWA,0x00000152                                   ; FCB0AE  e8 c8 52 01 00 00
	add XBC,XWA                                          ; FCB0B4  e8 81
	bit 5,(XBC)                                          ; FCB0B6  b1 cd
	jr z, .LFCB0CE                                       ; FCB0B8  66 14
.LFCB0BA:
	ld c, 0x0a:opc                                          ; FCB0BA  23 0a
	mul bc, d                                          ; FCB0BC  cc 43
	extz XBC                                             ; FCB0BE  e9 12
	add XBC,0x00000152                                   ; FCB0C0  e9 c8 52 01 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB0C6  ae 0c 81
	ld (XIX+0x07),XBC                                    ; FCB0C9  bc 07 61
	jr .LFCB0DA                                          ; FCB0CC  68 0c
.LFCB0CE:
	ld (XIX+0x01),0xff                                   ; FCB0CE  bc 01 00 ff
	lda xbc, (0x602aca:24)                               ; FCB0D2  f2 ca 2a 60 31
	ld (XIX+0x07),XBC                                    ; FCB0D7  bc 07 61
.LFCB0DA:
	ld bc, (NoteRouting_Mode:24)                                ; FCB0DA  d2 98 24 60 21
	and BC,0x0080                                        ; FCB0DF  d9 cc 80 00
	jr z, .LFCB11C                                       ; FCB0E3  66 37
	ld (XIX+0x02),0x00                                   ; FCB0E5  bc 02 00 00
	ld L,D                                               ; FCB0E9  cc 8f
	set 0x07,L                                           ; FCB0EB  cf 31 07
.LFCB0EE:
	ld H,(XIX+0x02)                                      ; FCB0EE  8c 02 26
	cp H,0x10                                            ; FCB0F1  ce cf 10
	jr nc, .LFCB114                                      ; FCB0F4  6f 1e
	ld C,H                                               ; FCB0F6  ce 8b
	extz BC                                              ; FCB0F8  d9 12
	extz XBC                                             ; FCB0FA  e9 12
	add XBC,0x00000042                                   ; FCB0FC  e9 c8 42 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB102  ae 0c 81
	ld A,(XBC)                                           ; FCB105  81 21
	cp A,L                                               ; FCB107  cf f1
	jr z, .LFCB114                                       ; FCB109  66 09
	ld A,H                                               ; FCB10B  ce 89
	inc 1,A                                              ; FCB10D  c9 61
	ld (XIX+0x02),A                                      ; FCB10F  bc 02 41
	jr .LFCB0EE                                          ; FCB112  68 da
.LFCB114:
	ld C,(XIX+0x02)                                      ; FCB114  8c 02 23
	cp C,0x10                                            ; FCB117  cb cf 10
	jr nz, .LFCB120                                      ; FCB11A  6e 04
.LFCB11C:
	ld (XIX+0x02),0xff                                   ; FCB11C  bc 02 00 ff
.LFCB120:
	pop XIX                                              ; FCB120  5c
	popw de                                              ; FCB121  4a
	popw hl                                              ; FCB122  4b
	unlk XIZ                                             ; FCB123  ee 0d
	ret                                                  ; FCB125  0e
; NoteRouting_ForReceivingPart: (out, routing block, part): the tone-generator output (+0x02 and its +0x92 record, without the bit-5 test) and the
;   recording track; MIDI OUT always 0xFF.  The MIDI IN processors' per-channel path: each part whose +0x22 is the
;   frame's channel and whose record has bit 6 receives the frame.
NoteRouting_ForReceivingPart:
	link XIZ,0x0000                                      ; FCB126  ee 0c 00 00
	pushw hl                                             ; FCB12A  2b
	pushw de                                             ; FCB12B  2a
	push XIX                                             ; FCB12C  3c
	ld XIX,(XIZ+0x08)                                    ; FCB12D  ae 08 24
	ld D,(XIZ+0x10)                                      ; FCB130  8e 10 24
	ld (XIX+0x01),0xff                                   ; FCB133  bc 01 00 ff
	lda xbc, (0x602aca:24)                               ; FCB137  f2 ca 2a 60 31
	ld (XIX+0x07),XBC                                    ; FCB13C  bc 07 61
	ld C,D                                               ; FCB13F  cc 8b
	extz BC                                              ; FCB141  d9 12
	extz XBC                                             ; FCB143  e9 12
	inc 2,XBC                                            ; FCB145  e9 62
	add XBC,(XIZ+0x0c)                                   ; FCB147  ae 0c 81
	ld H,(XBC)                                           ; FCB14A  81 26
	ld (XIX),H                                           ; FCB14C  b4 46
	cp H,0xff                                            ; FCB14E  ce cf ff
	jr z, .LFCB167                                       ; FCB151  66 14
	ld c, 0x06:opc                                          ; FCB153  23 06
	mul bc, d                                          ; FCB155  cc 43
	extz XBC                                             ; FCB157  e9 12
	add XBC,0x00000092                                   ; FCB159  e9 c8 92 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB15F  ae 0c 81
	ld (XIX+0x03),XBC                                    ; FCB162  bc 03 61
	jr .LFCB16F                                          ; FCB165  68 08
.LFCB167:
	lda xbc, (0x602aca:24)                               ; FCB167  f2 ca 2a 60 31
	ld (XIX+0x03),XBC                                    ; FCB16C  bc 03 61
.LFCB16F:
	ld bc, (NoteRouting_Mode:24)                                ; FCB16F  d2 98 24 60 21
	and BC,0x0080                                        ; FCB174  d9 cc 80 00
	jr z, .LFCB1B1                                       ; FCB178  66 37
	ld (XIX+0x02),0x00                                   ; FCB17A  bc 02 00 00
	ld L,D                                               ; FCB17E  cc 8f
	set 0x07,L                                           ; FCB180  cf 31 07
.LFCB183:
	ld H,(XIX+0x02)                                      ; FCB183  8c 02 26
	cp H,0x10                                            ; FCB186  ce cf 10
	jr nc, .LFCB1A9                                      ; FCB189  6f 1e
	ld C,H                                               ; FCB18B  ce 8b
	extz BC                                              ; FCB18D  d9 12
	extz XBC                                             ; FCB18F  e9 12
	add XBC,0x00000042                                   ; FCB191  e9 c8 42 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB197  ae 0c 81
	ld A,(XBC)                                           ; FCB19A  81 21
	cp A,L                                               ; FCB19C  cf f1
	jr z, .LFCB1A9                                       ; FCB19E  66 09
	ld A,H                                               ; FCB1A0  ce 89
	inc 1,A                                              ; FCB1A2  c9 61
	ld (XIX+0x02),A                                      ; FCB1A4  bc 02 41
	jr .LFCB183                                          ; FCB1A7  68 da
.LFCB1A9:
	ld C,(XIX+0x02)                                      ; FCB1A9  8c 02 23
	cp C,0x10                                            ; FCB1AC  cb cf 10
	jr nz, .LFCB1B5                                      ; FCB1AF  6e 04
.LFCB1B1:
	ld (XIX+0x02),0xff                                   ; FCB1B1  bc 02 00 ff
.LFCB1B5:
	pop XIX                                              ; FCB1B5  5c
	popw de                                              ; FCB1B6  4a
	popw hl                                              ; FCB1B7  4b
	unlk XIZ                                             ; FCB1B8  ee 0d
	ret                                                  ; FCB1BA  0e
; NoteRouting_ForTrack: (out, routing block, track): out+0 = the part the track feeds (+0x42 + track, low 5 bits), out+1 = its MIDI OUT
;   channel (+0x52 + track) when the port is allowed, out+2 = 0xFF (no recording) -- the timed-event path.
NoteRouting_ForTrack:
	link XIZ,0x0000                                      ; FCB1BB  ee 0c 00 00
	pushw hl                                             ; FCB1BF  2b
	push XIX                                             ; FCB1C0  3c
	ld XIX,(XIZ+0x08)                                    ; FCB1C1  ae 08 24
	ld (XIX+0x02),0xff                                   ; FCB1C4  bc 02 00 ff
	ld BC,(XIZ+0x12)                                     ; FCB1C8  9e 12 21
	extz BC                                              ; FCB1CB  d9 12
	extz XBC                                             ; FCB1CD  e9 12
	add XBC,0x00000042                                   ; FCB1CF  e9 c8 42 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB1D5  ae 0c 81
	ld H,(XBC)                                           ; FCB1D8  81 26
	ld (XIX),H                                           ; FCB1DA  b4 46
	cp H,0xff                                            ; FCB1DC  ce cf ff
	jr z, .LFCB1F9                                       ; FCB1DF  66 18
	and (XIX),0x1f                                       ; FCB1E1  84 3c 1f
	ld c, 0x06:opc                                          ; FCB1E4  23 06
	mul	bc, (xiz+16)                                 ; FCB1E6  8e 10 43
	extz XBC                                             ; FCB1E9  e9 12
	add XBC,0x00000092                                   ; FCB1EB  e9 c8 92 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB1F1  ae 0c 81
	ld (XIX+0x03),XBC                                    ; FCB1F4  bc 03 61
	jr .LFCB201                                          ; FCB1F7  68 08
.LFCB1F9:
	lda xbc, (0x602aca:24)                               ; FCB1F9  f2 ca 2a 60 31
	ld (XIX+0x03),XBC                                    ; FCB1FE  bc 03 61
.LFCB201:
	ld BC,(XIZ+0x12)                                     ; FCB201  9e 12 21
	extz BC                                              ; FCB204  d9 12
	extz XBC                                             ; FCB206  e9 12
	add XBC,0x00000052                                   ; FCB208  e9 c8 52 00 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB20E  ae 0c 81
	ld H,(XBC)                                           ; FCB211  81 26
	ld (XIX+0x01),H                                      ; FCB213  bc 01 46
	cp h, 0x00:i3                                          ; FCB216  ce d8
	jr c, .LFCB22C                                       ; FCB218  67 12
	ld C,(XIX+0x01)                                      ; FCB21A  8c 01 23
	cp C,0x10                                            ; FCB21D  cb cf 10
	jr nc, .LFCB22C                                      ; FCB220  6f 0a
	ld XBC,(XIZ+0x0c)                                    ; FCB222  ae 0c 21
	bit 4,(XBC+0x0293)                                   ; FCB225  f3 e5 93 02 cc
	jr nz, .LFCB243                                      ; FCB22A  6e 17
.LFCB22C:
	ld H,(XIX+0x01)                                      ; FCB22C  8c 01 26
	cp H,0x10                                            ; FCB22F  ce cf 10
	jr c, .LFCB258                                       ; FCB232  67 24
	cp H,0x20                                            ; FCB234  ce cf 20
	jr nc, .LFCB258                                      ; FCB237  6f 1f
	ld XBC,(XIZ+0x0c)                                    ; FCB239  ae 0c 21
	bit 3,(XBC+0x0293)                                   ; FCB23C  f3 e5 93 02 cb
	jr z, .LFCB258                                       ; FCB241  66 15
.LFCB243:
	ld c, 0x0a:opc                                          ; FCB243  23 0a
	mul	bc, (xiz+16)                                 ; FCB245  8e 10 43
	extz XBC                                             ; FCB248  e9 12
	add XBC,0x00000152                                   ; FCB24A  e9 c8 52 01 00 00
	add XBC,(XIZ+0x0c)                                   ; FCB250  ae 0c 81
	ld (XIX+0x07),XBC                                    ; FCB253  bc 07 61
	jr .LFCB264                                          ; FCB256  68 0c
.LFCB258:
	ld (XIX+0x01),0xff                                   ; FCB258  bc 01 00 ff
	lda xbc, (0x602aca:24)                               ; FCB25C  f2 ca 2a 60 31
	ld (XIX+0x07),XBC                                    ; FCB261  bc 07 61
.LFCB264:
	pop XIX                                              ; FCB264  5c
	popw hl                                              ; FCB265  4b
	unlk XIZ                                             ; FCB266  ee 0d
	ret                                                  ; FCB268  0e
; MidiFrame_ToNoteFrame: (MIDI frame, note frame): count, the source byte (MIDI frame +2: 1 for MIDI IN, 2 for timed events), and for
;   each 9-byte entry a 7-byte one: +0 = its +7, +2 = its +8.
MidiFrame_ToNoteFrame:
	link XIZ,0xffec                                      ; FCB269  ee 0c ec ff
	pushw hl                                             ; FCB26D  2b
	pushw de                                             ; FCB26E  2a
	push XIX                                             ; FCB26F  3c
	ld XBC,(XIZ+0x08)                                    ; FCB270  ae 08 21
	ld A,(XBC)                                           ; FCB273  81 21
	ld D,A                                               ; FCB275  c9 8c
	ld XWA,(XIZ+0x0c)                                    ; FCB277  ae 0c 20
	ld (XWA),D                                           ; FCB27A  b0 44
	ld XBC,(XIZ+0x08)                                    ; FCB27C  ae 08 21
	ld A,(XBC+0x02)                                      ; FCB27F  89 02 21
	ld D,A                                               ; FCB282  c9 8c
	ld XWA,(XIZ+0x0c)                                    ; FCB284  ae 0c 20
	ld (XWA+0x01),D                                      ; FCB287  b8 01 44
	ldw hl, 0x00                                         ; FCB28A  33 00 00
	ld XIX,0x00000000                                    ; FCB28D  44 00 00 00 00
	sub XBC,XBC                                          ; FCB292  e9 a1
	ld (xiz-4), xbc                                      ; FCB294  be fc 61
.LFCB297:
	ld XBC,(XIZ+0x0c)                                    ; FCB297  ae 0c 21
	ld A,(XBC)                                           ; FCB29A  81 21
	extz WA                                              ; FCB29C  d8 12
	cp HL,WA                                             ; FCB29E  d8 f3
	jr nc, .LFCB2EA                                      ; FCB2A0  6f 48
	ld (xiz-8), xix                                      ; FCB2A2  be f8 64
	ld xwa, (xiz-8)                                      ; FCB2A5  ae f8 20
	ld (xiz-12), xwa                                     ; FCB2A8  be f4 60
	inc 7,XWA                                            ; FCB2AB  e8 67
	add XWA,(XIZ+0x08)                                   ; FCB2AD  ae 08 80
	ld D,(XWA)                                           ; FCB2B0  80 24
	ld xwa, (xiz-4)                                      ; FCB2B2  ae fc 20
	ld (xiz-16), xwa                                     ; FCB2B5  be f0 60
	ld (xiz-20), xwa                                     ; FCB2B8  be ec 60
	inc 2,XWA                                            ; FCB2BB  e8 62
	add XBC,XWA                                          ; FCB2BD  e8 81
	ld (XBC),D                                           ; FCB2BF  b1 44
	ld xbc, (xiz-12)                                     ; FCB2C1  ae f4 21
	inc 8,XBC                                            ; FCB2C4  e9 60
	add XBC,(XIZ+0x08)                                   ; FCB2C6  ae 08 81
	ld D,(XBC)                                           ; FCB2C9  81 24
	ld xbc, (xiz-20)                                     ; FCB2CB  ae ec 21
	inc 4,XBC                                            ; FCB2CE  e9 64
	add XBC,(XIZ+0x0c)                                   ; FCB2D0  ae 0c 81
	ld (XBC),D                                           ; FCB2D3  b1 44
	ld xix, (xiz-8)                                      ; FCB2D5  ae f8 24
	add XIX,0x00000009                                   ; FCB2D8  ec c8 09 00 00 00
	ld xbc, (xiz-16)                                     ; FCB2DE  ae f0 21
	inc 7,XBC                                            ; FCB2E1  e9 67
	ld (xiz-4), xbc                                      ; FCB2E3  be fc 61
	inc 1,HL                                             ; FCB2E6  db 61
	jr .LFCB297                                          ; FCB2E8  68 ad
.LFCB2EA:
	pop XIX                                              ; FCB2EA  5c
	popw de                                              ; FCB2EB  4a
	popw hl                                              ; FCB2EC  4b
	unlk XIZ                                             ; FCB2ED  ee 0d
	ret                                                  ; FCB2EF  0e
; PartNotes_ResoundOnToneGen: T_PartNotes_ResoundOnToneGen (source, part): the part's notes from the source keyed by the part (PartNotes_CollectFrame, mask 1).
;   When one sounds on the tone generator and the part plays tone-generator part = itself (block +0x02):
;   [0xB0, part, 0x7B, 0], bits 6-7 set in each entry's tone-generator velocity, the part's state (0x6020D4) = 0x80,
;   and the frame sent again (PartFrame_SendToToneGen).  What velocity bits 6-7 mean on the link is not established.
;   Its one caller is Drawbar_SendPartParams, with source 0xFF.
PartNotes_ResoundOnToneGen:
	link XIZ,0xfed4                                      ; FCB2F0  ee 0c d4 fe
	pushw hl                                             ; FCB2F4  2b
	pushw de                                             ; FCB2F5  2a
	push XIX                                             ; FCB2F6  3c
	ld D,(XIZ+0x0a)                                      ; FCB2F7  8e 0a 24
	ld C,(XIZ+0x08)                                      ; FCB2FA  8e 08 23
	ld (xiz-294), c                                      ; FCB2FD  f3 f9 da fe 43
	ld (xiz-293), d                                      ; FCB302  f3 f9 db fe 44
	ld (xiz-296), 0x00                                   ; FCB307  f3 f9 d8 fe 00 00
	push 0x00                                            ; FCB30D  09 00
	push D                                               ; FCB30F  cc 04
	pushw 0x01                                           ; FCB311  0b 01 00
	lda xbc, (xiz-296)                                   ; FCB314  f3 f9 d8 fe 31
	push XBC                                             ; FCB319  39
	calr PartNotes_CollectFrame                                      ; FCB31A  1e 59 ef
	ld H,A                                               ; FCB31D  c9 8e
	inc 8,XSP                                            ; FCB31F  ef 60
	cp a, 0x00:i3                                          ; FCB321  c9 d8
	jrl z, .LFCB3CD                                      ; FCB323  76 a7 00
	and A,0x01                                           ; FCB326  c9 cc 01
	jrl z, .LFCB3CD                                      ; FCB329  76 a1 00
	ld C,D                                               ; FCB32C  cc 8b
	extz BC                                              ; FCB32E  d9 12
	extz XBC                                             ; FCB330  e9 12
	inc 2,XBC                                            ; FCB332  e9 62
	add XBC,NoteRouting                                   ; FCB334  e9 c8 00 22 60 00
	ld A,(XBC)                                           ; FCB33A  81 21
	cp A,D                                               ; FCB33C  cc f1
	jrl nz, .LFCB3CD                                     ; FCB33E  7e 8c 00
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCB341  f2 00 20 60 31
	ld (xiz-300), xbc                                    ; FCB346  f3 f9 d4 fe 61
	ld (XBC),0xb0                                        ; FCB34B  b1 00 b0
	ld xbc, (xiz-300)                                    ; FCB34E  e3 f9 d4 fe 21
	ld (XBC+0x01),D                                      ; FCB353  b9 01 44
	ld xbc, (xiz-300)                                    ; FCB356  e3 f9 d4 fe 21
	ld (XBC+0x02),0x7b                                   ; FCB35B  b9 02 00 7b
	ld xbc, (xiz-300)                                    ; FCB35F  e3 f9 d4 fe 21
	ld (XBC+0x03),0x00                                   ; FCB364  b9 03 00 00
	lda xbc, (NoteSend_MsgBuffer:24)                               ; FCB368  f2 00 20 60 31
	push XBC                                             ; FCB36D  39
	pushw 0x04                                           ; FCB36E  0b 04 00
	pushw 0x00                                           ; FCB371  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCB374  1d d4 0e f4
	ldw hl, 0x00                                         ; FCB378  33 00 00
	ld XIX,0x00000000                                    ; FCB37B  44 00 00 00 00
	inc 8,XSP                                            ; FCB380  ef 60
.LFCB382:
	ld c, (xiz-296)                                      ; FCB382  c3 f9 d8 fe 23
	extz BC                                              ; FCB387  d9 12
	cp HL,BC                                             ; FCB389  d9 f3
	jr nc, .LFCB3B4                                      ; FCB38B  6f 27
	ld (xiz-300), xix                                    ; FCB38D  f3 f9 d4 fe 64
	ld xbc, (xiz-300)                                    ; FCB392  e3 f9 d4 fe 21
	add XBC,0x0000000b                                   ; FCB397  e9 c8 0b 00 00 00
	add XBC,XIZ                                          ; FCB39D  ee 81
	or	(xbc-296), 0xc0                      ; FCB39F  c3 e5 d8 fe 3e c0
	ld xix, (xiz-300)                                    ; FCB3A5  e3 f9 d4 fe 24
	add XIX,0x00000009                                   ; FCB3AA  ec c8 09 00 00 00
	inc 1,HL                                             ; FCB3B0  db 61
	jr .LFCB382                                          ; FCB3B2  68 ce
.LFCB3B4:
	ld C,D                                               ; FCB3B4  cc 8b
	extz BC                                              ; FCB3B6  d9 12
	extz XBC                                             ; FCB3B8  e9 12
	add XBC,PartToneGen_State                                   ; FCB3BA  e9 c8 d4 20 60 00
	ld (XBC),0x80                                        ; FCB3C0  b1 00 80
	lda xbc, (xiz-296)                                   ; FCB3C3  f3 f9 d8 fe 31
	push XBC                                             ; FCB3C8  39
	calr PartFrame_SendToToneGen                                      ; FCB3C9  1e ef f2
	pop XIY                                              ; FCB3CC  5d
.LFCB3CD:
	pop XIX                                              ; FCB3CD  5c
	popw de                                              ; FCB3CE  4a
	popw hl                                              ; FCB3CF  4b
	unlk XIZ                                             ; FCB3D0  ee 0d
	ret                                                  ; FCB3D2  0e
; ---------------------------------------------------------------------
; Ram3800_DataImage -- 2,918 bytes copied verbatim to RAM 0x003800
;
; Evidence: `ld XBC,0x00000b66 / lda XIY,0xfcb3d3 / lda XIX,0x003800 / ldir`, at
; 0xFC8020 and again at 0xFC807D.  0xB66 = 2918, and 0xFCB3D3 + 0xB66 =
; 0xFCBF39, which is where the NEXT image starts -- the two abut with no slack,
; and that is this table's last-entry test.  Exactly two sites in prom_a and
; prom_b form the address 0xFCB3D3, and both are those `lda XIY`s.
;
; ★ ITS LAYOUT, established 2026-09-25 (lane proma).  This header used to say
; the block had "NO field structure claimed: nothing in this module indexes it
; with a stride the listing can read".  The module does, with literal strides,
; and the bytes confirm each one by pointing at themselves:
;
;   RAM 0x3800  32 x u8, all 24    a per-SLOT budget.  0xFC9FFE `add XIY,
;               0x00003800 / ld C,(XIY) / cp c,0 / jrl le` skips when it is
;               <= 0; 0xFCA0CE `decm8 0x01,(xbc)` spends one; five more `add
;               XBC,0x00003800` in PartNotes_ApplyFrame/PartNotes_CollectFrame/PartNotes_BuildReleaseFrame.
;   RAM 0x3820   3 x u8, all 16    the same per QUEUE (0xFC9CB3, 0xFC9D49).
;   RAM 0x3823   3 x 13-byte QUEUE HEADS.  0xFC8F7C `ldw DE,0x3823 / add
;               DE,13*k`.  Node layout: +0..+8 payload (+2 a key byte and
;               +5 a long, 0xFC8FB3/0xFC8FBF), +9 PREV, +0x0B NEXT, both u16.
;               A head's links point at ITSELF: three empty circular lists.
;   RAM 0x384A  33 x 13-byte POOL nodes, linked into ONE ring.
;   RAM 0x39F7  32 x 15-byte LIST HEADS (one per slot), self-linked.  0xFC8E93
;               `ldw WA,0x39F7 / add WA,15*i` (i = (XIZ+8), 0xFF = none);
;               +0x0B PREV, +0x0D NEXT (0xFC9FEC `ld WA,(XBC+0x0d)`).
;   RAM 0x3BD7 129 x 15-byte POOL nodes, linked into ONE ring.
; Counts: 32 and 3 are the self-linked heads (a head is the record whose
; links name itself); 33 and 129 are the ring lengths; 32+3+36*13+161*15 =
; 2,918, the copy length.  notes/proma-2026-09-25/gen_ram3800_images.py checks
; every link, the rings and the constants against the ROM.
; ⚠ NOT claimed: what a slot, a queue or a node's payload MEANS, or where the
; two pools' free-list heads live (no immediate in either image names 0x384A
; or 0x3BD7; the heads must be runtime pointers).
; ---------------------------------------------------------------------
Ram3800_DataImage:
	.byte 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24  ; FCB3D3  RAM 0x3800..0x380F
	.byte 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24  ; FCB3E3  RAM 0x3810..0x381F

; Ram3800_Img_QueueBudget -- RAM 0x3820, 3 x u8 = 16: the per-queue budget
; read at 0xFC9CB3 / 0xFC9D49 (`add XBC,0x00003820`); see Ram3800_DataImage.
Ram3800_Img_QueueBudget:
	.byte 16, 16, 16                    ; FCB3F3  RAM 0x3820..0x3822

; Ram3800_Img_QueueHeads -- RAM 0x3823, three 13-byte queue heads, each
; linked to itself (empty); read via 0xFC8F7C `ldw DE,0x3823 / add DE,13*k`.
Ram3800_Img_QueueHeads:
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB3F6  RAM 0x3823 payload
	.short 0x3823, 0x3823                    ; FCB3FF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB403  RAM 0x3830 payload
	.short 0x3830, 0x3830                    ; FCB40C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB410  RAM 0x383D payload
	.short 0x383D, 0x383D                    ; FCB419  prev, next

; Ram3800_Img_QueuePool -- RAM 0x384A, 33 13-byte nodes linked into one ring
; (prev at +9, next at +0x0B), the pool the three queues draw from.
Ram3800_Img_QueuePool:
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB41D  RAM 0x384A payload
	.short 0x39EA, 0x3857                    ; FCB426  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB42A  RAM 0x3857 payload
	.short 0x384A, 0x3864                    ; FCB433  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB437  RAM 0x3864 payload
	.short 0x3857, 0x3871                    ; FCB440  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB444  RAM 0x3871 payload
	.short 0x3864, 0x387E                    ; FCB44D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB451  RAM 0x387E payload
	.short 0x3871, 0x388B                    ; FCB45A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB45E  RAM 0x388B payload
	.short 0x387E, 0x3898                    ; FCB467  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB46B  RAM 0x3898 payload
	.short 0x388B, 0x38A5                    ; FCB474  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB478  RAM 0x38A5 payload
	.short 0x3898, 0x38B2                    ; FCB481  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB485  RAM 0x38B2 payload
	.short 0x38A5, 0x38BF                    ; FCB48E  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB492  RAM 0x38BF payload
	.short 0x38B2, 0x38CC                    ; FCB49B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB49F  RAM 0x38CC payload
	.short 0x38BF, 0x38D9                    ; FCB4A8  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4AC  RAM 0x38D9 payload
	.short 0x38CC, 0x38E6                    ; FCB4B5  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4B9  RAM 0x38E6 payload
	.short 0x38D9, 0x38F3                    ; FCB4C2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4C6  RAM 0x38F3 payload
	.short 0x38E6, 0x3900                    ; FCB4CF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4D3  RAM 0x3900 payload
	.short 0x38F3, 0x390D                    ; FCB4DC  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4E0  RAM 0x390D payload
	.short 0x3900, 0x391A                    ; FCB4E9  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4ED  RAM 0x391A payload
	.short 0x390D, 0x3927                    ; FCB4F6  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB4FA  RAM 0x3927 payload
	.short 0x391A, 0x3934                    ; FCB503  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB507  RAM 0x3934 payload
	.short 0x3927, 0x3941                    ; FCB510  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB514  RAM 0x3941 payload
	.short 0x3934, 0x394E                    ; FCB51D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB521  RAM 0x394E payload
	.short 0x3941, 0x395B                    ; FCB52A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB52E  RAM 0x395B payload
	.short 0x394E, 0x3968                    ; FCB537  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB53B  RAM 0x3968 payload
	.short 0x395B, 0x3975                    ; FCB544  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB548  RAM 0x3975 payload
	.short 0x3968, 0x3982                    ; FCB551  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB555  RAM 0x3982 payload
	.short 0x3975, 0x398F                    ; FCB55E  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB562  RAM 0x398F payload
	.short 0x3982, 0x399C                    ; FCB56B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB56F  RAM 0x399C payload
	.short 0x398F, 0x39A9                    ; FCB578  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB57C  RAM 0x39A9 payload
	.short 0x399C, 0x39B6                    ; FCB585  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB589  RAM 0x39B6 payload
	.short 0x39A9, 0x39C3                    ; FCB592  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB596  RAM 0x39C3 payload
	.short 0x39B6, 0x39D0                    ; FCB59F  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5A3  RAM 0x39D0 payload
	.short 0x39C3, 0x39DD                    ; FCB5AC  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5B0  RAM 0x39DD payload
	.short 0x39D0, 0x39EA                    ; FCB5B9  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5BD  RAM 0x39EA payload
	.short 0x39DD, 0x384A                    ; FCB5C6  prev, next

; Ram3800_Img_ListHeads -- RAM 0x39F7, thirty-two 15-byte list heads, one per
; slot, each linked to itself; read via 0xFC8E93 `ldw WA,0x39F7 / add WA,15*i`.
Ram3800_Img_ListHeads:
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5CA  RAM 0x39F7 payload
	.short 0x39F7, 0x39F7                    ; FCB5D5  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5D9  RAM 0x3A06 payload
	.short 0x3A06, 0x3A06                    ; FCB5E4  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5E8  RAM 0x3A15 payload
	.short 0x3A15, 0x3A15                    ; FCB5F3  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB5F7  RAM 0x3A24 payload
	.short 0x3A24, 0x3A24                    ; FCB602  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB606  RAM 0x3A33 payload
	.short 0x3A33, 0x3A33                    ; FCB611  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB615  RAM 0x3A42 payload
	.short 0x3A42, 0x3A42                    ; FCB620  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB624  RAM 0x3A51 payload
	.short 0x3A51, 0x3A51                    ; FCB62F  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB633  RAM 0x3A60 payload
	.short 0x3A60, 0x3A60                    ; FCB63E  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB642  RAM 0x3A6F payload
	.short 0x3A6F, 0x3A6F                    ; FCB64D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB651  RAM 0x3A7E payload
	.short 0x3A7E, 0x3A7E                    ; FCB65C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB660  RAM 0x3A8D payload
	.short 0x3A8D, 0x3A8D                    ; FCB66B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB66F  RAM 0x3A9C payload
	.short 0x3A9C, 0x3A9C                    ; FCB67A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB67E  RAM 0x3AAB payload
	.short 0x3AAB, 0x3AAB                    ; FCB689  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB68D  RAM 0x3ABA payload
	.short 0x3ABA, 0x3ABA                    ; FCB698  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB69C  RAM 0x3AC9 payload
	.short 0x3AC9, 0x3AC9                    ; FCB6A7  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB6AB  RAM 0x3AD8 payload
	.short 0x3AD8, 0x3AD8                    ; FCB6B6  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB6BA  RAM 0x3AE7 payload
	.short 0x3AE7, 0x3AE7                    ; FCB6C5  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB6C9  RAM 0x3AF6 payload
	.short 0x3AF6, 0x3AF6                    ; FCB6D4  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB6D8  RAM 0x3B05 payload
	.short 0x3B05, 0x3B05                    ; FCB6E3  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB6E7  RAM 0x3B14 payload
	.short 0x3B14, 0x3B14                    ; FCB6F2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB6F6  RAM 0x3B23 payload
	.short 0x3B23, 0x3B23                    ; FCB701  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB705  RAM 0x3B32 payload
	.short 0x3B32, 0x3B32                    ; FCB710  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB714  RAM 0x3B41 payload
	.short 0x3B41, 0x3B41                    ; FCB71F  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB723  RAM 0x3B50 payload
	.short 0x3B50, 0x3B50                    ; FCB72E  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB732  RAM 0x3B5F payload
	.short 0x3B5F, 0x3B5F                    ; FCB73D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB741  RAM 0x3B6E payload
	.short 0x3B6E, 0x3B6E                    ; FCB74C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB750  RAM 0x3B7D payload
	.short 0x3B7D, 0x3B7D                    ; FCB75B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB75F  RAM 0x3B8C payload
	.short 0x3B8C, 0x3B8C                    ; FCB76A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB76E  RAM 0x3B9B payload
	.short 0x3B9B, 0x3B9B                    ; FCB779  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB77D  RAM 0x3BAA payload
	.short 0x3BAA, 0x3BAA                    ; FCB788  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB78C  RAM 0x3BB9 payload
	.short 0x3BB9, 0x3BB9                    ; FCB797  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB79B  RAM 0x3BC8 payload
	.short 0x3BC8, 0x3BC8                    ; FCB7A6  prev, next

; Ram3800_Img_ListPool -- RAM 0x3BD7, 129 15-byte nodes linked into one ring
; (prev at +0x0B, next at +0x0D), the pool the 32 slot lists draw from.
Ram3800_Img_ListPool:
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB7AA  RAM 0x3BD7 payload
	.short 0x4357, 0x3BE6                    ; FCB7B5  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB7B9  RAM 0x3BE6 payload
	.short 0x3BD7, 0x3BF5                    ; FCB7C4  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB7C8  RAM 0x3BF5 payload
	.short 0x3BE6, 0x3C04                    ; FCB7D3  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB7D7  RAM 0x3C04 payload
	.short 0x3BF5, 0x3C13                    ; FCB7E2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB7E6  RAM 0x3C13 payload
	.short 0x3C04, 0x3C22                    ; FCB7F1  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB7F5  RAM 0x3C22 payload
	.short 0x3C13, 0x3C31                    ; FCB800  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB804  RAM 0x3C31 payload
	.short 0x3C22, 0x3C40                    ; FCB80F  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB813  RAM 0x3C40 payload
	.short 0x3C31, 0x3C4F                    ; FCB81E  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB822  RAM 0x3C4F payload
	.short 0x3C40, 0x3C5E                    ; FCB82D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB831  RAM 0x3C5E payload
	.short 0x3C4F, 0x3C6D                    ; FCB83C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB840  RAM 0x3C6D payload
	.short 0x3C5E, 0x3C7C                    ; FCB84B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB84F  RAM 0x3C7C payload
	.short 0x3C6D, 0x3C8B                    ; FCB85A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB85E  RAM 0x3C8B payload
	.short 0x3C7C, 0x3C9A                    ; FCB869  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB86D  RAM 0x3C9A payload
	.short 0x3C8B, 0x3CA9                    ; FCB878  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB87C  RAM 0x3CA9 payload
	.short 0x3C9A, 0x3CB8                    ; FCB887  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB88B  RAM 0x3CB8 payload
	.short 0x3CA9, 0x3CC7                    ; FCB896  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB89A  RAM 0x3CC7 payload
	.short 0x3CB8, 0x3CD6                    ; FCB8A5  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB8A9  RAM 0x3CD6 payload
	.short 0x3CC7, 0x3CE5                    ; FCB8B4  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB8B8  RAM 0x3CE5 payload
	.short 0x3CD6, 0x3CF4                    ; FCB8C3  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB8C7  RAM 0x3CF4 payload
	.short 0x3CE5, 0x3D03                    ; FCB8D2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB8D6  RAM 0x3D03 payload
	.short 0x3CF4, 0x3D12                    ; FCB8E1  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB8E5  RAM 0x3D12 payload
	.short 0x3D03, 0x3D21                    ; FCB8F0  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB8F4  RAM 0x3D21 payload
	.short 0x3D12, 0x3D30                    ; FCB8FF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB903  RAM 0x3D30 payload
	.short 0x3D21, 0x3D3F                    ; FCB90E  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB912  RAM 0x3D3F payload
	.short 0x3D30, 0x3D4E                    ; FCB91D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB921  RAM 0x3D4E payload
	.short 0x3D3F, 0x3D5D                    ; FCB92C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB930  RAM 0x3D5D payload
	.short 0x3D4E, 0x3D6C                    ; FCB93B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB93F  RAM 0x3D6C payload
	.short 0x3D5D, 0x3D7B                    ; FCB94A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB94E  RAM 0x3D7B payload
	.short 0x3D6C, 0x3D8A                    ; FCB959  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB95D  RAM 0x3D8A payload
	.short 0x3D7B, 0x3D99                    ; FCB968  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB96C  RAM 0x3D99 payload
	.short 0x3D8A, 0x3DA8                    ; FCB977  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB97B  RAM 0x3DA8 payload
	.short 0x3D99, 0x3DB7                    ; FCB986  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB98A  RAM 0x3DB7 payload
	.short 0x3DA8, 0x3DC6                    ; FCB995  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB999  RAM 0x3DC6 payload
	.short 0x3DB7, 0x3DD5                    ; FCB9A4  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB9A8  RAM 0x3DD5 payload
	.short 0x3DC6, 0x3DE4                    ; FCB9B3  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB9B7  RAM 0x3DE4 payload
	.short 0x3DD5, 0x3DF3                    ; FCB9C2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB9C6  RAM 0x3DF3 payload
	.short 0x3DE4, 0x3E02                    ; FCB9D1  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB9D5  RAM 0x3E02 payload
	.short 0x3DF3, 0x3E11                    ; FCB9E0  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB9E4  RAM 0x3E11 payload
	.short 0x3E02, 0x3E20                    ; FCB9EF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCB9F3  RAM 0x3E20 payload
	.short 0x3E11, 0x3E2F                    ; FCB9FE  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA02  RAM 0x3E2F payload
	.short 0x3E20, 0x3E3E                    ; FCBA0D  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA11  RAM 0x3E3E payload
	.short 0x3E2F, 0x3E4D                    ; FCBA1C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA20  RAM 0x3E4D payload
	.short 0x3E3E, 0x3E5C                    ; FCBA2B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA2F  RAM 0x3E5C payload
	.short 0x3E4D, 0x3E6B                    ; FCBA3A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA3E  RAM 0x3E6B payload
	.short 0x3E5C, 0x3E7A                    ; FCBA49  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA4D  RAM 0x3E7A payload
	.short 0x3E6B, 0x3E89                    ; FCBA58  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA5C  RAM 0x3E89 payload
	.short 0x3E7A, 0x3E98                    ; FCBA67  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA6B  RAM 0x3E98 payload
	.short 0x3E89, 0x3EA7                    ; FCBA76  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA7A  RAM 0x3EA7 payload
	.short 0x3E98, 0x3EB6                    ; FCBA85  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA89  RAM 0x3EB6 payload
	.short 0x3EA7, 0x3EC5                    ; FCBA94  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBA98  RAM 0x3EC5 payload
	.short 0x3EB6, 0x3ED4                    ; FCBAA3  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBAA7  RAM 0x3ED4 payload
	.short 0x3EC5, 0x3EE3                    ; FCBAB2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBAB6  RAM 0x3EE3 payload
	.short 0x3ED4, 0x3EF2                    ; FCBAC1  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBAC5  RAM 0x3EF2 payload
	.short 0x3EE3, 0x3F01                    ; FCBAD0  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBAD4  RAM 0x3F01 payload
	.short 0x3EF2, 0x3F10                    ; FCBADF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBAE3  RAM 0x3F10 payload
	.short 0x3F01, 0x3F1F                    ; FCBAEE  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBAF2  RAM 0x3F1F payload
	.short 0x3F10, 0x3F2E                    ; FCBAFD  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB01  RAM 0x3F2E payload
	.short 0x3F1F, 0x3F3D                    ; FCBB0C  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB10  RAM 0x3F3D payload
	.short 0x3F2E, 0x3F4C                    ; FCBB1B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB1F  RAM 0x3F4C payload
	.short 0x3F3D, 0x3F5B                    ; FCBB2A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB2E  RAM 0x3F5B payload
	.short 0x3F4C, 0x3F6A                    ; FCBB39  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB3D  RAM 0x3F6A payload
	.short 0x3F5B, 0x3F79                    ; FCBB48  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB4C  RAM 0x3F79 payload
	.short 0x3F6A, 0x3F88                    ; FCBB57  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB5B  RAM 0x3F88 payload
	.short 0x3F79, 0x3F97                    ; FCBB66  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB6A  RAM 0x3F97 payload
	.short 0x3F88, 0x3FA6                    ; FCBB75  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB79  RAM 0x3FA6 payload
	.short 0x3F97, 0x3FB5                    ; FCBB84  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB88  RAM 0x3FB5 payload
	.short 0x3FA6, 0x3FC4                    ; FCBB93  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBB97  RAM 0x3FC4 payload
	.short 0x3FB5, 0x3FD3                    ; FCBBA2  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBBA6  RAM 0x3FD3 payload
	.short 0x3FC4, 0x3FE2                    ; FCBBB1  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBBB5  RAM 0x3FE2 payload
	.short 0x3FD3, 0x3FF1                    ; FCBBC0  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBBC4  RAM 0x3FF1 payload
	.short 0x3FE2, 0x4000                    ; FCBBCF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBBD3  RAM 0x4000 payload
	.short 0x3FF1, 0x400F                    ; FCBBDE  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBBE2  RAM 0x400F payload
	.short 0x4000, 0x401E                    ; FCBBED  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBBF1  RAM 0x401E payload
	.short 0x400F, 0x402D                    ; FCBBFC  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC00  RAM 0x402D payload
	.short 0x401E, 0x403C                    ; FCBC0B  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC0F  RAM 0x403C payload
	.short 0x402D, 0x404B                    ; FCBC1A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC1E  RAM 0x404B payload
	.short 0x403C, 0x405A                    ; FCBC29  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC2D  RAM 0x405A payload
	.short 0x404B, 0x4069                    ; FCBC38  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC3C  RAM 0x4069 payload
	.short 0x405A, 0x4078                    ; FCBC47  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC4B  RAM 0x4078 payload
	.short 0x4069, 0x4087                    ; FCBC56  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC5A  RAM 0x4087 payload
	.short 0x4078, 0x4096                    ; FCBC65  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC69  RAM 0x4096 payload
	.short 0x4087, 0x40A5                    ; FCBC74  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC78  RAM 0x40A5 payload
	.short 0x4096, 0x40B4                    ; FCBC83  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC87  RAM 0x40B4 payload
	.short 0x40A5, 0x40C3                    ; FCBC92  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBC96  RAM 0x40C3 payload
	.short 0x40B4, 0x40D2                    ; FCBCA1  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCA5  RAM 0x40D2 payload
	.short 0x40C3, 0x40E1                    ; FCBCB0  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCB4  RAM 0x40E1 payload
	.short 0x40D2, 0x40F0                    ; FCBCBF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCC3  RAM 0x40F0 payload
	.short 0x40E1, 0x40FF                    ; FCBCCE  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCD2  RAM 0x40FF payload
	.short 0x40F0, 0x410E                    ; FCBCDD  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCE1  RAM 0x410E payload
	.short 0x40FF, 0x411D                    ; FCBCEC  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCF0  RAM 0x411D payload
	.short 0x410E, 0x412C                    ; FCBCFB  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBCFF  RAM 0x412C payload
	.short 0x411D, 0x413B                    ; FCBD0A  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD0E  RAM 0x413B payload
	.short 0x412C, 0x414A                    ; FCBD19  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD1D  RAM 0x414A payload
	.short 0x413B, 0x4159                    ; FCBD28  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD2C  RAM 0x4159 payload
	.short 0x414A, 0x4168                    ; FCBD37  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD3B  RAM 0x4168 payload
	.short 0x4159, 0x4177                    ; FCBD46  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD4A  RAM 0x4177 payload
	.short 0x4168, 0x4186                    ; FCBD55  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD59  RAM 0x4186 payload
	.short 0x4177, 0x4195                    ; FCBD64  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD68  RAM 0x4195 payload
	.short 0x4186, 0x41A4                    ; FCBD73  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD77  RAM 0x41A4 payload
	.short 0x4195, 0x41B3                    ; FCBD82  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD86  RAM 0x41B3 payload
	.short 0x41A4, 0x41C2                    ; FCBD91  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBD95  RAM 0x41C2 payload
	.short 0x41B3, 0x41D1                    ; FCBDA0  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDA4  RAM 0x41D1 payload
	.short 0x41C2, 0x41E0                    ; FCBDAF  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDB3  RAM 0x41E0 payload
	.short 0x41D1, 0x41EF                    ; FCBDBE  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDC2  RAM 0x41EF payload
	.short 0x41E0, 0x41FE                    ; FCBDCD  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDD1  RAM 0x41FE payload
	.short 0x41EF, 0x420D                    ; FCBDDC  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDE0  RAM 0x420D payload
	.short 0x41FE, 0x421C                    ; FCBDEB  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDEF  RAM 0x421C payload
	.short 0x420D, 0x422B                    ; FCBDFA  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBDFE  RAM 0x422B payload
	.short 0x421C, 0x423A                    ; FCBE09  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE0D  RAM 0x423A payload
	.short 0x422B, 0x4249                    ; FCBE18  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE1C  RAM 0x4249 payload
	.short 0x423A, 0x4258                    ; FCBE27  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE2B  RAM 0x4258 payload
	.short 0x4249, 0x4267                    ; FCBE36  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE3A  RAM 0x4267 payload
	.short 0x4258, 0x4276                    ; FCBE45  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE49  RAM 0x4276 payload
	.short 0x4267, 0x4285                    ; FCBE54  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE58  RAM 0x4285 payload
	.short 0x4276, 0x4294                    ; FCBE63  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE67  RAM 0x4294 payload
	.short 0x4285, 0x42A3                    ; FCBE72  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE76  RAM 0x42A3 payload
	.short 0x4294, 0x42B2                    ; FCBE81  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE85  RAM 0x42B2 payload
	.short 0x42A3, 0x42C1                    ; FCBE90  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBE94  RAM 0x42C1 payload
	.short 0x42B2, 0x42D0                    ; FCBE9F  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBEA3  RAM 0x42D0 payload
	.short 0x42C1, 0x42DF                    ; FCBEAE  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBEB2  RAM 0x42DF payload
	.short 0x42D0, 0x42EE                    ; FCBEBD  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBEC1  RAM 0x42EE payload
	.short 0x42DF, 0x42FD                    ; FCBECC  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBED0  RAM 0x42FD payload
	.short 0x42EE, 0x430C                    ; FCBEDB  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBEDF  RAM 0x430C payload
	.short 0x42FD, 0x431B                    ; FCBEEA  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBEEE  RAM 0x431B payload
	.short 0x430C, 0x432A                    ; FCBEF9  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBEFD  RAM 0x432A payload
	.short 0x431B, 0x4339                    ; FCBF08  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBF0C  RAM 0x4339 payload
	.short 0x432A, 0x4348                    ; FCBF17  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBF1B  RAM 0x4348 payload
	.short 0x4339, 0x4357                    ; FCBF26  prev, next
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; FCBF2A  RAM 0x4357 payload
	.short 0x4348, 0x3BD7                    ; FCBF35  prev, next

; ---------------------------------------------------------------------
; Ram602054_DataImage -- 160 bytes copied verbatim to RAM 0x00602054
;
; Evidence: `ld XBC,0x000000a0 / lda XIY,0xfcbf39 / lda XIX,0x602054 / ldir` at
; 0xFC805C.  0xA0 = 160, and 0xFCBF39 + 0xA0 = 0xFCBFD9 -- the last-entry test
; again: the byte at 0xFCBFD9 is 0xFF and begins the sentinel run below, and the
; last 25 bytes of THIS image are 0x80, so the boundary is visible in the bytes
; as well as in the length.  One site forms 0xFCBF39, that `lda XIY`.
;
; ★ ITS LAYOUT, established 2026-09-25 (lane proma; this header used to leave
; its contents open):
;   RAM 0x602054  32 x u32 = 1 << k, a SLOT BIT MASK per slot index.
;                 0xFC8F57 and 0xFC9C66: `ld C,4 / mul C,H / add XBC,
;                 0x00602054 / ld XBC,(XBC)`, the first then OR-ing it into a
;                 32-bit set at (XIZ-4).
;   RAM 0x6020D4  32 x u8 = 0x80, a per-slot state byte: 0xFCA6E5 reads it
;                 (`cp L,0xFF`), 0xFCA6FE writes it, 0xFCA715 reads it again.
; 32 slots, the same count as the 32 list heads in Ram3800_DataImage.
; ⚠ What the state byte's values mean is not claimed.
; ---------------------------------------------------------------------
Ram602054_DataImage:
	.long 0x00000001                          ; FCBF39  RAM 0x602054  1 << 0
	.long 0x00000002                          ; FCBF3D  RAM 0x602058  1 << 1
	.long 0x00000004                          ; FCBF41  RAM 0x60205C  1 << 2
	.long 0x00000008                          ; FCBF45  RAM 0x602060  1 << 3
	.long 0x00000010                          ; FCBF49  RAM 0x602064  1 << 4
	.long 0x00000020                          ; FCBF4D  RAM 0x602068  1 << 5
	.long 0x00000040                          ; FCBF51  RAM 0x60206C  1 << 6
	.long 0x00000080                          ; FCBF55  RAM 0x602070  1 << 7
	.long 0x00000100                          ; FCBF59  RAM 0x602074  1 << 8
	.long 0x00000200                          ; FCBF5D  RAM 0x602078  1 << 9
	.long 0x00000400                          ; FCBF61  RAM 0x60207C  1 << 10
	.long 0x00000800                          ; FCBF65  RAM 0x602080  1 << 11
	.long 0x00001000                          ; FCBF69  RAM 0x602084  1 << 12
	.long 0x00002000                          ; FCBF6D  RAM 0x602088  1 << 13
	.long 0x00004000                          ; FCBF71  RAM 0x60208C  1 << 14
	.long 0x00008000                          ; FCBF75  RAM 0x602090  1 << 15
	.long 0x00010000                          ; FCBF79  RAM 0x602094  1 << 16
	.long 0x00020000                          ; FCBF7D  RAM 0x602098  1 << 17
	.long 0x00040000                          ; FCBF81  RAM 0x60209C  1 << 18
	.long 0x00080000                          ; FCBF85  RAM 0x6020A0  1 << 19
	.long 0x00100000                          ; FCBF89  RAM 0x6020A4  1 << 20
	.long 0x00200000                          ; FCBF8D  RAM 0x6020A8  1 << 21
	.long 0x00400000                          ; FCBF91  RAM 0x6020AC  1 << 22
	.long 0x00800000                          ; FCBF95  RAM 0x6020B0  1 << 23
	.long 0x01000000                          ; FCBF99  RAM 0x6020B4  1 << 24
	.long 0x02000000                          ; FCBF9D  RAM 0x6020B8  1 << 25
	.long 0x04000000                          ; FCBFA1  RAM 0x6020BC  1 << 26
	.long 0x08000000                          ; FCBFA5  RAM 0x6020C0  1 << 27
	.long 0x10000000                          ; FCBFA9  RAM 0x6020C4  1 << 28
	.long 0x20000000                          ; FCBFAD  RAM 0x6020C8  1 << 29
	.long 0x40000000                          ; FCBFB1  RAM 0x6020CC  1 << 30
	.long 0x80000000                          ; FCBFB5  RAM 0x6020D0  1 << 31

; Ram602054_Img_SlotState -- RAM 0x6020D4, 32 x u8 = 0x80, the per-slot state
; byte read at 0xFCA6E5/0xFCA715 and written at 0xFCA6FE; see above.
Ram602054_Img_SlotState:
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80  ; FCBFB9  RAM 0x6020D4..0x6020E3
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80  ; FCBFC9  RAM 0x6020E4..0x6020F3

; ---------------------------------------------------------------------
; Ram3800_Sentinels -- 17 bytes: FF FF FF FF, five 0x00, then 0x00..0x07
;
; Evidence: the bytes, and the two boundaries either side -- Ram602054_DataImage
; ends here by its own length and Ram3800_RecordPtrTable starts at 0xFCBFEA with
; 0x000076A2, the same first entry the module's other record table has.
; Unknown: its reader.  ⚠ A SEARCHED NEGATIVE stated as what the search
;          returned: no `call`, `jp`, `lda` or 32-bit pointer in prom_a or
;          prom_b names 0xFCBFD9 or 0xFCBFE2.  Whoever reads it does so from a
;          register.  The 0x00..0x07 tail has the same shape as
;          Msg0716_IdentityRamp_0_24 at 0xFC11E2, which is also unreached by any
;          named site -- a pattern worth noticing, not a conclusion.
; ---------------------------------------------------------------------
Ram3800_Sentinels:
	.byte 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06  ; FCBFD9
	.byte 0x07                                                                ; FCBFE9
; ---------------------------------------------------------------------
; Ram3800_RecordPtrTable -- 32 pointers to the SAME 0x40-byte RAM records the
; 0x0716 message module indexes
;
; Entries 0..24 are 0x000076A2 + 0x40*k with the SAME single exception the other
; copy has -- the step from entry 7 (0x7862) to entry 8 (0x78E2) is 0x80, so
; 0x000078A2 is skipped -- and entries 25..31 are all 0x000076A2, the first
; record again.  So the two tables are not copies: 0xFC1162 runs the ladder all
; the way to 0x7EA2, this one stops at 0x7CE2 and pads.
;
; ENTRY COUNT = 32, by last-entry test: the four bytes a 33rd entry would occupy
; are 0xF69E02EE, which is not a RAM address in any of the ranges
; notes/FINDINGS-memory-map.md gives CPU 1, and 0xFCC06A is where this module's
; last code region begins.
; Evidence: every entry, every step, the seven repeats and the 0xF69E02EE are
;          checks in notes/prom_a_fc8000_module_check.py.
; Unknown: its reader -- no named site forms 0xFCBFEA either.
; ---------------------------------------------------------------------
Ram3800_RecordPtrTable:
	.long 0x000076a2                                 ; FCBFEA  [  0]
	.long 0x000076e2                                 ; FCBFEE  [  1]
	.long 0x00007722                                 ; FCBFF2  [  2]
	.long 0x00007762                                 ; FCBFF6  [  3]
	.long 0x000077a2                                 ; FCBFFA  [  4]
	.long 0x000077e2                                 ; FCBFFE  [  5]
	.long 0x00007822                                 ; FCC002  [  6]
	.long 0x00007862                                 ; FCC006  [  7]
	.long 0x000078e2                                 ; FCC00A  [  8]
	.long 0x00007922                                 ; FCC00E  [  9]
	.long 0x00007962                                 ; FCC012  [ 10]
	.long 0x000079a2                                 ; FCC016  [ 11]
	.long 0x000079e2                                 ; FCC01A  [ 12]
	.long 0x00007a22                                 ; FCC01E  [ 13]
	.long 0x00007a62                                 ; FCC022  [ 14]
	.long 0x00007aa2                                 ; FCC026  [ 15]
	.long 0x00007ae2                                 ; FCC02A  [ 16]
	.long 0x00007b22                                 ; FCC02E  [ 17]
	.long 0x00007b62                                 ; FCC032  [ 18]
	.long 0x00007ba2                                 ; FCC036  [ 19]
	.long 0x00007be2                                 ; FCC03A  [ 20]
	.long 0x00007c22                                 ; FCC03E  [ 21]
	.long 0x00007c62                                 ; FCC042  [ 22]
	.long 0x00007ca2                                 ; FCC046  [ 23]
	.long 0x00007ce2                                 ; FCC04A  [ 24]
	.long 0x000076a2                                 ; FCC04E  [ 25]
	.long 0x000076a2                                 ; FCC052  [ 26]
	.long 0x000076a2                                 ; FCC056  [ 27]
	.long 0x000076a2                                 ; FCC05A  [ 28]
	.long 0x000076a2                                 ; FCC05E  [ 29]
	.long 0x000076a2                                 ; FCC062  [ 30]
	.long 0x000076a2                                 ; FCC066  [ 31]
; ---------------------------------------------------------------------
; Gap_FCC06A -- one byte, 0xEE, that belongs to neither side
;
; Evidence: 0xEE is the XIZ prefix of the TLCS-900 32-bit register group and the
; byte after it is 0x02, which that group does not define, so `EE 02` is not an
; instruction unidasm can decode -- it is the ONE undecodable byte in the whole
; module outside the declared data.  It is also past the end of
; Ram3800_RecordPtrTable's 32 entries.
; Unknown: whether it is alignment padding, a 33rd table slot never filled in,
;          or the tail of something else.  It is emitted as a byte and claimed
;          as nothing.  See the ⚠ in the module header: the code start after it
;          is not pinned.
; ---------------------------------------------------------------------
Gap_FCC06A:
	.byte 0xee                                                                ; FCC06A
	push SR                                              ; FCC06B  02
	sub	iy, (xiz-10)                                 ; FCC06C  9e f6 a5
	ld DE,IY                                             ; FCC06F  dd 8a
	ld wa, (xiz-4)                                       ; FCC071  9e fc 20
	extz XWA                                             ; FCC074  e8 12
	ld	c, (xwa+iy)                                  ; FCC076  c3 07 e0 f4 23
	cp C,(XIZ+0x12)                                      ; FCC07B  8e 12 f3
; unpinned code (see the module header): this branch and the `jr` at 0xFCC08A land on 0xFCC050, inside
; Ram3800_RecordPtrTable's entry 25, so the loop they close does not run as decoded here
	jr nz, -48                                           ; FCC07E  6e d0
	inc 2,IY                                             ; FCC080  dd 62
	add WA,IY                                            ; FCC082  dd 80
	ld (XWA),0x00                                        ; FCC084  b0 00 00
	incm8 0x01, (xiz-8)                                  ; FCC087  8e f8 61
	jr -60                                               ; FCC08A  68 c4
	ld bc, (xiz-8)                                       ; FCC08C  9e f8 21
	extz BC                                              ; FCC08F  d9 12
	ld WA,BC                                             ; FCC091  d9 88
	pop XIX                                              ; FCC093  5c
	popw de                                              ; FCC094  4a
	popw hl                                              ; FCC095  4b
	unlk XIZ                                             ; FCC096  ee 0d
	ret                                                  ; FCC098  0e
	link XIZ,0xffe8                                      ; FCC099  ee 0c e8 ff
	pushw hl                                             ; FCC09D  2b
	push XDE                                             ; FCC09E  3a
	push XIX                                             ; FCC09F  3c
	lda xix, (0x6021fc:24)                               ; FCC0A0  f2 fc 21 60 34
	ld C,(XIZ+0x11)                                      ; FCC0A5  8e 11 23
	ld (xiz-4), c                                        ; FCC0A8  be fc 43
	ld BC,(XIZ+0x08)                                     ; FCC0AB  9e 08 21
	ld (xiz-8), bc                                       ; FCC0AE  be f8 51
	ld DE,(XIZ+0x0a)                                     ; FCC0B1  9e 0a 22
	ld XWA,(XIZ+0x0c)                                    ; FCC0B4  ae 0c 20
	ld (xiz-12), xwa                                     ; FCC0B7  be f4 60
	ld IY,(XIZ+0x12)                                     ; FCC0BA  9e 12 25
	extz IY                                              ; FCC0BD  dd 12
	extz XIY                                             ; FCC0BF  ed 12
	add XWA,XIY                                          ; FCC0C1  ed 80
	ld H,(XWA)                                           ; FCC0C3  80 26
	ld W,(XIZ+0x10)                                      ; FCC0C5  8e 10 20
	ld (xiz-2), w                                        ; FCC0C8  be fe 40
	ld (XIX),0x00                                        ; FCC0CB  b4 00 00
	ld C,H                                               ; FCC0CE  ce 8b
	extz BC                                              ; FCC0D0  d9 12
	sll bc, 0x01                                         ; FCC0D2  d9 ee 01
	ld (xiz-6), bc                                       ; FCC0D5  be fa 51
.LFCC0D8:
	ld bc, (xiz-6)                                       ; FCC0D8  9e fa 21
	extz XDE                                             ; FCC0DB  ea 12
	ld	l, (xde+bc)                                  ; FCC0DD  c3 07 e8 e4 27
	cp L,H                                               ; FCC0E2  ce f7
	jrl z, .LFCC187                                      ; FCC0E4  76 a0 00
	ld A,(XIX)                                           ; FCC0E7  84 21
	extz WA                                              ; FCC0E9  d8 12
	extz XWA                                             ; FCC0EB  e8 12
	ld (xiz-12), xwa                                     ; FCC0ED  be f4 60
	sll xwa, 0x01                                        ; FCC0F0  e8 ee 01
	ld (xiz-16), xwa                                     ; FCC0F3  be f0 60
	ld xiy, (xiz-12)                                     ; FCC0F6  ae f4 25
	sll xiy, 0x03                                        ; FCC0F9  ed ee 03
	sub	xiy, (xiz-16)                                ; FCC0FC  ae f0 a5
	add XIY,0x006021fd                                   ; FCC0FF  ed c8 fd 21 60 00
	ld a, (xiz-4)                                        ; FCC105  8e fc 21
	ld (XIY),A                                           ; FCC108  b5 41
	ld xiy, (xiz-16)                                     ; FCC10A  ae f0 25
	sll xiy, 0x02                                        ; FCC10D  ed ee 02
	sub	xiy, (xiz-16)                                ; FCC110  ae f0 a5
	ld (xiz-20), xiy                                     ; FCC113  be ec 65
	inc 1,XIY                                            ; FCC116  ed 61
	add XIY,0x006021fd                                   ; FCC118  ed c8 fd 21 60 00
	ld C,(XIZ+0x12)                                      ; FCC11E  8e 12 23
	ld (XIY),C                                           ; FCC121  b5 43
	ld C,L                                               ; FCC123  cf 8b
	extz BC                                              ; FCC125  d9 12
	ld (xiz-22), bc                                      ; FCC127  be ea 51
	sll bc, 0x02                                         ; FCC12A  d9 ee 02
	sub	bc, (xiz-22)                                 ; FCC12D  9e ea a1
	ld (xiz-24), bc                                      ; FCC130  be e8 51
	inc 1,BC                                             ; FCC133  d9 61
	ld wa, (xiz-8)                                       ; FCC135  9e f8 20
	extz XWA                                             ; FCC138  e8 12
	ld	l, (xwa+bc)                                  ; FCC13A  c3 07 e0 e4 27
	ld xiy, (xiz-20)                                     ; FCC13F  ae ec 25
	inc 2,XIY                                            ; FCC142  ed 62
	add XIY,0x006021fd                                   ; FCC144  ed c8 fd 21 60 00
	ld (XIY),L                                           ; FCC14A  b5 47
	ld bc, (xiz-24)                                      ; FCC14C  9e e8 21
	inc 2,BC                                             ; FCC14F  d9 62
	ld wa, (xiz-8)                                       ; FCC151  9e f8 20
	extz XWA                                             ; FCC154  e8 12
	ld	l, (xwa+bc)                                  ; FCC156  c3 07 e0 e4 27
	ld xiy, (xiz-20)                                     ; FCC15B  ae ec 25
	inc 3,XIY                                            ; FCC15E  ed 63
	add XIY,0x006021fd                                   ; FCC160  ed c8 fd 21 60 00
	ld (XIY),L                                           ; FCC166  b5 47
	pushw	(xiz-22)                                     ; FCC168  9e ea 04
	pushw de                                             ; FCC16B  2a
	call sub_FCC502                                      ; FCC16C  1d 02 c5 fc
	ld bc, (xiz-2)                                       ; FCC170  9e fe 21
	extz BC                                              ; FCC173  d9 12
	pushw bc                                             ; FCC175  29
	pushw	(xiz-22)                                     ; FCC176  9e ea 04
	pushw de                                             ; FCC179  2a
	call sub_FCC573                                      ; FCC17A  1d 73 c5 fc
	incm8 0x01, (xix)                                    ; FCC17E  84 61
	inc 8,XSP                                            ; FCC180  ef 60
	inc 2,XSP                                            ; FCC182  ef 62
	jrl .LFCC0D8                                         ; FCC184  78 51 ff
.LFCC187:
	ld C,(XIX)                                           ; FCC187  84 23
	extz BC                                              ; FCC189  d9 12
	ld WA,BC                                             ; FCC18B  d9 88
	pop XIX                                              ; FCC18D  5c
	pop XDE                                              ; FCC18E  5a
	popw hl                                              ; FCC18F  4b
	unlk XIZ                                             ; FCC190  ee 0d
	ret                                                  ; FCC192  0e
	link XIZ,0xffea                                      ; FCC193  ee 0c ea ff
	pushw hl                                             ; FCC197  2b
	push XDE                                             ; FCC198  3a
	push XIX                                             ; FCC199  3c
	lda xix, (0x6021fc:24)                               ; FCC19A  f2 fc 21 60 34
	ld C,(XIZ+0x11)                                      ; FCC19F  8e 11 23
	ld (xiz-4), c                                        ; FCC1A2  be fc 43
	ld BC,(XIZ+0x08)                                     ; FCC1A5  9e 08 21
	ld (xiz-8), bc                                       ; FCC1A8  be f8 51
	ld DE,(XIZ+0x0a)                                     ; FCC1AB  9e 0a 22
	ld XWA,(XIZ+0x0c)                                    ; FCC1AE  ae 0c 20
	ld (xiz-12), xwa                                     ; FCC1B1  be f4 60
	ld IY,(XIZ+0x12)                                     ; FCC1B4  9e 12 25
	extz IY                                              ; FCC1B7  dd 12
	extz XIY                                             ; FCC1B9  ed 12
	add XWA,XIY                                          ; FCC1BB  ed 80
	ld H,(XWA)                                           ; FCC1BD  80 26
	ld W,(XIZ+0x10)                                      ; FCC1BF  8e 10 20
	ld (xiz-2), w                                        ; FCC1C2  be fe 40
	ld (XIX),0x00                                        ; FCC1C5  b4 00 00
	ld C,H                                               ; FCC1C8  ce 8b
	extz BC                                              ; FCC1CA  d9 12
	sll bc, 0x01                                         ; FCC1CC  d9 ee 01
	ld (xiz-6), bc                                       ; FCC1CF  be fa 51
.LFCC1D2:
	ld bc, (xiz-6)                                       ; FCC1D2  9e fa 21
	extz XDE                                             ; FCC1D5  ea 12
	ld	l, (xde+bc)                                  ; FCC1D7  c3 07 e8 e4 27
	cp L,H                                               ; FCC1DC  ce f7
	jrl z, .LFCC270                                      ; FCC1DE  76 8f 00
	ld A,(XIX)                                           ; FCC1E1  84 21
	extz WA                                              ; FCC1E3  d8 12
	extz XWA                                             ; FCC1E5  e8 12
	ld (xiz-12), xwa                                     ; FCC1E7  be f4 60
	sll xwa, 0x01                                        ; FCC1EA  e8 ee 01
	ld (xiz-16), xwa                                     ; FCC1ED  be f0 60
	ld xiy, (xiz-12)                                     ; FCC1F0  ae f4 25
	sll xiy, 0x03                                        ; FCC1F3  ed ee 03
	sub	xiy, (xiz-16)                                ; FCC1F6  ae f0 a5
	add XIY,0x006021fd                                   ; FCC1F9  ed c8 fd 21 60 00
	ld a, (xiz-4)                                        ; FCC1FF  8e fc 21
	ld (XIY),A                                           ; FCC202  b5 41
	ld xiy, (xiz-16)                                     ; FCC204  ae f0 25
	sll xiy, 0x02                                        ; FCC207  ed ee 02
	sub	xiy, (xiz-16)                                ; FCC20A  ae f0 a5
	ld (xiz-20), xiy                                     ; FCC20D  be ec 65
	inc 1,XIY                                            ; FCC210  ed 61
	add XIY,0x006021fd                                   ; FCC212  ed c8 fd 21 60 00
	ld C,(XIZ+0x12)                                      ; FCC218  8e 12 23
	ld (XIY),C                                           ; FCC21B  b5 43
	ld C,L                                               ; FCC21D  cf 8b
	extz BC                                              ; FCC21F  d9 12
	ld (xiz-22), bc                                      ; FCC221  be ea 51
	sll bc, 0x02                                         ; FCC224  d9 ee 02
	sub	bc, (xiz-22)                                 ; FCC227  9e ea a1
	inc 1,BC                                             ; FCC22A  d9 61
	ld wa, (xiz-8)                                       ; FCC22C  9e f8 20
	extz XWA                                             ; FCC22F  e8 12
	ld	l, (xwa+bc)                                  ; FCC231  c3 07 e0 e4 27
	ld xiy, (xiz-20)                                     ; FCC236  ae ec 25
	inc 2,XIY                                            ; FCC239  ed 62
	add XIY,0x006021fd                                   ; FCC23B  ed c8 fd 21 60 00
	ld (XIY),L                                           ; FCC241  b5 47
	ld xbc, (xiz-20)                                     ; FCC243  ae ec 21
	inc 3,XBC                                            ; FCC246  e9 63
	add XBC,0x006021fd                                   ; FCC248  e9 c8 fd 21 60 00
	ld (XBC),0x00                                        ; FCC24E  b1 00 00
	pushw	(xiz-22)                                     ; FCC251  9e ea 04
	pushw de                                             ; FCC254  2a
	call sub_FCC502                                      ; FCC255  1d 02 c5 fc
	ld bc, (xiz-2)                                       ; FCC259  9e fe 21
	extz BC                                              ; FCC25C  d9 12
	pushw bc                                             ; FCC25E  29
	pushw	(xiz-22)                                     ; FCC25F  9e ea 04
	pushw de                                             ; FCC262  2a
	call sub_FCC573                                      ; FCC263  1d 73 c5 fc
	incm8 0x01, (xix)                                    ; FCC267  84 61
	inc 8,XSP                                            ; FCC269  ef 60
	inc 2,XSP                                            ; FCC26B  ef 62
	jrl .LFCC1D2                                         ; FCC26D  78 62 ff
.LFCC270:
	ld C,(XIX)                                           ; FCC270  84 23
	extz BC                                              ; FCC272  d9 12
	ld WA,BC                                             ; FCC274  d9 88
	pop XIX                                              ; FCC276  5c
	pop XDE                                              ; FCC277  5a
	popw hl                                              ; FCC278  4b
	unlk XIZ                                             ; FCC279  ee 0d
	ret                                                  ; FCC27B  0e
	link XIZ,0xfff6                                      ; FCC27C  ee 0c f6 ff
	pushw hl                                             ; FCC280  2b
	pushw de                                             ; FCC281  2a
	push XIX                                             ; FCC282  3c
	lda xix, (xiz+0x08)                                  ; FCC283  be 08 34
	ld BC,(XIX)                                          ; FCC286  94 21
	ld (xiz-4), bc                                       ; FCC288  be fc 51
	ld WA,(XIX+0x02)                                     ; FCC28B  9c 02 20
	ld (xiz-2), wa                                       ; FCC28E  be fe 50
	ld XIY,(XIX+0x04)                                    ; FCC291  ac 04 25
	ld (xiz-10), xiy                                     ; FCC294  be f6 65
	ld BC,(XIZ+0x14)                                     ; FCC297  9e 14 21
	extz BC                                              ; FCC29A  d9 12
	extz XBC                                             ; FCC29C  e9 12
	add XIY,XBC                                          ; FCC29E  e9 85
	ld L,(XIY)                                           ; FCC2A0  85 27
	ld H,L                                               ; FCC2A2  cf 8e
	ld (xiz-6), 0x00                                     ; FCC2A4  be fa 00 00
.LFCC2A8:
	ld C,H                                               ; FCC2A8  ce 8b
	extz BC                                              ; FCC2AA  d9 12
	sll bc, 0x01                                         ; FCC2AC  d9 ee 01
	inc 1,BC                                             ; FCC2AF  d9 61
	ld wa, (xiz-2)                                       ; FCC2B1  9e fe 20
	extz XWA                                             ; FCC2B4  e8 12
	ld	h, (xwa+bc)                                  ; FCC2B6  c3 07 e0 e4 26
	cp H,L                                               ; FCC2BB  cf f6
	jr z, .LFCC308                                       ; FCC2BD  66 49
	ldfr_berp h, 0xf4                                      ; FCC2BF  c7 f4 9e   ld IYL,H
	extz IY                                              ; FCC2C2  dd 12
	ld (xiz-8), iy                                       ; FCC2C4  be f8 55
	ld DE,IY                                             ; FCC2C7  dd 8a
	sll de, 0x01                                         ; FCC2C9  da ee 01
	sll iy, 0x03                                         ; FCC2CC  dd ee 03
	sub IY,DE                                            ; FCC2CF  da a5
	ld wa, (xiz-4)                                       ; FCC2D1  9e fc 20
	extz XWA                                             ; FCC2D4  e8 12
	ld	c, (xwa+iy)                                  ; FCC2D6  c3 07 e0 f4 23
	cp C,(XIZ+0x12)                                      ; FCC2DB  8e 12 f3
	jr nz, .LFCC2A8                                      ; FCC2DE  6e c8
	ld BC,DE                                             ; FCC2E0  da 89
	sll bc, 0x02                                         ; FCC2E2  d9 ee 02
	sub BC,DE                                            ; FCC2E5  da a1
	ld DE,BC                                             ; FCC2E7  d9 8a
	inc 1,BC                                             ; FCC2E9  d9 61
	ld wa, (xiz-4)                                       ; FCC2EB  9e fc 20
	extz XWA                                             ; FCC2EE  e8 12
	ld	c, (xwa+bc)                                  ; FCC2F0  c3 07 e0 e4 23
	cp C,(XIZ+0x14)                                      ; FCC2F5  8e 14 f3
	jr nz, .LFCC2A8                                      ; FCC2F8  6e ae
	ld BC,DE                                             ; FCC2FA  da 89
	inc 3,BC                                             ; FCC2FC  d9 63
	add WA,BC                                            ; FCC2FE  d9 80
	ld (XWA),0x00                                        ; FCC300  b0 00 00
	incm8 0x01, (xiz-6)                                  ; FCC303  8e fa 61
	jr .LFCC2A8                                          ; FCC306  68 a0
.LFCC308:
	ld bc, (xiz-6)                                       ; FCC308  9e fa 21
	extz BC                                              ; FCC30B  d9 12
	ld WA,BC                                             ; FCC30D  d9 88
	pop XIX                                              ; FCC30F  5c
	popw de                                              ; FCC310  4a
	popw hl                                              ; FCC311  4b
	unlk XIZ                                             ; FCC312  ee 0d
	ret                                                  ; FCC314  0e
	link XIZ,0xfff2                                      ; FCC315  ee 0c f2 ff
	pushw hl                                             ; FCC319  2b
	pushw de                                             ; FCC31A  2a
	push XIX                                             ; FCC31B  3c
	ld BC,(XIZ+0x08)                                     ; FCC31C  9e 08 21
	ld (xiz-6), bc                                       ; FCC31F  be fa 51
	ld WA,(XIZ+0x0a)                                     ; FCC322  9e 0a 20
	ld (xiz-4), wa                                       ; FCC325  be fc 50
	ld XIY,(XIZ+0x0c)                                    ; FCC328  ae 0c 25
	ld (xiz-10), xiy                                     ; FCC32B  be f6 65
	ld BC,(XIZ+0x14)                                     ; FCC32E  9e 14 21
	extz BC                                              ; FCC331  d9 12
	extz XBC                                             ; FCC333  e9 12
	add XIY,XBC                                          ; FCC335  e9 85
	ld L,(XIY)                                           ; FCC337  85 27
	ld (0x6022bd:24), 0x00                             ; FCC339  f2 bd 22 60 00 00
	ldfr_berp l, 0xf4                                      ; FCC33F  c7 f4 9f   ld IYL,L
	extz IY                                              ; FCC342  dd 12
	sll iy, 0x01                                         ; FCC344  dd ee 01
	ld (xiz-2), iy                                       ; FCC347  be fe 55
	ld XIX,0x00000000                                    ; FCC34A  44 00 00 00 00
.LFCC34F:
	ld wa, (xiz-2)                                       ; FCC34F  9e fe 20
	ld bc, (xiz-4)                                       ; FCC352  9e fc 21
	extz XBC                                             ; FCC355  e9 12
	ld	h, (xbc+wa)                                  ; FCC357  c3 07 e4 e0 26
	cp H,L                                               ; FCC35C  cf f6
	jrl z, .LFCC403                                      ; FCC35E  76 a2 00
	ldfr_berp h, 0xf4                                      ; FCC361  c7 f4 9e   ld IYL,H
	extz IY                                              ; FCC364  dd 12
	ld (xiz-8), iy                                       ; FCC366  be f8 55
	ld DE,IY                                             ; FCC369  dd 8a
	sll de, 0x01                                         ; FCC36B  da ee 01
	sll iy, 0x03                                         ; FCC36E  dd ee 03
	sub IY,DE                                            ; FCC371  da a5
	ld wa, (xiz-6)                                       ; FCC373  9e fa 20
	extz XWA                                             ; FCC376  e8 12
	ld	c, (xwa+iy)                                  ; FCC378  c3 07 e0 f4 23
	cp C,(XIZ+0x12)                                      ; FCC37D  8e 12 f3
	jr nz, .LFCC34F                                      ; FCC380  6e cd
	ld BC,DE                                             ; FCC382  da 89
	sll bc, 0x02                                         ; FCC384  d9 ee 02
	sub BC,DE                                            ; FCC387  da a1
	ld DE,BC                                             ; FCC389  d9 8a
	inc 1,BC                                             ; FCC38B  d9 61
	ld wa, (xiz-6)                                       ; FCC38D  9e fa 20
	extz XWA                                             ; FCC390  e8 12
	ld	c, (xwa+bc)                                  ; FCC392  c3 07 e0 e4 23
	cp C,(XIZ+0x14)                                      ; FCC397  8e 14 f3
	jr nz, .LFCC34F                                      ; FCC39A  6e b3
	ld (xiz-10), xix                                     ; FCC39C  be f6 64
	ld xbc, (xiz-10)                                     ; FCC39F  ae f6 21
	ld (xiz-14), xbc                                     ; FCC3A2  be f2 61
	add XBC,0x006022be                                   ; FCC3A5  e9 c8 be 22 60 00
	ld A,(XIZ+0x12)                                      ; FCC3AB  8e 12 21
	ld (XBC),A                                           ; FCC3AE  b1 41
	ld xbc, (xiz-14)                                     ; FCC3B0  ae f2 21
	inc 1,XBC                                            ; FCC3B3  e9 61
	add XBC,0x006022be                                   ; FCC3B5  e9 c8 be 22 60 00
	ld A,(XIZ+0x14)                                      ; FCC3BB  8e 14 21
	ld (XBC),A                                           ; FCC3BE  b1 41
	ld BC,DE                                             ; FCC3C0  da 89
	inc 2,BC                                             ; FCC3C2  d9 62
	ld wa, (xiz-6)                                       ; FCC3C4  9e fa 20
	extz XWA                                             ; FCC3C7  e8 12
	ld	h, (xwa+bc)                                  ; FCC3C9  c3 07 e0 e4 26
	ld xiy, (xiz-14)                                     ; FCC3CE  ae f2 25
	inc 2,XIY                                            ; FCC3D1  ed 62
	add XIY,0x006022be                                   ; FCC3D3  ed c8 be 22 60 00
	ld (XIY),H                                           ; FCC3D9  b5 46
	ld BC,DE                                             ; FCC3DB  da 89
	inc 3,BC                                             ; FCC3DD  d9 63
	ld wa, (xiz-6)                                       ; FCC3DF  9e fa 20
	extz XWA                                             ; FCC3E2  e8 12
	ld	h, (xwa+bc)                                  ; FCC3E4  c3 07 e0 e4 26
	ld xiy, (xiz-14)                                     ; FCC3E9  ae f2 25
	inc 3,XIY                                            ; FCC3EC  ed 63
	add XIY,0x006022be                                   ; FCC3EE  ed c8 be 22 60 00
	ld (XIY),H                                           ; FCC3F4  b5 46
	ld xix, (xiz-10)                                     ; FCC3F6  ae f6 24
	inc 6,XIX                                            ; FCC3F9  ec 66
	inc 0x01, (0x6022bd:24)                           ; FCC3FB  c2 bd 22 60 61
	jrl .LFCC34F                                         ; FCC400  78 4c ff
.LFCC403:
	ld bc, (0x6022bd:24)                                ; FCC403  d2 bd 22 60 21
	extz BC                                              ; FCC408  d9 12
	ld WA,BC                                             ; FCC40A  d9 88
	pop XIX                                              ; FCC40C  5c
	popw de                                              ; FCC40D  4a
	popw hl                                              ; FCC40E  4b
	unlk XIZ                                             ; FCC40F  ee 0d
	ret                                                  ; FCC411  0e
	link XIZ,0xfff2                                      ; FCC412  ee 0c f2 ff
	pushw hl                                             ; FCC416  2b
	pushw de                                             ; FCC417  2a
	push XIX                                             ; FCC418  3c
	ld BC,(XIZ+0x08)                                     ; FCC419  9e 08 21
	ld (xiz-6), bc                                       ; FCC41C  be fa 51
	ld WA,(XIZ+0x0a)                                     ; FCC41F  9e 0a 20
	ld (xiz-4), wa                                       ; FCC422  be fc 50
	ld XIY,(XIZ+0x0c)                                    ; FCC425  ae 0c 25
	ld (xiz-10), xiy                                     ; FCC428  be f6 65
	ld BC,(XIZ+0x14)                                     ; FCC42B  9e 14 21
	extz BC                                              ; FCC42E  d9 12
	extz XBC                                             ; FCC430  e9 12
	add XIY,XBC                                          ; FCC432  e9 85
	ld L,(XIY)                                           ; FCC434  85 27
	ld (0x6022bd:24), 0x00                             ; FCC436  f2 bd 22 60 00 00
	ldfr_berp l, 0xf4                                      ; FCC43C  c7 f4 9f   ld IYL,L
	extz IY                                              ; FCC43F  dd 12
	sll iy, 0x01                                         ; FCC441  dd ee 01
	ld (xiz-2), iy                                       ; FCC444  be fe 55
	ld XIX,0x00000000                                    ; FCC447  44 00 00 00 00
.LFCC44C:
	ld wa, (xiz-2)                                       ; FCC44C  9e fe 20
	ld bc, (xiz-4)                                       ; FCC44F  9e fc 21
	extz XBC                                             ; FCC452  e9 12
	ld	h, (xbc+wa)                                  ; FCC454  c3 07 e4 e0 26
	cp H,L                                               ; FCC459  cf f6
	jrl z, .LFCC4F3                                      ; FCC45B  76 95 00
	ldfr_berp h, 0xf4                                      ; FCC45E  c7 f4 9e   ld IYL,H
	extz IY                                              ; FCC461  dd 12
	ld (xiz-8), iy                                       ; FCC463  be f8 55
	ld DE,IY                                             ; FCC466  dd 8a
	sll de, 0x01                                         ; FCC468  da ee 01
	sll iy, 0x03                                         ; FCC46B  dd ee 03
	sub IY,DE                                            ; FCC46E  da a5
	ld wa, (xiz-6)                                       ; FCC470  9e fa 20
	extz XWA                                             ; FCC473  e8 12
	ld	c, (xwa+iy)                                  ; FCC475  c3 07 e0 f4 23
	cp C,(XIZ+0x12)                                      ; FCC47A  8e 12 f3
	jr nz, .LFCC44C                                      ; FCC47D  6e cd
	ld BC,DE                                             ; FCC47F  da 89
	sll bc, 0x02                                         ; FCC481  d9 ee 02
	sub BC,DE                                            ; FCC484  da a1
	ld DE,BC                                             ; FCC486  d9 8a
	inc 1,BC                                             ; FCC488  d9 61
	ld wa, (xiz-6)                                       ; FCC48A  9e fa 20
	extz XWA                                             ; FCC48D  e8 12
	ld	c, (xwa+bc)                                  ; FCC48F  c3 07 e0 e4 23
	cp C,(XIZ+0x14)                                      ; FCC494  8e 14 f3
	jr nz, .LFCC44C                                      ; FCC497  6e b3
	ld (xiz-10), xix                                     ; FCC499  be f6 64
	ld xbc, (xiz-10)                                     ; FCC49C  ae f6 21
	ld (xiz-14), xbc                                     ; FCC49F  be f2 61
	add XBC,0x006022be                                   ; FCC4A2  e9 c8 be 22 60 00
	ld A,(XIZ+0x12)                                      ; FCC4A8  8e 12 21
	ld (XBC),A                                           ; FCC4AB  b1 41
	ld xbc, (xiz-14)                                     ; FCC4AD  ae f2 21
	inc 1,XBC                                            ; FCC4B0  e9 61
	add XBC,0x006022be                                   ; FCC4B2  e9 c8 be 22 60 00
	ld A,(XIZ+0x14)                                      ; FCC4B8  8e 14 21
	ld (XBC),A                                           ; FCC4BB  b1 41
	ld BC,DE                                             ; FCC4BD  da 89
	inc 2,BC                                             ; FCC4BF  d9 62
	ld wa, (xiz-6)                                       ; FCC4C1  9e fa 20
	extz XWA                                             ; FCC4C4  e8 12
	ld	h, (xwa+bc)                                  ; FCC4C6  c3 07 e0 e4 26
	ld xiy, (xiz-14)                                     ; FCC4CB  ae f2 25
	inc 2,XIY                                            ; FCC4CE  ed 62
	add XIY,0x006022be                                   ; FCC4D0  ed c8 be 22 60 00
	ld (XIY),H                                           ; FCC4D6  b5 46
	ld xbc, (xiz-14)                                     ; FCC4D8  ae f2 21
	inc 3,XBC                                            ; FCC4DB  e9 63
	add XBC,0x006022be                                   ; FCC4DD  e9 c8 be 22 60 00
	ld (XBC),0x00                                        ; FCC4E3  b1 00 00
	ld xix, (xiz-10)                                     ; FCC4E6  ae f6 24
	inc 6,XIX                                            ; FCC4E9  ec 66
	inc 0x01, (0x6022bd:24)                           ; FCC4EB  c2 bd 22 60 61
	jrl .LFCC44C                                         ; FCC4F0  78 59 ff
.LFCC4F3:
	ld bc, (0x6022bd:24)                                ; FCC4F3  d2 bd 22 60 21
	extz BC                                              ; FCC4F8  d9 12
	ld WA,BC                                             ; FCC4FA  d9 88
	pop XIX                                              ; FCC4FC  5c
	popw de                                              ; FCC4FD  4a
	popw hl                                              ; FCC4FE  4b
	unlk XIZ                                             ; FCC4FF  ee 0d
	ret                                                  ; FCC501  0e
sub_FCC502:
	link XIZ,0xfffc                                      ; FCC502  ee 0c fc ff
	push H                                               ; FCC506  ce 04
	push XDE                                             ; FCC508  3a
	ld DE,(XIZ+0x08)                                     ; FCC509  9e 08 22
	ld BC,(XIZ+0x0a)                                     ; FCC50C  9e 0a 21
	extz BC                                              ; FCC50F  d9 12
	sll bc, 0x01                                         ; FCC511  d9 ee 01
	ld (xiz-2), bc                                       ; FCC514  be fe 51
	inc 1,BC                                             ; FCC517  d9 61
	ld (xiz-4), bc                                       ; FCC519  be fc 51
	extz XDE                                             ; FCC51C  ea 12
	ld	h, (xde+bc)                                  ; FCC51E  c3 07 e8 e4 26
	ld wa, (xiz-2)                                       ; FCC523  9e fe 20
	extz XDE                                             ; FCC526  ea 12
	ld	c, (xde+wa)                                  ; FCC528  c3 07 e8 e0 23
	extz BC                                              ; FCC52D  d9 12
	sll bc, 0x01                                         ; FCC52F  d9 ee 01
	inc 1,BC                                             ; FCC532  d9 61
	extz XBC                                             ; FCC534  e9 12
	add BC,DE                                            ; FCC536  da 81
	ld (XBC),H                                           ; FCC538  b1 46
	ld bc, (xiz-2)                                       ; FCC53A  9e fe 21
	extz XDE                                             ; FCC53D  ea 12
	ld	h, (xde+bc)                                  ; FCC53F  c3 07 e8 e4 26
	ld wa, (xiz-4)                                       ; FCC544  9e fc 20
	extz XDE                                             ; FCC547  ea 12
	ld	c, (xde+wa)                                  ; FCC549  c3 07 e8 e0 23
	extz BC                                              ; FCC54E  d9 12
	sll bc, 0x01                                         ; FCC550  d9 ee 01
	extz XBC                                             ; FCC553  e9 12
	add BC,DE                                            ; FCC555  da 81
	ld (XBC),H                                           ; FCC557  b1 46
	ld BC,DE                                             ; FCC559  da 89
	extz XBC                                             ; FCC55B  e9 12
	add	bc, (xiz-4)                                  ; FCC55D  9e fc 81
	ld (XBC),0x63                                        ; FCC560  b1 00 63
	ld BC,DE                                             ; FCC563  da 89
	extz XBC                                             ; FCC565  e9 12
	add	bc, (xiz-2)                                  ; FCC567  9e fe 81
	ld (XBC),0x63                                        ; FCC56A  b1 00 63
	pop XDE                                              ; FCC56D  5a
	pop H                                                ; FCC56E  ce 05
	unlk XIZ                                             ; FCC570  ee 0d
	ret                                                  ; FCC572  0e
sub_FCC573:
	link XIZ,0xfffc                                      ; FCC573  ee 0c fc ff
	pushw hl                                             ; FCC577  2b
	push XDE                                             ; FCC578  3a
	ld DE,(XIZ+0x08)                                     ; FCC579  9e 08 22
	ld H,(XIZ+0x0a)                                      ; FCC57C  8e 0a 26
	ld BC,(XIZ+0x0c)                                     ; FCC57F  9e 0c 21
	extz BC                                              ; FCC582  d9 12
	sll bc, 0x01                                         ; FCC584  d9 ee 01
	inc 1,BC                                             ; FCC587  d9 61
	ld (xiz-2), bc                                       ; FCC589  be fe 51
	extz XDE                                             ; FCC58C  ea 12
	ld	l, (xde+bc)                                  ; FCC58E  c3 07 e8 e4 27
	ld A,H                                               ; FCC593  ce 89
	extz WA                                              ; FCC595  d8 12
	sll wa, 0x01                                         ; FCC597  d8 ee 01
	ld (xiz-4), wa                                       ; FCC59A  be fc 50
	inc 1,WA                                             ; FCC59D  d8 61
	extz XWA                                             ; FCC59F  e8 12
	add WA,DE                                            ; FCC5A1  da 80
	ld (XWA),L                                           ; FCC5A3  b0 47
	ld BC,DE                                             ; FCC5A5  da 89
	extz XBC                                             ; FCC5A7  e9 12
	add	bc, (xiz-4)                                  ; FCC5A9  9e fc 81
	ld A,(XIZ+0x0c)                                      ; FCC5AC  8e 0c 21
	ld (XBC),A                                           ; FCC5AF  b1 41
	ld bc, (xiz-2)                                       ; FCC5B1  9e fe 21
	extz XDE                                             ; FCC5B4  ea 12
	ld	a, (xde+bc)                                  ; FCC5B6  c3 07 e8 e4 21
	extz WA                                              ; FCC5BB  d8 12
	sll wa, 0x01                                         ; FCC5BD  d8 ee 01
	extz XWA                                             ; FCC5C0  e8 12
	add WA,DE                                            ; FCC5C2  da 80
	ld (XWA),H                                           ; FCC5C4  b0 46
	ld BC,DE                                             ; FCC5C6  da 89
	extz XBC                                             ; FCC5C8  e9 12
	add	bc, (xiz-2)                                  ; FCC5CA  9e fe 81
	ld (XBC),H                                           ; FCC5CD  b1 46
	pop XDE                                              ; FCC5CF  5a
	popw hl                                              ; FCC5D0  4b
	unlk XIZ                                             ; FCC5D1  ee 0d
	ret                                                  ; FCC5D3  0e
	link XIZ,0xfff4                                      ; FCC5D4  ee 0c f4 ff
	pushw hl                                             ; FCC5D8  2b
	pushw de                                             ; FCC5D9  2a
	push XIX                                             ; FCC5DA  3c
	lda xix, (xiz+0x08)                                  ; FCC5DB  be 08 34
	ld BC,(XIX)                                          ; FCC5DE  94 21
	ld (xiz-6), bc                                       ; FCC5E0  be fa 51
	ld WA,(XIX+0x02)                                     ; FCC5E3  9c 02 20
	ld (xiz-8), wa                                       ; FCC5E6  be f8 50
	ld XIY,(XIX+0x04)                                    ; FCC5E9  ac 04 25
	ld (xiz-12), xiy                                     ; FCC5EC  be f4 65
	ld BC,(XIZ+0x12)                                     ; FCC5EF  9e 12 21
	extz BC                                              ; FCC5F2  d9 12
	extz XBC                                             ; FCC5F4  e9 12
	add XIY,XBC                                          ; FCC5F6  e9 85
	ld C,(XIY)                                           ; FCC5F8  85 23
	ld (xiz-2), c                                        ; FCC5FA  be fe 43
	ld H,C                                               ; FCC5FD  cb 8e
.LFCC5FF:
	ld C,H                                               ; FCC5FF  ce 8b
	extz BC                                              ; FCC601  d9 12
	sll bc, 0x01                                         ; FCC603  d9 ee 01
	inc 1,BC                                             ; FCC606  d9 61
	ld (xiz-4), bc                                       ; FCC608  be fc 51
	ld wa, (xiz-8)                                       ; FCC60B  9e f8 20
	extz XWA                                             ; FCC60E  e8 12
	ld	l, (xwa+bc)                                  ; FCC610  c3 07 e0 e4 27
	cp	l, (xiz-2)                                   ; FCC615  8e fe f7
	jr z, .LFCC653                                       ; FCC618  66 39
	ld DE,BC                                             ; FCC61A  d9 8a
	ldfr_berp l, 0xf4                                      ; FCC61C  c7 f4 9f   ld IYL,L
	extz IY                                              ; FCC61F  dd 12
	ld (xiz-10), iy                                      ; FCC621  be f6 55
	sll iy, 0x02                                         ; FCC624  dd ee 02
	sub	iy, (xiz-10)                                 ; FCC627  9e f6 a5
	inc 1,IY                                             ; FCC62A  dd 61
	ld wa, (xiz-6)                                       ; FCC62C  9e fa 20
	extz XWA                                             ; FCC62F  e8 12
	ld	c, (xwa+iy)                                  ; FCC631  c3 07 e0 f4 23
	cp C,(XIZ+0x14)                                      ; FCC636  8e 14 f3
	jr nz, .LFCC647                                      ; FCC639  6e 0c
	ld bc, (xiz-8)                                       ; FCC63B  9e f8 21
	extz XBC                                             ; FCC63E  e9 12
	ld	h, (xbc+de)                                  ; FCC640  c3 07 e4 e8 26
	jr .LFCC653                                          ; FCC645  68 0c
.LFCC647:
	ld bc, (xiz-8)                                       ; FCC647  9e f8 21
	extz XBC                                             ; FCC64A  e9 12
	ld	h, (xbc+de)                                  ; FCC64C  c3 07 e4 e8 26
	jr .LFCC5FF                                          ; FCC651  68 ac
.LFCC653:
	ld C,H                                               ; FCC653  ce 8b
	extz BC                                              ; FCC655  d9 12
	ld WA,BC                                             ; FCC657  d9 88
	pop XIX                                              ; FCC659  5c
	popw de                                              ; FCC65A  4a
	popw hl                                              ; FCC65B  4b
	unlk XIZ                                             ; FCC65C  ee 0d
	ret                                                  ; FCC65E  0e
	link XIZ,0xfff0                                      ; FCC65F  ee 0c f0 ff
	pushw hl                                             ; FCC663  2b
	pushw de                                             ; FCC664  2a
	push XIX                                             ; FCC665  3c
	lda xix, (xiz+0x08)                                  ; FCC666  be 08 34
	ld BC,(XIX)                                          ; FCC669  94 21
	ld (xiz-10), bc                                      ; FCC66B  be f6 51
	ld WA,(XIX+0x02)                                     ; FCC66E  9c 02 20
	ld (xiz-12), wa                                      ; FCC671  be f4 50
	ld XIY,(XIX+0x04)                                    ; FCC674  ac 04 25
	ld (xiz-16), xiy                                     ; FCC677  be f0 65
	ld BC,(XIZ+0x12)                                     ; FCC67A  9e 12 21
	extz BC                                              ; FCC67D  d9 12
	extz XBC                                             ; FCC67F  e9 12
	add XIY,XBC                                          ; FCC681  e9 85
	ld C,(XIY)                                           ; FCC683  85 23
	ld (xiz-8), c                                        ; FCC685  be f8 43
	ld H,C                                               ; FCC688  cb 8e
	ld B,(XIZ+0x16)                                      ; FCC68A  8e 16 22
	ld (xiz-2), b                                        ; FCC68D  be fe 42
	ld C,(XIZ+0x15)                                      ; FCC690  8e 15 23
	ld (xiz-4), c                                        ; FCC693  be fc 43
	ld C,(XIZ+0x14)                                      ; FCC696  8e 14 23
	ld (xiz-6), c                                        ; FCC699  be fa 43
.LFCC69C:
	ld C,H                                               ; FCC69C  ce 8b
	extz BC                                              ; FCC69E  d9 12
	ld DE,BC                                             ; FCC6A0  d9 8a
	sll bc, 0x01                                         ; FCC6A2  d9 ee 01
	inc 1,BC                                             ; FCC6A5  d9 61
	ld wa, (xiz-12)                                      ; FCC6A7  9e f4 20
	extz XWA                                             ; FCC6AA  e8 12
	ld	l, (xwa+bc)                                  ; FCC6AC  c3 07 e0 e4 27
	cp	l, (xiz-8)                                   ; FCC6B1  8e f8 f7
	jrl z, .LFCC740                                      ; FCC6B4  76 89 00
	ldfr_berp l, 0xf4                                      ; FCC6B7  c7 f4 9f   ld IYL,L
	extz IY                                              ; FCC6BA  dd 12
	ld (xiz-14), iy                                      ; FCC6BC  be f2 55
	sll iy, 0x01                                         ; FCC6BF  dd ee 01
	ld (xiz-16), iy                                      ; FCC6C2  be f0 55
	ld bc, (xiz-14)                                      ; FCC6C5  9e f2 21
	sll bc, 0x03                                         ; FCC6C8  d9 ee 03
	sub BC,IY                                            ; FCC6CB  dd a1
	inc 2,BC                                             ; FCC6CD  d9 62
	ld wa, (xiz-10)                                      ; FCC6CF  9e f6 20
	extz XWA                                             ; FCC6D2  e8 12
	ld	c, (xwa+bc)                                  ; FCC6D4  c3 07 e0 e4 23
	cp	c, (xiz-2)                                   ; FCC6D9  8e fe f3
	jr nz, .LFCC72A                                      ; FCC6DC  6e 4c
	ld BC,DE                                             ; FCC6DE  da 89
	add BC,DE                                            ; FCC6E0  da 81
	inc 1,BC                                             ; FCC6E2  d9 61
	ld wa, (xiz-12)                                      ; FCC6E4  9e f4 20
	extz XWA                                             ; FCC6E7  e8 12
	ld	l, (xwa+bc)                                  ; FCC6E9  c3 07 e0 e4 27
	ld C,L                                               ; FCC6EE  cf 8b
	extz BC                                              ; FCC6F0  d9 12
	ld (xiz-14), bc                                      ; FCC6F2  be f2 51
	ld DE,BC                                             ; FCC6F5  d9 8a
	sll de, 0x01                                         ; FCC6F7  da ee 01
	sll bc, 0x03                                         ; FCC6FA  d9 ee 03
	sub BC,DE                                            ; FCC6FD  da a1
	inc 1,BC                                             ; FCC6FF  d9 61
	ld wa, (xiz-10)                                      ; FCC701  9e f6 20
	extz XWA                                             ; FCC704  e8 12
	ld	c, (xwa+bc)                                  ; FCC706  c3 07 e0 e4 23
	cp	c, (xiz-4)                                   ; FCC70B  8e fc f3
	jr nz, .LFCC72A                                      ; FCC70E  6e 1a
	ld BC,DE                                             ; FCC710  da 89
	sll bc, 0x02                                         ; FCC712  d9 ee 02
	sub BC,DE                                            ; FCC715  da a1
	ld wa, (xiz-10)                                      ; FCC717  9e f6 20
	extz XWA                                             ; FCC71A  e8 12
	ld	c, (xwa+bc)                                  ; FCC71C  c3 07 e0 e4 23
	cp	c, (xiz-6)                                   ; FCC721  8e fa f3
	jr nz, .LFCC72A                                      ; FCC724  6e 04
	ld H,L                                               ; FCC726  cf 8e
	jr .LFCC740                                          ; FCC728  68 16
.LFCC72A:
	ld C,H                                               ; FCC72A  ce 8b
	extz BC                                              ; FCC72C  d9 12
	sll bc, 0x01                                         ; FCC72E  d9 ee 01
	inc 1,BC                                             ; FCC731  d9 61
	ld wa, (xiz-12)                                      ; FCC733  9e f4 20
	extz XWA                                             ; FCC736  e8 12
	ld	h, (xwa+bc)                                  ; FCC738  c3 07 e0 e4 26
	jrl .LFCC69C                                         ; FCC73D  78 5c ff
.LFCC740:
	ld C,H                                               ; FCC740  ce 8b
	extz BC                                              ; FCC742  d9 12
	ld WA,BC                                             ; FCC744  d9 88
	pop XIX                                              ; FCC746  5c
	popw de                                              ; FCC747  4a
	popw hl                                              ; FCC748  4b
	unlk XIZ                                             ; FCC749  ee 0d
	ret                                                  ; FCC74B  0e
	link XIZ,0xfff0                                      ; FCC74C  ee 0c f0 ff
	pushw hl                                             ; FCC750  2b
	pushw de                                             ; FCC751  2a
	push XIX                                             ; FCC752  3c
	ld BC,(XIZ+0x08)                                     ; FCC753  9e 08 21
	extz BC                                              ; FCC756  d9 12
	extz XBC                                             ; FCC758  e9 12
	add XBC,.LFD0500                                   ; FCC75A  e9 c8 00 05 fd 00
	ld L,(XBC)                                           ; FCC760  81 27
	ldw	(xiz-6), 0x0000                              ; FCC762  be fa 02 00 00
	ld BC,(XIZ+0x0e)                                     ; FCC767  9e 0e 21
	extz BC                                              ; FCC76A  d9 12
	ld (xiz-4), bc                                       ; FCC76C  be fc 51
	ld WA,(XIZ+0x10)                                     ; FCC76F  9e 10 20
	extz WA                                              ; FCC772  d8 12
	ld (xiz-2), wa                                       ; FCC774  be fe 50
	ld DE,WA                                             ; FCC777  d8 8a
	dec 1,WA                                             ; FCC779  d8 69
	ld DE,WA                                             ; FCC77B  d8 8a
	extz XBC                                             ; FCC77D  e9 12
	ld XIX,XBC                                           ; FCC77F  e9 8c
	sll xbc, 0x01                                        ; FCC781  e9 ee 01
	ld (xiz-14), xbc                                     ; FCC784  be f2 61
	ld XIY,XIX                                           ; FCC787  ec 8d
	sll xiy, 0x03                                        ; FCC789  ed ee 03
	sub XIY,XBC                                          ; FCC78C  e9 a5
	ld (xiz-10), xiy                                     ; FCC78E  be f6 65
.LFCC791:
	ld bc, (xiz-4)                                       ; FCC791  9e fc 21
	cp	bc, (xiz-2)                                  ; FCC794  9e fe f1
	jrl nc, .LFCC839                                     ; FCC797  7f 9f 00
	ld xix, (xiz-10)                                     ; FCC79A  ae f6 24
	ld XWA,(XIZ+0x0a)                                    ; FCC79D  ae 0a 20
	add XWA,XIX                                          ; FCC7A0  ec 80
	ld H,(XWA)                                           ; FCC7A2  80 26
	cp H,0xff                                            ; FCC7A4  ce cf ff
	jr z, .LFCC803                                       ; FCC7A7  66 5a
	ld W,H                                               ; FCC7A9  ce 88
	or W,0x90                                            ; FCC7AB  c8 ce 90
	ld (xiz-12), w                                       ; FCC7AE  be f4 40
	ld iy, (xiz-6)                                       ; FCC7B1  9e fa 25
	extz XIY                                             ; FCC7B4  ed 12
	sll xiy, 0x02                                        ; FCC7B6  ed ee 02
	ld (xiz-16), xiy                                     ; FCC7B9  be f0 65
	add XIY,0x0060237e                                   ; FCC7BC  ed c8 7e 23 60 00
	ld (XIY),W                                           ; FCC7C2  b5 40
	ld xbc, (xiz-16)                                     ; FCC7C4  ae f0 21
	inc 1,XBC                                            ; FCC7C7  e9 61
	add XBC,0x0060237e                                   ; FCC7C9  e9 c8 7e 23 60 00
	ld A,(XIZ+0x08)                                      ; FCC7CF  8e 08 21
	ld (XBC),A                                           ; FCC7D2  b1 41
	ld XBC,XIX                                           ; FCC7D4  ec 89
	inc 2,XBC                                            ; FCC7D6  e9 62
	add XBC,(XIZ+0x0a)                                   ; FCC7D8  ae 0a 81
	ld H,(XBC)                                           ; FCC7DB  81 26
	ld xbc, (xiz-16)                                     ; FCC7DD  ae f0 21
	inc 2,XBC                                            ; FCC7E0  e9 62
	add XBC,0x0060237e                                   ; FCC7E2  e9 c8 7e 23 60 00
	ld (XBC),H                                           ; FCC7E8  b1 46
	ld XBC,XIX                                           ; FCC7EA  ec 89
	inc 3,XBC                                            ; FCC7EC  e9 63
	add XBC,(XIZ+0x0a)                                   ; FCC7EE  ae 0a 81
	ld H,(XBC)                                           ; FCC7F1  81 26
	ld xbc, (xiz-16)                                     ; FCC7F3  ae f0 21
	inc 3,XBC                                            ; FCC7F6  e9 63
	add XBC,0x0060237e                                   ; FCC7F8  e9 c8 7e 23 60 00
	ld (XBC),H                                           ; FCC7FE  b1 46
	incw 0x01, (xiz-6)                                   ; FCC800  9e fa 61
.LFCC803:
	cpw	(xiz-6), 0x0006                              ; FCC803  9e fa 3f 06 00
	jr z, .LFCC811                                       ; FCC808  66 07
	ld bc, (xiz-4)                                       ; FCC80A  9e fc 21
	cp BC,DE                                             ; FCC80D  da f1
	jr nz, .LFCC82C                                      ; FCC80F  6e 1b
.LFCC811:
	lda xbc, (0x60237e:24)                               ; FCC811  f2 7e 23 60 31
	push XBC                                             ; FCC816  39
	ld iy, (xiz-6)                                       ; FCC817  9e fa 25
	sll iy, 0x02                                         ; FCC81A  dd ee 02
	pushw iy                                             ; FCC81D  2d
	pushw 0x00                                           ; FCC81E  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCC821  1d d4 0e f4
	ldw	(xiz-6), 0x0000                              ; FCC825  be fa 02 00 00
	inc 8,XSP                                            ; FCC82A  ef 60
.LFCC82C:
	sub XBC,XBC                                          ; FCC82C  e9 a1
	inc 6,XBC                                            ; FCC82E  e9 66
	add (xiz-10), xbc                                    ; FCC830  ae f6 89
	incw 0x01, (xiz-4)                                   ; FCC833  9e fc 61
	jrl .LFCC791                                         ; FCC836  78 58 ff
.LFCC839:
	ld C,L                                               ; FCC839  cf 8b
	extz BC                                              ; FCC83B  d9 12
	sll bc, 0x01                                         ; FCC83D  d9 ee 01
	inc 1,BC                                             ; FCC840  d9 61
	extz XBC                                             ; FCC842  e9 12
	ld A,(XBC+0x4308)                                    ; FCC844  c3 e5 08 43 21
	cp A,L                                               ; FCC849  cf f1
	jr nz, .LFCC879                                      ; FCC84B  6e 2c
	ld (0x60237e:24), 0xb0                             ; FCC84D  f2 7e 23 60 00 b0
	ld C,(XIZ+0x08)                                      ; FCC853  8e 08 23
	ld (0x60237f:24), c                                 ; FCC856  f2 7f 23 60 43
	ld (0x602380:24), 0x7b                             ; FCC85B  f2 80 23 60 00 7b
	ld (0x602381:24), 0x00                             ; FCC861  f2 81 23 60 00 00
	lda xbc, (0x60237e:24)                               ; FCC867  f2 7e 23 60 31
	push XBC                                             ; FCC86C  39
	pushw 0x04                                           ; FCC86D  0b 04 00
	pushw 0x00                                           ; FCC870  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FCC873  1d d4 0e f4
	inc 8,XSP                                            ; FCC877  ef 60
.LFCC879:
	pop XIX                                              ; FCC879  5c
	popw de                                              ; FCC87A  4a
	popw hl                                              ; FCC87B  4b
	unlk XIZ                                             ; FCC87C  ee 0d
	ret                                                  ; FCC87E  0e

; 0xFCC87F-0xFCEFFF -- 10113 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 10113, 1, 0x0E
