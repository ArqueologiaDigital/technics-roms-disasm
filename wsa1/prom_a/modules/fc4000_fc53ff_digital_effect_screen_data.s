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
; Regenerate / re-check: notes/proma-2026-09-25/gen_fc4000_pages.py (repo root).
; ==============================================================================

; DigitalEffect_Frame -- display list, 24 record(s), 180 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A33: XIY = this, XIX = DigitalEffect_FrameEnds[type]; so a PREFIX of this list is drawn, ending at one of the four inner labels.
; Framing: the length bytes walk from 0xFC4000 and land exactly on 0xFC40B4.
; (was `DisplayList_FC4000`, the label of this whole span until 2026-09-25)
DigitalEffect_Frame:
	.byte 0x06, 0x05                             ; FC4000  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xEA, 0x21, 0x8D                  ; FC4002
	.byte 0x06, 0x05                             ; FC4005  op 06, 5 bytes, handler 0xF31A3A
	.ascii "z#"                               ; FC4007
	.byte 0x8E                              ; FC4009
	.byte 0x22, 0x0A                             ; FC400A  op 22, 10 bytes, handler 0xF31A75
	.byte 0x09, 0x00, 0xDA, 0x00, 0x1E, 0x00, 0xEE, 0x00 ; FC400C
	.byte 0x01, 0x0A                             ; FC4014  op 01, 10 bytes, handler 0xF31A75
	.byte 0x09, 0x00, 0xE4, 0x00, 0x1E, 0x00, 0xE4, 0x00 ; FC4016
	.byte 0x06, 0x05                             ; FC401E  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xEF, 0x21, 0x8D                  ; FC4020
	.byte 0x06, 0x05                             ; FC4023  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x7F, 0x23, 0x8E                  ; FC4025
	.byte 0x22, 0x0A                             ; FC4028  op 22, 10 bytes, handler 0xF31A75
	.byte 0x31, 0x00, 0xDA, 0x00, 0x46, 0x00, 0xEE, 0x00 ; FC402A
	.byte 0x01, 0x0A                             ; FC4032  op 01, 10 bytes, handler 0xF31A75
	.byte 0x31, 0x00, 0xE4, 0x00, 0x46, 0x00, 0xE4, 0x00 ; FC4034
	.byte 0x06, 0x05                             ; FC403C  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xF4, 0x21, 0x8D                  ; FC403E
	.byte 0x06, 0x05                             ; FC4041  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x84, 0x23, 0x8E                  ; FC4043
	.byte 0x22, 0x0A                             ; FC4046  op 22, 10 bytes, handler 0xF31A75
	.byte 0x59, 0x00, 0xDA, 0x00, 0x6E, 0x00, 0xEE, 0x00 ; FC4048
	.byte 0x01, 0x0A                             ; FC4050  op 01, 10 bytes, handler 0xF31A75
	.byte 0x59, 0x00, 0xE4, 0x00, 0x6E, 0x00, 0xE4, 0x00 ; FC4052
; DLRec_FC405A -- a record (op 06, 5 bytes) inside DigitalEffect_Frame,
;          pointed at by DigitalEffect_FrameEnds[10], DigitalEffect_FrameEnds[11]
DLRec_FC405A:
	.byte 0x06, 0x05                             ; FC405A  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xF9, 0x21, 0x8D                  ; FC405C
	.byte 0x06, 0x05                             ; FC405F  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x89, 0x23, 0x8E                  ; FC4061
	.byte 0x22, 0x0A                             ; FC4064  op 22, 10 bytes, handler 0xF31A75
	.byte 0x81, 0x00, 0xDA, 0x00, 0x96, 0x00, 0xEE, 0x00 ; FC4066
	.byte 0x01, 0x0A                             ; FC406E  op 01, 10 bytes, handler 0xF31A75
	.byte 0x81, 0x00, 0xE4, 0x00, 0x96, 0x00, 0xE4, 0x00 ; FC4070
; DLRec_FC4078 -- a record (op 06, 5 bytes) inside DigitalEffect_Frame,
;          pointed at by DigitalEffect_FrameEnds[6], DigitalEffect_FrameEnds[7], DigitalEffect_FrameEnds[8], DigitalEffect_FrameEnds[9]
DLRec_FC4078:
	.byte 0x06, 0x05                             ; FC4078  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xFE, 0x21, 0x8D                  ; FC407A
	.byte 0x06, 0x05                             ; FC407D  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x8E, 0x23, 0x8E                  ; FC407F
	.byte 0x22, 0x0A                             ; FC4082  op 22, 10 bytes, handler 0xF31A75
	.byte 0xA9, 0x00, 0xDA, 0x00, 0xBE, 0x00, 0xEE, 0x00 ; FC4084
	.byte 0x01, 0x0A                             ; FC408C  op 01, 10 bytes, handler 0xF31A75
	.byte 0xA9, 0x00, 0xE4, 0x00, 0xBE, 0x00, 0xE4, 0x00 ; FC408E
; DLRec_FC4096 -- a record (op 06, 5 bytes) inside DigitalEffect_Frame,
;          pointed at by DigitalEffect_FrameEnds[0], DigitalEffect_FrameEnds[1], DigitalEffect_FrameEnds[2], DigitalEffect_FrameEnds[3]
DLRec_FC4096:
	.byte 0x06, 0x05                             ; FC4096  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x03, 0x22, 0x8D                  ; FC4098
	.byte 0x06, 0x05                             ; FC409B  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x93, 0x23, 0x8E                  ; FC409D
	.byte 0x22, 0x0A                             ; FC40A0  op 22, 10 bytes, handler 0xF31A75
	.byte 0xD1, 0x00, 0xDA, 0x00, 0xE6, 0x00, 0xEE, 0x00 ; FC40A2
	.byte 0x01, 0x0A                             ; FC40AA  op 01, 10 bytes, handler 0xF31A75
	.byte 0xD1, 0x00, 0xE4, 0x00, 0xE6, 0x00, 0xE4, 0x00 ; FC40AC
	.set DigitalEffect_Frame_End, .           ; FC40B4  end marker: the byte after the last record

; DigitalEffect_ValueFrames -- display list, 8 record(s), 60 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A5F (type != 10) / 0xF09A58 (type 10: from the inner label), to 0xFC40F0.
; Framing: the length bytes walk from 0xFC40B4 and land exactly on 0xFC40F0.
DigitalEffect_ValueFrames:
	.byte 0x06, 0x05                             ; FC40B4  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x08, 0x22, 0x8D                  ; FC40B6
	.byte 0x06, 0x05                             ; FC40B9  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x98, 0x23, 0x8E                  ; FC40BB
	.byte 0x22, 0x0A                             ; FC40BE  op 22, 10 bytes, handler 0xF31A75
	.byte 0xF9, 0x00, 0xDA, 0x00, 0x0E, 0x01, 0xEE, 0x00 ; FC40C0
	.byte 0x01, 0x0A                             ; FC40C8  op 01, 10 bytes, handler 0xF31A75
	.byte 0xF9, 0x00, 0xE4, 0x00, 0x0E, 0x01, 0xE4, 0x00 ; FC40CA
; SoundEditDigitalEffect_Paint_DL2 -- a record (op 06, 5 bytes) inside DigitalEffect_ValueFrames,
;          an inner entry point or end named in the list's Read-by line
SoundEditDigitalEffect_Paint_DL2:
; ; drawn (start operand) by SoundEditDigitalEffect_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x05                             ; FC40D2  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x0D, 0x22, 0x8D                  ; FC40D4
	.byte 0x06, 0x05                             ; FC40D7  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x9D, 0x23, 0x8E                  ; FC40D9
	.byte 0x22, 0x0A                             ; FC40DC  op 22, 10 bytes, handler 0xF31A75
	.byte 0x21, 0x01, 0xDA, 0x00, 0x36, 0x01, 0xEE, 0x00 ; FC40DE
	.byte 0x01, 0x0A                             ; FC40E6  op 01, 10 bytes, handler 0xF31A75
	.byte 0x21, 0x01, 0xE4, 0x00, 0x36, 0x01, 0xE4, 0x00 ; FC40E8
	.set DigitalEffect_ValueFrames_End, .     ; FC40F0  end marker: the byte after the last record

; DigitalEffect_Header -- display list, 31 record(s), 287 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A0C (type != 10) / 0xF09A05 (type 10: from the inner label), to 0xFC420F; text INTENSITY, DIGITAL EFFECT, SOUND EDIT, TYPE, REVERB DEPTH.
; Framing: the length bytes walk from 0xFC40F0 and land exactly on 0xFC420F.
DigitalEffect_Header:
	.byte 0x06, 0x0D                             ; FC40F0  op 06, 13 bytes, handler 0xF31A3A
	.byte 0x0B, 0x19                        ; FC40F2
	.ascii "INTENSITY"                        ; FC40F4
	.byte 0x06, 0x05                             ; FC40FD  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x19, 0x19, 0x3A                  ; FC40FF
	.byte 0x17, 0x0D                             ; FC4102  op 17, 13 bytes, handler 0xF31A52
	.byte 0xF0, 0x00, 0xD1, 0x00            ; FC4104
	.ascii "INTENS."                          ; FC4108
; SoundEditDigitalEffect_Paint_DL1 -- a record (op 23, 5 bytes) inside DigitalEffect_Header,
;          an inner entry point or end named in the list's Read-by line
SoundEditDigitalEffect_Paint_DL1:
; ; drawn (start operand) by SoundEditDigitalEffect_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x23, 0x05                             ; FC410F  op 23, 5 bytes, handler 0xF31ACE
	.byte 0x0A, 0x32, 0x00                  ; FC4111
	.byte 0x1C, 0x14                             ; FC4114  op 1C, 20 bytes, handler 0xF31A52
	.byte 0x6F, 0x00, 0x05, 0x00            ; FC4116
	.ascii "DIGITAL EFFECT"                   ; FC411A
	.byte 0x17, 0x10                             ; FC4128  op 17, 16 bytes, handler 0xF31A52
	.byte 0x06, 0x00, 0x07, 0x00            ; FC412A
	.ascii "SOUND EDIT"                       ; FC412E
	.byte 0x06, 0x08                             ; FC4138  op 06, 8 bytes, handler 0xF31A3A
	.byte 0x03, 0x08                        ; FC413A
	.ascii "TYPE"                             ; FC413C
	.byte 0x06, 0x05                             ; FC4140  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x08, 0x08, 0x3A                  ; FC4142
	.byte 0x17, 0x07                             ; FC4145  op 17, 7 bytes, handler 0xF31A52
	.byte 0x36, 0x01, 0x46, 0x00, 0x91      ; FC4147
	.byte 0x07, 0x05                             ; FC414C  op 07, 5 bytes, handler 0xF31A3A
	.byte 0x68, 0x0B, 0x10                  ; FC414E
	.byte 0x07, 0x07                             ; FC4151  op 07, 7 bytes, handler 0xF31A3A
	.byte 0x8C, 0x0B, 0x8D                  ; FC4153
	.ascii "  "                               ; FC4156
	.byte 0x07, 0x05                             ; FC4158  op 07, 5 bytes, handler 0xF31A3A
	.byte 0xB7, 0x0B, 0xA9                  ; FC415A
	.byte 0x06, 0x08                             ; FC415D  op 06, 8 bytes, handler 0xF31A3A
	.byte 0xAA, 0x0E                        ; FC415F
	.ascii "TYPE"                             ; FC4161
	.byte 0x17, 0x07                             ; FC4165  op 17, 7 bytes, handler 0xF31A52
	.byte 0x36, 0x01, 0x6D, 0x00, 0x91      ; FC4167
	.byte 0x07, 0x05                             ; FC416C  op 07, 5 bytes, handler 0xF31A3A
	.byte 0x80, 0x11, 0x10                  ; FC416E
	.byte 0x07, 0x07                             ; FC4171  op 07, 7 bytes, handler 0xF31A3A
	.byte 0xA4, 0x11, 0x8E                  ; FC4173
	.ascii "  "                               ; FC4176
	.byte 0x07, 0x05                             ; FC4178  op 07, 5 bytes, handler 0xF31A3A
	.byte 0xCF, 0x11, 0xA9                  ; FC417A
	.byte 0x06, 0x13                             ; FC417D  op 06, 19 bytes, handler 0xF31A3A
	.byte 0x63, 0x1B                        ; FC417F
	.ascii "REVERB DEPTH  :"                  ; FC4181
	.byte 0x17, 0x0C                             ; FC4190  op 17, 12 bytes, handler 0xF31A52
	.byte 0x1A, 0x01, 0xD1, 0x00            ; FC4192
	.ascii "REVERB"                           ; FC4196
	.byte 0x09, 0x0A                             ; FC419C  op 09, 10 bytes, handler 0xF31A75
	.byte 0x04, 0x00, 0x04, 0x00, 0x44, 0x00, 0x10, 0x00 ; FC419E
	.byte 0x22, 0x0A                             ; FC41A6  op 22, 10 bytes, handler 0xF31A75
	.byte 0x47, 0x00, 0x2E, 0x00, 0xFB, 0x00, 0xBB, 0x00 ; FC41A8
	.byte 0x09, 0x0A                             ; FC41B0  op 09, 10 bytes, handler 0xF31A75
	.byte 0x12, 0x01, 0x45, 0x00, 0x35, 0x01, 0x58, 0x00 ; FC41B2
	.byte 0x09, 0x0A                             ; FC41BA  op 09, 10 bytes, handler 0xF31A75
	.byte 0x0C, 0x00, 0x46, 0x00, 0x2C, 0x00, 0x59, 0x00 ; FC41BC
	.byte 0x09, 0x0A                             ; FC41C4  op 09, 10 bytes, handler 0xF31A75
	.byte 0x14, 0x01, 0x47, 0x00, 0x33, 0x01, 0x56, 0x00 ; FC41C6
	.byte 0x09, 0x0A                             ; FC41CE  op 09, 10 bytes, handler 0xF31A75
	.byte 0x0E, 0x00, 0x48, 0x00, 0x2A, 0x00, 0x57, 0x00 ; FC41D0
	.byte 0x09, 0x0A                             ; FC41D8  op 09, 10 bytes, handler 0xF31A75
	.byte 0x0C, 0x00, 0x6C, 0x00, 0x44, 0x00, 0x7F, 0x00 ; FC41DA
	.byte 0x09, 0x0A                             ; FC41E2  op 09, 10 bytes, handler 0xF31A75
	.byte 0x12, 0x01, 0x6C, 0x00, 0x35, 0x01, 0x7F, 0x00 ; FC41E4
	.byte 0x09, 0x0A                             ; FC41EC  op 09, 10 bytes, handler 0xF31A75
	.byte 0x0E, 0x00, 0x6E, 0x00, 0x42, 0x00, 0x7D, 0x00 ; FC41EE
	.byte 0x09, 0x0A                             ; FC41F6  op 09, 10 bytes, handler 0xF31A75
	.byte 0x14, 0x01, 0x6E, 0x00, 0x33, 0x01, 0x7D, 0x00 ; FC41F8
	.byte 0x01, 0x0A                             ; FC4200  op 01, 10 bytes, handler 0xF31A75
	.byte 0x47, 0x00, 0x41, 0x00, 0xFB, 0x00, 0x41, 0x00 ; FC4202
	.byte 0x23, 0x05                             ; FC420A  op 23, 5 bytes, handler 0xF31ACE
	.ascii "v2"                               ; FC420C
	.byte 0x00                              ; FC420E
	.set DigitalEffect_Header_End, .          ; FC420F  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC420F -- display list, 15 record(s), 131 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC420F and land exactly on 0xFC4292.
DigitalEffect_ParamLabels_FC420F:
	.byte 0x06, 0x09                             ; FC420F  op 06, 9 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC4211
	.ascii "DEPTH"                            ; FC4213
	.byte 0x06, 0x05                             ; FC4218  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC421A
	.byte 0x06, 0x09                             ; FC421D  op 06, 9 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC421F
	.ascii "SPEED"                            ; FC4221
	.byte 0x06, 0x05                             ; FC4226  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC4228
	.byte 0x06, 0x0A                             ; FC422B  op 06, 10 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC422D
	.ascii "DETUNE"                           ; FC422F
	.byte 0x06, 0x05                             ; FC4235  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC4237
	.byte 0x06, 0x09                             ; FC423A  op 06, 9 bytes, handler 0xF31A3A
	.byte 0x03, 0x12                        ; FC423C
	.ascii "DELAY"                            ; FC423E
	.byte 0x06, 0x05                             ; FC4243  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x11, 0x12, 0x3A                  ; FC4245
	.byte 0x06, 0x0B                             ; FC4248  op 06, 11 bytes, handler 0xF31A3A
	.byte 0x5B, 0x14                        ; FC424A
	.ascii "BALANCE"                          ; FC424C
	.byte 0x06, 0x05                             ; FC4253  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x69, 0x14, 0x3A                  ; FC4255
	.byte 0x17, 0x0B                             ; FC4258  op 17, 11 bytes, handler 0xF31A52
	.byte 0x06, 0x00, 0xD1, 0x00            ; FC425A
	.ascii "DEPTH"                            ; FC425E
	.byte 0x17, 0x0B                             ; FC4263  op 17, 11 bytes, handler 0xF31A52
	.byte 0x2D, 0x00, 0xD1, 0x00            ; FC4265
	.ascii "SPEED"                            ; FC4269
	.byte 0x17, 0x0C                             ; FC426E  op 17, 12 bytes, handler 0xF31A52
	.byte 0x52, 0x00, 0xD1, 0x00            ; FC4270
	.ascii "DETUNE"                           ; FC4274
	.byte 0x17, 0x0B                             ; FC427A  op 17, 11 bytes, handler 0xF31A52
	.byte 0x7C, 0x00, 0xD1, 0x00            ; FC427C
	.ascii "DELAY"                            ; FC4280
	.byte 0x17, 0x0D                             ; FC4285  op 17, 13 bytes, handler 0xF31A52
	.byte 0xA0, 0x00, 0xD1, 0x00            ; FC4287
	.ascii "BALANCE"                          ; FC428B
	.set DigitalEffect_ParamLabels_FC420F_End, . ; FC4292  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4292 -- display list, 18 record(s), 160 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4292 and land exactly on 0xFC4332.
DigitalEffect_ParamLabels_FC4292:
	.byte 0x06, 0x0A                             ; FC4292  op 06, 10 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC4294
	.ascii "DEPTH1"                           ; FC4296
	.byte 0x06, 0x05                             ; FC429C  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC429E
	.byte 0x06, 0x0A                             ; FC42A1  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC42A3
	.ascii "SPEED1"                           ; FC42A5
	.byte 0x06, 0x05                             ; FC42AB  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC42AD
	.byte 0x06, 0x0A                             ; FC42B0  op 06, 10 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC42B2
	.ascii "DEPTH2"                           ; FC42B4
	.byte 0x06, 0x05                             ; FC42BA  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC42BC
	.byte 0x06, 0x0A                             ; FC42BF  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x03, 0x12                        ; FC42C1
	.ascii "SPEED2"                           ; FC42C3
	.byte 0x06, 0x05                             ; FC42C9  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x11, 0x12, 0x3A                  ; FC42CB
	.byte 0x06, 0x0A                             ; FC42CE  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x5B, 0x14                        ; FC42D0
	.ascii "DETUNE"                           ; FC42D2
	.byte 0x06, 0x05                             ; FC42D8  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x69, 0x14, 0x3A                  ; FC42DA
	.byte 0x06, 0x09                             ; FC42DD  op 06, 9 bytes, handler 0xF31A3A
	.byte 0xB3, 0x16                        ; FC42DF
	.ascii "DELAY"                            ; FC42E1
	.byte 0x06, 0x05                             ; FC42E6  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xC1, 0x16, 0x3A                  ; FC42E8
	.byte 0x17, 0x0C                             ; FC42EB  op 17, 12 bytes, handler 0xF31A52
	.byte 0x02, 0x00, 0xD1, 0x00            ; FC42ED
	.ascii "DEPTH1"                           ; FC42F1
	.byte 0x17, 0x0C                             ; FC42F7  op 17, 12 bytes, handler 0xF31A52
	.byte 0x2A, 0x00, 0xD1, 0x00            ; FC42F9
	.ascii "SPEED1"                           ; FC42FD
	.byte 0x17, 0x0C                             ; FC4303  op 17, 12 bytes, handler 0xF31A52
	.byte 0x52, 0x00, 0xD1, 0x00            ; FC4305
	.ascii "DEPTH2"                           ; FC4309
	.byte 0x17, 0x0C                             ; FC430F  op 17, 12 bytes, handler 0xF31A52
	.byte 0x7A, 0x00, 0xD1, 0x00            ; FC4311
	.ascii "SPEED2"                           ; FC4315
	.byte 0x17, 0x0C                             ; FC431B  op 17, 12 bytes, handler 0xF31A52
	.byte 0xA2, 0x00, 0xD1, 0x00            ; FC431D
	.ascii "DETUNE"                           ; FC4321
	.byte 0x17, 0x0B                             ; FC4327  op 17, 11 bytes, handler 0xF31A52
	.byte 0xCD, 0x00, 0xD1, 0x00            ; FC4329
	.ascii "DELAY"                            ; FC432D
	.set DigitalEffect_ParamLabels_FC4292_End, . ; FC4332  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4332 -- display list, 12 record(s), 102 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4332 and land exactly on 0xFC4398.
DigitalEffect_ParamLabels_FC4332:
	.byte 0x06, 0x09                             ; FC4332  op 06, 9 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC4334
	.ascii "DEPTH"                            ; FC4336
	.byte 0x06, 0x05                             ; FC433B  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC433D
	.byte 0x06, 0x09                             ; FC4340  op 06, 9 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC4342
	.ascii "SPEED"                            ; FC4344
	.byte 0x06, 0x05                             ; FC4349  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC434B
	.byte 0x06, 0x08                             ; FC434E  op 06, 8 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC4350
	.ascii "WAVE"                             ; FC4352
	.byte 0x06, 0x05                             ; FC4356  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC4358
	.byte 0x06, 0x0B                             ; FC435B  op 06, 11 bytes, handler 0xF31A3A
	.byte 0x03, 0x12                        ; FC435D
	.ascii "BALANCE"                          ; FC435F
	.byte 0x06, 0x05                             ; FC4366  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x11, 0x12, 0x3A                  ; FC4368
	.byte 0x17, 0x0B                             ; FC436B  op 17, 11 bytes, handler 0xF31A52
	.byte 0x05, 0x00, 0xD1, 0x00            ; FC436D
	.ascii "DEPTH"                            ; FC4371
	.byte 0x17, 0x0B                             ; FC4376  op 17, 11 bytes, handler 0xF31A52
	.byte 0x2C, 0x00, 0xD1, 0x00            ; FC4378
	.ascii "SPEED"                            ; FC437C
	.byte 0x17, 0x0A                             ; FC4381  op 17, 10 bytes, handler 0xF31A52
	.byte 0x58, 0x00, 0xD1, 0x00            ; FC4383
	.ascii "WAVE"                             ; FC4387
	.byte 0x17, 0x0D                             ; FC438B  op 17, 13 bytes, handler 0xF31A52
	.byte 0x77, 0x00, 0xD1, 0x00            ; FC438D
	.ascii "BALANCE"                          ; FC4391
	.set DigitalEffect_ParamLabels_FC4332_End, . ; FC4398  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4398 -- display list, 12 record(s), 108 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4398 and land exactly on 0xFC4404.
DigitalEffect_ParamLabels_FC4398:
	.byte 0x06, 0x0A                             ; FC4398  op 06, 10 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC439A
	.ascii "DEPTH1"                           ; FC439C
	.byte 0x06, 0x05                             ; FC43A2  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC43A4
	.byte 0x06, 0x0A                             ; FC43A7  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC43A9
	.ascii "SPEED1"                           ; FC43AB
	.byte 0x06, 0x05                             ; FC43B1  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC43B3
	.byte 0x06, 0x0A                             ; FC43B6  op 06, 10 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC43B8
	.ascii "DEPTH2"                           ; FC43BA
	.byte 0x06, 0x05                             ; FC43C0  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC43C2
	.byte 0x06, 0x0A                             ; FC43C5  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x03, 0x12                        ; FC43C7
	.ascii "SPEED2"                           ; FC43C9
	.byte 0x06, 0x05                             ; FC43CF  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x11, 0x12, 0x3A                  ; FC43D1
	.byte 0x17, 0x0C                             ; FC43D4  op 17, 12 bytes, handler 0xF31A52
	.byte 0x02, 0x00, 0xD1, 0x00            ; FC43D6
	.ascii "DEPTH1"                           ; FC43DA
	.byte 0x17, 0x0C                             ; FC43E0  op 17, 12 bytes, handler 0xF31A52
	.byte 0x2A, 0x00, 0xD1, 0x00            ; FC43E2
	.ascii "SPEED1"                           ; FC43E6
	.byte 0x17, 0x0C                             ; FC43EC  op 17, 12 bytes, handler 0xF31A52
	.byte 0x52, 0x00, 0xD1, 0x00            ; FC43EE
	.ascii "DEPTH2"                           ; FC43F2
	.byte 0x17, 0x0C                             ; FC43F8  op 17, 12 bytes, handler 0xF31A52
	.byte 0x7A, 0x00, 0xD1, 0x00            ; FC43FA
	.ascii "SPEED2"                           ; FC43FE
	.set DigitalEffect_ParamLabels_FC4398_End, . ; FC4404  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4404 -- display list, 12 record(s), 108 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4404 and land exactly on 0xFC4470.
DigitalEffect_ParamLabels_FC4404:
	.byte 0x06, 0x09                             ; FC4404  op 06, 9 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC4406
	.ascii "DELAY"                            ; FC4408
	.byte 0x06, 0x05                             ; FC440D  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC440F
	.byte 0x06, 0x0A                             ; FC4412  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC4414
	.ascii "DETUNE"                           ; FC4416
	.byte 0x06, 0x05                             ; FC441C  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC441E
	.byte 0x06, 0x0D                             ; FC4421  op 06, 13 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC4423
	.ascii "KEY SHIFT"                        ; FC4425
	.byte 0x06, 0x05                             ; FC442E  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC4430
	.byte 0x06, 0x0B                             ; FC4433  op 06, 11 bytes, handler 0xF31A3A
	.byte 0x03, 0x12                        ; FC4435
	.ascii "BALANCE"                          ; FC4437
	.byte 0x06, 0x05                             ; FC443E  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x11, 0x12, 0x3A                  ; FC4440
	.byte 0x17, 0x0B                             ; FC4443  op 17, 11 bytes, handler 0xF31A52
	.byte 0x02, 0x00, 0xD1, 0x00            ; FC4445
	.ascii "DELAY"                            ; FC4449
	.byte 0x17, 0x0C                             ; FC444E  op 17, 12 bytes, handler 0xF31A52
	.byte 0x2A, 0x00, 0xD1, 0x00            ; FC4450
	.ascii "DETUNE"                           ; FC4454
	.byte 0x17, 0x09                             ; FC445A  op 17, 9 bytes, handler 0xF31A52
	.byte 0x5B, 0x00, 0xD1, 0x00            ; FC445C
	.ascii "KEY"                              ; FC4460
	.byte 0x17, 0x0D                             ; FC4463  op 17, 13 bytes, handler 0xF31A52
	.byte 0x78, 0x00, 0xD1, 0x00            ; FC4465
	.ascii "BALANCE"                          ; FC4469
	.set DigitalEffect_ParamLabels_FC4404_End, . ; FC4470  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC4470 -- display list, 12 record(s), 108 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC4470 and land exactly on 0xFC44DC.
DigitalEffect_ParamLabels_FC4470:
	.byte 0x06, 0x09                             ; FC4470  op 06, 9 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC4472
	.ascii "SPEED"                            ; FC4474
	.byte 0x06, 0x05                             ; FC4479  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC447B
	.byte 0x06, 0x09                             ; FC447E  op 06, 9 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC4480
	.ascii "DECAY"                            ; FC4482
	.byte 0x06, 0x05                             ; FC4487  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC4489
	.byte 0x06, 0x0B                             ; FC448C  op 06, 11 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC448E
	.ascii "SUSTAIN"                          ; FC4490
	.byte 0x06, 0x05                             ; FC4497  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC4499
	.byte 0x06, 0x0B                             ; FC449C  op 06, 11 bytes, handler 0xF31A3A
	.byte 0x03, 0x12                        ; FC449E
	.ascii "RELEASE"                          ; FC44A0
	.byte 0x06, 0x05                             ; FC44A7  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x11, 0x12, 0x3A                  ; FC44A9
	.byte 0x17, 0x0B                             ; FC44AC  op 17, 11 bytes, handler 0xF31A52
	.byte 0x04, 0x00, 0xD1, 0x00            ; FC44AE
	.ascii "SPEED"                            ; FC44B2
	.byte 0x17, 0x0B                             ; FC44B7  op 17, 11 bytes, handler 0xF31A52
	.byte 0x2D, 0x00, 0xD1, 0x00            ; FC44B9
	.ascii "DECAY"                            ; FC44BD
	.byte 0x17, 0x0D                             ; FC44C2  op 17, 13 bytes, handler 0xF31A52
	.byte 0x50, 0x00, 0xD1, 0x00            ; FC44C4
	.ascii "SUSTAIN"                          ; FC44C8
	.byte 0x17, 0x0D                             ; FC44CF  op 17, 13 bytes, handler 0xF31A52
	.byte 0x80, 0x00, 0xD1, 0x00            ; FC44D1
	.ascii "RELEASE"                          ; FC44D5
	.set DigitalEffect_ParamLabels_FC4470_End, . ; FC44DC  end marker: the byte after the last record

; DigitalEffect_ParamLabels_FC44DC -- display list, 9 record(s), 86 bytes, interpreter A
; Read by: SoundEditDigitalEffect_Paint (prom_b 0xF099F5) at 0xF09A2F, through DigitalEffect_ParamLabelLists[type].
; Framing: the length bytes walk from 0xFC44DC and land exactly on 0xFC4532.
DigitalEffect_ParamLabels_FC44DC:
	.byte 0x06, 0x0E                             ; FC44DC  op 06, 14 bytes, handler 0xF31A3A
	.byte 0xFB, 0x0A                        ; FC44DE
	.ascii "DISTORTION"                       ; FC44E0
	.byte 0x06, 0x05                             ; FC44EA  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x09, 0x0B, 0x3A                  ; FC44EC
	.byte 0x06, 0x0F                             ; FC44EF  op 06, 15 bytes, handler 0xF31A3A
	.byte 0x53, 0x0D                        ; FC44F1
	.ascii "TOUCH DEPTH"                      ; FC44F3
	.byte 0x06, 0x05                             ; FC44FE  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x61, 0x0D, 0x3A                  ; FC4500
	.byte 0x06, 0x09                             ; FC4503  op 06, 9 bytes, handler 0xF31A3A
	.byte 0xAB, 0x0F                        ; FC4505
	.ascii "DEPTH"                            ; FC4507
	.byte 0x06, 0x05                             ; FC450C  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xB9, 0x0F, 0x3A                  ; FC450E
	.byte 0x17, 0x0B                             ; FC4511  op 17, 11 bytes, handler 0xF31A52
	.byte 0x07, 0x00, 0xD1, 0x00            ; FC4513
	.ascii "DIST."                            ; FC4517
	.byte 0x17, 0x0B                             ; FC451C  op 17, 11 bytes, handler 0xF31A52
	.byte 0x2D, 0x00, 0xD1, 0x00            ; FC451E
	.ascii "TOUCH"                            ; FC4522
	.byte 0x17, 0x0B                             ; FC4527  op 17, 11 bytes, handler 0xF31A52
	.byte 0x55, 0x00, 0xD1, 0x00            ; FC4529
	.ascii "DEPTH"                            ; FC452D
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
	.byte 0x02, 0x0F                             ; FC4592  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A6                              ; FC4594  variable
	.byte 0x0F, 0x00, 0x20                     ; FC4596  mask, shift, +6
	.long DigitalEffect_TypeNames               ; FC4599  string table
	.short 13, 0x0809                        ; FC459D  entry width, +0x0D
; SoundEditDigitalEffect_RepaintField_DL -- a record (op 02, 15 bytes) inside DigitalEffect_Values,
;          an inner entry point or end named in the list's Read-by line
SoundEditDigitalEffect_RepaintField_DL:
; ; drawn (start operand) by SoundEditDigitalEffect_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F                             ; FC45A1  op 02, 15 bytes, handler 0xF31B21
	.byte 0xA6, 0x27, 0x80, 0x07, 0x20, 0xD8, 0x34, 0xF0, 0x00, 0x03, 0x00, 0xBA, 0x0B ; FC45A3
; DLRec_FC45B0 -- a record (op 02, 15 bytes) inside DigitalEffect_Values,
;          an inner entry point or end named in the list's Read-by line
DLRec_FC45B0:
	.byte 0x02, 0x0F                             ; FC45B0  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A6                              ; FC45B2  variable
	.byte 0x40, 0x06, 0x20                     ; FC45B4  mask, shift, +6
	.long DigitalEffect_OutputNames             ; FC45B7  string table
	.short 6, 0x11AA                        ; FC45BB  entry width, +0x0D
; DLRec_FC45BF -- a record (op 05, 11 bytes) inside DigitalEffect_Values,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[8]
DLRec_FC45BF:
	.byte 0x05, 0x0B                             ; FC45BF  op 05, 11 bytes, handler 0xF31BD7
	.byte 0xAE, 0x27, 0xFF, 0x00            ; FC45C1
	.ascii " s"                               ; FC45C5
	.byte 0x1B, 0x02, 0x00                  ; FC45C7
; DLRec_FC45CA -- a record (op 05, 11 bytes) inside DigitalEffect_Values,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[7]
DLRec_FC45CA:
	.byte 0x05, 0x0B                             ; FC45CA  op 05, 11 bytes, handler 0xF31BD7
	.byte 0xAD, 0x27, 0xFF, 0x00, 0x20, 0x1B, 0x19, 0x02, 0x00 ; FC45CC
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
	.byte 0x00, 0x0A                             ; FC4635  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA7, 0x27, 0xFF, 0x00, 0x20, 0x0C, 0x0B, 0x02 ; FC4637
; DLRec_FC463F -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[2]
DLRec_FC463F:
	.byte 0x00, 0x0A                             ; FC463F  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA8, 0x27, 0xFF, 0x00            ; FC4641
	.ascii " d"                               ; FC4645
	.byte 0x0D, 0x02                        ; FC4647
; DLRec_FC4649 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[3]
DLRec_FC4649:
	.byte 0x05, 0x0B                             ; FC4649  op 05, 11 bytes, handler 0xF31BD7
	.byte 0xA9, 0x27, 0xFF, 0x00, 0x20, 0xBB, 0x0F, 0x02, 0x00 ; FC464B
; DLRec_FC4654 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[4]
DLRec_FC4654:
	.byte 0x00, 0x0A                             ; FC4654  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAA, 0x27, 0xFF, 0x00, 0x20, 0x14, 0x12, 0x02 ; FC4656
; DLRec_FC465E -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4635,
;          pointed at by DigitalEffect_FieldRecords_FC4668[5]
DLRec_FC465E:
	.byte 0x00, 0x0A                             ; FC465E  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAB, 0x27, 0xFF, 0x00            ; FC4660
	.ascii " k"                               ; FC4664
	.byte 0x14, 0x03                        ; FC4666
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
	.byte 0x00, 0x0A                             ; FC4680  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA7, 0x27, 0xFF, 0x00, 0x20, 0x0C, 0x0B, 0x02 ; FC4682
; DLRec_FC468A -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[2]
DLRec_FC468A:
	.byte 0x00, 0x0A                             ; FC468A  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA8, 0x27, 0xFF, 0x00            ; FC468C
	.ascii " d"                               ; FC4690
	.byte 0x0D, 0x02                        ; FC4692
; DLRec_FC4694 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[3]
DLRec_FC4694:
	.byte 0x00, 0x0A                             ; FC4694  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA9, 0x27, 0xFF, 0x00, 0x20, 0xBC, 0x0F, 0x02 ; FC4696
; DLRec_FC469E -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[4]
DLRec_FC469E:
	.byte 0x00, 0x0A                             ; FC469E  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAA, 0x27, 0xFF, 0x00, 0x20, 0x14, 0x12, 0x02 ; FC46A0
; DLRec_FC46A8 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[5]
DLRec_FC46A8:
	.byte 0x05, 0x0B                             ; FC46A8  op 05, 11 bytes, handler 0xF31BD7
	.byte 0xAB, 0x27, 0xFF, 0x00            ; FC46AA
	.ascii " k"                               ; FC46AE
	.byte 0x14, 0x02, 0x00                  ; FC46B0
; DLRec_FC46B3 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4680,
;          pointed at by DigitalEffect_FieldRecords_FC46BD[6]
DLRec_FC46B3:
	.byte 0x00, 0x0A                             ; FC46B3  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAC, 0x27, 0xFF, 0x00, 0x20, 0xC4, 0x16, 0x02 ; FC46B5
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
	.byte 0x00, 0x0A                             ; FC46E1  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA7, 0x27, 0xFF, 0x00, 0x20, 0x0C, 0x0B, 0x02 ; FC46E3
; DLRec_FC46EB -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC46E1,
;          pointed at by DigitalEffect_FieldRecords_FC470E[2]
DLRec_FC46EB:
	.byte 0x00, 0x0A                             ; FC46EB  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA8, 0x27, 0xFF, 0x00            ; FC46ED
	.ascii " d"                               ; FC46F1
	.byte 0x0D, 0x02                        ; FC46F3
; DLRec_FC46F5 -- a record (op 02, 15 bytes) inside DigitalEffect_ParamValues_FC46E1,
;          pointed at by DigitalEffect_FieldRecords_FC470E[3]
DLRec_FC46F5:
	.byte 0x02, 0x0F                             ; FC46F5  op 02, 15 bytes, handler 0xF31B21
	.byte 0xA9, 0x27, 0x0F, 0x00            ; FC46F7
	.ascii " iT"                              ; FC46FB
	.byte 0xF0, 0x00, 0x03, 0x00, 0xBB, 0x0F ; FC46FE
; DLRec_FC4704 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC46E1,
;          pointed at by DigitalEffect_FieldRecords_FC470E[4]
DLRec_FC4704:
	.byte 0x00, 0x0A                             ; FC4704  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAA, 0x27, 0xFF, 0x00, 0x20, 0x13, 0x12, 0x03 ; FC4706
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
	.byte 0x00, 0x0A                             ; FC4722  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA7, 0x27, 0xFF, 0x00, 0x20, 0x0C, 0x0B, 0x02 ; FC4724
; DLRec_FC472C -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4722,
;          pointed at by DigitalEffect_FieldRecords_FC474A[2]
DLRec_FC472C:
	.byte 0x00, 0x0A                             ; FC472C  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA8, 0x27, 0xFF, 0x00            ; FC472E
	.ascii " d"                               ; FC4732
	.byte 0x0D, 0x02                        ; FC4734
; DLRec_FC4736 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4722,
;          pointed at by DigitalEffect_FieldRecords_FC474A[3]
DLRec_FC4736:
	.byte 0x00, 0x0A                             ; FC4736  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA9, 0x27, 0xFF, 0x00, 0x20, 0xBC, 0x0F, 0x02 ; FC4738
; DLRec_FC4740 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC4722,
;          pointed at by DigitalEffect_FieldRecords_FC474A[4]
DLRec_FC4740:
	.byte 0x00, 0x0A                             ; FC4740  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAA, 0x27, 0xFF, 0x00, 0x20, 0x14, 0x12, 0x02 ; FC4742
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
	.byte 0x00, 0x0A                             ; FC475E  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA7, 0x27, 0xFF, 0x00, 0x20, 0x0C, 0x0B, 0x02 ; FC4760
; DLRec_FC4768 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC475E,
;          pointed at by DigitalEffect_FieldRecords_FC4788[2]
DLRec_FC4768:
	.byte 0x05, 0x0B                             ; FC4768  op 05, 11 bytes, handler 0xF31BD7
	.byte 0xA8, 0x27, 0xFF, 0x00            ; FC476A
	.ascii " c"                               ; FC476E
	.byte 0x0D, 0x02, 0x00                  ; FC4770
; DLRec_FC4773 -- a record (op 05, 11 bytes) inside DigitalEffect_ParamValues_FC475E,
;          pointed at by DigitalEffect_FieldRecords_FC4788[3]
DLRec_FC4773:
	.byte 0x05, 0x0B                             ; FC4773  op 05, 11 bytes, handler 0xF31BD7
	.byte 0xA9, 0x27, 0xFF, 0x00, 0x20, 0xBB, 0x0F, 0x02, 0x00 ; FC4775
; DLRec_FC477E -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC475E,
;          pointed at by DigitalEffect_FieldRecords_FC4788[4]
DLRec_FC477E:
	.byte 0x00, 0x0A                             ; FC477E  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xAA, 0x27, 0xFF, 0x00, 0x20, 0x13, 0x12, 0x03 ; FC4780
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
	.byte 0x02, 0x0F                             ; FC479C  op 02, 15 bytes, handler 0xF31B21
	.byte 0xA7, 0x27, 0x01, 0x00, 0x20, 0xD2, 0x34, 0xF0, 0x00, 0x03, 0x00, 0x0B, 0x0B ; FC479E
; DLRec_FC47AB -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC479C,
;          pointed at by DigitalEffect_FieldRecords_FC47BF[2]
DLRec_FC47AB:
	.byte 0x00, 0x0A                             ; FC47AB  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA8, 0x27, 0xFF, 0x00            ; FC47AD
	.ascii " d"                               ; FC47B1
	.byte 0x0D, 0x02                        ; FC47B3
; DLRec_FC47B5 -- a record (op 00, 10 bytes) inside DigitalEffect_ParamValues_FC479C,
;          pointed at by DigitalEffect_FieldRecords_FC47BF[3]
DLRec_FC47B5:
	.byte 0x00, 0x0A                             ; FC47B5  op 00, 10 bytes, handler 0xF31BA1
	.byte 0xA9, 0x27, 0xFF, 0x00, 0x20, 0xBB, 0x0F, 0x03 ; FC47B7
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
; The `.byte` rows are checked against images/Widget_*.png by
; `python3 scripts/build/wsa1_bitmaps.py check` (lane IMAGE, 2026-09-02, which
; first showed this; see notes/FINDINGS-image-files.md section 4).  One row
; per 15-byte column below.
; Drawn, they are (lane IMAGE's reading): a flat bar, a cylinder, tapered
; wedges, a parallelogram, a spool, an arrow, a bolt.
; Widget_FC48D7 -- widget 0: read through PtrTable_F09B7B[0] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC48D7.png
Widget_FC48D7:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x20, 0x50, 0x88, 0x88, 0xf8, 0x00, 0x00, 0x00  ; FC48D7
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC48E6
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC48F5
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4904
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4913
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0x04, 0x0a, 0x11, 0x11, 0x1f, 0x00, 0x00, 0x00  ; FC4922
; Widget_FC4931 -- widget 1: read through PtrTable_F09B7B[1] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4931.png
Widget_FC4931:
	.byte 0x00, 0x00, 0x3f, 0x40, 0x40, 0x80, 0x80, 0x80, 0x80, 0xd5, 0x6a, 0x7f, 0x3f, 0x00, 0x00  ; FC4931
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xff, 0xff, 0x00, 0x00  ; FC4940
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xff, 0xff, 0x00, 0x00  ; FC494F
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xff, 0xff, 0x00, 0x00  ; FC495E
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xff, 0xff, 0x00, 0x00  ; FC496D
	.byte 0x00, 0x00, 0xf8, 0x14, 0x14, 0x22, 0x22, 0x22, 0x22, 0x62, 0xb4, 0xf4, 0xf8, 0x00, 0x00  ; FC497C
; Widget_FC498B -- widget 2: read through PtrTable_F09B7B[2] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC498B.png
Widget_FC498B:
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0x80, 0x80, 0xd5, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC498B
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x55, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC499A
	.byte 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00  ; FC49A9
	.byte 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00  ; FC49B8
	.byte 0x00, 0x00, 0x1f, 0xe0, 0x00, 0x00, 0x00, 0x55, 0xaa, 0xf5, 0xff, 0x1f, 0x00, 0x00, 0x00  ; FC49C7
	.byte 0x06, 0x3a, 0xc2, 0x02, 0x02, 0x02, 0x02, 0x56, 0xaa, 0x56, 0xaa, 0xfe, 0x7e, 0x06, 0x00  ; FC49D6
; Widget_FC49E5 -- widget 3: read through PtrTable_F09B7B[3] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC49E5.png
Widget_FC49E5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x80, 0x80, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC49E5
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC49F4
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4A03
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4A12
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0xfe, 0x00, 0x00, 0xff, 0xff, 0x01, 0x00, 0x00, 0x00, 0x00  ; FC4A21
	.byte 0x02, 0x06, 0x0a, 0x32, 0xc2, 0x02, 0x02, 0x02, 0xfa, 0x86, 0xf2, 0x3e, 0x0e, 0x06, 0x02  ; FC4A30
; Widget_FC4A3F -- widget 4: read through PtrTable_F09B7B[4] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4A3F.png
Widget_FC4A3F:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x03  ; FC4A3F
	.byte 0x0f, 0x11, 0x18, 0x24, 0x22, 0x41, 0x40, 0x80, 0xc0, 0x20, 0x10, 0x08, 0xff, 0xff, 0xff  ; FC4A4E
	.byte 0xff, 0x00, 0x80, 0x40, 0x20, 0x10, 0x88, 0x44, 0x22, 0x11, 0x08, 0x04, 0xff, 0xff, 0xff  ; FC4A5D
	.byte 0xff, 0x48, 0x24, 0x12, 0x09, 0x04, 0x02, 0x01, 0x00, 0x00, 0x80, 0x40, 0xff, 0xff, 0xff  ; FC4A6C
	.byte 0xff, 0x01, 0x01, 0x03, 0x03, 0x87, 0x47, 0x2e, 0x9e, 0x5c, 0x3c, 0x38, 0xf8, 0xf0, 0xf0  ; FC4A7B
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4A8A
; Widget_FC4A99 -- widget 5: read through PtrTable_F09B7B[5] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4A99.png
Widget_FC4A99:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4A99
	.byte 0x00, 0x07, 0x08, 0x08, 0x0f, 0x08, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x08, 0x07, 0x00  ; FC4AA8
	.byte 0x7f, 0x80, 0x00, 0x00, 0x80, 0x7f, 0x80, 0x7f, 0x68, 0x68, 0x68, 0xe8, 0x7f, 0x80, 0x7f  ; FC4AB7
	.byte 0xfe, 0x01, 0x00, 0x00, 0x01, 0xfe, 0x01, 0xff, 0x05, 0x05, 0x05, 0x05, 0xfe, 0x01, 0xfe  ; FC4AC6
	.byte 0x00, 0xe0, 0x10, 0x10, 0xf0, 0x10, 0xf0, 0x70, 0x70, 0x70, 0x70, 0xf0, 0x10, 0xe0, 0x00  ; FC4AD5
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4AE4
; Widget_FC4AF3 -- widget 6: read through PtrTable_F09B7B[6] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4AF3.png
Widget_FC4AF3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x3f, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4AF3
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4B02
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4B11
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4B20
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4B2F
	.byte 0x00, 0x00, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xf8, 0xf0, 0xe0, 0xc0, 0x80, 0x00, 0x00  ; FC4B3E
; Widget_FC4B4D -- widget 7: read through PtrTable_F09B7B[7] (prom_b 0xF09B7B),
;          48x15 pixels, 6 columns x 15 bytes; images/Widget_FC4B4D.png
Widget_FC4B4D:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06, 0x07, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4B4D
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb5, 0xb5, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00  ; FC4B5C
	.byte 0xf9, 0xff, 0xf3, 0xf1, 0xf4, 0xf6, 0x77, 0x74, 0xf7, 0xf7, 0xf5, 0xf4, 0x74, 0x34, 0x1c  ; FC4B6B
	.byte 0xf8, 0xfc, 0xc4, 0x94, 0x34, 0x74, 0xf7, 0x14, 0xf7, 0xf7, 0xf4, 0xf4, 0x74, 0x34, 0x1c  ; FC4B7A
	.byte 0x00, 0x00, 0x00, 0x01, 0x03, 0x06, 0xfd, 0x03, 0xff, 0xff, 0x07, 0x03, 0x01, 0x00, 0x00  ; FC4B89
	.byte 0x00, 0x00, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00  ; FC4B98

; SoundEditCopy_Frame -- display list, 51 record(s), 464 bytes, interpreter A
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BA0; text COPY, SOUND EDIT, FROM, TO, TONE:, OPTION.
; Framing: the length bytes walk from 0xFC4BA7 and land exactly on 0xFC4D77.
SoundEditCopy_Frame:
	.byte 0x1C, 0x0A                             ; FC4BA7  op 1C, 10 bytes, handler 0xF31A52
	.byte 0x87, 0x00, 0x04, 0x00            ; FC4BA9
	.ascii "COPY"                             ; FC4BAD
	.byte 0x17, 0x10                             ; FC4BB1  op 17, 16 bytes, handler 0xF31A52
	.byte 0x06, 0x00, 0x07, 0x00            ; FC4BB3
	.ascii "SOUND EDIT"                       ; FC4BB7
	.byte 0x1C, 0x0A                             ; FC4BC1  op 1C, 10 bytes, handler 0xF31A52
	.byte 0x37, 0x00, 0x1F, 0x00            ; FC4BC3
	.ascii "FROM"                             ; FC4BC7
	.byte 0x1C, 0x08                             ; FC4BCB  op 1C, 8 bytes, handler 0xF31A52
	.byte 0xE9, 0x00, 0x1F, 0x00            ; FC4BCD
	.ascii "TO"                               ; FC4BD1
	.byte 0x20, 0x09                             ; FC4BD3  op 20, 9 bytes, handler 0xF31A3A
	.byte 0x12, 0x13                        ; FC4BD5
	.ascii "TONE:"                            ; FC4BD7
	.byte 0x20, 0x0A                             ; FC4BDC  op 20, 10 bytes, handler 0xF31A3A
	.byte 0x80, 0x17                        ; FC4BDE
	.ascii "OPTION"                           ; FC4BE0
	.byte 0x06, 0x0A                             ; FC4BE6  op 06, 10 bytes, handler 0xF31A3A
	.byte 0x32, 0x18                        ; FC4BE8
	.ascii "COPY "                            ; FC4BEA
	.byte 0x11                              ; FC4BEF
	.byte 0x17, 0x0A                             ; FC4BF0  op 17, 10 bytes, handler 0xF31A52
	.byte 0x28, 0x00, 0xC4, 0x00            ; FC4BF2
	.ascii "FROM"                             ; FC4BF6
	.byte 0x17, 0x0B                             ; FC4BFA  op 17, 11 bytes, handler 0xF31A52
	.byte 0x25, 0x00, 0xD1, 0x00            ; FC4BFC
	.ascii "SOUND"                            ; FC4C00
	.byte 0x17, 0x0A                             ; FC4C05  op 17, 10 bytes, handler 0xF31A52
	.byte 0x4F, 0x00, 0xD1, 0x00            ; FC4C07
	.ascii "TONE"                             ; FC4C0B
	.byte 0x17, 0x0C                             ; FC4C0F  op 17, 12 bytes, handler 0xF31A52
	.byte 0x7A, 0x00, 0xD1, 0x00            ; FC4C11
	.ascii "OPTION"                           ; FC4C15
	.byte 0x17, 0x08                             ; FC4C1B  op 17, 8 bytes, handler 0xF31A52
	.byte 0xD5, 0x00, 0xD1, 0x00            ; FC4C1D
	.ascii "TO"                               ; FC4C21
	.byte 0x06, 0x05                             ; FC4C23  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xE9, 0x21, 0x8D                  ; FC4C25
	.byte 0x06, 0x05                             ; FC4C28  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xEE, 0x21, 0x8D                  ; FC4C2A
	.byte 0x06, 0x05                             ; FC4C2D  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xF3, 0x21, 0x8D                  ; FC4C2F
	.byte 0x06, 0x05                             ; FC4C32  op 06, 5 bytes, handler 0xF31A3A
	.byte 0xF9, 0x21, 0x8D                  ; FC4C34
	.byte 0x06, 0x05                             ; FC4C37  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x03, 0x22, 0x8D                  ; FC4C39
	.byte 0x06, 0x05                             ; FC4C3C  op 06, 5 bytes, handler 0xF31A3A
	.ascii "y#"                               ; FC4C3E
	.byte 0x8E                              ; FC4C40
	.byte 0x06, 0x05                             ; FC4C41  op 06, 5 bytes, handler 0xF31A3A
	.ascii "~#"                               ; FC4C43
	.byte 0x8E                              ; FC4C45
	.byte 0x06, 0x05                             ; FC4C46  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x83, 0x23, 0x8E                  ; FC4C48
	.byte 0x06, 0x05                             ; FC4C4B  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x89, 0x23, 0x8E                  ; FC4C4D
	.byte 0x06, 0x05                             ; FC4C50  op 06, 5 bytes, handler 0xF31A3A
	.byte 0x93, 0x23, 0x8E                  ; FC4C52
	.byte 0x09, 0x0A                             ; FC4C55  op 09, 10 bytes, handler 0xF31A75
	.byte 0x04, 0x00, 0x04, 0x00, 0x44, 0x00, 0x10, 0x00 ; FC4C57
	.byte 0x22, 0x0A                             ; FC4C5F  op 22, 10 bytes, handler 0xF31A75
	.byte 0x08, 0x00, 0x30, 0x00, 0xA7, 0x00, 0x8A, 0x00 ; FC4C61
	.byte 0x22, 0x0A                             ; FC4C69  op 22, 10 bytes, handler 0xF31A75
	.byte 0xC5, 0x00, 0x30, 0x00, 0x32, 0x01, 0x8A, 0x00 ; FC4C6B
	.byte 0x22, 0x0A                             ; FC4C73  op 22, 10 bytes, handler 0xF31A75
	.byte 0x57, 0x00, 0xA3, 0x00, 0xDF, 0x00, 0xBD, 0x00 ; FC4C75
	.byte 0x09, 0x0A                             ; FC4C7D  op 09, 10 bytes, handler 0xF31A75
	.byte 0x0A, 0x01, 0x95, 0x00, 0x35, 0x01, 0xA8, 0x00 ; FC4C7F
	.byte 0x09, 0x0A                             ; FC4C87  op 09, 10 bytes, handler 0xF31A75
	.byte 0x0C, 0x01, 0x97, 0x00, 0x33, 0x01, 0xA6, 0x00 ; FC4C89
	.byte 0x22, 0x0A                             ; FC4C91  op 22, 10 bytes, handler 0xF31A75
	.byte 0x01, 0x00, 0xDA, 0x00, 0x16, 0x00, 0xEE, 0x00 ; FC4C93
	.byte 0x22, 0x0A                             ; FC4C9B  op 22, 10 bytes, handler 0xF31A75
	.byte 0x29, 0x00, 0xDA, 0x00, 0x3E, 0x00, 0xEE, 0x00 ; FC4C9D
	.byte 0x22, 0x0A                             ; FC4CA5  op 22, 10 bytes, handler 0xF31A75
	.byte 0x51, 0x00, 0xDA, 0x00, 0x66, 0x00, 0xEE, 0x00 ; FC4CA7
	.byte 0x22, 0x0A                             ; FC4CAF  op 22, 10 bytes, handler 0xF31A75
	.byte 0x81, 0x00, 0xDA, 0x00, 0x96, 0x00, 0xEE, 0x00 ; FC4CB1
	.byte 0x22, 0x0A                             ; FC4CB9  op 22, 10 bytes, handler 0xF31A75
	.byte 0xD1, 0x00, 0xDA, 0x00, 0xE6, 0x00, 0xEE, 0x00 ; FC4CBB
	.byte 0x01, 0x0A                             ; FC4CC3  op 01, 10 bytes, handler 0xF31A75
	.byte 0x02, 0x00, 0xC7, 0x00, 0x25, 0x00, 0xC7, 0x00 ; FC4CC5
	.byte 0x01, 0x0A                             ; FC4CCD  op 01, 10 bytes, handler 0xF31A75
	.byte 0x43, 0x00, 0xC7, 0x00, 0x67, 0x00, 0xC7, 0x00 ; FC4CCF
	.byte 0x01, 0x0A                             ; FC4CD7  op 01, 10 bytes, handler 0xF31A75
	.byte 0x01, 0x00, 0xE4, 0x00, 0x16, 0x00, 0xE4, 0x00 ; FC4CD9
	.byte 0x01, 0x0A                             ; FC4CE1  op 01, 10 bytes, handler 0xF31A75
	.byte 0x29, 0x00, 0xE4, 0x00, 0x3E, 0x00, 0xE4, 0x00 ; FC4CE3
	.byte 0x01, 0x0A                             ; FC4CEB  op 01, 10 bytes, handler 0xF31A75
	.byte 0x51, 0x00, 0xE4, 0x00, 0x66, 0x00, 0xE4, 0x00 ; FC4CED
	.byte 0x01, 0x0A                             ; FC4CF5  op 01, 10 bytes, handler 0xF31A75
	.byte 0x81, 0x00, 0xE4, 0x00, 0x96, 0x00, 0xE4, 0x00 ; FC4CF7
	.byte 0x01, 0x0A                             ; FC4CFF  op 01, 10 bytes, handler 0xF31A75
	.byte 0xD1, 0x00, 0xE4, 0x00, 0xE6, 0x00, 0xE4, 0x00 ; FC4D01
	.byte 0x02, 0x0A                             ; FC4D09  op 02, 10 bytes, handler 0xF31A75
	.byte 0x02, 0x00, 0xC7, 0x00, 0x02, 0x00, 0xCC, 0x00 ; FC4D0B
	.byte 0x02, 0x0A                             ; FC4D13  op 02, 10 bytes, handler 0xF31A75
	.byte 0x67, 0x00, 0xC7, 0x00, 0x67, 0x00, 0xCC, 0x00 ; FC4D15
	.byte 0x01, 0x0A                             ; FC4D1D  op 01, 10 bytes, handler 0xF31A75
	.byte 0xB0, 0x00, 0x57, 0x00, 0xB9, 0x00, 0x57, 0x00 ; FC4D1F
	.byte 0x01, 0x0A                             ; FC4D27  op 01, 10 bytes, handler 0xF31A75
	.byte 0xB0, 0x00, 0x5D, 0x00, 0xB9, 0x00, 0x5D, 0x00 ; FC4D29
	.byte 0x02, 0x0A                             ; FC4D31  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB0, 0x00, 0x57, 0x00, 0xB0, 0x00, 0x5D, 0x00 ; FC4D33
	.byte 0x02, 0x0A                             ; FC4D3B  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB9, 0x00, 0x54, 0x00, 0xB9, 0x00, 0x57, 0x00 ; FC4D3D
	.byte 0x02, 0x0A                             ; FC4D45  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB9, 0x00, 0x5D, 0x00, 0xB9, 0x00, 0x60, 0x00 ; FC4D47
	.byte 0x00, 0x0A                             ; FC4D4F  op 00, 10 bytes, handler 0xF31A75
	.byte 0xB9, 0x00, 0x54, 0x00, 0xBF, 0x00, 0x5A, 0x00 ; FC4D51
	.byte 0x00, 0x0A                             ; FC4D59  op 00, 10 bytes, handler 0xF31A75
	.byte 0xB9, 0x00, 0x60, 0x00, 0xBF, 0x00, 0x5A, 0x00 ; FC4D5B
	.byte 0x05, 0x0A                             ; FC4D63  op 05, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0x77, 0x00, 0x52, 0x00, 0x86, 0x00 ; FC4D65
	.byte 0x05, 0x0A                             ; FC4D6D  op 05, 10 bytes, handler 0xF31A75
	.byte 0x59, 0x00, 0xA5, 0x00, 0xDD, 0x00, 0xBB, 0x00 ; FC4D6F
	.set SoundEditCopy_Frame_End, .           ; FC4D77  end marker: the byte after the last record

; SoundEditCopy_ToneLabels -- display list, 11 record(s), 116 bytes, interpreter A
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BBA when (0x27F5) != 1; text BANK:, 1st..4th TONE, SOUND:.
; Framing: the length bytes walk from 0xFC4D77 and land exactly on 0xFC4DEB.
SoundEditCopy_ToneLabels:
	.byte 0x20, 0x09                             ; FC4D77  op 20, 9 bytes, handler 0xF31A3A
	.byte 0xEA, 0x08                        ; FC4D79
	.ascii "BANK:"                            ; FC4D7B
	.byte 0x20, 0x0C                             ; FC4D80  op 20, 12 bytes, handler 0xF31A3A
	.byte 0xB3, 0x08                        ; FC4D82
	.ascii "1st TONE"                         ; FC4D84
	.byte 0x20, 0x0C                             ; FC4D8C  op 20, 12 bytes, handler 0xF31A3A
	.byte 0x5B, 0x0B                        ; FC4D8E
	.ascii "2nd TONE"                         ; FC4D90
	.byte 0x20, 0x0A                             ; FC4D98  op 20, 10 bytes, handler 0xF31A3A
	.byte 0x82, 0x0C                        ; FC4D9A
	.ascii "SOUND:"                           ; FC4D9C
	.byte 0x20, 0x0C                             ; FC4DA2  op 20, 12 bytes, handler 0xF31A3A
	.byte 0x03, 0x0E                        ; FC4DA4
	.ascii "3rd TONE"                         ; FC4DA6
	.byte 0x20, 0x0C                             ; FC4DAE  op 20, 12 bytes, handler 0xF31A3A
	.byte 0x83, 0x10                        ; FC4DB0
	.ascii "4th TONE"                         ; FC4DB2
	.byte 0x20, 0x09                             ; FC4DBA  op 20, 9 bytes, handler 0xF31A3A
	.byte 0xA4, 0x13                        ; FC4DBC
	.ascii "SOUND"                            ; FC4DBE
	.byte 0x17, 0x0A                             ; FC4DC3  op 17, 10 bytes, handler 0xF31A52
	.byte 0x01, 0x00, 0xD1, 0x00            ; FC4DC5
	.ascii "BANK"                             ; FC4DC9
	.byte 0x01, 0x0A                             ; FC4DCD  op 01, 10 bytes, handler 0xF31A75
	.byte 0xC5, 0x00, 0x78, 0x00, 0x32, 0x01, 0x78, 0x00 ; FC4DCF
	.byte 0x05, 0x0A                             ; FC4DD7  op 05, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0x36, 0x00, 0x5A, 0x00, 0x45, 0x00 ; FC4DD9
	.byte 0x05, 0x0A                             ; FC4DE1  op 05, 10 bytes, handler 0xF31A75
	.byte 0x15, 0x00, 0x5B, 0x00, 0x9A, 0x00, 0x6A, 0x00 ; FC4DE3
	.set SoundEditCopy_ToneLabels_End, .      ; FC4DEB  end marker: the byte after the last record

; SoundEditCopy_DrumLabels -- display list, 9 record(s), 105 bytes, interpreter A
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BE2 when (0x27F5) == 1; text DRUM KIT:, 1st/2nd TONE, DRUM SOUND:.
; Framing: the length bytes walk from 0xFC4DEB and land exactly on 0xFC4E54.
SoundEditCopy_DrumLabels:
	.byte 0x20, 0x0D                             ; FC4DEB  op 20, 13 bytes, handler 0xF31A3A
	.byte 0x4A, 0x08                        ; FC4DED
	.ascii "DRUM KIT:"                        ; FC4DEF
	.byte 0x20, 0x0C                             ; FC4DF8  op 20, 12 bytes, handler 0xF31A3A
	.byte 0xA3, 0x09                        ; FC4DFA
	.ascii "1st TONE"                         ; FC4DFC
	.byte 0x20, 0x0C                             ; FC4E04  op 20, 12 bytes, handler 0xF31A3A
	.byte 0x8B, 0x0D                        ; FC4E06
	.ascii "2nd TONE"                         ; FC4E08
	.byte 0x20, 0x0F                             ; FC4E10  op 20, 15 bytes, handler 0xF31A3A
	.byte 0x9A, 0x0D                        ; FC4E12
	.ascii "DRUM SOUND:"                      ; FC4E14
	.byte 0x20, 0x0E                             ; FC4E1F  op 20, 14 bytes, handler 0xF31A3A
	.byte 0xDA, 0x12                        ; FC4E21
	.ascii "DRUM SOUND"                       ; FC4E23
	.byte 0x17, 0x09                             ; FC4E2D  op 17, 9 bytes, handler 0xF31A52
	.byte 0x03, 0x00, 0xD1, 0x00            ; FC4E2F
	.ascii "KIT"                              ; FC4E33
	.byte 0x01, 0x0A                             ; FC4E36  op 01, 10 bytes, handler 0xF31A75
	.byte 0xC6, 0x00, 0x6E, 0x00, 0x31, 0x01, 0x6E, 0x00 ; FC4E38
	.byte 0x05, 0x0A                             ; FC4E40  op 05, 10 bytes, handler 0xF31A75
	.byte 0x15, 0x00, 0x41, 0x00, 0x9B, 0x00, 0x50, 0x00 ; FC4E42
	.byte 0x05, 0x0A                             ; FC4E4A  op 05, 10 bytes, handler 0xF31A75
	.byte 0x25, 0x00, 0x62, 0x00, 0x95, 0x00, 0x71, 0x00 ; FC4E4C
	.set SoundEditCopy_DrumLabels_End, .      ; FC4E54  end marker: the byte after the last record

; SoundEditCopy_ToneValues -- display list, 4 record(s), 56 bytes, interpreter B
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BCD.
; Framing: the length bytes walk from 0xFC4E54 and land exactly on 0xFC4E8C.
SoundEditCopy_ToneValues:
	.byte 0x02, 0x0F                             ; FC4E54  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A6                              ; FC4E56  variable
	.byte 0x0F, 0x00, 0x20                     ; FC4E58  mask, shift, +6
	.long SoundEditCopy_OptionNames             ; FC4E5B  string table
	.short 10, 0x1AEE                        ; FC4E5F  entry width, +0x0D
; DLRec_FC4E63 -- a record (op 02, 15 bytes) inside SoundEditCopy_ToneValues,
;          pointed at by SoundEditCopy_ToneFieldRecords[1]
DLRec_FC4E63:
	.byte 0x02, 0x0F                             ; FC4E63  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A7                              ; FC4E65  variable
	.byte 0x0F, 0x00, 0x20                     ; FC4E67  mask, shift, +6
	.long SoundEditCopy_ToneOrdinals            ; FC4E6A  string table
	.short 3, 0x1317                        ; FC4E6E  entry width, +0x0D
; DLRec_FC4E72 -- a record (op 02, 15 bytes) inside SoundEditCopy_ToneValues,
;          pointed at by SoundEditCopy_ToneFieldRecords[3]
DLRec_FC4E72:
	.byte 0x02, 0x0F                             ; FC4E72  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A9                              ; FC4E74  variable
	.byte 0x0F, 0x00, 0x20                     ; FC4E76  mask, shift, +6
	.long SoundEditCopy_ToneBankNames           ; FC4E79  string table
	.short 4, 0x08EF                        ; FC4E7D  entry width, +0x0D
; DLRec_FC4E81 -- a record (op 03, 11 bytes) inside SoundEditCopy_ToneValues,
;          pointed at by SoundEditCopy_ToneFieldRecords[2]
DLRec_FC4E81:
	.byte 0x03, 0x0B                             ; FC4E81  op 03, 11 bytes, handler 0xF31B57
	.short 0x27A8                              ; FC4E83  variable
	.byte 0x0F, 0x00, 0x05                     ; FC4E85  mask, shift, +6
	.long SoundEditCopy_ToneOptionRects         ; FC4E88  8-byte entries
	.set SoundEditCopy_ToneValues_End, .      ; FC4E8C  end marker: the byte after the last record

; SoundEditCopy_DrumValues -- display list, 4 record(s), 56 bytes, interpreter B
; Read by: SoundEditCopy_Paint (prom_b 0xF09B9B) at 0xF09BF5.
; Framing: the length bytes walk from 0xFC4E8C and land exactly on 0xFC4EC4.
SoundEditCopy_DrumValues:
	.byte 0x02, 0x0F                             ; FC4E8C  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A6                              ; FC4E8E  variable
	.byte 0x0F, 0x00, 0x20                     ; FC4E90  mask, shift, +6
	.long SoundEditCopy_OptionNames             ; FC4E93  string table
	.short 10, 0x1AEE                        ; FC4E97  entry width, +0x0D
; DLRec_FC4E9B -- a record (op 02, 15 bytes) inside SoundEditCopy_DrumValues,
;          pointed at by SoundEditCopy_DrumFieldRecords[1]
DLRec_FC4E9B:
	.byte 0x02, 0x0F                             ; FC4E9B  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A7                              ; FC4E9D  variable
	.byte 0x0F, 0x00, 0x20                     ; FC4E9F  mask, shift, +6
	.long SoundEditCopy_DrumOrdinals            ; FC4EA2  string table
	.short 3, 0x1317                        ; FC4EA6  entry width, +0x0D
; DLRec_FC4EAA -- a record (op 02, 15 bytes) inside SoundEditCopy_DrumValues,
;          pointed at by SoundEditCopy_DrumFieldRecords[3]
DLRec_FC4EAA:
	.byte 0x02, 0x0F                             ; FC4EAA  op 02, 15 bytes, handler 0xF31B21
	.short 0x27A9                              ; FC4EAC  variable
	.byte 0x03, 0x00, 0x20                     ; FC4EAE  mask, shift, +6
	.long SoundEditCopy_DrumBankNames           ; FC4EB1  string table
	.short 4, 0x0853                        ; FC4EB5  entry width, +0x0D
; DLRec_FC4EB9 -- a record (op 03, 11 bytes) inside SoundEditCopy_DrumValues,
;          pointed at by SoundEditCopy_DrumFieldRecords[2]
DLRec_FC4EB9:
	.byte 0x03, 0x0B                             ; FC4EB9  op 03, 11 bytes, handler 0xF31B57
	.short 0x27A8                              ; FC4EBB  variable
	.byte 0x0F, 0x00, 0x05                     ; FC4EBD  mask, shift, +6
	.long SoundEditCopy_DrumOptionRects         ; FC4EC0  8-byte entries
	.set SoundEditCopy_DrumValues_End, .      ; FC4EC4  end marker: the byte after the last record

; SoundEditCopy_Field5Values -- display list, 2 record(s), 30 bytes, interpreter B
; Read by: SoundEditCopy_RepaintField (prom_b 0xF09C08) at 0xF09C36 (field 5).
; Framing: the length bytes walk from 0xFC4EC4 and land exactly on 0xFC4EE2.
SoundEditCopy_Field5Values:
	.byte 0x02, 0x0F                             ; FC4EC4  op 02, 15 bytes, handler 0xF31B21
	.byte 0xAB, 0x27, 0x7F, 0x00, 0x06      ; FC4EC6
	.ascii "`["                               ; FC4ECB
	.byte 0xF0, 0x00, 0x03, 0x00, 0xA5, 0x0D ; FC4ECD
	.byte 0x02, 0x0F                             ; FC4ED3  op 02, 15 bytes, handler 0xF31B21
	.byte 0x00, 0x00, 0x00, 0x00, 0x20, 0xF0, 0x22, 0x00, 0x00, 0x0D, 0x00, 0xCD, 0x0F ; FC4ED5
	.set SoundEditCopy_Field5Values_End, .    ; FC4EE2  end marker: the byte after the last record

; SoundEditCopy_Field2Box -- display list, 1 record(s), 10 bytes, interpreter A
; Read by: SoundEditCopy_RepaintField (prom_b 0xF09C08) at 0xF09C19 (field 2, layer 1).
; Framing: the length bytes walk from 0xFC4EE2 and land exactly on 0xFC4EEC.
SoundEditCopy_Field2Box:
	.byte 0x1B, 0x0A                             ; FC4EE2  op 1B, 10 bytes, handler 0xF31A75
	.byte 0xCD, 0x00, 0x34, 0x00, 0x2A, 0x01, 0x88, 0x00 ; FC4EE4
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
	.byte 0x02, 0x0A                             ; FC4FC6  op 02, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0x5A, 0x00, 0x35, 0x00, 0x5B, 0x00 ; FC4FC8
	.byte 0x01, 0x0A                             ; FC4FD0  op 01, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0x5B, 0x00, 0xB6, 0x00, 0x5B, 0x00 ; FC4FD2
	.byte 0x02, 0x0A                             ; FC4FDA  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB6, 0x00, 0x46, 0x00, 0xB6, 0x00, 0x5B, 0x00 ; FC4FDC
	.set DisplayList_FC4FC6_End, .            ; FC4FE4  end marker: the byte after the last record

; DisplayList_FC4FE4 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC4FE4 and land exactly on 0xFC5002.
DisplayList_FC4FE4:
	.byte 0x02, 0x0A                             ; FC4FE4  op 02, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0x5C, 0x00, 0x36, 0x00, 0x5D, 0x00 ; FC4FE6
	.byte 0x01, 0x0A                             ; FC4FEE  op 01, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0x5D, 0x00, 0xB7, 0x00, 0x5D, 0x00 ; FC4FF0
	.byte 0x02, 0x0A                             ; FC4FF8  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB7, 0x00, 0x48, 0x00, 0xB7, 0x00, 0x5D, 0x00 ; FC4FFA
	.set DisplayList_FC4FE4_End, .            ; FC5002  end marker: the byte after the last record

; DisplayList_FC5002 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5002 and land exactly on 0xFC5020.
DisplayList_FC5002:
	.byte 0x02, 0x0A                             ; FC5002  op 02, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0x5E, 0x00, 0x37, 0x00, 0x5F, 0x00 ; FC5004
	.byte 0x01, 0x0A                             ; FC500C  op 01, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0x5F, 0x00, 0xB8, 0x00, 0x5F, 0x00 ; FC500E
	.byte 0x02, 0x0A                             ; FC5016  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB8, 0x00, 0x4A, 0x00, 0xB8, 0x00, 0x5F, 0x00 ; FC5018
	.set DisplayList_FC5002_End, .            ; FC5020  end marker: the byte after the last record

; DisplayList_FC5020 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5020 and land exactly on 0xFC503E.
DisplayList_FC5020:
	.byte 0x02, 0x0A                             ; FC5020  op 02, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0x7F, 0x00, 0x35, 0x00, 0x80, 0x00 ; FC5022
	.byte 0x01, 0x0A                             ; FC502A  op 01, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0x80, 0x00, 0xB6, 0x00, 0x80, 0x00 ; FC502C
	.byte 0x02, 0x0A                             ; FC5034  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB6, 0x00, 0x6B, 0x00, 0xB6, 0x00, 0x80, 0x00 ; FC5036
	.set DisplayList_FC5020_End, .            ; FC503E  end marker: the byte after the last record

; DisplayList_FC503E -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC503E and land exactly on 0xFC505C.
DisplayList_FC503E:
	.byte 0x02, 0x0A                             ; FC503E  op 02, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0x81, 0x00, 0x36, 0x00, 0x82, 0x00 ; FC5040
	.byte 0x01, 0x0A                             ; FC5048  op 01, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0x82, 0x00, 0xB7, 0x00, 0x82, 0x00 ; FC504A
	.byte 0x02, 0x0A                             ; FC5052  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB7, 0x00, 0x6D, 0x00, 0xB7, 0x00, 0x82, 0x00 ; FC5054
	.set DisplayList_FC503E_End, .            ; FC505C  end marker: the byte after the last record

; DisplayList_FC505C -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC505C and land exactly on 0xFC507A.
DisplayList_FC505C:
	.byte 0x02, 0x0A                             ; FC505C  op 02, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0x83, 0x00, 0x37, 0x00, 0x84, 0x00 ; FC505E
	.byte 0x01, 0x0A                             ; FC5066  op 01, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0x84, 0x00, 0xB8, 0x00, 0x84, 0x00 ; FC5068
	.byte 0x02, 0x0A                             ; FC5070  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB8, 0x00, 0x6F, 0x00, 0xB8, 0x00, 0x84, 0x00 ; FC5072
	.set DisplayList_FC505C_End, .            ; FC507A  end marker: the byte after the last record

; DisplayList_FC507A -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC507A and land exactly on 0xFC5098.
DisplayList_FC507A:
	.byte 0x02, 0x0A                             ; FC507A  op 02, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0xA4, 0x00, 0x35, 0x00, 0xA5, 0x00 ; FC507C
	.byte 0x01, 0x0A                             ; FC5084  op 01, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0xA5, 0x00, 0xB6, 0x00, 0xA5, 0x00 ; FC5086
	.byte 0x02, 0x0A                             ; FC508E  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB6, 0x00, 0x90, 0x00, 0xB6, 0x00, 0xA5, 0x00 ; FC5090
	.set DisplayList_FC507A_End, .            ; FC5098  end marker: the byte after the last record

; DisplayList_FC5098 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5098 and land exactly on 0xFC50B6.
DisplayList_FC5098:
	.byte 0x02, 0x0A                             ; FC5098  op 02, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0xA6, 0x00, 0x36, 0x00, 0xA7, 0x00 ; FC509A
	.byte 0x01, 0x0A                             ; FC50A2  op 01, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0xA7, 0x00, 0xB7, 0x00, 0xA7, 0x00 ; FC50A4
	.byte 0x02, 0x0A                             ; FC50AC  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB7, 0x00, 0x92, 0x00, 0xB7, 0x00, 0xA7, 0x00 ; FC50AE
	.set DisplayList_FC5098_End, .            ; FC50B6  end marker: the byte after the last record

; DisplayList_FC50B6 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC50B6 and land exactly on 0xFC50D4.
DisplayList_FC50B6:
	.byte 0x02, 0x0A                             ; FC50B6  op 02, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0xA8, 0x00, 0x37, 0x00, 0xA9, 0x00 ; FC50B8
	.byte 0x01, 0x0A                             ; FC50C0  op 01, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0xA9, 0x00, 0xB8, 0x00, 0xA9, 0x00 ; FC50C2
	.byte 0x02, 0x0A                             ; FC50CA  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB8, 0x00, 0x94, 0x00, 0xB8, 0x00, 0xA9, 0x00 ; FC50CC
	.set DisplayList_FC50B6_End, .            ; FC50D4  end marker: the byte after the last record

; DisplayList_FC50D4 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC50D4 and land exactly on 0xFC50F2.
DisplayList_FC50D4:
	.byte 0x02, 0x0A                             ; FC50D4  op 02, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0xC9, 0x00, 0x35, 0x00, 0xCA, 0x00 ; FC50D6
	.byte 0x01, 0x0A                             ; FC50DE  op 01, 10 bytes, handler 0xF31A75
	.byte 0x35, 0x00, 0xCA, 0x00, 0xB6, 0x00, 0xCA, 0x00 ; FC50E0
	.byte 0x02, 0x0A                             ; FC50E8  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB6, 0x00, 0xB5, 0x00, 0xB6, 0x00, 0xCA, 0x00 ; FC50EA
	.set DisplayList_FC50D4_End, .            ; FC50F2  end marker: the byte after the last record

; DisplayList_FC50F2 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC50F2 and land exactly on 0xFC5110.
DisplayList_FC50F2:
	.byte 0x02, 0x0A                             ; FC50F2  op 02, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0xCB, 0x00, 0x36, 0x00, 0xCC, 0x00 ; FC50F4
	.byte 0x01, 0x0A                             ; FC50FC  op 01, 10 bytes, handler 0xF31A75
	.byte 0x36, 0x00, 0xCC, 0x00, 0xB7, 0x00, 0xCC, 0x00 ; FC50FE
	.byte 0x02, 0x0A                             ; FC5106  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB7, 0x00, 0xB7, 0x00, 0xB7, 0x00, 0xCC, 0x00 ; FC5108
	.set DisplayList_FC50F2_End, .            ; FC5110  end marker: the byte after the last record

; DisplayList_FC5110 -- display list, 3 record(s), 30 bytes, interpreter A
; Read by: Draw_Page12EnvelopeKeyoffCurSor (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); so a run of 1-3 consecutive 30-byte segments is drawn.
; Framing: the length bytes walk from 0xFC5110 and land exactly on 0xFC512E.
DisplayList_FC5110:
	.byte 0x02, 0x0A                             ; FC5110  op 02, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0xCD, 0x00, 0x37, 0x00, 0xCE, 0x00 ; FC5112
	.byte 0x01, 0x0A                             ; FC511A  op 01, 10 bytes, handler 0xF31A75
	.byte 0x37, 0x00, 0xCE, 0x00, 0xB8, 0x00, 0xCE, 0x00 ; FC511C
	.byte 0x02, 0x0A                             ; FC5124  op 02, 10 bytes, handler 0xF31A75
	.byte 0xB8, 0x00, 0xB9, 0x00, 0xB8, 0x00, 0xCE, 0x00 ; FC5126
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
	.byte 0x07, 0x11                             ; FC517E  op 07, 17 bytes, handler 0xF31B39
	.byte 0x00, 0x00, 0x00, 0x00, 0x1C      ; FC5180
	.ascii " #"                               ; FC5185
	.byte 0x00, 0x00, 0x10, 0x00, 0x57, 0x00, 0x09, 0x00 ; FC5187
; DLRec_FC518F -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[1], DisplayRecordPtrs_FC52B4[2]
DLRec_FC518F:
	.byte 0x07, 0x11                             ; FC518F  op 07, 17 bytes, handler 0xF31B39
	.byte 0xA7, 0x27, 0x7F, 0x00, 0x1C      ; FC5191
	.ascii "`["                               ; FC5196
	.byte 0xF0, 0x00, 0x03, 0x00, 0x3D, 0x00, 0x35, 0x00 ; FC5198
	.byte 0x07, 0x11                             ; FC51A0  op 07, 17 bytes, handler 0xF31B39
	.byte 0x00, 0x00, 0x00, 0x00, 0x1C, 0xF0, 0x22, 0x00, 0x00, 0x0D, 0x00, 0x69, 0x00, 0x35, 0x00 ; FC51A2
; SoundEditMenu_RepaintField_DL3 -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[15]
SoundEditMenu_RepaintField_DL3:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11                             ; FC51B1  op 07, 17 bytes, handler 0xF31B39
	.byte 0xB5                              ; FC51B3
	.ascii "'?"                               ; FC51B4
	.byte 0x00, 0x17                        ; FC51B6
	.ascii "MW"                               ; FC51B8
	.byte 0xF0, 0x00, 0x02, 0x00, 0x3D, 0x00, 0x7A, 0x00 ; FC51BA
	.byte 0x07, 0x11                             ; FC51C2  op 07, 17 bytes, handler 0xF31B39
	.byte 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x23, 0x00, 0x00, 0x0D, 0x00, 0x49, 0x00, 0x7A, 0x00 ; FC51C4
; DLRec_FC51D3 -- a record (op 09, 12 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[3]
DLRec_FC51D3:
	.byte 0x09, 0x0C                             ; FC51D3  op 09, 12 bytes, handler 0xF31C14
	.byte 0xA9, 0x27, 0x7F, 0x00, 0x17, 0xA5, 0x00, 0x7A, 0x00, 0x03 ; FC51D5
; DLRec_FC51DF -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[5]
DLRec_FC51DF:
	.byte 0x0B, 0x0D                             ; FC51DF  op 0B, 13 bytes, handler 0xF31C56
	.byte 0xAB, 0x27, 0xFF, 0x00, 0x17, 0xC3, 0x00, 0x7A, 0x00, 0x02, 0x00 ; FC51E1
; DLRec_FC51EC -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[7]
DLRec_FC51EC:
	.byte 0x0B, 0x0D                             ; FC51EC  op 0B, 13 bytes, handler 0xF31C56
	.byte 0xAD, 0x27, 0xFF, 0x00, 0x17, 0xE1, 0x00, 0x7A, 0x00, 0x02, 0x00 ; FC51EE
; SoundEditMenu_RepaintField_DL4 -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[16]
SoundEditMenu_RepaintField_DL4:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11                             ; FC51F9  op 07, 17 bytes, handler 0xF31B39
	.byte 0xB6                              ; FC51FB
	.ascii "'?"                               ; FC51FC
	.byte 0x00, 0x17                        ; FC51FE
	.ascii "MW"                               ; FC5200
	.byte 0xF0, 0x00, 0x02, 0x00, 0x3D, 0x00, 0x98, 0x00 ; FC5202
	.byte 0x07, 0x11                             ; FC520A  op 07, 17 bytes, handler 0xF31B39
	.byte 0x00, 0x00, 0x00, 0x00, 0x17, 0x10, 0x23, 0x00, 0x00, 0x0D, 0x00, 0x49, 0x00, 0x98, 0x00 ; FC520C
; DLRec_FC521B -- a record (op 09, 12 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[4]
DLRec_FC521B:
	.byte 0x09, 0x0C                             ; FC521B  op 09, 12 bytes, handler 0xF31C14
	.byte 0xAA, 0x27, 0x7F, 0x00, 0x17, 0xA5, 0x00, 0x98, 0x00, 0x03 ; FC521D
; DLRec_FC5227 -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[6]
DLRec_FC5227:
	.byte 0x0B, 0x0D                             ; FC5227  op 0B, 13 bytes, handler 0xF31C56
	.byte 0xAC, 0x27, 0xFF, 0x00, 0x17, 0xC3, 0x00, 0x98, 0x00, 0x02, 0x00 ; FC5229
; DLRec_FC5234 -- a record (op 0B, 13 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[8]
DLRec_FC5234:
	.byte 0x0B, 0x0D                             ; FC5234  op 0B, 13 bytes, handler 0xF31C56
	.byte 0xAE, 0x27, 0xFF, 0x00, 0x17, 0xE1, 0x00, 0x98, 0x00, 0x02, 0x00 ; FC5236
; DLRec_FC5241 -- a record (op 09, 12 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[9], DisplayRecordPtrs_FC52B4[10], DisplayRecordPtrs_FC52B4[11]
DLRec_FC5241:
	.byte 0x09, 0x0C                             ; FC5241  op 09, 12 bytes, handler 0xF31C14
	.byte 0xB1, 0x27, 0x7F, 0x00, 0x17, 0x1C, 0x01, 0x89, 0x00, 0x03 ; FC5243
; SoundEditMenu_RepaintField_DL1 -- a record (op 07, 17 bytes) inside DisplayList_FC517E,
;          an inner entry point or end named in the list's Read-by line
SoundEditMenu_RepaintField_DL1:
; ; drawn (start operand) by SoundEditMenu_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11                             ; FC524D  op 07, 17 bytes, handler 0xF31B39
	.byte 0xB2, 0x27, 0x03, 0x00, 0x17      ; FC524F
	.ascii "N*"                               ; FC5254
	.byte 0xF3, 0x00, 0x03, 0x00, 0x03, 0x01, 0x7A, 0x00 ; FC5256
	.byte 0x07, 0x11                             ; FC525E  op 07, 17 bytes, handler 0xF31B39
	.byte 0xB2, 0x27, 0x0C, 0x02, 0x17      ; FC5260
	.ascii "N*"                               ; FC5265
	.byte 0xF3, 0x00, 0x03, 0x00, 0x03, 0x01, 0x98, 0x00 ; FC5267
; DLRec_FC526F -- a record (op 03, 11 bytes) inside DisplayList_FC517E,
;          pointed at by DisplayRecordPtrs_FC52B4[0]
DLRec_FC526F:
	.byte 0x03, 0x0B                             ; FC526F  op 03, 11 bytes, handler 0xF31B57
	.short 0x27A6                              ; FC5271  variable
	.byte 0x03, 0x00, 0x05                     ; FC5273  mask, shift, +6
	.long Rects_FC5292                          ; FC5276  8-byte entries
	.set DisplayList_FC517E_End, .            ; FC527A  end marker: the byte after the last record

; DisplayRecords_FC527A -- display list, 2 record(s), 24 bytes, interpreter B
; Read by: DisplayRecordPtrs_FC52B4[12..14] only (two op-09 records, each drawn alone).
; Framing: the length bytes walk from 0xFC527A and land exactly on 0xFC5292.
DisplayRecords_FC527A:
	.byte 0x09, 0x0C                             ; FC527A  op 09, 12 bytes, handler 0xF31C14
	.byte 0xB3, 0x27, 0x7F, 0x00, 0x17, 0x09, 0x01, 0x7A, 0x00, 0x02 ; FC527C
; DLRec_FC5286 -- a record (op 09, 12 bytes) inside DisplayRecords_FC527A,
;          pointed at by DisplayRecordPtrs_FC52B4[14]
DLRec_FC5286:
	.byte 0x09, 0x0C                             ; FC5286  op 09, 12 bytes, handler 0xF31C14
	.byte 0xB4, 0x27, 0x7F, 0x00, 0x17, 0x09, 0x01, 0x98, 0x00, 0x02 ; FC5288
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
	.byte 0x1B, 0x0A                             ; FC52AA  op 1B, 10 bytes, handler 0xF31A75
	.byte 0x0D, 0x00, 0x71, 0x00, 0x18, 0x01, 0xA8, 0x00 ; FC52AC
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
