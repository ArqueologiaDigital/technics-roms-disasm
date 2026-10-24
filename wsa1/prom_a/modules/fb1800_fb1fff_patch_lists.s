; PatchLists_ApplyAll -- "the T_F40840 entry routine" the PatchList_Apply* headers name: when (0x2744) is 0,
;          snapshot the parameter image and apply each patch list for index 0.
PatchLists_ApplyAll:
	push XIX
	lda xix, (0x2744:16)
	ld C,(XIX)
	cp c, 0x01:i3
	jr nc, .LFB1877
	ld C,(XIX)
	cp c, 0x00:i3
	jr z, .LFB181D
	push XDE
	push XHL
	push XIX
	push XIZ
	call T_ParamImage_SnapshotAll
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
.LFB181D:
	ld C,(XIX)
	extz BC
	pushw bc
	calr PatchList_ApplyRecordField0C
	ld C,(XIX)
	extz BC
	pushw bc
	calr PatchList_ApplyRecordBytes2B
	ld C,(XIX)
	extz BC
	pushw bc
	calr PatchList_ApplyGlobals7F32
	ld C,(XIX)
	extz BC
	pushw bc
	calr .LFB19C7
	ld c, (0x60f01f:24)
	and C,0x01
	inc 8,XSP
	jr nz, .LFB1866
	or	(Disk_Flags:16), 0x18
	push XDE
	push XHL
	push XIX
	push XIZ
	call T_ParamImage_QueueDiffAll
	call T_Queue2C00_DrainPassAB
	call T_UiEventList_Publish
	call T_Queue2C00_DrainPassAB
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
.LFB1866:
	ld C,(XIX)
	extz BC
	pushw bc
	calr .LFB19E7
	ld C,(XIX)
	extz BC
	pushw bc
	calr .LFB19E6
	pop XIY
.LFB1877:
	pop XIX
	ret
; PatchList_ApplyGlobals7F32 -- apply PatchList_Globals7F32: for each of its 11
; (address, and, or) records, (*address & and) | or.  Arg (XIZ+8) = the table
; index (0 is the only one; see the list's header).  Called by the T_F40840
; entry routine (0xFB1800).
PatchList_ApplyGlobals7F32:
	link XIZ,0xfff6
	pushw hl
	pushw de
	push XIX
	ld c, 0x04:opc
	mul	bc, (xiz+8)
	extz XBC
	add XBC,PatchList_Globals7F32_Ptr
	ld XBC,(XBC)
	ld XIX,XBC
	ldw de, 0x00
	ld h, 0x0b:opc
.LFB1896:
	ld (xiz-2), de
	ld bc, (xiz-2)
	extz XBC
	ld (xiz-6), xbc
	add XBC,XIX
	ld XWA,(XBC)
	ld (xiz-10), xwa
	ld xbc, (xiz-6)
	inc 4,XBC
	add XBC,XIX
	ld A,(XBC)
	ld xbc, (xiz-10)
	and (XBC),A
	ld xbc, (xiz-10)
	ld L,(XBC)
	ld xwa, (xiz-6)
	inc 5,XWA
	add XWA,XIX
	ld C,(XWA)
	or C,L
	ld L,C
	ld xbc, (xiz-10)
	ld (XBC),L
	ld de, (xiz-2)
	inc 6,DE
	dec 1,H
	cp h, 0x00:i3
	jr nz, .LFB1896
	pop XIX
	popw de
	popw hl
	unlk XIZ
	ret
; PatchList_ApplyRecordField0C -- apply PatchList_RecordField0C: for each of its
; 32 records, *addr = (*addr & 0xF8) | b4 and *(addr+1) = b5.  Arg (XIZ+8) = the
; table index (only 0).  Called by the T_F40840 entry routine.
PatchList_ApplyRecordField0C:
	link XIZ,0xfff2
	pushw hl
	pushw de
	push XIX
	ld c, 0x04:opc
	mul	bc, (xiz+8)
	extz XBC
	add XBC,PatchList_RecordField0C_Ptr
	ld XBC,(XBC)
	ld XIX,XBC
	ldw de, 0x00
	ld h, 0x20:opc
.LFB18FB:
	ld (xiz-2), de
	ld bc, (xiz-2)
	extz XBC
	ld (xiz-6), xbc
	add XBC,XIX
	ld XWA,(XBC)
	ld (xiz-10), xwa
	and (XWA),0xf8
	ld xbc, (xiz-10)
	ld L,(XBC)
	ld xwa, (xiz-6)
	inc 4,XWA
	add XWA,XIX
	ld C,(XWA)
	or C,L
	ld L,C
	ld xbc, (xiz-10)
	ld (XBC),L
	ld xbc, (xiz-10)
	inc 1,XBC
	ld (xiz-14), xbc
	ld xwa, (xiz-6)
	inc 5,XWA
	add XWA,XIX
	ld C,(XWA)
	ld L,C
	ld xbc, (xiz-14)
	ld (XBC),L
	ld de, (xiz-2)
	inc 6,DE
	dec 1,H
	cp h, 0x00:i3
	jr nz, .LFB18FB
	pop XIX
	popw de
	popw hl
	unlk XIZ
	ret
; PatchList_ApplyRecordBytes2B -- apply PatchList_RecordBytes2B: for each of its
; 32 entries, 12 consecutive bytes from the entry's address get (*p & and) | or.
; Arg (XIZ+8) = the table index (only 0).  Called by the T_F40840 entry routine.
PatchList_ApplyRecordBytes2B:
	link XIZ,0xfff0
	pushw hl
	pushw de
	push XIX
	ld c, 0x04:opc
	mul	bc, (xiz+8)
	extz XBC
	add XBC,PatchList_RecordBytes2B_Ptr
	ld XBC,(XBC)
	ld (xiz-12), xbc
	sub XWA,XWA
	ld (xiz-4), xwa
	ld l, 0x20:opc
.LFB1970:
	ld xbc, (xiz-4)
	ld (xiz-16), xbc
	ld xix, (xiz-12)
	add XBC,XIX
	ld XWA,(XBC)
	ld XIX,XWA
	ld xbc, (xiz-16)
	inc 4,XBC
	add	xbc, (xiz-12)
	ld (xiz-8), xbc
	ld h, 0x0c:opc
.LFB198C:
	ld xbc, (xiz-8)
	ld A,(XBC)
	and (XIX),A
	ld D,(XIX)
	ld xbc, (xiz-8)
	inc 1,XBC
	ld (xiz-16), xbc
	ld A,(XBC)
	or A,D
	ld (XIX),A
	ld xbc, (xiz-16)
	inc 1,XBC
	ld (xiz-8), xbc
	inc 1,XIX
	dec 1,H
	cp h, 0x00:i3
	jr nz, .LFB198C
	ld XWA,0x0000001c
	add (xiz-4), xwa
	dec 1,L
	cp l, 0x00:i3
	jr nz, .LFB1970
	pop XIX
	popw de
	popw hl
	unlk XIZ
	ret
.LFB19C7:
	link XIZ,0x0000
	push XIX
	lda xix, (0x7f4a:16)
	extz XIX
	and (XIX+0x03),0xf8
	cp (XIZ+0x08),0x00
	jr nz, .LFB19E2
	extz XIX
	or	(xix+3), 0x04
.LFB19E2:
	pop XIX
	unlk XIZ
	ret
.LFB19E6:
	ret
.LFB19E7:
	ret
	ld c, (0x60f01f:24)
	and C,0x01
	jr nz, .LFB1A04
	push XDE
	push XHL
	push XIX
	push XIZ
	call T_ParamImage_SanitizeAll_Entry
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
	calr .LFB1A05
	calr .LFB1A06
.LFB1A04:
	ret
.LFB1A05:
	ret
.LFB1A06:
	ret
	link XIZ,0x0000
	push XIX
	ld XIX,(XIZ+0x08)
	ld C,(XIX)
	ld (0x60f080:24), c
	ld A,(XIX+0x01)
	ld (0x60f081:24), a
	ld B,(XIX+0x02)
	ld (0x60f082:24), b
	ld W,(XIX+0x03)
	ld (0x60f083:24), w
	push XDE
	push XHL
	push XIX
	push XIZ
	call T_Queue2C00_PublishStagedDrainPassB
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
	pop XIX
	unlk XIZ
	ret
; ---------------------------------------------------------------------
; 0xFB1A3E-0xFB1ECB -- THREE AND/OR RAM PATCH LISTS, each followed by the
; one-entry pointer table its routine reads (notes/proma-2026-09-25/
; gen_patchlists.py re-derives every count and address below from the ROM)
;
; The module entered through T_F40840 (0xFB1800) calls each routine with the
; byte (0x2744), which it has already bounded to 0 (`cp C,1 / jr nc` leaves);
; each routine does `ld C,4 / mul BC,(XIZ+8) / add XBC,<table> / ld XBC,(XBC)`
; and walks the list that pointer names.  So one entry per table, from the
; bound.  The addresses in the second and third lists are +0x0C and +0x2B of
; the 32 64-byte RAM records at 0x76A2 (RecordPtrs_RAM76A2's array, with the
; same single 0x80 step after record 7); the first list patches 0x7F32-0x7F3C.
; What the patched fields MEAN is not claimed.
; ---------------------------------------------------------------------

; PatchList_Globals7F32 -- 11 x (address32, and8, or8): (*addr & and) | or.
; Applied by PatchList_ApplyGlobals7F32 (`ld H,0x0B` at 0xFB1894: 11 records,
; stride 6).
PatchList_Globals7F32:
	.long 0x00007f32                              ; FB1A3E  RAM 0x7F32
	.byte 0x80, 0x00                                  ; FB1A42  and, or
	.long 0x00007f33                              ; FB1A44  RAM 0x7F33
	.byte 0xf7, 0x00                                  ; FB1A48  and, or
	.long 0x00007f34                              ; FB1A4A  RAM 0x7F34
	.byte 0xe3, 0x00                                  ; FB1A4E  and, or
	.long 0x00007f35                              ; FB1A50  RAM 0x7F35
	.byte 0x00, 0x00                                  ; FB1A54  and, or
	.long 0x00007f36                              ; FB1A56  RAM 0x7F36
	.byte 0x1f, 0x00                                  ; FB1A5A  and, or
	.long 0x00007f37                              ; FB1A5C  RAM 0x7F37
	.byte 0xc0, 0x06                                  ; FB1A60  and, or
	.long 0x00007f38                              ; FB1A62  RAM 0x7F38
	.byte 0x00, 0xff                                  ; FB1A66  and, or
	.long 0x00007f39                              ; FB1A68  RAM 0x7F39
	.byte 0x00, 0xff                                  ; FB1A6C  and, or
	.long 0x00007f3a                              ; FB1A6E  RAM 0x7F3A
	.byte 0x40, 0x3f                                  ; FB1A72  and, or
	.long 0x00007f3b                              ; FB1A74  RAM 0x7F3B
	.byte 0x18, 0x81                                  ; FB1A78  and, or
	.long 0x00007f3c                              ; FB1A7A  RAM 0x7F3C
	.byte 0x40, 0xbf                                  ; FB1A7E  and, or

; PatchList_Globals7F32_Ptr -- the one-entry table PatchList_ApplyGlobals7F32 indexes
; with `add XBC,0x00FB1A80` at 0xFB1887; see the block header for the bound.
PatchList_Globals7F32_Ptr:
	.long PatchList_Globals7F32                 ; FB1A80

; PatchList_RecordField0C -- 32 x (address32, b4, b5): *addr = (*addr & 0xF8) | b4,
; then *(addr+1) = b5.  Applied by PatchList_ApplyRecordField0C (`ld H,0x20`
; at 0xFB18F9).
; Every address is +0x0C of RAM record k (0x76A2 + 0x40*k, +0x40 past k = 7) and
; b5 = k.  +0x0D is the record's MIDI-channel byte (MidiIn_BuildChannelRouteTable;
; see ParamNumber_RecordPtrs's header; that routine matches it masked with
; 0x1F), so applying this list gives part k channel k, for k = 0..31.
PatchList_RecordField0C:
	.long 0x000076ae                              ; FB1A84  record  0 +0x0C
	.byte 0x00, 0x00                                  ; FB1A88  b4, b5
	.long 0x000076ee                              ; FB1A8A  record  1 +0x0C
	.byte 0x00, 0x01                                  ; FB1A8E  b4, b5
	.long 0x0000772e                              ; FB1A90  record  2 +0x0C
	.byte 0x00, 0x02                                  ; FB1A94  b4, b5
	.long 0x0000776e                              ; FB1A96  record  3 +0x0C
	.byte 0x00, 0x03                                  ; FB1A9A  b4, b5
	.long 0x000077ae                              ; FB1A9C  record  4 +0x0C
	.byte 0x00, 0x04                                  ; FB1AA0  b4, b5
	.long 0x000077ee                              ; FB1AA2  record  5 +0x0C
	.byte 0x00, 0x05                                  ; FB1AA6  b4, b5
	.long 0x0000782e                              ; FB1AA8  record  6 +0x0C
	.byte 0x00, 0x06                                  ; FB1AAC  b4, b5
	.long 0x0000786e                              ; FB1AAE  record  7 +0x0C
	.byte 0x00, 0x07                                  ; FB1AB2  b4, b5
	.long 0x000078ee                              ; FB1AB4  record  8 +0x0C
	.byte 0x00, 0x08                                  ; FB1AB8  b4, b5
	.long 0x0000792e                              ; FB1ABA  record  9 +0x0C
	.byte 0x00, 0x09                                  ; FB1ABE  b4, b5
	.long 0x0000796e                              ; FB1AC0  record 10 +0x0C
	.byte 0x00, 0x0a                                  ; FB1AC4  b4, b5
	.long 0x000079ae                              ; FB1AC6  record 11 +0x0C
	.byte 0x00, 0x0b                                  ; FB1ACA  b4, b5
	.long 0x000079ee                              ; FB1ACC  record 12 +0x0C
	.byte 0x00, 0x0c                                  ; FB1AD0  b4, b5
	.long 0x00007a2e                              ; FB1AD2  record 13 +0x0C
	.byte 0x00, 0x0d                                  ; FB1AD6  b4, b5
	.long 0x00007a6e                              ; FB1AD8  record 14 +0x0C
	.byte 0x00, 0x0e                                  ; FB1ADC  b4, b5
	.long 0x00007aae                              ; FB1ADE  record 15 +0x0C
	.byte 0x00, 0x0f                                  ; FB1AE2  b4, b5
	.long 0x00007aee                              ; FB1AE4  record 16 +0x0C
	.byte 0x00, 0x10                                  ; FB1AE8  b4, b5
	.long 0x00007b2e                              ; FB1AEA  record 17 +0x0C
	.byte 0x00, 0x11                                  ; FB1AEE  b4, b5
	.long 0x00007b6e                              ; FB1AF0  record 18 +0x0C
	.byte 0x00, 0x12                                  ; FB1AF4  b4, b5
	.long 0x00007bae                              ; FB1AF6  record 19 +0x0C
	.byte 0x00, 0x13                                  ; FB1AFA  b4, b5
	.long 0x00007bee                              ; FB1AFC  record 20 +0x0C
	.byte 0x00, 0x14                                  ; FB1B00  b4, b5
	.long 0x00007c2e                              ; FB1B02  record 21 +0x0C
	.byte 0x00, 0x15                                  ; FB1B06  b4, b5
	.long 0x00007c6e                              ; FB1B08  record 22 +0x0C
	.byte 0x00, 0x16                                  ; FB1B0C  b4, b5
	.long 0x00007cae                              ; FB1B0E  record 23 +0x0C
	.byte 0x00, 0x17                                  ; FB1B12  b4, b5
	.long 0x00007cee                              ; FB1B14  record 24 +0x0C
	.byte 0x00, 0x18                                  ; FB1B18  b4, b5
	.long 0x00007d2e                              ; FB1B1A  record 25 +0x0C
	.byte 0x00, 0x19                                  ; FB1B1E  b4, b5
	.long 0x00007d6e                              ; FB1B20  record 26 +0x0C
	.byte 0x00, 0x1a                                  ; FB1B24  b4, b5
	.long 0x00007dae                              ; FB1B26  record 27 +0x0C
	.byte 0x00, 0x1b                                  ; FB1B2A  b4, b5
	.long 0x00007dee                              ; FB1B2C  record 28 +0x0C
	.byte 0x00, 0x1c                                  ; FB1B30  b4, b5
	.long 0x00007e2e                              ; FB1B32  record 29 +0x0C
	.byte 0x00, 0x1d                                  ; FB1B36  b4, b5
	.long 0x00007e6e                              ; FB1B38  record 30 +0x0C
	.byte 0x00, 0x1e                                  ; FB1B3C  b4, b5
	.long 0x00007eae                              ; FB1B3E  record 31 +0x0C
	.byte 0x00, 0x1f                                  ; FB1B42  b4, b5

; PatchList_RecordField0C_Ptr -- one entry, read with `add XBC,0x00FB1B44` at 0xFB18EC.
;          See the block header for why there is one.
PatchList_RecordField0C_Ptr:
	.long PatchList_RecordField0C               ; FB1B44

; PatchList_RecordBytes2B -- 32 x (address32, then 12 x (and8, or8)), 28 bytes
; each: for the 12 bytes from the address, (*p & and) | or.  Applied by
; PatchList_ApplyRecordBytes2B (`ld L,0x20` at 0xFB196E entries, `ld H,0x0C` at
; 0xFB198A pairs, stride 0x1C).  Every address is +0x2B of RAM record k.
PatchList_RecordBytes2B:
	.long 0x000076cd                              ; FB1B48  record  0 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1B4C  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1B58  and, or x 6
	.long 0x0000770d                              ; FB1B64  record  1 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1B68  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1B74  and, or x 6
	.long 0x0000774d                              ; FB1B80  record  2 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1B84  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1B90  and, or x 6
	.long 0x0000778d                              ; FB1B9C  record  3 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1BA0  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1BAC  and, or x 6
	.long 0x000077cd                              ; FB1BB8  record  4 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1BBC  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1BC8  and, or x 6
	.long 0x0000780d                              ; FB1BD4  record  5 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1BD8  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1BE4  and, or x 6
	.long 0x0000784d                              ; FB1BF0  record  6 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1BF4  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1C00  and, or x 6
	.long 0x0000788d                              ; FB1C0C  record  7 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1C10  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1C1C  and, or x 6
	.long 0x0000790d                              ; FB1C28  record  8 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1C2C  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1C38  and, or x 6
	.long 0x0000794d                              ; FB1C44  record  9 +0x2B
	.byte 0x00, 0x9c, 0x40, 0xac, 0x18, 0x81, 0x40, 0xbf, 0x00, 0x9c, 0x40, 0xac  ; FB1C48  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0x9c, 0x40, 0xac, 0x18, 0x81, 0x40, 0xbf  ; FB1C54  and, or x 6
	.long 0x0000798d                              ; FB1C60  record 10 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1C64  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1C70  and, or x 6
	.long 0x000079cd                              ; FB1C7C  record 11 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1C80  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1C8C  and, or x 6
	.long 0x00007a0d                              ; FB1C98  record 12 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1C9C  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1CA8  and, or x 6
	.long 0x00007a4d                              ; FB1CB4  record 13 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1CB8  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1CC4  and, or x 6
	.long 0x00007a8d                              ; FB1CD0  record 14 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1CD4  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1CE0  and, or x 6
	.long 0x00007acd                              ; FB1CEC  record 15 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1CF0  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1CFC  and, or x 6
	.long 0x00007b0d                              ; FB1D08  record 16 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1D0C  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1D18  and, or x 6
	.long 0x00007b4d                              ; FB1D24  record 17 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1D28  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1D34  and, or x 6
	.long 0x00007b8d                              ; FB1D40  record 18 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1D44  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1D50  and, or x 6
	.long 0x00007bcd                              ; FB1D5C  record 19 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1D60  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1D6C  and, or x 6
	.long 0x00007c0d                              ; FB1D78  record 20 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1D7C  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1D88  and, or x 6
	.long 0x00007c4d                              ; FB1D94  record 21 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1D98  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1DA4  and, or x 6
	.long 0x00007c8d                              ; FB1DB0  record 22 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1DB4  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1DC0  and, or x 6
	.long 0x00007ccd                              ; FB1DCC  record 23 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1DD0  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1DDC  and, or x 6
	.long 0x00007d0d                              ; FB1DE8  record 24 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1DEC  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1DF8  and, or x 6
	.long 0x00007d4d                              ; FB1E04  record 25 +0x2B
	.byte 0x00, 0x9c, 0x40, 0xac, 0x18, 0x81, 0x40, 0xbf, 0x00, 0x9c, 0x40, 0xac  ; FB1E08  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0x9c, 0x40, 0xac, 0x18, 0x81, 0x40, 0xbf  ; FB1E14  and, or x 6
	.long 0x00007d8d                              ; FB1E20  record 26 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1E24  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1E30  and, or x 6
	.long 0x00007dcd                              ; FB1E3C  record 27 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1E40  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1E4C  and, or x 6
	.long 0x00007e0d                              ; FB1E58  record 28 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1E5C  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1E68  and, or x 6
	.long 0x00007e4d                              ; FB1E74  record 29 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1E78  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1E84  and, or x 6
	.long 0x00007e8d                              ; FB1E90  record 30 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1E94  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1EA0  and, or x 6
	.long 0x00007ecd                              ; FB1EAC  record 31 +0x2B
	.byte 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf  ; FB1EB0  and, or x 6
	.byte 0x18, 0x81, 0x40, 0xbf, 0x00, 0xff, 0x40, 0xbf, 0x18, 0x81, 0x40, 0xbf  ; FB1EBC  and, or x 6

; PatchList_RecordBytes2B_Ptr -- one entry, read with `add XBC,0x00FB1EC8` at 0xFB195E.
;          See the block header for why there is one.
PatchList_RecordBytes2B_Ptr:
	.long PatchList_RecordBytes2B               ; FB1EC8

; 0xFB1ECC-0xFB1FFF -- 308 bytes of 0x0E (RET), module padding (checked by
; gen_patchlists.py, not sampled).
	.fill 308, 1, 0x0E                                 ; FB1ECC
