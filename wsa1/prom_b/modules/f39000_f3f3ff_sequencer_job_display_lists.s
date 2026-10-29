

; --------------------------------------------------------------------------
; DL_YesAreYouSure -- a display list: 70 records, framed by their own length
;                     bytes.  The walk from 0xF39000 consumes exactly 844
;                     bytes and lands on 0xF3934C, which is where the already-
;                     converted list DL_F3934C begins.
; Draws:   "YES "; "Are You Sure ?" -- and, at 0xF39311, "N0  ".  ⚠ THE NAME
;          USES ONLY THE FIRST TWO.  Round 4's rule keeps a literal only if it
;          holds two ADJACENT letters, which is what stops a coordinate byte
;          being quoted as text; the ROM spells NO with a digit zero, so that
;          record does not pass it.  The list draws it all the same, which is
;          why it is named here.
; Evidence: the framing walk is re-run on every emit and the file refuses to
;           print if it does not land on 0xF3934C; and the NAME is the
;           CamelCase of the literals above, which is the rule
;           notes/prom_b_dl_screens_round5.py and round 4's --dl-names use for
;           every other list in this image.  It says what the list PUTS ON THE
;           SCREEN and nothing more.
; Unknown: who runs it.  No call site of any of the four shapes in
;          notes/prom_b_dl_call_shapes.py names 0xF39000, so the list is
;          framed and named but UNREACHED by the census -- the same honest
;          hole the tree records for other lists.
; --------------------------------------------------------------------------
DL_YesAreYouSure:
	.byte	0x03, 0x0B, 0xF6, 0x12, 0xFF, 0x00, 0x05, 0x4F, 0xA1, 0xF3, 0x00	; F39000  |.......O...|  op 03, 11 bytes
	.byte	0x08, 0x0B, 0xF6, 0x12, 0xFF, 0x00, 0x1B, 0x4F, 0xA1, 0xF3, 0x00	; F3900B  |.......O...|  op 08, 11 bytes  "O"
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x05, 0x00, 0x35	; F39016  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F39026  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0xF7, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x23, 0x00, 0x35	; F39027  |.............#.5|  op 07, 17 bytes  "#5"
	.byte	0x00	; F39037  |.|  op 07, 17 bytes  "#5"
	.byte	0x07, 0x11, 0xF8, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x41, 0x00, 0x35	; F39038  |.............A.5|  op 07, 17 bytes  "A5"
	.byte	0x00	; F39048  |.|  op 07, 17 bytes  "A5"
	.byte	0x07, 0x11, 0xF9, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x5F, 0x00, 0x35	; F39049  |............._.5|  op 07, 17 bytes  "_5"
	.byte	0x00	; F39059  |.|  op 07, 17 bytes  "_5"
	.byte	0x07, 0x11, 0xFA, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x7D, 0x00, 0x35	; F3905A  |.............}.5|  op 07, 17 bytes  "}5"
	.byte	0x00	; F3906A  |.|  op 07, 17 bytes  "}5"
	.byte	0x07, 0x11, 0xFB, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x9B, 0x00, 0x35	; F3906B  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F3907B  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0xFC, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0xB9, 0x00, 0x35	; F3907C  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F3908C  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0xFD, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0xD7, 0x00, 0x35	; F3908D  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F3909D  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0xFE, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x05, 0x00, 0x35	; F3909E  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F390AE  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0xFF, 0x12, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x23, 0x00, 0x35	; F390AF  |.............#.5|  op 07, 17 bytes  "#5"
	.byte	0x00	; F390BF  |.|  op 07, 17 bytes  "#5"
	.byte	0x07, 0x11, 0x00, 0x13, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x41, 0x00, 0x35	; F390C0  |.............A.5|  op 07, 17 bytes  "A5"
	.byte	0x00	; F390D0  |.|  op 07, 17 bytes  "A5"
	.byte	0x07, 0x11, 0x01, 0x13, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x5F, 0x00, 0x35	; F390D1  |............._.5|  op 07, 17 bytes  "_5"
	.byte	0x00	; F390E1  |.|  op 07, 17 bytes  "_5"
	.byte	0x07, 0x11, 0x02, 0x13, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x7D, 0x00, 0x35	; F390E2  |.............}.5|  op 07, 17 bytes  "}5"
	.byte	0x00	; F390F2  |.|  op 07, 17 bytes  "}5"
	.byte	0x07, 0x11, 0x03, 0x13, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0x9B, 0x00, 0x35	; F390F3  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F39103  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0x04, 0x13, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0xB9, 0x00, 0x35	; F39104  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F39114  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0x05, 0x13, 0xFF, 0x00, 0x17, 0xA2, 0x95, 0xF3, 0x00, 0x03, 0x00, 0xD7, 0x00, 0x35	; F39115  |...............5|  op 07, 17 bytes  "5"
	.byte	0x00	; F39125  |.|  op 07, 17 bytes  "5"
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0x02, 0x00, 0x22	; F39126  |..............."|  op 07, 17 bytes  """
	.byte	0x00	; F39136  |.|  op 07, 17 bytes  """
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0x20, 0x00, 0x22	; F39137  |............. ."|  op 07, 17 bytes  " ""
	.byte	0x00	; F39147  |.|  op 07, 17 bytes  " ""
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0x3E, 0x00, 0x22	; F39148  |.............>."|  op 07, 17 bytes  ">""
	.byte	0x00	; F39158  |.|  op 07, 17 bytes  ">""
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0x5C, 0x00, 0x22	; F39159  |.............\."|  op 07, 17 bytes  "\""
	.byte	0x00	; F39169  |.|  op 07, 17 bytes  "\""
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0x7A, 0x00, 0x22	; F3916A  |.............z."|  op 07, 17 bytes  "z""
	.byte	0x00	; F3917A  |.|  op 07, 17 bytes  "z""
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0x98, 0x00, 0x22	; F3917B  |..............."|  op 07, 17 bytes  """
	.byte	0x00	; F3918B  |.|  op 07, 17 bytes  """
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0xB6, 0x00, 0x22	; F3918C  |..............."|  op 07, 17 bytes  """
	.byte	0x00	; F3919C  |.|  op 07, 17 bytes  """
	.byte	0x07, 0x11, 0xF6, 0x12, 0xFF, 0x00, 0x17, 0xA5, 0xA0, 0xF3, 0x00, 0x04, 0x00, 0xD4, 0x00, 0x22	; F3919D  |..............."|  op 07, 17 bytes  """
	.byte	0x00	; F391AD  |.|  op 07, 17 bytes  """
	.byte	0x0E, 0x08, 0xC0, 0x03, 0x1E, 0x00, 0x09, 0x00	; F391AE  |........|  op 0E, 8 bytes
	.byte	0x0A, 0x0A, 0x05, 0x00, 0xA0, 0x00, 0x22, 0x00, 0xBA, 0x00	; F391B6  |......"...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x2D, 0x00, 0xA0, 0x00, 0x4A, 0x00, 0xBA, 0x00	; F391C0  |..-...J...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x55, 0x00, 0xA0, 0x00, 0x72, 0x00, 0xBA, 0x00	; F391CA  |..U...r...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x7D, 0x00, 0xA0, 0x00, 0x9A, 0x00, 0xBA, 0x00	; F391D4  |..}.......|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0xA5, 0x00, 0xA0, 0x00, 0xC2, 0x00, 0xBA, 0x00	; F391DE  |..........|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0xCD, 0x00, 0xA0, 0x00, 0xEA, 0x00, 0xBA, 0x00	; F391E8  |..........|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0xF5, 0x00, 0xA0, 0x00, 0x12, 0x01, 0xBA, 0x00	; F391F2  |..........|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x1D, 0x01, 0xA0, 0x00, 0x3A, 0x01, 0xBA, 0x00	; F391FC  |......:...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x05, 0x00, 0xCF, 0x00, 0x22, 0x00, 0xE9, 0x00	; F39206  |......"...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x2D, 0x00, 0xCF, 0x00, 0x4A, 0x00, 0xE9, 0x00	; F39210  |..-...J...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x55, 0x00, 0xCF, 0x00, 0x72, 0x00, 0xE9, 0x00	; F3921A  |..U...r...|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x7D, 0x00, 0xCF, 0x00, 0x9A, 0x00, 0xE9, 0x00	; F39224  |..}.......|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0xA5, 0x00, 0xCF, 0x00, 0xC2, 0x00, 0xE9, 0x00	; F3922E  |..........|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0xCD, 0x00, 0xCF, 0x00, 0xEA, 0x00, 0xE9, 0x00	; F39238  |..........|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0xF5, 0x00, 0xCF, 0x00, 0x12, 0x01, 0xE9, 0x00	; F39242  |..........|  op 0A, 10 bytes
	.byte	0x0A, 0x0A, 0x1D, 0x01, 0xCF, 0x00, 0x3A, 0x01, 0xE9, 0x00	; F3924C  |......:...|  op 0A, 10 bytes
	.byte	0x17, 0x09, 0x05, 0x00, 0x2C, 0x00, 0x20, 0x31, 0x20	; F39256  |....,. 1 |  op 17, 9 bytes  " 1 "
	.byte	0x17, 0x09, 0x23, 0x00, 0x2C, 0x00, 0x20, 0x32, 0x20	; F3925F  |..#.,. 2 |  op 17, 9 bytes  " 2 "
	.byte	0x17, 0x07, 0x42, 0x00, 0x2C, 0x00, 0x20	; F39268  |..B.,. |  op 17, 7 bytes  " "
	.byte	0x17, 0x09, 0x41, 0x00, 0x2C, 0x00, 0x20, 0x33, 0x20	; F3926F  |..A.,. 3 |  op 17, 9 bytes  " 3 "
	.byte	0x17, 0x09, 0x5F, 0x00, 0x2C, 0x00, 0x20, 0x34, 0x20	; F39278  |.._.,. 4 |  op 17, 9 bytes  " 4 "
	.byte	0x17, 0x09, 0x7D, 0x00, 0x2C, 0x00, 0x20, 0x35, 0x20	; F39281  |..}.,. 5 |  op 17, 9 bytes  " 5 "
	.byte	0x17, 0x09, 0x9B, 0x00, 0x2C, 0x00, 0x20, 0x36, 0x20	; F3928A  |....,. 6 |  op 17, 9 bytes  " 6 "
	.byte	0x17, 0x07, 0xBA, 0x00, 0x2C, 0x00, 0x20	; F39293  |....,. |  op 17, 7 bytes  " "
	.byte	0x17, 0x09, 0xB9, 0x00, 0x2C, 0x00, 0x20, 0x37, 0x20	; F3929A  |....,. 7 |  op 17, 9 bytes  " 7 "
	.byte	0x17, 0x09, 0xD7, 0x00, 0x2C, 0x00, 0x20, 0x38, 0x20	; F392A3  |....,. 8 |  op 17, 9 bytes  " 8 "
	.byte	0x17, 0x09, 0x05, 0x00, 0x2C, 0x00, 0x20, 0x39, 0x20	; F392AC  |....,. 9 |  op 17, 9 bytes  " 9 "
	.byte	0x17, 0x08, 0x26, 0x00, 0x2C, 0x00, 0x31, 0x30	; F392B5  |..&.,.10|  op 17, 8 bytes  "10"
	.byte	0x17, 0x08, 0x44, 0x00, 0x2C, 0x00, 0x31, 0x31	; F392BD  |..D.,.11|  op 17, 8 bytes  "11"
	.byte	0x17, 0x08, 0x62, 0x00, 0x2C, 0x00, 0x31, 0x32	; F392C5  |..b.,.12|  op 17, 8 bytes  "12"
	.byte	0x17, 0x07, 0x83, 0x00, 0x2C, 0x00, 0x20	; F392CD  |....,. |  op 17, 7 bytes  " "
	.byte	0x17, 0x08, 0x80, 0x00, 0x2C, 0x00, 0x31, 0x33	; F392D4  |....,.13|  op 17, 8 bytes  "13"
	.byte	0x17, 0x08, 0x9E, 0x00, 0x2C, 0x00, 0x31, 0x34	; F392DC  |....,.14|  op 17, 8 bytes  "14"
	.byte	0x17, 0x08, 0xBC, 0x00, 0x2C, 0x00, 0x31, 0x35	; F392E4  |....,.15|  op 17, 8 bytes  "15"
	.byte	0x17, 0x08, 0xDA, 0x00, 0x2C, 0x00, 0x31, 0x36	; F392EC  |....,.16|  op 17, 8 bytes  "16"
	.byte	0x06, 0x09, 0xD1, 0x01, 0x59, 0x45, 0x53, 0x20, 0x11	; F392F4  |....YES .|  op 06, 9 bytes  "YES "
	.byte	0x1C, 0x14, 0x11, 0x00, 0x28, 0x00, 0x41, 0x72, 0x65, 0x20, 0x59, 0x6F, 0x75, 0x20, 0x53, 0x75	; F392FD  |....(.Are You Su|  op 1C, 20 bytes  "Are You Sure ?"
	.byte	0x72, 0x65, 0x20, 0x3F	; F3930D  |re ?|  op 1C, 20 bytes  "Are You Sure ?"
	.byte	0x06, 0x09, 0xC1, 0x07, 0x4E, 0x30, 0x20, 0x20, 0x11	; F39311  |....N0  .|  op 06, 9 bytes  "N0  "
	.byte	0x0A, 0x0A, 0x0A, 0x00, 0x20, 0x00, 0xB4, 0x00, 0x3A, 0x00	; F3931A  |.... ...:.|  op 0A, 10 bytes
	.byte	0x09, 0x0A, 0xC4, 0x00, 0x07, 0x00, 0xE4, 0x00, 0x18, 0x00	; F39324  |..........|  op 09, 10 bytes
	.byte	0x09, 0x0A, 0xC6, 0x00, 0x09, 0x00, 0xE2, 0x00, 0x16, 0x00	; F3932E  |..........|  op 09, 10 bytes
	.byte	0x09, 0x0A, 0xC4, 0x00, 0x2D, 0x00, 0xE4, 0x00, 0x3E, 0x00	; F39338  |....-...>.|  op 09, 10 bytes
	.byte	0x09, 0x0A, 0xC6, 0x00, 0x2F, 0x00, 0xE2, 0x00, 0x3C, 0x00	; F39342  |..../...<.|  op 09, 10 bytes

; ------------------------------------------------------------------
; 0xF3934C-0xF394E2 -- 48 display-list records, 407 bytes -- interpreter A
;   entered at: 0xF3934C
;   ends used:  0xF394E3
; ------------------------------------------------------------------
DL_F3934C:
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


; ------------------------------------------------------------------
; 0xF394E3-0xF39550 -- 11 display-list records, 110 bytes -- interpreter A
; Formerly Data_F394E3 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F394E3:
	dl_box_shadow2	x0=223, y0=104, x1=307, y1=119
	dl_box	x0=255, y0=29, x1=308, y1=48
	dl_box	x0=257, y0=31, x1=306, y1=46
	dl_box	x0=10, y0=32, x1=45, y1=51
	dl_box	x0=12, y0=34, x1=43, y1=49
	dl_box	x0=10, y0=68, x1=45, y1=87
	dl_box	x0=227, y0=69, x1=309, y1=88
	dl_box	x0=12, y0=70, x1=43, y1=85
	dl_box	x0=229, y0=71, x1=307, y1=86
	dl_box	x0=13, y0=108, x1=58, y1=127
	dl_box	x0=15, y0=110, x1=56, y1=125

; ------------------------------------------------------------------
; 0xF39551-0xF39558 -- 1 display-list records, 8 bytes -- interpreter A
;   entered at: 0xF39551
;   ends used:  0xF39559
; ------------------------------------------------------------------
DL_F39551:
	dl_clear_area	x=0, y=0, w=320, h=240

; === COVER-R1 0xF39559-0xF3972D ===
; ⚠ CLOSED 2026-09-02 (lane promB4).  The verdict below -- "everything
;   else is NOT reachable and stays `.incbin`" -- was true of the round-1
;   REACHABILITY WALK and false of the ROM: the remainder is display-list
;   operand arrays, reached by pointer from records the walk never enters
;   because nothing CALLS them.  0 bytes of this block are `.incbin` now.
;   Evidence and regeneration: notes/gen_prom_b_promB4_operand_arrays.py
; 0xF39559-0xF3972C, coverage round 1: 398 of this span's 468 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 398 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F39559 -- 393 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ CORRECTED 2026-09-02 (lane promB4): this header said 398 bytes.
;   The last 5 bytes were the head of the interpreter-B record at 0xF396E2,
;   which prom_b 0xF7E966 loads into XIY before calling T_DLB_Handler_Array8.  The
;   string table here is 32 entries of 7 bytes ending exactly at 0xF396E2.
; Reached from: 0x00F39559 appears as a 32-bit word at 0xF7E2F3 0xF7F008
;               0xF7F338 0xF7F676 0xF7F9AA +1 more; converted code at 0xF7E2F2
;               0xF7F007 0xF7F337 0xF7F675 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 99% printable ASCII; a linear decode runs 176 instructions and
;           ends `ld XWA,0x0000ff26`, with 16% of the bytes in spellings llvm-
;           mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F39559:
	.byte	0x4F, 0x46, 0x46, 0x4F, 0x4E, 0x20, 0x2D, 0x2D, 0x20, 0x20, 0x31, 0x20, 0x32, 0x20, 0x33, 0x20	; F39559  |OFFON --  1 2 3 |
	.byte	0x34, 0x20, 0x35, 0x20, 0x36, 0x20, 0x37, 0x20, 0x38, 0x20, 0x39, 0x31, 0x30, 0x31, 0x31, 0x31	; F39569  |4 5 6 7 8 910111|
	.byte	0x32, 0x31, 0x33, 0x31, 0x34, 0x31, 0x35, 0x31, 0x36, 0x31, 0x37, 0x31, 0x38, 0x31, 0x39, 0x32	; F39579  |2131415161718192|
	.byte	0x30, 0x32, 0x31, 0x32, 0x32, 0x32, 0x33, 0x32, 0x34, 0x32, 0x35, 0x32, 0x36, 0x32, 0x37, 0x32	; F39589  |0212223242526272|
	.byte	0x38, 0x32, 0x39, 0x33, 0x30, 0x33, 0x31, 0x33, 0x32, 0x50, 0x20, 0x31, 0x50, 0x20, 0x32, 0x50	; F39599  |829303132P 1P 2P|
	.byte	0x20, 0x33, 0x50, 0x20, 0x34, 0x50, 0x20, 0x35, 0x50, 0x20, 0x36, 0x50, 0x20, 0x37, 0x50, 0x20	; F395A9  | 3P 4P 5P 6P 7P |
	.byte	0x38, 0x50, 0x20, 0x39, 0x50, 0x31, 0x30, 0x50, 0x31, 0x31, 0x50, 0x31, 0x32, 0x50, 0x31, 0x33	; F395B9  |8P 9P10P11P12P13|
	.byte	0x50, 0x31, 0x34, 0x50, 0x31, 0x35, 0x50, 0x31, 0x36, 0x50, 0x31, 0x37, 0x50, 0x31, 0x38, 0x50	; F395C9  |P14P15P16P17P18P|
	.byte	0x31, 0x39, 0x50, 0x32, 0x30, 0x50, 0x32, 0x31, 0x50, 0x32, 0x32, 0x50, 0x32, 0x33, 0x50, 0x32	; F395D9  |19P20P21P22P23P2|
	.byte	0x34, 0x50, 0x32, 0x35, 0x50, 0x32, 0x36, 0x50, 0x32, 0x37, 0x50, 0x32, 0x38, 0x50, 0x32, 0x39	; F395E9  |4P25P26P27P28P29|
	.byte	0x50, 0x33, 0x30, 0x50, 0x33, 0x31, 0x50, 0x33, 0x32, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x20	; F395F9  |P30P31P32PART 1 |
	.byte	0x50, 0x41, 0x52, 0x54, 0x20, 0x32, 0x20, 0x50, 0x41, 0x52, 0x54, 0x20, 0x33, 0x20, 0x50, 0x41	; F39609  |PART 2 PART 3 PA|
	.byte	0x52, 0x54, 0x20, 0x34, 0x20, 0x50, 0x41, 0x52, 0x54, 0x20, 0x35, 0x20, 0x50, 0x41, 0x52, 0x54	; F39619  |RT 4 PART 5 PART|
	.byte	0x20, 0x36, 0x20, 0x50, 0x41, 0x52, 0x54, 0x20, 0x37, 0x20, 0x50, 0x41, 0x52, 0x54, 0x20, 0x38	; F39629  | 6 PART 7 PART 8|
	.byte	0x20, 0x50, 0x41, 0x52, 0x54, 0x20, 0x39, 0x20, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x30, 0x50	; F39639  | PART 9 PART 10P|
	.byte	0x41, 0x52, 0x54, 0x20, 0x31, 0x31, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x32, 0x50, 0x41, 0x52	; F39649  |ART 11PART 12PAR|
	.byte	0x54, 0x20, 0x31, 0x33, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x34, 0x50, 0x41, 0x52, 0x54, 0x20	; F39659  |T 13PART 14PART |
	.byte	0x31, 0x35, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x36, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x37	; F39669  |15PART 16PART 17|
	.byte	0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x38, 0x50, 0x41, 0x52, 0x54, 0x20, 0x31, 0x39, 0x50, 0x41	; F39679  |PART 18PART 19PA|
	.byte	0x52, 0x54, 0x20, 0x32, 0x30, 0x50, 0x41, 0x52, 0x54, 0x20, 0x32, 0x31, 0x50, 0x41, 0x52, 0x54	; F39689  |RT 20PART 21PART|
	.byte	0x20, 0x32, 0x32, 0x50, 0x41, 0x52, 0x54, 0x20, 0x32, 0x33, 0x50, 0x41, 0x52, 0x54, 0x20, 0x32	; F39699  | 22PART 23PART 2|
	.byte	0x34, 0x50, 0x41, 0x52, 0x54, 0x20, 0x32, 0x35, 0x50, 0x41, 0x52, 0x54, 0x20, 0x32, 0x36, 0x50	; F396A9  |4PART 25PART 26P|
	.byte	0x41, 0x52, 0x54, 0x20, 0x32, 0x37, 0x50, 0x41, 0x52, 0x54, 0x20, 0x32, 0x38, 0x50, 0x41, 0x52	; F396B9  |ART 27PART 28PAR|
	.byte	0x54, 0x20, 0x32, 0x39, 0x50, 0x41, 0x52, 0x54, 0x20, 0x33, 0x30, 0x50, 0x41, 0x52, 0x54, 0x20	; F396C9  |T 29PART 30PART |
	.byte	0x33, 0x31, 0x50, 0x41, 0x52, 0x54, 0x20, 0x33, 0x32	; F396D9  |31PART 32|

; ==================================================================
; 0xF396E2-0xF3972C -- display-list RECORDS and the OPERAND ARRAYS they
;                    point at (75 bytes) -- converted 2026-09-02,
;                    lane promB4, notes/gen_prom_b_promB4_operand_arrays.py
; ==================================================================
;
; Right edge anchored on TrackAssign_DrawTrackRowHighlight_DL, a converted interpreter-A op-1B record
; whose four words (0x0038, 0x003E, 0x0117, 0x00B5) are the bounding box of
; the 8 entries below.
;
; ⚠ THE 398-BYTE EXTENT OF Data_F39559 ABOVE OVERSHOT BY 5 BYTES, and its
;   own header said so: "the extent is the reachability walk's, not the
;   object's".  0xF396E2 is a record start -- prom_b 0xF7E966 does
;   `ld XIY,0x00F396E2` then calls T_DLB_Handler_Array8 (`jp 0xF31B57`, the
;   interpreter-B op-03 handler).  The string table above it is 32 entries
;   of 7 bytes, "PART 1 " .. "PART 32", ending exactly at 0xF396E2.
;   Data_F39559 is therefore 393 bytes, not 398.
;
Data_F396E2:
	dlb_rect_entry	var=UI_DrawScratch, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=DLTable_F396ED

; ------------------------------------------------------------------
; DLTable_F396ED -- 8 entries of 8 bytes, 0xF396ED-0xF3972C
; Referenced by: display-list record 0xF396E2
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F396ED:
	.short 0x0038, 0x003E, 0x0117, 0x004C	; [0]
	.short 0x0038, 0x004D, 0x0117, 0x005B	; [1]
	.short 0x0038, 0x005C, 0x0117, 0x006A	; [2]
	.short 0x0038, 0x006B, 0x0117, 0x0079	; [3]
	.short 0x0038, 0x007A, 0x0117, 0x0088	; [4]
	.short 0x0038, 0x0089, 0x0117, 0x0097	; [5]
	.short 0x0038, 0x0098, 0x0117, 0x00A6	; [6]
	.short 0x0038, 0x00A7, 0x0117, 0x00B5	; [7]

; === END COVER-R1 0xF39559-0xF3972D ===

; ------------------------------------------------------------------
; 0xF3972D-0xF39736 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF3972D
;   ends used:  0xF39737
; ------------------------------------------------------------------
TrackAssign_DrawTrackRowHighlight_DL:
; drawn (start operand) by TrackAssign_DrawTrackRowHighlight -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=56, y0=62, x1=279, y1=181


; ------------------------------------------------------------------
; 0xF39737-0xF39853 -- 19 display-list records, 285 bytes -- interpreter A
; Formerly Data_F39737 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
TrackAssign_DrawSelectedPart_DL:
; drawn (start operand) by TrackAssign_DrawSelectedPart -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=64	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=79	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=94	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=109	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=124	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=139	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=154	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=169	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=64	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=79	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=94	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=109	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=124	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=139	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=154	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559+0xa9, width=7, x=96, y=169	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F39559+0x9, width=2, x=48, y=110	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F39559+0xa9, width=7, x=112, y=110	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F39559+0xa9, width=7, x=192, y=110	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF39854-0xF39879 -- 4 display-list records, 38 bytes -- interpreter A
;   entered at: 0xF39854, 0xF39870
;   ends used:  0xF39870, 0xF3987A
; ------------------------------------------------------------------
DL_F39854:
	dl_text8x14	x=288, y=113, text="OK \021"
	dl_box	x0=285, y0=108, x1=308, y1=127
	dl_box	x0=287, y0=110, x1=306, y1=125
DL_F39870:
	dl_erase_rect	x0=285, y0=108, x1=320, y1=127


; ------------------------------------------------------------------
; 0xF3987A-0xF3998D -- 31 display-list records, 276 bytes -- interpreter A
; Formerly Data_F3987A -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F3987A:
	dl_text16x16_packed	x=48, y=8, text="TRACK"
	dl_text16x16_packed	x=114, y=8, text="ASSIGN"
	dl_text16x16_packed	x=191, y=8, text="CHANGE"
	dl_text16x16	x=48, y=51, text="ATTENTI0N!"
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x14	x=280, y=76, text="YES"
	dl_text8x16	x=8, y=84, text="Changing"
	dl_text8x16	x=80, y=84, text="the"
	dl_text8x16	x=112, y=84, text="assignment"
	dl_text8x16	x=200, y=84, text="of"
	dl_text8x16	x=8, y=110, text="Track"
	dl_text8x16	x=72, y=110, text="from"
	dl_text8x16	x=176, y=110, text="~"
	dl_text8x16	x=312, y=110, text="\021"
	dl_text8x14	x=280, y=111, text="N0"
	dl_text8x16	x=8, y=138, text="will"
	dl_text8x16	x=48, y=138, text="erase"
	dl_text8x16	x=96, y=138, text="all"
	dl_text8x16	x=128, y=138, text="the"
	dl_text8x16	x=160, y=138, text="current"
	dl_text8x16	x=224, y=138, text="data"
	dl_text16x16	x=24, y=178, text="Are"
	dl_text16x16	x=88, y=178, text="You"
	dl_text16x16	x=152, y=178, text="Sure?"
	dl_box_shadow2	x0=3, y0=37, x1=266, y1=210
	dl_box	x0=275, y0=71, x1=309, y1=90
	dl_box	x0=277, y0=73, x1=307, y1=88
	dl_box	x0=275, y0=106, x1=309, y1=125
	dl_box	x0=277, y0=108, x1=307, y1=123
	dl_hline	x0=46, y0=67, x1=208, y1=67
	dl_hline	x0=46, y0=68, x1=208, y1=68

; ------------------------------------------------------------------
; 0xF3998E-0xF399C0 -- 4 display-list records, 51 bytes -- interpreter B
;   entered at: 0xF3998E
;   ends used:  0xF399C1
; ------------------------------------------------------------------
Paint_SongClear_DL3:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16, table=0x000012f7, width=6, x=128, y=86
	dlb_number16_xy	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=248, y=73, digits=3
	dlb_number_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=93, y=86, digits=2
	dlb_number_xy	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=238, y=86, digits=3

; === COVER-R1 0xF399C1-0xF399D5 ===
; 0xF399C1-0xF399D4, coverage round 1: 20 of this span's 20 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 20 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F399C1 -- 20 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F399C1 appears as a 32-bit word at 0xF7EB70; converted
;               code at 0xF7EB6F loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 100% printable ASCII; a linear decode runs 10 instructions and
;           ends `ld BC,0x0030`, with 10% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F399C1:
	.byte	0x20, 0x31, 0x20, 0x32, 0x20, 0x33, 0x20, 0x34, 0x20, 0x35, 0x20, 0x36, 0x20, 0x37, 0x20, 0x38	; F399C1  | 1 2 3 4 5 6 7 8|
	.byte	0x20, 0x39, 0x31, 0x30	; F399D1  | 910|

; === END COVER-R1 0xF399C1-0xF399D5 ===

; ------------------------------------------------------------------
; 0xF399D5-0xF3A0A4 -- 202 display-list records, 1744 bytes -- interpreter A (198 records) and B (4)
;   entered at: 0xF399D5, 0xF39A73, 0xF39A7D, 0xF39BF8, 0xF39C02, 0xF39C35, 0xF39D3E, 0xF39E87, 0xF39F8A
;   ends used:  0xF39A73, 0xF39A7D, 0xF39BF8, 0xF39C02, 0xF39C35, 0xF39D3E, 0xF39E87, 0xF39F8A, 0xF3A0A5
; ------------------------------------------------------------------
; DL_SongClearKbSongS0ngAll -- the display list at 0xF399D5.  Its own text
;                              records read: "SONG"; "CLEAR"; "KB"; "SONG";
;                              "S0NG"; "/ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SongClearKbSongS0ngAll:
	dl_text16x16_packed	x=121, y=6, text="SONG"
	dl_text16x16_packed	x=176, y=6, text="CLEAR"
	dl_text8x8_packed	x=272, y=73, text="KB"
	dl_text16x16_packed	x=48, y=86, text="SONG"
	dl_text16x16_packed	x=227, y=86, text=":"
	dl_text16x16_packed	x=271, y=86, text="%"
	dl_text16x16_packed	x=115, y=87, text=";"
	dl_text8x16	x=312, y=150, text="\021"
	dl_text8x14	x=288, y=151, text="0K"
	dl_text8x14	x=72, y=197, text="S0NG"
	dl_text8x14	x=112, y=197, text="N0"
	dl_text8x14	x=136, y=197, text="/ALL"
	dl_text8x14	x=96, y=220, text="<"
	dl_text8x14	x=136, y=220, text=">"
	dl_value_glyph	glyph=61, x=88, y=1
	dl_box_shadow2	x0=38, y0=67, x1=290, y1=109
	dl_box_shadow2	x0=85, y0=212, x1=114, y1=236
	dl_box_shadow2	x0=125, y0=212, x1=154, y1=236
	dl_box	x0=283, y0=146, x1=309, y1=165
	dl_box	x0=285, y0=148, x1=307, y1=163
Paint_SongClear_DL1:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=39, y0=68, x1=290, y1=109
; DL_SongClearKbSongAttenti0n -- the display list at 0xF39A7D.  Its own text
;                                records read: "SONG"; "CLEAR"; "KB"; "SONG";
;                                "ATTENTI0N!"; "Using"; "S0NG"; "CLEAR" +12
;                                more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SongClearKbSongAttenti0n:
	dl_text16x16_packed	x=121, y=6, text="SONG"
	dl_text16x16_packed	x=176, y=6, text="CLEAR"
	dl_text8x8_packed	x=250, y=45, text="KB"
	dl_text16x16_packed	x=96, y=50, text="."
	dl_text16x16_packed	x=26, y=58, text="SONG"
	dl_text16x16_packed	x=207, y=59, text=":"
	dl_text16x16_packed	x=251, y=59, text="%"
	dl_text16x16_packed	x=96, y=66, text="'"
	dl_text16x16	x=56, y=106, text="ATTENTI0N!"
	dl_text8x14	x=32, y=134, text="Using"
	dl_text8x14	x=80, y=134, text="S0NG"
	dl_text8x14	x=120, y=134, text="CLEAR"
	dl_text8x14	x=168, y=134, text="will"
	dl_text8x14	x=208, y=134, text="erase"
	dl_text8x14	x=280, y=150, text="YES"
	dl_text8x16	x=312, y=150, text="\021"
	dl_text8x14	x=32, y=155, text="any"
	dl_text8x14	x=64, y=155, text="existing"
	dl_text8x14	x=136, y=155, text="recording"
	dl_text8x14	x=216, y=155, text="in"
	dl_text8x14	x=240, y=155, text="the"
	dl_text8x14	x=32, y=176, text="Sequencer."
	dl_text8x16	x=312, y=188, text="\021"
	dl_text8x14	x=280, y=189, text="N0"
	dl_text16x16	x=32, y=198, text="Are"
	dl_text16x16	x=96, y=198, text="You"
	dl_text16x16	x=160, y=198, text="Sure?"
	dl_box_shadow2	x0=16, y0=39, x1=268, y1=81
	dl_box	x0=276, y0=145, x1=308, y1=164
	dl_box	x0=278, y0=147, x1=306, y1=162
	dl_box	x0=276, y0=184, x1=308, y1=203
	dl_box	x0=278, y0=186, x1=306, y1=201
	dl_hline	x0=15, y0=96, x1=270, y1=96
	dl_hline	x0=55, y0=122, x1=215, y1=122
	dl_hline	x0=55, y0=123, x1=215, y1=123
	dl_hline	x0=15, y0=218, x1=272, y1=218
	dl_hline	x0=17, y0=219, x1=272, y1=219
	dl_hline	x0=17, y0=220, x1=272, y1=220
	dl_vline	x0=15, y0=96, x1=15, y1=220
	dl_vline	x0=270, y0=96, x1=270, y1=220
	dl_vline	x0=271, y0=97, x1=271, y1=220
	dl_vline	x0=272, y0=97, x1=272, y1=220
Paint_SongClear_DL4:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=17, y0=40, x1=268, y1=81
Paint_SongClear_DL6:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16, table=0x000012f7, width=6, x=104, y=58
	dlb_number16_xy	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=226, y=44, digits=3
	dlb_number_xy	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=72, y=58, digits=2
	dlb_number_xy	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=216, y=58, digits=3
; DL_TrackClearAttenti0nUsing -- the display list at 0xF39C35.  Its own text
;                                records read: "TRACK"; "CLEAR"; "ATTENTI0N!";
;                                "Using"; "TRACK"; "CLEAR"; "will"; "erase"
;                                +11 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackClearAttenti0nUsing:
	dl_text16x16_packed	x=121, y=6, text="TRACK"
	dl_text16x16_packed	x=187, y=6, text="CLEAR"
	dl_text16x16	x=48, y=39, text="ATTENTI0N!"
	dl_text8x14	x=16, y=63, text="Using"
	dl_text8x14	x=64, y=63, text="TRACK"
	dl_text8x14	x=112, y=63, text="CLEAR"
	dl_text8x14	x=160, y=63, text="will"
	dl_text8x14	x=200, y=63, text="erase"
	dl_text8x14	x=280, y=73, text="YES"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x14	x=16, y=84, text="any"
	dl_text8x14	x=48, y=84, text="existing"
	dl_text8x14	x=120, y=84, text="recordings"
	dl_text8x14	x=208, y=84, text="in"
	dl_text8x14	x=232, y=84, text="the"
	dl_text8x14	x=16, y=105, text="selected"
	dl_text8x14	x=88, y=105, text="Tracks."
	dl_text8x16	x=312, y=111, text="\021"
	dl_text8x14	x=280, y=112, text="N0"
	dl_text16x16	x=24, y=127, text="Are"
	dl_text16x16	x=88, y=127, text="You"
	dl_text16x16	x=152, y=127, text="Sure?"
	dl_box_shadow2	x0=11, y0=29, x1=264, y1=149
	dl_box	x0=276, y0=68, x1=308, y1=87
	dl_box	x0=278, y0=70, x1=306, y1=85
	dl_box	x0=276, y0=107, x1=308, y1=126
	dl_box	x0=278, y0=109, x1=306, y1=124
	dl_hline	x0=46, y0=55, x1=206, y1=55
	dl_hline	x0=46, y0=56, x1=206, y1=56
; DL_EditSeqN0teEditS0ngClear -- the display list at 0xF39D3E.  Its own text
;                                records read: "EDIT"; "SEQ."; "N0TE"; "EDIT";
;                                "S0NG"; "CLEAR"; "DRUM"; "EDIT" +10 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EditSeqN0teEditS0ngClear:
	dl_text16x16_packed	x=151, y=5, text="EDIT"
	dl_text8x8_packed	x=9, y=8, text="SEQ."
	dl_text8x14	x=40, y=36, text="N0TE"
	dl_text8x14	x=80, y=36, text="EDIT"
	dl_text8x14	x=176, y=36, text="S0NG"
	dl_text8x14	x=216, y=36, text="CLEAR"
	dl_text8x8_packed	x=0, y=38, text="\020"
	dl_text8x8_packed	x=314, y=38, text="\021"
	dl_text8x14	x=40, y=75, text="DRUM"
	dl_text8x14	x=80, y=75, text="EDIT"
	dl_text8x14	x=176, y=75, text="TRACK"
	dl_text8x14	x=224, y=75, text="CLEAR"
	dl_text8x8_packed	x=0, y=77, text="\020"
	dl_text8x8_packed	x=314, y=77, text="\021"
	dl_text8x14	x=176, y=113, text="N0TE"
	dl_text8x14	x=216, y=113, text="CHANGE"
	dl_text8x14	x=40, y=114, text="QUANTIZE"
	dl_text8x8_packed	x=0, y=116, text="\020"
	dl_text8x8_packed	x=314, y=116, text="\021"
	dl_text8x14	x=40, y=153, text="TRANSP0SE"
	dl_text8x14	x=176, y=153, text="ADVANCE/DELAY"
	dl_text8x8_packed	x=0, y=155, text="\020"
	dl_text8x8_packed	x=314, y=155, text="\021"
	dl_text8x14	x=40, y=192, text="VEL0CITY"
	dl_text8x14	x=112, y=192, text="CHANGE"
	dl_text8x8_packed	x=0, y=194, text="\020"
	dl_text8x8_packed	x=314, y=194, text="\021"
	dl_text8x14	x=176, y=192, text="PANEL WRITE"
	dl_text8x8_packed	x=288, y=8, text="P1/2"
	dl_box	x0=6, y0=4, x1=36, y1=18
	dl_value_glyph	glyph=16, x=128, y=2
	dl_value_glyph	glyph=2, x=8, y=26
	dl_value_glyph	glyph=15, x=8, y=66
	dl_value_glyph	glyph=59, x=8, y=106
	dl_value_glyph	glyph=60, x=8, y=146
	dl_value_glyph	glyph=8, x=8, y=186
	dl_value_glyph	glyph=61, x=288, y=26
	dl_value_glyph	glyph=62, x=288, y=66
	dl_value_glyph	glyph=63, x=288, y=106
	dl_value_glyph	glyph=64, x=288, y=146
	dl_value_glyph	glyph=68, x=288, y=186
; DL_EditSeqSongCopyCopyErase -- the display list at 0xF39E87.  Its own text
;                                records read: "EDIT"; "SEQ."; "SONG"; "COPY";
;                                "COPY"; "ERASE"; "MEASURE"; "DELETE" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EditSeqSongCopyCopyErase:
	dl_text16x16_packed	x=151, y=5, text="EDIT"
	dl_text8x8_packed	x=9, y=8, text="SEQ."
	dl_text8x14	x=40, y=36, text="SONG"
	dl_text8x14	x=80, y=36, text="COPY"
	dl_text8x14	x=232, y=36, text="COPY"
	dl_text8x8_packed	x=0, y=38, text="\020"
	dl_text8x8_packed	x=314, y=38, text="\021"
	dl_text8x14	x=232, y=75, text="ERASE"
	dl_text8x8_packed	x=314, y=77, text="\021"
	dl_text8x14	x=168, y=95, text="MEASURE"
	dl_text8x14	x=232, y=114, text="DELETE"
	dl_text8x8_packed	x=314, y=116, text="\021"
	dl_text8x14	x=40, y=114, text="TRACK"
	dl_text8x14	x=88, y=114, text="MERGE"
	dl_text8x14	x=232, y=153, text="INSERT"
	dl_text8x8_packed	x=0, y=116, text="\020"
	dl_text8x8_packed	x=314, y=155, text="\021"
	dl_text8x8_packed	x=288, y=8, text="P2/2"
	dl_box	x0=6, y0=4, x1=36, y1=18
	dl_hline	x0=228, y0=40, x1=231, y1=40
	dl_hline	x0=228, y0=79, x1=231, y1=79
	dl_hline	x0=225, y0=99, x1=228, y1=99
	dl_hline	x0=228, y0=119, x1=231, y1=119
	dl_hline	x0=228, y0=158, x1=231, y1=158
	dl_vline	x0=228, y0=40, x1=228, y1=158
	dl_value_glyph	glyph=16, x=128, y=2
	dl_value_glyph	glyph=65, x=8, y=26
	dl_value_glyph	glyph=67, x=8, y=108
	dl_value_glyph	glyph=69, x=288, y=33
	dl_value_glyph	glyph=70, x=288, y=69
	dl_value_glyph	glyph=71, x=288, y=108
	dl_value_glyph	glyph=72, x=288, y=149
; DL_TrackClearPressTheUpDown -- the display list at 0xF39F8A.  Its own text
;                                records read: "TRACK"; "CLEAR"; "Press";
;                                "the"; "up/down"; "buttons"; "under"; "the"
;                                +15 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackClearPressTheUpDown:
	dl_text16x16_packed	x=121, y=6, text="TRACK"
	dl_text16x16_packed	x=187, y=6, text="CLEAR"
	dl_text8x16	x=8, y=46, text="Press"
	dl_text8x16	x=56, y=46, text="the"
	dl_text8x16	x=88, y=46, text="up/down"
	dl_text8x16	x=152, y=46, text="buttons"
	dl_text8x16	x=216, y=46, text="under"
	dl_text8x16	x=8, y=65, text="the"
	dl_text8x16	x=40, y=65, text="screen"
	dl_text8x16	x=96, y=65, text="corresponding"
	dl_text8x16	x=208, y=65, text="to"
	dl_text8x16	x=232, y=65, text="the"
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x14	x=288, y=75, text="0K"
	dl_text8x16	x=8, y=84, text="tracks"
	dl_text8x16	x=64, y=84, text="that"
	dl_text8x16	x=104, y=84, text="you"
	dl_text8x16	x=136, y=84, text="want"
	dl_text8x16	x=176, y=84, text="to"
	dl_text8x16	x=200, y=84, text="clear."
	dl_text8x14	x=8, y=105, text="Press"
	dl_text8x14	x=56, y=105, text="0K"
	dl_text8x14	x=80, y=105, text="to"
	dl_text8x14	x=104, y=105, text="Complete"
	dl_text8x14	x=176, y=105, text="TRACK"
	dl_text8x14	x=224, y=105, text="CLEAR."
	dl_box_shadow2	x0=4, y0=34, x1=278, y1=132
	dl_box	x0=284, y0=70, x1=308, y1=89
	dl_box	x0=286, y0=72, x1=306, y1=87
	dl_box	x0=51, y0=100, x1=76, y1=119
	dl_box	x0=53, y0=102, x1=74, y1=117
	dl_value_glyph	glyph=62, x=96, y=2

; === COVER-R1 0xF3A0A5-0xF3A0D1 ===
; 0xF3A0A5-0xF3A0D0, coverage round 1: 33 of this span's 44 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 33 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3A0A5 -- 33 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3A0A5 appears as a 32-bit word at 0xF3912D 0xF3913E
;               0xF3914F 0xF39160 0xF39171 +4 more; converted code at 0xF7EC93
;               loads it as a 32-bit immediate.  No routine-directory slot and
;               no branch decoded in converted code names it.
; Measured: 61% printable ASCII; a linear decode runs 16 instructions and ends
;           `swi 2`, with 36% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F3A0A5:
	.byte	0x20, 0x52, 0x45, 0x43, 0x50, 0x4C, 0x41, 0x59, 0x20, 0x20, 0x20, 0x20, 0x20, 0x17, 0x25, 0x17	; F3A0A5  | RECPLAY     .%.|
	.byte	0x2A, 0x17, 0x2F, 0x17, 0x34, 0x17, 0x39, 0x17, 0x3E, 0x17, 0x43, 0x17, 0xF0, 0x1E, 0xF5, 0x1E	; F3A0B5  |*./.4.9.>.C.....|
	.byte	0xFA	; F3A0C5  |.|

; --- 0xF3A0C6-0xF3A0D0, 11 B, converted by lane promB6 (SHORTPROG).
;     a 16-bit table in strict +5 progression: 0x1EF0 0x1EF5 ... 0x1F13.  The
;     step is constant over the converted part and over the span, so the cut
;     is inside a single table
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x1E	; F3A0C6  high byte of the value at F3A0C5 = 0x1EFA
	.short	0x1EFF	; F3A0C7
	.short	0x1F04	; F3A0C9
	.short	0x1F09	; F3A0CB
	.short	0x1F0E	; F3A0CD
	.short	0x1F13	; F3A0CF

; === END COVER-R1 0xF3A0A5-0xF3A0D1 ===

; ------------------------------------------------------------------
; 0xF3A0D1-0xF3A0D8 -- 1 display-list records, 8 bytes -- interpreter A
;   entered at: 0xF3A0D1
;   ends used:  0xF3A0D9
; ------------------------------------------------------------------
DL_F3A0D1:
	dl_clear_area	x=0, y=148, w=320, h=75

; === COVER-R1 0xF3A0D9-0xF3A1CF ===
; ⚠ CLOSED 2026-09-02 (lane promB4).  The verdict below -- "everything
;   else is NOT reachable and stays `.incbin`" -- was true of the round-1
;   REACHABILITY WALK and false of the ROM: the remainder is display-list
;   operand arrays, reached by pointer from records the walk never enters
;   because nothing CALLS them.  0 bytes of this block are `.incbin` now.
;   Evidence and regeneration: notes/gen_prom_b_promB4_operand_arrays.py
; 0xF3A0D9-0xF3A1CE, coverage round 1: 10 of this span's 246 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 10 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3A0D9 -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3A0D9 appears as a 32-bit word at 0xF7E3AA 0xF7E3D6;
;               converted code at 0xF7E3A9 0xF7E3D5 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 0% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_tiny_records_batch.py: this object plus
; the .incbin that followed it is ONE interpreter-B record (verified against
; the ROM's own handler table, exactly one interpreter's implied-length rule fits).
Data_F3A0D9:
	.byte 0x03, 0x0B, 0xF6, 0x12, 0xFF, 0x00, 0x05, 0x4F, 0xA1, 0xF3, 0x00	; B op 03, 11 bytes -> handler HTBL_B[3]

; --------------------------------------------------------------------------
; Data_F3A0E4 -- 11 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ CORRECTED 2026-09-02 (lane promB4): this header said 5 bytes.
;   This object was the first 5 bytes of an 11-byte interpreter-B op-04
;   record; the .incbin behind it held the rest of the record and the two
;   operand arrays it and its neighbour 0xF3A0D9 name.
; Reached from: 0x00F3A0E4 appears as a 32-bit word at 0xF7E3E1; converted
;               code at 0xF7E3E0 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 20% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ==================================================================
; 0xF3A0E4-0xF3A1CE -- display-list RECORDS and the OPERAND ARRAYS they
;                    point at (235 bytes) -- converted 2026-09-02,
;                    lane promB4, notes/gen_prom_b_promB4_operand_arrays.py
; ==================================================================
;
; Right edge anchored on TrackGrid_DrawPartLabels_DL, a converted display-list span header;
; and the 6-byte array's end 0xF3A14F is named by the already-converted
; records at 0xF3A0D9, 0xF39000 and 0xF3900B.
;
; The 5 bytes previously typed here were the head of an 11-byte
; interpreter-B op-04 record; the .incbin held its remaining 6 bytes and
; the two arrays it and its neighbour 0xF3A0D9 name.
;
Data_F3A0E4:
	dlb_area_entry	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_ClearColumns, table=DLTable_F3A0EF

; ------------------------------------------------------------------
; DLTable_F3A0EF -- 16 entries of 6 bytes, 0xF3A0EF-0xF3A14E
; Referenced by: display-list record 0xF3A0E4
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3A0EF:
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
; DLTable_F3A14F -- 16 entries of 8 bytes, 0xF3A14F-0xF3A1CE
; Referenced by: display-list records 0xF39000, 0xF3900B, 0xF3A0D9
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3A14F:
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

; === END COVER-R1 0xF3A0D9-0xF3A1CF ===

; ------------------------------------------------------------------
; 0xF3A1CF-0xF3A432 -- 54 display-list records, 612 bytes -- interpreter A (37 records) and B (17)
;   entered at: 0xF3A1CF, 0xF3A2BF, 0xF3A40D, 0xF3A417, 0xF3A41F, 0xF3A429
;   ends used:  0xF3A2BF, 0xF3A40D, 0xF3A417, 0xF3A41F, 0xF3A429, 0xF3A433
; ------------------------------------------------------------------
TrackGrid_DrawPartLabels_DL:
; drawn (start operand) by TrackGrid_DrawPartLabels -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=8, y=175
	dlb_string	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=48, y=175
	dlb_string	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=88, y=175
	dlb_string	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=128, y=175
	dlb_string	var=DisplayListB_Stage+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=168, y=175
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=208, y=175
	dlb_string	var=DisplayListB_Stage+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=248, y=175
	dlb_string	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=288, y=175
	dlb_string	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=8, y=222
	dlb_string	var=DisplayListB_Stage+9, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=48, y=222
	dlb_string	var=DisplayListB_Stage+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=88, y=222
	dlb_string	var=DisplayListB_Stage+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=128, y=222
	dlb_string	var=DisplayListB_Stage+12, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=168, y=222
	dlb_string	var=DisplayListB_Stage+13, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=208, y=222
	dlb_string	var=DisplayListB_Stage+14, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=248, y=222
	dlb_string	var=DisplayListB_Stage+15, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Data_F39559 + 0x49, width=3, x=288, y=222
; DL_TrackAssignPresetsTechnicsSetUp1116 -- the display list at 0xF3A2BF.  Its
;                                           own text records read: "TRACK";
;                                           "ASSIGN"; "PRESETS"; "TECHNICS
;                                           SET-UP1 ( 1-16)"; "TECHNICS SET-
;                                           UP2 (17-32)"; "GM SET-UP"; "Any";
;                                           "existing" +9 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackAssignPresetsTechnicsSetUp1116:
	dl_text16x16_packed	x=48, y=7, text="TRACK"
	dl_text16x16_packed	x=114, y=7, text="ASSIGN"
	dl_text16x16_packed	x=192, y=7, text="PRESETS"
	dl_text8x16	x=0, y=37, text="\020"
	dl_text8x16	x=32, y=40, text="TECHNICS SET-UP1 ( 1-16)"
	dl_text8x16	x=0, y=73, text="\020"
	dl_text8x16	x=32, y=75, text="TECHNICS SET-UP2 (17-32)"
	dl_text8x16	x=0, y=108, text="\020"
	dl_text8x16	x=32, y=109, text="GM SET-UP"
	dl_text8x14	x=16, y=159, text="Any"
	dl_text8x14	x=48, y=159, text="existing"
	dl_text8x14	x=120, y=159, text="song"
	dl_text8x14	x=160, y=159, text="will"
	dl_text8x14	x=200, y=159, text="be"
	dl_text8x14	x=224, y=159, text="cleared."
	dl_text8x14	x=16, y=180, text="Press"
	dl_text8x14	x=72, y=180, text="0K"
	dl_text8x14	x=104, y=180, text="to"
	dl_text8x14	x=128, y=180, text="proceed."
	dl_text8x14	x=32, y=197, text="S0NG"
	dl_text8x14	x=72, y=197, text="N0"
	dl_text8x14	x=96, y=197, text="/ALL"
	dl_text8x14	x=56, y=219, text="<"
	dl_text8x14	x=96, y=219, text=">"
	dl_text8x14	x=208, y=221, text="0K"
	dl_box_shadow2	x0=18, y0=32, x1=241, y1=57
	dl_box_shadow2	x0=18, y0=67, x1=241, y1=93
	dl_box_shadow2	x0=18, y0=102, x1=241, y1=127
	dl_box_shadow2	x0=45, y0=211, x1=74, y1=235
	dl_box_shadow2	x0=85, y0=211, x1=114, y1=235
	dl_box	x0=68, y0=175, x1=93, y1=194
	dl_box	x0=70, y0=177, x1=91, y1=192
	dl_box	x0=203, y0=216, x1=229, y1=235
	dl_box	x0=205, y0=218, x1=227, y1=233
Paint_TrackAssignPresets_DL2:
; ; drawn (start operand) by Paint_TrackAssignPresets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_box	x0=30, y0=135, x1=85, y1=152
; DL_S0ng -- the display list at 0xF3A417.  Its own text records read: "S0NG".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_S0ng:
	dl_text8x14	x=32, y=139, text="S0NG"
; DL_All -- the display list at 0xF3A41F.  Its own text records read: "ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_All:
	dl_text8x14	x=32, y=139, text="  ALL "
Paint_TrackAssignPresets_DL1:
; ; drawn (start operand) by Paint_TrackAssignPresets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=64, y=139, digits=2

; === COVER-R1 0xF3A433-0xF3A461 ===
; 0xF3A433-0xF3A460, coverage round 1: 10 of this span's 46 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 10 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3A433 -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3A433 appears as a 32-bit word at 0xF7E64D 0xF7E77F;
;               converted code at 0xF7E64C 0xF7E77E loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 0% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_tiny_records_batch.py: this object plus
; the .incbin that followed it is ONE interpreter-B record (verified against
; the ROM's own handler table, exactly one interpreter's implied-length rule fits).
Data_F3A433:
	.byte 0x03, 0x0B, 0xF6, 0x12, 0xFF, 0x00, 0x05, 0x49, 0xA4, 0xF3, 0x00	; B op 03, 11 bytes -> handler HTBL_B[3]

; --------------------------------------------------------------------------
; Data_F3A43E -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3A43E appears as a 32-bit word at 0xF7E776; converted
;               code at 0xF7E775 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------

; ------------------------------------------------------------------
; 0xF3A43E-0xF3A460 -- 1 display-list record and its parameter array,
; 35 bytes -- interpreter B.  Formerly Data_F3A43E (5 bytes) plus the
; 30-byte `.incbin` that followed it.
;
; THE START IS NAMED BY CODE: prom_b 0xF7E775 does
; `ld XIY,0x00f3a43e` / `call 0xf41820`, and T_DLB_Handler_Array8_2 is `jp 0xF31B57`,
; the opcode-03/08 handler -- the record is handed to its handler
; directly, with no interpreter loop to mis-frame it.  Its neighbour
; Data_F3A433 goes to the same handler from 0xF7E77E.
; BOTH records carry `.long 0x00F3A449`; handler 0xF31B57 does
; `sla 0x03,HL` and reads (XIX+0/2/4/6), so entries are 8 bytes.
; THE END is DL_F3A461, a display-list start loaded by 7 `ld XIY`
; sites, so the array is exactly 3 entries.
; Verify: python3 notes/gen_prom_b_res3xx_spans.py --selftest
; ------------------------------------------------------------------
TrackAssignPresets_MoveFieldHighlight_DL:
; drawn (start operand) by TrackAssignPresets_MoveFieldHighlight -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_rect_entry_op08	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_EraseRect, table=DLTable_F3A449

; ------------------------------------------------------------------
; DLTable_F3A449 -- 3 entries of 8 bytes (24 bytes).
; Referenced by interpreter-B display-list record 0xF3A43E, whose +7
; pointer lands here and whose handler fixes the entry size.  3 entries is the
; EXTENT (24 / 8), bounded by DL_F3A461; the records' mask 0xFF would
; allow up to 256.  Records 0xF3A433 and 0xF3A43E share this array.
; ------------------------------------------------------------------
DLTable_F3A449:
	.short 0x0013, 0x0021, 0x00EF, 0x0037	; [0]
	.short 0x0013, 0x0044, 0x00EF, 0x005B	; [1]
	.short 0x0013, 0x0067, 0x00EF, 0x007D	; [2]


; === END COVER-R1 0xF3A433-0xF3A461 ===

; ------------------------------------------------------------------
; 0xF3A461-0xF3A589 -- 31 display-list records, 297 bytes -- interpreter A (27 records) and B (4)
;   entered at: 0xF3A461, 0xF3A47F, 0xF3A526, 0xF3A561
;   ends used:  0xF3A47F, 0xF3A526, 0xF3A561, 0xF3A57F, 0xF3A58A
; ------------------------------------------------------------------
; DL_AreYouSure -- the display list at 0xF3A461.  Its own text records read:
;                  "Are You Sure ?".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_AreYouSure:
	dl_text16x16_packed	x=81, y=202, text="Are You Sure ?"
	dl_box_shadow2	x0=73, y0=189, x1=243, y1=228
; DL_TrackMergeOkTrackTrackTrack -- the display list at 0xF3A47F.  Its own
;                                   text records read: "TRACK MERGE"; "OK";
;                                   "TRACK  :"; "TRACK  :"; "TRACK  :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackMergeOkTrackTrackTrack:
	dl_text16x16_packed	x=113, y=6, text="TRACK MERGE"
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x14	x=288, y=75, text="OK"
	dl_text8x16	x=32, y=77, text="TRACK  :  "
	dl_text8x16	x=0, y=78, text="\020"
	dl_text8x16	x=184, y=113, text="TRACK  :  "
	dl_text8x16	x=312, y=113, text="\021"
	dl_text8x16	x=0, y=148, text="\020"
	dl_text8x16	x=32, y=148, text="TRACK  :  "
	dl_text8x8_packed	x=172, y=115, text="\021"
	dl_box_shadow2	x0=22, y0=64, x1=138, y1=100
	dl_box_shadow2	x0=177, y0=100, x1=294, y1=136
	dl_box_shadow2	x0=22, y0=135, x1=138, y1=171
	dl_hline	x0=138, y0=84, x1=155, y1=84
	dl_hline	x0=155, y0=118, x1=177, y1=118
	dl_hline	x0=138, y0=154, x1=155, y1=154
	dl_vline	x0=155, y0=84, x1=155, y1=154
	dl_value_glyph	glyph=67, x=80, y=2
; DL_Track -- the display list at 0xF3A526.  Its own text records read:
;             "TRACK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Track:
	dl_text8x14	x=160, y=198, text="TRACK"
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box	x0=283, y0=70, x1=309, y1=89
	dl_box	x0=285, y0=72, x1=307, y1=87
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3A561:
	dlb_number	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=112, y=77, digits=2
	dlb_number	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=112, y=148, digits=2
	dlb_number	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=264, y=113, digits=2
	dlb_rect_entry	var=DisplayListB_Stage+3, mask=0x03, shift=0, svc=LCDSVC_FillRect, table=DLTable_F3A58A

; ==================================================================
; 0xF3A58A-0xF3A5A9 -- display-list OPERAND TABLES (32 bytes, 1 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F3A58A -- 4 entries of 8 bytes
; Referenced by: display-list record 0xF3A57F
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           4 entries is the EXTENT (32 bytes / 8), not the (mask >> shift) + 1
;           = 4 the record would allow.
; ------------------------------------------------------------------
DLTable_F3A58A:
	.short 0x0000, 0x0000, 0x0001, 0x0001	; [0]
	.short 0x0016, 0x0040, 0x008A, 0x0064	; [1]
	.short 0x0016, 0x0087, 0x008A, 0x00AB	; [2]
	.short 0x00B1, 0x0064, 0x0126, 0x0088	; [3]

; ------------------------------------------------------------------
; 0xF3A5AA-0xF3A6D8 -- 31 display-list records, 303 bytes -- interpreter A (27 records) and B (4)
;   entered at: 0xF3A5AA, 0xF3A5E9, 0xF3A66E, 0xF3A6AB
;   ends used:  0xF3A5E9, 0xF3A66E, 0xF3A6AB, 0xF3A6CE, 0xF3A6D9
; ------------------------------------------------------------------
Paint_TrackMerge_DL:
; ; drawn (start operand) by Paint_TrackMerge -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=280, y=74, text="YES"
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x16	x=312, y=152, text="\021"
	dl_text8x14	x=280, y=153, text="NO"
	dl_box	x0=276, y0=69, x1=308, y1=88
	dl_box	x0=278, y0=71, x1=306, y1=86
	dl_box	x0=276, y0=148, x1=308, y1=167
	dl_box	x0=278, y0=150, x1=306, y1=165
; DL_MeasureDeleteTrackFirstMeasure -- the display list at 0xF3A5E9.  Its own
;                                      text records read: "MEASURE DELETE";
;                                      "TRACK           :"; "FIRST MEASURE
;                                      :"; "LAST MEASURE    :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MeasureDeleteTrackFirstMeasure:
	dl_text16x16_packed	x=97, y=6, text="MEASURE DELETE"
	dl_text8x16	x=0, y=77, text="\020"
	dl_text8x16	x=24, y=77, text="TRACK           :"
	dl_text8x16	x=0, y=113, text="\020"
	dl_text8x16	x=24, y=113, text="FIRST MEASURE   :"
	dl_text8x16	x=0, y=149, text="\020"
	dl_text8x16	x=24, y=149, text="LAST MEASURE    :"
	dl_box_shadow2	x0=11, y0=67, x1=223, y1=98
	dl_box_shadow2	x0=11, y0=103, x1=223, y1=134
	dl_box_shadow2	x0=11, y0=139, x1=223, y1=170
	dl_value_glyph	glyph=71, x=64, y=1
Paint_MeasureDelete_DL:
; ; drawn (start operand) by Paint_MeasureDelete -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x16	x=312, y=113, text="\021"
	dl_text8x14	x=288, y=114, text="OK"
	dl_box	x0=284, y0=109, x1=308, y1=128
	dl_box	x0=286, y0=111, x1=306, y1=126
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
; DL_LastMeasure -- the display list at 0xF3A6AB, named by mechanism M3 of
;                   notes/prom_b_dl_screens_round5.py.  "LAST MEASURE    :"
;                   ends at 0x175C
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_LastMeasure:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16MasterAll, width=6, x=160, y=77
	dlb_number16	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=113, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=149, digits=3
	dlb_rect_entry	var=DisplayListB_Stage+5, mask=0x03, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3A6D9

; === COVER-R1 0xF3A6D9-0xF3A7DA ===
; 0xF3A6D9-0xF3A7D9, coverage round 1: 257 of this span's 257 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 257 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3A6D9-0xF3A7D9 -- 257 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3A6D9 appears as a 32-bit word at 0xF3A6D5 0xF7EFEE;
;               converted code at 0xF7EFED loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 89% printable ASCII; a linear decode runs 114 instructions and
;           ends `pop IX`, with 9% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3A6D9 -- 0xF3A6D9-0xF3A6F8, 4 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3A6CE ((0x12FB)
;   AND 0x03 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the next table over the width; the masks admit 4.  This
;   address is also the END of a display list: `ld XIY,0xF3A6AB / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF7EFED.
; --------------------------------------------------------------------------
DLBoxes_F3A6D9:
	.short	0, 0, 1, 1	; F3A6D9  [0]
	.short	11, 67, 223, 98	; F3A6E1  [1]
	.short	11, 103, 223, 134	; F3A6E9  [2]
	.short	11, 139, 223, 170	; F3A6F1  [3]
; --------------------------------------------------------------------------
; DLText_0To16All -- 0xF3A6F9-0xF3A72E, 18 entries of 3 bytes, text drawn by
;   LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02 records at
;   0xF3AB3B ((0x12F6) AND 0x1F >> 0), 0xF3ACF0 ((0x12F6) AND 0x1F >> 0),
;   0xF3AFE7 ((0x12F6) AND 0x1F >> 0), 0xF3B1E3 ((0x12F6) AND 0xFF >> 0) and
;   1 more -- value = (byte at the +2 address) AND mask >> shift -- whose
;   +0x07 names this address; DLB_Handler_StringTable draws entry [value]
;   with +0x0B = 3 as the width.  Entry count: the distance to the next
;   table over the width; the masks admit 256.
; --------------------------------------------------------------------------
DLText_0To16All:
	.ascii	"  0"	; F3A6F9  [0]
	.ascii	"  1"	; F3A6FC  [1]
	.ascii	"  2"	; F3A6FF  [2]
	.ascii	"  3"	; F3A702  [3]
	.ascii	"  4"	; F3A705  [4]
	.ascii	"  5"	; F3A708  [5]
	.ascii	"  6"	; F3A70B  [6]
	.ascii	"  7"	; F3A70E  [7]
	.ascii	"  8"	; F3A711  [8]
	.ascii	"  9"	; F3A714  [9]
	.ascii	" 10"	; F3A717  [10]
	.ascii	" 11"	; F3A71A  [11]
	.ascii	" 12"	; F3A71D  [12]
	.ascii	" 13"	; F3A720  [13]
	.ascii	" 14"	; F3A723  [14]
	.ascii	" 15"	; F3A726  [15]
	.ascii	" 16"	; F3A729  [16]
	.ascii	"ALL"	; F3A72C  [17]
; --------------------------------------------------------------------------
; DLText_0To16MasterAll -- 0xF3A72F-0xF3A7A0, 19 entries of 6 bytes, text
;   drawn by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02
;   records at 0xF3A6AB ((0x12F6) AND 0x1F >> 0), 0xF3A9DA ((0x12F6) AND
;   0x1F >> 0), 0xF3BD07 ((0x12F6) AND 0x1F >> 0), 0xF3BD16 ((0x12FB) AND
;   0x1F >> 0) and 2 more -- value = (byte at the +2 address) AND mask >>
;   shift -- whose +0x07 names this address; DLB_Handler_StringTable draws
;   entry [value] with +0x0B = 6 as the width.  Entry count: the distance to
;   the next table over the width; the masks admit 32.
; --------------------------------------------------------------------------
DLText_0To16MasterAll:
	.ascii	"  0   "	; F3A72F  [0]
	.ascii	"  1   "	; F3A735  [1]
	.ascii	"  2   "	; F3A73B  [2]
	.ascii	"  3   "	; F3A741  [3]
	.ascii	"  4   "	; F3A747  [4]
	.ascii	"  5   "	; F3A74D  [5]
	.ascii	"  6   "	; F3A753  [6]
	.ascii	"  7   "	; F3A759  [7]
	.ascii	"  8   "	; F3A75F  [8]
	.ascii	"  9   "	; F3A765  [9]
	.ascii	" 10   "	; F3A76B  [10]
	.ascii	" 11   "	; F3A771  [11]
	.ascii	" 12   "	; F3A777  [12]
	.ascii	" 13   "	; F3A77D  [13]
	.ascii	" 14   "	; F3A783  [14]
	.ascii	" 15   "	; F3A789  [15]
	.ascii	" 16   "	; F3A78F  [16]
	.ascii	"MASTER"	; F3A795  [17]
	.ascii	"ALL   "	; F3A79B  [18]
; --------------------------------------------------------------------------
; DLText_0To17All -- 0xF3A7A1-0xF3A7D9, 19 entries of 3 bytes, text drawn by
;   LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02 records at
;   0xF3C17B ((0x1304) AND 0x7F >> 0), 0xF3C18A ((0x1305) AND 0xFF >> 0) --
;   value = (byte at the +2 address) AND mask >> shift -- whose +0x07 names
;   this address; DLB_Handler_StringTable draws entry [value] with +0x0B = 3
;   as the width.  Entry count: the distance to the object's end over the
;   width; the masks admit 256.
; --------------------------------------------------------------------------
DLText_0To17All:
	.ascii	"  0"	; F3A7A1  [0]
	.ascii	"  1"	; F3A7A4  [1]
	.ascii	"  2"	; F3A7A7  [2]
	.ascii	"  3"	; F3A7AA  [3]
	.ascii	"  4"	; F3A7AD  [4]
	.ascii	"  5"	; F3A7B0  [5]
	.ascii	"  6"	; F3A7B3  [6]
	.ascii	"  7"	; F3A7B6  [7]
	.ascii	"  8"	; F3A7B9  [8]
	.ascii	"  9"	; F3A7BC  [9]
	.ascii	" 10"	; F3A7BF  [10]
	.ascii	" 11"	; F3A7C2  [11]
	.ascii	" 12"	; F3A7C5  [12]
	.ascii	" 13"	; F3A7C8  [13]
	.ascii	" 14"	; F3A7CB  [14]
	.ascii	" 15"	; F3A7CE  [15]
	.ascii	" 16"	; F3A7D1  [16]
	.ascii	" 17"	; F3A7D4  [17]
	.ascii	"ALL"	; F3A7D7  [18]

; === END COVER-R1 0xF3A6D9-0xF3A7DA ===

; ------------------------------------------------------------------
; 0xF3A7DA-0xF3AA16 -- 57 display-list records, 573 bytes -- interpreter A (52 records) and B (5)
;   entered at: 0xF3A7DA, 0xF3A8F5, 0xF3A99D, 0xF3A9DA
;   ends used:  0xF3A8F5, 0xF3A99D, 0xF3A9DA, 0xF3AA0C, 0xF3AA17
; ------------------------------------------------------------------
DL_F3A7DA:
	dl_text8x14	x=280, y=112, text="YES"
	dl_text8x16	x=312, y=112, text="\021"
	dl_text8x16	x=312, y=150, text="\021"
	dl_text8x14	x=280, y=151, text="NO"
	dl_box	x0=276, y0=107, x1=308, y1=126
	dl_box	x0=278, y0=109, x1=306, y1=124
	dl_box	x0=276, y0=146, x1=308, y1=165
	dl_box	x0=278, y0=148, x1=306, y1=163
	dl_hline	x0=313, y0=115, x1=316, y1=115
	dl_hline	x0=313, y0=116, x1=317, y1=116
	dl_hline	x0=313, y0=117, x1=318, y1=117
	dl_hline	x0=313, y0=118, x1=318, y1=118
	dl_hline	x0=313, y0=119, x1=317, y1=119
	dl_hline	x0=313, y0=120, x1=316, y1=120
	dl_hline	x0=313, y0=153, x1=316, y1=153
	dl_hline	x0=313, y0=154, x1=317, y1=154
	dl_hline	x0=313, y0=155, x1=318, y1=155
	dl_hline	x0=313, y0=156, x1=318, y1=156
	dl_hline	x0=313, y0=157, x1=317, y1=157
	dl_hline	x0=313, y0=158, x1=316, y1=158
	dl_vline	x0=313, y0=112, x1=313, y1=123
	dl_vline	x0=313, y0=150, x1=313, y1=161
	dl_vline	x0=314, y0=113, x1=314, y1=122
	dl_vline	x0=314, y0=151, x1=314, y1=160
	dl_vline	x0=315, y0=114, x1=315, y1=121
	dl_vline	x0=315, y0=152, x1=315, y1=159
	dl_vline	x0=316, y0=115, x1=316, y1=120
	dl_vline	x0=316, y0=153, x1=316, y1=158
	dl_vline	x0=317, y0=116, x1=317, y1=119
	dl_vline	x0=317, y0=154, x1=317, y1=157
; DL_MeasureEraseTrackFirstMeasure -- the display list at 0xF3A8F5.  Its own
;                                     text records read: "MEASURE ERASE";
;                                     "TRACK           :"; "FIRST MEASURE
;                                     :"; "LAST MEASURE    :"; "ERASE DATA
;                                     :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MeasureEraseTrackFirstMeasure:
	dl_text16x16_packed	x=95, y=6, text="MEASURE ERASE"
	dl_text8x16	x=0, y=41, text="\020"
	dl_text8x16	x=24, y=41, text="TRACK           :"
	dl_text8x16	x=0, y=77, text="\020"
	dl_text8x16	x=24, y=77, text="FIRST MEASURE   :"
	dl_text8x16	x=0, y=113, text="\020"
	dl_text8x16	x=24, y=113, text="LAST MEASURE    :"
	dl_text8x16	x=0, y=150, text="\020"
	dl_text8x16	x=24, y=151, text="ERASE DATA      :"
	dl_box_shadow2	x0=11, y0=31, x1=223, y1=62
	dl_box_shadow2	x0=11, y0=67, x1=223, y1=98
	dl_box_shadow2	x0=11, y0=103, x1=223, y1=134
	dl_box_shadow2	x0=11, y0=140, x1=223, y1=171
	dl_value_glyph	glyph=70, x=64, y=1
Paint_MeasureErase_DL:
; ; drawn (start operand) by Paint_MeasureErase -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x14	x=288, y=75, text="OK"
	dl_box	x0=284, y0=70, x1=308, y1=89
	dl_box	x0=286, y0=72, x1=306, y1=87
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3A9DA:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16MasterAll, width=6, x=160, y=41
	dlb_string	var=DisplayListB_Stage+5, mask=0x03, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_AllNoteControl, width=7, x=160, y=151
	dlb_number16	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=77, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=113, digits=3
	dlb_rect_entry	var=DisplayListB_Stage+6, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3AA17

; === COVER-R1 0xF3AA17-0xF3AA54 ===
; 0xF3AA17-0xF3AA53, coverage round 1: 61 of this span's 61 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 61 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3AA17-0xF3AA53 -- 61 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3AA17 appears as a 32-bit word at 0xF3AA13 0xF7F2C9;
;               converted code at 0xF7F2C8 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 41% printable ASCII; a linear decode runs 39 instructions and ends
;           `pop IX`, with 30% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3AA17 -- 0xF3AA17-0xF3AA3E, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3AA0C ((0x12FC)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the next table over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3A9DA / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF7F2C8.
; --------------------------------------------------------------------------
DLBoxes_F3AA17:
	.short	0, 0, 1, 1	; F3AA17  [0]
	.short	11, 31, 223, 62	; F3AA1F  [1]
	.short	11, 67, 223, 98	; F3AA27  [2]
	.short	11, 103, 223, 134	; F3AA2F  [3]
	.short	11, 140, 223, 171	; F3AA37  [4]
; --------------------------------------------------------------------------
; DLText_AllNoteControl -- 0xF3AA3F-0xF3AA53, 3 entries of 7 bytes, text
;   drawn by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02
;   record at 0xF3A9E9 ((0x12FB) AND 0x03 >> 0) -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 7 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 4.
; --------------------------------------------------------------------------
DLText_AllNoteControl:
	.ascii	"ALL    "	; F3AA3F  [0]
	.ascii	"NOTE   "	; F3AA46  [1]
	.ascii	"CONTROL"	; F3AA4D  [2]

; === END COVER-R1 0xF3AA17-0xF3AA54 ===

; ------------------------------------------------------------------
; 0xF3AA54-0xF3AB73 -- 27 display-list records, 288 bytes -- interpreter A (22 records) and B (5)
;   entered at: 0xF3AA54, 0xF3AB3B
;   ends used:  0xF3AAFE, 0xF3AB3B, 0xF3AB69, 0xF3AB74
; ------------------------------------------------------------------
; DL_Vel0cityChangeTrackFirstMeasure -- the display list at 0xF3AA54.  Its own
;                                       text records read: "VEL0CITY CHANGE";
;                                       "TRACK           :"; "FIRST MEASURE
;                                       :"; "LAST MEASURE    :"; "VELOCITY
;                                       :"; "OK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Vel0cityChangeTrackFirstMeasure:
	dl_text16x16_packed	x=94, y=7, text="VEL0CITY CHANGE"
	dl_text8x16	x=0, y=42, text="\020"
	dl_text8x16	x=24, y=42, text="TRACK           :"
	dl_text8x16	x=0, y=78, text="\020"
	dl_text8x16	x=24, y=78, text="FIRST MEASURE   :"
	dl_text8x16	x=0, y=114, text="\020"
	dl_text8x16	x=24, y=114, text="LAST MEASURE    :"
	dl_text8x16	x=0, y=150, text="\020"
	dl_text8x16	x=24, y=151, text="VELOCITY        :"
	dl_box_shadow2	x0=11, y0=32, x1=223, y1=63
	dl_box_shadow2	x0=11, y0=68, x1=223, y1=99
	dl_box_shadow2	x0=11, y0=104, x1=223, y1=135
	dl_box_shadow2	x0=11, y0=140, x1=223, y1=171
	dl_value_glyph	glyph=8, x=64, y=1
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x14	x=288, y=74, text="OK"
	dl_box	x0=283, y0=69, x1=309, y1=88
	dl_box	x0=285, y0=71, x1=307, y1=86
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3AB3B:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16All, width=3, x=160, y=42
	dlb_number16	var=DisplayListB_Stage+1, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=78, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=114, digits=3
	dlb_number_signed	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=151, digits=3, signflag=0x00
	dlb_rect_entry	var=DisplayListB_Stage+6, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3AB74

; === COVER-R1 0xF3AB74-0xF3AB9C ===
; 0xF3AB74-0xF3AB9B, coverage round 1: 40 of this span's 40 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 40 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3AB74-0xF3AB9B -- 40 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3AB74 appears as a 32-bit word at 0xF3AB70 0xF7F929;
;               converted code at 0xF7F928 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 12% printable ASCII; a linear decode runs 25 instructions and ends
;           `db`, with 35% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3AB74 -- 0xF3AB74-0xF3AB9B, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3AB69 ((0x12FC)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the object's end over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3AB3B / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF7F928.
; --------------------------------------------------------------------------
DLBoxes_F3AB74:
	.short	0, 0, 1, 1	; F3AB74  [0]
	.short	11, 32, 223, 63	; F3AB7C  [1]
	.short	11, 68, 223, 99	; F3AB84  [2]
	.short	11, 104, 223, 135	; F3AB8C  [3]
	.short	11, 140, 223, 171	; F3AB94  [4]

; === END COVER-R1 0xF3AB74-0xF3AB9C ===

; ------------------------------------------------------------------
; 0xF3AB9C-0xF3AD41 -- 45 display-list records, 422 bytes -- interpreter A (38 records) and B (7)
;   entered at: 0xF3AB9C, 0xF3ABDB, 0xF3ACB3, 0xF3ACF0
;   ends used:  0xF3ABDB, 0xF3ACB3, 0xF3ACF0, 0xF3AD37, 0xF3AD42
; ------------------------------------------------------------------
DL_F3AB9C:
	dl_text8x14	x=280, y=73, text="YES"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=312, y=111, text="\021"
	dl_text8x14	x=280, y=112, text="NO"
	dl_box	x0=276, y0=68, x1=308, y1=87
	dl_box	x0=278, y0=70, x1=306, y1=85
	dl_box	x0=276, y0=107, x1=308, y1=126
	dl_box	x0=278, y0=109, x1=306, y1=124
; DL_QuantizeTrackStrengthFirstMeasure -- the display list at 0xF3ABDB.  Its
;                                         own text records read: "QUANTIZE";
;                                         "TRACK         :"; "STRENGTH :";
;                                         "FIRST MEASURE :"; "WINDOW  :";
;                                         "LAST MEASURE  :"; "VALUE:".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_QuantizeTrackStrengthFirstMeasure:
	dl_text16x16_packed	x=119, y=5, text="QUANTIZE"
	dl_text8x16	x=16, y=40, text="TRACK         :"
	dl_text8x16	x=176, y=40, text="STRENGTH :"
	dl_text8x16	x=280, y=40, text=" %"
	dl_text8x16	x=0, y=41, text="\020"
	dl_text8x16	x=312, y=42, text="\021"
	dl_text8x16	x=16, y=76, text="FIRST MEASURE :"
	dl_text8x16	x=176, y=76, text="WINDOW  :"
	dl_text8x16	x=280, y=76, text=" %"
	dl_text8x16	x=0, y=77, text="\020"
	dl_text8x16	x=312, y=78, text="\021"
	dl_text8x16	x=16, y=112, text="LAST MEASURE  :"
	dl_text8x16	x=0, y=113, text="\020"
	dl_text8x16	x=0, y=149, text="\020"
	dl_text8x16	x=16, y=149, text="VALUE: "
	dl_box_shadow2	x0=11, y0=29, x1=162, y1=60
	dl_box_shadow2	x0=170, y0=29, x1=307, y1=60
	dl_box_shadow2	x0=11, y0=65, x1=162, y1=96
	dl_box_shadow2	x0=170, y0=65, x1=307, y1=96
	dl_box_shadow2	x0=11, y0=101, x1=162, y1=132
	dl_box_shadow2	x0=11, y0=138, x1=162, y1=169
	dl_value_glyph	glyph=59, x=96, y=2
Paint_Quantize_DL:
; ; drawn (start operand) by Paint_Quantize -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x16	x=312, y=113, text="\021"
	dl_text8x14	x=288, y=114, text="OK"
	dl_box	x0=283, y0=109, x1=309, y1=128
	dl_box	x0=285, y0=111, x1=307, y1=126
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
; DL_TrackValueFirstMeasureLastMeasureStrengthWindow -- the display list at
;                                                       0xF3ACF0, named by
;                                                       mechanism M3 of notes/
;                                                       prom_b_dl_screens_roun
;                                                       d5.py.  "TRACK
;                                                       :" ends at 0x0651
;                                                       "VALUE:" ends at
;                                                       0x1751  "FIRST MEASURE
;                                                       :" ends at 0x0BF1
;                                                       "LAST MEASURE  :" ends
;                                                       at 0x1191  "STRENGTH
;                                                       :" ends at 0x0660
;                                                       "WINDOW  :" ends at
;                                                       0x0BFF
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_TrackValueFirstMeasureLastMeasureStrengthWindow:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16All, width=3, x=136, y=40
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_GlyphPairs_F3AD7A, width=2, x=72, y=149
	dlb_number16	var=DisplayListB_Stage+1, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=136, y=76, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=136, y=112, digits=3
	dlb_number	var=DisplayListB_Stage+6, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x16, x=256, y=40, digits=3
	dlb_number_signed	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=248, y=76, digits=3, signflag=0x00
	dlb_rect_entry	var=DisplayListB_Stage+8, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3AD42

; === COVER-R1 0xF3AD42-0xF3AD88 ===
; 0xF3AD42-0xF3AD87, coverage round 1: 70 of this span's 70 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 70 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3AD42-0xF3AD87 -- 70 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3AD42 appears as a 32-bit word at 0xF3AD3E 0xF7F5F7;
;               converted code at 0xF7F5F6 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 19% printable ASCII; a linear decode runs 42 instructions and ends
;           `db`, with 31% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3AD42 -- 0xF3AD42-0xF3AD79, 7 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3AD37 ((0x12FE)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the next table over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3ACF0 / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF7F5F6.
; --------------------------------------------------------------------------
DLBoxes_F3AD42:
	.short	0, 0, 1, 1	; F3AD42  [0]
	.short	11, 29, 162, 60	; F3AD4A  [1]
	.short	11, 65, 162, 96	; F3AD52  [2]
	.short	11, 101, 162, 132	; F3AD5A  [3]
	.short	11, 138, 162, 169	; F3AD62  [4]
	.short	170, 29, 307, 60	; F3AD6A  [5]
	.short	170, 65, 307, 96	; F3AD72  [6]
; --------------------------------------------------------------------------
; DLText_GlyphPairs_F3AD7A -- 0xF3AD7A-0xF3AD87, 7 entries of 2 bytes, text
;   drawn by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02
;   record at 0xF3ACFF ((0x12FB) AND 0xFF >> 0) -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 2 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 256.
; --------------------------------------------------------------------------
DLText_GlyphPairs_F3AD7A:
	.byte	0x15, 0x20	; F3AD7A  [0]  "<15> "
	.byte	0x16, 0x20	; F3AD7C  [1]  "<16> "
	.byte	0x17, 0x20	; F3AD7E  [2]  "<17> "
	.byte	0x18, 0x20	; F3AD80  [3]  "<18> "
	.byte	0x16, 0x1F	; F3AD82  [4]  "<16><1F>"
	.byte	0x17, 0x1F	; F3AD84  [5]  "<17><1F>"
	.byte	0x18, 0x1F	; F3AD86  [6]  "<18><1F>"

; === END COVER-R1 0xF3AD42-0xF3AD88 ===

; ------------------------------------------------------------------
; 0xF3AD88-0xF3B064 -- 61 display-list records, 733 bytes -- interpreter A (51 records) and B (10)
;   entered at: 0xF3AD88, 0xF3AEAF, 0xF3AFAF, 0xF3AFE7
;   ends used:  0xF3AEAF, 0xF3AFAF, 0xF3AFE7, 0xF3B05A, 0xF3B065
; ------------------------------------------------------------------
; DL_PanelWritePanelWriteReplacesTheSoundsAnd -- the display list at 0xF3AD88.
;                                                Its own text records read:
;                                                "PANEL WRITE"; "PANEL WRITE
;                                                replaces the sounds and";
;                                                "settings at the beginning of
;                                                your"; "song,which are
;                                                selected when"; "you press
;                                                SEQUENCER RESET"; "Make the
;                                                desired changes and press";
;                                                "to store your new
;                                                settings."; "OK" +1 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_PanelWritePanelWriteReplacesTheSoundsAnd:
	dl_text16x16_packed	x=120, y=6, text="PANEL WRITE"
	dl_text8x16	x=16, y=44, text="PANEL WRITE replaces the sounds and"
	dl_text8x16	x=16, y=65, text="settings at the beginning of your"
	dl_text8x16	x=16, y=86, text="song,which are selected when"
	dl_text8x16	x=16, y=106, text="you press SEQUENCER RESET"
	dl_text8x16	x=216, y=107, text="."
	dl_text8x16	x=16, y=147, text="Make the desired changes and press"
	dl_text8x16	x=56, y=167, text="to store your new settings."
	dl_text8x14	x=24, y=169, text="OK"
	dl_text8x14	x=256, y=222, text="OK"
	dl_box_shadow2	x0=6, y0=34, x1=305, y1=201
	dl_box	x0=20, y0=164, x1=45, y1=183
	dl_box	x0=22, y0=166, x1=43, y1=181
	dl_box	x0=251, y0=217, x1=276, y1=236
	dl_box	x0=253, y0=219, x1=274, y1=234
	dl_value_glyph	glyph=68, x=88, y=1
; DL_N0teChangeTargetNoteTrack -- the display list at 0xF3AEAF.  Its own text
;                                 records read: "N0TE CHANGE"; "TARGET NOTE";
;                                 "TRACK         :"; "CHANGE TO"; "FIRST
;                                 MEASURE :"; "LAST MEASURE  :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_N0teChangeTargetNoteTrack:
	dl_text16x16_packed	x=113, y=6, text="N0TE CHANGE"
	dl_text8x16	x=192, y=67, text="TARGET NOTE"
	dl_text8x16	x=0, y=73, text="\020"
	dl_text8x16	x=16, y=73, text="TRACK         :"
	dl_text8x16	x=312, y=75, text="\021"
	dl_text8x16	x=208, y=81, text=":"
	dl_text8x16	x=248, y=81, text=" ("
	dl_text8x16	x=288, y=81, text=")"
	dl_text8x16	x=192, y=106, text="CHANGE TO"
	dl_text8x16	x=16, y=113, text="FIRST MEASURE :"
	dl_text8x16	x=0, y=114, text="\020"
	dl_text8x16	x=312, y=114, text="\021"
	dl_text8x16	x=208, y=121, text=":"
	dl_text8x16	x=248, y=121, text=" ("
	dl_text8x16	x=288, y=121, text=")"
	dl_text8x16	x=312, y=152, text="\021"
	dl_text8x16	x=16, y=153, text="LAST MEASURE  :"
	dl_text8x16	x=0, y=154, text="\020"
	dl_text8x8_packed	x=182, y=117, text="\021"
	dl_box_shadow2	x0=10, y0=62, x1=166, y1=93
	dl_box_shadow2	x0=187, y0=62, x1=305, y1=96
	dl_box_shadow2	x0=10, y0=103, x1=166, y1=133
	dl_box_shadow2	x0=187, y0=102, x1=305, y1=136
	dl_box_shadow2	x0=10, y0=143, x1=166, y1=174
	dl_value_glyph	glyph=63, x=88, y=1
	dl_hline	x0=179, y0=79, x1=187, y1=79
	dl_hline	x0=179, y0=120, x1=187, y1=120
	dl_vline	x0=179, y0=79, x1=179, y1=120
Paint_N0teChange_DL1:
; ; drawn (start operand) by Paint_N0teChange -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=288, y=153, text="OK"
	dl_box	x0=284, y0=148, x1=308, y1=167
	dl_box	x0=286, y0=150, x1=306, y1=165
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3AFE7:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16All, width=3, x=136, y=73
	dlb_string	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_NoteNamesInOctave, width=2, x=216, y=80
	dlb_string	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_OctavesMinus2To8, width=2, x=232, y=80
	dlb_string	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_NoteNamesInOctave, width=2, x=216, y=120
	dlb_string	var=DisplayListB_Stage+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_OctavesMinus2To8, width=2, x=232, y=120
	dlb_number	var=DisplayListB_Stage+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x16, x=264, y=80, digits=3
	dlb_number16	var=DisplayListB_Stage+6, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=136, y=113, digits=3
	dlb_number	var=DisplayListB_Stage+8, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x16, x=264, y=120, digits=3
	dlb_number16	var=DisplayListB_Stage+9, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=136, y=153, digits=3
	dlb_rect_entry	var=DisplayListB_Stage+11, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3B065

; === COVER-R1 0xF3B065-0xF3B0C3 ===
; 0xF3B065-0xF3B0C2, coverage round 1: 94 of this span's 94 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 94 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3B065-0xF3B0C2 -- 94 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3B065 appears as a 32-bit word at 0xF3B061.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 52% printable ASCII; a linear decode runs 44 instructions and ends
;           `ld W,0x00`, with 24% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3B065 -- 0xF3B065-0xF3B094, 6 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3B05A ((0x1301)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the next table over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3AFE7 / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF804DF.
; --------------------------------------------------------------------------
DLBoxes_F3B065:
	.short	0, 0, 1, 1	; F3B065  [0]
	.short	10, 62, 166, 93	; F3B06D  [1]
	.short	10, 103, 166, 133	; F3B075  [2]
	.short	10, 143, 166, 174	; F3B07D  [3]
	.short	187, 62, 305, 96	; F3B085  [4]
	.short	187, 102, 305, 136	; F3B08D  [5]
; --------------------------------------------------------------------------
; DLText_NoteNamesInOctave -- 0xF3B095-0xF3B0AC, 12 entries of 2 bytes, text
;   drawn by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02
;   records at 0xF3AFF6 ((0x12F7) AND 0xFF >> 0), 0xF3B014 ((0x12F9) AND
;   0xFF >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_StringTable draws entry
;   [value] with +0x0B = 2 as the width.  Entry count: the distance to the
;   next table over the width; the masks admit 256.
; --------------------------------------------------------------------------
DLText_NoteNamesInOctave:
	.ascii	" C"	; F3B095  [0]
	.byte	0x44, 0x88	; F3B097  [1]  "D<88>"
	.ascii	" D"	; F3B099  [2]
	.byte	0x45, 0x88	; F3B09B  [3]  "E<88>"
	.ascii	" E"	; F3B09D  [4]
	.ascii	" F"	; F3B09F  [5]
	.byte	0x46, 0x8C	; F3B0A1  [6]  "F<8C>"
	.ascii	" G"	; F3B0A3  [7]
	.byte	0x41, 0x88	; F3B0A5  [8]  "A<88>"
	.ascii	" A"	; F3B0A7  [9]
	.byte	0x42, 0x88	; F3B0A9  [10]  "B<88>"
	.ascii	" B"	; F3B0AB  [11]
; --------------------------------------------------------------------------
; DLText_OctavesMinus2To8 -- 0xF3B0AD-0xF3B0C2, 11 entries of 2 bytes, text
;   drawn by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02
;   records at 0xF3B005 ((0x12F8) AND 0xFF >> 0), 0xF3B023 ((0x12FA) AND
;   0xFF >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_StringTable draws entry
;   [value] with +0x0B = 2 as the width.  Entry count: the distance to the
;   object's end over the width; the masks admit 256.
; --------------------------------------------------------------------------
DLText_OctavesMinus2To8:
	.ascii	"-2"	; F3B0AD  [0]
	.ascii	"-1"	; F3B0AF  [1]
	.ascii	"0 "	; F3B0B1  [2]
	.ascii	"1 "	; F3B0B3  [3]
	.ascii	"2 "	; F3B0B5  [4]
	.ascii	"3 "	; F3B0B7  [5]
	.ascii	"4 "	; F3B0B9  [6]
	.ascii	"5 "	; F3B0BB  [7]
	.ascii	"6 "	; F3B0BD  [8]
	.ascii	"7 "	; F3B0BF  [9]
	.ascii	"8 "	; F3B0C1  [10]

; === END COVER-R1 0xF3B065-0xF3B0C3 ===

; ------------------------------------------------------------------
; 0xF3B0C3-0xF3B21B -- 35 display-list records, 345 bytes -- interpreter A (30 records) and B (5)
;   entered at: 0xF3B0C3, 0xF3B102, 0xF3B1E3
;   ends used:  0xF3B102, 0xF3B1A6, 0xF3B1E3, 0xF3B211, 0xF3B21C
; ------------------------------------------------------------------
Paint_N0teChange_DL2:
; ; drawn (start operand) by Paint_N0teChange -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=280, y=151, text="YES"
	dl_text8x16	x=312, y=151, text="\021"
	dl_text8x16	x=312, y=189, text="\021"
	dl_text8x14	x=280, y=190, text="NO"
	dl_box	x0=276, y0=146, x1=308, y1=165
	dl_box	x0=278, y0=148, x1=306, y1=163
	dl_box	x0=276, y0=185, x1=308, y1=204
	dl_box	x0=278, y0=187, x1=306, y1=202
; DL_Transp0seTrackFirstMeasure -- the display list at 0xF3B102.  Its own text
;                                  records read: "TRANSP0SE"; "TRACK
;                                  :"; "FIRST MEASURE   :"; "LAST MEASURE
;                                  :"; "TRANSPOSE       :"; "OK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Transp0seTrackFirstMeasure:
	dl_text16x16_packed	x=112, y=6, text="TRANSP0SE"
	dl_text8x16	x=0, y=42, text="\020"
	dl_text8x16	x=24, y=42, text="TRACK           :"
	dl_text8x16	x=0, y=78, text="\020"
	dl_text8x16	x=24, y=78, text="FIRST MEASURE   :"
	dl_text8x16	x=0, y=114, text="\020"
	dl_text8x16	x=24, y=114, text="LAST MEASURE    :"
	dl_text8x16	x=0, y=150, text="\020"
	dl_text8x16	x=24, y=150, text="TRANSPOSE       :"
	dl_box_shadow2	x0=11, y0=32, x1=223, y1=63
	dl_box_shadow2	x0=11, y0=68, x1=223, y1=99
	dl_box_shadow2	x0=11, y0=104, x1=223, y1=135
	dl_box_shadow2	x0=11, y0=140, x1=223, y1=171
	dl_value_glyph	glyph=60, x=88, y=1
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x14	x=288, y=74, text="OK"
	dl_box	x0=283, y0=69, x1=309, y1=88
	dl_box	x0=285, y0=71, x1=307, y1=86
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3B1E3:
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16All, width=3, x=160, y=42
	dlb_number16	var=DisplayListB_Stage+1, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=78, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=114, digits=3
	dlb_number_signed	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=150, digits=3, signflag=0x00
	dlb_rect_entry	var=DisplayListB_Stage+6, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3B21C

; === COVER-R1 0xF3B21C-0xF3B244 ===
; 0xF3B21C-0xF3B243, coverage round 1: 40 of this span's 40 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 40 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3B21C-0xF3B243 -- 40 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3B21C appears as a 32-bit word at 0xF3B218 0xF7FC8D;
;               converted code at 0xF7FC8C loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 12% printable ASCII; a linear decode runs 25 instructions and ends
;           `db`, with 35% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3B21C -- 0xF3B21C-0xF3B243, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3B211 ((0x12FC)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the object's end over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3B1E3 / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF7FC8C.
; --------------------------------------------------------------------------
DLBoxes_F3B21C:
	.short	0, 0, 1, 1	; F3B21C  [0]
	.short	11, 32, 223, 63	; F3B224  [1]
	.short	11, 68, 223, 99	; F3B22C  [2]
	.short	11, 104, 223, 135	; F3B234  [3]
	.short	11, 140, 223, 171	; F3B23C  [4]

; === END COVER-R1 0xF3B21C-0xF3B244 ===

; ------------------------------------------------------------------
; 0xF3B244-0xF3B3B1 -- 33 display-list records, 366 bytes -- interpreter A (28 records) and B (5)
;   entered at: 0xF3B244, 0xF3B26C, 0xF3B294, 0xF3B33C, 0xF3B379
;   ends used:  0xF3B26C, 0xF3B294, 0xF3B33C, 0xF3B379, 0xF3B3A7, 0xF3B3B2
; ------------------------------------------------------------------
Paint_SongClear_DL2:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text16x16_packed	x=232, y=87, text=":"
	dl_text16x16_packed	x=42, y=86, text="   ALL S0NGS     "
	dl_text16x16_packed	x=240, y=86, text="100%"
Paint_SongClear_DL5:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text16x16_packed	x=210, y=57, text=":"
	dl_text16x16_packed	x=20, y=59, text="   ALL S0NGS     "
	dl_text16x16_packed	x=218, y=59, text="100%"
; DL_AdvanceDelayTrackFirstMeasure -- the display list at 0xF3B294.  Its own
;                                     text records read: "ADVANCE/DELAY";
;                                     "TRACK           :"; "FIRST MEASURE
;                                     :"; "LAST MEASURE    :"; "ADVANCE/DELAY
;                                     :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_AdvanceDelayTrackFirstMeasure:
	dl_text16x16_packed	x=103, y=6, text="ADVANCE/DELAY"
	dl_text8x16	x=0, y=42, text="\020"
	dl_text8x16	x=24, y=42, text="TRACK           :"
	dl_text8x16	x=0, y=78, text="\020"
	dl_text8x16	x=24, y=78, text="FIRST MEASURE   :"
	dl_text8x16	x=0, y=114, text="\020"
	dl_text8x16	x=24, y=114, text="LAST MEASURE    :"
	dl_text8x16	x=0, y=150, text="\020"
	dl_text8x16	x=24, y=150, text="ADVANCE/DELAY   :"
	dl_box_shadow2	x0=11, y0=32, x1=223, y1=63
	dl_box_shadow2	x0=11, y0=68, x1=223, y1=99
	dl_box_shadow2	x0=11, y0=104, x1=223, y1=135
	dl_box_shadow2	x0=11, y0=140, x1=223, y1=171
	dl_value_glyph	glyph=64, x=80, y=1
Paint_AdvanceDelay_DL:
; ; drawn (start operand) by Paint_AdvanceDelay -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x16	x=312, y=113, text="\021"
	dl_text8x14	x=288, y=114, text="OK"
	dl_box	x0=286, y0=111, x1=306, y1=126
	dl_box	x0=284, y0=109, x1=308, y1=128
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3B379:
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16All, width=3, x=160, y=42
	dlb_number16	var=DisplayListB_Stage+1, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=78, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=114, digits=3
	dlb_number_signed	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=160, y=150, digits=2, signflag=0x00
	dlb_rect_entry	var=DisplayListB_Stage+6, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3B3B2

; === COVER-R1 0xF3B3B2-0xF3B7C3 ===
; 0xF3B3B2-0xF3B7C2, coverage round 1: 92 of this span's 1041 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 92 as DATA (only
; a `.long` or a 32-bit immediate names it) in 8 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3B3B2-0xF3B3D9 -- 40 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3B3B2 appears as a 32-bit word at 0xF3B3AE 0xF7FFBC;
;               converted code at 0xF7FFBB loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 19% printable ASCII; a linear decode runs 31 instructions and ends
;           `halt`, with 30% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3B3B2 -- 0xF3B3B2-0xF3B3D9, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3B3A7 ((0x12FC)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the object's end over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3B379 / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF7FFBB.
; --------------------------------------------------------------------------
DLBoxes_F3B3B2:
	.short	0, 0, 1, 1	; F3B3B2  [0]
	.short	11, 32, 223, 63	; F3B3BA  [1]
	.short	11, 68, 223, 99	; F3B3C2  [2]
	.short	11, 104, 223, 135	; F3B3CA  [3]
	.short	11, 140, 223, 171	; F3B3D2  [4]


; ------------------------------------------------------------------
; 0xF3B3DA-0xF3B5A8 -- 53 display-list records, 463 bytes -- interpreter A
; Paint_TrackAssign_DL1, the "TRACK ASSIGN" screen -- ALREADY NAMED AND CITED
; elsewhere in this file (search "draws display list 0xF3B3DA"),
; from a real `ld XIY,0x00F3B3DA` immediate inside 0xF7E440 (still
; .incbin).  Its first 13 bytes had been folded into DLBoxes_F3B3B2
; above (now shrunk to its real 40-byte extent); walking from here
; lands with ZERO DRIFT on Data_F3B5A9, already committed below.
; notes/gen_prom_b_f3b3da_module.py
; ------------------------------------------------------------------
Paint_TrackAssign_DL1:
; ; drawn (start operand) by Paint_TrackAssign -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=256, y=4, text="SONG"
	dl_text16x16_packed	x=96, y=5, text="TRACK ASSIGN"
	dl_text8x10	x=96, y=32, text="TRACK   L0CAL   MIDI"
	dl_text8x16	x=24, y=40, text="\215"
	dl_text8x16	x=0, y=40, text="\250"
	dl_text8x14	x=96, y=45, text="ASSIGN  CONTROL OUT CH"
	dl_text8x14	x=8, y=60, text="TRACK"
	dl_text8x16	x=0, y=76, text="\250"
	dl_text8x16	x=24, y=77, text="\216"
	dl_text8x16	x=24, y=108, text="_"
	dl_text8x16	x=0, y=112, text="\020"
	dl_text8x14	x=16, y=114, text="1"
	dl_text8x14	x=32, y=114, text="8"
	dl_text8x16	x=24, y=147, text="_"
	dl_text8x16	x=0, y=151, text="\020"
	dl_text8x14	x=16, y=153, text="9"
	dl_text8x14	x=32, y=153, text="16"
	dl_text8x16	x=0, y=195, text="\020"
	dl_text8x14	x=16, y=196, text="PRESETS"
	dl_text8x14	x=160, y=197, text="LO"
	dl_text8x14	x=176, y=197, text="C"
	dl_text8x14	x=184, y=197, text="AL    CHA"
	dl_text8x14	x=256, y=197, text="N"
	dl_text8x14	x=264, y=197, text="NEL"
	dl_text8x16	x=176, y=210, text="\215"
	dl_text8x16	x=256, y=210, text="\215"
	dl_text8x16	x=176, y=224, text="\216"
	dl_text8x16	x=256, y=224, text="\216"
	dl_box_shadow2	x0=165, y0=211, x1=194, y1=235
	dl_box_shadow2	x0=245, y0=211, x1=274, y1=235
	dl_box	x0=10, y0=37, x1=45, y1=56
	dl_box	x0=12, y0=39, x1=43, y1=54
	dl_box	x0=10, y0=73, x1=45, y1=92
	dl_box	x0=12, y0=75, x1=43, y1=90
	dl_box	x0=10, y0=109, x1=45, y1=128
	dl_box	x0=12, y0=111, x1=43, y1=126
	dl_box	x0=10, y0=148, x1=51, y1=167
	dl_box	x0=12, y0=150, x1=49, y1=165
	dl_box	x0=11, y0=191, x1=77, y1=211
	dl_box	x0=13, y0=193, x1=75, y1=209
	dl_hline	x0=55, y0=26, x1=280, y1=26
	dl_hline	x0=55, y0=59, x1=281, y1=59
	dl_hline	x0=55, y0=183, x1=281, y1=183
	dl_hline	x0=56, y0=184, x1=281, y1=184
	dl_hline	x0=165, y0=223, x1=196, y1=223
	dl_hline	x0=245, y0=223, x1=276, y1=223
	dl_vline	x0=55, y0=26, x1=55, y1=183
	dl_vline	x0=92, y0=26, x1=92, y1=184
	dl_vline	x0=155, y0=26, x1=155, y1=184
	dl_vline	x0=220, y0=26, x1=220, y1=184
	dl_vline	x0=280, y0=26, x1=280, y1=184
	dl_vline	x0=281, y0=28, x1=281, y1=184
	dl_value_glyph	glyph=55, x=56, y=2


; ------------------------------------------------------------------
; 0xF3B5A9-0xF3B5D0 -- 5 display-list records, 40 bytes -- interpreter A
; Formerly Data_F3B5A9 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
Paint_TrackAssign_DL2:
; ; drawn (start operand) by Paint_TrackAssign -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=104, y=197, text="ASSIGN"
	dl_text8x16	x=136, y=210, text="\215"
	dl_text8x16	x=136, y=224, text="\216"
	dl_box_shadow2	x0=125, y0=211, x1=154, y1=235
	dl_hline	x0=125, y0=223, x1=156, y1=223


; ------------------------------------------------------------------
; 0xF3B5D1-0xF3B610 -- 8 display-list records, 64 bytes -- interpreter A
; Formerly Data_F3B5D1 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
Paint_TrackLabels1To8_DL:
; ; drawn (start operand) by Paint_TrackLabels1To8 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=56, y=64, text="TR 1"
	dl_text8x14	x=56, y=79, text="TR 2"
	dl_text8x14	x=56, y=94, text="TR 3"
	dl_text8x14	x=56, y=109, text="TR 4"
	dl_text8x14	x=56, y=124, text="TR 5"
	dl_text8x14	x=56, y=139, text="TR 6"
	dl_text8x14	x=56, y=154, text="TR 7"
	dl_text8x14	x=56, y=169, text="TR 8"


; ------------------------------------------------------------------
; 0xF3B611-0xF3B650 -- 8 display-list records, 64 bytes -- interpreter A
; Formerly Data_F3B611 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
Paint_TrackLabels9To16_DL:
; ; drawn (start operand) by Paint_TrackLabels9To16 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=56, y=64, text="TR 9"
	dl_text8x14	x=56, y=79, text="TR10"
	dl_text8x14	x=56, y=94, text="TR11"
	dl_text8x14	x=56, y=109, text="TR12"
	dl_text8x14	x=56, y=124, text="TR13"
	dl_text8x14	x=56, y=139, text="TR14"
	dl_text8x14	x=56, y=154, text="TR15"
	dl_text8x14	x=56, y=169, text="TR16"

; --------------------------------------------------------------------------
; Data_F3B651 -- 5 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3B651 appears as a 32-bit word at 0xF7E79A 0xF7E8C4;
;               converted code at 0xF7E799 0xF7E8C3 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 40% printable ASCII; a linear decode runs 3 instructions and ends
;           `swi 7`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------

; ------------------------------------------------------------------
; 0xF3B651-0xF3B65A -- 1 display-list record, 10 bytes -- interpreter B.
; Formerly Data_F3B651 (5 bytes) plus the 5-byte `.incbin` after it.
;
; ⚠ THE ONE RECORD IN THE IMAGE WHOSE ADVANCE BYTE OVER-DECLARES.
; Lane promB6 left the question: as op 0x00 with length 11 this record
; would end at 0xF3B65C, yet the next record demonstrably starts at
; 0xF3B65B.  So EITHER op 0x00 does not carry its length at +1, OR
; DL_F3B65B's start is off by one.  It is NEITHER, and the handler
; settles it:
;   * op 0x00 DOES carry its advance at +1.  The interpreter reads +1
;     for every opcode without looking at the opcode -- 0xF31B15
;     `ld A,(XIY+0x01)` then `add XIY,XWA`.
;   * DL_F3B65B is not off by one.  prom_b 0xF7E79E passes 0xF3B65B as
;     XIX -- the list's exclusive end -- in the same breath as
;     `ld XIY,0x00f3b651` at 0xF7E799.
; ADVANCE and EXTENT are simply different numbers.  Handler 0xF31BA1's
; highest read is +9 (`ld C,(XIY+0x09)`), so the DATA this record
; occupies is 10 bytes, 0xF3B651-0xF3B65A.  The advance byte says 11.
; The over-declaration is inert: XIY lands on 0xF3B65C, past XIX, and
; the loop test `cp XIX,XIY / jr ULE` ends the list -- the machine draws
; the record and stops.
; The other edge is an immediate too: 0xF3B651 is the XIX of the
; interpreter-A call at 0xF7E8C3, i.e. the exclusive end of Paint_TrackLabels9To16_DL.
; Verify: python3 notes/gen_prom_b_res3xx_spans.py --selftest
; ------------------------------------------------------------------
TrackAssign_PaintTrackGroup_DL:
; drawn (start operand) by TrackAssign_PaintTrackGroup -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x00, 0x0B	; B op 00, 10 bytes of data, advance byte says 11 -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.short 0x00C4	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663



; ------------------------------------------------------------------
; 0xF3B65B-0xF3B6D2 -- 8 display-list records, 120 bytes -- interpreter A
; Formerly Data_F3B65B -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
DL_F3B65B:
	dlb_string	var=UI_DrawScratch+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=64	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=79	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=94	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=109	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=124	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=139	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=154	; operand bytes the handler does not read
	dlb_string	var=UI_DrawScratch+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x14, width=7, x=96, y=169	; operand bytes the handler does not read


; ------------------------------------------------------------------
; 0xF3B6D3-0xF3B74A -- 8 display-list records, 120 bytes -- interpreter A
; Formerly Data_F3B6D3 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
TrackAssign_DrawLocalControlColumn_DL:
; drawn (start operand) by TrackAssign_DrawLocalControlColumn -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=64	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=79	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=94	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=109	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=124	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=139	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=154	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0x1c0, width=3, x=176, y=169	; operand bytes the handler does not read


; ------------------------------------------------------------------
; 0xF3B74B-0xF3B7C2 -- 8 display-list records, 120 bytes -- interpreter A
; Formerly Data_F3B74B -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
TrackAssign_DrawOutChannelColumn_DL:
; drawn (start operand) by TrackAssign_DrawOutChannelColumn -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=64	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=79	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=94	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=109	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=124	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=139	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=154	; operand bytes the handler does not read
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Table_F3B7D4+0xf4, width=6, x=224, y=169	; operand bytes the handler does not read

; === END COVER-R1 0xF3B3B2-0xF3B7C3 ===

; ------------------------------------------------------------------
; 0xF3B7C3-0xF3B7CC -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF3B7C3
;   ends used:  0xF3B7CD
; ------------------------------------------------------------------
TrackAssign_DrawTrackGroupHighlight_DL:
; drawn (start operand) by TrackAssign_DrawTrackGroupHighlight -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=12, y0=111, x1=49, y1=165

; === COVER-R1 0xF3B7CD-0xF3B99D ===
; 0xF3B7CD-0xF3B99C, coverage round 1: 7 of this span's 464 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 7 as DATA (only a
; `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3B7CD -- 7 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3B7CD appears as a 32-bit word at 0xF7E927 0xF7E938;
;               converted code at 0xF7E926 0xF7E937 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 0% printable ASCII; a linear decode runs 5 instructions and ends
;           `halt`, with 14% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F3B7CD:
	.byte	0x03, 0x0B, 0xFA, 0x12, 0x01, 0x00, 0x05	; F3B7CD  |.......|


; ------------------------------------------------------------------
; 0xF3B7D4-0xF3B99C -- a 64-entry fixed-stride caption table, 457 bytes:
; "PART 1".."PART 32" (32 x 7 B) then "1- 1CH".."2-16CH" (32 x 6 B)
; then a 21-byte tail.  Immediately follows Data_F3B7CD and immediately
; precedes DL_TrackAssignChangeAttention, both already committed.
; The header's 8 words are NOT a display-list record (no handler's
; implied length matches) and their indexing scheme is not established;
; three of the eight (0x000C, 0x006F, 0x00A5) also appear verbatim in
; the immediately preceding record, TrackAssign_DrawTrackGroupHighlight_DL's own 4 words -- recorded
; as corroboration this is a deliberate field, not padding, without
; claiming what it selects.  Regenerate: python3
; notes/gen_prom_b_f3b7d4_module.py --splice
; ------------------------------------------------------------------
Table_F3B7D4:
	.long	Table_F3B7D4 + 0x4	; +0x00 purpose not established
	.short	0x000C	; +0x04 purpose not established
	.short	0x006F	; +0x06 purpose not established
	.short	0x002B	; +0x08 purpose not established
	.short	0x007E	; +0x0A purpose not established
	.short	0x000C	; +0x0C purpose not established
	.short	0x0096	; +0x0E purpose not established
	.short	0x0031	; +0x10 purpose not established
	.short	0x00A5	; +0x12 purpose not established
; 32 x 7-byte "PART n" captions, +0x14
	.ascii "PART 1 "	; entry 1
	.ascii "PART 2 "	; entry 2
	.ascii "PART 3 "	; entry 3
	.ascii "PART 4 "	; entry 4
	.ascii "PART 5 "	; entry 5
	.ascii "PART 6 "	; entry 6
	.ascii "PART 7 "	; entry 7
	.ascii "PART 8 "	; entry 8
	.ascii "PART 9 "	; entry 9
	.ascii "PART 10"	; entry 10
	.ascii "PART 11"	; entry 11
	.ascii "PART 12"	; entry 12
	.ascii "PART 13"	; entry 13
	.ascii "PART 14"	; entry 14
	.ascii "PART 15"	; entry 15
	.ascii "PART 16"	; entry 16
	.ascii "PART 17"	; entry 17
	.ascii "PART 18"	; entry 18
	.ascii "PART 19"	; entry 19
	.ascii "PART 20"	; entry 20
	.ascii "PART 21"	; entry 21
	.ascii "PART 22"	; entry 22
	.ascii "PART 23"	; entry 23
	.ascii "PART 24"	; entry 24
	.ascii "PART 25"	; entry 25
	.ascii "PART 26"	; entry 26
	.ascii "PART 27"	; entry 27
	.ascii "PART 28"	; entry 28
	.ascii "PART 29"	; entry 29
	.ascii "PART 30"	; entry 30
	.ascii "PART 31"	; entry 31
	.ascii "PART 32"	; entry 32
; 32 x 6-byte "<bank>-<channel>CH" captions, +0xF4
	.ascii "1- 1CH"	; entry 1
	.ascii "1- 2CH"	; entry 2
	.ascii "1- 3CH"	; entry 3
	.ascii "1- 4CH"	; entry 4
	.ascii "1- 5CH"	; entry 5
	.ascii "1- 6CH"	; entry 6
	.ascii "1- 7CH"	; entry 7
	.ascii "1- 8CH"	; entry 8
	.ascii "1- 9CH"	; entry 9
	.ascii "1-10CH"	; entry 10
	.ascii "1-11CH"	; entry 11
	.ascii "1-12CH"	; entry 12
	.ascii "1-13CH"	; entry 13
	.ascii "1-14CH"	; entry 14
	.ascii "1-15CH"	; entry 15
	.ascii "1-16CH"	; entry 16
	.ascii "2- 1CH"	; entry 17
	.ascii "2- 2CH"	; entry 18
	.ascii "2- 3CH"	; entry 19
	.ascii "2- 4CH"	; entry 20
	.ascii "2- 5CH"	; entry 21
	.ascii "2- 6CH"	; entry 22
	.ascii "2- 7CH"	; entry 23
	.ascii "2- 8CH"	; entry 24
	.ascii "2- 9CH"	; entry 25
	.ascii "2-10CH"	; entry 26
	.ascii "2-11CH"	; entry 27
	.ascii "2-12CH"	; entry 28
	.ascii "2-13CH"	; entry 29
	.ascii "2-14CH"	; entry 30
	.ascii "2-15CH"	; entry 31
	.ascii "2-16CH"	; entry 32
	.ascii " OFF  -- CH OFFON -- "	; +0x1B4, 21-byte tail

; === END COVER-R1 0xF3B7CD-0xF3B99D ===

; ------------------------------------------------------------------
; 0xF3B99D-0xF3BB96 -- 40 display-list records, 506 bytes -- interpreter A (36 records) and B (4)
;   entered at: 0xF3B99D, 0xF3BA91, 0xF3BAB9, 0xF3BB7E, 0xF3BB8D
;   ends used:  0xF3BA91, 0xF3BAB9, 0xF3BB7E, 0xF3BB8D, 0xF3BB97
; ------------------------------------------------------------------
; DL_TrackAssignChangeAttention -- the display list at 0xF3B99D.  Its own text
;                                  records read: "TRACK ASSIGN CHANGE";
;                                  "ATTENTION!"; "YES"; "Changing the
;                                  assignment of"; "NO"; "Track"; "from";
;                                  "will erase all the current data" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackAssignChangeAttention:
	dl_text16x16_packed	x=48, y=8, text="TRACK ASSIGN CHANGE"
	dl_text16x16	x=48, y=51, text="ATTENTION!"
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x14	x=280, y=76, text="YES"
	dl_text8x16	x=8, y=91, text="Changing the assignment of"
	dl_text8x16	x=312, y=110, text="\021"
	dl_text8x14	x=280, y=111, text="NO"
	dl_text8x16	x=8, y=117, text="Track"
	dl_text8x16	x=64, y=117, text=" from "
	dl_text8x16	x=168, y=117, text="~"
	dl_text8x16	x=8, y=143, text="will erase all the current data"
	dl_text16x16	x=24, y=178, text="Are"
	dl_text16x16	x=88, y=178, text="You"
	dl_text16x16	x=152, y=178, text="Sure?"
	dl_box_shadow2	x0=3, y0=37, x1=266, y1=210
	dl_box	x0=275, y0=71, x1=309, y1=90
	dl_box	x0=277, y0=73, x1=307, y1=88
	dl_box	x0=275, y0=106, x1=309, y1=125
	dl_box	x0=277, y0=108, x1=307, y1=123
	dl_hline	x0=46, y0=67, x1=208, y1=67
	dl_hline	x0=46, y0=68, x1=208, y1=68
Paint_TrackAssign_DL3:
; ; drawn (start operand) by Paint_TrackAssign -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F39559 + 0xA9, width=7, x=112, y=117
	dlb_string	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=Data_F39559 + 0xA9, width=7, x=176, y=117
	dlb_number	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=48, y=117, digits=2
; DL_AfterT0uchSettingSelectWhetherOrNotAfter -- the display list at 0xF3BAB9.
;                                                Its own text records read:
;                                                "AFTER T0UCH SETTING";
;                                                "Select whether or not After
;                                                Touch"; "is recorded by the
;                                                Sequencer."; "EN"; "AFTER
;                                                TOUCH RECORD :"; "DIS".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_AfterT0uchSettingSelectWhetherOrNotAfter:
	dl_text16x16_packed	x=72, y=5, text="AFTER T0UCH SETTING"
	dl_text8x16	x=16, y=45, text="Select whether or not After Touch"
	dl_text8x16	x=16, y=64, text="is recorded by the Sequencer."
	dl_text8x16	x=312, y=112, text="\021"
	dl_text8x14	x=280, y=113, text="EN"
	dl_text8x16	x=24, y=130, text="AFTER TOUCH RECORD :"
	dl_text8x16	x=312, y=147, text="\021"
	dl_text8x14	x=280, y=148, text="DIS"
	dl_value_glyph	glyph=57, x=40, y=1
	dl_box_shadow2	x0=10, y0=106, x1=254, y1=165
	dl_box	x0=276, y0=108, x1=308, y1=127
	dl_box	x0=278, y0=110, x1=306, y1=125
	dl_box	x0=276, y0=143, x1=308, y1=162
	dl_box	x0=278, y0=145, x1=306, y1=160
; DL_AfterTouchRecord -- the display list at 0xF3BB7E, named by mechanism M3
;                        of notes/prom_b_dl_screens_round5.py.  "AFTER TOUCH
;                        RECORD :" ends at 0x1467
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_AfterTouchRecord:
	dlb_string	var=DisplayListB_Stage, mask=0x01, shift=0, svc=LCDSVC_DrawText8x16, table=DLTable_DisableEnable, width=7, x=184, y=130
AfterT0uchSetting_EraseRecordValue_DL:
; drawn (start operand) by AfterT0uchSetting_EraseRecordValue -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=184, y0=130, x1=248, y1=138

; ==================================================================
; 0xF3BB97-0xF3BBA4 -- display-list OPERAND TABLES (14 bytes, 1 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_DisableEnable -- 2 entries of 7 characters
; Referenced by: display-list record 0xF3BB7E
; Evidence: the record's +7 pointer lands here and its +0x0B word is 7, so the
;           entries are 7 bytes wide (handler 0xF31B21/0xF31B39 loads the
;           extracted bit-field into HL as the index).
;           2 entries is the EXTENT (14 bytes / 7), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
; DLTable_DisableEnable -- renamed from DLTable_F3BB97: the object's own
;                          entries are "DISABLE"; "ENABLE".
; Evidence: the text printed below this label IS the object's whole content;
;           the name is CamelCase of its first entries and claims only what
;           the object HOLDS -- not what indexes it, and not what the words
;           mean.  The KIND is the one the tree already established and is
;           kept; only the address is replaced.  Generated by
;           notes/prom_b_dl_screens_round5.py --tables --apply.
DLTable_DisableEnable:
	.ascii "DISABLE"	; [0]
	.ascii "ENABLE "	; [1]

; ------------------------------------------------------------------
; 0xF3BBA5-0xF3BD57 -- 47 display-list records, 435 bytes -- interpreter A (40 records) and B (7)
;   entered at: 0xF3BBA5, 0xF3BC93, 0xF3BCCB, 0xF3BD07
;   ends used:  0xF3BC93, 0xF3BCCB, 0xF3BD07, 0xF3BD4D, 0xF3BD58
; ------------------------------------------------------------------
; DL_MeasureC0pyFromTrackToTrack -- the display list at 0xF3BBA5.  Its own
;                                   text records read: "MEASURE C0PY"; "FROM
;                                   TRACK"; "TO TRACK"; "FIRST MEASURE";
;                                   "START MEASURE"; "LAST MEASURE"; "REPEAT
;                                   :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MeasureC0pyFromTrackToTrack:
	dl_text16x16_packed	x=96, y=6, text="MEASURE C0PY"
	dl_text8x16	x=312, y=38, text="\021"
	dl_text8x16	x=24, y=66, text="FROM TRACK"
	dl_text8x16	x=192, y=66, text="TO TRACK"
	dl_text8x16	x=0, y=73, text="\020"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=64, y=80, text=":"
	dl_text8x16	x=232, y=80, text=":"
	dl_text8x16	x=24, y=104, text="FIRST MEASURE"
	dl_text8x16	x=192, y=104, text="START MEASURE"
	dl_text8x16	x=0, y=111, text="\020"
	dl_text16x16_packed	x=155, y=111, text="\212"
	dl_text8x16	x=312, y=111, text="\021"
	dl_text8x16	x=64, y=118, text=":"
	dl_text8x16	x=232, y=118, text=":"
	dl_text8x16	x=24, y=143, text="LAST MEASURE"
	dl_text8x16	x=0, y=149, text="\020"
	dl_text8x16	x=192, y=149, text="REPEAT :"
	dl_text8x16	x=312, y=150, text="\021"
	dl_text8x16	x=64, y=157, text=":"
	dl_value_glyph	glyph=69, x=64, y=1
	dl_hline	x0=144, y0=63, x1=147, y1=63
	dl_hline	x0=171, y0=63, x1=174, y1=63
	dl_hline	x0=171, y0=134, x1=174, y1=134
	dl_hline	x0=144, y0=172, x1=147, y1=172
	dl_vline	x0=147, y0=63, x1=147, y1=172
	dl_vline	x0=171, y0=63, x1=171, y1=134
Paint_MeasureC0py_DL:
; ; drawn (start operand) by Paint_MeasureC0py -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=288, y=39, text="OK"
	dl_box	x0=283, y0=34, x1=309, y1=53
	dl_box	x0=285, y0=36, x1=307, y1=51
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3BCCB:
	dl_box_shadow2	x0=11, y0=63, x1=138, y1=94
	dl_box_shadow2	x0=179, y0=63, x1=306, y1=94
	dl_box_shadow2	x0=11, y0=101, x1=138, y1=132
	dl_box_shadow2	x0=179, y0=101, x1=306, y1=132
	dl_box_shadow2	x0=179, y0=143, x1=306, y1=166
	dl_box_shadow2	x0=11, y0=139, x1=138, y1=170
DL_F3BD07:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16MasterAll, width=6, x=72, y=80
	dlb_string	var=DisplayListB_Stage+5, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16MasterAll, width=6, x=240, y=80
	dlb_number16	var=DisplayListB_Stage+1, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=72, y=118, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=72, y=157, digits=3
	dlb_number16	var=DisplayListB_Stage+6, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=240, y=118, digits=3
	dlb_number	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=256, y=149, digits=3
	dlb_rect_entry	var=DisplayListB_Stage+9, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3BD58

; === COVER-R1 0xF3BD58-0xF3BD90 ===
; 0xF3BD58-0xF3BD8F, coverage round 1: 56 of this span's 56 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 56 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3BD58-0xF3BD8F -- 56 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3BD58 appears as a 32-bit word at 0xF3BD54.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 16% printable ASCII; a linear decode runs 32 instructions and ends
;           `nop`, with 20% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3BD58 -- 0xF3BD58-0xF3BD8F, 7 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3BD4D ((0x12FF)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the object's end over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3BD07 / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF807FB.
; --------------------------------------------------------------------------
DLBoxes_F3BD58:
	.short	0, 0, 1, 1	; F3BD58  [0]
	.short	11, 61, 136, 92	; F3BD60  [1]
	.short	11, 99, 136, 130	; F3BD68  [2]
	.short	11, 137, 136, 168	; F3BD70  [3]
	.short	179, 61, 304, 92	; F3BD78  [4]
	.short	179, 99, 304, 130	; F3BD80  [5]
	.short	179, 141, 304, 164	; F3BD88  [6]

; === END COVER-R1 0xF3BD58-0xF3BD90 ===

; ------------------------------------------------------------------
; 0xF3BD90-0xF3BF47 -- 49 display-list records, 440 bytes -- interpreter A (42 records) and B (7)
;   entered at: 0xF3BD90, 0xF3BDCF, 0xF3BEBF, 0xF3BEF7
;   ends used:  0xF3BDCF, 0xF3BEBF, 0xF3BEF7, 0xF3BF3D, 0xF3BF48
; ------------------------------------------------------------------
DL_F3BD90:
	dl_text8x16	x=312, y=37, text="\021"
	dl_text8x14	x=280, y=39, text="YES"
	dl_text8x16	x=312, y=189, text="\021"
	dl_text8x14	x=280, y=190, text="NO"
	dl_box	x0=275, y0=34, x1=309, y1=53
	dl_box	x0=277, y0=36, x1=307, y1=51
	dl_box	x0=275, y0=185, x1=309, y1=204
	dl_box	x0=277, y0=187, x1=307, y1=202
; DL_MeasureInsertFromTrackToTrack -- the display list at 0xF3BDCF.  Its own
;                                     text records read: "MEASURE INSERT";
;                                     "FROM TRACK"; "TO TRACK"; "FIRST
;                                     MEASURE"; "START MEASURE"; "LAST
;                                     MEASURE"; "REPEAT :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MeasureInsertFromTrackToTrack:
	dl_text16x16_packed	x=95, y=6, text="MEASURE INSERT"
	dl_text8x16	x=312, y=36, text="\021"
	dl_text8x16	x=24, y=66, text="FROM TRACK"
	dl_text8x16	x=192, y=66, text="TO TRACK"
	dl_text8x16	x=0, y=73, text="\020"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=64, y=80, text=":"
	dl_text8x16	x=232, y=80, text=":"
	dl_text8x16	x=24, y=104, text="FIRST MEASURE"
	dl_text8x16	x=192, y=104, text="START MEASURE"
	dl_text8x16	x=0, y=111, text="\020"
	dl_text8x16	x=312, y=111, text="\021"
	dl_text8x16	x=64, y=118, text=":"
	dl_text16x16_packed	x=152, y=118, text="\212"
	dl_text8x16	x=232, y=118, text=":"
	dl_text8x16	x=24, y=142, text="LAST MEASURE"
	dl_text8x16	x=0, y=149, text="\020"
	dl_text8x16	x=192, y=149, text="REPEAT :"
	dl_text8x16	x=312, y=150, text="\021"
	dl_text8x16	x=64, y=156, text=":"
	dl_value_glyph	glyph=72, x=64, y=1
	dl_hline	x0=144, y0=63, x1=147, y1=63
	dl_hline	x0=171, y0=63, x1=174, y1=63
	dl_hline	x0=171, y0=134, x1=174, y1=134
	dl_hline	x0=144, y0=172, x1=147, y1=172
	dl_vline	x0=147, y0=63, x1=147, y1=172
	dl_vline	x0=171, y0=63, x1=171, y1=134
Paint_MeasureInsert_DL:
; ; drawn (start operand) by Paint_MeasureInsert -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=288, y=37, text="OK"
	dl_box	x0=284, y0=32, x1=308, y1=51
	dl_box	x0=286, y0=34, x1=306, y1=49
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_hline	x0=165, y0=224, x1=196, y1=224
DL_F3BEF7:
	dlb_string	var=DisplayListB_Stage, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16MasterAll, width=6, x=72, y=80
	dlb_string	var=DisplayListB_Stage+5, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To16MasterAll, width=6, x=240, y=80
	dlb_number16	var=DisplayListB_Stage+1, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=72, y=118, digits=3
	dlb_number16	var=DisplayListB_Stage+3, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=72, y=156, digits=3
	dlb_number16	var=DisplayListB_Stage+6, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, x=240, y=118, digits=3
	dlb_number	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=256, y=149, digits=3
	dlb_rect_entry	var=DisplayListB_Stage+9, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F3BF48

; === COVER-R1 0xF3BF48-0xF3BF80 ===
; 0xF3BF48-0xF3BF7F, coverage round 1: 56 of this span's 56 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 56 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3BF48-0xF3BF7F -- 56 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3BF48 appears as a 32-bit word at 0xF3BF44.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 16% printable ASCII; a linear decode runs 32 instructions and ends
;           `nop`, with 20% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F3BF48 -- 0xF3BF48-0xF3BF7F, 7 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF3BF3D ((0x12FF)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`); entry 0 is (0,0)-(1,1), a 2 x
;   2-pixel box in the panel's top-left corner, so value 0 draws next to
;   nothing (wsa1/scripts/analysis/sizing_defect_hunt.py calls this shape an
;   8-byte header; the reader indexes it as entry 0).  Entry count: the
;   distance to the object's end over the width; the masks admit 8.  This
;   address is also the END of a display list: `ld XIY,0xF3BEF7 / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF80B58.
; --------------------------------------------------------------------------
DLBoxes_F3BF48:
	.short	0, 0, 1, 1	; F3BF48  [0]
	.short	11, 61, 136, 92	; F3BF50  [1]
	.short	11, 99, 136, 130	; F3BF58  [2]
	.short	11, 137, 136, 168	; F3BF60  [3]
	.short	179, 61, 304, 92	; F3BF68  [4]
	.short	179, 99, 304, 130	; F3BF70  [5]
	.short	179, 141, 304, 164	; F3BF78  [6]

; === END COVER-R1 0xF3BF48-0xF3BF80 ===

; ------------------------------------------------------------------
; 0xF3BF80-0xF3C198 -- 49 display-list records, 537 bytes -- interpreter A (45 records) and B (4)
;   entered at: 0xF3BF80, 0xF3BFF8, 0xF3C133, 0xF3C145, 0xF3C15D, 0xF3C16C, 0xF3C17B
;   ends used:  0xF3BFF8, 0xF3C133, 0xF3C145, 0xF3C15D, 0xF3C16C, 0xF3C17B, 0xF3C199
; ------------------------------------------------------------------
; DL_S0ngC0pyFromToSongSongOk -- the display list at 0xF3BF80.  Its own text
;                                records read: "S0NG C0PY"; "FROM"; "TO";
;                                "SONG"; "SONG"; "OK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_S0ngC0pyFromToSongSongOk:
	dl_text16x16_packed	x=120, y=6, text="S0NG C0PY"
	dl_text8x16	x=64, y=40, text="FROM"
	dl_text8x16	x=208, y=40, text="TO"
	dl_text8x16	x=56, y=67, text="SONG "
	dl_text8x16	x=192, y=67, text="SONG "
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x14	x=288, y=74, text="OK"
	dl_text8x16	x=56, y=87, text=":"
	dl_text8x16	x=192, y=87, text=":"
	dl_text16x16_packed	x=147, y=95, text="\212"
	dl_box_shadow2	x0=46, y0=56, x1=123, y1=143
	dl_box_shadow2	x0=183, y0=56, x1=260, y1=143
	dl_hline	x0=46, y0=110, x1=125, y1=110
	dl_hline	x0=183, y0=110, x1=262, y1=110
	dl_value_glyph	glyph=65, x=96, y=1
; DL_FromToSongNoTrAllSongNoTrAll -- the display list at 0xF3BFF8.  Its own
;                                    text records read: "FROM"; "TO"; "SONG NO
;                                    TR/ALL    SONG NO   TR/ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_FromToSongNoTrAllSongNoTrAll:
	dl_text8x16	x=64, y=173, text="FROM"
	dl_text8x16	x=232, y=173, text="TO"
	dl_text8x14	x=16, y=198, text="SONG NO   TR/ALL    SONG NO   TR/ALL"
	dl_text8x14	x=8, y=219, text=" <    >    <    >    <    >    <    >"
	dl_box_shadow2	x0=5, y0=211, x1=34, y1=235
	dl_box_shadow2	x0=45, y0=211, x1=74, y1=235
	dl_box_shadow2	x0=81, y0=211, x1=110, y1=235
	dl_box_shadow2	x0=121, y0=211, x1=150, y1=235
	dl_box_shadow2	x0=167, y0=211, x1=196, y1=235
	dl_box_shadow2	x0=207, y0=211, x1=236, y1=235
	dl_box_shadow2	x0=245, y0=211, x1=274, y1=235
	dl_box_shadow2	x0=285, y0=211, x1=314, y1=235
	dl_box	x0=283, y0=69, x1=309, y1=88
	dl_box	x0=285, y0=71, x1=307, y1=86
	dl_hline	x0=4, y0=189, x1=152, y1=189
	dl_hline	x0=164, y0=189, x1=315, y1=189
	dl_hline	x0=4, y0=190, x1=152, y1=190
	dl_hline	x0=164, y0=190, x1=315, y1=190
	dl_vline	x0=4, y0=189, x1=4, y1=194
	dl_vline	x0=5, y0=189, x1=5, y1=194
	dl_vline	x0=151, y0=189, x1=151, y1=194
	dl_vline	x0=152, y0=189, x1=152, y1=194
	dl_vline	x0=164, y0=189, x1=164, y1=194
	dl_vline	x0=165, y0=189, x1=165, y1=194
	dl_vline	x0=314, y0=189, x1=314, y1=194
	dl_vline	x0=315, y0=189, x1=315, y1=194
; DL_TrackTrack -- the display list at 0xF3C133.  Its own text records read:
;                  "TRACK"; "TRACK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackTrack:
	dl_text8x16	x=56, y=123, text="TRACK"
	dl_text8x16	x=192, y=123, text="TRACK"
; DL_AllAll -- the display list at 0xF3C145.  Its own text records read:
;              "ALL"; "ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_AllAll:
	dl_text8x16	x=56, y=123, text="  ALL   "
	dl_text8x16	x=192, y=123, text="  ALL   "
S0ngC0py_DrawFromSong_DL2:
; ; drawn (start operand) by S0ngC0py_DrawFromSong -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, table=0x000012f8, width=6, x=64, y=87
S0ngC0py_DrawToSong_DL:
; ; drawn (start operand) by S0ngC0py_DrawToSong -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, table=0x000012fe, width=6, x=200, y=87
S0ngC0py_DrawTracks_DL:
; ; drawn (start operand) by S0ngC0py_DrawTracks -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage+14, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To17All, width=3, x=96, y=123
	dlb_string	var=DisplayListB_Stage+15, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_0To17All, width=3, x=232, y=123

; --- 0xF3C199-0xF3C1AC: not converted ---

; ------------------------------------------------------------------
; 0xF3C199-0xF3C1AC -- 2 display-list records, 20 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C199 lands with ZERO DRIFT exactly on 0xF3C1AD,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
S0ngC0py_DrawFromSong_DL1:
; ; drawn (start operand) by S0ngC0py_DrawFromSong -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=DisplayListB_Stage, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x16, x=96, y=67, digits=2
	dlb_number	var=DisplayListB_Stage+1, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x16, x=232, y=67, digits=2

; ------------------------------------------------------------------
; 0xF3C1AD-0xF3C350 -- 41 display-list records, 420 bytes -- interpreter A (37 records) and B (4)
;   entered at: 0xF3C1AD, 0xF3C31E
;   ends used:  0xF3C31E, 0xF3C351
; ------------------------------------------------------------------
; DL_S0ngSelectNameKbS0ngName -- the display list at 0xF3C1AD.  Its own text
;                                records read: "S0NG SELECT & NAME"; "KB";
;                                "S0NG"; "NAME"; "SONG"; "POSITION"; "ABC";
;                                "CLR".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_S0ngSelectNameKbS0ngName:
	dl_text16x16_packed	x=85, y=5, text="S0NG SELECT & NAME"
	dl_text8x8_packed	x=266, y=48, text=" KB"
	dl_text16x16_packed	x=48, y=61, text="S0NG"
	dl_text16x16	x=224, y=61, text=":"
	dl_text16x16_packed	x=273, y=61, text="%"
	dl_text16x16_packed	x=115, y=62, text=":"
	dl_text8x16	x=56, y=115, text="_"
	dl_text8x14	x=64, y=117, text=" A B C D E F G H I J K L M"
	dl_text8x14	x=56, y=132, text="N O P Q R S T U V W X Y Z"
	dl_text8x14	x=56, y=148, text="O 1 2 3 4 5 6 7 8 9"
	dl_text8x14	x=200, y=181, text="NAME"
	dl_text8x14	x=24, y=197, text="SONG"
	dl_text8x14	x=128, y=197, text="POSITION"
	dl_text8x14	x=208, y=197, text="ABC"
	dl_kana_halfwidth	x=232, y=197, text="\026\026"
	dl_text8x14	x=248, y=197, text="789"
	dl_text8x14	x=16, y=219, text="<"
	dl_text8x14	x=56, y=219, text=">"
	dl_text8x14	x=136, y=219, text="<"
	dl_text8x14	x=176, y=219, text=">"
	dl_text8x14	x=216, y=219, text="<"
	dl_text8x14	x=256, y=219, text=">"
	dl_text8x14	x=288, y=219, text="CLR"
	dl_value_glyph	glyph=53, x=56, y=1
	dl_box_shadow2	x0=38, y0=42, x1=290, y1=84
	dl_box_shadow2	x0=5, y0=211, x1=34, y1=235
	dl_box_shadow2	x0=45, y0=211, x1=74, y1=235
	dl_box_shadow2	x0=125, y0=211, x1=154, y1=235
	dl_box_shadow2	x0=165, y0=211, x1=194, y1=235
	dl_box_shadow2	x0=205, y0=211, x1=234, y1=235
	dl_box_shadow2	x0=245, y0=211, x1=274, y1=235
	dl_box_shadow2	x0=285, y0=211, x1=314, y1=235
	dl_box_patterned	x0=38, y0=106, x1=290, y1=167
	dl_hline	x0=123, y0=186, x1=191, y1=186
	dl_hline	x0=244, y0=186, x1=316, y1=186
	dl_vline	x0=123, y0=186, x1=123, y1=190
	dl_vline	x0=316, y0=186, x1=316, y1=191
S0ngSelectName_DrawValues_DL:
; ; drawn (start operand) by S0ngSelectName_DrawValues -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16, table=DisplayListB_Stage, width=6, x=128, y=61
	dlb_number_xy	var=DisplayListB_Stage+6, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=92, y=61, digits=2
	dlb_number16_xy	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=248, y=48, digits=3
	dlb_number_xy	var=DisplayListB_Stage+9, mask=0xff, shift=0, svc=LCDSVC_DrawText16x16Packed, x=240, y=61, digits=3

; --- 0xF3C351-0xF3C366: not converted ---

; ------------------------------------------------------------------
; 0xF3C351-0xF3C366 -- 2 display-list records, 22 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C351 lands with ZERO DRIFT exactly on 0xF3C367,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
DL_F3C351:
	dlb_rect_entry	var=DisplayListB_Stage+11, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=Data_F3C37D	; operand bytes the handler does not read
	dlb_rect_entry	var=DisplayListB_Stage+12, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=DLTable_F3C3AD	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF3C367-0xF3C37C -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF3C367
;   ends used:  0xF3C372, 0xF3C37D
; ------------------------------------------------------------------
DL_F3C367:
	dlb_rect_entry_op08	var=DisplayListB_Stage+11, mask=0x0f, shift=0, svc=LCDSVC_EraseRect, table=Data_F3C37D
	dlb_rect_entry_op08	var=DisplayListB_Stage+12, mask=0xff, shift=0, svc=LCDSVC_EraseRect, table=DLTable_F3C3AD

; === COVER-R1 0xF3C37D-0xF3C4D5 ===
; ⚠ CLOSED 2026-09-02 (lane promB4).  The verdict below -- "everything
;   else is NOT reachable and stays `.incbin`" -- was true of the round-1
;   REACHABILITY WALK and false of the ROM: the remainder is display-list
;   operand arrays, reached by pointer from records the walk never enters
;   because nothing CALLS them.  0 bytes of this block are `.incbin` now.
;   Evidence and regeneration: notes/gen_prom_b_promB4_operand_arrays.py
; 0xF3C37D-0xF3C4D4, coverage round 1: 257 of this span's 344 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 257 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3C37D -- 48 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ CORRECTED 2026-09-02 (lane promB4): this header said 257 bytes.
;   The 257-byte extent ran through a whole SECOND operand array and one
;   byte into its 27th entry.  Retyped as the two arrays the records at
;   0xF3C367 and 0xF3C372 point at; this label stays on the first.
; Reached from: 0x00F3C37D appears as a 32-bit word at 0xF3C358 0xF3C36E.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 17% printable ASCII; a linear decode runs 134 instructions and
;           ends `swi 0`, with 35% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ==================================================================
; 0xF3C37D-0xF3C4D4 -- display-list RECORDS and the OPERAND ARRAYS they
;                    point at (344 bytes) -- converted 2026-09-02,
;                    lane promB4, notes/gen_prom_b_promB4_operand_arrays.py
; ==================================================================
;
; Right edge anchored on DL_ACurrentTrackWillBeClearedAutomaticaly at
; 0xF3C4D5, a converted display-list span header; both array starts are
; named by the converted records at 0xF3C367 and 0xF3C372.
;
; The 257-byte Data_F3C37D was two whole arrays plus the first byte of
; the 27th entry of the second one -- again "the reachability walk's
; extent, not the object's".  Retyped as the two arrays; the label
; Data_F3C37D is kept on the first of them, which starts at its address.
;
; ------------------------------------------------------------------
; DLTable_F3C37D -- 6 entries of 8 bytes, 0xF3C37D-0xF3C3AC
; Referenced by: display-list record 0xF3C367
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
Data_F3C37D:
DLTable_F3C37D:
	.short 0x0080, 0x003B, 0x0090, 0x004E	; [0]
	.short 0x0090, 0x003B, 0x00A0, 0x004E	; [1]
	.short 0x00A0, 0x003B, 0x00B0, 0x004E	; [2]
	.short 0x00B0, 0x003B, 0x00C0, 0x004E	; [3]
	.short 0x00C0, 0x003B, 0x00D0, 0x004E	; [4]
	.short 0x00D0, 0x003B, 0x00E0, 0x004E	; [5]

; ------------------------------------------------------------------
; ⚠ TWO LANES FRAMED THIS ARRAY AND THEIR BASES DISAGREE (2026-09-02).
;   promB4 anchors it at 0xF3C3AD; promB6 (SHORTARR8) anchored it at
;   0xF3C37D and numbered the same rows 33..42 instead of 26..36.
;   The two bases differ by exactly 48 bytes = SIX WHOLE ENTRIES, so both
;   framings put every entry boundary in the SAME place and emit the SAME
;   bytes -- the byte gate cannot distinguish them, which is exactly why
;   this is written down instead of silently resolved.
;   promB4's base is kept because it is ANCHORED: display-list record
;   0xF3C372 names 0xF3C3AD, the handler fixes the 8-byte width, and
;   0xF3C3AD + 37*8 = 0xF3C4D5 lands exactly on the next object. promB6's
;   0xF3C37D is the base of Data_F3C37D, whose extent promB4 independently
;   corrected from 257 B to 48 B -- and 0xF3C37D + 48 = 0xF3C3AD, so the
;   two accounts AGREE once that correction is applied.
;   Entry NUMBERING here is therefore relative to 0xF3C3AD.
; ------------------------------------------------------------------
; ------------------------------------------------------------------
; DLTable_F3C3AD -- 37 entries of 8 bytes, 0xF3C3AD-0xF3C4D4
; Referenced by: display-list record 0xF3C372
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3C3AD:
	.short 0x0038, 0x0074, 0x0040, 0x007F	; [0]
	.short 0x0048, 0x0074, 0x0050, 0x007F	; [1]
	.short 0x0058, 0x0074, 0x0060, 0x007F	; [2]
	.short 0x0068, 0x0074, 0x0070, 0x007F	; [3]
	.short 0x0078, 0x0074, 0x0080, 0x007F	; [4]
	.short 0x0088, 0x0074, 0x0090, 0x007F	; [5]
	.short 0x0098, 0x0074, 0x00A0, 0x007F	; [6]
	.short 0x00A8, 0x0074, 0x00B0, 0x007F	; [7]
	.short 0x00B8, 0x0074, 0x00C0, 0x007F	; [8]
	.short 0x00C8, 0x0074, 0x00D0, 0x007F	; [9]
	.short 0x00D8, 0x0074, 0x00E0, 0x007F	; [10]
	.short 0x00E8, 0x0074, 0x00F0, 0x007F	; [11]
	.short 0x00F8, 0x0074, 0x0100, 0x007F	; [12]
	.short 0x0108, 0x0074, 0x0110, 0x007F	; [13]
	.short 0x0038, 0x0083, 0x0040, 0x008E	; [14]
	.short 0x0048, 0x0083, 0x0050, 0x008E	; [15]
	.short 0x0058, 0x0083, 0x0060, 0x008E	; [16]
	.short 0x0068, 0x0083, 0x0070, 0x008E	; [17]
	.short 0x0078, 0x0083, 0x0080, 0x008E	; [18]
	.short 0x0088, 0x0083, 0x0090, 0x008E	; [19]
	.short 0x0098, 0x0083, 0x00A0, 0x008E	; [20]
	.short 0x00A8, 0x0083, 0x00B0, 0x008E	; [21]
	.short 0x00B8, 0x0083, 0x00C0, 0x008E	; [22]
	.short 0x00C8, 0x0083, 0x00D0, 0x008E	; [23]
	.short 0x00D8, 0x0083, 0x00E0, 0x008E	; [24]
	.short 0x00E8, 0x0083, 0x00F0, 0x008E	; [25]
	.short 0x00F8, 0x0083, 0x0100, 0x008E	; [26]
	.short 0x0038, 0x0093, 0x0040, 0x009E	; [27]
	.short 0x0048, 0x0093, 0x0050, 0x009E	; [28]
	.short 0x0058, 0x0093, 0x0060, 0x009E	; [29]
	.short 0x0068, 0x0093, 0x0070, 0x009E	; [30]
	.short 0x0078, 0x0093, 0x0080, 0x009E	; [31]
	.short 0x0088, 0x0093, 0x0090, 0x009E	; [32]
	.short 0x0098, 0x0093, 0x00A0, 0x009E	; [33]
	.short 0x00A8, 0x0093, 0x00B0, 0x009E	; [34]
	.short 0x00B8, 0x0093, 0x00C0, 0x009E	; [35]
	.short 0x00C8, 0x0093, 0x00D0, 0x009E	; [36]

; === END COVER-R1 0xF3C37D-0xF3C4D5 ===

; ------------------------------------------------------------------
; 0xF3C4D5-0xF3C53E -- 7 display-list records, 106 bytes -- interpreter A (6 records) and B (1)
;   entered at: 0xF3C4D5, 0xF3C530
;   ends used:  0xF3C530, 0xF3C53F
; ------------------------------------------------------------------
; DL_ACurrentTrackWillBeClearedAutomaticaly -- the display list at 0xF3C4D5.
;                                              Its own text records read: "A
;                                              current"; "track will be";
;                                              "cleared automaticaly"; "Are
;                                              You Sure ?".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ACurrentTrackWillBeClearedAutomaticaly:
	dl_text8x14	x=24, y=156, text="A current "
	dl_text8x14	x=160, y=156, text=" track will be"
	dl_text8x16	x=184, y=170, text="."
	dl_text8x14	x=24, y=172, text="cleared automaticaly"
	dl_text16x16_packed	x=64, y=196, text="Are You Sure ?"
	dl_box_shadow2	x0=17, y0=152, x1=290, y1=233
Paint_S0ngC0py_DL:
; ; drawn (start operand) by Paint_S0ngC0py -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage+17, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_ChordApcControlRhythm, width=7, x=104, y=156

; === COVER-R1 0xF3C53F-0xF3C562 ===
; 0xF3C53F-0xF3C561, coverage round 1: 35 of this span's 35 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 35 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF3C53F-0xF3C561 -- 35 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3C53F appears as a 32-bit word at 0xF3C537.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 100% printable ASCII; a linear decode runs 21 instructions and
;           ends `ld W,0x00`, with 17% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_ChordApcControlRhythm -- 0xF3C53F-0xF3C561, 5 entries of 7 bytes,
;   text drawn by LCD_Svc_06_DrawText8x14.  Read by the interpreter-B
;   op-0x02 record at 0xF3C530 ((0x1307) AND 0x7F >> 0) -- value = (byte at
;   the +2 address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 7 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 128.  This address is also the END of a display list: `ld
;   XIY,0xF3C530 / ld XIX,this / call T_DisplayListB_Run` at 0xF802C2.
; --------------------------------------------------------------------------
DLText_ChordApcControlRhythm:
	.ascii	"       "	; F3C53F  [0]
	.ascii	" CHORD "	; F3C546  [1]
	.ascii	"  APC  "	; F3C54D  [2]
	.ascii	"CONTROL"	; F3C554  [3]
	.ascii	"RHYTHM "	; F3C55B  [4]

; === END COVER-R1 0xF3C53F-0xF3C562 ===

; ------------------------------------------------------------------
; 0xF3C562-0xF3C6B2 -- 37 display-list records, 337 bytes -- interpreter A
;   entered at: 0xF3C562
;   ends used:  0xF3C6B3
; ------------------------------------------------------------------
; DL_SequencerMedleyStartFirstS0ng -- the display list at 0xF3C562.  Its own
;                                     text records read: "SEQUENCER MEDLEY";
;                                     "START"; "FIRST S0NG"; "STOP"; "SKIP";
;                                     "LAST S0NG"; "SONG"; "MIDI" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SequencerMedleyStartFirstS0ng:
	dl_text16x16_packed	x=88, y=6, text="SEQUENCER MEDLEY"
	dl_text8x16	x=312, y=72, text="\021"
	dl_text8x14	x=264, y=73, text="START"
	dl_text8x16	x=0, y=77, text="\020"
	dl_text8x16	x=32, y=77, text="FIRST S0NG    "
	dl_text16x16	x=104, y=112, text="\211"
	dl_text8x16	x=312, y=114, text="\021"
	dl_text8x14	x=264, y=115, text="STOP"
	dl_text8x16	x=312, y=150, text="\021"
	dl_text8x14	x=264, y=151, text="SKIP"
	dl_text8x16	x=0, y=153, text="\020"
	dl_text8x16	x=32, y=154, text="LAST S0NG     "
	dl_text8x14	x=168, y=200, text="SONG"
	dl_text8x8_packed	x=247, y=210, text="MIDI"
	dl_text8x8_packed	x=288, y=210, text="NORM"
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x8_packed	x=247, y=221, text="FILE"
	dl_text8x8_packed	x=288, y=221, text="FILE"
	dl_text8x16	x=176, y=225, text="\216"
	dl_text16x16_packed	x=254, y=229, text="\022"
	dl_text16x16_packed	x=296, y=229, text="\022"
	dl_text8x8_packed	x=196, y=79, text="\020"
	dl_value_glyph	glyph=56, x=64, y=1
	dl_box_shadow2	x0=11, y0=67, x1=194, y1=98
	dl_box_shadow2	x0=11, y0=143, x1=194, y1=174
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_box	x0=260, y0=68, x1=308, y1=87
	dl_box	x0=262, y0=70, x1=306, y1=85
	dl_box	x0=260, y0=110, x1=308, y1=129
	dl_box	x0=262, y0=112, x1=306, y1=127
	dl_box	x0=260, y0=146, x1=308, y1=165
	dl_box	x0=243, y0=206, x1=275, y1=231
	dl_box	x0=284, y0=206, x1=317, y1=231
	dl_hline	x0=194, y0=82, x1=210, y1=82
	dl_hline	x0=194, y0=160, x1=210, y1=160
	dl_hline	x0=165, y0=224, x1=196, y1=224
	dl_vline	x0=210, y0=82, x1=210, y1=160

; --- 0xF3C6B3-0xF3C720: not converted ---

; ------------------------------------------------------------------
; 0xF3C6B3-0xF3C720 -- 13 display-list records, 110 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C6B3 lands with ZERO DRIFT exactly on 0xF3C721,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
DL_F3C6B3:
	dl_text8x14	x=72, y=194, text="SELECT"
	dl_text8x14	x=40, y=215, text="INT"
	dl_text8x14	x=88, y=215, text="FD"
	dl_text8x14	x=128, y=215, text="HD"
	dl_text16x16_packed	x=46, y=229, text="\022"
	dl_text16x16_packed	x=89, y=229, text="\022"
	dl_text16x16_packed	x=130, y=229, text="\022"
	dl_box_shadow2	x0=36, y0=212, x1=68, y1=228
	dl_box_shadow2	x0=77, y0=212, x1=109, y1=228
	dl_box_shadow2	x0=120, y0=212, x1=152, y1=228
	dl_hline	x0=36, y0=206, x1=152, y1=206
	dl_vline	x0=36, y0=206, x1=36, y1=209
	dl_vline	x0=152, y0=206, x1=152, y1=209

; ------------------------------------------------------------------
; 0xF3C721-0xF3C7AC -- 15 display-list records, 140 bytes -- interpreter A (10 records) and B (5)
;   entered at: 0xF3C721, 0xF3C778
;   ends used:  0xF3C778, 0xF3C78C, 0xF3C7AD
; ------------------------------------------------------------------
; DL_SelectIntFd -- the display list at 0xF3C721.  Its own text records read:
;                   "SELECT"; "INT"; "FD".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SelectIntFd:
	dl_text8x14	x=48, y=194, text="SELECT"
	dl_text8x14	x=40, y=215, text="INT"
	dl_text8x14	x=88, y=215, text="FD"
	dl_text16x16_packed	x=46, y=229, text="\022"
	dl_text16x16_packed	x=89, y=229, text="\022"
	dl_box_shadow2	x0=36, y0=212, x1=68, y1=228
	dl_box_shadow2	x0=77, y0=212, x1=109, y1=228
	dl_hline	x0=36, y0=206, x1=109, y1=206
	dl_vline	x0=36, y0=206, x1=36, y1=209
	dl_vline	x0=109, y0=206, x1=109, y1=209
; DL_FirstS0ngLastS0ng -- the display list at 0xF3C778, named by mechanism M3
;                         of notes/prom_b_dl_screens_round5.py.  "FIRST S0NG"
;                         ends at 0x0C1A  "LAST S0NG" ends at 0x1822
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_FirstS0ngLastS0ng:
	dlb_number	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=144, y=77, digits=3
	dlb_number	var=DisplayListB_Stage+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=144, y=154, digits=3
	dlb_rect_entry	var=DisplayListB_Stage+12, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=Data_F3C7E3
	dlb_rect_entry	var=DisplayListB_Stage+13, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=Data_F3C7E3 + 0x18
	dlb_rect_entry	var=DisplayListB_Stage+14, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=Data_F3C7E3 + 0x30

; --- 0xF3C7AD-0xF3C7C2: not converted ---

; ------------------------------------------------------------------
; 0xF3C7AD-0xF3C7C2 -- 2 display-list records, 22 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C7AD lands with ZERO DRIFT exactly on 0xF3C7C3,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
SequencerMedley_DrawPlayState_DL4:
; ; drawn (start operand) by SequencerMedley_DrawPlayState -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_rect_entry	var=DisplayListB_Stage+15, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=Data_F3C7E3+0x40	; operand bytes the handler does not read
	dlb_rect_entry_op08	var=DisplayListB_Stage+12, mask=0x0f, shift=0, svc=LCDSVC_EraseRect, table=Data_F3C7E3+0x50

; ------------------------------------------------------------------
; 0xF3C7C3-0xF3C7CC -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF3C7C3
;   ends used:  0xF3C7CD
; ------------------------------------------------------------------
SequencerMedley_DrawSourceBox_DL:
; ; drawn (start operand) by SequencerMedley_DrawSourceBox -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=36, y0=212, x1=152, y1=228

; === COVER-R1 0xF3C7CD-0xF3C86B ===
; 0xF3C7CD-0xF3C86A, coverage round 1: 136 of this span's 158 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 136 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF3C7CD-0xF3C7E2 -- 2 display-list records, 22 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C7CD lands with ZERO DRIFT exactly on 0xF3C7E3,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
SequencerMedley_DrawFileTypeBox_DL:
; ; drawn (start operand) by SequencerMedley_DrawFileTypeBox -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text16x16	x=224, y=121, text="\017\000\033K\310\363\000"
	dl_text16x16	x=232, y=121, text="\017\000\033[\310\363\000"

; --------------------------------------------------------------------------
; Data_F3C7E3 -- 136 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F3C7E3 appears as a 32-bit word at 0xF3C793.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 15% printable ASCII; a linear decode runs 75 instructions and ends
;           `jrl NC,0xf3c86c`, with 53% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F3C7E3:
	.byte	0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x0B, 0x00, 0x43, 0x00, 0xC2, 0x00, 0x62, 0x00	; F3C7E3  |..........C...b.|
	.byte	0x0B, 0x00, 0x8F, 0x00, 0xC2, 0x00, 0xAE, 0x00, 0x24, 0x00, 0xD4, 0x00, 0x44, 0x00, 0xE4, 0x00	; F3C7F3  |........$...D...|
	.byte	0x4D, 0x00, 0xD4, 0x00, 0x6D, 0x00, 0xE4, 0x00, 0x78, 0x00, 0xD4, 0x00, 0x98, 0x00, 0xE4, 0x00	; F3C803  |M...m...x.......|
	.byte	0x1C, 0x01, 0xCE, 0x00, 0x3D, 0x01, 0xE7, 0x00, 0xF3, 0x00, 0xCE, 0x00, 0x13, 0x01, 0xE7, 0x00	; F3C813  |....=...........|
	.byte	0x06, 0x01, 0x70, 0x00, 0x32, 0x01, 0x7F, 0x00, 0x06, 0x01, 0x46, 0x00, 0x32, 0x01, 0x55, 0x00	; F3C823  |..p.2.....F.2.U.|
	.byte	0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x0B, 0x00, 0x8F, 0x00, 0xC2, 0x00, 0xAE, 0x00	; F3C833  |................|
	.byte	0x0B, 0x00, 0x43, 0x00, 0xC2, 0x00, 0x62, 0x00, 0xF3, 0x00, 0xCE, 0x00, 0x13, 0x01, 0xE7, 0x00	; F3C843  |..C...b.........|
	.byte	0x1C, 0x01, 0xCE, 0x00, 0x3D, 0x01, 0xE7, 0x00, 0x06, 0x01, 0x46, 0x00, 0x32, 0x01, 0x55, 0x00	; F3C853  |....=.....F.2.U.|
	.byte	0x06, 0x01, 0x70, 0x00, 0x32, 0x01, 0x7F, 0x00	; F3C863  |..p.2...|

; === END COVER-R1 0xF3C7CD-0xF3C86B ===

; ------------------------------------------------------------------
; 0xF3C86B-0xF3C872 -- 1 display-list records, 8 bytes -- interpreter A
;   entered at: 0xF3C86B
;   ends used:  0xF3C873
; ------------------------------------------------------------------
SequencerMedley_DrawPlayState_DL1:
; ; drawn (start operand) by SequencerMedley_DrawPlayState -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_clear_area	x=32, y=37, w=264, h=16


; ------------------------------------------------------------------
; 0xF3C873-0xF3C89C -- 3 display-list records, 42 bytes -- interpreter A
; Formerly Data_F3C873 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
SequencerMedley_DrawPlayState_DL2:
; ; drawn (start operand) by SequencerMedley_DrawPlayState -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x16	x=32, y=37, text="N0W PLAYING S0NG "
	dl_text8x16	x=192, y=37, text=" :"
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, table=Medley_DisplayName, width=11, x=208, y=37	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF3C89D-0xF3C946 -- 9 display-list records, 170 bytes -- interpreter A (8 records) and B (1)
;   entered at: 0xF3C89D, 0xF3C8A7
;   ends used:  0xF3C8A7, 0xF3C947
; ------------------------------------------------------------------
SequencerMedley_DrawPlayState_DL3:
; ; drawn (start operand) by SequencerMedley_DrawPlayState -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=168, y=37, digits=3
; DL_StepRecordPartSelectPressTheUpDownButton -- the display list at 0xF3C8A7.
;                                                Its own text records read:
;                                                "STEP RECORD"; ": PART
;                                                SELECT"; "Press the up/down
;                                                button under"; "the screen
;                                                corresponding to the"; "track
;                                                that you want to"; "STEP
;                                                RECORD.".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_StepRecordPartSelectPressTheUpDownButton:
	dl_text16x16_packed	x=68, y=5, text="STEP RECORD"
	dl_text8x16	x=200, y=6, text=": PART SELECT"
	dl_text8x16	x=24, y=51, text="Press the up/down button under"
	dl_text8x16	x=24, y=72, text="the screen corresponding to the"
	dl_text8x16	x=24, y=91, text="track that you want to"
	dl_text8x16	x=24, y=113, text="STEP RECORD."
	dl_box_shadow2	x0=19, y0=39, x1=290, y1=134
	dl_value_glyph	glyph=52, x=40, y=1

; ------------------------------------------------------------------
; 0xF3C947-0xF3C975 -- 5 display-list records, 47 bytes -- interpreter A
; (4 records) then interpreter B (1 record); the B record's own +7
; field points at, and its +0x0B field gives the entry width of, the
; 28-byte string table that follows.  Wave 1's naive interp-A length
; walk misread this as unconverted because it does not know
; interpreter B's opcode 0x02 -- that opcode/length/handler table is
; already documented at wsa1_prom_b.s:52290.  See
; notes/gen_prom_b_f3c947_module.py for the full proof.
; ------------------------------------------------------------------
DL_F3C947:
	dl_clear_area	x=0, y=30, w=272, h=14
	dl_clear_area	x=0, y=75, w=272, h=6
	dl_clear_area	x=0, y=120, w=200, h=6
	dl_clear_area	x=0, y=165, w=272, h=6
	dlb_string	var=DisplayListB_Stage+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=StringTable_F3C976, width=7, x=184, y=1

; StringTable_F3C976 -- 4 entries, 7 bytes each, named by the record
; above (DL_F3C947's op-02 record: +0x07 -> here, +0x0B = 7).  The
; object's own content is these four words; the name is neutral
; (address-based) because semantic labelling is deferred this wave --
; see notes/gen_prom_b_f3c947_module.py.
StringTable_F3C976:
	.ascii "CHORD  "	; [0]
	.ascii "MELODY "	; [1]
	.ascii "CONTROL"	; [2]
	.ascii "RHYTHM "	; [3]

; ------------------------------------------------------------------
; 0xF3C992-0xF3D015 -- 206 display-list records, 1668 bytes -- interpreter A
;   named by StepSelectAddrTable_F3D089: 0xF3C992, 0xF3CA8C, 0xF3CB4B, 0xF3CB72, 0xF3CC3A, 0xF3CCF1, 0xF3CD88, 0xF3CE47, 0xF3CEE2, 0xF3CF09, 0xF3CF57, 0xF3CFC6
; ------------------------------------------------------------------
DL_F3C992:
	dl_text8x14	x=280, y=43, text="MIX"
	dl_box	x0=277, y0=40, x1=307, y1=55
	dl_box	x0=275, y0=38, x1=309, y1=57
	dl_text8x16	x=312, y=42, text="\021"
	dl_text8x14	x=280, y=83, text="ERS"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x16	x=312, y=82, text="\021"
	dl_text8x14	x=280, y=123, text="CTL"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x14	x=272, y=163, text="REST"
	dl_box	x0=269, y0=160, x1=307, y1=175
	dl_box	x0=267, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=162, text="\021"
	dl_text8x14	x=8, y=199, text="MEAS NOTE VEL   LENGTH   PHRS  CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=56, y=210, text="\215"
	dl_text8x14	x=56, y=223, text="\216"
	dl_text8x14	x=96, y=210, text="\215"
	dl_text8x14	x=96, y=223, text="\216"
	dl_text8x14	x=136, y=210, text="\215"
	dl_text8x14	x=136, y=223, text="\216"
	dl_text8x14	x=176, y=210, text="\215"
	dl_text8x14	x=176, y=223, text="\216"
	dl_text8x14	x=216, y=210, text="\215"
	dl_text8x14	x=216, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CA8C:
	dl_text8x14	x=160, y=199, text="VALUE"
	dl_text8x14	x=176, y=210, text="\215"
	dl_text8x14	x=176, y=223, text="\216"
	dl_box_shadow2	x0=165, y0=210, x1=195, y1=236
	dl_hline	x0=165, y0=223, x1=195, y1=223
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=280, y=43, text="MIX"
	dl_box	x0=277, y0=40, x1=307, y1=55
	dl_box	x0=275, y0=38, x1=309, y1=57
	dl_text8x16	x=312, y=42, text="\021"
	dl_text8x14	x=280, y=83, text="ERS"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x16	x=312, y=82, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CB4B:
	dl_text8x14	x=120, y=199, text="TEMPO"
	dl_text8x14	x=136, y=210, text="\215"
	dl_text8x14	x=136, y=223, text="\216"
	dl_box_shadow2	x0=125, y0=210, x1=155, y1=236
	dl_hline	x0=125, y0=223, x1=155, y1=223
DL_F3CB72:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=280, y=123, text="ERS"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x16	x=312, y=122, text="\021"
	dl_text8x14	x=272, y=147, text="TRACK"
	dl_text8x14	x=280, y=163, text="CLR"
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=122, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
	dl_text8x14	x=120, y=199, text="TEMPO"
	dl_text8x14	x=136, y=210, text="\215"
	dl_text8x14	x=136, y=223, text="\216"
	dl_box_shadow2	x0=125, y0=210, x1=155, y1=236
	dl_hline	x0=125, y0=223, x1=155, y1=223
DL_F3CC3A:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=280, y=43, text="MIX"
	dl_text8x16	x=312, y=42, text="\021"
	dl_box	x0=277, y0=40, x1=307, y1=55
	dl_box	x0=275, y0=38, x1=309, y1=57
	dl_text8x14	x=280, y=123, text="YES"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x14	x=280, y=163, text="NO"
	dl_text8x16	x=312, y=162, text="\021"
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CCF1:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=280, y=123, text="YES"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x14	x=280, y=163, text="NO"
	dl_text8x16	x=312, y=162, text="\021"
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CD88:
	dl_text8x14	x=280, y=43, text="MIX"
	dl_text8x16	x=312, y=42, text="\021"
	dl_box	x0=277, y0=40, x1=307, y1=55
	dl_box	x0=275, y0=38, x1=309, y1=57
	dl_text8x14	x=280, y=83, text="ERS"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x16	x=312, y=82, text="\021"
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=160, y=199, text="VALUE"
	dl_text8x14	x=176, y=210, text="\215"
	dl_text8x14	x=176, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_box_shadow2	x0=165, y0=210, x1=195, y1=236
	dl_hline	x0=165, y0=223, x1=195, y1=223
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CE47:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=208, y=218, text="REP"
	dl_text8x14	x=248, y=218, text="END"
	dl_box_shadow2	x0=205, y0=210, x1=235, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_text8x14	x=280, y=83, text="ERS"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x16	x=312, y=82, text="\021"
	dl_text8x14	x=272, y=147, text="TRACK"
	dl_text8x14	x=280, y=163, text="CLR"
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=162, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CEE2:
	dl_text8x14	x=120, y=199, text="VALUE"
	dl_text8x14	x=136, y=210, text="\215"
	dl_text8x14	x=136, y=223, text="\216"
	dl_box_shadow2	x0=125, y0=210, x1=155, y1=236
	dl_hline	x0=125, y0=223, x1=155, y1=223
Paint_StepRecord_DL2:
; ; drawn (start operand) by Paint_StepRecord -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=52, x=40, y=1
	dl_text8x16	x=88, y=1, text="STEP RECORD:"
	dl_text8x14	x=120, y=16, text="TRACK:"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
; Display-list records that prom_a names by number; from this record to the next label
; their own text records read: "MASTER STEP RECORD".
; The name is CamelCase of that text (notes/gen_prom_b_f067a6_module.py --dl-names's rule)
; and says what the interpreter draws from here, nothing more.
; Referenced by prom_a: Paint_StepRecord (ld).
; (Labelled by wsa1/scripts/tools/label_cross_image_targets.py so the prom_a operands
;  can be written symbolically.)
DL_MasterStepRecord:
	dl_value_glyph	glyph=58, x=40, y=1
	dl_text8x16	x=88, y=1, text="MASTER STEP RECORD"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3CF57:
	dl_text8x14	x=280, y=83, text="YES"
	dl_text8x16	x=312, y=82, text="\021"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x14	x=280, y=123, text="NO"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
Paint_StepRecord_DL1:
; ; drawn (start operand) by Paint_StepRecord -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text16x16	x=64, y=110, text="Are You Sure?"
	dl_text8x14	x=280, y=83, text="YES"
	dl_text8x16	x=312, y=82, text="\021"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x14	x=280, y=123, text="NO"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137

; ------------------------------------------------------------------
; 0xF3D016-0xF3D088 -- 13 display-list records, 115 bytes -- interpreter A
;   entered at: 0xF3D016
;   ends used:  0xF3D089
; ------------------------------------------------------------------
; DL_StepRecordTrackTrackClrMeas -- the display list at 0xF3D016.  Its own
;                                   text records read: "STEP RECORD:";
;                                   "TRACK:"; "TRACK"; "CLR"; "MEAS".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_StepRecordTrackTrackClrMeas:
	dl_text8x16	x=88, y=1, text="STEP RECORD:"
	dl_text8x14	x=120, y=16, text="TRACK:"
	dl_text8x14	x=272, y=147, text="TRACK"
	dl_text8x14	x=280, y=163, text="CLR"
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=162, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223

; ------------------------------------------------------------------
; StepSelectAddrTable_F3D089 -- 76 4-byte little-endian addresses = TWO
;   19-pair (start,end) tables, back to back.  entries [0,19) are the
;   "cond0" starts, [19,38) its ends, [38,57) the "cond2" starts, [57,76)
;   its ends -- i.e. StepList(i, cond) = [entry[cond*38+i], entry[cond*38+19+i]).
; Evidence: prom_a 0xF81B70-0xF81B9B loads XIY from this table's cond0 base
;   (or 0xF3D121 = +38 entries, when (0x2740)==(0x0e63)==2), scaled by an
;   index in HL*4 through an indexed load (`ld xiy, (xiy+hl)`), and
;   XIX the same way from +19 entries (or +57) -- see the header of
;   notes/gen_prom_b_stepselect_module.py for the exact instructions.
;   All 38 (start,end) pairs, both conditions, satisfy the tree's own
;   record-framing check (notes/gen_prom_b_stepselect_module.py
;   --verify-table: 19/19 and 19/19) -- independent confirmation that this
;   IS an address table and not a coincidence of the caller evidence above.
; Unknown: what selects the index in HL (a step or measure number is the
;   caller's own name for it, `Paint_StepRecordTrackClrMeas`, but the
;   selector itself is not traced here).
; ------------------------------------------------------------------
StepSelectAddrTable_F3D089:
	.long DL_F3C992	; [ 0] cond0 start[ 0]
	.long DL_F3DEB2	; [ 1] cond0 start[ 1]
	.long DL_F3CC3A	; [ 2] cond0 start[ 2]
	.long DL_F3CD88	; [ 3] cond0 start[ 3]
	.long DL_F3E2EB	; [ 4] cond0 start[ 4]
	.long DL_F3E228	; [ 5] cond0 start[ 5]
	.long DL_F3CCF1	; [ 6] cond0 start[ 6]
	.long DL_F3CB72	; [ 7] cond0 start[ 7]
	.long DL_F3E15C	; [ 8] cond0 start[ 8]
	.long DL_F3CA8C	; [ 9] cond0 start[ 9]
	.long DL_F3CA8C	; [10] cond0 start[10]
	.long DL_F3DF6A	; [11] cond0 start[11]
	.long DL_F3CE47	; [12] cond0 start[12]
	.long DL_F3CE47	; [13] cond0 start[13]
	.long DL_F3CE47	; [14] cond0 start[14]
	.long DL_F3CE47	; [15] cond0 start[15]
	.long DL_F3CF57	; [16] cond0 start[16]
	.long DL_F3CE47	; [17] cond0 start[17]
	.long Paint_StepRecord_DL1	; [18] cond0 start[18]
	.long DL_F3CA8C	; [19] cond0 end[ 0]
	.long DL_F3DF6A	; [20] cond0 end[ 1]
	.long DL_F3CCF1	; [21] cond0 end[ 2]
	.long DL_F3CE47	; [22] cond0 end[ 3]
	.long DL_F3E2EB + 0x78	; [23] cond0 end[ 4]
	.long DL_F3E2EB	; [24] cond0 end[ 5]
	.long DL_F3CD88	; [25] cond0 end[ 6]
	.long DL_F3CC3A	; [26] cond0 end[ 7]
	.long DL_F3E228	; [27] cond0 end[ 8]
	.long DL_F3CB4B	; [28] cond0 end[ 9]
	.long DL_F3CB4B	; [29] cond0 end[10]
	.long DL_F3E04E	; [30] cond0 end[11]
	.long DL_F3CEE2	; [31] cond0 end[12]
	.long DL_F3CEE2	; [32] cond0 end[13]
	.long DL_F3CEE2	; [33] cond0 end[14]
	.long DL_F3CEE2	; [34] cond0 end[15]
	.long Paint_StepRecord_DL1	; [35] cond0 end[16]
	.long Paint_StepRecord_DL2	; [36] cond0 end[17]
	.long DL_StepRecordTrackTrackClrMeas	; [37] cond0 end[18]
	.long DL_F3C992	; [38] cond2 start[ 0]
	.long DL_F3E2EB	; [39] cond2 start[ 1]
	.long DL_F3CC3A	; [40] cond2 start[ 2]
	.long DL_F3CD88	; [41] cond2 start[ 3]
	.long DL_F3E2EB	; [42] cond2 start[ 4]
	.long DL_F3E228	; [43] cond2 start[ 5]
	.long DL_F3CCF1	; [44] cond2 start[ 6]
	.long DL_F3CB72	; [45] cond2 start[ 7]
	.long DL_F3E15C	; [46] cond2 start[ 8]
	.long DL_F3CA8C	; [47] cond2 start[ 9]
	.long DL_F3CA8C	; [48] cond2 start[10]
	.long DL_F3DF6A	; [49] cond2 start[11]
	.long DL_F3CE47	; [50] cond2 start[12]
	.long DL_F3CE47	; [51] cond2 start[13]
	.long DL_F3CE47	; [52] cond2 start[14]
	.long DL_F3CE47	; [53] cond2 start[15]
	.long DL_F3CF57	; [54] cond2 start[16]
	.long DL_F3CE47	; [55] cond2 start[17]
	.long Paint_StepRecord_DL1	; [56] cond2 start[18]
	.long DL_F3CA8C	; [57] cond2 end[ 0]
	.long DL_F3E2EB + 0x78	; [58] cond2 end[ 1]
	.long DL_F3CCF1	; [59] cond2 end[ 2]
	.long DL_F3CE47	; [60] cond2 end[ 3]
	.long DL_F3E2EB + 0x78	; [61] cond2 end[ 4]
	.long DL_F3E2EB	; [62] cond2 end[ 5]
	.long DL_F3CD88	; [63] cond2 end[ 6]
	.long DL_F3CC3A	; [64] cond2 end[ 7]
	.long DL_F3E228	; [65] cond2 end[ 8]
	.long DL_F3CB4B	; [66] cond2 end[ 9]
	.long DL_F3CB4B	; [67] cond2 end[10]
	.long DL_F3E04E	; [68] cond2 end[11]
	.long DL_F3CEE2	; [69] cond2 end[12]
	.long DL_F3CEE2	; [70] cond2 end[13]
	.long DL_F3CEE2	; [71] cond2 end[14]
	.long DL_F3CEE2	; [72] cond2 end[15]
	.long Paint_StepRecord_DL1	; [73] cond2 end[16]
	.long Paint_StepRecord_DL2	; [74] cond2 end[17]
	.long DL_StepRecordTrackTrackClrMeas	; [75] cond2 end[18]

; ------------------------------------------------------------------
; 0xF3D1B9-0xF3D5E4 -- 88 display-list records, 1068 bytes -- interpreter A
; ------------------------------------------------------------------
DL_F3D1B9:
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0023
	.short 0x0046
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0024
	.short 0x000A
	.short 0x0028
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0046
	.short 0x0024
	.short 0x0046
	.short 0x0028
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x04B5
	.byte 0x15	; character codes below 0x20
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x0023
	.short 0x0086
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x0024
	.short 0x004A
	.short 0x0028
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0086
	.short 0x0024
	.short 0x0086
	.short 0x0028
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x04BD
	.byte 0x15	; character codes below 0x20
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x0023
	.short 0x00C6
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x0024
	.short 0x008A
	.short 0x0028
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C6
	.short 0x0024
	.short 0x00C6
	.short 0x0028
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x04C5
	.byte 0x15	; character codes below 0x20
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CA
	.short 0x0023
	.short 0x0106
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CA
	.short 0x0024
	.short 0x00CA
	.short 0x0028
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0106
	.short 0x0024
	.short 0x0106
	.short 0x0028
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x04CD
	.byte 0x15	; character codes below 0x20
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x004B
	.short 0x0005
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x0050
	.short 0x0049
	.short 0x0050
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0049
	.short 0x004B
	.short 0x0049
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x0050
	.short 0x0089
	.short 0x0050
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0089
	.short 0x004B
	.short 0x0089
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x0050
	.short 0x00C9
	.short 0x0050
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C9
	.short 0x004B
	.short 0x00C9
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CA
	.short 0x0050
	.short 0x0109
	.short 0x0050
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x004B
	.short 0x0109
	.short 0x004F
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x0078
	.short 0x0005
	.short 0x007C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x007D
	.short 0x0049
	.short 0x007D
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0049
	.short 0x0078
	.short 0x0049
	.short 0x007C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x007D
	.short 0x0089
	.short 0x007D
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0089
	.short 0x0078
	.short 0x0089
	.short 0x007C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x007D
	.short 0x00C9
	.short 0x007D
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C9
	.short 0x0078
	.short 0x00C9
	.short 0x007C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CA
	.short 0x007D
	.short 0x0109
	.short 0x007D
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x0078
	.short 0x0109
	.short 0x007C
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00A5
	.short 0x0005
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AA
	.short 0x0049
	.short 0x00AA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0049
	.short 0x00A5
	.short 0x0049
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x00AA
	.short 0x0089
	.short 0x00AA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0089
	.short 0x00A5
	.short 0x0089
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x00AA
	.short 0x00C9
	.short 0x00AA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C9
	.short 0x00A5
	.short 0x00C9
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CA
	.short 0x00AA
	.short 0x0109
	.short 0x00AA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x00A5
	.short 0x0109
	.short 0x00A9
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x12F6
	.byte 0x00, 0x00, 0x06	; character codes below 0x20
	.ascii "A"
	.byte 0x06, 0x03	; character codes below 0x20
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x12F8
	.byte 0x00, 0x00, 0x06	; character codes below 0x20
	.ascii "I"
	.byte 0x0D, 0x03	; character codes below 0x20
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x12FA
	.byte 0x00, 0x00, 0x06	; character codes below 0x20
	.ascii "Q"
	.byte 0x14, 0x03	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x0641
	.ascii "-"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x0D49
	.ascii "-"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1451
	.ascii "-"
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x12FD
	.short 0x00FF
	.short 0x9506
	.short 0x0202
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x0000
	.short 0xE406
	.short 0x000F
	.byte 0x00, 0x1E, 0x00, 0x21, 0x1C	; operand bytes the handler does not read
	.byte 0x20, 0x20	; op 20, 32 bytes -> handler 0xF31A3A
	.short 0x2020
	.ascii "END REP "
	.byte 0x1B	; character codes below 0x20
	.ascii "   "
	.byte 0x1C	; character codes below 0x20
	.ascii "   "
	.byte 0x02, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x06, 0x12, 0x10, 0x00, 0x00, 0x1E	; character codes below 0x20
	.byte 0x00, 0x21	; op 00, 33 bytes -> handler 0xF31A75
	.short 0x0208
	.short 0x000F
	.short 0x0313
	.short 0x0600
	.byte 0x23, 0xDE, 0xF3, 0x00, 0x01, 0x00, 0x51, 0x0A, 0x02, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x06, 0x30, 0x10, 0x00, 0x00, 0x1E, 0x00, 0x29, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x1301
	.short 0x820C
	.short 0x2306
	.short 0xF3DE
	.byte 0x00, 0x01, 0x00, 0x59, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x0000
	.short 0x4E06
	.short 0x0010
	.byte 0x00, 0x1E, 0x00, 0x31, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x1302
	.short 0x8430
	.short 0x2306
	.short 0xF3DE
	.byte 0x00, 0x01, 0x00, 0x61, 0x18	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2640
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x21, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2641
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x25, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2642
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x29, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2643
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x2D, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2644
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x31, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2645
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x35, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2646
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x39, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2647
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x3D, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2648
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x29, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2649
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x2D, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264A
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x31, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264B
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x35, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264C
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x39, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264D
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x3D, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264E
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x41, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264F
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x45, 0x0F	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2650
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x31, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2651
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x35, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2652
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x39, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2653
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x3D, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2654
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x41, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2655
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x45, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2656
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x49, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2657
	.short 0x00FF
	.short 0x9906
	.short 0xF3D3
	.byte 0x00, 0x04, 0x00, 0x4D, 0x16	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2648
	.short 0x00FF
	.short 0xA706
	.short 0xF3D9
	.byte 0x00, 0x02, 0x00, 0x21, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2649
	.short 0x00FF
	.short 0xC706
	.short 0xF3D9
	.byte 0x00, 0x05, 0x00, 0x23, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2658
	.short 0x0003
	.short 0x6706
	.short 0xF3DA
	.byte 0x00, 0x02, 0x00, 0x23, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264A
	.short 0x00FF
	.short 0xA706
	.short 0xF3D9
	.byte 0x00, 0x02, 0x00, 0x25, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264B
	.short 0x00FF
	.short 0xC706
	.short 0xF3D9
	.byte 0x00, 0x05, 0x00, 0x27, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2658
	.short 0x0003
	.short 0x6706
	.short 0xF3DA
	.byte 0x00, 0x02, 0x00, 0x27, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x264C
	.short 0x00FF
	.short 0xA706
	.short 0xF3D9
	.byte 0x00, 0x02, 0x00, 0x29, 0x08	; operand bytes the handler does not read
	.byte 0x02, 0x0D	; op 02, 13 bytes -> handler 0xF31A75
	.short 0x264D
	.short 0x00FF
	.short 0xC706
	.short 0xF3D9
	.byte 0x00, 0x05, 0x00	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF3D5E5-0xF3DA6E -- 2 unlabelled bytes then a 64-entry FIXED-STRIDE
; array (15 bytes/entry, 960 bytes) of the SAME field-and-pointer
; record already used just above this span, plus the three small
; string tables its own pointer fields name.  The array's per-entry
; +01 byte is NOT a length (proved by the fixed-stride walk landing
; exactly on the first table despite one entry's +01 reading 0x14
; instead of the usual 0x0F) -- wave 1's length-directed walk read
; that byte as an opcode and stopped here.  Full proof in
; notes/gen_prom_b_f3d5e5_module.py.
; ------------------------------------------------------------------
Data_F3D5E5:
	.short 0x082B	; == record[0]'s own +0x0D screen position below; role undetermined

StepRecordChordFieldArray_F3D5E7:
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x082B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+14	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x082D	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+15	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x082F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x082F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+16	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0831	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+17	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0833	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0833	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0835	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+19	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0837	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0837	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+20	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0839	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+21	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x083B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x083B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+22	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x083D	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+23	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x083F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x083F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F29	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F2B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F2B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F2D	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+11	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F2F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F2F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+12	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F31	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+13	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F33	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F33	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+14	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F35	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+15	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F37	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F37	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+16	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F39	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+17	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F3B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F3B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F3D	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+19	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F3F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F3F	; +0x0D screen position
	.byte 0x02, 0x14	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+20	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F41	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+21	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F43	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F43	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+22	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F45	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+23	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x0F47	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x0F47	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1631	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x1633	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1633	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1635	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+11	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x1637	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1637	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+12	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1639	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+13	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x163B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x163B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+14	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x163D	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+15	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x163F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x163F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+16	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1641	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+17	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x1643	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1643	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+18	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1645	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+19	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x1647	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1647	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+20	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x1649	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+21	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x164B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x164B	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+22	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long NoteNameTable_F3D9A7	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x164D	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+23	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordQualityTable_F3D9C7	; +0x07 -> one of this span's own tables, below
	.short 0x0005	; +0x0B entry width of that table
	.short 0x164F	; +0x0D screen position
	.byte 0x02, 0x0F	; tag 0x02; +0x01 (NOT a length here, see header)
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift
	.byte 0x06	; +0x06 swi 7 function
	.long ChordTailTable_F3DA67	; +0x07 -> one of this span's own tables, below
	.short 0x0002	; +0x0B entry width of that table
	.short 0x164F	; +0x0D screen position

; NoteNameTable_F3D9A7 -- 16 entries, 2 bytes each, named by the +0x07/
; +0x0B fields above (0xF3D9A7).  0x88/0x8C are non-ASCII glyph bytes
; this table shares with the display-list text renderer's own
; below-0x20 glyphs; not decoded further this wave.
NoteNameTable_F3D9A7:
	.ascii "  "	; [0]
	.ascii "C "	; [1]
	.byte 0x44, 0x88	; D<0x88>	; [2]
	.ascii "D "	; [3]
	.byte 0x45, 0x88	; E<0x88>	; [4]
	.ascii "E "	; [5]
	.ascii "F "	; [6]
	.byte 0x46, 0x8C	; F<0x8C>	; [7]
	.ascii "G "	; [8]
	.byte 0x41, 0x88	; A<0x88>	; [9]
	.ascii "A "	; [10]
	.byte 0x42, 0x88	; B<0x88>	; [11]
	.ascii "B "	; [12]
	.ascii "  "	; [13]
	.ascii "  "	; [14]
	.ascii "  "	; [15]

; ChordQualityTable_F3D9C7 -- 32 entries, 5 bytes each, named by the
; +0x07/+0x0B fields above (0xF3D9C7).
ChordQualityTable_F3D9C7:
	.ascii "     "	; [0]
	.ascii "     "	; [1]
	.ascii "7    "	; [2]
	.ascii "Maj7 "	; [3]
	.ascii "aug  "	; [4]
	.ascii "min  "	; [5]
	.ascii "min7 "	; [6]
	.ascii "dim  "	; [7]
	.byte 0x6D, 0x37, 0x88, 0x35, 0x20	; m7<0x88>5 	; [8]
	.ascii "mM7  "	; [9]
	.ascii "7sus4"	; [10]
	.ascii "6    "	; [11]
	.ascii "aug7 "	; [12]
	.byte 0x20, 0x20, 0x88, 0x35, 0x20	;   <0x88>5 	; [13]
	.byte 0x37, 0x20, 0x88, 0x35, 0x20	; 7 <0x88>5 	; [14]
	.ascii "79   "	; [15]
	.byte 0x37, 0x20, 0x88, 0x39, 0x20	; 7 <0x88>9 	; [16]
	.ascii "M79  "	; [17]
	.ascii "69   "	; [18]
	.ascii "m6   "	; [19]
	.byte 0x6D, 0x20, 0x88, 0x35, 0x20	; m <0x88>5 	; [20]
	.ascii "m79  "	; [21]
	.ascii "m69  "	; [22]
	.ascii "sus4 "	; [23]
	.byte 0x37, 0x20, 0x8C, 0x39, 0x20	; 7 <0x8C>9 	; [24]
	.byte 0x4D, 0x37, 0x88, 0x35, 0x20	; M7<0x88>5 	; [25]
	.byte 0x4D, 0x37, 0x8C, 0x35, 0x20	; M7<0x8C>5 	; [26]
	.byte 0x6D, 0x4D, 0x37, 0x88, 0x35	; mM7<0x88>5	; [27]
	.ascii "13   "	; [28]
	.byte 0x39, 0x8C, 0x35, 0x20, 0x20	; 9<0x8C>5  	; [29]
	.byte 0x31, 0x33, 0x88, 0x39, 0x20	; 13<0x88>9 	; [30]
	.ascii "     "	; [31]

; ChordTailTable_F3DA67 -- 4 entries, 2 bytes each, named by the
; +0x07/+0x0B fields above (0xF3DA67).  Ends the span exactly at
; 0xF3DA6E.
ChordTailTable_F3DA67:
	.ascii "  "	; [0]
	.ascii "_ "	; [1]
	.ascii "7 "	; [2]
	.ascii "6 "	; [3]

; ------------------------------------------------------------------
; 0xF3DA6F-0xF3DA76 -- 1 display-list records, 8 bytes -- interpreter A
;   entered at: 0xF3DA6F
;   ends used:  0xF3DA77
; ------------------------------------------------------------------
DL_F3DA6F:
	dl_clear_area	x=8, y=111, w=264, h=13

; ==================================================================
; 0xF3DA77-0xF3DBFF -- display-list RECORDS and the OPERAND ARRAYS they
;                    point at (393 bytes) -- converted 2026-09-02,
;                    lane promB4, notes/gen_prom_b_promB4_operand_arrays.py
; ==================================================================
;
; Right edge anchored on DL_F3DC00, a converted display-list span header.
;
; All three records are named from prom_a, which calls the interpreter-B
; op-03 handler directly: 0xF81E93, 0xF81EE3 -> 0xF3DA77; 0xF81EAE ->
; 0xF3DAA2; 0xF81ECC -> 0xF3DAED, each followed by `call T_DLB_Handler_Array8`
; (`jp 0xF31B57`).  The first record's own mask/shift (0x0C >> 2) + 1 = 4
; equals its array's extent exactly -- the one place in this lane where
; the index bound and the measured size agree.
;
Data_F3DA77:
	dlb_rect_entry	var=DisplayListB_Stage+13, mask=0x0c, shift=130, svc=LCDSVC_FillRect, table=DLTable_F3DA82

; ------------------------------------------------------------------
; DLTable_F3DA82 -- 4 entries of 8 bytes, 0xF3DA82-0xF3DAA1
; Referenced by: display-list record 0xF3DA77
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3DA82:
	.short 0x0008, 0x006F, 0x0010, 0x007B	; [0]
	.short 0x0008, 0x006F, 0x0010, 0x007B	; [1]
	.short 0x0008, 0x006F, 0x0010, 0x007B	; [2]
	.short 0x0008, 0x006F, 0x0010, 0x007B	; [3]

Data_F3DAA2:
	dlb_rect_entry	var=DisplayListB_Stage+10, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=DLTable_F3DAAD

; ------------------------------------------------------------------
; DLTable_F3DAAD -- 8 entries of 8 bytes, 0xF3DAAD-0xF3DAEC
; Referenced by: display-list record 0xF3DAA2
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3DAAD:
	.short 0x0008, 0x006F, 0x0010, 0x007B	; [0]
	.short 0x0028, 0x006F, 0x0030, 0x007B	; [1]
	.short 0x0048, 0x006F, 0x0050, 0x007B	; [2]
	.short 0x0068, 0x006F, 0x0070, 0x007B	; [3]
	.short 0x0088, 0x006F, 0x0090, 0x007B	; [4]
	.short 0x00A8, 0x006F, 0x00B0, 0x007B	; [5]
	.short 0x00C8, 0x006F, 0x00D0, 0x007B	; [6]
	.short 0x00E8, 0x006F, 0x00F0, 0x007B	; [7]

Data_F3DAED:
	dlb_rect_entry	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_FillRect, table=DLTable_F3DAF8

; ------------------------------------------------------------------
; DLTable_F3DAF8 -- 33 entries of 8 bytes, 0xF3DAF8-0xF3DBFF
; Referenced by: display-list record 0xF3DAED
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3DAF8:
	.short 0x0000, 0x0000, 0x0000, 0x0000	; [0]
	.short 0x0008, 0x006F, 0x0010, 0x007B	; [1]
	.short 0x0010, 0x006F, 0x0018, 0x007B	; [2]
	.short 0x0018, 0x006F, 0x0020, 0x007B	; [3]
	.short 0x0020, 0x006F, 0x0028, 0x007B	; [4]
	.short 0x0028, 0x006F, 0x0030, 0x007B	; [5]
	.short 0x0030, 0x006F, 0x0038, 0x007B	; [6]
	.short 0x0038, 0x006F, 0x0040, 0x007B	; [7]
	.short 0x0040, 0x006F, 0x0048, 0x007B	; [8]
	.short 0x0048, 0x006F, 0x0050, 0x007B	; [9]
	.short 0x0050, 0x006F, 0x0058, 0x007B	; [10]
	.short 0x0058, 0x006F, 0x0060, 0x007B	; [11]
	.short 0x0060, 0x006F, 0x0068, 0x007B	; [12]
	.short 0x0068, 0x006F, 0x0070, 0x007B	; [13]
	.short 0x0070, 0x006F, 0x0078, 0x007B	; [14]
	.short 0x0078, 0x006F, 0x0080, 0x007B	; [15]
	.short 0x0080, 0x006F, 0x0088, 0x007B	; [16]
	.short 0x0088, 0x006F, 0x0090, 0x007B	; [17]
	.short 0x0090, 0x006F, 0x0098, 0x007B	; [18]
	.short 0x0098, 0x006F, 0x00A0, 0x007B	; [19]
	.short 0x00A0, 0x006F, 0x00A8, 0x007B	; [20]
	.short 0x00A8, 0x006F, 0x00B0, 0x007B	; [21]
	.short 0x00B0, 0x006F, 0x00B8, 0x007B	; [22]
	.short 0x00B8, 0x006F, 0x00C0, 0x007B	; [23]
	.short 0x00C0, 0x006F, 0x00C8, 0x007B	; [24]
	.short 0x00C8, 0x006F, 0x00D0, 0x007B	; [25]
	.short 0x00D0, 0x006F, 0x00D8, 0x007B	; [26]
	.short 0x00D8, 0x006F, 0x00E0, 0x007B	; [27]
	.short 0x00E0, 0x006F, 0x00E8, 0x007B	; [28]
	.short 0x00E8, 0x006F, 0x00F0, 0x007B	; [29]
	.short 0x00F0, 0x006F, 0x00F8, 0x007B	; [30]
	.short 0x00F8, 0x006F, 0x0100, 0x007B	; [31]
	.short 0x0100, 0x006F, 0x0108, 0x007B	; [32]

; ------------------------------------------------------------------
; 0xF3DC00-0xF3DC20 -- 3 display-list records, 33 bytes -- interpreter B
;   entered at: 0xF3DC00
;   ends used:  0xF3DC21
; ------------------------------------------------------------------
DL_F3DC00:
	dlb_area_entry	var=UI_DrawScratch, mask=0xff, shift=0, svc=LCDSVC_ClearColumns, table=Data_F3DC21
	dlb_area_entry	var=UI_DrawScratch+1, mask=0xff, shift=0, svc=LCDSVC_ClearColumns, table=Data_F3DC21 + 0x1E
	dlb_area_entry	var=UI_DrawScratch+2, mask=0xff, shift=0, svc=LCDSVC_ClearColumns, table=Data_F3DC21 + 0x3C

; === COVER-R1 0xF3DC21-0xF3DE26 ===
; ⚠ CLOSED 2026-09-02 (lane promB4).  The verdict below -- "everything
;   else is NOT reachable and stays `.incbin`" -- was true of the round-1
;   REACHABILITY WALK and false of the ROM: the remainder is display-list
;   operand arrays, reached by pointer from records the walk never enters
;   because nothing CALLS them.  0 bytes of this block are `.incbin` now.
;   Evidence and regeneration: notes/gen_prom_b_promB4_operand_arrays.py
; 0xF3DC21-0xF3DE25, coverage round 1: 158 of this span's 517 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 158 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F3DC21 -- 154 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ CORRECTED 2026-09-02 (lane promB4): this header said 158 bytes.
;   The last 4 bytes were the head of the interpreter-B record at 0xF3DCBB,
;   the first of 24 that run to 0xF3DE23.
; Reached from: 0x00F3DC21 appears as a 32-bit word at 0xF3DC07.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 31% printable ASCII; a linear decode runs 99 instructions and ends
;           `retd 0x2658`, with 30% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F3DC21:
	.byte	0x51, 0x0A, 0x20, 0x00, 0x0A, 0x00, 0x59, 0x0A, 0x18, 0x00, 0x0A, 0x00, 0x61, 0x0A, 0x10, 0x00	; F3DC21  |Q. ...Y.....a...|
	.byte	0x0A, 0x00, 0x69, 0x0A, 0x08, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x59, 0x11	; F3DC31  |..i...........Y.|
	.byte	0x20, 0x00, 0x0A, 0x00, 0x61, 0x11, 0x18, 0x00, 0x0A, 0x00, 0x69, 0x11, 0x10, 0x00, 0x0A, 0x00	; F3DC41  | ...a.....i.....|
	.byte	0x71, 0x11, 0x08, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x61, 0x18, 0x20, 0x00	; F3DC51  |q...........a. .|
	.byte	0x0A, 0x00, 0x69, 0x18, 0x18, 0x00, 0x0A, 0x00, 0x71, 0x18, 0x10, 0x00, 0x0A, 0x00, 0x79, 0x18	; F3DC61  |..i.....q.....y.|
	.byte	0x08, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x91, 0x91, 0x91, 0x91, 0x2A, 0x91	; F3DC71  |..............*.|
	.byte	0x91, 0x91, 0x91, 0x2A, 0x91, 0x91, 0x2A, 0x2A, 0x91, 0x91, 0x91, 0x91, 0x2A, 0x91, 0x2A, 0x91	; F3DC81  |...*..**....*.*.|
	.byte	0x2A, 0x91, 0x91, 0x2A, 0x2A, 0x91, 0x2A, 0x2A, 0x2A, 0x91, 0x91, 0x91, 0x91, 0x2A, 0x2A, 0x91	; F3DC91  |*..**.***....**.|
	.byte	0x91, 0x2A, 0x91, 0x2A, 0x91, 0x2A, 0x2A, 0x2A, 0x91, 0x2A, 0x91, 0x91, 0x2A, 0x2A, 0x2A, 0x91	; F3DCA1  |.*.*.***.*..***.|
	.byte	0x2A, 0x2A, 0x91, 0x2A, 0x2A, 0x2A, 0x2A, 0x2A, 0x2A, 0x2A	; F3DCB1  |**.*******|

; ==================================================================
; 0xF3DCBB-0xF3DE25 -- display-list RECORDS and the OPERAND ARRAYS they
;                    point at (363 bytes) -- converted 2026-09-02,
;                    lane promB4, notes/gen_prom_b_promB4_operand_arrays.py
; ==================================================================
;
; Right edge anchored on Paint_StepRecord_DL3, a converted display-list span header;
; and the 3-byte table start 0xF3DE23 is named by the converted records at
; 0xF3D3C3, 0xF3D3E1 and 0xF3D3FF as well as by all 24 records here.
;
; ⚠ NO call site and no 32-bit word anywhere in the four ROMs names
;   0xF3DCBB, so these 24 records are framed from the RIGHT: walking
;   15-byte op-02 records backward from 0xF3DE23 lands here after exactly
;   24 of them and no further -- the byte before is 0x2A, past the 0x24
;   opcode bound.  The run is maximal and self-terminating, every record
;   has the identical shape, and the source variables (0x2658..0x265F,
;   0x1301..0x1310) and screen positions (0x0A51/0x1159/0x1861 + 4k) are
;   three clean arithmetic runs of eight.
;   Data_F3DC21 above shrinks from 158 to 154 bytes for the same reason
;   span 1's blob did: its last 4 bytes were this first record's head.
;
Data_F3DCBB:
	dlb_string	var=UI_DrawScratch+24, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=8, y=66
Data_F3DCCA:
	dlb_string	var=UI_DrawScratch+25, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=40, y=66
Data_F3DCD9:
	dlb_string	var=UI_DrawScratch+26, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=72, y=66
Data_F3DCE8:
	dlb_string	var=UI_DrawScratch+27, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=104, y=66
Data_F3DCF7:
	dlb_string	var=UI_DrawScratch+28, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=136, y=66
Data_F3DD06:
	dlb_string	var=UI_DrawScratch+29, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=168, y=66
Data_F3DD15:
	dlb_string	var=UI_DrawScratch+30, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=200, y=66
Data_F3DD24:
	dlb_string	var=UI_DrawScratch+31, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=232, y=66
Data_F3DD33:
	dlb_string	var=DisplayListB_Stage+11, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=8, y=111
Data_F3DD42:
	dlb_string	var=DisplayListB_Stage+12, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=40, y=111
Data_F3DD51:
	dlb_string	var=DisplayListB_Stage+13, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=72, y=111
Data_F3DD60:
	dlb_string	var=DisplayListB_Stage+14, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=104, y=111
Data_F3DD6F:
	dlb_string	var=DisplayListB_Stage+15, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=136, y=111
Data_F3DD7E:
	dlb_string	var=DisplayListB_Stage+16, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=168, y=111
Data_F3DD8D:
	dlb_string	var=DisplayListB_Stage+17, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=200, y=111
Data_F3DD9C:
	dlb_string	var=DisplayListB_Stage+18, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=232, y=111
Data_F3DDAB:
	dlb_string	var=DisplayListB_Stage+19, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=8, y=156
Data_F3DDBA:
	dlb_string	var=DisplayListB_Stage+20, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=40, y=156
Data_F3DDC9:
	dlb_string	var=DisplayListB_Stage+21, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=72, y=156
Data_F3DDD8:
	dlb_string	var=DisplayListB_Stage+22, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=104, y=156
Data_F3DDE7:
	dlb_string	var=DisplayListB_Stage+23, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=136, y=156
Data_F3DDF6:
	dlb_string	var=DisplayListB_Stage+24, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=168, y=156
Data_F3DE05:
	dlb_string	var=DisplayListB_Stage+25, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=200, y=156
Data_F3DE14:
	dlb_string	var=DisplayListB_Stage+26, mask=0x60, shift=133, svc=LCDSVC_DrawText8x14, table=DLTable_F3DE23, width=1, x=232, y=156

; ------------------------------------------------------------------
; DLTable_F3DE23 -- 3 entries of 1 bytes, 0xF3DE23-0xF3DE25
; Referenced by: display-list records 0xF3D3C3, 0xF3D3E1, 0xF3D3FF, 0xF3DCBB
;   Width is the HANDLER's (0xF31B57 `sla 3,HL` => 8; 0xF31B86
;   `mul HL,6` => 6; 0xF31B21 takes it from the record's +0x0B).
;   The COUNT is the extent divided by that width, and the extent
;   is fixed by the anchors on both sides -- NOT by the record's
;   AND mask, which bounds the index only.
; ------------------------------------------------------------------
DLTable_F3DE23:
	.byte 0x20	; [0] | |
	.byte 0x2A	; [1] |*|
	.byte 0x91	; [2] |.|

; === END COVER-R1 0xF3DC21-0xF3DE26 ===

; ------------------------------------------------------------------
; 0xF3DE26-0xF3DEB1 -- 14 display-list records, 140 bytes -- interpreter A
;   entered at: 0xF3DE26
;   ends used:  0xF3DEB2
; ------------------------------------------------------------------
Paint_StepRecord_DL3:
; ; drawn (start operand) by Paint_StepRecord -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=45, y0=210, x1=75, y1=236
	dl_box_shadow2	x0=85, y0=210, x1=115, y1=236
	dl_box_shadow2	x0=125, y0=210, x1=155, y1=236
	dl_box_shadow2	x0=165, y0=210, x1=195, y1=236
	dl_box_shadow2	x0=205, y0=210, x1=235, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_hline	x0=45, y0=223, x1=75, y1=223
	dl_hline	x0=85, y0=223, x1=115, y1=223
	dl_hline	x0=125, y0=223, x1=155, y1=223
	dl_hline	x0=165, y0=223, x1=195, y1=223
	dl_hline	x0=205, y0=223, x1=235, y1=223

; ------------------------------------------------------------------
; 0xF3DEB2-0xF3E06D -- 56 display-list records, 444 bytes -- interpreter A
;   named by StepSelectAddrTable_F3D089: 0xF3DEB2, 0xF3DF6A, 0xF3E04E
; ------------------------------------------------------------------
DL_F3DEB2:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=280, y=123, text="CTL"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=280, y=43, text="MIX"
	dl_box	x0=277, y0=40, x1=307, y1=55
	dl_box	x0=275, y0=38, x1=309, y1=57
	dl_text8x16	x=312, y=42, text="\021"
	dl_text8x14	x=280, y=83, text="ERS"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x16	x=312, y=82, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3DF6A:
	dl_text8x14	x=280, y=123, text="YES"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x14	x=280, y=163, text="NO "
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=162, text="\021"
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=56, y=210, text="\215"
	dl_text8x14	x=56, y=223, text="\216"
	dl_text8x14	x=48, y=199, text="CTL"
	dl_text8x14	x=128, y=199, text="VALUE"
	dl_text8x14	x=136, y=210, text="\215"
	dl_text8x14	x=136, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_box_shadow2	x0=45, y0=210, x1=75, y1=236
	dl_hline	x0=45, y0=223, x1=75, y1=223
	dl_box_shadow2	x0=125, y0=210, x1=155, y1=236
	dl_hline	x0=125, y0=223, x1=155, y1=223
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3E04E:
	dl_text8x14	x=280, y=123, text="CTL"
	dl_text8x16	x=312, y=122, text="\021"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137

; ------------------------------------------------------------------
; 0xF3E06E-0xF3E15B -- 17 display-list records, 238 bytes -- interpreter A
;   entered at: 0xF3E06E
;   ends used:  0xF3E15C
; ------------------------------------------------------------------
; DL_MasterTrackClearAttention -- the display list at 0xF3E06E.  Its own text
;                                 records read: "MASTER TRACK CLEAR";
;                                 "ATTENTION!"; "Using MASTER TRACK CLEAR
;                                 will"; "YES"; "erase any existing
;                                 recordings"; "in the MASTER TRACK."; "Are
;                                 You Sure?".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MasterTrackClearAttention:
	dl_text16x16_packed	x=56, y=3, text="MASTER TRACK CLEAR"
	dl_text16x16	x=48, y=47, text="ATTENTION!"
	dl_text8x16	x=312, y=74, text="\021"
	dl_text8x16	x=16, y=75, text="Using MASTER TRACK CLEAR will"
	dl_text8x14	x=280, y=76, text="YES"
	dl_text8x16	x=16, y=92, text="erase any existing recordings"
	dl_text8x16	x=312, y=110, text="\021"
	dl_text8x16	x=16, y=111, text="in the MASTER TRACK."
	dl_text8x14	x=280, y=111, text="N0"
	dl_text16x16	x=24, y=135, text="Are You Sure?"
	dl_box_shadow2	x0=11, y0=37, x1=264, y1=157
	dl_box	x0=275, y0=71, x1=309, y1=90
	dl_box	x0=277, y0=73, x1=307, y1=88
	dl_box	x0=275, y0=106, x1=309, y1=125
	dl_box	x0=277, y0=108, x1=307, y1=123
	dl_hline	x0=46, y0=63, x1=206, y1=63
	dl_hline	x0=46, y0=64, x1=206, y1=64

; ------------------------------------------------------------------
; 0xF3E15C-0xF3E362 -- 64 display-list records, 519 bytes -- interpreter A
;   named by StepSelectAddrTable_F3D089: 0xF3E15C, 0xF3E228, 0xF3E2EB
; ------------------------------------------------------------------
DL_F3E15C:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=64, y=199, text="TIME SIG."
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=96, y=210, text="\215"
	dl_text8x14	x=96, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=85, y0=210, x1=115, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_hline	x0=85, y0=223, x1=115, y1=223
	dl_text8x14	x=280, y=123, text="ERS"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x16	x=312, y=122, text="\021"
	dl_text8x14	x=272, y=147, text="TRACK"
	dl_text8x14	x=280, y=163, text="CLR"
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=122, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3E228:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=64, y=199, text="TIME SIG."
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=96, y=210, text="\215"
	dl_text8x14	x=96, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=85, y0=210, x1=115, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_hline	x0=85, y0=223, x1=115, y1=223
	dl_text8x14	x=280, y=123, text="YES"
	dl_box	x0=277, y0=120, x1=307, y1=135
	dl_box	x0=275, y0=118, x1=309, y1=137
	dl_text8x16	x=312, y=122, text="\021"
	dl_text8x14	x=280, y=163, text="NO "
	dl_box	x0=277, y0=160, x1=307, y1=175
	dl_box	x0=275, y0=158, x1=309, y1=177
	dl_text8x16	x=312, y=162, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195
DL_F3E2EB:
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x14	x=16, y=210, text="\215"
	dl_text8x14	x=16, y=223, text="\216"
	dl_text8x14	x=256, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_box_shadow2	x0=5, y0=210, x1=35, y1=236
	dl_box_shadow2	x0=245, y0=210, x1=275, y1=236
	dl_box_shadow2	x0=285, y0=210, x1=315, y1=236
	dl_hline	x0=5, y0=223, x1=35, y1=223
	dl_text8x14	x=280, y=83, text="ERS"
	dl_box	x0=277, y0=80, x1=307, y1=95
	dl_box	x0=275, y0=78, x1=309, y1=97
	dl_text8x16	x=312, y=82, text="\021"
	dl_box_shadow2	x0=5, y0=175, x1=250, y1=195

; ------------------------------------------------------------------
; 0xF3E363-0xF3F3FF -- 4253 bytes of pad, value 0x0E (verified, not sampled)
;   Directly follows the display list that ends here (StepSelectAddrTable_F3D089
;   entries [23] and [61], both conditions' pair-4 end).  A naive length-byte
;   walk starting from that list's own start self-frames INTO this run as ~300
;   fake 14-byte records -- see the header of
;   notes/gen_prom_b_stepselect_module.py.  0xF3F400 onward is a different,
;   unidentified format and stays `.incbin`.
; ------------------------------------------------------------------
	.fill 4253, 1, 0x0E
