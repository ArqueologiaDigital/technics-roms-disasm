
; PanelScreen_RequestRedrawIfFieldQueued -- set bit 4 of (0x2095) when a 0x2C00 record with a non-zero
; changed-bits byte names a {tag, offset} the current screen lists in ScreenFieldListPtrs
; Evidence: UiEventPassB_TailList[2] = T_PanelScreen_RequestRedrawIfFieldQueued = `jp 0xF99400`; runs only with bit 1 of (0x97) set and bit 3
; of (0x2673) clear; XHL = ScreenFieldListPtrs[(0x207C)]; each record's first word (skipped if +3 == 0) is
; compared with the list's words up to 0xFFFF; a match does `or (0x2095),0x10`; always `and (0x2673),0xD7`.
; Bit 4 of (0x2095) -> (0x2072) via PanelState_SyncScreenFlags, which PanelScreen_RunRedraw turns into a re-Enter.
PanelScreen_RequestRedrawIfFieldQueued:
	bit	1, (0x97:8)                                   ; F99400  f0 97 c9
	jr z, .LF99459                                       ; F99403  66 54
	bit	3, (0x2673:16)                               ; F99405  f1 73 26 cb
	jr nz, .LF99459                                      ; F99409  6e 4e
	ld l, (UI_ScreenId:16)                                   ; F9940B  c1 7c 20 27
	xor H,H                                              ; F9940F  ce d6
	sla hl, 0x02                                         ; F99411  db ec 02
	ld XIY,ScreenFieldListPtrs                           ; F99414  45 00 d0 f2 00
	ld	xhl, (xiy+hl)                                ; F99419  e3 07 f4 ec 23
	cp (XHL),0xff                                        ; F9941E  83 3f ff
	jr z, .LF99459                                       ; F99421  66 36
	xor IX,IX                                            ; F99423  dc d4
	ld XIY,0x00002c00                                    ; F99425  45 00 2c 00 00
.LF9942A:
	ld WA,(XIY)                                          ; F9942A  95 20
	cp A,0xff                                            ; F9942C  c9 cf ff
	jr z, .LF99459                                       ; F9942F  66 28
	cp (XIY+0x03),0x00                                   ; F99431  8d 03 3f 00
	jr z, .LF9944A                                       ; F99435  66 13
.LF99437:
	ld	bc, (xhl+ix)                                 ; F99437  d3 07 ec f0 21
	cp BC,0xffff                                         ; F9943C  d9 cf ff ff
	jr z, .LF9944A                                       ; F99440  66 08
	cp BC,WA                                             ; F99442  d8 f1
	jr z, .LF99454                                       ; F99444  66 0e
	inc 2,IX                                             ; F99446  dc 62
	jr .LF99437                                          ; F99448  68 ed
.LF9944A:
	add XIY,0x00000004                                   ; F9944A  ed c8 04 00 00 00
	xor IX,IX                                            ; F99450  dc d4
	jr .LF9942A                                          ; F99452  68 d6
.LF99454:
	or	(UI_ScreenFlags:16), 0x10                            ; F99454  c1 95 20 3e 10
.LF99459:
	and	(0x2673:16), 0xd7                            ; F99459  c1 73 26 3c d7
	ret                                                  ; F9945E  0e

; 0xF9945F-0xF997FF -- 929 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 929, 1, 0x0E
