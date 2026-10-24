
; ------------------------------------------------------------------
; 0xF32800-0xF3281B -- 4 display-list records, 28 bytes -- interpreter A
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 247 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ------------------------------------------------------------------
	.byte 0x20, 0x07	; op 20, 7 bytes -> handler 0xF31A3A
	.short 0x0A06
	.ascii "1st"
	.byte 0x20, 0x07	; op 20, 7 bytes -> handler 0xF31A3A
	.short 0x0EDE
	.ascii "2nd"
	.byte 0x20, 0x07	; op 20, 7 bytes -> handler 0xF31A3A
	.short 0x13B6
	.ascii "3rd"
	.byte 0x20, 0x07	; op 20, 7 bytes -> handler 0xF31A3A
	.short 0x18B6
	.ascii "4th"

; --------------------------------------------------------------------------
; 0xF3281C-0xF3282B -- 24 bytes, EMITTED AS DATA (not promoted to code).
; SHRUNK 2026-09-02 from a declared 29 B: the trailing 5 declared bytes
; plus the 7 B .incbin that followed it were really the first record of
; the display list right after this object -- see
; notes/gen_prom_b_f3281c_fix_module.py.
; Reached from: 0x00F3281C appears as a 32-bit word at 0xF32830 0xF5C589;
;               converted code at 0xF5C588 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 21% printable ASCII; a linear decode runs 14 instructions and ends
;           `jp 0xf019`, with 76% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F3281C -- 0xF3281C-0xF3282B, 4 32-bit pointers, each to the
;   first byte of a display-list record (op 20 len 7).  Read by: `ld XIZ,this
;   / ld XIY,(XIZ+BC) / add BC,4 / ld XIX,(XIZ+BC) / call T_DisplayList_Run`
;   at 0xF5C588: entries k and k+1 bound list k.  Entry count: the object's
;   extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F3281C:
	.long	ValueGlyph_Bitmaps + 0x91F	; F3281C  [0]
	.long	ValueGlyph_Bitmaps + 0x91F	; F32820  [1]
	.long	ValueGlyph_Bitmaps + 0x926	; F32824  [2]
	.long	ValueGlyph_Bitmaps + 0x92D	; F32828  [3]
	.byte	0x15, 0x28, 0xF3, 0x00, 0x1C, 0x28, 0xF3, 0x00	; F3282C

; ------------------------------------------------------------------
; 0xF32834-0xF32863 -- 4 display-list records, 48 bytes -- interpreter A.
; The FIRST record (0xF32834-0xF32840, 12 B) was recovered from
; DLRecordPtrs_F3281C's oversized declaration (see notes/gen_prom_b_f3281c_fix_module.py);
; the other 3 (0xF32840-0xF32863) are as follows.
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 7 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ------------------------------------------------------------------
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE, recovered from DLRecordPtrs_F3281C's oversized declaration
	.long Data_F0191A
	.short 0x0A06
	.short 0x0003
	.short 0x000A
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F0191A + 0x1E
	.short 0x0EDE
	.short 0x0003
	.short 0x000A
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F0191A + 0x3C
	.short 0x13B6
	.short 0x0003
	.short 0x000A
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F0191A + 0x5A
	.short 0x18B6
	.short 0x0003
	.short 0x000A

; --------------------------------------------------------------------------
; Data_F32864 -- 120 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32864 appears as a 32-bit word at 0xF32878 0xF5C567;
;               converted code at 0xF5C566 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 33% printable ASCII; a linear decode runs 65 instructions and ends
;           `db`, with 30% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32864:
	.byte	0x34, 0x28, 0xF3, 0x00, 0x34, 0x28, 0xF3, 0x00, 0x40, 0x28, 0xF3, 0x00, 0x4C, 0x28, 0xF3, 0x00	; F32864  |4(..4(..@(..L(..|
	.byte	0x58, 0x28, 0xF3, 0x00, 0x64, 0x28, 0xF3, 0x00, 0x8C, 0x28, 0xF3, 0x00, 0xA0, 0x28, 0xF3, 0x00	; F32874  |X(..d(...(...(..|
	.byte	0xB4, 0x28, 0xF3, 0x00, 0xC8, 0x28, 0xF3, 0x00, 0x09, 0x0A, 0x4F, 0x00, 0x41, 0x00, 0x58, 0x00	; F32884  |.(...(....O.A.X.|
	.byte	0x4A, 0x00, 0x01, 0x0A, 0x4D, 0x00, 0x45, 0x00, 0x4F, 0x00, 0x45, 0x00, 0x09, 0x0A, 0x4F, 0x00	; F32894  |J...M.E.O.E...O.|
	.byte	0x60, 0x00, 0x58, 0x00, 0x69, 0x00, 0x01, 0x0A, 0x4D, 0x00, 0x64, 0x00, 0x4F, 0x00, 0x64, 0x00	; F328A4  |`.X.i...M.d.O.d.|
	.byte	0x09, 0x0A, 0x4F, 0x00, 0x7F, 0x00, 0x58, 0x00, 0x88, 0x00, 0x01, 0x0A, 0x4D, 0x00, 0x83, 0x00	; F328B4  |..O...X.....M...|
	.byte	0x4F, 0x00, 0x83, 0x00, 0x09, 0x0A, 0x4F, 0x00, 0x9E, 0x00, 0x58, 0x00, 0xA7, 0x00, 0x01, 0x0A	; F328C4  |O.....O...X.....|
	.byte	0x4D, 0x00, 0xA2, 0x00, 0x4F, 0x00, 0xA2, 0x00	; F328D4  |M...O...|

; === END COVER-R1 0xF32709-0xF328DC ===

; ------------------------------------------------------------------
; 0xF328DC-0xF32991 -- 14 display-list records, 182 bytes -- interpreter B
;   entered at: 0xF328DC, 0xF3294B, 0xF32987
;   ends used:  0xF32918, 0xF3294B, 0xF32987, 0xF32992
; ------------------------------------------------------------------
DL_F328DC:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_KeyOnKeyOffLegato	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x0D4F	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x0C	; +0x04 AND mask
	.byte 0x02	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_KeyOnKeyOffLegato	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x1277	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x30	; +0x04 AND mask
	.byte 0x04	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_KeyOnKeyOffLegato	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x174F	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0xC0	; +0x04 AND mask
	.byte 0x06	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_KeyOnKeyOffLegato	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x1C4F	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x0D59	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x1281	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x1759	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x1C59	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x27A3	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F32A87	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
DL_F3294B:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+11	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_CtrLRRdm	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0D52	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+11	; +0x02 source variable, 16-bit address
	.byte 0x0C	; +0x04 AND mask
	.byte 0x02	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_CtrLRRdm	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x127A	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+11	; +0x02 source variable, 16-bit address
	.byte 0x30	; +0x04 AND mask
	.byte 0x04	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_CtrLRRdm	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1752	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+11	; +0x02 source variable, 16-bit address
	.byte 0xC0	; +0x04 AND mask
	.byte 0x06	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_CtrLRRdm	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1C52	; +0x0D -> IX
SoundEditToneLayerPanning_RepaintField_DL2:
; ; drawn (start operand) by SoundEditToneLayerPanning_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x27A3	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F32AAF	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF32992-0xF32A7D ===
; 0xF32992-0xF32A7C, coverage round 1: 158 of this span's 235 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 158 as DATA (only
; a `.long` or a 32-bit immediate names it) in 3 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F32992 -- 110 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ SUPERSEDED 2026-09-02 (lane res3xx): 110 is 6 bytes too long.  The
;   last 6 bytes are the head of the opcode-02 record at 0xF329FA, which
;   the pointer array at 0xF32A36 names and 0xF09AE1 runs; it is framed
;   below.  So: 104 bytes, and the `stays `.incbin`` sentence below no
;   longer holds for this span.
; Reached from: 0x00F32992 appears as a 32-bit word at 0xF329D2 0xF329EA
;               0xF5D42F 0xF5D693; converted code at 0xF5D42E 0xF5D692 loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 32% printable ASCII; a linear decode runs 56 instructions and ends
;           `reti`, with 50% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32992:
	.byte	0x00, 0x0A, 0xB2, 0x27, 0x7F, 0x00, 0x20, 0x53, 0x0D, 0x02, 0x00, 0x0A, 0xB3, 0x27, 0x7F, 0x00	; F32992  |...'.. S.....'..|
	.byte	0x20, 0x7B, 0x12, 0x02, 0x00, 0x0A, 0xB4, 0x27, 0x7F, 0x00, 0x20, 0x53, 0x17, 0x02, 0x00, 0x0A	; F329A2  | {.....'.. S....|
	.byte	0xB5, 0x27, 0x7F, 0x00, 0x20, 0x53, 0x1C, 0x02, 0x40, 0x29, 0xF3, 0x00, 0xDC, 0x28, 0xF3, 0x00	; F329B2  |.'.. S..@)...(..|
	.byte	0x18, 0x29, 0xF3, 0x00, 0x22, 0x29, 0xF3, 0x00, 0x2C, 0x29, 0xF3, 0x00, 0x36, 0x29, 0xF3, 0x00	; F329C2  |.)..")..,)..6)..|
	.byte	0x92, 0x29, 0xF3, 0x00, 0x9C, 0x29, 0xF3, 0x00, 0xA6, 0x29, 0xF3, 0x00, 0xB0, 0x29, 0xF3, 0x00	; F329D2  |.)...)...)...)..|
	.byte	0x4B, 0x29, 0xF3, 0x00, 0x4B, 0x29, 0xF3, 0x00, 0x92, 0x29, 0xF3, 0x00, 0x9C, 0x29, 0xF3, 0x00	; F329E2  |K)..K)...)...)..|
	.byte	0xA6, 0x29, 0xF3, 0x00, 0xB0, 0x29, 0xF3, 0x00	; F329F2  |.)...)..|

; ------------------------------------------------------------------
; 0xF329FA-0xF32A08 -- 1 display-list record, 15 bytes -- interpreter B.
; Formerly the last 6 bytes of Data_F32992 plus the 9-byte `.incbin`
; that followed it.
;
; THE START IS NAMED BY CODE, not by a stride: entries 1 and 2 of the
; LE32 pointer array at 0xF32A36 hold 0x00F329FA (entry 3 holds
; 0x00F32A09, the record run framed just below).  0xF09AE1 indexes that
; array -- `sla 0x02,WA / add XIY,XWA / ld XIY,(XIY)` -- and calls
; T_F41830 -> 0xF31AEC DisplayListB_RunOne, which sets XIX = XIY + 1 and
; so runs EXACTLY ONE record at the loaded address.  prom_b 0xF5D488
; loads that array (`ld XIY,0x00f32a36`).
; The record's 15-byte extent is handler 0xF31B21's, and it ends exactly
; on 0xF32A09.  Verify: python3 notes/gen_prom_b_res3xx_spans.py --selftest
; ------------------------------------------------------------------
DL_F329FA:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x80	; +0x04 AND mask
	.byte 0x07	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_NonLegChord	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x0D4F	; +0x0D -> IX


; ------------------------------------------------------------------
; 0xF32A09-0xF32A35 -- 3 display-list records, 45 bytes -- interpreter B
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 9 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ------------------------------------------------------------------
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x80	; +0x04 AND mask
	.byte 0x07	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_NonLegChord	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x1277	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x80	; +0x04 AND mask
	.byte 0x07	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_NonLegChord	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x174F	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0x80	; +0x04 AND mask
	.byte 0x07	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_NonLegChord	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x1C4F	; +0x0D -> IX

; --------------------------------------------------------------------------
; Data_F32A36 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32A36 appears as a 32-bit word at 0xF5D489; converted
;               code at 0xF5D488 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `swi 2`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32A36:
	.byte	0xFA	; F32A36  |.|

; --- 0xF32A37-0xF32A4D, 23 B, converted by lane promB6 (PTRTAB4).
;     6-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x29, 0xF3, 0x00	; F32A37  top 3 bytes of the entry at F32A36 = 0x00F329FA
	.long	DL_F329FA	; F32A3A  entry 1
	.long	DL_F329FA	; F32A3E  entry 2
	.long	DL_F329FA + 0xF	; F32A42  entry 3
	.long	DL_F329FA + 0x1E	; F32A46  entry 4
	.long	DL_F329FA + 0x2D	; F32A4A  entry 5

; --------------------------------------------------------------------------
; 0xF32A4E-0xF32A7C -- 47 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32A4E appears as a 32-bit word at 0xF0654B 0xF0655A
;               0xF32952 0xF32961 0xF32970 +1 more.  No routine-directory slot
;               and no branch decoded in converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 19 instructions and
;           ends `ld XIX,0x00002020`, with 13% of the bytes in spellings llvm-
;           mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_CtrLRRdm -- 0xF32A4E-0xF32A59, 4 entries of 3 bytes, text drawn by
;   LCD_Svc_06_DrawText8x14 / LCD_Svc_20_DrawText8x10.  Read by the
;   interpreter-B op-0x02 records at 0xF06544 ((0x27B0) AND 0x03 >> 0),
;   0xF06553 ((0x27B0) AND 0x0C >> 2), 0xF3294B ((0x27B1) AND 0x03 >> 0),
;   0xF3295A ((0x27B1) AND 0x0C >> 2) and 2 more -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the next table over the width; the masks
;   admit 4.
; --------------------------------------------------------------------------
DLText_CtrLRRdm:
	.ascii	"CTR"	; F32A4E  [0]
	.ascii	"L  "	; F32A51  [1]
	.ascii	"R  "	; F32A54  [2]
	.ascii	"RDM"	; F32A57  [3]
; --------------------------------------------------------------------------
; DLText_KeyOnKeyOffLegato -- 0xF32A5A-0xF32A6E, 3 entries of 7 bytes, text
;   drawn by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02
;   records at 0xF328DC ((0x27A7) AND 0x03 >> 0), 0xF328EB ((0x27A7) AND
;   0x0C >> 2), 0xF328FA ((0x27A7) AND 0x30 >> 4), 0xF32909 ((0x27A7) AND
;   0xC0 >> 6) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_StringTable draws entry
;   [value] with +0x0B = 7 as the width.  Entry count: the distance to the
;   next table over the width; the masks admit 4.
; --------------------------------------------------------------------------
DLText_KeyOnKeyOffLegato:
	.ascii	"KEY ON "	; F32A5A  [0]
	.ascii	"KEY OFF"	; F32A61  [1]
	.ascii	"LEGATO "	; F32A68  [2]
; --------------------------------------------------------------------------
; DLText_NonLegChord -- 0xF32A6F-0xF32A7C, 2 entries of 7 bytes, text drawn
;   by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 records
;   at 0xF329FA ((0x27A8) AND 0x80 >> 7), 0xF32A09 ((0x27A9) AND 0x80 >> 7),
;   0xF32A18 ((0x27AA) AND 0x80 >> 7), 0xF32A27 ((0x27AB) AND 0x80 >> 7) --
;   value = (byte at the +2 address) AND mask >> shift -- whose +0x07 names
;   this address; DLB_Handler_StringTable draws entry [value] with +0x0B = 7
;   as the width.  Entry count: the distance to the object's end over the
;   width; the masks admit 2.
; --------------------------------------------------------------------------
DLText_NonLegChord:
	.ascii	"NON LEG"	; F32A6F  [0]
	.ascii	"CHORD  "	; F32A76  [1]

; === END COVER-R1 0xF32992-0xF32A7D ===

; ------------------------------------------------------------------
; 0xF32A7D-0xF32A86 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF32A7D
;   ends used:  0xF32A87
; ------------------------------------------------------------------
SoundEditToneLayerPanning_RepaintField_DL1:
; ; drawn (start operand) by SoundEditToneLayerPanning_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x004C
	.short 0x00AC
	.short 0x00C8

; === COVER-R1 0xF32A87-0xF32AD7 ===
; 0xF32A87-0xF32AD6, coverage round 1: 80 of this span's 80 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 80 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF32A87-0xF32AD6 -- 80 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32A87 appears as a 32-bit word at 0xF32947 0xF5D675;
;               converted code at 0xF5D674 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 12% printable ASCII; a linear decode runs 51 instructions and ends
;           `db`, with 50% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F32A87 -- 0xF32A87-0xF32AAE, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF32940 ((0x27A3)
;   AND 0x0F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   next table over the width; the masks admit 16.  This address is also the
;   END of a display list: `ld XIY,0xF32A7D / ld XIX,this / call
;   T_DisplayList_Run` at 0xF5D674.
; --------------------------------------------------------------------------
DLBoxes_F32A87:
	.short	13, 76, 172, 104	; F32A87  [0]
	.short	13, 76, 172, 104	; F32A8F  [1]
	.short	13, 108, 172, 136	; F32A97  [2]
	.short	13, 140, 172, 168	; F32A9F  [3]
	.short	13, 172, 172, 200	; F32AA7  [4]
; --------------------------------------------------------------------------
; DLBoxes_F32AAF -- 0xF32AAF-0xF32AD6, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF32987 ((0x27A3)
;   AND 0x0F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 16.
; --------------------------------------------------------------------------
DLBoxes_F32AAF:
	.short	13, 76, 132, 104	; F32AAF  [0]
	.short	13, 76, 132, 104	; F32AB7  [1]
	.short	13, 108, 132, 136	; F32ABF  [2]
	.short	13, 140, 132, 168	; F32AC7  [3]
	.short	13, 172, 132, 200	; F32ACF  [4]

; === END COVER-R1 0xF32A87-0xF32AD7 ===

; ------------------------------------------------------------------
; 0xF32AD7-0xF32B1D -- 5 display-list records, 71 bytes -- interpreter B
;   entered at: 0xF32AD7
;   ends used:  0xF32B1E
; ------------------------------------------------------------------
SoundEditToneLayerKeyLayer_Paint_DL2:
; ; drawn (start operand) by SoundEditToneLayerKeyLayer_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_NoteNamesCm2ToG8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x2292	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_NoteNamesCm2ToG8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x2298	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_NoteNamesCm2ToG8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x229D	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_NoteNamesCm2ToG8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22A2	; +0x0D -> IX
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x27A3	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F32B3C	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF32B1E-0xF32B32 ===
; 0xF32B1E-0xF32B31, coverage round 1: 9 of this span's 20 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 9 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F32B1E -- 9 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32B1E appears as a 32-bit word at 0xF5D510 0xF5D6CB;
;               converted code at 0xF5D50F 0xF5D6CA loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 22% printable ASCII; a linear decode runs 5 instructions and ends
;           `jp C,XWA0`, with 67% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32B1E:
	.byte	0x13, 0x2B, 0xF3, 0x00, 0xE6, 0x2A, 0xF3, 0x00, 0xD7	; F32B1E  |.+...*...|

; --- 0xF32B27-0xF32B31, 11 B, converted by lane promB6 (PTRTAB4).
;     5-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x2A, 0xF3, 0x00	; F32B27  top 3 bytes of the entry at F32B26 = 0x00F32AD7
	.long	SoundEditToneLayerKeyLayer_Paint_DL2 + 0x1E	; F32B2A  entry 3
	.long	SoundEditToneLayerKeyLayer_Paint_DL2 + 0x2D	; F32B2E  entry 4

; === END COVER-R1 0xF32B1E-0xF32B32 ===

; ------------------------------------------------------------------
; 0xF32B32-0xF32B3B -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF32B32
;   ends used:  0xF32B3C
; ------------------------------------------------------------------
DL_F32B32:
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0008
	.short 0x0049
	.short 0x00FA
	.short 0x00C5

; === COVER-R1 0xF32B3C-0xF32B64 ===
; 0xF32B3C-0xF32B63, coverage round 1: 5 of this span's 40 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 5 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F32B3C -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32B3C appears as a 32-bit word at 0xF32B1A 0xF32B93
;               0xF5D6BB 0xF5D6E3; converted code at 0xF5D6BA 0xF5D6E2 loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 20% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 2`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32B3C:
	.byte	0x08, 0x00, 0x49, 0x00, 0xFA	; F32B3C  |..I..|

; --- 0xF32B41-0xF32B63, 35 B, converted by lane promB6 (SHORTARR8).
;     declared array base 0xF32B3C
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x67, 0x00	; F32B41  rest of the 8-byte entry at F32B3C
	.short	0x0008, 0x0049, 0x00FA, 0x0067	; F32B44  entry 1
	.short	0x0008, 0x0068, 0x00FA, 0x0086	; F32B4C  entry 2
	.short	0x0008, 0x0087, 0x00FA, 0x00A5	; F32B54  entry 3
	.short	0x0008, 0x00A6, 0x00FA, 0x00C5	; F32B5C  entry 4

; === END COVER-R1 0xF32B3C-0xF32B64 ===

; ------------------------------------------------------------------
; 0xF32B64-0xF32B96 -- 5 display-list records, 51 bytes -- interpreter B
;   entered at: 0xF32B64
;   ends used:  0xF32B97
; ------------------------------------------------------------------
SoundEditToneLayerVelocityLayer_Paint_DL2:
; ; drawn (start operand) by SoundEditToneLayerVelocityLayer_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2291	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2297	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x229D	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x22A2	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x27A3	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F32B3C	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF32B97-0xF32BAB ===
; 0xF32B97-0xF32BAA, coverage round 1: 20 of this span's 20 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 20 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF32B97-0xF32BAA -- 20 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32B97 appears as a 32-bit word at 0xF5D556 0xF5D6F3;
;               converted code at 0xF5D555 0xF5D6F2 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 40% printable ASCII; a linear decode runs 10 instructions and ends
;           `ld (XWA0),0x00`, with 70% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F32B97 -- 0xF32B97-0xF32BAA, 5 32-bit pointers, each to the
;   first byte of a display-list record (op 00 len 10, op 03 len 11).  Read
;   by: `ld XIY,this / call RunDisplayListBFromPointerArray` at 0xF5D6F2: ONE
;   interpreter-B record from entry A.  Its address is also used as a list
;   end: `ld XIY,0xF32B64 / ld XIX,this / call T_DisplayListB_Run` at
;   0xF5D555: the END of the list that starts at 0xF32B64.  Entry count: the
;   object's extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F32B97:
	.long	SoundEditToneLayerVelocityLayer_Paint_DL2 + 0x28	; F32B97  [0]
	.long	SoundEditToneLayerVelocityLayer_Paint_DL2 + 0xA	; F32B9B  [1]
	.long	SoundEditToneLayerVelocityLayer_Paint_DL2	; F32B9F  [2]
	.long	SoundEditToneLayerVelocityLayer_Paint_DL2 + 0x14	; F32BA3  [3]
	.long	SoundEditToneLayerVelocityLayer_Paint_DL2 + 0x1E	; F32BA7  [4]

; === END COVER-R1 0xF32B97-0xF32BAB ===

; ------------------------------------------------------------------
; 0xF32BAB-0xF32C01 -- 7 display-list records, 87 bytes -- interpreter B
;   entered at: 0xF32BAB
;   ends used:  0xF32C02
; ------------------------------------------------------------------
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL2:
; ; drawn (start operand) by Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x22A6	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x22AC	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_NoteNamesCm2ToG8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x229D	; +0x0D -> IX
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x228D	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2292	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2297	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short ModelingPage_Fields+9	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_AttackDecayRelease	; +0x07 -> XIY: string table
	.short 0x0008	; +0x0B -> BC: bytes per entry
	.short 0x009D	; +0x0D -> (0x2530)
	.short 0x003E	; +0x0F -> (0x2532)

; === COVER-R1 0xF32C02-0xF32C2A ===
; 0xF32C02-0xF32C29, coverage round 1: 18 of this span's 40 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 18 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F32C02 -- 13 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F32C02 appears as a 32-bit word at 0xF5D610 0xF5D702;
;               converted code at 0xF5D60F 0xF5D701 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 23% printable ASCII; a linear decode runs 6 instructions and ends
;           `jp F,XWA0`, with 85% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32C02:
	.byte	0xAB, 0x2B, 0xF3, 0x00, 0xB6, 0x2B, 0xF3, 0x00, 0xC1, 0x2B, 0xF3, 0x00, 0xD0	; F32C02  |.+...+...+...|

; --- 0xF32C0F-0xF32C24, 22 B, converted by lane promB6 (PTRTAB4).
;     pointer array whose LAST entry is completed by the first byte of
;     Data_F32C25, so the array's own end (0xF32C26) is past this span; the 3
;     bytes of that entry inside the span stay `.byte`
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x2B, 0xF3, 0x00	; F32C0F  top 3 bytes of the entry at F32C0E = 0x00F32BD0
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL2 + 0x30	; F32C12  entry 4
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL2 + 0x3B	; F32C16  entry 5
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL2 + 0x46	; F32C1A  entry 6
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL2 + 0x46	; F32C1E  entry 7
	.byte	0xF1, 0x2B, 0xF3	; F32C22  past the array: 0xF1 trailing bytes

; --------------------------------------------------------------------------
; Data_F32C25 -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: nothing aligned holds this address; the walk fell through into
;               it.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 20% printable ASCII; a linear decode runs 2 instructions and ends
;           `ld (0xf32b),0x00`, with 80% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F32C25:
	.byte	0x00, 0xF1, 0x2B, 0xF3, 0x00	; F32C25  |..+..|

; === END COVER-R1 0xF32C02-0xF32C2A ===

; ------------------------------------------------------------------
; 0xF32C2A-0xF32FE5 -- 104 display-list records, 956 bytes -- interpreter A (92 records) and B (12)
;   entered at: 0xF32C2A, 0xF32D03, 0xF32D2C, 0xF32E71, 0xF32F43, 0xF32FA0, 0xF32FC8
;   ends used:  0xF32CC8, 0xF32D03, 0xF32D2C, 0xF32E71, 0xF32F43, 0xF32FA0, 0xF32FC8, 0xF32FE6
; ------------------------------------------------------------------
; DL_C0ntr0llerSoundEditDepth -- the display list at 0xF32C2A.  Its own text
;                                records read: "C0NTR0LLER"; "SOUND EDIT";
;                                "DEPTH"; "FUNCTION"; "1st 2nd 3rd 4th".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_C0ntr0llerSoundEditDepth:
	.byte 0x1C, 0x10	; op 1C, 16 bytes -> handler 0xF31A52
	.short 0x0072
	.short 0x0005
	.ascii "C0NTR0LLER"
	.byte 0x17, 0x10	; op 17, 16 bytes -> handler 0xF31A52
	.short 0x0006
	.short 0x0007
	.ascii "SOUND EDIT"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x2067
	.ascii "DEPTH"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x214B
	.ascii "FUNCTION"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x241E
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2451
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2457
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x245C
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B68
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1108
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x112F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x16D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x16F7
	.byte 0x11	; character codes below 0x20
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0013
	.short 0x00CC
	.short 0x005D
	.short 0x00E7
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0075
	.short 0x00CC
	.short 0x00A4
	.short 0x00E9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0075
	.short 0x00DB
	.short 0x00A4
	.short 0x00DB
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0076
	.short 0x00DC
	.short 0x00A3
	.short 0x00E8
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x0004
	.short 0x0044
	.short 0x0010
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x24
	.short 0x000B
	.byte 0x06, 0x13	; op 06, 19 bytes -> handler 0xF31A3A
	.short 0x206F
	.ascii "1st 2nd 3rd 4th"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2461
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2466
	.byte 0x12	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00B5
	.short 0x00CC
	.short 0x0133
	.short 0x00E9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00B5
	.short 0x00DB
	.short 0x0133
	.short 0x00DB
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x00B6
	.short 0x00DC
	.short 0x0132
	.short 0x00E8
; DL_1st2nd -- the display list at 0xF32D03.  Its own text records read: "1st
;              2nd".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_1st2nd:
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x206F
	.ascii "1st 2nd"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00B5
	.short 0x00CC
	.short 0x00F4
	.short 0x00E9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00B5
	.short 0x00DB
	.short 0x00F4
	.short 0x00DB
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x00B6
	.short 0x00DC
	.short 0x00F3
	.short 0x00E8
SoundEditController_PaintPage1_DL:
; ; drawn (start operand) by SoundEditController_PaintPage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x0110
	.ascii "PAGE1/2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0017
	.short 0x0099
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0027
	.short 0x0099
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0037
	.short 0x0099
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0047
	.short 0x0099
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0057
	.short 0x0099
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0067
	.short 0x0099
	.ascii "6"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00D1
	.short 0x0099
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00E1
	.short 0x0099
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00F1
	.short 0x0099
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0101
	.short 0x0099
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0111
	.short 0x0099
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0121
	.short 0x0099
	.ascii "6"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0043
	.short 0x007B
	.short 0x005C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00C5
	.short 0x0043
	.short 0x0136
	.short 0x005C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0067
	.short 0x007B
	.short 0x0080
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00C5
	.short 0x0067
	.short 0x0136
	.short 0x0080
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0013
	.short 0x0095
	.short 0x0021
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0023
	.short 0x0095
	.short 0x0031
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0033
	.short 0x0095
	.short 0x0041
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0043
	.short 0x0095
	.short 0x0051
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0053
	.short 0x0095
	.short 0x0061
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0063
	.short 0x0095
	.short 0x0071
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x0095
	.short 0x00DB
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00DD
	.short 0x0095
	.short 0x00EB
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00ED
	.short 0x0095
	.short 0x00FB
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x0095
	.short 0x010B
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x010D
	.short 0x0095
	.short 0x011B
	.short 0x00A2
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0095
	.short 0x012B
	.short 0x00A2
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x49
	.short 0x1079
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x24
	.short 0x107D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007B
	.short 0x004F
	.short 0x0094
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x004F
	.short 0x00C5
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007B
	.short 0x0073
	.short 0x0087
	.short 0x0073
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x0073
	.short 0x00C5
	.short 0x0073
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0094
	.short 0x004F
	.short 0x0094
	.short 0x0068
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x004F
	.short 0x00B3
	.short 0x0068
; DL_Page22AfterTouchCtrlPedal -- the display list at 0xF32E71.  Its own text
;                                 records read: "PAGE2/2"; "AFTER TOUCH";
;                                 "CTRL PEDAL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page22AfterTouchCtrlPedal:
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x0110
	.ascii "PAGE2/2"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0557
	.ascii "__"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0001
	.short 0x0024
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0A57
	.ascii "__"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0FA7
	.ascii "__"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x14A7
	.ascii "__"
	.byte 0x17, 0x11	; op 17, 17 bytes -> handler 0xF31A52
	.short 0x000A
	.short 0x009D
	.ascii "AFTER TOUCH"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x1A1F
	.ascii "__"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0001
	.short 0x00B4
	.byte 0x10	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0135
	.short 0x00B4
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x10	; op 17, 16 bytes -> handler 0xF31A52
	.short 0x000B
	.short 0x00C1
	.ascii "CTRL PEDAL"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x0023
	.short 0x00BC
	.short 0x0036
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x0043
	.short 0x012C
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x0065
	.short 0x012C
	.short 0x0078
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x0085
	.short 0x012C
	.short 0x0098
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x00A8
	.short 0x012C
	.short 0x00BB
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BC
	.short 0x0043
	.short 0x00BC
	.short 0x0056
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BC
	.short 0x0065
	.short 0x00BC
	.short 0x0078
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BC
	.short 0x0085
	.short 0x00BC
	.short 0x0098
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BC
	.short 0x00A8
	.short 0x00BC
	.short 0x00BB
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x5B
	.short 0x0553
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x5C
	.short 0x0A53
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x5D
	.short 0x0FA3
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x39
	.short 0x14A3
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x2D
	.short 0x19F3
DL_F32F43:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x0BBA	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x115A	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x0BD1	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x1171	; +0x0D -> IX
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short ModelingPage_Fields	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F33394	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short ModelingPage_Fields+14	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F33394 + 0x28	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short ModelingPage_Fields+15	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F33394 + 0x58	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
DL_F32FA0:
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+11	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2298	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+12	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerSwitchStateText	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x229F	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+12	; +0x02 source variable, 16-bit address
	.byte 0x0C	; +0x04 AND mask
	.byte 0x02	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerSwitchStateText	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22A3	; +0x0D -> IX
DL_F32FC8:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+12	; +0x02 source variable, 16-bit address
	.byte 0x30	; +0x04 AND mask
	.byte 0x04	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerSwitchStateText	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22A7	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+12	; +0x02 source variable, 16-bit address
	.byte 0xC0	; +0x04 AND mask
	.byte 0x06	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerSwitchStateText	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22AB	; +0x0D -> IX

; === COVER-R1 0xF32FE6-0xF33362 ===
; 0xF32FE6-0xF33361, coverage round 1: 892 of this span's 892 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 892 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; SoundEditController_HeaderRecords -- 0xF32FE6, 12 pointers to single
;   interpreter-B records (0xF32F43-0xF32FA0).  Read by
;   SoundEditController_PaintHeader: `ld XIY,this / call
;   RunDisplayListBFromPointerArray` at 0xF09957 -- A indexes it and ONE record
;   is run.  Entries 6-11 all name 0xF32FA0.  This address is also the END of
;   the interpreter-B list at DL_F32FC8 (`ld XIY,DL_F32FC8 / ld XIX,this /
;   call T_DisplayListB_Run` at 0xF0983A, 0xF09896, 0xF099D3, 0xF5D75D and
;   0xF5D7CD).
; ⚠ REPLACES `Data_F32FE6` (892 bytes: this array and the two string tables
;   below), whose header gave no layout and put its extent down to the
;   reachability walk.  python3 notes/promb-2026-09-25/
;   controller_destination_names.py checks every claim here.
; --------------------------------------------------------------------------
SoundEditController_HeaderRecords:
	.long	DL_F32F43 + 0x3C	; F32FE6  [0]
	.long	DL_F32F43	; F32FEA  [1]
	.long	DL_F32F43 + 0xF	; F32FEE  [2]
	.long	DL_F32F43 + 0x1E	; F32FF2  [3]
	.long	DL_F32F43 + 0x2D	; F32FF6  [4]
	.long	DL_F32F43 + 0x47	; F32FFA  [5]
	.long	DL_F32FA0	; F32FFE  [6]
	.long	DL_F32FA0	; F33002  [7]
	.long	DL_F32FA0	; F33006  [8]
	.long	DL_F32FA0	; F3300A  [9]
	.long	DL_F32FA0	; F3300E  [10]
	.long	DL_F32FA0	; F33012  [11]
; ControllerSwitchStateText -- 0xF33016, 4 entries of 3 bytes: OFF / ON /
;   --- / INV.  Read by 4 interpreter-B op-0x02 records at 0xF32FAA-0xF32FD7,
;   one per 2-bit field of (0x27B2) (masks 0x03/0x0C/0x30/0xC0, shifts 0/2/4/6,
;   entry width 3 at +0x0B): four switches, each OFF, ON, --- or INV.
ControllerSwitchStateText:
	.ascii	"OFF"	; F33016  [0]
	.ascii	"ON "	; F33019  [1]
	.ascii	"---"	; F3301C  [2]
	.ascii	"INV"	; F3301F  [3]
; --------------------------------------------------------------------------
; ControllerDestinationNames -- 0xF33022, 64 entries of 13 bytes: the names of
;   what a sound-edit controller can be assigned to -- PITCH BEND, SUSTAIN
;   LEVEL, FILTER CUTOFF, the pitch/amp/filter LFO depths and speeds,
;   FITTING .. REV DYNAMIC -- then 14 numbered placeholders "           50" ..
;   "           63".
; Read by: 13 interpreter-B op-0x02 records (DL_F32F43 and on: mask 0x3F,
;   width 13 at +0x0B) and UiText_CopyLabel13_To_22F0 (0xF5B800: `and
;   A,0x3F / mul A,13 / ld XIY,this` then a 13-byte copy to 0x22F0).  The
;   0x3F mask is the 64-entry bound; 64 x 13 ends exactly at SoundEditController_RepaintFieldPage1_DL1.
; --------------------------------------------------------------------------
ControllerDestinationNames:
	.ascii	"-------------"	; F33022  [0]
	.ascii	"PITCH BEND   "	; F3302F  [1]
	.ascii	"SUSTAIN LEVEL"	; F3303C  [2]
	.ascii	"FILTER CUTOFF"	; F33049  [3]
	.ascii	"PTCH LFO1 DEP"	; F33056  [4]
	.ascii	"PTCH LFO2 DEP"	; F33063  [5]
	.ascii	"PTCH LFO3 DEP"	; F33070  [6]
	.ascii	"PTCH LFO4 DEP"	; F3307D  [7]
	.ascii	"AMP LFO1 DEP "	; F3308A  [8]
	.ascii	"AMP LFO2 DEP "	; F33097  [9]
	.ascii	"AMP LFO3 DEP "	; F330A4  [10]
	.ascii	"AMP LFO4 DEP "	; F330B1  [11]
	.ascii	"FLTR LFO1 DEP"	; F330BE  [12]
	.ascii	"FLTR LFO2 DEP"	; F330CB  [13]
	.ascii	"FLTR LFO3 DEP"	; F330D8  [14]
	.ascii	"FLTR LFO4 DEP"	; F330E5  [15]
	.ascii	"PTCH LFO1 SPD"	; F330F2  [16]
	.ascii	"PTCH LFO2 SPD"	; F330FF  [17]
	.ascii	"PTCH LFO3 SPD"	; F3310C  [18]
	.ascii	"PTCH LFO4 SPD"	; F33119  [19]
	.ascii	"AMP LFO1 SPD "	; F33126  [20]
	.ascii	"AMP LFO2 SPD "	; F33133  [21]
	.ascii	"AMP LFO3 SPD "	; F33140  [22]
	.ascii	"AMP LFO4 SPD "	; F3314D  [23]
	.ascii	"FLTR LFO1 SPD"	; F3315A  [24]
	.ascii	"FLTR LFO2 SPD"	; F33167  [25]
	.ascii	"FLTR LFO3 SPD"	; F33174  [26]
	.ascii	"FLTR LFO4 SPD"	; F33181  [27]
	.ascii	"FITTING      "	; F3318E  [28]
	.ascii	"POSITION     "	; F3319B  [29]
	.ascii	"POS.DEPTH    "	; F331A8  [30]
	.ascii	"POS.COLOR    "	; F331B5  [31]
	.ascii	"POS.MOV.WIDTH"	; F331C2  [32]
	.ascii	"POS.MOV.SPEED"	; F331CF  [33]
	.ascii	"INTERACTION  "	; F331DC  [34]
	.ascii	"MUTING       "	; F331E9  [35]
	.ascii	"RESO.KEYSHIFT"	; F331F6  [36]
	.ascii	"SUB GAIN     "	; F33203  [37]
	.ascii	"DELAY        "	; F33210  [38]
	.ascii	"PANNING      "	; F3321D  [39]
	.ascii	"EFF1 SEND    "	; F3322A  [40]
	.ascii	"REV SEND     "	; F33237  [41]
	.ascii	"LEVEL        "	; F33244  [42]
	.ascii	"ATTACK TIME  "	; F33251  [43]
	.ascii	"DECAY TIME   "	; F3325E  [44]
	.ascii	"RELEASE TIME "	; F3326B  [45]
	.ascii	"FILTER RESO. "	; F33278  [46]
	.ascii	"EFF1 DYNAMIC "	; F33285  [47]
	.ascii	"EFF2 DYNAMIC "	; F33292  [48]
	.ascii	"REV DYNAMIC  "	; F3329F  [49]
	.ascii	"           50"	; F332AC  [50]
	.ascii	"           51"	; F332B9  [51]
	.ascii	"           52"	; F332C6  [52]
	.ascii	"           53"	; F332D3  [53]
	.ascii	"           54"	; F332E0  [54]
	.ascii	"           55"	; F332ED  [55]
	.ascii	"           56"	; F332FA  [56]
	.ascii	"           57"	; F33307  [57]
	.ascii	"           58"	; F33314  [58]
	.ascii	"           59"	; F33321  [59]
	.ascii	"           60"	; F3332E  [60]
	.ascii	"           61"	; F3333B  [61]
	.ascii	"           62"	; F33348  [62]
	.ascii	"           63"	; F33355  [63]

; === END COVER-R1 0xF32FE6-0xF33362 ===

; ------------------------------------------------------------------
; 0xF33362-0xF33393 -- 5 display-list records, 50 bytes -- interpreter A
;   entered at: 0xF33362, 0xF3338A
;   ends used:  0xF3338A, 0xF33394
; ------------------------------------------------------------------
SoundEditController_RepaintFieldPage1_DL1:
; ; drawn (start operand) by SoundEditController_RepaintFieldPage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0044
	.short 0x0079
	.short 0x005A
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C6
	.short 0x0044
	.short 0x0134
	.short 0x005A
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0068
	.short 0x0079
	.short 0x007E
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x0069
	.short 0x0134
	.short 0x007E
SoundEditController_RepaintFieldPage1_DL2:
; ; drawn (start operand) by SoundEditController_RepaintFieldPage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0015
	.short 0x0097
	.short 0x0129
	.short 0x00A0

; === COVER-R1 0xF33394-0xF3341C ===
; 0xF33394-0xF3341B, coverage round 1: 109 of this span's 136 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 109 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F33394 -- 109 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F33394 appears as a 32-bit word at 0xF09931 0xF32F86;
;               converted code at 0xF09930 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 23% printable ASCII; a linear decode runs 61 instructions and ends
;           `swi 1`, with 44% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F33394:
	.byte	0x0C, 0x00, 0x42, 0x00, 0x79, 0x00, 0x57, 0x00, 0x0C, 0x00, 0x45, 0x00, 0x79, 0x00, 0x5A, 0x00	; F33394  |..B.y.W...E.y.Z.|
	.byte	0x0C, 0x00, 0x69, 0x00, 0x79, 0x00, 0x7E, 0x00, 0xC7, 0x00, 0x45, 0x00, 0x34, 0x01, 0x5A, 0x00	; F333A4  |..i.y.~...E.4.Z.|
	.byte	0xC7, 0x00, 0x69, 0x00, 0x34, 0x01, 0x7E, 0x00, 0x15, 0x00, 0x97, 0x00, 0x1F, 0x00, 0xA0, 0x00	; F333B4  |..i.4.~.........|
	.byte	0x25, 0x00, 0x97, 0x00, 0x2F, 0x00, 0xA0, 0x00, 0x35, 0x00, 0x97, 0x00, 0x3F, 0x00, 0xA0, 0x00	; F333C4  |%.../...5...?...|
	.byte	0x45, 0x00, 0x97, 0x00, 0x4F, 0x00, 0xA0, 0x00, 0x55, 0x00, 0x97, 0x00, 0x5F, 0x00, 0xA0, 0x00	; F333D4  |E...O...U..._...|
	.byte	0x65, 0x00, 0x97, 0x00, 0x6F, 0x00, 0xA0, 0x00, 0xCF, 0x00, 0x97, 0x00, 0xD9, 0x00, 0xA0, 0x00	; F333E4  |e...o...........|
	.byte	0xDF, 0x00, 0x97, 0x00, 0xE9, 0x00, 0xA0, 0x00, 0xEF, 0x00, 0x97, 0x00, 0xF9	; F333F4  |.............|

; --- 0xF33401-0xF3341B, 27 B, converted by lane promB6 (SHORTARR8).
;     declared array base 0xF33394
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0xA0, 0x00	; F33401  rest of the 8-byte entry at F333FC
	.short	0x00FF, 0x0097, 0x0109, 0x00A0	; F33404  entry 14
	.short	0x010F, 0x0097, 0x0119, 0x00A0	; F3340C  entry 15
	.short	0x011F, 0x0097, 0x0129, 0x00A0	; F33414  entry 16

; === END COVER-R1 0xF33394-0xF3341C ===

; ------------------------------------------------------------------
; 0xF3341C-0xF334AD -- 10 display-list records, 146 bytes -- interpreter B
;   entered at: 0xF3341C
;   ends used:  0xF334AE
; ------------------------------------------------------------------
DL_F3341C:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x064A	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x0B4A	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x0B58	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x109A	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x10A8	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+6	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x1B12	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+7	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x1B20	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+8	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x159A	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+9	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long ControllerDestinationNames	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x15A8	; +0x0D -> IX
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short ModelingPage_Fields	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F334AE	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF334AE-0xF334FE ===
; 0xF334AE-0xF334FD, coverage round 1: 80 of this span's 80 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 80 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF334AE-0xF334FD -- 80 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F334AE appears as a 32-bit word at 0xF09882 0xF099AA
;               0xF334AA 0xF5D749; converted code at 0xF09881 0xF099A9
;               0xF5D748 loads it as a 32-bit immediate.  No routine-directory
;               slot and no branch decoded in converted code names it.
; Measured: 28% printable ASCII; a linear decode runs 47 instructions and ends
;           `db`, with 52% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F334AE -- 0xF334AE-0xF334FD, 10 entries of four words, left / top
;   / right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF334A3 ((0x27A6)
;   AND 0x0F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 16.  This address is also
;   the END of a display list: `ld XIY,0xF3341C / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF09881; `ld XIY,0xF3341C / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF099A9; `ld XIY,0xF3341C / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF5D748.
; --------------------------------------------------------------------------
DLBoxes_F334AE:
	.short	77, 37, 186, 52	; F334AE  [0]
	.short	77, 37, 186, 52	; F334B6  [1]
	.short	77, 69, 186, 84	; F334BE  [2]
	.short	190, 69, 298, 84	; F334C6  [3]
	.short	77, 103, 186, 118	; F334CE  [4]
	.short	190, 103, 298, 118	; F334D6  [5]
	.short	77, 170, 186, 185	; F334DE  [6]
	.short	190, 170, 298, 185	; F334E6  [7]
	.short	77, 135, 186, 150	; F334EE  [8]
	.short	190, 135, 298, 150	; F334F6  [9]

; === END COVER-R1 0xF334AE-0xF334FE ===

; ------------------------------------------------------------------
; 0xF334FE-0xF33507 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF334FE
;   ends used:  0xF33508
; ------------------------------------------------------------------
SoundEditController_RepaintFieldPage2_DL:
; ; drawn (start operand) by SoundEditController_RepaintFieldPage2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x004C
	.short 0x0024
	.short 0x012B
	.short 0x00BA

; === COVER-R1 0xF33508-0xF33538 ===
; 0xF33508-0xF33537, coverage round 1: 48 of this span's 48 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 48 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF33508-0xF33537 -- 48 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F33508 appears as a 32-bit word at 0xF09980 0xF09997
;               0xF099BE; converted code at 0xF0997F 0xF09996 0xF099BD loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 38% printable ASCII; a linear decode runs 21 instructions and ends
;           `ld (XWA0),0x00`, with 42% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F33508 -- 0xF33508-0xF33537, 12 32-bit pointers, each to the
;   first byte of a display-list record (op 00 len 10, op 02 len 15, op 03 len
;   11).  Read by: `ld XIY,this / call RunDisplayListBFromPointerArray` at
;   0xF099BD: ONE interpreter-B record from entry A.  Its address is also used
;   as a list end: `ld XIY,0xF334FE / ld XIX,this / call T_DisplayList_Run` at
;   0xF0997F: the END of the list that starts at 0xF334FE; `ld XIY,0xF334FE /
;   ld XIX,this / call T_DisplayList_Run` at 0xF09996: the END of the list
;   that starts at 0xF334FE.  Entry count: the object's extent over 4; every
;   word is a record start (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F33508:
	.long	DL_F3341C + 0x87	; F33508  [0]
	.long	DL_F3341C	; F3350C  [1]
	.long	DL_F3341C + 0xF	; F33510  [2]
	.long	DL_F3341C + 0x1E	; F33514  [3]
	.long	DL_F3341C + 0x2D	; F33518  [4]
	.long	DL_F3341C + 0x3C	; F3351C  [5]
	.long	DL_F3341C + 0x4B	; F33520  [6]
	.long	DL_F3341C + 0x5A	; F33524  [7]
	.long	DL_F3341C + 0x69	; F33528  [8]
	.long	DL_F3341C + 0x78	; F3352C  [9]
	.long	DL_F32FA0	; F33530  [10]
	.long	DL_F32FA0	; F33534  [11]

; === END COVER-R1 0xF33508-0xF33538 ===

; ------------------------------------------------------------------
; 0xF33538-0xF3356A -- 3 display-list records, 51 bytes -- interpreter B
;   entered at: 0xF33538
;   ends used:  0xF3356B
; ------------------------------------------------------------------
DL_F33538:
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short ModelingPage_Fields	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.long DLText_NoteNamesCm2ToG8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0020	; +0x0D -> (0x2530)
	.short 0x00D6	; +0x0F -> (0x2532)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.long DLTable_ABCDEFGHIJKLMNOPQRSU	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0058	; +0x0D -> (0x2530)
	.short 0x00D6	; +0x0F -> (0x2532)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x0070	; +0x0D -> (0x2530)
	.short 0x00D6	; +0x0F -> (0x2532)

; === COVER-R1 0xF3356B-0xF33573 ===
; 0xF3356B-0xF33572, coverage round 1: 8 of this span's 8 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 8 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3356B -- 8 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3356B appears as a 32-bit word at 0xF5D2CC 0xF5D2E0;
;               converted code at 0xF5D2CB 0xF5D2DF loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 50% printable ASCII; a linear decode runs 4 instructions and ends
;           `ld IY,0x00f3`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F3356B:
	.byte	0x38, 0x35, 0xF3, 0x00, 0x49, 0x35, 0xF3, 0x00	; F3356B  |85..I5..|

; === END COVER-R1 0xF3356B-0xF33573 ===

; ------------------------------------------------------------------
; 0xF33573-0xF3380D -- 69 display-list records, 667 bytes -- interpreter A (58 records) and B (11)
;   entered at: 0xF33573, 0xF336CE, 0xF33796
;   ends used:  0xF336CE, 0xF33796, 0xF337EF, 0xF3380E
; ------------------------------------------------------------------
; DL_DelayLevelTouchCurveGroupDump -- the display list at 0xF33573.  Its own
;                                     text records read: "DELAY"; "LEVEL";
;                                     "TOUCH"; "CURVE"; "GROUP DUMP";
;                                     "ON/OFF"; "GROUP"; "DELAY" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_DelayLevelTouchCurveGroupDump:
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0031
	.short 0x003E
	.ascii "DELAY"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0059
	.short 0x003E
	.ascii "LEVEL"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0083
	.short 0x003E
	.ascii "TOUCH"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x00AB
	.short 0x003E
	.ascii "CURVE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x0C30
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x11F8
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x10	; op 17, 16 bytes -> handler 0xF31A52
	.short 0x00F7
	.short 0x00C2
	.ascii "GROUP DUMP"
	.byte 0x17, 0x0C	; op 17, 12 bytes -> handler 0xF31A52
	.short 0x00F0
	.short 0x00CF
	.ascii "ON/OFF"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x011B
	.short 0x00CF
	.ascii "GROUP"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x002C
	.short 0x00D1
	.ascii "DELAY"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0056
	.short 0x00D1
	.ascii "LEVEL"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x007C
	.short 0x00D1
	.ascii "TOUCH"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x00A5
	.short 0x00D1
	.ascii "CURVE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21EF
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21F4
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21F9
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21FE
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x237F
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2384
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2389
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x238E
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2438
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x243D
	.byte 0x12	; character codes below 0x20
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0038
	.short 0x00D4
	.short 0x008A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00EC
	.short 0x00CB
	.short 0x013C
	.short 0x00E8
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0031
	.short 0x00DA
	.short 0x0046
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0059
	.short 0x00DA
	.short 0x006E
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0081
	.short 0x00DA
	.short 0x0096
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00DA
	.short 0x00BE
	.short 0x00EE
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x004A
	.short 0x00D4
	.short 0x004A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x006A
	.short 0x00D4
	.short 0x006A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EC
	.short 0x00D9
	.short 0x013C
	.short 0x00D9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0031
	.short 0x00E4
	.short 0x0046
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0059
	.short 0x00E4
	.short 0x006E
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0081
	.short 0x00E4
	.short 0x0096
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00E4
	.short 0x00BE
	.short 0x00E4
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002C
	.short 0x0038
	.short 0x002C
	.short 0x008A
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0043
	.short 0x0132
	.short 0x005C
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x00ED
	.short 0x00DA
	.short 0x013B
	.short 0x00E7
; DL_KeyOffModeTouchAtkDecay1Sust1Decay2Sust2 -- the display list at 0xF336CE.
;                                                Its own text records read:
;                                                "KEY OFF MODE :"; "TOUCH";
;                                                "ATK  DECAY1 SUST1 DECAY2
;                                                SUST2 RELEASE"; "ATK  DECAY".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_KeyOffModeTouchAtkDecay1Sust1Decay2Sust2:
	.byte 0x06, 0x13	; op 06, 19 bytes -> handler 0xF31A3A
	.short 0x1D60
	.byte 0x10	; character codes below 0x20
	.ascii "KEY OFF MODE :"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x010B
	.short 0x00C2
	.ascii "TOUCH"
	.byte 0x17, 0x2C	; op 17, 44 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x00CF
	.ascii "ATK  DECAY1 SUST1 DECAY2 SUST2 RELEASE"
	.byte 0x17, 0x10	; op 17, 16 bytes -> handler 0xF31A52
	.short 0x00FE
	.short 0x00CF
	.ascii "ATK  DECAY"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x241A
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x241F
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2424
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2429
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x242E
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2433
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2439
	.byte 0x12	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x243E
	.byte 0x12	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x00CB
	.short 0x00F1
	.short 0x00E8
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00FA
	.short 0x00CB
	.short 0x013E
	.short 0x00E8
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x00D9
	.short 0x00F1
	.short 0x00D9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FA
	.short 0x00D9
	.short 0x013E
	.short 0x00D9
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x00DA
	.short 0x00F0
	.short 0x00E7
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x00FB
	.short 0x00DA
	.short 0x013D
	.short 0x00E7
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0027
	.short 0x0132
	.short 0x0034
DL_F33796:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x80	; +0x04 AND mask
	.byte 0x07	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn_F034D8	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x227F	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2284	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x0D59	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x1259	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+6	; +0x02 source variable, 16-bit address
	.byte 0xE0	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x0D5F	; +0x07 -> IX
	.byte 0x01	; +0x09 digit count
	.byte 0x03	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+7	; +0x02 source variable, 16-bit address
	.byte 0xE0	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x125F	; +0x07 -> IX
	.byte 0x01	; +0x09 digit count
	.byte 0x03	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+8	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x0D4F	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+9	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x124F	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x0D53	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x1253	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x27A3	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F33840	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF3380E-0xF33836 ===
; 0xF3380E-0xF33835, coverage round 1: 40 of this span's 40 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 40 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3380E-0xF33835 -- 40 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3380E appears as a 32-bit word at 0xF5C71E 0xF5D052;
;               converted code at 0xF5C71D 0xF5D051 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 25% printable ASCII; a linear decode runs 18 instructions and ends
;           `ld SP,0x00f3`, with 78% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F3380E -- 0xF3380E-0xF33835, 10 32-bit pointers, each to the
;   first byte of a display-list record (op 00 len 10, op 02 len 15, op 03 len
;   11, op 05 len 11).  Read by: `ld XIY,this / call
;   RunDisplayListBFromPointerArray` at 0xF5D051: ONE interpreter-B record
;   from entry A.  Its address is also used as a list end: `ld XIY,0xF33796 /
;   ld XIX,this / call T_DisplayListB_Run` at 0xF5C71D: the END of the list
;   that starts at 0xF33796.  Entry count: the object's extent over 4; every
;   word is a record start (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F3380E:
	.long	DL_F33796 + 0x6D	; F3380E  [0]
	.long	DL_F33796	; F33812  [1]
	.long	DL_F33796 + 0x59	; F33816  [2]
	.long	DL_F33796 + 0x63	; F3381A  [3]
	.long	DL_F33796 + 0x19	; F3381E  [4]
	.long	DL_F33796 + 0x24	; F33822  [5]
	.long	DL_F33796 + 0x2F	; F33826  [6]
	.long	DL_F33796 + 0x3A	; F3382A  [7]
	.long	DL_F33796 + 0x45	; F3382E  [8]
	.long	DL_F33796 + 0x4F	; F33832  [9]

; === END COVER-R1 0xF3380E-0xF33836 ===

; ------------------------------------------------------------------
; 0xF33836-0xF3383F -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF33836
;   ends used:  0xF33840
; ------------------------------------------------------------------
SoundEditAmpLevel1_RepaintField_DL:
; ; drawn (start operand) by SoundEditAmpLevel1_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x004C
	.short 0x00D2
	.short 0x0088

; === COVER-R1 0xF33840-0xF33858 ===
; 0xF33840-0xF33857, coverage round 1: 24 of this span's 24 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 24 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF33840-0xF33857 -- 24 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F33840 appears as a 32-bit word at 0xF3380A 0xF5D020;
;               converted code at 0xF5D01F loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 21% printable ASCII; a linear decode runs 12 instructions and ends
;           `db`, with 58% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F33840 -- 0xF33840-0xF33857, 3 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF33803 ((0x27A3)
;   AND 0x0F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 16.  This address is also
;   the END of a display list: `ld XIY,0xF33836 / ld XIX,this / call
;   T_DisplayList_Run` at 0xF5D01F.
; --------------------------------------------------------------------------
DLBoxes_F33840:
	.short	13, 76, 210, 104	; F33840  [0]
	.short	13, 76, 210, 104	; F33848  [1]
	.short	13, 108, 210, 136	; F33850  [2]

; === END COVER-R1 0xF33840-0xF33858 ===

; ------------------------------------------------------------------
; 0xF33858-0xF338A4 -- 7 display-list records, 77 bytes -- interpreter B
;   entered at: 0xF33858
;   ends used:  0xF338A5
; ------------------------------------------------------------------
SoundEditAmpEnvelope1_Paint_DL2:
; ; drawn (start operand) by SoundEditAmpEnvelope1_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLText_OffOn	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1D70	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2261	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2265	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x226A	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x226F	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2280	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short ModelingPage_Fields+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2284	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed

; === COVER-R1 0xF338A5-0xF338C9 ===
; 0xF338A5-0xF338C8, coverage round 1: 25 of this span's 36 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 25 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F338A5 -- 25 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F338A5 appears as a 32-bit word at 0xF5C816 0xF5D082
;               0xF5D091; converted code at 0xF5C815 0xF5D081 0xF5D090 loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 40% printable ASCII; a linear decode runs 13 instructions and ends
;           `jp ULE,XWA0`, with 72% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F338A5:
	.byte	0x58, 0x38, 0xF3, 0x00, 0x67, 0x38, 0xF3, 0x00, 0x71, 0x38, 0xF3, 0x00, 0x7B, 0x38, 0xF3, 0x00	; F338A5  |X8..g8..q8..{8..|
	.byte	0x85, 0x38, 0xF3, 0x00, 0xC9, 0x38, 0xF3, 0x00, 0xD3	; F338B5  |.8...8...|

; --- 0xF338BE-0xF338C8, 11 B, converted by lane promB6 (PTRTAB4).
;     9-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x38, 0xF3, 0x00	; F338BE  top 3 bytes of the entry at F338BD = 0x00F338D3
	.long	SoundEditAmpEnvelope1_Paint_DL2 + 0x37	; F338C1  entry 7
	.long	SoundEditAmpEnvelope1_Paint_DL2 + 0x42	; F338C5  entry 8

; === END COVER-R1 0xF338A5-0xF338C9 ===

; ------------------------------------------------------------------
; 0xF338C9-0xF3391D -- 8 display-list records, 85 bytes -- interpreter A (2 records) and B (6)
;   entered at: 0xF338C9, 0xF338DD, 0xF338EB, 0xF338F6
;   ends used:  0xF338DD, 0xF338EB, 0xF338F6, 0xF3391E
; ------------------------------------------------------------------
Draw_Keyoff_DL1:
; ; drawn (start operand) by Draw_Keyoff -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x2274	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+6	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x227A	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
Draw_Keyoff_DL2:
; ; drawn (start operand) by Draw_Keyoff -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x20, 0x07	; op 20, 7 bytes -> handler 0xF31A3A
	.short 0x2274
	.ascii " --"
	.byte 0x20, 0x07	; op 20, 7 bytes -> handler 0xF31A3A
	.short 0x227A
	.ascii " --"
DL_F338EB:
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short ModelingPage_Fields	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F33A49	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
SoundEditModelingDriverWaveform_PaintRows_DL2:
; drawn (start operand) by SoundEditModelingDriverWaveform_PaintRows -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+8	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLTable_F0574D	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x12A0	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x12A2	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short ModelingPage_Fields+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.short 0x12B4	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663


; ------------------------------------------------------------------
; 0xF3391E-0xF339B3 -- 12 display-list records, 150 bytes -- interpreter A
; Formerly Data_F3391E -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F3391E:
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x27AF
	.short 0x003F
	.short 0x4D20
	.short 0xF057
	.byte 0x00, 0x02, 0x00, 0x20, 0x15	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x0000
	.short 0x0020
	.short 0x0023
	.byte 0x00, 0x0D, 0x00, 0x22, 0x15	; operand bytes the handler does not read
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x27AA
	.short 0x007F
	.short 0x3020
	.short 0x0315
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x27A8
	.short 0x007F
	.short 0x3420
	.short 0x0315
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x27B0
	.short 0x003F
	.short 0x4D20
	.short 0xF057
	.byte 0x00, 0x02, 0x00, 0xA0, 0x17	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x0000
	.short 0x1020
	.short 0x0023
	.byte 0x00, 0x0D, 0x00, 0xA2, 0x17	; operand bytes the handler does not read
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x27AB
	.short 0x007F
	.short 0xB020
	.short 0x0317
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x27A9
	.short 0x007F
	.short 0xB420
	.short 0x0317
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x27B1
	.short 0x003F
	.short 0x4D20
	.short 0xF057
	.byte 0x00, 0x02, 0x00, 0x20, 0x1A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x0000
	.short 0x2020
	.short 0x0023
	.byte 0x00, 0x0D, 0x00, 0x22, 0x1A	; operand bytes the handler does not read
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x27AC
	.short 0x007F
	.short 0x3020
	.short 0x031A
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x27AD
	.short 0x007F
	.short 0x3420
	.short 0x031A

; ------------------------------------------------------------------
; 0xF339B4-0xF339BB -- 1 display-list records, 8 bytes -- interpreter A
;   entered at: 0xF339B4
;   ends used:  0xF339BC
; ------------------------------------------------------------------
SoundEditModelingDriverWaveform_PaintRows_DL1:
; drawn (start operand) by SoundEditModelingDriverWaveform_PaintRows -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x12B0
	.ascii "  0-"

; === COVER-R1 0xF339BC-0xF33A3F ===
; 0xF339BC-0xF33A3E, coverage round 1: 55 of this span's 131 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 55 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF339BC-0xF33A1A -- 11 display-list records, 95 bytes -- interpreter A
; Formerly Data_F339BC -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
DL_F339BC:
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1533
	.ascii "-"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x17B3
	.ascii "-"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1A33
	.ascii "-"
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0030
	.short 0x0077
	.short 0x00A8
	.short 0x0084
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C0
	.short 0x0077
	.short 0x00F8
	.short 0x0084
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0040
	.short 0x0087
	.short 0x00B8
	.short 0x0094
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C0
	.short 0x0087
	.short 0x00F8
	.short 0x0094
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0040
	.short 0x0097
	.short 0x00B8
	.short 0x00A4
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C0
	.short 0x0097
	.short 0x00F8
	.short 0x00A4
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0040
	.short 0x00A7
	.short 0x00B8
	.short 0x00B4
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C0
	.short 0x00A7
	.short 0x00F8
	.short 0x00B4

; --------------------------------------------------------------------------
; Data_F33A1B -- 36 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F33A1B appears as a 32-bit word at 0xF5CC95; converted
;               code at 0xF5CC94 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 28% printable ASCII; a linear decode runs 19 instructions and ends
;           `ld (XWA0),0x00`, with 67% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F33A1B:
	.byte	0x1E, 0x39, 0xF3, 0x00, 0x50, 0x39, 0xF3, 0x00, 0x82, 0x39, 0xF3, 0x00, 0xDF, 0x39, 0xF3, 0x00	; F33A1B  |.9..P9...9...9..|
	.byte	0xF3, 0x39, 0xF3, 0x00, 0x07, 0x3A, 0xF3, 0x00, 0xBC, 0x39, 0xF3, 0x00, 0xC1, 0x39, 0xF3, 0x00	; F33A2B  |.9...:...9...9..|
	.byte	0xC6, 0x39, 0xF3, 0x00	; F33A3B  |.9..|

; === END COVER-R1 0xF339BC-0xF33A3F ===

; ------------------------------------------------------------------
; 0xF33A3F-0xF33A48 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF33A3F
;   ends used:  0xF33A49
; ------------------------------------------------------------------
SoundEditModelingDriverWaveform_RepaintField_DL:
; ; drawn (start operand) by SoundEditModelingDriverWaveform_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x003D
	.short 0x0076
	.short 0x00FC
	.short 0x00B4

; === COVER-R1 0xF33A49-0xF33A71 ===
; 0xF33A49-0xF33A70, coverage round 1: 21 of this span's 40 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 21 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F33A49 -- 21 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F33A49 appears as a 32-bit word at 0xF338F2 0xF5CC52;
;               converted code at 0xF5CC51 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 24% printable ASCII; a linear decode runs 14 instructions and ends
;           `swi 4`, with 29% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F33A49:
	.byte	0x3D, 0x00, 0x76, 0x00, 0xFC, 0x00, 0x84, 0x00, 0x3D, 0x00, 0x76, 0x00, 0xFC, 0x00, 0x84, 0x00	; F33A49  |=.v.....=.v.....|
	.byte	0x3D, 0x00, 0x86, 0x00, 0xFC	; F33A59  |=....|

; --- 0xF33A5E-0xF33A70, 19 B, converted by lane promB6 (SHORTARR8).
;     declared array base 0xF33A49
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x94, 0x00	; F33A5E  rest of the 8-byte entry at F33A59
	.short	0x003D, 0x0096, 0x00FC, 0x00A4	; F33A61  entry 3
	.short	0x003D, 0x00A6, 0x00FC, 0x00B4	; F33A69  entry 4

; === END COVER-R1 0xF33A49-0xF33A71 ===

; ------------------------------------------------------------------
; 0xF33A71-0xF33B8B -- 21 display-list records, 283 bytes -- interpreter B
;   entered at: 0xF33A71, 0xF33B09, 0xF33B81
;   ends used:  0xF33ABD, 0xF33B45, 0xF33B8C
; ------------------------------------------------------------------
Draw_ToneTemplateLevelKeyTune_DL3:
; ; drawn (start operand) by Draw_ToneTemplateLevelKeyTune -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short ModelingPage_Fields+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00B4	; +0x07 -> (0x2530)
	.short 0x0057	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D2	; +0x07 -> (0x2530)
	.short 0x0057	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00EA	; +0x07 -> (0x2530)
	.short 0x0057	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short ModelingPage_Fields+5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00B4	; +0x07 -> (0x2530)
	.short 0x0077	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D2	; +0x07 -> (0x2530)
	.short 0x0077	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00EA	; +0x07 -> (0x2530)
	.short 0x0077	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short ModelingPage_Fields+8	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00B4	; +0x07 -> (0x2530)
	.short 0x0097	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D2	; +0x07 -> (0x2530)
	.short 0x0097	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00EA	; +0x07 -> (0x2530)
	.short 0x0097	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short ModelingPage_Fields+11	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00B4	; +0x07 -> (0x2530)
	.short 0x00B7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+12	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D2	; +0x07 -> (0x2530)
	.short 0x00B7	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short ModelingPage_Fields+13	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00EA	; +0x07 -> (0x2530)
	.short 0x00B7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x00	; +0x0C bit 7 set = unsigned, clear = signed
Draw_ToneTemplateLevelKeyTune_DL4:
; ; drawn (start operand) by Draw_ToneTemplateLevelKeyTune -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+14	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLTable_ABCDEFGHIJKLMNOPQRSU	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0D4E	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x0D50	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+15	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLTable_ABCDEFGHIJKLMNOPQRSU	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x124E	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long 0x00002300	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x1250	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+16	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLTable_ABCDEFGHIJKLMNOPQRSU	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x174E	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long 0x00002310	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x1750	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short ModelingPage_Fields+17	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long DLTable_ABCDEFGHIJKLMNOPQRSU	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1C4E	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x20	; +0x06 swi 7 function
	.long 0x00002320	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x1C50	; +0x0D -> IX
Draw_ToneTemplateLevelKeyTune_DL5:
; ; drawn (start operand) by Draw_ToneTemplateLevelKeyTune -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x27A3	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F04CE8	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF33B8C-0xF33BD8 ===
; 0xF33B8C-0xF33BD7, coverage round 1: 41 of this span's 76 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 41 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F33B8C -- 41 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F33B8C appears as a 32-bit word at 0xF5C300 0xF5C32F
;               0xF5CE6F 0xF5CEA4; converted code at 0xF5C2FF 0xF5C32E
;               0xF5CE6E 0xF5CEA3 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 32% printable ASCII; a linear decode runs 19 instructions and ends
;           `jp Z,XWA0`, with 59% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F33B8C:
	.byte	0x81, 0x3B, 0xF3, 0x00, 0x71, 0x3A, 0xF3, 0x00, 0x71, 0x3A, 0xF3, 0x00, 0x7D, 0x3A, 0xF3, 0x00	; F33B8C  |.;..q:..q:..}:..|
	.byte	0x8A, 0x3A, 0xF3, 0x00, 0x97, 0x3A, 0xF3, 0x00, 0xA3, 0x3A, 0xF3, 0x00, 0xB0, 0x3A, 0xF3, 0x00	; F33B9C  |.:...:...:...:..|
	.byte	0xBD, 0x3A, 0xF3, 0x00, 0xC9, 0x3A, 0xF3, 0x00, 0xD6	; F33BAC  |.:...:...|

; --- 0xF33BB5-0xF33BD7, 35 B, converted by lane promB6 (PTRTAB4).
;     19-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x3A, 0xF3, 0x00	; F33BB5  top 3 bytes of the entry at F33BB4 = 0x00F33AD6
	.long	Draw_ToneTemplateLevelKeyTune_DL3 + 0x72	; F33BB8  entry 11
	.long	Draw_ToneTemplateLevelKeyTune_DL3 + 0x7E	; F33BBC  entry 12
	.long	Draw_ToneTemplateLevelKeyTune_DL3 + 0x8B	; F33BC0  entry 13
	.long	Draw_ToneTemplateLevelKeyTune_DL4	; F33BC4  entry 14
	.long	Draw_ToneTemplateLevelKeyTune_DL4 + 0x1E	; F33BC8  entry 15
	.long	Draw_ToneTemplateLevelKeyTune_DL4 + 0x3C	; F33BCC  entry 16
	.long	Draw_ToneTemplateLevelKeyTune_DL4 + 0x5A	; F33BD0  entry 17
	.long	Draw_ToneTemplateLevelKeyTune_DL5	; F33BD4  entry 18

; === END COVER-R1 0xF33B8C-0xF33BD8 ===

; ------------------------------------------------------------------
; 0xF33BD8-0xF33F00 -- 96 display-list records, 809 bytes -- interpreter A
;   entered at: 0xF33BD8
;   ends used:  0xF33F01
; ------------------------------------------------------------------
; DL_UserKitSoundEditSoundToneSelect -- the display list at 0xF33BD8.  Its own
;                                       text records read: "User Kit"; "SOUND
;                                       EDIT"; "SOUND"; "TONE SELECT";
;                                       "LEVEL"; "KEY"; "TUNE"; "PAN" +12
;                                       more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_UserKitSoundEditSoundToneSelect:
	.byte 0x1C, 0x0E	; op 1C, 14 bytes -> handler 0xF31A52
	.short 0x0070
	.short 0x0009
	.ascii "User Kit"
	.byte 0x17, 0x10	; op 17, 16 bytes -> handler 0xF31A52
	.short 0x0006
	.short 0x0007
	.ascii "SOUND EDIT"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0136
	.short 0x001F
	.byte 0x91	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x054C
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x059F
	.byte 0xA9	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x005E
	.short 0x0035
	.ascii ":"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0115
	.short 0x0038
	.ascii "SOUND"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0136
	.short 0x0046
	.byte 0x91	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8C
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0xA9	; character codes below 0x20
	.byte 0x17, 0x11	; op 17, 17 bytes -> handler 0xF31A52
	.short 0x0047
	.short 0x0064
	.ascii "TONE SELECT"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x00A2
	.short 0x0064
	.ascii "LEVEL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00C7
	.short 0x0064
	.ascii "KEY"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00E1
	.short 0x0064
	.ascii "TUNE"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0102
	.short 0x0064
	.ascii "PAN"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x011D
	.short 0x0064
	.ascii "REV"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0044
	.short 0x0076
	.ascii "."
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0043
	.short 0x007B
	.byte 0x91	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0044
	.short 0x0094
	.ascii "."
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x17E8
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0043
	.short 0x0099
	.byte 0x91	; character codes below 0x20
	.byte 0x06, 0x0F	; op 06, 15 bytes -> handler 0xF31A3A
	.short 0x1D53
	.ascii "DETAIL EDIT"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1DB0
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1DD7
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x0C	; op 17, 12 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x00D1
	.ascii "ON/OFF"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x002B
	.short 0x00D1
	.ascii "GROUP"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0050
	.short 0x00D1
	.ascii "TONE"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x007D
	.short 0x00D1
	.ascii "LEVEL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00AA
	.short 0x00D1
	.ascii "KEY"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00CF
	.short 0x00D1
	.ascii "TUNE"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0102
	.short 0x00D1
	.ascii "PAN"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x012B
	.short 0x00D1
	.ascii "REV"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21E9
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21EF
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21F3
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21F9
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x21FE
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2203
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2209
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x220E
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2379
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x237F
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2383
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2389
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x238E
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2393
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2399
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x239E
	.byte 0x8E	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x0004
	.short 0x0044
	.short 0x0010
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x001E
	.short 0x0135
	.short 0x0031
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0020
	.short 0x0133
	.short 0x002F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x002E
	.short 0x00FD
	.short 0x0049
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0039
	.short 0x0030
	.short 0x00FB
	.short 0x0047
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
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x005E
	.short 0x0135
	.short 0x00AA
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00B5
	.short 0x0135
	.short 0x00CA
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00D4
	.short 0x00B7
	.short 0x0133
	.short 0x00C8
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0001
	.short 0x00DA
	.short 0x0016
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0031
	.short 0x00DA
	.short 0x0046
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0051
	.short 0x00DA
	.short 0x0066
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0081
	.short 0x00DA
	.short 0x0096
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00DA
	.short 0x00BE
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x00DA
	.short 0x00E6
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0101
	.short 0x00DA
	.short 0x0116
	.short 0x00EE
	.byte 0x22, 0x0A	; op 22, 10 bytes -> handler 0xF31A75
	.short 0x0129
	.short 0x00DA
	.short 0x013E
	.short 0x00EE
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x006F
	.short 0x0135
	.short 0x006F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008C
	.short 0x0119
	.short 0x008C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0001
	.short 0x00E4
	.short 0x0016
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0031
	.short 0x00E4
	.short 0x0046
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0051
	.short 0x00E4
	.short 0x0066
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0081
	.short 0x00E4
	.short 0x0096
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00E4
	.short 0x00BE
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x00E4
	.short 0x00E6
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0101
	.short 0x00E4
	.short 0x0116
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0129
	.short 0x00E4
	.short 0x013E
	.short 0x00E4
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0038
	.short 0x005E
	.short 0x0038
	.short 0x00AA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009D
	.short 0x005E
	.short 0x009D
	.short 0x00AA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0119
	.short 0x005E
	.short 0x0119
	.short 0x00AA
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0003
	.short 0x001F
	.byte 0x91	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x052B
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0578
	.byte 0xA8	; character codes below 0x20
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0010
	.short 0x0038
	.ascii "NOTE"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0003
	.short 0x0046
	.byte 0x91	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B6B
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B90
	.byte 0xA8	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1D3A
	.ascii "WRITE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1DB0
	.byte 0x10	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001E
	.short 0x002E
	.short 0x0031
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0020
	.short 0x002C
	.short 0x002F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0045
	.short 0x002E
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x0047
	.short 0x002C
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00B5
	.short 0x003D
	.short 0x00CA
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x00B7
	.short 0x003B
	.short 0x00C8
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0071
	.short 0x0133
	.short 0x00A8

; --- 0xF33F01-0xF33FFF: 255 bytes of 0x0E fill (ret padding), not a
; display list -- a naive op/len walk from here decodes as 44 bogus
; [op 0x0E, len 14] records because 0x0E happens to be a valid
; opcode; measuring the run of the single repeated byte instead
; shows it is pure filler.  notes/gen_prom_b_f33f01_module.py
	.fill 255, 1, 0x0E
