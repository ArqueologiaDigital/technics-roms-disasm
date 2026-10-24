

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


; ------------------------------------------------------------------
; 0xF394E3-0xF39550 -- 11 display-list records, 110 bytes -- interpreter A
; Formerly Data_F394E3 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F394E3:
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00DF
	.short 0x0068
	.short 0x0133
	.short 0x0077
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
	.short 0x00E3
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0046
	.short 0x002B
	.short 0x0055
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00E5
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x006C
	.short 0x003A
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000F
	.short 0x006E
	.short 0x0038
	.short 0x007D

; ------------------------------------------------------------------
; 0xF39551-0xF39558 -- 1 display-list records, 8 bytes -- interpreter A
;   entered at: 0xF39551
;   ends used:  0xF39559
; ------------------------------------------------------------------
DL_F39551:
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x0000
	.short 0x0028
	.short 0x00F0

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
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F396ED	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0038
	.short 0x003E
	.short 0x0117
	.short 0x00B5


; ------------------------------------------------------------------
; 0xF39737-0xF39853 -- 19 display-list records, 285 bytes -- interpreter A
; Formerly Data_F39737 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
TrackAssign_DrawSelectedPart_DL:
; drawn (start operand) by TrackAssign_DrawSelectedPart -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x0C, 0x0A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x64, 0x0C	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0xBC, 0x0E	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x14, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x6C, 0x13	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0xC4, 0x15	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x1C, 0x18	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x74, 0x1A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x0C, 0x0A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x64, 0x0C	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0xBC, 0x0E	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x14, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x6C, 0x13	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0xC4, 0x15	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x1C, 0x18	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12FB
	.short 0x00FF
	.short 0x0206
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x74, 0x1A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x6207
	.short 0xF395
	.byte 0x00, 0x02, 0x00, 0x36, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x0207
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x3E, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x0207
	.short 0xF396
	.byte 0x00, 0x07, 0x00, 0x48, 0x11	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF39854-0xF39879 -- 4 display-list records, 38 bytes -- interpreter A
;   entered at: 0xF39854, 0xF39870
;   ends used:  0xF39870, 0xF3987A
; ------------------------------------------------------------------
DL_F39854:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x11CC
	.ascii "OK "
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x006C
	.short 0x0134
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011F
	.short 0x006E
	.short 0x0132
	.short 0x007D
DL_F39870:
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x006C
	.short 0x0140
	.short 0x007F


; ------------------------------------------------------------------
; 0xF3987A-0xF3998D -- 31 display-list records, 276 bytes -- interpreter A
; Formerly Data_F3987A -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F3987A:
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0030
	.short 0x0008
	.ascii "TRACK"
	.byte 0x1C, 0x0C	; op 1C, 12 bytes -> handler 0xF31A52
	.short 0x0072
	.short 0x0008
	.ascii "ASSIGN"
	.byte 0x1C, 0x0C	; op 1C, 12 bytes -> handler 0xF31A52
	.short 0x00BF
	.short 0x0008
	.ascii "CHANGE"
	.byte 0x08, 0x0E	; op 08, 14 bytes -> handler 0xF31A3A
	.short 0x07FE
	.ascii "ATTENTI0N!"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0C03
	.ascii "YES"
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x0D21
	.ascii "Changing"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x0D2A
	.ascii "the"
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0D2E
	.ascii "assignment"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0D39
	.ascii "of"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x1131
	.ascii "Track"
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x1139
	.ascii "from"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1146
	.ascii "~"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1157
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x117B
	.ascii "N0"
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x1591
	.ascii "will"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x1596
	.ascii "erase"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x159C
	.ascii "all"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x15A0
	.ascii "the"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x15A4
	.ascii "current"
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x15AC
	.ascii "data"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x1BD3
	.ascii "Are"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x1BDB
	.ascii "You"
	.byte 0x08, 0x09	; op 08, 9 bytes -> handler 0xF31A3A
	.short 0x1BE3
	.ascii "Sure?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x0025
	.short 0x010A
	.short 0x00D2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0047
	.short 0x0135
	.short 0x005A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0049
	.short 0x0133
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x006A
	.short 0x0135
	.short 0x007D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x006C
	.short 0x0133
	.short 0x007B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0043
	.short 0x00D0
	.short 0x0043
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0044
	.short 0x00D0
	.short 0x0044

; ------------------------------------------------------------------
; 0xF3998E-0xF399C0 -- 4 display-list records, 51 bytes -- interpreter B
;   entered at: 0xF3998E
;   ends used:  0xF399C1
; ------------------------------------------------------------------
Paint_SongClear_DL3:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x08	; +0x06 swi 7 function
	.long 0x000012F7	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0D80	; +0x0D -> IX
	.byte 0x0A, 0x0C	; B op 0A, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00F8	; +0x07 -> (0x2530)
	.short 0x0049	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x005D	; +0x07 -> (0x2530)
	.short 0x0056	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x00EE	; +0x07 -> (0x2530)
	.short 0x0056	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count

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
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x0079
	.short 0x0006
	.ascii "SONG"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x00B0
	.short 0x0006
	.ascii "CLEAR"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x0110
	.short 0x0049
	.ascii "KB"
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x0030
	.short 0x0056
	.ascii "SONG"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x00E3
	.short 0x0056
	.ascii ":"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x010F
	.short 0x0056
	.ascii "%"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0073
	.short 0x0057
	.ascii ";"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1797
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x17BC
	.ascii "0K"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1ED1
	.ascii "S0NG"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1ED6
	.ascii "N0"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1ED9
	.ascii "/ALL"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x226C
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2271
	.ascii ">"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3D
	.short 0x0033
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0026
	.short 0x0043
	.short 0x0122
	.short 0x006D
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00D4
	.short 0x0072
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D4
	.short 0x009A
	.short 0x00EC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0092
	.short 0x0135
	.short 0x00A5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0094
	.short 0x0133
	.short 0x00A3
Paint_SongClear_DL1:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0027
	.short 0x0044
	.short 0x0122
	.short 0x006D
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
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x0079
	.short 0x0006
	.ascii "SONG"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x00B0
	.short 0x0006
	.ascii "CLEAR"
	.byte 0x17, 0x08	; op 17, 8 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x002D
	.ascii "KB"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0060
	.short 0x0032
	.ascii "."
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x001A
	.short 0x003A
	.ascii "SONG"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x00CF
	.short 0x003B
	.ascii ":"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x00FB
	.short 0x003B
	.ascii "%"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0060
	.short 0x0042
	.ascii "'"
	.byte 0x08, 0x0E	; op 08, 14 bytes -> handler 0xF31A3A
	.short 0x1097
	.ascii "ATTENTI0N!"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x14F4
	.ascii "Using"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x14FA
	.ascii "S0NG"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x14FF
	.ascii "CLEAR"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1505
	.ascii "will"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x150A
	.ascii "erase"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1793
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1797
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x183C
	.ascii "any"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x1840
	.ascii "existing"
	.byte 0x06, 0x0D	; op 06, 13 bytes -> handler 0xF31A3A
	.short 0x1849
	.ascii "recording"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1853
	.ascii "in"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1856
	.ascii "the"
	.byte 0x06, 0x0E	; op 06, 14 bytes -> handler 0xF31A3A
	.short 0x1B84
	.ascii "Sequencer."
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1D87
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1DAB
	.ascii "N0"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x1EF4
	.ascii "Are"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x1EFC
	.ascii "You"
	.byte 0x08, 0x09	; op 08, 9 bytes -> handler 0xF31A3A
	.short 0x1F04
	.ascii "Sure?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0010
	.short 0x0027
	.short 0x010C
	.short 0x0051
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0091
	.short 0x0134
	.short 0x00A4
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0093
	.short 0x0132
	.short 0x00A2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x00B8
	.short 0x0134
	.short 0x00CB
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x00BA
	.short 0x0132
	.short 0x00C9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000F
	.short 0x0060
	.short 0x010E
	.short 0x0060
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x007A
	.short 0x00D7
	.short 0x007A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x007B
	.short 0x00D7
	.short 0x007B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000F
	.short 0x00DA
	.short 0x0110
	.short 0x00DA
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0011
	.short 0x00DB
	.short 0x0110
	.short 0x00DB
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0011
	.short 0x00DC
	.short 0x0110
	.short 0x00DC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000F
	.short 0x0060
	.short 0x000F
	.short 0x00DC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010E
	.short 0x0060
	.short 0x010E
	.short 0x00DC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010F
	.short 0x0061
	.short 0x010F
	.short 0x00DC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0110
	.short 0x0061
	.short 0x0110
	.short 0x00DC
Paint_SongClear_DL4:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0011
	.short 0x0028
	.short 0x010C
	.short 0x0051
Paint_SongClear_DL6:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x08	; +0x06 swi 7 function
	.long 0x000012F7	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x091D	; +0x0D -> IX
	.byte 0x0A, 0x0C	; B op 0A, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00E2	; +0x07 -> (0x2530)
	.short 0x002C	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x0048	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x00D8	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
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
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0079
	.short 0x0006
	.ascii "TRACK"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x00BB
	.short 0x0006
	.ascii "CLEAR"
	.byte 0x08, 0x0E	; op 08, 14 bytes -> handler 0xF31A3A
	.short 0x061E
	.ascii "ATTENTI0N!"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x09DA
	.ascii "Using"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x09E0
	.ascii "TRACK"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x09E6
	.ascii "CLEAR"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x09EC
	.ascii "will"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x09F1
	.ascii "erase"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0B8B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D22
	.ascii "any"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x0D26
	.ascii "existing"
	.byte 0x06, 0x0E	; op 06, 14 bytes -> handler 0xF31A3A
	.short 0x0D2F
	.ascii "recordings"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0D3A
	.ascii "in"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D3D
	.ascii "the"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x106A
	.ascii "selected"
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x1073
	.ascii "Tracks."
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x117F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x11A3
	.ascii "N0"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x13DB
	.ascii "Are"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x13E3
	.ascii "You"
	.byte 0x08, 0x09	; op 08, 9 bytes -> handler 0xF31A3A
	.short 0x13EB
	.ascii "Sure?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001D
	.short 0x0108
	.short 0x0095
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0044
	.short 0x0134
	.short 0x0057
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0046
	.short 0x0132
	.short 0x0055
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x006B
	.short 0x0134
	.short 0x007E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x006D
	.short 0x0132
	.short 0x007C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0037
	.short 0x00CE
	.short 0x0037
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0038
	.short 0x00CE
	.short 0x0038
; DL_EditSeqN0teEditS0ngClear -- the display list at 0xF39D3E.  Its own text
;                                records read: "EDIT"; "SEQ."; "N0TE"; "EDIT";
;                                "S0NG"; "CLEAR"; "DRUM"; "EDIT" +10 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EditSeqN0teEditS0ngClear:
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x0097
	.short 0x0005
	.ascii "EDIT"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x0008
	.ascii "SEQ."
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05A5
	.ascii "N0TE"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05AA
	.ascii "EDIT"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05B6
	.ascii "S0NG"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x05BB
	.ascii "CLEAR"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0026
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0026
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0BBD
	.ascii "DRUM"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0BC2
	.ascii "EDIT"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x0BCE
	.ascii "TRACK"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x0BD4
	.ascii "CLEAR"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x004D
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x004D
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x11BE
	.ascii "N0TE"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x11C3
	.ascii "CHANGE"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x11D5
	.ascii "QUANTIZE"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0074
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0074
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x0D	; op 06, 13 bytes -> handler 0xF31A3A
	.short 0x17ED
	.ascii "TRANSP0SE"
	.byte 0x06, 0x11	; op 06, 17 bytes -> handler 0xF31A3A
	.short 0x17FE
	.ascii "ADVANCE/DELAY"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x009B
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x009B
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x1E05
	.ascii "VEL0CITY"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1E0E
	.ascii "CHANGE"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x00C2
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x00C2
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x0F	; op 06, 15 bytes -> handler 0xF31A3A
	.short 0x1E16
	.ascii "PANEL WRITE"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x0008
	.ascii "P1/2"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0004
	.short 0x0024
	.short 0x0012
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x10
	.short 0x0060
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x02
	.short 0x0411
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x0F
	.short 0x0A51
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3B
	.short 0x1091
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3C
	.short 0x16D1
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x08
	.short 0x1D11
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3D
	.short 0x0434
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3E
	.short 0x0A74
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3F
	.short 0x10B4
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x40
	.short 0x16F4
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x44
	.short 0x1D34
; DL_EditSeqSongCopyCopyErase -- the display list at 0xF39E87.  Its own text
;                                records read: "EDIT"; "SEQ."; "SONG"; "COPY";
;                                "COPY"; "ERASE"; "MEASURE"; "DELETE" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EditSeqSongCopyCopyErase:
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x0097
	.short 0x0005
	.ascii "EDIT"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x0008
	.ascii "SEQ."
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05A5
	.ascii "SONG"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05AA
	.ascii "COPY"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x05BD
	.ascii "COPY"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0026
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0026
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x0BD5
	.ascii "ERASE"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x004D
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x0EED
	.ascii "MEASURE"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x11ED
	.ascii "DELETE"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0074
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x11D5
	.ascii "TRACK"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x11DB
	.ascii "MERGE"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1805
	.ascii "INSERT"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0074
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x009B
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x0008
	.ascii "P2/2"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0004
	.short 0x0024
	.short 0x0012
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x0028
	.short 0x00E7
	.short 0x0028
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x004F
	.short 0x00E7
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E1
	.short 0x0063
	.short 0x00E4
	.short 0x0063
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x0077
	.short 0x00E7
	.short 0x0077
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x009E
	.short 0x00E7
	.short 0x009E
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x0028
	.short 0x00E4
	.short 0x009E
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x10
	.short 0x0060
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x41
	.short 0x0411
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x43
	.short 0x10E1
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x45
	.short 0x054C
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x46
	.short 0x0AEC
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x47
	.short 0x1104
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x48
	.short 0x176C
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
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0079
	.short 0x0006
	.ascii "TRACK"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x00BB
	.short 0x0006
	.ascii "CLEAR"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x0731
	.ascii "Press"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x0737
	.ascii "the"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x073B
	.ascii "up/down"
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x0743
	.ascii "buttons"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x074B
	.ascii "under"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x0A29
	.ascii "the"
	.byte 0x07, 0x0A	; op 07, 10 bytes -> handler 0xF31A3A
	.short 0x0A2D
	.ascii "screen"
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x0A34
	.ascii "corresponding"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0A42
	.ascii "to"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x0A45
	.ascii "the"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BDC
	.ascii "0K"
	.byte 0x07, 0x0A	; op 07, 10 bytes -> handler 0xF31A3A
	.short 0x0D21
	.ascii "tracks"
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x0D28
	.ascii "that"
	.byte 0x07, 0x07	; op 07, 7 bytes -> handler 0xF31A3A
	.short 0x0D2D
	.ascii "you"
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x0D31
	.ascii "want"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0D36
	.ascii "to"
	.byte 0x07, 0x0A	; op 07, 10 bytes -> handler 0xF31A3A
	.short 0x0D39
	.ascii "clear."
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1069
	.ascii "Press"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x106F
	.ascii "0K"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1072
	.ascii "to"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x1075
	.ascii "Complete"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x107E
	.ascii "TRACK"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1084
	.ascii "CLEAR."
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x0022
	.short 0x0116
	.short 0x0084
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x0046
	.short 0x0134
	.short 0x0059
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x0048
	.short 0x0132
	.short 0x0057
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0033
	.short 0x0064
	.short 0x004C
	.short 0x0077
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0035
	.short 0x0066
	.short 0x004A
	.short 0x0075
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3E
	.short 0x005C

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
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x1720
	.short 0x0028
	.short 0x004B

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
	.byte 0x04, 0x0B	; B op 04, 11 bytes -> handler 0xF31B86 -- entry[value] -> IY, BC, HL
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x0E	; +0x06 swi 7 function
	.long DLTable_F3A0EF	; +0x07 -> XIX: array of 6-byte entries, indexed by the value

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
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B59	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B5E	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B63	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B68	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B6D	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B72	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B77	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1B7C	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22B1	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22B6	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22BB	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+11	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22C0	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+12	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22C5	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+13	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22CA	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+14	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22CF	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+15	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long Data_F39559 + 0x49	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x22D4	; +0x0D -> IX
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
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0030
	.short 0x0007
	.ascii "TRACK"
	.byte 0x1C, 0x0C	; op 1C, 12 bytes -> handler 0xF31A52
	.short 0x0072
	.short 0x0007
	.ascii "ASSIGN"
	.byte 0x1C, 0x0D	; op 1C, 13 bytes -> handler 0xF31A52
	.short 0x00C0
	.short 0x0007
	.ascii "PRESETS"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05C8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x1C	; op 07, 28 bytes -> handler 0xF31A3A
	.short 0x0644
	.ascii "TECHNICS SET-UP1 ( 1-16)"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B68
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x1C	; op 07, 28 bytes -> handler 0xF31A3A
	.short 0x0BBC
	.ascii "TECHNICS SET-UP2 (17-32)"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x10E0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0D	; op 07, 13 bytes -> handler 0xF31A3A
	.short 0x110C
	.ascii "GM SET-UP"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x18DA
	.ascii "Any"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x18DE
	.ascii "existing"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x18E7
	.ascii "song"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x18EC
	.ascii "will"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x18F1
	.ascii "be"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x18F4
	.ascii "cleared."
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1C22
	.ascii "Press"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1C29
	.ascii "0K"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1C2D
	.ascii "to"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x1C30
	.ascii "proceed."
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1ECC
	.ascii "S0NG"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1ED1
	.ascii "N0"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1ED4
	.ascii "/ALL"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x223F
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2244
	.ascii ">"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x22A2
	.ascii "0K"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0012
	.short 0x0020
	.short 0x00F1
	.short 0x0039
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0012
	.short 0x0043
	.short 0x00F1
	.short 0x005D
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0012
	.short 0x0066
	.short 0x00F1
	.short 0x007F
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00D3
	.short 0x004A
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00D3
	.short 0x0072
	.short 0x00EB
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0044
	.short 0x00AF
	.short 0x005D
	.short 0x00C2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0046
	.short 0x00B1
	.short 0x005B
	.short 0x00C0
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00CB
	.short 0x00D8
	.short 0x00E5
	.short 0x00EB
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00DA
	.short 0x00E3
	.short 0x00E9
Paint_TrackAssignPresets_DL2:
; ; drawn (start operand) by Paint_TrackAssignPresets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x001E
	.short 0x0087
	.short 0x0055
	.short 0x0098
; DL_S0ng -- the display list at 0xF3A417.  Its own text records read: "S0NG".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_S0ng:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x15BC
	.ascii "S0NG"
; DL_All -- the display list at 0xF3A41F.  Its own text records read: "ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_All:
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x15BC
	.ascii "  ALL "
Paint_TrackAssignPresets_DL1:
; ; drawn (start operand) by Paint_TrackAssignPresets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.short 0x15C0	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663

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
	.byte 0x08, 0x0B	; B op 08, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F3A449	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x1C, 0x14	; op 1C, 20 bytes -> handler 0xF31A52
	.short 0x0051
	.short 0x00CA
	.ascii "Are You Sure ?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0049
	.short 0x00BD
	.short 0x00F3
	.short 0x00E4
; DL_TrackMergeOkTrackTrackTrack -- the display list at 0xF3A47F.  Its own
;                                   text records read: "TRACK MERGE"; "OK";
;                                   "TRACK  :"; "TRACK  :"; "TRACK  :".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackMergeOkTrackTrackTrack:
	.byte 0x1C, 0x11	; op 1C, 17 bytes -> handler 0xF31A52
	.short 0x0071
	.short 0x0006
	.ascii "TRACK MERGE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BDC
	.ascii "OK"
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0C0C
	.ascii "TRACK  :  "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C30
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x11BF
	.ascii "TRACK  :  "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11CF
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1720
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x1724
	.ascii "TRACK  :  "
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00AC
	.short 0x0073
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0016
	.short 0x0040
	.short 0x008A
	.short 0x0064
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00B1
	.short 0x0064
	.short 0x0126
	.short 0x0088
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0016
	.short 0x0087
	.short 0x008A
	.short 0x00AB
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x0054
	.short 0x009B
	.short 0x0054
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x009B
	.short 0x0076
	.short 0x00B1
	.short 0x0076
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x008A
	.short 0x009A
	.short 0x009B
	.short 0x009A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009B
	.short 0x0054
	.short 0x009B
	.short 0x009A
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x43
	.short 0x005A
; DL_Track -- the display list at 0xF3A526.  Its own text records read:
;             "TRACK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Track:
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F04
	.ascii "TRACK"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0046
	.short 0x0135
	.short 0x0059
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0048
	.short 0x0133
	.short 0x0057
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3A561:
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0C16	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x172E	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11C9	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F3A58A	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0BB3
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x180B
	.ascii "NO"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0045
	.short 0x0134
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0047
	.short 0x0132
	.short 0x0056
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0094
	.short 0x0134
	.short 0x00A7
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0096
	.short 0x0132
	.short 0x00A5
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
	.byte 0x1C, 0x14	; op 1C, 20 bytes -> handler 0xF31A52
	.short 0x0061
	.short 0x0006
	.ascii "MEASURE DELETE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C08
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0C0B
	.ascii "TRACK           :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x11AB
	.ascii "FIRST MEASURE   :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1748
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x174B
	.ascii "LAST MEASURE    :"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0043
	.short 0x00DF
	.short 0x0062
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0067
	.short 0x00DF
	.short 0x0086
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008B
	.short 0x00DF
	.short 0x00AA
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x47
	.short 0x0030
Paint_MeasureDelete_DL:
; ; drawn (start operand) by Paint_MeasureDelete -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11CF
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x11F4
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x006D
	.short 0x0134
	.short 0x0080
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x006F
	.short 0x0132
	.short 0x007E
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
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
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16MasterAll	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0C1C	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11BC	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x175C	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3A6D9	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x11A3
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1797
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x17BB
	.ascii "NO"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x006B
	.short 0x0134
	.short 0x007E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x006D
	.short 0x0132
	.short 0x007C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0092
	.short 0x0134
	.short 0x00A5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0094
	.short 0x0132
	.short 0x00A3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0073
	.short 0x013C
	.short 0x0073
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0074
	.short 0x013D
	.short 0x0074
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0075
	.short 0x013E
	.short 0x0075
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0076
	.short 0x013E
	.short 0x0076
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0077
	.short 0x013D
	.short 0x0077
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0078
	.short 0x013C
	.short 0x0078
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0099
	.short 0x013C
	.short 0x0099
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x009A
	.short 0x013D
	.short 0x009A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x009B
	.short 0x013E
	.short 0x009B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x009C
	.short 0x013E
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x009D
	.short 0x013D
	.short 0x009D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x009E
	.short 0x013C
	.short 0x009E
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0070
	.short 0x0139
	.short 0x007B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0139
	.short 0x0096
	.short 0x0139
	.short 0x00A1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013A
	.short 0x0071
	.short 0x013A
	.short 0x007A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013A
	.short 0x0097
	.short 0x013A
	.short 0x00A0
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013B
	.short 0x0072
	.short 0x013B
	.short 0x0079
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013B
	.short 0x0098
	.short 0x013B
	.short 0x009F
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013C
	.short 0x0073
	.short 0x013C
	.short 0x0078
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013C
	.short 0x0099
	.short 0x013C
	.short 0x009E
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013D
	.short 0x0074
	.short 0x013D
	.short 0x0077
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013D
	.short 0x009A
	.short 0x013D
	.short 0x009D
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
	.byte 0x1C, 0x13	; op 1C, 19 bytes -> handler 0xF31A52
	.short 0x005F
	.short 0x0006
	.ascii "MEASURE ERASE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0668
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x066B
	.ascii "TRACK           :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C08
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0C0B
	.ascii "FIRST MEASURE   :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x11AB
	.ascii "LAST MEASURE    :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1770
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x179B
	.ascii "ERASE DATA      :"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001F
	.short 0x00DF
	.short 0x003E
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0043
	.short 0x00DF
	.short 0x0062
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0067
	.short 0x00DF
	.short 0x0086
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008C
	.short 0x00DF
	.short 0x00AB
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x46
	.short 0x0030
Paint_MeasureErase_DL:
; ; drawn (start operand) by Paint_MeasureErase -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BDC
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x0046
	.short 0x0134
	.short 0x0059
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x0048
	.short 0x0132
	.short 0x0057
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3A9DA:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16MasterAll	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x067C	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0x03	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_AllNoteControl	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x17AC	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0C1C	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11BC	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3AA17	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x1C, 0x15	; op 1C, 21 bytes -> handler 0xF31A52
	.short 0x005E
	.short 0x0007
	.ascii "VEL0CITY CHANGE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0690
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0693
	.ascii "TRACK           :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C30
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0C33
	.ascii "FIRST MEASURE   :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x11D3
	.ascii "LAST MEASURE    :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1770
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x179B
	.ascii "VELOCITY        :"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0020
	.short 0x00DF
	.short 0x003F
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0044
	.short 0x00DF
	.short 0x0063
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0068
	.short 0x00DF
	.short 0x0087
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008C
	.short 0x00DF
	.short 0x00AB
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x08
	.short 0x0030
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BB4
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3AB3B:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x06A4	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0C44	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11E4	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x17AC	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3AB74	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0B8B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x117F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x11A3
	.ascii "NO"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0044
	.short 0x0134
	.short 0x0057
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0046
	.short 0x0132
	.short 0x0055
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x006B
	.short 0x0134
	.short 0x007E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x006D
	.short 0x0132
	.short 0x007C
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
	.byte 0x1C, 0x0E	; op 1C, 14 bytes -> handler 0xF31A52
	.short 0x0077
	.short 0x0005
	.ascii "QUANTIZE"
	.byte 0x07, 0x13	; op 07, 19 bytes -> handler 0xF31A3A
	.short 0x0642
	.ascii "TRACK         :"
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0656
	.ascii "STRENGTH :"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0663
	.ascii " %"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0668
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x06B7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x13	; op 07, 19 bytes -> handler 0xF31A3A
	.short 0x0BE2
	.ascii "FIRST MEASURE :"
	.byte 0x07, 0x0D	; op 07, 13 bytes -> handler 0xF31A3A
	.short 0x0BF6
	.ascii "WINDOW  :"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0C03
	.ascii " %"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C08
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C57
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x13	; op 07, 19 bytes -> handler 0xF31A3A
	.short 0x1182
	.ascii "LAST MEASURE  :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1748
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0B	; op 07, 11 bytes -> handler 0xF31A3A
	.short 0x174A
	.ascii "VALUE: "
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001D
	.short 0x00A2
	.short 0x003C
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00AA
	.short 0x001D
	.short 0x0133
	.short 0x003C
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0041
	.short 0x00A2
	.short 0x0060
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00AA
	.short 0x0041
	.short 0x0133
	.short 0x0060
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0065
	.short 0x00A2
	.short 0x0084
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008A
	.short 0x00A2
	.short 0x00A9
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3B
	.short 0x005C
Paint_Quantize_DL:
; ; drawn (start operand) by Paint_Quantize -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11CF
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x11F4
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x006D
	.short 0x0135
	.short 0x0080
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x006F
	.short 0x0133
	.short 0x007E
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
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
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0651	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_GlyphPairs_F3AD7A	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x1751	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0BF1	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1191	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0660	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short DisplayListB_Stage+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0BFF	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3AD42	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x1C, 0x11	; op 1C, 17 bytes -> handler 0xF31A52
	.short 0x0078
	.short 0x0006
	.ascii "PANEL WRITE"
	.byte 0x07, 0x27	; op 07, 39 bytes -> handler 0xF31A3A
	.short 0x06E2
	.ascii "PANEL WRITE replaces the sounds and"
	.byte 0x07, 0x25	; op 07, 37 bytes -> handler 0xF31A3A
	.short 0x0A2A
	.ascii "settings at the beginning of your"
	.byte 0x07, 0x20	; op 07, 32 bytes -> handler 0xF31A3A
	.short 0x0D72
	.ascii "song,which are selected when"
	.byte 0x07, 0x1D	; op 07, 29 bytes -> handler 0xF31A3A
	.short 0x1092
	.ascii "you press SEQUENCER RESET"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x10D3
	.ascii "."
	.byte 0x07, 0x26	; op 07, 38 bytes -> handler 0xF31A3A
	.short 0x16FA
	.ascii "Make the desired changes and press"
	.byte 0x07, 0x1F	; op 07, 31 bytes -> handler 0xF31A3A
	.short 0x1A1F
	.ascii "to store your new settings."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1A6B
	.ascii "OK"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x22D0
	.ascii "OK"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0022
	.short 0x0131
	.short 0x00C9
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0014
	.short 0x00A4
	.short 0x002D
	.short 0x00B7
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0016
	.short 0x00A6
	.short 0x002B
	.short 0x00B5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00FB
	.short 0x00D9
	.short 0x0114
	.short 0x00EC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x00DB
	.short 0x0112
	.short 0x00EA
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x44
	.short 0x0033
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
	.byte 0x1C, 0x11	; op 1C, 17 bytes -> handler 0xF31A52
	.short 0x0071
	.short 0x0006
	.ascii "N0TE CHANGE"
	.byte 0x07, 0x0F	; op 07, 15 bytes -> handler 0xF31A3A
	.short 0x0A90
	.ascii "TARGET NOTE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B68
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x13	; op 07, 19 bytes -> handler 0xF31A3A
	.short 0x0B6A
	.ascii "TRACK         :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BDF
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CC2
	.ascii ":"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x0CC7
	.ascii " ("
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CCC
	.ascii ")"
	.byte 0x07, 0x0D	; op 07, 13 bytes -> handler 0xF31A3A
	.short 0x10A8
	.ascii "CHANGE TO"
	.byte 0x07, 0x13	; op 07, 19 bytes -> handler 0xF31A3A
	.short 0x11AA
	.ascii "FIRST MEASURE :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11F7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1302
	.ascii ":"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x1307
	.ascii " ("
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x130C
	.ascii ")"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x13	; op 07, 19 bytes -> handler 0xF31A3A
	.short 0x17EA
	.ascii "LAST MEASURE  :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1810
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00B6
	.short 0x0075
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x003E
	.short 0x00A6
	.short 0x005D
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00BB
	.short 0x003E
	.short 0x0131
	.short 0x0060
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0067
	.short 0x00A6
	.short 0x0085
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00BB
	.short 0x0066
	.short 0x0131
	.short 0x0088
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x008F
	.short 0x00A6
	.short 0x00AE
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3F
	.short 0x0033
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x004F
	.short 0x00BB
	.short 0x004F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x0078
	.short 0x00BB
	.short 0x0078
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x004F
	.short 0x00B3
	.short 0x0078
Paint_N0teChange_DL1:
; ; drawn (start operand) by Paint_N0teChange -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x180C
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x0094
	.short 0x0134
	.short 0x00A7
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x0096
	.short 0x0132
	.short 0x00A5
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3AFE7:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0B79	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_NoteNamesInOctave	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x0C9B	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_OctavesMinus2To8	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x0C9D	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_NoteNamesInOctave	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x12DB	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+4	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_OctavesMinus2To8	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x12DD	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0CA1	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11B9	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x12E1	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+9	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x17F9	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+11	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3B065	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x17BB
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17BF
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1DAF
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1DD3
	.ascii "NO"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x0092
	.short 0x0134
	.short 0x00A5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0094
	.short 0x0132
	.short 0x00A3
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x00B9
	.short 0x0134
	.short 0x00CC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x00BB
	.short 0x0132
	.short 0x00CA
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
	.byte 0x1C, 0x0F	; op 1C, 15 bytes -> handler 0xF31A52
	.short 0x0070
	.short 0x0006
	.ascii "TRANSP0SE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0690
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0693
	.ascii "TRACK           :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C30
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0C33
	.ascii "FIRST MEASURE   :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x11D3
	.ascii "LAST MEASURE    :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1770
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x1773
	.ascii "TRANSPOSE       :"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0020
	.short 0x00DF
	.short 0x003F
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0044
	.short 0x00DF
	.short 0x0063
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0068
	.short 0x00DF
	.short 0x0087
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008C
	.short 0x00DF
	.short 0x00AB
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3C
	.short 0x0033
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BB4
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3B1E3:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x06A4	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0C44	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11E4	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1784	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3B21C	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x00E8
	.short 0x0057
	.ascii ":"
	.byte 0x1C, 0x17	; op 1C, 23 bytes -> handler 0xF31A52
	.short 0x002A
	.short 0x0056
	.ascii "   ALL S0NGS     "
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x00F0
	.short 0x0056
	.ascii "100%"
Paint_SongClear_DL5:
; ; drawn (start operand) by Paint_SongClear -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x00D2
	.short 0x0039
	.ascii ":"
	.byte 0x1C, 0x17	; op 1C, 23 bytes -> handler 0xF31A52
	.short 0x0014
	.short 0x003B
	.ascii "   ALL S0NGS     "
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x00DA
	.short 0x003B
	.ascii "100%"
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
	.byte 0x1C, 0x13	; op 1C, 19 bytes -> handler 0xF31A52
	.short 0x0067
	.short 0x0006
	.ascii "ADVANCE/DELAY"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0690
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0693
	.ascii "TRACK           :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C30
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x0C33
	.ascii "FIRST MEASURE   :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11D0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x11D3
	.ascii "LAST MEASURE    :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1770
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x1773
	.ascii "ADVANCE/DELAY   :"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0020
	.short 0x00DF
	.short 0x003F
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0044
	.short 0x00DF
	.short 0x0063
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0068
	.short 0x00DF
	.short 0x0087
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008C
	.short 0x00DF
	.short 0x00AB
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x40
	.short 0x0032
Paint_AdvanceDelay_DL:
; ; drawn (start operand) by Paint_AdvanceDelay -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11CF
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x11F4
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x006F
	.short 0x0132
	.short 0x007E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x006D
	.short 0x0134
	.short 0x0080
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3B379:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x06A4	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0C44	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x11E4	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x05, 0x0B	; B op 05, 11 bytes -> handler 0xF31BD7 -- decimal readout, signed (0xF8BCC9 via T_Value_ToSignedAsciiDigits3_RightJustified), buffer 0x2660
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1784	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count
	.byte 0x00	; +0x0A bit 7 set = unsigned, clear = signed
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3B3B2	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x00C0
	.ascii "SONG"
	.byte 0x1C, 0x12	; op 1C, 18 bytes -> handler 0xF31A52
	.short 0x0060
	.short 0x0005
	.ascii "TRACK ASSIGN"
	.byte 0x20, 0x18	; op 20, 24 bytes -> handler 0xF31A3A
	.short 0x050C
	.ascii "TRACK   L0CAL   MIDI"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0643
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0640
	.byte 0xA8	; character codes below 0x20
	.byte 0x06, 0x1A	; op 06, 26 bytes -> handler 0xF31A3A
	.short 0x0714
	.ascii "ASSIGN  CONTROL OUT CH"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x0961
	.ascii "TRACK"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BE0
	.byte 0xA8	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C0B
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x10E3
	.ascii "_"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1180
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x11D2
	.ascii "1"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x11D4
	.ascii "8"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x16FB
	.ascii "_"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1798
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x17EA
	.ascii "9"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x17EC
	.ascii "16"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1E78
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x1EA2
	.ascii "PRESETS"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1EDC
	.ascii "LO"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1EDE
	.ascii "C"
	.byte 0x06, 0x0D	; op 06, 13 bytes -> handler 0xF31A3A
	.short 0x1EDF
	.ascii "AL    CHA"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1EE8
	.ascii "N"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1EE9
	.ascii "NEL"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x20E6
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x20F0
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2316
	.byte 0x8E	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2320
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D3
	.short 0x00C2
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D3
	.short 0x0112
	.short 0x00EB
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0025
	.short 0x002D
	.short 0x0038
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0027
	.short 0x002B
	.short 0x0036
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0049
	.short 0x002D
	.short 0x005C
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x004B
	.short 0x002B
	.short 0x005A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x006D
	.short 0x002D
	.short 0x0080
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x006F
	.short 0x002B
	.short 0x007E
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x0094
	.short 0x0033
	.short 0x00A7
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0096
	.short 0x0031
	.short 0x00A5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00BF
	.short 0x004D
	.short 0x00D3
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000D
	.short 0x00C1
	.short 0x004B
	.short 0x00D1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x001A
	.short 0x0118
	.short 0x001A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x003B
	.short 0x0119
	.short 0x003B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x00B7
	.short 0x0119
	.short 0x00B7
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0038
	.short 0x00B8
	.short 0x0119
	.short 0x00B8
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DF
	.short 0x00C4
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00DF
	.short 0x0114
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0037
	.short 0x001A
	.short 0x0037
	.short 0x00B7
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x005C
	.short 0x001A
	.short 0x005C
	.short 0x00B8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009B
	.short 0x001A
	.short 0x009B
	.short 0x00B8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DC
	.short 0x001A
	.short 0x00DC
	.short 0x00B8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0118
	.short 0x001A
	.short 0x0118
	.short 0x00B8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0119
	.short 0x001C
	.short 0x0119
	.short 0x00B8
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x37
	.short 0x0057


; ------------------------------------------------------------------
; 0xF3B5A9-0xF3B5D0 -- 5 display-list records, 40 bytes -- interpreter A
; Formerly Data_F3B5A9 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
Paint_TrackAssign_DL2:
; ; drawn (start operand) by Paint_TrackAssign -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1ED5
	.ascii "ASSIGN"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x20E1
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x2311
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D3
	.short 0x009A
	.short 0x00EB
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DF
	.short 0x009C
	.short 0x00DF


; ------------------------------------------------------------------
; 0xF3B5D1-0xF3B610 -- 8 display-list records, 64 bytes -- interpreter A
; Formerly Data_F3B5D1 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
Paint_TrackLabels1To8_DL:
; ; drawn (start operand) by Paint_TrackLabels1To8 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0A07
	.ascii "TR 1"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0C5F
	.ascii "TR 2"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0EB7
	.ascii "TR 3"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x110F
	.ascii "TR 4"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1367
	.ascii "TR 5"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x15BF
	.ascii "TR 6"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1817
	.ascii "TR 7"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1A6F
	.ascii "TR 8"


; ------------------------------------------------------------------
; 0xF3B611-0xF3B650 -- 8 display-list records, 64 bytes -- interpreter A
; Formerly Data_F3B611 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
Paint_TrackLabels9To16_DL:
; ; drawn (start operand) by Paint_TrackLabels9To16 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0A07
	.ascii "TR 9"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0C5F
	.ascii "TR10"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x0EB7
	.ascii "TR11"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x110F
	.ascii "TR12"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1367
	.ascii "TR13"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x15BF
	.ascii "TR14"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1817
	.ascii "TR15"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1A6F
	.ascii "TR16"

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
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2641
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0x0C, 0x0A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2642
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0x64, 0x0C	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2643
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0xBC, 0x0E	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2644
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0x14, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2645
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0x6C, 0x13	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2646
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0xC4, 0x15	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2647
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0x1C, 0x18	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x2648
	.short 0x00FF
	.short 0xE806
	.short 0xF3B7
	.byte 0x00, 0x07, 0x00, 0x74, 0x1A	; operand bytes the handler does not read


; ------------------------------------------------------------------
; 0xF3B6D3-0xF3B74A -- 8 display-list records, 120 bytes -- interpreter A
; Formerly Data_F3B6D3 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
TrackAssign_DrawLocalControlColumn_DL:
; drawn (start operand) by TrackAssign_DrawLocalControlColumn -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0x16, 0x0A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0x6E, 0x0C	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0xC6, 0x0E	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0x1E, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0x76, 0x13	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0xCE, 0x15	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0x26, 0x18	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0x9406
	.short 0xF3B9
	.byte 0x00, 0x03, 0x00, 0x7E, 0x1A	; operand bytes the handler does not read


; ------------------------------------------------------------------
; 0xF3B74B-0xF3B7C2 -- 8 display-list records, 120 bytes -- interpreter A
; Formerly Data_F3B74B -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round3_module.py
; ------------------------------------------------------------------
TrackAssign_DrawOutChannelColumn_DL:
; drawn (start operand) by TrackAssign_DrawOutChannelColumn -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0x1C, 0x0A	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0x74, 0x0C	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0xCC, 0x0E	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0x24, 0x11	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0x7C, 0x13	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0xD4, 0x15	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0x2C, 0x18	; operand bytes the handler does not read
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x00FF
	.short 0xC806
	.short 0xF3B8
	.byte 0x00, 0x06, 0x00, 0x84, 0x1A	; operand bytes the handler does not read

; === END COVER-R1 0xF3B3B2-0xF3B7C3 ===

; ------------------------------------------------------------------
; 0xF3B7C3-0xF3B7CC -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF3B7C3
;   ends used:  0xF3B7CD
; ------------------------------------------------------------------
TrackAssign_DrawTrackGroupHighlight_DL:
; drawn (start operand) by TrackAssign_DrawTrackGroupHighlight -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x006F
	.short 0x0031
	.short 0x00A5

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
	.byte 0x1C, 0x19	; op 1C, 25 bytes -> handler 0xF31A52
	.short 0x0030
	.short 0x0008
	.ascii "TRACK ASSIGN CHANGE"
	.byte 0x08, 0x0E	; op 08, 14 bytes -> handler 0xF31A3A
	.short 0x07FE
	.ascii "ATTENTION!"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0C03
	.ascii "YES"
	.byte 0x07, 0x1E	; op 07, 30 bytes -> handler 0xF31A3A
	.short 0x0E39
	.ascii "Changing the assignment of"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1157
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x117B
	.ascii "NO"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x1249
	.ascii "Track"
	.byte 0x07, 0x0A	; op 07, 10 bytes -> handler 0xF31A3A
	.short 0x1250
	.ascii " from "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x125D
	.ascii "~"
	.byte 0x07, 0x23	; op 07, 35 bytes -> handler 0xF31A3A
	.short 0x1659
	.ascii "will erase all the current data"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x1BD3
	.ascii "Are"
	.byte 0x08, 0x07	; op 08, 7 bytes -> handler 0xF31A3A
	.short 0x1BDB
	.ascii "You"
	.byte 0x08, 0x09	; op 08, 9 bytes -> handler 0xF31A3A
	.short 0x1BE3
	.ascii "Sure?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x0025
	.short 0x010A
	.short 0x00D2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0047
	.short 0x0135
	.short 0x005A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0049
	.short 0x0133
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x006A
	.short 0x0135
	.short 0x007D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x006C
	.short 0x0133
	.short 0x007B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0043
	.short 0x00D0
	.short 0x0043
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0044
	.short 0x00D0
	.short 0x0044
Paint_TrackAssign_DL3:
; ; drawn (start operand) by Paint_TrackAssign -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long Data_F39559 + 0xA9	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x1256	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long Data_F39559 + 0xA9	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x125E	; +0x0D -> IX
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x124E	; +0x07 -> IX
	.byte 0x02	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
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
	.byte 0x1C, 0x19	; op 1C, 25 bytes -> handler 0xF31A52
	.short 0x0048
	.short 0x0005
	.ascii "AFTER T0UCH SETTING"
	.byte 0x07, 0x25	; op 07, 37 bytes -> handler 0xF31A3A
	.short 0x070A
	.ascii "Select whether or not After Touch"
	.byte 0x07, 0x21	; op 07, 33 bytes -> handler 0xF31A3A
	.short 0x0A02
	.ascii "is recorded by the Sequencer."
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11A7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x11CB
	.ascii "EN"
	.byte 0x07, 0x18	; op 07, 24 bytes -> handler 0xF31A3A
	.short 0x1453
	.ascii "AFTER TOUCH RECORD :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x171F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1743
	.ascii "DIS"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x39
	.short 0x002D
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x006A
	.short 0x00FE
	.short 0x00A5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x006C
	.short 0x0134
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x006E
	.short 0x0132
	.short 0x007D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0114
	.short 0x008F
	.short 0x0134
	.short 0x00A2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x0091
	.short 0x0132
	.short 0x00A0
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
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLTable_DisableEnable	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x1467	; +0x0D -> IX
AfterT0uchSetting_EraseRecordValue_DL:
; drawn (start operand) by AfterT0uchSetting_EraseRecordValue -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00B8
	.short 0x0082
	.short 0x00F8
	.short 0x008A

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
	.byte 0x1C, 0x12	; op 1C, 18 bytes -> handler 0xF31A52
	.short 0x0060
	.short 0x0006
	.ascii "MEASURE C0PY"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0617
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0A53
	.ascii "FROM TRACK"
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x0A68
	.ascii "TO TRACK"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B68
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C88
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C9D
	.ascii ":"
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1043
	.ascii "FIRST MEASURE"
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1058
	.ascii "START MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1158
	.byte 0x10	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x009B
	.short 0x006F
	.byte 0x8A	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x117F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1278
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x128D
	.ascii ":"
	.byte 0x07, 0x10	; op 07, 16 bytes -> handler 0xF31A3A
	.short 0x165B
	.ascii "LAST MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1748
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x1760
	.ascii "REPEAT :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1797
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1890
	.ascii ":"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x45
	.short 0x0030
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0090
	.short 0x003F
	.short 0x0093
	.short 0x003F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AB
	.short 0x003F
	.short 0x00AE
	.short 0x003F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AB
	.short 0x0086
	.short 0x00AE
	.short 0x0086
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0090
	.short 0x00AC
	.short 0x0093
	.short 0x00AC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0093
	.short 0x003F
	.short 0x0093
	.short 0x00AC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00AB
	.short 0x003F
	.short 0x00AB
	.short 0x0086
Paint_MeasureC0py_DL:
; ; drawn (start operand) by Paint_MeasureC0py -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x063C
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0022
	.short 0x0135
	.short 0x0035
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0024
	.short 0x0133
	.short 0x0033
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3BCCB:
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x003F
	.short 0x008A
	.short 0x005E
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x003F
	.short 0x0132
	.short 0x005E
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0065
	.short 0x008A
	.short 0x0084
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x0065
	.short 0x0132
	.short 0x0084
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00B3
	.short 0x008F
	.short 0x0132
	.short 0x00A6
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008B
	.short 0x008A
	.short 0x00AA
DL_F3BD07:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16MasterAll	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0C89	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16MasterAll	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0C9E	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1279	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1891	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x128E	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1768	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+9	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3BD58	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05EF
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x063B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1DAF
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1DD3
	.ascii "NO"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0022
	.short 0x0135
	.short 0x0035
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0024
	.short 0x0133
	.short 0x0033
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x00B9
	.short 0x0135
	.short 0x00CC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00BB
	.short 0x0133
	.short 0x00CA
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
	.byte 0x1C, 0x14	; op 1C, 20 bytes -> handler 0xF31A52
	.short 0x005F
	.short 0x0006
	.ascii "MEASURE INSERT"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x05C7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x0E	; op 07, 14 bytes -> handler 0xF31A3A
	.short 0x0A53
	.ascii "FROM TRACK"
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x0A68
	.ascii "TO TRACK"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B68
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C88
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C9D
	.ascii ":"
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1043
	.ascii "FIRST MEASURE"
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x1058
	.ascii "START MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1158
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x117F
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1278
	.ascii ":"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0098
	.short 0x0076
	.byte 0x8A	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x128D
	.ascii ":"
	.byte 0x07, 0x10	; op 07, 16 bytes -> handler 0xF31A3A
	.short 0x1633
	.ascii "LAST MEASURE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1748
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x1760
	.ascii "REPEAT :"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1797
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1868
	.ascii ":"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x48
	.short 0x0030
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0090
	.short 0x003F
	.short 0x0093
	.short 0x003F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AB
	.short 0x003F
	.short 0x00AE
	.short 0x003F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AB
	.short 0x0086
	.short 0x00AE
	.short 0x0086
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0090
	.short 0x00AC
	.short 0x0093
	.short 0x00AC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0093
	.short 0x003F
	.short 0x0093
	.short 0x00AC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00AB
	.short 0x003F
	.short 0x00AB
	.short 0x0086
Paint_MeasureInsert_DL:
; ; drawn (start operand) by Paint_MeasureInsert -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05EC
	.ascii "OK"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x0020
	.short 0x0134
	.short 0x0033
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x0022
	.short 0x0132
	.short 0x0031
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
DL_F3BEF7:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16MasterAll	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0C89	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+5	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To16MasterAll	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0C9E	; +0x0D -> IX
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+1	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1279	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+3	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1869	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x06, 0x0A	; B op 06, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x128E	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1768	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+9	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F3BF48	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x1C, 0x0F	; op 1C, 15 bytes -> handler 0xF31A52
	.short 0x0078
	.short 0x0006
	.ascii "S0NG C0PY"
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x0648
	.ascii "FROM"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x065A
	.ascii "TO"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x0A7F
	.ascii "SONG "
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x0A90
	.ascii "SONG "
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B8F
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BB4
	.ascii "OK"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0D9F
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0DB0
	.ascii ":"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0093
	.short 0x005F
	.byte 0x8A	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0038
	.short 0x007B
	.short 0x008F
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00B7
	.short 0x0038
	.short 0x0104
	.short 0x008F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x006E
	.short 0x007D
	.short 0x006E
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00B7
	.short 0x006E
	.short 0x0106
	.short 0x006E
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x41
	.short 0x0034
; DL_FromToSongNoTrAllSongNoTrAll -- the display list at 0xF3BFF8.  Its own
;                                    text records read: "FROM"; "TO"; "SONG NO
;                                    TR/ALL    SONG NO   TR/ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_FromToSongNoTrAllSongNoTrAll:
	.byte 0x07, 0x08	; op 07, 8 bytes -> handler 0xF31A3A
	.short 0x1B10
	.ascii "FROM"
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x1B25
	.ascii "TO"
	.byte 0x06, 0x28	; op 06, 40 bytes -> handler 0xF31A3A
	.short 0x1EF2
	.ascii "SONG NO   TR/ALL    SONG NO   TR/ALL"
	.byte 0x06, 0x29	; op 06, 41 bytes -> handler 0xF31A3A
	.short 0x2239
	.ascii " <    >    <    >    <    >    <    >"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D3
	.short 0x0022
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00D3
	.short 0x004A
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0051
	.short 0x00D3
	.short 0x006E
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0079
	.short 0x00D3
	.short 0x0096
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A7
	.short 0x00D3
	.short 0x00C4
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CF
	.short 0x00D3
	.short 0x00EC
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D3
	.short 0x0112
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D3
	.short 0x013A
	.short 0x00EB
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011B
	.short 0x0045
	.short 0x0135
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x0047
	.short 0x0133
	.short 0x0056
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x00BD
	.short 0x0098
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A4
	.short 0x00BD
	.short 0x013B
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x00BE
	.short 0x0098
	.short 0x00BE
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A4
	.short 0x00BE
	.short 0x013B
	.short 0x00BE
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0004
	.short 0x00BD
	.short 0x0004
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00BD
	.short 0x0005
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0097
	.short 0x00BD
	.short 0x0097
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0098
	.short 0x00BD
	.short 0x0098
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A4
	.short 0x00BD
	.short 0x00A4
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00BD
	.short 0x00A5
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013A
	.short 0x00BD
	.short 0x013A
	.short 0x00C2
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013B
	.short 0x00BD
	.short 0x013B
	.short 0x00C2
; DL_TrackTrack -- the display list at 0xF3C133.  Its own text records read:
;                  "TRACK"; "TRACK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TrackTrack:
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x133F
	.ascii "TRACK"
	.byte 0x07, 0x09	; op 07, 9 bytes -> handler 0xF31A3A
	.short 0x1350
	.ascii "TRACK"
; DL_AllAll -- the display list at 0xF3C145.  Its own text records read:
;              "ALL"; "ALL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_AllAll:
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x133F
	.ascii "  ALL   "
	.byte 0x07, 0x0C	; op 07, 12 bytes -> handler 0xF31A3A
	.short 0x1350
	.ascii "  ALL   "
S0ngC0py_DrawFromSong_DL2:
; ; drawn (start operand) by S0ngC0py_DrawFromSong -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long 0x000012F8	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0DA0	; +0x0D -> IX
S0ngC0py_DrawToSong_DL:
; ; drawn (start operand) by S0ngC0py_DrawToSong -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long 0x000012FE	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0DB1	; +0x0D -> IX
S0ngC0py_DrawTracks_DL:
; ; drawn (start operand) by S0ngC0py_DrawTracks -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+14	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To17All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1344	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+15	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long DLText_0To17All	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1355	; +0x0D -> IX

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
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x12F6
	.short 0x000F
	.short 0x8407
	.short 0x020A
	.byte 0x00, 0x0A	; op 00, 10 bytes -> handler 0xF31A75
	.short 0x12F7
	.short 0x000F
	.short 0x9507
	.short 0x020A

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
	.byte 0x1C, 0x18	; op 1C, 24 bytes -> handler 0xF31A52
	.short 0x0055
	.short 0x0005
	.ascii "S0NG SELECT & NAME"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x010A
	.short 0x0030
	.ascii " KB"
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x0030
	.short 0x003D
	.ascii "S0NG"
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x09A4
	.ascii ":"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0111
	.short 0x003D
	.ascii "%"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0073
	.short 0x003E
	.ascii ":"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11FF
	.ascii "_"
	.byte 0x06, 0x1E	; op 06, 30 bytes -> handler 0xF31A3A
	.short 0x1250
	.ascii " A B C D E F G H I J K L M"
	.byte 0x06, 0x1D	; op 06, 29 bytes -> handler 0xF31A3A
	.short 0x14A7
	.ascii "N O P Q R S T U V W X Y Z"
	.byte 0x06, 0x17	; op 06, 23 bytes -> handler 0xF31A3A
	.short 0x1727
	.ascii "O 1 2 3 4 5 6 7 8 9"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1C61
	.ascii "NAME"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1ECB
	.ascii "SONG"
	.byte 0x06, 0x0C	; op 06, 12 bytes -> handler 0xF31A3A
	.short 0x1ED8
	.ascii "POSITION"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1EE2
	.ascii "ABC"
	.byte 0x16, 0x06	; op 16, 6 bytes -> handler 0xF31A3A
	.short 0x1EE5
	.byte 0x16, 0x16	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1EE7
	.ascii "789"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x223A
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x223F
	.ascii ">"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2249
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x224E
	.ascii ">"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2253
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2258
	.ascii ">"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x225C
	.ascii "CLR"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x35
	.short 0x002F
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0026
	.short 0x002A
	.short 0x0122
	.short 0x0054
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D3
	.short 0x0022
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00D3
	.short 0x004A
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D3
	.short 0x009A
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D3
	.short 0x00C2
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00D3
	.short 0x00EA
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D3
	.short 0x0112
	.short 0x00EB
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D3
	.short 0x013A
	.short 0x00EB
	.byte 0x13, 0x0A	; op 13, 10 bytes -> handler 0xF31A75
	.short 0x0026
	.short 0x006A
	.short 0x0122
	.short 0x00A7
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007B
	.short 0x00BA
	.short 0x00BF
	.short 0x00BA
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F4
	.short 0x00BA
	.short 0x013C
	.short 0x00BA
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x007B
	.short 0x00BA
	.short 0x007B
	.short 0x00BE
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013C
	.short 0x00BA
	.short 0x013C
	.short 0x00BF
S0ngSelectName_DrawValues_DL:
; ; drawn (start operand) by S0ngSelectName_DrawValues -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short 0x0000	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x08	; +0x06 swi 7 function
	.long 0x000012F6	; +0x07 -> XIY: string table
	.short 0x0006	; +0x0B -> BC: bytes per entry
	.short 0x0998	; +0x0D -> IX
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x005C	; +0x07 -> (0x2530)
	.short 0x003D	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x0A, 0x0C	; B op 0A, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+7	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00F8	; +0x07 -> (0x2530)
	.short 0x0030	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short DisplayListB_Stage+9	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1C	; +0x06 swi 7 function
	.short 0x00F0	; +0x07 -> (0x2530)
	.short 0x003D	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count

; --- 0xF3C351-0xF3C366: not converted ---

; ------------------------------------------------------------------
; 0xF3C351-0xF3C366 -- 2 display-list records, 22 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C351 lands with ZERO DRIFT exactly on 0xF3C367,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
DL_F3C351:
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x000F1301
	.short 0x7D05
	.short 0xF3C3
	.byte 0x00	; operand bytes the handler does not read
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x00FF1302
	.short 0xAD05
	.short 0xF3C3
	.byte 0x00	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF3C367-0xF3C37C -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF3C367
;   ends used:  0xF3C372, 0xF3C37D
; ------------------------------------------------------------------
DL_F3C367:
	.byte 0x08, 0x0B	; B op 08, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+11	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long Data_F3C37D	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x08, 0x0B	; B op 08, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+12	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F3C3AD	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x06, 0x0E	; op 06, 14 bytes -> handler 0xF31A3A
	.short 0x1863
	.ascii "A current "
	.byte 0x06, 0x12	; op 06, 18 bytes -> handler 0xF31A3A
	.short 0x1874
	.ascii " track will be"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1AA7
	.ascii "."
	.byte 0x06, 0x18	; op 06, 24 bytes -> handler 0xF31A3A
	.short 0x1AE3
	.ascii "cleared automaticaly"
	.byte 0x1C, 0x14	; op 1C, 20 bytes -> handler 0xF31A52
	.short 0x0040
	.short 0x00C4
	.ascii "Are You Sure ?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0011
	.short 0x0098
	.short 0x0122
	.short 0x00E9
Paint_S0ngC0py_DL:
; ; drawn (start operand) by Paint_S0ngC0py -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+17	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_ChordApcControlRhythm	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x186D	; +0x0D -> IX

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
	.byte 0x1C, 0x16	; op 1C, 22 bytes -> handler 0xF31A52
	.short 0x0058
	.short 0x0006
	.ascii "SEQUENCER MEDLEY"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0B67
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x0B89
	.ascii "START"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0C08
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x12	; op 07, 18 bytes -> handler 0xF31A3A
	.short 0x0C0C
	.ascii "FIRST S0NG    "
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x118D
	.byte 0x89	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x11F7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1219
	.ascii "STOP"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1797
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x17B9
	.ascii "SKIP"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E8
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x12	; op 07, 18 bytes -> handler 0xF31A3A
	.short 0x1814
	.ascii "LAST S0NG     "
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F55
	.ascii "SONG"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00F7
	.short 0x00D2
	.ascii "MIDI"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x00D2
	.ascii "NORM"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x210E
	.byte 0x8D	; character codes below 0x20
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00F7
	.short 0x00DD
	.ascii "FILE"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x00DD
	.ascii "FILE"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x233E
	.byte 0x8E	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x00FE
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0128
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00C4
	.short 0x004F
	.byte 0x10	; character codes below 0x20
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x38
	.short 0x0030
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0043
	.short 0x00C2
	.short 0x0062
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x008F
	.short 0x00C2
	.short 0x00AE
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D4
	.short 0x00C2
	.short 0x00EC
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0104
	.short 0x0044
	.short 0x0134
	.short 0x0057
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0106
	.short 0x0046
	.short 0x0132
	.short 0x0055
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0104
	.short 0x006E
	.short 0x0134
	.short 0x0081
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0106
	.short 0x0070
	.short 0x0132
	.short 0x007F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0104
	.short 0x0092
	.short 0x0134
	.short 0x00A5
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00F3
	.short 0x00CE
	.short 0x0113
	.short 0x00E7
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011C
	.short 0x00CE
	.short 0x013D
	.short 0x00E7
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C2
	.short 0x0052
	.short 0x00D2
	.short 0x0052
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C2
	.short 0x00A0
	.short 0x00D2
	.short 0x00A0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E0
	.short 0x00C4
	.short 0x00E0
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x0052
	.short 0x00D2
	.short 0x00A0

; --- 0xF3C6B3-0xF3C720: not converted ---

; ------------------------------------------------------------------
; 0xF3C6B3-0xF3C720 -- 13 display-list records, 110 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF3C6B3 lands with ZERO DRIFT exactly on 0xF3C721,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
DL_F3C6B3:
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1E59
	.ascii "SELECT"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x219D
	.ascii "INT"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x21A3
	.ascii "FD"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x21A8
	.ascii "HD"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x002E
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0059
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0082
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00D4
	.short 0x0044
	.short 0x00E4
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x004D
	.short 0x00D4
	.short 0x006D
	.short 0x00E4
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0078
	.short 0x00D4
	.short 0x0098
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00CE
	.short 0x0098
	.short 0x00CE
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00CE
	.short 0x0024
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0098
	.short 0x00CE
	.short 0x0098
	.short 0x00D1

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
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1E56
	.ascii "SELECT"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x219D
	.ascii "INT"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x21A3
	.ascii "FD"
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x002E
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x1C, 0x07	; op 1C, 7 bytes -> handler 0xF31A52
	.short 0x0059
	.short 0x00E5
	.byte 0x12	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00D4
	.short 0x0044
	.short 0x00E4
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x004D
	.short 0x00D4
	.short 0x006D
	.short 0x00E4
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00CE
	.short 0x006D
	.short 0x00CE
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00CE
	.short 0x0024
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x006D
	.short 0x00CE
	.short 0x006D
	.short 0x00D1
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
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x0C1A	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x1822	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+12	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F3C7E3	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+13	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F3C7E3 + 0x18	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+14	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F3C7E3 + 0x30	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x000F1305
	.short 0x2305
	.short 0xF3C8
	.byte 0x00	; operand bytes the handler does not read
	.byte 0x08, 0x0B	; op 08, 11 bytes -> handler 0xF31A3A
	.short 0x1302
	.byte 0x0F, 0x00, 0x1B	; character codes below 0x20
	.ascii "3"
	.byte 0xC8, 0xF3, 0x00	; character codes below 0x20

; ------------------------------------------------------------------
; 0xF3C7C3-0xF3C7CC -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF3C7C3
;   ends used:  0xF3C7CD
; ------------------------------------------------------------------
SequencerMedley_DrawSourceBox_DL:
; ; drawn (start operand) by SequencerMedley_DrawSourceBox -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0024
	.short 0x00D4
	.short 0x0098
	.short 0x00E4

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
	.byte 0x08, 0x0B	; op 08, 11 bytes -> handler 0xF31A3A
	.short 0x1304
	.byte 0x0F, 0x00, 0x1B	; character codes below 0x20
	.ascii "K"
	.byte 0xC8, 0xF3, 0x00	; character codes below 0x20
	.byte 0x08, 0x0B	; op 08, 11 bytes -> handler 0xF31A3A
	.short 0x1305
	.byte 0x0F, 0x00, 0x1B	; character codes below 0x20
	.ascii "["
	.byte 0xC8, 0xF3, 0x00	; character codes below 0x20

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
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x05CC
	.short 0x0021
	.short 0x0010


; ------------------------------------------------------------------
; 0xF3C873-0xF3C89C -- 3 display-list records, 42 bytes -- interpreter A
; Formerly Data_F3C873 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
SequencerMedley_DrawPlayState_DL2:
; ; drawn (start operand) by SequencerMedley_DrawPlayState -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x15	; op 07, 21 bytes -> handler 0xF31A3A
	.short 0x05CC
	.ascii "N0W PLAYING S0NG "
	.byte 0x07, 0x06	; op 07, 6 bytes -> handler 0xF31A3A
	.short 0x05E0
	.ascii " :"
	.byte 0x02, 0x0F	; op 02, 15 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x0000
	.short 0x3807
	.short 0x000E
	.byte 0x00, 0x0B, 0x00, 0xE2, 0x05	; operand bytes the handler does not read

; ------------------------------------------------------------------
; 0xF3C89D-0xF3C946 -- 9 display-list records, 170 bytes -- interpreter A (8 records) and B (1)
;   entered at: 0xF3C89D, 0xF3C8A7
;   ends used:  0xF3C8A7, 0xF3C947
; ------------------------------------------------------------------
SequencerMedley_DrawPlayState_DL3:
; ; drawn (start operand) by SequencerMedley_DrawPlayState -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x00, 0x0A	; B op 00, 10 bytes -> handler 0xF31BA1 -- decimal readout, unsigned (0xF8BCAF via T_Value_ToAsciiDigits3_RightJustified)
	.short DisplayListB_Stage	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.short 0x05DD	; +0x07 -> IX
	.byte 0x03	; +0x09 digit count: 3 -> 0x2661, 2 -> 0x2662, else 0x2663
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
	.byte 0x1C, 0x11	; op 1C, 17 bytes -> handler 0xF31A52
	.short 0x0044
	.short 0x0005
	.ascii "STEP RECORD"
	.byte 0x07, 0x11	; op 07, 17 bytes -> handler 0xF31A3A
	.short 0x0109
	.ascii ": PART SELECT"
	.byte 0x07, 0x22	; op 07, 34 bytes -> handler 0xF31A3A
	.short 0x07FB
	.ascii "Press the up/down button under"
	.byte 0x07, 0x23	; op 07, 35 bytes -> handler 0xF31A3A
	.short 0x0B43
	.ascii "the screen corresponding to the"
	.byte 0x07, 0x1A	; op 07, 26 bytes -> handler 0xF31A3A
	.short 0x0E3B
	.ascii "track that you want to"
	.byte 0x07, 0x10	; op 07, 16 bytes -> handler 0xF31A3A
	.short 0x11AB
	.ascii "STEP RECORD."
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0013
	.short 0x0027
	.short 0x0122
	.short 0x0086
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x34
	.short 0x002D

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
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x04B0
	.short 0x0022
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x0BB8
	.short 0x0022
	.short 0x0006
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x12C0
	.short 0x0019
	.short 0x0006
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x19C8
	.short 0x0022
	.short 0x0006
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+6	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x07	; +0x06 swi 7 function
	.long StringTable_F3C976	; +0x07 -> XIY: string table
	.short 0x0007	; +0x0B -> BC: bytes per entry
	.short 0x003F	; +0x0D -> IX

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
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x06DB
	.ascii "MIX"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0028
	.short 0x0133
	.short 0x0037
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0026
	.short 0x0135
	.short 0x0039
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x06B7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "CTL"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x199A
	.ascii "REST"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x010D
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x010B
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x29	; op 06, 41 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS NOTE VEL   LENGTH   PHRS  CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D7
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DF
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20DC
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E4
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E1
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E9
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E6
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22EE
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20EB
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22F3
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CA8C:
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F2C
	.ascii "VALUE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E6
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22EE
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D2
	.short 0x00C3
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DF
	.short 0x00C3
	.short 0x00DF
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x06DB
	.ascii "MIX"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0028
	.short 0x0133
	.short 0x0037
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0026
	.short 0x0135
	.short 0x0039
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x06B7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CB4B:
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F27
	.ascii "TEMPO"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E1
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E9
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D2
	.short 0x009B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DF
	.short 0x009B
	.short 0x00DF
DL_F3CB72:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x171A
	.ascii "TRACK"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "CLR"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F27
	.ascii "TEMPO"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E1
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E9
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D2
	.short 0x009B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DF
	.short 0x009B
	.short 0x00DF
DL_F3CC3A:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x06DB
	.ascii "MIX"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x06B7
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0028
	.short 0x0133
	.short 0x0037
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0026
	.short 0x0135
	.short 0x0039
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "NO"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CCF1:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "NO"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CD88:
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x06DB
	.ascii "MIX"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x06B7
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0028
	.short 0x0133
	.short 0x0037
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0026
	.short 0x0135
	.short 0x0039
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F2C
	.ascii "VALUE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E6
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22EE
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D2
	.short 0x00C3
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DF
	.short 0x00C3
	.short 0x00DF
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CE47:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x222A
	.ascii "REP"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x222F
	.ascii "END"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00D2
	.short 0x00EB
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x171A
	.ascii "TRACK"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "CLR"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CEE2:
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F27
	.ascii "VALUE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E1
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E9
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D2
	.short 0x009B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DF
	.short 0x009B
	.short 0x00DF
Paint_StepRecord_DL2:
; ; drawn (start operand) by Paint_StepRecord -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x34
	.short 0x002D
	.byte 0x07, 0x10	; op 07, 16 bytes -> handler 0xF31A3A
	.short 0x0033
	.ascii "STEP RECORD:"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x028F
	.ascii "TRACK:"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x3A
	.short 0x002D
	.byte 0x07, 0x16	; op 07, 22 bytes -> handler 0xF31A3A
	.short 0x0033
	.ascii "MASTER STEP RECORD"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3CF57:
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "NO"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
Paint_StepRecord_DL1:
; ; drawn (start operand) by Paint_StepRecord -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x08, 0x11	; op 08, 17 bytes -> handler 0xF31A3A
	.short 0x1138
	.ascii "Are You Sure?"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "NO"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089

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
	.byte 0x07, 0x10	; op 07, 16 bytes -> handler 0xF31A3A
	.short 0x0033
	.ascii "STEP RECORD:"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x028F
	.ascii "TRACK:"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x171A
	.ascii "TRACK"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "CLR"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF

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
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x1159
	.short 0x0021
	.short 0x000D

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
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+13	; +0x02 source variable, 16-bit address
	.byte 0x0C	; +0x04 AND mask
	.byte 0x82	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F3DA82	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+10	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F3DAAD	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short DisplayListB_Stage+8	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F3DAF8	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

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
	.byte 0x04, 0x0B	; B op 04, 11 bytes -> handler 0xF31B86 -- entry[value] -> IY, BC, HL
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x0E	; +0x06 swi 7 function
	.long Data_F3DC21	; +0x07 -> XIX: array of 6-byte entries, indexed by the value
	.byte 0x04, 0x0B	; B op 04, 11 bytes -> handler 0xF31B86 -- entry[value] -> IY, BC, HL
	.short UI_DrawScratch+1	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x0E	; +0x06 swi 7 function
	.long Data_F3DC21 + 0x1E	; +0x07 -> XIX: array of 6-byte entries, indexed by the value
	.byte 0x04, 0x0B	; B op 04, 11 bytes -> handler 0xF31B86 -- entry[value] -> IY, BC, HL
	.short UI_DrawScratch+2	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x0E	; +0x06 swi 7 function
	.long Data_F3DC21 + 0x3C	; +0x07 -> XIX: array of 6-byte entries, indexed by the value

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
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+24	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A51	; +0x0D -> IX
Data_F3DCCA:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+25	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A55	; +0x0D -> IX
Data_F3DCD9:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+26	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A59	; +0x0D -> IX
Data_F3DCE8:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+27	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A5D	; +0x0D -> IX
Data_F3DCF7:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+28	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A61	; +0x0D -> IX
Data_F3DD06:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+29	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A65	; +0x0D -> IX
Data_F3DD15:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+30	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A69	; +0x0D -> IX
Data_F3DD24:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+31	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x0A6D	; +0x0D -> IX
Data_F3DD33:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+11	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1159	; +0x0D -> IX
Data_F3DD42:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+12	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x115D	; +0x0D -> IX
Data_F3DD51:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+13	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1161	; +0x0D -> IX
Data_F3DD60:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+14	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1165	; +0x0D -> IX
Data_F3DD6F:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+15	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1169	; +0x0D -> IX
Data_F3DD7E:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+16	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x116D	; +0x0D -> IX
Data_F3DD8D:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+17	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1171	; +0x0D -> IX
Data_F3DD9C:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+18	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1175	; +0x0D -> IX
Data_F3DDAB:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+19	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1861	; +0x0D -> IX
Data_F3DDBA:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+20	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1865	; +0x0D -> IX
Data_F3DDC9:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+21	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1869	; +0x0D -> IX
Data_F3DDD8:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+22	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x186D	; +0x0D -> IX
Data_F3DDE7:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+23	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1871	; +0x0D -> IX
Data_F3DDF6:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+24	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1875	; +0x0D -> IX
Data_F3DE05:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+25	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x1879	; +0x0D -> IX
Data_F3DE14:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short DisplayListB_Stage+26	; +0x02 source variable, 16-bit address
	.byte 0x60	; +0x04 AND mask
	.byte 0x85	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLTable_F3DE23	; +0x07 -> XIY: string table
	.short 0x0001	; +0x0B -> BC: bytes per entry
	.short 0x187D	; +0x0D -> IX

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
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00D2
	.short 0x004B
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00D2
	.short 0x0073
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D2
	.short 0x009B
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00D2
	.short 0x00C3
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00D2
	.short 0x00EB
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00DF
	.short 0x004B
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00DF
	.short 0x0073
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DF
	.short 0x009B
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00DF
	.short 0x00C3
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00DF
	.short 0x00EB
	.short 0x00DF

; ------------------------------------------------------------------
; 0xF3DEB2-0xF3E06D -- 56 display-list records, 444 bytes -- interpreter A
;   named by StepSelectAddrTable_F3D089: 0xF3DEB2, 0xF3DF6A, 0xF3E04E
; ------------------------------------------------------------------
DL_F3DEB2:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "CTL"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x06DB
	.ascii "MIX"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0028
	.short 0x0133
	.short 0x0037
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0026
	.short 0x0135
	.short 0x0039
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x06B7
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3DF6A:
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "YES"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "NO "
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D7
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DF
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1F1E
	.ascii "CTL"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1F28
	.ascii "VALUE"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20E1
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E9
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00D2
	.short 0x004B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00DF
	.short 0x004B
	.short 0x00DF
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00D2
	.short 0x009B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00DF
	.short 0x009B
	.short 0x00DF
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3E04E:
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "CTL"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089

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
	.byte 0x1C, 0x18	; op 1C, 24 bytes -> handler 0xF31A52
	.short 0x0038
	.short 0x0003
	.ascii "MASTER TRACK CLEAR"
	.byte 0x08, 0x0E	; op 08, 14 bytes -> handler 0xF31A3A
	.short 0x075E
	.ascii "ATTENTION!"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0BB7
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x21	; op 07, 33 bytes -> handler 0xF31A3A
	.short 0x0BBA
	.ascii "Using MASTER TRACK CLEAR will"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0C03
	.ascii "YES"
	.byte 0x07, 0x21	; op 07, 33 bytes -> handler 0xF31A3A
	.short 0x0E62
	.ascii "erase any existing recordings"
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1157
	.byte 0x11	; character codes below 0x20
	.byte 0x07, 0x18	; op 07, 24 bytes -> handler 0xF31A3A
	.short 0x115A
	.ascii "in the MASTER TRACK."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x117B
	.ascii "N0"
	.byte 0x08, 0x11	; op 08, 17 bytes -> handler 0xF31A3A
	.short 0x151B
	.ascii "Are You Sure?"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0025
	.short 0x0108
	.short 0x009D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0047
	.short 0x0135
	.short 0x005A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0049
	.short 0x0133
	.short 0x0058
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x006A
	.short 0x0135
	.short 0x007D
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x006C
	.short 0x0133
	.short 0x007B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x003F
	.short 0x00CE
	.short 0x003F
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0040
	.short 0x00CE
	.short 0x0040

; ------------------------------------------------------------------
; 0xF3E15C-0xF3E362 -- 64 display-list records, 519 bytes -- interpreter A
;   named by StepSelectAddrTable_F3D089: 0xF3E15C, 0xF3E228, 0xF3E2EB
; ------------------------------------------------------------------
DL_F3E15C:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0D	; op 06, 13 bytes -> handler 0xF31A3A
	.short 0x1F20
	.ascii "TIME SIG."
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20DC
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E4
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00D2
	.short 0x0073
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00DF
	.short 0x0073
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x171A
	.ascii "TRACK"
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "CLR"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3E228:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0D	; op 06, 13 bytes -> handler 0xF31A3A
	.short 0x1F20
	.ascii "TIME SIG."
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20DC
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22E4
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00D2
	.short 0x0073
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00DF
	.short 0x0073
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x135B
	.ascii "YES"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0078
	.short 0x0133
	.short 0x0087
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x0076
	.short 0x0135
	.short 0x0089
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1337
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x199B
	.ascii "NO "
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x00A0
	.short 0x0133
	.short 0x00AF
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0135
	.short 0x00B1
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1977
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3
DL_F3E2EB:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x1F19
	.ascii "MEAS"
	.byte 0x06, 0x0A	; op 06, 10 bytes -> handler 0xF31A3A
	.short 0x1F38
	.ascii "CURSOR"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x20D2
	.byte 0x8D	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x22DA
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2230
	.ascii "<"
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x2235
	.ascii ">"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00D2
	.short 0x0023
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00D2
	.short 0x0113
	.short 0x00EC
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00D2
	.short 0x013B
	.short 0x00EC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00DF
	.short 0x0023
	.short 0x00DF
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0D1B
	.ascii "ERS"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0115
	.short 0x0050
	.short 0x0133
	.short 0x005F
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x004E
	.short 0x0135
	.short 0x0061
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0CF7
	.byte 0x11	; character codes below 0x20
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00AF
	.short 0x00FA
	.short 0x00C3

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
