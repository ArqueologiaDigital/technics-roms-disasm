

; ==============================================================================
; 0xF84000-0xF842DE -- the BYTE RING-BUFFER CLASS: five operations, five sizes
; ==============================================================================
;
; Twenty-five routines that are five operations emitted once per ring capacity.
; Every one of them takes the ring in XHL and nothing else, and every one of
; them is a fixed byte template whose ONLY variable field is the wrap mask of
; its `minc1_16` (or, for Init, the seed of the free count).
;
; THE OBJECT.  XHL points at the ring's DATA.  The five control words sit BELOW
; that pointer, at negative 8-bit displacements:
;
;   (XHL-10)  scan cursor        \  the non-consuming reader
;   (XHL-6)   scan limit         /
;   (XHL-8)   read  cursor       \  the consuming reader
;   (XHL-4)   write cursor       /  and the writer
;   (XHL-2)   FREE BYTES remaining
;   (XHL+0) .. (XHL+capacity-1)  the data
;
; Evidence for each field, in the routines below:
;   -4  is the WRITE cursor: Put stores A at (XHL + (XHL-4)) and advances it.
;   -8  is the READ cursor:  Get loads A from (XHL + (XHL-8)) and advances it;
;       the IsEmpty veneer in every instance compares -8 against -4 directly.
;   -2  is FREE SPACE IN BYTES, not an occupancy: Init seeds it with
;       capacity-1, Put refuses when it is zero and decrements it, Get
;       increments it, and neither scan family touches it.  The seed being
;       capacity-1 and not capacity is why one slot of the ring is never used.
;   -10 is a SECOND cursor with its own limit at -6: the two scan families read
;       through it and never touch -2, so a scan does not consume.
;
; ★ TEN OF THE TWENTY-FIVE ARE DEAD.  The instance bank below uses only the
; 0x100, 0x200 and 0x400 capacities; the ten routines for 0x80 and 0x1000 have
; no reference anywhere in prom_a or prom_b, by absolute call/jp or by any
; PC-relative displacement.  Both statements are checks in
; notes/prom_a_ringbuf_map.py, and they are what a library emitted whole by a
; linker looks like.
;
; ★ AND NOTHING OUTSIDE THE BANK CALLS ANY OF THEM.  The class is reached only
; through the 165 veneers at 0xF842DF-0xF84C6B; also a check.
; ---------------------------------------------------------------------
; Ring_Get_0080 .. Ring_Get_1000 -- consuming read, one byte
;
; Called from: the instance bank's per-ring Get veneer, and nothing else.
; Inputs:  XHL = the ring.
; Outputs: WA = the byte read, W forced to 0 first so the result is a clean
;          0x00nn; WA = 0xFFFF when the ring is empty.  The read cursor is
;          advanced modulo the capacity and the free count incremented.
; Evidence: the empty test is `cp (XHL-8),(XHL-4)` -- read cursor against write
;          cursor -- and the byte is fetched with the register-indexed operand
;          `ld A,(XHL+IX)` after `ld IX,(XHL-8)`, so the cursor really is an
;          index into the data at XHL and not a pointer.
; The five, and the wrap mask that gives each its capacity:
;   0x80      0xF84000
;   0x100     0xF8401F
;   0x200     0xF8403E
;   0x400     0xF8405D
;   0x1000    0xF8407C
; ---------------------------------------------------------------------
Ring_Get_0080:
	ld w, 0x00:opc                                          ; F84000  20 00
	ld ix, (xhl-8)                                       ; F84002  9b f8 24
	cp	ix, (xhl-4)                                  ; F84005  9b fc f4
	jr nz, .LF8400F                                      ; F84008  6e 05
	ldw wa, 0xffff                                       ; F8400A  30 ff ff
	jr .LF8401E                                          ; F8400D  68 0f
.LF8400F:
	ld	a, (xhl+ix)                                  ; F8400F  c3 07 ec f0 21
	minc1_16 ix, 0x007f                                  ; F84014  dc 38 7f 00
	ld (xhl-8), ix                                       ; F84018  bb f8 54
	incw 0x01, (xhl-2)                                   ; F8401B  9b fe 61
.LF8401E:
	ret                                                  ; F8401E  0e
Ring_Get_0100:
	ld w, 0x00:opc                                          ; F8401F  20 00
	ld ix, (xhl-8)                                       ; F84021  9b f8 24
	cp	ix, (xhl-4)                                  ; F84024  9b fc f4
	jr nz, .LF8402E                                      ; F84027  6e 05
	ldw wa, 0xffff                                       ; F84029  30 ff ff
	jr .LF8403D                                          ; F8402C  68 0f
.LF8402E:
	ld	a, (xhl+ix)                                  ; F8402E  c3 07 ec f0 21
	minc1_16 ix, 0x00ff                                  ; F84033  dc 38 ff 00
	ld (xhl-8), ix                                       ; F84037  bb f8 54
	incw 0x01, (xhl-2)                                   ; F8403A  9b fe 61
.LF8403D:
	ret                                                  ; F8403D  0e
Ring_Get_0200:
	ld w, 0x00:opc                                          ; F8403E  20 00
	ld ix, (xhl-8)                                       ; F84040  9b f8 24
	cp	ix, (xhl-4)                                  ; F84043  9b fc f4
	jr nz, .LF8404D                                      ; F84046  6e 05
	ldw wa, 0xffff                                       ; F84048  30 ff ff
	jr .LF8405C                                          ; F8404B  68 0f
.LF8404D:
	ld	a, (xhl+ix)                                  ; F8404D  c3 07 ec f0 21
	minc1_16 ix, 0x01ff                                  ; F84052  dc 38 ff 01
	ld (xhl-8), ix                                       ; F84056  bb f8 54
	incw 0x01, (xhl-2)                                   ; F84059  9b fe 61
.LF8405C:
	ret                                                  ; F8405C  0e
Ring_Get_0400:
	ld w, 0x00:opc                                          ; F8405D  20 00
	ld ix, (xhl-8)                                       ; F8405F  9b f8 24
	cp	ix, (xhl-4)                                  ; F84062  9b fc f4
	jr nz, .LF8406C                                      ; F84065  6e 05
	ldw wa, 0xffff                                       ; F84067  30 ff ff
	jr .LF8407B                                          ; F8406A  68 0f
.LF8406C:
	ld	a, (xhl+ix)                                  ; F8406C  c3 07 ec f0 21
	minc1_16 ix, 0x03ff                                  ; F84071  dc 38 ff 03
	ld (xhl-8), ix                                       ; F84075  bb f8 54
	incw 0x01, (xhl-2)                                   ; F84078  9b fe 61
.LF8407B:
	ret                                                  ; F8407B  0e
Ring_Get_1000:
	ld w, 0x00:opc                                          ; F8407C  20 00
	ld ix, (xhl-8)                                       ; F8407E  9b f8 24
	cp	ix, (xhl-4)                                  ; F84081  9b fc f4
	jr nz, .LF8408B                                      ; F84084  6e 05
	ldw wa, 0xffff                                       ; F84086  30 ff ff
	jr .LF8409A                                          ; F84089  68 0f
.LF8408B:
	ld	a, (xhl+ix)                                  ; F8408B  c3 07 ec f0 21
	minc1_16 ix, 0x0fff                                  ; F84090  dc 38 ff 0f
	ld (xhl-8), ix                                       ; F84094  bb f8 54
	incw 0x01, (xhl-2)                                   ; F84097  9b fe 61
.LF8409A:
	ret                                                  ; F8409A  0e
; ---------------------------------------------------------------------
; Ring_Scan_0080 .. Ring_Scan_1000 -- NON-consuming read against the scan limit
;
; Called from: the instance bank's per-ring Scan veneer, and nothing else.
; Inputs:  XHL = the ring.
; Outputs: WA = the byte, or 0xFFFF when the scan cursor has reached the scan
;          limit.  (XHL-10) advanced modulo the capacity.
; Evidence: identical to Ring_Get except for the two words it names -- (XHL-10)
;          against (XHL-6) instead of (XHL-8) against (XHL-4) -- and for the
;          missing `incw 1,(XHL-2)`: this family never touches the free count,
;          which is what makes it non-consuming.  The templates are matched byte
;          for byte by notes/prom_a_ringbuf_map.py, with the cursor pair as the
;          only substituted field.
; Unknown: nothing in this module writes the scan limit at (XHL-6) except Init,
;          which zeroes it.  Its producer is outside the module.
; The five:
;   0x80      0xF8409B
;   0x100     0xF840B7
;   0x200     0xF840D3
;   0x400     0xF840EF
;   0x1000    0xF8410B
; ---------------------------------------------------------------------
Ring_Scan_0080:
	ld w, 0x00:opc                                          ; F8409B  20 00
	ld ix, (xhl-10)                                      ; F8409D  9b f6 24
	cp	ix, (xhl-6)                                  ; F840A0  9b fa f4
	jr nz, .LF840AA                                      ; F840A3  6e 05
	ldw wa, 0xffff                                       ; F840A5  30 ff ff
	jr .LF840B6                                          ; F840A8  68 0c
.LF840AA:
	ld	a, (xhl+ix)                                  ; F840AA  c3 07 ec f0 21
	minc1_16 ix, 0x007f                                  ; F840AF  dc 38 7f 00
	ld (xhl-10), ix                                      ; F840B3  bb f6 54
.LF840B6:
	ret                                                  ; F840B6  0e
Ring_Scan_0100:
	ld w, 0x00:opc                                          ; F840B7  20 00
	ld ix, (xhl-10)                                      ; F840B9  9b f6 24
	cp	ix, (xhl-6)                                  ; F840BC  9b fa f4
	jr nz, .LF840C6                                      ; F840BF  6e 05
	ldw wa, 0xffff                                       ; F840C1  30 ff ff
	jr .LF840D2                                          ; F840C4  68 0c
.LF840C6:
	ld	a, (xhl+ix)                                  ; F840C6  c3 07 ec f0 21
	minc1_16 ix, 0x00ff                                  ; F840CB  dc 38 ff 00
	ld (xhl-10), ix                                      ; F840CF  bb f6 54
.LF840D2:
	ret                                                  ; F840D2  0e
Ring_Scan_0200:
	ld w, 0x00:opc                                          ; F840D3  20 00
	ld ix, (xhl-10)                                      ; F840D5  9b f6 24
	cp	ix, (xhl-6)                                  ; F840D8  9b fa f4
	jr nz, .LF840E2                                      ; F840DB  6e 05
	ldw wa, 0xffff                                       ; F840DD  30 ff ff
	jr .LF840EE                                          ; F840E0  68 0c
.LF840E2:
	ld	a, (xhl+ix)                                  ; F840E2  c3 07 ec f0 21
	minc1_16 ix, 0x01ff                                  ; F840E7  dc 38 ff 01
	ld (xhl-10), ix                                      ; F840EB  bb f6 54
.LF840EE:
	ret                                                  ; F840EE  0e
Ring_Scan_0400:
	ld w, 0x00:opc                                          ; F840EF  20 00
	ld ix, (xhl-10)                                      ; F840F1  9b f6 24
	cp	ix, (xhl-6)                                  ; F840F4  9b fa f4
	jr nz, .LF840FE                                      ; F840F7  6e 05
	ldw wa, 0xffff                                       ; F840F9  30 ff ff
	jr .LF8410A                                          ; F840FC  68 0c
.LF840FE:
	ld	a, (xhl+ix)                                  ; F840FE  c3 07 ec f0 21
	minc1_16 ix, 0x03ff                                  ; F84103  dc 38 ff 03
	ld (xhl-10), ix                                      ; F84107  bb f6 54
.LF8410A:
	ret                                                  ; F8410A  0e
Ring_Scan_1000:
	ld w, 0x00:opc                                          ; F8410B  20 00
	ld ix, (xhl-10)                                      ; F8410D  9b f6 24
	cp	ix, (xhl-6)                                  ; F84110  9b fa f4
	jr nz, .LF8411A                                      ; F84113  6e 05
	ldw wa, 0xffff                                       ; F84115  30 ff ff
	jr .LF84126                                          ; F84118  68 0c
.LF8411A:
	ld	a, (xhl+ix)                                  ; F8411A  c3 07 ec f0 21
	minc1_16 ix, 0x0fff                                  ; F8411F  dc 38 ff 0f
	ld (xhl-10), ix                                      ; F84123  bb f6 54
.LF84126:
	ret                                                  ; F84126  0e
; ---------------------------------------------------------------------
; Ring_ScanToPut_0080 .. _1000 -- non-consuming read against the WRITE cursor
;
; Called from: the instance bank's per-ring ScanToPut veneer, and nothing else.
; Inputs:  XHL = the ring.
; Outputs: WA = the byte, or 0xFFFF when the scan cursor has caught up with the
;          write cursor.  (XHL-10) advanced modulo the capacity.
; Evidence: the third cursor pairing, and the only difference from Ring_Scan is
;          the second operand of the comparison: (XHL-4), the write cursor,
;          instead of (XHL-6).  So the ring offers a look-ahead reader that can
;          run either to a limit somebody else sets or all the way to live data.
; The five:
;   0x80      0xF84127
;   0x100     0xF84143
;   0x200     0xF8415F
;   0x400     0xF8417B
;   0x1000    0xF84197
; ---------------------------------------------------------------------
Ring_ScanToPut_0080:
	ld w, 0x00:opc                                          ; F84127  20 00
	ld ix, (xhl-10)                                      ; F84129  9b f6 24
	cp	ix, (xhl-4)                                  ; F8412C  9b fc f4
	jr nz, .LF84136                                      ; F8412F  6e 05
	ldw wa, 0xffff                                       ; F84131  30 ff ff
	jr .LF84142                                          ; F84134  68 0c
.LF84136:
	ld	a, (xhl+ix)                                  ; F84136  c3 07 ec f0 21
	minc1_16 ix, 0x007f                                  ; F8413B  dc 38 7f 00
	ld (xhl-10), ix                                      ; F8413F  bb f6 54
.LF84142:
	ret                                                  ; F84142  0e
Ring_ScanToPut_0100:
	ld w, 0x00:opc                                          ; F84143  20 00
	ld ix, (xhl-10)                                      ; F84145  9b f6 24
	cp	ix, (xhl-4)                                  ; F84148  9b fc f4
	jr nz, .LF84152                                      ; F8414B  6e 05
	ldw wa, 0xffff                                       ; F8414D  30 ff ff
	jr .LF8415E                                          ; F84150  68 0c
.LF84152:
	ld	a, (xhl+ix)                                  ; F84152  c3 07 ec f0 21
	minc1_16 ix, 0x00ff                                  ; F84157  dc 38 ff 00
	ld (xhl-10), ix                                      ; F8415B  bb f6 54
.LF8415E:
	ret                                                  ; F8415E  0e
Ring_ScanToPut_0200:
	ld w, 0x00:opc                                          ; F8415F  20 00
	ld ix, (xhl-10)                                      ; F84161  9b f6 24
	cp	ix, (xhl-4)                                  ; F84164  9b fc f4
	jr nz, .LF8416E                                      ; F84167  6e 05
	ldw wa, 0xffff                                       ; F84169  30 ff ff
	jr .LF8417A                                          ; F8416C  68 0c
.LF8416E:
	ld	a, (xhl+ix)                                  ; F8416E  c3 07 ec f0 21
	minc1_16 ix, 0x01ff                                  ; F84173  dc 38 ff 01
	ld (xhl-10), ix                                      ; F84177  bb f6 54
.LF8417A:
	ret                                                  ; F8417A  0e
Ring_ScanToPut_0400:
	ld w, 0x00:opc                                          ; F8417B  20 00
	ld ix, (xhl-10)                                      ; F8417D  9b f6 24
	cp	ix, (xhl-4)                                  ; F84180  9b fc f4
	jr nz, .LF8418A                                      ; F84183  6e 05
	ldw wa, 0xffff                                       ; F84185  30 ff ff
	jr .LF84196                                          ; F84188  68 0c
.LF8418A:
	ld	a, (xhl+ix)                                  ; F8418A  c3 07 ec f0 21
	minc1_16 ix, 0x03ff                                  ; F8418F  dc 38 ff 03
	ld (xhl-10), ix                                      ; F84193  bb f6 54
.LF84196:
	ret                                                  ; F84196  0e
Ring_ScanToPut_1000:
	ld w, 0x00:opc                                          ; F84197  20 00
	ld ix, (xhl-10)                                      ; F84199  9b f6 24
	cp	ix, (xhl-4)                                  ; F8419C  9b fc f4
	jr nz, .LF841A6                                      ; F8419F  6e 05
	ldw wa, 0xffff                                       ; F841A1  30 ff ff
	jr .LF841B2                                          ; F841A4  68 0c
.LF841A6:
	ld	a, (xhl+ix)                                  ; F841A6  c3 07 ec f0 21
	minc1_16 ix, 0x0fff                                  ; F841AB  dc 38 ff 0f
	ld (xhl-10), ix                                      ; F841AF  bb f6 54
.LF841B2:
	ret                                                  ; F841B2  0e
; ---------------------------------------------------------------------
; Ring_Put_0080 .. Ring_Put_1000 -- append one byte
;
; Called from: the instance bank's per-ring Put and PutBlock veneers, and
;          nothing else.
; Inputs:  XHL = the ring; A = the byte.
; Outputs: WA = the free count AFTER the store, or 0xFFFF when the ring was
;          full and nothing was written.  A full ring DROPS; it does not wrap
;          over live data.
; Evidence: the guard is `cp (XHL-2),0x0000` before anything else, and the
;          store is the register-indexed `ld (XHL+IX),A` with `ld IX,(XHL-4)`.
;          `decw 1,(XHL-2)` immediately after the cursor update is the exact
;          inverse of Ring_Get's `incw 1,(XHL-2)`, which is what makes the two
;          families one pair over one field.
; The five:
;   0x80      0xF841B3
;   0x100     0xF841D5
;   0x200     0xF841F7
;   0x400     0xF84219
;   0x1000    0xF8423B
; ---------------------------------------------------------------------
Ring_Put_0080:
	cpw	(xhl-2), 0x0000                              ; F841B3  9b fe 3f 00 00
	jr nz, .LF841BF                                      ; F841B8  6e 05
	ldw wa, 0xffff                                       ; F841BA  30 ff ff
	jr .LF841D4                                          ; F841BD  68 15
.LF841BF:
	ld ix, (xhl-4)                                       ; F841BF  9b fc 24
	ld	(xhl+ix), a                                  ; F841C2  f3 07 ec f0 41
	minc1_16 ix, 0x007f                                  ; F841C7  dc 38 7f 00
	ld (xhl-4), ix                                       ; F841CB  bb fc 54
	decm 0x01, (xhl-2)                                   ; F841CE  9b fe 69
	ld wa, (xhl-2)                                       ; F841D1  9b fe 20
.LF841D4:
	ret                                                  ; F841D4  0e
Ring_Put_0100:
	cpw	(xhl-2), 0x0000                              ; F841D5  9b fe 3f 00 00
	jr nz, .LF841E1                                      ; F841DA  6e 05
	ldw wa, 0xffff                                       ; F841DC  30 ff ff
	jr .LF841F6                                          ; F841DF  68 15
.LF841E1:
	ld ix, (xhl-4)                                       ; F841E1  9b fc 24
	ld	(xhl+ix), a                                  ; F841E4  f3 07 ec f0 41
	minc1_16 ix, 0x00ff                                  ; F841E9  dc 38 ff 00
	ld (xhl-4), ix                                       ; F841ED  bb fc 54
	decm 0x01, (xhl-2)                                   ; F841F0  9b fe 69
	ld wa, (xhl-2)                                       ; F841F3  9b fe 20
.LF841F6:
	ret                                                  ; F841F6  0e
Ring_Put_0200:
	cpw	(xhl-2), 0x0000                              ; F841F7  9b fe 3f 00 00
	jr nz, .LF84203                                      ; F841FC  6e 05
	ldw wa, 0xffff                                       ; F841FE  30 ff ff
	jr .LF84218                                          ; F84201  68 15
.LF84203:
	ld ix, (xhl-4)                                       ; F84203  9b fc 24
	ld	(xhl+ix), a                                  ; F84206  f3 07 ec f0 41
	minc1_16 ix, 0x01ff                                  ; F8420B  dc 38 ff 01
	ld (xhl-4), ix                                       ; F8420F  bb fc 54
	decm 0x01, (xhl-2)                                   ; F84212  9b fe 69
	ld wa, (xhl-2)                                       ; F84215  9b fe 20
.LF84218:
	ret                                                  ; F84218  0e
Ring_Put_0400:
	cpw	(xhl-2), 0x0000                              ; F84219  9b fe 3f 00 00
	jr nz, .LF84225                                      ; F8421E  6e 05
	ldw wa, 0xffff                                       ; F84220  30 ff ff
	jr .LF8423A                                          ; F84223  68 15
.LF84225:
	ld ix, (xhl-4)                                       ; F84225  9b fc 24
	ld	(xhl+ix), a                                  ; F84228  f3 07 ec f0 41
	minc1_16 ix, 0x03ff                                  ; F8422D  dc 38 ff 03
	ld (xhl-4), ix                                       ; F84231  bb fc 54
	decm 0x01, (xhl-2)                                   ; F84234  9b fe 69
	ld wa, (xhl-2)                                       ; F84237  9b fe 20
.LF8423A:
	ret                                                  ; F8423A  0e
Ring_Put_1000:
	cpw	(xhl-2), 0x0000                              ; F8423B  9b fe 3f 00 00
	jr nz, .LF84247                                      ; F84240  6e 05
	ldw wa, 0xffff                                       ; F84242  30 ff ff
	jr .LF8425C                                          ; F84245  68 15
.LF84247:
	ld ix, (xhl-4)                                       ; F84247  9b fc 24
	ld	(xhl+ix), a                                  ; F8424A  f3 07 ec f0 41
	minc1_16 ix, 0x0fff                                  ; F8424F  dc 38 ff 0f
	ld (xhl-4), ix                                       ; F84253  bb fc 54
	decm 0x01, (xhl-2)                                   ; F84256  9b fe 69
	ld wa, (xhl-2)                                       ; F84259  9b fe 20
.LF8425C:
	ret                                                  ; F8425C  0e
; ---------------------------------------------------------------------
; Ring_Init_0080 .. Ring_Init_1000 -- reset a ring to empty
;
; Called from: the instance bank's per-ring Init veneer, and nothing else.
; Inputs:  XHL = the ring.
; Outputs: all four cursors zeroed and the free count seeded with capacity-1.
; Evidence: five stores, in the order -10, -8, -4, -6, -2, the first four with
;          the immediate 0x0000.  The seed is the ONLY variable field, and it is
;          capacity-1 for every one of the five -- checked against each family's
;          own `minc1_16` mask by notes/prom_a_ringbuf_map.py ("Init's
;          free-space seed is capacity-1 for every capacity").  That is also the
;          evidence that (XHL-2) counts FREE bytes and not stored ones.
; The five:
;   0x80      0xF8425D
;   0x100     0xF84277
;   0x200     0xF84291
;   0x400     0xF842AB
;   0x1000    0xF842C5
; ---------------------------------------------------------------------
Ring_Init_0080:
	ldw	(xhl-10), 0x0000                             ; F8425D  bb f6 02 00 00
	ldw	(xhl-8), 0x0000                              ; F84262  bb f8 02 00 00
	ldw	(xhl-4), 0x0000                              ; F84267  bb fc 02 00 00
	ldw	(xhl-6), 0x0000                              ; F8426C  bb fa 02 00 00
	ldw	(xhl-2), 0x007f                              ; F84271  bb fe 02 7f 00
	ret                                                  ; F84276  0e
Ring_Init_0100:
	ldw	(xhl-10), 0x0000                             ; F84277  bb f6 02 00 00
	ldw	(xhl-8), 0x0000                              ; F8427C  bb f8 02 00 00
	ldw	(xhl-4), 0x0000                              ; F84281  bb fc 02 00 00
	ldw	(xhl-6), 0x0000                              ; F84286  bb fa 02 00 00
	ldw	(xhl-2), 0x00ff                              ; F8428B  bb fe 02 ff 00
	ret                                                  ; F84290  0e
Ring_Init_0200:
	ldw	(xhl-10), 0x0000                             ; F84291  bb f6 02 00 00
	ldw	(xhl-8), 0x0000                              ; F84296  bb f8 02 00 00
	ldw	(xhl-4), 0x0000                              ; F8429B  bb fc 02 00 00
	ldw	(xhl-6), 0x0000                              ; F842A0  bb fa 02 00 00
	ldw	(xhl-2), 0x01ff                              ; F842A5  bb fe 02 ff 01
	ret                                                  ; F842AA  0e
Ring_Init_0400:
	ldw	(xhl-10), 0x0000                             ; F842AB  bb f6 02 00 00
	ldw	(xhl-8), 0x0000                              ; F842B0  bb f8 02 00 00
	ldw	(xhl-4), 0x0000                              ; F842B5  bb fc 02 00 00
	ldw	(xhl-6), 0x0000                              ; F842BA  bb fa 02 00 00
	ldw	(xhl-2), 0x03ff                              ; F842BF  bb fe 02 ff 03
	ret                                                  ; F842C4  0e
Ring_Init_1000:
	ldw	(xhl-10), 0x0000                             ; F842C5  bb f6 02 00 00
	ldw	(xhl-8), 0x0000                              ; F842CA  bb f8 02 00 00
	ldw	(xhl-4), 0x0000                              ; F842CF  bb fc 02 00 00
	ldw	(xhl-6), 0x0000                              ; F842D4  bb fa 02 00 00
	ldw	(xhl-2), 0x0fff                              ; F842D9  bb fe 02 ff 0f
	ret                                                  ; F842DE  0e

; ==============================================================================
; 0xF842DF-0xF84C6B -- the INSTANCE BANK: 15 groups of 11 veneers
; ==============================================================================
;
; One group per ring object.  Every group is the same eleven routines in the
; same order and is exactly 163 bytes long; nine of the eleven are published
; through the prom_b directory and two are a bare `ret`.
;
;   1  Get         push IX/XHL, lda XHL,<ring>, call the class Get, pop, ret
;   2  Put         one stack argument, the byte
;   3  PutBlock    two stack arguments, a count and a pointer; Put in a djnz loop
;   4  IsEmpty     compares the ring's -4 and -8 directly; WA = 0 or 0xFFFF
;   5  Init
;   6  ScanRewind  (ring-10) := (ring-8)   -- rewind the scan to the read cursor
;   7  Scan
;   8  ret
;   9  ScanToPut
;  10  ret
;  11  GetCommit   (ring-8) := (ring-6)    -- move the read cursor to the limit
;
; The 6/11 pair is what makes the two extra cursors a TRANSACTION: rewind the
; scan to where reading stopped, look ahead without consuming, then either
; commit up to the limit or leave the read cursor where it was.  ⚠ that is a
; reading of the two assignments and of which fields the scan families compare;
; nothing in the ROM names it, and the writer of the scan limit at (ring-6) is
; not in this module.
;
; The fourteen distinct rings, their capacities, and the RAM they occupy are in
; notes/FINDINGS-prom_a-ring-buffers.md; the table there is printed by
; `python3 notes/prom_a_ringbuf_map.py`, not typed.  ★ Eleven of the fourteen
; TILE 0x600800-0x601E6E end to end with no gap and no overlap under the
; "control block ten bytes below the pointer, data `capacity` bytes above it"
; reading -- which is the strongest single piece of evidence that the layout is
; what the class says it is, since nothing forces a linker to place them so.
; ---------------------------------------------------------------------
; Ring608A0A_Get and its group -- the eleven veneers of ring 0x608A0A
;
; Called from: prom_b directory slot T_Ring608A0A_Get (T_F41CD0) (`jp 0xf842df`), which is the ONLY
;          slot naming this veneer; 6 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x608A0A` and calls a class routine of the SAME capacity
;          0x400 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x608A00-0x608E09: ten bytes of control block below the pointer,
;          0x400 bytes of data at and above it.
; Extent:  0xF842DF-0xF84381, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring608A0A_Get:
	pushw ix                                             ; F842DF  2c
	push XHL                                             ; F842E0  3b
	lda xhl, (0x608a0a:24)                               ; F842E1  f2 0a 8a 60 33
	call Ring_Get_0400                                   ; F842E6  1d 5d 40 f8
	pop XHL                                              ; F842EA  5b
	popw ix                                              ; F842EB  4c
	ret                                                  ; F842EC  0e
Ring608A0A_Put:
	link XIZ,0x0000                                      ; F842ED  ee 0c 00 00
	pushw ix                                             ; F842F1  2c
	push XHL                                             ; F842F2  3b
	ld A,(XIZ+0x08)                                      ; F842F3  8e 08 21
	lda xhl, (0x608a0a:24)                               ; F842F6  f2 0a 8a 60 33
	call Ring_Put_0400                                   ; F842FB  1d 19 42 f8
	pop XHL                                              ; F842FF  5b
	popw ix                                              ; F84300  4c
	unlk XIZ                                             ; F84301  ee 0d
	ret                                                  ; F84303  0e
Ring608A0A_PutBlock:
	link XIZ,0x0000                                      ; F84304  ee 0c 00 00
	push XIY                                             ; F84308  3d
	push XIX                                             ; F84309  3c
	push XHL                                             ; F8430A  3b
	ld BC,(XIZ+0x08)                                     ; F8430B  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F8430E  ae 0a 25
	lda xhl, (0x608a0a:24)                               ; F84311  f2 0a 8a 60 33
.LF84316:
	ld A,(XIY)                                           ; F84316  85 21
	call Ring_Put_0400                                   ; F84318  1d 19 42 f8
	inc 1,XIY                                            ; F8431C  ed 61
	djnz16 bc, .LF84316                                  ; F8431E  d9 1c f5
	pop XHL                                              ; F84321  5b
	pop XIX                                              ; F84322  5c
	pop XIY                                              ; F84323  5d
	unlk XIZ                                             ; F84324  ee 0d
	ret                                                  ; F84326  0e
Ring608A0A_IsEmpty:
	pushw bc                                             ; F84327  29
	ldw wa, 0x00                                         ; F84328  30 00 00
	ld bc, (0x608a06:24)                                ; F8432B  d2 06 8a 60 21
	cp	bc, (0x608a02:24)                            ; F84330  d2 02 8a 60 f1
	jr z, .LF8433A                                       ; F84335  66 03
	ldw wa, 0xffff                                       ; F84337  30 ff ff
.LF8433A:
	popw bc                                              ; F8433A  49
	ret                                                  ; F8433B  0e
Ring608A0A_Init:
	pushw ix                                             ; F8433C  2c
	push XHL                                             ; F8433D  3b
	lda xhl, (0x608a0a:24)                               ; F8433E  f2 0a 8a 60 33
	call Ring_Init_0400                                  ; F84343  1d ab 42 f8
	pop XHL                                              ; F84347  5b
	popw ix                                              ; F84348  4c
	ret                                                  ; F84349  0e
Ring608A0A_ScanRewind:
	pushw wa                                             ; F8434A  28
	ld wa, (0x608a02:24)                                ; F8434B  d2 02 8a 60 20
	ld (0x608a00:24), wa                                ; F84350  f2 00 8a 60 50
	popw wa                                              ; F84355  48
	ret                                                  ; F84356  0e
Ring608A0A_Scan:
	pushw ix                                             ; F84357  2c
	push XHL                                             ; F84358  3b
	lda xhl, (0x608a0a:24)                               ; F84359  f2 0a 8a 60 33
	call Ring_Scan_0400                                  ; F8435E  1d ef 40 f8
	pop XHL                                              ; F84362  5b
	popw ix                                              ; F84363  4c
	ret                                                  ; F84364  0e
	ret                                                  ; F84365  0e
Ring608A0A_ScanToPut:
	pushw ix                                             ; F84366  2c
	push XHL                                             ; F84367  3b
	lda xhl, (0x608a0a:24)                               ; F84368  f2 0a 8a 60 33
	call Ring_ScanToPut_0400                             ; F8436D  1d 7b 41 f8
	pop XHL                                              ; F84371  5b
	popw ix                                              ; F84372  4c
	ret                                                  ; F84373  0e
	ret                                                  ; F84374  0e
Ring608A0A_GetCommit:
	pushw wa                                             ; F84375  28
	ld wa, (0x608a04:24)                                ; F84376  d2 04 8a 60 20
	ld (0x608a02:24), wa                                ; F8437B  f2 02 8a 60 50
	popw wa                                              ; F84380  48
	ret                                                  ; F84381  0e
; ---------------------------------------------------------------------
; Ring60480A_Get and its group -- the eleven veneers of ring 0x60480A
;
; Called from: prom_b directory slot T_Ring60480A_Get (T_F41CF4) (`jp 0xf84382`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x60480A` and calls a class routine of the SAME capacity
;          0x100 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x604800-0x604909: ten bytes of control block below the pointer,
;          0x100 bytes of data at and above it.
; Extent:  0xF84382-0xF84424, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring60480A_Get:
	pushw ix                                             ; F84382  2c
	push XHL                                             ; F84383  3b
	lda xhl, (0x60480a:24)                               ; F84384  f2 0a 48 60 33
	call Ring_Get_0100                                   ; F84389  1d 1f 40 f8
	pop XHL                                              ; F8438D  5b
	popw ix                                              ; F8438E  4c
	ret                                                  ; F8438F  0e
Ring60480A_Put:
	link XIZ,0x0000                                      ; F84390  ee 0c 00 00
	pushw ix                                             ; F84394  2c
	push XHL                                             ; F84395  3b
	ld A,(XIZ+0x08)                                      ; F84396  8e 08 21
	lda xhl, (0x60480a:24)                               ; F84399  f2 0a 48 60 33
	call Ring_Put_0100                                   ; F8439E  1d d5 41 f8
	pop XHL                                              ; F843A2  5b
	popw ix                                              ; F843A3  4c
	unlk XIZ                                             ; F843A4  ee 0d
	ret                                                  ; F843A6  0e
Ring60480A_PutBlock:
	link XIZ,0x0000                                      ; F843A7  ee 0c 00 00
	push XIY                                             ; F843AB  3d
	push XIX                                             ; F843AC  3c
	push XHL                                             ; F843AD  3b
	ld BC,(XIZ+0x08)                                     ; F843AE  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F843B1  ae 0a 25
	lda xhl, (0x60480a:24)                               ; F843B4  f2 0a 48 60 33
.LF843B9:
	ld A,(XIY)                                           ; F843B9  85 21
	call Ring_Put_0100                                   ; F843BB  1d d5 41 f8
	inc 1,XIY                                            ; F843BF  ed 61
	djnz16 bc, .LF843B9                                  ; F843C1  d9 1c f5
	pop XHL                                              ; F843C4  5b
	pop XIX                                              ; F843C5  5c
	pop XIY                                              ; F843C6  5d
	unlk XIZ                                             ; F843C7  ee 0d
	ret                                                  ; F843C9  0e
Ring60480A_IsEmpty:
	pushw bc                                             ; F843CA  29
	ldw wa, 0x00                                         ; F843CB  30 00 00
	ld bc, (0x604806:24)                                ; F843CE  d2 06 48 60 21
	cp	bc, (0x604802:24)                            ; F843D3  d2 02 48 60 f1
	jr z, .LF843DD                                       ; F843D8  66 03
	ldw wa, 0xffff                                       ; F843DA  30 ff ff
.LF843DD:
	popw bc                                              ; F843DD  49
	ret                                                  ; F843DE  0e
Ring60480A_Init:
	pushw ix                                             ; F843DF  2c
	push XHL                                             ; F843E0  3b
	lda xhl, (0x60480a:24)                               ; F843E1  f2 0a 48 60 33
	call Ring_Init_0100                                  ; F843E6  1d 77 42 f8
	pop XHL                                              ; F843EA  5b
	popw ix                                              ; F843EB  4c
	ret                                                  ; F843EC  0e
Ring60480A_ScanRewind:
	pushw wa                                             ; F843ED  28
	ld wa, (0x604802:24)                                ; F843EE  d2 02 48 60 20
	ld (0x604800:24), wa                                ; F843F3  f2 00 48 60 50
	popw wa                                              ; F843F8  48
	ret                                                  ; F843F9  0e
Ring60480A_Scan:
	pushw ix                                             ; F843FA  2c
	push XHL                                             ; F843FB  3b
	lda xhl, (0x60480a:24)                               ; F843FC  f2 0a 48 60 33
	call Ring_Scan_0100                                  ; F84401  1d b7 40 f8
	pop XHL                                              ; F84405  5b
	popw ix                                              ; F84406  4c
	ret                                                  ; F84407  0e
	ret                                                  ; F84408  0e
Ring60480A_ScanToPut:
	pushw ix                                             ; F84409  2c
	push XHL                                             ; F8440A  3b
	lda xhl, (0x60480a:24)                               ; F8440B  f2 0a 48 60 33
	call Ring_ScanToPut_0100                             ; F84410  1d 43 41 f8
	pop XHL                                              ; F84414  5b
	popw ix                                              ; F84415  4c
	ret                                                  ; F84416  0e
	ret                                                  ; F84417  0e
Ring60480A_GetCommit:
	pushw wa                                             ; F84418  28
	ld wa, (0x604804:24)                                ; F84419  d2 04 48 60 20
	ld (0x604802:24), wa                                ; F8441E  f2 02 48 60 50
	popw wa                                              ; F84423  48
	ret                                                  ; F84424  0e
; ---------------------------------------------------------------------
; Ring601B64_Get and its group -- the eleven veneers of ring 0x601B64
;
; Called from: prom_b directory slot T_Ring601B64_Get (T_F41D3C) (`jp 0xf84425`), which is the ONLY
;          slot naming this veneer; 0 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601B64` and calls a class routine of the SAME capacity
;          0x100 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601B5A-0x601C63: ten bytes of control block below the pointer,
;          0x100 bytes of data at and above it.
; Extent:  0xF84425-0xF844C7, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring601B64_Get:
	pushw ix                                             ; F84425  2c
	push XHL                                             ; F84426  3b
	lda xhl, (0x601b64:24)                               ; F84427  f2 64 1b 60 33
	call Ring_Get_0100                                   ; F8442C  1d 1f 40 f8
	pop XHL                                              ; F84430  5b
	popw ix                                              ; F84431  4c
	ret                                                  ; F84432  0e
Ring601B64_Put:
	link XIZ,0x0000                                      ; F84433  ee 0c 00 00
	pushw ix                                             ; F84437  2c
	push XHL                                             ; F84438  3b
	ld A,(XIZ+0x08)                                      ; F84439  8e 08 21
	lda xhl, (0x601b64:24)                               ; F8443C  f2 64 1b 60 33
	call Ring_Put_0100                                   ; F84441  1d d5 41 f8
	pop XHL                                              ; F84445  5b
	popw ix                                              ; F84446  4c
	unlk XIZ                                             ; F84447  ee 0d
	ret                                                  ; F84449  0e
Ring601B64_PutBlock:
	link XIZ,0x0000                                      ; F8444A  ee 0c 00 00
	push XIY                                             ; F8444E  3d
	push XIX                                             ; F8444F  3c
	push XHL                                             ; F84450  3b
	ld BC,(XIZ+0x08)                                     ; F84451  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84454  ae 0a 25
	lda xhl, (0x601b64:24)                               ; F84457  f2 64 1b 60 33
.LF8445C:
	ld A,(XIY)                                           ; F8445C  85 21
	call Ring_Put_0100                                   ; F8445E  1d d5 41 f8
	inc 1,XIY                                            ; F84462  ed 61
	djnz16 bc, .LF8445C                                  ; F84464  d9 1c f5
	pop XHL                                              ; F84467  5b
	pop XIX                                              ; F84468  5c
	pop XIY                                              ; F84469  5d
	unlk XIZ                                             ; F8446A  ee 0d
	ret                                                  ; F8446C  0e
Ring601B64_IsEmpty:
	pushw bc                                             ; F8446D  29
	ldw wa, 0x00                                         ; F8446E  30 00 00
	ld bc, (0x601b60:24)                                ; F84471  d2 60 1b 60 21
	cp	bc, (0x601b5c:24)                            ; F84476  d2 5c 1b 60 f1
	jr z, .LF84480                                       ; F8447B  66 03
	ldw wa, 0xffff                                       ; F8447D  30 ff ff
.LF84480:
	popw bc                                              ; F84480  49
	ret                                                  ; F84481  0e
Ring601B64_Init:
	pushw ix                                             ; F84482  2c
	push XHL                                             ; F84483  3b
	lda xhl, (0x601b64:24)                               ; F84484  f2 64 1b 60 33
	call Ring_Init_0100                                  ; F84489  1d 77 42 f8
	pop XHL                                              ; F8448D  5b
	popw ix                                              ; F8448E  4c
	ret                                                  ; F8448F  0e
Ring601B64_ScanRewind:
	pushw wa                                             ; F84490  28
	ld wa, (0x601b5c:24)                                ; F84491  d2 5c 1b 60 20
	ld (0x601b5a:24), wa                                ; F84496  f2 5a 1b 60 50
	popw wa                                              ; F8449B  48
	ret                                                  ; F8449C  0e
Ring601B64_Scan:
	pushw ix                                             ; F8449D  2c
	push XHL                                             ; F8449E  3b
	lda xhl, (0x601b64:24)                               ; F8449F  f2 64 1b 60 33
	call Ring_Scan_0100                                  ; F844A4  1d b7 40 f8
	pop XHL                                              ; F844A8  5b
	popw ix                                              ; F844A9  4c
	ret                                                  ; F844AA  0e
	ret                                                  ; F844AB  0e
Ring601B64_ScanToPut:
	pushw ix                                             ; F844AC  2c
	push XHL                                             ; F844AD  3b
	lda xhl, (0x601b64:24)                               ; F844AE  f2 64 1b 60 33
	call Ring_ScanToPut_0100                             ; F844B3  1d 43 41 f8
	pop XHL                                              ; F844B7  5b
	popw ix                                              ; F844B8  4c
	ret                                                  ; F844B9  0e
	ret                                                  ; F844BA  0e
Ring601B64_GetCommit:
	pushw wa                                             ; F844BB  28
	ld wa, (0x601b5e:24)                                ; F844BC  d2 5e 1b 60 20
	ld (0x601b5c:24), wa                                ; F844C1  f2 5c 1b 60 50
	popw wa                                              ; F844C6  48
	ret                                                  ; F844C7  0e
; ---------------------------------------------------------------------
; Ring60000C_Get and its group -- the eleven veneers of ring 0x60000C
;
; Called from: prom_b directory slot T_Ring60000C_Get (T_F41E80) (`jp 0xf844c8`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x60000C` and calls a class routine of the SAME capacity
;          0x400 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x600002-0x60040B: ten bytes of control block below the pointer,
;          0x400 bytes of data at and above it.
; Extent:  0xF844C8-0xF8456A, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring60000C_Get:
	pushw ix                                             ; F844C8  2c
	push XHL                                             ; F844C9  3b
	lda xhl, (0x60000c:24)                               ; F844CA  f2 0c 00 60 33
	call Ring_Get_0400                                   ; F844CF  1d 5d 40 f8
	pop XHL                                              ; F844D3  5b
	popw ix                                              ; F844D4  4c
	ret                                                  ; F844D5  0e
Ring60000C_Put:
	link XIZ,0x0000                                      ; F844D6  ee 0c 00 00
	pushw ix                                             ; F844DA  2c
	push XHL                                             ; F844DB  3b
	ld A,(XIZ+0x08)                                      ; F844DC  8e 08 21
	lda xhl, (0x60000c:24)                               ; F844DF  f2 0c 00 60 33
	call Ring_Put_0400                                   ; F844E4  1d 19 42 f8
	pop XHL                                              ; F844E8  5b
	popw ix                                              ; F844E9  4c
	unlk XIZ                                             ; F844EA  ee 0d
	ret                                                  ; F844EC  0e
Ring60000C_PutBlock:
	link XIZ,0x0000                                      ; F844ED  ee 0c 00 00
	push XIY                                             ; F844F1  3d
	push XIX                                             ; F844F2  3c
	push XHL                                             ; F844F3  3b
	ld BC,(XIZ+0x08)                                     ; F844F4  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F844F7  ae 0a 25
	lda xhl, (0x60000c:24)                               ; F844FA  f2 0c 00 60 33
.LF844FF:
	ld A,(XIY)                                           ; F844FF  85 21
	call Ring_Put_0400                                   ; F84501  1d 19 42 f8
	inc 1,XIY                                            ; F84505  ed 61
	djnz16 bc, .LF844FF                                  ; F84507  d9 1c f5
	pop XHL                                              ; F8450A  5b
	pop XIX                                              ; F8450B  5c
	pop XIY                                              ; F8450C  5d
	unlk XIZ                                             ; F8450D  ee 0d
	ret                                                  ; F8450F  0e
Ring60000C_IsEmpty:
	pushw bc                                             ; F84510  29
	ldw wa, 0x00                                         ; F84511  30 00 00
	ld bc, (0x600008:24)                                ; F84514  d2 08 00 60 21
	cp	bc, (0x600004:24)                            ; F84519  d2 04 00 60 f1
	jr z, .LF84523                                       ; F8451E  66 03
	ldw wa, 0xffff                                       ; F84520  30 ff ff
.LF84523:
	popw bc                                              ; F84523  49
	ret                                                  ; F84524  0e
Ring60000C_Init:
	pushw ix                                             ; F84525  2c
	push XHL                                             ; F84526  3b
	lda xhl, (0x60000c:24)                               ; F84527  f2 0c 00 60 33
	call Ring_Init_0400                                  ; F8452C  1d ab 42 f8
	pop XHL                                              ; F84530  5b
	popw ix                                              ; F84531  4c
	ret                                                  ; F84532  0e
Ring60000C_ScanRewind:
	pushw wa                                             ; F84533  28
	ld wa, (0x600004:24)                                ; F84534  d2 04 00 60 20
	ld (0x600002:24), wa                                ; F84539  f2 02 00 60 50
	popw wa                                              ; F8453E  48
	ret                                                  ; F8453F  0e
Ring60000C_Scan:
	pushw ix                                             ; F84540  2c
	push XHL                                             ; F84541  3b
	lda xhl, (0x60000c:24)                               ; F84542  f2 0c 00 60 33
	call Ring_Scan_0400                                  ; F84547  1d ef 40 f8
	pop XHL                                              ; F8454B  5b
	popw ix                                              ; F8454C  4c
	ret                                                  ; F8454D  0e
	ret                                                  ; F8454E  0e
Ring60000C_ScanToPut:
	pushw ix                                             ; F8454F  2c
	push XHL                                             ; F84550  3b
	lda xhl, (0x60000c:24)                               ; F84551  f2 0c 00 60 33
	call Ring_ScanToPut_0400                             ; F84556  1d 7b 41 f8
	pop XHL                                              ; F8455A  5b
	popw ix                                              ; F8455B  4c
	ret                                                  ; F8455C  0e
	ret                                                  ; F8455D  0e
Ring60000C_GetCommit:
	pushw wa                                             ; F8455E  28
	ld wa, (0x600006:24)                                ; F8455F  d2 06 00 60 20
	ld (0x600004:24), wa                                ; F84564  f2 04 00 60 50
	popw wa                                              ; F84569  48
	ret                                                  ; F8456A  0e
; ---------------------------------------------------------------------
; TimedEventRing_Get and its group -- the eleven veneers of ring 0x60080A
;
; Called from: prom_b directory slot T_TimedEventRing_Get (T_F41D60) (`jp 0xf8456b`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x60080A` and calls a class routine of the SAME capacity
;          0x200 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x600800-0x600A09: ten bytes of control block below the pointer,
;          0x200 bytes of data at and above it.
; Extent:  0xF8456B-0xF8460D, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
TimedEventRing_Get:
	pushw ix                                             ; F8456B  2c
	push XHL                                             ; F8456C  3b
	lda xhl, (TimedEvents_Ring:24)                               ; F8456D  f2 0a 08 60 33
	call Ring_Get_0200                                   ; F84572  1d 3e 40 f8
	pop XHL                                              ; F84576  5b
	popw ix                                              ; F84577  4c
	ret                                                  ; F84578  0e
TimedEventRing_Put:
	link XIZ,0x0000                                      ; F84579  ee 0c 00 00
	pushw ix                                             ; F8457D  2c
	push XHL                                             ; F8457E  3b
	ld A,(XIZ+0x08)                                      ; F8457F  8e 08 21
	lda xhl, (TimedEvents_Ring:24)                               ; F84582  f2 0a 08 60 33
	call Ring_Put_0200                                   ; F84587  1d f7 41 f8
	pop XHL                                              ; F8458B  5b
	popw ix                                              ; F8458C  4c
	unlk XIZ                                             ; F8458D  ee 0d
	ret                                                  ; F8458F  0e
TimedEventRing_PutBlock:
	link XIZ,0x0000                                      ; F84590  ee 0c 00 00
	push XIY                                             ; F84594  3d
	push XIX                                             ; F84595  3c
	push XHL                                             ; F84596  3b
	ld BC,(XIZ+0x08)                                     ; F84597  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F8459A  ae 0a 25
	lda xhl, (TimedEvents_Ring:24)                               ; F8459D  f2 0a 08 60 33
.LF845A2:
	ld A,(XIY)                                           ; F845A2  85 21
	call Ring_Put_0200                                   ; F845A4  1d f7 41 f8
	inc 1,XIY                                            ; F845A8  ed 61
	djnz16 bc, .LF845A2                                  ; F845AA  d9 1c f5
	pop XHL                                              ; F845AD  5b
	pop XIX                                              ; F845AE  5c
	pop XIY                                              ; F845AF  5d
	unlk XIZ                                             ; F845B0  ee 0d
	ret                                                  ; F845B2  0e
TimedEventRing_IsEmpty:
	pushw bc                                             ; F845B3  29
	ldw wa, 0x00                                         ; F845B4  30 00 00
	ld bc, (0x600806:24)                                ; F845B7  d2 06 08 60 21
	cp	bc, (0x600802:24)                            ; F845BC  d2 02 08 60 f1
	jr z, .LF845C6                                       ; F845C1  66 03
	ldw wa, 0xffff                                       ; F845C3  30 ff ff
.LF845C6:
	popw bc                                              ; F845C6  49
	ret                                                  ; F845C7  0e
TimedEventRing_Init:
	pushw ix                                             ; F845C8  2c
	push XHL                                             ; F845C9  3b
	lda xhl, (TimedEvents_Ring:24)                               ; F845CA  f2 0a 08 60 33
	call Ring_Init_0200                                  ; F845CF  1d 91 42 f8
	pop XHL                                              ; F845D3  5b
	popw ix                                              ; F845D4  4c
	ret                                                  ; F845D5  0e
TimedEventRing_ScanRewind:
	pushw wa                                             ; F845D6  28
	ld wa, (0x600802:24)                                ; F845D7  d2 02 08 60 20
	ld (0x600800:24), wa                                ; F845DC  f2 00 08 60 50
	popw wa                                              ; F845E1  48
	ret                                                  ; F845E2  0e
TimedEventRing_Scan:
	pushw ix                                             ; F845E3  2c
	push XHL                                             ; F845E4  3b
	lda xhl, (TimedEvents_Ring:24)                               ; F845E5  f2 0a 08 60 33
	call Ring_Scan_0200                                  ; F845EA  1d d3 40 f8
	pop XHL                                              ; F845EE  5b
	popw ix                                              ; F845EF  4c
	ret                                                  ; F845F0  0e
	ret                                                  ; F845F1  0e
TimedEventRing_ScanToPut:
	pushw ix                                             ; F845F2  2c
	push XHL                                             ; F845F3  3b
	lda xhl, (TimedEvents_Ring:24)                               ; F845F4  f2 0a 08 60 33
	call Ring_ScanToPut_0200                             ; F845F9  1d 5f 41 f8
	pop XHL                                              ; F845FD  5b
	popw ix                                              ; F845FE  4c
	ret                                                  ; F845FF  0e
	ret                                                  ; F84600  0e
TimedEventRing_GetCommit:
	pushw wa                                             ; F84601  28
	ld wa, (0x600804:24)                                ; F84602  d2 04 08 60 20
	ld (0x600802:24), wa                                ; F84607  f2 02 08 60 50
	popw wa                                              ; F8460C  48
	ret                                                  ; F8460D  0e
; ---------------------------------------------------------------------
; SeqBufRing_Get and its group -- the eleven veneers of ring 0x600A14
;
; Called from: prom_b directory slot T_SeqBufRing_Get (T_F41D84) (`jp 0xf8460e`), which is the ONLY
;          slot naming this veneer; 48 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x600A14` and calls a class routine of the SAME capacity
;          0x200 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x600A0A-0x600C13: ten bytes of control block below the pointer,
;          0x200 bytes of data at and above it.
; Extent:  0xF8460E-0xF846B0, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
SeqBufRing_Get:
	pushw ix                                             ; F8460E  2c
	push XHL                                             ; F8460F  3b
	lda xhl, (SeqBuf_Ring:24)                               ; F84610  f2 14 0a 60 33
	call Ring_Get_0200                                   ; F84615  1d 3e 40 f8
	pop XHL                                              ; F84619  5b
	popw ix                                              ; F8461A  4c
	ret                                                  ; F8461B  0e
SeqBufRing_Put:
	link XIZ,0x0000                                      ; F8461C  ee 0c 00 00
	pushw ix                                             ; F84620  2c
	push XHL                                             ; F84621  3b
	ld A,(XIZ+0x08)                                      ; F84622  8e 08 21
	lda xhl, (SeqBuf_Ring:24)                               ; F84625  f2 14 0a 60 33
	call Ring_Put_0200                                   ; F8462A  1d f7 41 f8
	pop XHL                                              ; F8462E  5b
	popw ix                                              ; F8462F  4c
	unlk XIZ                                             ; F84630  ee 0d
	ret                                                  ; F84632  0e
SeqBufRing_PutBlock:
	link XIZ,0x0000                                      ; F84633  ee 0c 00 00
	push XIY                                             ; F84637  3d
	push XIX                                             ; F84638  3c
	push XHL                                             ; F84639  3b
	ld BC,(XIZ+0x08)                                     ; F8463A  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F8463D  ae 0a 25
	lda xhl, (SeqBuf_Ring:24)                               ; F84640  f2 14 0a 60 33
.LF84645:
	ld A,(XIY)                                           ; F84645  85 21
	call Ring_Put_0200                                   ; F84647  1d f7 41 f8
	inc 1,XIY                                            ; F8464B  ed 61
	djnz16 bc, .LF84645                                  ; F8464D  d9 1c f5
	pop XHL                                              ; F84650  5b
	pop XIX                                              ; F84651  5c
	pop XIY                                              ; F84652  5d
	unlk XIZ                                             ; F84653  ee 0d
	ret                                                  ; F84655  0e
SeqBufRing_IsEmpty:
	pushw bc                                             ; F84656  29
	ldw wa, 0x00                                         ; F84657  30 00 00
	ld bc, (SeqBuf_RingPut:24)                                ; F8465A  d2 10 0a 60 21
	cp	bc, (0x600a0c:24)                            ; F8465F  d2 0c 0a 60 f1
	jr z, .LF84669                                       ; F84664  66 03
	ldw wa, 0xffff                                       ; F84666  30 ff ff
.LF84669:
	popw bc                                              ; F84669  49
	ret                                                  ; F8466A  0e
SeqBufRing_Init:
	pushw ix                                             ; F8466B  2c
	push XHL                                             ; F8466C  3b
	lda xhl, (SeqBuf_Ring:24)                               ; F8466D  f2 14 0a 60 33
	call Ring_Init_0200                                  ; F84672  1d 91 42 f8
	pop XHL                                              ; F84676  5b
	popw ix                                              ; F84677  4c
	ret                                                  ; F84678  0e
SeqBufRing_ScanRewind:
	pushw wa                                             ; F84679  28
	ld wa, (0x600a0c:24)                                ; F8467A  d2 0c 0a 60 20
	ld (0x600a0a:24), wa                                ; F8467F  f2 0a 0a 60 50
	popw wa                                              ; F84684  48
	ret                                                  ; F84685  0e
SeqBufRing_Scan:
	pushw ix                                             ; F84686  2c
	push XHL                                             ; F84687  3b
	lda xhl, (SeqBuf_Ring:24)                               ; F84688  f2 14 0a 60 33
	call Ring_Scan_0200                                  ; F8468D  1d d3 40 f8
	pop XHL                                              ; F84691  5b
	popw ix                                              ; F84692  4c
	ret                                                  ; F84693  0e
	ret                                                  ; F84694  0e
SeqBufRing_ScanToPut:
	pushw ix                                             ; F84695  2c
	push XHL                                             ; F84696  3b
	lda xhl, (SeqBuf_Ring:24)                               ; F84697  f2 14 0a 60 33
	call Ring_ScanToPut_0200                             ; F8469C  1d 5f 41 f8
	pop XHL                                              ; F846A0  5b
	popw ix                                              ; F846A1  4c
	ret                                                  ; F846A2  0e
	ret                                                  ; F846A3  0e
SeqBufRing_GetCommit:
	pushw wa                                             ; F846A4  28
	ld wa, (0x600a0e:24)                                ; F846A5  d2 0e 0a 60 20
	ld (0x600a0c:24), wa                                ; F846AA  f2 0c 0a 60 50
	popw wa                                              ; F846AF  48
	ret                                                  ; F846B0  0e
; ---------------------------------------------------------------------
; MidiInARing_Get and its group -- the eleven veneers of ring 0x600C1E
;
; Called from: prom_b directory slot T_MidiInARing_Get (T_F41DA8) (`jp 0xf846b1`), which is the ONLY
;          slot naming this veneer; 0 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x600C1E` and calls a class routine of the SAME capacity
;          0x400 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x600C14-0x60101D: ten bytes of control block below the pointer,
;          0x400 bytes of data at and above it.
; Extent:  0xF846B1-0xF84753, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
MidiInARing_Get:
	pushw ix                                             ; F846B1  2c
	push XHL                                             ; F846B2  3b
	lda xhl, (MidiIn_PortARing:24)                               ; F846B3  f2 1e 0c 60 33
	call Ring_Get_0400                                   ; F846B8  1d 5d 40 f8
	pop XHL                                              ; F846BC  5b
	popw ix                                              ; F846BD  4c
	ret                                                  ; F846BE  0e
MidiInARing_Put:
	link XIZ,0x0000                                      ; F846BF  ee 0c 00 00
	pushw ix                                             ; F846C3  2c
	push XHL                                             ; F846C4  3b
	ld A,(XIZ+0x08)                                      ; F846C5  8e 08 21
	lda xhl, (MidiIn_PortARing:24)                               ; F846C8  f2 1e 0c 60 33
	call Ring_Put_0400                                   ; F846CD  1d 19 42 f8
	pop XHL                                              ; F846D1  5b
	popw ix                                              ; F846D2  4c
	unlk XIZ                                             ; F846D3  ee 0d
	ret                                                  ; F846D5  0e
MidiInARing_PutBlock:
	link XIZ,0x0000                                      ; F846D6  ee 0c 00 00
	push XIY                                             ; F846DA  3d
	push XIX                                             ; F846DB  3c
	push XHL                                             ; F846DC  3b
	ld BC,(XIZ+0x08)                                     ; F846DD  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F846E0  ae 0a 25
	lda xhl, (MidiIn_PortARing:24)                               ; F846E3  f2 1e 0c 60 33
.LF846E8:
	ld A,(XIY)                                           ; F846E8  85 21
	call Ring_Put_0400                                   ; F846EA  1d 19 42 f8
	inc 1,XIY                                            ; F846EE  ed 61
	djnz16 bc, .LF846E8                                  ; F846F0  d9 1c f5
	pop XHL                                              ; F846F3  5b
	pop XIX                                              ; F846F4  5c
	pop XIY                                              ; F846F5  5d
	unlk XIZ                                             ; F846F6  ee 0d
	ret                                                  ; F846F8  0e
MidiInARing_IsEmpty:
	pushw bc                                             ; F846F9  29
	ldw wa, 0x00                                         ; F846FA  30 00 00
	ld bc, (0x600c1a:24)                                ; F846FD  d2 1a 0c 60 21
	cp	bc, (0x600c16:24)                            ; F84702  d2 16 0c 60 f1
	jr z, .LF8470C                                       ; F84707  66 03
	ldw wa, 0xffff                                       ; F84709  30 ff ff
.LF8470C:
	popw bc                                              ; F8470C  49
	ret                                                  ; F8470D  0e
MidiInARing_Init:
	pushw ix                                             ; F8470E  2c
	push XHL                                             ; F8470F  3b
	lda xhl, (MidiIn_PortARing:24)                               ; F84710  f2 1e 0c 60 33
	call Ring_Init_0400                                  ; F84715  1d ab 42 f8
	pop XHL                                              ; F84719  5b
	popw ix                                              ; F8471A  4c
	ret                                                  ; F8471B  0e
MidiInARing_ScanRewind:
	pushw wa                                             ; F8471C  28
	ld wa, (0x600c16:24)                                ; F8471D  d2 16 0c 60 20
	ld (0x600c14:24), wa                                ; F84722  f2 14 0c 60 50
	popw wa                                              ; F84727  48
	ret                                                  ; F84728  0e
MidiInARing_Scan:
	pushw ix                                             ; F84729  2c
	push XHL                                             ; F8472A  3b
	lda xhl, (MidiIn_PortARing:24)                               ; F8472B  f2 1e 0c 60 33
	call Ring_Scan_0400                                  ; F84730  1d ef 40 f8
	pop XHL                                              ; F84734  5b
	popw ix                                              ; F84735  4c
	ret                                                  ; F84736  0e
	ret                                                  ; F84737  0e
MidiInARing_ScanToPut:
	pushw ix                                             ; F84738  2c
	push XHL                                             ; F84739  3b
	lda xhl, (MidiIn_PortARing:24)                               ; F8473A  f2 1e 0c 60 33
	call Ring_ScanToPut_0400                             ; F8473F  1d 7b 41 f8
	pop XHL                                              ; F84743  5b
	popw ix                                              ; F84744  4c
	ret                                                  ; F84745  0e
	ret                                                  ; F84746  0e
MidiInARing_GetCommit:
	pushw wa                                             ; F84747  28
	ld wa, (0x600c18:24)                                ; F84748  d2 18 0c 60 20
	ld (0x600c16:24), wa                                ; F8474D  f2 16 0c 60 50
	popw wa                                              ; F84752  48
	ret                                                  ; F84753  0e
; ---------------------------------------------------------------------
; MidiInBRing_Get and its group -- the eleven veneers of ring 0x601028
;
; Called from: prom_b directory slot T_MidiInBRing_Get (T_F41DCC) (`jp 0xf84754`), which is the ONLY
;          slot naming this veneer; 0 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601028` and calls a class routine of the SAME capacity
;          0x400 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x60101E-0x601427: ten bytes of control block below the pointer,
;          0x400 bytes of data at and above it.
; Extent:  0xF84754-0xF847F6, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
MidiInBRing_Get:
	pushw ix                                             ; F84754  2c
	push XHL                                             ; F84755  3b
	lda xhl, (MidiIn_PortBRing:24)                               ; F84756  f2 28 10 60 33
	call Ring_Get_0400                                   ; F8475B  1d 5d 40 f8
	pop XHL                                              ; F8475F  5b
	popw ix                                              ; F84760  4c
	ret                                                  ; F84761  0e
MidiInBRing_Put:
	link XIZ,0x0000                                      ; F84762  ee 0c 00 00
	pushw ix                                             ; F84766  2c
	push XHL                                             ; F84767  3b
	ld A,(XIZ+0x08)                                      ; F84768  8e 08 21
	lda xhl, (MidiIn_PortBRing:24)                               ; F8476B  f2 28 10 60 33
	call Ring_Put_0400                                   ; F84770  1d 19 42 f8
	pop XHL                                              ; F84774  5b
	popw ix                                              ; F84775  4c
	unlk XIZ                                             ; F84776  ee 0d
	ret                                                  ; F84778  0e
MidiInBRing_PutBlock:
	link XIZ,0x0000                                      ; F84779  ee 0c 00 00
	push XIY                                             ; F8477D  3d
	push XIX                                             ; F8477E  3c
	push XHL                                             ; F8477F  3b
	ld BC,(XIZ+0x08)                                     ; F84780  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84783  ae 0a 25
	lda xhl, (MidiIn_PortBRing:24)                               ; F84786  f2 28 10 60 33
.LF8478B:
	ld A,(XIY)                                           ; F8478B  85 21
	call Ring_Put_0400                                   ; F8478D  1d 19 42 f8
	inc 1,XIY                                            ; F84791  ed 61
	djnz16 bc, .LF8478B                                  ; F84793  d9 1c f5
	pop XHL                                              ; F84796  5b
	pop XIX                                              ; F84797  5c
	pop XIY                                              ; F84798  5d
	unlk XIZ                                             ; F84799  ee 0d
	ret                                                  ; F8479B  0e
MidiInBRing_IsEmpty:
	pushw bc                                             ; F8479C  29
	ldw wa, 0x00                                         ; F8479D  30 00 00
	ld bc, (0x601024:24)                                ; F847A0  d2 24 10 60 21
	cp	bc, (0x601020:24)                            ; F847A5  d2 20 10 60 f1
	jr z, .LF847AF                                       ; F847AA  66 03
	ldw wa, 0xffff                                       ; F847AC  30 ff ff
.LF847AF:
	popw bc                                              ; F847AF  49
	ret                                                  ; F847B0  0e
MidiInBRing_Init:
	pushw ix                                             ; F847B1  2c
	push XHL                                             ; F847B2  3b
	lda xhl, (MidiIn_PortBRing:24)                               ; F847B3  f2 28 10 60 33
	call Ring_Init_0400                                  ; F847B8  1d ab 42 f8
	pop XHL                                              ; F847BC  5b
	popw ix                                              ; F847BD  4c
	ret                                                  ; F847BE  0e
MidiInBRing_ScanRewind:
	pushw wa                                             ; F847BF  28
	ld wa, (0x601020:24)                                ; F847C0  d2 20 10 60 20
	ld (0x60101e:24), wa                                ; F847C5  f2 1e 10 60 50
	popw wa                                              ; F847CA  48
	ret                                                  ; F847CB  0e
MidiInBRing_Scan:
	pushw ix                                             ; F847CC  2c
	push XHL                                             ; F847CD  3b
	lda xhl, (MidiIn_PortBRing:24)                               ; F847CE  f2 28 10 60 33
	call Ring_Scan_0400                                  ; F847D3  1d ef 40 f8
	pop XHL                                              ; F847D7  5b
	popw ix                                              ; F847D8  4c
	ret                                                  ; F847D9  0e
	ret                                                  ; F847DA  0e
MidiInBRing_ScanToPut:
	pushw ix                                             ; F847DB  2c
	push XHL                                             ; F847DC  3b
	lda xhl, (MidiIn_PortBRing:24)                               ; F847DD  f2 28 10 60 33
	call Ring_ScanToPut_0400                             ; F847E2  1d 7b 41 f8
	pop XHL                                              ; F847E6  5b
	popw ix                                              ; F847E7  4c
	ret                                                  ; F847E8  0e
	ret                                                  ; F847E9  0e
MidiInBRing_GetCommit:
	pushw wa                                             ; F847EA  28
	ld wa, (0x601022:24)                                ; F847EB  d2 22 10 60 20
	ld (0x601020:24), wa                                ; F847F0  f2 20 10 60 50
	popw wa                                              ; F847F5  48
	ret                                                  ; F847F6  0e
; ---------------------------------------------------------------------
; Ring601432_Get and its group -- the eleven veneers of ring 0x601432
;
; Called from: prom_b directory slot T_Ring601432_Get (T_F41DF0) (`jp 0xf847f7`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601432` and calls a class routine of the SAME capacity
;          0x100 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601428-0x601531: ten bytes of control block below the pointer,
;          0x100 bytes of data at and above it.
; Extent:  0xF847F7-0xF84899, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring601432_Get:
	pushw ix                                             ; F847F7  2c
	push XHL                                             ; F847F8  3b
	lda xhl, (0x601432:24)                               ; F847F9  f2 32 14 60 33
	call Ring_Get_0100                                   ; F847FE  1d 1f 40 f8
	pop XHL                                              ; F84802  5b
	popw ix                                              ; F84803  4c
	ret                                                  ; F84804  0e
Ring601432_Put:
	link XIZ,0x0000                                      ; F84805  ee 0c 00 00
	pushw ix                                             ; F84809  2c
	push XHL                                             ; F8480A  3b
	ld A,(XIZ+0x08)                                      ; F8480B  8e 08 21
	lda xhl, (0x601432:24)                               ; F8480E  f2 32 14 60 33
	call Ring_Put_0100                                   ; F84813  1d d5 41 f8
	pop XHL                                              ; F84817  5b
	popw ix                                              ; F84818  4c
	unlk XIZ                                             ; F84819  ee 0d
	ret                                                  ; F8481B  0e
Ring601432_PutBlock:
	link XIZ,0x0000                                      ; F8481C  ee 0c 00 00
	push XIY                                             ; F84820  3d
	push XIX                                             ; F84821  3c
	push XHL                                             ; F84822  3b
	ld BC,(XIZ+0x08)                                     ; F84823  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84826  ae 0a 25
	lda xhl, (0x601432:24)                               ; F84829  f2 32 14 60 33
.LF8482E:
	ld A,(XIY)                                           ; F8482E  85 21
	call Ring_Put_0100                                   ; F84830  1d d5 41 f8
	inc 1,XIY                                            ; F84834  ed 61
	djnz16 bc, .LF8482E                                  ; F84836  d9 1c f5
	pop XHL                                              ; F84839  5b
	pop XIX                                              ; F8483A  5c
	pop XIY                                              ; F8483B  5d
	unlk XIZ                                             ; F8483C  ee 0d
	ret                                                  ; F8483E  0e
Ring601432_IsEmpty:
	pushw bc                                             ; F8483F  29
	ldw wa, 0x00                                         ; F84840  30 00 00
	ld bc, (0x60142e:24)                                ; F84843  d2 2e 14 60 21
	cp	bc, (0x60142a:24)                            ; F84848  d2 2a 14 60 f1
	jr z, .LF84852                                       ; F8484D  66 03
	ldw wa, 0xffff                                       ; F8484F  30 ff ff
.LF84852:
	popw bc                                              ; F84852  49
	ret                                                  ; F84853  0e
Ring601432_Init:
	pushw ix                                             ; F84854  2c
	push XHL                                             ; F84855  3b
	lda xhl, (0x601432:24)                               ; F84856  f2 32 14 60 33
	call Ring_Init_0100                                  ; F8485B  1d 77 42 f8
	pop XHL                                              ; F8485F  5b
	popw ix                                              ; F84860  4c
	ret                                                  ; F84861  0e
Ring601432_ScanRewind:
	pushw wa                                             ; F84862  28
	ld wa, (0x60142a:24)                                ; F84863  d2 2a 14 60 20
	ld (0x601428:24), wa                                ; F84868  f2 28 14 60 50
	popw wa                                              ; F8486D  48
	ret                                                  ; F8486E  0e
Ring601432_Scan:
	pushw ix                                             ; F8486F  2c
	push XHL                                             ; F84870  3b
	lda xhl, (0x601432:24)                               ; F84871  f2 32 14 60 33
	call Ring_Scan_0100                                  ; F84876  1d b7 40 f8
	pop XHL                                              ; F8487A  5b
	popw ix                                              ; F8487B  4c
	ret                                                  ; F8487C  0e
	ret                                                  ; F8487D  0e
Ring601432_ScanToPut:
	pushw ix                                             ; F8487E  2c
	push XHL                                             ; F8487F  3b
	lda xhl, (0x601432:24)                               ; F84880  f2 32 14 60 33
	call Ring_ScanToPut_0100                             ; F84885  1d 43 41 f8
	pop XHL                                              ; F84889  5b
	popw ix                                              ; F8488A  4c
	ret                                                  ; F8488B  0e
	ret                                                  ; F8488C  0e
Ring601432_GetCommit:
	pushw wa                                             ; F8488D  28
	ld wa, (0x60142c:24)                                ; F8488E  d2 2c 14 60 20
	ld (0x60142a:24), wa                                ; F84893  f2 2a 14 60 50
	popw wa                                              ; F84898  48
	ret                                                  ; F84899  0e
; ---------------------------------------------------------------------
; Ring60153C_Get and its group -- the eleven veneers of ring 0x60153C
;
; Called from: prom_b directory slot T_Ring60153C_Get (T_F41E14) (`jp 0xf8489a`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x60153C` and calls a class routine of the SAME capacity
;          0x100 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601532-0x60163B: ten bytes of control block below the pointer,
;          0x100 bytes of data at and above it.
; Extent:  0xF8489A-0xF8493C, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring60153C_Get:
	pushw ix                                             ; F8489A  2c
	push XHL                                             ; F8489B  3b
	lda xhl, (0x60153c:24)                               ; F8489C  f2 3c 15 60 33
	call Ring_Get_0100                                   ; F848A1  1d 1f 40 f8
	pop XHL                                              ; F848A5  5b
	popw ix                                              ; F848A6  4c
	ret                                                  ; F848A7  0e
Ring60153C_Put:
	link XIZ,0x0000                                      ; F848A8  ee 0c 00 00
	pushw ix                                             ; F848AC  2c
	push XHL                                             ; F848AD  3b
	ld A,(XIZ+0x08)                                      ; F848AE  8e 08 21
	lda xhl, (0x60153c:24)                               ; F848B1  f2 3c 15 60 33
	call Ring_Put_0100                                   ; F848B6  1d d5 41 f8
	pop XHL                                              ; F848BA  5b
	popw ix                                              ; F848BB  4c
	unlk XIZ                                             ; F848BC  ee 0d
	ret                                                  ; F848BE  0e
Ring60153C_PutBlock:
	link XIZ,0x0000                                      ; F848BF  ee 0c 00 00
	push XIY                                             ; F848C3  3d
	push XIX                                             ; F848C4  3c
	push XHL                                             ; F848C5  3b
	ld BC,(XIZ+0x08)                                     ; F848C6  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F848C9  ae 0a 25
	lda xhl, (0x60153c:24)                               ; F848CC  f2 3c 15 60 33
.LF848D1:
	ld A,(XIY)                                           ; F848D1  85 21
	call Ring_Put_0100                                   ; F848D3  1d d5 41 f8
	inc 1,XIY                                            ; F848D7  ed 61
	djnz16 bc, .LF848D1                                  ; F848D9  d9 1c f5
	pop XHL                                              ; F848DC  5b
	pop XIX                                              ; F848DD  5c
	pop XIY                                              ; F848DE  5d
	unlk XIZ                                             ; F848DF  ee 0d
	ret                                                  ; F848E1  0e
Ring60153C_IsEmpty:
	pushw bc                                             ; F848E2  29
	ldw wa, 0x00                                         ; F848E3  30 00 00
	ld bc, (0x601538:24)                                ; F848E6  d2 38 15 60 21
	cp	bc, (0x601534:24)                            ; F848EB  d2 34 15 60 f1
	jr z, .LF848F5                                       ; F848F0  66 03
	ldw wa, 0xffff                                       ; F848F2  30 ff ff
.LF848F5:
	popw bc                                              ; F848F5  49
	ret                                                  ; F848F6  0e
Ring60153C_Init:
	pushw ix                                             ; F848F7  2c
	push XHL                                             ; F848F8  3b
	lda xhl, (0x60153c:24)                               ; F848F9  f2 3c 15 60 33
	call Ring_Init_0100                                  ; F848FE  1d 77 42 f8
	pop XHL                                              ; F84902  5b
	popw ix                                              ; F84903  4c
	ret                                                  ; F84904  0e
Ring60153C_ScanRewind:
	pushw wa                                             ; F84905  28
	ld wa, (0x601534:24)                                ; F84906  d2 34 15 60 20
	ld (0x601532:24), wa                                ; F8490B  f2 32 15 60 50
	popw wa                                              ; F84910  48
	ret                                                  ; F84911  0e
Ring60153C_Scan:
	pushw ix                                             ; F84912  2c
	push XHL                                             ; F84913  3b
	lda xhl, (0x60153c:24)                               ; F84914  f2 3c 15 60 33
	call Ring_Scan_0100                                  ; F84919  1d b7 40 f8
	pop XHL                                              ; F8491D  5b
	popw ix                                              ; F8491E  4c
	ret                                                  ; F8491F  0e
	ret                                                  ; F84920  0e
Ring60153C_ScanToPut:
	pushw ix                                             ; F84921  2c
	push XHL                                             ; F84922  3b
	lda xhl, (0x60153c:24)                               ; F84923  f2 3c 15 60 33
	call Ring_ScanToPut_0100                             ; F84928  1d 43 41 f8
	pop XHL                                              ; F8492C  5b
	popw ix                                              ; F8492D  4c
	ret                                                  ; F8492E  0e
	ret                                                  ; F8492F  0e
Ring60153C_GetCommit:
	pushw wa                                             ; F84930  28
	ld wa, (0x601536:24)                                ; F84931  d2 36 15 60 20
	ld (0x601534:24), wa                                ; F84936  f2 34 15 60 50
	popw wa                                              ; F8493B  48
	ret                                                  ; F8493C  0e
; ---------------------------------------------------------------------
; Ring60195A_Get and its group -- the eleven veneers of ring 0x60195A
;
; Called from: prom_b directory slot T_Ring60195A_Get (T_F41D18) (`jp 0xf8493d`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x60195A` and calls a class routine of the SAME capacity
;          0x200 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601950-0x601B59: ten bytes of control block below the pointer,
;          0x200 bytes of data at and above it.
; Extent:  0xF8493D-0xF849DF, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring60195A_Get:
	pushw ix                                             ; F8493D  2c
	push XHL                                             ; F8493E  3b
	lda xhl, (0x60195a:24)                               ; F8493F  f2 5a 19 60 33
	call Ring_Get_0200                                   ; F84944  1d 3e 40 f8
	pop XHL                                              ; F84948  5b
	popw ix                                              ; F84949  4c
	ret                                                  ; F8494A  0e
Ring60195A_Put:
	link XIZ,0x0000                                      ; F8494B  ee 0c 00 00
	pushw ix                                             ; F8494F  2c
	push XHL                                             ; F84950  3b
	ld A,(XIZ+0x08)                                      ; F84951  8e 08 21
	lda xhl, (0x60195a:24)                               ; F84954  f2 5a 19 60 33
	call Ring_Put_0200                                   ; F84959  1d f7 41 f8
	pop XHL                                              ; F8495D  5b
	popw ix                                              ; F8495E  4c
	unlk XIZ                                             ; F8495F  ee 0d
	ret                                                  ; F84961  0e
Ring60195A_PutBlock:
	link XIZ,0x0000                                      ; F84962  ee 0c 00 00
	push XIY                                             ; F84966  3d
	push XIX                                             ; F84967  3c
	push XHL                                             ; F84968  3b
	ld BC,(XIZ+0x08)                                     ; F84969  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F8496C  ae 0a 25
	lda xhl, (0x60195a:24)                               ; F8496F  f2 5a 19 60 33
.LF84974:
	ld A,(XIY)                                           ; F84974  85 21
	call Ring_Put_0200                                   ; F84976  1d f7 41 f8
	inc 1,XIY                                            ; F8497A  ed 61
	djnz16 bc, .LF84974                                  ; F8497C  d9 1c f5
	pop XHL                                              ; F8497F  5b
	pop XIX                                              ; F84980  5c
	pop XIY                                              ; F84981  5d
	unlk XIZ                                             ; F84982  ee 0d
	ret                                                  ; F84984  0e
Ring60195A_IsEmpty:
	pushw bc                                             ; F84985  29
	ldw wa, 0x00                                         ; F84986  30 00 00
	ld bc, (0x601956:24)                                ; F84989  d2 56 19 60 21
	cp	bc, (0x601952:24)                            ; F8498E  d2 52 19 60 f1
	jr z, .LF84998                                       ; F84993  66 03
	ldw wa, 0xffff                                       ; F84995  30 ff ff
.LF84998:
	popw bc                                              ; F84998  49
	ret                                                  ; F84999  0e
Ring60195A_Init:
	pushw ix                                             ; F8499A  2c
	push XHL                                             ; F8499B  3b
	lda xhl, (0x60195a:24)                               ; F8499C  f2 5a 19 60 33
	call Ring_Init_0200                                  ; F849A1  1d 91 42 f8
	pop XHL                                              ; F849A5  5b
	popw ix                                              ; F849A6  4c
	ret                                                  ; F849A7  0e
Ring60195A_ScanRewind:
	pushw wa                                             ; F849A8  28
	ld wa, (0x601952:24)                                ; F849A9  d2 52 19 60 20
	ld (0x601950:24), wa                                ; F849AE  f2 50 19 60 50
	popw wa                                              ; F849B3  48
	ret                                                  ; F849B4  0e
Ring60195A_Scan:
	pushw ix                                             ; F849B5  2c
	push XHL                                             ; F849B6  3b
	lda xhl, (0x60195a:24)                               ; F849B7  f2 5a 19 60 33
	call Ring_Scan_0200                                  ; F849BC  1d d3 40 f8
	pop XHL                                              ; F849C0  5b
	popw ix                                              ; F849C1  4c
	ret                                                  ; F849C2  0e
	ret                                                  ; F849C3  0e
Ring60195A_ScanToPut:
	pushw ix                                             ; F849C4  2c
	push XHL                                             ; F849C5  3b
	lda xhl, (0x60195a:24)                               ; F849C6  f2 5a 19 60 33
	call Ring_ScanToPut_0200                             ; F849CB  1d 5f 41 f8
	pop XHL                                              ; F849CF  5b
	popw ix                                              ; F849D0  4c
	ret                                                  ; F849D1  0e
	ret                                                  ; F849D2  0e
Ring60195A_GetCommit:
	pushw wa                                             ; F849D3  28
	ld wa, (0x601954:24)                                ; F849D4  d2 54 19 60 20
	ld (0x601952:24), wa                                ; F849D9  f2 52 19 60 50
	popw wa                                              ; F849DE  48
	ret                                                  ; F849DF  0e
; ---------------------------------------------------------------------
; Ring601646_Get and its group -- the eleven veneers of ring 0x601646
;
; Called from: prom_b directory slot T_Ring601646_Get (T_F41E38) (`jp 0xf849e0`), which is the ONLY
;          slot naming this veneer; 2 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601646` and calls a class routine of the SAME capacity
;          0x200 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x60163C-0x601845: ten bytes of control block below the pointer,
;          0x200 bytes of data at and above it.
; Extent:  0xF849E0-0xF84A82, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring601646_Get:
	pushw ix                                             ; F849E0  2c
	push XHL                                             ; F849E1  3b
	lda xhl, (0x601646:24)                               ; F849E2  f2 46 16 60 33
	call Ring_Get_0200                                   ; F849E7  1d 3e 40 f8
	pop XHL                                              ; F849EB  5b
	popw ix                                              ; F849EC  4c
	ret                                                  ; F849ED  0e
Ring601646_Put:
	link XIZ,0x0000                                      ; F849EE  ee 0c 00 00
	pushw ix                                             ; F849F2  2c
	push XHL                                             ; F849F3  3b
	ld A,(XIZ+0x08)                                      ; F849F4  8e 08 21
	lda xhl, (0x601646:24)                               ; F849F7  f2 46 16 60 33
	call Ring_Put_0200                                   ; F849FC  1d f7 41 f8
	pop XHL                                              ; F84A00  5b
	popw ix                                              ; F84A01  4c
	unlk XIZ                                             ; F84A02  ee 0d
	ret                                                  ; F84A04  0e
Ring601646_PutBlock:
	link XIZ,0x0000                                      ; F84A05  ee 0c 00 00
	push XIY                                             ; F84A09  3d
	push XIX                                             ; F84A0A  3c
	push XHL                                             ; F84A0B  3b
	ld BC,(XIZ+0x08)                                     ; F84A0C  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84A0F  ae 0a 25
	lda xhl, (0x601646:24)                               ; F84A12  f2 46 16 60 33
.LF84A17:
	ld A,(XIY)                                           ; F84A17  85 21
	call Ring_Put_0200                                   ; F84A19  1d f7 41 f8
	inc 1,XIY                                            ; F84A1D  ed 61
	djnz16 bc, .LF84A17                                  ; F84A1F  d9 1c f5
	pop XHL                                              ; F84A22  5b
	pop XIX                                              ; F84A23  5c
	pop XIY                                              ; F84A24  5d
	unlk XIZ                                             ; F84A25  ee 0d
	ret                                                  ; F84A27  0e
Ring601646_IsEmpty:
	pushw bc                                             ; F84A28  29
	ldw wa, 0x00                                         ; F84A29  30 00 00
	ld bc, (0x601642:24)                                ; F84A2C  d2 42 16 60 21
	cp	bc, (0x60163e:24)                            ; F84A31  d2 3e 16 60 f1
	jr z, .LF84A3B                                       ; F84A36  66 03
	ldw wa, 0xffff                                       ; F84A38  30 ff ff
.LF84A3B:
	popw bc                                              ; F84A3B  49
	ret                                                  ; F84A3C  0e
Ring601646_Init:
	pushw ix                                             ; F84A3D  2c
	push XHL                                             ; F84A3E  3b
	lda xhl, (0x601646:24)                               ; F84A3F  f2 46 16 60 33
	call Ring_Init_0200                                  ; F84A44  1d 91 42 f8
	pop XHL                                              ; F84A48  5b
	popw ix                                              ; F84A49  4c
	ret                                                  ; F84A4A  0e
Ring601646_ScanRewind:
	pushw wa                                             ; F84A4B  28
	ld wa, (0x60163e:24)                                ; F84A4C  d2 3e 16 60 20
	ld (0x60163c:24), wa                                ; F84A51  f2 3c 16 60 50
	popw wa                                              ; F84A56  48
	ret                                                  ; F84A57  0e
Ring601646_Scan:
	pushw ix                                             ; F84A58  2c
	push XHL                                             ; F84A59  3b
	lda xhl, (0x601646:24)                               ; F84A5A  f2 46 16 60 33
	call Ring_Scan_0200                                  ; F84A5F  1d d3 40 f8
	pop XHL                                              ; F84A63  5b
	popw ix                                              ; F84A64  4c
	ret                                                  ; F84A65  0e
	ret                                                  ; F84A66  0e
Ring601646_ScanToPut:
	pushw ix                                             ; F84A67  2c
	push XHL                                             ; F84A68  3b
	lda xhl, (0x601646:24)                               ; F84A69  f2 46 16 60 33
	call Ring_ScanToPut_0200                             ; F84A6E  1d 5f 41 f8
	pop XHL                                              ; F84A72  5b
	popw ix                                              ; F84A73  4c
	ret                                                  ; F84A74  0e
	ret                                                  ; F84A75  0e
Ring601646_GetCommit:
	pushw wa                                             ; F84A76  28
	ld wa, (0x601640:24)                                ; F84A77  d2 40 16 60 20
	ld (0x60163e:24), wa                                ; F84A7C  f2 3e 16 60 50
	popw wa                                              ; F84A81  48
	ret                                                  ; F84A82  0e
; ---------------------------------------------------------------------
; Ring601C6E_Get and its group -- the eleven veneers of ring 0x601C6E
;
; Called from: prom_b directory slot T_Ring601C6E_Get (T_F41EA4) (`jp 0xf84a83`), which is the ONLY
;          slot naming this veneer; 1 call site reaches that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601C6E` and calls a class routine of the SAME capacity
;          0x200 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601C64-0x601E6D: ten bytes of control block below the pointer,
;          0x200 bytes of data at and above it.
; Extent:  0xF84A83-0xF84B25, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring601C6E_Get:
	pushw ix                                             ; F84A83  2c
	push XHL                                             ; F84A84  3b
	lda xhl, (0x601c6e:24)                               ; F84A85  f2 6e 1c 60 33
	call Ring_Get_0200                                   ; F84A8A  1d 3e 40 f8
	pop XHL                                              ; F84A8E  5b
	popw ix                                              ; F84A8F  4c
	ret                                                  ; F84A90  0e
Ring601C6E_Put:
	link XIZ,0x0000                                      ; F84A91  ee 0c 00 00
	pushw ix                                             ; F84A95  2c
	push XHL                                             ; F84A96  3b
	ld A,(XIZ+0x08)                                      ; F84A97  8e 08 21
	lda xhl, (0x601c6e:24)                               ; F84A9A  f2 6e 1c 60 33
	call Ring_Put_0200                                   ; F84A9F  1d f7 41 f8
	pop XHL                                              ; F84AA3  5b
	popw ix                                              ; F84AA4  4c
	unlk XIZ                                             ; F84AA5  ee 0d
	ret                                                  ; F84AA7  0e
Ring601C6E_PutBlock:
	link XIZ,0x0000                                      ; F84AA8  ee 0c 00 00
	push XIY                                             ; F84AAC  3d
	push XIX                                             ; F84AAD  3c
	push XHL                                             ; F84AAE  3b
	ld BC,(XIZ+0x08)                                     ; F84AAF  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84AB2  ae 0a 25
	lda xhl, (0x601c6e:24)                               ; F84AB5  f2 6e 1c 60 33
.LF84ABA:
	ld A,(XIY)                                           ; F84ABA  85 21
	call Ring_Put_0200                                   ; F84ABC  1d f7 41 f8
	inc 1,XIY                                            ; F84AC0  ed 61
	djnz16 bc, .LF84ABA                                  ; F84AC2  d9 1c f5
	pop XHL                                              ; F84AC5  5b
	pop XIX                                              ; F84AC6  5c
	pop XIY                                              ; F84AC7  5d
	unlk XIZ                                             ; F84AC8  ee 0d
	ret                                                  ; F84ACA  0e
Ring601C6E_IsEmpty:
	pushw bc                                             ; F84ACB  29
	ldw wa, 0x00                                         ; F84ACC  30 00 00
	ld bc, (0x601c6a:24)                                ; F84ACF  d2 6a 1c 60 21
	cp	bc, (0x601c66:24)                            ; F84AD4  d2 66 1c 60 f1
	jr z, .LF84ADE                                       ; F84AD9  66 03
	ldw wa, 0xffff                                       ; F84ADB  30 ff ff
.LF84ADE:
	popw bc                                              ; F84ADE  49
	ret                                                  ; F84ADF  0e
Ring601C6E_Init:
	pushw ix                                             ; F84AE0  2c
	push XHL                                             ; F84AE1  3b
	lda xhl, (0x601c6e:24)                               ; F84AE2  f2 6e 1c 60 33
	call Ring_Init_0200                                  ; F84AE7  1d 91 42 f8
	pop XHL                                              ; F84AEB  5b
	popw ix                                              ; F84AEC  4c
	ret                                                  ; F84AED  0e
Ring601C6E_ScanRewind:
	pushw wa                                             ; F84AEE  28
	ld wa, (0x601c66:24)                                ; F84AEF  d2 66 1c 60 20
	ld (0x601c64:24), wa                                ; F84AF4  f2 64 1c 60 50
	popw wa                                              ; F84AF9  48
	ret                                                  ; F84AFA  0e
Ring601C6E_Scan:
	pushw ix                                             ; F84AFB  2c
	push XHL                                             ; F84AFC  3b
	lda xhl, (0x601c6e:24)                               ; F84AFD  f2 6e 1c 60 33
	call Ring_Scan_0200                                  ; F84B02  1d d3 40 f8
	pop XHL                                              ; F84B06  5b
	popw ix                                              ; F84B07  4c
	ret                                                  ; F84B08  0e
	ret                                                  ; F84B09  0e
Ring601C6E_ScanToPut:
	pushw ix                                             ; F84B0A  2c
	push XHL                                             ; F84B0B  3b
	lda xhl, (0x601c6e:24)                               ; F84B0C  f2 6e 1c 60 33
	call Ring_ScanToPut_0200                             ; F84B11  1d 5f 41 f8
	pop XHL                                              ; F84B15  5b
	popw ix                                              ; F84B16  4c
	ret                                                  ; F84B17  0e
	ret                                                  ; F84B18  0e
Ring601C6E_GetCommit:
	pushw wa                                             ; F84B19  28
	ld wa, (0x601c68:24)                                ; F84B1A  d2 68 1c 60 20
	ld (0x601c66:24), wa                                ; F84B1F  f2 66 1c 60 50
	popw wa                                              ; F84B24  48
	ret                                                  ; F84B25  0e
; ---------------------------------------------------------------------
; Ring601850_Get and its group -- the eleven veneers of ring 0x601850
;
; Called from: prom_b directory slot T_Ring601850_Get (T_F41E5C) (`jp 0xf84b26`), which is the ONLY
;          slot naming this veneer; 2 call sites reach that slot.  The
;          group's other veneers own their own slots in the same module
;          T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (`python3 notes/prom_a_call_graph.py --module
;          0xF41CD0`).  CORRECTED 2026-08-25 (audit F9): every one of these
;          fourteen headers used to cite 0xF41CD0, which is Ring608A0A_Get's
;          slot and nobody else's.  Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601850` and calls a class routine of the SAME capacity
;          0x100 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601846-0x60194F: ten bytes of control block below the pointer,
;          0x100 bytes of data at and above it.
; Extent:  0xF84B26-0xF84BC8, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring601850_Get:
	pushw ix                                             ; F84B26  2c
	push XHL                                             ; F84B27  3b
	lda xhl, (0x601850:24)                               ; F84B28  f2 50 18 60 33
	call Ring_Get_0100                                   ; F84B2D  1d 1f 40 f8
	pop XHL                                              ; F84B31  5b
	popw ix                                              ; F84B32  4c
	ret                                                  ; F84B33  0e
Ring601850_Put:
	link XIZ,0x0000                                      ; F84B34  ee 0c 00 00
	pushw ix                                             ; F84B38  2c
	push XHL                                             ; F84B39  3b
	ld A,(XIZ+0x08)                                      ; F84B3A  8e 08 21
	lda xhl, (0x601850:24)                               ; F84B3D  f2 50 18 60 33
	call Ring_Put_0100                                   ; F84B42  1d d5 41 f8
	pop XHL                                              ; F84B46  5b
	popw ix                                              ; F84B47  4c
	unlk XIZ                                             ; F84B48  ee 0d
	ret                                                  ; F84B4A  0e
Ring601850_PutBlock:
	link XIZ,0x0000                                      ; F84B4B  ee 0c 00 00
	push XIY                                             ; F84B4F  3d
	push XIX                                             ; F84B50  3c
	push XHL                                             ; F84B51  3b
	ld BC,(XIZ+0x08)                                     ; F84B52  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84B55  ae 0a 25
	lda xhl, (0x601850:24)                               ; F84B58  f2 50 18 60 33
.LF84B5D:
	ld A,(XIY)                                           ; F84B5D  85 21
	call Ring_Put_0100                                   ; F84B5F  1d d5 41 f8
	inc 1,XIY                                            ; F84B63  ed 61
	djnz16 bc, .LF84B5D                                  ; F84B65  d9 1c f5
	pop XHL                                              ; F84B68  5b
	pop XIX                                              ; F84B69  5c
	pop XIY                                              ; F84B6A  5d
	unlk XIZ                                             ; F84B6B  ee 0d
	ret                                                  ; F84B6D  0e
Ring601850_IsEmpty:
	pushw bc                                             ; F84B6E  29
	ldw wa, 0x00                                         ; F84B6F  30 00 00
	ld bc, (0x60184c:24)                                ; F84B72  d2 4c 18 60 21
	cp	bc, (0x601848:24)                            ; F84B77  d2 48 18 60 f1
	jr z, .LF84B81                                       ; F84B7C  66 03
	ldw wa, 0xffff                                       ; F84B7E  30 ff ff
.LF84B81:
	popw bc                                              ; F84B81  49
	ret                                                  ; F84B82  0e
Ring601850_Init:
	pushw ix                                             ; F84B83  2c
	push XHL                                             ; F84B84  3b
	lda xhl, (0x601850:24)                               ; F84B85  f2 50 18 60 33
	call Ring_Init_0100                                  ; F84B8A  1d 77 42 f8
	pop XHL                                              ; F84B8E  5b
	popw ix                                              ; F84B8F  4c
	ret                                                  ; F84B90  0e
Ring601850_ScanRewind:
	pushw wa                                             ; F84B91  28
	ld wa, (0x601848:24)                                ; F84B92  d2 48 18 60 20
	ld (0x601846:24), wa                                ; F84B97  f2 46 18 60 50
	popw wa                                              ; F84B9C  48
	ret                                                  ; F84B9D  0e
Ring601850_Scan:
	pushw ix                                             ; F84B9E  2c
	push XHL                                             ; F84B9F  3b
	lda xhl, (0x601850:24)                               ; F84BA0  f2 50 18 60 33
	call Ring_Scan_0100                                  ; F84BA5  1d b7 40 f8
	pop XHL                                              ; F84BA9  5b
	popw ix                                              ; F84BAA  4c
	ret                                                  ; F84BAB  0e
	ret                                                  ; F84BAC  0e
Ring601850_ScanToPut:
	pushw ix                                             ; F84BAD  2c
	push XHL                                             ; F84BAE  3b
	lda xhl, (0x601850:24)                               ; F84BAF  f2 50 18 60 33
	call Ring_ScanToPut_0100                             ; F84BB4  1d 43 41 f8
	pop XHL                                              ; F84BB8  5b
	popw ix                                              ; F84BB9  4c
	ret                                                  ; F84BBA  0e
	ret                                                  ; F84BBB  0e
Ring601850_GetCommit:
	pushw wa                                             ; F84BBC  28
	ld wa, (0x60184a:24)                                ; F84BBD  d2 4a 18 60 20
	ld (0x601848:24), wa                                ; F84BC2  f2 48 18 60 50
	popw wa                                              ; F84BC7  48
	ret                                                  ; F84BC8  0e
; ---------------------------------------------------------------------
; Ring601850_Copy_Get and its group -- the eleven veneers of ring 0x601850
;
; Called from: ★ NOTHING.  No prom_b directory slot names 0xF84BC9, and
;          notes/prom_a_xref.py 0xF84BC9 finds no site in either image that
;          spells the address.  This whole 163-byte group is UNREACHED as far
;          as the converted tree can see -- it is a second copy of the
;          0x601850 veneers, which is why it carries `_Copy_` in its name.
;          CORRECTED 2026-08-25 (audit F9): this header used to claim the
;          group "owns nine slots" of module T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4); it owns none.
;          Asserted by notes/prom_a_ring_slots.py.
; Inputs / Outputs: as the class routine each veneer calls; see the five class
;          headers above.
; Evidence: every veneer of this group loads the SAME object address with
;          `lda XHL,0x601850` and calls a class routine of the SAME capacity
;          0x100 -- that agreement across nine independent instructions is what
;          establishes the capacity, and it is check "every instance names ONE
;          capacity" in notes/prom_a_ringbuf_map.py.  The ring therefore
;          occupies 0x601846-0x60194F: ten bytes of control block below the pointer,
;          0x100 bytes of data at and above it.
; Extent:  0xF84BC9-0xF84C6B, 163 bytes, the same length as every other group.
; ---------------------------------------------------------------------
Ring601850_Copy_Get:
	pushw ix                                             ; F84BC9  2c
	push XHL                                             ; F84BCA  3b
	lda xhl, (0x601850:24)                               ; F84BCB  f2 50 18 60 33
	call Ring_Get_0100                                   ; F84BD0  1d 1f 40 f8
	pop XHL                                              ; F84BD4  5b
	popw ix                                              ; F84BD5  4c
	ret                                                  ; F84BD6  0e
Ring601850_Copy_Put:
	link XIZ,0x0000                                      ; F84BD7  ee 0c 00 00
	pushw ix                                             ; F84BDB  2c
	push XHL                                             ; F84BDC  3b
	ld A,(XIZ+0x08)                                      ; F84BDD  8e 08 21
	lda xhl, (0x601850:24)                               ; F84BE0  f2 50 18 60 33
	call Ring_Put_0100                                   ; F84BE5  1d d5 41 f8
	pop XHL                                              ; F84BE9  5b
	popw ix                                              ; F84BEA  4c
	unlk XIZ                                             ; F84BEB  ee 0d
	ret                                                  ; F84BED  0e
Ring601850_Copy_PutBlock:
	link XIZ,0x0000                                      ; F84BEE  ee 0c 00 00
	push XIY                                             ; F84BF2  3d
	push XIX                                             ; F84BF3  3c
	push XHL                                             ; F84BF4  3b
	ld BC,(XIZ+0x08)                                     ; F84BF5  9e 08 21
	ld XIY,(XIZ+0x0a)                                    ; F84BF8  ae 0a 25
	lda xhl, (0x601850:24)                               ; F84BFB  f2 50 18 60 33
.LF84C00:
	ld A,(XIY)                                           ; F84C00  85 21
	call Ring_Put_0100                                   ; F84C02  1d d5 41 f8
	inc 1,XIY                                            ; F84C06  ed 61
	djnz16 bc, .LF84C00                                  ; F84C08  d9 1c f5
	pop XHL                                              ; F84C0B  5b
	pop XIX                                              ; F84C0C  5c
	pop XIY                                              ; F84C0D  5d
	unlk XIZ                                             ; F84C0E  ee 0d
	ret                                                  ; F84C10  0e
Ring601850_Copy_IsEmpty:
	pushw bc                                             ; F84C11  29
	ldw wa, 0x00                                         ; F84C12  30 00 00
	ld bc, (0x60184c:24)                                ; F84C15  d2 4c 18 60 21
	cp	bc, (0x601848:24)                            ; F84C1A  d2 48 18 60 f1
	jr z, .LF84C24                                       ; F84C1F  66 03
	ldw wa, 0xffff                                       ; F84C21  30 ff ff
.LF84C24:
	popw bc                                              ; F84C24  49
	ret                                                  ; F84C25  0e
Ring601850_Copy_Init:
	pushw ix                                             ; F84C26  2c
	push XHL                                             ; F84C27  3b
	lda xhl, (0x601850:24)                               ; F84C28  f2 50 18 60 33
	call Ring_Init_0100                                  ; F84C2D  1d 77 42 f8
	pop XHL                                              ; F84C31  5b
	popw ix                                              ; F84C32  4c
	ret                                                  ; F84C33  0e
Ring601850_Copy_ScanRewind:
	pushw wa                                             ; F84C34  28
	ld wa, (0x601848:24)                                ; F84C35  d2 48 18 60 20
	ld (0x601846:24), wa                                ; F84C3A  f2 46 18 60 50
	popw wa                                              ; F84C3F  48
	ret                                                  ; F84C40  0e
Ring601850_Copy_Scan:
	pushw ix                                             ; F84C41  2c
	push XHL                                             ; F84C42  3b
	lda xhl, (0x601850:24)                               ; F84C43  f2 50 18 60 33
	call Ring_Scan_0100                                  ; F84C48  1d b7 40 f8
	pop XHL                                              ; F84C4C  5b
	popw ix                                              ; F84C4D  4c
	ret                                                  ; F84C4E  0e
	ret                                                  ; F84C4F  0e
Ring601850_Copy_ScanToPut:
	pushw ix                                             ; F84C50  2c
	push XHL                                             ; F84C51  3b
	lda xhl, (0x601850:24)                               ; F84C52  f2 50 18 60 33
	call Ring_ScanToPut_0100                             ; F84C57  1d 43 41 f8
	pop XHL                                              ; F84C5B  5b
	popw ix                                              ; F84C5C  4c
	ret                                                  ; F84C5D  0e
	ret                                                  ; F84C5E  0e
Ring601850_Copy_GetCommit:
	pushw wa                                             ; F84C5F  28
	ld wa, (0x60184a:24)                                ; F84C60  d2 4a 18 60 20
	ld (0x601848:24), wa                                ; F84C65  f2 48 18 60 50
	popw wa                                              ; F84C6A  48
	ret                                                  ; F84C6B  0e

; 0xF84C6C-0xF855FF -- 2452 bytes of 0x0E, the encoding of RET.  padding up to the kernel at 0xF85600
; EVERY byte of the run is checked, not sampled:
; notes/gen_prom_a_ringbuf_module.py refuses to emit this directive
; unless set(ROM[lo:hi]) == {0x0E}.
	.fill 2452, 1, 0x0E
