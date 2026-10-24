
; ==============================================================================
; 0xF8BC00-0xF8BF21 -- ASCII numeric fields, and the signed-nibble delta table
; ==============================================================================
;
; Chosen because notes/prom_a_call_graph.py --modules ranks its two directory
; modules -- T_Value_ToAsciiDigits3_RightJustified-T_PendingEventQueue_AppendStackArgs (11 slots, reference upper bound 146) and
; T_AsciiDigits3_ToValue (T_F432F0)-T_AsciiField_Clear (T_F432F8) (3 slots, 27) -- fourth and fifteenth in prom_a, and they
; both land here.  0xF8BC00, 0xF8BC04 and 0xF8BC08 are three `calr`-and-return
; veneers onto routines at the top of the module, the shape the linker gives a
; module's published entry points.
;
; Two RAM structures run through it, and neither is a reading -- both are the
; literal addresses in the instructions:
;
;   0x2820  one ASCII byte, the SIGN.  0x2B ('+') is tested for by name at
;           0xF8BC6A; anything else negates.
;   0x2821-0x2823  three ASCII digit cells, most significant first
;   0x2824  a 16-bit bias added to the parsed value
;   0x2826  how many of the three cells are live (1, 2 or 3)
;
;   0x2661-0x2663  three ASCII digit cells written by the formatter
;   0x2665  its flag byte; bits 0 and 1 are cleared on entry and set as digits
;           are produced, and are what the two blanking variants test
;
; ⚠ What the field is FOR is not established.  Nothing here names a screen, and
; the routines are reached only through the directory.
;
; Routines whose name is not established are `sub_XXXXXX` on purpose.
; FixedEventList_AppendStackArgs -- C-callable List2030_AppendRegs: append 4 stack bytes to the list at 0x2030
; Evidence: prom_b directory slot T_FixedEventList_AppendStackArgs (`jp 0xF8BC00`, 3 refs); `calr 0x02ce` resolves to 0xF8BED1
;   (FixedEventList_AppendStackArgs_Body).  The veneer's own return address is what makes the body's (XIZ+0x0C..0x12)
;   offsets land on the caller's four 16-bit pushes.
FixedEventList_AppendStackArgs:
	calr FixedEventList_AppendStackArgs_Body                                          ; F8BC00  1e ce 02
	ret                                                  ; F8BC03  0e
; EventQueue_AppendStackArgs -- C-callable Queue2C00_AppendRegs (4 stack words -> the 0x2C00 event queue)
; Evidence: prom_b directory slot T_EventQueue_AppendStackArgs (12 refs); `calr EventQueue_AppendStackArgs_Body` at 0xF8BC04.
EventQueue_AppendStackArgs:
	calr EventQueue_AppendStackArgs_Body                                          ; F8BC04  1e e5 02
	ret                                                  ; F8BC07  0e
; PendingEventQueue_AppendStackArgs -- C-callable Queue2E00_AppendRegs (4 stack words -> the pending list 0x2E00)
; Evidence: prom_b directory slot T_PendingEventQueue_AppendStackArgs (34 refs); `calr PendingEventQueue_AppendStackArgs_Body` at 0xF8BC08.
PendingEventQueue_AppendStackArgs:
	calr PendingEventQueue_AppendStackArgs_Body                                          ; F8BC08  1e fc 02
	ret                                                  ; F8BC0B  0e
; ---------------------------------------------------------------------
; AsciiDigits3_ToValue -- three ASCII digit cells at 0x2821 -> WA
;
; Called from: directory slot T_AsciiDigits3_ToValue (T_F432F0) (21 references, the module's second
;          busiest), and by `calr` from AsciiField_ToSignedValue.
; Inputs:  (0x2821),(0x2822),(0x2823) ASCII; (0x2826) = how many are live.
; Outputs: WA = the value; XIX, BC, DE preserved by push/pop.
; Evidence: the three arms are the same seven instructions with a different
;          multiplier -- `mul C,0x64`, `mul C,0x0a`, and none at all for the
;          units digit -- and each is guarded by `cp E,3` / `cp E,2` / `cp E,1`
;          against the live-cell count in E.  Each arm accepts a cell only if it
;          is between `cp C,0x30` and `cp C,0x39`, i.e. ASCII '0'..'9', and
;          subtracts 0x30 before scaling.  Nothing here is inferred: the
;          constants 0x30, 0x39, 0x64 and 0x0A are immediates in the ROM.
; Unknown: a cell outside '0'..'9' is skipped rather than rejected, so the
;          routine cannot report a malformed field.  Whether the caller
;          pre-validates is not established.
; ---------------------------------------------------------------------
AsciiDigits3_ToValue:
	push XIX                                             ; F8BC0C  3c
	pushw bc                                             ; F8BC0D  29
	pushw de                                             ; F8BC0E  2a
	ld XIX,0x00002821                                    ; F8BC0F  44 21 28 00 00
	ld e, (0x2826:16)                                   ; F8BC14  c1 26 28 25
	xor WA,WA                                            ; F8BC18  d8 d0
	ld c, (xix+)                                      ; F8BC1A  c5 f0 23
	cp e, 0x03:i3                                          ; F8BC1D  cd db
	jr c, .LF8BC33                                       ; F8BC1F  67 12
	cp C,0x30                                            ; F8BC21  cb cf 30
	jr ule, .LF8BC33                                     ; F8BC24  63 0d
	cp C,0x39                                            ; F8BC26  cb cf 39
	jr ugt, .LF8BC33                                     ; F8BC29  6b 08
	sub C,0x30                                           ; F8BC2B  cb ca 30
	mul C,0x64                                           ; F8BC2E  cb 08 64
	add WA,BC                                            ; F8BC31  d9 80
.LF8BC33:
	ld c, (xix+)                                      ; F8BC33  c5 f0 23
	cp e, 0x02:i3                                          ; F8BC36  cd da
	jr c, .LF8BC4C                                       ; F8BC38  67 12
	cp C,0x30                                            ; F8BC3A  cb cf 30
	jr ule, .LF8BC4C                                     ; F8BC3D  63 0d
	cp C,0x39                                            ; F8BC3F  cb cf 39
	jr ugt, .LF8BC4C                                     ; F8BC42  6b 08
	sub C,0x30                                           ; F8BC44  cb ca 30
	mul C,0x0a                                           ; F8BC47  cb 08 0a
	add WA,BC                                            ; F8BC4A  d9 80
.LF8BC4C:
	ld C,(XIX)                                           ; F8BC4C  84 23
	cp e, 0x01:i3                                          ; F8BC4E  cd d9
	jr c, .LF8BC63                                       ; F8BC50  67 11
	cp C,0x30                                            ; F8BC52  cb cf 30
	jr ule, .LF8BC63                                     ; F8BC55  63 0c
	cp C,0x39                                            ; F8BC57  cb cf 39
	jr ugt, .LF8BC63                                     ; F8BC5A  6b 07
	sub C,0x30                                           ; F8BC5C  cb ca 30
	extz BC                                              ; F8BC5F  d9 12
	add WA,BC                                            ; F8BC61  d9 80
.LF8BC63:
	popw de                                              ; F8BC63  4a
	popw bc                                              ; F8BC64  49
	pop XIX                                              ; F8BC65  5c
	ret                                                  ; F8BC66  0e
; ---------------------------------------------------------------------
; AsciiField_ToSignedValue -- the same field, with its sign cell and bias
;
; Called from: nothing in prom_a or prom_b names it (notes/prom_a_xref.py);
;          it sits between two published entries and may be reached only
;          through one of them.
; Inputs:  the 0x2820-0x2826 field described in the module header.
; Outputs: WA = (parsed value, negated unless (0x2820) is '+') + (0x2824).
; Evidence: `cp (0x2820),0x2b` then `jr Z` past a `neg WA` is the sign test --
;          0x2B is ASCII '+' -- and `add WA,(0x2824)` is the bias, a 16-bit
;          add against the word the clear routine zeroes.
; ---------------------------------------------------------------------
AsciiField_ToSignedValue:
	calr AsciiDigits3_ToValue                            ; F8BC67  1e a2 ff
	cp	(0x2820:16), 0x2b                            ; F8BC6A  c1 20 28 3f 2b
	jr z, .LF8BC73                                       ; F8BC6F  66 02
	neg WA                                               ; F8BC71  d8 07
.LF8BC73:
	add	wa, (0x2824:16)                              ; F8BC73  d1 24 28 80
	ret                                                  ; F8BC77  0e
; ---------------------------------------------------------------------
; AsciiField_Clear -- reset the field to "+   " with a zero bias
;
; Called from: nothing in prom_a or prom_b names it (notes/prom_a_xref.py).
; Inputs:  none.
; Outputs: (0x2820..0x2823) = '+', ' ', ' ', ' '; (0x2824) = 0.
; Evidence: one 32-bit store, `ld XWA,0x2020202b` then `ld (0x2820),XWA`.
;          0x2B is '+' and 0x20 is the space, and the little-endian order puts
;          the '+' in the sign cell at 0x2820 -- which is the same cell
;          AsciiField_ToSignedValue tests for 0x2B, so the two agree on the
;          layout.  Then `ld (0x2824),0x0000`.
; ---------------------------------------------------------------------
AsciiField_Clear:
	push XWA                                             ; F8BC78  38
	ld XWA,0x2020202b                                    ; F8BC79  40 2b 20 20 20
	ld (0x2820:16), xwa                                 ; F8BC7E  f1 20 28 60
	ldw (0x2824:16), 0x00                                ; F8BC82  f1 24 28 02 00 00
	pop XWA                                              ; F8BC88  58
	ret                                                  ; F8BC89  0e
; Value_ToAsciiDigits3_LeftJustified -- WA -> three ASCII cells at 0x2661, digits moved left, space-padded
; Evidence: after `calr Value_ToAsciiDigits3`: (0x2665) bit 1 clear -> `ld WA,(0x2662) / ld (0x2661),WA / ld
;   (0x2663),0x20`; bit 0 also clear -> shift once more.  So 5 -> "5  ", 50 -> "50 ".  Published as T_F41AF4.
Value_ToAsciiDigits3_LeftJustified:
	calr Value_ToAsciiDigits3                            ; F8BC8A  1e 4a 00
	bit	1, (0x2665:16)                               ; F8BC8D  f1 65 26 c9
	jr nz, .LF8BCAE                                      ; F8BC91  6e 1b
	ld wa, (Value_AsciiDigits+1:16)                                 ; F8BC93  d1 62 26 20
	ld (Value_AsciiDigits:16), wa                                  ; F8BC97  f1 61 26 50
	ld (Value_AsciiDigits+2:16), 0x20                                 ; F8BC9B  f1 63 26 00 20
	bit	0, (0x2665:16)                               ; F8BCA0  f1 65 26 c8
	jr nz, .LF8BCAE                                      ; F8BCA4  6e 08
	ld wa, (Value_AsciiDigits+1:16)                                 ; F8BCA6  d1 62 26 20
	ld (Value_AsciiDigits:16), wa                                  ; F8BCAA  f1 61 26 50
.LF8BCAE:
	ret                                                  ; F8BCAE  0e
; Value_ToAsciiDigits3_RightJustified -- WA -> three ASCII cells at 0x2661, leading zeros blanked
; Evidence: `calr Value_ToAsciiDigits3`; (0x2665) bit 1 clear (no hundreds) -> (0x2661) = ' '; bit 0 also clear (no
;   tens) -> (0x2662) = ' '.  So 5 -> "  5", 50 -> " 50".  Published as T_Value_ToAsciiDigits3_RightJustified, 35 refs; prom_b's display-list op
;   0x00 handler 0xF31BA1 is annotated "decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)".
Value_ToAsciiDigits3_RightJustified:
	calr Value_ToAsciiDigits3                            ; F8BCAF  1e 25 00
	bit	1, (0x2665:16)                               ; F8BCB2  f1 65 26 c9
	jr nz, .LF8BCC8                                      ; F8BCB6  6e 10
	ld (Value_AsciiDigits:16), 0x20                                 ; F8BCB8  f1 61 26 00 20
	bit	0, (0x2665:16)                               ; F8BCBD  f1 65 26 c8
	jr nz, .LF8BCC8                                      ; F8BCC1  6e 05
	ld (Value_AsciiDigits+1:16), 0x20                                 ; F8BCC3  f1 62 26 00 20
.LF8BCC8:
	ret                                                  ; F8BCC8  0e
; Value_ToSignedAsciiDigits3_RightJustified -- (WA - DE) -> sign cell 0x2660 + right-justified digits 0x2661-0x2663
; Evidence: `calr Value_OffsetToSignAndMagnitude / calr Value_ToAsciiDigits3_RightJustified`.  Published as T_Value_ToSignedAsciiDigits3_RightJustified
;   (7 refs); prom_b's op-05 handler 0xF31BD7 is annotated "decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer
;   0x2660".
Value_ToSignedAsciiDigits3_RightJustified:
	calr Value_OffsetToSignAndMagnitude                                      ; F8BCC9  1e 75 00
	calr Value_ToAsciiDigits3_RightJustified                                      ; F8BCCC  1e e0 ff
	ret                                                  ; F8BCCF  0e
; Value_ToSignedAsciiDigits3_LeftJustified -- (WA - DE) -> sign cell 0x2660 + left-justified digits 0x2661-0x2663
; Evidence: `calr Value_OffsetToSignAndMagnitude / calr Value_ToAsciiDigits3_LeftJustified` (0xF8BCD0-0xF8BCD3);
;   published as T_F41AFC.
Value_ToSignedAsciiDigits3_LeftJustified:
	calr Value_OffsetToSignAndMagnitude                                      ; F8BCD0  1e 6e 00
	calr Value_ToAsciiDigits3_LeftJustified                                      ; F8BCD3  1e b4 ff
	ret                                                  ; F8BCD6  0e
; ---------------------------------------------------------------------
; Value_ToAsciiDigits3 -- WA -> up to three ASCII digits at 0x2661
;
; Called from: `calr` from the four routines above it at 0xF8BC8A, 0xF8BCAF,
;          0xF8BCC9 and 0xF8BCD0, which are the blanking variants; two of those
;          are directory slots T_Value_ToAsciiDigits3_LeftJustified and T_F41AF0.
; Inputs:  WA = the value.
; Outputs: (0x2661..0x2663) ASCII; (0x2665) bits 0-1 record which digits were
;          produced; C is preserved.
; Evidence: `and (0x2665),0xfc` clears exactly the two bits the variants above
;          test with `bit 0` and `bit 1`.  The hundreds digit is a repeated
;          `sub WA,0x0064` counted in C -- 0x64 is 100 -- and the routine sets
;          bit 1 of the flag byte the first time that subtraction succeeds.
; Unknown: the tail beyond 0xF8BD33 is not described here; the two blanking
;          variants and the zero-suppression rule are `sub_XXXXXX`.
; ---------------------------------------------------------------------
Value_ToAsciiDigits3:
	push C                                               ; F8BCD7  cb 04
	and	(0x2665:16), 0xfc                            ; F8BCD9  c1 65 26 3c fc
	ld (Value_AsciiDigits:16), 0x00                                 ; F8BCDE  f1 61 26 00 00
	ldw (Value_AsciiDigits+1:16), 0x00                                ; F8BCE3  f1 62 26 02 00 00
	cp wa, 0x00:i3                                         ; F8BCE9  d8 d8
	jr z, .LF8BD33                                       ; F8BCEB  66 46
	xor C,C                                              ; F8BCED  cb d3
.LF8BCEF:
	sub WA,0x0064                                        ; F8BCEF  d8 ca 64 00
	jr c, .LF8BD06                                       ; F8BCF3  67 11
	inc 1,C                                              ; F8BCF5  cb 61
	or	(0x2665:16), 0x02                            ; F8BCF7  c1 65 26 3e 02
	cp wa, 0x00:i3                                         ; F8BCFC  d8 d8
	jr NZ,.LF8BCEF                                       ; F8BCFE  6e ef
	ld (Value_AsciiDigits:16), c                                   ; F8BD00  f1 61 26 43
	jr .LF8BD33                                          ; F8BD04  68 2d
.LF8BD06:
	ld (Value_AsciiDigits:16), c                                   ; F8BD06  f1 61 26 43
	add WA,0x0064                                        ; F8BD0A  d8 c8 64 00
	xor C,C                                              ; F8BD0E  cb d3
.LF8BD10:
	sub WA,0x000a                                        ; F8BD10  d8 ca 0a 00
	jr c, .LF8BD27                                       ; F8BD14  67 11
	inc 1,C                                              ; F8BD16  cb 61
	or	(0x2665:16), 0x01                            ; F8BD18  c1 65 26 3e 01
	cp wa, 0x00:i3                                         ; F8BD1D  d8 d8
	jr nz, .LF8BD10                                      ; F8BD1F  6e ef
	ld (Value_AsciiDigits+1:16), c                                   ; F8BD21  f1 62 26 43
	jr .LF8BD33                                          ; F8BD25  68 0c
.LF8BD27:
	ld (Value_AsciiDigits+1:16), c                                   ; F8BD27  f1 62 26 43
	add WA,0x000a                                        ; F8BD2B  d8 c8 0a 00
	ld (Value_AsciiDigits+2:16), a                                   ; F8BD2F  f1 63 26 41
.LF8BD33:
	add	(Value_AsciiDigits:16), 0x30                            ; F8BD33  c1 61 26 38 30
	addw	(Value_AsciiDigits+1:16), 0x3030                          ; F8BD38  d1 62 26 38 30 30
	pop C                                                ; F8BD3E  cb 05
	ret                                                  ; F8BD40  0e
; Value_OffsetToSignAndMagnitude -- WA -= DE (signed), store its sign char at 0x2660, leave |WA| in WA
; Evidence: DE > 0 -> `sub WA,DE`; DE < 0 -> negate and `add WA,DE` (0xF8BD41-0xF8BD51); then WA < 0 -> negate and `ld
;   (0x2660),0x2d` ('-'), WA > 0 -> 0x2b ('+'), WA = 0 -> 0x20 (' ').  The sign cell sits just below the digit cells
;   Value_ToAsciiDigits3 fills.
Value_OffsetToSignAndMagnitude:
	cp de, 0x00:i3                                         ; F8BD41  da d8
	jr z, .LF8BD53                                       ; F8BD43  66 0e
	jr gt, .LF8BD51                                      ; F8BD45  6a 0a
	xor DE,0xffff                                        ; F8BD47  da cd ff ff
	inc 1,DE                                             ; F8BD4B  da 61
	add WA,DE                                            ; F8BD4D  da 80
	jr .LF8BD53                                          ; F8BD4F  68 02
.LF8BD51:
	sub WA,DE                                            ; F8BD51  da a0
.LF8BD53:
	cp wa, 0x00:i3                                         ; F8BD53  d8 d8
	jr z, .LF8BD6D                                       ; F8BD55  66 16
	jr gt, .LF8BD66                                      ; F8BD57  6a 0d
	xor WA,0xffff                                        ; F8BD59  d8 cd ff ff
	inc 1,WA                                             ; F8BD5D  d8 61
	ld (0x2660:16), 0x2d                                 ; F8BD5F  f1 60 26 00 2d
	jr .LF8BD72                                          ; F8BD64  68 0c
.LF8BD66:
	ld (0x2660:16), 0x2b                                 ; F8BD66  f1 60 26 00 2b
	jr .LF8BD72                                          ; F8BD6B  68 05
.LF8BD6D:
	ld (0x2660:16), 0x20                                 ; F8BD6D  f1 60 26 00 20
.LF8BD72:
	ret                                                  ; F8BD72  0e
; Value_ApplyNibbleDeltaClamped -- A += signed 4-bit step encoded in W, clamped to C..B
; Evidence: index (W&0x0F)|((W&0x80)>>3) into SignedNibbleDelta_Table (0xF8BD80), `add A,L`; a sign-bit flip clamps
;   (positive overflow -> B, negative underflow -> 0), then `cp A,C` raises to C and `cp A,B` lowers to B. Published
;   T_Value_ApplyNibbleDeltaClamped (9 refs); e.g. SoftKeyCol4_Eff1_Step passes A = field, B = 0x7F, C = 0, W = key flag + step.
Value_ApplyNibbleDeltaClamped:
	ld L,W                                               ; F8BD73  c8 8f
	and L,0x0f                                           ; F8BD75  cf cc 0f
	and W,0x80                                           ; F8BD78  c8 cc 80
	srl w, 0x03                                          ; F8BD7B  c8 ef 03
	or W,L                                               ; F8BD7E  cf e0
	ld XHL,SignedNibbleDelta_Table                       ; F8BD80  43 a5 bd f8 00
	ld	l, (xhl+w)                                   ; F8BD85  c3 03 ec e1 27
	add A,L                                              ; F8BD8A  cf 81
	bit 0x07,A                                           ; F8BD8C  c9 33 07
	jr z, .LF8BD98                                       ; F8BD8F  66 07
	bit 0x07,L                                           ; F8BD91  cf 33 07
	jr z, .LF8BD9E                                       ; F8BD94  66 08
	xor A,A                                              ; F8BD96  c9 d1
.LF8BD98:
	cp A,C                                               ; F8BD98  cb f1
	jr nc, .LF8BD9E                                      ; F8BD9A  6f 02
	ld A,C                                               ; F8BD9C  cb 89
.LF8BD9E:
	cp A,B                                               ; F8BD9E  ca f1
	jr ule, .LF8BDA4                                     ; F8BDA0  63 02
	ld A,B                                               ; F8BDA2  ca 89
.LF8BDA4:
	ret                                                  ; F8BDA4  0e
; ---------------------------------------------------------------------
; SignedNibbleDelta_Table -- 32 bytes, a 4-bit magnitude plus a sign bit -> a
; signed 8-bit delta
;
; Read by: the routine at 0xF8BD73, and only there: `ld XHL,0x00f8bda5` at
;          0xF8BD80 followed by `ld L,(XHL+W)` at 0xF8BD85.  The index W is
;          built two instructions earlier as `(W & 0x0F) | ((W & 0x80) >> 3)`
;          -- `and L,0x0f`, `and W,0x80`, `srl 0x03,W`, `or W,L` -- so the only
;          indices that can occur are 0..15 and 16..31.
; Layout:  one byte per entry, 32 entries, index = the encoded delta.
;            [0x00..0x0F] = 0x00..0x0F   the positive deltas, +0 to +15
;            [0x10]       = 0x00         negative zero
;            [0x11..0x1F] = 0xFF..0xF1   the negative deltas, -1 to -15
; Evidence: the two halves are literally 0x00..0x0F ascending and 0x00,
;          0xFF..0xF1 descending, which is exactly "magnitude" and "negated
;          magnitude" for a 4-bit field, and the index's high half comes from
;          bit 7 of W -- a sign bit -- moved down by `srl 0x03,W` into bit 4.
;          Nothing else in prom_a or prom_b names 0xF8BDA5.
; ENTRY COUNT, and how it is established: the index arithmetic above cannot
;          produce 32 or more, and the byte at 0xF8BDA5 + 32 = 0xF8BDC5 is the
;          first byte of the next routine -- which is not an inference from the
;          decode but a published entry, directory slot T_PanelButton_CallTableEntry (32 references).
;          Both ends of the table are therefore pinned by something other than
;          the table.  ★ LAST-ENTRY TEST: entry 31 is 0xF1 = -15, the largest
;          negative magnitude the 4-bit field can hold, and entry 30 is 0xF2.
; ⚠ This region is emitted as `.byte` and never decoded.  A linear disassembly
;          runs straight into it -- that is what produced the `db` bytes at
;          0xF8BDBF-0xF8BDC4 in the first survey of this module -- and would
;          have printed six invented instructions.
; ---------------------------------------------------------------------
SignedNibbleDelta_Table:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; F8BDA5
	.byte 0x00, 0xff, 0xfe, 0xfd, 0xfc, 0xfb, 0xfa, 0xf9, 0xf8, 0xf7, 0xf6, 0xf5, 0xf4, 0xf3, 0xf2, 0xf1  ; F8BDB5
; PanelButton_CallTableEntry -- call entry HL of a screen's 32-entry button-handler table (XIX)
; Evidence: `cp HL,0x001f / jr ugt` (0xF8BDC5), `ld XIX,(XIX+4*L) / call (xix)` (0xF8BDF0); first XDE = 1<<L
;   (IndexToBitMask32_Copy) is tested against (0x2666) or, when W bit 7 is set, (0x266A); no hit -> and (0x2075),0xfe.
;   Callers are Button methods (e.g. ScreenButton_SoundMode) via T_PanelButton_CallTableEntry; HL/W are the code and pair flag
;   PanelButton_Route passes.
PanelButton_CallTableEntry:
	cp HL,0x001f                                         ; F8BDC5  db cf 1f 00
	jr ugt, .LF8BDF7                                     ; F8BDC9  6b 2c
	ld E,L                                               ; F8BDCB  cf 8d
	inc 1,E                                              ; F8BDCD  cd 61
	calr IndexToBitMask32_Copy                                      ; F8BDCF  1e 64 00
	ld xbc, (0x2666:16)                                 ; F8BDD2  e1 66 26 21
	bit 0x07,W                                           ; F8BDD6  c8 33 07
	jr z, .LF8BDDF                                       ; F8BDD9  66 04
	ld xbc, (0x266a:16)                                 ; F8BDDB  e1 6a 26 21
.LF8BDDF:
	and XDE,XBC                                          ; F8BDDF  e9 c2
	jr nz, .LF8BDE8                                      ; F8BDE1  6e 05
	and	(UI_RequestBits:16), 0xfe                            ; F8BDE3  c1 75 20 3c fe
.LF8BDE8:
	ld XBC,XHL                                           ; F8BDE8  eb 89
	and L,0x1f                                           ; F8BDEA  cf cc 1f
	sla l, 0x02                                          ; F8BDED  cf ec 02
	ld	xix, (xix+l)                                 ; F8BDF0  e3 03 f0 ec 24
	call (xix)                                           ; F8BDF5  b4 e8
.LF8BDF7:
	ret                                                  ; F8BDF7  0e
; PanelButton_CallPageTableEntry -- PanelButton_CallTableEntry on row E of consecutive 32-entry tables
; Evidence: the same bound and enable-mask test as PanelButton_CallTableEntry, then `xor XDE,XDE / pop E / sla 7,DE /
;   add XIX,XDE` (0xF8BE1D-0xF8BE2C) selects row E (128 bytes per row) before `call (xix)`.  T_PanelButton_CallPageTableEntry callers:
;   ScreenButton_SysexBulkDump_Entry and ScreenButton_GeneralMidiMode_Entry with E = (0x2740), the page.
PanelButton_CallPageTableEntry:
	cp HL,0x001f                                         ; F8BDF8  db cf 1f 00
	jr ugt, .LF8BE35                                     ; F8BDFC  6b 37
	push E                                               ; F8BDFE  cd 04
	ld E,L                                               ; F8BE00  cf 8d
	inc 1,E                                              ; F8BE02  cd 61
	calr IndexToBitMask32_Copy                                      ; F8BE04  1e 2f 00
	ld xbc, (0x2666:16)                                 ; F8BE07  e1 66 26 21
	bit 0x07,W                                           ; F8BE0B  c8 33 07
; (sub_F8BE0E removed 2026-10-04: no code names it and the line above falls through into it -- part of PanelButton_CallPageTableEntry;
;  notes/prom_a_stray_label_removal.py)
	jr z, .LF8BE14                                       ; F8BE0E  66 04
	ld xbc, (0x266a:16)                                 ; F8BE10  e1 6a 26 21
.LF8BE14:
	and XDE,XBC                                          ; F8BE14  e9 c2
	jr nz, .LF8BE1D                                      ; F8BE16  6e 05
	and	(UI_RequestBits:16), 0xfe                            ; F8BE18  c1 75 20 3c fe
.LF8BE1D:
	xor XDE,XDE                                          ; F8BE1D  ea d2
	pop E                                                ; F8BE1F  cd 05
	sla de, 0x07                                         ; F8BE21  da ec 07
	ld XBC,XHL                                           ; F8BE24  eb 89
	and L,0x1f                                           ; F8BE26  cf cc 1f
	sla l, 0x02                                          ; F8BE29  cf ec 02
	add XIX,XDE                                          ; F8BE2C  ea 84
	ld	xix, (xix+l)                                 ; F8BE2E  e3 03 f0 ec 24
	call (xix)                                           ; F8BE33  b4 e8
.LF8BE35:
	ret                                                  ; F8BE35  0e
; ---------------------------------------------------------------------
; IndexToBitMask32_Copy -- E (0..32) -> XDE = one-hot 32-bit mask, a LIVE
;          second copy of IndexToBitMask32 (0xF8A97D): identical but for its
;          table operand (check C3).  Renamed from sub_F8BE36.
; Called by: PanelButton_CallTableEntry (`calr` at 0xF8BDCF) and PanelButton_CallPageTableEntry (0xF8BE04),
;          each with E = L + 1.
; ---------------------------------------------------------------------
IndexToBitMask32_Copy:
	push XIX                                             ; F8BE36  3c
	cp E,0x20                                            ; F8BE37  cd cf 20
	jr ule, .LF8BE3E                                     ; F8BE3A  63 02
	xor E,E                                              ; F8BE3C  cd d5
.LF8BE3E:
	sla e, 0x02                                          ; F8BE3E  cd ec 02
	ld XIX,BitMask32ByIndex_Copy                      ; F8BE41  44 4d be f8 00
	ld	xde, (xix+e)                                 ; F8BE46  e3 03 f0 e8 22
	pop XIX                                              ; F8BE4B  5c
	ret                                                  ; F8BE4C  0e
; ---------------------------------------------------------------------
; BitMask32ByIndex_Copy -- 33 x u32: 0, then 1<<0 .. 1<<31 (entry k = 1 << (k-1)).
; Read by: IndexToBitMask32_Copy (0xF8BE36) -- `cp E,0x20 / jr ule / xor E,E /
;          sla 2,E / ld XIX,<this> / ld XDE,(XIX+E)`: any E above 32 reads entry 0.
; COUNT 33 = that bound + 1; FixedEventList_AppendStackArgs_Body starts right after.
; Byte-identical to BitMask32ByIndex (0xF8A994).  This copy is LIVE: its
;          routine is called by PanelButton_CallTableEntry (0xF8BDCF) and PanelButton_CallPageTableEntry (0xF8BE04).
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
BitMask32ByIndex_Copy:
	.long 0x00000000, 0x00000001, 0x00000002, 0x00000004  ; F8BE4D  [0]
	.long 0x00000008, 0x00000010, 0x00000020, 0x00000040  ; F8BE5D  [4]
	.long 0x00000080, 0x00000100, 0x00000200, 0x00000400  ; F8BE6D  [8]
	.long 0x00000800, 0x00001000, 0x00002000, 0x00004000  ; F8BE7D  [12]
	.long 0x00008000, 0x00010000, 0x00020000, 0x00040000  ; F8BE8D  [16]
	.long 0x00080000, 0x00100000, 0x00200000, 0x00400000  ; F8BE9D  [20]
	.long 0x00800000, 0x01000000, 0x02000000, 0x04000000  ; F8BEAD  [24]
	.long 0x08000000, 0x10000000, 0x20000000, 0x40000000  ; F8BEBD  [28]
	.long 0x80000000  ; F8BECD  [32]
; FixedEventList_AppendStackArgs_Body -- read four stack words into E,D,A,W and call List2030_AppendRegs
; Evidence: `ld E,(XIZ+0x0c) / ld D,(XIZ+0x0e) / ld A,(XIZ+0x10) / ld W,(XIZ+0x12)` then `call T_List2030_AppendRegs`
;   (0xF8BED7-0xF8BEE3); XIX/XHL/XDE preserved.  Reached only through FixedEventList_AppendStackArgs (0xF8BC00).
;   prom_b's List2030_Append4 (0xF552CC) is the C-compiled twin.
FixedEventList_AppendStackArgs_Body:
	push XIZ                                             ; F8BED1  3e
	ld XIZ,XSP                                           ; F8BED2  ef 8e
	push XIX                                             ; F8BED4  3c
	push XHL                                             ; F8BED5  3b
	push XDE                                             ; F8BED6  3a
	ld E,(XIZ+0x0c)                                      ; F8BED7  8e 0c 25
	ld D,(XIZ+0x0e)                                      ; F8BEDA  8e 0e 24
	ld A,(XIZ+0x10)                                      ; F8BEDD  8e 10 21
	ld W,(XIZ+0x12)                                      ; F8BEE0  8e 12 20
	call T_List2030_AppendRegs                           ; F8BEE3  1d 40 0f f4
	pop XDE                                              ; F8BEE7  5a
	pop XHL                                              ; F8BEE8  5b
sub_F8BEE9:
	pop XIX                                              ; F8BEE9  5c
	pop XIZ                                              ; F8BEEA  5e
	ret                                                  ; F8BEEB  0e
; EventQueue_AppendStackArgs_Body -- read four stack words into E,D,A,W and call Queue2C00_AppendRegs
; Evidence: same frame reads as FixedEventList_AppendStackArgs_Body, then `call T_Queue2C00_AppendRegs` at 0xF8BEFE
;   (one of the 7 call sites Queue2C00_AppendRegs' header lists).  Twin of prom_b Queue2C00_Append4 (0xF55231).
EventQueue_AppendStackArgs_Body:
	push XIZ                                             ; F8BEEC  3e
	ld XIZ,XSP                                           ; F8BEED  ef 8e
	push XIX                                             ; F8BEEF  3c
	push XHL                                             ; F8BEF0  3b
	push XDE                                             ; F8BEF1  3a
	ld E,(XIZ+0x0c)                                      ; F8BEF2  8e 0c 25
	ld D,(XIZ+0x0e)                                      ; F8BEF5  8e 0e 24
	ld A,(XIZ+0x10)                                      ; F8BEF8  8e 10 21
	ld W,(XIZ+0x12)                                      ; F8BEFB  8e 12 20
	call T_Queue2C00_AppendRegs                          ; F8BEFE  1d 38 0f f4
	pop XDE                                              ; F8BF02  5a
	pop XHL                                              ; F8BF03  5b
	pop XIX                                              ; F8BF04  5c
	pop XIZ                                              ; F8BF05  5e
	ret                                                  ; F8BF06  0e
; PendingEventQueue_AppendStackArgs_Body -- read four stack words into E,D,A,W and call Queue2E00_AppendRegs
; Evidence: same frame reads as FixedEventList_AppendStackArgs_Body, then `call T_Queue2E00_AppendRegs` at 0xF8BF19
;   (first of the call sites Queue2E00_AppendRegs' header lists).  Twin of prom_b Queue2E00_Append4 (0xF5527E).
PendingEventQueue_AppendStackArgs_Body:
	push XIZ                                             ; F8BF07  3e
	ld XIZ,XSP                                           ; F8BF08  ef 8e
	push XIX                                             ; F8BF0A  3c
	push XHL                                             ; F8BF0B  3b
	push XDE                                             ; F8BF0C  3a
	ld E,(XIZ+0x0c)                                      ; F8BF0D  8e 0c 25
	ld D,(XIZ+0x0e)                                      ; F8BF10  8e 0e 24
	ld A,(XIZ+0x10)                                      ; F8BF13  8e 10 21
	ld W,(XIZ+0x12)                                      ; F8BF16  8e 12 20
	call T_Queue2E00_AppendRegs                          ; F8BF19  1d 3c 0f f4
	pop XDE                                              ; F8BF1D  5a
	pop XHL                                              ; F8BF1E  5b
	pop XIX                                              ; F8BF1F  5c
	pop XIZ                                              ; F8BF20  5e
	ret                                                  ; F8BF21  0e

; 0xF8BF22-0xF8BFFF -- 222 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 222, 1, 0x0E
