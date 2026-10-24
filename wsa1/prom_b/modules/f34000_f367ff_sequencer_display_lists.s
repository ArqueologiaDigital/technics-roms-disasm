
; ------------------------------------------------------------------
; 0xF34000-0xF341B5 -- 27 display-list records, 438 bytes -- interpreter A
; the fill run above stops dead here; DL.walk() lands with ZERO
; DRIFT on 0xF341B6, the ALREADY CALL-VERIFIED start of DL_F341B6
; (see its own header below: "entered at: 0xF341B6").
; ------------------------------------------------------------------
DL_F34000:
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x00FF12F6
	.short 0x1805
	.short 0xF34D
	.byte 0x00	; operand bytes the handler does not read
	.byte 0x08, 0x0B	; op 08, 11 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x1B, 0x18	; character codes below 0x20
	.ascii "M"
	.byte 0xF3, 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0x05, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F7
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "#"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F8
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "A"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F9
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "_"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12FA
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "}"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12FB
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0x9B, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12FC
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0xB9, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12FD
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0xD7, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12FE
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0x05, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12FF
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "#"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1300
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "A"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1301
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "_"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1302
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00	; character codes below 0x20
	.ascii "}"
	.byte 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1303
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0x9B, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1304
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0xB9, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1305
	.byte 0xFF, 0x00, 0x17, 0x88	; character codes below 0x20
	.ascii "N"
	.byte 0xF3, 0x00, 0x03, 0x00, 0xD7, 0x00	; character codes below 0x20
	.ascii "5"
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00, 0x02, 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00	; character codes below 0x20
	.ascii " "
	.byte 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00	; character codes below 0x20
	.ascii ">"
	.byte 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00	; character codes below 0x20
	.ascii "\\"
	.byte 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00	; character codes below 0x20
	.ascii "z"
	.byte 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00, 0x98, 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00, 0xB6, 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0xFF, 0x00, 0x17	; character codes below 0x20
	.ascii "nL"
	.byte 0xF3, 0x00, 0x04, 0x00, 0xD4, 0x00	; character codes below 0x20
	.ascii "\""
	.byte 0x00	; character codes below 0x20
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x03C0
	.short 0x001E
	.short 0x0009

; ------------------------------------------------------------------
; 0xF341B6-0xF34255 -- 16 display-list records, 160 bytes -- interpreter A
;   entered at: 0xF341B6
;   ends used:  0xF34256
; ------------------------------------------------------------------
DL_F341B6:
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00A0
	.short 0x0022
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00A0
	.short 0x004A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00A0
	.short 0x0072
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00A0
	.short 0x009A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00A0
	.short 0x00C2
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00A0
	.short 0x00EA
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00A0
	.short 0x0112
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00A0
	.short 0x013A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00CF
	.short 0x0022
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00CF
	.short 0x004A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00CF
	.short 0x0072
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00CF
	.short 0x009A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00CF
	.short 0x00C2
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00CF
	.short 0x00EA
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00CF
	.short 0x0112
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00CF
	.short 0x013A
	.short 0x00E9

; === COVER-R1 0xF34256-0xF34361 ===
; 0xF34256-0xF34360, coverage round 1: 7 of this span's 267 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 7 as DATA (only a
; `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF34256-0xF3434B -- 27 display-list records, 246 bytes -- interpreter A
; Formerly Data_F34256 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F34256:
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0005
	.short 0x002C
	.ascii " 1 "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0023
	.short 0x002C
	.ascii " 2 "
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0042
	.short 0x002C
	.ascii " "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0041
	.short 0x002C
	.ascii " 3 "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x005F
	.short 0x002C
	.ascii " 4 "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x007D
	.short 0x002C
	.ascii " 5 "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x009B
	.short 0x002C
	.ascii " 6 "
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00BA
	.short 0x002C
	.ascii " "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00B9
	.short 0x002C
	.ascii " 7 "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00D7
	.short 0x002C
	.ascii " 8 "
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0005
	.short 0x002C
	.ascii " 9 "
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x0026
	.short 0x002C
	.ascii "10"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x0044
	.short 0x002C
	.ascii "11"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x0062
	.short 0x002C
	.ascii "12"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0083
	.short 0x002C
	.ascii " "
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x0080
	.short 0x002C
	.ascii "13"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x009E
	.short 0x002C
	.ascii "14"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x00BC
	.short 0x002C
	.ascii "15"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x00DA
	.short 0x002C
	.ascii "16"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x0163
	.ascii "YES "
	.byte 0x11	; character codes below 0x20
	.byte 0x1C, 0x14	; op 1C, 20 bytes -> handler 0xF31A52
	.short 0x0011
	.short 0x0028
	.ascii "Are You Sure ?"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x05D7
	.ascii "N0  "
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0020
	.short 0x00B4
	.short 0x003A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x0007
	.short 0x00E4
	.short 0x0018
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00C6
	.short 0x0009
	.short 0x00E2
	.short 0x0016
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x002D
	.short 0x00E4
	.short 0x003E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00C6
	.short 0x002F
	.short 0x00E2
	.short 0x003C

; --------------------------------------------------------------------------
; Data_F3434C -- 4 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3434C appears as a 32-bit word at 0xF55CA7 0xF55D58;
;               converted code at 0xF55CA6 0xF55D57 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 0% printable ASCII; a linear decode runs 2 instructions and ends
;           `retd 0x12f6`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------

; ------------------------------------------------------------------
; 0xF3434C-0xF34360 -- 1 display-list record and its string table,
; 21 bytes -- interpreter B.  Formerly Data_F3434C (4 bytes) plus the
; 17-byte `.incbin` that followed it.
;
; THE START IS NAMED BY CODE: prom_b 0xF55CA6 and 0xF55D57 both do
; `ld XIY,0x00f3434c`, then reach T_F417F8 -> 0xF31B21 -- the opcode-02
; handler itself -- with that XIY (via SeqScreen_DrawCountInMeasure).  So this address is
; a record start on the firmware's own say-so, and the handler fixes the
; extent at 15 bytes.  Its +7 lands on 0xF3435B, the byte right after it.
; THE END IS NAMED BY CODE TOO: RealtimeRecordScreen_DrawValues_DL is `ld XIY,0x00f34361` at
; prom_b 0xF55D45, so the table is exactly 2 entries of 3 bytes.
; Verify: python3 notes/gen_prom_b_res3xx_spans.py --selftest
; ------------------------------------------------------------------
DL_F3434C:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLTable_F3435B	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x053E	; +0x0D -> IX

; ------------------------------------------------------------------
; DLTable_F3435B -- 2 entries of 3 bytes (6 bytes).
; Referenced by interpreter-B display-list record 0xF3434C, whose +7
; pointer lands here and whose handler fixes the entry size.  2 entries is the
; EXTENT (6 / 3), bounded by RealtimeRecordScreen_DrawValues_DL; the record's mask 0xFF would
; allow up to 256.
; ------------------------------------------------------------------
DLTable_F3435B:
	.ascii " -1"	; [0]
	.ascii " -2"	; [1]


; === END COVER-R1 0xF34256-0xF34361 ===

; ------------------------------------------------------------------
; 0xF34361-0xF343B5 -- 7 display-list records, 85 bytes -- interpreter B
;   entered at: 0xF34361, 0xF3437F, 0xF343A2
;   ends used:  0xF3438E, 0xF343AC, 0xF343B6
; ------------------------------------------------------------------
RealtimeRecordScreen_DrawValues_DL:
; drawn (start operand) by RealtimeRecordScreen_DrawValues -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn_F343B6	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0573	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn_F349BB	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0BB3	; +0x0D -> IX
; DL_MasterSongMeasure -- the display list at 0xF3437F, named by mechanism M3
;                         of notes/prom_b_dl_screens_round5.py.  "(MASTER:"
;                         ends at 0x0B2C  "SONG" ends at 0x013C  "MEASURE ="
;                         ends at 0x053E
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_MasterSongMeasure:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+19	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_OffOn_F349C1	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0B2C	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+11	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x013C	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x053E	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
; DL_TimeSig -- the display list at 0xF343A2, named by mechanism M3 of
;               notes/prom_b_dl_screens_round5.py.  "TIME SIG.=" ends at
;               0x0887
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_TimeSig:
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0887	; +0x07 -> IX
	.byte 0x01	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0EC5	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663

; === COVER-R1 0xF343B6-0xF343BC ===
; 0xF343B6-0xF343BB, coverage round 1: 6 of this span's 6 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 6 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF343B6-0xF343BB -- 6 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F343B6 appears as a 32-bit word at 0xF34368 0xF351BD
;               0xF55D4B; converted code at 0xF55D4A loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 2 instructions and ends
;           `ld XIZ,0x4e4f2046`, with 0% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_OffOn_F343B6 -- 0xF343B6-0xF343BB, 2 entries of 3 bytes, text drawn
;   by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 records
;   at 0xF34361 ((0x2648) AND 0xFF >> 0), 0xF351B6 ((0x2648) AND 0x01 >> 0)
;   -- value = (byte at the +2 address) AND mask >> shift -- whose +0x07
;   names this address; DLB_Handler_StringTable draws entry [value] with
;   +0x0B = 3 as the width.  Entry count: the distance to the object's end
;   over the width; the masks admit 256.  This address is also the END of a
;   display list: `ld XIY,0xF34361 / ld XIX,this / call T_DisplayListB_Run`
;   at 0xF55D4A.
; --------------------------------------------------------------------------
DLText_OffOn_F343B6:
	.ascii	"OFF"	; F343B6  [0]
	.ascii	" ON"	; F343B9  [1]

; === END COVER-R1 0xF343B6-0xF343BC ===

; ------------------------------------------------------------------
; 0xF343BC-0xF34967 -- 170 display-list records, 1452 bytes -- interpreter A
;   entered at: 0xF343BC, 0xF34681
;   ends used:  0xF34681, 0xF34968
; ------------------------------------------------------------------
; DL_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle -- the display list at
;                                                         0xF343BC, named by
;                                                         mechanism M1 of note
;                                                         s/prom_b_dl_screens_
;                                                         round5.py.
;                                                         "REALTIME RECORD"
;                                                         "SONG"  "MEASURE ="
;                                                         "QUANTI"  "TIME
;                                                         SIG.="  "(MASTER:"
;                                                         "CYCLE:"  "MEMORY ="
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim.  Round 4 stopped its CamelCase at
;           24 characters and this list collided; the name is the SAME
;           literals read further, and says what the list PUTS ON THE SCREEN
;           and nothing more.  Generated by notes/prom_b_dl_screens_round5.py
;           --apply.
DL_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle:
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x32
	.short 0x002D
	.byte 0x1C, 0x15	; op 1C, 21 bytes -> handler 0xF31A52
	.short 0x0048
	.short 0x0005
	.ascii "REALTIME RECORD"
	.byte 0x20, 0x08	; op 20, 8 bytes -> handler 0xF31A3A
	.short 0x0138
	.ascii "SONG"
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0534
	.ascii "MEASURE = "
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x0571
	.byte 0x87	; character codes below 0x20
	.byte 0x20, 0x05	; op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0572
	.ascii " "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0577
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0578
	.byte 0x10	; character codes below 0x20
	.byte 0x20, 0x0A	; op 20, 10 bytes -> handler 0xF31A3A
	.short 0x05CA
	.ascii "QUANTI"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x05D0
	.ascii "Z"
	.byte 0x20, 0x05	; op 20, 5 bytes -> handler 0xF31A3A
	.short 0x05D1
	.ascii "E"
	.byte 0x07, 0x0F	; op 07, 15 bytes -> handler 0xF31A3A
	.short 0x087C
	.ascii "TIME SIG.= "
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0888
	.ascii "/4"
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x0B24
	.ascii "(MASTER:"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B2F
	.ascii ")"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x20, 0x0A	; op 20, 10 bytes -> handler 0xF31A3A
	.short 0x0BAD
	.ascii "CYCLE:"
	.byte 0x07, 0x0D	; op 07, 13 bytes -> handler 0xF31A3A
	.short 0x0EBD
	.ascii "MEMORY = "
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0EC8
	.ascii " %"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1158
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A5
	.ascii "."
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A7
	.byte 0x11	; character codes below 0x20
	.byte 0x20, 0x09	; op 20, 9 bytes -> handler 0xF31A3A
	.short 0x11AA
	.ascii "MIXER"
	.byte 0x20, 0x0C	; op 20, 12 bytes -> handler 0xF31A3A
	.short 0x11ED
	.ascii "TIME SIG"
	.byte 0x08, 0x06	; op 08, 6 bytes -> handler 0xF31A3A
	.short 0x127D
	.byte 0x15	; character codes below 0x20
	.ascii "="
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1952
	.ascii "1"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1957
	.ascii "2"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x195C
	.ascii "3"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1961
	.ascii "4"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1966
	.ascii "5"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x196B
	.ascii "6"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1970
	.ascii "7"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1975
	.ascii "8"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20AA
	.ascii "9"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20AF
	.ascii "10"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20B4
	.ascii "11"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20B9
	.ascii "12"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20BE
	.ascii "13"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20C3
	.ascii "14"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20C8
	.ascii "15"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20CD
	.ascii "16"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00A0
	.short 0x0022
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00A0
	.short 0x004A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00A0
	.short 0x0072
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00A0
	.short 0x009A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00A0
	.short 0x00C2
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00A0
	.short 0x00EA
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00A0
	.short 0x0112
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00A0
	.short 0x013A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00CF
	.short 0x0022
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00CF
	.short 0x004A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00CF
	.short 0x0072
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00CF
	.short 0x009A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00CF
	.short 0x00C2
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00CF
	.short 0x00EA
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00CF
	.short 0x0112
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00CF
	.short 0x013A
	.short 0x00E9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AD
	.short 0x0024
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00AD
	.short 0x004C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00AD
	.short 0x0074
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00AD
	.short 0x009C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00AD
	.short 0x00C4
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00AD
	.short 0x00EC
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00AD
	.short 0x0114
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00AD
	.short 0x013C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DC
	.short 0x0024
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00DC
	.short 0x004C
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00DC
	.short 0x0074
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DC
	.short 0x009C
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DC
	.short 0x00C4
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00DC
	.short 0x00EC
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00DC
	.short 0x0114
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00DC
	.short 0x013C
	.short 0x00DC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00FF
	.short 0x001D
	.short 0x0134
	.short 0x0030
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0101
	.short 0x001F
	.short 0x0132
	.short 0x002E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0020
	.short 0x0056
	.short 0x0033
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0022
	.short 0x0054
	.short 0x0031
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E3
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E5
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x006C
	.short 0x003E
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x006D
	.short 0x0134
	.short 0x0080
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x006E
	.short 0x003C
	.short 0x007D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E6
	.short 0x006F
	.short 0x0132
	.short 0x007E
; DL_RealtimeRecordSongMeasureQuantiTimeSigMasterClear -- the display list at
;                                                         0xF34681, named by
;                                                         mechanism M1 of note
;                                                         s/prom_b_dl_screens_
;                                                         round5.py.
;                                                         "REALTIME RECORD"
;                                                         "SONG"  "MEASURE ="
;                                                         "QUANTI"  "TIME
;                                                         SIG.="  "(MASTER:"
;                                                         "CLEAR"  "CYCLE:"
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim.  Round 4 stopped its CamelCase at
;           24 characters and this list collided; the name is the SAME
;           literals read further, and says what the list PUTS ON THE SCREEN
;           and nothing more.  Generated by notes/prom_b_dl_screens_round5.py
;           --apply.
DL_RealtimeRecordSongMeasureQuantiTimeSigMasterClear:
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x32
	.short 0x002D
	.byte 0x1C, 0x15	; op 1C, 21 bytes -> handler 0xF31A52
	.short 0x0048
	.short 0x0005
	.ascii "REALTIME RECORD"
	.byte 0x20, 0x08	; op 20, 8 bytes -> handler 0xF31A3A
	.short 0x0138
	.ascii "SONG"
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0534
	.ascii "MEASURE = "
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x0571
	.byte 0x87	; character codes below 0x20
	.byte 0x20, 0x05	; op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0572
	.ascii " "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0577
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0578
	.byte 0x10	; character codes below 0x20
	.byte 0x20, 0x0A	; op 20, 10 bytes -> handler 0xF31A3A
	.short 0x05CA
	.ascii "QUANTI"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x05D0
	.ascii "Z"
	.byte 0x20, 0x05	; op 20, 5 bytes -> handler 0xF31A3A
	.short 0x05D1
	.ascii "E"
	.byte 0x07, 0x0F	; op 07, 15 bytes -> handler 0xF31A3A
	.short 0x087C
	.ascii "TIME SIG.= "
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0888
	.ascii "/4"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B18
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x0B24
	.ascii "(MASTER:"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B2F
	.ascii ")"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x20, 0x09	; op 20, 9 bytes -> handler 0xF31A3A
	.short 0x0B92
	.ascii "CLEAR"
	.byte 0x20, 0x0A	; op 20, 10 bytes -> handler 0xF31A3A
	.short 0x0BAD
	.ascii "CYCLE:"
	.byte 0x07, 0x0D	; op 07, 13 bytes -> handler 0xF31A3A
	.short 0x0EBD
	.ascii "MEMORY = "
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0EC8
	.ascii " %"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1158
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A5
	.ascii "."
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A7
	.byte 0x11	; character codes below 0x20
	.byte 0x20, 0x09	; op 20, 9 bytes -> handler 0xF31A3A
	.short 0x11AA
	.ascii "MIXER"
	.byte 0x20, 0x0C	; op 20, 12 bytes -> handler 0xF31A3A
	.short 0x11ED
	.ascii "TIME SIG"
	.byte 0x08, 0x06	; op 08, 6 bytes -> handler 0xF31A3A
	.short 0x127D
	.byte 0x15	; character codes below 0x20
	.ascii "="
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1952
	.ascii "1"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1957
	.ascii "2"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x195C
	.ascii "3"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1961
	.ascii "4"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1966
	.ascii "5"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x196B
	.ascii "6"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1970
	.ascii "7"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1975
	.ascii "8"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20AA
	.ascii "9"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20AF
	.ascii "10"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20B4
	.ascii "11"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20B9
	.ascii "12"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20BE
	.ascii "13"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20C3
	.ascii "14"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20C8
	.ascii "15"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20CD
	.ascii "16"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00A0
	.short 0x0022
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00A0
	.short 0x004A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00A0
	.short 0x0072
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00A0
	.short 0x009A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00A0
	.short 0x00C2
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00A0
	.short 0x00EA
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00A0
	.short 0x0112
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00A0
	.short 0x013A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00CF
	.short 0x0022
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00CF
	.short 0x004A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00CF
	.short 0x0072
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00CF
	.short 0x009A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00CF
	.short 0x00C2
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00CF
	.short 0x00EA
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00CF
	.short 0x0112
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00CF
	.short 0x013A
	.short 0x00E9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AD
	.short 0x0024
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00AD
	.short 0x004C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00AD
	.short 0x0074
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00AD
	.short 0x009C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00AD
	.short 0x00C4
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00AD
	.short 0x00EC
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00AD
	.short 0x0114
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00AD
	.short 0x013C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DC
	.short 0x0024
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00DC
	.short 0x004C
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00DC
	.short 0x0074
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DC
	.short 0x009C
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DC
	.short 0x00C4
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00DC
	.short 0x00EC
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00DC
	.short 0x0114
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00DC
	.short 0x013C
	.short 0x00DC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00FF
	.short 0x001D
	.short 0x0134
	.short 0x0030
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0101
	.short 0x001F
	.short 0x0132
	.short 0x002E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0020
	.short 0x0056
	.short 0x0033
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0022
	.short 0x0054
	.short 0x0031
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0043
	.short 0x003E
	.short 0x0059
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0045
	.short 0x003C
	.short 0x0057
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E3
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E5
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x006C
	.short 0x003E
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x006D
	.short 0x0134
	.short 0x0080
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x006E
	.short 0x003C
	.short 0x007D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E6
	.short 0x006F
	.short 0x0132
	.short 0x007E

; === COVER-R1 0xF34968-0xF34970 ===
; 0xF34968-0xF3496F, coverage round 1: 1 of this span's 8 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 1 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F34968 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F34968 appears as a 32-bit word at 0xF55CF0; converted
;               code at 0xF55CEF loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `ret`, with 0% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_f34968_fix_module.py: this
; 1 B object plus the 7 B .incbin that followed it is ONE interpreter-A
; op-0x0E record (handler 0xF31A9F, fixed 8 B, verified against the ROM's
; own handler table), the record immediately before the already-named
; DL_CycleMasterS0ngMeasureTimeSig list right after it.
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x0000
	.short 0x0028
	.short 0x00F0

; === END COVER-R1 0xF34968-0xF34970 ===

; ------------------------------------------------------------------
; 0xF34970-0xF349BA -- 6 display-list records, 75 bytes -- interpreter B
;   entered at: 0xF34970
;   ends used:  0xF349BB
; ------------------------------------------------------------------
; DL_CycleMasterS0ngMeasureTimeSig -- the display list at 0xF34970, named by
;                                     mechanism M3 of
;                                     notes/prom_b_dl_screens_round5.py.
;                                     "CYCLE:" ends at 0x0573  "MASTER:" ends
;                                     at 0x11A3  "S0NG" ends at 0x015D
;                                     "MEASURE =" ends at 0x0656  "TIME SIG.="
;                                     ends at 0x0ADF
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_CycleMasterS0ngMeasureTimeSig:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn_F349BB	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0573	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+19	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn_F349C1	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x11A3	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x0000264C	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0160	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+11	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x015D	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+4	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0656	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0ADF	; +0x07 -> IX
	.byte 0x01	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663

; === COVER-R1 0xF349BB-0xF349C7 ===
; 0xF349BB-0xF349C6, coverage round 1: 12 of this span's 12 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 12 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF349BB-0xF349C6 -- 12 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F349BB appears as a 32-bit word at 0xF34377 0xF34977
;               0xF55C9A; converted code at 0xF55C99 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 4 instructions and ends
;           `ld XIZ,0x4e4f2046`, with 0% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_OffOn_F349BB -- 0xF349BB-0xF349C0, 2 entries of 3 bytes, text drawn
;   by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 records
;   at 0xF34370 ((0x2647) AND 0xFF >> 0), 0xF34970 ((0x2647) AND 0xFF >> 0)
;   -- value = (byte at the +2 address) AND mask >> shift -- whose +0x07
;   names this address; DLB_Handler_StringTable draws entry [value] with
;   +0x0B = 3 as the width.  Entry count: the distance to the next table
;   over the width; the masks admit 256.  This address is also the END of a
;   display list: `ld XIY,0xF34970 / ld XIX,this / call T_DisplayListB_Run`
;   at 0xF55C99.
; --------------------------------------------------------------------------
DLText_OffOn_F349BB:
	.ascii	"OFF"	; F349BB  [0]
	.ascii	" ON"	; F349BE  [1]
; --------------------------------------------------------------------------
; DLText_OffOn_F349C1 -- 0xF349C1-0xF349C6, 2 entries of 3 bytes, text drawn
;   by LCD_Svc_07_DrawText8x16 / LCD_Svc_20_DrawText8x10.  Read by the
;   interpreter-B op-0x02 records at 0xF3437F ((0x1309) AND 0xFF >> 0),
;   0xF3497F ((0x1309) AND 0xFF >> 0) -- value = (byte at the +2 address)
;   AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 256.
; --------------------------------------------------------------------------
DLText_OffOn_F349C1:
	.ascii	"OFF"	; F349C1  [0]
	.ascii	" ON"	; F349C4  [1]

; === END COVER-R1 0xF349BB-0xF349C7 ===

; ------------------------------------------------------------------
; 0xF349C7-0xF34C6D -- 79 display-list records, 679 bytes -- interpreter A
;   entered at: 0xF349C7
;   ends used:  0xF34C6E
; ------------------------------------------------------------------
; DL_SequencerPlayS0ngCycleMeasure -- the display list at 0xF349C7.  Its own
;                                     text records read: "SEQUENCER PLAY";
;                                     "S0NG"; "CYCLE:"; "MEASURE ="; "MEAS";
;                                     "TIME SIG.="; "REC0RD"; "MASTER:" +1
;                                     more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SequencerPlayS0ngCycleMeasure:
	.byte 0x1C, 0x14	; op 1C, 20 bytes -> handler 0xF31A52
	.short 0x0015
	.short 0x0005
	.ascii "SEQUENCER PLAY"
	.byte 0x20, 0x08	; op 20, 8 bytes -> handler 0xF31A3A
	.short 0x0159
	.ascii "S0NG"
	.byte 0x20, 0x05	; op 20, 5 bytes -> handler 0xF31A3A
	.short 0x015F
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x054F
	.byte 0x11	; character codes below 0x20
	.byte 0x20, 0x0A	; op 20, 10 bytes -> handler 0xF31A3A
	.short 0x056D
	.ascii "CYCLE:"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x057B
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05A0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x064C
	.ascii "MEASURE = "
	.byte 0x20, 0x08	; op 20, 8 bytes -> handler 0xF31A3A
	.short 0x089A
	.ascii "MEAS"
	.byte 0x07, 0x0F	; op 07, 15 bytes -> handler 0xF31A3A
	.short 0x0AD4
	.ascii "TIME SIG.= "
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0AE0
	.ascii "/4"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B18
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B43
	.byte 0x8E	; character codes below 0x20
	.byte 0x20, 0x0A	; op 20, 10 bytes -> handler 0xF31A3A
	.short 0x0B5F
	.ascii "REC0RD"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x08, 0x06	; op 08, 6 bytes -> handler 0xF31A3A
	.short 0x1075
	.byte 0x15	; character codes below 0x20
	.ascii "="
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1158
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x117F
	.byte 0x11	; character codes below 0x20
	.byte 0x20, 0x0B	; op 20, 11 bytes -> handler 0xF31A3A
	.short 0x119C
	.ascii "MASTER:"
	.byte 0x20, 0x09	; op 20, 9 bytes -> handler 0xF31A3A
	.short 0x11AA
	.ascii "MIXER"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1952
	.ascii "1"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1957
	.ascii "2"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x195C
	.ascii "3"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1961
	.ascii "4"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1966
	.ascii "5"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x196B
	.ascii "6"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1970
	.ascii "7"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1975
	.ascii "8"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20AA
	.ascii "9"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20AF
	.ascii "10"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20B4
	.ascii "11"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20B9
	.ascii "12"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20BE
	.ascii "13"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20C3
	.ascii "14"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20C8
	.ascii "15"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x20CD
	.ascii "16"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F2
	.short 0x0043
	.short 0x0132
	.short 0x0056
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00A0
	.short 0x0022
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00A0
	.short 0x004A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00A0
	.short 0x0072
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00A0
	.short 0x009A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00A0
	.short 0x00C2
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00A0
	.short 0x00EA
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00A0
	.short 0x0112
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00A0
	.short 0x013A
	.short 0x00BA
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00CF
	.short 0x0022
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00CF
	.short 0x004A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00CF
	.short 0x0072
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00CF
	.short 0x009A
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00CF
	.short 0x00C2
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00CF
	.short 0x00EA
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00CF
	.short 0x0112
	.short 0x00E9
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00CF
	.short 0x013A
	.short 0x00E9
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E3
	.short 0x001D
	.short 0x0135
	.short 0x0030
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E5
	.short 0x001F
	.short 0x0133
	.short 0x002E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0020
	.short 0x002D
	.short 0x0033
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0022
	.short 0x002B
	.short 0x0031
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0044
	.short 0x002D
	.short 0x0057
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0046
	.short 0x002B
	.short 0x0055
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00DA
	.short 0x006B
	.short 0x0134
	.short 0x007E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x006C
	.short 0x003E
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00DC
	.short 0x006D
	.short 0x0132
	.short 0x007C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x006E
	.short 0x003C
	.short 0x007D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AD
	.short 0x0024
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00AD
	.short 0x004C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00AD
	.short 0x0074
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00AD
	.short 0x009C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00AD
	.short 0x00C4
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00AD
	.short 0x00EC
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00AD
	.short 0x0114
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00AD
	.short 0x013C
	.short 0x00AD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DC
	.short 0x0024
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00DC
	.short 0x004C
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00DC
	.short 0x0074
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DC
	.short 0x009C
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DC
	.short 0x00C4
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00DC
	.short 0x00EC
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00DC
	.short 0x0114
	.short 0x00DC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00DC
	.short 0x013C
	.short 0x00DC

; === COVER-R1 0xF34C6E-0xF34D98 ===
; ⚠ AMENDED 2026-09-02 (lane promB5, notes/gen_promB5_spans.py): 224 of the 243 B
; this band left `.incbin` are now typed data -- the 16x6 and 16x8 operand
; arrays that the two interpreter-B records just above them point at.  7 B at
; 0xF34C9B remain; the other 12 were closed by gen_prom_b_f34ca2_fix_module.py.
; 0xF34C6E-0xF34D97, coverage round 1: 55 of this span's 298 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 55 as DATA (only
; a `.long` or a 32-bit immediate names it) in 3 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F34C6E -- 45 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F34C6E appears as a 32-bit word at 0xF3412D 0xF3413E
;               0xF3414F 0xF34160 0xF34171 +5 more; converted code at 0xF55C69
;               0xF55DF8 loads it as a 32-bit immediate.  No routine-directory
;               slot and no branch decoded in converted code names it.
; Measured: 44% printable ASCII; a linear decode runs 20 instructions and ends
;           `ret`, with 33% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F34C6E:
	.byte	0x20, 0x52, 0x45, 0x43, 0x50, 0x4C, 0x41, 0x59, 0x20, 0x20, 0x20, 0x20, 0x20, 0x17, 0x25, 0x17	; F34C6E  | RECPLAY     .%.|
	.byte	0x2A, 0x17, 0x2F, 0x17, 0x34, 0x17, 0x39, 0x17, 0x3E, 0x17, 0x43, 0x17, 0xA0, 0x1E, 0xA5, 0x1E	; F34C7E  |*./.4.9.>.C.....|
	.byte	0xAA, 0x1E, 0xAF, 0x1E, 0xB4, 0x1E, 0xB9, 0x1E, 0xBE, 0x1E, 0xC3, 0x1E, 0x0E	; F34C8E  |.............|

; --- 0xF34C9B-0xF34CA1, 7 B, converted by lane promB6 (DLTAIL).
;     one interpreter record op 0x0E, length 8, whose first byte 0xF34C9A the
;     previous `.byte` row absorbed.  Handler 0xF31A9F reads three 16-bit
;     operands -- exactly the 8 bytes -- and the record lands on Data_F34CA2,
;     which a previous pass already re-framed as a record start
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x08, 0x20, 0x17, 0x28, 0x00, 0x4B, 0x00	; F34C9B  rest of the op 0x0E record that starts at F34C9A

; --------------------------------------------------------------------------
; Data_F34CA2 -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F34CA2 appears as a 32-bit word at 0xF55E2F 0xF55E5B;
;               converted code at 0xF55E2E 0xF55E5A loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 0% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_f34ca2_fix_module.py: this
; 5 B object plus the 6 B .incbin that followed it is ONE interpreter-B
; op-0x03 record (handler 0xF31B57, fixed 11 B, verified against the
; ROM's own HTBL_B table -- interpreter A's op-0x03 rule is fixed-12 and
; does NOT fit these 11 bytes).  Lands exactly on Data_F34CAD, below.
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57
	.byte 0xF6, 0x12, 0xFF, 0x00, 0x05, 0x18, 0x4D, 0xF3, 0x00

; --------------------------------------------------------------------------
; Data_F34CAD -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F34CAD appears as a 32-bit word at 0xF55E66; converted
;               code at 0xF55E65 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 20% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; NARROWED 2026-09-02 -- see notes/gen_prom_b_f34ca2_fix_module.py: this
; 5 B object plus the FIRST 6 of the 230 B .incbin that followed it is
; ONE interpreter-B op-0x04 record (fixed 11 B, verified against the
; ROM's own HTBL_B table).  The remaining 224 B is NOT walked by this
; pass and stays .incbin.
	.byte 0x04, 0x0B	; B op 04, 11 bytes -> handler (HTBL_B[4])
	.byte 0xF6, 0x12, 0xFF, 0x00, 0x0E, 0xB8, 0x4C, 0xF3, 0x00

; ------------------------------------------------------------------
; DLTable_F34CB8 -- 16 entries of 6 bytes (96 bytes).
; Referenced by interpreter-B display-list record 0xF34CAD, whose +7
; pointer lands here and whose handler fixes the entry size.  16
; entries is the EXTENT (96 / 6); the record's (mask >> shift) + 1
; would allow up to 256.
; ------------------------------------------------------------------
DLTable_F34CB8:
	.short 0x1900, 0x0005, 0x000E	; [0]
	.short 0x1905, 0x0005, 0x000E	; [1]
	.short 0x190A, 0x0005, 0x000E	; [2]
	.short 0x190F, 0x0005, 0x000E	; [3]
	.short 0x1914, 0x0005, 0x000E	; [4]
	.short 0x1919, 0x0005, 0x000E	; [5]
	.short 0x191E, 0x0005, 0x000E	; [6]
	.short 0x1923, 0x0005, 0x000E	; [7]
	.short 0x20D0, 0x0005, 0x000E	; [8]
	.short 0x20D5, 0x0005, 0x000E	; [9]
	.short 0x20DA, 0x0005, 0x000E	; [10]
	.short 0x20DF, 0x0005, 0x000E	; [11]
	.short 0x20E4, 0x0005, 0x000E	; [12]
	.short 0x20E9, 0x0005, 0x000E	; [13]
	.short 0x20EE, 0x0005, 0x000E	; [14]
	.short 0x20F3, 0x0005, 0x000E	; [15]

; ------------------------------------------------------------------
; DLTable_F34D18 -- 16 entries of 8 bytes (128 bytes).
; Referenced by interpreter-B display-list records 0xF34000 0xF3400B 0xF34CA2, whose +7
; pointer lands here and whose handler fixes the entry size.  16
; entries is the EXTENT (128 / 8); the record's (mask >> shift) + 1
; would allow up to 256.
; ------------------------------------------------------------------
DLTable_F34D18:
	.short 0x0006, 0x00A1, 0x0022, 0x00AC	; [0]
	.short 0x002E, 0x00A1, 0x004A, 0x00AC	; [1]
	.short 0x0056, 0x00A1, 0x0072, 0x00AC	; [2]
	.short 0x007E, 0x00A1, 0x009A, 0x00AC	; [3]
	.short 0x00A6, 0x00A1, 0x00C2, 0x00AC	; [4]
	.short 0x00CE, 0x00A1, 0x00EA, 0x00AC	; [5]
	.short 0x00F6, 0x00A1, 0x0112, 0x00AC	; [6]
	.short 0x011E, 0x00A1, 0x013A, 0x00AC	; [7]
	.short 0x0006, 0x00D0, 0x0022, 0x00DB	; [8]
	.short 0x002E, 0x00D0, 0x004A, 0x00DB	; [9]
	.short 0x0056, 0x00D0, 0x0072, 0x00DB	; [10]
	.short 0x007E, 0x00D0, 0x009A, 0x00DB	; [11]
	.short 0x00A6, 0x00D0, 0x00C2, 0x00DB	; [12]
	.short 0x00CE, 0x00D0, 0x00EA, 0x00DB	; [13]
	.short 0x00F6, 0x00D0, 0x0112, 0x00DB	; [14]
	.short 0x011E, 0x00D0, 0x013A, 0x00DB	; [15]

; === END COVER-R1 0xF34C6E-0xF34D98 ===

; ------------------------------------------------------------------
; 0xF34D98-0xF34E87 -- 16 display-list records, 240 bytes -- interpreter B
;   entered at: 0xF34D98
;   ends used:  0xF34E88
; ------------------------------------------------------------------
SeqScreen_DrawTrackPartLabels_DL:
; drawn (start operand) by SeqScreen_DrawTrackPartLabels -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B59	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B5E	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B63	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B68	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B6D	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B72	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B77	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B7C	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22B1	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22B6	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22BB	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+11	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22C0	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+12	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22C5	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+13	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22CA	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+14	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22CF	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+15	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_P1ToP32	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22D4	; +0x0D -> IX

; === COVER-R1 0xF34E88-0xF34EE8 ===
; 0xF34E88-0xF34EE7, coverage round 1: 96 of this span's 96 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 96 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF34E88-0xF34EE7 -- 96 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F34E88 appears as a 32-bit word at 0xF3401D 0xF3402E
;               0xF3403F 0xF34050 0xF34061 +28 more; converted code at
;               0xF55D86 loads it as a 32-bit immediate.  No routine-directory
;               slot and no branch decoded in converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 42 instructions and
;           ends `ld HL,0x0032`, with 12% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_P1ToP32 -- 0xF34E88-0xF34EE7, 32 entries of 3 bytes, text drawn by
;   LCD_Svc_06_DrawText8x14 / LCD_Svc_17_DrawText8x8Packed.  Read by the
;   interpreter-B op-0x02/0x07 records at 0xF34016 ((0x12F6) AND 0xFF >> 0),
;   0xF34027 ((0x12F7) AND 0xFF >> 0), 0xF34038 ((0x12F8) AND 0xFF >> 0),
;   0xF34049 ((0x12F9) AND 0xFF >> 0) and 28 more -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable/StringTable2 draws entry [value] with +0x0B = 3
;   as the width.  Entry count: the distance to the object's end over the
;   width; the masks admit 256.  This address is also the END of a display
;   list: `ld XIY,0xF34D98 / ld XIX,this / call T_DisplayListB_Run` at
;   0xF55D86.
; --------------------------------------------------------------------------
DLText_P1ToP32:
	.ascii	"P 1"	; F34E88  [0]
	.ascii	"P 2"	; F34E8B  [1]
	.ascii	"P 3"	; F34E8E  [2]
	.ascii	"P 4"	; F34E91  [3]
	.ascii	"P 5"	; F34E94  [4]
	.ascii	"P 6"	; F34E97  [5]
	.ascii	"P 7"	; F34E9A  [6]
	.ascii	"P 8"	; F34E9D  [7]
	.ascii	"P 9"	; F34EA0  [8]
	.ascii	"P10"	; F34EA3  [9]
	.ascii	"P11"	; F34EA6  [10]
	.ascii	"P12"	; F34EA9  [11]
	.ascii	"P13"	; F34EAC  [12]
	.ascii	"P14"	; F34EAF  [13]
	.ascii	"P15"	; F34EB2  [14]
	.ascii	"P16"	; F34EB5  [15]
	.ascii	"P17"	; F34EB8  [16]
	.ascii	"P18"	; F34EBB  [17]
	.ascii	"P19"	; F34EBE  [18]
	.ascii	"P20"	; F34EC1  [19]
	.ascii	"P21"	; F34EC4  [20]
	.ascii	"P22"	; F34EC7  [21]
	.ascii	"P23"	; F34ECA  [22]
	.ascii	"P24"	; F34ECD  [23]
	.ascii	"P25"	; F34ED0  [24]
	.ascii	"P26"	; F34ED3  [25]
	.ascii	"P27"	; F34ED6  [26]
	.ascii	"P28"	; F34ED9  [27]
	.ascii	"P29"	; F34EDC  [28]
	.ascii	"P30"	; F34EDF  [29]
	.ascii	"P31"	; F34EE2  [30]
	.ascii	"P32"	; F34EE5  [31]

; === END COVER-R1 0xF34E88-0xF34EE8 ===

; ------------------------------------------------------------------
; 0xF34EE8-0xF35034 -- 39 display-list records, 333 bytes -- interpreter A (33 records) and B (6)
;   entered at: 0xF34EE8, 0xF34FF2
;   ends used:  0xF34FF2, 0xF35001, 0xF35035
; ------------------------------------------------------------------
; DL_CyclePlayCurrentMeasureCycle -- the display list at 0xF34EE8.  Its own
;                                    text records read: "CYCLE"; "PLAY";
;                                    "CURRENT"; "MEASURE"; "CYCLE"; "CYCLE";
;                                    "START"; "MEASURE" +4 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_CyclePlayCurrentMeasureCycle:
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0068
	.short 0x0004
	.ascii "CYCLE"
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x00AA
	.short 0x0004
	.ascii "PLAY"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x05A3
	.ascii "CURRENT"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x05AB
	.ascii "MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05B7
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B64
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x0BE3
	.ascii "CYCLE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BEC
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x112C
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x112F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x11FB
	.ascii "CYCLE"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x1201
	.ascii "START"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x1207
	.ascii "MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x120F
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x17EB
	.ascii "CYCLE"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x17F1
	.ascii "END"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x17F5
	.ascii "MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17FF
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1DD7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1DFA
	.ascii "EXIT"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0041
	.short 0x0096
	.short 0x0060
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0067
	.short 0x00E5
	.short 0x0086
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x008D
	.short 0x00E5
	.short 0x00AC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0069
	.short 0x0135
	.short 0x007C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x006B
	.short 0x0133
	.short 0x007A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x00BA
	.short 0x0135
	.short 0x00CD
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x010B
	.short 0x00BC
	.short 0x0133
	.short 0x00CB
DL_F34FF2:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long Data_F35035	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0BED	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x05B8	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1210	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+20	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1800	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F35035 + 0x6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x08, 0x0B	; B op 08, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long Data_F35035 + 0x6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF35035-0xF3505B ===
; 0xF35035-0xF3505A, coverage round 1: 7 of this span's 38 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 7 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F35035 -- 7 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F35035 appears as a 32-bit word at 0xF34FF9 0xF351AE
;               0xF55EFC; converted code at 0xF55EFB loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 86% printable ASCII; a linear decode runs 3 instructions and ends
;           `ret`, with 0% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F35035:
	.byte	0x4F, 0x46, 0x46, 0x20, 0x4F, 0x4E, 0x0E	; F35035  |OFF ON.|

; --- 0xF3503C-0xF3505A, 31 B, converted by lane promB6 (SHORTARR8).
;     declared array base 0xF3503B
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x42, 0x00, 0x94, 0x00, 0x5E, 0x00	; F3503C  rest of the 8-byte entry at F3503B
	.short	0x000E, 0x0068, 0x00E3, 0x0084	; F35043  entry 1
	.short	0x000E, 0x008E, 0x00E3, 0x00AA	; F3504B  entry 2
	.short	0x000E, 0x0042, 0x00E3, 0x005E	; F35053  entry 3

; === END COVER-R1 0xF35035-0xF3505B ===

; ------------------------------------------------------------------
; 0xF3505B-0xF351F8 -- 48 display-list records, 414 bytes -- interpreter A (41 records) and B (7)
;   entered at: 0xF3505B, 0xF351A7
;   ends used:  0xF351A7, 0xF351F9
; ------------------------------------------------------------------
; DL_CycleRecordCurrentMeasure -- the display list at 0xF3505B.  Its own text
;                                 records read: "CYCLE"; "RECORD"; "CURRENT";
;                                 "MEASURE"; "CYCLE"; "CYCLE"; "START";
;                                 "MEASURE" +5 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_CycleRecordCurrentMeasure:
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0058
	.short 0x0003
	.ascii "CYCLE"
	.byte 0x1C, 0x0C	; op 1C, 12 bytes -> handler 0xF31A52
	.short 0x009A
	.short 0x0003
	.ascii "RECORD"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0549
	.byte 0x87	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0577
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x05A3
	.ascii "CURRENT"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x05AB
	.ascii "MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05B7
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B64
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B90
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x0BE3
	.ascii "CYCLE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BEB
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x112C
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x112F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x11FB
	.ascii "CYCLE"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x1201
	.ascii "START"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x1207
	.ascii "MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x120F
	.ascii ":"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x17EB
	.ascii "CYCLE"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x17F1
	.ascii "END"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x17F5
	.ascii "MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17FF
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1DD7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1DD8
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1DFA
	.ascii "EXIT"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1E52
	.ascii "CLEAR"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0041
	.short 0x0096
	.short 0x0060
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0067
	.short 0x00E5
	.short 0x0086
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x008D
	.short 0x00E5
	.short 0x00AC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00FF
	.short 0x001D
	.short 0x0134
	.short 0x0030
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0101
	.short 0x001F
	.short 0x0132
	.short 0x002E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0069
	.short 0x0135
	.short 0x007C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x006B
	.short 0x0133
	.short 0x007A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x00BA
	.short 0x0135
	.short 0x00CD
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x00BB
	.short 0x003E
	.short 0x00D1
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x010B
	.short 0x00BC
	.short 0x0133
	.short 0x00CB
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x00BD
	.short 0x003C
	.short 0x00CF
CycleRecordScreen_DrawValues_DL:
; drawn (start operand) by CycleRecordScreen_DrawValues -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long Data_F35035	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0BED	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+8	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn_F343B6	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0573	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x05B8	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+22	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1210	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1800	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F35035 + 0x6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x08, 0x0B	; B op 08, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long Data_F35035 + 0x6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF351F9-0xF35208 ===
; 0xF351F9-0xF35207, coverage round 1: 4 of this span's 15 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 4 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F351F9 -- 4 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F351F9 appears as a 32-bit word at 0xF55F57 0xF55F69;
;               converted code at 0xF55F56 0xF55F68 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 0% printable ASCII; a linear decode runs 2 instructions and ends
;           `retd 0x12f6`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_tiny_records_batch.py: this object plus
; the .incbin that followed it is ONE interpreter-B record (verified against
; the ROM's own handler table, exactly one interpreter's implied-length rule fits).
Data_F351F9:
	.byte 0x02, 0x0F, 0xF6, 0x12, 0xFF, 0x00, 0x07, 0x5B, 0x43, 0xF3, 0x00, 0x03, 0x00, 0xB8, 0x05	; B op 02, 15 bytes -> handler HTBL_B[2]

; === END COVER-R1 0xF351F9-0xF35208 ===

; ------------------------------------------------------------------
; 0xF35208-0xF3533B -- 29 display-list records, 308 bytes -- interpreter A (23 records) and B (6)
;   entered at: 0xF35208, 0xF352F9
;   ends used:  0xF352F9, 0xF35308, 0xF3533C
; ------------------------------------------------------------------
; DL_CyclePlayCurrentMeasureEdit -- the display list at 0xF35208.  Its own
;                                   text records read: "CYCLE PLAY"; "CURRENT
;                                   MEASURE     :"; "EDIT"; "SOLO  :"; "CYCLE
;                                   START MEASURE :"; "CYCLE END MEASURE   :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_CyclePlayCurrentMeasureEdit:
	.byte 0x1C, 0x10	; op 1C, 16 bytes -> handler 0xF31A52
	.short 0x0060
	.short 0x0005
	.ascii "CYCLE PLAY"
	.byte 0x07, 0x19	; op 07, 25 bytes -> handler 0xF31A3A
	.short 0x05A3
	.ascii "CURRENT MEASURE     :"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05C2
	.ascii "EDIT"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05C7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B64
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B90
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x0BBB
	.ascii "SOLO  : "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x112C
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1157
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11F8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x19	; op 07, 25 bytes -> handler 0xF31A3A
	.short 0x11FB
	.ascii "CYCLE START MEASURE :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x19	; op 07, 25 bytes -> handler 0xF31A3A
	.short 0x17EB
	.ascii "CYCLE END MEASURE   :"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0041
	.short 0x00E5
	.short 0x0060
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0067
	.short 0x00E5
	.short 0x0086
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x008D
	.short 0x00E5
	.short 0x00AC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x010B
	.short 0x001F
	.short 0x0135
	.short 0x0033
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x010D
	.short 0x0021
	.short 0x0133
	.short 0x0031
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0117
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0069
	.short 0x0135
	.short 0x007C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0117
	.short 0x006B
	.short 0x0133
	.short 0x007A
DL_F352F9:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_OffOn_F3533C	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0BC3	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x05B8	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1210	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch+20	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1800	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F35035 + 0x6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x08, 0x0B	; B op 08, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long Data_F35035 + 0x6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF3533C-0xF35342 ===
; 0xF3533C-0xF35341, coverage round 1: 6 of this span's 6 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 6 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3533C-0xF35341 -- 6 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3533C appears as a 32-bit word at 0xF35300 0xF55EA1;
;               converted code at 0xF55EA0 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 100% printable ASCII; a linear decode runs 2 instructions and ends
;           `ld XIZ,0x4e4f2046`, with 0% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_OffOn_F3533C -- 0xF3533C-0xF35341, 2 entries of 3 bytes, text drawn
;   by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02 record at
;   0xF352F9 ((0x1308) AND 0xFF >> 0) -- value = (byte at the +2 address)
;   AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 256.  This address is also the END of a display list: `ld
;   XIY,0xF352F9 / ld XIX,this / call T_DisplayListB_Run` at 0xF55EA0.
; --------------------------------------------------------------------------
DLText_OffOn_F3533C:
	.ascii	"OFF"	; F3533C  [0]
	.ascii	" ON"	; F3533F  [1]

; === END COVER-R1 0xF3533C-0xF35342 ===

; ------------------------------------------------------------------
; 0xF35342-0xF353AA -- 11 display-list records, 105 bytes -- interpreter A (10 records) and B (1)
;   entered at: 0xF35342, 0xF3539F
;   ends used:  0xF3539F, 0xF353AB
; ------------------------------------------------------------------
; DL_MetronomeBalance -- the display list at 0xF35342.  Its own text records
;                        read: "METRONOME BALANCE".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MetronomeBalance:
	.byte 0x1C, 0x17	; op 1C, 23 bytes -> handler 0xF31A52
	.short 0x003D
	.short 0x0052
	.ascii "METRONOME BALANCE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1794
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17BF
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1D5C
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1D5F
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0093
	.short 0x0135
	.short 0x00A6
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x004F
	.short 0x0094
	.short 0x00E4
	.short 0x00C8
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0095
	.short 0x0133
	.short 0x00A4
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x00B7
	.short 0x0135
	.short 0x00CA
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x00B9
	.short 0x0133
	.short 0x00C8
MetronomeBalanceScreen_PaintValue_DL:
; drawn (start operand) by MetronomeBalanceScreen_PaintValue -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x0086	; +0x07 -> (0x2530)
	.short 0x00A6	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
; ==============================================================================
; 0xF353AB-0xF3934B -- THE PARAMETER-RANGE CLAMP MODULE, AND THE CONFIRMATION
;   PROMPT ABOVE IT.  16,289 bytes, of which 8079 are 0x0E padding.
; ==============================================================================
;
; ⚠ WHAT THE MODULE DOES.  ClampFieldToRange (0xF3702F) reads five 16-bit words
; off the caller's stack -- value, mask, shift, maximum, minimum -- and returns
; the value with ONE FIELD replaced by that field clamped, SIGNED, to [min,max]:
;   `and DE,(XIZ+0x08)` masks, Asr16ByCount shifts, `jr LE`/`jr GE` clamp, and
;   `cpl BC / and BC,(XIZ+0x08) / or BC,HL` merges the field back under the same
;   mask so every other bit survives.
; Everything else feeds it.  ClampParamValueById_From541 (0xF37069) and
; ClampParamValueById_From408 (0xF37594) take a PARAMETER ID, reduce it to a
; small index, and `jp` into one of SIX tables of arms; each arm pushes that
; parameter's minimum and maximum and falls into a shared tail.  The six tables
; are therefore the instrument's per-parameter RANGE TABLE, spelled as code.
;
; ⚠ WHAT IS NOT KNOWN.  WHICH parameter any index is.  The ids arrive from
; outside through six thunk slots and nothing in the span names one, so the six
; tables keep FRAMED names, not one arm is named, and 49 of the 64 labels are
; sub_XXXXXX with the gap stated.
;
; ⚠ WHERE THE BOUNDARIES COME FROM.  notes/prom_b_f067a6_layout.py, re-derived
; on EVERY run of this file with LO/HI moved to this span and its `seeds()`
; replaced (its defaults were bound to the other span at import time).  19
; segments, 0 conflicts between the barrier rules and the code walk.  Not from a
; linear decode -- notes/prom_a_linear_decode_check.py records why one pins
; nothing.
;
; ⚠ SIX ARM TABLES, AND EACH EXTENT IS PROVED BY ITS OWN INDEXER.  A `cp r,N /
; jrl UGT,<default>` immediately above every `add Xr,<base>` bounds the index, so
; the entry count is N+1 and the byte extent is 4*(N+1) -- which is exactly the
; segment the content rules found, six times over.  Nothing about a table's size
; is asserted here.
;   0xF370A7 42   0xF3719C 77   0xF37312 138
;   0xF3760E 42   0xF37705 60   0xF3782E 82
;
; ⚠ ONE LEAD LEFT OPEN.  0xF37E23 is an instruction boundary seven bytes past
; the thunk entry 0xF37E1C, and prom_b 0xF7AE62 spells it as a 32-bit word -- but
; that byte is still inside an `.incbin`, so one spelling in unknown bytes is not
; evidence of an entry point and no label is given.  --selftest pins both facts.
;
; ⚠ ONE RUN LEFT UNCLAIMED.  0xF38C4F-0xF38CFE decodes as `link XIZ` routines
; and two of its runs are byte-identical for 76 bytes, but NOTHING references any
; address inside it, so it is emitted as `.byte` with the decode stated rather
; than promoted to code.  Same rule as 0xF09E85 in the 0xF067A6 block.
;
; LAYOUT.  19 segments: 8 code (5426 bytes), 6 arm tables (1764 bytes),
; 2 data objects (1020 bytes) and 3 runs of 0x0E `ret` padding (8079 bytes).
; Substantive: 8210 of 16289.
;
; LABELS.  64, of which 15 carry a name derived from something and 49 are
; sub_XXXXXX with the gap stated.
;
; WHAT THE BLOCK TOUCHES, measured over the transcription itself.
; Heaviest 16-bit RAM words: (0x7FC0) x3 (0x21E7) x2 (0x7EE2) x2 (0x7EE3) x2 (0x2250) x2 (0x7F05) x2.
; That is a measurement of what the code ADDRESSES, not a claim about what it IS.
;
; REGENERATE:  python3 notes/gen_prom_b_f353ab_module.py
; CHECKS:      python3 notes/gen_prom_b_f353ab_module.py --selftest
; ==============================================================================

	.fill	5205, 1, 0x0E	; F353AB-F367FF  `ret` padding (asserted pure 0x0E)
