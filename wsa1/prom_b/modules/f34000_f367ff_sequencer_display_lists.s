; ⚠ CAPTIONS TYPED WITH 0x30.  Some captions in this file
;   spell capital O with character code 0x30, the digit zero: `N0`, `S0NG`, `REC0RD`.  They are the ROM's
;   own bytes and stay as they are, as do the comments that quote them; six of the machine's seven Latin
;   faces draw cells 0x30 and 0x4F alike (notes/prom_b_screens_round8.py --glyphs).  Label names spell the
;   word with O (owner decision 2026-11-06, notes/zero-for-o/README.md).
;

; ------------------------------------------------------------------
; 0xF34000-0xF341B5 -- 27 display-list records, 438 bytes -- interpreter A (1 records) and B (26)
;   CORRECTED 2026-10-29 (lane gui-wsa1): this said 'interpreter A'.  The first 26 are B: the op-03 record's A reading is impossible (length 11) and its neighbours read as B (rules 'length', 'adjacent').
; the fill run above stops dead here; DL.walk() lands with ZERO
; DRIFT on 0xF341B6, the ALREADY CALL-VERIFIED start of DL_F341B6
; (see its own header below: "entered at: 0xF341B6").
; ------------------------------------------------------------------
DL_F34000:
	dlb_rect_entry	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=DLTable_F34D18
	dlb_rect_entry_op08	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_EraseRect, table=DLTable_F34D18
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=5, y=53
	dlb_string_xy	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=35, y=53
	dlb_string_xy	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=65, y=53
	dlb_string_xy	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=95, y=53
	dlb_string_xy	var=DisplayListB_Stage+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=125, y=53
	dlb_string_xy	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=155, y=53
	dlb_string_xy	var=DisplayListB_Stage+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=185, y=53
	dlb_string_xy	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=215, y=53
	dlb_string_xy	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=5, y=53
	dlb_string_xy	var=DisplayListB_Stage+9, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=35, y=53
	dlb_string_xy	var=DisplayListB_Stage+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=65, y=53
	dlb_string_xy	var=DisplayListB_Stage+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=95, y=53
	dlb_string_xy	var=DisplayListB_Stage+12, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=125, y=53
	dlb_string_xy	var=DisplayListB_Stage+13, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=155, y=53
	dlb_string_xy	var=DisplayListB_Stage+14, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=185, y=53
	dlb_string_xy	var=DisplayListB_Stage+15, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_P1ToP32, width=3, x=215, y=53
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=2, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=32, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=62, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=92, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=122, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=152, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=182, y=34
	dlb_string_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, table=Data_F34C6E, width=4, x=212, y=34
	dl_clear_area	x=0, y=24, w=240, h=9

; ------------------------------------------------------------------
; 0xF341B6-0xF34255 -- 16 display-list records, 160 bytes -- interpreter A
;   entered at: 0xF341B6
;   ends used:  0xF34256
; ------------------------------------------------------------------
DL_F341B6:
	dl_box_shadow2	x0=5, y0=160, x1=34, y1=186
	dl_box_shadow2	x0=45, y0=160, x1=74, y1=186
	dl_box_shadow2	x0=85, y0=160, x1=114, y1=186
	dl_box_shadow2	x0=125, y0=160, x1=154, y1=186
	dl_box_shadow2	x0=165, y0=160, x1=194, y1=186
	dl_box_shadow2	x0=205, y0=160, x1=234, y1=186
	dl_box_shadow2	x0=245, y0=160, x1=274, y1=186
	dl_box_shadow2	x0=285, y0=160, x1=314, y1=186
	dl_box_shadow2	x0=5, y0=207, x1=34, y1=233
	dl_box_shadow2	x0=45, y0=207, x1=74, y1=233
	dl_box_shadow2	x0=85, y0=207, x1=114, y1=233
	dl_box_shadow2	x0=125, y0=207, x1=154, y1=233
	dl_box_shadow2	x0=165, y0=207, x1=194, y1=233
	dl_box_shadow2	x0=205, y0=207, x1=234, y1=233
	dl_box_shadow2	x0=245, y0=207, x1=274, y1=233
	dl_box_shadow2	x0=285, y0=207, x1=314, y1=233

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
	dl_text8x8_packed	x=5, y=44, text=" 1 "
	dl_text8x8_packed	x=35, y=44, text=" 2 "
	dl_text8x8_packed	x=66, y=44, text=" "
	dl_text8x8_packed	x=65, y=44, text=" 3 "
	dl_text8x8_packed	x=95, y=44, text=" 4 "
	dl_text8x8_packed	x=125, y=44, text=" 5 "
	dl_text8x8_packed	x=155, y=44, text=" 6 "
	dl_text8x8_packed	x=186, y=44, text=" "
	dl_text8x8_packed	x=185, y=44, text=" 7 "
	dl_text8x8_packed	x=215, y=44, text=" 8 "
	dl_text8x8_packed	x=5, y=44, text=" 9 "
	dl_text8x8_packed	x=38, y=44, text="10"
	dl_text8x8_packed	x=68, y=44, text="11"
	dl_text8x8_packed	x=98, y=44, text="12"
	dl_text8x8_packed	x=131, y=44, text=" "
	dl_text8x8_packed	x=128, y=44, text="13"
	dl_text8x8_packed	x=158, y=44, text="14"
	dl_text8x8_packed	x=188, y=44, text="15"
	dl_text8x8_packed	x=218, y=44, text="16"
	dl_text8x14	x=280, y=8, text="YES \021"
	dl_text16x16_packed	x=17, y=40, text="Are You Sure ?"
	dl_text8x14	x=120, y=37, text="N0  \021"
	dl_box_shadow2	x0=10, y0=32, x1=180, y1=58
	dl_box	x0=196, y0=7, x1=228, y1=24
	dl_box	x0=198, y0=9, x1=226, y1=22
	dl_box	x0=196, y0=45, x1=228, y1=62
	dl_box	x0=198, y0=47, x1=226, y1=60

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
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLTable_F3435B, width=3, x=176, y=33

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
	dlb_string	var=UI_DrawScratch+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F343B6, width=3, x=280, y=34
	dlb_string	var=UI_DrawScratch+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F349BB, width=3, x=280, y=74
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
	dlb_string	var=DisplayListB_Stage+19, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_OffOn_F349C1, width=3, x=160, y=71
	dlb_number	var=UI_DrawScratch+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=288, y=7, digits=2
	dlb_number16	var=UI_DrawScratch+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=176, y=33, digits=3
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
	dlb_number	var=UI_DrawScratch+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=184, y=54, digits=1
	dlb_number16	var=UI_DrawScratch+9, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=168, y=94, digits=3

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
	dl_value_glyph	glyph=50, x=40, y=1
	dl_text16x16_packed	x=72, y=5, text="REALTIME RECORD"
	dl_text8x10	x=256, y=7, text="SONG"
	dl_text8x16	x=96, y=33, text="MEASURE = "
	dl_text8x14	x=264, y=34, text="\207"
	dl_text8x10	x=272, y=34, text=" "
	dl_text8x16	x=312, y=34, text="\021"
	dl_text8x16	x=0, y=35, text="\020"
	dl_text8x10	x=16, y=37, text="QUANTI"
	dl_text8x14	x=64, y=37, text="Z"
	dl_text8x10	x=72, y=37, text="E"
	dl_text8x16	x=96, y=54, text="TIME SIG.= "
	dl_text8x16	x=192, y=54, text="/4"
	dl_text8x16	x=96, y=71, text="(MASTER:"
	dl_text8x16	x=184, y=71, text=")"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x10	x=232, y=74, text="CYCLE:"
	dl_text8x16	x=104, y=94, text="MEMORY = "
	dl_text8x16	x=192, y=94, text=" %"
	dl_text8x16	x=0, y=111, text="\020"
	dl_text8x16	x=296, y=112, text="."
	dl_text8x16	x=312, y=112, text="\021"
	dl_text8x10	x=16, y=113, text="MIXER"
	dl_text8x10	x=232, y=114, text="TIME SIG"
	dl_text16x16	x=104, y=118, text="\025="
	dl_text8x14	x=16, y=162, text="1"
	dl_text8x14	x=56, y=162, text="2"
	dl_text8x14	x=96, y=162, text="3"
	dl_text8x14	x=136, y=162, text="4"
	dl_text8x14	x=176, y=162, text="5"
	dl_text8x14	x=216, y=162, text="6"
	dl_text8x14	x=256, y=162, text="7"
	dl_text8x14	x=296, y=162, text="8"
	dl_text8x14	x=16, y=209, text="9"
	dl_text8x14	x=56, y=209, text="10"
	dl_text8x14	x=96, y=209, text="11"
	dl_text8x14	x=136, y=209, text="12"
	dl_text8x14	x=176, y=209, text="13"
	dl_text8x14	x=216, y=209, text="14"
	dl_text8x14	x=256, y=209, text="15"
	dl_text8x14	x=296, y=209, text="16"
	dl_box_shadow2	x0=5, y0=160, x1=34, y1=186
	dl_box_shadow2	x0=45, y0=160, x1=74, y1=186
	dl_box_shadow2	x0=85, y0=160, x1=114, y1=186
	dl_box_shadow2	x0=125, y0=160, x1=154, y1=186
	dl_box_shadow2	x0=165, y0=160, x1=194, y1=186
	dl_box_shadow2	x0=205, y0=160, x1=234, y1=186
	dl_box_shadow2	x0=245, y0=160, x1=274, y1=186
	dl_box_shadow2	x0=285, y0=160, x1=314, y1=186
	dl_box_shadow2	x0=5, y0=207, x1=34, y1=233
	dl_box_shadow2	x0=45, y0=207, x1=74, y1=233
	dl_box_shadow2	x0=85, y0=207, x1=114, y1=233
	dl_box_shadow2	x0=125, y0=207, x1=154, y1=233
	dl_box_shadow2	x0=165, y0=207, x1=194, y1=233
	dl_box_shadow2	x0=205, y0=207, x1=234, y1=233
	dl_box_shadow2	x0=245, y0=207, x1=274, y1=233
	dl_box_shadow2	x0=285, y0=207, x1=314, y1=233
	dl_hline	x0=5, y0=173, x1=36, y1=173
	dl_hline	x0=45, y0=173, x1=76, y1=173
	dl_hline	x0=85, y0=173, x1=116, y1=173
	dl_hline	x0=125, y0=173, x1=156, y1=173
	dl_hline	x0=165, y0=173, x1=196, y1=173
	dl_hline	x0=205, y0=173, x1=236, y1=173
	dl_hline	x0=245, y0=173, x1=276, y1=173
	dl_hline	x0=285, y0=173, x1=316, y1=173
	dl_hline	x0=5, y0=220, x1=36, y1=220
	dl_hline	x0=45, y0=220, x1=76, y1=220
	dl_hline	x0=85, y0=220, x1=116, y1=220
	dl_hline	x0=125, y0=220, x1=156, y1=220
	dl_hline	x0=165, y0=220, x1=196, y1=220
	dl_hline	x0=205, y0=220, x1=236, y1=220
	dl_hline	x0=245, y0=220, x1=276, y1=220
	dl_hline	x0=285, y0=220, x1=316, y1=220
	dl_box	x0=255, y0=29, x1=308, y1=48
	dl_box	x0=257, y0=31, x1=306, y1=46
	dl_box	x0=10, y0=32, x1=86, y1=51
	dl_box	x0=12, y0=34, x1=84, y1=49
	dl_box	x0=227, y0=69, x1=309, y1=88
	dl_box	x0=229, y0=71, x1=307, y1=86
	dl_box	x0=10, y0=108, x1=62, y1=127
	dl_box	x0=228, y0=109, x1=308, y1=128
	dl_box	x0=12, y0=110, x1=60, y1=125
	dl_box	x0=230, y0=111, x1=306, y1=126
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
	dl_value_glyph	glyph=50, x=40, y=1
	dl_text16x16_packed	x=72, y=5, text="REALTIME RECORD"
	dl_text8x10	x=256, y=7, text="SONG"
	dl_text8x16	x=96, y=33, text="MEASURE = "
	dl_text8x14	x=264, y=34, text="\207"
	dl_text8x10	x=272, y=34, text=" "
	dl_text8x16	x=312, y=34, text="\021"
	dl_text8x16	x=0, y=35, text="\020"
	dl_text8x10	x=16, y=37, text="QUANTI"
	dl_text8x14	x=64, y=37, text="Z"
	dl_text8x10	x=72, y=37, text="E"
	dl_text8x16	x=96, y=54, text="TIME SIG.= "
	dl_text8x16	x=192, y=54, text="/4"
	dl_text8x16	x=0, y=71, text="\020"
	dl_text8x16	x=96, y=71, text="(MASTER:"
	dl_text8x16	x=184, y=71, text=")"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x10	x=16, y=74, text="CLEAR"
	dl_text8x10	x=232, y=74, text="CYCLE:"
	dl_text8x16	x=104, y=94, text="MEMORY = "
	dl_text8x16	x=192, y=94, text=" %"
	dl_text8x16	x=0, y=111, text="\020"
	dl_text8x16	x=296, y=112, text="."
	dl_text8x16	x=312, y=112, text="\021"
	dl_text8x10	x=16, y=113, text="MIXER"
	dl_text8x10	x=232, y=114, text="TIME SIG"
	dl_text16x16	x=104, y=118, text="\025="
	dl_text8x14	x=16, y=162, text="1"
	dl_text8x14	x=56, y=162, text="2"
	dl_text8x14	x=96, y=162, text="3"
	dl_text8x14	x=136, y=162, text="4"
	dl_text8x14	x=176, y=162, text="5"
	dl_text8x14	x=216, y=162, text="6"
	dl_text8x14	x=256, y=162, text="7"
	dl_text8x14	x=296, y=162, text="8"
	dl_text8x14	x=16, y=209, text="9"
	dl_text8x14	x=56, y=209, text="10"
	dl_text8x14	x=96, y=209, text="11"
	dl_text8x14	x=136, y=209, text="12"
	dl_text8x14	x=176, y=209, text="13"
	dl_text8x14	x=216, y=209, text="14"
	dl_text8x14	x=256, y=209, text="15"
	dl_text8x14	x=296, y=209, text="16"
	dl_box_shadow2	x0=5, y0=160, x1=34, y1=186
	dl_box_shadow2	x0=45, y0=160, x1=74, y1=186
	dl_box_shadow2	x0=85, y0=160, x1=114, y1=186
	dl_box_shadow2	x0=125, y0=160, x1=154, y1=186
	dl_box_shadow2	x0=165, y0=160, x1=194, y1=186
	dl_box_shadow2	x0=205, y0=160, x1=234, y1=186
	dl_box_shadow2	x0=245, y0=160, x1=274, y1=186
	dl_box_shadow2	x0=285, y0=160, x1=314, y1=186
	dl_box_shadow2	x0=5, y0=207, x1=34, y1=233
	dl_box_shadow2	x0=45, y0=207, x1=74, y1=233
	dl_box_shadow2	x0=85, y0=207, x1=114, y1=233
	dl_box_shadow2	x0=125, y0=207, x1=154, y1=233
	dl_box_shadow2	x0=165, y0=207, x1=194, y1=233
	dl_box_shadow2	x0=205, y0=207, x1=234, y1=233
	dl_box_shadow2	x0=245, y0=207, x1=274, y1=233
	dl_box_shadow2	x0=285, y0=207, x1=314, y1=233
	dl_hline	x0=5, y0=173, x1=36, y1=173
	dl_hline	x0=45, y0=173, x1=76, y1=173
	dl_hline	x0=85, y0=173, x1=116, y1=173
	dl_hline	x0=125, y0=173, x1=156, y1=173
	dl_hline	x0=165, y0=173, x1=196, y1=173
	dl_hline	x0=205, y0=173, x1=236, y1=173
	dl_hline	x0=245, y0=173, x1=276, y1=173
	dl_hline	x0=285, y0=173, x1=316, y1=173
	dl_hline	x0=5, y0=220, x1=36, y1=220
	dl_hline	x0=45, y0=220, x1=76, y1=220
	dl_hline	x0=85, y0=220, x1=116, y1=220
	dl_hline	x0=125, y0=220, x1=156, y1=220
	dl_hline	x0=165, y0=220, x1=196, y1=220
	dl_hline	x0=205, y0=220, x1=236, y1=220
	dl_hline	x0=245, y0=220, x1=276, y1=220
	dl_hline	x0=285, y0=220, x1=316, y1=220
	dl_box	x0=255, y0=29, x1=308, y1=48
	dl_box	x0=257, y0=31, x1=306, y1=46
	dl_box	x0=10, y0=32, x1=86, y1=51
	dl_box	x0=12, y0=34, x1=84, y1=49
	dl_box	x0=10, y0=67, x1=62, y1=89
	dl_box	x0=12, y0=69, x1=60, y1=87
	dl_box	x0=227, y0=69, x1=309, y1=88
	dl_box	x0=229, y0=71, x1=307, y1=86
	dl_box	x0=10, y0=108, x1=62, y1=127
	dl_box	x0=228, y0=109, x1=308, y1=128
	dl_box	x0=12, y0=110, x1=60, y1=125
	dl_box	x0=230, y0=111, x1=306, y1=126

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
; DL_CycleMasterSongMeasureTimeSig list right after it.
	dl_clear_area	x=0, y=0, w=320, h=240

; === END COVER-R1 0xF34968-0xF34970 ===

; ------------------------------------------------------------------
; 0xF34970-0xF349BA -- 6 display-list records, 75 bytes -- interpreter B
;   entered at: 0xF34970
;   ends used:  0xF349BB
; ------------------------------------------------------------------
; DL_CycleMasterSongMeasureTimeSig -- the display list at 0xF34970, named by
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
DL_CycleMasterSongMeasureTimeSig:
	dlb_string	var=UI_DrawScratch+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F349BB, width=3, x=280, y=34
	dlb_string	var=DisplayListB_Stage+19, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F349C1, width=3, x=280, y=112
	dlb_string	var=DLB_NoVariable, mask=0x00, shift=0, svc=LCDSVC_DrawText8x14, table=UI_DrawScratch+12, width=6, x=256, y=8
	dlb_number	var=UI_DrawScratch+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=232, y=8, digits=2
	dlb_number16	var=UI_DrawScratch+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x16, x=176, y=40, digits=3
	dlb_number	var=UI_DrawScratch+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=184, y=69, digits=1

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
; DL_SequencerPlaySongCycleMeasure -- the display list at 0xF349C7.  Its own
;                                     text records read: "SEQUENCER PLAY";
;                                     "S0NG"; "CYCLE:"; "MEASURE ="; "MEAS";
;                                     "TIME SIG.="; "REC0RD"; "MASTER:" +1
;                                     more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SequencerPlaySongCycleMeasure:
	dl_text16x16_packed	x=21, y=5, text="SEQUENCER PLAY"
	dl_text8x10	x=200, y=8, text="S0NG"
	dl_text8x10	x=248, y=8, text=":"
	dl_text8x16	x=312, y=33, text="\021"
	dl_text8x10	x=232, y=34, text="CYCLE:"
	dl_text8x16	x=24, y=35, text="\215"
	dl_text8x16	x=0, y=36, text="\020"
	dl_text8x16	x=96, y=40, text="MEASURE = "
	dl_text8x10	x=16, y=55, text="MEAS"
	dl_text8x16	x=96, y=69, text="TIME SIG.= "
	dl_text8x16	x=192, y=69, text="/4"
	dl_text8x16	x=0, y=71, text="\020"
	dl_text8x16	x=24, y=72, text="\216"
	dl_text8x10	x=248, y=72, text="REC0RD"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text16x16	x=104, y=105, text="\025="
	dl_text8x16	x=0, y=111, text="\020"
	dl_text8x16	x=312, y=111, text="\021"
	dl_text8x10	x=224, y=112, text="MASTER:"
	dl_text8x10	x=16, y=113, text="MIXER"
	dl_text8x14	x=16, y=162, text="1"
	dl_text8x14	x=56, y=162, text="2"
	dl_text8x14	x=96, y=162, text="3"
	dl_text8x14	x=136, y=162, text="4"
	dl_text8x14	x=176, y=162, text="5"
	dl_text8x14	x=216, y=162, text="6"
	dl_text8x14	x=256, y=162, text="7"
	dl_text8x14	x=296, y=162, text="8"
	dl_text8x14	x=16, y=209, text="9"
	dl_text8x14	x=56, y=209, text="10"
	dl_text8x14	x=96, y=209, text="11"
	dl_text8x14	x=136, y=209, text="12"
	dl_text8x14	x=176, y=209, text="13"
	dl_text8x14	x=216, y=209, text="14"
	dl_text8x14	x=256, y=209, text="15"
	dl_text8x14	x=296, y=209, text="16"
	dl_box_shadow2	x0=242, y0=67, x1=306, y1=86
	dl_box_shadow2	x0=5, y0=160, x1=34, y1=186
	dl_box_shadow2	x0=45, y0=160, x1=74, y1=186
	dl_box_shadow2	x0=85, y0=160, x1=114, y1=186
	dl_box_shadow2	x0=125, y0=160, x1=154, y1=186
	dl_box_shadow2	x0=165, y0=160, x1=194, y1=186
	dl_box_shadow2	x0=205, y0=160, x1=234, y1=186
	dl_box_shadow2	x0=245, y0=160, x1=274, y1=186
	dl_box_shadow2	x0=285, y0=160, x1=314, y1=186
	dl_box_shadow2	x0=5, y0=207, x1=34, y1=233
	dl_box_shadow2	x0=45, y0=207, x1=74, y1=233
	dl_box_shadow2	x0=85, y0=207, x1=114, y1=233
	dl_box_shadow2	x0=125, y0=207, x1=154, y1=233
	dl_box_shadow2	x0=165, y0=207, x1=194, y1=233
	dl_box_shadow2	x0=205, y0=207, x1=234, y1=233
	dl_box_shadow2	x0=245, y0=207, x1=274, y1=233
	dl_box_shadow2	x0=285, y0=207, x1=314, y1=233
	dl_box	x0=227, y0=29, x1=309, y1=48
	dl_box	x0=229, y0=31, x1=307, y1=46
	dl_box	x0=10, y0=32, x1=45, y1=51
	dl_box	x0=12, y0=34, x1=43, y1=49
	dl_box	x0=10, y0=68, x1=45, y1=87
	dl_box	x0=12, y0=70, x1=43, y1=85
	dl_box	x0=218, y0=107, x1=308, y1=126
	dl_box	x0=10, y0=108, x1=62, y1=127
	dl_box	x0=220, y0=109, x1=306, y1=124
	dl_box	x0=12, y0=110, x1=60, y1=125
	dl_hline	x0=5, y0=173, x1=36, y1=173
	dl_hline	x0=45, y0=173, x1=76, y1=173
	dl_hline	x0=85, y0=173, x1=116, y1=173
	dl_hline	x0=125, y0=173, x1=156, y1=173
	dl_hline	x0=165, y0=173, x1=196, y1=173
	dl_hline	x0=205, y0=173, x1=236, y1=173
	dl_hline	x0=245, y0=173, x1=276, y1=173
	dl_hline	x0=285, y0=173, x1=316, y1=173
	dl_hline	x0=5, y0=220, x1=36, y1=220
	dl_hline	x0=45, y0=220, x1=76, y1=220
	dl_hline	x0=85, y0=220, x1=116, y1=220
	dl_hline	x0=125, y0=220, x1=156, y1=220
	dl_hline	x0=165, y0=220, x1=196, y1=220
	dl_hline	x0=205, y0=220, x1=236, y1=220
	dl_hline	x0=245, y0=220, x1=276, y1=220
	dl_hline	x0=285, y0=220, x1=316, y1=220

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
	dlb_rect_entry	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=DLTable_F34D18

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
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=8, y=175
	dlb_string	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=48, y=175
	dlb_string	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=88, y=175
	dlb_string	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=128, y=175
	dlb_string	var=DisplayListB_Stage+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=168, y=175
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=208, y=175
	dlb_string	var=DisplayListB_Stage+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=248, y=175
	dlb_string	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=288, y=175
	dlb_string	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=8, y=222
	dlb_string	var=DisplayListB_Stage+9, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=48, y=222
	dlb_string	var=DisplayListB_Stage+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=88, y=222
	dlb_string	var=DisplayListB_Stage+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=128, y=222
	dlb_string	var=DisplayListB_Stage+12, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=168, y=222
	dlb_string	var=DisplayListB_Stage+13, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=208, y=222
	dlb_string	var=DisplayListB_Stage+14, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=248, y=222
	dlb_string	var=DisplayListB_Stage+15, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_P1ToP32, width=3, x=288, y=222

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
	dl_text16x16_packed	x=104, y=4, text="CYCLE"
	dl_text16x16_packed	x=170, y=4, text="PLAY"
	dl_text8x16	x=24, y=36, text="CURRENT"
	dl_text8x16	x=88, y=36, text="MEASURE"
	dl_text8x16	x=184, y=36, text=":"
	dl_text8x16	x=288, y=72, text="\215"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=0, y=75, text="\020"
	dl_text8x16	x=24, y=76, text="CYCLE"
	dl_text8x16	x=96, y=76, text=":"
	dl_text8x16	x=288, y=109, text="\216"
	dl_text8x16	x=312, y=109, text="\021"
	dl_text8x16	x=0, y=114, text="\020"
	dl_text8x16	x=24, y=115, text="CYCLE"
	dl_text8x16	x=72, y=115, text="START"
	dl_text8x16	x=120, y=115, text="MEASURE"
	dl_text8x16	x=184, y=115, text=":"
	dl_text8x16	x=0, y=153, text="\020"
	dl_text8x16	x=24, y=153, text="CYCLE"
	dl_text8x16	x=72, y=153, text="END"
	dl_text8x16	x=104, y=153, text="MEASURE"
	dl_text8x16	x=184, y=153, text=":"
	dl_text8x16	x=312, y=190, text="\021"
	dl_text8x14	x=272, y=191, text="EXIT"
	dl_box_shadow2	x0=13, y0=65, x1=150, y1=96
	dl_box_shadow2	x0=13, y0=103, x1=229, y1=134
	dl_box_shadow2	x0=13, y0=141, x1=229, y1=172
	dl_box	x0=274, y0=69, x1=309, y1=88
	dl_box	x0=276, y0=71, x1=307, y1=86
	dl_box	x0=274, y0=105, x1=309, y1=124
	dl_box	x0=276, y0=107, x1=307, y1=122
	dl_box	x0=265, y0=186, x1=309, y1=205
	dl_box	x0=267, y0=188, x1=307, y1=203
DL_F34FF2:
	dlb_string	var=UI_DrawScratch+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F35035, width=3, x=104, y=76
	dlb_number16	var=UI_DrawScratch+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=36, digits=3
	dlb_number16	var=UI_DrawScratch+18, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=115, digits=3
	dlb_number16	var=UI_DrawScratch+20, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=153, digits=3
	dlb_rect_entry	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=Data_F35035 + 0x6
	dlb_rect_entry_op08	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_EraseRect, table=Data_F35035 + 0x6

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
	dl_text16x16_packed	x=88, y=3, text="CYCLE"
	dl_text16x16_packed	x=154, y=3, text="RECORD"
	dl_text8x16	x=264, y=33, text="\207"
	dl_text8x16	x=312, y=34, text="\021"
	dl_text8x16	x=24, y=36, text="CURRENT"
	dl_text8x16	x=88, y=36, text="MEASURE"
	dl_text8x16	x=184, y=36, text=":"
	dl_text8x16	x=288, y=72, text="\215"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=0, y=74, text="\020"
	dl_text8x16	x=24, y=76, text="CYCLE"
	dl_text8x16	x=88, y=76, text=":"
	dl_text8x16	x=288, y=109, text="\216"
	dl_text8x16	x=312, y=109, text="\021"
	dl_text8x16	x=0, y=114, text="\020"
	dl_text8x16	x=24, y=115, text="CYCLE"
	dl_text8x16	x=72, y=115, text="START"
	dl_text8x16	x=120, y=115, text="MEASURE"
	dl_text8x16	x=184, y=115, text=":"
	dl_text8x16	x=24, y=153, text="CYCLE"
	dl_text8x16	x=72, y=153, text="END"
	dl_text8x16	x=104, y=153, text="MEASURE"
	dl_text8x16	x=0, y=153, text="\020"
	dl_text8x16	x=184, y=153, text=":"
	dl_text8x16	x=312, y=190, text="\021"
	dl_text8x16	x=0, y=191, text="\020"
	dl_text8x14	x=272, y=191, text="EXIT"
	dl_text8x14	x=16, y=194, text="CLEAR"
	dl_box_shadow2	x0=13, y0=65, x1=150, y1=96
	dl_box_shadow2	x0=13, y0=103, x1=229, y1=134
	dl_box_shadow2	x0=13, y0=141, x1=229, y1=172
	dl_box	x0=255, y0=29, x1=308, y1=48
	dl_box	x0=257, y0=31, x1=306, y1=46
	dl_box	x0=274, y0=69, x1=309, y1=88
	dl_box	x0=276, y0=71, x1=307, y1=86
	dl_box	x0=274, y0=105, x1=309, y1=124
	dl_box	x0=276, y0=107, x1=307, y1=122
	dl_box	x0=265, y0=186, x1=309, y1=205
	dl_box	x0=10, y0=187, x1=62, y1=209
	dl_box	x0=267, y0=188, x1=307, y1=203
	dl_box	x0=12, y0=189, x1=60, y1=207
CycleRecordScreen_DrawValues_DL:
; drawn (start operand) by CycleRecordScreen_DrawValues -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=UI_DrawScratch+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F35035, width=3, x=104, y=76
	dlb_string	var=UI_DrawScratch+8, mask=0x01, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F343B6, width=3, x=280, y=34
	dlb_number16	var=UI_DrawScratch+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=36, digits=3
	dlb_number16	var=UI_DrawScratch+22, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=115, digits=3
	dlb_number16	var=UI_DrawScratch+24, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=153, digits=3
	dlb_rect_entry	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=Data_F35035 + 0x6
	dlb_rect_entry_op08	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_EraseRect, table=Data_F35035 + 0x6

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
	dl_text16x16_packed	x=96, y=5, text="CYCLE PLAY"
	dl_text8x16	x=24, y=36, text="CURRENT MEASURE     :"
	dl_text8x14	x=272, y=36, text="EDIT"
	dl_text8x16	x=312, y=36, text="\021"
	dl_text8x16	x=288, y=72, text="\215"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=0, y=74, text="\020"
	dl_text8x16	x=24, y=75, text="SOLO  : "
	dl_text8x16	x=288, y=109, text="\216"
	dl_text8x16	x=312, y=110, text="\021"
	dl_text8x16	x=0, y=115, text="\020"
	dl_text8x16	x=24, y=115, text="CYCLE START MEASURE :"
	dl_text8x16	x=0, y=153, text="\020"
	dl_text8x16	x=24, y=153, text="CYCLE END MEASURE   :"
	dl_box_shadow2	x0=13, y0=65, x1=229, y1=96
	dl_box_shadow2	x0=13, y0=103, x1=229, y1=134
	dl_box_shadow2	x0=13, y0=141, x1=229, y1=172
	dl_box	x0=267, y0=31, x1=309, y1=51
	dl_box	x0=269, y0=33, x1=307, y1=49
	dl_box	x0=277, y0=69, x1=309, y1=88
	dl_box	x0=279, y0=71, x1=307, y1=86
	dl_box	x0=277, y0=105, x1=309, y1=124
	dl_box	x0=279, y0=107, x1=307, y1=122
DL_F352F9:
	dlb_string	var=DisplayListB_Stage+18, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_OffOn_F3533C, width=3, x=88, y=75
	dlb_number16	var=UI_DrawScratch+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=36, digits=3
	dlb_number16	var=UI_DrawScratch+18, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=115, digits=3
	dlb_number16	var=UI_DrawScratch+20, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=192, y=153, digits=3
	dlb_rect_entry	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=Data_F35035 + 0x6
	dlb_rect_entry_op08	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_EraseRect, table=Data_F35035 + 0x6

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
	dl_text16x16_packed	x=61, y=82, text="METRONOME BALANCE"
	dl_text8x16	x=288, y=150, text="\215"
	dl_text8x16	x=312, y=151, text="\021"
	dl_text8x16	x=288, y=187, text="\216"
	dl_text8x16	x=312, y=187, text="\021"
	dl_box	x0=274, y0=147, x1=309, y1=166
	dl_box	x0=79, y0=148, x1=228, y1=200
	dl_box	x0=276, y0=149, x1=307, y1=164
	dl_box	x0=274, y0=183, x1=309, y1=202
	dl_box	x0=276, y0=185, x1=307, y1=200
MetronomeBalanceScreen_PaintValue_DL:
; drawn (start operand) by MetronomeBalanceScreen_PaintValue -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_xy	var=UI_DrawScratch+18, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=134, y=166, digits=3
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
