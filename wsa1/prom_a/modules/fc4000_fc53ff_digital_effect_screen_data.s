; ==============================================================================
; 0xFC4000-0xFC52F7 -- THE SOUND EDIT "DIGITAL EFFECT" AND "COPY" PAGES' SCREEN
; DATA: display lists, their bound/record arrays, name tables, eight widgets
; ==============================================================================
;
; ★ READ BY PROM_B.  This span's header used to record its reader as an open
; question, because prom_a's own control-flow graph reaches none of it.  Its
; readers are prom_b routines, whose source writes these addresses as
; DECIMAL immediates (`ld xiy, 16531456` is `ld XIY,0x00FC4000`) -- so no hex
; search could find them:
;   SoundEditDigitalEffect_Paint 0xF099F5, SoundEditDigitalEffect_RepaintField
;   0xF09AA5, ToneEditPage_A0_PaintResonatorIcon 0xF09AF1 (via PtrTable_F09B7B), SoundEditCopy_Paint
;   0xF09B9B, SoundEditCopy_RepaintField 0xF09C08, SoundEditMenu_RepaintField 0xF09CA9
;   (Dispatch_Code80_RepaintFieldTable[0]) with prom_b 0xF5BF6D, and Draw_Page12EnvelopeKeyoffCurSor at 0xF5CBAD.
; The DIGITAL EFFECT type is (0x27B6) = (0x27A6) & 0x0F; every per-type array
; below is indexed by it, and 12 entries is the extent every one of them shares.
; Inside the span, interpreter-B records point at the name and rectangle
; tables (op 02: +2 variable, +4 mask, +5 shift, +7 long -> string table,
; +0x0B entry width; op 03: +7 long -> 8-byte entries -- the handler table in
; wsa1/notes/FINDINGS-ui-display-list-interpreter-b.md), and those pointers are
; `.long <label>` here, so the byte gate now checks every table's position.
; Interpreter A is DisplayList_Run (prom_b 0xF31A09, thunk T_DisplayList_Run
; 0xF417F0), B is 0xF31AF0 (T_DisplayListB_Run 0xF417F4).
;
; ⚠ CORRECTIONS to the framing this replaces (notes/gen_prom_a_fc4000_module.py):
;   * the "13 entries x 13 bytes" name table is 12 x 13 (DigitalEffect_TypeNames,
;     width 13 from its record) + 2 x 6 ("MONO  " / "STEREO", width 6 from a
;     second record) -- 168 bytes, so it ends at 0xFC48D6, the byte before
;     Widget_FC48D7, and the one-byte overlap the two framings had is gone;
;   * "Unclassified_FC48D8" was bytes 1-12 of Widget_FC48D7;
;   * "Bitmap1bpp_FC48E4, 172 rows x 15 bytes" was the other seven widgets and,
;     from 0xFC4BA7, the COPY page's display lists and tables.  Lane IMAGE had
;     already shown the widget half (images/Widget_FC48D7.png ..); the rest is
;     named here by its prom_b readers.
; ⚠ What is NOT claimed: which field or effect parameter each record draws
; beyond the text the records carry; prom_b's PtrTable_F006CD / PtrArray_F00C4E
; words that land inside DigitalEffect_Frame (0xFC4082, 0xFC4097, 0xFC4480 ...)
; are not record starts of this framing and are not explained here.
; Re-check: notes/proma-2026-09-25/gen_fc4000_pages.py (repo root).  Its --apply,
; which wrote this span in its 2026-09-25 form, is retired: this file is the source.
; ==============================================================================

; DigitalEffect_Frame -- display list, 24 record(s), 180 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A33: XIY = this, XIX = DigitalEffect_FrameEnds[type]; so a PREFIX of this list is drawn, ending at one of the four inner labels.
; Framing: the length bytes walk from 0xFC4000 and land exactly on 0xFC40B4.
; (was `DisplayList_FC4000`, the label of this whole span until 2026-09-25)
DigitalEffect_Frame:
	dl_text8x14	x=16, y=217, text="\215"
	dl_text8x14	x=16, y=227, text="\216"
	dl_box_shadow1	x0=9, y0=218, x1=30, y1=238
	dl_hline	x0=9, y0=228, x1=30, y1=228
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=96, y=227, text="\216"
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_hline	x0=89, y0=228, x1=110, y1=228
; DLRec_FC405A -- a record (op 06, 5 bytes) inside DigitalEffect_Frame,
;          pointed at by DigitalEffect_FrameEnds[10], DigitalEffect_FrameEnds[11]
DLRec_FC405A:
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=136, y=227, text="\216"
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_hline	x0=129, y0=228, x1=150, y1=228
; DLRec_FC4078 -- a record (op 06, 5 bytes) inside DigitalEffect_Frame,
;          pointed at by DigitalEffect_FrameEnds[6], DigitalEffect_FrameEnds[7], DigitalEffect_FrameEnds[8], DigitalEffect_FrameEnds[9]
DLRec_FC4078:
	dl_text8x14	x=176, y=217, text="\215"
	dl_text8x14	x=176, y=227, text="\216"
	dl_box_shadow1	x0=169, y0=218, x1=190, y1=238
	dl_hline	x0=169, y0=228, x1=190, y1=228
; DLRec_FC4096 -- a record (op 06, 5 bytes) inside DigitalEffect_Frame,
;          pointed at by DigitalEffect_FrameEnds[0], DigitalEffect_FrameEnds[1], DigitalEffect_FrameEnds[2], DigitalEffect_FrameEnds[3]
DLRec_FC4096:
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=216, y=227, text="\216"
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=209, y0=228, x1=230, y1=228
	.set DigitalEffect_Frame_End, .           ; FC40B4  end marker: the byte after the last record

; DigitalEffect_ValueFrames -- display list, 8 record(s), 60 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A5F (type != 10) / 0xF09A58 (type 10: from the inner label), to 0xFC40F0.
; Framing: the length bytes walk from 0xFC40B4 and land exactly on 0xFC40F0.
DigitalEffect_ValueFrames:
	dl_text8x14	x=256, y=217, text="\215"
	dl_text8x14	x=256, y=227, text="\216"
	dl_box_shadow1	x0=249, y0=218, x1=270, y1=238
	dl_hline	x0=249, y0=228, x1=270, y1=228
; SoundEditDigitalEffect_Paint_DL2 -- a record (op 06, 5 bytes) inside DigitalEffect_ValueFrames,
;          an inner entry point or end named in the list's Read-by line
SoundEditDigitalEffect_Paint_DL2:
; ; drawn (start operand) by SoundEditDigitalEffect_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=296, y=217, text="\215"
	dl_text8x14	x=296, y=227, text="\216"
	dl_box_shadow1	x0=289, y0=218, x1=310, y1=238
	dl_hline	x0=289, y0=228, x1=310, y1=228
	.set DigitalEffect_ValueFrames_End, .     ; FC40F0  end marker: the byte after the last record

; DigitalEffect_Header -- display list, 31 record(s), 287 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A0C (type != 10) / 0xF09A05 (type 10: from the inner label), to 0xFC420F; text INTENSITY, DIGITAL EFFECT, SOUND EDIT, TYPE, REVERB DEPTH.
; Framing: the length bytes walk from 0xFC40F0 and land exactly on 0xFC420F.
DigitalEffect_Header:
	dl_text8x14	x=88, y=160, text="INTENSITY"
	dl_text8x14	x=200, y=160, text=":"
	dl_text8x8_packed	x=240, y=209, text="INTENS."
; SoundEditDigitalEffect_Paint_DL1 -- a record (op 23, 5 bytes) inside DigitalEffect_Header,
;          an inner entry point or end named in the list's Read-by line
SoundEditDigitalEffect_Paint_DL1:
; ; drawn (start operand) by SoundEditDigitalEffect_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=10, x=80, y=1
	dl_text16x16_packed	x=111, y=5, text="DIGITAL EFFECT"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x14	x=88, y=51, text="TYPE"
	dl_text8x14	x=128, y=51, text=":"
	dl_text8x8_packed	x=310, y=70, text="\221"
	dl_text8x16	x=0, y=73, text="\020"
	dl_text8x16	x=288, y=73, text="\215  "
	dl_text8x16	x=312, y=74, text="\251"
	dl_text8x14	x=272, y=93, text="TYPE"
	dl_text8x8_packed	x=310, y=109, text="\221"
	dl_text8x16	x=0, y=112, text="\020"
	dl_text8x16	x=288, y=112, text="\216  "
	dl_text8x16	x=312, y=113, text="\251"
	dl_text8x14	x=88, y=175, text="REVERB DEPTH  :"
	dl_text8x8_packed	x=282, y=209, text="REVERB"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box_shadow1	x0=71, y0=46, x1=251, y1=187
	dl_box	x0=274, y0=69, x1=309, y1=88
	dl_box	x0=12, y0=70, x1=44, y1=89
	dl_box	x0=276, y0=71, x1=307, y1=86
	dl_box	x0=14, y0=72, x1=42, y1=87
	dl_box	x0=12, y0=108, x1=68, y1=127
	dl_box	x0=274, y0=108, x1=309, y1=127
	dl_box	x0=14, y0=110, x1=66, y1=125
	dl_box	x0=276, y0=110, x1=307, y1=125
	dl_hline	x0=71, y0=65, x1=251, y1=65
	dl_value_glyph	glyph=118, x=80, y=1
	.set DigitalEffect_Header_End, .          ; FC420F  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC420F -- display list, 15 record(s), 131 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC420F and land exactly on 0xFC4292.
DigitalEffect_ParamLabels_FC420F:
	dl_text8x14	x=88, y=70, text="DEPTH"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="SPEED"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="DETUNE"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x14	x=88, y=115, text="DELAY"
	dl_text8x14	x=200, y=115, text=":"
	dl_text8x14	x=88, y=130, text="BALANCE"
	dl_text8x14	x=200, y=130, text=":"
	dl_text8x8_packed	x=6, y=209, text="DEPTH"
	dl_text8x8_packed	x=45, y=209, text="SPEED"
	dl_text8x8_packed	x=82, y=209, text="DETUNE"
	dl_text8x8_packed	x=124, y=209, text="DELAY"
	dl_text8x8_packed	x=160, y=209, text="BALANCE"
	.set DigitalEffect_ParamLabels_FC420F_End, . ; FC4292  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4292 -- display list, 18 record(s), 160 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4292 and land exactly on 0xFC4332.
DigitalEffect_ParamLabels_FC4292:
	dl_text8x14	x=88, y=70, text="DEPTH1"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="SPEED1"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="DEPTH2"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x14	x=88, y=115, text="SPEED2"
	dl_text8x14	x=200, y=115, text=":"
	dl_text8x14	x=88, y=130, text="DETUNE"
	dl_text8x14	x=200, y=130, text=":"
	dl_text8x14	x=88, y=145, text="DELAY"
	dl_text8x14	x=200, y=145, text=":"
	dl_text8x8_packed	x=2, y=209, text="DEPTH1"
	dl_text8x8_packed	x=42, y=209, text="SPEED1"
	dl_text8x8_packed	x=82, y=209, text="DEPTH2"
	dl_text8x8_packed	x=122, y=209, text="SPEED2"
	dl_text8x8_packed	x=162, y=209, text="DETUNE"
	dl_text8x8_packed	x=205, y=209, text="DELAY"
	.set DigitalEffect_ParamLabels_FC4292_End, . ; FC4332  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4332 -- display list, 12 record(s), 102 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4332 and land exactly on 0xFC4398.
DigitalEffect_ParamLabels_FC4332:
	dl_text8x14	x=88, y=70, text="DEPTH"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="SPEED"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="WAVE"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x14	x=88, y=115, text="BALANCE"
	dl_text8x14	x=200, y=115, text=":"
	dl_text8x8_packed	x=5, y=209, text="DEPTH"
	dl_text8x8_packed	x=44, y=209, text="SPEED"
	dl_text8x8_packed	x=88, y=209, text="WAVE"
	dl_text8x8_packed	x=119, y=209, text="BALANCE"
	.set DigitalEffect_ParamLabels_FC4332_End, . ; FC4398  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4398 -- display list, 12 record(s), 108 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4398 and land exactly on 0xFC4404.
DigitalEffect_ParamLabels_FC4398:
	dl_text8x14	x=88, y=70, text="DEPTH1"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="SPEED1"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="DEPTH2"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x14	x=88, y=115, text="SPEED2"
	dl_text8x14	x=200, y=115, text=":"
	dl_text8x8_packed	x=2, y=209, text="DEPTH1"
	dl_text8x8_packed	x=42, y=209, text="SPEED1"
	dl_text8x8_packed	x=82, y=209, text="DEPTH2"
	dl_text8x8_packed	x=122, y=209, text="SPEED2"
	.set DigitalEffect_ParamLabels_FC4398_End, . ; FC4404  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4404 -- display list, 12 record(s), 108 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4404 and land exactly on 0xFC4470.
DigitalEffect_ParamLabels_FC4404:
	dl_text8x14	x=88, y=70, text="DELAY"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="DETUNE"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="KEY SHIFT"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x14	x=88, y=115, text="BALANCE"
	dl_text8x14	x=200, y=115, text=":"
	dl_text8x8_packed	x=2, y=209, text="DELAY"
	dl_text8x8_packed	x=42, y=209, text="DETUNE"
	dl_text8x8_packed	x=91, y=209, text="KEY"
	dl_text8x8_packed	x=120, y=209, text="BALANCE"
	.set DigitalEffect_ParamLabels_FC4404_End, . ; FC4470  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4470 -- display list, 12 record(s), 108 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4470 and land exactly on 0xFC44DC.
DigitalEffect_ParamLabels_FC4470:
	dl_text8x14	x=88, y=70, text="SPEED"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="DECAY"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="SUSTAIN"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x14	x=88, y=115, text="RELEASE"
	dl_text8x14	x=200, y=115, text=":"
	dl_text8x8_packed	x=4, y=209, text="SPEED"
	dl_text8x8_packed	x=45, y=209, text="DECAY"
	dl_text8x8_packed	x=80, y=209, text="SUSTAIN"
	dl_text8x8_packed	x=128, y=209, text="RELEASE"
	.set DigitalEffect_ParamLabels_FC4470_End, . ; FC44DC  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC44DC -- display list, 9 record(s), 86 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC44DC and land exactly on 0xFC4532.
DigitalEffect_ParamLabels_FC44DC:
	dl_text8x14	x=88, y=70, text="DISTORTION"
	dl_text8x14	x=200, y=70, text=":"
	dl_text8x14	x=88, y=85, text="TOUCH DEPTH"
	dl_text8x14	x=200, y=85, text=":"
	dl_text8x14	x=88, y=100, text="DEPTH"
	dl_text8x14	x=200, y=100, text=":"
	dl_text8x8_packed	x=7, y=209, text="DIST."
	dl_text8x8_packed	x=45, y=209, text="TOUCH"
	dl_text8x8_packed	x=85, y=209, text="DEPTH"
	.set DigitalEffect_ParamLabels_FC44DC_End, . ; FC4532  end marker: the byte after the last record

; DigitalEffect_ParamLabelLists -- 12 (start, end) display-list bounds, 96 bytes
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A23: `ld A,(0x27B6) / sla 3,WA / ld XIZ,0x00FC4532 / add XIZ,XWA / ld XIY,(XIZ) / ld XIX,(XIZ+4) / call T_DisplayList_Run`.
; COUNT 12 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_ParamLabelLists:
	.long DigitalEffect_ParamLabels_FC420F, DigitalEffect_ParamLabels_FC420F_End ; FC4532  [ 0]
	.long DigitalEffect_ParamLabels_FC420F, DigitalEffect_ParamLabels_FC420F_End ; FC453A  [ 1]
	.long DigitalEffect_ParamLabels_FC420F, DigitalEffect_ParamLabels_FC420F_End ; FC4542  [ 2]
	.long DigitalEffect_ParamLabels_FC420F, DigitalEffect_ParamLabels_FC420F_End ; FC454A  [ 3]
	.long DigitalEffect_ParamLabels_FC4292, DigitalEffect_ParamLabels_FC4292_End ; FC4552  [ 4]
	.long DigitalEffect_ParamLabels_FC4292, DigitalEffect_ParamLabels_FC4292_End ; FC455A  [ 5]
	.long DigitalEffect_ParamLabels_FC4332, DigitalEffect_ParamLabels_FC4332_End ; FC4562  [ 6]
	.long DigitalEffect_ParamLabels_FC4398, DigitalEffect_ParamLabels_FC4398_End ; FC456A  [ 7]
	.long DigitalEffect_ParamLabels_FC4404, DigitalEffect_ParamLabels_FC4404_End ; FC4572  [ 8]
	.long DigitalEffect_ParamLabels_FC4470, DigitalEffect_ParamLabels_FC4470_End ; FC457A  [ 9]
	.long DigitalEffect_ParamLabels_FC44DC, DigitalEffect_ParamLabels_FC44DC_End ; FC4582  [10]
	.long DigitalEffect_ParamLabels_FC44DC, DigitalEffect_ParamLabels_FC44DC_End ; FC458A  [11]

; DigitalEffect_Values -- display list, 5 record(s), 67 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A6D, to 0xFC45D5 (type != 10) or 0xFC45CA (type 10); SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) runs the inner record 0xFC45A1..0xFC45BF alone (field 0).
; Framing: the length bytes walk from 0xFC4592 and land exactly on 0xFC45D5.
DigitalEffect_Values:
	dlb_string	var=ModelingPage_Fields, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=DigitalEffect_TypeNames, width=13, x=136, y=51	; variable; mask, shift, +6; string table; entry width, +0x0D
; SoundEditDigitalEffect_RepaintField_DL -- a record (op 02, 15 bytes) inside DigitalEffect_Values,
;          an inner entry point or end named in the list's Read-by line
SoundEditDigitalEffect_RepaintField_DL:
; ; drawn (start operand) by SoundEditDigitalEffect_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=ModelingPage_Fields, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F034D8, width=3, x=16, y=75
; DLRec_FC45B0 -- a record (op 02, 15 bytes) inside DigitalEffect_Values,
;          an inner entry point or end named in the list's Read-by line
DLRec_FC45B0:
	dlb_string	var=ModelingPage_Fields, mask=0x40, shift=6, svc=LCDSVC_DrawText8x10, table=DigitalEffect_OutputNames, width=6, x=16, y=113	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC45BF -- a record (op 05, 11 bytes) inside DigitalEffect_Values,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[8]
DLRec_FC45BF:
	dlb_number_signed	var=ModelingPage_Fields+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=175, digits=2, signflag=0x00
; DLRec_FC45CA -- a record (op 05, 11 bytes) inside DigitalEffect_Values,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[7]
DLRec_FC45CA:
	dlb_number_signed	var=ModelingPage_Fields+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=160, digits=2, signflag=0x00
	.set DigitalEffect_Values_End, .          ; FC45D5  end marker: the byte after the last record

; DigitalEffect_ParamValueLists -- 12 (start, end) display-list bounds, 96 bytes
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A94: the same shape as DigitalEffect_ParamLabelLists, run by interpreter B.
; COUNT 12 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_ParamValueLists:
	.long DigitalEffect_ParamValues_FC4635, DigitalEffect_ParamValues_FC4635_End ; FC45D5  [ 0]
	.long DigitalEffect_ParamValues_FC4635, DigitalEffect_ParamValues_FC4635_End ; FC45DD  [ 1]
	.long DigitalEffect_ParamValues_FC4635, DigitalEffect_ParamValues_FC4635_End ; FC45E5  [ 2]
	.long DigitalEffect_ParamValues_FC4635, DigitalEffect_ParamValues_FC4635_End ; FC45ED  [ 3]
	.long DigitalEffect_ParamValues_FC4680, DigitalEffect_ParamValues_FC4680_End ; FC45F5  [ 4]
	.long DigitalEffect_ParamValues_FC4680, DigitalEffect_ParamValues_FC4680_End ; FC45FD  [ 5]
	.long DigitalEffect_ParamValues_FC46E1, DigitalEffect_ParamValues_FC46E1_End ; FC4605  [ 6]
	.long DigitalEffect_ParamValues_FC4722, DigitalEffect_ParamValues_FC4722_End ; FC460D  [ 7]
	.long DigitalEffect_ParamValues_FC475E, DigitalEffect_ParamValues_FC475E_End ; FC4615  [ 8]
	.long DigitalEffect_ParamValues_FC4722, DigitalEffect_ParamValues_FC4722_End ; FC461D  [ 9]
	.long DigitalEffect_ParamValues_FC479C, DigitalEffect_ParamValues_FC479C_End ; FC4625  [10]
	.long DigitalEffect_ParamValues_FC479C, DigitalEffect_ParamValues_FC479C_End ; FC462D  [11]

; DigitalEffect_ParamValues_FC4635 -- display list, 5 record(s), 51 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09AA0, through DigitalEffect_ParamValueLists[type].
; Framing: the length bytes walk from 0xFC4635 and land exactly on 0xFC4668.
DigitalEffect_ParamValues_FC4635:
	dlb_number	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=70, digits=2
; DLRec_FC463F -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[2]
DLRec_FC463F:
	dlb_number	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=85, digits=2
; DLRec_FC4649 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[3]
DLRec_FC4649:
	dlb_number_signed	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=100, digits=2, signflag=0x00
; DLRec_FC4654 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[4]
DLRec_FC4654:
	dlb_number	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=115, digits=2
; DLRec_FC465E -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[5]
DLRec_FC465E:
	dlb_number	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=130, digits=3
	.set DigitalEffect_ParamValues_FC4635_End, . ; FC4668  end marker: the byte after the last record

; DigitalEffect_FieldRecords_FC4668 -- 6 pointers, 24 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 (field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): record [field] drawn alone.
; COUNT 6 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecords_FC4668:
	.long DigitalEffect_ParamValues_FC4635      ; FC4668  [ 0]
	.long DigitalEffect_ParamValues_FC4635      ; FC466C  [ 1]
	.long DLRec_FC463F                          ; FC4670  [ 2]
	.long DLRec_FC4649                          ; FC4674  [ 3]
	.long DLRec_FC4654                          ; FC4678  [ 4]
	.long DLRec_FC465E                          ; FC467C  [ 5]

; DigitalEffect_ParamValues_FC4680 -- display list, 6 record(s), 61 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09AA0, through DigitalEffect_ParamValueLists[type].
; Framing: the length bytes walk from 0xFC4680 and land exactly on 0xFC46BD.
DigitalEffect_ParamValues_FC4680:
	dlb_number	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=70, digits=2
; DLRec_FC468A -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[2]
DLRec_FC468A:
	dlb_number	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=85, digits=2
; DLRec_FC4694 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[3]
DLRec_FC4694:
	dlb_number	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=100, digits=2
; DLRec_FC469E -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[4]
DLRec_FC469E:
	dlb_number	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=115, digits=2
; DLRec_FC46A8 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[5]
DLRec_FC46A8:
	dlb_number_signed	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=130, digits=2, signflag=0x00
; DLRec_FC46B3 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[6]
DLRec_FC46B3:
	dlb_number	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=145, digits=2
	.set DigitalEffect_ParamValues_FC4680_End, . ; FC46BD  end marker: the byte after the last record

; DigitalEffect_FieldRecords_FC46BD -- 9 pointers, 36 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 (field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): record [field] drawn alone.
; COUNT 9 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecords_FC46BD:
	.long DigitalEffect_ParamValues_FC4680      ; FC46BD  [ 0]
	.long DigitalEffect_ParamValues_FC4680      ; FC46C1  [ 1]
	.long DLRec_FC468A                          ; FC46C5  [ 2]
	.long DLRec_FC4694                          ; FC46C9  [ 3]
	.long DLRec_FC469E                          ; FC46CD  [ 4]
	.long DLRec_FC46A8                          ; FC46D1  [ 5]
	.long DLRec_FC46B3                          ; FC46D5  [ 6]
	.long DLRec_FC45CA                          ; FC46D9  [ 7]
	.long DLRec_FC45BF                          ; FC46DD  [ 8]

; DigitalEffect_ParamValues_FC46E1 -- display list, 4 record(s), 45 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09AA0, through DigitalEffect_ParamValueLists[type].
; Framing: the length bytes walk from 0xFC46E1 and land exactly on 0xFC470E.
DigitalEffect_ParamValues_FC46E1:
	dlb_number	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=70, digits=2
; DLRec_FC46EB -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC46E1,
;          pointed at by DigitalEffect_FieldRecords_FC470E[2]
DLRec_FC46EB:
	dlb_number	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=85, digits=2
; DLRec_FC46F5 -- a record (op 02, 15 bytes) inside DigitalEffect_ParamValues_FC46E1,
;          pointed at by DigitalEffect_FieldRecords_FC470E[3]
DLRec_FC46F5:
	dlb_string	var=ModelingPage_Fields+3, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_SinTriSqrSaw, width=3, x=216, y=100
; DLRec_FC4704 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC46E1,
;          pointed at by DigitalEffect_FieldRecords_FC470E[4]
DLRec_FC4704:
	dlb_number	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=115, digits=3
	.set DigitalEffect_ParamValues_FC46E1_End, . ; FC470E  end marker: the byte after the last record

; DigitalEffect_FieldRecords_FC470E -- 5 pointers, 20 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 (field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): record [field] drawn alone.
; COUNT 5 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecords_FC470E:
	.long DigitalEffect_ParamValues_FC46E1      ; FC470E  [ 0]
	.long DigitalEffect_ParamValues_FC46E1      ; FC4712  [ 1]
	.long DLRec_FC46EB                          ; FC4716  [ 2]
	.long DLRec_FC46F5                          ; FC471A  [ 3]
	.long DLRec_FC4704                          ; FC471E  [ 4]

; DigitalEffect_ParamValues_FC4722 -- display list, 4 record(s), 40 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09AA0, through DigitalEffect_ParamValueLists[type].
; Framing: the length bytes walk from 0xFC4722 and land exactly on 0xFC474A.
DigitalEffect_ParamValues_FC4722:
	dlb_number	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=70, digits=2
; DLRec_FC472C -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4722,
;          pointed at by DigitalEffect_FieldRecords_FC474A[2]
DLRec_FC472C:
	dlb_number	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=85, digits=2
; DLRec_FC4736 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4722,
;          pointed at by DigitalEffect_FieldRecords_FC474A[3]
DLRec_FC4736:
	dlb_number	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=100, digits=2
; DLRec_FC4740 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4722,
;          pointed at by DigitalEffect_FieldRecords_FC474A[4]
DLRec_FC4740:
	dlb_number	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=115, digits=2
	.set DigitalEffect_ParamValues_FC4722_End, . ; FC474A  end marker: the byte after the last record

; DigitalEffect_FieldRecords_FC474A -- 5 pointers, 20 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 (field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): record [field] drawn alone.
; COUNT 5 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecords_FC474A:
	.long DigitalEffect_ParamValues_FC4722      ; FC474A  [ 0]
	.long DigitalEffect_ParamValues_FC4722      ; FC474E  [ 1]
	.long DLRec_FC472C                          ; FC4752  [ 2]
	.long DLRec_FC4736                          ; FC4756  [ 3]
	.long DLRec_FC4740                          ; FC475A  [ 4]

; DigitalEffect_ParamValues_FC475E -- display list, 4 record(s), 42 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09AA0, through DigitalEffect_ParamValueLists[type].
; Framing: the length bytes walk from 0xFC475E and land exactly on 0xFC4788.
DigitalEffect_ParamValues_FC475E:
	dlb_number	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=70, digits=2
; DLRec_FC4768 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC475E,
;          pointed at by DigitalEffect_FieldRecords_FC4788[2]
DLRec_FC4768:
	dlb_number_signed	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=85, digits=2, signflag=0x00
; DLRec_FC4773 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC475E,
;          pointed at by DigitalEffect_FieldRecords_FC4788[3]
DLRec_FC4773:
	dlb_number_signed	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=100, digits=2, signflag=0x00
; DLRec_FC477E -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC475E,
;          pointed at by DigitalEffect_FieldRecords_FC4788[4]
DLRec_FC477E:
	dlb_number	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=115, digits=3
	.set DigitalEffect_ParamValues_FC475E_End, . ; FC4788  end marker: the byte after the last record

; DigitalEffect_FieldRecords_FC4788 -- 5 pointers, 20 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 (field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): record [field] drawn alone.
; COUNT 5 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecords_FC4788:
	.long DigitalEffect_ParamValues_FC475E      ; FC4788  [ 0]
	.long DigitalEffect_ParamValues_FC475E      ; FC478C  [ 1]
	.long DLRec_FC4768                          ; FC4790  [ 2]
	.long DLRec_FC4773                          ; FC4794  [ 3]
	.long DLRec_FC477E                          ; FC4798  [ 4]

; DigitalEffect_ParamValues_FC479C -- display list, 3 record(s), 35 bytes, interpreter B
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09AA0, through DigitalEffect_ParamValueLists[type].
; Framing: the length bytes walk from 0xFC479C and land exactly on 0xFC47BF.
DigitalEffect_ParamValues_FC479C:
	dlb_string	var=ModelingPage_Fields+1, mask=0x01, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn, width=3, x=216, y=70
; DLRec_FC47AB -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC479C,
;          pointed at by DigitalEffect_FieldRecords_FC47BF[2]
DLRec_FC47AB:
	dlb_number	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=85, digits=2
; DLRec_FC47B5 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC479C,
;          pointed at by DigitalEffect_FieldRecords_FC47BF[3]
DLRec_FC47B5:
	dlb_number	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=100, digits=3
	.set DigitalEffect_ParamValues_FC479C_End, . ; FC47BF  end marker: the byte after the last record

; DigitalEffect_FieldRecords_FC47BF -- 4 pointers, 16 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 (field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): record [field] drawn alone.
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecords_FC47BF:
	.long DigitalEffect_ParamValues_FC479C      ; FC47BF  [ 0]
	.long DigitalEffect_ParamValues_FC479C      ; FC47C3  [ 1]
	.long DLRec_FC47AB                          ; FC47C7  [ 2]
	.long DLRec_FC47B5                          ; FC47CB  [ 3]

; DigitalEffect_FieldRecordArrays -- 12 pointers, 48 bytes
; Read by: SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5) at 0xF09AAF: `ld XIZ,0x00FC47CF / ld C,(0x27B6) / sla 2,BC / ld XIY,(XIZ+BC)`.
; COUNT 12 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FieldRecordArrays:
	.long DigitalEffect_FieldRecords_FC4668     ; FC47CF  [ 0]
	.long DigitalEffect_FieldRecords_FC4668     ; FC47D3  [ 1]
	.long DigitalEffect_FieldRecords_FC4668     ; FC47D7  [ 2]
	.long DigitalEffect_FieldRecords_FC4668     ; FC47DB  [ 3]
	.long DigitalEffect_FieldRecords_FC46BD     ; FC47DF  [ 4]
	.long DigitalEffect_FieldRecords_FC46BD     ; FC47E3  [ 5]
	.long DigitalEffect_FieldRecords_FC470E     ; FC47E7  [ 6]
	.long DigitalEffect_FieldRecords_FC474A     ; FC47EB  [ 7]
	.long DigitalEffect_FieldRecords_FC4788     ; FC47EF  [ 8]
	.long DigitalEffect_FieldRecords_FC474A     ; FC47F3  [ 9]
	.long DigitalEffect_FieldRecords_FC47BF     ; FC47F7  [10]
	.long DigitalEffect_FieldRecords_FC47BF     ; FC47FB  [11]

; DigitalEffect_FrameEnds -- 12 pointers, 48 bytes
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A3A: `ld XIZ,0x00FC47FF / ld C,(0x27B6) / sla 2,BC / ld XIX,(XIZ+BC)`, the END of the DigitalEffect_Frame prefix.
; COUNT 12 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DigitalEffect_FrameEnds:
	.long DLRec_FC4096                          ; FC47FF  [ 0]
	.long DLRec_FC4096                          ; FC4803  [ 1]
	.long DLRec_FC4096                          ; FC4807  [ 2]
	.long DLRec_FC4096                          ; FC480B  [ 3]
	.long DigitalEffect_Frame_End               ; FC480F  [ 4]
	.long DigitalEffect_Frame_End               ; FC4813  [ 5]
	.long DLRec_FC4078                          ; FC4817  [ 6]
	.long DLRec_FC4078                          ; FC481B  [ 7]
	.long DLRec_FC4078                          ; FC481F  [ 8]
	.long DLRec_FC4078                          ; FC4823  [ 9]
	.long DLRec_FC405A                          ; FC4827  [10]
	.long DLRec_FC405A                          ; FC482B  [11]

; DigitalEffect_TypeNames -- 12 names x 13 characters, fixed width, no terminator
; Read by: the interpreter-B op-02 record DigitalEffect_Values (0xFC4592): variable 0x27A6, mask 0x0F, +7 = this table, +0x0B entry width 13.
; COUNT 12 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
DigitalEffect_TypeNames:
	.ascii "CELESTE 1    "                     ; FC482F  [0]
	.ascii "CELESTE 2    "                     ; FC483C  [1]
	.ascii "CHORUS 1     "                     ; FC4849  [2]
	.ascii "CHORUS 2     "                     ; FC4856  [3]
	.ascii "ENSEMBLE 1   "                     ; FC4863  [4]
	.ascii "ENSEMBLE 2   "                     ; FC4870  [5]
	.ascii "TREMOLO      "                     ; FC487D  [6]
	.ascii "ORGAN TREMOLO"                     ; FC488A  [7]
	.ascii "SINGLE DELAY "                     ; FC4897  [8]
	.ascii "REPEAT DELAY "                     ; FC48A4  [9]
	.ascii "SOLO EFFECT 1"                     ; FC48B1  [10]
	.ascii "SOLO EFFECT 2"                     ; FC48BE  [11]

; DigitalEffect_OutputNames -- 2 names x 6 characters, fixed width, no terminator
; Read by: the op-02 record at 0xFC45B0: variable 0x27A6, mask 0x40, shift 6, +7 = this table, width 6.
; COUNT 2 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
DigitalEffect_OutputNames:
	.ascii "MONO  "                            ; FC48CB  [0]
	.ascii "STEREO"                            ; FC48D1  [1]

; Widget_FC48D7 .. Widget_FC4B4D -- EIGHT 48x15 1-bpp pictograms, 90 bytes each
; Read by: ToneEditPage_A0_PaintResonatorIcon (prom_b 0xF09AF1): `ld XBC,0x00F09B7B / ld XIY,(XBC+D)` then
;   `ld A,3 / ld BC,6 / ld HL,0x0F / swi 7` -- SWI7 service 3,
;   LCD_Svc_03_BlitColumns (0xF8EDB4): 6 columns of 15 bytes, column-major.
;   PtrTable_F09B7B holds exactly these eight addresses, stride 90 = 6*15;
;   the index comes through IndexMap_F09B3B, whose largest value is 7.
; The pixels are images/Widget_*.png (lane IMAGE, 2026-09-02, which first
; showed this; see notes/FINDINGS-image-files.md section 4); each `.incbin`
; below reads the .bin `python3 scripts/build/wsa1_bitmaps.py build` writes
; from its PNG.
; Drawn, they are (lane IMAGE's reading): a flat bar, a cylinder, tapered
; wedges, a parallelogram, a spool, an arrow, a bolt.
; Widget_FC48D7 -- widget 0: read through PtrTable_F09B7B[0] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC48D7.png
Widget_FC48D7:
	.incbin	"images/Widget_FC48D7.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC4931 -- widget 1: read through PtrTable_F09B7B[1] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4931.png
Widget_FC4931:
	.incbin	"images/Widget_FC4931.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC498B -- widget 2: read through PtrTable_F09B7B[2] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC498B.png
Widget_FC498B:
	.incbin	"images/Widget_FC498B.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC49E5 -- widget 3: read through PtrTable_F09B7B[3] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC49E5.png
Widget_FC49E5:
	.incbin	"images/Widget_FC49E5.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC4A3F -- widget 4: read through PtrTable_F09B7B[4] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4A3F.png
Widget_FC4A3F:
	.incbin	"images/Widget_FC4A3F.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC4A99 -- widget 5: read through PtrTable_F09B7B[5] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4A99.png
Widget_FC4A99:
	.incbin	"images/Widget_FC4A99.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC4AF3 -- widget 6: read through PtrTable_F09B7B[6] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4AF3.png
Widget_FC4AF3:
	.incbin	"images/Widget_FC4AF3.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it
; Widget_FC4B4D -- widget 7: read through PtrTable_F09B7B[7] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4B4D.png
Widget_FC4B4D:
	.incbin	"images/Widget_FC4B4D.bin", 0, 90	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; SoundEditCopy_Frame -- display list, 51 record(s), 464 bytes, interpreter A
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BA0; text COPY, SOUND EDIT, FROM, TO, TONE:, OPTION.
; Framing: the length bytes walk from 0xFC4BA7 and land exactly on 0xFC4D77.
SoundEditCopy_Frame:
	dl_text16x16_packed	x=135, y=4, text="COPY"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text16x16_packed	x=55, y=31, text="FROM"
	dl_text16x16_packed	x=233, y=31, text="TO"
	dl_text8x10	x=16, y=122, text="TONE:"
	dl_text8x10	x=128, y=150, text="OPTION"
	dl_text8x14	x=272, y=154, text="COPY \021"
	dl_text8x8_packed	x=40, y=196, text="FROM"
	dl_text8x8_packed	x=37, y=209, text="SOUND"
	dl_text8x8_packed	x=79, y=209, text="TONE"
	dl_text8x8_packed	x=122, y=209, text="OPTION"
	dl_text8x8_packed	x=213, y=209, text="TO"
	dl_text8x14	x=8, y=217, text="\215"
	dl_text8x14	x=48, y=217, text="\215"
	dl_text8x14	x=88, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=8, y=227, text="\216"
	dl_text8x14	x=48, y=227, text="\216"
	dl_text8x14	x=88, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box_shadow1	x0=8, y0=48, x1=167, y1=138
	dl_box_shadow1	x0=197, y0=48, x1=306, y1=138
	dl_box_shadow1	x0=87, y0=163, x1=223, y1=189
	dl_box	x0=266, y0=149, x1=309, y1=168
	dl_box	x0=268, y0=151, x1=307, y1=166
	dl_box_shadow1	x0=1, y0=218, x1=22, y1=238
	dl_box_shadow1	x0=41, y0=218, x1=62, y1=238
	dl_box_shadow1	x0=81, y0=218, x1=102, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=2, y0=199, x1=37, y1=199
	dl_hline	x0=67, y0=199, x1=103, y1=199
	dl_hline	x0=1, y0=228, x1=22, y1=228
	dl_hline	x0=41, y0=228, x1=62, y1=228
	dl_hline	x0=81, y0=228, x1=102, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_vline	x0=2, y0=199, x1=2, y1=204
	dl_vline	x0=103, y0=199, x1=103, y1=204
	dl_hline	x0=176, y0=87, x1=185, y1=87
	dl_hline	x0=176, y0=93, x1=185, y1=93
	dl_vline	x0=176, y0=87, x1=176, y1=93
	dl_vline	x0=185, y0=84, x1=185, y1=87
	dl_vline	x0=185, y0=93, x1=185, y1=96
	dl_line	x0=185, y0=84, x1=191, y1=90
	dl_line	x0=185, y0=96, x1=191, y1=90
	dl_fill_rect	x0=54, y0=119, x1=82, y1=134
	dl_fill_rect	x0=89, y0=165, x1=221, y1=187
	.set SoundEditCopy_Frame_End, .           ; FC4D77  end marker: the byte after the last record

; SoundEditCopy_ToneLabels -- display list, 11 record(s), 116 bytes, interpreter A
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BBA when (0x27F5) != 1; text BANK:, 1st..4th TONE, SOUND:.
; Framing: the length bytes walk from 0xFC4D77 and land exactly on 0xFC4DEB.
SoundEditCopy_ToneLabels:
	dl_text8x10	x=16, y=57, text="BANK:"
	dl_text8x10	x=216, y=55, text="1st TONE"
	dl_text8x10	x=216, y=72, text="2nd TONE"
	dl_text8x10	x=16, y=80, text="SOUND:"
	dl_text8x10	x=216, y=89, text="3rd TONE"
	dl_text8x10	x=216, y=105, text="4th TONE"
	dl_text8x10	x=224, y=125, text="SOUND"
	dl_text8x8_packed	x=1, y=209, text="BANK"
	dl_hline	x0=197, y0=120, x1=306, y1=120
	dl_fill_rect	x0=54, y0=54, x1=90, y1=69
	dl_fill_rect	x0=21, y0=91, x1=154, y1=106
	.set SoundEditCopy_ToneLabels_End, .      ; FC4DEB  end marker: the byte after the last record

; SoundEditCopy_DrumLabels -- display list, 9 record(s), 105 bytes, interpreter A
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BE2 when (0x27F5) == 1; text DRUM KIT:, 1st/2nd TONE, DRUM SOUND:.
; Framing: the length bytes walk from 0xFC4DEB and land exactly on 0xFC4E54.
SoundEditCopy_DrumLabels:
	dl_text8x10	x=16, y=53, text="DRUM KIT:"
	dl_text8x10	x=216, y=61, text="1st TONE"
	dl_text8x10	x=216, y=86, text="2nd TONE"
	dl_text8x10	x=16, y=87, text="DRUM SOUND:"
	dl_text8x10	x=208, y=120, text="DRUM SOUND"
	dl_text8x8_packed	x=3, y=209, text="KIT"
	dl_hline	x0=198, y0=110, x1=305, y1=110
	dl_fill_rect	x0=21, y0=65, x1=155, y1=80
	dl_fill_rect	x0=37, y0=98, x1=149, y1=113
	.set SoundEditCopy_DrumLabels_End, .      ; FC4E54  end marker: the byte after the last record

; SoundEditCopy_ToneValues -- display list, 4 record(s), 56 bytes, interpreter B
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BCD.
; Framing: the length bytes walk from 0xFC4E54 and land exactly on 0xFC4E8C.
SoundEditCopy_ToneValues:
	dlb_string	var=ModelingPage_Fields, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=SoundEditCopy_OptionNames, width=10, x=112, y=172	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC4E63 -- a record (op 02, 15 bytes) inside SoundEditCopy_ToneValues,
;          pointed at by SoundEditCopy_ToneFieldRecords[1]
DLRec_FC4E63:
	dlb_string	var=ModelingPage_Fields+1, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=SoundEditCopy_ToneOrdinals, width=3, x=56, y=122	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC4E72 -- a record (op 02, 15 bytes) inside SoundEditCopy_ToneValues,
;          pointed at by SoundEditCopy_ToneFieldRecords[3]
DLRec_FC4E72:
	dlb_string	var=ModelingPage_Fields+3, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=SoundEditCopy_ToneBankNames, width=4, x=56, y=57	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC4E81 -- a record (op 03, 11 bytes) inside SoundEditCopy_ToneValues,
;          pointed at by SoundEditCopy_ToneFieldRecords[2]
DLRec_FC4E81:
	dlb_rect_entry	var=ModelingPage_Fields+2, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=SoundEditCopy_ToneOptionRects	; variable; mask, shift, +6; 8-byte entries
	.set SoundEditCopy_ToneValues_End, .      ; FC4E8C  end marker: the byte after the last record

; SoundEditCopy_DrumValues -- display list, 4 record(s), 56 bytes, interpreter B
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BF5.
; Framing: the length bytes walk from 0xFC4E8C and land exactly on 0xFC4EC4.
SoundEditCopy_DrumValues:
	dlb_string	var=ModelingPage_Fields, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=SoundEditCopy_OptionNames, width=10, x=112, y=172	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC4E9B -- a record (op 02, 15 bytes) inside SoundEditCopy_DrumValues,
;          pointed at by SoundEditCopy_DrumFieldRecords[1]
DLRec_FC4E9B:
	dlb_string	var=ModelingPage_Fields+1, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=SoundEditCopy_DrumOrdinals, width=3, x=56, y=122	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC4EAA -- a record (op 02, 15 bytes) inside SoundEditCopy_DrumValues,
;          pointed at by SoundEditCopy_DrumFieldRecords[3]
DLRec_FC4EAA:
	dlb_string	var=ModelingPage_Fields+3, mask=0x03, shift=0, svc=LCDSVC_DrawText8x10, table=SoundEditCopy_DrumBankNames, width=4, x=88, y=53	; variable; mask, shift, +6; string table; entry width, +0x0D
; DLRec_FC4EB9 -- a record (op 03, 11 bytes) inside SoundEditCopy_DrumValues,
;          pointed at by SoundEditCopy_DrumFieldRecords[2]
DLRec_FC4EB9:
	dlb_rect_entry	var=ModelingPage_Fields+2, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=SoundEditCopy_DrumOptionRects	; variable; mask, shift, +6; 8-byte entries
	.set SoundEditCopy_DrumValues_End, .      ; FC4EC4  end marker: the byte after the last record

; SoundEditCopy_Field5Values -- display list, 2 record(s), 30 bytes, interpreter B
; Read by: SoundEditCopy_RepaintField (prom_b 0xF09C08) at 0xF09C36 (field 5).
; Framing: the length bytes walk from 0xFC4EC4 and land exactly on 0xFC4EE2.
SoundEditCopy_Field5Values:
	dlb_string	var=ModelingPage_Fields+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=104, y=87
	dlb_string	var=DLB_NoVariable, mask=0x00, shift=0, svc=LCDSVC_DrawText8x10, table=DiskSave_PasswordEntry, width=13, x=40, y=101
	.set SoundEditCopy_Field5Values_End, .    ; FC4EE2  end marker: the byte after the last record

; SoundEditCopy_Field2Box -- display list, 1 record(s), 10 bytes, interpreter A
; Read by: SoundEditCopy_RepaintField (prom_b 0xF09C08) at 0xF09C19 (field 2, layer 1).
; Framing: the length bytes walk from 0xFC4EE2 and land exactly on 0xFC4EEC.
SoundEditCopy_Field2Box:
	dl_erase_rect	x0=205, y0=52, x1=298, y1=136
	.set SoundEditCopy_Field2Box_End, .       ; FC4EEC  end marker: the byte after the last record

; SoundEditCopy_ToneOptionRects -- 5 x 8-byte entries, four LE16 each (x0, y0, x1, y1 pixel
; coordinates, by their values: x in 0xCD..0x123, y ascending)
; Read by: the interpreter-B op-03 record at 0xFC4E81 (SoundEditCopy_ToneValues): variable 0x27A8, mask 0x0F, +7 = this table of 8-byte entries; the handler indexes it with `sla 3,HL`.
; COUNT 5 is the extent to the next object.
SoundEditCopy_ToneOptionRects:
	.short 0x00D0, 0x0034, 0x0121, 0x0043      ; FC4EEC  [0]
	.short 0x00D0, 0x0045, 0x0121, 0x0054      ; FC4EF4  [1]
	.short 0x00D0, 0x0056, 0x0121, 0x0065      ; FC4EFC  [2]
	.short 0x00D0, 0x0067, 0x0121, 0x0076      ; FC4F04  [3]
	.short 0x00D0, 0x007B, 0x0121, 0x0088      ; FC4F0C  [4]

; SoundEditCopy_DrumOptionRects -- 3 x 8-byte entries, four LE16 each (x0, y0, x1, y1 pixel
; coordinates, by their values: x in 0xCD..0x123, y ascending)
; Read by: the op-03 record at 0xFC4EB9 (SoundEditCopy_DrumValues): variable 0x27A8, +7 = this table; the handler indexes it with `sla 3,HL`.
; COUNT 3 is the extent to the next object.
SoundEditCopy_DrumOptionRects:
	.short 0x00D0, 0x0039, 0x0121, 0x004A      ; FC4F14  [0]
	.short 0x00D0, 0x0053, 0x0121, 0x0062      ; FC4F1C  [1]
	.short 0x00CD, 0x0074, 0x0123, 0x0085      ; FC4F24  [2]

; SoundEditCopy_OptionNames -- 7 names x 10 characters, fixed width, no terminator
; Read by: the op-02 records at 0xFC4E54 and 0xFC4E8C: variable 0x27A6, mask 0x0F, width 10.
; COUNT 7 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
SoundEditCopy_OptionNames:
	.ascii "  TOTAL   "                        ; FC4F2C  [0]
	.ascii " MODELING "                        ; FC4F36  [1]
	.ascii "AMPLITUDE "                        ; FC4F40  [2]
	.ascii "  PITCH   "                        ; FC4F4A  [3]
	.ascii "  FILTER  "                        ; FC4F54  [4]
	.ascii "TONE LAYER"                        ; FC4F5E  [5]
	.ascii "  CLEAR   "                        ; FC4F68  [6]

; SoundEditCopy_ToneBankNames -- 4 names x 4 characters, fixed width, no terminator
; Read by: the op-02 record at 0xFC4E72: variable 0x27A9, mask 0x0F, width 4.
; COUNT 4 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
SoundEditCopy_ToneBankNames:
	.ascii "ROM1"                              ; FC4F72  [0]
	.ascii "ROM2"                              ; FC4F76  [1]
	.ascii "USR1"                              ; FC4F7A  [2]
	.ascii "USR2"                              ; FC4F7E  [3]

; SoundEditCopy_DrumBankNames -- 3 names x 4 characters, fixed width, no terminator
; Read by: the op-02 record at 0xFC4EAA: variable 0x27A9, mask 0x03, width 4.
; COUNT 3 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
SoundEditCopy_DrumBankNames:
	.ascii "ROM "                              ; FC4F82  [0]
	.ascii "USR1"                              ; FC4F86  [1]
	.ascii "USR2"                              ; FC4F8A  [2]

; SoundEditCopy_ToneOrdinals -- 5 names x 3 characters, fixed width, no terminator
; Read by: the op-02 record at 0xFC4E63: variable 0x27A7, mask 0x0F, width 3.
; COUNT 5 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
SoundEditCopy_ToneOrdinals:
	.ascii "1st"                               ; FC4F8E  [0]
	.ascii "2nd"                               ; FC4F91  [1]
	.ascii "3rd"                               ; FC4F94  [2]
	.ascii "4th"                               ; FC4F97  [3]
	.ascii "---"                               ; FC4F9A  [4]

; SoundEditCopy_DrumOrdinals -- 3 names x 3 characters, fixed width, no terminator
; Read by: the op-02 record at 0xFC4E9B: variable 0x27A7, mask 0x0F, width 3.
; COUNT 3 is the extent to the next object (the mask bounds the index only
; loosely); the width is the record's own +0x0B field, checked by the generator.
SoundEditCopy_DrumOrdinals:
	.ascii "1st"                               ; FC4F9D  [0]
	.ascii "2nd"                               ; FC4FA0  [1]
	.ascii "---"                               ; FC4FA3  [2]

; SoundEditCopy_ToneFieldRecords -- 4 pointers, 16 bytes
; Read by: SoundEditCopy_RepaintField (prom_b 0xF09C08) at 0xF09C4D when (0x27F5) != 1, then RunDisplayListBFromPointerArray (prom_b 0xF09AE1).
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SoundEditCopy_ToneFieldRecords:
	.long SoundEditCopy_ToneValues              ; FC4FA6  [ 0]
	.long DLRec_FC4E63                          ; FC4FAA  [ 1]
	.long DLRec_FC4E81                          ; FC4FAE  [ 2]
	.long DLRec_FC4E72                          ; FC4FB2  [ 3]

; SoundEditCopy_DrumFieldRecords -- 4 pointers, 16 bytes
; Read by: SoundEditCopy_RepaintField (prom_b 0xF09C08) at 0xF09C54 when (0x27F5) == 1, then RunDisplayListBFromPointerArray.
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SoundEditCopy_DrumFieldRecords:
	.long SoundEditCopy_ToneValues              ; FC4FB6  [ 0]
	.long DLRec_FC4E9B                          ; FC4FBA  [ 1]
	.long DLRec_FC4EB9                          ; FC4FBE  [ 2]
	.long DLRec_FC4EAA                          ; FC4FC2  [ 3]

; DisplayList_FC4FC6 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC4FC6 and land exactly on 0xFC4FE4.
DisplayList_FC4FC6:
	dl_vline	x0=53, y0=90, x1=53, y1=91
	dl_hline	x0=53, y0=91, x1=182, y1=91
	dl_vline	x0=182, y0=70, x1=182, y1=91
	.set DisplayList_FC4FC6_End, .            ; FC4FE4  end marker: the byte after the last record

; DisplayList_FC4FE4 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC4FE4 and land exactly on 0xFC5002.
DisplayList_FC4FE4:
	dl_vline	x0=54, y0=92, x1=54, y1=93
	dl_hline	x0=54, y0=93, x1=183, y1=93
	dl_vline	x0=183, y0=72, x1=183, y1=93
	.set DisplayList_FC4FE4_End, .            ; FC5002  end marker: the byte after the last record

; DisplayList_FC5002 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5002 and land exactly on 0xFC5020.
DisplayList_FC5002:
	dl_vline	x0=55, y0=94, x1=55, y1=95
	dl_hline	x0=55, y0=95, x1=184, y1=95
	dl_vline	x0=184, y0=74, x1=184, y1=95
	.set DisplayList_FC5002_End, .            ; FC5020  end marker: the byte after the last record

; DisplayList_FC5020 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5020 and land exactly on 0xFC503E.
DisplayList_FC5020:
	dl_vline	x0=53, y0=127, x1=53, y1=128
	dl_hline	x0=53, y0=128, x1=182, y1=128
	dl_vline	x0=182, y0=107, x1=182, y1=128
	.set DisplayList_FC5020_End, .            ; FC503E  end marker: the byte after the last record

; DisplayList_FC503E -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC503E and land exactly on 0xFC505C.
DisplayList_FC503E:
	dl_vline	x0=54, y0=129, x1=54, y1=130
	dl_hline	x0=54, y0=130, x1=183, y1=130
	dl_vline	x0=183, y0=109, x1=183, y1=130
	.set DisplayList_FC503E_End, .            ; FC505C  end marker: the byte after the last record

; DisplayList_FC505C -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC505C and land exactly on 0xFC507A.
DisplayList_FC505C:
	dl_vline	x0=55, y0=131, x1=55, y1=132
	dl_hline	x0=55, y0=132, x1=184, y1=132
	dl_vline	x0=184, y0=111, x1=184, y1=132
	.set DisplayList_FC505C_End, .            ; FC507A  end marker: the byte after the last record

; DisplayList_FC507A -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC507A and land exactly on 0xFC5098.
DisplayList_FC507A:
	dl_vline	x0=53, y0=164, x1=53, y1=165
	dl_hline	x0=53, y0=165, x1=182, y1=165
	dl_vline	x0=182, y0=144, x1=182, y1=165
	.set DisplayList_FC507A_End, .            ; FC5098  end marker: the byte after the last record

; DisplayList_FC5098 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5098 and land exactly on 0xFC50B6.
DisplayList_FC5098:
	dl_vline	x0=54, y0=166, x1=54, y1=167
	dl_hline	x0=54, y0=167, x1=183, y1=167
	dl_vline	x0=183, y0=146, x1=183, y1=167
	.set DisplayList_FC5098_End, .            ; FC50B6  end marker: the byte after the last record

; DisplayList_FC50B6 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC50B6 and land exactly on 0xFC50D4.
DisplayList_FC50B6:
	dl_vline	x0=55, y0=168, x1=55, y1=169
	dl_hline	x0=55, y0=169, x1=184, y1=169
	dl_vline	x0=184, y0=148, x1=184, y1=169
	.set DisplayList_FC50B6_End, .            ; FC50D4  end marker: the byte after the last record

; DisplayList_FC50D4 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC50D4 and land exactly on 0xFC50F2.
DisplayList_FC50D4:
	dl_vline	x0=53, y0=201, x1=53, y1=202
	dl_hline	x0=53, y0=202, x1=182, y1=202
	dl_vline	x0=182, y0=181, x1=182, y1=202
	.set DisplayList_FC50D4_End, .            ; FC50F2  end marker: the byte after the last record

; DisplayList_FC50F2 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC50F2 and land exactly on 0xFC5110.
DisplayList_FC50F2:
	dl_vline	x0=54, y0=203, x1=54, y1=204
	dl_hline	x0=54, y0=204, x1=183, y1=204
	dl_vline	x0=183, y0=183, x1=183, y1=204
	.set DisplayList_FC50F2_End, .            ; FC5110  end marker: the byte after the last record

; DisplayList_FC5110 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5110 and land exactly on 0xFC512E.
DisplayList_FC5110:
	dl_vline	x0=55, y0=205, x1=55, y1=206
	dl_hline	x0=55, y0=206, x1=184, y1=206
	dl_vline	x0=184, y0=185, x1=184, y1=206
	.set DisplayList_FC5110_End, .            ; FC512E  end marker: the byte after the last record

; SegmentArrays_FC512E -- 4 pointers, 16 bytes
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD, indexed by A-20 (see DisplayList_FC4FC6).
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SegmentArrays_FC512E:
	.long SegmentBounds_FC513E                  ; FC512E  [ 0]
	.long SegmentBounds_FC514E                  ; FC5132  [ 1]
	.long SegmentBounds_FC515E                  ; FC5136  [ 2]
	.long SegmentBounds_FC516E                  ; FC513A  [ 3]

; SegmentBounds_FC513E -- 4 pointers, 16 bytes
; Read by: SegmentArrays_FC512E[0]: (XIZ) is the start, (XIZ+4*B) the end.
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SegmentBounds_FC513E:
	.long DisplayList_FC4FC6                    ; FC513E  [ 0]
	.long DisplayList_FC4FC6_End                ; FC5142  [ 1]
	.long DisplayList_FC4FE4_End                ; FC5146  [ 2]
	.long DisplayList_FC5002_End                ; FC514A  [ 3]

; SegmentBounds_FC514E -- 4 pointers, 16 bytes
; Read by: SegmentArrays_FC512E[1].
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SegmentBounds_FC514E:
	.long DisplayList_FC5020                    ; FC514E  [ 0]
	.long DisplayList_FC5020_End                ; FC5152  [ 1]
	.long DisplayList_FC503E_End                ; FC5156  [ 2]
	.long DisplayList_FC505C_End                ; FC515A  [ 3]

; SegmentBounds_FC515E -- 4 pointers, 16 bytes
; Read by: SegmentArrays_FC512E[2].
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SegmentBounds_FC515E:
	.long DisplayList_FC507A                    ; FC515E  [ 0]
	.long DisplayList_FC507A_End                ; FC5162  [ 1]
	.long DisplayList_FC5098_End                ; FC5166  [ 2]
	.long DisplayList_FC50B6_End                ; FC516A  [ 3]

; SegmentBounds_FC516E -- 4 pointers, 16 bytes
; Read by: SegmentArrays_FC512E[3].
; COUNT 4 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
SegmentBounds_FC516E:
	.long DisplayList_FC50D4                    ; FC516E  [ 0]
	.long DisplayList_FC50D4_End                ; FC5172  [ 1]
	.long DisplayList_FC50F2_End                ; FC5176  [ 2]
	.long DisplayList_FC5110_End                ; FC517A  [ 3]

; DisplayList_FC517E -- display list, 17 record(s), 252 bytes, interpreter B
; Read by: SoundEditMenu_RepaintField (prom_b 0xF09CA9, Dispatch_Code80_RepaintFieldTable[0]) at 0xF09D07 and 0xF09D69, and prom_b 0xF5BF6D, whole; its inner sub-lists 0xFC51B1-0xFC51D3 (0xF09D28), 0xFC51F9-0xFC521B (0xF09D3D), 0xFC524D-0xFC526F (0xF09CD1).
; Framing: the length bytes walk from 0xFC517E and land exactly on 0xFC527A.
DisplayList_FC517E:
	dlb_string_xy	var=DLB_NoVariable, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16Packed, table=SoundEditText_Slot4, width=16, x=87, y=9
; DLRec_FC518F -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[1], DisplayRecordPtrs_FC52B4[2]
DLRec_FC518F:
	dlb_string_xy	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText16x16Packed, table=DLText_NoteNamesCm2ToG8, width=3, x=61, y=53
	dlb_string_xy	var=DLB_NoVariable, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16Packed, table=DiskSave_PasswordEntry, width=13, x=105, y=53
; SoundEditMenu_RepaintField_DL3 -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[15]
SoundEditMenu_RepaintField_DL3:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string_xy	var=ModelingPage_Fields+15, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLTable_F0574D, width=2, x=61, y=122
	dlb_string_xy	var=DLB_NoVariable, mask=0x00, shift=0, svc=LCDSVC_DrawText8x8Packed, table=SoundEditText_Slot2, width=13, x=73, y=122
; DLRec_FC51D3 -- a record (op 09, 12 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[3]
DLRec_FC51D3:
	dlb_number_xy	var=ModelingPage_Fields+3, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x8Packed, x=165, y=122, digits=3
; DLRec_FC51DF -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[5]
DLRec_FC51DF:
	dlb_number_signed_xy	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=195, y=122, digits=2, signflag=0x00
; DLRec_FC51EC -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[7]
DLRec_FC51EC:
	dlb_number_signed_xy	var=ModelingPage_Fields+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=225, y=122, digits=2, signflag=0x00
; SoundEditMenu_RepaintField_DL4 -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[16]
SoundEditMenu_RepaintField_DL4:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string_xy	var=ModelingPage_Fields+16, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLTable_F0574D, width=2, x=61, y=152
	dlb_string_xy	var=DLB_NoVariable, mask=0x00, shift=0, svc=LCDSVC_DrawText8x8Packed, table=SoundEditText_Slot3, width=13, x=73, y=152
; DLRec_FC521B -- a record (op 09, 12 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[4]
DLRec_FC521B:
	dlb_number_xy	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x8Packed, x=165, y=152, digits=3
; DLRec_FC5227 -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[6]
DLRec_FC5227:
	dlb_number_signed_xy	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=195, y=152, digits=2, signflag=0x00
; DLRec_FC5234 -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[8]
DLRec_FC5234:
	dlb_number_signed_xy	var=ModelingPage_Fields+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=225, y=152, digits=2, signflag=0x00
; DLRec_FC5241 -- a record (op 09, 12 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[9], DisplayRecordPtrs_FC52B4[10], DisplayRecordPtrs_FC52B4[11]
DLRec_FC5241:
	dlb_number_xy	var=ModelingPage_Fields+11, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x8Packed, x=284, y=137, digits=3
; SoundEditMenu_RepaintField_DL1 -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          an inner entry point or end named in the list's Read-by line
SoundEditMenu_RepaintField_DL1:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string_xy	var=ModelingPage_Fields+12, mask=0x03, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_CtrLRRdm, width=3, x=259, y=122
	dlb_string_xy	var=ModelingPage_Fields+12, mask=0x0c, shift=2, svc=LCDSVC_DrawText8x8Packed, table=DLText_CtrLRRdm, width=3, x=259, y=152
; DLRec_FC526F -- a record (op 03, 11 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[0]
DLRec_FC526F:
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x03, shift=0, svc=LCDSVC_FillRect, table=Rects_FC5292	; variable; mask, shift, +6; 8-byte entries
	.set DisplayList_FC517E_End, .            ; FC527A  end marker: the byte after the last record

; DisplayRecords_FC527A -- display list, 2 record(s), 24 bytes, interpreter B
; Read by: DisplayRecordPtrs_FC52B4[12..14] only (two op-09 records, each drawn alone).
; Framing: the length bytes walk from 0xFC527A and land exactly on 0xFC5292.
DisplayRecords_FC527A:
	dlb_number_xy	var=ModelingPage_Fields+13, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x8Packed, x=265, y=122, digits=2
; DLRec_FC5286 -- a record (op 09, 12 bytes) inside DisplayRecords_FC527A,
;          pointed at by DisplayRecordPtrs_FC52B4[14]
DLRec_FC5286:
	dlb_number_xy	var=ModelingPage_Fields+14, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x8Packed, x=265, y=152, digits=2
	.set DisplayRecords_FC527A_End, .         ; FC5292  end marker: the byte after the last record

; Rects_FC5292 -- 3 x 8-byte entries, four LE16 each (x0, y0, x1, y1 pixel
; coordinates, by their values: x in 0xCD..0x123, y ascending)
; Read by: the interpreter-B op-03 record at 0xFC526F: variable 0x27A6, mask 0x03, +7 = this table; the handler indexes it with `sla 3,HL`.
; COUNT 3 is the extent to the next object.
Rects_FC5292:
	.short 0x000D, 0x0071, 0x0118, 0x008A      ; FC5292  [0]
	.short 0x000D, 0x0071, 0x0117, 0x008A      ; FC529A  [1]
	.short 0x000D, 0x008E, 0x0117, 0x00A8      ; FC52A2  [2]

; SoundEditMenu_RepaintField_DL2 -- display list, 1 record(s), 10 bytes, interpreter A
; Read by: SoundEditMenu_RepaintField (prom_b 0xF09CA9, Dispatch_Code80_RepaintFieldTable[0]) at 0xF09CEB and 0xF09D52 (layer 1).
; Framing: the length bytes walk from 0xFC52AA and land exactly on 0xFC52B4.
SoundEditMenu_RepaintField_DL2:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=13, y0=113, x1=280, y1=168
	.set DisplayList_FC52AA_End, .            ; FC52B4  end marker: the byte after the last record

; DisplayRecordPtrs_FC52B4 -- 17 pointers, 68 bytes
; Read by: SoundEditMenu_RepaintField (prom_b 0xF09CA9, Dispatch_Code80_RepaintFieldTable[0]) at 0xF09CFB and 0xF09D82, prom_b 0xF09E11 and 0xF09E76: XIY = this, then RunDisplayListBFromPointerArray / 0xF09AB0 with A = the field.
; COUNT 17 is the extent to the next object of this framing; every entry lands
; on a list or record boundary (gen_fc4000_pages.py checks each one).
DisplayRecordPtrs_FC52B4:
	.long DLRec_FC526F                          ; FC52B4  [ 0]
	.long DLRec_FC518F                          ; FC52B8  [ 1]
	.long DLRec_FC518F                          ; FC52BC  [ 2]
	.long DLRec_FC51D3                          ; FC52C0  [ 3]
	.long DLRec_FC521B                          ; FC52C4  [ 4]
	.long DLRec_FC51DF                          ; FC52C8  [ 5]
	.long DLRec_FC5227                          ; FC52CC  [ 6]
	.long DLRec_FC51EC                          ; FC52D0  [ 7]
	.long DLRec_FC5234                          ; FC52D4  [ 8]
	.long DLRec_FC5241                          ; FC52D8  [ 9]
	.long DLRec_FC5241                          ; FC52DC  [10]
	.long DLRec_FC5241                          ; FC52E0  [11]
	.long DisplayRecords_FC527A                 ; FC52E4  [12]
	.long DisplayRecords_FC527A                 ; FC52E8  [13]
	.long DLRec_FC5286                          ; FC52EC  [14]
	.long SoundEditMenu_RepaintField_DL3                          ; FC52F0  [15]
	.long SoundEditMenu_RepaintField_DL4                          ; FC52F4  [16]

; 0xFC52F8-0xFC53FF -- 264 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: verified against original_ROMs/wsa1_prom_a.ic12.
	.fill 264, 1, 0x0E
