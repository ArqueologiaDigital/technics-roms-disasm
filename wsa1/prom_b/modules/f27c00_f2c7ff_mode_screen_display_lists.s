
; ------------------------------------------------------------------
; 0xF27C00-0xF283A6 -- 200 display-list records, 1959 bytes -- interpreter A
;   entered at: 0xF27C00, 0xF28064, 0xF2808C, 0xF28331, 0xF2833B, 0xF2834F, 0xF28373, 0xF2837D
;   ends used:  0xF28064, 0xF2808C, 0xF28331, 0xF2833B, 0xF28345, 0xF2834F, 0xF28373, 0xF2837D, 0xF283A7
; ------------------------------------------------------------------
DL_F27C00:
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x05F1
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FC9
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0615
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FED
	.short 0x0002
	.short 0x0009
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x49
	.short 0x16AA
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x24
	.short 0x16CB
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2080
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2085
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208A
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208F
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2094
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2099
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x209E
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x20A3
	.short 0x0005
	.short 0x001E
	.byte 0x1C, 0x10	; op 1C, 16 bytes -> handler 0xF31A52
	.short 0x006E
	.short 0x0005
	.ascii "SOUND MODE"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x13
	.short 0x005A
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17C0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E7
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0031
	.short 0x00B3
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x003F
	.short 0x00B3
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x004D
	.short 0x00B3
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x005B
	.short 0x00B3
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0069
	.short 0x00B3
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0077
	.short 0x00B3
	.ascii "6"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00C2
	.short 0x00B3
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00D0
	.short 0x00B3
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00DE
	.short 0x00B3
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00EC
	.short 0x00B3
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x00B3
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0108
	.short 0x00B3
	.ascii "6"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000A
	.short 0x00D4
	.ascii "OCT"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0032
	.short 0x00D4
	.ascii "LVL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x005A
	.short 0x00D4
	.ascii "PAN"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0080
	.short 0x00D4
	.ascii "EFF1"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00A8
	.short 0x00D4
	.ascii "EFF2"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00D2
	.short 0x00D4
	.ascii "REV"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x00D4
	.ascii "INT"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x00D4
	.ascii "MIDI"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0008
	.short 0x0023
	.short 0x0136
	.short 0x0070
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x007D
	.short 0x009C
	.short 0x00C2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A2
	.short 0x007D
	.short 0x0135
	.short 0x00C2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x0089
	.short 0x002E
	.short 0x0089
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x008A
	.short 0x002E
	.short 0x008A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x0089
	.short 0x001B
	.short 0x0090
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x001C
	.short 0x0089
	.short 0x001C
	.short 0x0090
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0028
	.short 0x009D
	.short 0x002D
	.short 0x009D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0028
	.short 0x009E
	.short 0x002D
	.short 0x009E
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0089
	.short 0x0122
	.short 0x0089
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x008A
	.short 0x0122
	.short 0x008A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0122
	.short 0x0089
	.short 0x0122
	.short 0x0090
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0123
	.short 0x0089
	.short 0x0123
	.short 0x0090
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009D
	.short 0x0116
	.short 0x009D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0116
	.short 0x009E
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00B0
	.short 0x003A
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x003C
	.short 0x00B0
	.short 0x0048
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x00B0
	.short 0x0056
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0058
	.short 0x00B0
	.short 0x0064
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0066
	.short 0x00B0
	.short 0x0072
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0074
	.short 0x00B0
	.short 0x0080
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x00B0
	.short 0x00CB
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00B0
	.short 0x00D9
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00DB
	.short 0x00B0
	.short 0x00E7
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E9
	.short 0x00B0
	.short 0x00F5
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F7
	.short 0x00B0
	.short 0x0103
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0105
	.short 0x00B0
	.short 0x0111
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00BC
	.short 0x0081
	.short 0x00BC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x00BC
	.short 0x0112
	.short 0x00BC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00BD
	.short 0x003B
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x003D
	.short 0x00BD
	.short 0x0049
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x00BD
	.short 0x0057
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0059
	.short 0x00BD
	.short 0x0065
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0067
	.short 0x00BD
	.short 0x0073
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0075
	.short 0x00BD
	.short 0x0081
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C0
	.short 0x00BD
	.short 0x00CC
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x00BD
	.short 0x00DA
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00DC
	.short 0x00BD
	.short 0x00E8
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EA
	.short 0x00BD
	.short 0x00F6
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F8
	.short 0x00BD
	.short 0x0104
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0106
	.short 0x00BD
	.short 0x0112
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00B0
	.short 0x002E
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003A
	.short 0x00B0
	.short 0x003A
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003B
	.short 0x00B1
	.short 0x003B
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003C
	.short 0x00B0
	.short 0x003C
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0048
	.short 0x00B0
	.short 0x0048
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0049
	.short 0x00B1
	.short 0x0049
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x00B0
	.short 0x004A
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0056
	.short 0x00B0
	.short 0x0056
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00B1
	.short 0x0057
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0058
	.short 0x00B0
	.short 0x0058
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0064
	.short 0x00B0
	.short 0x0064
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0065
	.short 0x00B1
	.short 0x0065
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0066
	.short 0x00B0
	.short 0x0066
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0072
	.short 0x00B0
	.short 0x0072
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0073
	.short 0x00B1
	.short 0x0073
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0074
	.short 0x00B0
	.short 0x0074
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0080
	.short 0x00B0
	.short 0x0080
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0081
	.short 0x00B1
	.short 0x0081
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x00B0
	.short 0x00BF
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CB
	.short 0x00B0
	.short 0x00CB
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CC
	.short 0x00B1
	.short 0x00CC
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00B0
	.short 0x00CD
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D9
	.short 0x00B0
	.short 0x00D9
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DA
	.short 0x00B1
	.short 0x00DA
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DB
	.short 0x00B0
	.short 0x00DB
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E7
	.short 0x00B0
	.short 0x00E7
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E8
	.short 0x00B1
	.short 0x00E8
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E9
	.short 0x00B0
	.short 0x00E9
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00B0
	.short 0x00F5
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F6
	.short 0x00B1
	.short 0x00F6
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F7
	.short 0x00B0
	.short 0x00F7
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0103
	.short 0x00B0
	.short 0x0103
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0104
	.short 0x00B1
	.short 0x0104
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0105
	.short 0x00B0
	.short 0x0105
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0111
	.short 0x00B0
	.short 0x0111
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x00B1
	.short 0x0112
	.short 0x00BD
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0021
	.short 0x0138
	.short 0x0072
DL_F28064:
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0083
	.short 0x009A
	.short 0x0090
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x0083
	.short 0x0112
	.short 0x0090
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0097
	.short 0x009A
	.short 0x00A4
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x0097
	.short 0x0112
	.short 0x00A4
DL_F2808C:
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x05F1
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FC9
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0615
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FED
	.short 0x0002
	.short 0x0009
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x24
	.short 0x183B
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2080
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2085
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208A
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208F
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2094
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2099
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x209E
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x20A3
	.short 0x0005
	.short 0x001E
	.byte 0x1C, 0x10	; op 1C, 16 bytes -> handler 0xF31A52
	.short 0x006E
	.short 0x0005
	.ascii "SOUND MODE"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x13
	.short 0x005A
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00C7
	.short 0x009F
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00D5
	.short 0x009F
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00E3
	.short 0x009F
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00F1
	.short 0x009F
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00FF
	.short 0x009F
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x010D
	.short 0x009F
	.ascii "6"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000A
	.short 0x00D4
	.ascii "OCT"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0032
	.short 0x00D4
	.ascii "LVL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x005A
	.short 0x00D4
	.ascii "PAN"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0080
	.short 0x00D4
	.ascii "EFF1"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00A8
	.short 0x00D4
	.ascii "EFF2"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00D2
	.short 0x00D4
	.ascii "REV"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x00D4
	.ascii "INT"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x00D4
	.ascii "MIDI"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0008
	.short 0x0023
	.short 0x0136
	.short 0x0070
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0009
	.short 0x007D
	.short 0x0135
	.short 0x00C2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0021
	.short 0x0093
	.short 0x0036
	.short 0x0093
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0021
	.short 0x0094
	.short 0x0036
	.short 0x0094
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x009C
	.short 0x00D0
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x009C
	.short 0x00DE
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E0
	.short 0x009C
	.short 0x00EC
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x009C
	.short 0x00FA
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FC
	.short 0x009C
	.short 0x0108
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x010A
	.short 0x009C
	.short 0x0116
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00A7
	.short 0x0036
	.short 0x00A7
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00A8
	.short 0x0036
	.short 0x00A8
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x00A8
	.short 0x0117
	.short 0x00A8
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C5
	.short 0x00A9
	.short 0x00D1
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D3
	.short 0x00A9
	.short 0x00DF
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E1
	.short 0x00A9
	.short 0x00ED
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EF
	.short 0x00A9
	.short 0x00FB
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x00A9
	.short 0x0109
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x010B
	.short 0x00A9
	.short 0x0117
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0021
	.short 0x0093
	.short 0x0021
	.short 0x009A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0022
	.short 0x0093
	.short 0x0022
	.short 0x009A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x009C
	.short 0x00C4
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D0
	.short 0x009C
	.short 0x00D0
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x009D
	.short 0x00D1
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x009C
	.short 0x00D2
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DE
	.short 0x009C
	.short 0x00DE
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DF
	.short 0x009D
	.short 0x00DF
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E0
	.short 0x009C
	.short 0x00E0
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EC
	.short 0x009C
	.short 0x00EC
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00ED
	.short 0x009D
	.short 0x00ED
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x009C
	.short 0x00EE
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FA
	.short 0x009C
	.short 0x00FA
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FB
	.short 0x009D
	.short 0x00FB
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FC
	.short 0x009C
	.short 0x00FC
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0108
	.short 0x009C
	.short 0x0108
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x009D
	.short 0x0109
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010A
	.short 0x009C
	.short 0x010A
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x009C
	.short 0x0116
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0117
	.short 0x009D
	.short 0x0117
	.short 0x00A9
Paint_SoundMode_DeadCopy_DL:
; ; drawn (start operand) by Paint_SoundMode_DeadCopy -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0021
	.short 0x0138
	.short 0x0072
Paint_SoundMode_DL:
; ; drawn (start operand) by Paint_SoundMode -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x008D
	.short 0x00A2
	.short 0x009A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x00A1
	.short 0x00A2
	.short 0x00AE
; DL_Drawbar -- the display list at 0xF2834F.  Its own text records read:
;               "DRAWBAR".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Drawbar:
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x001E
	.short 0x004F
	.short 0x0031
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0550
	.byte 0x10	; character codes below 0x20
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x0552
	.ascii "DRAWBAR"
	.byte 0x0A, 0x0A	; op 0A, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x001E
	.short 0x004C
	.short 0x002E
Paint_Drawbar_DL1:
; ; drawn (start operand) by Paint_Drawbar -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0000
	.short 0x001E
	.short 0x004F
	.short 0x0031
Paint_Drawbar_DL2:
; ; drawn (start operand) by Paint_Drawbar -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x05F1
	.short 0x0002
	.short 0x0009
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0008
	.short 0x0023
	.short 0x004F
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0008
	.short 0x0023
	.short 0x0008
	.short 0x0031
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0021
	.short 0x004F
	.short 0x0031

; === COVER-R1 0xF283A7-0xF28802 ===
; ⚠ AMENDED 2026-09-02 (lane promB5, notes/gen_promB5_spans.py).  Of the 687 B
; this band left `.incbin`, 598 are now typed data -- two bitmaps, eleven
; interpreter-B records and ten operand tables; 44 B more were closed earlier
; by notes/gen_prom_b_dl_shape1_gap_f286f9.py, leaving 45 B at 0xF286CC.
; Round 1 reached each object's FIRST byte through a 32-bit pointer and
; stopped there; the display-list handler that consumes the pointer also
; fixes the object's SIZE, which is what closes them.
; 0xF283A7-0xF28801, coverage round 1: 428 of this span's 1115 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 428 as DATA (only
; a `.long` or a 32-bit immediate names it) in 3 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ==== round-1 header, KEPT VERBATIM and SUPERSEDED below (lane promB5, 2026-09-02) ====
; | ; --------------------------------------------------------------------------
; | ; Data_F283A7 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; | ; Reached from: 0x00F283A7 appears as a 32-bit word at 0xF27C3C 0xF27C48
; | ;               0xF27C54 0xF27C60 0xF27C6C +27 more.  No routine-directory
; | ;               slot and no branch decoded in converted code names it.
; | ; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
; | ;           `reti`, with 0% of the bytes in spellings llvm-mc will not encode.
; | ; ⚠ The extent is the reachability walk's, not the object's; the rest of
; | ;   this span is unreachable and stays `.incbin`.  Why this is data and
; | ;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; | ; --------------------------------------------------------------------------
; | Data_F283A7:
; | 	.byte	0x07	; F283A7  |.|
; ==== end of the superseded round-1 header ====

; ------------------------------------------------------------------
; Data_F283A7 -- the 5 x 30 BITMAP (150 bytes) that 32 interpreter-A
; op-0x03 records draw.  Each carries +2 = this address, +8 = BC = 5
; bytes wide, +0x0A = HL = 30 rows, and `swi 7` fn 3 = draw bitmap;
; 5 x 30 = 150.  All 32 agree on BC and HL.
; Drawn by the records at (the RECORD's own address; the superseded
; header above lists the same sites at +2, where the pointer sits):
;   0xF27C3A 0xF27C46 0xF27C52 0xF27C5E 0xF27C6A 0xF27C76 0xF27C82 0xF27C8E
;   0xF280C1 0xF280CD 0xF280D9 0xF280E5 0xF280F1 0xF280FD 0xF28109 0xF28115
;   0xF2897D 0xF28989 0xF28995 0xF289A1 0xF289AD 0xF289B9 0xF289C5 0xF289D1
;   0xF28E5B 0xF28E67 0xF28E73 0xF28E7F 0xF28E8B 0xF28E97 0xF28EA3 0xF28EAF
; ⚠ SUPERSEDES the round-1 header kept above, which gave this object
;   1 byte and said "the extent is the reachability walk's, not the
;   object's".  The extent IS the object's: the records that name it
;   fix it.  And its "a linear decode runs 1 instructions and ends
;   `reti`" was a decode of picture bytes -- nothing calls or branches
;   into this span, every reference loads the ADDRESS, so it is data.
;   (lane promB5, 2026-09-02, notes/gen_promB5_spans.py)
; Picture, read column-major (byte column c, row r at +c*30+r):
;   .....#############################......
;   ....#.............................#.....
;   ...#...............................#....
;   ..#.................................#...
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..####################################..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ..#.................................##..
;   ...#...............................###..
;   ....#.............................###...
;   .....###############################....
;   ......#############################.....
; ------------------------------------------------------------------
Data_F283A7:
	.byte	0x07, 0x08, 0x10, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x3F	; column 0, rows 0..14
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x10, 0x08, 0x07, 0x03	; column 0, rows 15..29
	.byte	0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF	; column 1, rows 0..14
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; column 1, rows 15..29
	.byte	0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF	; column 2, rows 0..14
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; column 2, rows 15..29
	.byte	0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF	; column 3, rows 0..14
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; column 3, rows 15..29
	.byte	0xC0, 0x20, 0x10, 0x08, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0xFC	; column 4, rows 0..14
	.byte	0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x1C, 0x38, 0xF0, 0xE0	; column 4, rows 15..29


; ==== round-1 header, KEPT VERBATIM and SUPERSEDED below (lane promB5, 2026-09-02) ====
; | ; --------------------------------------------------------------------------
; | ; Data_F2843D -- 1 bytes, EMITTED AS DATA (not promoted to code).
; | ; Reached from: 0x00F2843D appears as a 32-bit word at 0xF27C02 0xF27C0E
; | ;               0xF27C1A 0xF27C26 0xF2808E +12 more.  No routine-directory
; | ;               slot and no branch decoded in converted code names it.
; | ; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
; | ;           `reti`, with 0% of the bytes in spellings llvm-mc will not encode.
; | ; ⚠ The extent is the reachability walk's, not the object's; the rest of
; | ;   this span is unreachable and stays `.incbin`.  Why this is data and
; | ;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; | ; --------------------------------------------------------------------------
; | Data_F2843D:
; | 	.byte	0x07	; F2843D  |.|
; ==== end of the superseded round-1 header ====

; ------------------------------------------------------------------
; Data_F2843D -- the 2 x 9 BITMAP (18 bytes) that 17 interpreter-A
; op-0x03 records draw.  Each carries +2 = this address, +8 = BC = 2
; bytes wide, +0x0A = HL = 9 rows, and `swi 7` fn 3 = draw bitmap;
; 2 x 9 = 18.  All 17 agree on BC and HL.
; Drawn by the records at (the RECORD's own address; the superseded
; header above lists the same sites at +2, where the pointer sits):
;   0xF27C00 0xF27C0C 0xF27C18 0xF27C24 0xF2808C 0xF28098 0xF280A4 0xF280B0
;   0xF2837D 0xF28938 0xF28944 0xF28950 0xF2895C 0xF28E1B 0xF28E27 0xF28E33
;   0xF28E3F
; ⚠ SUPERSEDES the round-1 header kept above, which gave this object
;   1 byte and said "the extent is the reachability walk's, not the
;   object's".  The extent IS the object's: the records that name it
;   fix it.  And its "a linear decode runs 1 instructions and ends
;   `reti`" was a decode of picture bytes -- nothing calls or branches
;   into this span, every reference loads the ADDRESS, so it is data.
;   (lane promB5, 2026-09-02, notes/gen_promB5_spans.py)
; Picture, read column-major (byte column c, row r at +c*9+r):
;   .....#####......
;   ....##...##.....
;   ...##.###.##....
;   ...#.#######....
;   ...#.#######....
;   ...#.#######....
;   ...##.######....
;   ....#######.....
;   .....#####......
; ------------------------------------------------------------------
Data_F2843D:
	.byte	0x07, 0x0C, 0x1B, 0x17, 0x17, 0x17, 0x1B, 0x0F, 0x07	; column 0, rows 0..8
	.byte	0xC0, 0x60, 0xB0, 0xF0, 0xF0, 0xF0, 0xF0, 0xE0, 0xC0	; column 1, rows 0..8

; ------------------------------------------------------------------
; 0xF2844F-0xF284A1 -- 6 interpreter-B display-list records, 83 bytes.
; Every length byte equals its handler's implied length (HTBL_B at
; 0xF31DB1), and the run lands exactly on 0xF284A2.
; ⚠ No `ld XIY / ld XIX / call` site names this run: the committed
; scanner (scripts/analysis/prom_b_display_lists.py) is blind to lists
; entered through DisplayListB_RunOne_Stack (0xF3183D), which takes ONE
; pointer on the stack.  The framing therefore rests on the length rule
; plus BOTH endpoints being proven independently -- it starts where the
; previous object provably ends and lands on an address a pointer names.
; ------------------------------------------------------------------
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0031	; +0x07 -> (0x2530)
	.short 0x00E2	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x0B, 0x0D	; B op 0B, 13 bytes -> handler 0xF31C56 -- decimal readout, signed, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0031	; +0x07 -> (0x2530)
	.short 0x00E2	; +0x09 -> (0x2532)
	.byte 0x02	; +0x0B digit count
	.byte 0x1E	; +0x0C bit 7 set = unsigned, clear = signed
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_DrawScratch+1	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x005A	; +0x0D -> (0x2530)
	.short 0x00E2	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch+2	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0082	; +0x07 -> (0x2530)
	.short 0x00E2	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch+3	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D2	; +0x07 -> (0x2530)
	.short 0x00E2	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_DrawScratch+5	; +0x02 source variable, 16-bit address
	.byte 0x1F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLTable_F284A2	; +0x07 -> XIY: string table
	.short 0x0004	; +0x0B -> BC: bytes per entry
	.short 0x0120	; +0x0D -> (0x2530)
	.short 0x00E2	; +0x0F -> (0x2532)

; ------------------------------------------------------------------
; DLTable_F284A2 -- 32 entries of 4 bytes (128 bytes).
; Referenced by interpreter-B display-list record 0xF28491, whose +7
; pointer lands here and whose handler fixes the entry size.  32
; entries is the EXTENT (128 / 4); the record's (mask >> shift) + 1
; would allow up to 32.
; ------------------------------------------------------------------
DLTable_F284A2:
	.ascii "1-01"	; [0]
	.ascii "1-02"	; [1]
	.ascii "1-03"	; [2]
	.ascii "1-04"	; [3]
	.ascii "1-05"	; [4]
	.ascii "1-06"	; [5]
	.ascii "1-07"	; [6]
	.ascii "1-08"	; [7]
	.ascii "1-09"	; [8]
	.ascii "1-10"	; [9]
	.ascii "1-11"	; [10]
	.ascii "1-12"	; [11]
	.ascii "1-13"	; [12]
	.ascii "1-14"	; [13]
	.ascii "1-15"	; [14]
	.ascii "1-16"	; [15]
	.ascii "2-01"	; [16]
	.ascii "2-02"	; [17]
	.ascii "2-03"	; [18]
	.ascii "2-04"	; [19]
	.ascii "2-05"	; [20]
	.ascii "2-06"	; [21]
	.ascii "2-07"	; [22]
	.ascii "2-08"	; [23]
	.ascii "2-09"	; [24]
	.ascii "2-10"	; [25]
	.ascii "2-11"	; [26]
	.ascii "2-12"	; [27]
	.ascii "2-13"	; [28]
	.ascii "2-14"	; [29]
	.ascii "2-15"	; [30]
	.ascii "2-16"	; [31]

; --------------------------------------------------------------------------
; 0xF28522 -- 426 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ SUPERSEDED 2026-09-02 (lane res3xx): 426 was the reachability walk's
;   extent, and it is 42 bytes TOO LONG.  The record at 0xF28468 that
;   names 0x00F28522 declares 3 bytes per entry and mask 0x7F, i.e. 128
;   entries = 384 bytes, ending at 0xF286A1.  The 42 bytes that used to
;   be tacked on here are a display-list record and its string table and
;   are now framed as such below.  So: 384 bytes, and the `stays
;   `.incbin`` sentence below no longer holds for this span.
; Reached from: 0x00F28522 appears as a 32-bit word at 0xF2846F 0xF29AE5
;               0xF29AF6 0xF29B07 0xF29B18 +4 more.  No routine-directory slot
;               and no branch decoded in converted code names it.
; Measured: 96% printable ASCII; a linear decode runs 155 instructions and
;           ends `reti`, with 5% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_PanL64CtrR63 -- 0xF28522-0xF286A1, 128 entries of 3 bytes, text
;   drawn by LCD_Svc_17_DrawText8x8Packed.  Read by the interpreter-B
;   op-0x07 records at 0xF28468 ((0x2641) AND 0x7F >> 0), 0xF29ADE ((0x76AA)
;   AND 0x7F >> 0), 0xF29AEF ((0x76EA) AND 0x7F >> 0), 0xF29B00 ((0x772A)
;   AND 0x7F >> 0) and 5 more -- value = (byte at the +2 address) AND mask
;   >> shift -- whose +0x07 names this address; DLB_Handler_StringTable2
;   draws entry [value] with +0x0B = 3 as the width.  Entry count: the
;   distance to the object's end over the width; the masks admit 128.
; --------------------------------------------------------------------------
DLText_PanL64CtrR63:
	.ascii	"L64"	; F28522  [0]
	.ascii	"L63"	; F28525  [1]
	.ascii	"L62"	; F28528  [2]
	.ascii	"L61"	; F2852B  [3]
	.ascii	"L60"	; F2852E  [4]
	.ascii	"L59"	; F28531  [5]
	.ascii	"L58"	; F28534  [6]
	.ascii	"L57"	; F28537  [7]
	.ascii	"L56"	; F2853A  [8]
	.ascii	"L55"	; F2853D  [9]
	.ascii	"L54"	; F28540  [10]
	.ascii	"L53"	; F28543  [11]
	.ascii	"L52"	; F28546  [12]
	.ascii	"L51"	; F28549  [13]
	.ascii	"L50"	; F2854C  [14]
	.ascii	"L49"	; F2854F  [15]
	.ascii	"L48"	; F28552  [16]
	.ascii	"L47"	; F28555  [17]
	.ascii	"L46"	; F28558  [18]
	.ascii	"L45"	; F2855B  [19]
	.ascii	"L44"	; F2855E  [20]
	.ascii	"L43"	; F28561  [21]
	.ascii	"L42"	; F28564  [22]
	.ascii	"L41"	; F28567  [23]
	.ascii	"L40"	; F2856A  [24]
	.ascii	"L39"	; F2856D  [25]
	.ascii	"L38"	; F28570  [26]
	.ascii	"L37"	; F28573  [27]
	.ascii	"L36"	; F28576  [28]
	.ascii	"L35"	; F28579  [29]
	.ascii	"L34"	; F2857C  [30]
	.ascii	"L33"	; F2857F  [31]
	.ascii	"L32"	; F28582  [32]
	.ascii	"L31"	; F28585  [33]
	.ascii	"L30"	; F28588  [34]
	.ascii	"L29"	; F2858B  [35]
	.ascii	"L28"	; F2858E  [36]
	.ascii	"L27"	; F28591  [37]
	.ascii	"L26"	; F28594  [38]
	.ascii	"L25"	; F28597  [39]
	.ascii	"L24"	; F2859A  [40]
	.ascii	"L23"	; F2859D  [41]
	.ascii	"L22"	; F285A0  [42]
	.ascii	"L21"	; F285A3  [43]
	.ascii	"L20"	; F285A6  [44]
	.ascii	"L19"	; F285A9  [45]
	.ascii	"L18"	; F285AC  [46]
	.ascii	"L17"	; F285AF  [47]
	.ascii	"L16"	; F285B2  [48]
	.ascii	"L15"	; F285B5  [49]
	.ascii	"L14"	; F285B8  [50]
	.ascii	"L13"	; F285BB  [51]
	.ascii	"L12"	; F285BE  [52]
	.ascii	"L11"	; F285C1  [53]
	.ascii	"L10"	; F285C4  [54]
	.ascii	"L 9"	; F285C7  [55]
	.ascii	"L 8"	; F285CA  [56]
	.ascii	"L 7"	; F285CD  [57]
	.ascii	"L 6"	; F285D0  [58]
	.ascii	"L 5"	; F285D3  [59]
	.ascii	"L 4"	; F285D6  [60]
	.ascii	"L 3"	; F285D9  [61]
	.ascii	"L 2"	; F285DC  [62]
	.ascii	"L 1"	; F285DF  [63]
	.ascii	"CTR"	; F285E2  [64]
	.ascii	"R 1"	; F285E5  [65]
	.ascii	"R 2"	; F285E8  [66]
	.ascii	"R 3"	; F285EB  [67]
	.ascii	"R 4"	; F285EE  [68]
	.ascii	"R 5"	; F285F1  [69]
	.ascii	"R 6"	; F285F4  [70]
	.ascii	"R 7"	; F285F7  [71]
	.ascii	"R 8"	; F285FA  [72]
	.ascii	"R 9"	; F285FD  [73]
	.ascii	"R10"	; F28600  [74]
	.ascii	"R11"	; F28603  [75]
	.ascii	"R12"	; F28606  [76]
	.ascii	"R13"	; F28609  [77]
	.ascii	"R14"	; F2860C  [78]
	.ascii	"R15"	; F2860F  [79]
	.ascii	"R16"	; F28612  [80]
	.ascii	"R17"	; F28615  [81]
	.ascii	"R18"	; F28618  [82]
	.ascii	"R19"	; F2861B  [83]
	.ascii	"R20"	; F2861E  [84]
	.ascii	"R21"	; F28621  [85]
	.ascii	"R22"	; F28624  [86]
	.ascii	"R23"	; F28627  [87]
	.ascii	"R24"	; F2862A  [88]
	.ascii	"R25"	; F2862D  [89]
	.ascii	"R26"	; F28630  [90]
	.ascii	"R27"	; F28633  [91]
	.ascii	"R28"	; F28636  [92]
	.ascii	"R29"	; F28639  [93]
	.ascii	"R30"	; F2863C  [94]
	.ascii	"R31"	; F2863F  [95]
	.ascii	"R32"	; F28642  [96]
	.ascii	"R33"	; F28645  [97]
	.ascii	"R34"	; F28648  [98]
	.ascii	"R35"	; F2864B  [99]
	.ascii	"R36"	; F2864E  [100]
	.ascii	"R37"	; F28651  [101]
	.ascii	"R38"	; F28654  [102]
	.ascii	"R39"	; F28657  [103]
	.ascii	"R40"	; F2865A  [104]
	.ascii	"R41"	; F2865D  [105]
	.ascii	"R42"	; F28660  [106]
	.ascii	"R43"	; F28663  [107]
	.ascii	"R44"	; F28666  [108]
	.ascii	"R45"	; F28669  [109]
	.ascii	"R46"	; F2866C  [110]
	.ascii	"R47"	; F2866F  [111]
	.ascii	"R48"	; F28672  [112]
	.ascii	"R49"	; F28675  [113]
	.ascii	"R50"	; F28678  [114]
	.ascii	"R51"	; F2867B  [115]
	.ascii	"R52"	; F2867E  [116]
	.ascii	"R53"	; F28681  [117]
	.ascii	"R54"	; F28684  [118]
	.ascii	"R55"	; F28687  [119]
	.ascii	"R56"	; F2868A  [120]
	.ascii	"R57"	; F2868D  [121]
	.ascii	"R58"	; F28690  [122]
	.ascii	"R59"	; F28693  [123]
	.ascii	"R60"	; F28696  [124]
	.ascii	"R61"	; F28699  [125]
	.ascii	"R62"	; F2869C  [126]
	.ascii	"R63"	; F2869F  [127]

; ------------------------------------------------------------------
; 0xF286A2-0xF286F8 -- 3 display-list records and their 3 string tables,
; 87 bytes -- interpreter B.  Formerly the last 42 bytes of DLText_PanL64CtrR63
; plus the 45-byte `.incbin` that followed it.
;
; BOTH ENDS ARE FIXED FROM OUTSIDE THE BYTES, not from a stride read off
; them:
;   * LEFT -- the framed opcode-07 record at 0xF28468 carries
;     `.long 0x00F28522`, `BC = 3` (bytes per entry) and mask 0x7F, so the
;     string table it names is 128 x 3 = 384 bytes and ENDS at 0xF286A1.
;   * RIGHT -- ModeScreen_PaintDirtyFields2_DL1 is an established display-list start (prom_a call
;     site 0xF90FBB, notes/prom_b_dl_call_shapes.py).
; In between, each record's own +7 pointer lands on the byte immediately
; after that record, and (mask >> shift) + 1 entries of the +0x0B width
; run exactly up to the next record:
;     0xF286A2 + 17 + 24 + 17 + 6 + 17 + 6 = 0xF286F9, no slack anywhere.
;
; This is the neighbourhood notes/FINDINGS-ui-display-list-interpreter-b.md
; already described as `record, its table, record, its table` while it was
; still `.incbin`.  The layout below is that description, emitted.
; Verify: python3 notes/gen_prom_b_res3xx_spans.py --selftest
; ------------------------------------------------------------------
C0mbinati0nM0de_RepaintPage1Fields_DL:
; ; drawn (start operand) by C0mbinati0nM0de_RepaintPage1Fields -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_DrawScratch+5	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLTable_F286B3	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0123	; +0x0D -> (0x2530)
	.short 0x00E2	; +0x0F -> (0x2532)

; ------------------------------------------------------------------
; DLTable_F286B3 -- 8 entries of 3 bytes (24 bytes).
; Referenced by interpreter-B display-list record 0xF286A2, whose +7
; pointer lands here and whose handler fixes the entry size.  8 entries is both
; the EXTENT (24 / 3) and the record's (mask >> shift) + 1 bound.
; ------------------------------------------------------------------
DLTable_F286B3:
	.ascii "PT1"	; [0]
	.ascii "PT2"	; [1]
	.ascii "PT3"	; [2]
	.ascii "PT4"	; [3]
	.ascii "PT5"	; [4]
	.ascii "PT6"	; [5]
	.ascii "PT7"	; [6]
	.ascii "PT8"	; [7]

DL_F286CB:
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_DrawScratch+4	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLTable_F286DC	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00FA	; +0x0D -> (0x2530)
	.short 0x00E2	; +0x0F -> (0x2532)

; ------------------------------------------------------------------
; DLTable_F286DC -- 2 entries of 3 bytes (6 bytes).
; Referenced by interpreter-B display-list record 0xF286CB, whose +7
; pointer lands here and whose handler fixes the entry size.  2 entries is both
; the EXTENT (6 / 3) and the record's (mask >> shift) + 1 bound.
; ------------------------------------------------------------------
DLTable_F286DC:
	.ascii "ON "	; [0]
	.ascii "OFF"	; [1]

DL_F286E2:
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_DrawScratch+6	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLTable_F286F3	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00AA	; +0x0D -> (0x2530)
	.short 0x00E2	; +0x0F -> (0x2532)

; ------------------------------------------------------------------
; DLTable_F286F3 -- 2 entries of 3 bytes (6 bytes).
; Referenced by interpreter-B display-list record 0xF286E2, whose +7
; pointer lands here and whose handler fixes the entry size.  2 entries is both
; the EXTENT (6 / 3) and the record's (mask >> shift) + 1 bound.
; ------------------------------------------------------------------
DLTable_F286F3:
	.ascii "OFF"	; [0]
	.ascii "ON "	; [1]


; ------------------------------------------------------------------
; 0xF286F9-0xF28724 -- 4 display-list records, 44 bytes -- interpreter A
; the one remaining shape-1 site notes/prom_b_dl_call_shapes.py found
; still `.incbin` (site 0xF90FBB in prom_a).  Regenerate:
; python3 notes/gen_prom_b_dl_shape1_gap_f286f9.py --splice
; ------------------------------------------------------------------
ModeScreen_PaintDirtyFields2_DL1:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x00012640
	.short 0x251B
	.short 0xF287
	.byte 0x00	; operand bytes the handler does not read
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x00012640
	.short 0x351B
	.short 0xF287
	.byte 0x00	; operand bytes the handler does not read
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x00012640
	.short 0x4505
	.short 0xF287
	.byte 0x00	; operand bytes the handler does not read
	.byte 0x03, 0x0B	; op 03, 11 bytes -> handler 0xF31ABE
	.long 0x00012640
	.short 0x5505
	.short 0xF287
	.byte 0x00	; operand bytes the handler does not read


; ------------------------------------------------------------------
; DLTable_F28725 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF286F9, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F28725:
	.short 0x00A7, 0x0084, 0x0111, 0x008F	; [0]
	.short 0x002F, 0x0084, 0x0099, 0x008F	; [1]

; ------------------------------------------------------------------
; DLTable_F28735 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF28704, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F28735:
	.short 0x00A7, 0x0098, 0x0111, 0x00A3	; [0]
	.short 0x002F, 0x0098, 0x0099, 0x00A3	; [1]

; ------------------------------------------------------------------
; DLTable_F28745 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF2870F, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F28745:
	.short 0x002F, 0x0084, 0x0099, 0x008F	; [0]
	.short 0x00A7, 0x0084, 0x0111, 0x008F	; [1]

; ------------------------------------------------------------------
; DLTable_F28755 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF2871A, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F28755:
	.short 0x002F, 0x0098, 0x0099, 0x00A3	; [0]
	.short 0x00A7, 0x0098, 0x0111, 0x00A3	; [1]

; ------------------------------------------------------------------
; 0xF28765-0xF28790 -- 4 interpreter-B display-list records, 44 bytes.
; Every length byte equals its handler's implied length (HTBL_B at
; 0xF31DB1), and the run lands exactly on 0xF28791.
; ⚠ No `ld XIY / ld XIX / call` site names this run: the committed
; scanner (scripts/analysis/prom_b_display_lists.py) is blind to lists
; entered through DisplayListB_RunOne_Stack (0xF3183D), which takes ONE
; pointer on the stack.  The framing therefore rests on the length rule
; plus BOTH endpoints being proven independently -- it starts where the
; previous object provably ends and lands on an address a pointer names.
; ------------------------------------------------------------------
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F28791	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F287A1	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F287B1	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x01	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long ModeScreen_PaintDirtyFields2_DeadCopy_DL	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ------------------------------------------------------------------
; DLTable_F28791 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF28765, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F28791:
	.short 0x0036, 0x008D, 0x00A2, 0x009A	; [0]
	.short 0x002F, 0x0084, 0x0099, 0x008F	; [1]

; ------------------------------------------------------------------
; DLTable_F287A1 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF28770, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F287A1:
	.short 0x0036, 0x00A1, 0x00A2, 0x00AE	; [0]
	.short 0x002F, 0x0084, 0x0099, 0x008F	; [1]

; ------------------------------------------------------------------
; DLTable_F287B1 -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF2877B, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
DLTable_F287B1:
	.short 0x002F, 0x0084, 0x0099, 0x008F	; [0]
	.short 0x0036, 0x008D, 0x00A2, 0x009A	; [1]

; ------------------------------------------------------------------
; ModeScreen_PaintDirtyFields2_DeadCopy_DL -- 2 entries of 8 bytes (16 bytes).
; Referenced by interpreter-B display-list record 0xF28786, whose +7
; pointer lands here and whose handler fixes the entry size.  2
; entries is the EXTENT (16 / 8); the record's (mask >> shift) + 1
; would allow up to 2.
; ------------------------------------------------------------------
ModeScreen_PaintDirtyFields2_DeadCopy_DL:
; drawn (start operand) by ModeScreen_PaintDirtyFields2_DeadCopy -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.short 0x002F, 0x0084, 0x0099, 0x008F	; [0]
	.short 0x0036, 0x00A1, 0x00A2, 0x00AE	; [1]

; ------------------------------------------------------------------
; 0xF287D1-0xF287E1 -- 1 interpreter-B display-list record, 17 bytes.
; Every length byte equals its handler's implied length (HTBL_B at
; 0xF31DB1), and the run lands exactly on 0xF287E2.
; ⚠ No `ld XIY / ld XIX / call` site names this run: the committed
; scanner (scripts/analysis/prom_b_display_lists.py) is blind to lists
; entered through DisplayListB_RunOne_Stack (0xF3183D), which takes ONE
; pointer on the stack.  The framing therefore rests on the length rule
; plus BOTH endpoints being proven independently -- it starts where the
; previous object provably ends and lands on an address a pointer names.
; ------------------------------------------------------------------
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_DrawScratch+7	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLTable_F287E2	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x000D	; +0x0D -> (0x2530)
	.short 0x00E2	; +0x0F -> (0x2532)

; ------------------------------------------------------------------
; DLTable_F287E2 -- 16 entries of 2 bytes (32 bytes).
; Referenced by interpreter-B display-list record 0xF287D1, whose +7
; pointer lands here and whose handler fixes the entry size.  16
; entries is the EXTENT (32 / 2); the record's (mask >> shift) + 1
; would allow up to 128.
; ------------------------------------------------------------------
DLTable_F287E2:
	.ascii "-3"	; [0]
	.ascii "-2"	; [1]
	.ascii "-1"	; [2]
	.ascii " 0"	; [3]
	.ascii "+1"	; [4]
	.ascii "+2"	; [5]
	.ascii "+3"	; [6]
	.ascii " 0"	; [7]
	.ascii " 0"	; [8]
	.ascii " 0"	; [9]
	.ascii " 0"	; [10]
	.ascii " 0"	; [11]
	.ascii " 0"	; [12]
	.ascii " 0"	; [13]
	.ascii " 0"	; [14]
	.ascii " 0"	; [15]

; === END COVER-R1 0xF283A7-0xF28802 ===

; ------------------------------------------------------------------
; 0xF28802-0xF2882A -- 4 display-list records, 41 bytes -- interpreter A (3 records) and B (1)
;   entered at: 0xF28802, 0xF2880C, 0xF28816, 0xF28820
;   ends used:  0xF2880C, 0xF28816, 0xF28820, 0xF2882B
; ------------------------------------------------------------------
ModeScreen_PaintDirtyFields2_DL2:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0030
	.short 0x00B2
	.short 0x007E
	.short 0x00BA
ModeScreen_PaintDirtyFields2_DL6:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C1
	.short 0x00B2
	.short 0x010F
	.short 0x00BA
ModeScreen_PaintDirtyFields2_DL10:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00C6
	.short 0x009E
	.short 0x0114
	.short 0x00A6
ModeScreen_PaintDirtyFields2_DL3:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLBoxes_F2882B	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF2882B-0xF2885B ===
; 0xF2882B-0xF2885A, coverage round 1: 48 of this span's 48 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 48 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF2882B-0xF2885A -- 48 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F2882B appears as a 32-bit word at 0xF28827.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 25% printable ASCII; a linear decode runs 25 instructions and ends
;           `ld (XDE+0x00),0x00`, with 35% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F2882B -- 0xF2882B-0xF2885A, 6 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF28820 ((0x2640)
;   AND 0x3F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 64.  This address is also
;   the END of a display list: `ld XIY,0xF28820 / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF91004.
; --------------------------------------------------------------------------
DLBoxes_F2882B:
	.short	48, 178, 56, 186	; F2882B  [0]
	.short	62, 178, 70, 186	; F28833  [1]
	.short	76, 178, 84, 186	; F2883B  [2]
	.short	90, 178, 98, 186	; F28843  [3]
	.short	104, 178, 112, 186	; F2884B  [4]
	.short	118, 178, 126, 186	; F28853  [5]

; === END COVER-R1 0xF2882B-0xF2885B ===

; ------------------------------------------------------------------
; 0xF2885B-0xF28865 -- 1 display-list records, 11 bytes -- interpreter B
;   entered at: 0xF2885B
;   ends used:  0xF28866
; ------------------------------------------------------------------
ModeScreen_PaintDirtyFields2_DL7:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F28866	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF28866-0xF28896 ===
; 0xF28866-0xF28895, coverage round 1: 17 of this span's 48 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 17 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F28866 -- 17 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F28866 appears as a 32-bit word at 0xF28862.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 7 instructions and ends
;           `jp P/PL,XDE+0x00`, with 71% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F28866:
	.byte	0xC1, 0x00, 0xB2, 0x00, 0xC9, 0x00, 0xBA, 0x00, 0xCF, 0x00, 0xB2, 0x00, 0xD7, 0x00, 0xBA, 0x00	; F28866  |................|
	.byte	0xDD	; F28876  |.|

; --- 0xF28877-0xF28895, 31 B, converted by lane promB6 (SHORTARR8).
;     declared array base 0xF28866
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0xB2, 0x00, 0xE5, 0x00, 0xBA, 0x00	; F28877  rest of the 8-byte entry at F28876
	.short	0x00EB, 0x00B2, 0x00F3, 0x00BA	; F2887E  entry 3
	.short	0x00F9, 0x00B2, 0x0101, 0x00BA	; F28886  entry 4
	.short	0x0107, 0x00B2, 0x010F, 0x00BA	; F2888E  entry 5

; === END COVER-R1 0xF28866-0xF28896 ===

; ------------------------------------------------------------------
; 0xF28896-0xF288A0 -- 1 display-list records, 11 bytes -- interpreter B
;   entered at: 0xF28896
;   ends used:  0xF288A1
; ------------------------------------------------------------------
ModeScreen_PaintDirtyFields2_DL11:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F288A1	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF288A1-0xF288D1 ===
; 0xF288A1-0xF288D0, coverage round 1: 29 of this span's 48 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 29 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F288A1 -- 29 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F288A1 appears as a 32-bit word at 0xF2889D.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 15 instructions and ends
;           `swi 0`, with 69% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F288A1:
	.byte	0xC6, 0x00, 0x9E, 0x00, 0xCE, 0x00, 0xA6, 0x00, 0xD4, 0x00, 0x9E, 0x00, 0xDC, 0x00, 0xA6, 0x00	; F288A1  |................|
	.byte	0xE2, 0x00, 0x9E, 0x00, 0xEA, 0x00, 0xA6, 0x00, 0xF0, 0x00, 0x9E, 0x00, 0xF8	; F288B1  |.............|

; --- 0xF288BE-0xF288D0, 19 B, converted by lane promB6 (SHORTARR8).
;     declared array base 0xF288A1
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0xA6, 0x00	; F288BE  rest of the 8-byte entry at F288B9
	.short	0x00FE, 0x009E, 0x0106, 0x00A6	; F288C1  entry 4
	.short	0x010C, 0x009E, 0x0114, 0x00A6	; F288C9  entry 5

; === END COVER-R1 0xF288A1-0xF288D1 ===

; ------------------------------------------------------------------
; 0xF288D1-0xF296D5 -- 363 display-list records, 3589 bytes -- interpreter A (357 records) and B (6)
;   entered at: 0xF288D1, 0xF288E0, 0xF288EF, 0xF288FE, 0xF2890D, 0xF2891C, 0xF2892B, 0xF28930, 0xF28938, 0xF28DF3, 0xF28E1B, 0xF29121, 0xF29135, 0xF29672, 0xF2967C, 0xF29686, 0xF296AE, 0xF296B8, 0xF296C2, 0xF296CC
;   ends used:  0xF288E0, 0xF288EF, 0xF288FE, 0xF2890D, 0xF2891C, 0xF2892B, 0xF28930, 0xF28938, 0xF28DF3, 0xF28E1B, 0xF29121, 0xF29135, 0xF29672, 0xF2967C, 0xF29686, 0xF296AE, 0xF296B8, 0xF296C2, 0xF296CC, 0xF296D6
; ------------------------------------------------------------------
ModeScreen_PaintDirtyFields2_DL4:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x17EE	; +0x0D -> IX
ModeScreen_PaintDirtyFields2_DL5:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x14CE	; +0x0D -> IX
ModeScreen_PaintDirtyFields2_DL8:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x17FD	; +0x0D -> IX
ModeScreen_PaintDirtyFields2_DL9:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x14DD	; +0x0D -> IX
ModeScreen_PaintDirtyFields2_DL12:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x197F	; +0x0D -> IX
ModeScreen_PaintDirtyFields2_DL13:
; drawn (start operand) by ModeScreen_PaintDirtyFields2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x000022F0	; +0x07 -> XIY: string table
	.short 0x000D	; +0x0B -> BC: bytes per entry
	.short 0x165F	; +0x0D -> IX
ModeScreen_DrawGmModeGlyph_DL2:
; drawn (start operand) by ModeScreen_DrawGmModeGlyph -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x1E
	.short 0x0DB1
ModeScreen_DrawGmModeGlyph_DL1:
; drawn (start operand) by ModeScreen_DrawGmModeGlyph -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x0DB1
	.short 0x0003
	.short 0x0018
Paint_C0mbinati0nM0dePage1_DL1:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x05F1
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FC9
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0615
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FED
	.short 0x0002
	.short 0x0009
	.byte 0x20, 0x0B	; op 20, 11 bytes -> handler 0xF31A3A
	.short 0x0110
	.ascii "PAGE1/2"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x49
	.short 0x16AA
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x24
	.short 0x16CB
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2080
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2085
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208A
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208F
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2094
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2099
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x209E
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x20A3
	.short 0x0005
	.short 0x001E
	.byte 0x1C, 0x16	; op 1C, 22 bytes -> handler 0xF31A52
	.short 0x0040
	.short 0x0005
	.ascii "C0MBINATI0N M0DE"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x6F
	.short 0x002C
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17C0
	.byte 0x10	; character codes below 0x20
	.byte 0x07, 0x05	; op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E7
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0031
	.short 0x00B3
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x003F
	.short 0x00B3
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x004D
	.short 0x00B3
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x005B
	.short 0x00B3
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0069
	.short 0x00B3
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0077
	.short 0x00B3
	.ascii "6"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00C2
	.short 0x00B3
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00D0
	.short 0x00B3
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00DE
	.short 0x00B3
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00EC
	.short 0x00B3
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x00B3
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0108
	.short 0x00B3
	.ascii "6"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000A
	.short 0x00D4
	.ascii "OCT"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0032
	.short 0x00D4
	.ascii "VOL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x005A
	.short 0x00D4
	.ascii "PAN"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0080
	.short 0x00D4
	.ascii "EFF1"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00A8
	.short 0x00D4
	.ascii "EFF2"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00D2
	.short 0x00D4
	.ascii "REV"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x00D4
	.ascii "INT"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x00D4
	.ascii "PART"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x000A
	.short 0x007D
	.short 0x009C
	.short 0x00C2
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A2
	.short 0x007D
	.short 0x0135
	.short 0x00C2
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0021
	.short 0x0138
	.short 0x0021
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0022
	.short 0x0138
	.short 0x0022
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0071
	.short 0x0138
	.short 0x0071
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0072
	.short 0x0138
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0021
	.short 0x0006
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0021
	.short 0x0007
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0137
	.short 0x0021
	.short 0x0137
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0138
	.short 0x0021
	.short 0x0138
	.short 0x0072
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x0089
	.short 0x002E
	.short 0x0089
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x008A
	.short 0x002E
	.short 0x008A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x0089
	.short 0x001B
	.short 0x0090
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x001C
	.short 0x0089
	.short 0x001C
	.short 0x0090
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0028
	.short 0x009D
	.short 0x002D
	.short 0x009D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0028
	.short 0x009E
	.short 0x002D
	.short 0x009E
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x0089
	.short 0x0122
	.short 0x0089
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x008A
	.short 0x0122
	.short 0x008A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0122
	.short 0x0089
	.short 0x0122
	.short 0x0090
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0123
	.short 0x0089
	.short 0x0123
	.short 0x0090
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009D
	.short 0x0116
	.short 0x009D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x009E
	.short 0x0116
	.short 0x009E
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00B0
	.short 0x003A
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x003C
	.short 0x00B0
	.short 0x0048
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x00B0
	.short 0x0056
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0058
	.short 0x00B0
	.short 0x0064
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0066
	.short 0x00B0
	.short 0x0072
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0074
	.short 0x00B0
	.short 0x0080
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x00B0
	.short 0x00CB
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00B0
	.short 0x00D9
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00DB
	.short 0x00B0
	.short 0x00E7
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E9
	.short 0x00B0
	.short 0x00F5
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F7
	.short 0x00B0
	.short 0x0103
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0105
	.short 0x00B0
	.short 0x0111
	.short 0x00B0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00BC
	.short 0x0081
	.short 0x00BC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x00BC
	.short 0x0112
	.short 0x00BC
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00BD
	.short 0x003B
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x003D
	.short 0x00BD
	.short 0x0049
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x00BD
	.short 0x0057
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0059
	.short 0x00BD
	.short 0x0065
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0067
	.short 0x00BD
	.short 0x0073
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0075
	.short 0x00BD
	.short 0x0081
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C0
	.short 0x00BD
	.short 0x00CC
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x00BD
	.short 0x00DA
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00DC
	.short 0x00BD
	.short 0x00E8
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EA
	.short 0x00BD
	.short 0x00F6
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F8
	.short 0x00BD
	.short 0x0104
	.short 0x00BD
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0106
	.short 0x00BD
	.short 0x0112
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00B0
	.short 0x002E
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003A
	.short 0x00B0
	.short 0x003A
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003B
	.short 0x00B1
	.short 0x003B
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003C
	.short 0x00B0
	.short 0x003C
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0048
	.short 0x00B0
	.short 0x0048
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0049
	.short 0x00B1
	.short 0x0049
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x004A
	.short 0x00B0
	.short 0x004A
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0056
	.short 0x00B0
	.short 0x0056
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00B1
	.short 0x0057
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0058
	.short 0x00B0
	.short 0x0058
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0064
	.short 0x00B0
	.short 0x0064
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0065
	.short 0x00B1
	.short 0x0065
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0066
	.short 0x00B0
	.short 0x0066
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0072
	.short 0x00B0
	.short 0x0072
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0073
	.short 0x00B1
	.short 0x0073
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0074
	.short 0x00B0
	.short 0x0074
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0080
	.short 0x00B0
	.short 0x0080
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0081
	.short 0x00B1
	.short 0x0081
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BF
	.short 0x00B0
	.short 0x00BF
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CB
	.short 0x00B0
	.short 0x00CB
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CC
	.short 0x00B1
	.short 0x00CC
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00B0
	.short 0x00CD
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D9
	.short 0x00B0
	.short 0x00D9
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DA
	.short 0x00B1
	.short 0x00DA
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DB
	.short 0x00B0
	.short 0x00DB
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E7
	.short 0x00B0
	.short 0x00E7
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E8
	.short 0x00B1
	.short 0x00E8
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E9
	.short 0x00B0
	.short 0x00E9
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00B0
	.short 0x00F5
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F6
	.short 0x00B1
	.short 0x00F6
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F7
	.short 0x00B0
	.short 0x00F7
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0103
	.short 0x00B0
	.short 0x0103
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0104
	.short 0x00B1
	.short 0x0104
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0105
	.short 0x00B0
	.short 0x0105
	.short 0x00BC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0111
	.short 0x00B0
	.short 0x0111
	.short 0x00BD
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0112
	.short 0x00B1
	.short 0x0112
	.short 0x00BD
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0009
	.short 0x0024
	.short 0x0135
	.short 0x006F
Paint_C0mbinati0nM0dePage1_DL2:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0083
	.short 0x009A
	.short 0x0090
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x0083
	.short 0x0112
	.short 0x0090
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0097
	.short 0x009A
	.short 0x00A4
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x0097
	.short 0x0112
	.short 0x00A4
Paint_C0mbinati0nM0dePage1_DL3:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x05F1
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FC9
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0615
	.short 0x0002
	.short 0x0009
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F2843D
	.short 0x0FED
	.short 0x0002
	.short 0x0009
	.byte 0x20, 0x0B	; op 20, 11 bytes -> handler 0xF31A3A
	.short 0x0110
	.ascii "PAGE1/2"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x24
	.short 0x183B
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2080
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2085
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208A
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x208F
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2094
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x2099
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x209E
	.short 0x0005
	.short 0x001E
	.byte 0x03, 0x0C	; op 03, 12 bytes -> handler 0xF31ABE
	.long Data_F283A7
	.short 0x20A3
	.short 0x0005
	.short 0x001E
	.byte 0x1C, 0x16	; op 1C, 22 bytes -> handler 0xF31A52
	.short 0x0040
	.short 0x0005
	.ascii "C0MBINATI0N M0DE"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x6F
	.short 0x002C
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00C7
	.short 0x009F
	.ascii "1"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00D5
	.short 0x009F
	.ascii "2"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00E3
	.short 0x009F
	.ascii "3"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00F1
	.short 0x009F
	.ascii "4"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00FF
	.short 0x009F
	.ascii "5"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x010D
	.short 0x009F
	.ascii "6"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000A
	.short 0x00D4
	.ascii "OCT"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0032
	.short 0x00D4
	.ascii "VOL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x005A
	.short 0x00D4
	.ascii "PAN"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0080
	.short 0x00D4
	.ascii "EFF1"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x00A8
	.short 0x00D4
	.ascii "EFF2"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00D2
	.short 0x00D4
	.ascii "REV"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00FA
	.short 0x00D4
	.ascii "INT"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0120
	.short 0x00D4
	.ascii "PART"
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0021
	.short 0x0138
	.short 0x0021
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0022
	.short 0x0138
	.short 0x0022
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0071
	.short 0x0138
	.short 0x0071
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0072
	.short 0x0138
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0021
	.short 0x0006
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0021
	.short 0x0007
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0137
	.short 0x0021
	.short 0x0137
	.short 0x0072
	.byte 0x12, 0x0A	; op 12, 10 bytes -> handler 0xF31A75
	.short 0x0138
	.short 0x0021
	.short 0x0138
	.short 0x0072
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0009
	.short 0x007D
	.short 0x0135
	.short 0x00C2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0021
	.short 0x0093
	.short 0x0036
	.short 0x0093
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0021
	.short 0x0094
	.short 0x0036
	.short 0x0094
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x009C
	.short 0x00D0
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x009C
	.short 0x00DE
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E0
	.short 0x009C
	.short 0x00EC
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x009C
	.short 0x00FA
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FC
	.short 0x009C
	.short 0x0108
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x010A
	.short 0x009C
	.short 0x0116
	.short 0x009C
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00A7
	.short 0x0036
	.short 0x00A7
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00A8
	.short 0x0036
	.short 0x00A8
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x00A8
	.short 0x0117
	.short 0x00A8
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00C5
	.short 0x00A9
	.short 0x00D1
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D3
	.short 0x00A9
	.short 0x00DF
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E1
	.short 0x00A9
	.short 0x00ED
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00EF
	.short 0x00A9
	.short 0x00FB
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x00A9
	.short 0x0109
	.short 0x00A9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x010B
	.short 0x00A9
	.short 0x0117
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0021
	.short 0x0093
	.short 0x0021
	.short 0x009A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0022
	.short 0x0093
	.short 0x0022
	.short 0x009A
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C4
	.short 0x009C
	.short 0x00C4
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D0
	.short 0x009C
	.short 0x00D0
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x009D
	.short 0x00D1
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x009C
	.short 0x00D2
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DE
	.short 0x009C
	.short 0x00DE
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DF
	.short 0x009D
	.short 0x00DF
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E0
	.short 0x009C
	.short 0x00E0
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EC
	.short 0x009C
	.short 0x00EC
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00ED
	.short 0x009D
	.short 0x00ED
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x009C
	.short 0x00EE
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FA
	.short 0x009C
	.short 0x00FA
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FB
	.short 0x009D
	.short 0x00FB
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FC
	.short 0x009C
	.short 0x00FC
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0108
	.short 0x009C
	.short 0x0108
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0109
	.short 0x009D
	.short 0x0109
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010A
	.short 0x009C
	.short 0x010A
	.short 0x00A8
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0116
	.short 0x009C
	.short 0x0116
	.short 0x00A9
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0117
	.short 0x009D
	.short 0x0117
	.short 0x00A9
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0009
	.short 0x0024
	.short 0x0135
	.short 0x006F
Paint_C0mbinati0nM0dePage1_DL4:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x008D
	.short 0x00A2
	.short 0x009A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x00A1
	.short 0x00A2
	.short 0x00AE
; DL_C0mbinati0nM0dePage22Sound -- the display list at 0xF29135.  Its own text
;                                  records read: "C0MBINATI0N M0DE";
;                                  "PAGE2/2"; "SOUND:"; "SOUND"; "SOLO";
;                                  "INT"; "PAN"; "VOL" +8 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_C0mbinati0nM0dePage22Sound:
	.byte 0x1C, 0x16	; op 1C, 22 bytes -> handler 0xF31A52
	.short 0x0040
	.short 0x0005
	.ascii "C0MBINATI0N M0DE"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x6F
	.short 0x002C
	.byte 0x20, 0x0B	; op 20, 11 bytes -> handler 0xF31A3A
	.short 0x0110
	.ascii "PAGE2/2"
	.byte 0x17, 0x0C	; op 17, 12 bytes -> handler 0xF31A52
	.short 0x0077
	.short 0x001B
	.ascii "SOUND:"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0007
	.short 0x0022
	.ascii "SOUND"
	.byte 0x17, 0x0A	; op 17, 10 bytes -> handler 0xF31A52
	.short 0x0121
	.short 0x0022
	.ascii "SOLO"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0024
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013B
	.short 0x0024
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000D
	.short 0x0049
	.ascii "INT"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x004B
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0010
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x003A
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0061
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x008A
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00B2
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x00DA
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0102
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x012A
	.short 0x005D
	.ascii "o"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000D
	.short 0x0070
	.ascii "PAN"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0072
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0099
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000D
	.short 0x009B
	.ascii "VOL"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x000B
	.short 0x00E4
	.ascii "PT1"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0033
	.short 0x00E4
	.ascii "PT2"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x005B
	.short 0x00E4
	.ascii "PT3"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0083
	.short 0x00E4
	.ascii "PT4"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00AB
	.short 0x00E4
	.ascii "PT5"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00D3
	.short 0x00E4
	.ascii "PT6"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x00FB
	.short 0x00E4
	.ascii "PT7"
	.byte 0x17, 0x09	; op 17, 9 bytes -> handler 0xF31A52
	.short 0x0123
	.short 0x00E4
	.ascii "PT8"
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0046
	.short 0x0018
	.short 0x0102
	.short 0x0024
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0020
	.short 0x0026
	.short 0x002A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0120
	.short 0x0020
	.short 0x013A
	.short 0x002A
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x002E
	.short 0x0023
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x002E
	.short 0x004C
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x002E
	.short 0x0073
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x007E
	.short 0x002E
	.short 0x009C
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x002E
	.short 0x00C4
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x002E
	.short 0x00EC
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x00F6
	.short 0x002E
	.short 0x0114
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x002E
	.short 0x013C
	.short 0x0042
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0047
	.short 0x0026
	.short 0x0051
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x006E
	.short 0x0026
	.short 0x0078
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x0099
	.short 0x0026
	.short 0x00A3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0046
	.short 0x0019
	.short 0x0102
	.short 0x0019
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0046
	.short 0x0023
	.short 0x0102
	.short 0x0023
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x0038
	.short 0x0023
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x0038
	.short 0x004C
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x0038
	.short 0x0073
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x007E
	.short 0x0038
	.short 0x009C
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x0038
	.short 0x00C4
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x0038
	.short 0x00EC
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x00F6
	.short 0x0038
	.short 0x0114
	.short 0x0038
	.byte 0x11, 0x0A	; op 11, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x0038
	.short 0x013C
	.short 0x0038
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0055
	.short 0x001A
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x0055
	.short 0x0044
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005D
	.short 0x0055
	.short 0x006B
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0086
	.short 0x0055
	.short 0x0094
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AE
	.short 0x0055
	.short 0x00BC
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D6
	.short 0x0055
	.short 0x00E4
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x0055
	.short 0x010C
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0126
	.short 0x0055
	.short 0x0134
	.short 0x0055
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x005D
	.short 0x001B
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0035
	.short 0x005D
	.short 0x0045
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005C
	.short 0x005D
	.short 0x006C
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0085
	.short 0x005D
	.short 0x0095
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AD
	.short 0x005D
	.short 0x00BD
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D5
	.short 0x005D
	.short 0x00E5
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x005D
	.short 0x010D
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0125
	.short 0x005D
	.short 0x0135
	.short 0x005D
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x0065
	.short 0x001A
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x0065
	.short 0x0044
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005D
	.short 0x0065
	.short 0x006B
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0086
	.short 0x0065
	.short 0x0094
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00AE
	.short 0x0065
	.short 0x00BC
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D6
	.short 0x0065
	.short 0x00E4
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x0065
	.short 0x010C
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0126
	.short 0x0065
	.short 0x0134
	.short 0x0065
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00E1
	.short 0x0022
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00E1
	.short 0x004A
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0056
	.short 0x00E1
	.short 0x0072
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007E
	.short 0x00E1
	.short 0x009A
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00E1
	.short 0x00C2
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x00E1
	.short 0x00EA
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F6
	.short 0x00E1
	.short 0x0112
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x00E1
	.short 0x013A
	.short 0x00E1
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00ED
	.short 0x0022
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00ED
	.short 0x004A
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0056
	.short 0x00ED
	.short 0x0072
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007E
	.short 0x00ED
	.short 0x009A
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00ED
	.short 0x00C2
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x00ED
	.short 0x00EA
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00F6
	.short 0x00ED
	.short 0x0112
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x011E
	.short 0x00ED
	.short 0x013A
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0005
	.short 0x00E2
	.short 0x0005
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x0056
	.short 0x000B
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0013
	.short 0x0057
	.short 0x0013
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x001B
	.short 0x0056
	.short 0x001B
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0023
	.short 0x00E2
	.short 0x0023
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002D
	.short 0x00E2
	.short 0x002D
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0035
	.short 0x0056
	.short 0x0035
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003D
	.short 0x0057
	.short 0x003D
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0042
	.short 0x001B
	.short 0x0042
	.short 0x0022
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0044
	.short 0x001A
	.short 0x0044
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0045
	.short 0x0056
	.short 0x0045
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x004B
	.short 0x00E2
	.short 0x004B
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0055
	.short 0x00E2
	.short 0x0055
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x005C
	.short 0x0056
	.short 0x005C
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0064
	.short 0x0057
	.short 0x0064
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x006C
	.short 0x0056
	.short 0x006C
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0073
	.short 0x00E2
	.short 0x0073
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x007D
	.short 0x00E2
	.short 0x007D
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0085
	.short 0x0056
	.short 0x0085
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x008D
	.short 0x0057
	.short 0x008D
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0095
	.short 0x0056
	.short 0x0095
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009B
	.short 0x00E2
	.short 0x009B
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A5
	.short 0x00E2
	.short 0x00A5
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00AD
	.short 0x0056
	.short 0x00AD
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00B5
	.short 0x0057
	.short 0x00B5
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00BD
	.short 0x0056
	.short 0x00BD
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C3
	.short 0x00E2
	.short 0x00C3
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CD
	.short 0x00E2
	.short 0x00CD
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D5
	.short 0x0056
	.short 0x00D5
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00DD
	.short 0x0057
	.short 0x00DD
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00E5
	.short 0x0056
	.short 0x00E5
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EB
	.short 0x00E2
	.short 0x00EB
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F5
	.short 0x00E2
	.short 0x00F5
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x0056
	.short 0x00FD
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0104
	.short 0x001A
	.short 0x0104
	.short 0x0023
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0105
	.short 0x0057
	.short 0x0105
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0106
	.short 0x001B
	.short 0x0106
	.short 0x0022
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010D
	.short 0x0056
	.short 0x010D
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0113
	.short 0x00E2
	.short 0x0113
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x011D
	.short 0x00E2
	.short 0x011D
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0125
	.short 0x0056
	.short 0x0125
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x012D
	.short 0x0057
	.short 0x012D
	.short 0x005B
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0135
	.short 0x0056
	.short 0x0135
	.short 0x0064
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013B
	.short 0x00E2
	.short 0x013B
	.short 0x00EC
DL_F29672:
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0121
	.short 0x0021
	.short 0x0139
	.short 0x0029
DL_F2967C:
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0121
	.short 0x0021
	.short 0x0139
	.short 0x0029
DL_F29686:
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0021
	.short 0x0025
	.short 0x0029
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0048
	.short 0x0025
	.short 0x0050
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x006F
	.short 0x0025
	.short 0x0077
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x009A
	.short 0x0025
	.short 0x00A2
C0mbinati0nM0de_HighlightSoundRow_DL:
; ; drawn (start operand) by C0mbinati0nM0de_HighlightSoundRow -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0021
	.short 0x0025
	.short 0x0029
C0mbinati0nM0de_HighlightIntRow_DL:
; ; drawn (start operand) by C0mbinati0nM0de_HighlightIntRow -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x0048
	.short 0x0025
	.short 0x0050
C0mbinati0nM0de_HighlightPanRow_DL:
; ; drawn (start operand) by C0mbinati0nM0de_HighlightPanRow -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x006F
	.short 0x0025
	.short 0x0077
DL_F296CC:
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x009A
	.short 0x0025
	.short 0x00A2

; --- 0xF296D6-0xF29764: CONVERTED 2026-09-02, lane promB5 (notes/gen_promB5_spans.py) ---

; ------------------------------------------------------------------
; 0xF296D6-0xF296E6 -- 1 interpreter-B display-list record, 17 bytes.
; Every length byte equals its handler's implied length (HTBL_B at
; 0xF31DB1), and the run lands exactly on 0xF296E7.
; ⚠ No `ld XIY / ld XIX / call` site names this run: the committed
; scanner (scripts/analysis/prom_b_display_lists.py) is blind to lists
; entered through DisplayListB_RunOne_Stack (0xF3183D), which takes ONE
; pointer on the stack.  The framing therefore rests on the length rule
; plus BOTH endpoints being proven independently -- it starts where the
; previous object provably ends and lands on an address a pointer names.
; ------------------------------------------------------------------
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short UI_PartIndex	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLTable_F296E7	; +0x07 -> XIY: string table
	.short 0x0005	; +0x0B -> BC: bytes per entry
	.short 0x004D	; +0x0D -> (0x2530)
	.short 0x001B	; +0x0F -> (0x2532)

; ------------------------------------------------------------------
; DLTable_F296E7 -- 8 entries of 5 bytes (40 bytes).
; Referenced by interpreter-B display-list record 0xF296D6, whose +7
; pointer lands here and whose handler fixes the entry size.  8
; entries is the EXTENT (40 / 5); the record's (mask >> shift) + 1
; would allow up to 8.
; ------------------------------------------------------------------
DLTable_F296E7:
	.ascii "PART1"	; [0]
	.ascii "PART2"	; [1]
	.ascii "PART3"	; [2]
	.ascii "PART4"	; [3]
	.ascii "PART5"	; [4]
	.ascii "PART6"	; [5]
	.ascii "PART7"	; [6]
	.ascii "PART8"	; [7]

; ------------------------------------------------------------------
; 0xF2970F-0xF29724 -- 2 interpreter-B display-list records, 22 bytes.
; Every length byte equals its handler's implied length (HTBL_B at
; 0xF31DB1), and the run lands exactly on 0xF29725.
; ⚠ No `ld XIY / ld XIX / call` site names this run: the committed
; scanner (scripts/analysis/prom_b_display_lists.py) is blind to lists
; entered through DisplayListB_RunOne_Stack (0xF3183D), which takes ONE
; pointer on the stack.  The framing therefore rests on the length rule
; plus BOTH endpoints being proven independently -- it starts where the
; previous object provably ends and lands on an address a pointer names.
; ------------------------------------------------------------------
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short CombinationMode_ShownPart	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F29725	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_PartIndex	; +0x02 source variable, 16-bit address
	.byte 0x07	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F29725	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ------------------------------------------------------------------
; DLTable_F29725 -- 8 entries of 8 bytes (64 bytes).
; Referenced by interpreter-B display-list records 0xF2970F 0xF2971A, whose +7
; pointer lands here and whose handler fixes the entry size.  8
; entries is the EXTENT (64 / 8); the record's (mask >> shift) + 1
; would allow up to 8.
; ------------------------------------------------------------------
DLTable_F29725:
	.short 0x0006, 0x00E2, 0x0022, 0x00EC	; [0]
	.short 0x002E, 0x00E2, 0x004A, 0x00EC	; [1]
	.short 0x0056, 0x00E2, 0x0072, 0x00EC	; [2]
	.short 0x007E, 0x00E2, 0x009A, 0x00EC	; [3]
	.short 0x00A6, 0x00E2, 0x00C2, 0x00EC	; [4]
	.short 0x00CE, 0x00E2, 0x00EA, 0x00EC	; [5]
	.short 0x00F6, 0x00E2, 0x0112, 0x00EC	; [6]
	.short 0x011E, 0x00E2, 0x013A, 0x00EC	; [7]

; ------------------------------------------------------------------
; 0xF29765-0xF2979F -- 4 display-list records, 59 bytes -- interpreter B
;   entered at: 0xF29765, 0xF29783
;   ends used:  0xF29783, 0xF297A0
; ------------------------------------------------------------------
DL_F29765:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0F6D	; +0x0D -> IX
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+2	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x00002661	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0F71	; +0x0D -> IX
Paint_C0mbinati0nM0dePage2Sound1_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x76DF	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x000C	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x000C	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count

; === COVER-R1 0xF297A0-0xF29863 ===
; 0xF297A0-0xF29862, coverage round 1: 195 of this span's 195 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 195 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF297A0-0xF29862 -- 195 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F297A0 appears as a 32-bit word at 0xF2976C 0xF2978A
;               0xF2986A 0xF29887 0xF298A4 +4 more.  No routine-directory slot
;               and no branch decoded in converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 91 instructions and
;           ends `ld W,0x20`, with 2% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_PartCodes -- 0xF297A0-0xF29862, 65 entries of 3 bytes, text drawn
;   by LCD_Svc_06_DrawText8x14 / LCD_Svc_17_DrawText8x8Packed.  Read by the
;   interpreter-B op-0x02/0x07 records at 0xF29765 ((0x2640) AND 0xFF >> 0),
;   0xF29783 ((0x76DF) AND 0xFF >> 0), 0xF29863 ((0x771F) AND 0x7F >> 0),
;   0xF29880 ((0x775F) AND 0x7F >> 0) and 5 more -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable/StringTable2 draws entry [value] with +0x0B = 3
;   as the width.  Entry count: the distance to the object's end over the
;   width; the masks admit 256.  This address is also the END of a display
;   list: `ld XIY,0xF29783 / ld XIX,this / call T_DisplayListB_Run` at
;   0xF9193C.
; --------------------------------------------------------------------------
DLText_PartCodes:
	.ascii	"R1-"	; F297A0  [0]
	.ascii	"R2-"	; F297A3  [1]
	.ascii	"   "	; F297A6  [2]
	.ascii	"   "	; F297A9  [3]
	.ascii	"   "	; F297AC  [4]
	.ascii	"   "	; F297AF  [5]
	.ascii	"   "	; F297B2  [6]
	.ascii	"   "	; F297B5  [7]
	.ascii	"U1-"	; F297B8  [8]
	.ascii	"U2-"	; F297BB  [9]
	.ascii	"   "	; F297BE  [10]
	.ascii	"   "	; F297C1  [11]
	.ascii	"   "	; F297C4  [12]
	.ascii	"   "	; F297C7  [13]
	.ascii	"   "	; F297CA  [14]
	.ascii	"   "	; F297CD  [15]
	.ascii	"E1-"	; F297D0  [16]
	.ascii	"   "	; F297D3  [17]
	.ascii	"   "	; F297D6  [18]
	.ascii	"   "	; F297D9  [19]
	.ascii	"   "	; F297DC  [20]
	.ascii	"   "	; F297DF  [21]
	.ascii	"   "	; F297E2  [22]
	.ascii	"   "	; F297E5  [23]
	.ascii	"M1-"	; F297E8  [24]
	.ascii	"M2-"	; F297EB  [25]
	.ascii	"M3-"	; F297EE  [26]
	.ascii	"   "	; F297F1  [27]
	.ascii	"   "	; F297F4  [28]
	.ascii	"   "	; F297F7  [29]
	.ascii	"   "	; F297FA  [30]
	.ascii	"   "	; F297FD  [31]
	.ascii	"RD1"	; F29800  [32]
	.ascii	"RD2"	; F29803  [33]
	.ascii	"   "	; F29806  [34]
	.ascii	"   "	; F29809  [35]
	.ascii	"   "	; F2980C  [36]
	.ascii	"   "	; F2980F  [37]
	.ascii	"   "	; F29812  [38]
	.ascii	"   "	; F29815  [39]
	.ascii	"UD1"	; F29818  [40]
	.ascii	"UD2"	; F2981B  [41]
	.ascii	"   "	; F2981E  [42]
	.ascii	"   "	; F29821  [43]
	.ascii	"   "	; F29824  [44]
	.ascii	"   "	; F29827  [45]
	.ascii	"   "	; F2982A  [46]
	.ascii	"   "	; F2982D  [47]
	.ascii	"ED1"	; F29830  [48]
	.ascii	"   "	; F29833  [49]
	.ascii	"   "	; F29836  [50]
	.ascii	"   "	; F29839  [51]
	.ascii	"   "	; F2983C  [52]
	.ascii	"   "	; F2983F  [53]
	.ascii	"   "	; F29842  [54]
	.ascii	"   "	; F29845  [55]
	.ascii	"   "	; F29848  [56]
	.ascii	"   "	; F2984B  [57]
	.ascii	"   "	; F2984E  [58]
	.ascii	"   "	; F29851  [59]
	.ascii	"   "	; F29854  [60]
	.ascii	"   "	; F29857  [61]
	.ascii	"   "	; F2985A  [62]
	.ascii	"   "	; F2985D  [63]
	.ascii	"   "	; F29860  [64]

; === END COVER-R1 0xF297A0-0xF29863 ===

; ------------------------------------------------------------------
; 0xF29863-0xF29943 -- 16 display-list records, 225 bytes -- interpreter B
;   entered at: 0xF29863, 0xF29880, 0xF2989D, 0xF298BA, 0xF298D7, 0xF298F4, 0xF29911, 0xF2992E
;   ends used:  0xF29880, 0xF2989D, 0xF298BA, 0xF298D7, 0xF298F4, 0xF29911, 0xF2992E, 0xF29944
; ------------------------------------------------------------------
Paint_C0mbinati0nM0dePage2Sound2_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x771F	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0034	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0034	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
Paint_C0mbinati0nM0dePage2Sound3_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound3 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x775F	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x005C	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x005C	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
Paint_C0mbinati0nM0dePage2Sound4_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound4 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x779F	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0084	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0084	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
Paint_C0mbinati0nM0dePage2Sound5_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound5 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x77DF	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00AC	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00AC	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
Paint_C0mbinati0nM0dePage2Sound6_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound6 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x781F	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00D4	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D4	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
Paint_C0mbinati0nM0dePage2Sound7_DL:
; ; drawn (start operand) by Paint_C0mbinati0nM0dePage2Sound7 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x785F	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00FC	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00FC	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart8Sound_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart8Sound -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x789F	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PartCodes	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0124	; +0x0D -> (0x2530)
	.short 0x0030	; +0x0F -> (0x2532)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0124	; +0x07 -> (0x2530)
	.short 0x003A	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart1Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart1Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x76AF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F29944	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x76AF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F29954	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF29944-0xF29963 -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F29944 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF2992E
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29944:
	.short 0x000C, 0x005E, 0x001A, 0x0064	; [0]
	.short 0x000C, 0x0056, 0x001A, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F29954 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29939
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29954:
	.short 0x000C, 0x0056, 0x001A, 0x005C	; [0]
	.short 0x000C, 0x005E, 0x001A, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF29964-0xF29979 -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF29964
;   ends used:  0xF2997A
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart2Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart2Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x76EF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F2997A	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x76EF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F2998A	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF2997A-0xF29999 -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F2997A -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29964
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F2997A:
	.short 0x0036, 0x005E, 0x0044, 0x0064	; [0]
	.short 0x0036, 0x0056, 0x0044, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F2998A -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF2996F
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F2998A:
	.short 0x0036, 0x0056, 0x0044, 0x005C	; [0]
	.short 0x0036, 0x005E, 0x0044, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF2999A-0xF299AF -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF2999A
;   ends used:  0xF299B0
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart3Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart3Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x772F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F299B0	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x772F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F299C0	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF299B0-0xF299CF -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F299B0 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF2999A
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F299B0:
	.short 0x005D, 0x005E, 0x006B, 0x0064	; [0]
	.short 0x005D, 0x0056, 0x006B, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F299C0 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF299A5
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F299C0:
	.short 0x005D, 0x0056, 0x006B, 0x005C	; [0]
	.short 0x005D, 0x005E, 0x006B, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF299D0-0xF299E5 -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF299D0
;   ends used:  0xF299E6
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart4Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart4Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x776F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F299E6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x776F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F299F6	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF299E6-0xF29A05 -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F299E6 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF299D0
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F299E6:
	.short 0x0086, 0x005E, 0x0094, 0x0064	; [0]
	.short 0x0086, 0x0056, 0x0094, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F299F6 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF299DB
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F299F6:
	.short 0x0086, 0x0056, 0x0094, 0x005C	; [0]
	.short 0x0086, 0x005E, 0x0094, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF29A06-0xF29A1B -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF29A06
;   ends used:  0xF29A1C
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart5Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart5Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x77AF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F29A1C	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x77AF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F29A2C	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF29A1C-0xF29A3B -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F29A1C -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29A06
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29A1C:
	.short 0x00AE, 0x005E, 0x00BC, 0x0064	; [0]
	.short 0x00AE, 0x0056, 0x00BC, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F29A2C -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29A11
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29A2C:
	.short 0x00AE, 0x0056, 0x00BC, 0x005C	; [0]
	.short 0x00AE, 0x005E, 0x00BC, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF29A3C-0xF29A51 -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF29A3C
;   ends used:  0xF29A52
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart6Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart6Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x77EF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F29A52	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x77EF	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F29A62	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF29A52-0xF29A71 -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F29A52 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29A3C
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29A52:
	.short 0x00D6, 0x005E, 0x00E4, 0x0064	; [0]
	.short 0x00D6, 0x0056, 0x00E4, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F29A62 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29A47
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29A62:
	.short 0x00D6, 0x0056, 0x00E4, 0x005C	; [0]
	.short 0x00D6, 0x005E, 0x00E4, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF29A72-0xF29A87 -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF29A72
;   ends used:  0xF29A88
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart7Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart7Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x782F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F29A88	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x782F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F29A98	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF29A88-0xF29AA7 -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F29A88 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29A72
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29A88:
	.short 0x00FE, 0x005E, 0x010C, 0x0064	; [0]
	.short 0x00FE, 0x0056, 0x010C, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F29A98 -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29A7D
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29A98:
	.short 0x00FE, 0x0056, 0x010C, 0x005C	; [0]
	.short 0x00FE, 0x005E, 0x010C, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF29AA8-0xF29ABD -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF29AA8
;   ends used:  0xF29ABE
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart8Int_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart8Int -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x786F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F29ABE	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x786F	; +0x02 source variable, 16-bit address
	.byte 0x20	; +0x04 AND mask
	.byte 0x05	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F29ACE	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ==================================================================
; 0xF29ABE-0xF29ADD -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F29ABE -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29AA8
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29ABE:
	.short 0x0126, 0x005E, 0x0134, 0x0064	; [0]
	.short 0x0126, 0x0056, 0x0134, 0x005C	; [1]
; ------------------------------------------------------------------
; DLTable_F29ACE -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF29AB3
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F29ACE:
	.short 0x0126, 0x0056, 0x0134, 0x005C	; [0]
	.short 0x0126, 0x005E, 0x0134, 0x0064	; [1]

; ------------------------------------------------------------------
; 0xF29ADE-0xF29BC5 -- 16 display-list records, 232 bytes -- interpreter B
;   entered at: 0xF29ADE, 0xF29AEF, 0xF29B00, 0xF29B11, 0xF29B22, 0xF29B33, 0xF29B44, 0xF29B55, 0xF29B66, 0xF29B72, 0xF29B7E, 0xF29B8A, 0xF29B96, 0xF29BA2, 0xF29BAE, 0xF29BBA
;   ends used:  0xF29AEF, 0xF29B00, 0xF29B11, 0xF29B22, 0xF29B33, 0xF29B44, 0xF29B55, 0xF29B66, 0xF29B72, 0xF29B7E, 0xF29B8A, 0xF29B96, 0xF29BA2, 0xF29BAE, 0xF29BBA, 0xF29BC6
; ------------------------------------------------------------------
C0mbinati0nM0de_DrawPart1Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart1Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x76AA	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x000A	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart2Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart2Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x76EA	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0032	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart3Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart3Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x772A	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x005A	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart4Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart4Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x776A	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0082	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart5Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart5Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x77AA	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00AA	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart6Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart6Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x77EA	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00D2	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart7Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart7Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x782A	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x00FA	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart8Pan_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart8Pan -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x07, 0x11	; B op 07, 17 bytes -> handler 0xF31B39 -- string-table readout with two extra words
	.short 0x786A	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.long DLText_PanL64CtrR63	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x0122	; +0x0D -> (0x2530)
	.short 0x007B	; +0x0F -> (0x2532)
C0mbinati0nM0de_DrawPart1Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart1Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x76A5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x000A	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart2Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart2Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x76E5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0032	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart3Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart3Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x7725	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x005A	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart4Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart4Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x7765	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0082	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart5Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart5Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x77A5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00AA	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart6Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart6Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x77E5	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00D2	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart7Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart7Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x7825	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x00FA	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count
C0mbinati0nM0de_DrawPart8Vol_DL:
; ; drawn (start operand) by C0mbinati0nM0de_DrawPart8Vol -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x09, 0x0C	; B op 09, 12 bytes -> handler 0xF31C14 -- decimal readout, unsigned, two extra words
	.short 0x7865	; +0x02 source variable, 16-bit address
	.byte 0x7F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x17	; +0x06 swi 7 function
	.short 0x0122	; +0x07 -> (0x2530)
	.short 0x00A7	; +0x09 -> (0x2532)
	.byte 0x03	; +0x0B digit count

; --- 0xF29BC6-0xF2ADD1: not converted ---
; --- 0xF29BC6-0xF29C09: 17-entry pointer table, 4 bytes/entry, stride 0xE6 ---
; entry i = 0xF29C0A + i*0xE6; each names the record at PART 2 below.
	.long BITMAP_ICON_F29BC6_0	; -> record 0
	.long BITMAP_ICON_F29BC6_1	; -> record 1
	.long BITMAP_ICON_F29BC6_2	; -> record 2
	.long BITMAP_ICON_F29BC6_3	; -> record 3
	.long BITMAP_ICON_F29BC6_4	; -> record 4
	.long BITMAP_ICON_F29BC6_5	; -> record 5
	.long BITMAP_ICON_F29BC6_6	; -> record 6
	.long BITMAP_ICON_F29BC6_7	; -> record 7
	.long BITMAP_ICON_F29BC6_8	; -> record 8
	.long BITMAP_ICON_F29BC6_9	; -> record 9
	.long BITMAP_ICON_F29BC6_10	; -> record 10
	.long BITMAP_ICON_F29BC6_11	; -> record 11
	.long BITMAP_ICON_F29BC6_12	; -> record 12
	.long BITMAP_ICON_F29BC6_13	; -> record 13
	.long BITMAP_ICON_F29BC6_14	; -> record 14
	.long BITMAP_ICON_F29BC6_15	; -> record 15
	.long BITMAP_ICON_F29BC6_16	; -> record 16

; --- 0xF29C0A-0xF2AB4F: 17 x 0xE6-byte records -- a 17-frame, 24x46px
; 1bpp bitmap animation (frame 0 blank, frame 16 fully drawn).  Each
; record: 1 flag byte, 45 zero bytes, 46 rows x 3 bytes (MSB-first),
; 46 zero bytes.  See --show-bitmaps.  Not named: see module docstring.
BITMAP_ICON_F29BC6_0:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x00, 0x00, 0x00	; row 10
	.byte 0x00, 0x00, 0x00	; row 11
	.byte 0x00, 0x00, 0x00	; row 12
	.byte 0x00, 0x00, 0x00	; row 13
	.byte 0x00, 0x00, 0x00	; row 14
	.byte 0x00, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0x00, 0x00	; row 25
	.byte 0x00, 0x00, 0x00	; row 26
	.byte 0x00, 0x00, 0x00	; row 27
	.byte 0x00, 0x00, 0x00	; row 28
	.byte 0x00, 0x00, 0x00	; row 29
	.byte 0x00, 0x00, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0x00	; row 40
	.byte 0x00, 0x00, 0x00	; row 41
	.byte 0x00, 0x00, 0x00	; row 42
	.byte 0x00, 0x00, 0x00	; row 43
	.byte 0x00, 0x00, 0x00	; row 44
	.byte 0x00, 0x00, 0x00	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_1:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x00, 0x00, 0x00	; row 10
	.byte 0x00, 0x00, 0x00	; row 11
	.byte 0x00, 0x00, 0x00	; row 12
	.byte 0x00, 0x00, 0x00	; row 13
	.byte 0x00, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0x00, 0x00	; row 25
	.byte 0x00, 0x00, 0x00	; row 26
	.byte 0x00, 0x00, 0x00	; row 27
	.byte 0x00, 0x00, 0x00	; row 28
	.byte 0x00, 0x00, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0x00	; row 40
	.byte 0x00, 0x00, 0x00	; row 41
	.byte 0x00, 0x00, 0x00	; row 42
	.byte 0x00, 0x00, 0x00	; row 43
	.byte 0x00, 0x00, 0x00	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_2:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x00, 0x00, 0x00	; row 10
	.byte 0x00, 0x00, 0x00	; row 11
	.byte 0x00, 0x00, 0x00	; row 12
	.byte 0x00, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0x00, 0x00	; row 25
	.byte 0x00, 0x00, 0x00	; row 26
	.byte 0x00, 0x00, 0x00	; row 27
	.byte 0x00, 0x00, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0x00	; row 40
	.byte 0x00, 0x00, 0x00	; row 41
	.byte 0x00, 0x00, 0x00	; row 42
	.byte 0x00, 0x00, 0x00	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_3:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x00, 0x00, 0x00	; row 10
	.byte 0x00, 0x00, 0x00	; row 11
	.byte 0x00, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0x00, 0x00	; row 25
	.byte 0x00, 0x00, 0x00	; row 26
	.byte 0x00, 0x00, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0x00	; row 40
	.byte 0x00, 0x00, 0x00	; row 41
	.byte 0x00, 0x00, 0x00	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_4:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x00, 0x00, 0x00	; row 10
	.byte 0x00, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0x00, 0x00	; row 25
	.byte 0x00, 0x00, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0x00	; row 40
	.byte 0x00, 0x00, 0x00	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_5:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x00, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0x00, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0x00	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_6:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x00, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0x00, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0x00	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_7:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x00, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0x00, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0x00	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_8:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x00, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0x00, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0x00	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_9:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x00, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0x00, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0x00	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_10:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x00, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0x00, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0x00	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_11:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x00, 0x00, 0x00	; row  4
	.byte 0x7F, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0x00, 0x00	; row 19
	.byte 0x00, 0xFF, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0x00	; row 34
	.byte 0x00, 0x00, 0xFC	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_12:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x00, 0x00, 0x00	; row  3
	.byte 0x7F, 0x00, 0x00	; row  4
	.byte 0x7F, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0x00, 0x00	; row 18
	.byte 0x00, 0xFF, 0x00	; row 19
	.byte 0x00, 0xFF, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0x00	; row 33
	.byte 0x00, 0x00, 0xFC	; row 34
	.byte 0x00, 0x00, 0xFC	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_13:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0x00, 0x00, 0x00	; row  2
	.byte 0x7F, 0x00, 0x00	; row  3
	.byte 0x7F, 0x00, 0x00	; row  4
	.byte 0x7F, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0x00, 0x00	; row 17
	.byte 0x00, 0xFF, 0x00	; row 18
	.byte 0x00, 0xFF, 0x00	; row 19
	.byte 0x00, 0xFF, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0x00	; row 32
	.byte 0x00, 0x00, 0xFC	; row 33
	.byte 0x00, 0x00, 0xFC	; row 34
	.byte 0x00, 0x00, 0xFC	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_14:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0x00, 0x00, 0x00	; row  1
	.byte 0xFF, 0x00, 0x00	; row  2
	.byte 0x7F, 0x00, 0x00	; row  3
	.byte 0x7F, 0x00, 0x00	; row  4
	.byte 0x7F, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0x00, 0x00	; row 16
	.byte 0x00, 0xFF, 0x00	; row 17
	.byte 0x00, 0xFF, 0x00	; row 18
	.byte 0x00, 0xFF, 0x00	; row 19
	.byte 0x00, 0xFF, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0x00	; row 31
	.byte 0x00, 0x00, 0xFE	; row 32
	.byte 0x00, 0x00, 0xFC	; row 33
	.byte 0x00, 0x00, 0xFC	; row 34
	.byte 0x00, 0x00, 0xFC	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_15:
	.byte 0x00	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0x00, 0x00, 0x00	; row  0
	.byte 0xFF, 0x00, 0x00	; row  1
	.byte 0xFF, 0x00, 0x00	; row  2
	.byte 0x7F, 0x00, 0x00	; row  3
	.byte 0x7F, 0x00, 0x00	; row  4
	.byte 0x7F, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0x00, 0x00	; row 15
	.byte 0x00, 0xFF, 0x00	; row 16
	.byte 0x00, 0xFF, 0x00	; row 17
	.byte 0x00, 0xFF, 0x00	; row 18
	.byte 0x00, 0xFF, 0x00	; row 19
	.byte 0x00, 0xFF, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0x00	; row 30
	.byte 0x00, 0x00, 0xFE	; row 31
	.byte 0x00, 0x00, 0xFE	; row 32
	.byte 0x00, 0x00, 0xFC	; row 33
	.byte 0x00, 0x00, 0xFC	; row 34
	.byte 0x00, 0x00, 0xFC	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding
BITMAP_ICON_F29BC6_16:
	.byte 0x01	; flag
	.fill 45, 1, 0x00	; header padding
	.byte 0xFF, 0x00, 0x00	; row  0
	.byte 0xFF, 0x00, 0x00	; row  1
	.byte 0xFF, 0x00, 0x00	; row  2
	.byte 0x7F, 0x00, 0x00	; row  3
	.byte 0x7F, 0x00, 0x00	; row  4
	.byte 0x7F, 0x00, 0x00	; row  5
	.byte 0x3F, 0x00, 0x00	; row  6
	.byte 0x3F, 0x00, 0x00	; row  7
	.byte 0x1F, 0x00, 0x00	; row  8
	.byte 0x1F, 0x00, 0x00	; row  9
	.byte 0x0F, 0x00, 0x00	; row 10
	.byte 0x0F, 0x00, 0x00	; row 11
	.byte 0x07, 0x00, 0x00	; row 12
	.byte 0x07, 0x00, 0x00	; row 13
	.byte 0x03, 0x00, 0x00	; row 14
	.byte 0x03, 0xFF, 0x00	; row 15
	.byte 0x00, 0xFF, 0x00	; row 16
	.byte 0x00, 0xFF, 0x00	; row 17
	.byte 0x00, 0xFF, 0x00	; row 18
	.byte 0x00, 0xFF, 0x00	; row 19
	.byte 0x00, 0xFF, 0x00	; row 20
	.byte 0x00, 0xFF, 0x00	; row 21
	.byte 0x00, 0xFF, 0x00	; row 22
	.byte 0x00, 0xFF, 0x00	; row 23
	.byte 0x00, 0xFF, 0x00	; row 24
	.byte 0x00, 0xFF, 0x00	; row 25
	.byte 0x00, 0xFF, 0x00	; row 26
	.byte 0x00, 0xFF, 0x00	; row 27
	.byte 0x00, 0xFF, 0x00	; row 28
	.byte 0x00, 0xFF, 0x00	; row 29
	.byte 0x00, 0xFF, 0xFF	; row 30
	.byte 0x00, 0x00, 0xFE	; row 31
	.byte 0x00, 0x00, 0xFE	; row 32
	.byte 0x00, 0x00, 0xFC	; row 33
	.byte 0x00, 0x00, 0xFC	; row 34
	.byte 0x00, 0x00, 0xFC	; row 35
	.byte 0x00, 0x00, 0xF8	; row 36
	.byte 0x00, 0x00, 0xF8	; row 37
	.byte 0x00, 0x00, 0xF0	; row 38
	.byte 0x00, 0x00, 0xF0	; row 39
	.byte 0x00, 0x00, 0xE0	; row 40
	.byte 0x00, 0x00, 0xE0	; row 41
	.byte 0x00, 0x00, 0xC0	; row 42
	.byte 0x00, 0x00, 0xC0	; row 43
	.byte 0x00, 0x00, 0x80	; row 44
	.byte 0x00, 0x00, 0x80	; row 45
	.fill 46, 1, 0x00	; footer padding

; --- 0xF2AB50-0xF2AC4F: two parallel 32 x 4-byte arrays (top byte always 0).
; Block 1: ramp 0x76A2..0x7EA2 step 0x40, one doubled step (0x80).
; Block 2 = block 1 + 0x20, entry for entry, same doubled step.
; Typed, unnamed -- see module docstring.
	.long 0x000076A2
	.long 0x000076E2
	.long 0x00007722
	.long 0x00007762
	.long 0x000077A2
	.long 0x000077E2
	.long 0x00007822
	.long 0x00007862
	.long 0x000078E2
	.long 0x00007922
	.long 0x00007962
	.long 0x000079A2
	.long 0x000079E2
	.long 0x00007A22
	.long 0x00007A62
	.long 0x00007AA2
	.long 0x00007AE2
	.long 0x00007B22
	.long 0x00007B62
	.long 0x00007BA2
	.long 0x00007BE2
	.long 0x00007C22
	.long 0x00007C62
	.long 0x00007CA2
	.long 0x00007CE2
	.long 0x00007D22
	.long 0x00007D62
	.long 0x00007DA2
	.long 0x00007DE2
	.long 0x00007E22
	.long 0x00007E62
	.long 0x00007EA2
	.long 0x000076C2
	.long 0x00007702
	.long 0x00007742
	.long 0x00007782
	.long 0x000077C2
	.long 0x00007802
	.long 0x00007842
	.long 0x00007882
	.long 0x00007902
	.long 0x00007942
	.long 0x00007982
	.long 0x000079C2
	.long 0x00007A02
	.long 0x00007A42
	.long 0x00007A82
	.long 0x00007AC2
	.long 0x00007B02
	.long 0x00007B42
	.long 0x00007B82
	.long 0x00007BC2
	.long 0x00007C02
	.long 0x00007C42
	.long 0x00007C82
	.long 0x00007CC2
	.long 0x00007D02
	.long 0x00007D42
	.long 0x00007D82
	.long 0x00007DC2
	.long 0x00007E02
	.long 0x00007E42
	.long 0x00007E82
	.long 0x00007EC2

; ------------------------------------------------------------------
; 0xF2AC50-0xF2ADD1 -- 44 display-list records, 386 bytes -- interpreter A
; NOT reached by any known call shape (1/2/3); a plain op/len walk
; from 0xF2AC50 lands with ZERO DRIFT on 0xF2ADD2, where the already-
; converted DL_CombinationGroupMenuReMap1 begins.
; ------------------------------------------------------------------
Draw_CombinationGroupMenuReMap1_DL:
; ; drawn (start operand) by Draw_CombinationGroupMenuReMap1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1C, 0x1C	; op 1C, 28 bytes -> handler 0xF31A52
	.short 0x0035
	.short 0x0005
	.ascii "COMBINATION GROUP MENU"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05A1
	.ascii "1."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05B5
	.ascii "9."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x08C1
	.ascii "2."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x08D4
	.ascii "10."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BE1
	.ascii "3."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0BF4
	.ascii "11."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0F01
	.ascii "4."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0F14
	.ascii "12."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1221
	.ascii "5."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1234
	.ascii "13."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1541
	.ascii "6."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1554
	.ascii "14."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1861
	.ascii "7."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1874
	.ascii "15."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1B81
	.ascii "8."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1B94
	.ascii "16."
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x00C9
	.ascii "USER1"
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0063
	.short 0x00C9
	.ascii "ROM/EXT"
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x2096
	.byte 0x8D	; character codes below 0x20
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x22C6
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x236B
	.ascii "OK"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x25
	.short 0x0003
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0002
	.short 0x001A
	.short 0x013D
	.short 0x00C6
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x001B
	.short 0x013C
	.short 0x00C5
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00D2
	.short 0x0029
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0061
	.short 0x00D2
	.short 0x008F
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00D3
	.short 0x00C6
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00E0
	.short 0x00C6
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00ED
	.short 0x00C6
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00E0
	.short 0x00ED
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00ED
	.short 0x00ED
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00C8
	.short 0x0006
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002A
	.short 0x00C8
	.short 0x002A
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0060
	.short 0x00C8
	.short 0x0060
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0090
	.short 0x00C8
	.short 0x0090
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009E
	.short 0x001A
	.short 0x009E
	.short 0x00C6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00D4
	.short 0x00A8
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00D4
	.short 0x00C7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00E1
	.short 0x00C7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x00E1
	.short 0x00D1
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x00E1
	.short 0x00EE
	.short 0x00EC

; ------------------------------------------------------------------
; 0xF2ADD2-0xF2AF80 -- 48 display-list records, 431 bytes -- interpreter A
;   entered at: 0xF2ADD2
;   ends used:  0xF2AF81
; ------------------------------------------------------------------
; DL_CombinationGroupMenuReMap1 -- the display list at 0xF2ADD2.  Its own text
;                                  records read: "COMBINATION GROUP MENU";
;                                  "RE-MAP1"; "RE-MAP2"; "RE-MAP3"; "OK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_CombinationGroupMenuReMap1:
	.byte 0x1C, 0x1C	; op 1C, 28 bytes -> handler 0xF31A52
	.short 0x0035
	.short 0x0005
	.ascii "COMBINATION GROUP MENU"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05A1
	.ascii "1."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05B5
	.ascii "9."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x08C1
	.ascii "2."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x08D4
	.ascii "10."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BE1
	.ascii "3."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0BF4
	.ascii "11."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0F01
	.ascii "4."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0F14
	.ascii "12."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1221
	.ascii "5."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1234
	.ascii "13."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1541
	.ascii "6."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1554
	.ascii "14."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1861
	.ascii "7."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1874
	.ascii "15."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1B81
	.ascii "8."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1B94
	.ascii "16."
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x00C9
	.ascii "RE-MAP1"
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0041
	.short 0x00C9
	.ascii "RE-MAP2"
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0079
	.short 0x00C9
	.ascii "RE-MAP3"
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x2096
	.byte 0x8D	; character codes below 0x20
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x22C6
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x236B
	.ascii "OK"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x25
	.short 0x0003
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0002
	.short 0x001A
	.short 0x013D
	.short 0x00C6
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x001B
	.short 0x013C
	.short 0x00C5
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00D2
	.short 0x0035
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x003F
	.short 0x00D2
	.short 0x006D
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0077
	.short 0x00D2
	.short 0x00A5
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00D3
	.short 0x00C6
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00E0
	.short 0x00C6
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00ED
	.short 0x00C6
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00E0
	.short 0x00ED
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00ED
	.short 0x00ED
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00C8
	.short 0x0006
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x00C8
	.short 0x0036
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003E
	.short 0x00C8
	.short 0x003E
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x006E
	.short 0x00C8
	.short 0x006E
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0076
	.short 0x00C8
	.short 0x0076
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00C8
	.short 0x00A6
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009E
	.short 0x001A
	.short 0x009E
	.short 0x00C6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00D4
	.short 0x00A8
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00D4
	.short 0x00C7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00E1
	.short 0x00C7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x00E1
	.short 0x00D1
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x00E1
	.short 0x00EE
	.short 0x00EC

; --- 0xF2AF81-0xF2B12F: not converted ---

; ------------------------------------------------------------------
; 0xF2AF81-0xF2B12F -- 50 display-list records, 431 bytes -- interpreter A
; SELF-FRAMING: no call site found for this span, but DL.walk()'s
; op/len walk from 0xF2AF81 lands with ZERO DRIFT exactly on 0xF2B130,
; and every opcode resolves to a documented interpreter-A handler.
; notes/gen_prom_b_selfframing_incbin_module.py
; ------------------------------------------------------------------
Draw_SoundGroupMenuReMap1ReMap2_DL:
; ; drawn (start operand) by Draw_SoundGroupMenuReMap1ReMap2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0055
	.short 0x0005
	.ascii "SOUND"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0097
	.short 0x0005
	.ascii "GROUP"
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x00D9
	.short 0x0005
	.ascii "MENU"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05A1
	.ascii "1."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05B5
	.ascii "9."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x08C1
	.ascii "2."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x08D4
	.ascii "10."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BE1
	.ascii "3."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0BF4
	.ascii "11."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0F01
	.ascii "4."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0F14
	.ascii "12."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1221
	.ascii "5."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1234
	.ascii "13."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1541
	.ascii "6."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1554
	.ascii "14."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1861
	.ascii "7."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1874
	.ascii "15."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1B81
	.ascii "8."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1B94
	.ascii "16."
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x00C9
	.ascii "USER1"
	.byte 0x17, 0x0B	; op 17, 11 bytes -> handler 0xF31A52
	.short 0x0036
	.short 0x00C9
	.ascii "USER2"
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0063
	.short 0x00C9
	.ascii "ROM/EXT"
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x2096
	.byte 0x8D	; character codes below 0x20
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x22C6
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x236B
	.ascii "OK"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x25
	.short 0x0007
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0002
	.short 0x001A
	.short 0x013D
	.short 0x00C6
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x001B
	.short 0x013C
	.short 0x00C5
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00D2
	.short 0x0029
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0034
	.short 0x00D2
	.short 0x0056
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0061
	.short 0x00D2
	.short 0x008F
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00D3
	.short 0x00C6
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00E0
	.short 0x00C6
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00ED
	.short 0x00C6
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00E0
	.short 0x00ED
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00ED
	.short 0x00ED
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00C8
	.short 0x0006
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002A
	.short 0x00C8
	.short 0x002A
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0033
	.short 0x00C8
	.short 0x0033
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00C8
	.short 0x0057
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0060
	.short 0x00C8
	.short 0x0060
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0090
	.short 0x00C8
	.short 0x0090
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009E
	.short 0x001A
	.short 0x009E
	.short 0x00C6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00D4
	.short 0x00A8
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00D4
	.short 0x00C7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00E1
	.short 0x00C7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x00E1
	.short 0x00D1
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x00E1
	.short 0x00EE
	.short 0x00EC

; ------------------------------------------------------------------
; 0xF2B130-0xF2B2E2 -- 50 display-list records, 435 bytes -- interpreter A
;   entered at: 0xF2B130
;   ends used:  0xF2B2E3
; ------------------------------------------------------------------
; DL_SoundGroupMenuReMap1ReMap2 -- the display list at 0xF2B130.  Its own text
;                                  records read: "SOUND"; "GROUP"; "MENU";
;                                  "RE-MAP1"; "RE-MAP2"; "RE-MAP3"; "OK".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SoundGroupMenuReMap1ReMap2:
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0055
	.short 0x0005
	.ascii "SOUND"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0097
	.short 0x0005
	.ascii "GROUP"
	.byte 0x1C, 0x0A	; op 1C, 10 bytes -> handler 0xF31A52
	.short 0x00D9
	.short 0x0005
	.ascii "MENU"
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05A1
	.ascii "1."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x05B5
	.ascii "9."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x08C1
	.ascii "2."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x08D4
	.ascii "10."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0BE1
	.ascii "3."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0BF4
	.ascii "11."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x0F01
	.ascii "4."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x0F14
	.ascii "12."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1221
	.ascii "5."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1234
	.ascii "13."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1541
	.ascii "6."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1554
	.ascii "14."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1861
	.ascii "7."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1874
	.ascii "15."
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x1B81
	.ascii "8."
	.byte 0x06, 0x07	; op 06, 7 bytes -> handler 0xF31A3A
	.short 0x1B94
	.ascii "16."
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0009
	.short 0x00C9
	.ascii "RE-MAP1"
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0041
	.short 0x00C9
	.ascii "RE-MAP2"
	.byte 0x17, 0x0D	; op 17, 13 bytes -> handler 0xF31A52
	.short 0x0079
	.short 0x00C9
	.ascii "RE-MAP3"
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x2096
	.byte 0x8D	; character codes below 0x20
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x22C6
	.byte 0x8E	; character codes below 0x20
	.byte 0x06, 0x06	; op 06, 6 bytes -> handler 0xF31A3A
	.short 0x236B
	.ascii "OK"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x25
	.short 0x0007
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0002
	.short 0x001A
	.short 0x013D
	.short 0x00C6
	.byte 0x09, 0x0A	; op 09, 10 bytes -> handler 0xF31A75
	.short 0x0003
	.short 0x001B
	.short 0x013C
	.short 0x00C5
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00D2
	.short 0x0035
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x003F
	.short 0x00D2
	.short 0x006D
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0077
	.short 0x00D2
	.short 0x00A5
	.short 0x00D2
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00D3
	.short 0x00C6
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00E0
	.short 0x00C6
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A9
	.short 0x00ED
	.short 0x00C6
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00E0
	.short 0x00ED
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00D2
	.short 0x00ED
	.short 0x00ED
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00C8
	.short 0x0006
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0036
	.short 0x00C8
	.short 0x0036
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x003E
	.short 0x00C8
	.short 0x003E
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x006E
	.short 0x00C8
	.short 0x006E
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0076
	.short 0x00C8
	.short 0x0076
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00C8
	.short 0x00A6
	.short 0x00D1
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009E
	.short 0x001A
	.short 0x009E
	.short 0x00C6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00D4
	.short 0x00A8
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E1
	.short 0x00A8
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00D4
	.short 0x00C7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00E1
	.short 0x00C7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00D1
	.short 0x00E1
	.short 0x00D1
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00EE
	.short 0x00E1
	.short 0x00EE
	.short 0x00EC

; --- 0xF2B2E3-0xF2B378: CONVERTED 2026-09-02, lane promB5 (notes/gen_promB5_spans.py) ---

; ------------------------------------------------------------------
; 0xF2B2E3-0xF2B2F8 -- 2 interpreter-B display-list records, 22 bytes.
; Every length byte equals its handler's implied length (HTBL_B at
; 0xF31DB1), and the run lands exactly on 0xF2B2F9.
; ⚠ No `ld XIY / ld XIX / call` site names this run: the committed
; scanner (scripts/analysis/prom_b_display_lists.py) is blind to lists
; entered through DisplayListB_RunOne_Stack (0xF3183D), which takes ONE
; pointer on the stack.  The framing therefore rests on the length rule
; plus BOTH endpoints being proven independently -- it starts where the
; previous object provably ends and lands on an address a pointer names.
; ------------------------------------------------------------------
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x2674	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F2B2F9	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short SoundSel_Bank	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F2B2F9	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; ------------------------------------------------------------------
; DLTable_F2B2F9 -- 16 entries of 8 bytes (128 bytes).
; Referenced by interpreter-B display-list records 0xF2B2E3 0xF2B2EE, whose +7
; pointer lands here and whose handler fixes the entry size.  16
; entries is the EXTENT (128 / 8); the record's (mask >> shift) + 1
; would allow up to 16.
; ------------------------------------------------------------------
DLTable_F2B2F9:
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [0]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [1]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [2]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [3]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [4]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [5]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [6]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [7]
	.short 0x0007, 0x00C7, 0x0029, 0x00D1	; [8]
	.short 0x0034, 0x00C7, 0x0056, 0x00D1	; [9]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [10]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [11]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [12]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [13]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [14]
	.short 0x0061, 0x00C7, 0x008F, 0x00D1	; [15]

; ------------------------------------------------------------------
; 0xF2B379-0xF2B38E -- 2 display-list records, 22 bytes -- interpreter B
;   entered at: 0xF2B379
;   ends used:  0xF2B38F
; ------------------------------------------------------------------
DL_F2B379:
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x2674	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long Data_F2B38F	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short SoundSel_Bank	; +0x02 source variable, 16-bit address
	.byte 0x0F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long Data_F2B38F	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

; === COVER-R1 0xF2B38F-0xF2B574 ===
; 0xF2B38F-0xF2B573, coverage round 1: 147 of this span's 485 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 147 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F2B38F -- 147 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F2B38F appears as a 32-bit word at 0xF2B380 0xF2B38B.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 14% printable ASCII; a linear decode runs 54 instructions and ends
;           `jp 0xd705b7`, with 78% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F2B38F:
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B38F  |w.......w.......|
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B39F  |w.......w.......|
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B3AF  |w.......w.......|
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B3BF  |w.......w.......|
	.byte	0x07, 0x00, 0xC7, 0x00, 0x35, 0x00, 0xD1, 0x00, 0x3F, 0x00, 0xC7, 0x00, 0x6D, 0x00, 0xD1, 0x00	; F2B3CF  |....5...?...m...|
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B3DF  |w.......w.......|
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B3EF  |w.......w.......|
	.byte	0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00, 0x77, 0x00, 0xC7, 0x00, 0xA5, 0x00, 0xD1, 0x00	; F2B3FF  |w.......w.......|
	.byte	0xA3, 0x05, 0xC3, 0x08, 0xE3, 0x0B, 0x03, 0x0F, 0x23, 0x12, 0x43, 0x15, 0x63, 0x18, 0x83, 0x1B	; F2B40F  |........#.C.c...|
	.byte	0xB7, 0x05, 0xD7	; F2B41F  |...|


; ==================================================================
; 0xF2B422-0xF2B573 -- the tail of a word array, three interpreter-B records,
; two operand tables, a pointer table and the five arrays it names (338 bytes)
; ==================================================================
;
;   0xF2B422 +13   the last 13 bytes of the 16-byte word array at 0xF2B41F
;   0xF2B42F +11   B record, op 03       -> 0xF2B445
;   0xF2B43A +11   B record, op 03       -> 0xF2B445
;   0xF2B445 +128  16 x 8-byte entries
;   0xF2B4C5 +11   B record, op 03       -> 0xF2B4D0
;   0xF2B4D0 +64   8 x 8-byte entries
;   0xF2B510 +40   10 x 4-byte pointers  -> the five arrays below
;   0xF2B538 +60   five word arrays of 2, 4, 6, 8 and 10 entries
;
; Evidence:
;   * The three record starts are named by prom_a as single records, not lists:
;     0xF928C3 `ld XIY,0x00F2B42F` / `call 0xF41820`, 0xF928CC
;     `ld XIY,0x00F2B43A` / `call 0xF4181C`, and 0xF933D4 / 0xF93433 / 0xF93E64 /
;     0xF93EC3 `ld XIY,0x00F2B4C5`.  Their +7 longs land on 0xF2B445 and
;     0xF2B4D0, and handler 0xF31B57's `sla 3,HL` makes those 8-byte entries;
;     128 and 64 are whole numbers of them, each running to the next named
;     address.
;   * 0xF2B510: prom_a 0xF934CB and 0xF93EF0 `ld XIZ,0x00F2B510` immediately
;     after `sla 0x02,HL`, then `ld XIZ,(XIZ+HL)` -- 4-byte entries.  All ten
;     hold one of five addresses, and those five tile 0xF2B538-0xF2B573 with no
;     slack, ending exactly on 0xF2B574, a proven interpreter-A list start.
;   * ⚠ THE SPAN OPENS MID-OBJECT.  0xF2B41F-0xF2B42E is eight 16-bit values in
;     arithmetic progression, step 0x320: 0x05B7 0x08D7 0x0BF7 0x0F17 0x1237
;     0x1557 0x1877 0x1B97.  Its first three bytes are the last `.byte` row of
;     Data_F2B38F above, whose own header says its extent is the reachability
;     walk's and not the object's -- this is that seam.  The array is the twin
;     of the one at 0xF2B40F, same eight elements and same 0x320 step, starting
;     0x05A3 instead of 0x05B7.  Only its last 13 bytes can be typed here.
; ==================================================================
	.byte 0x08	; F2B422  high half of 0x08D7, the 2nd element of the array at 0xF2B41F
	.short 0x0BF7, 0x0F17, 0x1237, 0x1557, 0x1877, 0x1B97	; F2B423  elements 3-8, step 0x320

	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x1B	; +0x06 swi 7 function
	.long DLTable_F2B445	; +0x07 -> XIX: array of 8-byte entries, indexed by the value
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short SoundSel_Group	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F2B445	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

DLTable_F2B445:
	.short 0x0004, 0x0022, 0x009D, 0x0032	; [0]
	.short 0x0004, 0x0036, 0x009D, 0x0046	; [1]
	.short 0x0004, 0x004A, 0x009D, 0x005A	; [2]
	.short 0x0004, 0x005E, 0x009D, 0x006E	; [3]
	.short 0x0004, 0x0072, 0x009D, 0x0082	; [4]
	.short 0x0004, 0x0086, 0x009D, 0x0096	; [5]
	.short 0x0004, 0x009A, 0x009D, 0x00AA	; [6]
	.short 0x0004, 0x00AE, 0x009D, 0x00BE	; [7]
	.short 0x009F, 0x0022, 0x013B, 0x0032	; [8]
	.short 0x009F, 0x0036, 0x013B, 0x0046	; [9]
	.short 0x009F, 0x004A, 0x013B, 0x005A	; [10]
	.short 0x009F, 0x005E, 0x013B, 0x006E	; [11]
	.short 0x009F, 0x0072, 0x013B, 0x0082	; [12]
	.short 0x009F, 0x0086, 0x013B, 0x0096	; [13]
	.short 0x009F, 0x009A, 0x013B, 0x00AA	; [14]
	.short 0x009F, 0x00AE, 0x013B, 0x00BE	; [15]

	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short 0x2671	; +0x02 source variable, 16-bit address
	.byte 0xFF	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F2B4D0	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

DLTable_F2B4D0:
	.short 0x000D, 0x0022, 0x009D, 0x0032	; [0]
	.short 0x000D, 0x0049, 0x009D, 0x0059	; [1]
	.short 0x000D, 0x0070, 0x009D, 0x0080	; [2]
	.short 0x000D, 0x0097, 0x009D, 0x00A7	; [3]
	.short 0x009F, 0x0022, 0x0132, 0x0032	; [4]
	.short 0x009F, 0x0049, 0x0132, 0x0059	; [5]
	.short 0x009F, 0x0070, 0x0132, 0x0080	; [6]
	.short 0x009F, 0x0097, 0x0132, 0x00A7	; [7]

; ------------------------------------------------------------------
; DLPtrTable_F2B510 -- 10 entries of 4 bytes
; Evidence: prom_a 0xF934CB / 0xF93EF0 `ld XIZ,0x00F2B510` after
;           `sla 0x02,HL`, then `ld XIZ,(XIZ+HL)`.  The extent ends where
;           its own lowest target begins.
; ------------------------------------------------------------------
DLPtrTable_F2B510:
	.long WordArray_F2B538	; [0]
	.long WordArray_F2B538	; [1]
	.long WordArray_F2B53C	; [2]
	.long WordArray_F2B53C	; [3]
	.long WordArray_F2B544	; [4]
	.long WordArray_F2B544	; [5]
	.long WordArray_F2B550	; [6]
	.long WordArray_F2B550	; [7]
	.long WordArray_F2B560	; [8]
	.long WordArray_F2B560	; [9]

; ------------------------------------------------------------------
; The five arrays DLPtrTable_F2B510 names, 2/4/6/8/10 16-bit values.  Each
; is two halves of n/2: the first half starts 0x05A3 and the second 0x05B5,
; both stepping 0x618, with the last array repeating its final value in each
; half.  They tile 0xF2B538-0xF2B573 exactly.
; ------------------------------------------------------------------
WordArray_F2B538:
	.short 0x05A3, 0x05B5
WordArray_F2B53C:
	.short 0x05A3, 0x0BBB, 0x05B5, 0x0BCD
WordArray_F2B544:
	.short 0x05A3, 0x0BBB, 0x11D3, 0x05B5, 0x0BCD, 0x11E5
WordArray_F2B550:
	.short 0x05A3, 0x0BBB, 0x11D3, 0x17EB, 0x05B5, 0x0BCD, 0x11E5, 0x17FD
WordArray_F2B560:
	.short 0x05A3, 0x0BBB, 0x11D3, 0x17EB, 0x17EB, 0x05B5, 0x0BCD, 0x11E5, 0x17FD, 0x17FD

; === END COVER-R1 0xF2B38F-0xF2B574 ===

; ------------------------------------------------------------------
; 0xF2B574-0xF2B8F8 -- 98 display-list records, 901 bytes -- interpreter A
;   entered at: 0xF2B574, 0xF2B736
;   ends used:  0xF2B736, 0xF2B8F9
; ------------------------------------------------------------------
; DL_GroupSoundDisplayHoldGr0up -- the display list at 0xF2B574.  Its own text
;                                  records read: "GROUP:"; "SOUND"; "DISPLAY";
;                                  "HOLD"; "GR0UP"; "MENU".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_GroupSoundDisplayHoldGr0up:
	.byte 0x17, 0x0C	; op 17, 12 bytes -> handler 0xF31A52
	.short 0x010D
	.short 0x000A
	.ascii "GROUP:"
	.byte 0x1C, 0x0B	; op 1C, 11 bytes -> handler 0xF31A52
	.short 0x0021
	.short 0x0005
	.ascii "SOUND"
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x2190
	.ascii "DISPLAY"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2371
	.ascii "HOLD"
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1EDF
	.ascii "GR0UP"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x227A
	.ascii "MENU"
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0026
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0026
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x004D
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x004D
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0074
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0074
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x009B
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x009B
	.byte 0x11	; character codes below 0x20
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x13
	.short 0x0029
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x2096
	.byte 0x8D	; character codes below 0x20
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x22C6
	.byte 0x8E	; character codes below 0x20
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00D3
	.short 0x00C6
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E0
	.short 0x00C6
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00ED
	.short 0x00C6
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005B
	.short 0x0002
	.short 0x010B
	.short 0x0002
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005B
	.short 0x0015
	.short 0x010B
	.short 0x0015
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001A
	.short 0x0134
	.short 0x001A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001B
	.short 0x0134
	.short 0x001B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00B5
	.short 0x0134
	.short 0x00B5
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00B6
	.short 0x0134
	.short 0x00B6
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x00D3
	.short 0x0139
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x00ED
	.short 0x0139
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001A
	.short 0x000B
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x001A
	.short 0x000C
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x005A
	.short 0x0003
	.short 0x005A
	.short 0x0014
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009E
	.short 0x001A
	.short 0x009E
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x00D4
	.short 0x00FD
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013A
	.short 0x00D4
	.short 0x013A
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010C
	.short 0x0003
	.short 0x010C
	.short 0x0014
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0133
	.short 0x001A
	.short 0x0133
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0134
	.short 0x001A
	.short 0x0134
	.short 0x00B6
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00C9
	.short 0x00B1
	.short 0x00C9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x00C9
	.short 0x00F3
	.short 0x00C9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CF
	.short 0x00D3
	.short 0x00F1
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CF
	.short 0x00ED
	.short 0x00F1
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00C9
	.short 0x00A6
	.short 0x00CE
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A7
	.short 0x00D4
	.short 0x00A7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A7
	.short 0x00E1
	.short 0x00A7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00D4
	.short 0x00C7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00E1
	.short 0x00C7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x00D4
	.short 0x00CE
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F2
	.short 0x00D4
	.short 0x00F2
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F3
	.short 0x00C9
	.short 0x00F3
	.short 0x00CE
; DL_GroupCombiDisplayHoldGr0up -- the display list at 0xF2B736.  Its own text
;                                  records read: "GROUP:"; "COMBI.";
;                                  "DISPLAY"; "HOLD"; "GR0UP"; "MENU".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_GroupCombiDisplayHoldGr0up:
	.byte 0x17, 0x0C	; op 17, 12 bytes -> handler 0xF31A52
	.short 0x010D
	.short 0x000A
	.ascii "GROUP:"
	.byte 0x1C, 0x0C	; op 1C, 12 bytes -> handler 0xF31A52
	.short 0x001C
	.short 0x0005
	.ascii "COMBI."
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0026
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0026
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x004D
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x004D
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x0074
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x0074
	.byte 0x11	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000
	.short 0x009B
	.byte 0x10	; character codes below 0x20
	.byte 0x17, 0x07	; op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A
	.short 0x009B
	.byte 0x11	; character codes below 0x20
	.byte 0x06, 0x0B	; op 06, 11 bytes -> handler 0xF31A3A
	.short 0x2190
	.ascii "DISPLAY"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2371
	.ascii "HOLD"
	.byte 0x23, 0x05	; op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x27
	.short 0x0028
	.byte 0x06, 0x09	; op 06, 9 bytes -> handler 0xF31A3A
	.short 0x1EDF
	.ascii "GR0UP"
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x227A
	.ascii "MENU"
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x2096
	.byte 0x8D	; character codes below 0x20
	.byte 0x08, 0x05	; op 08, 5 bytes -> handler 0xF31A3A
	.short 0x22C6
	.byte 0x8E	; character codes below 0x20
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00D3
	.short 0x00C6
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00E0
	.short 0x00C6
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A8
	.short 0x00ED
	.short 0x00C6
	.short 0x00ED
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005B
	.short 0x0002
	.short 0x010B
	.short 0x0002
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x005B
	.short 0x0015
	.short 0x010B
	.short 0x0015
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001A
	.short 0x0134
	.short 0x001A
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001B
	.short 0x0134
	.short 0x001B
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00B5
	.short 0x0134
	.short 0x00B5
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00B6
	.short 0x0134
	.short 0x00B6
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x00D3
	.short 0x0139
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x00ED
	.short 0x0139
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x001A
	.short 0x000B
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x001A
	.short 0x000C
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x005A
	.short 0x0003
	.short 0x005A
	.short 0x0014
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x009E
	.short 0x001A
	.short 0x009E
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00FD
	.short 0x00D4
	.short 0x00FD
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x013A
	.short 0x00D4
	.short 0x013A
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x010C
	.short 0x0003
	.short 0x010C
	.short 0x0014
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0133
	.short 0x001A
	.short 0x0133
	.short 0x00B6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0134
	.short 0x001A
	.short 0x0134
	.short 0x00B6
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00C9
	.short 0x00B1
	.short 0x00C9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00E4
	.short 0x00C9
	.short 0x00F3
	.short 0x00C9
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CF
	.short 0x00D3
	.short 0x00F1
	.short 0x00D3
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x00CF
	.short 0x00ED
	.short 0x00F1
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A6
	.short 0x00C9
	.short 0x00A6
	.short 0x00CE
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A7
	.short 0x00D4
	.short 0x00A7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A7
	.short 0x00E1
	.short 0x00A7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00D4
	.short 0x00C7
	.short 0x00DF
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00C7
	.short 0x00E1
	.short 0x00C7
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00CE
	.short 0x00D4
	.short 0x00CE
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F2
	.short 0x00D4
	.short 0x00F2
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00F3
	.short 0x00C9
	.short 0x00F3
	.short 0x00CE

; ------------------------------------------------------------------
; 0xF2B8F9-0xF2BA0B -- one interpreter-B string-table-readout record (op 0x02,
; handler 0xF31B21) plus its OWN 65-entry, 4-byte-stride caption table --
; NOT 3 interpreter-A records, which was this lane's own earlier misframe
; (see this generator's docstring). The record's +0x07 field names
; 0xF2B908, the address of the very next byte, and 65 entries of the
; record's own +0x0B stride (4) exactly fill the rest of this span with
; zero remainder: 15 + 65*4 = 275, the whole original span.
; Regenerate: python3 notes/gen_prom_b_f2b8f9_fix_module.py --splice
; ------------------------------------------------------------------
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short SoundSel_Bank	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long DL_GroupCombiDisplayHoldGr0up + 0x1D2	; +0x07 -> XIY: string table
	.short 0x0004	; +0x0B -> BC: bytes per entry
	.short 0x0124	; +0x0D -> IX
; 65 x 4-byte entries, +0x00 of the string table above
	.ascii "R1 :"	; entry 0
	.ascii "R2 :"	; entry 1
	.ascii "   :"	; entry 2
	.ascii "   :"	; entry 3
	.ascii "   :"	; entry 4
	.ascii "   :"	; entry 5
	.ascii "   :"	; entry 6
	.ascii "   :"	; entry 7
	.ascii "U1 :"	; entry 8
	.ascii "U2 :"	; entry 9
	.ascii "   :"	; entry 10
	.ascii "   :"	; entry 11
	.ascii "   :"	; entry 12
	.ascii "   :"	; entry 13
	.ascii "   :"	; entry 14
	.ascii "   :"	; entry 15
	.ascii "E1 :"	; entry 16
	.ascii "   :"	; entry 17
	.ascii "   :"	; entry 18
	.ascii "   :"	; entry 19
	.ascii "   :"	; entry 20
	.ascii "   :"	; entry 21
	.ascii "   :"	; entry 22
	.ascii "   :"	; entry 23
	.ascii "M1 :"	; entry 24
	.ascii "M2 :"	; entry 25
	.ascii "M3 :"	; entry 26
	.ascii "   :"	; entry 27
	.ascii "   :"	; entry 28
	.ascii "   :"	; entry 29
	.ascii "   :"	; entry 30
	.ascii "   :"	; entry 31
	.ascii "RD1:"	; entry 32
	.ascii "RD2:"	; entry 33
	.ascii "   :"	; entry 34
	.ascii "   :"	; entry 35
	.ascii "   :"	; entry 36
	.ascii "   :"	; entry 37
	.ascii "   :"	; entry 38
	.ascii "   :"	; entry 39
	.ascii "UD1:"	; entry 40
	.ascii "UD2:"	; entry 41
	.ascii "   :"	; entry 42
	.ascii "   :"	; entry 43
	.ascii "   :"	; entry 44
	.ascii "   :"	; entry 45
	.ascii "   :"	; entry 46
	.ascii "   :"	; entry 47
	.ascii "ED1:"	; entry 48
	.ascii "   :"	; entry 49
	.ascii "   :"	; entry 50
	.ascii "   :"	; entry 51
	.ascii "   :"	; entry 52
	.ascii "   :"	; entry 53
	.ascii "   :"	; entry 54
	.ascii "   :"	; entry 55
	.ascii "   :"	; entry 56
	.ascii "   :"	; entry 57
	.ascii "   :"	; entry 58
	.ascii "   :"	; entry 59
	.ascii "   :"	; entry 60
	.ascii "   :"	; entry 61
	.ascii "   :"	; entry 62
	.ascii "   :"	; entry 63
	.ascii "   :"	; entry 64

; ------------------------------------------------------------------
; 0xF2BA0C-0xF2BB0C -- 26 display-list records, 257 bytes -- interpreter A (25 records) and B (1)
;   entered at: 0xF2BA0C, 0xF2BA16, 0xF2BA20, 0xF2BA50, 0xF2BA5A, 0xF2BA64, 0xF2BA73, 0xF2BB03
;   ends used:  0xF2BA16, 0xF2BA20, 0xF2BA50, 0xF2BA5A, 0xF2BA64, 0xF2BA73, 0xF2BAD3, 0xF2BB03, 0xF2BB0D
; ------------------------------------------------------------------
DisplayHold_DrawHoldHighlight_DL1:
; ; drawn (start operand) by DisplayHold_DrawHoldHighlight -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x00D4
	.short 0x0139
	.short 0x00EC
DisplayHold_DrawHoldHighlight_DL2:
; ; drawn (start operand) by DisplayHold_DrawHoldHighlight -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x00FE
	.short 0x00D4
	.short 0x0139
	.short 0x00EC
; DL_Drum -- the display list at 0xF2BA20.  Its own text records read: "DRUM".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Drum:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x235B
	.ascii "DRUM"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00E0
	.short 0x0079
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00ED
	.short 0x0079
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0056
	.short 0x00E1
	.short 0x0056
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x007A
	.short 0x00E1
	.short 0x007A
	.short 0x00EC
Paint_Drum_DL1:
; ; drawn (start operand) by Paint_Drum -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00E1
	.short 0x0079
	.short 0x00EC
Paint_Drum_DL2:
; ; drawn (start operand) by Paint_Drum -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0057
	.short 0x00E1
	.short 0x0079
	.short 0x00EC
DL_F2BA64:
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x00002661	; +0x07 -> XIY: string table
	.short 0x0002	; +0x0B -> BC: bytes per entry
	.short 0x0166	; +0x0D -> IX
; DL_Ext1 -- the display list at 0xF2BA73.  Its own text records read: "EXT1".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Ext1:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2351
	.ascii "R0M1"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00E0
	.short 0x0029
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00ED
	.short 0x0029
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00E1
	.short 0x0006
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002A
	.short 0x00E1
	.short 0x002A
	.short 0x00EC
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2360
	.ascii "EXT1"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007F
	.short 0x00E0
	.short 0x00A1
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x007F
	.short 0x00ED
	.short 0x00A1
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x007E
	.short 0x00E1
	.short 0x007E
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x00A2
	.short 0x00E1
	.short 0x00A2
	.short 0x00EC
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2356
	.ascii "R0M2"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00E0
	.short 0x0051
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00ED
	.short 0x0051
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00E1
	.short 0x002E
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0052
	.short 0x00E1
	.short 0x0052
	.short 0x00EC
DL_F2BB03:
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00E0
	.short 0x00A2
	.short 0x00ED


; ==================================================================
; 0xF2BB0D-0xF2BD17 -- one interpreter-B record and the 64-entry operand table
; its own AND mask sizes exactly (523 bytes)
; ==================================================================
;
;   0xF2BB0D +11   B record, op 03, mask 0x3F -> 0xF2BB18
;   0xF2BB18 +512  64 x 8-byte entries
;
; Evidence: prom_a names 0xF2BB0D six times -- 0xF92A06 and 0xF92A36
;           `ld XIY,0x00F2BB0D` / `call 0xF4181C` run it as a single record, and
;           0xF929D1, 0xF929F8, 0xF92A2D, 0xF92A4A use it as the XIX end of the
;           list that starts at the already-converted DL_F2BB03.  Its +7 long is
;           0xF2BB18 and handler 0xF31B57's `sla 3,HL` makes 8-byte entries.
;           The size is EXACT rather than tiled, which is the strong case in
;           notes/prom_b_dl_operand_tables.py: mask 0x3F with shift 0 allows
;           (0x3F >> 0) + 1 = 64 indices, 64 x 8 = 512, and 0xF2BB18 + 512 =
;           0xF2BD18, the first byte of the proven interpreter-A list DL_Usr1.
;           The implied count and the measured extent agree with no slack.
; ==================================================================
	.byte 0x03, 0x0B	; B op 03, 11 bytes -> handler 0xF31B57 -- four words of entry[value] -> (0x2530..0x2536)
	.short SoundSel_Bank	; +0x02 source variable, 16-bit address
	.byte 0x3F	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x05	; +0x06 swi 7 function
	.long DLTable_F2BB18	; +0x07 -> XIX: array of 8-byte entries, indexed by the value

DLTable_F2BB18:
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [0]
	.short 0x002F, 0x00E1, 0x0051, 0x00EC	; [1]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [2]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [3]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [4]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [5]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [6]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [7]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [8]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [9]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [10]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [11]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [12]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [13]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [14]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [15]
	.short 0x007F, 0x00E1, 0x00A1, 0x00EC	; [16]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [17]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [18]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [19]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [20]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [21]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [22]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [23]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [24]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [25]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [26]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [27]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [28]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [29]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [30]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [31]
	.short 0x0057, 0x00E1, 0x0079, 0x00EC	; [32]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [33]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [34]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [35]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [36]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [37]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [38]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [39]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [40]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [41]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [42]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [43]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [44]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [45]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [46]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [47]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [48]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [49]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [50]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [51]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [52]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [53]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [54]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [55]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [56]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [57]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [58]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [59]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [60]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [61]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [62]
	.short 0x0007, 0x00E1, 0x0029, 0x00EC	; [63]

; ------------------------------------------------------------------
; 0xF2BD18-0xF2BE34 -- 30 display-list records, 285 bytes -- interpreter A (28 records) and B (2)
;   entered at: 0xF2BD18, 0xF2BD48, 0xF2BD52, 0xF2BD66, 0xF2BD96, 0xF2BDA0, 0xF2BDB4, 0xF2BDC3, 0xF2BDD2, 0xF2BDF5
;   ends used:  0xF2BD48, 0xF2BD52, 0xF2BD66, 0xF2BD96, 0xF2BDA0, 0xF2BDB4, 0xF2BDC3, 0xF2BDD2, 0xF2BDF5, 0xF2BE35
; ------------------------------------------------------------------
; DL_Usr1 -- the display list at 0xF2BD18.  Its own text records read: "USR1".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Usr1:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2351
	.ascii "USR1"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00E0
	.short 0x0029
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00ED
	.short 0x0029
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0006
	.short 0x00E1
	.short 0x0006
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002A
	.short 0x00E1
	.short 0x002A
	.short 0x00EC
BankLegend_DrawUser_DL3:
; ; drawn (start operand) by BankLegend_DrawUser -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00E1
	.short 0x0029
	.short 0x00EC
BankLegend_DrawUser_DL2:
; ; drawn (start operand) by BankLegend_DrawUser -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x0007
	.short 0x00E1
	.short 0x0029
	.short 0x00EC
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x007F
	.short 0x00E1
	.short 0x00A1
	.short 0x00EC
; DL_Usr2 -- the display list at 0xF2BD66.  Its own text records read: "USR2".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Usr2:
	.byte 0x06, 0x08	; op 06, 8 bytes -> handler 0xF31A3A
	.short 0x2356
	.ascii "USR2"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00E0
	.short 0x0051
	.short 0x00E0
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00ED
	.short 0x0051
	.short 0x00ED
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x002E
	.short 0x00E1
	.short 0x002E
	.short 0x00EC
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x0052
	.short 0x00E1
	.short 0x0052
	.short 0x00EC
BankLegend_DrawUser_DL1:
; ; drawn (start operand) by BankLegend_DrawUser -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0A	; op 05, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00E1
	.short 0x0051
	.short 0x00EC
BankLegend_DrawUser_DL4:
; ; drawn (start operand) by BankLegend_DrawUser -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x002F
	.short 0x00E1
	.short 0x0051
	.short 0x00EC
	.byte 0x1B, 0x0A	; op 1B, 10 bytes -> handler 0xF31A75
	.short 0x007F
	.short 0x00E1
	.short 0x00A1
	.short 0x00EC
GroupCombiDisplayHold_DrawNumberRange_DL2:
; ; drawn (start operand) by GroupCombiDisplayHold_DrawNumberRange -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+2	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x00002661	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1D12	; +0x0D -> IX
GroupCombiDisplayHold_DrawNumberRange_DL1:
; ; drawn (start operand) by GroupCombiDisplayHold_DrawNumberRange -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x02, 0x0F	; B op 02, 15 bytes -> handler 0xF31B21 -- string-table readout: HL = extracted value = entry index
	.short UI_DrawScratch+2	; +0x02 source variable, 16-bit address
	.byte 0x00	; +0x04 AND mask
	.byte 0x00	; +0x05 right shift, low 3 bits
	.byte 0x06	; +0x06 swi 7 function
	.long 0x00002661	; +0x07 -> XIY: string table
	.short 0x0003	; +0x0B -> BC: bytes per entry
	.short 0x1D16	; +0x0D -> IX
GroupCombiDisplayHold_DrawNumberRange_DL3:
; ; drawn (start operand) by GroupCombiDisplayHold_DrawNumberRange -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x06, 0x05	; op 06, 5 bytes -> handler 0xF31A3A
	.short 0x1D15
	.ascii "-"
	.byte 0x01, 0x0A	; op 01, 10 bytes -> handler 0xF31A75
	.short 0x000C
	.short 0x00C6
	.short 0x004C
	.short 0x00C6
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x000B
	.short 0x00B7
	.short 0x000B
	.short 0x00C5
	.byte 0x02, 0x0A	; op 02, 10 bytes -> handler 0xF31A75
	.short 0x004D
	.short 0x00B7
	.short 0x004D
	.short 0x00C5
GroupDisplayHold_ClearNameSlots_DL:
; ; drawn (start operand) by GroupDisplayHold_ClearNameSlots -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x05A3
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x0BBB
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x11D3
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x17EB
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x05B5
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x0BCD
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x11E5
	.short 0x0010
	.short 0x000E
	.byte 0x0E, 0x08	; op 0E, 8 bytes -> handler 0xF31A9F
	.short 0x17FD
	.short 0x0010
	.short 0x000E

; ============================================================================
; 0xF2BE35-0xF317FF -- THE MESSAGE MODULE: the machine's dialogs, in more
;                     than one language, the SERVICE-MODE self-diagnostic
;                     screens, and three RAM defaults
; ============================================================================
;
; 22,987 bytes: 18,694 substantive and 4,293 of 0x0E `ret` padding.
; 802 display-list records in 81 lists, plus 4 single records that are run
; on their own; four string/array operand tables; a 5x30 bitmap; a
; 256-entry screen index and the 127 field lists it points at; 3,712 bytes
; of RAM initialisation image; and 37 bytes of text that only an
; overlapping list reaches.
;
; WHY IT WAS STILL `.incbin` AFTER SEVEN ROUNDS.  The committed scanner
; finds a display list only where a caller spells BOTH ends as immediates
; (`ld XIY,imm32 / ld XIX,imm32 / call`).  These lists are named by a TABLE
; of (start,end) pairs instead, so no immediate in the image holds their
; addresses and no amount of scanning for one would have found them.
;
; THE READER, prom_a 0xF99098 (that image is another lane's; quoted, not
; edited):
;     lda XIX,0x2880 / ld C,(XIX)          C = MESSAGE ID
;     cp C,0x40 / jrl NC,0xF9911C          ids >= 0x40 draw nothing
;     ld A,0x04 / mul WA,(0x7FC1)          (0x7FC1) = LANGUAGE
;     add XWA,0x00F993B9 / ld XWA,(XWA)    -> that language's pair table
;     mul C,0x08 / add XWA,XBC / ld XIY,(XWA)      + id*8  -> list START
;     inc 4,XBC / add XBC,(XIZ-8) / ld XWA,(XBC)           -> list END
;     push XWA / push XIY / call 0xF42E00  -> DisplayList_Run_Stack (A)
;
; The table that call reaches for language 0 is prom_a 0xF99121: 64 entries
; of 8 bytes, 0xF99121-0xF99320, every one of which names a list in THIS
; range and every one of which frames.  A second reader at prom_a 0xF990F1
; indexes prom_a 0xF99321 by 8*(0x7FC1) with no message id at all and calls
; 0xF42E04, DisplayListB_Run_Stack -- which is why two lists here are
; interpreter-B lists among 74 interpreter-A ones.
;
; EXTENTS.  75 (start,end) pairs, kept only when the framing walk from the
; start lands EXACTLY on the end.  Between them the range tiles with no
; hole and nothing unexplained: `python3 notes/prom_b_message_module.py
; --selftest`, 76 checks, 0 failures.
; ============================================================================

; ------------------------------------------------------------------
; 0xF2BE35-0xF2BE3F -- 11 space characters nothing reaches
;   The interpreter-A list before them is 0xF2BDF5-0xF2BE34, named by
;   prom_a 0xF93538 (`ld XIY,0x00F2BDF5 / ld XIX,0x00F2BE35 /
;   call 0xF417F0`), so its walk stops on the first of these bytes.
;   No pointer in any of the four images names any address in this
;   range, and the 0x0E pad starts immediately after.  Emitted as the
;   data it is; what wrote it is NOT established.
; ------------------------------------------------------------------
MsgPad_F2BE35:
	.ascii "           "

; 0xF2BE40-0xF2C7FF -- 2496 bytes of 0x0E `ret` padding
	.fill 2496, 1, 0x0E
