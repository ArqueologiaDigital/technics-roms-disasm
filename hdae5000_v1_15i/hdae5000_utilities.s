; ---------------------------------------------------------------------------
; HDAE5000_MemCmp(s, t, HDAE5000_StrLen(s)): 0 when t BEGINS WITH s (whatever
; follows in t is ignored).  Callers use it as a string-equality test (CHS
; code entry, slot names).
; In:  (xsp+4) = s, (xsp+8) = t
; Out: HL = 0 on a match.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_StrPrefixCmp:
	push xiz
	ld xiz, (xsp + 8)
	push xiz
	call HDAE5000_StrLen
	pushw hl
	ld xwa, (xsp + 0x12)
	push xwa
	push xiz
	call HDAE5000_MemCmp
	lda xsp, (xsp + 0x0e)
	pop xiz
	ret

; ---------------------------------------------------------------------------
; strcpy(dest, src): HDAE5000_MemCCpy(dest, src, 0, 0xFFFE) copies src up to
; and including its NUL; when no NUL turned up (MemCCpy returned 0) a
; terminator is forced at dest + 0xFFFF.
; In:  (xsp+4) = dest, (xsp+8) = src (caller pops)
; Out: XHL = dest.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_StrCpy:
	push xiz
	pushw 0xfffe			; max length
	pushw 0x0000			; flags
	ld xwa, (xsp + 0x10)		; source pointer
	push xwa
	ld xiz, (xsp + 0x10)		; dest pointer
	push xiz
	call HDAE5000_MemCCpy
	add xsp, 0x0000000c		; clean up 12 bytes
	or xhl, xhl			; test result
	jr nz, .Lmcb_done
	ld xwa, xiz			; get dest pointer
	add xwa, 0x0000ffff		; point to last byte
	ld (xwa), 0x00		; null-terminate
.Lmcb_done:
	ld xhl, xiz			; return dest pointer
	pop xiz
	ret

; ---------------------------------------------------------------------------
; strlen(s) = HDAE5000_MemChr(s, 0, 0xFFFF) - s; 0xFFFF when no NUL is found
; in 0xFFFF bytes.
; In:  (xsp+4) = s
; Out: HL = length (XHL's high word is the high word of the pointer
;      difference).  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_StrLen:
	push xiz
	pushw 0xffff			; sentinel
	pushw 0x0000			; flags
	ld xiz, (xsp + 0x0c)		; buffer pointer
	push xiz
	call HDAE5000_MemChr
	inc 8, xsp			; clean up 8 bytes
	or xhl, xhl			; test result
	jr nz, .Ldbv_ok
	ldw hl, 0xffff			; return -1
	jr t, .Ldbv_done
.Ldbv_ok:
	sub xhl, xiz			; HL = length (offset from base)
.Ldbv_done:
	pop xiz
	ret
	; --- String copy with length limit (secondary entry) ---
	; Stack: [+0x04] dest, [+0x08] source, [+0x0C] count
	; Returns: XHL = end of copied string
	; strncat(dest, src, n): walks to dest's terminator first (.Lscl_entry
	; loop), then appends at most n bytes and terminates.  XHL = dest.
HDAE5000_StrNCat:
	ld xix, (xsp + 4)		; XIX = dest
	ld xhl, xix			; XHL = dest (for return)
	jr t, .Lscl_entry
.Lscl_next:
	inc 1, xix
.Lscl_entry:
	cp (xix), 0x00		; find end of dest string
	jr nz, .Lscl_next
	ld xde, (xsp + 8)		; XDE = source
	ld bc, (xsp + 0x0C)		; BC = count
	jr t, .Lscl_check
.Lscl_copy:
	ld a, (xde)			; load source byte
	ld (xix), a			; store to dest
	cp (xix), 0x00		; was it null terminator?
	ret z				; yes - done
	inc 1, xix
	inc 1, xde
.Lscl_check:
	ld wa, bc			; save current count
	dec 1, bc			; decrement remaining
	cp wa, 0:i3			; was count zero?
	jr nz, .Lscl_copy		; no - copy next byte
	ld (xix), 0x00		; null-terminate
	ret

; ---------------------------------------------------------------------------
; strncmp(a, b, n): stops at n or at a NUL in a.
; In:  (xsp+4) = a, (xsp+8) = b, (xsp+12) = n (word)
; Out: HL = 0 on a match, else the sign-extended difference of the first
;      differing bytes.  Clobbers XIX, XDE, BC, A.
; ---------------------------------------------------------------------------
HDAE5000_StrNCmp:
	ld bc, (xsp + 0x0C)		; BC = count
	ld xde, (xsp + 8)		; XDE = block B
	ld xix, (xsp + 4)		; XIX = block A
	jr t, .Lmcmp_check
.Lmcmp_loop:
	cp (xix), 0x00		; block A byte is null?
	jr nz, .Lmcmp_advance
	ld hl, 0:i3			; return 0 (match up to null)
	ret
.Lmcmp_advance:
	inc 1, xix
	inc 1, xde
	dec 1, bc
.Lmcmp_check:
	cp bc, 0:i3			; count exhausted?
	jr z, .Lmcmp_result
	ld a, (xde)			; B byte
	cp a, (xix)			; compare with A byte
	jr z, .Lmcmp_loop		; equal - continue
.Lmcmp_result:
	ld l, 0x00:opc			; default L = 0
	cp bc, 0:i3			; if count exhausted, return 0
	jr z, .Lmcmp_done
	ld a, (xix)			; A byte
	sub a, (xde)			; difference = A - B
	ld l, a
.Lmcmp_done:
	exts hl				; sign-extend L to HL
	ret

; ---------------------------------------------------------------------------
; strncpy(dest, src, n): copies up to n bytes, stopping at src's NUL, then
; zero-fills the rest of the n bytes (no terminator when src is n or longer).
; In:  (xsp+4) = dest, (xsp+8) = src, (xsp+12) = n (word)
; Out: XHL = dest.  Clobbers XIX, XDE, BC, A.
; ---------------------------------------------------------------------------
HDAE5000_StrNCpy:
	ld	bc, (xsp+12)
	ld xde, (xsp + 0x08)
	ld xix, (xsp + 0x04)
	ld	xhl, xix
	jr	t, HDAE5000_StrNCpy_Next
HDAE5000_StrNCpy_Loop:
	ld a, (xde+)
	ld (xix+), a
	dec	1, bc
HDAE5000_StrNCpy_Next:
	cp	bc, 0:i3
	jr	z, HDAE5000_StrNCpy_Join
	cp	(xde), 0x00
	jr	nz, HDAE5000_StrNCpy_Loop
HDAE5000_StrNCpy_Join:
	jr	t, HDAE5000_StrNCpy_Next2
HDAE5000_StrNCpy_Loop2:
	ld (xix+), 0x00
	dec	1, bc
HDAE5000_StrNCpy_Next2:
	cp	bc, 0:i3
	jr	nz, HDAE5000_StrNCpy_Loop2
	ret



; ----------------------------------------------------------------------------
; Floating point -> decimal digits (used by HDAE5000_FormatFloat)
;
; HDAE5000_FltDec_Convert and the ten FltDec_* helpers below turn the IEEE
; bytes of a double (or, with flag bit 7, the 10-byte long double) into a
; string of decimal digits plus a decimal exponent, using multi-precision
; arithmetic on arrays of u16 limbs that each hold one byte (every helper
; masks with 0x00ff and carries the high byte into the neighbour).  Buffers
; are in RAM: 0x2394AA (the binary mantissa, limbs), 0x2394EA (fraction
; work area, 10 limbs), 0x23948A (the decimal digits, 32 bytes).
; Each helper's name says what its loop does; which C library source
; routine each corresponds to is not recoverable from the ROM.
; ----------------------------------------------------------------------------
HDAE5000_FltDec_Convert:
	; five stack arguments (HDAE5000_FormatFloat pushes them): +0x18 value
	; bytes *, +0x1C digit output buffer, +0x20 flags (bit 7 = 10-byte long
	; double), +0x22 int *decimal exponent, +0x26 int *sign (offsets as
	; read inside the 20-byte frame below).
	lda	xsp, (xsp-16)
	push xiz
	ld	iz, 0:i3
	ldw (xsp + 0x06), 15
	ldw (xsp + 0x08), 8
	pushw	HDAE5000_RAM_AtaIdentifyBuffer@hi16
	pushw	HDAE5000_RAM_AtaIdentifyBuffer@lo16		; low half of HDAE5000_RAM_AtaIdentifyBuffer
	pushw	HDAE5000_RAM_FltDecDigits@hi16
	pushw	HDAE5000_RAM_FltDecDigits@lo16		; low half of HDAE5000_RAM_FltDecDigits
	call HDAE5000_MemFill
	inc 8, xsp
	ld	qiz, 0
HDAE5000_FltDec_Convert_Loop:
	ld	bc, qiz
	add	bc, bc
	lda xde, (HDAE5000_RAM_FltDecFraction:24)
	lda xwa, (HDAE5000_RAM_FltDecMantissa:24)
	ldw	(xwa+bc), 0x0000
	ldw	(xde+bc), 0x0000
	inc	1, qiz
	cpw	qiz, 0x0020
	jr	lt, HDAE5000_FltDec_Convert_Loop
	ld	wa, (xsp+32)
	bit	0x07, wa
	jr	z, HDAE5000_FltDec_Convert_Join
	ldw (xsp + 0x06), 18
	ldw (xsp + 0x08), 10
HDAE5000_FltDec_Convert_Join:
	ld	qiz, 0
	cpw	(xsp+8), 0x0000
	jr	le, HDAE5000_FltDec_Convert_Join2
HDAE5000_FltDec_Convert_Loop2:
	lda	xwa, (xsp+10)
	ld	bc, (xsp+8)
	dec	1, bc
	sub	bc, qiz
	extz xbc
	add	xbc, (xsp+24)
	ld	c, (xbc)
	ld	(xwa+qiz), c
	inc	1, qiz
	ld	wa, qiz
	cp	wa, (xsp+8)
	jr	lt, HDAE5000_FltDec_Convert_Loop2
HDAE5000_FltDec_Convert_Join2:
	lda	xde, (xsp+10)
	bitm	7, (xde)
	jr	z, HDAE5000_FltDec_Convert_Skip
	ld	wa, 1:i3
	jr	t, HDAE5000_FltDec_Convert_Join3
HDAE5000_FltDec_Convert_Skip:
	ld	wa, 0:i3
HDAE5000_FltDec_Convert_Join3:
	ld xbc, (xsp + 0x26)
	ld (xbc), wa
	lda	xbc, (xde+1)
	ld	wa, (xsp+32)
	bit	0x07, wa
	jr	z, HDAE5000_FltDec_Convert_Skip2
	cp	(xde), 0x00
	jr	nz, HDAE5000_FltDec_Convert_Join4
	cp	(xbc), 0x00
	jr	z, HDAE5000_FltDec_Convert_Skip2
HDAE5000_FltDec_Convert_Join4:
	ld8_src_ri xbc, l		; ld L,(XBC)
	extz hl
	ldw	wa, 0x0008
	ldw	bc, 0x4000
	jr	t, HDAE5000_FltDec_Convert_Join6
HDAE5000_FltDec_Convert_Skip2:
	cp	(xde), 0x00
	jr	nz, HDAE5000_FltDec_Convert_Join5
	cp	(xbc), 0x00
	jr	z, HDAE5000_FltDec_Convert_Join8
HDAE5000_FltDec_Convert_Join5:
	ld8_src_ri xbc, l		; ld L,(XBC)
	and l, 0xf0
	extz hl
	sra	hl, 0x04
	ld	wa, 4:i3
	ldw	bc, 0x0400
HDAE5000_FltDec_Convert_Join6:
	ld	e, (xde)
	res	0x07, e
	extz de
	and	a, 0x0f
	jr	z, HDAE5000_FltDec_Convert_Join7
	slaa	de
HDAE5000_FltDec_Convert_Join7:
	ld	iz, de
	add	iz, hl
	sub	iz, bc
HDAE5000_FltDec_Convert_Join8:
	pushw iz
	calr	HDAE5000_FltDec_DecimalExponent
	inc 2, xsp
	ld (xsp + 0x04), hl
	cp	iz, 0:i3
	jr	ge, HDAE5000_FltDec_Convert_Join9
	decm	1, (xsp+4)
HDAE5000_FltDec_Convert_Join9:
	ld	wa, (xsp+32)
	bit	0x07, wa
	jr	z, HDAE5000_FltDec_Convert_Skip3
	ld	qiz, 2
HDAE5000_FltDec_Convert_Loop3:
	lda	xwa, (xsp+10)
	ld	a, (xwa+qiz)
	and	a, 0xff
	ld	de, qiz
	add	de, de
	lda xbc, (0x23c890:24)
	extz wa
	ld	(xbc+de), wa
	inc	1, qiz
	cpw	qiz, 0x000a
	jr	lt, HDAE5000_FltDec_Convert_Loop3
	jr	t, HDAE5000_FltDec_Convert_Join11
HDAE5000_FltDec_Convert_Skip3:
	ld	ix, 0:i3
	ld	qiz, 0
HDAE5000_FltDec_Convert_Loop4:
	lda	xbc, (xsp+10)
	cpib_sri 0x07, 0xE4, 0xFA, 0x00	; cp (XBC+QIZ),0x00
	jr	z, HDAE5000_FltDec_Convert_Next
	ld	ix, 1:i3
	jr	t, HDAE5000_FltDec_Convert_Join10
HDAE5000_FltDec_Convert_Next:
	inc	1, qiz
	cpw	qiz, 0x0008
	jr	lt, HDAE5000_FltDec_Convert_Loop4
HDAE5000_FltDec_Convert_Join10:
	and8_imm_rid8 xbc, 0x01, 0x0f		; and (XBC+0x01),0x0f
	ld	qiz, 1
HDAE5000_FltDec_Convert_Loop5:
	ld	a, (xbc+qiz)
	and	a, 0xff
	ld	hl, qiz
	add	hl, hl
	dec	2, hl
	lda xde, (HDAE5000_RAM_FltDecMantissa:24)
	extz wa
	ld	(xde+hl), wa
	inc	1, qiz
	cpw	qiz, 0x0008
	jr	lt, HDAE5000_FltDec_Convert_Loop5
	cp	ix, 0:i3
	jr	z, HDAE5000_FltDec_Convert_Join11
	or16_imm_ri xde, 0x10, 0x00		; or (XDE),0x0010
HDAE5000_FltDec_Convert_Join11:
	pushm	(xsp+8)
	pushw 0x0023
	pushw 0xc894
	calr	HDAE5000_FltDec_NormalizeLeft
	inc	6, xsp
	ld	qiz, 0
	cp	iz, 0:i3
	jr	le, HDAE5000_FltDec_Convert_Next2
	cpw	(xsp+4), 0x0000
	jr	le, HDAE5000_FltDec_Convert_Join12
HDAE5000_FltDec_Convert_Loop6:
	pushw 0x0023
	pushw 0xc894
	calr	HDAE5000_FltDec_DivBy10
	pushm	(xsp+12)
	pushw 0x0023
	pushw 0xc894
	calr	HDAE5000_FltDec_NormalizeLeft
	lda	xsp, (xsp+10)
	sub	iz, hl
	inc	1, qiz
	ld	wa, qiz
	cp	wa, (xsp+4)
	jr	lt, HDAE5000_FltDec_Convert_Loop6
HDAE5000_FltDec_Convert_Join12:
	pushm	(xsp+6)
	ld	wa, 6:i3
	sub	wa, iz
	pushw wa
	pushw 0x0023
	pushw 0xc894
	jr	t, HDAE5000_FltDec_Convert_Join13
HDAE5000_FltDec_Convert_Loop7:
	push xbc
	calr	HDAE5000_FltDec_MulBy10
	pushm	(xsp+12)
	pushw 0x0023
	pushw 0xc894
	calr	HDAE5000_FltDec_NormalizeRight
	lda	xsp, (xsp+10)
	add	iz, hl
	inc	1, qiz
HDAE5000_FltDec_Convert_Next2:
	ld	de, (xsp+4)
	neg	de
	lda xbc, (HDAE5000_RAM_FltDecMantissa:24)
	ld	wa, qiz
	cp	wa, de
	jr	lt, HDAE5000_FltDec_Convert_Loop7
	pushm	(xsp+6)
	ld	wa, 6:i3
	sub	wa, iz
	pushw wa
	push xbc
HDAE5000_FltDec_Convert_Join13:
	calr	HDAE5000_FltDec_ShiftRightBits
	inc 8, xsp
	ld	qiz, 1
HDAE5000_FltDec_Convert_Loop8:
	push	qiz
	ld	bc, qiz
	add	bc, bc
	lda xwa, (HDAE5000_RAM_FltDecMantissa:24)
	pushw	(xwa+bc)
	calr	HDAE5000_FltDec_FractionDigits
	inc 4, xsp
	inc	1, qiz
	cpw	qiz, 0x0009
	jr	lt, HDAE5000_FltDec_Convert_Loop8
	ld	de, 0:i3
	lda xbc, (HDAE5000_RAM_FltDecMantissa:24)
	ld xhl, (xsp + 0x1c)
	ld	wa, (xbc)
	cp	wa, 0x0009
	jr	ule, HDAE5000_FltDec_Convert_Join14
	ld	de, 1:i3
	extz xwa
	div wa, 0x000a
	ld	(xhl), a
	incw	1, (xsp+4)
HDAE5000_FltDec_Convert_Join14:
	ld	ix, de
	inc	1, de
	ld	wa, (xbc)
	extz xwa
	div wa, 0x000a
	ld	wa, qwa
	ld	(xhl+ix), a
	incw	1, (xsp+4)
	ld	qiz, 1
	jr	t, HDAE5000_FltDec_Convert_Next3
HDAE5000_FltDec_Convert_Loop9:
	ld	bc, de
	inc	1, de
	lda xwa, (HDAE5000_RAM_FltDecDigits:24)
	ld	a, (xwa+qiz)
	ld	(xhl+bc), a
	inc	1, qiz
HDAE5000_FltDec_Convert_Next3:
	ld	bc, (xsp+6)
	inc	2, bc
	ld	wa, qiz
	cp	wa, bc
	jr	lt, HDAE5000_FltDec_Convert_Loop9
	ld	de, (xsp+6)
	inc	1, de
	lda	xbc, (xhl+de)
	cp	(xbc), 0x05
	jr	c, HDAE5000_FltDec_Convert_Join15
	ld	wa, (xsp+6)
	inc	1, (xhl+wa)
HDAE5000_FltDec_Convert_Join15:
	ld	(xbc), 0x00
	ld	wa, (xsp+6)
	ld	qiz, wa
	jr	t, HDAE5000_FltDec_Convert_Next4
HDAE5000_FltDec_Convert_Loop10:
	ld	bc, qiz
	dec	1, bc
	inc	1, (xhl+bc)
	ld	(xwa), 0x00
	dec	1, qiz
HDAE5000_FltDec_Convert_Next4:
	cp	qiz, 0
	jr	z, HDAE5000_FltDec_Convert_Join16
	lda	xwa, (xhl+qiz)
	cp	(xwa), 0x09
	jr	ugt, HDAE5000_FltDec_Convert_Loop10
HDAE5000_FltDec_Convert_Join16:
	ld	qiz, 0
	jr	t, HDAE5000_FltDec_Convert_Next5
HDAE5000_FltDec_Convert_Loop11:
	or_srib_im 0x07, 0xEC, 0xFA, 0x30	; or (XHL+QIZ),0x30
	inc	1, qiz
HDAE5000_FltDec_Convert_Next5:
	ld	wa, qiz
	cp	wa, de
	jr	lt, HDAE5000_FltDec_Convert_Loop11
	ld xbc, (xsp + 0x22)
	ld	wa, (xsp+4)
	ld (xbc), wa
	pop xiz
	lda	xsp, (xsp+16)
	ret

; ---------------------------------------------------------------------------
; Shift a limb array (one byte per u16 limb) right by N bits.  Compiled C,
; arguments on the stack.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_ShiftRightBits:
	dec 8, xsp
	pushw iz
	ld	iz, 0:i3
	ld	wa, 0:i3
	ld	hl, (xsp+18)
	cp	hl, 0:i3
	jr	le, HDAE5000_FltDec_ShiftRightBits_Join
HDAE5000_FltDec_ShiftRightBits_Loop:
	add	wa, wa
	set	0x00, wa
	inc	1, iz
	cp	iz, hl
	jr	lt, HDAE5000_FltDec_ShiftRightBits_Loop
HDAE5000_FltDec_ShiftRightBits_Join:
	ld	iz, (xsp+20)
	dec	1, iz
	ld xiy, (xsp + 0x0e)
	cp	iz, 0:i3
	jr	le, HDAE5000_FltDec_ShiftRightBits_Join3
	ld (xsp + 0x04), wa
	ldw (xsp + 0x02), 8
	sub	(xsp+2), hl
	ld	wa, iz
	exts xwa
	add	xwa, xwa
	ld	xix, xwa
HDAE5000_FltDec_ShiftRightBits_Loop2:
	ld (xsp + 0x06), xix
	add	(xsp+6), xiy
	ld xbc, (xsp + 0x06)
	ld	de, (xbc)
	ld	wa, hl
	and	a, 0x0f
	jr	z, HDAE5000_FltDec_ShiftRightBits_Join2
	srla	de
HDAE5000_FltDec_ShiftRightBits_Join2:
	ld (xbc), de
	ld	xbc, xix
	ld	xwa, 2:i3
	sub	xbc, xwa
	add	xbc, xiy
	ld	wa, (xsp+4)
	and	wa, (xbc)
	ld	bc, wa
	ld	wa, (xsp+2)
	and	a, 0x0f
	jr	z, HDAE5000_FltDec_ShiftRightBits_Next
	slla	bc
HDAE5000_FltDec_ShiftRightBits_Next:
	ld xwa, (xsp + 0x06)
	or	(xwa), bc
	dec	1, iz
	dec	2, xix
	cp	iz, 0:i3
	jr	gt, HDAE5000_FltDec_ShiftRightBits_Loop2
HDAE5000_FltDec_ShiftRightBits_Join3:
	ld	bc, (xiy)
	ld	wa, hl
	and	a, 0x0f
	jr	z, HDAE5000_FltDec_ShiftRightBits_Join4
	srla	bc
HDAE5000_FltDec_ShiftRightBits_Join4:
	ld (xiy), bc
	popw iz
	inc 8, xsp
	ret

; ---------------------------------------------------------------------------
; Shift a limb array left by N bits, carrying each limb's high byte up.
; Compiled C, arguments on the stack.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_ShiftLeftBits:
	ld xiy, (xsp + 0x04)
	and16_imm_ri xiy, 0xff, 0x00		; and (XIY),0x00ff
	ld	ix, 1:i3
	ld	hl, (xsp+8)
	add	hl, hl
	jr	t, HDAE5000_FltDec_ShiftLeftBits_Next
HDAE5000_FltDec_ShiftLeftBits_Loop:
	ld	de, ix
	exts xde
	add	xde, xde
	add	xde, xiy
	ld	wa, (xsp+10)
	ld	bc, (xde)
	and	a, 0x0f
	jr	z, HDAE5000_FltDec_ShiftLeftBits_Join
	slla	bc
HDAE5000_FltDec_ShiftLeftBits_Join:
	ld (xde), bc
	ld	wa, ix
	dec	1, wa
	exts xwa
	add	xwa, xwa
	ld	xbc, xwa
	add	xbc, xiy
	ld	wa, (xde)
	srl	wa, 0x08
	add	(xbc), wa
	and16_imm_ri xde, 0xff, 0x00		; and (XDE),0x00ff
	inc	1, ix
HDAE5000_FltDec_ShiftLeftBits_Next:
	cp	ix, hl
	jr	lt, HDAE5000_FltDec_ShiftLeftBits_Loop
	ret

; ---------------------------------------------------------------------------
; Zero HDAE5000_RAM_FltDecFraction, then repeatedly x10
; (HDAE5000_FltDec_FracMulBy10) and add the integer part as the next decimal
; digit (HDAE5000_FltDec_AddDigit).  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_FractionDigits:
	pushw iz
	lda xde, (HDAE5000_RAM_FltDecFraction:24)
	ld	xwa, xde
	lda	xbc, (xde+18)
HDAE5000_FltDec_FractionDigits_Loop:
	ldw (xwa+), 0x0000
	cp	xwa, xbc
	jr	c, HDAE5000_FltDec_FractionDigits_Loop
	ld	wa, (xsp+6)
	ld (xde + 0x10), wa
	ld	iz, 0:i3
HDAE5000_FltDec_FractionDigits_Loop2:
	lda xwa, (HDAE5000_RAM_FltDecFraction:24)
	cpw	(xwa), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+2), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+4), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+6), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+8), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+10), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+12), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+14), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	cpw	(xwa+16), 0x0000
	jr	nz, HDAE5000_FltDec_FractionDigits_Next
	jr	t, HDAE5000_FltDec_FractionDigits_Epilogue
HDAE5000_FltDec_FractionDigits_Loop3:
	inc	1, iz
	calr	HDAE5000_FltDec_FracMulBy10
HDAE5000_FltDec_FractionDigits_Next:
	ldw	wa, 0x0008
	sub	wa, (xsp+8)
	add	wa, wa
	lda xbc, (HDAE5000_RAM_FltDecFraction:24)
	ld	wa, (xbc+wa)
	cp	wa, 0:i3
	jr	z, HDAE5000_FltDec_FractionDigits_Loop3
	pushw iz
	pushw wa
	calr	HDAE5000_FltDec_AddDigit
	inc 4, xsp
	ldw	bc, 0x0008
	sub	bc, (xsp+8)
	add	bc, bc
	lda xwa, (HDAE5000_RAM_FltDecFraction:24)
	ldw	(xwa+bc), 0x0000
	cp	iz, 0x0020
	jrl	le, HDAE5000_FltDec_FractionDigits_Loop2
HDAE5000_FltDec_FractionDigits_Epilogue:
	popw iz
	ret

; ---------------------------------------------------------------------------
; Add a value at a position of HDAE5000_RAM_FltDecDigits with decimal carry
; (subtract 10, increment the digit to the left); positions >= 32 are
; ignored.
; In:  (xsp+4) = value (word), (xsp+6) = position (word)
; ---------------------------------------------------------------------------
HDAE5000_FltDec_AddDigit:
	ld	de, (xsp+6)
	cp	de, 0x0020
	jr	ge, HDAE5000_FltDec_AddDigit_Join
	lda xbc, (HDAE5000_RAM_FltDecDigits:24)
	ld	wa, (xsp+4)
	add	(xbc+de), a
HDAE5000_FltDec_AddDigit_Join:
	jr	t, HDAE5000_FltDec_AddDigit_Next
HDAE5000_FltDec_AddDigit_Loop:
	dec	1, de
HDAE5000_FltDec_AddDigit_Next:
	cp	de, 0x0020
	jr	ge, HDAE5000_FltDec_AddDigit_Loop
	lda xwa, (HDAE5000_RAM_FltDecDigits:24)
	jr	t, HDAE5000_FltDec_AddDigit_Next2
HDAE5000_FltDec_AddDigit_Loop2:
	ld	bc, de
	dec	1, bc
	inc	1, (xwa+bc)
	ld	bc, de
	dec	1, de
	sub	(xwa+bc), 0x0a
HDAE5000_FltDec_AddDigit_Next2:
	cp	(xwa+de), 0x0a
	ret lt

	cp	de, 0:i3
	jr	gt, HDAE5000_FltDec_AddDigit_Loop2
	ret

; ---------------------------------------------------------------------------
; Divide a limb array by 10 in place (DIV per limb, remainder carried down).
; In:  (xsp+4) = the array
; ---------------------------------------------------------------------------
HDAE5000_FltDec_DivBy10:
	ld xwa, (xsp + 0x04)
	ld	xbc, xwa
	lda	xde, (xwa+18)
HDAE5000_FltDec_DivBy10_Loop:
	ld	wa, (xbc)
	extz xwa
	div wa, 0x000a
	ld	wa, qwa
	sll	wa, 0x08
	add	(xbc+2), wa
	ld	wa, (xbc)
	extz xwa
	div wa, 0x000a
	ld (xbc+), wa
	cp	xbc, xde
	jr	c, HDAE5000_FltDec_DivBy10_Loop
	ret

; ---------------------------------------------------------------------------
; Multiply a 16-limb array by 10 in place with carry propagation.
; Compiled C, arguments on the stack; IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_MulBy10:
	pushw iz
	ld	ix, 0:i3
	ld	xbc, 0:i3
HDAE5000_FltDec_MulBy10_Loop:
	ld xhl, (xsp + 0x06)
	ld	xde, xbc
	add	xde, xhl
	ld	wa, (xde)
	mul	wa, 0x000a
	ld (xde), wa
	cp	ix, 0:i3
	jr	z, HDAE5000_FltDec_MulBy10_Next2
	ld	iz, ix
	jr	t, HDAE5000_FltDec_MulBy10_Next
HDAE5000_FltDec_MulBy10_Loop2:
	ld	iy, iz
	dec	1, iy
	exts xiy
	add	xiy, xiy
	add	xiy, xhl
	srl	wa, 0x08
	add	(xiy), wa
	and16_imm_ri xde, 0xff, 0x00		; and (XDE),0x00ff
	dec	1, iz
HDAE5000_FltDec_MulBy10_Next:
	cp	iz, 0:i3
	jr	le, HDAE5000_FltDec_MulBy10_Next2
	ld	de, iz
	exts xde
	add	xde, xde
	add	xde, xhl
	ld	wa, (xde)
	cp	wa, 0x00ff
	jr	ugt, HDAE5000_FltDec_MulBy10_Loop2
HDAE5000_FltDec_MulBy10_Next2:
	inc	1, ix
	inc 2, xbc
	cp	ix, 0x0010
	jr	lt, HDAE5000_FltDec_MulBy10_Loop
	lda	xbc, (xhl+30)
	ld	wa, (xbc)
	bit	0x07, wa
	jr	z, HDAE5000_FltDec_MulBy10_Join
	incw	1, (xhl+28)
HDAE5000_FltDec_MulBy10_Join:
	ldw	(xbc), 0x0000
	popw iz
	ret

; ---------------------------------------------------------------------------
; Multiply HDAE5000_RAM_FltDecFraction (10 limbs) by 10 and normalise the
; carries.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_FracMulBy10:
	lda xhl, (HDAE5000_RAM_FltDecFraction:24)
	ld	xbc, xhl
	lda	xde, (xhl+20)
HDAE5000_FltDec_FracMulBy10_Loop:
	cpw	(xbc), 0x0000
	jr	z, HDAE5000_FltDec_FracMulBy10_Next
	ld	wa, (xbc)
	mul	wa, 0x000a
	ld (xbc), wa
HDAE5000_FltDec_FracMulBy10_Next:
	inc 2, xbc
	cp	xbc, xde
	jr	c, HDAE5000_FltDec_FracMulBy10_Loop
	lda	xbc, (xhl+18)
	ldw	de, 0x0012
HDAE5000_FltDec_FracMulBy10_Loop2:
	ld	wa, (xbc)
	cp	wa, 0x0100
	jr	c, HDAE5000_FltDec_FracMulBy10_Next2
	ld	ix, de
	dec	2, ix
	srl	wa, 0x08
	add	(xhl+ix), wa
	and16_imm_ri xbc, 0xff, 0x00		; and (XBC),0x00ff
HDAE5000_FltDec_FracMulBy10_Next2:
	dec	2, de
	dec	2, xbc
	cp	de, 0:i3
	jr	gt, HDAE5000_FltDec_FracMulBy10_Loop2
	ret

; ---------------------------------------------------------------------------
; Shift a limb array left until its top limb has bit 7 set.
; Out: HL = the shift count.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_NormalizeLeft:
	dec	2, xsp
	pushw iz
	ld	iz, 0:i3
	cpw	(xsp+12), 0x0000
	jr	le, HDAE5000_FltDec_NormalizeLeft_Join
HDAE5000_FltDec_NormalizeLeft_Loop:
	ld	wa, iz
	exts xwa
	add	xwa, xwa
	add	xwa, (xsp+8)
	cpw	(xwa), 0x0000
	jr	nz, HDAE5000_FltDec_NormalizeLeft_Join
	inc	1, iz
	cp	iz, (xsp+12)
	jr	lt, HDAE5000_FltDec_NormalizeLeft_Loop
HDAE5000_FltDec_NormalizeLeft_Join:
	cp	iz, (xsp+12)
	jr	nz, HDAE5000_FltDec_NormalizeLeft_Skip
	ld	hl, 0:i3
	jr	t, HDAE5000_FltDec_NormalizeLeft_Epilogue
HDAE5000_FltDec_NormalizeLeft_Skip:
	ldw (xsp + 0x02), 0
	jr	t, HDAE5000_FltDec_NormalizeLeft_Next2
HDAE5000_FltDec_NormalizeLeft_Loop2:
	ld	iz, 0:i3
	ld xbc, (xsp + 0x08)
	jr	t, HDAE5000_FltDec_NormalizeLeft_Next
HDAE5000_FltDec_NormalizeLeft_Loop3:
	ld xwa, (xsp + 0x08)
	sllw_ri xwa		; sllw (XWA)
	inc	1, iz
HDAE5000_FltDec_NormalizeLeft_Next:
	ld	wa, (xbc)
	bit	0x07, wa
	jr	nz, HDAE5000_FltDec_NormalizeLeft_Join2
	cp	iz, 0x0008
	jr	lt, HDAE5000_FltDec_NormalizeLeft_Loop3
HDAE5000_FltDec_NormalizeLeft_Join2:
	cp	iz, 0:i3
	jr	z, HDAE5000_FltDec_NormalizeLeft_Join3
	pushw iz
	pushm	(xsp+14)
	ld xwa, (xsp + 0x0c)
	push xwa
	calr	HDAE5000_FltDec_ShiftLeftBits
	inc 8, xsp
HDAE5000_FltDec_NormalizeLeft_Join3:
	add	(xsp+2), iz
HDAE5000_FltDec_NormalizeLeft_Next2:
	ld xwa, (xsp + 0x08)
	ld	wa, (xwa)
	bit	0x07, wa
	jr	z, HDAE5000_FltDec_NormalizeLeft_Loop2
	ld	hl, (xsp+2)
HDAE5000_FltDec_NormalizeLeft_Epilogue:
	popw iz
	inc 2, xsp
	ret

; ---------------------------------------------------------------------------
; If the top limb exceeds 8 bits, shift right until it fits.
; Out: HL = the shift count.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_NormalizeRight:
	pushw iz
	ld xde, (xsp + 0x06)
	ld	iz, 0:i3
	ld	bc, (xsp+10)
	cp	bc, 0:i3
	jr	le, HDAE5000_FltDec_NormalizeRight_Join
HDAE5000_FltDec_NormalizeRight_Loop:
	ld	wa, iz
	exts xwa
	add	xwa, xwa
	add	xwa, xde
	cpw	(xwa), 0x0000
	jr	nz, HDAE5000_FltDec_NormalizeRight_Join
	inc	1, iz
	cp	iz, bc
	jr	lt, HDAE5000_FltDec_NormalizeRight_Loop
HDAE5000_FltDec_NormalizeRight_Join:
	cp	iz, bc
	jr	nz, HDAE5000_FltDec_NormalizeRight_Skip
	ld	hl, 0:i3
	jr	t, HDAE5000_FltDec_NormalizeRight_Epilogue
HDAE5000_FltDec_NormalizeRight_Skip:
	ld	hl, (xde)
	ld	iz, 0:i3
	jr	t, HDAE5000_FltDec_NormalizeRight_Next
HDAE5000_FltDec_NormalizeRight_Loop2:
	srl	hl, 0x01
	inc	1, iz
HDAE5000_FltDec_NormalizeRight_Next:
	ld	wa, hl
	and	wa, 0xff00
	jr	z, HDAE5000_FltDec_NormalizeRight_Join2
	cp	iz, 0x0008
	jr	lt, HDAE5000_FltDec_NormalizeRight_Loop2
HDAE5000_FltDec_NormalizeRight_Join2:
	cp	iz, 0:i3
	jr	z, HDAE5000_FltDec_NormalizeRight_Done
	pushw bc
	pushw iz
	push xde
	calr	HDAE5000_FltDec_ShiftRightBits
	inc 8, xsp
HDAE5000_FltDec_NormalizeRight_Done:
	ld	hl, iz
HDAE5000_FltDec_NormalizeRight_Epilogue:
	popw iz
	ret

; ---------------------------------------------------------------------------
; Decimal exponent from the binary one: e * 301 / 1000 (log10 2 ~ 0.301), the
; remainder deciding the rounding (HDAE5000_SMod32 / _SDiv32 by 1000).
; In:  (xsp+4) = binary exponent (word).  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FltDec_DecimalExponent:
	dec 8, xsp
	push xiz
	ld	wa, (xsp+16)
	exts xwa
	lda	xbc, (301:16)
	call HDAE5000_Multiply
	ld	xiz, xhl
	cp	xiz, 0x00000000
	jr	ge, HDAE5000_FltDec_DecimalExponent_Skip
	ld	xwa, xiz
	cpl	wa
	cpl	qwa
	inc 1, xwa
	ld (xsp + 0x04), xwa
	jr	t, HDAE5000_FltDec_DecimalExponent_Join
HDAE5000_FltDec_DecimalExponent_Skip:
	ld (xsp + 0x04), xiz
HDAE5000_FltDec_DecimalExponent_Join:
	ld xiz, (xsp + 0x04)
	ld	xwa, xiz
	lda	xbc, (1000:16)
	call HDAE5000_SMod32
	ld (xsp + 0x08), xhl
	ld	xwa, xiz
	lda	xbc, (1000:16)
	call HDAE5000_SDiv32
	ld	xiz, xhl
	ld xwa, (xsp + 0x08)
	cp	xwa, 0x000003d4
	jr	le, HDAE5000_FltDec_DecimalExponent_Skip2
	inc 1, xiz
	jr	t, HDAE5000_FltDec_DecimalExponent_Join2
HDAE5000_FltDec_DecimalExponent_Skip2:
	ld xwa, (xsp + 0x04)
	or xwa, xwa
	jr	z, HDAE5000_FltDec_DecimalExponent_Join2
	ld xwa, (xsp + 0x08)
	cp	xwa, 0x00000014
	jr	ge, HDAE5000_FltDec_DecimalExponent_Join2
	dec	1, xiz
HDAE5000_FltDec_DecimalExponent_Join2:
	cpw	(xsp+16), 0x0000
	jr	ge, HDAE5000_FltDec_DecimalExponent_Done
	ld	xwa, xiz
	cpl	wa
	cpl	qwa
	inc 1, xwa
	ld	xhl, xwa
	jr	t, HDAE5000_FltDec_DecimalExponent_Epilogue
HDAE5000_FltDec_DecimalExponent_Done:
	ld	xhl, xiz
HDAE5000_FltDec_DecimalExponent_Epilogue:
	pop xiz
	inc 8, xsp
	ret


; ---------------------------------------------------------------------------
; 32 x 32 -> 32-bit multiply (signed and unsigned alike): WA*BC (32-bit)
; + ((QWA*BC + QBC*WA) << 16), from three 16 x 16 MULs.
; In:  XWA, XBC
; Out: XHL = XWA * XBC (low 32 bits).  Clobbers XWA, XDE.
; ---------------------------------------------------------------------------
HDAE5000_Multiply:
	ld	hl, qwa
	mul	xhl, bc
	ld	de, qbc
	mul	xde, wa
	add	xhl, xde
	ld	qhl, hl
	ld	hl, 0:i3
	mul	xwa, bc
	add	xhl, xwa
	ret

	nop

; ---------------------------------------------------------------------------
; Unpack the IEEE single at (XBC) into the internal form at (XWA): +0 s16
; unbiased exponent, +2 u8 class flag (1 = zero), +3 u8 sign (bit 7), +4 u32
; mantissa with the hidden bit restored (bit 23).
; Out: L = class flag.  Clobbers XHL, XIX, DE.
; ---------------------------------------------------------------------------
HDAE5000_Float_Unpack:
	ld	xhl, 0:i3
	ld xix, (xbc)
	ld	de, qix
	ldcf16ri 15, de		; ldcf 0x0f,DE
	stcf	0x0f, qhl
	ld	hl, de
	sll	hl, 0x01
	ld	l, 0x00:opc
	ex8 h, l		; ex H,L
	cp	hl, 0:i3
	jr	z, HDAE5000_Float_Unpack_Skip
	and	de, 0x007f
	set	0x07, de
	ld	qix, de
	sub	hl, 0x007f
HDAE5000_Float_Unpack_Done:
	ld (xwa), xhl
	ld (xwa + 0x04), xix
	ldto_berp l, 0xee		; ld L,QL
	ret

HDAE5000_Float_Unpack_Skip:
	ld	xix, 0:i3
	ldib_erp 0xee, 1		; ld QL,1
	jr	t, HDAE5000_Float_Unpack_Done
	nop

; ---------------------------------------------------------------------------
; Pack the internal form at (XBC) into an IEEE single at (XWA).  Exponent
; overflow stores +/-0x7F7FFFFF (FLT_MAX), class flag 8 stores 0; both set
; HDAE5000_RAM_Errno = 34 (ERANGE) and call HDAE5000_RAM_MathErrorHook when it
; is non-zero.  Zero (class 1) and exponent underflow store 0 silently.
; ---------------------------------------------------------------------------
HDAE5000_Float_Pack:
	ld xhl, (xbc)
	cpib_erp 0xee, 0		; cp QL,0
	jr	nz, HDAE5000_Float_Pack_Skip
	ld xde, (xbc + 0x04)
	cp	hl, 0x007f
	jr	gt, HDAE5000_Float_Pack_Skip3
	cp	hl, 0xff82
	jr	lt, HDAE5000_Float_Pack_Skip2
	add	hl, 0x007f
	ld	bc, qde
	res	0x07, bc
	sll	hl, 0x07
	orb_erp h, 0xef		; or H,QH
	or	hl, bc
	ld	qde, hl
	ld (xwa), xde
	ret

HDAE5000_Float_Pack_Skip:
	ldto_berp e, 0xee		; ld E,QL
	cp	e, 0x08
	jr	nz, HDAE5000_Float_Pack_Skip2
	ld	xde, 0:i3
	jr	t, HDAE5000_Float_Pack_Join
HDAE5000_Float_Pack_Skip2:
	ld	xde, 0:i3
	ld (xwa), xde
	ret

HDAE5000_Float_Pack_Skip3:
	ldw	de, 0xffff
	ldw	bc, 0x7f7f
	orb_erp b, 0xef		; or B,QH
	ld	qde, bc
HDAE5000_Float_Pack_Join:
	ldw	(HDAE5000_RAM_Errno:24), 34
	ld (xwa), xde
	ld	xbc, (HDAE5000_RAM_MathErrorHook)
	or xbc, xbc
	call_cc_ri xbc, 14		; call NZ,XBC
	ret

; ---------------------------------------------------------------------------
; *(double *)XWA = *(double *)XBC -- an 8-byte copy.  HDAE5000_DoPrintf uses
; it to fetch a double va_arg for %e/%f/%g (ap += 8 first).  Clobbers XIX, XIY.
; ---------------------------------------------------------------------------
HDAE5000_Copy8:
	ld xix, (xbc)
	ld xiy, (xbc + 0x04)
	ld (xwa), xix
	ld (xwa + 0x04), xiy
	ret

	nop

; ---------------------------------------------------------------------------
; 10-byte copy (XBC) -> (XWA): HDAE5000_DoPrintf's long double va_arg fetch,
; taken when its flag bit 7 is set (ap += 10 first).  Clobbers XIX, XIY, HL.
; ---------------------------------------------------------------------------
HDAE5000_Copy10:
	ld xix, (xbc)
	ld xiy, (xbc + 0x04)
	ld	hl, (xbc+8)
	ld (xwa), xix
	ld (xwa + 0x04), xiy
	ld (xwa + 0x08), hl
	ret

	nop
HDAE5000_LongToFloat:
	; *(float *)XWA = (float)*(long *)XBC.  No caller in this ROM (searched:
	; symbolic references to this label, which did not exist before, and
	; the literal 0x29B7FA in every hdae5000 source); library code linked in.
	push xiz
	lda	xsp, (xsp-8)
	ld	xiz, xwa
	ld	xwa, xsp
	ld xbc, (xbc)
	call HDAE5000_Long_To_Unpacked
	ld	xwa, xiz
	ld	xbc, xsp
	call HDAE5000_Float_Pack
	lda	xsp, (xsp+8)
	pop xiz
	ret

; ---------------------------------------------------------------------------
; *(float *)XWA = (float)*(unsigned long *)XBC (HDAE5000_ULong_To_Unpacked,
; then HDAE5000_Float_Pack).  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_ULongToFloat:
	push xiz
	lda	xsp, (xsp-8)
	ld	xiz, xwa
	ld	xwa, xsp
	ld xbc, (xbc)
	call HDAE5000_ULong_To_Unpacked
	ld	xwa, xiz
	ld	xbc, xsp
	call HDAE5000_Float_Pack
	lda	xsp, (xsp+8)
	pop xiz
	ret

HDAE5000_FloatDiv_Special:
	; entered from HDAE5000_Unpacked_Div when either operand's class flag
	; (+2) is non-zero: a zero divisor (flag bit 0) makes the quotient's
	; class 8, which HDAE5000_Float_Pack stores as 0 with errno = ERANGE;
	; otherwise the dividend's special class stands.
	ld	h, (xwa+2)
	ld8_src_rid8 xbc, 0x02, l		; ld L,(XBC+0x02)
	bit 0x00, l
	ret z

	ld	(xwa+2), 0x08
	ret

; ---------------------------------------------------------------------------
; *(float *)XWA = *(float *)XBC / *(float *)XDE: unpack both
; (HDAE5000_Float_Unpack), HDAE5000_Unpacked_Div, HDAE5000_Float_Pack.
; XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FloatDiv:
	push xiz
	lda	xsp, (xsp-20)
	ld	xiz, xde
	ld (xsp + 0x10), xwa
	ld	xwa, xsp
	call HDAE5000_Float_Unpack
	ld	xbc, xiz
	lda	xiz, (xsp+8)
	lda	xwa, (xiz)
	call HDAE5000_Float_Unpack
	ld	xwa, xsp
	lda	xbc, (xiz)
	call HDAE5000_Unpacked_Div
	ld xwa, (xsp + 0x10)
	ld	xbc, xsp
	call HDAE5000_Float_Pack
	lda	xsp, (xsp+20)
	pop xiz
	ret

HDAE5000_SDivMod32_Common:
	; signed front end of HDAE5000_UDivMod32.  D = 0: remainder (sign of the
	; dividend); D = 1: quotient (negated when exactly one operand is
	; negative).  E collects the operand signs (bit 0 dividend, bit 1
	; divisor) before both are made positive.
	ld	e, 0x00:opc
	bit	0x0f, qwa
	jr	z, HDAE5000_SDivMod32_Common_Join
	ld	e, 0x01:opc
	cpl	qwa
	cpl	wa
	inc 1, xwa
HDAE5000_SDivMod32_Common_Join:
	bit	0x0f, qbc
	jr	z, HDAE5000_SDivMod32_Common_Join2
	or	e, 0x02
	cpl	qbc
	cpl	bc
	inc 1, xbc
HDAE5000_SDivMod32_Common_Join2:
	pushw de
	calr	HDAE5000_UDivMod32
	popw wa
	cp	w, 1:i3
	jr	z, HDAE5000_SDivMod32_Common_Skip
	ld	xhl, xde
	bit	0x00, a
	scc8	nz, a
	jr	t, HDAE5000_SDivMod32_Common_Join3
HDAE5000_SDivMod32_Common_Skip:
	cp	a, 3:i3
	ret z

HDAE5000_SDivMod32_Common_Join3:
	or xhl, xhl
	ret z

	cp	a, 0:i3
	ret z

	cpl	qhl
	cpl	hl
	inc 1, xhl
	ret

; ---------------------------------------------------------------------------
; XHL = XWA % XBC, signed (D = 0 into HDAE5000_SDivMod32_Common).
; ---------------------------------------------------------------------------
HDAE5000_SMod32:
	ld	d, 0x00:opc
	jr	t, HDAE5000_SDivMod32_Common

; ---------------------------------------------------------------------------
; XHL = XWA / XBC, signed (D = 1 into HDAE5000_SDivMod32_Common).
; ---------------------------------------------------------------------------
HDAE5000_SDiv32:
	ld	d, 0x01:opc
	jr	t, HDAE5000_SDivMod32_Common


; ---------------------------------------------------------------------------
; XHL = XWA % XBC, unsigned: HDAE5000_UDivMod32's remainder (XDE) moved to XHL.
; ---------------------------------------------------------------------------
HDAE5000_UMod32:
	calr HDAE5000_UDivMod32
	ld xhl, xde		; XHL = remainder (XDE)
	ret

; ---------------------------------------------------------------------------
; UNSIGNED 32 / 32 divide: `jr c` / `jr ule` compares, a 32/16 DIV fast path
; when QBC = 0, else a shift-and-subtract loop.  The signed forms
; HDAE5000_SDiv32 / HDAE5000_SMod32 call this core.
; In:  XWA = dividend, XBC = divisor
; Out: XHL = quotient, XDE = remainder; XBC = 0 returns XHL = 0xFFFFFFFF.
; ---------------------------------------------------------------------------
HDAE5000_UDivMod32:
	cp	xbc, 0x00000001
	jr	z, HDAE5000_UDivMod32_Done
	jr	c, HDAE5000_UDivMod32_Done2
	cp	xwa, xbc
	jr	ule, HDAE5000_UDivMod32_Skip2
	cp	qbc, 0
	jr	nz, HDAE5000_UDivMod32_Skip3
	ld	xde, xwa
	div	xwa, bc
	jr	ov, HDAE5000_UDivMod32_Skip
	ld	xhl, 0:i3
	ld	xde, xhl
	ld	hl, wa
	ld	de, qwa
	ret

HDAE5000_UDivMod32_Skip:
	ld	wa, qde
	extz xwa
	div	xwa, bc
	ld	qhl, wa
	ld	wa, de
	div	xwa, bc
	ld	hl, wa
	ld	de, qwa
	extz xde
	ret

HDAE5000_UDivMod32_Done:
	ld	xhl, xwa
	ld	xde, 0:i3
	ret

HDAE5000_UDivMod32_Done2:
	ld	xhl, 0:i3
	ld	xde, xhl
	dec	1, xhl
	ret

HDAE5000_UDivMod32_Skip2:
	ld	xhl, 1:i3
	ld	xde, 0:i3
	ret z

	dec	1, xhl
	ld	xde, xwa
	ret

HDAE5000_UDivMod32_Skip3:
	ld	d, 0x00:opc
HDAE5000_UDivMod32_Loop:
	cp	xwa, xbc
	jr	c, HDAE5000_UDivMod32_Skip4
	inc	1, d
	add	xbc, xbc
	jr	nc, HDAE5000_UDivMod32_Loop
	stcf16ri 0, bc		; stcf 0x00,BC
	rrc	xbc
	jr	t, HDAE5000_UDivMod32_Join
HDAE5000_UDivMod32_Skip4:
	srl	xbc, 0x01
HDAE5000_UDivMod32_Join:
	ld	xhl, 0:i3
	add	xhl, xhl
	cp	xwa, xbc
	jr	c, HDAE5000_UDivMod32_Done3
	set 0x00, l
	sub	xwa, xbc
HDAE5000_UDivMod32_Done3:
	srl	xbc, 0x01
	djnz8	d, -17				; loop back for next division bit
	ld	xde, xwa
	ret

; ---------------------------------------------------------------------------
; Pack the 12-byte internal form at (XBC) (exponent/class/sign word, +4 low and
; +8 high mantissa longs) into an IEEE double at (XWA), bias 0x3FF.  Exponent
; overflow and class 8 store DBL_MAX (0x7FEFFFFF FFFFFFFF) with the sign, set
; HDAE5000_RAM_Errno = 34 (ERANGE) and call HDAE5000_RAM_MathErrorHook; class 1
; (zero) and underflow store 0.
; ---------------------------------------------------------------------------
HDAE5000_Double_Pack:
	ld xhl, (xbc)
	cpib_erp 0xee, 0		; cp QL,0
	jr	nz, HDAE5000_Double_Pack_Next
	ld xix, (xbc + 0x08)
	ld xiy, (xbc + 0x04)
	cp	hl, 0x03ff
	jr	gt, HDAE5000_Double_Pack_Join
	cp	hl, 0xfc02
	jr	lt, HDAE5000_Double_Pack_Skip
	add	hl, 0x03ff
	res	0x04, qix
	sll	hl, 0x04
	orb_erp h, 0xef		; or H,QH
	or	hl, qix
	ld	qix, hl
HDAE5000_Double_Pack_Done:
	ld (xwa), xiy
	ld (xwa + 0x04), xix
	ret

HDAE5000_Double_Pack_Skip:
	ld	xix, 0:i3
	ld	xiy, xix
	jr	t, HDAE5000_Double_Pack_Done
HDAE5000_Double_Pack_Next:
	bit_erpb 0xee, 0x00		; bit 0x00,QL
	jr	nz, HDAE5000_Double_Pack_Skip
HDAE5000_Double_Pack_Join:
	ldw	(HDAE5000_RAM_Errno:24), 34
	ld	xde, 0:i3
	dec	1, xde
	ld (xwa), xde
	ld	xde, 0x7fefffff
	ldto_berp c, 0xef		; ld C,QH
	orb_erp c, 0xeb		; or C,QD
	ldfr_berp c, 0xeb		; ld QD,C
	ld (xwa + 0x04), xde
	jr	t, HDAE5000_Double_Pack_Done2
HDAE5000_Double_Pack_Done2:
	ld	xbc, (HDAE5000_RAM_MathErrorHook)
	or xbc, xbc
	call_cc_ri xbc, 14		; call NZ,XBC
	ret

	nop

; ---------------------------------------------------------------------------
; Signed long XBC -> internal form at (XWA): records the sign, negates, then
; HDAE5000_ULong_To_Unpacked.
; ---------------------------------------------------------------------------
HDAE5000_Long_To_Unpacked:
	ld	e, 0x00:opc
	ldcf	0x0f, qbc
	stcf8ri 7, e		; stcf 0x07,E
	jr	nc, HDAE5000_Long_To_Unpacked_Join
	cpl	qbc
	cpl	bc
	inc 1, xbc
HDAE5000_Long_To_Unpacked_Join:
	calr	HDAE5000_ULong_To_Unpacked
	ld	(xiy+3), e
	ret

; ---------------------------------------------------------------------------
; Unsigned long XBC -> internal form at (XWA): BS1B finds the top bit, the
; value is shifted to a 24-bit mantissa (rounded) and the exponent stored;
; XBC = 0 sets class flag 1 (zero).
; ---------------------------------------------------------------------------
HDAE5000_ULong_To_Unpacked:
	ld	xiy, xwa
	or xbc, xbc
	jr	z, HDAE5000_ULong_To_Unpacked_Skip3
	bs1b	qbc
	jr	ov, HDAE5000_ULong_To_Unpacked_Skip
	add	a, 0x10
	jr	t, HDAE5000_ULong_To_Unpacked_Join
HDAE5000_ULong_To_Unpacked_Skip:
	bs1b16 bc		; bs1b A,BC
HDAE5000_ULong_To_Unpacked_Join:
	ld	hl, 0:i3
	ld (xiy + 0x02), hl
	ld l, a
	ld_dst16_rid8 xiy, 0x00, hl		; ld (XIY+0x00),HL
	cp l, 0x17
	jr	z, HDAE5000_ULong_To_Unpacked_Join3
	jr	lt, HDAE5000_ULong_To_Unpacked_Skip2
	sub l, 0x17
	ld a, l
	srla	xbc
	jr	nc, HDAE5000_ULong_To_Unpacked_Join3
	inc 1, xbc
	bit_erpb 0xe7, 0x00		; bit 0x00,QB
	jr	z, HDAE5000_ULong_To_Unpacked_Join3
	srl	xbc, 0x01
	inc1_8_rid8 xiy, 0x00		; inc 1,(XIY+0x00)
	jr	t, HDAE5000_ULong_To_Unpacked_Join3
HDAE5000_ULong_To_Unpacked_Skip2:
	ld	a, 0x17:opc
	sub a, l
	cp	a, 0x10
	jr	lt, HDAE5000_ULong_To_Unpacked_Join2
	ld	qbc, bc
	ld	bc, 0:i3
	sub	a, 0x10
	jr	z, HDAE5000_ULong_To_Unpacked_Join3
HDAE5000_ULong_To_Unpacked_Join2:
	slla	xbc
HDAE5000_ULong_To_Unpacked_Join3:
	ld (xiy + 0x04), xbc
	ret

HDAE5000_ULong_To_Unpacked_Skip3:
	ld	(xiy+2), 0x01
	ret

	nop

; ---------------------------------------------------------------------------
; *(double *)XWA = (double)*(float *)XBC: HDAE5000_Float_Unpack, widen the
; mantissa by three right shifts into a high/low pair, HDAE5000_Double_Pack.
; XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FloatToDouble:
	push xiz
	lda	xsp, (xsp-12)
	ld	xiz, xwa
	ld	xwa, xsp
	call HDAE5000_Float_Unpack
	cp	l, 0:i3
	jr	nz, HDAE5000_FloatToDouble_Join
	ld xhl, (xsp + 0x04)
	ld	xde, 0:i3
	srl	xhl, 0x01
	stcf16ri 0, de		; stcf 0x00,DE
	rrc	xde
	srl	xhl, 0x01
	stcf16ri 0, de		; stcf 0x00,DE
	rrc	xde
	srl	xhl, 0x01
	stcf16ri 0, de		; stcf 0x00,DE
	rrc	xde
	ld (xsp + 0x08), xhl
	ld (xsp + 0x04), xde
HDAE5000_FloatToDouble_Join:
	ld	xwa, xiz
	ld	xbc, xsp
	call HDAE5000_Double_Pack
	lda	xsp, (xsp+12)
	pop xiz
	ret

	nop

; ---------------------------------------------------------------------------
; (XWA) /= (XBC) on the internal form: exponents subtracted, signs XORed,
; mantissas divided four quotient bits per pass; special classes go to
; HDAE5000_FloatDiv_Special.
; ---------------------------------------------------------------------------
HDAE5000_Unpacked_Div:
	ld	e, (xwa+2)
	or	e, (xwa+2)
	jp	nz, (HDAE5000_FloatDiv_Special:24)
	push xiz
	push xwa
	ld16_src_rid8 xbc, 0x00, hl		; ld HL,(XBC+0x00)
	sub16_mem_rid8 xwa, 0x00, hl		; sub (XWA+0x00),HL
	ld8_src_rid8 xbc, 0x03, l		; ld L,(XBC+0x03)
	xor8_mem_rid8 xwa, 0x03, l		; xor (XWA+0x03),L
	ld xwa, (xwa + 0x04)
	ld xbc, (xbc + 0x04)
	cp	xbc, 0x00800000
	jr	z, HDAE5000_Unpacked_Div_Skip2
	ld	xhl, 0:i3
	ld	xix, xbc
	add	xix, xix
	ld	xiy, xix
	add	xiy, xiy
	ld	xiz, xiy
	add	xiz, xiz
	ldw	de, 0x0008
	sll	xwa, 0x03
HDAE5000_Unpacked_Div_Loop:
	cp	xwa, xiz
	jr	c, HDAE5000_Unpacked_Div_Join
	sub	xwa, xiz
	set 0x03, l
HDAE5000_Unpacked_Div_Join:
	cp	xwa, xiy
	jr	c, HDAE5000_Unpacked_Div_Join2
	sub	xwa, xiy
	set 0x02, l
HDAE5000_Unpacked_Div_Join2:
	cp	xwa, xix
	jr	c, HDAE5000_Unpacked_Div_Join3
	sub	xwa, xix
	set 0x01, l
HDAE5000_Unpacked_Div_Join3:
	cp	xwa, xbc
	jr	c, HDAE5000_Unpacked_Div_Join4
	sub	xwa, xbc
	set 0x00, l
HDAE5000_Unpacked_Div_Join4:
	dec	1, e
	jr	z, HDAE5000_Unpacked_Div_Skip
	sll	xhl, 0x04
	sll	xwa, 0x04
	jr	t, HDAE5000_Unpacked_Div_Loop
HDAE5000_Unpacked_Div_Skip:
	pop xwa
	bit	0x0f, qhl
	jr	nz, HDAE5000_Unpacked_Div_Join5
	sll	xhl, 0x01
	dec1_16_rid8 xwa, 0x00		; decw 1,(XWA+0x00)
HDAE5000_Unpacked_Div_Join5:
	cp l, 0x80
	jr	c, HDAE5000_Unpacked_Div_Join6
	add	xhl, 0x00000100
	jr	nc, HDAE5000_Unpacked_Div_Join6
	stcf16ri 0, hl		; stcf 0x00,HL
	rrc	xhl
HDAE5000_Unpacked_Div_Join6:
	srl	xhl, 0x08
HDAE5000_Unpacked_Div_Done:
	ld (xwa + 0x04), xhl
	pop xiz
	ret

HDAE5000_Unpacked_Div_Skip2:
	ld	xhl, xwa
	pop xwa
	jr	t, HDAE5000_Unpacked_Div_Done

; ----------------------------------------------------------------------------
; Registered-object name pool  (0x29bafc - 0x29bfdf)
;
; NUL-terminated ASCII names published to the main-CPU UI framework.  Every
; string here is the target of a pointer in HDAE5000_ObjName_Table (the .data
; image at HDAE5000_DataSegmentImage), so the framework can resolve a handler, a
; bitmap or a screen by name.  The pool is laid out in reverse table order.
;
; This region used to be decoded as TLCS-900 instructions (.LDIV_* labels);
; the "code" was the ASCII of these names.
;
; NOTE: the pool continues past the end of this file - the include boundary at
; 0x29bfe0 falls INSIDE the string "en_paradraw", whose last six characters are
; the first bytes of HDAE5000_UI_Config in hdae5000_data_tables.s.
; ----------------------------------------------------------------------------
HDAE5000_Str_End_ObjNames:
	.zero 2
HDAE5000_Str_LanguageTextReturn:
	.asciz "LanguageTextReturn"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_ErrMsgTimerCatchLBN:
	.asciz "ErrMsgTimerCatchLBN"
HDAE5000_Str_ErrMsgTimerCatch:
	.asciz "ErrMsgTimerCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SeparateBassPartCheck:
	.asciz "SeparateBassPartCheck"
HDAE5000_Str_SeparateDrumPartCheck:
	.asciz "SeparateDrumPartCheck"
HDAE5000_Str_FlsOverWrSwCatch:
	.asciz "FlsOverWrSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FlsDel2SwCatch:
	.asciz "FlsDel2SwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FlsDel1SwCatch:
	.asciz "FlsDel1SwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_AttenCpToMarkSwCatch:
	.asciz "AttenCpToMarkSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_AttenCpToHDSwCatch:
	.asciz "AttenCpToHDSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_AttenHDFormatSwCatch:
	.asciz "AttenHDFormatSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_AttenDelFileSwCatch:
	.asciz "AttenDelFileSwCatch"
HDAE5000_Str_AttenDelDirSwCatch:
	.asciz "AttenDelDirSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FlsFileLoadSwCatch:
	.asciz "FlsFileLoadSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNMdBitCheck:
	.asciz "LBNMdBitCheck"
HDAE5000_Str_LBNRcmBitCheck:
	.asciz "LBNRcmBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNMspBitCheck:
	.asciz "LBNMspBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNTmBitCheck:
	.asciz "LBNTmBitCheck"
HDAE5000_Str_LBNCmpBitCheck:
	.asciz "LBNCmpBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNSqtBitCheck:
	.asciz "LBNSqtBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNPmtBitCheck:
	.asciz "LBNPmtBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNLswBitCheck:
	.asciz "LBNLswBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FileLBNNameCheck:
	.asciz "FileLBNNameCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNLoadSwCatch:
	.asciz "LBNLoadSwCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LBNPage1SwCatch:
	.asciz "LBNPage1SwCatch"
HDAE5000_Str_BitmapHdd_icon:
	.asciz "BitmapHdd_icon"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DelMdEditCheck:
	.asciz "DelMdEditCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DelRcmEditCheck:
	.asciz "DelRcmEditCheck"
HDAE5000_Str_DelMspEditCheck:
	.asciz "DelMspEditCheck"
HDAE5000_Str_DelTmEditCheck:
	.asciz "DelTmEditCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DelCmpEditCheck:
	.asciz "DelCmpEditCheck"
HDAE5000_Str_DelSqtEditCheck:
	.asciz "DelSqtEditCheck"
HDAE5000_Str_DelPmtEditCheck:
	.asciz "DelPmtEditCheck"
HDAE5000_Str_DelLswEditCheck:
	.asciz "DelLswEditCheck"
HDAE5000_Str_DelOptNameCheck:
	.asciz "DelOptNameCheck"
HDAE5000_Str_DelOptSwEventCatch:
	.asciz "DelOptSwEventCatch"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SaveOptSwEventCatch:
	.asciz "SaveOptSwEventCatch"
HDAE5000_Str_WrConfirmEventCatch:
	.asciz "WrConfirmEventCatch"
HDAE5000_Str_CP_FD_DIRNAMECheck:
	.asciz "CP_FD_DIRNAMECheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FlsNamingCheck2:
	.asciz "FlsNamingCheck2"
HDAE5000_Str_FlsNamingCheck:
	.asciz "FlsNamingCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_HdTitleEventCatch:
	.asciz "HdTitleEventCatch"
HDAE5000_Str_JumpAfterLoadModeEditCheck:
	.asciz "JumpAfterLoadModeEditCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LoadByNumberModeEditCheck:
	.asciz "LoadByNumberModeEditCheck"
HDAE5000_Str_QuickLoadModeEditCheck:
	.asciz "QuickLoadModeEditCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_WriteConfirmEditCheck:
	.asciz "WriteConfirmEditCheck"
HDAE5000_Str_WriteProtectEditCheck:
	.asciz "WriteProtectEditCheck"
HDAE5000_Str_SfxMdBitCheck:
	.asciz "SfxMdBitCheck"
HDAE5000_Str_SfxRcmBitCheck:
	.asciz "SfxRcmBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SfxMspBitCheck:
	.asciz "SfxMspBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SfxTmBitCheck:
	.asciz "SfxTmBitCheck"
HDAE5000_Str_SfxCmpBitCheck:
	.asciz "SfxCmpBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SfxSqtBitCheck:
	.asciz "SfxSqtBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SfxPmtBitCheck:
	.asciz "SfxPmtBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SfxLswBitCheck:
	.asciz "SfxLswBitCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FileOptNameCheck:
	.asciz "FileOptNameCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SaveOptNameCheck:
	.asciz "SaveOptNameCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SeparateOutputModeCheck:
	.asciz "SeparateOutputModeCheck"
HDAE5000_Str_PC_DATA_LINK_PAGE:
	.asciz "PC_DATA_LINK_PAGE"
HDAE5000_Str_HDD_UTIL_PAGE:
	.asciz "HDD_UTIL_PAGE"
HDAE5000_Str_HDD_DIRNAMECheck:
	.asciz "HDD_DIRNAMECheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_HDDNamingCheck:
	.asciz "HDDNamingCheck"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_HardTestPage:
	.asciz "HardTestPage"
	.byte 0x00
HDAE5000_ParamStr_ListBox_End:
	.zero 2
HDAE5000_ParamStr_ListBox_sel_type:
	.asciz "sel_type"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_ParamStr_ListBox_en_paradraw:
	.ascii "en_par"
