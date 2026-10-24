
; --- 0xFA6000-0xFA6017  entry thunks (24 bytes) ---

; ---------------------------------------------------------------------
; MidiIn_EntryThunks -- the module's six-slot entry table
;
; Read by: prom_b's directory, which holds the BARE pointer 0x00FA6000 at
;          T_MidiIn_EntryThunks (T_F40740) and follows it with the run of live `jp` slots
;          T_MidiIn_PumpPortA (T_F40744)-T_MidiOut_ResyncChangedParts.  Same idiom as MIDI_EntryThunks at 0xFA5400.
; Layout:  slot 0 is `1b ae 83 fa` = `jp MidiIn_ModuleReset`; slots 1-5 are
;          `0e 00 00 00`, i.e. a bare RET followed by three pad bytes.
; ---------------------------------------------------------------------
MidiIn_EntryThunks:
	.byte 0x1b, 0xae, 0x83, 0xfa, 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00   ; FA6000
	.byte 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00   ; FA6010

; ---------------------------------------------------------------------
; MidiIn_PumpPortA -- drain MIDI IN port A and dispatch every message
;
; Called from: prom_b directory slot T_MidiIn_PumpPortA (T_F40744) (`jp 0xFA6018`).
; Inputs:  ring 0x600C1E; (0x60F000) is zeroed on entry and used as a count.
; Outputs: for each message, the 0x1940 staging record is filled and one
;          entry of MidiIn_StatusClassTable is called; on exhaustion
;          0xF40898 runs and (0x2C00 + (0x60F000)) is set to 0xFF.
; Evidence: `ld XIX,0x00600C1E` and the head/tail compare `ld WA,(XIX+0xF6)
;          / cp WA,(XIX+0xFA)` are the ring-scan idiom; 0xF41DBC is
;          Ring600C1E_ScanRewind.  The dispatch index is
;          (status & 0x70) >> 2, so it is the message class 0x8n..0xFn.
; Twin:    MidiIn_PumpPortB is the same 97 bytes with FOUR bytes different
;          (measured, check T1): the ring base and the two thunk slots.
; ---------------------------------------------------------------------
MidiIn_PumpPortA:   ; entry: prom_b directory slot T_MidiIn_PumpPortA (T_F40744)
	call T_MidiInARing_ScanRewind                  ; FA6018  1d bc 1d f4
	ldw (0x60f000:24), 0x00                      ; FA601C  f2 00 f0 60 02 00 00   ld (0x60f000),0x0000
.LFA6023:
	ld XIX,MidiIn_PortARing                             ; FA6023  44 1e 0c 60 00
	ld wa, (xix-10)                               ; FA6028  9c f6 20   ld WA,(XIX+0xf6)
	cp	wa, (xix-6)                           ; FA602B  9c fa f0   cp WA,(XIX+0xfa)
	jr z, .LFA6053                                ; FA602E  66 23
	and	(0x9f:8), 0xfe                        ; FA6030  c0 9f 3c fe   and (0x9f),0xfe
	calr MidiIn_FetchMessage_PortA                                     ; FA6034  1e 63 00   calr 0xfa609a
	ld a, (MidiIn_MsgStatus:16)                            ; FA6037  c1 40 19 21   ld A,(0x1940)
	ld (0x1960:16), a                            ; FA603B  f1 60 19 41   ld (0x1960),A
	and A,0x70                                    ; FA603F  c9 cc 70
	srl a, 0x02                                   ; FA6042  c9 ef 02   srl 0x02,A
	ld XIZ,MidiIn_StatusClassTable                ; FA6045  46 7a 60 fa 00
	ld	xiz, (xiz+a)                          ; FA604A  e3 03 f8 e0 26   ld XIZ,(XIZ+A)
	call (xiz)                                    ; FA604F  b6 e8   call T,XIZ
	jr .LFA6023                                   ; FA6051  68 d0
.LFA6053:
	call T_ParamShadow_FlushAll                                 ; FA6053  1d 98 08 f4
	ld XIX,0x00002c00                             ; FA6057  44 00 2c 00 00
	ld hl, (0x60f000:24)                         ; FA605C  d2 00 f0 60 23   ld HL,(0x60f000)
	ld	(xix+hl), 0xff                        ; FA6061  f3 07 f0 ec 00 ff   ld (XIX+HL),0xff
	ret                                           ; FA6067  0e

; ---------------------------------------------------------------------
; sub_FA6068 -- `call 0xF40004 / 0xF40008 / 0xF4000C / 0xF40010 / ret`
;
; Called from: NOTHING FOUND.  No thunk slot, no pointer-table entry and no
;          call or jp anywhere in prom_a or prom_b names 0xFA6068 -- a
;          searched negative, not an unsearched one.  It is inside a code
;          segment because it sits between MidiIn_PumpPortA's `ret` and the
;          table that follows, and it decodes exactly.
; Notes:   the four targets are Dev7F_WriteSlot8_Slot0..Slot3, four
;          consecutive directory slots.  sub_FA6112 is the same 17 bytes.
; Unknown: what calls it, and why the module carries it twice.
; ---------------------------------------------------------------------
sub_FA6068:
	call T_Dev7F_WriteSlot8_Slot0                 ; FA6068  1d 04 00 f4
	call T_Dev7F_WriteSlot8_Slot1                 ; FA606C  1d 08 00 f4
	call T_Dev7F_WriteSlot8_Slot2                 ; FA6070  1d 0c 00 f4
	call T_Dev7F_WriteSlot8_Slot3                 ; FA6074  1d 10 00 f4
	ret                                           ; FA6078  0e

; --- 0xFA6079-0xFA6079  alignment pad (1 bytes) ---
	.byte 0x00   ; FA6079

; --- 0xFA607A-0xFA6099  pointer table (32 bytes) ---
MidiIn_StatusClassTable:
	.long MidiIn_RouteChannelMessage            ; FA607A  [0]   -> MidiIn_RouteChannelMessage
	.long MidiIn_RouteChannelMessage            ; FA607E  [1]   -> MidiIn_RouteChannelMessage
	.long MidiIn_RouteChannelMessage            ; FA6082  [2]   -> MidiIn_RouteChannelMessage
	.long MidiIn_RouteChannelMessage            ; FA6086  [3]   -> MidiIn_RouteChannelMessage
	.long MidiIn_RouteChannelMessage            ; FA608A  [4]   -> MidiIn_RouteChannelMessage
	.long MidiIn_RouteChannelMessage            ; FA608E  [5]   -> MidiIn_RouteChannelMessage
	.long MidiIn_RouteChannelMessage            ; FA6092  [6]   -> MidiIn_RouteChannelMessage
	.long MidiIn_SystemMessage                  ; FA6096  [7]   -> MidiIn_SystemMessage

; ---------------------------------------------------------------------
; MidiIn_FetchMessage_PortA -- copy one message from ring 0x600C1E to 0x1940
;
; Called from: MidiIn_PumpPortA 0xFA6034 (`calr`), its only caller.
; Outputs: (0x1940) status, (0x1941..) the data bytes, and (0x1943) = 0x00,
;          the PORT TAG.
; Evidence: `ld (XIY+0x03),0x00` at 0xFA60A4 pre-sets (0x1943); the port-B
;          twin writes 0x10 there instead, and MidiIn_RouteChannelMessage
;          ORs that byte into the channel to index a 32-entry map, so the
;          tag is the 0x10 bit that separates the two ports' 16 channels.
;          The copy loop calls 0xF41DC0 (MidiInARing_Scan) and stops when the
;          NEXT byte has bit 7 set, i.e. at the next status byte.
; ---------------------------------------------------------------------
MidiIn_FetchMessage_PortA:   ; entry: call from 0xFA6034
	ld XIZ,MidiIn_PortARing                             ; FA609A  46 1e 0c 60 00
	ld XIY,MidiIn_MsgStatus                             ; FA609F  45 40 19 00 00
	ld (XIY+0x03),0x00                            ; FA60A4  bd 03 00 00
.LFA60A8:
	call T_MidiInARing_Scan                        ; FA60A8  1d c0 1d f4
	ld (xiy+), a                             ; FA60AC  f5 f4 41   ld (XIY+),A
	ld hl, (xiz-10)                               ; FA60AF  9e f6 23   ld HL,(XIZ+0xf6)
	cp	hl, (xiz-6)                           ; FA60B2  9e fa f3   cp HL,(XIZ+0xfa)
	jr z, .LFA60C1                                ; FA60B5  66 0a
	ld	a, (xiz+hl)                           ; FA60B7  c3 07 f8 ec 21   ld A,(XIZ+HL)
	bit 0x07,A                                    ; FA60BC  c9 33 07
	jr z, .LFA60A8                                ; FA60BF  66 e7
.LFA60C1:
	ret                                           ; FA60C1  0e

; ---------------------------------------------------------------------
; MidiIn_PumpPortB -- drain MIDI IN port B and dispatch every message
;
; Called from: prom_b directory slot T_MidiIn_PumpPortB (T_F43358) (`jp 0xFA60C2`).
; Evidence: 97 bytes, of which FOUR differ from MidiIn_PumpPortA (check T1
;          re-derives the count): ring 0x601028 for 0x600C1E, and the
;          Ring601028 veneers 0xF41DE0/0xF41DE4 for 0xF41DBC/0xF41DC0.
; ---------------------------------------------------------------------
MidiIn_PumpPortB:   ; entry: prom_b directory slot T_MidiIn_PumpPortB (T_F43358)
	call T_MidiInBRing_ScanRewind                  ; FA60C2  1d e0 1d f4
	ldw (0x60f000:24), 0x00                      ; FA60C6  f2 00 f0 60 02 00 00   ld (0x60f000),0x0000
.LFA60CD:
	ld XIX,MidiIn_PortBRing                             ; FA60CD  44 28 10 60 00
	ld wa, (xix-10)                               ; FA60D2  9c f6 20   ld WA,(XIX+0xf6)
	cp	wa, (xix-6)                           ; FA60D5  9c fa f0   cp WA,(XIX+0xfa)
	jr z, .LFA60FD                                ; FA60D8  66 23
	and	(0x9f:8), 0xfe                        ; FA60DA  c0 9f 3c fe   and (0x9f),0xfe
	calr .LFA6123                                 ; FA60DE  1e 42 00
	ld a, (MidiIn_MsgStatus:16)                            ; FA60E1  c1 40 19 21   ld A,(0x1940)
	ld (0x1960:16), a                            ; FA60E5  f1 60 19 41   ld (0x1960),A
	and A,0x70                                    ; FA60E9  c9 cc 70
	srl a, 0x02                                   ; FA60EC  c9 ef 02   srl 0x02,A
	ld XIZ,MidiIn_StatusClassTable                ; FA60EF  46 7a 60 fa 00
	ld	xiz, (xiz+a)                          ; FA60F4  e3 03 f8 e0 26   ld XIZ,(XIZ+A)
	call (xiz)                                    ; FA60F9  b6 e8   call T,XIZ
	jr .LFA60CD                                   ; FA60FB  68 d0
.LFA60FD:
	call T_ParamShadow_FlushAll                                 ; FA60FD  1d 98 08 f4
	ld XIX,0x00002c00                             ; FA6101  44 00 2c 00 00
	ld hl, (0x60f000:24)                         ; FA6106  d2 00 f0 60 23   ld HL,(0x60f000)
	ld	(xix+hl), 0xff                        ; FA610B  f3 07 f0 ec 00 ff   ld (XIX+HL),0xff
	ret                                           ; FA6111  0e

; ---------------------------------------------------------------------
; sub_FA6112 -- the second copy of sub_FA6068, byte for byte
;
; Called from: NOTHING FOUND, same searched negative as sub_FA6068.
; ---------------------------------------------------------------------
sub_FA6112:
	call T_Dev7F_WriteSlot8_Slot0                 ; FA6112  1d 04 00 f4
	call T_Dev7F_WriteSlot8_Slot1                 ; FA6116  1d 08 00 f4
	call T_Dev7F_WriteSlot8_Slot2                 ; FA611A  1d 0c 00 f4
	call T_Dev7F_WriteSlot8_Slot3                 ; FA611E  1d 10 00 f4
	ret                                           ; FA6122  0e
.LFA6123:

; ---------------------------------------------------------------------
; MidiIn_FetchMessage_PortB -- copy one message from ring 0x601028 to 0x1940
;
; Called from: MidiIn_PumpPortB 0xFA60DE (`calr`), its only caller.
; Evidence: 0x28 bytes, of which FOUR differ from MidiIn_FetchMessage_PortA
;          (check T2): the ring base, the scan veneer, and the port tag
;          `ld (XIY+0x03),0x10` where port A writes 0x00.
; ---------------------------------------------------------------------
MidiIn_FetchMessage_PortB:   ; entry: call from 0xFA60DE
	ld XIZ,MidiIn_PortBRing                             ; FA6123  46 28 10 60 00
	ld XIY,MidiIn_MsgStatus                             ; FA6128  45 40 19 00 00
	ld (XIY+0x03),0x10                            ; FA612D  bd 03 00 10
.LFA6131:
	call T_MidiInBRing_Scan                        ; FA6131  1d e4 1d f4
	ld (xiy+), a                             ; FA6135  f5 f4 41   ld (XIY+),A
	ld hl, (xiz-10)                               ; FA6138  9e f6 23   ld HL,(XIZ+0xf6)
	cp	hl, (xiz-6)                           ; FA613B  9e fa f3   cp HL,(XIZ+0xfa)
	jr z, .LFA614A                                ; FA613E  66 0a
	ld	a, (xiz+hl)                           ; FA6140  c3 07 f8 ec 21   ld A,(XIZ+HL)
	bit 0x07,A                                    ; FA6145  c9 33 07
	jr z, .LFA6131                                ; FA6148  66 e7
.LFA614A:
	ret                                           ; FA614A  0e

; ---------------------------------------------------------------------
; MidiIn_SystemMessage -- dispatch an 0xFn status on its low nibble
;
; Called from: MidiIn_StatusClassTable[7], the 0xFn slot.
; Evidence: `and L,0x0F / sla 2,L` then MidiIn_SystemSubTable, so the index
;          IS the System sub-type: 2 = Song Position, 3 = Song Select.
; ---------------------------------------------------------------------
MidiIn_SystemMessage:   ; entry: MidiIn_StatusClassTable[7]
	ld l, (MidiIn_MsgStatus:16)                            ; FA614B  c1 40 19 27   ld L,(0x1940)
	and L,0x0f                                    ; FA614F  cf cc 0f
	sla l, 0x02                                   ; FA6152  cf ec 02   sla 0x02,L
	extz HL                                       ; FA6155  db 12
	ld XIZ,MidiIn_SystemSubTable                  ; FA6157  46 64 61 fa 00
	ld	xiz, (xiz+hl)                         ; FA615C  e3 07 f8 ec 26   ld XIZ,(XIZ+HL)
	call (xiz)                                    ; FA6161  b6 e8   call T,XIZ
	ret                                           ; FA6163  0e

; --- 0xFA6164-0xFA61A3  pointer table (64 bytes) ---
; ---------------------------------------------------------------------
; MidiIn_SystemSubTable -- 16 LE32 handlers, one per MIDI SYSTEM status
;          0xF0-0xFF.
; Read by: MidiIn_SystemMessage (0xFA614B, MidiIn_StatusClassTable[7]):
;          `ld L,(0x1940) / and L,0x0F / sla 2,L / ld XIZ,<this> /
;          ld XIZ,(XIZ+HL) / call (XIZ)` -- the status byte's low nibble,
;          hence COUNT 16.  [2] 0xF2 Song Position and [3] 0xF3 Song Select
;          are handled; the rest are MidiIn_SystemIgnore.
;          (notes/proma-2026-09-25/gen_small_headers.py, H2)
; ---------------------------------------------------------------------
MidiIn_SystemSubTable:
	.long MidiIn_SystemIgnore                   ; FA6164  [0]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6168  [1]   -> MidiIn_SystemIgnore
	.long MidiIn_SongPosition                   ; FA616C  [2]   -> MidiIn_SongPosition
	.long MidiIn_SongSelect                     ; FA6170  [3]   -> MidiIn_SongSelect
	.long MidiIn_SystemIgnore                   ; FA6174  [4]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6178  [5]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA617C  [6]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6180  [7]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6184  [8]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6188  [9]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA618C  [10]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6190  [11]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6194  [12]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA6198  [13]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA619C  [14]   -> MidiIn_SystemIgnore
	.long MidiIn_SystemIgnore                   ; FA61A0  [15]   -> MidiIn_SystemIgnore

; ---------------------------------------------------------------------
; MidiIn_SongPosition -- MIDI 0xF2, Song Position Pointer
;
; Called from: MidiIn_SystemSubTable[2], and the index is the status byte's
;          low nibble, so this handler IS status 0xF2.
; Outputs: (0xA4) = data 1 (LSB), (0xA5) = data 2 (MSB), with bit 7 of
;          (0xA5) set when bit 2 of (0x7F34) is set.
; Evidence: `ld WA,(0x1941)` takes BOTH data bytes as one 16-bit load and
;          they are stored to adjacent bytes -- the two-data-byte shape of
;          Song Position, and the only System message with two.
; ---------------------------------------------------------------------
MidiIn_SongPosition:   ; entry: MidiIn_SystemSubTable[2]
	ld wa, (MidiIn_MsgData1:16)                          ; FA61A4  d1 41 19 20   ld WA,(0x1941)
	ld	(MidiIn_SongPositionLo:8), a                               ; FA61A8  f0 a4 41   ld (0xa4),A
	bit	2, (0x7f34:16)                        ; FA61AB  f1 34 7f ca   bit 2,(0x7f34)
	jr z, .LFA61B4                                ; FA61AF  66 03
	set 0x07,W                                    ; FA61B1  c8 31 07
.LFA61B4:
	ld	(MidiIn_SongPositionHi:8), w                               ; FA61B4  f0 a5 40   ld (0xa5),W
	ret                                           ; FA61B7  0e

; ---------------------------------------------------------------------
; MidiIn_SongSelect -- MIDI 0xF3, Song Select
;
; Called from: MidiIn_SystemSubTable[3], so this handler IS status 0xF3.
; Outputs: (0xA3) = the single data byte, bit 7 set when bit 3 of (0x7F33)
;          is set.
; Evidence: it reads (0x1941) only -- one data byte, which is Song Select's
;          shape and distinguishes it from the handler above.
; ---------------------------------------------------------------------
MidiIn_SongSelect:   ; entry: MidiIn_SystemSubTable[3]
	ld a, (MidiIn_MsgData1:16)                            ; FA61B8  c1 41 19 21   ld A,(0x1941)
	bit	3, (MidiFilter_SongSelect:16)                        ; FA61BC  f1 33 7f cb   bit 3,(0x7f33)
	jr z, .LFA61C5                                ; FA61C0  66 03
	set 0x07,A                                    ; FA61C2  c9 31 07
.LFA61C5:
	ld	(MidiIn_SongSelectValue:8), a                               ; FA61C5  f0 a3 41   ld (0xa3),A
	ret                                           ; FA61C8  0e

; ---------------------------------------------------------------------
; MidiIn_SystemIgnore -- `or (0x9F),0x01` and return
;
; Called from: fourteen of MidiIn_SystemSubTable's sixteen slots -- every
;          System status except 0xF2 and 0xF3.
; ---------------------------------------------------------------------
MidiIn_SystemIgnore:   ; entry: MidiIn_SystemSubTable[0-1,4-15]
	or	(0x9f:8), 0x01                        ; FA61C9  c0 9f 3e 01   or (0x9f),0x01
	ret                                           ; FA61CD  0e

; ---------------------------------------------------------------------
; MidiIn_RouteChannelMessage -- run one channel message on every part
; listening to its channel
;
; Called from: seven of MidiIn_StatusClassTable's eight slots (0x8n..0xEn).
; Inputs:  (0x1940..0x1943) the staged message; the routing tables at
;          0x1800 (32 bytes) and 0x1820 (64 bytes).
; Outputs: (0x197E) = channel | port tag, (0x1974/0x1975/0x1977) the list
;          cursor and count, (0x1976) the current part index, then one call
;          of MidiIn_ChannelStatusTable per listening part.
; Evidence: `and A,0x0F / or A,(0x1943)` builds a 0..0x1F index -- 16
;          channels times two ports -- which selects an offset in 0x1800;
;          0x1820[offset] is the COUNT and 0x1820[offset+1..] the part
;          indices, because 0xFA620B increments the cursor and 0xFA623B
;          decrements (0x1977) until it hits zero.  Both tables are built by
;          MidiIn_BuildChannelRouteTable, which writes exactly that shape.
; ---------------------------------------------------------------------
MidiIn_RouteChannelMessage:   ; entry: MidiIn_StatusClassTable[0-6]
	ld a, (MidiIn_MsgStatus:16)                            ; FA61CE  c1 40 19 21   ld A,(0x1940)
	and A,0x0f                                    ; FA61D2  c9 cc 0f
	or a, (MidiIn_MsgPortTag:16)                             ; FA61D5  c1 43 19 e1   or A,(0x1943)
	ld (MidiIn_ChannelTag:16), a                            ; FA61D9  f1 7e 19 41   ld (0x197e),A
	ld (0x197d:16), 0xff                          ; FA61DD  f1 7d 19 00 ff   ld (0x197d),0xff
	ld XHL,0x00001800                             ; FA61E2  43 00 18 00 00
	ld	a, (xhl+a)                            ; FA61E7  c3 03 ec e0 21   ld A,(XHL+A)
	cp A,0xff                                     ; FA61EC  c9 cf ff
	jr z, .LFA6241                                ; FA61EF  66 50
	ld (MidiIn_RouteCursor:16), a                            ; FA61F1  f1 74 19 41   ld (0x1974),A
	ld XHL,0x00001820                             ; FA61F5  43 20 18 00 00
	ld	a, (xhl+a)                            ; FA61FA  c3 03 ec e0 21   ld A,(XHL+A)
	cp a, 0x00:i3                                   ; FA61FF  c9 d8   cp A,0
	jr z, .LFA6241                                ; FA6201  66 3e
	ld (MidiIn_RouteCount:16), a                            ; FA6203  f1 75 19 41   ld (0x1975),A
	ld (MidiIn_RouteRemaining:16), a                            ; FA6207  f1 77 19 41   ld (0x1977),A
.LFA620B:
	inc 0x01, (MidiIn_RouteCursor:16)                         ; FA620B  c1 74 19 61   inc 1,(0x1974)
	xor H,H                                       ; FA620F  ce d6
	ld l, (MidiIn_RouteCursor:16)                            ; FA6211  c1 74 19 27   ld L,(0x1974)
	ld XIX,0x00001820                             ; FA6215  44 20 18 00 00
	ld	a, (xix+hl)                           ; FA621A  c3 07 f0 ec 21   ld A,(XIX+HL)
	ld (MidiIn_CurrentPart:16), a                            ; FA621F  f1 76 19 41   ld (0x1976),A
	xor H,H                                       ; FA6223  ce d6
	ld l, (MidiIn_MsgStatus:16)                            ; FA6225  c1 40 19 27   ld L,(0x1940)
	and L,0x70                                    ; FA6229  cf cc 70
	srl hl, 0x02                                  ; FA622C  db ef 02   srl 0x02,HL
	ld XIX,MidiIn_ChannelStatusTable              ; FA622F  44 42 62 fa 00
	ld	xix, (xix+hl)                         ; FA6234  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	call (xix)                                    ; FA6239  b4 e8   call T,XIX
	dec 0x01, (MidiIn_RouteRemaining:16)                         ; FA623B  c1 77 19 69   dec 1,(0x1977)
	jr nz, .LFA620B                               ; FA623F  6e ca
.LFA6241:
	ret                                           ; FA6241  0e

; --- 0xFA6242-0xFA6261  pointer table (32 bytes) ---
; ---------------------------------------------------------------------
; MidiIn_ChannelStatusTable -- 8 LE32 handlers, one per CHANNEL message kind
;          0x80-0xF0 (status bits 4-6).
; Read by: 0xFA6225 `ld L,(0x1940) / and L,0x70 / srl 2,HL / ld XIX,<this> /
;          ld XIX,(XIX+HL) / call (XIX)` -- (status & 0x70) / 4, hence
;          COUNT 8.  [3] 0xB0 Control Change, [4] 0xC0 Program Change,
;          [5] 0xD0 Channel Pressure, [6] 0xE0 Pitch Bend; note on/off,
;          polyphonic aftertouch and [7] are MidiIn_ChannelIgnore.
;          (notes/proma-2026-09-25/gen_small_headers.py, H3)
; ---------------------------------------------------------------------
MidiIn_ChannelStatusTable:
	.long MidiIn_ChannelIgnore                  ; FA6242  [0]   -> MidiIn_ChannelIgnore
	.long MidiIn_ChannelIgnore                  ; FA6246  [1]   -> MidiIn_ChannelIgnore
	.long MidiIn_ChannelIgnore                  ; FA624A  [2]   -> MidiIn_ChannelIgnore
	.long MidiIn_ControlChange                  ; FA624E  [3]   -> MidiIn_ControlChange
	.long MidiIn_ProgramChange                  ; FA6252  [4]   -> MidiIn_ProgramChange
	.long MidiIn_ChannelPressure                ; FA6256  [5]   -> MidiIn_ChannelPressure
	.long MidiIn_PitchBend                      ; FA625A  [6]   -> MidiIn_PitchBend
	.long MidiIn_ChannelIgnore                  ; FA625E  [7]   -> MidiIn_ChannelIgnore

; ---------------------------------------------------------------------
; MidiIn_ChannelIgnore -- `or (0x9F),0x01` and return
;
; Called from: MidiIn_ChannelStatusTable slots 0, 1, 2 and 7 -- Note Off,
;          Note On, Poly Key Pressure and 0xFn.
; ★ Note On and Note Off are DELIBERATELY not handled here.  This module
;   routes controllers and per-part parameters; notes reach the tone
;   generator by another path.  That is a property of the table, not an
;   omission in this reading.
; ---------------------------------------------------------------------
MidiIn_ChannelIgnore:   ; entry: MidiIn_ChannelStatusTable[0-2,7]
	or	(0x9f:8), 0x01                        ; FA6262  c0 9f 3e 01   or (0x9f),0x01
	ret                                           ; FA6266  0e

; ---------------------------------------------------------------------
; MidiIn_ControlChange -- MIDI 0xBn, Control Change
;
; Called from: MidiIn_ChannelStatusTable[3], the 0xBn slot.
; Inputs:  (0x1941) the controller number, (0x1942) its value.
; Outputs: (0x1963) = the internal controller index, then
;          MidiIn_ControllerHandlerTable[index] is called.
; Evidence: three tables in a row, each with its own bound.  (1) the
;          controller number indexes MidiIn_ControllerNumberToIndex; 0xFF
;          means `not ours` and returns.  (2) the index doubles into
;          MidiIn_ControllerEnableTable, whose 16-bit entry is a byte offset
;          from 0x7F39 in the high half and a bit mask in the low half --
;          `ld XIX,0x00007F39 / ld C,(XIX+W) / and C,A` -- and 0xFFFF means
;          `always enabled`.  (3) the index quadruples into
;          MidiIn_ControllerHandlerTable.
; ---------------------------------------------------------------------
MidiIn_ControlChange:   ; entry: MidiIn_ChannelStatusTable[3]
	ld XIX,MidiIn_ControllerNumberToIndex         ; FA6267  44 e8 83 fa 00
	ld l, (MidiIn_MsgData1:16)                            ; FA626C  c1 41 19 27   ld L,(0x1941)
	ld	a, (xix+l)                            ; FA6270  c3 03 f0 ec 21   ld A,(XIX+L)
	ld (0x1963:16), a                            ; FA6275  f1 63 19 41   ld (0x1963),A
	cp A,0xff                                     ; FA6279  c9 cf ff
	jr z, .LFA62B6                                ; FA627C  66 38
	extz WA                                       ; FA627E  d8 12
	sll a, 0x01                                   ; FA6280  c9 ee 01   sll 0x01,A
	ld XIX,MidiIn_ControllerEnableTable           ; FA6283  44 68 84 fa 00
	ld	wa, (xix+wa)                          ; FA6288  d3 07 f0 e0 20   ld WA,(XIX+WA)
	cp WA,0xffff                                  ; FA628D  d8 cf ff ff
	jr z, .LFA62A1                                ; FA6291  66 0e
	ld XIX,MidiFilter_ChannelMsgs                             ; FA6293  44 39 7f 00 00
	ld	c, (xix+w)                            ; FA6298  c3 03 f0 e1 23   ld C,(XIX+W)
	and C,A                                       ; FA629D  c9 c3
	jr z, .LFA62B6                                ; FA629F  66 15
.LFA62A1:
	extz WA                                       ; FA62A1  d8 12
	ld a, (0x1963:16)                            ; FA62A3  c1 63 19 21   ld A,(0x1963)
	sla wa, 0x02                                  ; FA62A7  d8 ec 02   sla 0x02,WA
	ld XIX,MidiIn_ControllerHandlerTable          ; FA62AA  44 b8 62 fa 00
	ld	xix, (xix+wa)                         ; FA62AF  e3 07 f0 e0 24   ld XIX,(XIX+WA)
	call (xix)                                    ; FA62B4  b4 e8   call T,XIX
.LFA62B6:
	ret                                           ; FA62B6  0e

; --- 0xFA62B7-0xFA62B7  alignment pad (1 bytes) ---
	.byte 0x00   ; FA62B7

; --- 0xFA62B8-0xFA6377  pointer table (192 bytes) ---
MidiIn_ControllerHandlerTable:
	.long MidiIn_CC40_Hold                      ; FA62B8  [0]   -> MidiIn_CC40_Hold
	.long MidiIn_CC01_Modulation                ; FA62BC  [1]   -> MidiIn_CC01_Modulation
	.long MidiIn_CC07_Volume                    ; FA62C0  [2]   -> MidiIn_CC07_Volume
	.long MidiIn_CC0B_Expression                ; FA62C4  [3]   -> MidiIn_CC0B_Expression
	.long MidiIn_CC0A_Pan                       ; FA62C8  [4]   -> MidiIn_CC0A_Pan
	.long MidiIn_CC5D_Effect3Depth              ; FA62CC  [5]   -> MidiIn_CC5D_Effect3Depth
	.long MidiIn_CC5E_Effect4Depth              ; FA62D0  [6]   -> MidiIn_CC5E_Effect4Depth
	.long MidiIn_CC5B_Effect1Depth              ; FA62D4  [7]   -> MidiIn_CC5B_Effect1Depth
	.long sub_FA64E5                            ; FA62D8  [8]   -> sub_FA64E5
	.long sub_FA6526                            ; FA62DC  [9]   -> sub_FA6526
	.long MidiIn_CC02_Modulation2               ; FA62E0  [10]   -> MidiIn_CC02_Modulation2
	.long MidiIn_CC04_CtrlPedal                 ; FA62E4  [11]   -> MidiIn_CC04_CtrlPedal
	.long MidiIn_CC10_RTCreatX                  ; FA62E8  [12]   -> MidiIn_CC10_RTCreatX
	.long MidiIn_CC11_RTCreatY                  ; FA62EC  [13]   -> MidiIn_CC11_RTCreatY
	.long MidiIn_CC12_RTCtrlX                   ; FA62F0  [14]   -> MidiIn_CC12_RTCtrlX
	.long MidiIn_CC13_RTCtrlY                   ; FA62F4  [15]   -> MidiIn_CC13_RTCtrlY
	.long MidiIn_ControllerHandlerTable_Nop16                            ; FA62F8  [16]   -> MidiIn_ControllerHandlerTable_Nop16
	.long MidiIn_ControllerHandlerTable_Nop17                            ; FA62FC  [17]   -> MidiIn_ControllerHandlerTable_Nop17
	.long MidiIn_CC51_General6                  ; FA6300  [18]   -> MidiIn_CC51_General6
	.long MidiIn_NullHandler                    ; FA6304  [19]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6308  [20]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA630C  [21]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6310  [22]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6314  [23]   -> MidiIn_NullHandler
	.long MidiIn_CC00_BankSelMSB                ; FA6318  [24]   -> MidiIn_CC00_BankSelMSB
	.long MidiIn_CC20_BankSelLSB                ; FA631C  [25]   -> MidiIn_CC20_BankSelLSB
	.long MidiIn_NullHandler                    ; FA6320  [26]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6324  [27]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6328  [28]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA632C  [29]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6330  [30]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6334  [31]   -> MidiIn_NullHandler
	.long MidiIn_CC06_DataEntMSB                ; FA6338  [32]   -> MidiIn_CC06_DataEntMSB
	.long MidiIn_CC26_DataEntLSB                ; FA633C  [33]   -> MidiIn_CC26_DataEntLSB
	.long MidiIn_CC65_RpnMSB                    ; FA6340  [34]   -> MidiIn_CC65_RpnMSB
	.long MidiIn_CC64_RpnLSB                    ; FA6344  [35]   -> MidiIn_CC64_RpnLSB
	.long MidiIn_NullHandler                    ; FA6348  [36]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA634C  [37]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6350  [38]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6354  [39]   -> MidiIn_NullHandler
	.long MidiIn_CC79_ResetAllCtrl              ; FA6358  [40]   -> MidiIn_CC79_ResetAllCtrl
	.long MidiIn_CC78_AllSoundOff               ; FA635C  [41]   -> MidiIn_CC78_AllSoundOff
	.long MidiIn_NullHandler                    ; FA6360  [42]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6364  [43]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6368  [44]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA636C  [45]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6370  [46]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA6374  [47]   -> MidiIn_NullHandler

; ---------------------------------------------------------------------
; MidiIn_NullHandler -- one byte, `ret`
;
; Called from: 21 of MidiIn_ControllerHandlerTable's 48 slots and 5 of
;          MidiOut_ParamClassTable's 17 (counts re-derived, check N1).
; ★ Its address is also what pins MidiIn_ControllerHandlerTable's length:
;   0xFA62B8 + 48*4 = 0xFA6378, so the table ends exactly where the first
;   routine it points at begins.  A 49th entry would read this `ret`.
; ---------------------------------------------------------------------
MidiIn_NullHandler:   ; entry: MidiIn_ControllerHandlerTable[19-23,26-31,36-39,42-47]; MidiOut_ParamClassTable[2,4,12-14]; 0xFA7520[0,2-3]; 0xFA753C[0-3]
	ret                                           ; FA6378  0e

; ---------------------------------------------------------------------
; MidiIn_CC20_BankSelLSB -- MIDI controller 0x20, Bank Select LSB
;
; Called from: MidiIn_ControllerHandlerTable[25], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x20] = 25 selects this slot,
;          and MidiIn_IndexToControllerNumber[25] reads back 0x20.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; ---------------------------------------------------------------------
MidiIn_CC20_BankSelLSB:   ; entry: MidiIn_ControllerHandlerTable[25]
	extz HL                                       ; FA6379  db 12
	ld l, (MidiIn_CurrentPart:16)                            ; FA637B  c1 76 19 27   ld L,(0x1976)
	cp L,0xff                                     ; FA637F  cf cf ff
	jr nz, .LFA6391                               ; FA6382  6e 0d
	ld c, (MidiIn_ChannelTag:16)                            ; FA6384  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6388  f1 7d 19 43   ld (0x197d),C
	ldw bc, 0x0198                                ; FA638C  31 98 01   ld BC,0x0198
	jr .LFA63CE                                   ; FA638F  68 3d
.LFA6391:
	cp L,0x1f                                     ; FA6391  cf cf 1f
	jr ugt, .LFA63E8                              ; FA6394  6b 52
	ld c, (MidiIn_ChannelTag:16)                            ; FA6396  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA639A  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA63BC                                ; FA639E  66 1c
	pushw hl                                      ; FA63A0  2b   push HL
	sll hl, 0x02                                  ; FA63A1  db ee 02   sll 0x02,HL
	ld xix, (IndexedTable_Base:24)                        ; FA63A4  e2 18 f0 60 24   ld XIX,(0x60f018)
	ld	xix, (xix+hl)                         ; FA63A9  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	popw hl                                       ; FA63AE  4b   pop HL
	cp XIX,0xffffffff                             ; FA63AF  ec cf ff ff ff ff
	jr z, .LFA63E8                                ; FA63B5  66 31
	bit 7,(XIX+0x30)                              ; FA63B7  bc 30 cf
	jr z, .LFA63E8                                ; FA63BA  66 2c
.LFA63BC:
	sll hl, 0x01                                  ; FA63BC  db ee 01   sll 0x01,HL
	ld XIX,MidiIn_BankSelect_ParamTable           ; FA63BF  44 88 8c fa 00
	ld	bc, (xix+hl)                          ; FA63C4  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA63C9  cb cf ff
	jr z, .LFA63E8                                ; FA63CC  66 1a
.LFA63CE:
	ld e, (MidiIn_MsgData2:16)                            ; FA63CE  c1 42 19 25   ld E,(0x1942)
	ld d, 0xff:opc                                   ; FA63D2  24 ff   ld D,0xff
	ld a, (MidiIn_MsgPortTag:16)                            ; FA63D4  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA63D8  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA63DC  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA63E0  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_StorePairAndDerive                                 ; FA63E4  1d 70 08 f4
.LFA63E8:
	ret                                           ; FA63E8  0e

; ---------------------------------------------------------------------
; MidiIn_CC00_BankSelMSB -- MIDI controller 0x00, Bank Select MSB
;
; Called from: MidiIn_ControllerHandlerTable[24], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x00] = 24 selects this slot,
;          and MidiIn_IndexToControllerNumber[24] reads back 0x00.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; ---------------------------------------------------------------------
MidiIn_CC00_BankSelMSB:   ; entry: MidiIn_ControllerHandlerTable[24]
	extz HL                                       ; FA63E9  db 12
	ld l, (MidiIn_CurrentPart:16)                            ; FA63EB  c1 76 19 27   ld L,(0x1976)
	cp L,0xff                                     ; FA63EF  cf cf ff
	jr nz, .LFA6401                               ; FA63F2  6e 0d
	ld c, (MidiIn_ChannelTag:16)                            ; FA63F4  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA63F8  f1 7d 19 43   ld (0x197d),C
	ldw bc, 0x0198                                ; FA63FC  31 98 01   ld BC,0x0198
	jr .LFA643E                                   ; FA63FF  68 3d
.LFA6401:
	cp L,0x1f                                     ; FA6401  cf cf 1f
	jr ugt, .LFA6458                              ; FA6404  6b 52
	ld c, (MidiIn_ChannelTag:16)                            ; FA6406  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA640A  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA642C                                ; FA640E  66 1c
	pushw hl                                      ; FA6410  2b   push HL
	sll hl, 0x02                                  ; FA6411  db ee 02   sll 0x02,HL
	ld xix, (IndexedTable_Base:24)                        ; FA6414  e2 18 f0 60 24   ld XIX,(0x60f018)
	ld	xix, (xix+hl)                         ; FA6419  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	popw hl                                       ; FA641E  4b   pop HL
	cp XIX,0xffffffff                             ; FA641F  ec cf ff ff ff ff
	jr z, .LFA6458                                ; FA6425  66 31
	bit 7,(XIX+0x30)                              ; FA6427  bc 30 cf
	jr z, .LFA6458                                ; FA642A  66 2c
.LFA642C:
	sll hl, 0x01                                  ; FA642C  db ee 01   sll 0x01,HL
	ld XIX,MidiIn_BankSelect_ParamTable           ; FA642F  44 88 8c fa 00
	ld	bc, (xix+hl)                          ; FA6434  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6439  cb cf ff
	jr z, .LFA6458                                ; FA643C  66 1a
.LFA643E:
	ld d, (MidiIn_MsgData2:16)                            ; FA643E  c1 42 19 24   ld D,(0x1942)
	ld e, 0xff:opc                                   ; FA6442  25 ff   ld E,0xff
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6444  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6448  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA644C  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6450  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_StorePairAndDerive                                 ; FA6454  1d 70 08 f4
.LFA6458:
	ret                                           ; FA6458  0e

; ---------------------------------------------------------------------
; MidiIn_ControllerHandlerTable_Nop16 -- MidiIn_ControllerHandlerTable[16]
;
; Called from: that table only.
; Unknown: MidiIn_ControllerNumberToIndex sends NO controller
;          number to this index, so nothing inbound says which
;          controller it is.  MidiIn_IndexToControllerNumber
;          does name it -- 0x50 -- but that map is only read
;          on the OUTBOUND side, so it is one witness and this
;          file's rule is two.  Named sub_ deliberately.
; ---------------------------------------------------------------------
MidiIn_ControllerHandlerTable_Nop16:   ; entry: MidiIn_ControllerHandlerTable[16]
	ret                                           ; FA6459  0e

; ---------------------------------------------------------------------
; MidiIn_ControllerHandlerTable_Nop17 -- MidiIn_ControllerHandlerTable[17]
;
; Called from: that table only.
; Unknown: MidiIn_ControllerNumberToIndex sends NO controller
;          number to this index, so nothing inbound says which
;          controller it is.  MidiIn_IndexToControllerNumber
;          does name it -- 0x52 -- but that map is only read
;          on the OUTBOUND side, so it is one witness and this
;          file's rule is two.  Named sub_ deliberately.
; ---------------------------------------------------------------------
MidiIn_ControllerHandlerTable_Nop17:   ; entry: MidiIn_ControllerHandlerTable[17]
	ret                                           ; FA645A  0e

; ---------------------------------------------------------------------
; MidiIn_CC40_Hold -- MIDI controller 0x40, Damper pedal (sustain)
;
; Called from: MidiIn_ControllerHandlerTable[0], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x40] = 0 selects this slot,
;          and MidiIn_IndexToControllerNumber[0] reads back 0x40.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC40_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC40_Damper.  Controller 64 is what this
;          instrument's own on-screen list at 0xFA2C13 calls
;          `HOLD       (#64)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Damper` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC40_Hold:   ; entry: MidiIn_ControllerHandlerTable[0]
	ld a, (MidiIn_CurrentPart:16)                            ; FA645B  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA645F  c9 cf ff
	jr nz, .LFA6470                               ; FA6462  6e 0c
	ld a, 0x00:opc                                   ; FA6464  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6466  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA646A  f1 7d 19 43   ld (0x197d),C
	jr .LFA647A                                   ; FA646E  68 0a
.LFA6470:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6470  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6474  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA64E4                                ; FA6478  66 6a
.LFA647A:
	cp A,0x1f                                     ; FA647A  c9 cf 1f
	jr ugt, .LFA64E4                              ; FA647D  6b 65
	xor W,W                                       ; FA647F  c8 d0
	ld HL,WA                                      ; FA6481  d8 8b
	sll wa, 0x01                                  ; FA6483  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6486  d8 83
	ld XIX,MidiIn_CC40_ParamTable                 ; FA6488  44 c8 84 fa 00
	ld	bc, (xix+hl)                          ; FA648D  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6492  cb cf ff
	jr z, .LFA64E4                                ; FA6495  66 4d
	inc 2,XIX                                     ; FA6497  ec 62
	ld	d, (xix+hl)                           ; FA6499  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA649E  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA64A2  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA64A6  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA64AA  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA64AE  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA64B2  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA64E0                               ; FA64B7  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA64B9  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA64D2                               ; FA64BD  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA64BF  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA64C3  c9 d9   cp A,1
	jr nz, .LFA64D2                               ; FA64C5  6e 0b
	ld (0x1958:16), bc                           ; FA64C7  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA64CB  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC40_Hold                                   ; FA64CF  1e bf 13   calr 0xfa7891
.LFA64D2:
	ld XIX,0x00001950                             ; FA64D2  44 50 19 00 00
	push XIX                                      ; FA64D7  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA64D8  1d 0c 08 f4
	inc 4,XSP                                     ; FA64DC  ef 64
	jr .LFA64E4                                   ; FA64DE  68 04
.LFA64E0:
	call T_ParamApply_PublishStagedPair                                 ; FA64E0  1d 84 08 f4
.LFA64E4:
	ret                                           ; FA64E4  0e

; ---------------------------------------------------------------------
; sub_FA64E5 -- MidiIn_ControllerHandlerTable[8]
;
; Called from: that table only.
; Unknown: MidiIn_ControllerNumberToIndex sends NO controller
;          number to this index, so nothing inbound says which
;          controller it is, and the reverse map leaves the
;          index 0xFF too.  Named sub_ deliberately.
; Reads:   sub_FA64E5_ParamTable.
; ---------------------------------------------------------------------
sub_FA64E5:   ; entry: MidiIn_ControllerHandlerTable[8]
	ld a, (MidiIn_CurrentPart:16)                            ; FA64E5  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA64E9  c9 cf 1f
	jr ugt, .LFA6525                              ; FA64EC  6b 37
	xor W,W                                       ; FA64EE  c8 d0
	ld HL,WA                                      ; FA64F0  d8 8b
	sll wa, 0x01                                  ; FA64F2  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA64F5  d8 83
	ld XIX,sub_FA64E5_ParamTable                  ; FA64F7  44 28 85 fa 00
	ld	bc, (xix+hl)                          ; FA64FC  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6501  cb cf ff
	jr z, .LFA6525                                ; FA6504  66 1f
	inc 2,XIX                                     ; FA6506  ec 62
	ld	d, (xix+hl)                           ; FA6508  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA650D  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6511  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6515  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6519  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA651D  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_PublishStagedPair                                 ; FA6521  1d 84 08 f4
.LFA6525:
	ret                                           ; FA6525  0e

; ---------------------------------------------------------------------
; sub_FA6526 -- MidiIn_ControllerHandlerTable[9]
;
; Called from: that table only.
; Unknown: MidiIn_ControllerNumberToIndex sends NO controller
;          number to this index, so nothing inbound says which
;          controller it is, and the reverse map leaves the
;          index 0xFF too.  Named sub_ deliberately.
; Reads:   sub_FA6526_ParamTable.
; ---------------------------------------------------------------------
sub_FA6526:   ; entry: MidiIn_ControllerHandlerTable[9]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6526  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA652A  c9 cf 1f
	jr ugt, .LFA6566                              ; FA652D  6b 37
	xor W,W                                       ; FA652F  c8 d0
	ld HL,WA                                      ; FA6531  d8 8b
	sll wa, 0x01                                  ; FA6533  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6536  d8 83
	ld XIX,sub_FA6526_ParamTable                  ; FA6538  44 88 85 fa 00
	ld	bc, (xix+hl)                          ; FA653D  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6542  cb cf ff
	jr z, .LFA6566                                ; FA6545  66 1f
	inc 2,XIX                                     ; FA6547  ec 62
	ld	d, (xix+hl)                           ; FA6549  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA654E  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6552  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6556  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA655A  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA655E  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_PublishStagedPair                                 ; FA6562  1d 84 08 f4
.LFA6566:
	ret                                           ; FA6566  0e

; ---------------------------------------------------------------------
; MidiIn_CC01_Modulation -- MIDI controller 0x01, Modulation wheel
;
; Called from: MidiIn_ControllerHandlerTable[1], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x01] = 1 selects this slot,
;          and MidiIn_IndexToControllerNumber[1] reads back 0x01.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC01_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC01_Modulation:   ; entry: MidiIn_ControllerHandlerTable[1]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6567  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA656B  c9 cf ff
	jr nz, .LFA657C                               ; FA656E  6e 0c
	ld a, 0x00:opc                                   ; FA6570  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6572  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6576  f1 7d 19 43   ld (0x197d),C
	jr .LFA6586                                   ; FA657A  68 0a
.LFA657C:
	ld c, (MidiIn_ChannelTag:16)                            ; FA657C  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6580  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA65F0                                ; FA6584  66 6a
.LFA6586:
	cp A,0x1f                                     ; FA6586  c9 cf 1f
	jr ugt, .LFA65F0                              ; FA6589  6b 65
	xor W,W                                       ; FA658B  c8 d0
	ld HL,WA                                      ; FA658D  d8 8b
	sll wa, 0x01                                  ; FA658F  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6592  d8 83
	ld XIX,MidiIn_CC01_ParamTable                 ; FA6594  44 e8 85 fa 00
	ld	bc, (xix+hl)                          ; FA6599  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA659E  cb cf ff
	jr z, .LFA65F0                                ; FA65A1  66 4d
	inc 2,XIX                                     ; FA65A3  ec 62
	ld	d, (xix+hl)                           ; FA65A5  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA65AA  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA65AE  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA65B2  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA65B6  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA65BA  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA65BE  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA65EC                               ; FA65C3  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA65C5  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA65DE                               ; FA65C9  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA65CB  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA65CF  c9 d9   cp A,1
	jr nz, .LFA65DE                               ; FA65D1  6e 0b
	ld (0x1958:16), bc                           ; FA65D3  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA65D7  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC01_Modulation                                   ; FA65DB  1e 3f 11   calr 0xfa771d
.LFA65DE:
	ld XIX,0x00001950                             ; FA65DE  44 50 19 00 00
	push XIX                                      ; FA65E3  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA65E4  1d 0c 08 f4
	inc 4,XSP                                     ; FA65E8  ef 64
	jr .LFA65F0                                   ; FA65EA  68 04
.LFA65EC:
	call T_ParamShadow_SetModulation1                                 ; FA65EC  1d 68 08 f4
.LFA65F0:
	ret                                           ; FA65F0  0e

; ---------------------------------------------------------------------
; MidiIn_CC07_Volume -- MIDI controller 0x07, Channel Volume
;
; Called from: MidiIn_ControllerHandlerTable[2], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x07] = 2 selects this slot,
;          and MidiIn_IndexToControllerNumber[2] reads back 0x07.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC07_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC07_Volume:   ; entry: MidiIn_ControllerHandlerTable[2]
	ld a, (MidiIn_CurrentPart:16)                            ; FA65F1  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA65F5  c9 cf 1f
	jr ugt, .LFA664F                              ; FA65F8  6b 55
	extz HL                                       ; FA65FA  db 12
	ld L,A                                        ; FA65FC  c9 8f
	sll hl, 0x02                                  ; FA65FE  db ee 02   sll 0x02,HL
	ld xix, (IndexedTable_Base:24)                        ; FA6601  e2 18 f0 60 24   ld XIX,(0x60f018)
	ld	xix, (xix+hl)                         ; FA6606  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA660B  ec cf ff ff ff ff
	jr z, .LFA664F                                ; FA6611  66 3c
	bit 2,(XIX+0x30)                              ; FA6613  bc 30 ca
	jr z, .LFA664F                                ; FA6616  66 37
	xor W,W                                       ; FA6618  c8 d0
	ld HL,WA                                      ; FA661A  d8 8b
	sll wa, 0x01                                  ; FA661C  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA661F  d8 83
	ld XIX,MidiIn_CC07_ParamTable                 ; FA6621  44 48 86 fa 00
	ld	bc, (xix+hl)                          ; FA6626  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA662B  cb cf ff
	jr z, .LFA664F                                ; FA662E  66 1f
	inc 2,XIX                                     ; FA6630  ec 62
	ld	d, (xix+hl)                           ; FA6632  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6637  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA663B  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA663F  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6643  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6647  f1 52 19 52   ld (0x1952),DE
	call T_ParamShadow_SetField3                                 ; FA664B  1d 74 08 f4
.LFA664F:
	ret                                           ; FA664F  0e

; ---------------------------------------------------------------------
; MidiIn_CC0B_Expression -- MIDI controller 0x0B, Expression
;
; Called from: MidiIn_ControllerHandlerTable[3], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x0B] = 3 selects this slot,
;          and MidiIn_IndexToControllerNumber[3] reads back 0x0B.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC0B_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC0B_Expression:   ; entry: MidiIn_ControllerHandlerTable[3]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6650  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6654  c9 cf ff
	jr nz, .LFA6665                               ; FA6657  6e 0c
	ld a, 0x00:opc                                   ; FA6659  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA665B  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA665F  f1 7d 19 43   ld (0x197d),C
	jr .LFA666F                                   ; FA6663  68 0a
.LFA6665:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6665  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6669  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA66D9                                ; FA666D  66 6a
.LFA666F:
	cp A,0x1f                                     ; FA666F  c9 cf 1f
	jr ugt, .LFA66D9                              ; FA6672  6b 65
	xor W,W                                       ; FA6674  c8 d0
	ld HL,WA                                      ; FA6676  d8 8b
	sll wa, 0x01                                  ; FA6678  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA667B  d8 83
	ld XIX,MidiIn_CC0B_ParamTable                 ; FA667D  44 a8 86 fa 00
	ld	bc, (xix+hl)                          ; FA6682  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6687  cb cf ff
	jr z, .LFA664F                                ; FA668A  66 c3
	inc 2,XIX                                     ; FA668C  ec 62
	ld	d, (xix+hl)                           ; FA668E  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6693  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6697  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA669B  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA669F  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA66A3  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA66A7  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA66D5                               ; FA66AC  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA66AE  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA66C7                               ; FA66B2  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA66B4  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA66B8  c9 d9   cp A,1
	jr nz, .LFA66C7                               ; FA66BA  6e 0b
	ld (0x1958:16), bc                           ; FA66BC  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA66C0  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC0B_Expression                                   ; FA66C4  1e c4 10   calr 0xfa778b
.LFA66C7:
	ld XIX,0x00001950                             ; FA66C7  44 50 19 00 00
	push XIX                                      ; FA66CC  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA66CD  1d 0c 08 f4
	inc 4,XSP                                     ; FA66D1  ef 64
	jr .LFA66D9                                   ; FA66D3  68 04
.LFA66D5:
	call T_ParamShadow_SetExpression                                 ; FA66D5  1d 6c 08 f4
.LFA66D9:
	ret                                           ; FA66D9  0e

; ---------------------------------------------------------------------
; MidiIn_CC0A_Pan -- MIDI controller 0x0A, Pan
;
; Called from: MidiIn_ControllerHandlerTable[4], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x0A] = 4 selects this slot,
;          and MidiIn_IndexToControllerNumber[4] reads back 0x0A.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC0A_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC0A_Pan:   ; entry: MidiIn_ControllerHandlerTable[4]
	ld a, (MidiIn_CurrentPart:16)                            ; FA66DA  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA66DE  c9 cf 1f
	jr ugt, .LFA671A                              ; FA66E1  6b 37
	xor W,W                                       ; FA66E3  c8 d0
	ld HL,WA                                      ; FA66E5  d8 8b
	sll wa, 0x01                                  ; FA66E7  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA66EA  d8 83
	ld XIX,MidiIn_CC0A_ParamTable                 ; FA66EC  44 08 87 fa 00
	ld	bc, (xix+hl)                          ; FA66F1  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA66F6  cb cf ff
	jr z, .LFA671A                                ; FA66F9  66 1f
	inc 2,XIX                                     ; FA66FB  ec 62
	ld	d, (xix+hl)                           ; FA66FD  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6702  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6706  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA670A  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA670E  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6712  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_WriteStagedAndPublish_Copy                                 ; FA6716  1d 88 08 f4
.LFA671A:
	ret                                           ; FA671A  0e

; ---------------------------------------------------------------------
; MidiIn_CC5D_Effect3Depth -- MIDI controller 0x5D, Effects 3 Depth
;
; Called from: MidiIn_ControllerHandlerTable[5], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x5D] = 5 selects this slot,
;          and MidiIn_IndexToControllerNumber[5] reads back 0x5D.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC5D_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC5D_Effect3Depth:   ; entry: MidiIn_ControllerHandlerTable[5]
	ld a, (MidiIn_CurrentPart:16)                            ; FA671B  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA671F  c9 cf 1f
	jr ugt, .LFA675B                              ; FA6722  6b 37
	xor W,W                                       ; FA6724  c8 d0
	ld HL,WA                                      ; FA6726  d8 8b
	sll wa, 0x01                                  ; FA6728  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA672B  d8 83
	ld XIX,MidiIn_CC5D_ParamTable                 ; FA672D  44 68 87 fa 00
	ld	bc, (xix+hl)                          ; FA6732  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6737  cb cf ff
	jr z, .LFA675B                                ; FA673A  66 1f
	inc 2,XIX                                     ; FA673C  ec 62
	ld	d, (xix+hl)                           ; FA673E  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6743  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6747  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA674B  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA674F  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6753  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_WriteStagedAndPublish_Copy                                 ; FA6757  1d 88 08 f4
.LFA675B:
	ret                                           ; FA675B  0e

; ---------------------------------------------------------------------
; MidiIn_CC5E_Effect4Depth -- MIDI controller 0x5E, Effects 4 Depth
;
; Called from: MidiIn_ControllerHandlerTable[6], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x5E] = 6 selects this slot,
;          and MidiIn_IndexToControllerNumber[6] reads back 0x5E.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC5E_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC5E_Effect4Depth:   ; entry: MidiIn_ControllerHandlerTable[6]
	ld a, (MidiIn_CurrentPart:16)                            ; FA675C  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA6760  c9 cf 1f
	jr ugt, .LFA679C                              ; FA6763  6b 37
	xor W,W                                       ; FA6765  c8 d0
	ld HL,WA                                      ; FA6767  d8 8b
	sll wa, 0x01                                  ; FA6769  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA676C  d8 83
	ld XIX,MidiIn_CC5E_ParamTable                 ; FA676E  44 c8 87 fa 00
	ld	bc, (xix+hl)                          ; FA6773  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6778  cb cf ff
	jr z, .LFA679C                                ; FA677B  66 1f
	inc 2,XIX                                     ; FA677D  ec 62
	ld	d, (xix+hl)                           ; FA677F  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6784  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6788  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA678C  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6790  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6794  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_WriteStagedAndPublish_Copy                                 ; FA6798  1d 88 08 f4
.LFA679C:
	ret                                           ; FA679C  0e

; ---------------------------------------------------------------------
; MidiIn_CC5B_Effect1Depth -- MIDI controller 0x5B, Effects 1 Depth
;
; Called from: MidiIn_ControllerHandlerTable[7], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x5B] = 7 selects this slot,
;          and MidiIn_IndexToControllerNumber[7] reads back 0x5B.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC5B_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC5B_Effect1Depth:   ; entry: MidiIn_ControllerHandlerTable[7]
	ld a, (MidiIn_CurrentPart:16)                            ; FA679D  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA67A1  c9 cf 1f
	jr ugt, .LFA67E7                              ; FA67A4  6b 41
	xor W,W                                       ; FA67A6  c8 d0
	ld HL,WA                                      ; FA67A8  d8 8b
	sll wa, 0x01                                  ; FA67AA  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA67AD  d8 83
	ld XIX,MidiIn_CC5B_ParamTable                 ; FA67AF  44 28 88 fa 00
	ld	bc, (xix+hl)                          ; FA67B4  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA67B9  cb cf ff
	jr z, .LFA67E7                                ; FA67BC  66 29
	inc 2,XIX                                     ; FA67BE  ec 62
	ld	d, (xix+hl)                           ; FA67C0  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA67C5  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA67C9  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA67CD  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA67D1  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA67D5  f1 52 19 52   ld (0x1952),DE
	cp C,0x60                                     ; FA67D9  cb cf 60
	jr z, .LFA67E4                                ; FA67DC  66 06
	call T_ParamApply_WriteStagedAndPublish_Copy                                 ; FA67DE  1d 88 08 f4
	jr .LFA67E7                                   ; FA67E2  68 03
.LFA67E4:
	calr .LFA6D27                                 ; FA67E4  1e 40 05
.LFA67E7:
	ret                                           ; FA67E7  0e

; ---------------------------------------------------------------------
; MidiIn_CC02_Modulation2 -- MIDI controller 0x02, Breath controller
;
; Called from: MidiIn_ControllerHandlerTable[10], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x02] = 10 selects this slot,
;          and MidiIn_IndexToControllerNumber[10] reads back 0x02.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC02_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC02_Breath.  Controller 2 is what this
;          instrument's own on-screen list at 0xFA2BE3 calls
;          `MODULATION2(# 2)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Breath` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC02_Modulation2:   ; entry: MidiIn_ControllerHandlerTable[10]
	ld a, (MidiIn_CurrentPart:16)                            ; FA67E8  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA67EC  c9 cf ff
	jr nz, .LFA67FD                               ; FA67EF  6e 0c
	ld a, 0x00:opc                                   ; FA67F1  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA67F3  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA67F7  f1 7d 19 43   ld (0x197d),C
	jr .LFA6807                                   ; FA67FB  68 0a
.LFA67FD:
	ld c, (MidiIn_ChannelTag:16)                            ; FA67FD  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6801  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6871                                ; FA6805  66 6a
.LFA6807:
	cp A,0x1f                                     ; FA6807  c9 cf 1f
	jr ugt, .LFA6871                              ; FA680A  6b 65
	xor W,W                                       ; FA680C  c8 d0
	ld HL,WA                                      ; FA680E  d8 8b
	sll wa, 0x01                                  ; FA6810  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6813  d8 83
	ld XIX,MidiIn_CC02_ParamTable                 ; FA6815  44 88 88 fa 00
	ld	bc, (xix+hl)                          ; FA681A  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA681F  cb cf ff
	jr z, .LFA6871                                ; FA6822  66 4d
	inc 2,XIX                                     ; FA6824  ec 62
	ld	d, (xix+hl)                           ; FA6826  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA682B  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA682F  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6833  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6837  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA683B  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA683F  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA686D                               ; FA6844  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA6846  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA685F                               ; FA684A  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA684C  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA6850  c9 d9   cp A,1
	jr nz, .LFA685F                               ; FA6852  6e 0b
	ld (0x1958:16), bc                           ; FA6854  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA6858  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC02_Modulation2                                   ; FA685C  1e b8 12   calr 0xfa7b17
.LFA685F:
	ld XIX,0x00001950                             ; FA685F  44 50 19 00 00
	push XIX                                      ; FA6864  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6865  1d 0c 08 f4
	inc 4,XSP                                     ; FA6869  ef 64
	jr .LFA6871                                   ; FA686B  68 04
.LFA686D:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA686D  1d 8c 08 f4
.LFA6871:
	ret                                           ; FA6871  0e

; ---------------------------------------------------------------------
; MidiIn_CC04_CtrlPedal -- MIDI controller 0x04, Foot controller
;
; Called from: MidiIn_ControllerHandlerTable[11], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x04] = 11 selects this slot,
;          and MidiIn_IndexToControllerNumber[11] reads back 0x04.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC04_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC04_Foot.  Controller 4 is what this
;          instrument's own on-screen list at 0xFA2BF3 calls
;          `CTRL.PEDAL (# 4)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Foot` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC04_CtrlPedal:   ; entry: MidiIn_ControllerHandlerTable[11]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6872  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6876  c9 cf ff
	jr nz, .LFA6887                               ; FA6879  6e 0c
	ld a, 0x00:opc                                   ; FA687B  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA687D  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6881  f1 7d 19 43   ld (0x197d),C
	jr .LFA6891                                   ; FA6885  68 0a
.LFA6887:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6887  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA688B  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA68FB                                ; FA688F  66 6a
.LFA6891:
	cp A,0x1f                                     ; FA6891  c9 cf 1f
	jr ugt, .LFA68FB                              ; FA6894  6b 65
	xor W,W                                       ; FA6896  c8 d0
	ld HL,WA                                      ; FA6898  d8 8b
	sll wa, 0x01                                  ; FA689A  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA689D  d8 83
	ld XIX,MidiIn_CC04_ParamTable                 ; FA689F  44 e8 88 fa 00
	ld	bc, (xix+hl)                          ; FA68A4  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA68A9  cb cf ff
	jr z, .LFA68FB                                ; FA68AC  66 4d
	inc 2,XIX                                     ; FA68AE  ec 62
	ld	d, (xix+hl)                           ; FA68B0  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA68B5  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA68B9  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA68BD  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA68C1  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA68C5  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA68C9  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA68F7                               ; FA68CE  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA68D0  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA68E9                               ; FA68D4  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA68D6  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA68DA  c9 d9   cp A,1
	jr nz, .LFA68E9                               ; FA68DC  6e 0b
	ld (0x1958:16), bc                           ; FA68DE  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA68E2  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC04_CtrlPedal                                   ; FA68E6  1e 9c 12   calr 0xfa7b85
.LFA68E9:
	ld XIX,0x00001950                             ; FA68E9  44 50 19 00 00
	push XIX                                      ; FA68EE  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA68EF  1d 0c 08 f4
	inc 4,XSP                                     ; FA68F3  ef 64
	jr .LFA68FB                                   ; FA68F5  68 04
.LFA68F7:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA68F7  1d 8c 08 f4
.LFA68FB:
	ret                                           ; FA68FB  0e

; ---------------------------------------------------------------------
; MidiIn_CC10_RTCreatX -- MIDI controller 0x10, General Purpose 1
;
; Called from: MidiIn_ControllerHandlerTable[12], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x10] = 12 selects this slot,
;          and MidiIn_IndexToControllerNumber[12] reads back 0x10.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC10_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC10_General1.  Controller 16 is what this
;          instrument's own on-screen list at 0xFA2C23 calls
;          `R.T.CREAT.X(#16)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General1` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC10_RTCreatX:   ; entry: MidiIn_ControllerHandlerTable[12]
	ld a, (MidiIn_CurrentPart:16)                            ; FA68FC  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6900  c9 cf ff
	jr nz, .LFA6911                               ; FA6903  6e 0c
	ld a, 0x00:opc                                   ; FA6905  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6907  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA690B  f1 7d 19 43   ld (0x197d),C
	jr .LFA691B                                   ; FA690F  68 0a
.LFA6911:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6911  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6915  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6985                                ; FA6919  66 6a
.LFA691B:
	cp A,0x1f                                     ; FA691B  c9 cf 1f
	jr ugt, .LFA6985                              ; FA691E  6b 65
	xor W,W                                       ; FA6920  c8 d0
	ld HL,WA                                      ; FA6922  d8 8b
	sll wa, 0x01                                  ; FA6924  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6927  d8 83
	ld XIX,MidiIn_CC10_ParamTable                 ; FA6929  44 48 89 fa 00
	ld	bc, (xix+hl)                          ; FA692E  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6933  cb cf ff
	jr z, .LFA6985                                ; FA6936  66 4d
	inc 2,XIX                                     ; FA6938  ec 62
	ld	d, (xix+hl)                           ; FA693A  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA693F  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6943  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6947  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA694B  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA694F  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA6953  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA6981                               ; FA6958  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA695A  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA6973                               ; FA695E  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA6960  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA6964  c9 d9   cp A,1
	jr nz, .LFA6973                               ; FA6966  6e 0b
	ld (0x1958:16), bc                           ; FA6968  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA696C  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC10_RTCreatX                                   ; FA6970  1e ec 0f   calr 0xfa795f
.LFA6973:
	ld XIX,0x00001950                             ; FA6973  44 50 19 00 00
	push XIX                                      ; FA6978  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6979  1d 0c 08 f4
	inc 4,XSP                                     ; FA697D  ef 64
	jr .LFA6985                                   ; FA697F  68 04
.LFA6981:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA6981  1d 8c 08 f4
.LFA6985:
	ret                                           ; FA6985  0e

; ---------------------------------------------------------------------
; MidiIn_CC11_RTCreatY -- MIDI controller 0x11, General Purpose 2
;
; Called from: MidiIn_ControllerHandlerTable[13], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x11] = 13 selects this slot,
;          and MidiIn_IndexToControllerNumber[13] reads back 0x11.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC11_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC11_General2.  Controller 17 is what this
;          instrument's own on-screen list at 0xFA2C33 calls
;          `R.T.CREAT.Y(#17)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General2` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC11_RTCreatY:   ; entry: MidiIn_ControllerHandlerTable[13]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6986  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA698A  c9 cf ff
	jr nz, .LFA699B                               ; FA698D  6e 0c
	ld a, 0x00:opc                                   ; FA698F  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6991  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6995  f1 7d 19 43   ld (0x197d),C
	jr .LFA69A5                                   ; FA6999  68 0a
.LFA699B:
	ld c, (MidiIn_ChannelTag:16)                            ; FA699B  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA699F  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6A0F                                ; FA69A3  66 6a
.LFA69A5:
	cp A,0x1f                                     ; FA69A5  c9 cf 1f
	jr ugt, .LFA6A0F                              ; FA69A8  6b 65
	xor W,W                                       ; FA69AA  c8 d0
	ld HL,WA                                      ; FA69AC  d8 8b
	sll wa, 0x01                                  ; FA69AE  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA69B1  d8 83
	ld XIX,MidiIn_CC11_ParamTable                 ; FA69B3  44 a8 89 fa 00
	ld	bc, (xix+hl)                          ; FA69B8  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA69BD  cb cf ff
	jr z, .LFA6A0F                                ; FA69C0  66 4d
	inc 2,XIX                                     ; FA69C2  ec 62
	ld	d, (xix+hl)                           ; FA69C4  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA69C9  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA69CD  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA69D1  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA69D5  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA69D9  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA69DD  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA6A0B                               ; FA69E2  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA69E4  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA69FD                               ; FA69E8  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA69EA  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA69EE  c9 d9   cp A,1
	jr nz, .LFA69FD                               ; FA69F0  6e 0b
	ld (0x1958:16), bc                           ; FA69F2  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA69F6  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC11_RTCreatY                                   ; FA69FA  1e d0 0f   calr 0xfa79cd
.LFA69FD:
	ld XIX,0x00001950                             ; FA69FD  44 50 19 00 00
	push XIX                                      ; FA6A02  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6A03  1d 0c 08 f4
	inc 4,XSP                                     ; FA6A07  ef 64
	jr .LFA6A0F                                   ; FA6A09  68 04
.LFA6A0B:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA6A0B  1d 8c 08 f4
.LFA6A0F:
	ret                                           ; FA6A0F  0e

; ---------------------------------------------------------------------
; MidiIn_CC12_RTCtrlX -- MIDI controller 0x12, General Purpose 3
;
; Called from: MidiIn_ControllerHandlerTable[14], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x12] = 14 selects this slot,
;          and MidiIn_IndexToControllerNumber[14] reads back 0x12.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC12_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC12_General3.  Controller 18 is what this
;          instrument's own on-screen list at 0xFA2C43 calls
;          `R.T.CTRL. X(#18)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General3` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC12_RTCtrlX:   ; entry: MidiIn_ControllerHandlerTable[14]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6A10  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6A14  c9 cf ff
	jr nz, .LFA6A25                               ; FA6A17  6e 0c
	ld a, 0x00:opc                                   ; FA6A19  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6A1B  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6A1F  f1 7d 19 43   ld (0x197d),C
	jr .LFA6A2F                                   ; FA6A23  68 0a
.LFA6A25:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6A25  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6A29  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6A99                                ; FA6A2D  66 6a
.LFA6A2F:
	cp A,0x1f                                     ; FA6A2F  c9 cf 1f
	jr ugt, .LFA6A99                              ; FA6A32  6b 65
	xor W,W                                       ; FA6A34  c8 d0
	ld HL,WA                                      ; FA6A36  d8 8b
	sll wa, 0x01                                  ; FA6A38  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6A3B  d8 83
	ld XIX,MidiIn_CC12_ParamTable                 ; FA6A3D  44 08 8a fa 00
	ld	bc, (xix+hl)                          ; FA6A42  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6A47  cb cf ff
	jr z, .LFA6A99                                ; FA6A4A  66 4d
	inc 2,XIX                                     ; FA6A4C  ec 62
	ld	d, (xix+hl)                           ; FA6A4E  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6A53  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6A57  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6A5B  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6A5F  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6A63  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA6A67  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA6A95                               ; FA6A6C  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA6A6E  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA6A87                               ; FA6A72  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA6A74  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA6A78  c9 d9   cp A,1
	jr nz, .LFA6A87                               ; FA6A7A  6e 0b
	ld (0x1958:16), bc                           ; FA6A7C  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA6A80  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC12_RTCtrlX                                   ; FA6A84  1e b4 0f   calr 0xfa7a3b
.LFA6A87:
	ld XIX,0x00001950                             ; FA6A87  44 50 19 00 00
	push XIX                                      ; FA6A8C  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6A8D  1d 0c 08 f4
	inc 4,XSP                                     ; FA6A91  ef 64
	jr .LFA6A99                                   ; FA6A93  68 04
.LFA6A95:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA6A95  1d 8c 08 f4
.LFA6A99:
	ret                                           ; FA6A99  0e

; ---------------------------------------------------------------------
; MidiIn_CC13_RTCtrlY -- MIDI controller 0x13, General Purpose 4
;
; Called from: MidiIn_ControllerHandlerTable[15], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x13] = 15 selects this slot,
;          and MidiIn_IndexToControllerNumber[15] reads back 0x13.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC13_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
;
; ★ RENAMED FROM MidiIn_CC13_General4.  Controller 19 is what this
;          instrument's own on-screen list at 0xFA2C53 calls
;          `R.T.CTRL. Y(#19)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General4` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiIn_CC13_RTCtrlY:   ; entry: MidiIn_ControllerHandlerTable[15]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6A9A  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6A9E  c9 cf ff
	jr nz, .LFA6AAF                               ; FA6AA1  6e 0c
	ld a, 0x00:opc                                   ; FA6AA3  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6AA5  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6AA9  f1 7d 19 43   ld (0x197d),C
	jr .LFA6AB9                                   ; FA6AAD  68 0a
.LFA6AAF:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6AAF  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6AB3  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6B23                                ; FA6AB7  66 6a
.LFA6AB9:
	cp A,0x1f                                     ; FA6AB9  c9 cf 1f
	jr ugt, .LFA6B23                              ; FA6ABC  6b 65
	xor W,W                                       ; FA6ABE  c8 d0
	ld HL,WA                                      ; FA6AC0  d8 8b
	sll wa, 0x01                                  ; FA6AC2  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6AC5  d8 83
	ld XIX,MidiIn_CC13_ParamTable                 ; FA6AC7  44 68 8a fa 00
	ld	bc, (xix+hl)                          ; FA6ACC  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6AD1  cb cf ff
	jr z, .LFA6B23                                ; FA6AD4  66 4d
	inc 2,XIX                                     ; FA6AD6  ec 62
	ld	d, (xix+hl)                           ; FA6AD8  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6ADD  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6AE1  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6AE5  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6AE9  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6AED  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA6AF1  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA6B1F                               ; FA6AF6  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA6AF8  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA6B11                               ; FA6AFC  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA6AFE  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA6B02  c9 d9   cp A,1
	jr nz, .LFA6B11                               ; FA6B04  6e 0b
	ld (0x1958:16), bc                           ; FA6B06  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA6B0A  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_CC13_RTCtrlY                                   ; FA6B0E  1e 98 0f   calr 0xfa7aa9
.LFA6B11:
	ld XIX,0x00001950                             ; FA6B11  44 50 19 00 00
	push XIX                                      ; FA6B16  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6B17  1d 0c 08 f4
	inc 4,XSP                                     ; FA6B1B  ef 64
	jr .LFA6B23                                   ; FA6B1D  68 04
.LFA6B1F:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA6B1F  1d 8c 08 f4
.LFA6B23:
	ret                                           ; FA6B23  0e

; ---------------------------------------------------------------------
; MidiIn_CC51_General6 -- MIDI controller 0x51, General Purpose 6
;
; Called from: MidiIn_ControllerHandlerTable[18], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x51] = 18 selects this slot,
;          and MidiIn_IndexToControllerNumber[18] reads back 0x51.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC51_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 3.
; ---------------------------------------------------------------------
MidiIn_CC51_General6:   ; entry: MidiIn_ControllerHandlerTable[18]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6B24  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA6B28  c9 cf 1f
	jr ugt, .LFA6B64                              ; FA6B2B  6b 37
	xor W,W                                       ; FA6B2D  c8 d0
	ld HL,WA                                      ; FA6B2F  d8 8b
	sll wa, 0x01                                  ; FA6B31  d8 ee 01   sll 0x01,WA
	add HL,WA                                     ; FA6B34  d8 83
	ld XIX,MidiIn_CC51_ParamTable                 ; FA6B36  44 c8 8a fa 00
	ld	bc, (xix+hl)                          ; FA6B3B  d3 07 f0 ec 21   ld BC,(XIX+HL)
	cp C,0xff                                     ; FA6B40  cb cf ff
	jr z, .LFA6B64                                ; FA6B43  66 1f
	inc 2,XIX                                     ; FA6B45  ec 62
	ld	d, (xix+hl)                           ; FA6B47  c3 07 f0 ec 24   ld D,(XIX+HL)
	ld e, (MidiIn_MsgData2:16)                            ; FA6B4C  c1 42 19 25   ld E,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6B50  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6B54  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6B58  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6B5C  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_OneHotOfSix                                 ; FA6B60  1d 9c 08 f4
.LFA6B64:
	ret                                           ; FA6B64  0e

; ---------------------------------------------------------------------
; MidiIn_CC06_DataEntMSB -- MIDI controller 0x06, Data Entry MSB
;
; Called from: MidiIn_ControllerHandlerTable[32], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x06] = 32 selects this slot,
;          and MidiIn_IndexToControllerNumber[32] reads back 0x06.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; ---------------------------------------------------------------------
MidiIn_CC06_DataEntMSB:   ; entry: MidiIn_ControllerHandlerTable[32]
	ld l, (MidiIn_CurrentPart:16)                            ; FA6B65  c1 76 19 27   ld L,(0x1976)
	cp L,0x1f                                     ; FA6B69  cf cf 1f
	jrl ugt, .LFA6BF4                             ; FA6B6C  7b 85 00
	extz HL                                       ; FA6B6F  db 12
	ld XIX,MidiIn_PartIdentityMap                 ; FA6B71  44 68 8c fa 00
	ld	c, (xix+hl)                           ; FA6B76  c3 07 f0 ec 23   ld C,(XIX+HL)
	cp C,0xff                                     ; FA6B7B  cb cf ff
	jr z, .LFA6BF4                                ; FA6B7E  66 74
	extz WA                                       ; FA6B80  d8 12
	ld A,C                                        ; FA6B82  cb 89
	sll wa, 0x02                                  ; FA6B84  d8 ee 02   sll 0x02,WA
	ld xiy, (IndexedTable_Base:24)                        ; FA6B87  e2 18 f0 60 25   ld XIY,(0x60f018)
	ld	xiy, (xiy+wa)                         ; FA6B8C  e3 07 f4 e0 25   ld XIY,(XIY+WA)
	sll hl, 0x01                                  ; FA6B91  db ee 01   sll 0x01,HL
	ld XIX,0x00001980                             ; FA6B94  44 80 19 00 00
	ld	wa, (xix+hl)                          ; FA6B99  d3 07 f0 ec 20   ld WA,(XIX+HL)
	cp WA,0x8080                                  ; FA6B9E  d8 cf 80 80
	jr z, .LFA6BB2                                ; FA6BA2  66 0e
	cp WA,0x8081                                  ; FA6BA4  d8 cf 81 80
	jr z, .LFA6BC1                                ; FA6BA8  66 17
	cp WA,0x8082                                  ; FA6BAA  d8 cf 82 80
	jr z, .LFA6BCE                                ; FA6BAE  66 1e
	jr .LFA6BF4                                   ; FA6BB0  68 42
.LFA6BB2:
	ld b, 0x0b:opc                                   ; FA6BB2  22 0b   ld B,0x0b
	ld e, (MidiIn_MsgData2:16)                            ; FA6BB4  c1 42 19 25   ld E,(0x1942)
	cp E,0x0c                                     ; FA6BB8  cd cf 0c
	jr ugt, .LFA6BF4                              ; FA6BBB  6b 37
	ld d, 0x7f:opc                                   ; FA6BBD  24 7f   ld D,0x7f
	jr .LFA6BE0                                   ; FA6BBF  68 1f
.LFA6BC1:
	ld b, 0x0a:opc                                   ; FA6BC1  22 0a   ld B,0x0a
	ld e, (MidiIn_MsgData2:16)                            ; FA6BC3  c1 42 19 25   ld E,(0x1942)
	sll e, 0x01                                   ; FA6BC7  cd ee 01   sll 0x01,E
	ld d, 0xff:opc                                   ; FA6BCA  24 ff   ld D,0xff
	jr .LFA6BE0                                   ; FA6BCC  68 12
.LFA6BCE:
	ld b, 0x09:opc                                   ; FA6BCE  22 09   ld B,0x09
	ld e, (MidiIn_MsgData2:16)                            ; FA6BD0  c1 42 19 25   ld E,(0x1942)
	cp E,0x64                                     ; FA6BD4  cd cf 64
	jr ugt, .LFA6BF4                              ; FA6BD7  6b 1b
	cp E,0x1c                                     ; FA6BD9  cd cf 1c
	jr c, .LFA6BF4                                ; FA6BDC  67 16
	ld d, 0x7f:opc                                   ; FA6BDE  24 7f   ld D,0x7f
.LFA6BE0:
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6BE0  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6BE4  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6BE8  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6BEC  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_WriteStagedAndPublish                                 ; FA6BF0  1d 78 08 f4
.LFA6BF4:
	ret                                           ; FA6BF4  0e

; ---------------------------------------------------------------------
; MidiIn_CC26_DataEntLSB -- MIDI controller 0x26, Data Entry LSB
;
; Called from: MidiIn_ControllerHandlerTable[33], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x26] = 33 selects this slot,
;          and MidiIn_IndexToControllerNumber[33] reads back 0x26.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; ---------------------------------------------------------------------
MidiIn_CC26_DataEntLSB:   ; entry: MidiIn_ControllerHandlerTable[33]
	ld l, (MidiIn_CurrentPart:16)                            ; FA6BF5  c1 76 19 27   ld L,(0x1976)
	cp L,0x1f                                     ; FA6BF9  cf cf 1f
	jr ugt, .LFA6C5A                              ; FA6BFC  6b 5c
	extz HL                                       ; FA6BFE  db 12
	ld XIX,MidiIn_PartIdentityMap                 ; FA6C00  44 68 8c fa 00
	ld	c, (xix+hl)                           ; FA6C05  c3 07 f0 ec 23   ld C,(XIX+HL)
	cp C,0xff                                     ; FA6C0A  cb cf ff
	jr z, .LFA6C5A                                ; FA6C0D  66 4b
	sll hl, 0x01                                  ; FA6C0F  db ee 01   sll 0x01,HL
	ld XIX,0x00001980                             ; FA6C12  44 80 19 00 00
	cpw	(xix+hl), 0x8081                     ; FA6C17  d3 07 f0 ec 3f 81 80
	jr nz, .LFA6C5A                               ; FA6C1E  6e 3a
	ld b, 0x0a:opc                                   ; FA6C20  22 0a   ld B,0x0a
	ld xix, (IndexedTable_Base:24)                        ; FA6C22  e2 18 f0 60 24   ld XIX,(0x60f018)
	extz HL                                       ; FA6C27  db 12
	ld l, (MidiIn_CurrentPart:16)                            ; FA6C29  c1 76 19 27   ld L,(0x1976)
	sll hl, 0x02                                  ; FA6C2D  db ee 02   sll 0x02,HL
	ld	xix, (xix+hl)                         ; FA6C30  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	ld A,(XIX+0x0a)                               ; FA6C35  8c 0a 21
	res 0x00,A                                    ; FA6C38  c9 30 00
	ld e, (MidiIn_MsgData2:16)                            ; FA6C3B  c1 42 19 25   ld E,(0x1942)
	srl e, 0x06                                   ; FA6C3F  cd ef 06   srl 0x06,E
	or E,A                                        ; FA6C42  c9 e5
	ld d, 0xff:opc                                   ; FA6C44  24 ff   ld D,0xff
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6C46  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6C4A  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6C4E  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6C52  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_WriteStagedAndPublish                                 ; FA6C56  1d 78 08 f4
.LFA6C5A:
	ret                                           ; FA6C5A  0e

; ---------------------------------------------------------------------
; MidiIn_CC65_RpnMSB -- MIDI controller 0x65, RPN MSB
;
; Called from: MidiIn_ControllerHandlerTable[34], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x65] = 34 selects this slot,
;          and MidiIn_IndexToControllerNumber[34] reads back 0x65.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; ---------------------------------------------------------------------
MidiIn_CC65_RpnMSB:   ; entry: MidiIn_ControllerHandlerTable[34]
	ld a, (MidiIn_MsgData2:16)                            ; FA6C5B  c1 42 19 21   ld A,(0x1942)
	set 0x07,A                                    ; FA6C5F  c9 31 07
	extz HL                                       ; FA6C62  db 12
	ld l, (MidiIn_CurrentPart:16)                            ; FA6C64  c1 76 19 27   ld L,(0x1976)
	sll hl, 0x01                                  ; FA6C68  db ee 01   sll 0x01,HL
	ld XIX,0x00001981                             ; FA6C6B  44 81 19 00 00
	ld	(xix+hl), a                           ; FA6C70  f3 07 f0 ec 41   ld (XIX+HL),A
	dec 1,XIX                                     ; FA6C75  ec 69
	ld	w, (xix+hl)                           ; FA6C77  c3 07 f0 ec 20   ld W,(XIX+HL)
	cp WA,0xffff                                  ; FA6C7C  d8 cf ff ff
	jr nz, .LFA6C89                               ; FA6C80  6e 07
	ldw	(xix+hl), 0x7f7f                     ; FA6C82  f3 07 f0 ec 02 7f 7f
.LFA6C89:
	ret                                           ; FA6C89  0e

; ---------------------------------------------------------------------
; MidiIn_CC64_RpnLSB -- MIDI controller 0x64, RPN LSB
;
; Called from: MidiIn_ControllerHandlerTable[35], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x64] = 35 selects this slot,
;          and MidiIn_IndexToControllerNumber[35] reads back 0x64.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; ---------------------------------------------------------------------
MidiIn_CC64_RpnLSB:   ; entry: MidiIn_ControllerHandlerTable[35]
	ld a, (MidiIn_MsgData2:16)                            ; FA6C8A  c1 42 19 21   ld A,(0x1942)
	set 0x07,A                                    ; FA6C8E  c9 31 07
	extz HL                                       ; FA6C91  db 12
	ld l, (MidiIn_CurrentPart:16)                            ; FA6C93  c1 76 19 27   ld L,(0x1976)
	sll hl, 0x01                                  ; FA6C97  db ee 01   sll 0x01,HL
	ld XIX,0x00001980                             ; FA6C9A  44 80 19 00 00
	ld	(xix+hl), a                           ; FA6C9F  f3 07 f0 ec 41   ld (XIX+HL),A
	inc 1,XIX                                     ; FA6CA4  ec 61
	ld	w, (xix+hl)                           ; FA6CA6  c3 07 f0 ec 20   ld W,(XIX+HL)
	cp WA,0xffff                                  ; FA6CAB  d8 cf ff ff
	jr nz, .LFA6CBA                               ; FA6CAF  6e 09
	dec 1,XIX                                     ; FA6CB1  ec 69
	ldw	(xix+hl), 0x7f7f                     ; FA6CB3  f3 07 f0 ec 02 7f 7f
.LFA6CBA:
	ret                                           ; FA6CBA  0e

; ---------------------------------------------------------------------
; MidiIn_CC79_ResetAllCtrl -- MIDI controller 0x79, Reset All Controllers
;
; Called from: MidiIn_ControllerHandlerTable[40], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x79] = 40 selects this slot,
;          and MidiIn_IndexToControllerNumber[40] reads back 0x79.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC79_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 2.
; ---------------------------------------------------------------------
MidiIn_CC79_ResetAllCtrl:   ; entry: MidiIn_ControllerHandlerTable[40]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6CBB  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA6CBF  c9 cf 1f
	jr ugt, .LFA6CF0                              ; FA6CC2  6b 2c
	sll a, 0x01                                   ; FA6CC4  c9 ee 01   sll 0x01,A
	ld XIX,MidiIn_CC79_ParamTable                 ; FA6CC7  44 28 8b fa 00
	ld	bc, (xix+a)                           ; FA6CCC  d3 03 f0 e0 21   ld BC,(XIX+A)
	cp C,0xff                                     ; FA6CD1  cb cf ff
	jr z, .LFA6CF0                                ; FA6CD4  66 1a
	ld e, (MidiIn_MsgData2:16)                            ; FA6CD6  c1 42 19 25   ld E,(0x1942)
	ld d, 0x7f:opc                                   ; FA6CDA  24 7f   ld D,0x7f
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6CDC  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6CE0  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6CE4  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6CE8  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_PublishStagedAndPostSeven                                 ; FA6CEC  1d 7c 08 f4
.LFA6CF0:
	ret                                           ; FA6CF0  0e

; ---------------------------------------------------------------------
; MidiIn_CC78_AllSoundOff -- MIDI controller 0x78, All Sound Off
;
; Called from: MidiIn_ControllerHandlerTable[41], and nothing else.
; Evidence: TWO independent witnesses give the controller number.
;          MidiIn_ControllerNumberToIndex[0x78] = 41 selects this slot,
;          and MidiIn_IndexToControllerNumber[41] reads back 0x78.
;          The two maps are inverse on all 23 live entries of the
;          first (check M1).
; Reads:   MidiIn_CC78_ParamTable, indexed by the part number (0x1976), 32
;          records of stride 2.
; ---------------------------------------------------------------------
MidiIn_CC78_AllSoundOff:   ; entry: MidiIn_ControllerHandlerTable[41]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6CF1  c1 76 19 21   ld A,(0x1976)
	cp A,0x1f                                     ; FA6CF5  c9 cf 1f
	jr ugt, .LFA6D26                              ; FA6CF8  6b 2c
	sll a, 0x01                                   ; FA6CFA  c9 ee 01   sll 0x01,A
	ld XIX,MidiIn_CC78_ParamTable                 ; FA6CFD  44 68 8b fa 00
	ld	bc, (xix+a)                           ; FA6D02  d3 03 f0 e0 21   ld BC,(XIX+A)
	cp C,0xff                                     ; FA6D07  cb cf ff
	jr z, .LFA6D26                                ; FA6D0A  66 1a
	ld e, (MidiIn_MsgData2:16)                            ; FA6D0C  c1 42 19 25   ld E,(0x1942)
	ld d, 0x7f:opc                                   ; FA6D10  24 7f   ld D,0x7f
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6D12  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6D16  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6D1A  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6D1E  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_PublishStagedPairBCDE                                 ; FA6D22  1d 80 08 f4
.LFA6D26:
	ret                                           ; FA6D26  0e
.LFA6D27:

; ---------------------------------------------------------------------
; sub_FA6D27 -- the special arm of the CC 0x5B handler
;
; Called from: 0xFA67E4 (`calr`), inside MidiIn_CC5B_Effect1Depth, taken
;          only when the parameter id byte the table yielded is 0x60.
; Evidence: it rewrites (0x1952) to 0 or to the table's third byte on a
;          threshold of 0x40 -- `cp A,0x40 / jr C` -- and then calls
;          0xF40858 instead of 0xF40888.  What the 0x60 id and the two
;          senders mean is a question for the 0xFAD800 module.
; ---------------------------------------------------------------------
sub_FA6D27:   ; entry: call from 0xFA67E4
	ld a, (MidiIn_MsgData2:16)                            ; FA6D27  c1 42 19 21   ld A,(0x1942)
	ld de, (0x1952:16)                          ; FA6D2B  d1 52 19 22   ld DE,(0x1952)
	xor E,E                                       ; FA6D2F  cd d5
	cp A,0x40                                     ; FA6D31  c9 cf 40
	jr c, .LFA6D38                                ; FA6D34  67 02
	ld E,D                                        ; FA6D36  cc 8d
.LFA6D38:
	ld (0x1952:16), de                           ; FA6D38  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_MaskedWriteAndPublish                                 ; FA6D3C  1d 58 08 f4
	ret                                           ; FA6D40  0e
	ld E,A                                        ; FA6D41  c9 8d
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6D43  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6D47  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6D4B  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6D4F  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_WriteStagedAndPublish_Copy                                 ; FA6D53  1d 88 08 f4
	ret                                           ; FA6D57  0e

; ---------------------------------------------------------------------
; MidiIn_ProgramChange -- MIDI 0xCn, Program Change
;
; Called from: MidiIn_ChannelStatusTable[4], the 0xCn slot.
; Evidence: it reads ONE data byte -- `ld E,(0x1941) / ld D,0xFF` at
;          0xFA6DC8 -- which is Program Change's shape, and it is gated on
;          bit 4 of (0x7F39), the same enable array MidiIn_ControlChange
;          indexes.  Its per-part table is MidiOut_PartFlagsTable's
;          neighbour at 0xFA8BA8.
; ---------------------------------------------------------------------
MidiIn_ProgramChange:   ; entry: MidiIn_ChannelStatusTable[4]
	bit	4, (MidiFilter_ChannelMsgs:16)                        ; FA6D58  f1 39 7f cc   bit 4,(0x7f39)
	jrl z, .LFA6DE2                               ; FA6D5C  76 83 00
	ld a, (MidiIn_CurrentPart:16)                            ; FA6D5F  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6D63  c9 cf ff
	jr nz, .LFA6D91                               ; FA6D66  6e 29
	ld a, (MidiCfg_InOutMode:16)                            ; FA6D68  c1 35 7f 21   ld A,(0x7f35)
	and A,0x0f                                    ; FA6D6C  c9 cc 0f
	cp a, 0x00:i3                                   ; FA6D6F  c9 d8   cp A,0
	jr z, .LFA6DE2                                ; FA6D71  66 6f
	bit	3, (MidiCfg_ModeBits:16)                        ; FA6D73  f1 32 7f cb   bit 3,(0x7f32)
	jr z, .LFA6DE2                                ; FA6D77  66 69
	ld a, (0x7f02:16)                            ; FA6D79  c1 02 7f 21   ld A,(0x7f02)
	and A,0xf0                                    ; FA6D7D  c9 cc f0
	cp a, 0x00:i3                                   ; FA6D80  c9 d8   cp A,0
	jr z, .LFA6DE2                                ; FA6D82  66 5e
	ld c, (MidiIn_ChannelTag:16)                            ; FA6D84  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6D88  f1 7d 19 43   ld (0x197d),C
	ldw bc, 0x0198                                ; FA6D8C  31 98 01   ld BC,0x0198
	jr .LFA6DC8                                   ; FA6D8F  68 37
.LFA6D91:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6D91  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6D95  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6DE2                                ; FA6D99  66 47
	cp A,0x1f                                     ; FA6D9B  c9 cf 1f
	jr ugt, .LFA6DE2                              ; FA6D9E  6b 42
	ld xix, (IndexedTable_Base:24)                        ; FA6DA0  e2 18 f0 60 24   ld XIX,(0x60f018)
	extz HL                                       ; FA6DA5  db 12
	ld L,A                                        ; FA6DA7  c9 8f
	sll hl, 0x02                                  ; FA6DA9  db ee 02   sll 0x02,HL
	ld	xix, (xix+hl)                         ; FA6DAC  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	bit 4,(XIX+0x2f)                              ; FA6DB1  bc 2f cc
	jr z, .LFA6DE2                                ; FA6DB4  66 2c
	sll a, 0x01                                   ; FA6DB6  c9 ee 01   sll 0x01,A
	ld XIX,MidiIn_ProgramChange_ParamTable        ; FA6DB9  44 a8 8b fa 00
	ld	bc, (xix+a)                           ; FA6DBE  d3 03 f0 e0 21   ld BC,(XIX+A)
	cp C,0xff                                     ; FA6DC3  cb cf ff
	jr z, .LFA6DE2                                ; FA6DC6  66 1a
.LFA6DC8:
	ld e, (MidiIn_MsgData1:16)                            ; FA6DC8  c1 41 19 25   ld E,(0x1941)
	ld d, 0xff:opc                                   ; FA6DCC  24 ff   ld D,0xff
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6DCE  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6DD2  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6DD6  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6DDA  f1 52 19 52   ld (0x1952),DE
	call T_ParamApply_ByModeOfParam80                                 ; FA6DDE  1d 54 08 f4
.LFA6DE2:
	ret                                           ; FA6DE2  0e

; ---------------------------------------------------------------------
; MidiIn_PitchBend -- MIDI 0xEn, Pitch Bend
;
; Called from: MidiIn_ChannelStatusTable[6], the 0xEn slot.
; Evidence: it reads BOTH data bytes -- `ld E,(0x1941) / ld D,(0x1942)` at
;          0xFA6E1F -- and it is the only channel handler that does, which
;          is Pitch Bend's shape.  Gated on bit 6 of (0x7F39).
; ---------------------------------------------------------------------
MidiIn_PitchBend:   ; entry: MidiIn_ChannelStatusTable[6]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6DE3  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6DE7  c9 cf ff
	jr nz, .LFA6DF8                               ; FA6DEA  6e 0c
	ld a, 0x00:opc                                   ; FA6DEC  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6DEE  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6DF2  f1 7d 19 43   ld (0x197d),C
	jr .LFA6E02                                   ; FA6DF6  68 0a
.LFA6DF8:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6DF8  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6DFC  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6E69                                ; FA6E00  66 67
.LFA6E02:
	cp A,0x1f                                     ; FA6E02  c9 cf 1f
	jr ugt, .LFA6E69                              ; FA6E05  6b 62
	bit	6, (MidiFilter_ChannelMsgs:16)                        ; FA6E07  f1 39 7f ce   bit 6,(0x7f39)
	jr z, .LFA6E69                                ; FA6E0B  66 5c
	sll a, 0x01                                   ; FA6E0D  c9 ee 01   sll 0x01,A
	ld XIX,MidiIn_PitchBend_ParamTable            ; FA6E10  44 e8 8b fa 00
	ld	bc, (xix+a)                           ; FA6E15  d3 03 f0 e0 21   ld BC,(XIX+A)
	cp C,0xff                                     ; FA6E1A  cb cf ff
	jr z, .LFA6E69                                ; FA6E1D  66 4a
	ld e, (MidiIn_MsgData1:16)                            ; FA6E1F  c1 41 19 25   ld E,(0x1941)
	ld d, (MidiIn_MsgData2:16)                            ; FA6E23  c1 42 19 24   ld D,(0x1942)
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6E27  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6E2B  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6E2F  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6E33  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA6E37  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA6E65                               ; FA6E3C  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA6E3E  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA6E57                               ; FA6E42  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA6E44  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA6E48  c9 d9   cp A,1
	jr nz, .LFA6E57                               ; FA6E4A  6e 0b
	ld (0x1958:16), bc                           ; FA6E4C  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA6E50  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_PitchBend                                   ; FA6E54  1e 27 08   calr 0xfa767e
.LFA6E57:
	ld XIX,0x00001950                             ; FA6E57  44 50 19 00 00
	push XIX                                      ; FA6E5C  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6E5D  1d 0c 08 f4
	inc 4,XSP                                     ; FA6E61  ef 64
	jr .LFA6E69                                   ; FA6E63  68 04
.LFA6E65:
	call T_ParamShadow_SetPitchBend                                 ; FA6E65  1d 64 08 f4
.LFA6E69:
	ret                                           ; FA6E69  0e

; ---------------------------------------------------------------------
; MidiIn_ChannelPressure -- MIDI 0xDn, Channel Pressure
;
; Called from: MidiIn_ChannelStatusTable[5], the 0xDn slot.
; Evidence: one data byte, `ld E,(0x1941) / ld D,0x7F` at 0xFA6EA6.  Gated
;          on bit 5 of (0x7F39) -- bits 4, 5 and 6 of that byte gate
;          Program Change, Channel Pressure and Pitch Bend in table order.
; ---------------------------------------------------------------------
MidiIn_ChannelPressure:   ; entry: MidiIn_ChannelStatusTable[5]
	ld a, (MidiIn_CurrentPart:16)                            ; FA6E6A  c1 76 19 21   ld A,(0x1976)
	cp A,0xff                                     ; FA6E6E  c9 cf ff
	jr nz, .LFA6E7F                               ; FA6E71  6e 0c
	ld a, 0x00:opc                                   ; FA6E73  21 00   ld A,0x00
	ld c, (MidiIn_ChannelTag:16)                            ; FA6E75  c1 7e 19 23   ld C,(0x197e)
	ld (0x197d:16), c                            ; FA6E79  f1 7d 19 43   ld (0x197d),C
	jr .LFA6E89                                   ; FA6E7D  68 0a
.LFA6E7F:
	ld c, (MidiIn_ChannelTag:16)                            ; FA6E7F  c1 7e 19 23   ld C,(0x197e)
	cp	c, (0x197d:16)                        ; FA6E83  c1 7d 19 f3   cp C,(0x197d)
	jr z, .LFA6EEE                                ; FA6E87  66 65
.LFA6E89:
	cp A,0x1f                                     ; FA6E89  c9 cf 1f
	jr ugt, .LFA6EEE                              ; FA6E8C  6b 60
	bit	5, (MidiFilter_ChannelMsgs:16)                        ; FA6E8E  f1 39 7f cd   bit 5,(0x7f39)
	jr z, .LFA6EEE                                ; FA6E92  66 5a
	sll a, 0x01                                   ; FA6E94  c9 ee 01   sll 0x01,A
	ld XIX,MidiIn_ChannelPressure_ParamTable      ; FA6E97  44 28 8c fa 00
	ld	bc, (xix+a)                           ; FA6E9C  d3 03 f0 e0 21   ld BC,(XIX+A)
	cp C,0xff                                     ; FA6EA1  cb cf ff
	jr z, .LFA6EEE                                ; FA6EA4  66 48
	ld e, (MidiIn_MsgData1:16)                            ; FA6EA6  c1 41 19 25   ld E,(0x1941)
	ld d, 0x7f:opc                                   ; FA6EAA  24 7f   ld D,0x7f
	ld a, (MidiIn_MsgPortTag:16)                            ; FA6EAC  c1 43 19 21   ld A,(0x1943)
	ld (0x1954:16), a                            ; FA6EB0  f1 54 19 41   ld (0x1954),A
	ld (0x1950:16), bc                           ; FA6EB4  f1 50 19 51   ld (0x1950),BC
	ld (0x1952:16), de                           ; FA6EB8  f1 52 19 52   ld (0x1952),DE
	cp	(MidiIn_CurrentPart:16), 0xff                     ; FA6EBC  c1 76 19 3f ff   cp (0x1976),0xff
	jr nz, .LFA6EEA                               ; FA6EC1  6e 27
	cp	(Variant_Flag:8), 0x02                        ; FA6EC3  c0 c4 3f 02   cp (0xc4),0x02
	jr nz, .LFA6EDC                               ; FA6EC7  6e 13
	ld a, (MidiCfg_InOutMode:16)                            ; FA6EC9  c1 35 7f 21   ld A,(0x7f35)
	cp a, 0x01:i3                                   ; FA6ECD  c9 d9   cp A,1
	jr nz, .LFA6EDC                               ; FA6ECF  6e 0b
	ld (0x1958:16), bc                           ; FA6ED1  f1 58 19 51   ld (0x1958),BC
	ld (0x195a:16), de                           ; FA6ED5  f1 5a 19 52   ld (0x195a),DE
	calr MidiOut_ChannelPressure                                   ; FA6ED9  1e 1e 09   calr 0xfa77fa
.LFA6EDC:
	ld XIX,0x00001950                             ; FA6EDC  44 50 19 00 00
	push XIX                                      ; FA6EE1  3c
	call T_MidiIn_ControlRecord_Dispatch                                 ; FA6EE2  1d 0c 08 f4
	inc 4,XSP                                     ; FA6EE6  ef 64
	jr .LFA6EEE                                   ; FA6EE8  68 04
.LFA6EEA:
	call T_ParamApply_PublishStagedPair_Copy                                 ; FA6EEA  1d 8c 08 f4
.LFA6EEE:
	ret                                           ; FA6EEE  0e

; ---------------------------------------------------------------------
; MidiIn_ReqRouteRebuild_Msg0D -- ask for a channel-route rebuild
;
; Called from: prom_b directory slot T_MidiIn_ReqRouteRebuild_Msg0D (T_F40754) (`jp 0xFA6EEF`).
; Outputs: bit 0 of (0x1978) set, but only when (0x20B8) == 0x0D and
;          (0x20BA) & 0xDF is non-zero.
; Evidence: (0x20B8) is the message/page number the 0xFC0000 module
;          dispatches on (notes/FINDINGS-prom_a-msg0716-module.md), so this
;          is a hook on one UI message.  Bit 0 of (0x1978) is exactly what
;          MidiIn_ServiceRouteRebuild tests and clears.
; ---------------------------------------------------------------------
MidiIn_ReqRouteRebuild_Msg0D:   ; entry: prom_b directory slot T_MidiIn_ReqRouteRebuild_Msg0D (T_F40754)
	cp	(UiEvent_Byte1:16), 0x0d                     ; FA6EEF  c1 b8 20 3f 0d   cp (0x20b8),0x0d
	jr nz, .LFA6F03                               ; FA6EF4  6e 0d
	ld a, (UiEvent_Byte3:16)                            ; FA6EF6  c1 ba 20 21   ld A,(0x20ba)
	and A,0xdf                                    ; FA6EFA  c9 cc df
	jr z, .LFA6F03                                ; FA6EFD  66 04
	set	0, (0x1978:16)                        ; FA6EFF  f1 78 19 b8   set 0,(0x1978)
.LFA6F03:
	ret                                           ; FA6F03  0e

; ---------------------------------------------------------------------
; MidiIn_ServiceDeferred -- run whatever (0x1978) has queued
;
; Called from: prom_b directory slot T_MidiIn_ServiceDeferred (T_F40758) (`jp 0xFA6F04`).
; Evidence: two calls and a return -- MidiIn_ServiceRouteRebuild for bit 0
;          and MidiIn_ServicePartLists for bit 1.
; ---------------------------------------------------------------------
MidiIn_ServiceDeferred:   ; entry: prom_b directory slot T_MidiIn_ServiceDeferred (T_F40758)
	calr .LFA6F0B                                 ; FA6F04  1e 04 00
	calr MidiIn_ServicePartLists                                   ; FA6F07  1e 96 14   calr 0xfa83a0
	ret                                           ; FA6F0A  0e
.LFA6F0B:
MidiIn_ServiceRouteRebuild:   ; entry: call from 0xFA6F04
	bit	0, (0x1978:16)                        ; FA6F0B  f1 78 19 c8   bit 0,(0x1978)
	jr z, .LFA6F20                                ; FA6F0F  66 0f
	res	0, (0x1978:16)                        ; FA6F11  f1 78 19 b0   res 0,(0x1978)
	ld (0x1979:16), 0x80                          ; FA6F15  f1 79 19 00 80   ld (0x1979),0x80
	calr .LFA6F21                                 ; FA6F1A  1e 04 00
	calr .LFA701C                                 ; FA6F1D  1e fc 00
.LFA6F20:
	ret                                           ; FA6F20  0e
.LFA6F21:

; ---------------------------------------------------------------------
; MidiIn_BuildChannelRouteTable -- rebuild 0x1800/0x1820 from the part records
;
; Called from: MidiIn_ServiceRouteRebuild 0xFA6F1A (`calr`), its only caller.
; Outputs: 0x1800[0..0x1F] = the offset of that channel's list in 0x1820,
;          and each list is `count, part, part, ...`.
; Evidence: the outer loop runs W = 0..0x1F (`cp (0x197A),0x20`), the inner
;          one runs (0x197C) = 0..0x1F over the 32 part structures reached
;          through (0x60F018), and the channel it matches on is byte +0x0D
;          of each structure masked with 0x1F.  The count is written back
;          at 0xFA6FFF (`ld (XIY),E` with E = (0x197B), the match count) and
;          the offset at 0xFA7007.  That is precisely the shape
;          MidiIn_RouteChannelMessage reads.
; Note:    (0x1979) chooses between the 0x1800/0x1820 pair and a second
;          pair at 0x18A0/0x18C0.  MidiIn_ServiceRouteRebuild always sets it
;          to 0x80, so on that path only the first pair is written.
; ---------------------------------------------------------------------
MidiIn_BuildChannelRouteTable:   ; entry: call from 0xFA6F1A
	ld XIX,0x00001800                             ; FA6F21  44 00 18 00 00
	cp	(0x1979:16), 0x80                     ; FA6F26  c1 79 19 3f 80   cp (0x1979),0x80
	jr z, .LFA6F32                                ; FA6F2B  66 05
	ld XIX,0x000018a0                             ; FA6F2D  44 a0 18 00 00
.LFA6F32:
	ldw wa, 0xffff                                ; FA6F32  30 ff ff   ld WA,0xffff
	ldw bc, 0x10                                  ; FA6F35  31 10 00   ld BC,0x0010
.LFA6F38:
	ld (xix+), wa                              ; FA6F38  f5 f1 50   ld (XIX+),WA
	djnz16 bc, .LFA6F38                           ; FA6F3B  d9 1c fa
	ld XIX,0x00001820                             ; FA6F3E  44 20 18 00 00
	cp	(0x1979:16), 0x80                     ; FA6F43  c1 79 19 3f 80   cp (0x1979),0x80
	jr z, .LFA6F4F                                ; FA6F48  66 05
	ld XIX,0x000018c0                             ; FA6F4A  44 c0 18 00 00
.LFA6F4F:
	xor WA,WA                                     ; FA6F4F  d8 d0
	ldw bc, 0x40                                  ; FA6F51  31 40 00   ld BC,0x0040
.LFA6F54:
	ld (xix+), wa                              ; FA6F54  f5 f1 50   ld (XIX+),WA
	djnz16 bc, .LFA6F54                           ; FA6F57  d9 1c fa
	ld XIX,0x00001800                             ; FA6F5A  44 00 18 00 00
	ld XIY,0x00001820                             ; FA6F5F  45 20 18 00 00
	cp	(0x1979:16), 0x80                     ; FA6F64  c1 79 19 3f 80   cp (0x1979),0x80
	jr z, .LFA6F75                                ; FA6F69  66 0a
	ld XIX,0x000018a0                             ; FA6F6B  44 a0 18 00 00
	ld XIY,0x000018c0                             ; FA6F70  45 c0 18 00 00
.LFA6F75:
	ld (0x1970:16), xiy                          ; FA6F75  f1 70 19 65   ld (0x1970),XIY
	ld (0x197a:16), 0x00                          ; FA6F79  f1 7a 19 00 00   ld (0x197a),0x00
	ld w, 0x00:opc                                   ; FA6F7E  20 00   ld W,0x00
.LFA6F80:
	ld XHL,0x00000001                             ; FA6F80  43 01 00 00 00
	ld (0x197b:16), 0x00                          ; FA6F85  f1 7b 19 00 00   ld (0x197b),0x00
	ld (0x197c:16), 0x00                          ; FA6F8A  f1 7c 19 00 00   ld (0x197c),0x00
	ld d, (MidiCfg_InOutMode:16)                            ; FA6F8F  c1 35 7f 24   ld D,(0x7f35)
	and D,0x0f                                    ; FA6F93  cc cc 0f
	cp d, 0x01:i3                                   ; FA6F96  cc d9   cp D,1
	jr nz, .LFA6F9F                               ; FA6F98  6e 05
	ld (0x197c:16), 0xff                          ; FA6F9A  f1 7c 19 00 ff   ld (0x197c),0xff
.LFA6F9F:
	ld xiz, (IndexedTable_Base:24)                        ; FA6F9F  e2 18 f0 60 26   ld XIZ,(0x60f018)
	xor D,D                                       ; FA6FA4  cc d4
	ld e, (0x197c:16)                            ; FA6FA6  c1 7c 19 25   ld E,(0x197c)
	cp E,0xff                                     ; FA6FAA  cd cf ff
	jr nz, .LFA6FB8                               ; FA6FAD  6e 09
	ld a, (MidiCfg_SingleChannel:16)                            ; FA6FAF  c1 36 7f 21   ld A,(0x7f36)
	and A,0x1f                                    ; FA6FB3  c9 cc 1f
	jr .LFA6FCB                                   ; FA6FB6  68 13
.LFA6FB8:
	sll de, 0x02                                  ; FA6FB8  da ee 02   sll 0x02,DE
	ld	xiz, (xiz+de)                         ; FA6FBB  e3 07 f8 e8 26   ld XIZ,(XIZ+DE)
	cp XIZ,0xffffffff                             ; FA6FC0  ee cf ff ff ff ff
	jr z, .LFA6FE9                                ; FA6FC6  66 21
	ld A,(XIZ+0x0d)                               ; FA6FC8  8e 0d 21
.LFA6FCB:
	pushw wa                                      ; FA6FCB  28   push WA
	and a, (0x1979:16)                            ; FA6FCC  c1 79 19 c1   and A,(0x1979)
	popw wa                                       ; FA6FD0  48   pop WA
	jr nz, .LFA6FE9                               ; FA6FD1  6e 16
	and A,0x1f                                    ; FA6FD3  c9 cc 1f
	cp A,W                                        ; FA6FD6  c8 f1
	jr nz, .LFA6FE9                               ; FA6FD8  6e 0f
	ld d, (0x197c:16)                            ; FA6FDA  c1 7c 19 24   ld D,(0x197c)
	ld	(xiy+hl), d                           ; FA6FDE  f3 07 f4 ec 44   ld (XIY+HL),D
	inc 1,XHL                                     ; FA6FE3  eb 61
	inc 0x01, (0x197b:16)                         ; FA6FE5  c1 7b 19 61   inc 1,(0x197b)
.LFA6FE9:
	inc 0x01, (0x197c:16)                         ; FA6FE9  c1 7c 19 61   inc 1,(0x197c)
	cp	(0x197c:16), 0x20                     ; FA6FED  c1 7c 19 3f 20   cp (0x197c),0x20
	jr nz, .LFA6F9F                               ; FA6FF2  6e ab
	cp	(0x197b:16), 0x00                     ; FA6FF4  c1 7b 19 3f 00   cp (0x197b),0x00
	jr z, .LFA700B                                ; FA6FF9  66 10
	ld e, (0x197b:16)                            ; FA6FFB  c1 7b 19 25   ld E,(0x197b)
	ld (XIY),E                                    ; FA6FFF  b5 45
	ld XDE,XIY                                    ; FA7001  ed 8a
	sub xde, (0x1970:16)                         ; FA7003  e1 70 19 a2   sub XDE,(0x1970)
	ld (XIX),E                                    ; FA7007  b4 45
	add XIY,XHL                                   ; FA7009  eb 85
.LFA700B:
	inc 1,XIX                                     ; FA700B  ec 61
	inc 1,W                                       ; FA700D  c8 61
	inc 0x01, (0x197a:16)                         ; FA700F  c1 7a 19 61   inc 1,(0x197a)
	cp	(0x197a:16), 0x20                     ; FA7013  c1 7a 19 3f 20   cp (0x197a),0x20
	jrl nz, .LFA6F80                              ; FA7018  7e 65 ff
	ret                                           ; FA701B  0e
.LFA701C:
MidiIn_AfterRebuild:   ; entry: call from 0xFA6F1D
	ld a, (MidiCfg_InOutMode:16)                            ; FA701C  c1 35 7f 21   ld A,(0x7f35)
	and A,0x0f                                    ; FA7020  c9 cc 0f
	sll a, 0x02                                   ; FA7023  c9 ee 02   sll 0x02,A
	ld XIX,MidiIn_AfterRebuildTable               ; FA7026  44 34 70 fa 00
	ld	xix, (xix+a)                          ; FA702B  e3 03 f0 e0 24   ld XIX,(XIX+A)
	call (xix)                                    ; FA7030  b4 e8   call T,XIX
	ret                                           ; FA7032  0e

; --- 0xFA7033-0xFA7033  alignment pad (1 bytes) ---
	.byte 0x00   ; FA7033

; --- 0xFA7034-0xFA7073  pointer table (64 bytes) ---
MidiIn_AfterRebuildTable:
	.long MidiIn_AfterRebuild_Nop               ; FA7034  [0]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuildTable_Nop1                            ; FA7038  [1]   -> MidiIn_AfterRebuildTable_Nop1
	.long MidiIn_ResetChannelRouteTable         ; FA703C  [2]   -> MidiIn_ResetChannelRouteTable
	.long MidiIn_AfterRebuild_Nop               ; FA7040  [3]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7044  [4]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7048  [5]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA704C  [6]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7050  [7]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7054  [8]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7058  [9]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA705C  [10]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7060  [11]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7064  [12]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7068  [13]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA706C  [14]   -> MidiIn_AfterRebuild_Nop
	.long MidiIn_AfterRebuild_Nop               ; FA7070  [15]   -> MidiIn_AfterRebuild_Nop
MidiIn_AfterRebuild_Nop:   ; entry: MidiIn_AfterRebuildTable[0,3-15]
	ret                                           ; FA7074  0e

; ---------------------------------------------------------------------
; MidiIn_AfterRebuildTable_Nop1 -- MidiIn_AfterRebuildTable[1]
;
; Called from: MidiIn_AfterRebuildTable[1], selected by (0x7F35) & 0x0F.
; Evidence: it walks 0x1800 from the entry named by (0x7F36) & 0x1F,
;          incrementing every non-0xFF offset, then opens a hole in the
;          0x1820 list by copying backwards and writing 0xFF -- an insert.
; Unknown: which list element is being inserted, and for what.  Named
;          sub_ deliberately.
; ---------------------------------------------------------------------
MidiIn_AfterRebuildTable_Nop1:   ; entry: MidiIn_AfterRebuildTable[1]
	ret                                           ; FA7075  0e
	ld XIX,0x00001800                             ; FA7076  44 00 18 00 00
	xor XHL,XHL                                   ; FA707B  eb d3
	ld	l, (MidiCfg_SingleChannel:16)                        ; FA707D  c1 36 7f 27   ld L,(0x7f36)
	and L,0x1f                                    ; FA7081  cf cc 1f
	add XIX,XHL                                   ; FA7084  eb 84
	inc 1,XIX                                     ; FA7086  ec 61
	ld C,0x1f:opc                                 ; FA7088  23 1f   ld C,0x1f
	sub C,L                                       ; FA708A  cf a3
.LFA708C:
	ld A,(XIX)                                    ; FA708C  84 21
	cp A,0xff                                     ; FA708E  c9 cf ff
	jr z, .LFA7097                                ; FA7091  66 04   jr Z,0xfa7097
	inc 1,A                                       ; FA7093  c9 61
	ld (XIX),A                                    ; FA7095  b4 41
.LFA7097:
	inc 1,XIX                                     ; FA7097  ec 61
	djnz8 c, .LFA708C                             ; FA7099  cb 1c f0   djnz C,0xfa708c
	ld XIX,0x00001800                             ; FA709C  44 00 18 00 00
	ld	l, (xix+l)                            ; FA70A1  c3 03 f0 ec 27   ld L,(XIX+L)
	ld XIY,0x00001820                             ; FA70A6  45 20 18 00 00
	ld XIZ,XIY                                    ; FA70AB  ed 8e
	add XIZ,XHL                                   ; FA70AD  eb 86
	inc	1, (xiz)                              ; FA70AF  86 61   inc 1,(XIZ)
	inc 1,XIZ                                     ; FA70B1  ee 61
	ld L,(XIX+0x1f)                               ; FA70B3  8c 1f 27
	inc 1,XIY                                     ; FA70B6  ed 61
	ld XIX,XIY                                    ; FA70B8  ed 8c
	add XIX,XHL                                   ; FA70BA  eb 84
	ld XIY,XIX                                    ; FA70BC  ec 8d
	inc 1,XIY                                     ; FA70BE  ed 61
.LFA70C0:
	ld A,(-XIX)                                   ; FA70C0  c4 f0 21   ld A,(-XIX)
	ld (-XIY),A                                   ; FA70C3  f4 f4 41   ld (-XIY),A
	cp XIX,XIZ                                    ; FA70C6  ee f4
	jr nz, .LFA70C0                               ; FA70C8  6e f6   jr NZ,0xfa70c0
	ld (XIX),0xff                                 ; FA70CA  b4 00 ff
	ret                                           ; FA70CD  0e

; ---------------------------------------------------------------------
; MidiIn_ResetChannelRouteTable -- put 0x1800/0x1820 back to one entry per
; channel
;
; Called from: MidiIn_AfterRebuildTable[2].
; Evidence: 0x1800[k] = 3k for k = 0..0x1F (`xor A,A / ld (XIX+),A / inc
;          3,A`, 0x20 times) and 0x1820 gets 32 copies of the three bytes
;          02 FF 00 (`ld WA,0xff02 / ld E,0x00`), which is stride 3 and
;          matches the offsets exactly.
; ---------------------------------------------------------------------
MidiIn_ResetChannelRouteTable:   ; entry: MidiIn_AfterRebuildTable[2]
	ld XIX,0x00001800                             ; FA70CE  44 00 18 00 00
	xor A,A                                       ; FA70D3  c9 d1
	ld C,0x20:opc                                 ; FA70D5  23 20   ld C,0x20
.LFA70D7:
	ld (XIX+),A                                   ; FA70D7  f5 f0 41   ld (XIX+),A
	inc 3,A                                       ; FA70DA  c9 63
	djnz8 c, .LFA70D7                             ; FA70DC  cb 1c f8   djnz C,0xfa70d7
	ld XIX,0x00001820                             ; FA70DF  44 20 18 00 00
	ldw	wa, 0xff02                           ; FA70E4  30 02 ff
	ld E,0x00:opc                                 ; FA70E7  25 00   ld E,0x00
	ld C,0x20:opc                                 ; FA70E9  23 20   ld C,0x20
.LFA70EB:
	ld (XIX+),WA                                  ; FA70EB  f5 f1 50   ld (XIX+),WA
	ld (XIX+),E                                   ; FA70EE  f5 f0 45   ld (XIX+),E
	djnz8 c, .LFA70EB                             ; FA70F1  cb 1c f7   djnz C,0xfa70eb
	ret                                           ; FA70F4  0e

; ---------------------------------------------------------------------
; MidiOut_ParamChanged -- a parameter changed; maybe echo it as MIDI
;
; Called from: prom_b directory slot T_MidiOut_ParamChanged (T_F40748) (`jp 0xFA70F5`).
; Inputs:  BC = the parameter id (C the number, B the class), DE the value.
; Outputs: (0x1958..0x195B) = BC,DE, then MidiOut_ParamNumberTable[C] is
;          called; bit 7 of (0x60F007) is cleared on the way out.
; Evidence: `cp C,0xbf / jr UGT` is the table's bound and 0xBF + 1 = 192 is
;          its entry count, which is also pinned by 0xFA8CC8 + 192*4 =
;          0xFA8FC8, the base of the next object.  The whole routine is
;          skipped when bit 0 of (0x0922) is set and bit 1 is clear.
; ---------------------------------------------------------------------
MidiOut_ParamChanged:   ; entry: prom_b directory slot T_MidiOut_ParamChanged (T_F40748)
	ld	a, (0x0922:16)                        ; FA70F5  c1 22 09 21   ld A,(0x0922)
	bit 0x00,A                                    ; FA70F9  c9 33 00
	jr z, .LFA7103                                ; FA70FC  66 05   jr Z,0xfa7103
	bit 0x01,A                                    ; FA70FE  c9 33 01
	jr nz, .LFA7123                               ; FA7101  6e 20   jr NZ,0xfa7123
.LFA7103:
	ld	(0x1958:16), bc                       ; FA7103  f1 58 19 51   ld (0x1958),BC
	ld	(0x195a:16), de                       ; FA7107  f1 5a 19 52   ld (0x195a),DE
	cp C,0xbf                                     ; FA710B  cb cf bf
	jr ugt, .LFA7123                              ; FA710E  6b 13   jr UGT,0xfa7123
	ld L,C                                        ; FA7110  cb 8f
	extz HL                                       ; FA7112  db 12
	sll HL,2                                      ; FA7114  db ee 02   sll 0x02,HL
	ld XIX,MidiOut_ParamNumberTable               ; FA7117  44 c8 8c fa 00
	ld	xix, (xix+hl)                         ; FA711C  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	call (xix)                                    ; FA7121  b4 e8   call T,XIX
.LFA7123:
	res	7, (0x60f007:24)                      ; FA7123  f2 07 f0 60 b7   res 7,(0x60f007)
	ret                                           ; FA7128  0e

; ---------------------------------------------------------------------
; MidiOut_Param_Ignore -- one byte, `ret`
;
; Called from: 111 of MidiOut_ParamNumberTable's 192 slots (re-derived,
;          check N2).  Most parameter numbers are not echoed.
; ---------------------------------------------------------------------
MidiOut_Param_Ignore:   ; entry: MidiOut_ParamNumberTable[64-111,113-128,130-151,153-172,175,182-183,190-191]
	ret                                           ; FA7129  0e

; ---------------------------------------------------------------------
; MidiOut_ParamGate_Part0/1/2 -- MidiOut_ParamNumberTable[0], [1] and [2]
;
; Called from: MidiOut_ParamNumberTable slots 0, 1 and 2.
; Evidence: each is 24 bytes and each tests bit 6 of ONE RAM byte -- 0x76AF,
;          0x76EF and 0x772F, which are entries [0], [1] and [2] of
;          MidiOut_PartRecordPtrs_00.  So parameter number k names part k's
;          record for k < 3.  All three then fall into the same
;          `ld XIY,MidiOut_ParamClassTable / ld A,0x10 / calr` dispatch that
;          MidiOut_ParamDispatch reaches unconditionally.
; ---------------------------------------------------------------------
MidiOut_ParamGate_Part0:   ; entry: MidiOut_ParamNumberTable[0]
	bit	7, (0x60f007:24)                      ; FA712A  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7137                               ; FA712F  6e 06   jr NZ,0xfa7137
	bit	6, (0x76af:16)                        ; FA7131  f1 af 76 ce   bit 6,(0x76af)
	jr nz, .LFA7141                               ; FA7135  6e 0a   jr NZ,0xfa7141
.LFA7137:
	ld XIY,MidiOut_ParamClassTable                ; FA7137  45 80 71 fa 00
	ld A,0x10:opc                                 ; FA713C  21 10   ld A,0x10
	calr MidiOut_DispatchByClass                  ; FA713E  1e 0b 04   calr 0xfa754c
.LFA7141:
	ret                                           ; FA7141  0e
MidiOut_ParamGate_Part1:   ; entry: MidiOut_ParamNumberTable[1]
	bit	7, (0x60f007:24)                      ; FA7142  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA714F                               ; FA7147  6e 06   jr NZ,0xfa714f
	bit	6, (0x76ef:16)                        ; FA7149  f1 ef 76 ce   bit 6,(0x76ef)
	jr nz, .LFA7159                               ; FA714D  6e 0a   jr NZ,0xfa7159
.LFA714F:
	ld XIY,MidiOut_ParamClassTable                ; FA714F  45 80 71 fa 00
	ld A,0x10:opc                                 ; FA7154  21 10   ld A,0x10
	calr MidiOut_DispatchByClass                  ; FA7156  1e f3 03   calr 0xfa754c
.LFA7159:
	ret                                           ; FA7159  0e
MidiOut_ParamGate_Part2:   ; entry: MidiOut_ParamNumberTable[2]
	bit	7, (0x60f007:24)                      ; FA715A  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7167                               ; FA715F  6e 06   jr NZ,0xfa7167
	bit	6, (0x772f:16)                        ; FA7161  f1 2f 77 ce   bit 6,(0x772f)
	jr nz, .LFA7171                               ; FA7165  6e 0a   jr NZ,0xfa7171
.LFA7167:
	ld XIY,MidiOut_ParamClassTable                ; FA7167  45 80 71 fa 00
	ld A,0x10:opc                                 ; FA716C  21 10   ld A,0x10
	calr MidiOut_DispatchByClass                  ; FA716E  1e db 03   calr 0xfa754c
.LFA7171:
	ret                                           ; FA7171  0e

; ---------------------------------------------------------------------
; MidiOut_ParamDispatch -- the ungated dispatch on the parameter CLASS
;
; Called from: MidiOut_ParamNumberTable slots 3..31 (29 of them).
; Evidence: `ld XIY,0x00FA7180 / ld A,0x10 / calr MidiOut_DispatchByClass`,
;          the same three instructions the three gated twins end with.
; ---------------------------------------------------------------------
MidiOut_ParamDispatch:   ; entry: MidiOut_ParamNumberTable[3-31]
	ld XIY,MidiOut_ParamClassTable                ; FA7172  45 80 71 fa 00
	ld A,0x10:opc                                 ; FA7177  21 10   ld A,0x10
	calr MidiOut_DispatchByClass                  ; FA7179  1e d0 03   calr 0xfa754c
	ret                                           ; FA717C  0e
	ret                                           ; FA717D  0e
	ret                                           ; FA717E  0e

; --- 0xFA717F-0xFA717F  alignment pad (1 bytes) ---
	.byte 0x00   ; FA717F

; --- 0xFA7180-0xFA71C3  pointer table (68 bytes) ---
MidiOut_ParamClassTable:
	.long MidiOut_ProgramChange                 ; FA7180  [0]   -> MidiOut_ProgramChange
	.long MidiOut_BankSelect_Packed             ; FA7184  [1]   -> MidiOut_BankSelect_Packed
	.long MidiIn_NullHandler                    ; FA7188  [2]   -> MidiIn_NullHandler
	.long MidiOut_CC07_Volume                   ; FA718C  [3]   -> MidiOut_CC07_Volume
	.long MidiIn_NullHandler                    ; FA7190  [4]   -> MidiIn_NullHandler
	.long MidiOut_CC5D_Effect3Depth             ; FA7194  [5]   -> MidiOut_CC5D_Effect3Depth
	.long MidiOut_CC5E_Effect4Depth             ; FA7198  [6]   -> MidiOut_CC5E_Effect4Depth
	.long MidiOut_CC5B_Effect1Depth             ; FA719C  [7]   -> MidiOut_CC5B_Effect1Depth
	.long MidiOut_CC0A_Pan                      ; FA71A0  [8]   -> MidiOut_CC0A_Pan
	.long MidiOut_Rpn02_CoarseTune              ; FA71A4  [9]   -> MidiOut_Rpn02_CoarseTune
	.long MidiOut_Rpn01_FineTune                ; FA71A8  [10]   -> MidiOut_Rpn01_FineTune
	.long MidiOut_Rpn00_PitchBendRange          ; FA71AC  [11]   -> MidiOut_Rpn00_PitchBendRange
	.long MidiIn_NullHandler                    ; FA71B0  [12]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA71B4  [13]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA71B8  [14]   -> MidiIn_NullHandler
	.long MidiOut_BankSelect_LsbHalf            ; FA71BC  [15]   -> MidiOut_BankSelect_LsbHalf
	.long MidiOut_BankSelect_MsbHalf            ; FA71C0  [16]   -> MidiOut_BankSelect_MsbHalf

; ---------------------------------------------------------------------
; MidiOut_ProgramChange -- echo a program change outbound
;
; Called from: MidiOut_ParamClassTable[0].
; Evidence: it builds the status byte with `and A,0x0F / or A,0xC0` at
;          0xFA7210 -- 0xCn IS Program Change -- and stages (0x195A) as the
;          one data byte.  It is gated on bit 4 of (0x7F39), the same bit
;          that gates MidiIn_ProgramChange on the inbound side.
; ---------------------------------------------------------------------
MidiOut_ProgramChange:   ; entry: MidiOut_ParamClassTable[0]
	bit	4, (MidiFilter_ChannelMsgs:16)                        ; FA71C4  f1 39 7f cc   bit 4,(0x7f39)
	jr z, .LFA7221                                ; FA71C8  66 57
	ld l, (0x1958:16)                            ; FA71CA  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA71CE  cf cf 1f
	jr ugt, .LFA7221                              ; FA71D1  6b 4e
	ld XIX,MidiOut_PartRecordPtrs_00              ; FA71D3  44 f8 8f fa 00
	extz HL                                       ; FA71D8  db 12
	sll l, 0x02                                   ; FA71DA  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA71DD  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA71E2  ec cf ff ff ff ff
	jr z, .LFA7221                                ; FA71E8  66 37
	bit 4,(XIX+0x26)                              ; FA71EA  bc 26 cc
	jr z, .LFA7221                                ; FA71ED  66 32
	ld a, (0x60f007:24)                          ; FA71EF  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA71F4  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7202                               ; FA71F9  6e 07
	ld A,(XIX)                                    ; FA71FB  84 21
	bit 0x06,A                                    ; FA71FD  c9 33 06
	jr nz, .LFA7221                               ; FA7200  6e 1f
.LFA7202:
	ldw de, 0x0200                                ; FA7202  32 00 02   ld DE,0x0200
	bit 0x04,A                                    ; FA7205  c9 33 04
	jr z, .LFA720C                                ; FA7208  66 02
	ld e, 0x10:opc                                   ; FA720A  25 10   ld E,0x10
.LFA720C:
	ld (0x194b:16), de                           ; FA720C  f1 4b 19 52   ld (0x194b),DE
	and A,0x0f                                    ; FA7210  c9 cc 0f
	or A,0xc0                                     ; FA7213  c9 ce c0
	ld w, (0x195a:16)                            ; FA7216  c1 5a 19 20   ld W,(0x195a)
	ld (0x1948:16), wa                           ; FA721A  f1 48 19 50   ld (0x1948),WA
	calr MidiOut_PostStagedMessage                                   ; FA721E  1e c7 0a   calr 0xfa7ce8
.LFA7221:
	ret                                           ; FA7221  0e

; ---------------------------------------------------------------------
; MidiOut_CC07_Volume -- echo controller 0x07 (Channel Volume) outbound
;
; Called from: MidiOut_ParamClassTable[3].
; Evidence: it ends in `ld W,0x02 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x02 of that map is 0x07.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC07_Volume:   ; entry: MidiOut_ParamClassTable[3]
	ld a, (0x195b:16)                            ; FA7222  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA7226  c9 cc 7f
	jr z, .LFA725F                                ; FA7229  66 34
	ld l, (0x1958:16)                            ; FA722B  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA722F  cf cf 1f
	jr ugt, .LFA725F                              ; FA7232  6b 2b
	ld XIX,MidiOut_PartRecordPtrs_CC07Volume      ; FA7234  44 78 90 fa 00
	extz HL                                       ; FA7239  db 12
	sll l, 0x02                                   ; FA723B  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA723E  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7243  ec cf ff ff ff ff
	jr z, .LFA725F                                ; FA7249  66 14
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA724B  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA725F                                ; FA724F  66 0e
	bit 2,(XIX+0x27)                              ; FA7251  bc 27 ca
	jr z, .LFA725F                                ; FA7254  66 09
	ld e, (0x195a:16)                            ; FA7256  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x02:opc                                   ; FA725A  20 02   ld W,0x02
	calr MidiOut_SendController                                   ; FA725C  1e 94 09   calr 0xfa7bf3
.LFA725F:
	ret                                           ; FA725F  0e

; ---------------------------------------------------------------------
; MidiOut_CC5D_Effect3Depth -- echo controller 0x5D (Effects 3 Depth) outbound
;
; Called from: MidiOut_ParamClassTable[5].
; Evidence: it ends in `ld W,0x05 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x05 of that map is 0x5D.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC5D_Effect3Depth:   ; entry: MidiOut_ParamClassTable[5]
	ld a, (0x195b:16)                            ; FA7260  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA7264  c9 cc 7f
	jr z, .LFA729D                                ; FA7267  66 34
	ld l, (0x1958:16)                            ; FA7269  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA726D  cf cf 1f
	jr ugt, .LFA729D                              ; FA7270  6b 2b
	ld XIX,MidiOut_PartRecordPtrs_CC5DEffect3Depth ; FA7272  44 f8 90 fa 00
	extz HL                                       ; FA7277  db 12
	sll l, 0x02                                   ; FA7279  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA727C  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7281  ec cf ff ff ff ff
	jr z, .LFA729D                                ; FA7287  66 14
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7289  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA729D                                ; FA728D  66 0e
	bit 5,(XIX+0x27)                              ; FA728F  bc 27 cd
	jr z, .LFA729D                                ; FA7292  66 09
	ld e, (0x195a:16)                            ; FA7294  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x05:opc                                   ; FA7298  20 05   ld W,0x05
	calr MidiOut_SendController                                   ; FA729A  1e 56 09   calr 0xfa7bf3
.LFA729D:
	ret                                           ; FA729D  0e

; ---------------------------------------------------------------------
; MidiOut_CC5E_Effect4Depth -- echo controller 0x5E (Effects 4 Depth) outbound
;
; Called from: MidiOut_ParamClassTable[6].
; Evidence: it ends in `ld W,0x06 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x06 of that map is 0x5E.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC5E_Effect4Depth:   ; entry: MidiOut_ParamClassTable[6]
	ld a, (0x195b:16)                            ; FA729E  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA72A2  c9 cc 7f
	jr z, .LFA72D6                                ; FA72A5  66 2f
	ld l, (0x1958:16)                            ; FA72A7  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA72AB  cf cf 1f
	jr ugt, .LFA72D6                              ; FA72AE  6b 26
	ld XIX,MidiOut_PartRecordPtrs_CC5EEffect4Depth ; FA72B0  44 78 91 fa 00
	extz HL                                       ; FA72B5  db 12
	sll l, 0x02                                   ; FA72B7  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA72BA  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA72BF  ec cf ff ff ff ff
	jr z, .LFA72D6                                ; FA72C5  66 0f
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA72C7  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA72D6                                ; FA72CB  66 09
	ld e, (0x195a:16)                            ; FA72CD  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x06:opc                                   ; FA72D1  20 06   ld W,0x06
	calr MidiOut_SendController                                   ; FA72D3  1e 1d 09   calr 0xfa7bf3
.LFA72D6:
	ret                                           ; FA72D6  0e

; ---------------------------------------------------------------------
; MidiOut_CC5B_Effect1Depth -- echo controller 0x5B (Effects 1 Depth) outbound
;
; Called from: MidiOut_ParamClassTable[7].
; Evidence: it ends in `ld W,0x07 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x07 of that map is 0x5B.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC5B_Effect1Depth:   ; entry: MidiOut_ParamClassTable[7]
	ld a, (0x195b:16)                            ; FA72D7  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA72DB  c9 cc 7f
	jr z, .LFA7314                                ; FA72DE  66 34
	ld l, (0x1958:16)                            ; FA72E0  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA72E4  cf cf 1f
	jr ugt, .LFA7314                              ; FA72E7  6b 2b
	ld XIX,MidiOut_PartRecordPtrs_CC5BEffect1Depth ; FA72E9  44 f8 91 fa 00
	extz HL                                       ; FA72EE  db 12
	sll l, 0x02                                   ; FA72F0  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA72F3  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA72F8  ec cf ff ff ff ff
	jr Z,.LFA7314                                 ; FA72FE  66 14
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7300  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7314                                ; FA7304  66 0e
	bit 5,(XIX+0x27)                              ; FA7306  bc 27 cd
	jr z, .LFA7314                                ; FA7309  66 09
	ld e, (0x195a:16)                            ; FA730B  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x07:opc                                   ; FA730F  20 07   ld W,0x07
	calr MidiOut_SendController                                   ; FA7311  1e df 08   calr 0xfa7bf3
.LFA7314:
	ret                                           ; FA7314  0e

; ---------------------------------------------------------------------
; MidiOut_CC0A_Pan -- echo controller 0x0A (Pan) outbound
;
; Called from: MidiOut_ParamClassTable[8].
; Evidence: it ends in `ld W,0x04 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x04 of that map is 0x0A.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC0A_Pan:   ; entry: MidiOut_ParamClassTable[8]
	ld a, (0x195b:16)                            ; FA7315  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA7319  c9 cc 7f
	jr z, .LFA7352                                ; FA731C  66 34
	ld l, (0x1958:16)                            ; FA731E  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA7322  cf cf 1f
	jr ugt, .LFA7352                              ; FA7325  6b 2b
	ld XIX,MidiOut_PartRecordPtrs_CC0APan         ; FA7327  44 78 92 fa 00
	extz HL                                       ; FA732C  db 12
	sll l, 0x02                                   ; FA732E  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7331  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7336  ec cf ff ff ff ff
	jr z, .LFA7352                                ; FA733C  66 14
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA733E  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7352                                ; FA7342  66 0e
	bit 4,(XIX+0x27)                              ; FA7344  bc 27 cc
	jr z, .LFA7352                                ; FA7347  66 09
	ld e, (0x195a:16)                            ; FA7349  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x04:opc                                   ; FA734D  20 04   ld W,0x04
	calr MidiOut_SendController                                   ; FA734F  1e a1 08   calr 0xfa7bf3
.LFA7352:
	ret                                           ; FA7352  0e

; ---------------------------------------------------------------------
; MidiOut_Rpn02_CoarseTune -- echo RPN 0x0002 (Coarse Tune) outbound
;
; Called from: MidiOut_ParamClassTable[9].
; Evidence: `ld BC,0x0002` is the RPN number it hands MidiOut_SendRpn,
;          and MidiIn_CC06_DataEntryMSB routes RPN 0x0002 to exactly
;          this class (it compares the stored RPN against 0x8082, the
;          same number with bit 7 set in each half, and loads the class
;          number this table entry sits at).  Two witnesses, check E2.
;          Gated on bit 3 of (0x7F39).
; ---------------------------------------------------------------------
MidiOut_Rpn02_CoarseTune:   ; entry: MidiOut_ParamClassTable[9]
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7353  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA738E                                ; FA7357  66 35
	ld a, (0x195b:16)                            ; FA7359  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA735D  c9 cc 7f
	jr z, .LFA738E                                ; FA7360  66 2c
	ld l, (0x1958:16)                            ; FA7362  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA7366  cf cf 1f
	jr ugt, .LFA738E                              ; FA7369  6b 23
	ld XIX,MidiOut_PartRecordPtrs_Rpn02CoarseTune ; FA736B  44 f8 92 fa 00
	extz HL                                       ; FA7370  db 12
	sll l, 0x02                                   ; FA7372  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7375  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA737A  ec cf ff ff ff ff
	jr z, .LFA738E                                ; FA7380  66 0c
	ldw bc, 0x02                                  ; FA7382  31 02 00   ld BC,0x0002
	ld d, (0x195a:16)                            ; FA7385  c1 5a 19 24   ld D,(0x195a)
	xor E,E                                       ; FA7389  cd d5
	calr MidiOut_SendRpn                                   ; FA738B  1e b0 08   calr 0xfa7c3e
.LFA738E:
	ret                                           ; FA738E  0e

; ---------------------------------------------------------------------
; MidiOut_Rpn01_FineTune -- echo RPN 0x0001 (Fine Tune) outbound
;
; Called from: MidiOut_ParamClassTable[10].
; Evidence: `ld BC,0x0001` is the RPN number it hands MidiOut_SendRpn,
;          and MidiIn_CC06_DataEntryMSB routes RPN 0x0001 to exactly
;          this class (it compares the stored RPN against 0x8081, the
;          same number with bit 7 set in each half, and loads the class
;          number this table entry sits at).  Two witnesses, check E2.
;          Gated on bit 3 of (0x7F39).
; ---------------------------------------------------------------------
MidiOut_Rpn01_FineTune:   ; entry: MidiOut_ParamClassTable[10]
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA738F  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA73D0                                ; FA7393  66 3b
	ld a, (0x195b:16)                            ; FA7395  c1 5b 19 21   ld A,(0x195b)
	and A,0xff                                    ; FA7399  c9 cc ff
	jr z, .LFA73D0                                ; FA739C  66 32
	ld l, (0x1958:16)                            ; FA739E  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA73A2  cf cf 1f
	jr ugt, .LFA73D0                              ; FA73A5  6b 29
	ld XIX,MidiOut_PartRecordPtrs_Rpn01FineTune   ; FA73A7  44 78 93 fa 00
	extz HL                                       ; FA73AC  db 12
	sll l, 0x02                                   ; FA73AE  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA73B1  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA73B6  ec cf ff ff ff ff
	jr z, .LFA73D0                                ; FA73BC  66 12
	ldw bc, 0x01                                  ; FA73BE  31 01 00   ld BC,0x0001
	ld d, (0x195a:16)                            ; FA73C1  c1 5a 19 24   ld D,(0x195a)
	xor E,E                                       ; FA73C5  cd d5
	srl de, 0x01                                  ; FA73C7  da ef 01   srl 0x01,DE
	srl e, 0x01                                   ; FA73CA  cd ef 01   srl 0x01,E
	calr MidiOut_SendRpn                                   ; FA73CD  1e 6e 08   calr 0xfa7c3e
.LFA73D0:
	ret                                           ; FA73D0  0e

; ---------------------------------------------------------------------
; MidiOut_Rpn00_PitchBendRange -- echo RPN 0x0000 (Pitch Bend Sensitivity) outbound
;
; Called from: MidiOut_ParamClassTable[11].
; Evidence: `ld BC,0x0000` is the RPN number it hands MidiOut_SendRpn,
;          and MidiIn_CC06_DataEntryMSB routes RPN 0x0000 to exactly
;          this class (it compares the stored RPN against 0x8080, the
;          same number with bit 7 set in each half, and loads the class
;          number this table entry sits at).  Two witnesses, check E2.
;          Gated on bit 3 of (0x7F39).
; ---------------------------------------------------------------------
MidiOut_Rpn00_PitchBendRange:   ; entry: MidiOut_ParamClassTable[11]
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA73D1  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA740C                                ; FA73D5  66 35
	ld a, (0x195b:16)                            ; FA73D7  c1 5b 19 21   ld A,(0x195b)
	and A,0x7f                                    ; FA73DB  c9 cc 7f
	jr z, .LFA740C                                ; FA73DE  66 2c
	ld l, (0x1958:16)                            ; FA73E0  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA73E4  cf cf 1f
	jr ugt, .LFA740C                              ; FA73E7  6b 23
	ld XIX,MidiOut_PartRecordPtrs_Rpn00PitchBendRange ; FA73E9  44 f8 93 fa 00
	extz HL                                       ; FA73EE  db 12
	sll l, 0x02                                   ; FA73F0  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA73F3  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA73F8  ec cf ff ff ff ff
	jr Z,.LFA740C                                 ; FA73FE  66 0c
	ldw bc, 0x00                                  ; FA7400  31 00 00   ld BC,0x0000
	ld d, (0x195a:16)                            ; FA7403  c1 5a 19 24   ld D,(0x195a)
	xor E,E                                       ; FA7407  cd d5
	calr MidiOut_SendRpn                                   ; FA7409  1e 32 08   calr 0xfa7c3e
.LFA740C:
	ret                                           ; FA740C  0e

; ---------------------------------------------------------------------
; MidiOut_BankSelect_LsbHalf -- send a Bank Select through MidiOut_SendBankSelect
;
; Called from: MidiOut_ParamClassTable[15].
; Evidence: it puts the incoming value (0x195A) in E -- the CC 0x20
;          half -- and takes the MSB from the stash at (0x196B); when
;          the stash's bit 7 is still set it only remembers the value
;          and sends nothing.
; ---------------------------------------------------------------------
MidiOut_BankSelect_LsbHalf:   ; entry: MidiOut_ParamClassTable[15]
	ld l, (0x1958:16)                            ; FA740D  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA7411  cf cf 1f
	jr ugt, .LFA7454                              ; FA7414  6b 3e
	ld XIX,MidiOut_PartRecordPtrs_00              ; FA7416  44 f8 8f fa 00
	extz HL                                       ; FA741B  db 12
	sll l, 0x02                                   ; FA741D  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7420  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7425  ec cf ff ff ff ff
	jr z, .LFA7454                                ; FA742B  66 27
	ld e, (0x195a:16)                            ; FA742D  c1 5a 19 25   ld E,(0x195a)
	ld d, (0x196b:16)                            ; FA7431  c1 6b 19 24   ld D,(0x196b)
	bit 0x07,D                                    ; FA7435  cc 33 07
	jr z, .LFA744D                                ; FA7438  66 13
	res 0x07,D                                    ; FA743A  cc 30 07
	ld (0x196b:16), d                            ; FA743D  f1 6b 19 44   ld (0x196b),D
	res 0x07,E                                    ; FA7441  cd 30 07
	ld (0x196a:16), e                            ; FA7444  f1 6a 19 45   ld (0x196a),E
	calr MidiOut_SendBankSelect                                   ; FA7448  1e 4a 08   calr 0xfa7c95
	jr .LFA7454                                   ; FA744B  68 07
.LFA744D:
	set 0x07,E                                    ; FA744D  cd 31 07
	ld (0x196a:16), e                            ; FA7450  f1 6a 19 45   ld (0x196a),E
.LFA7454:
	ret                                           ; FA7454  0e

; ---------------------------------------------------------------------
; MidiOut_BankSelect_MsbHalf -- send a Bank Select through MidiOut_SendBankSelect
;
; Called from: MidiOut_ParamClassTable[16].
; Evidence: the mirror image: the incoming value goes to D, the CC
;          0x00 half, and the LSB comes from the stash at (0x196A).
; ---------------------------------------------------------------------
MidiOut_BankSelect_MsbHalf:   ; entry: MidiOut_ParamClassTable[16]
	ld l, (0x1958:16)                            ; FA7455  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA7459  cf cf 1f
	jr ugt, .LFA749C                              ; FA745C  6b 3e
	ld XIX,MidiOut_PartRecordPtrs_00              ; FA745E  44 f8 8f fa 00
	extz HL                                       ; FA7463  db 12
	sll l, 0x02                                   ; FA7465  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7468  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA746D  ec cf ff ff ff ff
	jr z, .LFA749C                                ; FA7473  66 27
	ld d, (0x195a:16)                            ; FA7475  c1 5a 19 24   ld D,(0x195a)
	ld e, (0x196a:16)                            ; FA7479  c1 6a 19 25   ld E,(0x196a)
	bit 0x07,E                                    ; FA747D  cd 33 07
	jr z, .LFA7495                                ; FA7480  66 13
	res 0x07,E                                    ; FA7482  cd 30 07
	ld (0x196a:16), e                            ; FA7485  f1 6a 19 45   ld (0x196a),E
	res 0x07,D                                    ; FA7489  cc 30 07
	ld (0x196b:16), d                            ; FA748C  f1 6b 19 44   ld (0x196b),D
	calr MidiOut_SendBankSelect                                   ; FA7490  1e 02 08   calr 0xfa7c95
	jr .LFA749C                                   ; FA7493  68 07
.LFA7495:
	set 0x07,D                                    ; FA7495  cc 31 07
	ld (0x196b:16), d                            ; FA7498  f1 6b 19 44   ld (0x196b),D
.LFA749C:
	ret                                           ; FA749C  0e

; ---------------------------------------------------------------------
; MidiOut_BankSelect_Packed -- send a Bank Select through MidiOut_SendBankSelect
;
; Called from: MidiOut_ParamClassTable[1].
; Evidence: one 6-bit value becomes both halves -- `and E,0x3F / sll
;          5,DE / srl 1,E` leaves D = value >> 3 and E = (value << 4)
;          & 0x7F.
; ---------------------------------------------------------------------
MidiOut_BankSelect_Packed:   ; entry: MidiOut_ParamClassTable[1]
	ld l, (0x1958:16)                            ; FA749D  c1 58 19 27   ld L,(0x1958)
	cp L,0x1f                                     ; FA74A1  cf cf 1f
	jr ugt, .LFA74CF                              ; FA74A4  6b 29
	ld XIX,MidiOut_PartRecordPtrs_00              ; FA74A6  44 f8 8f fa 00
	extz HL                                       ; FA74AB  db 12
	sll l, 0x02                                   ; FA74AD  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA74B0  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA74B5  ec cf ff ff ff ff
	jr z, .LFA74CF                                ; FA74BB  66 12
	extz DE                                       ; FA74BD  da 12
	ld e, (0x195a:16)                            ; FA74BF  c1 5a 19 25   ld E,(0x195a)
	and E,0x3f                                    ; FA74C3  cd cc 3f
	sll de, 0x05                                  ; FA74C6  da ee 05   sll 0x05,DE
	srl e, 0x01                                   ; FA74C9  cd ef 01   srl 0x01,E
	calr MidiOut_SendBankSelect                                   ; FA74CC  1e c6 07   calr 0xfa7c95
.LFA74CF:
	ret                                           ; FA74CF  0e

; ---------------------------------------------------------------------
; MidiOut_CC51_General6 -- echo controller 0x51 (General Purpose 6) outbound
;
; Called from: MidiOut_ParamNumberTable[32-63].
; Evidence: it ends in `ld W,0x12 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x12 of that map is 0x51.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC51_General6:   ; entry: MidiOut_ParamNumberTable[32-63]
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA74D0  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7509                                ; FA74D4  66 33
	cp	(0x1959:16), 0x18                     ; FA74D6  c1 59 19 3f 18   cp (0x1959),0x18
	jr nz, .LFA7509                               ; FA74DB  6e 2c
	ld l, (0x1958:16)                            ; FA74DD  c1 58 19 27   ld L,(0x1958)
	sub L,0x20                                    ; FA74E1  cf ca 20
	cp L,0x1f                                     ; FA74E4  cf cf 1f
	jr ugt, .LFA7509                              ; FA74E7  6b 20
	ld XIX,MidiOut_PartRecordPtrs_CC51General6    ; FA74E9  44 f8 9b fa 00
	extz HL                                       ; FA74EE  db 12
	sll l, 0x02                                   ; FA74F0  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA74F3  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA74F8  ec cf ff ff ff ff
	jr Z,.LFA7509                                 ; FA74FE  66 09
	ld e, (0x195a:16)                            ; FA7500  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x12:opc                                   ; FA7504  20 12   ld W,0x12
	calr MidiOut_SendController                                   ; FA7506  1e ea 06   calr 0xfa7bf3
.LFA7509:
	ret                                           ; FA7509  0e
	ret                                           ; FA750A  0e
	nop                                           ; FA750B  00
	nop                                           ; FA750C  00
	push SR                                       ; FA750D  02
	normal                                        ; FA750E  01
	pop SR                                        ; FA750F  03
	nop                                           ; FA7510  00
	nop                                           ; FA7511  00
	nop                                           ; FA7512  00
	nop                                           ; FA7513  00
	ld XIY,MidiOut_CC51_General6_JumpTable_FA7520                             ; FA7514  45 20 75 fa 00
	ld a, 0x03:opc                                   ; FA7519  21 03   ld A,0x03
	calr MidiOut_DispatchByClass                                     ; FA751B  1e 2e 00   calr 0xfa754c
	ret                                           ; FA751E  0e

; --- 0xFA751F-0xFA751F  alignment pad (1 bytes) ---
	.byte 0x00   ; FA751F

; --- 0xFA7520-0xFA752F  pointer table (16 bytes) ---
MidiOut_CC51_General6_JumpTable_FA7520:
	.long MidiIn_NullHandler                    ; FA7520  [232]   -> MidiIn_NullHandler
	.long MidiOut_CC51_General6_JumpTable_FA7520_Nop1                            ; FA7524  [233]   -> MidiOut_CC51_General6_JumpTable_FA7520_Nop1
	.long MidiIn_NullHandler                    ; FA7528  [234]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA752C  [235]   -> MidiIn_NullHandler
MidiOut_CC51_General6_JumpTable_FA7520_Nop1:   ; entry: 0xFA7520[1]
	ret                                           ; FA7530  0e
MidiOut_Param70:   ; entry: MidiOut_ParamNumberTable[112]
	ld XIY,sub_FA7531_JumpTable_FA753C                             ; FA7531  45 3c 75 fa 00
	ld a, 0x03:opc                                   ; FA7536  21 03   ld A,0x03
	calr MidiOut_DispatchByClass                                     ; FA7538  1e 11 00   calr 0xfa754c
	ret                                           ; FA753B  0e

; --- 0xFA753C-0xFA754B  pointer table (16 bytes) ---
sub_FA7531_JumpTable_FA753C:
	.long MidiIn_NullHandler                    ; FA753C  [239]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA7540  [240]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA7544  [241]   -> MidiIn_NullHandler
	.long MidiIn_NullHandler                    ; FA7548  [242]   -> MidiIn_NullHandler

; ---------------------------------------------------------------------
; MidiOut_DispatchByClass -- call table[(0x1959)] if the index is in range
;
; Called from: 0xFA713E, 0xFA7156, 0xFA716E, 0xFA7179, 0xFA751B, 0xFA7538.
; Inputs:  XIY = the table base, A = its HIGHEST legal index, (0x1959) = the
;          parameter class.
; Evidence: `cp L,A / jr UGT` is the bound test, so the caller's literal is
;          the entry count minus one.  Its four 0xFA7180 callers all pass
;          0x10, giving 17 entries, and 0xFA7180 + 17*4 = 0xFA71C4, which is
;          entry [0] of that very table -- the table ends where its first
;          handler begins.  The 0xFA7520 and 0xFA753C callers pass 3.
; Notes:   the same idiom as the two dispatchers of the 0xFC0000 module
;          (notes/FINDINGS-prom_a-msg0716-module.md), down to the `cp L,A`.
; ---------------------------------------------------------------------
MidiOut_DispatchByClass:   ; entry: call from 0xFA713E, 0xFA7156, 0xFA716E, 0xFA7179, 0xFA751B, 0xFA7538
	ld l, (0x1959:16)                            ; FA754C  c1 59 19 27   ld L,(0x1959)
	cp L,A                                        ; FA7550  c9 f7
	jr ugt, .LFA7560                              ; FA7552  6b 0c
	extz HL                                       ; FA7554  db 12
	sll hl, 0x02                                  ; FA7556  db ee 02   sll 0x02,HL
	ld	xhl, (xiy+hl)                         ; FA7559  e3 07 f4 ec 23   ld XHL,(XIY+HL)
	call (xhl)                                    ; FA755E  b3 e8   call T,XHL
.LFA7560:
	ret                                           ; FA7560  0e

; ---------------------------------------------------------------------
; MidiOut_BankSelect_Pair -- send a Bank Select through MidiOut_SendBankSelect
;
; Called from: MidiOut_ParamNumberTable[129].
; Evidence: it loads BOTH halves at once, `ld DE,(0x195A)` as one
;          16-bit word.
; ---------------------------------------------------------------------
MidiOut_BankSelect_Pair:   ; entry: MidiOut_ParamNumberTable[129]
	ld XIX,MidiOut_PartRecordPtrs_00              ; FA7561  44 f8 8f fa 00
	ld l, (0x1959:16)                            ; FA7566  c1 59 19 27   ld L,(0x1959)
	extz HL                                       ; FA756A  db 12
	sll hl, 0x02                                  ; FA756C  db ee 02   sll 0x02,HL
	ld	xix, (xix+hl)                         ; FA756F  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7574  ec cf ff ff ff ff
	jr z, .LFA7583                                ; FA757A  66 07
	ld de, (0x195a:16)                          ; FA757C  d1 5a 19 22   ld DE,(0x195a)
	calr .LFA7C95                                 ; FA7580  1e 12 07
.LFA7583:
	ret                                           ; FA7583  0e
MidiOut_Param98:   ; entry: MidiOut_ParamNumberTable[152]
	ld a, (MidiCfg_InOutMode:16)                            ; FA7584  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA7588  c9 cc f0
	cp a, 0x00:i3                                   ; FA758B  c9 d8   cp A,0
	jrl z, .LFA7620                               ; FA758D  76 90 00
	cp b, 0x02:i3                                   ; FA7590  ca da   cp B,2
	jr nz, .LFA75E6                               ; FA7592  6e 52
	bit	7, (MidiFilter_BankSelect:16)                        ; FA7594  f1 3a 7f cf   bit 7,(0x7f3a)
	jrl z, .LFA7620                               ; FA7598  76 85 00
	ld a, (0x60f007:24)                          ; FA759B  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA75A0  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA75B0                               ; FA75A5  6e 09
	ld a, (MidiCfg_SingleChannel:16)                            ; FA75A7  c1 36 7f 21   ld A,(0x7f36)
	bit 0x06,A                                    ; FA75AB  c9 33 06
	jr nz, .LFA7620                               ; FA75AE  6e 70
.LFA75B0:
	ld XIY,0x00001948                             ; FA75B0  45 48 19 00 00
	ldw bc, 0x0300                                ; FA75B5  31 00 03   ld BC,0x0300
	bit 0x04,A                                    ; FA75B8  c9 33 04
	jr z, .LFA75BF                                ; FA75BB  66 02
	ld c, 0x10:opc                                   ; FA75BD  23 10   ld C,0x10
.LFA75BF:
	ld (XIY+0x03),BC                              ; FA75BF  bd 03 51
	and A,0x0f                                    ; FA75C2  c9 cc 0f
	or A,0xb0                                     ; FA75C5  c9 ce b0
	ld w, 0x00:opc                                   ; FA75C8  20 00   ld W,0x00
	ld	(xiy+0:8), wa                         ; FA75CA  bd 00 50   ld (XIY+0x00),WA
	res 0x07,D                                    ; FA75CD  cc 30 07
	ld (XIY+0x02),D                               ; FA75D0  bd 02 44
	calr .LFA7CE8                                 ; FA75D3  1e 12 07
	ld w, 0x20:opc                                   ; FA75D6  20 20   ld W,0x20
	ld (XIY+0x01),W                               ; FA75D8  bd 01 40
	res 0x07,E                                    ; FA75DB  cd 30 07
	ld (XIY+0x02),E                               ; FA75DE  bd 02 45
	calr .LFA7CE8                                 ; FA75E1  1e 04 07
	jr .LFA7620                                   ; FA75E4  68 3a
.LFA75E6:
	bit	4, (MidiFilter_ChannelMsgs:16)                        ; FA75E6  f1 39 7f cc   bit 4,(0x7f39)
	jr z, .LFA7620                                ; FA75EA  66 34
	ld a, (0x60f007:24)                          ; FA75EC  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA75F1  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7601                               ; FA75F6  6e 09
	ld a, (MidiCfg_SingleChannel:16)                            ; FA75F8  c1 36 7f 21   ld A,(0x7f36)
	bit 0x06,A                                    ; FA75FC  c9 33 06
	jr nz, .LFA7620                               ; FA75FF  6e 1f
.LFA7601:
	ldw de, 0x0200                                ; FA7601  32 00 02   ld DE,0x0200
	bit 0x04,A                                    ; FA7604  c9 33 04
	jr z, .LFA760B                                ; FA7607  66 02
	ld e, 0x10:opc                                   ; FA7609  25 10   ld E,0x10
.LFA760B:
	ld (0x194b:16), de                           ; FA760B  f1 4b 19 52   ld (0x194b),DE
	and A,0x0f                                    ; FA760F  c9 cc 0f
	or A,0xc0                                     ; FA7612  c9 ce c0
	ld w, (0x195a:16)                            ; FA7615  c1 5a 19 20   ld W,(0x195a)
	ld (0x1948:16), wa                           ; FA7619  f1 48 19 50   ld (0x1948),WA
	calr .LFA7CE8                                 ; FA761D  1e c8 06
.LFA7620:
	ret                                           ; FA7620  0e

; ---------------------------------------------------------------------
; MidiOut_CC79_ResetAllCtrl -- echo controller 0x79 (Reset All Controllers) outbound
;
; Called from: MidiOut_ParamNumberTable[173].
; Evidence: it ends in `ld W,0x28 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x28 of that map is 0x79.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC79_ResetAllCtrl:   ; entry: MidiOut_ParamNumberTable[173]
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7621  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA764E                                ; FA7625  66 27
	ld l, (0x1959:16)                            ; FA7627  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA762B  cf cf 1f
	jr ugt, .LFA764E                              ; FA762E  6b 1e
	ld XIX,MidiOut_PartRecordPtrs_CC79ResetAllCtrl ; FA7630  44 78 94 fa 00
	extz HL                                       ; FA7635  db 12
	sll l, 0x02                                   ; FA7637  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA763A  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA763F  ec cf ff ff ff ff
	jr z, .LFA764E                                ; FA7645  66 07
	xor E,E                                       ; FA7647  cd d5
	ld w, 0x28:opc                                   ; FA7649  20 28   ld W,0x28
	calr .LFA7BF3                                 ; FA764B  1e a5 05
.LFA764E:
	ret                                           ; FA764E  0e

; ---------------------------------------------------------------------
; MidiOut_CC78_AllSoundOff -- echo controller 0x78 (All Sound Off) outbound
;
; Called from: MidiOut_ParamNumberTable[174].
; Evidence: it ends in `ld W,0x29 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x29 of that map is 0x78.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC78_AllSoundOff:   ; entry: MidiOut_ParamNumberTable[174]
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA764F  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA764E                                ; FA7653  66 f9
	ld l, (0x1959:16)                            ; FA7655  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7659  cf cf 1f
	jr ugt, .LFA767C                              ; FA765C  6b 1e
	ld XIX,MidiOut_PartRecordPtrs_CC78AllSoundOff ; FA765E  44 f8 94 fa 00
	extz HL                                       ; FA7663  db 12
	sll l, 0x02                                   ; FA7665  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7668  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA766D  ec cf ff ff ff ff
	jr z, .LFA767C                                ; FA7673  66 07
	xor E,E                                       ; FA7675  cd d5
	ld w, 0x29:opc                                   ; FA7677  20 29   ld W,0x29
	calr .LFA7BF3                                 ; FA7679  1e 77 05
.LFA767C:
	ret                                           ; FA767C  0e
MidiOut_ParamNumberTable_Nop176:   ; entry: MidiOut_ParamNumberTable[176]
	ret                                           ; FA767D  0e
.LFA767E:
; ---------------------------------------------------------------------
; MidiOut_PitchBend -- echo a PITCH BEND message outbound, part by part
;
; ★ RENAMED FROM sub_FA767E.  This message is NOT a control change, which
;          is why MidiOut_ChangeIndexMap -- a map indexed by CONTROLLER
;          NUMBER -- can never produce its record.  The ⚠ above
;          MidiOut_ChangeRecord_CC01Modulation, "two of the eleven records
;          are unreachable through that map ... stated, not explained", is
;          explained by this name and its twin, and that ⚠ is rewritten.
; Called from: MidiOut_ParamNumberTable[0xB1] -- the listing's own inline
;          entry comment spells that slot in decimal, 177 -- and directly
;          by MidiIn_PitchBend
;          at 0xFA6E54, which the tree named from the inbound side.
; Body:    the three-routine shape of this family -- walk the 0xFF-terminated
;          part list at RAM 0x19F0 (`ld XIZ` at 0xFA76A4), call MidiOut_PitchBend__partgate
;          once per part, and fall into MidiOut_PitchBend__emit.
; Evidence: FOUR agreements, and not one of them is adjacency.
;          1. MidiOut_PitchBend__emit builds its status byte with `or A,0xE0`
;             at 0xFA7706.  0xEn is the pitch-bend status in MIDI 1.0.
;             ⚠ that step is a fact about the PROTOCOL, not about this ROM;
;             the others are facts about these bytes.
;          2. the same routine stages a 3-BYTE message -- `ld DE,0x0300`
;             at 0xFA76F5 -- and 3 bytes is that message's length.
;          3. its caller at 0xFA6E54 is MidiIn_PitchBend, the INBOUND handler
;             of the same message, named by a different pass from a
;             different table.
;          4. change record 9's reset value is 0x4000 -- the only one
;             of the eleven outside {0x7F00, 0x7F40, 0x7F7F}, and the
;             midpoint of the range the other ten top out at, i.e.
;             pitch-bend centre (check X6).
; Unknown: what CPU 2 does with the message.  Nothing here says.
; ---------------------------------------------------------------------

MidiOut_PitchBend:   ; entry: MidiOut_ParamNumberTable[177]; call from 0xFA6E54, 0xFA7E5A, 0xFA7E8C
	cp b, 0x00:i3                                   ; FA767E  ca d8   cp B,0
	jr nz, .LFA76BD                               ; FA7680  6e 3b
	bit	7, (0x60f007:24)                      ; FA7682  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA76BD                               ; FA7687  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7689  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA768D  c9 cc f0
	cp a, 0x00:i3                                   ; FA7690  c9 d8   cp A,0
	jr z, .LFA76A4                                ; FA7692  66 10
	bit	6, (MidiFilter_ChannelMsgs:16)                        ; FA7694  f1 39 7f ce   bit 6,(0x7f39)
	jr z, .LFA76BC                                ; FA7698  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA769A  44 36 7f 00 00
	calr .LFA76EE                                 ; FA769F  1e 4c 00
	jr .LFA76BC                                   ; FA76A2  68 18
.LFA76A4:
	ld XIZ,0x000019f0                             ; FA76A4  46 f0 19 00 00
.LFA76A9:
	ld b, (xiz+)                               ; FA76A9  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA76AC  ca cf ff
	jr z, .LFA76BC                                ; FA76AF  66 0b
	push XIZ                                      ; FA76B1  3e
	ld (0x1959:16), b                            ; FA76B2  f1 59 19 42   ld (0x1959),B
	calr .LFA76BD                                 ; FA76B6  1e 04 00
	pop XIZ                                       ; FA76B9  5e
	jr .LFA76A9                                   ; FA76BA  68 ed
.LFA76BC:
	ret                                           ; FA76BC  0e
.LFA76BD:
; ---------------------------------------------------------------------
; MidiOut_PitchBend__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_PitchBend, `calr` at 0xFA76B6, once per part in the
;          0xFF-terminated list at RAM 0x19F0; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7680, 0xFA7687).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_PitchBend
;          by index*4 (`ld XIX,0xFA9578` at 0xFA76C6); reject 0xFFFFFFFF; test
;          bit 6 of (record+0x26); fall through into MidiOut_PitchBend__emit.
; Evidence: the (offset,mask) pair it tests is (+0x00, 0x40), and that is
;          EXACTLY the pair MidiIn_BuildList_PitchBend hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x4000` at 0xFA8204).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_PitchBend__partgate:   ; entry: call from 0xFA76B6
	ld l, (0x1959:16)                            ; FA76BD  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA76C1  cf cf 1f
	jr ugt, .LFA771C                              ; FA76C4  6b 56
	ld XIX,MidiOut_PartRecordPtrs_PitchBend       ; FA76C6  44 78 95 fa 00
	extz HL                                       ; FA76CB  db 12
	sll l, 0x02                                   ; FA76CD  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA76D0  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA76D5  ec cf ff ff ff ff
	jr z, .LFA771C                                ; FA76DB  66 3f
	bit 6,(XIX+0x26)                              ; FA76DD  bc 26 ce
	jr z, .LFA771C                                ; FA76E0  66 3a
	ld a, (0x60f007:24)                          ; FA76E2  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA76E7  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA76F5                               ; FA76EC  6e 07
.LFA76EE:
; ---------------------------------------------------------------------
; MidiOut_PitchBend__emit -- stage the PITCH BEND bytes and post them
;
; Called from: MidiOut_PitchBend at 0xFA769F, and by fall-through from MidiOut_PitchBend__partgate.
; Body:    status byte = (the part record's byte 0, or (0x60F007) when bit 7
;          of (0x60F007) is set) & 0x0F, then `or A,0xE0` at 0xFA7706;
;          a length word 0x0300 into (0x194B) (`ld DE` at 0xFA76F5);
;          the data bytes into (0x1948..); then MidiOut_PostStagedMessage.
; Evidence: as MidiOut_PitchBend.  ★ It ends in MidiOut_PostStagedMessage and NOT in
;          MidiOut_SendController, which is the mechanical difference
;          between this pair and the nine controller families beside them:
;          SendController's job is to map an index to a CONTROLLER NUMBER
;          through MidiOut_IndexToControllerNumber, and these two messages
;          do not have one.
; ---------------------------------------------------------------------

MidiOut_PitchBend__emit:   ; entry: call from 0xFA769F
	ld A,(XIX)                                    ; FA76EE  84 21
	bit 0x06,A                                    ; FA76F0  c9 33 06
	jr nz, .LFA771C                               ; FA76F3  6e 27
.LFA76F5:
	ldw de, 0x0300                                ; FA76F5  32 00 03   ld DE,0x0300
	bit 0x04,A                                    ; FA76F8  c9 33 04
	jr z, .LFA76FF                                ; FA76FB  66 02
	ld e, 0x10:opc                                   ; FA76FD  25 10   ld E,0x10
.LFA76FF:
	ld (0x194b:16), de                           ; FA76FF  f1 4b 19 52   ld (0x194b),DE
	and A,0x0f                                    ; FA7703  c9 cc 0f
	or A,0xe0                                     ; FA7706  c9 ce e0
	ld w, (0x195a:16)                            ; FA7709  c1 5a 19 20   ld W,(0x195a)
	ld (0x1948:16), wa                           ; FA770D  f1 48 19 50   ld (0x1948),WA
	ld a, (0x195b:16)                            ; FA7711  c1 5b 19 21   ld A,(0x195b)
	ld (0x194a:16), a                            ; FA7715  f1 4a 19 41   ld (0x194a),A
	calr .LFA7CE8                                 ; FA7719  1e cc 05
.LFA771C:
	ret                                           ; FA771C  0e

; ---------------------------------------------------------------------
; MidiOut_CC01_Modulation -- echo controller 0x01 (Modulation wheel) outbound
;
; Called from: MidiOut_ParamNumberTable[178]; call from 0xFA65DB.
; Evidence: its tail MidiOut_CC01_Modulation__emit at 0xFA7781 ends in
;          `ld W,0x01 / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x01 of that map is 0x01.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC01_Modulation:   ; entry: MidiOut_ParamNumberTable[178]; call from 0xFA65DB
	cp b, 0x00:i3                                   ; FA771D  ca d8   cp B,0
	jr nz, .LFA775C                               ; FA771F  6e 3b
	bit	7, (0x60f007:24)                      ; FA7721  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA775C                               ; FA7726  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7728  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA772C  c9 cc f0
	cp a, 0x00:i3                                   ; FA772F  c9 d8   cp A,0
	jr z, .LFA7743                                ; FA7731  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7733  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA775B                                ; FA7737  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA7739  44 36 7f 00 00
	calr .LFA7781                                 ; FA773E  1e 40 00
	jr .LFA775B                                   ; FA7741  68 18
.LFA7743:
	ld XIZ,0x00001a00                             ; FA7743  46 00 1a 00 00
.LFA7748:
	ld b, (xiz+)                               ; FA7748  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA774B  ca cf ff
	jr z, .LFA775B                                ; FA774E  66 0b
	push XIZ                                      ; FA7750  3e
	ld (0x1959:16), b                            ; FA7751  f1 59 19 42   ld (0x1959),B
	calr .LFA775C                                 ; FA7755  1e 04 00
	pop XIZ                                       ; FA7758  5e
	jr .LFA7748                                   ; FA7759  68 ed
.LFA775B:
	ret                                           ; FA775B  0e
.LFA775C:
; ---------------------------------------------------------------------
; MidiOut_CC01_Modulation__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC01_Modulation, `calr` at 0xFA7755, once per part in the
;          0xFF-terminated list at RAM 0x1A00; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA771F, 0xFA7726).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC01Modulation
;          by index*4 (`ld XIX,0xFA95F8` at 0xFA7765); reject 0xFFFFFFFF; test
;          bit 1 of (record+0x27); fall through into MidiOut_CC01_Modulation__emit.
; Evidence: the (offset,mask) pair it tests is (+0x01, 0x02), and that is
;          EXACTLY the pair MidiIn_BuildList_CC01Modulation hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x0201` at 0xFA8213).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC01_Modulation__partgate:   ; entry: call from 0xFA7755
	ld l, (0x1959:16)                            ; FA775C  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7760  cf cf 1f
	jr ugt, .LFA778A                              ; FA7763  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC01Modulation  ; FA7765  44 f8 95 fa 00
	extz HL                                       ; FA776A  db 12
	sll l, 0x02                                   ; FA776C  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA776F  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7774  ec cf ff ff ff ff
	jr z, .LFA778A                                ; FA777A  66 0e
	bit 1,(XIX+0x27)                              ; FA777C  bc 27 c9
	jr z, .LFA778A                                ; FA777F  66 09
.LFA7781:

; ---------------------------------------------------------------------
; MidiOut_CC01_Modulation__emit -- echo controller 0x01 (Modulation wheel) outbound
;
; Called from: call from 0xFA773E.
; Evidence: it ends in `ld W,0x01 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x01 of that map is 0x01.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC01_Modulation__emit:   ; entry: call from 0xFA773E
	ld e, (0x195a:16)                            ; FA7781  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x01:opc                                   ; FA7785  20 01   ld W,0x01
	calr .LFA7BF3                                 ; FA7787  1e 69 04
.LFA778A:
	ret                                           ; FA778A  0e

; ---------------------------------------------------------------------
; MidiOut_CC0B_Expression -- echo controller 0x0B (Expression) outbound
;
; Called from: MidiOut_ParamNumberTable[179]; call from 0xFA66C4.
; Evidence: its tail MidiOut_CC0B_Expression__emit at 0xFA77F0 ends in
;          `ld W,0x03 / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x03 of that map is 0x0B.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC0B_Expression:   ; entry: MidiOut_ParamNumberTable[179]; call from 0xFA66C4
	cp b, 0x00:i3                                   ; FA778B  ca d8   cp B,0
	jr nz, .LFA77CA                               ; FA778D  6e 3b
	bit	7, (0x60f007:24)                      ; FA778F  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA77CA                               ; FA7794  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7796  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA779A  c9 cc f0
	cp a, 0x00:i3                                   ; FA779D  c9 d8   cp A,0
	jr z, .LFA77B1                                ; FA779F  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA77A1  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA77C9                                ; FA77A5  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA77A7  44 36 7f 00 00
	calr .LFA77F0                                 ; FA77AC  1e 41 00
	jr .LFA77C9                                   ; FA77AF  68 18
.LFA77B1:
	ld XIZ,0x00001a90                             ; FA77B1  46 90 1a 00 00
.LFA77B6:
	ld b, (xiz+)                               ; FA77B6  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA77B9  ca cf ff
	jr z, .LFA77C9                                ; FA77BC  66 0b
	push XIZ                                      ; FA77BE  3e
	ld (0x1959:16), b                            ; FA77BF  f1 59 19 42   ld (0x1959),B
	calr .LFA77CA                                 ; FA77C3  1e 04 00
	pop XIZ                                       ; FA77C6  5e
	jr .LFA77B6                                   ; FA77C7  68 ed
.LFA77C9:
	ret                                           ; FA77C9  0e
.LFA77CA:
; ---------------------------------------------------------------------
; MidiOut_CC0B_Expression__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC0B_Expression, `calr` at 0xFA77C3, once per part in the
;          0xFF-terminated list at RAM 0x1A90; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA778D, 0xFA7794).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC0BExpression
;          by index*4 (`ld XIX,0xFA9678` at 0xFA77D3); reject 0xFFFFFFFF; test
;          bit 3 of (0x7F39), a GLOBAL enable and not a record bit; fall through into MidiOut_CC0B_Expression__emit.
; Evidence: this is the ONE gate of the eleven with no record-bit test, and
;          MidiIn_BuildList_CC0BExpression is the ONE builder that passes BC=0xFFFF --
;          `ld BC,0xFFFF` at 0xFA829A -- i.e. accepts every part.
;          The two exceptions are the two ends of one pairing, which is
;          itself the agreement; --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC0B_Expression__partgate:   ; entry: call from 0xFA77C3
	ld l, (0x1959:16)                            ; FA77CA  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA77CE  cf cf 1f
	jr ugt, .LFA77F9                              ; FA77D1  6b 26
	ld XIX,MidiOut_PartRecordPtrs_CC0BExpression  ; FA77D3  44 78 96 fa 00
	extz HL                                       ; FA77D8  db 12
	sll l, 0x02                                   ; FA77DA  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA77DD  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA77E2  ec cf ff ff ff ff
	jr z, .LFA77F9                                ; FA77E8  66 0f
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA77EA  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA77F9                                ; FA77EE  66 09
.LFA77F0:

; ---------------------------------------------------------------------
; MidiOut_CC0B_Expression__emit -- echo controller 0x0B (Expression) outbound
;
; Called from: call from 0xFA77AC.
; Evidence: it ends in `ld W,0x03 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x03 of that map is 0x0B.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
; ---------------------------------------------------------------------
MidiOut_CC0B_Expression__emit:   ; entry: call from 0xFA77AC
	ld e, (0x195a:16)                            ; FA77F0  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x03:opc                                   ; FA77F4  20 03   ld W,0x03
	calr .LFA7BF3                                 ; FA77F6  1e fa 03
.LFA77F9:
	ret                                           ; FA77F9  0e
.LFA77FA:
; ---------------------------------------------------------------------
; MidiOut_ChannelPressure -- echo a CHANNEL PRESSURE message outbound, part by part
;
; ★ RENAMED FROM sub_FA77FA.  This message is NOT a control change, which
;          is why MidiOut_ChangeIndexMap -- a map indexed by CONTROLLER
;          NUMBER -- can never produce its record.  The ⚠ above
;          MidiOut_ChangeRecord_CC01Modulation, "two of the eleven records
;          are unreachable through that map ... stated, not explained", is
;          explained by this name and its twin, and that ⚠ is rewritten.
; Called from: MidiOut_ParamNumberTable[0xB4] -- the listing's own inline
;          entry comment spells that slot in decimal, 180 -- and directly
;          by MidiIn_ChannelPressure
;          at 0xFA6ED9, which the tree named from the inbound side.
; Body:    the three-routine shape of this family -- walk the 0xFF-terminated
;          part list at RAM 0x1A10 (`ld XIZ` at 0xFA7820), call MidiOut_ChannelPressure__partgate
;          once per part, and fall into MidiOut_ChannelPressure__emit.
; Evidence: THREE agreements, and not one of them is adjacency.
;          1. MidiOut_ChannelPressure__emit builds its status byte with `or A,0xD0`
;             at 0xFA7882.  0xDn is the channel-pressure status in MIDI 1.0.
;             ⚠ that step is a fact about the PROTOCOL, not about this ROM;
;             the others are facts about these bytes.
;          2. the same routine stages a 2-BYTE message -- `ld DE,0x0200`
;             at 0xFA7871 -- and 2 bytes is that message's length.
;          3. its caller at 0xFA6ED9 is MidiIn_ChannelPressure, the INBOUND handler
;             of the same message, named by a different pass from a
;             different table.
;          ⚠ AND NOT A FOURTH.  Its twin has one -- record 9's reset
;             value is the only one of the eleven that is not a
;             maximum -- and record 8's 0x7F00 is not distinctive.
; Unknown: what CPU 2 does with the message.  Nothing here says.
; ---------------------------------------------------------------------

MidiOut_ChannelPressure:   ; entry: MidiOut_ParamNumberTable[180]; call from 0xFA6ED9, 0xFA7EA1, 0xFA7EBF
	cp b, 0x00:i3                                   ; FA77FA  ca d8   cp B,0
	jr nz, .LFA7839                               ; FA77FC  6e 3b
	bit	7, (0x60f007:24)                      ; FA77FE  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7839                               ; FA7803  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7805  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA7809  c9 cc f0
	cp a, 0x00:i3                                   ; FA780C  c9 d8   cp A,0
	jr z, .LFA7820                                ; FA780E  66 10
	bit	5, (MidiFilter_ChannelMsgs:16)                        ; FA7810  f1 39 7f cd   bit 5,(0x7f39)
	jr z, .LFA7838                                ; FA7814  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA7816  44 36 7f 00 00
	calr .LFA786A                                 ; FA781B  1e 4c 00
	jr .LFA7838                                   ; FA781E  68 18
.LFA7820:
	ld XIZ,0x00001a10                             ; FA7820  46 10 1a 00 00
.LFA7825:
	ld b, (xiz+)                               ; FA7825  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA7828  ca cf ff
	jr z, .LFA7838                                ; FA782B  66 0b
	push XIZ                                      ; FA782D  3e
	ld (0x1959:16), b                            ; FA782E  f1 59 19 42   ld (0x1959),B
	calr .LFA7839                                 ; FA7832  1e 04 00
	pop XIZ                                       ; FA7835  5e
	jr .LFA7825                                   ; FA7836  68 ed
.LFA7838:
	ret                                           ; FA7838  0e
.LFA7839:
; ---------------------------------------------------------------------
; MidiOut_ChannelPressure__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_ChannelPressure, `calr` at 0xFA7832, once per part in the
;          0xFF-terminated list at RAM 0x1A10; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA77FC, 0xFA7803).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_ChannelPressure
;          by index*4 (`ld XIX,0xFA96F8` at 0xFA7842); reject 0xFFFFFFFF; test
;          bit 5 of (record+0x26); fall through into MidiOut_ChannelPressure__emit.
; Evidence: the (offset,mask) pair it tests is (+0x00, 0x20), and that is
;          EXACTLY the pair MidiIn_BuildList_ChannelPressure hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x2000` at 0xFA8222).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_ChannelPressure__partgate:   ; entry: call from 0xFA7832
	ld l, (0x1959:16)                            ; FA7839  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA783D  cf cf 1f
	jr ugt, .LFA7890                              ; FA7840  6b 4e
	ld XIX,MidiOut_PartRecordPtrs_ChannelPressure ; FA7842  44 f8 96 fa 00
	extz HL                                       ; FA7847  db 12
	sll l, 0x02                                   ; FA7849  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA784C  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7851  ec cf ff ff ff ff
	jr z, .LFA7890                                ; FA7857  66 37
	bit 5,(XIX+0x26)                              ; FA7859  bc 26 cd
	jr z, .LFA7890                                ; FA785C  66 32
	ld a, (0x60f007:24)                          ; FA785E  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA7863  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7871                               ; FA7868  6e 07
.LFA786A:
; ---------------------------------------------------------------------
; MidiOut_ChannelPressure__emit -- stage the CHANNEL PRESSURE bytes and post them
;
; Called from: MidiOut_ChannelPressure at 0xFA781B, and by fall-through from MidiOut_ChannelPressure__partgate.
; Body:    status byte = (the part record's byte 0, or (0x60F007) when bit 7
;          of (0x60F007) is set) & 0x0F, then `or A,0xD0` at 0xFA7882;
;          a length word 0x0200 into (0x194B) (`ld DE` at 0xFA7871);
;          the data bytes into (0x1948..); then MidiOut_PostStagedMessage.
; Evidence: as MidiOut_ChannelPressure.  ★ It ends in MidiOut_PostStagedMessage and NOT in
;          MidiOut_SendController, which is the mechanical difference
;          between this pair and the nine controller families beside them:
;          SendController's job is to map an index to a CONTROLLER NUMBER
;          through MidiOut_IndexToControllerNumber, and these two messages
;          do not have one.
; ---------------------------------------------------------------------

MidiOut_ChannelPressure__emit:   ; entry: call from 0xFA781B
	ld A,(XIX)                                    ; FA786A  84 21
	bit 0x06,A                                    ; FA786C  c9 33 06
	jr nz, .LFA7890                               ; FA786F  6e 1f
.LFA7871:
	ldw de, 0x0200                                ; FA7871  32 00 02   ld DE,0x0200
	bit 0x04,A                                    ; FA7874  c9 33 04
	jr z, .LFA787B                                ; FA7877  66 02
	ld e, 0x10:opc                                   ; FA7879  25 10   ld E,0x10
.LFA787B:
	ld (0x194b:16), de                           ; FA787B  f1 4b 19 52   ld (0x194b),DE
	and A,0x0f                                    ; FA787F  c9 cc 0f
	or A,0xd0                                     ; FA7882  c9 ce d0
	ld w, (0x195a:16)                            ; FA7885  c1 5a 19 20   ld W,(0x195a)
	ld (0x1948:16), wa                           ; FA7889  f1 48 19 50   ld (0x1948),WA
	calr .LFA7CE8                                 ; FA788D  1e 58 04
.LFA7890:
	ret                                           ; FA7890  0e

; ---------------------------------------------------------------------
; MidiOut_CC40_Hold -- echo controller 0x40 (Damper pedal (sustain)) outbound
;
; Called from: MidiOut_ParamNumberTable[181]; call from 0xFA64CF.
; Evidence: its tail MidiOut_CC40_Hold__emit at 0xFA78F5 ends in `ld
;          W,0x00 / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x00 of that map is 0x40.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC40_Damper.  Controller 64 is what this
;          instrument's own on-screen list at 0xFA2C13 calls
;          `HOLD       (#64)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Damper` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC40_Hold:   ; entry: MidiOut_ParamNumberTable[181]; call from 0xFA64CF
	cp b, 0x00:i3                                   ; FA7891  ca d8   cp B,0
	jr nz, .LFA78D0                               ; FA7893  6e 3b
	bit	7, (0x60f007:24)                      ; FA7895  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA78D0                               ; FA789A  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA789C  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA78A0  c9 cc f0
	cp a, 0x00:i3                                   ; FA78A3  c9 d8   cp A,0
	jr z, .LFA78B7                                ; FA78A5  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA78A7  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA78CF                                ; FA78AB  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA78AD  44 36 7f 00 00
	calr .LFA78F5                                 ; FA78B2  1e 40 00
	jr .LFA78CF                                   ; FA78B5  68 18
.LFA78B7:
	ld XIZ,0x00001a20                             ; FA78B7  46 20 1a 00 00
.LFA78BC:
	ld b, (xiz+)                               ; FA78BC  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA78BF  ca cf ff
	jr z, .LFA78CF                                ; FA78C2  66 0b
	push XIZ                                      ; FA78C4  3e
	ld (0x1959:16), b                            ; FA78C5  f1 59 19 42   ld (0x1959),B
	calr .LFA78D0                                 ; FA78C9  1e 04 00
	pop XIZ                                       ; FA78CC  5e
	jr .LFA78BC                                   ; FA78CD  68 ed
.LFA78CF:
	ret                                           ; FA78CF  0e
.LFA78D0:
; ---------------------------------------------------------------------
; MidiOut_CC40_Hold__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC40_Hold, `calr` at 0xFA78C9, once per part in the
;          0xFF-terminated list at RAM 0x1A20; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7893, 0xFA789A).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC40Hold
;          by index*4 (`ld XIX,0xFA9778` at 0xFA78D9); reject 0xFFFFFFFF; test
;          bit 0 of (record+0x27); fall through into MidiOut_CC40_Hold__emit.
; Evidence: the (offset,mask) pair it tests is (+0x01, 0x01), and that is
;          EXACTLY the pair MidiIn_BuildList_CC40Hold hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x0101` at 0xFA8231).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC40_Hold__partgate:   ; entry: call from 0xFA78C9
	ld l, (0x1959:16)                            ; FA78D0  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA78D4  cf cf 1f
	jr ugt, .LFA78FE                              ; FA78D7  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC40Hold        ; FA78D9  44 78 97 fa 00
	extz HL                                       ; FA78DE  db 12
	sll l, 0x02                                   ; FA78E0  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA78E3  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA78E8  ec cf ff ff ff ff
	jr z, .LFA78FE                                ; FA78EE  66 0e
	bit 0,(XIX+0x27)                              ; FA78F0  bc 27 c8
	jr z, .LFA78FE                                ; FA78F3  66 09
.LFA78F5:

; ---------------------------------------------------------------------
; MidiOut_CC40_Hold__emit -- echo controller 0x40 (Damper pedal (sustain)) outbound
;
; Called from: call from 0xFA78B2.
; Evidence: it ends in `ld W,0x00 / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x00 of that map is 0x40.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC40_Damper__emit.  Controller 64 is what this
;          instrument's own on-screen list at 0xFA2C13 calls
;          `HOLD       (#64)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Damper` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC40_Hold__emit:   ; entry: call from 0xFA78B2
	ld e, (0x195a:16)                            ; FA78F5  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x00:opc                                   ; FA78F9  20 00   ld W,0x00
	calr .LFA7BF3                                 ; FA78FB  1e f5 02
.LFA78FE:
	ret                                           ; FA78FE  0e

; ---------------------------------------------------------------------
; sub_FA78FF -- NOT NAMED.  A per-part gate of the family above whose send
;               index is dead, and which nothing reaches.
;
; ★ THIS LABEL EXISTS TO CORRECT A DOCUMENTED CLAIM.
;          notes/prom_a_understanding_round4.py --gaps says
;          "MidiOut_PartRecordPtrs_16/_17 -- ONE routine,
;          MidiOut_CC40_Hold__emit, loads both (0xFA790E and 0xFA793E), so a
;          reader-derived name would collide".  IT IS NOT ONE ROUTINE.
;          MidiOut_CC40_Hold__emit ends at the `ret` at 0xFA78FE; 0xFA78FF and
;          0xFA792F begin two MORE routines that carried no label at all, so
;          an address-to-nearest-label census credited both loads to the label
;          above them.  That is the same mis-scoping the tree already recorded
;          once, when a painter heuristic scoped to the source line instead of
;          the routine's own `ret`.  There is no collision to name around.
; Body:    `bit 3,(0x7F39)` at 0xFA78FF and return if clear; part index from
;          (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_16 by index*4
;          (`ld XIX,0xFA97F8` at 0xFA790E); reject 0xFFFFFFFF; (0x195A) into E,
;          0x09 into W (0xFA7929), `calr MidiOut_SendController`.  It does NOT
;          test a bit of the part record, which ten of the eleven live gates do.
; ★ THREE MEASUREMENTS, and they are why the name stops here:
;          1. NOTHING REACHES IT.  0xFA78FF occurs as a 24-bit little-endian
;             word NOWHERE in either of CPU 1's ROMs, and no `jr`, `jrl` or
;             `calr` anywhere in prom_a resolves to it.  Check X7 re-runs both
;             scans over the whole 512 KiB image.
;          2. ITS SEND CANNOT EMIT.  MidiOut_SendController maps W through
;             MidiOut_IndexToControllerNumber and DROPS the message when the
;             entry is 0xFF (`cp W,0xff` at 0xFA7C2E, then `jr Z`).  Entry
;             0x09 of that map is 0xFF, so this routine's message is dropped
;             even if it ever ran.  Check X8.
;          3. IT HAS NO CHANGE RECORD.  Eleven of the thirteen gates in this
;             address range are the [4:8] handlers of the eleven
;             MidiOut_ChangeRecord_*; these two are the two that are not.
; Unknown: WHAT IT WAS FOR.  The only thing separating it from its twin at
;          0xFA792F is a send index, and a send index has a referent only
;          inside this ROM's own tables.  The tree's rule for that is
;          `sub_XXXXXX` plus a stated gap; this is the stated gap.
; ---------------------------------------------------------------------

sub_FA78FF:
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA78FF  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA792E                                ; FA7903  66 29
	ld l, (0x1959:16)                            ; FA7905  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7909  cf cf 1f
	jr ugt, .LFA792E                              ; FA790C  6b 20
	ld XIX,MidiOut_PartRecordPtrs_16              ; FA790E  44 f8 97 fa 00
	extz HL                                       ; FA7913  db 12
	sll l, 0x02                                   ; FA7915  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7918  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA791D  ec cf ff ff ff ff
	jr z, .LFA792E                                ; FA7923  66 09
	ld e, (0x195a:16)                            ; FA7925  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x09:opc                                   ; FA7929  20 09   ld W,0x09
	calr .LFA7BF3                                 ; FA792B  1e c5 02
.LFA792E:
	ret                                           ; FA792E  0e

; ---------------------------------------------------------------------
; sub_FA792F -- NOT NAMED.  The twin of sub_FA78FF: same shape, same three
;               measurements, a different send index and a different table.
;
; Body:    `bit 3,(0x7F39)` at 0xFA792F and return if clear; part index from
;          (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_17 by index*4
;          (`ld XIX,0xFA9878` at 0xFA793E); reject 0xFFFFFFFF; (0x195A) into E,
;          0x08 into W (0xFA7959), `calr MidiOut_SendController`.  It does NOT
;          test a bit of the part record, which ten of the eleven live gates do.
; ★ THREE MEASUREMENTS, and they are why the name stops here:
;          1. NOTHING REACHES IT.  0xFA792F occurs as a 24-bit little-endian
;             word NOWHERE in either of CPU 1's ROMs, and no `jr`, `jrl` or
;             `calr` anywhere in prom_a resolves to it.  Check X7 re-runs both
;             scans over the whole 512 KiB image.
;          2. ITS SEND CANNOT EMIT.  MidiOut_SendController maps W through
;             MidiOut_IndexToControllerNumber and DROPS the message when the
;             entry is 0xFF (`cp W,0xff` at 0xFA7C2E, then `jr Z`).  Entry
;             0x08 of that map is 0xFF, so this routine's message is dropped
;             even if it ever ran.  Check X8.
;          3. IT HAS NO CHANGE RECORD.  Eleven of the thirteen gates in this
;             address range are the [4:8] handlers of the eleven
;             MidiOut_ChangeRecord_*; these two are the two that are not.
; Unknown: WHAT IT WAS FOR.  The only thing separating it from its twin at
;          0xFA78FF is a send index, and a send index has a referent only
;          inside this ROM's own tables.  The tree's rule for that is
;          `sub_XXXXXX` plus a stated gap; this is the stated gap.
; ---------------------------------------------------------------------

sub_FA792F:
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA792F  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA795E                                ; FA7933  66 29
	ld l, (0x1959:16)                            ; FA7935  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7939  cf cf 1f
	jr ugt, .LFA795E                              ; FA793C  6b 20
	ld XIX,MidiOut_PartRecordPtrs_17              ; FA793E  44 78 98 fa 00
	extz HL                                       ; FA7943  db 12
	sll l, 0x02                                   ; FA7945  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7948  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA794D  ec cf ff ff ff ff
	jr z, .LFA795E                                ; FA7953  66 09
	ld e, (0x195a:16)                            ; FA7955  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x08:opc                                   ; FA7959  20 08   ld W,0x08
	calr .LFA7BF3                                 ; FA795B  1e 95 02
.LFA795E:
	ret                                           ; FA795E  0e

; ---------------------------------------------------------------------
; MidiOut_CC10_RTCreatX -- echo controller 0x10 (General Purpose 1) outbound
;
; Called from: MidiOut_ParamNumberTable[184]; call from 0xFA6970.
; Evidence: its tail MidiOut_CC10_RTCreatX__emit at 0xFA79C3 ends in
;          `ld W,0x0c / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0c of that map is 0x10.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC10_General1.  Controller 16 is what this
;          instrument's own on-screen list at 0xFA2C23 calls
;          `R.T.CREAT.X(#16)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General1` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC10_RTCreatX:   ; entry: MidiOut_ParamNumberTable[184]; call from 0xFA6970
	cp b, 0x00:i3                                   ; FA795F  ca d8   cp B,0
	jr nz, .LFA799E                               ; FA7961  6e 3b
	bit	7, (0x60f007:24)                      ; FA7963  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA799E                               ; FA7968  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA796A  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA796E  c9 cc f0
	cp a, 0x00:i3                                   ; FA7971  c9 d8   cp A,0
	jr z, .LFA7985                                ; FA7973  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7975  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA799D                                ; FA7979  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA797B  44 36 7f 00 00
	calr .LFA79C3                                 ; FA7980  1e 40 00
	jr .LFA799D                                   ; FA7983  68 18
.LFA7985:
	ld XIZ,0x00001a30                             ; FA7985  46 30 1a 00 00
.LFA798A:
	ld b, (xiz+)                               ; FA798A  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA798D  ca cf ff
	jr z, .LFA799D                                ; FA7990  66 0b
	push XIZ                                      ; FA7992  3e
	ld (0x1959:16), b                            ; FA7993  f1 59 19 42   ld (0x1959),B
	calr .LFA799E                                 ; FA7997  1e 04 00
	pop XIZ                                       ; FA799A  5e
	jr .LFA798A                                   ; FA799B  68 ed
.LFA799D:
	ret                                           ; FA799D  0e
.LFA799E:
; ---------------------------------------------------------------------
; MidiOut_CC10_RTCreatX__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC10_RTCreatX, `calr` at 0xFA7997, once per part in the
;          0xFF-terminated list at RAM 0x1A30; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7961, 0xFA7968).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC10RTCreatX
;          by index*4 (`ld XIX,0xFA98F8` at 0xFA79A7); reject 0xFFFFFFFF; test
;          bit 0 of (record+0x29); fall through into MidiOut_CC10_RTCreatX__emit.
; Evidence: the (offset,mask) pair it tests is (+0x03, 0x01), and that is
;          EXACTLY the pair MidiIn_BuildList_CC10RTCreatX hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x0103` at 0xFA8240).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC10_RTCreatX__partgate:   ; entry: call from 0xFA7997
	ld l, (0x1959:16)                            ; FA799E  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA79A2  cf cf 1f
	jr ugt, .LFA79CC                              ; FA79A5  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC10RTCreatX    ; FA79A7  44 f8 98 fa 00
	extz HL                                       ; FA79AC  db 12
	sll l, 0x02                                   ; FA79AE  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA79B1  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA79B6  ec cf ff ff ff ff
	jr z, .LFA79CC                                ; FA79BC  66 0e
	bit 0,(XIX+0x29)                              ; FA79BE  bc 29 c8
	jr z, .LFA79CC                                ; FA79C1  66 09
.LFA79C3:

; ---------------------------------------------------------------------
; MidiOut_CC10_RTCreatX__emit -- echo controller 0x10 (General Purpose 1) outbound
;
; Called from: call from 0xFA7980.
; Evidence: it ends in `ld W,0x0c / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0c of that map is 0x10.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC10_General1__emit.  Controller 16 is what this
;          instrument's own on-screen list at 0xFA2C23 calls
;          `R.T.CREAT.X(#16)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General1` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC10_RTCreatX__emit:   ; entry: call from 0xFA7980
	ld e, (0x195a:16)                            ; FA79C3  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x0c:opc                                   ; FA79C7  20 0c   ld W,0x0c
	calr .LFA7BF3                                 ; FA79C9  1e 27 02
.LFA79CC:
	ret                                           ; FA79CC  0e

; ---------------------------------------------------------------------
; MidiOut_CC11_RTCreatY -- echo controller 0x11 (General Purpose 2) outbound
;
; Called from: MidiOut_ParamNumberTable[185]; call from 0xFA69FA.
; Evidence: its tail MidiOut_CC11_RTCreatY__emit at 0xFA7A31 ends in
;          `ld W,0x0d / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0d of that map is 0x11.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC11_General2.  Controller 17 is what this
;          instrument's own on-screen list at 0xFA2C33 calls
;          `R.T.CREAT.Y(#17)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General2` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC11_RTCreatY:   ; entry: MidiOut_ParamNumberTable[185]; call from 0xFA69FA
	cp b, 0x00:i3                                   ; FA79CD  ca d8   cp B,0
	jr nz, .LFA7A0C                               ; FA79CF  6e 3b
	bit	7, (0x60f007:24)                      ; FA79D1  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7A0C                               ; FA79D6  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA79D8  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA79DC  c9 cc f0
	cp a, 0x00:i3                                   ; FA79DF  c9 d8   cp A,0
	jr z, .LFA79F3                                ; FA79E1  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA79E3  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7A0B                                ; FA79E7  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA79E9  44 36 7f 00 00
	calr .LFA7A31                                 ; FA79EE  1e 40 00
	jr .LFA7A0B                                   ; FA79F1  68 18
.LFA79F3:
	ld XIZ,0x00001a40                             ; FA79F3  46 40 1a 00 00
.LFA79F8:
	ld b, (xiz+)                               ; FA79F8  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA79FB  ca cf ff
	jr Z,.LFA7A0B                                 ; FA79FE  66 0b
	push XIZ                                      ; FA7A00  3e
	ld (0x1959:16), b                            ; FA7A01  f1 59 19 42   ld (0x1959),B
	calr .LFA7A0C                                 ; FA7A05  1e 04 00
	pop XIZ                                       ; FA7A08  5e
	jr .LFA79F8                                   ; FA7A09  68 ed
.LFA7A0B:
	ret                                           ; FA7A0B  0e
.LFA7A0C:
; ---------------------------------------------------------------------
; MidiOut_CC11_RTCreatY__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC11_RTCreatY, `calr` at 0xFA7A05, once per part in the
;          0xFF-terminated list at RAM 0x1A40; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA79CF, 0xFA79D6).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC11RTCreatY
;          by index*4 (`ld XIX,0xFA9978` at 0xFA7A15); reject 0xFFFFFFFF; test
;          bit 1 of (record+0x29); fall through into MidiOut_CC11_RTCreatY__emit.
; Evidence: the (offset,mask) pair it tests is (+0x03, 0x02), and that is
;          EXACTLY the pair MidiIn_BuildList_CC11RTCreatY hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x0203` at 0xFA824F).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC11_RTCreatY__partgate:   ; entry: call from 0xFA7A05
	ld l, (0x1959:16)                            ; FA7A0C  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7A10  cf cf 1f
	jr ugt, .LFA7A3A                              ; FA7A13  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC11RTCreatY    ; FA7A15  44 78 99 fa 00
	extz HL                                       ; FA7A1A  db 12
	sll l, 0x02                                   ; FA7A1C  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7A1F  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7A24  ec cf ff ff ff ff
	jr z, .LFA7A3A                                ; FA7A2A  66 0e
	bit 1,(XIX+0x29)                              ; FA7A2C  bc 29 c9
	jr z, .LFA7A3A                                ; FA7A2F  66 09
.LFA7A31:

; ---------------------------------------------------------------------
; MidiOut_CC11_RTCreatY__emit -- echo controller 0x11 (General Purpose 2) outbound
;
; Called from: call from 0xFA79EE.
; Evidence: it ends in `ld W,0x0d / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0d of that map is 0x11.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC11_General2__emit.  Controller 17 is what this
;          instrument's own on-screen list at 0xFA2C33 calls
;          `R.T.CREAT.Y(#17)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General2` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC11_RTCreatY__emit:   ; entry: call from 0xFA79EE
	ld e, (0x195a:16)                            ; FA7A31  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x0d:opc                                   ; FA7A35  20 0d   ld W,0x0d
	calr .LFA7BF3                                 ; FA7A37  1e b9 01
.LFA7A3A:
	ret                                           ; FA7A3A  0e

; ---------------------------------------------------------------------
; MidiOut_CC12_RTCtrlX -- echo controller 0x12 (General Purpose 3) outbound
;
; Called from: MidiOut_ParamNumberTable[186]; call from 0xFA6A84.
; Evidence: its tail MidiOut_CC12_RTCtrlX__emit at 0xFA7A9F ends in
;          `ld W,0x0e / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0e of that map is 0x12.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC12_General3.  Controller 18 is what this
;          instrument's own on-screen list at 0xFA2C43 calls
;          `R.T.CTRL. X(#18)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General3` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC12_RTCtrlX:   ; entry: MidiOut_ParamNumberTable[186]; call from 0xFA6A84
	cp b, 0x00:i3                                   ; FA7A3B  ca d8   cp B,0
	jr nz, .LFA7A7A                               ; FA7A3D  6e 3b
	bit	7, (0x60f007:24)                      ; FA7A3F  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7A7A                               ; FA7A44  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7A46  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA7A4A  c9 cc f0
	cp a, 0x00:i3                                   ; FA7A4D  c9 d8   cp A,0
	jr z, .LFA7A61                                ; FA7A4F  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7A51  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7A79                                ; FA7A55  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA7A57  44 36 7f 00 00
	calr .LFA7A9F                                 ; FA7A5C  1e 40 00
	jr .LFA7A79                                   ; FA7A5F  68 18
.LFA7A61:
	ld XIZ,0x00001a50                             ; FA7A61  46 50 1a 00 00
.LFA7A66:
	ld b, (xiz+)                               ; FA7A66  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA7A69  ca cf ff
	jr z, .LFA7A79                                ; FA7A6C  66 0b
	push XIZ                                      ; FA7A6E  3e
	ld (0x1959:16), b                            ; FA7A6F  f1 59 19 42   ld (0x1959),B
	calr .LFA7A7A                                 ; FA7A73  1e 04 00
	pop XIZ                                       ; FA7A76  5e
	jr .LFA7A66                                   ; FA7A77  68 ed
.LFA7A79:
	ret                                           ; FA7A79  0e
.LFA7A7A:
; ---------------------------------------------------------------------
; MidiOut_CC12_RTCtrlX__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC12_RTCtrlX, `calr` at 0xFA7A73, once per part in the
;          0xFF-terminated list at RAM 0x1A50; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7A3D, 0xFA7A44).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC12RTCtrlX
;          by index*4 (`ld XIX,0xFA99F8` at 0xFA7A83); reject 0xFFFFFFFF; test
;          bit 2 of (record+0x29); fall through into MidiOut_CC12_RTCtrlX__emit.
; Evidence: the (offset,mask) pair it tests is (+0x03, 0x04), and that is
;          EXACTLY the pair MidiIn_BuildList_CC12RTCtrlX hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x0403` at 0xFA825E).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC12_RTCtrlX__partgate:   ; entry: call from 0xFA7A73
	ld l, (0x1959:16)                            ; FA7A7A  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7A7E  cf cf 1f
	jr ugt, .LFA7AA8                              ; FA7A81  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC12RTCtrlX     ; FA7A83  44 f8 99 fa 00
	extz HL                                       ; FA7A88  db 12
	sll l, 0x02                                   ; FA7A8A  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7A8D  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7A92  ec cf ff ff ff ff
	jr z, .LFA7AA8                                ; FA7A98  66 0e
	bit 2,(XIX+0x29)                              ; FA7A9A  bc 29 ca
	jr z, .LFA7AA8                                ; FA7A9D  66 09
.LFA7A9F:

; ---------------------------------------------------------------------
; MidiOut_CC12_RTCtrlX__emit -- echo controller 0x12 (General Purpose 3) outbound
;
; Called from: call from 0xFA7A5C.
; Evidence: it ends in `ld W,0x0e / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0e of that map is 0x12.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC12_General3__emit.  Controller 18 is what this
;          instrument's own on-screen list at 0xFA2C43 calls
;          `R.T.CTRL. X(#18)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General3` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC12_RTCtrlX__emit:   ; entry: call from 0xFA7A5C
	ld e, (0x195a:16)                            ; FA7A9F  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x0e:opc                                   ; FA7AA3  20 0e   ld W,0x0e
	calr .LFA7BF3                                 ; FA7AA5  1e 4b 01
.LFA7AA8:
	ret                                           ; FA7AA8  0e

; ---------------------------------------------------------------------
; MidiOut_CC13_RTCtrlY -- echo controller 0x13 (General Purpose 4) outbound
;
; Called from: MidiOut_ParamNumberTable[187]; call from 0xFA6B0E.
; Evidence: its tail MidiOut_CC13_RTCtrlY__emit at 0xFA7B0D ends in
;          `ld W,0x0f / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0f of that map is 0x13.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC13_General4.  Controller 19 is what this
;          instrument's own on-screen list at 0xFA2C53 calls
;          `R.T.CTRL. Y(#19)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General4` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC13_RTCtrlY:   ; entry: MidiOut_ParamNumberTable[187]; call from 0xFA6B0E
	cp b, 0x00:i3                                   ; FA7AA9  ca d8   cp B,0
	jr nz, .LFA7AE8                               ; FA7AAB  6e 3b
	bit	7, (0x60f007:24)                      ; FA7AAD  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7AE8                               ; FA7AB2  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7AB4  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA7AB8  c9 cc f0
	cp a, 0x00:i3                                   ; FA7ABB  c9 d8   cp A,0
	jr z, .LFA7ACF                                ; FA7ABD  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7ABF  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7AE7                                ; FA7AC3  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA7AC5  44 36 7f 00 00
	calr .LFA7B0D                                 ; FA7ACA  1e 40 00
	jr .LFA7AE7                                   ; FA7ACD  68 18
.LFA7ACF:
	ld XIZ,0x00001a60                             ; FA7ACF  46 60 1a 00 00
.LFA7AD4:
	ld b, (xiz+)                               ; FA7AD4  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA7AD7  ca cf ff
	jr z, .LFA7AE7                                ; FA7ADA  66 0b
	push XIZ                                      ; FA7ADC  3e
	ld (0x1959:16), b                            ; FA7ADD  f1 59 19 42   ld (0x1959),B
	calr .LFA7AE8                                 ; FA7AE1  1e 04 00
	pop XIZ                                       ; FA7AE4  5e
	jr .LFA7AD4                                   ; FA7AE5  68 ed
.LFA7AE7:
	ret                                           ; FA7AE7  0e
.LFA7AE8:
; ---------------------------------------------------------------------
; MidiOut_CC13_RTCtrlY__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC13_RTCtrlY, `calr` at 0xFA7AE1, once per part in the
;          0xFF-terminated list at RAM 0x1A60; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7AAB, 0xFA7AB2).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC13RTCtrlY
;          by index*4 (`ld XIX,0xFA9A78` at 0xFA7AF1); reject 0xFFFFFFFF; test
;          bit 3 of (record+0x29); fall through into MidiOut_CC13_RTCtrlY__emit.
; Evidence: the (offset,mask) pair it tests is (+0x03, 0x08), and that is
;          EXACTLY the pair MidiIn_BuildList_CC13RTCtrlY hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x0803` at 0xFA826D).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC13_RTCtrlY__partgate:   ; entry: call from 0xFA7AE1
	ld l, (0x1959:16)                            ; FA7AE8  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7AEC  cf cf 1f
	jr ugt, .LFA7B16                              ; FA7AEF  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC13RTCtrlY     ; FA7AF1  44 78 9a fa 00
	extz HL                                       ; FA7AF6  db 12
	sll l, 0x02                                   ; FA7AF8  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7AFB  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7B00  ec cf ff ff ff ff
	jr z, .LFA7B16                                ; FA7B06  66 0e
	bit 3,(XIX+0x29)                              ; FA7B08  bc 29 cb
	jr z, .LFA7B16                                ; FA7B0B  66 09
.LFA7B0D:

; ---------------------------------------------------------------------
; MidiOut_CC13_RTCtrlY__emit -- echo controller 0x13 (General Purpose 4) outbound
;
; Called from: call from 0xFA7ACA.
; Evidence: it ends in `ld W,0x0f / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0f of that map is 0x13.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC13_General4__emit.  Controller 19 is what this
;          instrument's own on-screen list at 0xFA2C53 calls
;          `R.T.CTRL. Y(#19)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `General4` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC13_RTCtrlY__emit:   ; entry: call from 0xFA7ACA
	ld e, (0x195a:16)                            ; FA7B0D  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x0f:opc                                   ; FA7B11  20 0f   ld W,0x0f
	calr .LFA7BF3                                 ; FA7B13  1e dd 00
.LFA7B16:
	ret                                           ; FA7B16  0e

; ---------------------------------------------------------------------
; MidiOut_CC02_Modulation2 -- echo controller 0x02 (Breath controller) outbound
;
; Called from: MidiOut_ParamNumberTable[188]; call from 0xFA685C.
; Evidence: its tail MidiOut_CC02_Modulation2__emit at 0xFA7B7B ends in `ld
;          W,0x0a / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0a of that map is 0x02.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC02_Breath.  Controller 2 is what this
;          instrument's own on-screen list at 0xFA2BE3 calls
;          `MODULATION2(# 2)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Breath` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC02_Modulation2:   ; entry: MidiOut_ParamNumberTable[188]; call from 0xFA685C
	cp b, 0x00:i3                                   ; FA7B17  ca d8   cp B,0
	jr nz, .LFA7B56                               ; FA7B19  6e 3b
	bit	7, (0x60f007:24)                      ; FA7B1B  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7B56                               ; FA7B20  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7B22  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA7B26  c9 cc f0
	cp a, 0x00:i3                                   ; FA7B29  c9 d8   cp A,0
	jr z, .LFA7B3D                                ; FA7B2B  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7B2D  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7B55                                ; FA7B31  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA7B33  44 36 7f 00 00
	calr .LFA7B7B                                 ; FA7B38  1e 40 00
	jr .LFA7B55                                   ; FA7B3B  68 18
.LFA7B3D:
	ld XIZ,0x00001a70                             ; FA7B3D  46 70 1a 00 00
.LFA7B42:
	ld b, (xiz+)                               ; FA7B42  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA7B45  ca cf ff
	jr z, .LFA7B55                                ; FA7B48  66 0b
	push XIZ                                      ; FA7B4A  3e
	ld (0x1959:16), b                            ; FA7B4B  f1 59 19 42   ld (0x1959),B
	calr .LFA7B56                                 ; FA7B4F  1e 04 00
	pop XIZ                                       ; FA7B52  5e
	jr .LFA7B42                                   ; FA7B53  68 ed
.LFA7B55:
	ret                                           ; FA7B55  0e
.LFA7B56:
; ---------------------------------------------------------------------
; MidiOut_CC02_Modulation2__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC02_Modulation2, `calr` at 0xFA7B4F, once per part in the
;          0xFF-terminated list at RAM 0x1A70; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7B19, 0xFA7B20).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC02Modulation2
;          by index*4 (`ld XIX,0xFA9AF8` at 0xFA7B5F); reject 0xFFFFFFFF; test
;          bit 4 of (record+0x29); fall through into MidiOut_CC02_Modulation2__emit.
; Evidence: the (offset,mask) pair it tests is (+0x03, 0x10), and that is
;          EXACTLY the pair MidiIn_BuildList_CC02Modulation2 hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x1003` at 0xFA827C).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC02_Modulation2__partgate:   ; entry: call from 0xFA7B4F
	ld l, (0x1959:16)                            ; FA7B56  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7B5A  cf cf 1f
	jr ugt, .LFA7B84                              ; FA7B5D  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC02Modulation2 ; FA7B5F  44 f8 9a fa 00
	extz HL                                       ; FA7B64  db 12
	sll l, 0x02                                   ; FA7B66  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7B69  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7B6E  ec cf ff ff ff ff
	jr z, .LFA7B84                                ; FA7B74  66 0e
	bit 4,(XIX+0x29)                              ; FA7B76  bc 29 cc
	jr z, .LFA7B84                                ; FA7B79  66 09
.LFA7B7B:

; ---------------------------------------------------------------------
; MidiOut_CC02_Modulation2__emit -- echo controller 0x02 (Breath controller) outbound
;
; Called from: call from 0xFA7B38.
; Evidence: it ends in `ld W,0x0a / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0a of that map is 0x02.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC02_Breath__emit.  Controller 2 is what this
;          instrument's own on-screen list at 0xFA2BE3 calls
;          `MODULATION2(# 2)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Breath` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC02_Modulation2__emit:   ; entry: call from 0xFA7B38
	ld e, (0x195a:16)                            ; FA7B7B  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x0a:opc                                   ; FA7B7F  20 0a   ld W,0x0a
	calr .LFA7BF3                                 ; FA7B81  1e 6f 00
.LFA7B84:
	ret                                           ; FA7B84  0e

; ---------------------------------------------------------------------
; MidiOut_CC04_CtrlPedal -- echo controller 0x04 (Foot controller) outbound
;
; Called from: MidiOut_ParamNumberTable[189]; call from 0xFA68E6.
; Evidence: its tail MidiOut_CC04_CtrlPedal__emit at 0xFA7BE9 ends in `ld
;          W,0x0b / calr MidiOut_SendController`, which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0b of that map is 0x04.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC04_Foot.  Controller 4 is what this
;          instrument's own on-screen list at 0xFA2BF3 calls
;          `CTRL.PEDAL (# 4)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Foot` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC04_CtrlPedal:   ; entry: MidiOut_ParamNumberTable[189]; call from 0xFA68E6
	cp b, 0x00:i3                                   ; FA7B85  ca d8   cp B,0
	jr nz, .LFA7BC4                               ; FA7B87  6e 3b
	bit	7, (0x60f007:24)                      ; FA7B89  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7BC4                               ; FA7B8E  6e 34
	ld a, (MidiCfg_InOutMode:16)                            ; FA7B90  c1 35 7f 21   ld A,(0x7f35)
	and A,0xf0                                    ; FA7B94  c9 cc f0
	cp a, 0x00:i3                                   ; FA7B97  c9 d8   cp A,0
	jr z, .LFA7BAB                                ; FA7B99  66 10
	bit	3, (MidiFilter_ChannelMsgs:16)                        ; FA7B9B  f1 39 7f cb   bit 3,(0x7f39)
	jr z, .LFA7BC3                                ; FA7B9F  66 22
	ld XIX,MidiCfg_SingleChannel                             ; FA7BA1  44 36 7f 00 00
	calr .LFA7BE9                                 ; FA7BA6  1e 40 00
	jr .LFA7BC3                                   ; FA7BA9  68 18
.LFA7BAB:
	ld XIZ,0x00001a80                             ; FA7BAB  46 80 1a 00 00
.LFA7BB0:
	ld b, (xiz+)                               ; FA7BB0  c5 f8 22   ld B,(XIZ+)
	cp B,0xff                                     ; FA7BB3  ca cf ff
	jr z, .LFA7BC3                                ; FA7BB6  66 0b
	push XIZ                                      ; FA7BB8  3e
	ld (0x1959:16), b                            ; FA7BB9  f1 59 19 42   ld (0x1959),B
	calr .LFA7BC4                                 ; FA7BBD  1e 04 00
	pop XIZ                                       ; FA7BC0  5e
	jr .LFA7BB0                                   ; FA7BC1  68 ed
.LFA7BC3:
	ret                                           ; FA7BC3  0e
.LFA7BC4:
; ---------------------------------------------------------------------
; MidiOut_CC04_CtrlPedal__partgate -- emit for ONE part, if that part's record allows it
;
; Called from: MidiOut_CC04_CtrlPedal, `calr` at 0xFA7BBD, once per part in the
;          0xFF-terminated list at RAM 0x1A80; and by fall-in from that
;          routine's two early rejects (`jr NZ` at 0xFA7B87, 0xFA7B8E).
; Body:    part index from (0x1959), rejected above 0x1F; index MidiOut_PartRecordPtrs_CC04CtrlPedal
;          by index*4 (`ld XIX,0xFA9B78` at 0xFA7BCD); reject 0xFFFFFFFF; test
;          bit 5 of (record+0x29); fall through into MidiOut_CC04_CtrlPedal__emit.
; Evidence: the (offset,mask) pair it tests is (+0x03, 0x20), and that is
;          EXACTLY the pair MidiIn_BuildList_CC04CtrlPedal hands MidiIn_BuildPartList
;          to choose the parts that go in the list this gate is called for
;          (`ld BC,0x2003` at 0xFA828B).  TEN of the eleven gates agree with
;          their own builder that way, and --midi prints all eleven.
; ---------------------------------------------------------------------

MidiOut_CC04_CtrlPedal__partgate:   ; entry: call from 0xFA7BBD
	ld l, (0x1959:16)                            ; FA7BC4  c1 59 19 27   ld L,(0x1959)
	cp L,0x1f                                     ; FA7BC8  cf cf 1f
	jr ugt, .LFA7BF2                              ; FA7BCB  6b 25
	ld XIX,MidiOut_PartRecordPtrs_CC04CtrlPedal   ; FA7BCD  44 78 9b fa 00
	extz HL                                       ; FA7BD2  db 12
	sll l, 0x02                                   ; FA7BD4  cf ee 02   sll 0x02,L
	ld	xix, (xix+hl)                         ; FA7BD7  e3 07 f0 ec 24   ld XIX,(XIX+HL)
	cp XIX,0xffffffff                             ; FA7BDC  ec cf ff ff ff ff
	jr z, .LFA7BF2                                ; FA7BE2  66 0e
	bit 5,(XIX+0x29)                              ; FA7BE4  bc 29 cd
	jr z, .LFA7BF2                                ; FA7BE7  66 09
.LFA7BE9:

; ---------------------------------------------------------------------
; MidiOut_CC04_CtrlPedal__emit -- echo controller 0x04 (Foot controller) outbound
;
; Called from: call from 0xFA7BA6.
; Evidence: it ends in `ld W,0x0b / calr MidiOut_SendController`,
;          which
;          maps the index through MidiOut_IndexToControllerNumber; entry
;          0x0b of that map is 0x04.  Check E asserts this agrees with
;          the inbound handler's controller number wherever one calls it.
;
; ★ RENAMED FROM MidiOut_CC04_Foot__emit.  Controller 4 is what this
;          instrument's own on-screen list at 0xFA2BF3 calls
;          `CTRL.PEDAL (# 4)` -- the string is 16 bytes and carries the
;          controller number in its own text.  `Foot` is the MIDI 1.0
;          spec's word for the same controller number, not this
;          machine's, and for `Breath` and `General` the spec word
;          occurs ZERO times in all four images (check W2).  The
;          controller NUMBER in the label is unchanged and is still
;          the thing that is proven; only the gloss moved to the
;          word the ROM itself uses.
; Evidence: notes/prom_a_understanding_round4.py --controllers prints
;          both lists straight from the ROM; check W1 re-reads this
;          entry and re-extracts the number from the parentheses.
; ---------------------------------------------------------------------
MidiOut_CC04_CtrlPedal__emit:   ; entry: call from 0xFA7BA6
	ld e, (0x195a:16)                            ; FA7BE9  c1 5a 19 25   ld E,(0x195a)
	ld w, 0x0b:opc                                   ; FA7BED  20 0b   ld W,0x0b
	calr .LFA7BF3                                 ; FA7BEF  1e 01 00
.LFA7BF2:
	ret                                           ; FA7BF2  0e
.LFA7BF3:

; ---------------------------------------------------------------------
; MidiOut_SendController -- emit `Bn <cc> <value>` for an internal index
;
; Called from: 19 sites, all inside this module.
; Inputs:  W = the internal controller index, E = the value, XIX = the
;          part's RAM record.
; Outputs: the message staged at 0x1948 and handed to
;          MidiOut_PostStagedMessage.
; Evidence: `cp W,0x2f / jr UGT` then `ld XIZ,0x00FA8FC8 / ld W,(XIZ+W)`
;          -- the index is looked up in MidiOut_IndexToControllerNumber and
;          0xFF means `no controller, drop it`.  0x2F + 1 = 48 is that map's
;          length and 0xFA8FC8 + 48 = 0xFA8FF8, the next object's base.
;          The status byte is built by `and A,0x0F / or A,0xB0`.
; ---------------------------------------------------------------------
MidiOut_SendController:   ; entry: call from 0xFA725C, 0xFA729A, 0xFA72D3, 0xFA7311, 0xFA734F, 0xFA7506, +13 more
	pushw bc                                      ; FA7BF3  29   push BC
	ld a, (0x60f007:24)                          ; FA7BF4  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA7BF9  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr NZ,.LFA7C07                                ; FA7BFE  6e 07
	ld A,(XIX)                                    ; FA7C00  84 21
	bit 0x06,A                                    ; FA7C02  c9 33 06
	jr nz, .LFA7C3C                               ; FA7C05  6e 35
.LFA7C07:
	ld XIY,0x00001948                             ; FA7C07  45 48 19 00 00
	ldw bc, 0x0300                                ; FA7C0C  31 00 03   ld BC,0x0300
	bit 0x04,A                                    ; FA7C0F  c9 33 04
	jr z, .LFA7C16                                ; FA7C12  66 02
	ld c, 0x10:opc                                   ; FA7C14  23 10   ld C,0x10
.LFA7C16:
	ld (XIY+0x03),BC                              ; FA7C16  bd 03 51
	and A,0x0f                                    ; FA7C19  c9 cc 0f
	or A,0xb0                                     ; FA7C1C  c9 ce b0
	cp W,0x2f                                     ; FA7C1F  c8 cf 2f
	jr ugt, .LFA7C3C                              ; FA7C22  6b 18
	ld XIZ,MidiOut_IndexToControllerNumber        ; FA7C24  46 c8 8f fa 00
	ld	w, (xiz+w)                            ; FA7C29  c3 03 f8 e1 20   ld W,(XIZ+W)
	cp W,0xff                                     ; FA7C2E  c8 cf ff
	jr z, .LFA7C3C                                ; FA7C31  66 09
	ld	(xiy+0:8), wa                         ; FA7C33  bd 00 50   ld (XIY+0x00),WA
	ld (XIY+0x02),E                               ; FA7C36  bd 02 45
	calr .LFA7CE8                                 ; FA7C39  1e ac 00
.LFA7C3C:
	popw bc                                       ; FA7C3C  49   pop BC
	ret                                           ; FA7C3D  0e

; ---------------------------------------------------------------------
; MidiOut_SendRpn -- emit a four-message RPN write
;
; Called from: 0xFA738B, 0xFA73CD, 0xFA7409 -- the class handlers for
;          classes 9, 10 and 11.
; Evidence: it stages four controller numbers in order, 0x64, 0x65, 0x06 and
;          0x26 (`ld W,0x64`, `ld A,0x65`, `ld A,0x06`, `ld A,0x26`), which
;          is RPN LSB, RPN MSB, Data Entry MSB, Data Entry LSB -- the
;          standard RPN sequence.  C and B carry the RPN number, D and E the
;          data.
; ★ The three callers are classes 9, 10 and 11, and MidiIn_CC06_DataEntryMSB
;   writes exactly those three class numbers for RPN 0x0002, 0x0001 and
;   0x0000 -- coarse tune, fine tune and pitch-bend sensitivity.  The two
;   halves agree without either being written from the other.
; ---------------------------------------------------------------------
MidiOut_SendRpn:   ; entry: call from 0xFA738B, 0xFA73CD, 0xFA7409
	ld a, (0x60f007:24)                          ; FA7C3E  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA7C43  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7C51                               ; FA7C48  6e 07
	ld A,(XIX)                                    ; FA7C4A  84 21
	bit 0x06,A                                    ; FA7C4C  c9 33 06
	jr nz, .LFA7C94                               ; FA7C4F  6e 43
.LFA7C51:
	ld XIY,0x00001948                             ; FA7C51  45 48 19 00 00
	pushw bc                                      ; FA7C56  29   push BC
	ldw bc, 0x0300                                ; FA7C57  31 00 03   ld BC,0x0300
	bit 0x04,A                                    ; FA7C5A  c9 33 04
	jr z, .LFA7C61                                ; FA7C5D  66 02
	ld c, 0x10:opc                                   ; FA7C5F  23 10   ld C,0x10
.LFA7C61:
	ld (XIY+0x03),BC                              ; FA7C61  bd 03 51
	popw bc                                       ; FA7C64  49   pop BC
	and A,0x0f                                    ; FA7C65  c9 cc 0f
	or A,0xb0                                     ; FA7C68  c9 ce b0
	ld w, 0x64:opc                                   ; FA7C6B  20 64   ld W,0x64
	ld	(xiy+0:8), wa                         ; FA7C6D  bd 00 50   ld (XIY+0x00),WA
	ld (XIY+0x02),C                               ; FA7C70  bd 02 43
	calr .LFA7CE8                                 ; FA7C73  1e 72 00
	ld a, 0x65:opc                                   ; FA7C76  21 65   ld A,0x65
	ld W,B                                        ; FA7C78  ca 88
	ld (XIY+0x01),WA                              ; FA7C7A  bd 01 50
	calr .LFA7CE8                                 ; FA7C7D  1e 68 00
	ld a, 0x06:opc                                   ; FA7C80  21 06   ld A,0x06
	ld W,D                                        ; FA7C82  cc 88
	ld (XIY+0x01),WA                              ; FA7C84  bd 01 50
	calr .LFA7CE8                                 ; FA7C87  1e 5e 00
	ld a, 0x26:opc                                   ; FA7C8A  21 26   ld A,0x26
	ld W,E                                        ; FA7C8C  cd 88
	ld (XIY+0x01),WA                              ; FA7C8E  bd 01 50
	calr .LFA7CE8                                 ; FA7C91  1e 54 00
.LFA7C94:
	ret                                           ; FA7C94  0e
.LFA7C95:

; ---------------------------------------------------------------------
; MidiOut_SendBankSelect -- emit CC 0 then CC 32
;
; Called from: 0xFA7448, 0xFA7490, 0xFA74CC, 0xFA7580.
; Evidence: `ld W,0x00` with D, then `ld W,0x20` with E, each followed by
;          MidiOut_PostStagedMessage; both values have bit 7 cleared first.
;          Gated on bit 7 of (0x7F3A) and bit 7 of the part record's +0x27.
; ---------------------------------------------------------------------
MidiOut_SendBankSelect:   ; entry: call from 0xFA7448, 0xFA7490, 0xFA74CC, 0xFA7580
	bit	7, (MidiFilter_BankSelect:16)                        ; FA7C95  f1 3a 7f cf   bit 7,(0x7f3a)
	jr z, .LFA7CE7                                ; FA7C99  66 4c
	bit 7,(XIX+0x27)                              ; FA7C9B  bc 27 cf
	jr z, .LFA7CE7                                ; FA7C9E  66 47
	ld a, (0x60f007:24)                          ; FA7CA0  c2 07 f0 60 21   ld A,(0x60f007)
	bit	7, (0x60f007:24)                      ; FA7CA5  f2 07 f0 60 cf   bit 7,(0x60f007)
	jr nz, .LFA7CB3                               ; FA7CAA  6e 07
	ld A,(XIX)                                    ; FA7CAC  84 21
	bit 0x06,A                                    ; FA7CAE  c9 33 06
	jr nz, .LFA7CE7                               ; FA7CB1  6e 34
.LFA7CB3:
	ld XIY,0x00001948                             ; FA7CB3  45 48 19 00 00
	ldw bc, 0x0300                                ; FA7CB8  31 00 03   ld BC,0x0300
	bit 0x04,A                                    ; FA7CBB  c9 33 04
	jr z, .LFA7CC2                                ; FA7CBE  66 02
	ld c, 0x10:opc                                   ; FA7CC0  23 10   ld C,0x10
.LFA7CC2:
	ld (XIY+0x03),BC                              ; FA7CC2  bd 03 51
	and A,0x0f                                    ; FA7CC5  c9 cc 0f
	or A,0xb0                                     ; FA7CC8  c9 ce b0
	ld w, 0x00:opc                                   ; FA7CCB  20 00   ld W,0x00
	ld	(xiy+0:8), wa                         ; FA7CCD  bd 00 50   ld (XIY+0x00),WA
	res 0x07,D                                    ; FA7CD0  cc 30 07
	ld (XIY+0x02),D                               ; FA7CD3  bd 02 44
	calr .LFA7CE8                                 ; FA7CD6  1e 0f 00
	ld w, 0x20:opc                                   ; FA7CD9  20 20   ld W,0x20
	ld (XIY+0x01),W                               ; FA7CDB  bd 01 40
	res 0x07,E                                    ; FA7CDE  cd 30 07
	ld (XIY+0x02),E                               ; FA7CE1  bd 02 45
	calr .LFA7CE8                                 ; FA7CE4  1e 01 00
.LFA7CE7:
	ret                                           ; FA7CE7  0e
.LFA7CE8:

; ---------------------------------------------------------------------
; MidiOut_PostStagedMessage -- put the 0x1948 message on the chosen port,
; waiting for room
;
; Called from: 13 sites, all inside this module.
; Inputs:  0x1948 = {status, controller, value, port, length}.
; Evidence: (0x194B) picks the port everywhere at once -- `cp (XIX+0x03),
;          0x00` selects 0xF41DF8 (Ring601432_PutBlock) with mailbox (0x9B)
;          and post-work 0xF40724 (MIDI_PostSendWork), or 0xF41E1C
;          (Ring60153C_PutBlock) with mailbox (0x091F) and post-work
;          0xF40730 (MIDI_PostSendWork_PortB).  Running status is honoured:
;          when the staged status equals the mailbox the status byte is
;          dropped and the length decremented (0xFA7D10-0xFA7D18).
; Notes:   on a full queue it spins up to 0xF0 times (`cp (0xA2),0xF0`)
;          re-testing the ring's free count, then re-initialises the ring
;          through 0xF41E00/0xF41E24 and retries.
; ---------------------------------------------------------------------
MidiOut_PostStagedMessage:   ; entry: call from 0xFA721E, 0xFA75D3, 0xFA75E1, 0xFA761D, 0xFA7719, 0xFA788D, +7 more
	push XIX                                      ; FA7CE8  3c
	push XIY                                      ; FA7CE9  3d
	push XIZ                                      ; FA7CEA  3e
.LFA7CEB:
	ld XIX,0x00001948                             ; FA7CEB  44 48 19 00 00
	ld C,(XIX+0x04)                               ; FA7CF0  8c 04 23
	ld	w, (xix+0:8)                          ; FA7CF3  8c 00 20   ld W,(XIX+0x00)
	ld XIY,T_Ring601432_PutBlock                  ; FA7CF6  45 f8 1d f4 00
	ld XIZ,0x0000009b                             ; FA7CFB  46 9b 00 00 00
	cp (XIX+0x03),0x00                            ; FA7D00  8c 03 3f 00
	jr z, .LFA7D10                                ; FA7D04  66 0a
	ld XIY,T_Ring60153C_PutBlock                  ; FA7D06  45 1c 1e f4 00
	ld XIZ,0x0000091f                             ; FA7D0B  46 1f 09 00 00
.LFA7D10:
	cp (XIZ),W                                    ; FA7D10  86 f8
	jr nz, .LFA7D1A                               ; FA7D12  6e 06
	inc 1,XIX                                     ; FA7D14  ec 61
	dec 1,C                                       ; FA7D16  cb 69
	jr .LFA7D1C                                   ; FA7D18  68 02
.LFA7D1A:
	ld (XIZ),W                                    ; FA7D1A  b6 40
.LFA7D1C:
	push XIX                                      ; FA7D1C  3c
	ld WA,BC                                      ; FA7D1D  d9 88
	extz WA                                       ; FA7D1F  d8 12
	pushw wa                                      ; FA7D21  28   push WA
	ei 0x06                                       ; FA7D22  06 06
	call (xiy)                                    ; FA7D24  b5 e8   call T,XIY
	ld XIX,T_MIDI_PostSendWork                    ; FA7D26  44 24 07 f4 00
	cp	(0x194b:16), 0x00                     ; FA7D2B  c1 4b 19 3f 00   cp (0x194b),0x00
	jr z, .LFA7D37                                ; FA7D30  66 05
	ld XIX,T_MIDI_PostSendWork_PortB              ; FA7D32  44 30 07 f4 00
.LFA7D37:
	call (xix)                                    ; FA7D37  b4 e8   call T,XIX
	ei 0x00                                       ; FA7D39  06 00
	inc 6,XSP                                     ; FA7D3B  ef 66
	cp WA,0xffff                                  ; FA7D3D  d8 cf ff ff
	jr z, .LFA7D47                                ; FA7D41  66 04
	pop XIZ                                       ; FA7D43  5e
	pop XIY                                       ; FA7D44  5d
	pop XIX                                       ; FA7D45  5c
	ret                                           ; FA7D46  0e
.LFA7D47:
	set	0, (MIDI_RX_Flags:8)                            ; FA7D47  f0 9e b8   set 0,(0x9e)
	ld (0xa2:8), 0x00:io                               ; FA7D4A  08 a2 00   ld (0xa2),0x00
.LFA7D4D:
	inc	1, (0xa2:8)                           ; FA7D4D  c0 a2 61   inc 1,(0xa2)
	cp	(0xa2:8), 0xf0                        ; FA7D50  c0 a2 3f f0   cp (0xa2),0xf0
	jr nc, .LFA7D73                               ; FA7D54  6f 1d
	push XIZ                                      ; FA7D56  3e
	ld XIZ,0x00601430                             ; FA7D57  46 30 14 60 00
	cp XIY,0x00f41df8                             ; FA7D5C  ed cf f8 1d f4 00
	jr z, .LFA7D69                                ; FA7D62  66 05
	ld XIZ,0x0060153a                             ; FA7D64  46 3a 15 60 00
.LFA7D69:
	cpw	(xiz), 0x0003                         ; FA7D69  96 3f 03 00   cp (XIZ),0x0003
	pop XIZ                                       ; FA7D6D  5e
	jr c, .LFA7D4D                                ; FA7D6E  67 dd
	jrl .LFA7CEB                                  ; FA7D70  78 78 ff
.LFA7D73:
	ld (XIZ),0x00                                 ; FA7D73  b6 00 00
	ld (SC0BUF:8), 0xf6:io                               ; FA7D76  08 50 f6   ld (0x50),0xf6
	push XIZ                                      ; FA7D79  3e
	ld XIZ,T_Ring601432_Init                      ; FA7D7A  46 00 1e f4 00
	cp XIY,0x00f41df8                             ; FA7D7F  ed cf f8 1d f4 00
	jr z, .LFA7D8C                                ; FA7D85  66 05
	ld XIZ,T_Ring60153C_Init                      ; FA7D87  46 24 1e f4 00
.LFA7D8C:
	call (xiz)                                    ; FA7D8C  b6 e8   call T,XIZ
	pop XIZ                                       ; FA7D8E  5e
	jrl .LFA7CEB                                  ; FA7D8F  78 59 ff

; ---------------------------------------------------------------------
; sub_FA7D92 -- set the port-A running-status mailbox, then fall through
;
; Called from: prom_b directory slot T_MidiOut_PutByteA_SetStatus (T_F4074C) (`jp 0xFA7D92`).
; Evidence: three bytes, `ld (0x9B),A`, falling into sub_FA7D95.  (0x9B) is
;          the mailbox MIDI_PostSendWork and MidiOut_PostStagedMessage both
;          use for port A's running status.
; ---------------------------------------------------------------------
MidiOut_PutByteA_SetStatus:   ; entry: prom_b directory slot T_MidiOut_PutByteA_SetStatus (T_F4074C)
	ld	(0x9b:8), a                               ; FA7D92  f0 9b 41   ld (0x9b),A

; ---------------------------------------------------------------------
; MidiOut_PutByteA -- push one byte into port A's transmit ring
;
; Called from: prom_b directory slot T_MidiOut_PutByteA (T_F40750), and by fall-through from
;          MidiOut_PutByteA_SetStatus (T_MidiOut_PutByteA_SetStatus (T_F4074C)), which is the same routine
;          with `ld (0x9B),A` in front of it -- (0x9B) is port A's
;          running-status mailbox.
; Evidence: it pushes A zero-extended and calls 0xF41DF4, which prom_b's
;          directory resolves to Ring601432_Put, inside `ei 6` / `ei 0`.
; ---------------------------------------------------------------------
MidiOut_PutByteA:   ; entry: prom_b directory slot T_MidiOut_PutByteA (T_F40750)
	extz WA                                       ; FA7D95  d8 12
	pushw wa                                      ; FA7D97  28   push WA
	ei 0x06                                       ; FA7D98  06 06
	call T_Ring601432_Put                         ; FA7D9A  1d f4 1d f4
	ei 0x00                                       ; FA7D9E  06 00
	inc 2,XSP                                     ; FA7DA0  ef 62
	ret                                           ; FA7DA2  0e

; ---------------------------------------------------------------------
; MidiOut_RunPeriodicTimeouts -- two timeouts on the millisecond counter at (0x80)
;
; Called from: prom_b directory slot T_MidiOut_RunPeriodicTimeouts (`jp 0xFA7DA3`).
; Evidence: sub_FA7DAA compares (0x80) - (0x091C) against 0x0096 = 150 and
;          clears both transmitter mailboxes when it expires; sub_FA7DCA
;          compares (0x80) - (0x0920) against 0x05DC = 1500 and republishes
;          bit 0 of (0x0922) through 0xF40F3C.
; Unknown: what the 150 ms and 1500 ms deadlines protect.  Named sub_.
; ---------------------------------------------------------------------
; MidiOut_RunPeriodicTimeouts: MIDI-out housekeeping MainTask_Loop runs beside T_Blink_Tick: every 150 Tick_Count
;   ticks (~0.31 s at 488 Hz) drops both ports' running-status mailboxes (0x9B port A, 0x091F port B) so the next
;   message resends its status; every 1500 ticks (~3.1 s) re-reads P8 bit 2 into (0x0922) bit 0 (inverted) and queues
;   {0x10A8, value} via Queue2E00_AppendRegs when it changed. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
MidiOut_RunPeriodicTimeouts:   ; entry: prom_b directory slot T_MidiOut_RunPeriodicTimeouts
	calr .LFA7DAA                                 ; FA7DA3  1e 04 00
	calr .LFA7DCA                                 ; FA7DA6  1e 21 00
	ret                                           ; FA7DA9  0e
.LFA7DAA:
sub_FA7DAA:   ; entry: call from 0xFA7DA3
	pushw wa                                      ; FA7DAA  28   push WA
	pushw de                                      ; FA7DAB  2a   push DE
	ld	wa, (Tick_Count:8)                          ; FA7DAC  d0 80 20   ld WA,(0x80)
	ld DE,WA                                      ; FA7DAF  d8 8a
	sub	wa, (0x091c:16)                       ; FA7DB1  d1 1c 09 a0   sub WA,(0x091c)
	cp WA,0x0096                                  ; FA7DB5  d8 cf 96 00
	jr c, .LFA7DC7                                ; FA7DB9  67 0c
	ld (0x091c:16), de                           ; FA7DBB  f1 1c 09 52   ld (0x091c),DE
	ld (0x9b:8), 0x00:io                               ; FA7DBF  08 9b 00   ld (0x9b),0x00
	ld (0x091f:16), 0x00                          ; FA7DC2  f1 1f 09 00 00   ld (0x091f),0x00
.LFA7DC7:
	popw de                                       ; FA7DC7  4a   pop DE
	popw wa                                       ; FA7DC8  48   pop WA
	ret                                           ; FA7DC9  0e
.LFA7DCA:
sub_FA7DCA:   ; entry: call from 0xFA7DA6
	pushw wa                                      ; FA7DCA  28   push WA
	pushw de                                      ; FA7DCB  2a   push DE
	ld	wa, (Tick_Count:8)                          ; FA7DCC  d0 80 20   ld WA,(0x80)
	ld DE,WA                                      ; FA7DCF  d8 8a
	sub	wa, (0x0920:16)                       ; FA7DD1  d1 20 09 a0   sub WA,(0x0920)
	cp WA,0x05dc                                  ; FA7DD5  d8 cf dc 05
	jr c, .LFA7E09                                ; FA7DD9  67 2e
	ld (0x0920:16), de                           ; FA7DDB  f1 20 09 52   ld (0x0920),DE
	res	2, (P8:8)                            ; FA7DDF  f0 18 b2   res 2,(0x18)
	ld w, (0x0922:16)                            ; FA7DE2  c1 22 09 20   ld W,(0x0922)
	res	0, (0x0922:16)                        ; FA7DE6  f1 22 09 b0   res 0,(0x0922)
	ld	a, (P8:8)                               ; FA7DEA  c0 18 21   ld A,(0x18)
	bit 0x02,A                                    ; FA7DED  c9 33 02
	jr nz, .LFA7DF6                               ; FA7DF0  6e 04
	set	0, (0x0922:16)                        ; FA7DF2  f1 22 09 b8   set 0,(0x0922)
.LFA7DF6:
	xor w, (0x0922:16)                            ; FA7DF6  c1 22 09 d0   xor W,(0x0922)
	jr z, .LFA7E09                                ; FA7DFA  66 0d
	ldw de, 0x10a8                                ; FA7DFC  32 a8 10   ld DE,0x10a8
	ld a, (0x0922:16)                            ; FA7DFF  c1 22 09 21   ld A,(0x0922)
	ld w, 0x01:opc                                   ; FA7E03  20 01   ld W,0x01
	call T_Queue2E00_AppendRegs                   ; FA7E05  1d 3c 0f f4
.LFA7E09:
	popw de                                       ; FA7E09  4a   pop DE
	popw wa                                       ; FA7E0A  48   pop WA
	ret                                           ; FA7E0B  0e

; ---------------------------------------------------------------------
; MidiOut_ResyncChangedParts -- the module's bulk `send everything again` entry
;
; Called from: prom_b directory slot T_MidiOut_ResyncChangedParts (`jp 0xFA7E0C`).
; Evidence: it calls sub_FA7E1E, then sub_FA7E37 (344 bytes that walk every
;          part and re-emit its parameters through MidiOut_ChangeRecords),
;          then MidiIn_RebuildPartLists.
; ---------------------------------------------------------------------
; MidiOut_ResyncChangedParts: Snapshots NoteRouting_ActivePartMask into (0x19E0) (previous in (0x19E4), changed bits
;   in (0x19E8)); when any part changed it re-sends pitch bend, channel pressure and the nine assigned controllers --
;   centre/zero to parts that left, current values to parts that joined -- then MidiIn_RebuildPartLists. Called
;   through T_MidiOut_ResyncChangedParts by ParamMsg_RefreshPartMasks. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
MidiOut_ResyncChangedParts:   ; entry: prom_b directory slot T_MidiOut_ResyncChangedParts
	calr .LFA7E1E                                 ; FA7E0C  1e 0f 00
	xor XWA,XWA                                   ; FA7E0F  e8 d0
	cp (0x19e8:16), xwa                          ; FA7E11  e1 e8 19 f8   cp (0x19e8),XWA
	jr z, .LFA7E1D                                ; FA7E15  66 06
	calr .LFA7E37                                 ; FA7E17  1e 1d 00
	calr MidiIn_RebuildPartLists                                   ; FA7E1A  1e 91 03   calr 0xfa81ae
.LFA7E1D:
	ret                                           ; FA7E1D  0e
.LFA7E1E:
sub_FA7E1E:   ; entry: call from 0xFA7E0C
	ld xwa, (0x19e0:16)                          ; FA7E1E  e1 e0 19 20   ld XWA,(0x19e0)
	ld (0x19e4:16), xwa                          ; FA7E22  f1 e4 19 60   ld (0x19e4),XWA
	ld xwa, (NoteRouting_ActivePartMask:16)                          ; FA7E26  e1 06 4c 20   ld XWA,(0x4c06)
	ld (0x19e0:16), xwa                          ; FA7E2A  f1 e0 19 60   ld (0x19e0),XWA
	xor	xwa, (0x19e4:16)                      ; FA7E2E  e1 e4 19 d0   xor XWA,(0x19e4)
	ld (0x19e8:16), xwa                          ; FA7E32  f1 e8 19 60   ld (0x19e8),XWA
	ret                                           ; FA7E36  0e
.LFA7E37:
sub_FA7E37:   ; entry: call from 0xFA7E17
	xor XWA,XWA                                   ; FA7E37  e8 d0
	cp (0x19e8:16), xwa                          ; FA7E39  e1 e8 19 f8   cp (0x19e8),XWA
	jrl z, .LFA7F8E                               ; FA7E3D  76 4e 01
	ld xwa, (0x19e4:16)                          ; FA7E40  e1 e4 19 20   ld XWA,(0x19e4)
	and	xwa, (0x19e8:16)                      ; FA7E44  e1 e8 19 c0   and XWA,(0x19e8)
	push XWA                                      ; FA7E48  38
	calr MidiIn_BuildList_PitchBend                                   ; FA7E49  1e b0 03   calr 0xfa81fc
	ldw bc, 0xb1                                  ; FA7E4C  31 b1 00   ld BC,0x00b1
	ld (0x1958:16), bc                           ; FA7E4F  f1 58 19 51   ld (0x1958),BC
	ldw de, 0x4000                                ; FA7E53  32 00 40   ld DE,0x4000
	ld (0x195a:16), de                           ; FA7E56  f1 5a 19 52   ld (0x195a),DE
	calr .LFA767E                                 ; FA7E5A  1e 21 f8
	ld xwa, (0x19e0:16)                          ; FA7E5D  e1 e0 19 20   ld XWA,(0x19e0)
	and	xwa, (0x19e8:16)                      ; FA7E61  e1 e8 19 c0   and XWA,(0x19e8)
	ld (0x19ec:16), xwa                          ; FA7E65  f1 ec 19 60   ld (0x19ec),XWA
	calr MidiIn_BuildList_PitchBend                                   ; FA7E69  1e 90 03   calr 0xfa81fc
	ldw bc, 0xb1                                  ; FA7E6C  31 b1 00   ld BC,0x00b1
	ld (0x1958:16), bc                           ; FA7E6F  f1 58 19 51   ld (0x1958),BC
	extz DE                                       ; FA7E73  da 12
	ld e, (0x24f4:16)                            ; FA7E75  c1 f4 24 25   ld E,(0x24f4)
	sll de, 0x07                                  ; FA7E79  da ee 07   sll 0x07,DE
	srl e, 0x01                                   ; FA7E7C  cd ef 01   srl 0x01,E
	cp DE,0x7f40                                  ; FA7E7F  da cf 40 7f
	jr c, .LFA7E88                                ; FA7E83  67 03
	ldw de, 0x7f7f                                ; FA7E85  32 7f 7f   ld DE,0x7f7f
.LFA7E88:
	ld (0x195a:16), de                           ; FA7E88  f1 5a 19 52   ld (0x195a),DE
	calr .LFA767E                                 ; FA7E8C  1e ef f7
	pop XWA                                       ; FA7E8F  58
	calr MidiIn_BuildList_ChannelPressure                                   ; FA7E90  1e 87 03   calr 0xfa821a
	ldw bc, 0xb4                                  ; FA7E93  31 b4 00   ld BC,0x00b4
	ld (0x1958:16), bc                           ; FA7E96  f1 58 19 51   ld (0x1958),BC
	ldw de, 0x7f00                                ; FA7E9A  32 00 7f   ld DE,0x7f00
	ld (0x195a:16), de                           ; FA7E9D  f1 5a 19 52   ld (0x195a),DE
	calr .LFA77FA                                 ; FA7EA1  1e 56 f9
	ld xwa, (0x19ec:16)                          ; FA7EA4  e1 ec 19 20   ld XWA,(0x19ec)
	calr MidiIn_BuildList_ChannelPressure                                   ; FA7EA8  1e 6f 03   calr 0xfa821a
	ldw bc, 0xb4                                  ; FA7EAB  31 b4 00   ld BC,0x00b4
	ld (0x1958:16), bc                           ; FA7EAE  f1 58 19 51   ld (0x1958),BC
	ld e, (0x24ff:16)                            ; FA7EB2  c1 ff 24 25   ld E,(0x24ff)
	res 0x07,E                                    ; FA7EB6  cd 30 07
	ld d, 0x7f:opc                                   ; FA7EB9  24 7f   ld D,0x7f
	ld (0x195a:16), de                           ; FA7EBB  f1 5a 19 52   ld (0x195a),DE
	calr .LFA77FA                                 ; FA7EBF  1e 38 f9
	ld a, (0x7f23:16)                            ; FA7EC2  c1 23 7f 21   ld A,(0x7f23)
	ld (0x1968:16), a                            ; FA7EC6  f1 68 19 41   ld (0x1968),A
	ld a, (0x24f5:16)                            ; FA7ECA  c1 f5 24 21   ld A,(0x24f5)
	res 0x07,A                                    ; FA7ECE  c9 30 07
	ld (0x1969:16), a                            ; FA7ED1  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7ED5  1e b7 00
	ld a, (0x7f24:16)                            ; FA7ED8  c1 24 7f 21   ld A,(0x7f24)
	ld (0x1968:16), a                            ; FA7EDC  f1 68 19 41   ld (0x1968),A
	ld a, (0x24f6:16)                            ; FA7EE0  c1 f6 24 21   ld A,(0x24f6)
	res 0x07,A                                    ; FA7EE4  c9 30 07
	ld (0x1969:16), a                            ; FA7EE7  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7EEB  1e a1 00
	ld a, (0x7f27:16)                            ; FA7EEE  c1 27 7f 21   ld A,(0x7f27)
	ld (0x1968:16), a                            ; FA7EF2  f1 68 19 41   ld (0x1968),A
	ld a, (0x2503:16)                            ; FA7EF6  c1 03 25 21   ld A,(0x2503)
	res 0x07,A                                    ; FA7EFA  c9 30 07
	ld (0x1969:16), a                            ; FA7EFD  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F01  1e 8b 00
	ld a, (0x7f28:16)                            ; FA7F04  c1 28 7f 21   ld A,(0x7f28)
	ld (0x1968:16), a                            ; FA7F08  f1 68 19 41   ld (0x1968),A
	ld a, (0x2504:16)                            ; FA7F0C  c1 04 25 21   ld A,(0x2504)
	res 0x07,A                                    ; FA7F10  c9 30 07
	ld (0x1969:16), a                            ; FA7F13  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F17  1e 75 00
	ld a, (0x7f29:16)                            ; FA7F1A  c1 29 7f 21   ld A,(0x7f29)
	ld (0x1968:16), a                            ; FA7F1E  f1 68 19 41   ld (0x1968),A
	ld a, (0x2505:16)                            ; FA7F22  c1 05 25 21   ld A,(0x2505)
	res 0x07,A                                    ; FA7F26  c9 30 07
	ld (0x1969:16), a                            ; FA7F29  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F2D  1e 5f 00
	ld a, (0x7f2a:16)                            ; FA7F30  c1 2a 7f 21   ld A,(0x7f2a)
	ld (0x1968:16), a                            ; FA7F34  f1 68 19 41   ld (0x1968),A
	ld a, (0x2506:16)                            ; FA7F38  c1 06 25 21   ld A,(0x2506)
	res 0x07,A                                    ; FA7F3C  c9 30 07
	ld (0x1969:16), a                            ; FA7F3F  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F43  1e 49 00
	ld a, (0x7f14:16)                            ; FA7F46  c1 14 7f 21   ld A,(0x7f14)
	ld (0x1968:16), a                            ; FA7F4A  f1 68 19 41   ld (0x1968),A
	ld a, (0x24f2:16)                            ; FA7F4E  c1 f2 24 21   ld A,(0x24f2)
	res 0x07,A                                    ; FA7F52  c9 30 07
	ld (0x1969:16), a                            ; FA7F55  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F59  1e 33 00
	ld a, (0x7f16:16)                            ; FA7F5C  c1 16 7f 21   ld A,(0x7f16)
	ld (0x1968:16), a                            ; FA7F60  f1 68 19 41   ld (0x1968),A
	xor A,A                                       ; FA7F64  c9 d1
	bit	0, (0x2190:16)                        ; FA7F66  f1 90 21 c8   bit 0,(0x2190)
	jr z, .LFA7F6E                                ; FA7F6A  66 02
	ld a, 0x7f:opc                                   ; FA7F6C  21 7f   ld A,0x7f
.LFA7F6E:
	ld (0x1969:16), a                            ; FA7F6E  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F72  1e 1a 00
	ld a, (0x7f17:16)                            ; FA7F75  c1 17 7f 21   ld A,(0x7f17)
	ld (0x1968:16), a                            ; FA7F79  f1 68 19 41   ld (0x1968),A
	xor A,A                                       ; FA7F7D  c9 d1
	bit	0, (0x2191:16)                        ; FA7F7F  f1 91 21 c8   bit 0,(0x2191)
	jr z, .LFA7F87                                ; FA7F83  66 02
	ld a, 0x7f:opc                                   ; FA7F85  21 7f   ld A,0x7f
.LFA7F87:
	ld (0x1969:16), a                            ; FA7F87  f1 69 19 41   ld (0x1969),A
	calr .LFA7F8F                                 ; FA7F8B  1e 01 00
.LFA7F8E:
	ret                                           ; FA7F8E  0e
.LFA7F8F:

; ---------------------------------------------------------------------
; MidiOut_RunChangeRecord -- look up (0x1968) and run its 12-byte record
;
; Called from: nine sites in sub_FA7E37, each of which loads (0x1968) with a
;          different source byte first.
; Evidence: (0x1968) indexes MidiOut_ChangeIndexMap; 0xFF means `nothing to
;          do`; the surviving value indexes MidiOut_ChangeRecordTable, whose
;          eleven entries are the eleven records at 0xFA812A.  The record is
;          then read field by field with post-increment (`ld XIY,(XIX+)`),
;          which is what makes it twelve bytes: two routine pointers, a
;          parameter id and a value, twice.
; ---------------------------------------------------------------------
MidiOut_RunChangeRecord:   ; entry: call from 0xFA7ED5, 0xFA7EEB, 0xFA7F01, 0xFA7F17, 0xFA7F2D, 0xFA7F43, +3 more
	ld XIX,MidiOut_ChangeIndexMap                 ; FA7F8F  44 fe 7f fa 00
	extz WA                                       ; FA7F94  d8 12
	ld a, (0x1968:16)                            ; FA7F96  c1 68 19 21   ld A,(0x1968)
	ld	a, (xix+wa)                           ; FA7F9A  c3 07 f0 e0 21   ld A,(XIX+WA)
	cp A,0xff                                     ; FA7F9F  c9 cf ff
	jr z, .LFA7FFD                                ; FA7FA2  66 59
	extz WA                                       ; FA7FA4  d8 12
	sll wa, 0x02                                  ; FA7FA6  d8 ee 02   sll 0x02,WA
	ld XIX,MidiOut_ChangeRecordTable              ; FA7FA9  44 fe 80 fa 00
	ld	xix, (xix+wa)                         ; FA7FAE  e3 07 f0 e0 24   ld XIX,(XIX+WA)
	push XIX                                      ; FA7FB3  3c
	ld xiy, (xix+)                             ; FA7FB4  e5 f2 25   ld XIY,(XIX+)
	ld xwa, (0x19e4:16)                          ; FA7FB7  e1 e4 19 20   ld XWA,(0x19e4)
	and	xwa, (0x19e8:16)                      ; FA7FBB  e1 e8 19 c0   and XWA,(0x19e8)
	push XIX                                      ; FA7FBF  3c
	call (xiy)                                    ; FA7FC0  b5 e8   call T,XIY
	pop XIX                                       ; FA7FC2  5c
	ld xiz, (xix+)                             ; FA7FC3  e5 f2 26   ld XIZ,(XIX+)
	ld bc, (xix+)                              ; FA7FC6  d5 f1 21   ld BC,(XIX+)
	ld (0x1958:16), bc                           ; FA7FC9  f1 58 19 51   ld (0x1958),BC
	ld DE,(XIX)                                   ; FA7FCD  94 22
	ld (0x195a:16), de                           ; FA7FCF  f1 5a 19 52   ld (0x195a),DE
	call (xiz)                                    ; FA7FD3  b6 e8   call T,XIZ
	pop XIX                                       ; FA7FD5  5c
	ld xiy, (xix+)                             ; FA7FD6  e5 f2 25   ld XIY,(XIX+)
	ld xwa, (0x19e0:16)                          ; FA7FD9  e1 e0 19 20   ld XWA,(0x19e0)
	and	xwa, (0x19e8:16)                      ; FA7FDD  e1 e8 19 c0   and XWA,(0x19e8)
	push XIX                                      ; FA7FE1  3c
	call (xiy)                                    ; FA7FE2  b5 e8   call T,XIY
	pop XIX                                       ; FA7FE4  5c
	ld xiz, (xix+)                             ; FA7FE5  e5 f2 26   ld XIZ,(XIX+)
	ld bc, (xix+)                              ; FA7FE8  d5 f1 21   ld BC,(XIX+)
	ld (0x1958:16), bc                           ; FA7FEB  f1 58 19 51   ld (0x1958),BC
	inc 1,XIX                                     ; FA7FEF  ec 61
	ld D,(XIX)                                    ; FA7FF1  84 24
	ld e, (0x1969:16)                            ; FA7FF3  c1 69 19 25   ld E,(0x1969)
	ld (0x195a:16), de                           ; FA7FF7  f1 5a 19 52   ld (0x195a),DE
	call (xiz)                                    ; FA7FFB  b6 e8   call T,XIZ
.LFA7FFD:
	ret                                           ; FA7FFD  0e

; --- 0xFA7FFE-0xFA80FD  sparse byte map (256 bytes) ---
MidiOut_ChangeIndexMap:
	.byte 0xff, 0x00, 0x01, 0xff, 0x02, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0a, 0xff, 0xff, 0xff, 0xff   ; FA7FFE
	.byte 0x03, 0x04, 0x05, 0x06, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA800E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA801E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA802E
	.byte 0x07, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA803E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA804E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA805E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA806E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA807E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA808E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA809E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA80AE
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA80BE
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA80CE
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA80DE
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA80EE

; --- 0xFA80FE-0xFA8129  pointer table (44 bytes) ---
MidiOut_ChangeRecordTable:
	.long MidiOut_ChangeRecord_CC01Modulation   ; FA80FE  [0]   -> MidiOut_ChangeRecord_CC01Modulation
	.long MidiOut_ChangeRecord_CC02Modulation2  ; FA8102  [1]   -> MidiOut_ChangeRecord_CC02Modulation2
	.long MidiOut_ChangeRecord_CC04CtrlPedal    ; FA8106  [2]   -> MidiOut_ChangeRecord_CC04CtrlPedal
	.long MidiOut_ChangeRecord_CC10RTCreatX     ; FA810A  [3]   -> MidiOut_ChangeRecord_CC10RTCreatX
	.long MidiOut_ChangeRecord_CC11RTCreatY     ; FA810E  [4]   -> MidiOut_ChangeRecord_CC11RTCreatY
	.long MidiOut_ChangeRecord_CC12RTCtrlX      ; FA8112  [5]   -> MidiOut_ChangeRecord_CC12RTCtrlX
	.long MidiOut_ChangeRecord_CC13RTCtrlY      ; FA8116  [6]   -> MidiOut_ChangeRecord_CC13RTCtrlY
	.long MidiOut_ChangeRecord_CC40Hold         ; FA811A  [7]   -> MidiOut_ChangeRecord_CC40Hold
	.long MidiOut_ChangeRecord_ChannelPressure  ; FA811E  [8]   -> MidiOut_ChangeRecord_ChannelPressure
	.long MidiOut_ChangeRecord_PitchBend        ; FA8122  [9]   -> MidiOut_ChangeRecord_PitchBend
	.long MidiOut_ChangeRecord_CC0BExpression   ; FA8126  [10]   -> MidiOut_ChangeRecord_CC0BExpression

; --- 0xFA812A-0xFA81AD  12-byte records (132 bytes) ---

; ---------------------------------------------------------------------
; The eleven MidiOut_ChangeRecord_* -- eleven 12-byte records
;
; Read by: MidiOut_RunChangeRecord, through MidiOut_ChangeRecordTable.
; Layout:  [0:4] a routine called with a 32-bit part mask, [4:8] a routine
;          called with the parameter staged, [8:10] the parameter id and
;          [10:12] its value.  The reader walks the record with
;          post-increment loads, then rewinds and walks it AGAIN with a
;          second mask and a second value, so one record drives two passes.
;          Entry [0] of the table is 0xFA812A and the eleven entries are
;          0x0C apart, so the stride is the table's own arithmetic; 11 * 12
;          = 132 = 0xFA81AE - 0xFA812A, and 0xFA81AE is
;          MidiIn_RebuildPartLists, which prom_b names.  Both ends pinned.
; ★ Indices 8 and 9 are never produced by MidiOut_ChangeIndexMap (its live
;   values are 0,1,2,3,4,5,6,7,10), and ROUND 12 EXPLAINS IT rather than
;   restating it.  The nine cells of that map that are NOT 0xFF sit at map
;   indices 0x01,0x02,0x04,0x0B,0x10,0x11,0x12,0x13,0x40, which are exactly
;   the nine CONTROLLER NUMBERS of the nine records they select (check X5).
;   So the index is a controller number -- and records 8 and 9 are
;   MidiOut_ChangeRecord_ChannelPressure and MidiOut_ChangeRecord_PitchBend,
;   two channel messages that HAVE no controller number.  They are reached
;   from MidiIn_ChannelPressure (0xFA6ED9) and MidiIn_PitchBend (0xFA6E54)
;   instead, which is why nothing had to produce them here.
; ⚠ These are NOT the "8 and 9" that are dead.  Those are indices into
;   MidiOut_IndexToControllerNumber, a different table with a different index
;   rule; see the header above sub_FA78FF.  Two families, two index rules,
;   and this file does not weld them.
;
; MidiOut_ChangeRecord_CC01Modulation -- the record whose handler is MidiOut_CC01_Modulation
;
; ★ RENAMED FROM MidiOut_ChangeRecord_00, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA812A.  [0:4] = 0x00FA820B, [4:8] = 0x00FA771D
;          (MidiOut_CC01_Modulation), [8:10] = parameter number 0x00B2, [10:12] = 0x7F00.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xB2] is MidiOut_CC01_Modulation too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC01Modulation:
	.byte 0x0b, 0x82, 0xfa, 0x00, 0x1d, 0x77, 0xfa, 0x00, 0xb2, 0x00, 0x00, 0x7f   ; FA812A  MidiIn_BuildList_CC01Modulation / MidiOut_CC01_Modulation  id 0x00B2 val 0x7F00
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC02Modulation2 -- the record whose handler is MidiOut_CC02_Modulation2
;
; ★ RENAMED FROM MidiOut_ChangeRecord_01, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA8136.  [0:4] = 0x00FA8274, [4:8] = 0x00FA7B17
;          (MidiOut_CC02_Modulation2), [8:10] = parameter number 0x00BC, [10:12] = 0x7F00.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xBC] is MidiOut_CC02_Breath too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC02Modulation2:
	.byte 0x74, 0x82, 0xfa, 0x00, 0x17, 0x7b, 0xfa, 0x00, 0xbc, 0x00, 0x00, 0x7f   ; FA8136  MidiIn_BuildList_CC02Modulation2 / MidiOut_CC02_Modulation2  id 0x00BC val 0x7F00
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC04CtrlPedal -- the record whose handler is MidiOut_CC04_CtrlPedal
;
; ★ RENAMED FROM MidiOut_ChangeRecord_02, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA8142.  [0:4] = 0x00FA8283, [4:8] = 0x00FA7B85
;          (MidiOut_CC04_CtrlPedal), [8:10] = parameter number 0x00BD, [10:12] = 0x7F00.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xBD] is MidiOut_CC04_Foot too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC04CtrlPedal:
	.byte 0x83, 0x82, 0xfa, 0x00, 0x85, 0x7b, 0xfa, 0x00, 0xbd, 0x00, 0x00, 0x7f   ; FA8142  MidiIn_BuildList_CC04CtrlPedal / MidiOut_CC04_CtrlPedal  id 0x00BD val 0x7F00
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC10RTCreatX -- the record whose handler is MidiOut_CC10_RTCreatX
;
; ★ RENAMED FROM MidiOut_ChangeRecord_03, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA814E.  [0:4] = 0x00FA8238, [4:8] = 0x00FA795F
;          (MidiOut_CC10_RTCreatX), [8:10] = parameter number 0x00B8, [10:12] = 0x7F40.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xB8] is MidiOut_CC10_General1 too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC10RTCreatX:
	.byte 0x38, 0x82, 0xfa, 0x00, 0x5f, 0x79, 0xfa, 0x00, 0xb8, 0x00, 0x40, 0x7f   ; FA814E  MidiIn_BuildList_CC10RTCreatX / MidiOut_CC10_RTCreatX  id 0x00B8 val 0x7F40
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC11RTCreatY -- the record whose handler is MidiOut_CC11_RTCreatY
;
; ★ RENAMED FROM MidiOut_ChangeRecord_04, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA815A.  [0:4] = 0x00FA8247, [4:8] = 0x00FA79CD
;          (MidiOut_CC11_RTCreatY), [8:10] = parameter number 0x00B9, [10:12] = 0x7F40.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xB9] is MidiOut_CC11_General2 too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC11RTCreatY:
	.byte 0x47, 0x82, 0xfa, 0x00, 0xcd, 0x79, 0xfa, 0x00, 0xb9, 0x00, 0x40, 0x7f   ; FA815A  MidiIn_BuildList_CC11RTCreatY / MidiOut_CC11_RTCreatY  id 0x00B9 val 0x7F40
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC12RTCtrlX -- the record whose handler is MidiOut_CC12_RTCtrlX
;
; ★ RENAMED FROM MidiOut_ChangeRecord_05, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA8166.  [0:4] = 0x00FA8256, [4:8] = 0x00FA7A3B
;          (MidiOut_CC12_RTCtrlX), [8:10] = parameter number 0x00BA, [10:12] = 0x7F40.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xBA] is MidiOut_CC12_General3 too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC12RTCtrlX:
	.byte 0x56, 0x82, 0xfa, 0x00, 0x3b, 0x7a, 0xfa, 0x00, 0xba, 0x00, 0x40, 0x7f   ; FA8166  MidiIn_BuildList_CC12RTCtrlX / MidiOut_CC12_RTCtrlX  id 0x00BA val 0x7F40
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC13RTCtrlY -- the record whose handler is MidiOut_CC13_RTCtrlY
;
; ★ RENAMED FROM MidiOut_ChangeRecord_06, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA8172.  [0:4] = 0x00FA8265, [4:8] = 0x00FA7AA9
;          (MidiOut_CC13_RTCtrlY), [8:10] = parameter number 0x00BB, [10:12] = 0x7F40.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xBB] is MidiOut_CC13_General4 too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC13RTCtrlY:
	.byte 0x65, 0x82, 0xfa, 0x00, 0xa9, 0x7a, 0xfa, 0x00, 0xbb, 0x00, 0x40, 0x7f   ; FA8172  MidiIn_BuildList_CC13RTCtrlY / MidiOut_CC13_RTCtrlY  id 0x00BB val 0x7F40
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC40Hold -- the record whose handler is MidiOut_CC40_Hold
;
; ★ RENAMED FROM MidiOut_ChangeRecord_07, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA817E.  [0:4] = 0x00FA8229, [4:8] = 0x00FA7891
;          (MidiOut_CC40_Hold), [8:10] = parameter number 0x00B5, [10:12] = 0x7F00.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xB5] is MidiOut_CC40_Damper too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC40Hold:
	.byte 0x29, 0x82, 0xfa, 0x00, 0x91, 0x78, 0xfa, 0x00, 0xb5, 0x00, 0x00, 0x7f   ; FA817E  MidiIn_BuildList_CC40Hold / MidiOut_CC40_Hold  id 0x00B5 val 0x7F00
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_ChannelPressure -- the record whose handler is MidiOut_ChannelPressure
;
; ★ RENAMED FROM MidiOut_ChangeRecord_08, whose suffix was the record's position
;          in the table and nothing else.  round 4's --gaps named this exact
;          blocker -- "their [4:8] handlers, sub_FA77FA and sub_FA767E, have
;          no name" -- and they have one now.
; Body:    12 bytes at 0xFA818A.  [0:4] = 0x00FA821A (MidiIn_BuildList_ChannelPressure),
;          [4:8] = 0x00FA77FA (MidiOut_ChannelPressure), [8:10] = parameter number
;          0x00B4, [10:12] = 0x7F00.
; Evidence: the name is the [4:8] handler's, and that handler is named
;          in its own header at 0xFA77FA from four agreeing readings.
;          The eleven records' [8:10] parameter numbers are exactly
;          {0xB1..0xB5, 0xB8..0xBD}, and MidiOut_ParamNumberTable[0x00B4]
;          is this same handler -- the pairing has two witnesses, which
;          is the rule the other nine records in this table already use.
; ---------------------------------------------------------------------

MidiOut_ChangeRecord_ChannelPressure:
	.byte 0x1a, 0x82, 0xfa, 0x00, 0xfa, 0x77, 0xfa, 0x00, 0xb4, 0x00, 0x00, 0x7f   ; FA818A  MidiIn_BuildList_ChannelPressure / MidiOut_ChannelPressure  id 0x00B4 val 0x7F00
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_PitchBend -- the record whose handler is MidiOut_PitchBend
;
; ★ RENAMED FROM MidiOut_ChangeRecord_09, whose suffix was the record's position
;          in the table and nothing else.  round 4's --gaps named this exact
;          blocker -- "their [4:8] handlers, sub_FA77FA and sub_FA767E, have
;          no name" -- and they have one now.
; Body:    12 bytes at 0xFA8196.  [0:4] = 0x00FA81FC (MidiIn_BuildList_PitchBend),
;          [4:8] = 0x00FA767E (MidiOut_PitchBend), [8:10] = parameter number
;          0x00B1, [10:12] = 0x4000.
; Evidence: the name is the [4:8] handler's, and that handler is named
;          in its own header at 0xFA767E from four agreeing readings.
;          The eleven records' [8:10] parameter numbers are exactly
;          {0xB1..0xB5, 0xB8..0xBD}, and MidiOut_ParamNumberTable[0x00B1]
;          is this same handler -- the pairing has two witnesses, which
;          is the rule the other nine records in this table already use.
; ---------------------------------------------------------------------

MidiOut_ChangeRecord_PitchBend:
	.byte 0xfc, 0x81, 0xfa, 0x00, 0x7e, 0x76, 0xfa, 0x00, 0xb1, 0x00, 0x00, 0x40   ; FA8196  MidiIn_BuildList_PitchBend / MidiOut_PitchBend  id 0x00B1 val 0x4000
; ---------------------------------------------------------------------
; MidiOut_ChangeRecord_CC0BExpression -- the record whose handler is MidiOut_CC0B_Expression
;
; ★ RENAMED FROM MidiOut_ChangeRecord_10, whose suffix was the record's position
;          in the table and nothing else.
; Body:    12 bytes at 0xFA81A2.  [0:4] = 0x00FA8292, [4:8] = 0x00FA778B
;          (MidiOut_CC0B_Expression), [8:10] = parameter number 0x00B3, [10:12] = 0x7F7F.
; ★ Evidence, and it is a THIRD independent derivation of the same
;          eleven-element set: the eleven records' [8:10] fields are
;          exactly {0xB1..0xB5, 0xB8..0xBD} -- the eleven parameter
;          numbers that have an Evt2030 handler and no record in
;          ParamNumber_RecordPtrs, and the eleven the forwarders at
;          0xFADE56-0xFADE8C serve.  And for this record
;          MidiOut_ParamNumberTable[0xB3] is MidiOut_CC0B_Expression too, so the pairing
;          has two witnesses.  Check R2 re-derives both for all eleven.
; ---------------------------------------------------------------------
MidiOut_ChangeRecord_CC0BExpression:
	.byte 0x92, 0x82, 0xfa, 0x00, 0x8b, 0x77, 0xfa, 0x00, 0xb3, 0x00, 0x7f, 0x7f   ; FA81A2  MidiIn_BuildList_CC0BExpression / MidiOut_CC0B_Expression  id 0x00B3 val 0x7F7F

; ---------------------------------------------------------------------
; MidiIn_RebuildPartLists -- rebuild the eleven part lists at 0x19F0..0x1A90
;
; Called from: sub_FA7E1A and MidiIn_ServicePartLists 0xFA83AA.
; Evidence: eleven `ld XWA,(0x19E0) / calr` pairs, one per list; each callee
;          is fifteen bytes that load its list address, a selector word and a
;          mask word and jump into MidiIn_BuildPartList.  The eleven bases
;          are 0x19F0, 0x1A00, ... 0x1A90, sixteen bytes apart.
; ⚠ MidiIn_ModuleReset clears only TEN of them -- 0x1A90 is missing from
;   MidiIn_ResetPointerTable.  Re-derived by check R1.
; ---------------------------------------------------------------------
MidiIn_RebuildPartLists:   ; entry: call from 0xFA7E1A, 0xFA83AA
	ld xwa, (0x19e0:16)                          ; FA81AE  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA81FC                                 ; FA81B2  1e 47 00
	ld xwa, (0x19e0:16)                          ; FA81B5  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA820B                                 ; FA81B9  1e 4f 00
	ld xwa, (0x19e0:16)                          ; FA81BC  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA821A                                 ; FA81C0  1e 57 00
	ld xwa, (0x19e0:16)                          ; FA81C3  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8229                                 ; FA81C7  1e 5f 00
	ld xwa, (0x19e0:16)                          ; FA81CA  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8238                                 ; FA81CE  1e 67 00
	ld xwa, (0x19e0:16)                          ; FA81D1  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8247                                 ; FA81D5  1e 6f 00
	ld xwa, (0x19e0:16)                          ; FA81D8  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8256                                 ; FA81DC  1e 77 00
	ld xwa, (0x19e0:16)                          ; FA81DF  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8265                                 ; FA81E3  1e 7f 00
	ld xwa, (0x19e0:16)                          ; FA81E6  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8274                                 ; FA81EA  1e 87 00
	ld xwa, (0x19e0:16)                          ; FA81ED  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8283                                 ; FA81F1  1e 8f 00
	ld xwa, (0x19e0:16)                          ; FA81F4  e1 e0 19 20   ld XWA,(0x19e0)
	calr .LFA8292                                 ; FA81F8  1e 97 00
	ret                                           ; FA81FB  0e
.LFA81FC:

; ---------------------------------------------------------------------
; The eleven MidiIn_BuildList_* -- eleven fifteen-byte veneers
;
; Called from: MidiIn_RebuildPartLists, one `calr` each, in this order;
;          three of them are also called directly from sub_FA7E37.
; Layout:  `ld XIX,<list>` / `ld DE,<selector>` / `ld BC,<offset:mask>`
;          / `calr MidiIn_BuildPartList` / `ret`, fifteen bytes, and the
;          eleven list addresses are 0x19F0 in steps of 0x10.
; ★ RENAMED in round 12, and the OLD EVIDENCE LINE IS WITHDRAWN.  It read
;          "each veneer's name is taken from the 32-bit immediate of its own
;          first instruction, not assigned by hand (check R2)".  That was true
;          of the OLD names, MidiIn_BuildList_19F0.._1A90, and it is not true
;          of the new ones: each veneer is now named for the outbound handler
;          that walks the list it fills, which is a fact about a DIFFERENT
;          table.  check R2 still pins the eleven ADDRESSES and is unaffected.
; Evidence: TWO independent witnesses per pairing, and --midi prints both.
;          1. MidiOut_ChangeRecordTable's k-th record holds [0:4] = the veneer
;             and [4:8] = the handler, in ONE 12-byte object.
;          2. the handler's own `ld XIZ,<list>` walks the very list the veneer
;             fills, so the pairing is closed without reading the record.
;          list    record    handler
;          0x19F0  record 9   MidiOut_PitchBend
;          0x1A00  record 0   MidiOut_CC01_Modulation
;          0x1A10  record 8   MidiOut_ChannelPressure
;          0x1A20  record 7   MidiOut_CC40_Hold
;          0x1A30  record 3   MidiOut_CC10_RTCreatX
;          0x1A40  record 4   MidiOut_CC11_RTCreatY
;          0x1A50  record 5   MidiOut_CC12_RTCtrlX
;          0x1A60  record 6   MidiOut_CC13_RTCtrlY
;          0x1A70  record 1   MidiOut_CC02_Modulation2
;          0x1A80  record 2   MidiOut_CC04_CtrlPedal
;          0x1A90  record 10  MidiOut_CC0B_Expression
; ⚠ MidiIn_ModuleReset clears only the first TEN; 0x1A90 is not in
;   MidiIn_ResetPointerTable.  Check R1.
;
; MidiIn_BuildList_PitchBend -- rebuild the part list MidiOut_PitchBend walks
;
; ★ RENAMED FROM MidiIn_BuildList_19F0, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x19F0 / ld DE,0x4000 / ld BC,0x4000 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA81FC.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 9 at 0xFA8196 pairs this builder with
;             MidiOut_PitchBend in one 12-byte record: [0:4] is this address.
;          2. MidiOut_PitchBend's own `ld XIZ,0x000019F0` at 0xFA76A4 walks THIS
;             list, and 0x19F0 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_PitchBend:   ; entry: call from 0xFA7E49, 0xFA7E69, 0xFA81B2
	ld XIX,0x000019f0                             ; FA81FC  44 f0 19 00 00
	ldw de, 0x4000                                ; FA8201  32 00 40   ld DE,0x4000
	ldw bc, 0x4000                                ; FA8204  31 00 40   ld BC,0x4000
	calr .LFA82A1                                 ; FA8207  1e 97 00
	ret                                           ; FA820A  0e
.LFA820B:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC01Modulation -- rebuild the part list MidiOut_CC01_Modulation walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A00, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A00 / ld DE,0x0800 / ld BC,0x0201 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA820B.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 0 at 0xFA812A pairs this builder with
;             MidiOut_CC01_Modulation in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC01_Modulation's own `ld XIZ,0x00001A00` at 0xFA7743 walks THIS
;             list, and 0x1A00 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC01Modulation:   ; entry: call from 0xFA81B9
	ld XIX,0x00001a00                             ; FA820B  44 00 1a 00 00
	ldw de, 0x0800                                ; FA8210  32 00 08   ld DE,0x0800
	ldw bc, 0x0201                                ; FA8213  31 01 02   ld BC,0x0201
	calr .LFA82A1                                 ; FA8216  1e 88 00
	ret                                           ; FA8219  0e
.LFA821A:
; ---------------------------------------------------------------------
; MidiIn_BuildList_ChannelPressure -- rebuild the part list MidiOut_ChannelPressure walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A10, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A10 / ld DE,0x2000 / ld BC,0x2000 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA821A.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 8 at 0xFA818A pairs this builder with
;             MidiOut_ChannelPressure in one 12-byte record: [0:4] is this address.
;          2. MidiOut_ChannelPressure's own `ld XIZ,0x00001A10` at 0xFA7820 walks THIS
;             list, and 0x1A10 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_ChannelPressure:   ; entry: call from 0xFA7E90, 0xFA7EA8, 0xFA81C0
	ld XIX,0x00001a10                             ; FA821A  44 10 1a 00 00
	ldw de, 0x2000                                ; FA821F  32 00 20   ld DE,0x2000
	ldw bc, 0x2000                                ; FA8222  31 00 20   ld BC,0x2000
	calr .LFA82A1                                 ; FA8225  1e 79 00
	ret                                           ; FA8228  0e
.LFA8229:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC40Hold -- rebuild the part list MidiOut_CC40_Hold walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A20, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A20 / ld DE,0x0800 / ld BC,0x0101 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8229.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 7 at 0xFA817E pairs this builder with
;             MidiOut_CC40_Hold in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC40_Hold's own `ld XIZ,0x00001A20` at 0xFA78B7 walks THIS
;             list, and 0x1A20 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC40Hold:   ; entry: call from 0xFA81C7
	ld XIX,0x00001a20                             ; FA8229  44 20 1a 00 00
	ldw de, 0x0800                                ; FA822E  32 00 08   ld DE,0x0800
	ldw bc, 0x0101                                ; FA8231  31 01 01   ld BC,0x0101
	calr .LFA82A1                                 ; FA8234  1e 6a 00
	ret                                           ; FA8237  0e
.LFA8238:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC10RTCreatX -- rebuild the part list MidiOut_CC10_RTCreatX walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A30, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A30 / ld DE,0x0800 / ld BC,0x0103 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8238.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 3 at 0xFA814E pairs this builder with
;             MidiOut_CC10_RTCreatX in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC10_RTCreatX's own `ld XIZ,0x00001A30` at 0xFA7985 walks THIS
;             list, and 0x1A30 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC10RTCreatX:   ; entry: call from 0xFA81CE
	ld XIX,0x00001a30                             ; FA8238  44 30 1a 00 00
	ldw de, 0x0800                                ; FA823D  32 00 08   ld DE,0x0800
	ldw bc, 0x0103                                ; FA8240  31 03 01   ld BC,0x0103
	calr .LFA82A1                                 ; FA8243  1e 5b 00
	ret                                           ; FA8246  0e
.LFA8247:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC11RTCreatY -- rebuild the part list MidiOut_CC11_RTCreatY walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A40, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A40 / ld DE,0x0800 / ld BC,0x0203 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8247.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 4 at 0xFA815A pairs this builder with
;             MidiOut_CC11_RTCreatY in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC11_RTCreatY's own `ld XIZ,0x00001A40` at 0xFA79F3 walks THIS
;             list, and 0x1A40 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC11RTCreatY:   ; entry: call from 0xFA81D5
	ld XIX,0x00001a40                             ; FA8247  44 40 1a 00 00
	ldw de, 0x0800                                ; FA824C  32 00 08   ld DE,0x0800
	ldw bc, 0x0203                                ; FA824F  31 03 02   ld BC,0x0203
	calr .LFA82A1                                 ; FA8252  1e 4c 00
	ret                                           ; FA8255  0e
.LFA8256:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC12RTCtrlX -- rebuild the part list MidiOut_CC12_RTCtrlX walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A50, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A50 / ld DE,0x0800 / ld BC,0x0403 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8256.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 5 at 0xFA8166 pairs this builder with
;             MidiOut_CC12_RTCtrlX in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC12_RTCtrlX's own `ld XIZ,0x00001A50` at 0xFA7A61 walks THIS
;             list, and 0x1A50 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC12RTCtrlX:   ; entry: call from 0xFA81DC
	ld XIX,0x00001a50                             ; FA8256  44 50 1a 00 00
	ldw de, 0x0800                                ; FA825B  32 00 08   ld DE,0x0800
	ldw bc, 0x0403                                ; FA825E  31 03 04   ld BC,0x0403
	calr .LFA82A1                                 ; FA8261  1e 3d 00
	ret                                           ; FA8264  0e
.LFA8265:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC13RTCtrlY -- rebuild the part list MidiOut_CC13_RTCtrlY walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A60, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A60 / ld DE,0x0800 / ld BC,0x0803 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8265.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 6 at 0xFA8172 pairs this builder with
;             MidiOut_CC13_RTCtrlY in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC13_RTCtrlY's own `ld XIZ,0x00001A60` at 0xFA7ACF walks THIS
;             list, and 0x1A60 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC13RTCtrlY:   ; entry: call from 0xFA81E3
	ld XIX,0x00001a60                             ; FA8265  44 60 1a 00 00
	ldw de, 0x0800                                ; FA826A  32 00 08   ld DE,0x0800
	ldw bc, 0x0803                                ; FA826D  31 03 08   ld BC,0x0803
	calr .LFA82A1                                 ; FA8270  1e 2e 00
	ret                                           ; FA8273  0e
.LFA8274:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC02Modulation2 -- rebuild the part list MidiOut_CC02_Modulation2 walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A70, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A70 / ld DE,0x0800 / ld BC,0x1003 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8274.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 1 at 0xFA8136 pairs this builder with
;             MidiOut_CC02_Modulation2 in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC02_Modulation2's own `ld XIZ,0x00001A70` at 0xFA7B3D walks THIS
;             list, and 0x1A70 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC02Modulation2:   ; entry: call from 0xFA81EA
	ld XIX,0x00001a70                             ; FA8274  44 70 1a 00 00
	ldw de, 0x0800                                ; FA8279  32 00 08   ld DE,0x0800
	ldw bc, 0x1003                                ; FA827C  31 03 10   ld BC,0x1003
	calr .LFA82A1                                 ; FA827F  1e 1f 00
	ret                                           ; FA8282  0e
.LFA8283:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC04CtrlPedal -- rebuild the part list MidiOut_CC04_CtrlPedal walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A80, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A80 / ld DE,0x0800 / ld BC,0x2003 / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8283.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 2 at 0xFA8142 pairs this builder with
;             MidiOut_CC04_CtrlPedal in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC04_CtrlPedal's own `ld XIZ,0x00001A80` at 0xFA7BAB walks THIS
;             list, and 0x1A80 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC04CtrlPedal:   ; entry: call from 0xFA81F1
	ld XIX,0x00001a80                             ; FA8283  44 80 1a 00 00
	ldw de, 0x0800                                ; FA8288  32 00 08   ld DE,0x0800
	ldw bc, 0x2003                                ; FA828B  31 03 20   ld BC,0x2003
	calr .LFA82A1                                 ; FA828E  1e 10 00
	ret                                           ; FA8291  0e
.LFA8292:
; ---------------------------------------------------------------------
; MidiIn_BuildList_CC0BExpression -- rebuild the part list MidiOut_CC0B_Expression walks
;
; ★ RENAMED FROM MidiIn_BuildList_1A90, whose suffix was the list's RAM address.
; Called from: MidiIn_RebuildPartLists.
; Body:    `ld XIX,0x1A90 / ld DE,0x0800 / ld BC,0xFFFF / calr
;          MidiIn_BuildPartList`, fifteen bytes at 0xFA8292.
; Evidence: TWO witnesses, independent of each other.
;          1. change record 10 at 0xFA81A2 pairs this builder with
;             MidiOut_CC0B_Expression in one 12-byte record: [0:4] is this address.
;          2. MidiOut_CC0B_Expression's own `ld XIZ,0x00001A90` at 0xFA77B1 walks THIS
;             list, and 0x1A90 is this builder's own destination.
; ---------------------------------------------------------------------

MidiIn_BuildList_CC0BExpression:   ; entry: call from 0xFA81F8
	ld XIX,0x00001a90                             ; FA8292  44 90 1a 00 00
	ldw de, 0x0800                                ; FA8297  32 00 08   ld DE,0x0800
	ldw bc, 0xffff                                ; FA829A  31 ff ff   ld BC,0xffff
	calr .LFA82A1                                 ; FA829D  1e 01 00
	ret                                           ; FA82A0  0e
.LFA82A1:

; ---------------------------------------------------------------------
; MidiIn_BuildPartList -- collect the parts that pass a mask into one list
;
; Called from: all eleven of the fifteen-byte veneers above.
; Inputs:  XIX the destination, XWA a 32-bit per-part selector, DE and BC
;          the byte offset and mask pair.
; Outputs: a 0xFF-terminated list of part indices.
; Evidence: `srl 1,XWA / jr NC` walks the 32 selector bits, `cp L,0x20`
;          bounds the loop at 32 parts, and the second test reads
;          MidiOut_PartFlagsTable[part] + C.  It writes 0xFF both before the
;          loop and after it, so an empty list is still terminated.
; ---------------------------------------------------------------------
MidiIn_BuildPartList:   ; entry: call from 0xFA8207, 0xFA8216, 0xFA8225, 0xFA8234, 0xFA8243, 0xFA8252, +5 more
	ld (XIX),0xff                                 ; FA82A1  b4 00 ff
	ld XIY,MidiFilter_ChannelMsgs                             ; FA82A4  45 39 7f 00 00
	ld	h, (xiy+e)                            ; FA82A9  c3 03 f4 e8 26   ld H,(XIY+E)
	and H,D                                       ; FA82AE  cc c6
	jr z, .LFA82DD                                ; FA82B0  66 2b
	xor L,L                                       ; FA82B2  cf d7
	ld XIY,MidiOut_PartFlagsTable                 ; FA82B4  45 de 82 fa 00
.LFA82B9:
	srl xwa, 0x01                                 ; FA82B9  e8 ef 01   srl 0x01,XWA
	jr nc, .LFA82D1                               ; FA82BC  6f 13
	cp B,0xff                                     ; FA82BE  ca cf ff
	jr z, .LFA82CE                                ; FA82C1  66 0b
	ld XIZ,(XIY)                                  ; FA82C3  a5 26
	ld	h, (xiz+c)                            ; FA82C5  c3 03 f8 e4 26   ld H,(XIZ+C)
	and H,B                                       ; FA82CA  ca c6
	jr z, .LFA82D1                                ; FA82CC  66 03
.LFA82CE:
	ld (xix+), l                             ; FA82CE  f5 f0 47   ld (XIX+),L
.LFA82D1:
	inc 4,XIY                                     ; FA82D1  ed 64
	inc 1,L                                       ; FA82D3  cf 61
	cp L,0x20                                     ; FA82D5  cf cf 20
	jr nz, .LFA82B9                               ; FA82D8  6e df
	ld (XIX),0xff                                 ; FA82DA  b4 00 ff
.LFA82DD:
	ret                                           ; FA82DD  0e

; --- 0xFA82DE-0xFA835D  RAM-address table (128 bytes) ---

; ---------------------------------------------------------------------
; MidiOut_PartFlagsTable -- 32 pointers to part record + 0x26
;
; Read by: MidiIn_BuildPartList 0xFA82B4.
; Layout:  32 LE32 words holding 16-bit RAM addresses, 0x76D5..0x7ED5.
; Evidence: entry k is exactly MidiOut_PartRecordPtrs_00[k] + 0x26 for all
;          32 k (check P2), including the one place both tables step by 0x80
;          instead of 0x40.  So this is the SAME 32 records seen at a fixed
;          field offset, and `cp L,0x20` in the reader is the entry count.
; ---------------------------------------------------------------------
MidiOut_PartFlagsTable:
	.long 0x000076D5                            ; FA82DE  [0]   RAM 0x76D5
	.long 0x00007715                            ; FA82E2  [1]   RAM 0x7715
	.long 0x00007755                            ; FA82E6  [2]   RAM 0x7755
	.long 0x00007795                            ; FA82EA  [3]   RAM 0x7795
	.long 0x000077D5                            ; FA82EE  [4]   RAM 0x77D5
	.long 0x00007815                            ; FA82F2  [5]   RAM 0x7815
	.long 0x00007855                            ; FA82F6  [6]   RAM 0x7855
	.long 0x00007895                            ; FA82FA  [7]   RAM 0x7895
	.long 0x00007915                            ; FA82FE  [8]   RAM 0x7915
	.long 0x00007955                            ; FA8302  [9]   RAM 0x7955
	.long 0x00007995                            ; FA8306  [10]   RAM 0x7995
	.long 0x000079D5                            ; FA830A  [11]   RAM 0x79D5
	.long 0x00007A15                            ; FA830E  [12]   RAM 0x7A15
	.long 0x00007A55                            ; FA8312  [13]   RAM 0x7A55
	.long 0x00007A95                            ; FA8316  [14]   RAM 0x7A95
	.long 0x00007AD5                            ; FA831A  [15]   RAM 0x7AD5
	.long 0x00007B15                            ; FA831E  [16]   RAM 0x7B15
	.long 0x00007B55                            ; FA8322  [17]   RAM 0x7B55
	.long 0x00007B95                            ; FA8326  [18]   RAM 0x7B95
	.long 0x00007BD5                            ; FA832A  [19]   RAM 0x7BD5
	.long 0x00007C15                            ; FA832E  [20]   RAM 0x7C15
	.long 0x00007C55                            ; FA8332  [21]   RAM 0x7C55
	.long 0x00007C95                            ; FA8336  [22]   RAM 0x7C95
	.long 0x00007CD5                            ; FA833A  [23]   RAM 0x7CD5
	.long 0x00007D15                            ; FA833E  [24]   RAM 0x7D15
	.long 0x00007D55                            ; FA8342  [25]   RAM 0x7D55
	.long 0x00007D95                            ; FA8346  [26]   RAM 0x7D95
	.long 0x00007DD5                            ; FA834A  [27]   RAM 0x7DD5
	.long 0x00007E15                            ; FA834E  [28]   RAM 0x7E15
	.long 0x00007E55                            ; FA8352  [29]   RAM 0x7E55
	.long 0x00007E95                            ; FA8356  [30]   RAM 0x7E95
	.long 0x00007ED5                            ; FA835A  [31]   RAM 0x7ED5

; ---------------------------------------------------------------------
; MidiIn_ReqListRebuild_Msg13_16 -- ask for a part-list rebuild
;
; Called from: prom_b directory slot T_MidiIn_ReqListRebuild_Msg13_16 (`jp 0xFA835E`).
; Evidence: sets bit 1 of (0x1978) when (0x20B8) is 0x13..0x16 and (0x20BA)
;          is non-zero.  Bit 1 is the bit MidiIn_ServicePartLists tests.
; ---------------------------------------------------------------------
MidiIn_ReqListRebuild_Msg13_16:   ; entry: prom_b directory slot T_MidiIn_ReqListRebuild_Msg13_16
	ld a, (UiEvent_Byte1:16)                            ; FA835E  c1 b8 20 21   ld A,(0x20b8)
	cp A,0x13                                     ; FA8362  c9 cf 13
	jr c, .LFA8377                                ; FA8365  67 10
	cp A,0x16                                     ; FA8367  c9 cf 16
	jr ugt, .LFA8377                              ; FA836A  6b 0b
	cp	(UiEvent_Byte3:16), 0x00                     ; FA836C  c1 ba 20 3f 00   cp (0x20ba),0x00
	jr z, .LFA8377                                ; FA8371  66 04
	set	1, (0x1978:16)                        ; FA8373  f1 78 19 b9   set 1,(0x1978)
.LFA8377:
	ret                                           ; FA8377  0e

; ---------------------------------------------------------------------
; MidiIn_ReqRebuild_Msg03_0A -- ask for either rebuild, by message number
;
; Called from: prom_b directory slot T_MidiIn_ReqRebuild_Msg03_0A (T_F43354) (`jp 0xFA8378`).
; Evidence: (0x20B8) == 3 or 4 sets bit 0 of (0x1978), the channel-route
;          rebuild; 7..0x0A with (0x20BA) non-zero sets bit 1, the part-list
;          rebuild.  Same two bits as the two hooks above.
; ---------------------------------------------------------------------
MidiIn_ReqRebuild_Msg03_0A:   ; entry: prom_b directory slot T_MidiIn_ReqRebuild_Msg03_0A (T_F43354)
	ld XIX,0x00001978                             ; FA8378  44 78 19 00 00
	ld a, (UiEvent_Byte1:16)                            ; FA837D  c1 b8 20 21   ld A,(0x20b8)
	cp a, 0x03:i3                                   ; FA8381  c9 db   cp A,3
	jr z, .LFA839D                                ; FA8383  66 18
	cp a, 0x04:i3                                   ; FA8385  c9 dc   cp A,4
	jr z, .LFA839D                                ; FA8387  66 14
	cp a, 0x07:i3                                   ; FA8389  c9 df   cp A,7
	jr c, .LFA839F                                ; FA838B  67 12
	cp A,0x0a                                     ; FA838D  c9 cf 0a
	jr ugt, .LFA839F                              ; FA8390  6b 0d
	cp	(UiEvent_Byte3:16), 0x00                     ; FA8392  c1 ba 20 3f 00   cp (0x20ba),0x00
	jr z, .LFA839F                                ; FA8397  66 06
	set 1,(XIX)                                   ; FA8399  b4 b9
	jr .LFA839F                                   ; FA839B  68 02
.LFA839D:
	set 0,(XIX)                                   ; FA839D  b4 b8
.LFA839F:
	ret                                           ; FA839F  0e
MidiIn_ServicePartLists:   ; entry: call from 0xFA6F07
	bit	1, (0x1978:16)                        ; FA83A0  f1 78 19 c9   bit 1,(0x1978)
	jr z, .LFA83AD                                ; FA83A4  66 07
	res	1, (0x1978:16)                        ; FA83A6  f1 78 19 b1   res 1,(0x1978)
	calr MidiIn_RebuildPartLists                                   ; FA83AA  1e 01 fe   calr 0xfa81ae
.LFA83AD:
	ret                                           ; FA83AD  0e

; ---------------------------------------------------------------------
; MidiIn_ModuleReset -- put 0xFF at the head of ten part lists
;
; Called from: MidiIn_EntryThunks slot 0 (`jp 0xFA83AE`), the module's
;          published reset entry.
; Evidence: `ld C,0x0a` is the loop count and `ld A,0xff` the value; the ten
;          destinations are the ten LE32 entries of MidiIn_ResetPointerTable,
;          read with post-increment.  Ten entries is also 0xFA83C0 + 10*4 =
;          0xFA83E8, the base of MidiIn_ControllerNumberToIndex, which the
;          code names independently at 0xFA6267.
; ---------------------------------------------------------------------
MidiIn_ModuleReset:
	ld XIX,MidiIn_ResetPointerTable               ; FA83AE  44 c0 83 fa 00
	ld c, 0x0a:opc                                   ; FA83B3  23 0a   ld C,0x0a
	ld a, 0xff:opc                                   ; FA83B5  21 ff   ld A,0xff
.LFA83B7:
	ld xiy, (xix+)                             ; FA83B7  e5 f2 25   ld XIY,(XIX+)
	ld (XIY),A                                    ; FA83BA  b5 41
	djnz8 c, .LFA83B7                             ; FA83BC  cb 1c f8
	ret                                           ; FA83BF  0e

; --- 0xFA83C0-0xFA83E7  RAM-address table (40 bytes) ---
MidiIn_ResetPointerTable:
	.long 0x000019F0                            ; FA83C0  [0]   RAM 0x19F0
	.long 0x00001A00                            ; FA83C4  [1]   RAM 0x1A00
	.long 0x00001A10                            ; FA83C8  [2]   RAM 0x1A10
	.long 0x00001A20                            ; FA83CC  [3]   RAM 0x1A20
	.long 0x00001A30                            ; FA83D0  [4]   RAM 0x1A30
	.long 0x00001A40                            ; FA83D4  [5]   RAM 0x1A40
	.long 0x00001A50                            ; FA83D8  [6]   RAM 0x1A50
	.long 0x00001A60                            ; FA83DC  [7]   RAM 0x1A60
	.long 0x00001A70                            ; FA83E0  [8]   RAM 0x1A70
	.long 0x00001A80                            ; FA83E4  [9]   RAM 0x1A80

; --- 0xFA83E8-0xFA84C7  sparse byte map (224 bytes) ---
MidiIn_ControllerNumberToIndex:
	.byte 0x18, 0x01, 0x0a, 0xff, 0x0b, 0xff, 0x20, 0x02, 0xff, 0xff, 0x04, 0x03, 0xff, 0xff, 0xff, 0xff   ; FA83E8
	.byte 0x0c, 0x0d, 0x0e, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA83F8
	.byte 0x19, 0xff, 0xff, 0xff, 0xff, 0xff, 0x21, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8408
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8418
	.byte 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8428
	.byte 0xff, 0x12, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x07, 0xff, 0x05, 0x06, 0xff   ; FA8438
	.byte 0xff, 0xff, 0xff, 0xff, 0x23, 0x22, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8448
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x29, 0x28, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8458
MidiIn_ControllerEnableTable:
	.byte 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00   ; FA8468
	.byte 0xff, 0xff, 0xff, 0xff, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00   ; FA8478
	.byte 0xff, 0xff, 0xff, 0xff, 0x08, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8488
	.byte 0x80, 0x01, 0x80, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8498
	.byte 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA84A8
	.byte 0x01, 0x02, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA84B8

; --- 0xFA84C8-0xFA8C67  32-record parameter tables (1952 bytes) ---
; ---------------------------------------------------------------------
; MidiIn_CC40_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC40_Hold (0xFA645B): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6488 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB5 for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xB5] = MidiOut_CC40_Hold: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC40_ParamTable:
	.byte 0xb5, 0x00, 0x7f, 0xb5, 0x01, 0x7f, 0xb5, 0x02, 0x7f, 0xb5, 0x03, 0x7f   ; FA84C8
	.byte 0xb5, 0x04, 0x7f, 0xb5, 0x05, 0x7f, 0xb5, 0x06, 0x7f, 0xb5, 0x07, 0x7f   ; FA84D4
	.byte 0xb5, 0x08, 0x7f, 0xb5, 0x09, 0x7f, 0xb5, 0x0a, 0x7f, 0xb5, 0x0b, 0x7f   ; FA84E0
	.byte 0xb5, 0x0c, 0x7f, 0xb5, 0x0d, 0x7f, 0xb5, 0x0e, 0x7f, 0xb5, 0x0f, 0x7f   ; FA84EC
	.byte 0xb5, 0x10, 0x7f, 0xb5, 0x11, 0x7f, 0xb5, 0x12, 0x7f, 0xb5, 0x13, 0x7f   ; FA84F8
	.byte 0xb5, 0x14, 0x7f, 0xb5, 0x15, 0x7f, 0xb5, 0x16, 0x7f, 0xb5, 0x17, 0x7f   ; FA8504
	.byte 0xb5, 0x18, 0x7f, 0xb5, 0x19, 0x7f, 0xb5, 0x1a, 0x7f, 0xb5, 0x1b, 0x7f   ; FA8510
	.byte 0xb5, 0x1c, 0x7f, 0xb5, 0x1d, 0x7f, 0xb5, 0x1e, 0x7f, 0xb5, 0x1f, 0x7f   ; FA851C
; ---------------------------------------------------------------------
; sub_FA64E5_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: sub_FA64E5 (0xFA64E5): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA64F7 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB7 for every part, class = the part (0..31), mask 0x7F.
; ⚠ Which controller this is is not established: its handler's slot is
;          reached by no controller number (see that handler's header),
;          and MidiOut_ParamNumberTable[0xB7] is MidiOut_Param_Ignore.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
sub_FA64E5_ParamTable:
	.byte 0xb7, 0x00, 0x7f, 0xb7, 0x01, 0x7f, 0xb7, 0x02, 0x7f, 0xb7, 0x03, 0x7f   ; FA8528
	.byte 0xb7, 0x04, 0x7f, 0xb7, 0x05, 0x7f, 0xb7, 0x06, 0x7f, 0xb7, 0x07, 0x7f   ; FA8534
	.byte 0xb7, 0x08, 0x7f, 0xb7, 0x09, 0x7f, 0xb7, 0x0a, 0x7f, 0xb7, 0x0b, 0x7f   ; FA8540
	.byte 0xb7, 0x0c, 0x7f, 0xb7, 0x0d, 0x7f, 0xb7, 0x0e, 0x7f, 0xb7, 0x0f, 0x7f   ; FA854C
	.byte 0xb7, 0x10, 0x7f, 0xb7, 0x11, 0x7f, 0xb7, 0x12, 0x7f, 0xb7, 0x13, 0x7f   ; FA8558
	.byte 0xb7, 0x14, 0x7f, 0xb7, 0x15, 0x7f, 0xb7, 0x16, 0x7f, 0xb7, 0x17, 0x7f   ; FA8564
	.byte 0xb7, 0x18, 0x7f, 0xb7, 0x19, 0x7f, 0xb7, 0x1a, 0x7f, 0xb7, 0x1b, 0x7f   ; FA8570
	.byte 0xb7, 0x1c, 0x7f, 0xb7, 0x1d, 0x7f, 0xb7, 0x1e, 0x7f, 0xb7, 0x1f, 0x7f   ; FA857C
; ---------------------------------------------------------------------
; sub_FA6526_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: sub_FA6526 (0xFA6526): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6538 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB6 for every part, class = the part (0..31), mask 0x7F.
; ⚠ Which controller this is is not established: its handler's slot is
;          reached by no controller number (see that handler's header),
;          and MidiOut_ParamNumberTable[0xB6] is MidiOut_Param_Ignore.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
sub_FA6526_ParamTable:
	.byte 0xb6, 0x00, 0x7f, 0xb6, 0x01, 0x7f, 0xb6, 0x02, 0x7f, 0xb6, 0x03, 0x7f   ; FA8588
	.byte 0xb6, 0x04, 0x7f, 0xb6, 0x05, 0x7f, 0xb6, 0x06, 0x7f, 0xb6, 0x07, 0x7f   ; FA8594
	.byte 0xb6, 0x08, 0x7f, 0xb6, 0x09, 0x7f, 0xb6, 0x0a, 0x7f, 0xb6, 0x0b, 0x7f   ; FA85A0
	.byte 0xb6, 0x0c, 0x7f, 0xb6, 0x0d, 0x7f, 0xb6, 0x0e, 0x7f, 0xb6, 0x0f, 0x7f   ; FA85AC
	.byte 0xb6, 0x10, 0x7f, 0xb6, 0x11, 0x7f, 0xb6, 0x12, 0x7f, 0xb6, 0x13, 0x7f   ; FA85B8
	.byte 0xb6, 0x14, 0x7f, 0xb6, 0x15, 0x7f, 0xb6, 0x16, 0x7f, 0xb6, 0x17, 0x7f   ; FA85C4
	.byte 0xb6, 0x18, 0x7f, 0xb6, 0x19, 0x7f, 0xb6, 0x1a, 0x7f, 0xb6, 0x1b, 0x7f   ; FA85D0
	.byte 0xb6, 0x1c, 0x7f, 0xb6, 0x1d, 0x7f, 0xb6, 0x1e, 0x7f, 0xb6, 0x1f, 0x7f   ; FA85DC
; ---------------------------------------------------------------------
; MidiIn_CC01_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC01_Modulation (0xFA6567): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6594 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB2 for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xB2] = MidiOut_CC01_Modulation: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC01_ParamTable:
	.byte 0xb2, 0x00, 0x7f, 0xb2, 0x01, 0x7f, 0xb2, 0x02, 0x7f, 0xb2, 0x03, 0x7f   ; FA85E8
	.byte 0xb2, 0x04, 0x7f, 0xb2, 0x05, 0x7f, 0xb2, 0x06, 0x7f, 0xb2, 0x07, 0x7f   ; FA85F4
	.byte 0xb2, 0x08, 0x7f, 0xb2, 0x09, 0x7f, 0xb2, 0x0a, 0x7f, 0xb2, 0x0b, 0x7f   ; FA8600
	.byte 0xb2, 0x0c, 0x7f, 0xb2, 0x0d, 0x7f, 0xb2, 0x0e, 0x7f, 0xb2, 0x0f, 0x7f   ; FA860C
	.byte 0xb2, 0x10, 0x7f, 0xb2, 0x11, 0x7f, 0xb2, 0x12, 0x7f, 0xb2, 0x13, 0x7f   ; FA8618
	.byte 0xb2, 0x14, 0x7f, 0xb2, 0x15, 0x7f, 0xb2, 0x16, 0x7f, 0xb2, 0x17, 0x7f   ; FA8624
	.byte 0xb2, 0x18, 0x7f, 0xb2, 0x19, 0x7f, 0xb2, 0x1a, 0x7f, 0xb2, 0x1b, 0x7f   ; FA8630
	.byte 0xb2, 0x1c, 0x7f, 0xb2, 0x1d, 0x7f, 0xb2, 0x1e, 0x7f, 0xb2, 0x1f, 0x7f   ; FA863C
; ---------------------------------------------------------------------
; MidiIn_CC07_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC07_Volume (0xFA65F1): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6621 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number = the part (0..31), class 0x03 for every part, mask 0x7F:
;          a PART parameter.  MidiOut_ParamClassTable[0x03], which
;          MidiOut_DispatchByClass indexes with that class, is
;          MidiOut_CC07_Volume.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC07_ParamTable:
	.byte 0x00, 0x03, 0x7f, 0x01, 0x03, 0x7f, 0x02, 0x03, 0x7f, 0x03, 0x03, 0x7f   ; FA8648
	.byte 0x04, 0x03, 0x7f, 0x05, 0x03, 0x7f, 0x06, 0x03, 0x7f, 0x07, 0x03, 0x7f   ; FA8654
	.byte 0x08, 0x03, 0x7f, 0x09, 0x03, 0x7f, 0x0a, 0x03, 0x7f, 0x0b, 0x03, 0x7f   ; FA8660
	.byte 0x0c, 0x03, 0x7f, 0x0d, 0x03, 0x7f, 0x0e, 0x03, 0x7f, 0x0f, 0x03, 0x7f   ; FA866C
	.byte 0x10, 0x03, 0x7f, 0x11, 0x03, 0x7f, 0x12, 0x03, 0x7f, 0x13, 0x03, 0x7f   ; FA8678
	.byte 0x14, 0x03, 0x7f, 0x15, 0x03, 0x7f, 0x16, 0x03, 0x7f, 0x17, 0x03, 0x7f   ; FA8684
	.byte 0x18, 0x03, 0x7f, 0x19, 0x03, 0x7f, 0x1a, 0x03, 0x7f, 0x1b, 0x03, 0x7f   ; FA8690
	.byte 0x1c, 0x03, 0x7f, 0x1d, 0x03, 0x7f, 0x1e, 0x03, 0x7f, 0x1f, 0x03, 0x7f   ; FA869C
; ---------------------------------------------------------------------
; MidiIn_CC0B_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC0B_Expression (0xFA6650): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA667D with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB3 for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xB3] = MidiOut_CC0B_Expression: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC0B_ParamTable:
	.byte 0xb3, 0x00, 0x7f, 0xb3, 0x01, 0x7f, 0xb3, 0x02, 0x7f, 0xb3, 0x03, 0x7f   ; FA86A8
	.byte 0xb3, 0x04, 0x7f, 0xb3, 0x05, 0x7f, 0xb3, 0x06, 0x7f, 0xb3, 0x07, 0x7f   ; FA86B4
	.byte 0xb3, 0x08, 0x7f, 0xb3, 0x09, 0x7f, 0xb3, 0x0a, 0x7f, 0xb3, 0x0b, 0x7f   ; FA86C0
	.byte 0xb3, 0x0c, 0x7f, 0xb3, 0x0d, 0x7f, 0xb3, 0x0e, 0x7f, 0xb3, 0x0f, 0x7f   ; FA86CC
	.byte 0xb3, 0x10, 0x7f, 0xb3, 0x11, 0x7f, 0xb3, 0x12, 0x7f, 0xb3, 0x13, 0x7f   ; FA86D8
	.byte 0xb3, 0x14, 0x7f, 0xb3, 0x15, 0x7f, 0xb3, 0x16, 0x7f, 0xb3, 0x17, 0x7f   ; FA86E4
	.byte 0xb3, 0x18, 0x7f, 0xb3, 0x19, 0x7f, 0xb3, 0x1a, 0x7f, 0xb3, 0x1b, 0x7f   ; FA86F0
	.byte 0xb3, 0x1c, 0x7f, 0xb3, 0x1d, 0x7f, 0xb3, 0x1e, 0x7f, 0xb3, 0x1f, 0x7f   ; FA86FC
; ---------------------------------------------------------------------
; MidiIn_CC0A_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC0A_Pan (0xFA66DA): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA66EC with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number = the part (0..31), class 0x08 for every part, mask 0x7F:
;          a PART parameter.  MidiOut_ParamClassTable[0x08], which
;          MidiOut_DispatchByClass indexes with that class, is
;          MidiOut_CC0A_Pan.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC0A_ParamTable:
	.byte 0x00, 0x08, 0x7f, 0x01, 0x08, 0x7f, 0x02, 0x08, 0x7f, 0x03, 0x08, 0x7f   ; FA8708
	.byte 0x04, 0x08, 0x7f, 0x05, 0x08, 0x7f, 0x06, 0x08, 0x7f, 0x07, 0x08, 0x7f   ; FA8714
	.byte 0x08, 0x08, 0x7f, 0x09, 0x08, 0x7f, 0x0a, 0x08, 0x7f, 0x0b, 0x08, 0x7f   ; FA8720
	.byte 0x0c, 0x08, 0x7f, 0x0d, 0x08, 0x7f, 0x0e, 0x08, 0x7f, 0x0f, 0x08, 0x7f   ; FA872C
	.byte 0x10, 0x08, 0x7f, 0x11, 0x08, 0x7f, 0x12, 0x08, 0x7f, 0x13, 0x08, 0x7f   ; FA8738
	.byte 0x14, 0x08, 0x7f, 0x15, 0x08, 0x7f, 0x16, 0x08, 0x7f, 0x17, 0x08, 0x7f   ; FA8744
	.byte 0x18, 0x08, 0x7f, 0x19, 0x08, 0x7f, 0x1a, 0x08, 0x7f, 0x1b, 0x08, 0x7f   ; FA8750
	.byte 0x1c, 0x08, 0x7f, 0x1d, 0x08, 0x7f, 0x1e, 0x08, 0x7f, 0x1f, 0x08, 0x7f   ; FA875C
; ---------------------------------------------------------------------
; MidiIn_CC5D_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC5D_Effect3Depth (0xFA671B): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA672D with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number = the part (0..31), class 0x05 for every part, mask 0x7F:
;          a PART parameter.  MidiOut_ParamClassTable[0x05], which
;          MidiOut_DispatchByClass indexes with that class, is
;          MidiOut_CC5D_Effect3Depth.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC5D_ParamTable:
	.byte 0x00, 0x05, 0x7f, 0x01, 0x05, 0x7f, 0x02, 0x05, 0x7f, 0x03, 0x05, 0x7f   ; FA8768
	.byte 0x04, 0x05, 0x7f, 0x05, 0x05, 0x7f, 0x06, 0x05, 0x7f, 0x07, 0x05, 0x7f   ; FA8774
	.byte 0x08, 0x05, 0x7f, 0x09, 0x05, 0x7f, 0x0a, 0x05, 0x7f, 0x0b, 0x05, 0x7f   ; FA8780
	.byte 0x0c, 0x05, 0x7f, 0x0d, 0x05, 0x7f, 0x0e, 0x05, 0x7f, 0x0f, 0x05, 0x7f   ; FA878C
	.byte 0x10, 0x05, 0x7f, 0x11, 0x05, 0x7f, 0x12, 0x05, 0x7f, 0x13, 0x05, 0x7f   ; FA8798
	.byte 0x14, 0x05, 0x7f, 0x15, 0x05, 0x7f, 0x16, 0x05, 0x7f, 0x17, 0x05, 0x7f   ; FA87A4
	.byte 0x18, 0x05, 0x7f, 0x19, 0x05, 0x7f, 0x1a, 0x05, 0x7f, 0x1b, 0x05, 0x7f   ; FA87B0
	.byte 0x1c, 0x05, 0x7f, 0x1d, 0x05, 0x7f, 0x1e, 0x05, 0x7f, 0x1f, 0x05, 0x7f   ; FA87BC
; ---------------------------------------------------------------------
; MidiIn_CC5E_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC5E_Effect4Depth (0xFA675C): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA676E with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number = the part (0..31), class 0x06 for every part, mask 0x7F:
;          a PART parameter.  MidiOut_ParamClassTable[0x06], which
;          MidiOut_DispatchByClass indexes with that class, is
;          MidiOut_CC5E_Effect4Depth.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC5E_ParamTable:
	.byte 0x00, 0x06, 0x7f, 0x01, 0x06, 0x7f, 0x02, 0x06, 0x7f, 0x03, 0x06, 0x7f   ; FA87C8
	.byte 0x04, 0x06, 0x7f, 0x05, 0x06, 0x7f, 0x06, 0x06, 0x7f, 0x07, 0x06, 0x7f   ; FA87D4
	.byte 0x08, 0x06, 0x7f, 0x09, 0x06, 0x7f, 0x0a, 0x06, 0x7f, 0x0b, 0x06, 0x7f   ; FA87E0
	.byte 0x0c, 0x06, 0x7f, 0x0d, 0x06, 0x7f, 0x0e, 0x06, 0x7f, 0x0f, 0x06, 0x7f   ; FA87EC
	.byte 0x10, 0x06, 0x7f, 0x11, 0x06, 0x7f, 0x12, 0x06, 0x7f, 0x13, 0x06, 0x7f   ; FA87F8
	.byte 0x14, 0x06, 0x7f, 0x15, 0x06, 0x7f, 0x16, 0x06, 0x7f, 0x17, 0x06, 0x7f   ; FA8804
	.byte 0x18, 0x06, 0x7f, 0x19, 0x06, 0x7f, 0x1a, 0x06, 0x7f, 0x1b, 0x06, 0x7f   ; FA8810
	.byte 0x1c, 0x06, 0x7f, 0x1d, 0x06, 0x7f, 0x1e, 0x06, 0x7f, 0x1f, 0x06, 0x7f   ; FA881C
; ---------------------------------------------------------------------
; MidiIn_CC5B_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC5B_Effect1Depth (0xFA679D): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA67AF with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number = the part (0..31), class 0x07 for every part, mask 0x7F:
;          a PART parameter.  MidiOut_ParamClassTable[0x07], which
;          MidiOut_DispatchByClass indexes with that class, is
;          MidiOut_CC5B_Effect1Depth.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC5B_ParamTable:
	.byte 0x00, 0x07, 0x7f, 0x01, 0x07, 0x7f, 0x02, 0x07, 0x7f, 0x03, 0x07, 0x7f   ; FA8828
	.byte 0x04, 0x07, 0x7f, 0x05, 0x07, 0x7f, 0x06, 0x07, 0x7f, 0x07, 0x07, 0x7f   ; FA8834
	.byte 0x08, 0x07, 0x7f, 0x09, 0x07, 0x7f, 0x0a, 0x07, 0x7f, 0x0b, 0x07, 0x7f   ; FA8840
	.byte 0x0c, 0x07, 0x7f, 0x0d, 0x07, 0x7f, 0x0e, 0x07, 0x7f, 0x0f, 0x07, 0x7f   ; FA884C
	.byte 0x10, 0x07, 0x7f, 0x11, 0x07, 0x7f, 0x12, 0x07, 0x7f, 0x13, 0x07, 0x7f   ; FA8858
	.byte 0x14, 0x07, 0x7f, 0x15, 0x07, 0x7f, 0x16, 0x07, 0x7f, 0x17, 0x07, 0x7f   ; FA8864
	.byte 0x18, 0x07, 0x7f, 0x19, 0x07, 0x7f, 0x1a, 0x07, 0x7f, 0x1b, 0x07, 0x7f   ; FA8870
	.byte 0x1c, 0x07, 0x7f, 0x1d, 0x07, 0x7f, 0x1e, 0x07, 0x7f, 0x1f, 0x07, 0x7f   ; FA887C
; ---------------------------------------------------------------------
; MidiIn_CC02_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC02_Modulation2 (0xFA67E8): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6815 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xBC for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xBC] = MidiOut_CC02_Modulation2: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC02_ParamTable:
	.byte 0xbc, 0x00, 0x7f, 0xbc, 0x01, 0x7f, 0xbc, 0x02, 0x7f, 0xbc, 0x03, 0x7f   ; FA8888
	.byte 0xbc, 0x04, 0x7f, 0xbc, 0x05, 0x7f, 0xbc, 0x06, 0x7f, 0xbc, 0x07, 0x7f   ; FA8894
	.byte 0xbc, 0x08, 0x7f, 0xbc, 0x09, 0x7f, 0xbc, 0x0a, 0x7f, 0xbc, 0x0b, 0x7f   ; FA88A0
	.byte 0xbc, 0x0c, 0x7f, 0xbc, 0x0d, 0x7f, 0xbc, 0x0e, 0x7f, 0xbc, 0x0f, 0x7f   ; FA88AC
	.byte 0xbc, 0x10, 0x7f, 0xbc, 0x11, 0x7f, 0xbc, 0x12, 0x7f, 0xbc, 0x13, 0x7f   ; FA88B8
	.byte 0xbc, 0x14, 0x7f, 0xbc, 0x15, 0x7f, 0xbc, 0x16, 0x7f, 0xbc, 0x17, 0x7f   ; FA88C4
	.byte 0xbc, 0x18, 0x7f, 0xbc, 0x19, 0x7f, 0xbc, 0x1a, 0x7f, 0xbc, 0x1b, 0x7f   ; FA88D0
	.byte 0xbc, 0x1c, 0x7f, 0xbc, 0x1d, 0x7f, 0xbc, 0x1e, 0x7f, 0xbc, 0x1f, 0x7f   ; FA88DC
; ---------------------------------------------------------------------
; MidiIn_CC04_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC04_CtrlPedal (0xFA6872): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA689F with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xBD for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xBD] = MidiOut_CC04_CtrlPedal: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC04_ParamTable:
	.byte 0xbd, 0x00, 0x7f, 0xbd, 0x01, 0x7f, 0xbd, 0x02, 0x7f, 0xbd, 0x03, 0x7f   ; FA88E8
	.byte 0xbd, 0x04, 0x7f, 0xbd, 0x05, 0x7f, 0xbd, 0x06, 0x7f, 0xbd, 0x07, 0x7f   ; FA88F4
	.byte 0xbd, 0x08, 0x7f, 0xbd, 0x09, 0x7f, 0xbd, 0x0a, 0x7f, 0xbd, 0x0b, 0x7f   ; FA8900
	.byte 0xbd, 0x0c, 0x7f, 0xbd, 0x0d, 0x7f, 0xbd, 0x0e, 0x7f, 0xbd, 0x0f, 0x7f   ; FA890C
	.byte 0xbd, 0x10, 0x7f, 0xbd, 0x11, 0x7f, 0xbd, 0x12, 0x7f, 0xbd, 0x13, 0x7f   ; FA8918
	.byte 0xbd, 0x14, 0x7f, 0xbd, 0x15, 0x7f, 0xbd, 0x16, 0x7f, 0xbd, 0x17, 0x7f   ; FA8924
	.byte 0xbd, 0x18, 0x7f, 0xbd, 0x19, 0x7f, 0xbd, 0x1a, 0x7f, 0xbd, 0x1b, 0x7f   ; FA8930
	.byte 0xbd, 0x1c, 0x7f, 0xbd, 0x1d, 0x7f, 0xbd, 0x1e, 0x7f, 0xbd, 0x1f, 0x7f   ; FA893C
; ---------------------------------------------------------------------
; MidiIn_CC10_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC10_RTCreatX (0xFA68FC): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6929 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB8 for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xB8] = MidiOut_CC10_RTCreatX: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC10_ParamTable:
	.byte 0xb8, 0x00, 0x7f, 0xb8, 0x01, 0x7f, 0xb8, 0x02, 0x7f, 0xb8, 0x03, 0x7f   ; FA8948
	.byte 0xb8, 0x04, 0x7f, 0xb8, 0x05, 0x7f, 0xb8, 0x06, 0x7f, 0xb8, 0x07, 0x7f   ; FA8954
	.byte 0xb8, 0x08, 0x7f, 0xb8, 0x09, 0x7f, 0xb8, 0x0a, 0x7f, 0xb8, 0x0b, 0x7f   ; FA8960
	.byte 0xb8, 0x0c, 0x7f, 0xb8, 0x0d, 0x7f, 0xb8, 0x0e, 0x7f, 0xb8, 0x0f, 0x7f   ; FA896C
	.byte 0xb8, 0x10, 0x7f, 0xb8, 0x11, 0x7f, 0xb8, 0x12, 0x7f, 0xb8, 0x13, 0x7f   ; FA8978
	.byte 0xb8, 0x14, 0x7f, 0xb8, 0x15, 0x7f, 0xb8, 0x16, 0x7f, 0xb8, 0x17, 0x7f   ; FA8984
	.byte 0xb8, 0x18, 0x7f, 0xb8, 0x19, 0x7f, 0xb8, 0x1a, 0x7f, 0xb8, 0x1b, 0x7f   ; FA8990
	.byte 0xb8, 0x1c, 0x7f, 0xb8, 0x1d, 0x7f, 0xb8, 0x1e, 0x7f, 0xb8, 0x1f, 0x7f   ; FA899C
; ---------------------------------------------------------------------
; MidiIn_CC11_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC11_RTCreatY (0xFA6986): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA69B3 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xB9 for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xB9] = MidiOut_CC11_RTCreatY: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC11_ParamTable:
	.byte 0xb9, 0x00, 0x7f, 0xb9, 0x01, 0x7f, 0xb9, 0x02, 0x7f, 0xb9, 0x03, 0x7f   ; FA89A8
	.byte 0xb9, 0x04, 0x7f, 0xb9, 0x05, 0x7f, 0xb9, 0x06, 0x7f, 0xb9, 0x07, 0x7f   ; FA89B4
	.byte 0xb9, 0x08, 0x7f, 0xb9, 0x09, 0x7f, 0xb9, 0x0a, 0x7f, 0xb9, 0x0b, 0x7f   ; FA89C0
	.byte 0xb9, 0x0c, 0x7f, 0xb9, 0x0d, 0x7f, 0xb9, 0x0e, 0x7f, 0xb9, 0x0f, 0x7f   ; FA89CC
	.byte 0xb9, 0x10, 0x7f, 0xb9, 0x11, 0x7f, 0xb9, 0x12, 0x7f, 0xb9, 0x13, 0x7f   ; FA89D8
	.byte 0xb9, 0x14, 0x7f, 0xb9, 0x15, 0x7f, 0xb9, 0x16, 0x7f, 0xb9, 0x17, 0x7f   ; FA89E4
	.byte 0xb9, 0x18, 0x7f, 0xb9, 0x19, 0x7f, 0xb9, 0x1a, 0x7f, 0xb9, 0x1b, 0x7f   ; FA89F0
	.byte 0xb9, 0x1c, 0x7f, 0xb9, 0x1d, 0x7f, 0xb9, 0x1e, 0x7f, 0xb9, 0x1f, 0x7f   ; FA89FC
; ---------------------------------------------------------------------
; MidiIn_CC12_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC12_RTCtrlX (0xFA6A10): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6A3D with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xBA for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xBA] = MidiOut_CC12_RTCtrlX: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC12_ParamTable:
	.byte 0xba, 0x00, 0x7f, 0xba, 0x01, 0x7f, 0xba, 0x02, 0x7f, 0xba, 0x03, 0x7f   ; FA8A08
	.byte 0xba, 0x04, 0x7f, 0xba, 0x05, 0x7f, 0xba, 0x06, 0x7f, 0xba, 0x07, 0x7f   ; FA8A14
	.byte 0xba, 0x08, 0x7f, 0xba, 0x09, 0x7f, 0xba, 0x0a, 0x7f, 0xba, 0x0b, 0x7f   ; FA8A20
	.byte 0xba, 0x0c, 0x7f, 0xba, 0x0d, 0x7f, 0xba, 0x0e, 0x7f, 0xba, 0x0f, 0x7f   ; FA8A2C
	.byte 0xba, 0x10, 0x7f, 0xba, 0x11, 0x7f, 0xba, 0x12, 0x7f, 0xba, 0x13, 0x7f   ; FA8A38
	.byte 0xba, 0x14, 0x7f, 0xba, 0x15, 0x7f, 0xba, 0x16, 0x7f, 0xba, 0x17, 0x7f   ; FA8A44
	.byte 0xba, 0x18, 0x7f, 0xba, 0x19, 0x7f, 0xba, 0x1a, 0x7f, 0xba, 0x1b, 0x7f   ; FA8A50
	.byte 0xba, 0x1c, 0x7f, 0xba, 0x1d, 0x7f, 0xba, 0x1e, 0x7f, 0xba, 0x1f, 0x7f   ; FA8A5C
; ---------------------------------------------------------------------
; MidiIn_CC13_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC13_RTCtrlY (0xFA6A9A): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6AC7 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number 0xBB for every part, class = the part (0..31), mask 0x7F.
;          MidiOut_ParamNumberTable[0xBB] = MidiOut_CC13_RTCtrlY: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC13_ParamTable:
	.byte 0xbb, 0x00, 0x7f, 0xbb, 0x01, 0x7f, 0xbb, 0x02, 0x7f, 0xbb, 0x03, 0x7f   ; FA8A68
	.byte 0xbb, 0x04, 0x7f, 0xbb, 0x05, 0x7f, 0xbb, 0x06, 0x7f, 0xbb, 0x07, 0x7f   ; FA8A74
	.byte 0xbb, 0x08, 0x7f, 0xbb, 0x09, 0x7f, 0xbb, 0x0a, 0x7f, 0xbb, 0x0b, 0x7f   ; FA8A80
	.byte 0xbb, 0x0c, 0x7f, 0xbb, 0x0d, 0x7f, 0xbb, 0x0e, 0x7f, 0xbb, 0x0f, 0x7f   ; FA8A8C
	.byte 0xbb, 0x10, 0x7f, 0xbb, 0x11, 0x7f, 0xbb, 0x12, 0x7f, 0xbb, 0x13, 0x7f   ; FA8A98
	.byte 0xbb, 0x14, 0x7f, 0xbb, 0x15, 0x7f, 0xbb, 0x16, 0x7f, 0xbb, 0x17, 0x7f   ; FA8AA4
	.byte 0xbb, 0x18, 0x7f, 0xbb, 0x19, 0x7f, 0xbb, 0x1a, 0x7f, 0xbb, 0x1b, 0x7f   ; FA8AB0
	.byte 0xbb, 0x1c, 0x7f, 0xbb, 0x1d, 0x7f, 0xbb, 0x1e, 0x7f, 0xbb, 0x1f, 0x7f   ; FA8ABC
; ---------------------------------------------------------------------
; MidiIn_CC51_ParamTable -- 32 x 3-byte records, one per part: [number] [class] [mask].
; Read by: MidiIn_CC51_General6 (0xFA6B24): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `ld XIX,<this>` at
;          0xFA6B36 with HL = part*3;
;          `ld BC,(XIX+HL)` -- C = 0xFF would skip the part -- then
;          `inc 2,XIX / ld D,(XIX+HL)`, E = the controller value (0x1942),
;          and BC / DE become the parameter-change record at RAM 0x1950:
;          [number = C] [class = B] [value = E] [mask = D] -- the
;          (0x1958) number / (0x1959) class of MidiOut_DispatchByClass.
; Here:    number = 0x20 + the part, class 0x18, mask 0x01 for every part.
;          MidiOut_ParamNumberTable[0x20..0x3F] are all MidiOut_CC51_General6.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC51_ParamTable:
	.byte 0x20, 0x18, 0x01, 0x21, 0x18, 0x01, 0x22, 0x18, 0x01, 0x23, 0x18, 0x01   ; FA8AC8
	.byte 0x24, 0x18, 0x01, 0x25, 0x18, 0x01, 0x26, 0x18, 0x01, 0x27, 0x18, 0x01   ; FA8AD4
	.byte 0x28, 0x18, 0x01, 0x29, 0x18, 0x01, 0x2a, 0x18, 0x01, 0x2b, 0x18, 0x01   ; FA8AE0
	.byte 0x2c, 0x18, 0x01, 0x2d, 0x18, 0x01, 0x2e, 0x18, 0x01, 0x2f, 0x18, 0x01   ; FA8AEC
	.byte 0x30, 0x18, 0x01, 0x31, 0x18, 0x01, 0x32, 0x18, 0x01, 0x33, 0x18, 0x01   ; FA8AF8
	.byte 0x34, 0x18, 0x01, 0x35, 0x18, 0x01, 0x36, 0x18, 0x01, 0x37, 0x18, 0x01   ; FA8B04
	.byte 0x38, 0x18, 0x01, 0x39, 0x18, 0x01, 0x3a, 0x18, 0x01, 0x3b, 0x18, 0x01   ; FA8B10
	.byte 0x3c, 0x18, 0x01, 0x3d, 0x18, 0x01, 0x3e, 0x18, 0x01, 0x3f, 0x18, 0x01   ; FA8B1C
; ---------------------------------------------------------------------
; MidiIn_CC79_ParamTable -- 32 x 2-byte records, one per part: [number] [class].
; Read by: MidiIn_CC79_ResetAllCtrl (0xFA6CBB): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `sll 1,A` and
;          `ld XIX,<this>` at 0xFA6CC7,
;          `ld BC,(XIX+A)` -- C = 0xFF would skip the part -- then
;          E = the controller value (0x1942), D = 0x7F, and BC / DE become
;          the parameter-change record at RAM 0x1950.
; Here:    number 0xAD for every part, class = the part (0..31).
;          MidiOut_ParamNumberTable[0xAD] = MidiOut_CC79_ResetAllCtrl: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC79_ParamTable:
	.byte 0xad, 0x00, 0xad, 0x01, 0xad, 0x02, 0xad, 0x03, 0xad, 0x04, 0xad, 0x05   ; FA8B28
	.byte 0xad, 0x06, 0xad, 0x07, 0xad, 0x08, 0xad, 0x09, 0xad, 0x0a, 0xad, 0x0b   ; FA8B34
	.byte 0xad, 0x0c, 0xad, 0x0d, 0xad, 0x0e, 0xad, 0x0f, 0xad, 0x10, 0xad, 0x11   ; FA8B40
	.byte 0xad, 0x12, 0xad, 0x13, 0xad, 0x14, 0xad, 0x15, 0xad, 0x16, 0xad, 0x17   ; FA8B4C
	.byte 0xad, 0x18, 0xad, 0x19, 0xad, 0x1a, 0xad, 0x1b, 0xad, 0x1c, 0xad, 0x1d   ; FA8B58
	.byte 0xad, 0x1e, 0xad, 0x1f   ; FA8B64
; ---------------------------------------------------------------------
; MidiIn_CC78_ParamTable -- 32 x 2-byte records, one per part: [number] [class].
; Read by: MidiIn_CC78_AllSoundOff (0xFA6CF1): the part (from (0x1976)) passes
;          `cp A,0x1F / jr ugt` (hence COUNT 32); `sll 1,A` and
;          `ld XIX,<this>` at 0xFA6CFD,
;          `ld BC,(XIX+A)` -- C = 0xFF would skip the part -- then
;          E = the controller value (0x1942), D = 0x7F, and BC / DE become
;          the parameter-change record at RAM 0x1950.
; Here:    number 0xAE for every part, class = the part (0..31).
;          MidiOut_ParamNumberTable[0xAE] = MidiOut_CC78_AllSoundOff: the number goes
;          back out through the handler named for the same message.
; (header: notes/proma-2026-09-25/gen_midiin_param_headers.py, checks R1-R4)
; ---------------------------------------------------------------------
MidiIn_CC78_ParamTable:
	.byte 0xae, 0x00, 0xae, 0x01, 0xae, 0x02, 0xae, 0x03, 0xae, 0x04, 0xae, 0x05   ; FA8B68
	.byte 0xae, 0x06, 0xae, 0x07, 0xae, 0x08, 0xae, 0x09, 0xae, 0x0a, 0xae, 0x0b   ; FA8B74
	.byte 0xae, 0x0c, 0xae, 0x0d, 0xae, 0x0e, 0xae, 0x0f, 0xae, 0x10, 0xae, 0x11   ; FA8B80
	.byte 0xae, 0x12, 0xae, 0x13, 0xae, 0x14, 0xae, 0x15, 0xae, 0x16, 0xae, 0x17   ; FA8B8C
	.byte 0xae, 0x18, 0xae, 0x19, 0xae, 0x1a, 0xae, 0x1b, 0xae, 0x1c, 0xae, 0x1d   ; FA8B98
	.byte 0xae, 0x1e, 0xae, 0x1f   ; FA8BA4

; ---------------------------------------------------------------------
; MidiIn_ProgramChange_ParamTable -- 32 LE16 parameter ids, one per part
;
; Read by: MidiIn_ProgramChange 0xFA6DB9, its only reader.
; ---------------------------------------------------------------------
MidiIn_ProgramChange_ParamTable:
	.byte 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00   ; FA8BA8
	.byte 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0a, 0x00, 0x0b, 0x00   ; FA8BB4
	.byte 0x0c, 0x00, 0x0d, 0x00, 0x0e, 0x00, 0x0f, 0x00, 0x10, 0x00, 0x11, 0x00   ; FA8BC0
	.byte 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00   ; FA8BCC
	.byte 0x18, 0x00, 0x19, 0x00, 0x1a, 0x00, 0x1b, 0x00, 0x1c, 0x00, 0x1d, 0x00   ; FA8BD8
	.byte 0x1e, 0x00, 0x1f, 0x00   ; FA8BE4

; ---------------------------------------------------------------------
; MidiIn_PitchBend_ParamTable -- 32 LE16 parameter ids, one per part
;
; Read by: MidiIn_PitchBend 0xFA6E10, its only reader.
; ---------------------------------------------------------------------
MidiIn_PitchBend_ParamTable:
	.byte 0xb1, 0x00, 0xb1, 0x01, 0xb1, 0x02, 0xb1, 0x03, 0xb1, 0x04, 0xb1, 0x05   ; FA8BE8
	.byte 0xb1, 0x06, 0xb1, 0x07, 0xb1, 0x08, 0xb1, 0x09, 0xb1, 0x0a, 0xb1, 0x0b   ; FA8BF4
	.byte 0xb1, 0x0c, 0xb1, 0x0d, 0xb1, 0x0e, 0xb1, 0x0f, 0xb1, 0x10, 0xb1, 0x11   ; FA8C00
	.byte 0xb1, 0x12, 0xb1, 0x13, 0xb1, 0x14, 0xb1, 0x15, 0xb1, 0x16, 0xb1, 0x17   ; FA8C0C
	.byte 0xb1, 0x18, 0xb1, 0x19, 0xb1, 0x1a, 0xb1, 0x1b, 0xb1, 0x1c, 0xb1, 0x1d   ; FA8C18
	.byte 0xb1, 0x1e, 0xb1, 0x1f   ; FA8C24

; ---------------------------------------------------------------------
; MidiIn_ChannelPressure_ParamTable -- 32 LE16 parameter ids, one per part
;
; Read by: MidiIn_ChannelPressure 0xFA6E97, its only reader.
; ---------------------------------------------------------------------
MidiIn_ChannelPressure_ParamTable:
	.byte 0xb4, 0x00, 0xb4, 0x01, 0xb4, 0x02, 0xb4, 0x03, 0xb4, 0x04, 0xb4, 0x05   ; FA8C28
	.byte 0xb4, 0x06, 0xb4, 0x07, 0xb4, 0x08, 0xb4, 0x09, 0xb4, 0x0a, 0xb4, 0x0b   ; FA8C34
	.byte 0xb4, 0x0c, 0xb4, 0x0d, 0xb4, 0x0e, 0xb4, 0x0f, 0xb4, 0x10, 0xb4, 0x11   ; FA8C40
	.byte 0xb4, 0x12, 0xb4, 0x13, 0xb4, 0x14, 0xb4, 0x15, 0xb4, 0x16, 0xb4, 0x17   ; FA8C4C
	.byte 0xb4, 0x18, 0xb4, 0x19, 0xb4, 0x1a, 0xb4, 0x1b, 0xb4, 0x1c, 0xb4, 0x1d   ; FA8C58
	.byte 0xb4, 0x1e, 0xb4, 0x1f   ; FA8C64

; --- 0xFA8C68-0xFA8C87  identity map (32 bytes) ---

; ---------------------------------------------------------------------
; MidiIn_PartIdentityMap -- 32 bytes, value == index
;
; Read by: MidiIn_CC06_DataEntryMSB 0xFA6B71 and MidiIn_CC26_DataEntryLSB
;          0xFA6C00, both as `ld C,(XIX+HL)` with HL the part index.
; Layout:  0x00..0x1F, checked whole (check I1), not at the ends.
; Notes:   the two readers use it exactly as the other controllers use their
;          32-record tables, so the parameter id for Data Entry is the part
;          index itself.
; ---------------------------------------------------------------------
MidiIn_PartIdentityMap:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f   ; FA8C68
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f   ; FA8C78

; --- 0xFA8C88-0xFA8CC7  32-record parameter tables (64 bytes) ---

; ---------------------------------------------------------------------
; MidiIn_BankSelect_ParamTable -- 32 LE16 parameter ids, one per part
;
; Read by: MidiIn_CC00_BankSelectMSB 0xFA63BF and MidiIn_CC20_BankSelectLSB
;          0xFA642F -- the only 32-record table with two readers.
; Layout:  32 entries of 2 bytes; 0xFA8C88 + 64 = 0xFA8CC8, the base of
;          MidiOut_ParamNumberTable.
; ---------------------------------------------------------------------
MidiIn_BankSelect_ParamTable:
	.byte 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00   ; FA8C88
	.byte 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0a, 0x00, 0x0b, 0x00   ; FA8C94
	.byte 0x0c, 0x00, 0x0d, 0x00, 0x0e, 0x00, 0x0f, 0x00, 0x10, 0x00, 0x11, 0x00   ; FA8CA0
	.byte 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00   ; FA8CAC
	.byte 0x18, 0x00, 0x19, 0x00, 0x1a, 0x00, 0x1b, 0x00, 0x1c, 0x00, 0x1d, 0x00   ; FA8CB8
	.byte 0x1e, 0x00, 0x1f, 0x00   ; FA8CC4

; ---------------------------------------------------------------------
; MidiOut_ParamNumberTable -- 192 handler pointers, one per parameter NUMBER
;
; Read by: MidiOut_ParamChanged (0xFA70F5, prom_b slot T_MidiOut_ParamChanged):
;          `cp C,0xBF / jr ugt` then `ld L,C / extz HL / sll 2,HL / ld XIX,
;          0x00FA8CC8 / ld XIX,(XIX+HL) / call (XIX)` at 0xFA710B-0xFA7121, with
;          BC = the parameter id (C the number) and DE the value, both also
;          stored at (0x1958..0x195B) first.
; COUNT 192 is that bound (0xBF + 1), and 0xFA8CC8 + 192*4 = 0xFA8FC8, the next
;          object.  111 slots are MidiOut_Param_Ignore (a lone `ret`): most
;          parameter numbers are not echoed as MIDI.  Entries are `.long <label>`,
;          so the byte gate checks every target's position.
; ---------------------------------------------------------------------
MidiOut_ParamNumberTable:
	.long MidiOut_ParamGate_Part0               ; FA8CC8  [0]
	.long MidiOut_ParamGate_Part1               ; FA8CCC  [1]
	.long MidiOut_ParamGate_Part2               ; FA8CD0  [2]
	.long MidiOut_ParamDispatch                 ; FA8CD4  [3]
	.long MidiOut_ParamDispatch                 ; FA8CD8  [4]
	.long MidiOut_ParamDispatch                 ; FA8CDC  [5]
	.long MidiOut_ParamDispatch                 ; FA8CE0  [6]
	.long MidiOut_ParamDispatch                 ; FA8CE4  [7]
	.long MidiOut_ParamDispatch                 ; FA8CE8  [8]
	.long MidiOut_ParamDispatch                 ; FA8CEC  [9]
	.long MidiOut_ParamDispatch                 ; FA8CF0  [10]
	.long MidiOut_ParamDispatch                 ; FA8CF4  [11]
	.long MidiOut_ParamDispatch                 ; FA8CF8  [12]
	.long MidiOut_ParamDispatch                 ; FA8CFC  [13]
	.long MidiOut_ParamDispatch                 ; FA8D00  [14]
	.long MidiOut_ParamDispatch                 ; FA8D04  [15]
	.long MidiOut_ParamDispatch                 ; FA8D08  [16]
	.long MidiOut_ParamDispatch                 ; FA8D0C  [17]
	.long MidiOut_ParamDispatch                 ; FA8D10  [18]
	.long MidiOut_ParamDispatch                 ; FA8D14  [19]
	.long MidiOut_ParamDispatch                 ; FA8D18  [20]
	.long MidiOut_ParamDispatch                 ; FA8D1C  [21]
	.long MidiOut_ParamDispatch                 ; FA8D20  [22]
	.long MidiOut_ParamDispatch                 ; FA8D24  [23]
	.long MidiOut_ParamDispatch                 ; FA8D28  [24]
	.long MidiOut_ParamDispatch                 ; FA8D2C  [25]
	.long MidiOut_ParamDispatch                 ; FA8D30  [26]
	.long MidiOut_ParamDispatch                 ; FA8D34  [27]
	.long MidiOut_ParamDispatch                 ; FA8D38  [28]
	.long MidiOut_ParamDispatch                 ; FA8D3C  [29]
	.long MidiOut_ParamDispatch                 ; FA8D40  [30]
	.long MidiOut_ParamDispatch                 ; FA8D44  [31]
	.long MidiOut_CC51_General6                 ; FA8D48  [32]
	.long MidiOut_CC51_General6                 ; FA8D4C  [33]
	.long MidiOut_CC51_General6                 ; FA8D50  [34]
	.long MidiOut_CC51_General6                 ; FA8D54  [35]
	.long MidiOut_CC51_General6                 ; FA8D58  [36]
	.long MidiOut_CC51_General6                 ; FA8D5C  [37]
	.long MidiOut_CC51_General6                 ; FA8D60  [38]
	.long MidiOut_CC51_General6                 ; FA8D64  [39]
	.long MidiOut_CC51_General6                 ; FA8D68  [40]
	.long MidiOut_CC51_General6                 ; FA8D6C  [41]
	.long MidiOut_CC51_General6                 ; FA8D70  [42]
	.long MidiOut_CC51_General6                 ; FA8D74  [43]
	.long MidiOut_CC51_General6                 ; FA8D78  [44]
	.long MidiOut_CC51_General6                 ; FA8D7C  [45]
	.long MidiOut_CC51_General6                 ; FA8D80  [46]
	.long MidiOut_CC51_General6                 ; FA8D84  [47]
	.long MidiOut_CC51_General6                 ; FA8D88  [48]
	.long MidiOut_CC51_General6                 ; FA8D8C  [49]
	.long MidiOut_CC51_General6                 ; FA8D90  [50]
	.long MidiOut_CC51_General6                 ; FA8D94  [51]
	.long MidiOut_CC51_General6                 ; FA8D98  [52]
	.long MidiOut_CC51_General6                 ; FA8D9C  [53]
	.long MidiOut_CC51_General6                 ; FA8DA0  [54]
	.long MidiOut_CC51_General6                 ; FA8DA4  [55]
	.long MidiOut_CC51_General6                 ; FA8DA8  [56]
	.long MidiOut_CC51_General6                 ; FA8DAC  [57]
	.long MidiOut_CC51_General6                 ; FA8DB0  [58]
	.long MidiOut_CC51_General6                 ; FA8DB4  [59]
	.long MidiOut_CC51_General6                 ; FA8DB8  [60]
	.long MidiOut_CC51_General6                 ; FA8DBC  [61]
	.long MidiOut_CC51_General6                 ; FA8DC0  [62]
	.long MidiOut_CC51_General6                 ; FA8DC4  [63]
	.long MidiOut_Param_Ignore                  ; FA8DC8  [64]
	.long MidiOut_Param_Ignore                  ; FA8DCC  [65]
	.long MidiOut_Param_Ignore                  ; FA8DD0  [66]
	.long MidiOut_Param_Ignore                  ; FA8DD4  [67]
	.long MidiOut_Param_Ignore                  ; FA8DD8  [68]
	.long MidiOut_Param_Ignore                  ; FA8DDC  [69]
	.long MidiOut_Param_Ignore                  ; FA8DE0  [70]
	.long MidiOut_Param_Ignore                  ; FA8DE4  [71]
	.long MidiOut_Param_Ignore                  ; FA8DE8  [72]
	.long MidiOut_Param_Ignore                  ; FA8DEC  [73]
	.long MidiOut_Param_Ignore                  ; FA8DF0  [74]
	.long MidiOut_Param_Ignore                  ; FA8DF4  [75]
	.long MidiOut_Param_Ignore                  ; FA8DF8  [76]
	.long MidiOut_Param_Ignore                  ; FA8DFC  [77]
	.long MidiOut_Param_Ignore                  ; FA8E00  [78]
	.long MidiOut_Param_Ignore                  ; FA8E04  [79]
	.long MidiOut_Param_Ignore                  ; FA8E08  [80]
	.long MidiOut_Param_Ignore                  ; FA8E0C  [81]
	.long MidiOut_Param_Ignore                  ; FA8E10  [82]
	.long MidiOut_Param_Ignore                  ; FA8E14  [83]
	.long MidiOut_Param_Ignore                  ; FA8E18  [84]
	.long MidiOut_Param_Ignore                  ; FA8E1C  [85]
	.long MidiOut_Param_Ignore                  ; FA8E20  [86]
	.long MidiOut_Param_Ignore                  ; FA8E24  [87]
	.long MidiOut_Param_Ignore                  ; FA8E28  [88]
	.long MidiOut_Param_Ignore                  ; FA8E2C  [89]
	.long MidiOut_Param_Ignore                  ; FA8E30  [90]
	.long MidiOut_Param_Ignore                  ; FA8E34  [91]
	.long MidiOut_Param_Ignore                  ; FA8E38  [92]
	.long MidiOut_Param_Ignore                  ; FA8E3C  [93]
	.long MidiOut_Param_Ignore                  ; FA8E40  [94]
	.long MidiOut_Param_Ignore                  ; FA8E44  [95]
	.long MidiOut_Param_Ignore                  ; FA8E48  [96]
	.long MidiOut_Param_Ignore                  ; FA8E4C  [97]
	.long MidiOut_Param_Ignore                  ; FA8E50  [98]
	.long MidiOut_Param_Ignore                  ; FA8E54  [99]
	.long MidiOut_Param_Ignore                  ; FA8E58  [100]
	.long MidiOut_Param_Ignore                  ; FA8E5C  [101]
	.long MidiOut_Param_Ignore                  ; FA8E60  [102]
	.long MidiOut_Param_Ignore                  ; FA8E64  [103]
	.long MidiOut_Param_Ignore                  ; FA8E68  [104]
	.long MidiOut_Param_Ignore                  ; FA8E6C  [105]
	.long MidiOut_Param_Ignore                  ; FA8E70  [106]
	.long MidiOut_Param_Ignore                  ; FA8E74  [107]
	.long MidiOut_Param_Ignore                  ; FA8E78  [108]
	.long MidiOut_Param_Ignore                  ; FA8E7C  [109]
	.long MidiOut_Param_Ignore                  ; FA8E80  [110]
	.long MidiOut_Param_Ignore                  ; FA8E84  [111]
	.long MidiOut_Param70                            ; FA8E88  [112]
	.long MidiOut_Param_Ignore                  ; FA8E8C  [113]
	.long MidiOut_Param_Ignore                  ; FA8E90  [114]
	.long MidiOut_Param_Ignore                  ; FA8E94  [115]
	.long MidiOut_Param_Ignore                  ; FA8E98  [116]
	.long MidiOut_Param_Ignore                  ; FA8E9C  [117]
	.long MidiOut_Param_Ignore                  ; FA8EA0  [118]
	.long MidiOut_Param_Ignore                  ; FA8EA4  [119]
	.long MidiOut_Param_Ignore                  ; FA8EA8  [120]
	.long MidiOut_Param_Ignore                  ; FA8EAC  [121]
	.long MidiOut_Param_Ignore                  ; FA8EB0  [122]
	.long MidiOut_Param_Ignore                  ; FA8EB4  [123]
	.long MidiOut_Param_Ignore                  ; FA8EB8  [124]
	.long MidiOut_Param_Ignore                  ; FA8EBC  [125]
	.long MidiOut_Param_Ignore                  ; FA8EC0  [126]
	.long MidiOut_Param_Ignore                  ; FA8EC4  [127]
	.long MidiOut_Param_Ignore                  ; FA8EC8  [128]
	.long MidiOut_BankSelect_Pair               ; FA8ECC  [129]
	.long MidiOut_Param_Ignore                  ; FA8ED0  [130]
	.long MidiOut_Param_Ignore                  ; FA8ED4  [131]
	.long MidiOut_Param_Ignore                  ; FA8ED8  [132]
	.long MidiOut_Param_Ignore                  ; FA8EDC  [133]
	.long MidiOut_Param_Ignore                  ; FA8EE0  [134]
	.long MidiOut_Param_Ignore                  ; FA8EE4  [135]
	.long MidiOut_Param_Ignore                  ; FA8EE8  [136]
	.long MidiOut_Param_Ignore                  ; FA8EEC  [137]
	.long MidiOut_Param_Ignore                  ; FA8EF0  [138]
	.long MidiOut_Param_Ignore                  ; FA8EF4  [139]
	.long MidiOut_Param_Ignore                  ; FA8EF8  [140]
	.long MidiOut_Param_Ignore                  ; FA8EFC  [141]
	.long MidiOut_Param_Ignore                  ; FA8F00  [142]
	.long MidiOut_Param_Ignore                  ; FA8F04  [143]
	.long MidiOut_Param_Ignore                  ; FA8F08  [144]
	.long MidiOut_Param_Ignore                  ; FA8F0C  [145]
	.long MidiOut_Param_Ignore                  ; FA8F10  [146]
	.long MidiOut_Param_Ignore                  ; FA8F14  [147]
	.long MidiOut_Param_Ignore                  ; FA8F18  [148]
	.long MidiOut_Param_Ignore                  ; FA8F1C  [149]
	.long MidiOut_Param_Ignore                  ; FA8F20  [150]
	.long MidiOut_Param_Ignore                  ; FA8F24  [151]
	.long MidiOut_Param98                            ; FA8F28  [152]
	.long MidiOut_Param_Ignore                  ; FA8F2C  [153]
	.long MidiOut_Param_Ignore                  ; FA8F30  [154]
	.long MidiOut_Param_Ignore                  ; FA8F34  [155]
	.long MidiOut_Param_Ignore                  ; FA8F38  [156]
	.long MidiOut_Param_Ignore                  ; FA8F3C  [157]
	.long MidiOut_Param_Ignore                  ; FA8F40  [158]
	.long MidiOut_Param_Ignore                  ; FA8F44  [159]
	.long MidiOut_Param_Ignore                  ; FA8F48  [160]
	.long MidiOut_Param_Ignore                  ; FA8F4C  [161]
	.long MidiOut_Param_Ignore                  ; FA8F50  [162]
	.long MidiOut_Param_Ignore                  ; FA8F54  [163]
	.long MidiOut_Param_Ignore                  ; FA8F58  [164]
	.long MidiOut_Param_Ignore                  ; FA8F5C  [165]
	.long MidiOut_Param_Ignore                  ; FA8F60  [166]
	.long MidiOut_Param_Ignore                  ; FA8F64  [167]
	.long MidiOut_Param_Ignore                  ; FA8F68  [168]
	.long MidiOut_Param_Ignore                  ; FA8F6C  [169]
	.long MidiOut_Param_Ignore                  ; FA8F70  [170]
	.long MidiOut_Param_Ignore                  ; FA8F74  [171]
	.long MidiOut_Param_Ignore                  ; FA8F78  [172]
	.long MidiOut_CC79_ResetAllCtrl             ; FA8F7C  [173]
	.long MidiOut_CC78_AllSoundOff              ; FA8F80  [174]
	.long MidiOut_Param_Ignore                  ; FA8F84  [175]
	.long MidiOut_ParamNumberTable_Nop176                            ; FA8F88  [176]
	.long MidiOut_PitchBend                     ; FA8F8C  [177]
	.long MidiOut_CC01_Modulation               ; FA8F90  [178]
	.long MidiOut_CC0B_Expression               ; FA8F94  [179]
	.long MidiOut_ChannelPressure               ; FA8F98  [180]
	.long MidiOut_CC40_Hold                     ; FA8F9C  [181]
	.long MidiOut_Param_Ignore                  ; FA8FA0  [182]
	.long MidiOut_Param_Ignore                  ; FA8FA4  [183]
	.long MidiOut_CC10_RTCreatX                 ; FA8FA8  [184]
	.long MidiOut_CC11_RTCreatY                 ; FA8FAC  [185]
	.long MidiOut_CC12_RTCtrlX                  ; FA8FB0  [186]
	.long MidiOut_CC13_RTCtrlY                  ; FA8FB4  [187]
	.long MidiOut_CC02_Modulation2              ; FA8FB8  [188]
	.long MidiOut_CC04_CtrlPedal                ; FA8FBC  [189]
	.long MidiOut_Param_Ignore                  ; FA8FC0  [190]
	.long MidiOut_Param_Ignore                  ; FA8FC4  [191]

; --- 0xFA8FC8-0xFA8FF7  sparse byte map (48 bytes) ---
MidiOut_IndexToControllerNumber:
	.byte 0x40, 0x01, 0x07, 0x0b, 0x0a, 0x5d, 0x5e, 0x5b, 0xff, 0xff, 0x02, 0x04, 0x10, 0x11, 0x12, 0x13   ; FA8FC8
	.byte 0x50, 0x52, 0x51, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x20, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8FD8
	.byte 0x06, 0x26, 0x65, 0x64, 0xff, 0xff, 0xff, 0xff, 0x79, 0x78, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FA8FE8

; --- 0xFA8FF8-0xFA9C77  RAM-address table (3200 bytes) ---

; ---------------------------------------------------------------------
; The 25 MidiOut_PartRecordPtrs_* -- 25 tables of 32 part-record pointers
;
; Read by: 29 distinct instructions.  Block 00 is named at 5 sites (0xFA71D3, 0xFA7416, 0xFA745E, 0xFA74A6, 0xFA7561)
;          and each of the other 24 blocks at exactly one; check B1 asserts
;          that no block is left without a reader.
; Layout:  each block is 32 LE32 words holding 16-bit RAM addresses, from
;          0x76AF in steps of 0x40 -- with ONE step of 0x80, between entries
;          7 and 8.  All 25 blocks are BYTE-IDENTICAL (check B2).
; ★ The identity is not a redundancy in one table: these are 25 SEPARATE
;   32-entry tables, each named by its own `ld XIX,<base>` in a different
;   routine, all mapping the same part index to the same record.  Reading
;   the 3,200 bytes as `25 rows of one 800-entry table` is what makes the
;   row index look meaningless; it is not a row index.
;   ⚠ notes/prom_a_fa5aeb_layout.py's docstring still describes it the
;   other way, and its own --sites mode misses two of the 25 readers
;   (0xFA97F8 and 0xFA9878) because that mode only sees the `0x00xxxxxx`
;   immediate spelling inside descend().  This file's --sites finds all 25.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_00:
	.long 0x000076AF                            ; FA8FF8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA8FFC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9000  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9004  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9008  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA900C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9010  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9014  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9018  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA901C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9020  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9024  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9028  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA902C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9030  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9034  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9038  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA903C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9040  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9044  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9048  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA904C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9050  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9054  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9058  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA905C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9060  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9064  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9068  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA906C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9070  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9074  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC07Volume -- the copy MidiOut_CC07_Volume loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_01.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa9078` at 0xFA7234, inside MidiOut_CC07_Volume.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA7234 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC07Volume:
	.long 0x000076AF                            ; FA9078  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA907C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9080  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9084  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9088  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA908C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9090  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9094  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9098  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA909C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA90A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA90A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA90A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA90AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA90B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA90B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA90B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA90BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA90C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA90C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA90C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA90CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA90D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA90D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA90D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA90DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA90E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA90E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA90E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA90EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA90F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA90F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC5DEffect3Depth -- the copy MidiOut_CC5D_Effect3Depth loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_02.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa90f8` at 0xFA7272, inside MidiOut_CC5D_Effect3Depth.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA7272 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC5DEffect3Depth:
	.long 0x000076AF                            ; FA90F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA90FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9100  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9104  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9108  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA910C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9110  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9114  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9118  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA911C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9120  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9124  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9128  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA912C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9130  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9134  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9138  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA913C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9140  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9144  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9148  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA914C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9150  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9154  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9158  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA915C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9160  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9164  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9168  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA916C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9170  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9174  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC5EEffect4Depth -- the copy MidiOut_CC5E_Effect4Depth loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_03.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa9178` at 0xFA72B0, inside MidiOut_CC5E_Effect4Depth.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA72B0 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC5EEffect4Depth:
	.long 0x000076AF                            ; FA9178  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA917C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9180  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9184  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9188  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA918C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9190  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9194  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9198  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA919C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA91A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA91A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA91A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA91AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA91B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA91B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA91B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA91BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA91C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA91C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA91C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA91CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA91D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA91D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA91D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA91DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA91E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA91E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA91E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA91EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA91F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA91F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC5BEffect1Depth -- the copy MidiOut_CC5B_Effect1Depth loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_04.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa91f8` at 0xFA72E9, inside MidiOut_CC5B_Effect1Depth.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA72E9 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC5BEffect1Depth:
	.long 0x000076AF                            ; FA91F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA91FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9200  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9204  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9208  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA920C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9210  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9214  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9218  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA921C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9220  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9224  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9228  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA922C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9230  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9234  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9238  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA923C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9240  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9244  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9248  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA924C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9250  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9254  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9258  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA925C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9260  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9264  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9268  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA926C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9270  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9274  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC0APan -- the copy MidiOut_CC0A_Pan loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_05.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa9278` at 0xFA7327, inside MidiOut_CC0A_Pan.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA7327 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC0APan:
	.long 0x000076AF                            ; FA9278  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA927C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9280  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9284  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9288  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA928C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9290  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9294  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9298  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA929C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA92A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA92A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA92A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA92AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA92B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA92B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA92B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA92BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA92C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA92C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA92C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA92CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA92D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA92D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA92D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA92DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA92E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA92E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA92E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA92EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA92F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA92F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_Rpn02CoarseTune -- the copy MidiOut_Rpn02_CoarseTune loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_06.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa92f8` at 0xFA736B, inside MidiOut_Rpn02_CoarseTune.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA736B is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_Rpn02CoarseTune:
	.long 0x000076AF                            ; FA92F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA92FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9300  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9304  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9308  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA930C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9310  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9314  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9318  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA931C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9320  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9324  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9328  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA932C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9330  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9334  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9338  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA933C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9340  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9344  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9348  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA934C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9350  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9354  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9358  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA935C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9360  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9364  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9368  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA936C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9370  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9374  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_Rpn01FineTune -- the copy MidiOut_Rpn01_FineTune loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_07.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa9378` at 0xFA73A7, inside MidiOut_Rpn01_FineTune.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA73A7 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_Rpn01FineTune:
	.long 0x000076AF                            ; FA9378  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA937C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9380  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9384  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9388  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA938C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9390  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9394  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9398  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA939C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA93A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA93A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA93A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA93AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA93B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA93B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA93B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA93BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA93C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA93C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA93C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA93CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA93D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA93D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA93D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA93DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA93E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA93E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA93E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA93EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA93F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA93F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_Rpn00PitchBendRange -- the copy MidiOut_Rpn00_PitchBendRange loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_08.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa93f8` at 0xFA73E9, inside MidiOut_Rpn00_PitchBendRange.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA73E9 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_Rpn00PitchBendRange:
	.long 0x000076AF                            ; FA93F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA93FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9400  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9404  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9408  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA940C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9410  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9414  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9418  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA941C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9420  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9424  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9428  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA942C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9430  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9434  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9438  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA943C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9440  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9444  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9448  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA944C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9450  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9454  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9458  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA945C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9460  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9464  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9468  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA946C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9470  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9474  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC79ResetAllCtrl -- the copy MidiOut_CC79_ResetAllCtrl loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_09.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa9478` at 0xFA7630, inside MidiOut_CC79_ResetAllCtrl.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA7630 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC79ResetAllCtrl:
	.long 0x000076AF                            ; FA9478  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA947C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9480  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9484  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9488  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA948C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9490  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9494  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9498  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA949C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA94A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA94A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA94A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA94AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA94B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA94B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA94B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA94BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA94C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA94C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA94C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA94CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA94D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA94D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA94D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA94DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA94E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA94E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA94E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA94EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA94F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA94F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC78AllSoundOff -- the copy MidiOut_CC78_AllSoundOff loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_10.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa94f8` at 0xFA765E, inside MidiOut_CC78_AllSoundOff.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA765E is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC78AllSoundOff:
	.long 0x000076AF                            ; FA94F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA94FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9500  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9504  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9508  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA950C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9510  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9514  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9518  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA951C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9520  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9524  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9528  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA952C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9530  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9534  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9538  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA953C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9540  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9544  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9548  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA954C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9550  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9554  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9558  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA955C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9560  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9564  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9568  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA956C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9570  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9574  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_PitchBend -- 32 part-record pointers,
;                           the copy MidiOut_PitchBend__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_11.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9578` at 0xFA76C6, inside MidiOut_PitchBend__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_PitchBend:
	.long 0x000076AF                            ; FA9578  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA957C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9580  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9584  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9588  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA958C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9590  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9594  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9598  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA959C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA95A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA95A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA95A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA95AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA95B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA95B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA95B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA95BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA95C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA95C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA95C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA95CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA95D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA95D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA95D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA95DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA95E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA95E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA95E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA95EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA95F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA95F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC01Modulation -- 32 part-record pointers,
;                           the copy MidiOut_CC01_Modulation__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_12.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA95F8` at 0xFA7765, inside MidiOut_CC01_Modulation__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC01Modulation:
	.long 0x000076AF                            ; FA95F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA95FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9600  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9604  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9608  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA960C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9610  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9614  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9618  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA961C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9620  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9624  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9628  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA962C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9630  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9634  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9638  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA963C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9640  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9644  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9648  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA964C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9650  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9654  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9658  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA965C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9660  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9664  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9668  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA966C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9670  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9674  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC0BExpression -- 32 part-record pointers,
;                           the copy MidiOut_CC0B_Expression__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_13.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9678` at 0xFA77D3, inside MidiOut_CC0B_Expression__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC0BExpression:
	.long 0x000076AF                            ; FA9678  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA967C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9680  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9684  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9688  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA968C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9690  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9694  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9698  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA969C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA96A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA96A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA96A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA96AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA96B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA96B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA96B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA96BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA96C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA96C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA96C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA96CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA96D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA96D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA96D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA96DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA96E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA96E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA96E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA96EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA96F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA96F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_ChannelPressure -- 32 part-record pointers,
;                           the copy MidiOut_ChannelPressure__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_14.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA96F8` at 0xFA7842, inside MidiOut_ChannelPressure__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_ChannelPressure:
	.long 0x000076AF                            ; FA96F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA96FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9700  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9704  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9708  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA970C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9710  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9714  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9718  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA971C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9720  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9724  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9728  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA972C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9730  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9734  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9738  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA973C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9740  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9744  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9748  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA974C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9750  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9754  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9758  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA975C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9760  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9764  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9768  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA976C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9770  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9774  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC40Hold -- 32 part-record pointers,
;                           the copy MidiOut_CC40_Hold__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_15.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9778` at 0xFA78D9, inside MidiOut_CC40_Hold__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC40Hold:
	.long 0x000076AF                            ; FA9778  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA977C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9780  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9784  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9788  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA978C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9790  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9794  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9798  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA979C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA97A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA97A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA97A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA97AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA97B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA97B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA97B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA97BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA97C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA97C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA97C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA97CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA97D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA97D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA97D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA97DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA97E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA97E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA97E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA97EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA97F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA97F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_16 -- 32 part-record pointers, READ ONLY BY DEAD CODE
;
; ★ DELIBERATELY STILL FRAMED, and that is this round's measured refusal.
;          Its one reader is sub_FA78FF, which nothing in either of CPU 1's
;          ROMs reaches and whose send index maps to 0xFF.  A name taken from
;          that reader would state a send index and nothing else, and a send
;          index has no referent outside this ROM's own tables.  The other
;          eleven blocks in this address range ARE named this round; these two
;          are the two that are not.  See the header above sub_FA78FF.
; Read by: `ld XIX,0xFA97F8` at 0xFA790E, and nothing else.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_16:
	.long 0x000076AF                            ; FA97F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA97FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9800  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9804  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9808  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA980C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9810  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9814  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9818  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA981C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9820  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9824  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9828  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA982C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9830  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9834  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9838  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA983C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9840  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9844  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9848  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA984C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9850  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9854  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9858  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA985C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9860  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9864  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9868  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA986C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9870  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9874  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_17 -- 32 part-record pointers, READ ONLY BY DEAD CODE
;
; ★ DELIBERATELY STILL FRAMED, and that is this round's measured refusal.
;          Its one reader is sub_FA792F, which nothing in either of CPU 1's
;          ROMs reaches and whose send index maps to 0xFF.  A name taken from
;          that reader would state a send index and nothing else, and a send
;          index has no referent outside this ROM's own tables.  The other
;          eleven blocks in this address range ARE named this round; these two
;          are the two that are not.  See the header above sub_FA792F.
; Read by: `ld XIX,0xFA9878` at 0xFA793E, and nothing else.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_17:
	.long 0x000076AF                            ; FA9878  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA987C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9880  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9884  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9888  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA988C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9890  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9894  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9898  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA989C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA98A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA98A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA98A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA98AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA98B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA98B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA98B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA98BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA98C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA98C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA98C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA98CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA98D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA98D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA98D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA98DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA98E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA98E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA98E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA98EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA98F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA98F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC10RTCreatX -- 32 part-record pointers,
;                           the copy MidiOut_CC10_RTCreatX__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_18.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA98F8` at 0xFA79A7, inside MidiOut_CC10_RTCreatX__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC10RTCreatX:
	.long 0x000076AF                            ; FA98F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA98FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9900  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9904  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9908  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA990C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9910  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9914  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9918  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA991C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9920  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9924  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9928  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA992C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9930  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9934  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9938  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA993C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9940  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9944  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9948  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA994C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9950  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9954  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9958  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA995C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9960  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9964  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9968  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA996C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9970  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9974  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC11RTCreatY -- 32 part-record pointers,
;                           the copy MidiOut_CC11_RTCreatY__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_19.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9978` at 0xFA7A15, inside MidiOut_CC11_RTCreatY__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC11RTCreatY:
	.long 0x000076AF                            ; FA9978  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA997C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9980  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9984  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9988  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA998C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9990  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9994  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9998  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA999C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA99A0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA99A4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA99A8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA99AC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA99B0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA99B4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA99B8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA99BC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA99C0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA99C4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA99C8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA99CC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA99D0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA99D4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA99D8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA99DC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA99E0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA99E4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA99E8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA99EC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA99F0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA99F4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC12RTCtrlX -- 32 part-record pointers,
;                           the copy MidiOut_CC12_RTCtrlX__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_20.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA99F8` at 0xFA7A83, inside MidiOut_CC12_RTCtrlX__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC12RTCtrlX:
	.long 0x000076AF                            ; FA99F8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA99FC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9A00  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9A04  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9A08  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA9A0C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9A10  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9A14  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9A18  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA9A1C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9A20  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9A24  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9A28  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA9A2C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9A30  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9A34  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9A38  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA9A3C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9A40  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9A44  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9A48  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA9A4C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9A50  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9A54  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9A58  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA9A5C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9A60  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9A64  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9A68  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA9A6C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9A70  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9A74  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC13RTCtrlY -- 32 part-record pointers,
;                           the copy MidiOut_CC13_RTCtrlY__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_21.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9A78` at 0xFA7AF1, inside MidiOut_CC13_RTCtrlY__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC13RTCtrlY:
	.long 0x000076AF                            ; FA9A78  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA9A7C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9A80  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9A84  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9A88  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA9A8C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9A90  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9A94  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9A98  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA9A9C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9AA0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9AA4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9AA8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA9AAC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9AB0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9AB4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9AB8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA9ABC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9AC0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9AC4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9AC8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA9ACC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9AD0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9AD4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9AD8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA9ADC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9AE0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9AE4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9AE8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA9AEC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9AF0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9AF4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC02Modulation2 -- 32 part-record pointers,
;                           the copy MidiOut_CC02_Modulation2__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_22.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9AF8` at 0xFA7B5F, inside MidiOut_CC02_Modulation2__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC02Modulation2:
	.long 0x000076AF                            ; FA9AF8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA9AFC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9B00  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9B04  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9B08  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA9B0C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9B10  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9B14  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9B18  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA9B1C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9B20  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9B24  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9B28  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA9B2C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9B30  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9B34  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9B38  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA9B3C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9B40  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9B44  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9B48  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA9B4C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9B50  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9B54  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9B58  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA9B5C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9B60  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9B64  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9B68  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA9B6C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9B70  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9B74  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC04CtrlPedal -- 32 part-record pointers,
;                           the copy MidiOut_CC04_CtrlPedal__partgate loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_23.  All 25 blocks are BYTE-IDENTICAL, so the
;          number in the old name said only "the Nth in address order".  What
;          distinguishes this block is the routine that loads it, and that
;          routine now has a name -- which is exactly the condition round 4's
;          --gaps set: "Name those eleven routines and these eleven tables
;          name themselves."
; Read by: `ld XIX,0xFA9B78` at 0xFA7BCD, inside MidiOut_CC04_CtrlPedal__partgate, and
;          nowhere else in either of CPU 1's ROMs.
; Evidence: check X4 re-derives the reader of every one of the 25 blocks.
; ---------------------------------------------------------------------

MidiOut_PartRecordPtrs_CC04CtrlPedal:
	.long 0x000076AF                            ; FA9B78  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA9B7C  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9B80  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9B84  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9B88  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA9B8C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9B90  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9B94  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9B98  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA9B9C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9BA0  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9BA4  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9BA8  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA9BAC  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9BB0  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9BB4  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9BB8  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA9BBC  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9BC0  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9BC4  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9BC8  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA9BCC  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9BD0  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9BD4  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9BD8  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA9BDC  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9BE0  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9BE4  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9BE8  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA9BEC  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9BF0  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9BF4  [31]   RAM 0x7EAF
; ---------------------------------------------------------------------
; MidiOut_PartRecordPtrs_CC51General6 -- the copy MidiOut_CC51_General6 loads
;
; ★ RENAMED FROM MidiOut_PartRecordPtrs_24.  All 25 of these blocks are
;          BYTE-IDENTICAL (their shared header says so and check B2 of
;          notes/gen_prom_a_fa5aeb_module.py proves it), so the number
;          in the old name said only "the Nth in address order".  What
;          actually distinguishes this block is the routine that loads
;          it, and that routine has a name.
; Read by: `ld XIX,0x00fa9bf8` at 0xFA74E9, inside MidiOut_CC51_General6.  The table's address
;          occurs EXACTLY ONCE as a 32-bit little-endian word anywhere
;          in prom_a, and the byte at 0xFA74E9 is the `ld` opcode -- the
;          instruction address, not the operand address one byte later.
; Evidence: check R1 re-runs the scan and the owner lookup for every one
;          of the 25 blocks and reports which are renamed and which are
;          not; the eleven that are not are listed by --gaps.
; ---------------------------------------------------------------------
MidiOut_PartRecordPtrs_CC51General6:
	.long 0x000076AF                            ; FA9BF8  [0]   RAM 0x76AF
	.long 0x000076EF                            ; FA9BFC  [1]   RAM 0x76EF
	.long 0x0000772F                            ; FA9C00  [2]   RAM 0x772F
	.long 0x0000776F                            ; FA9C04  [3]   RAM 0x776F
	.long 0x000077AF                            ; FA9C08  [4]   RAM 0x77AF
	.long 0x000077EF                            ; FA9C0C  [5]   RAM 0x77EF
	.long 0x0000782F                            ; FA9C10  [6]   RAM 0x782F
	.long 0x0000786F                            ; FA9C14  [7]   RAM 0x786F
	.long 0x000078EF                            ; FA9C18  [8]   RAM 0x78EF
	.long 0x0000792F                            ; FA9C1C  [9]   RAM 0x792F
	.long 0x0000796F                            ; FA9C20  [10]   RAM 0x796F
	.long 0x000079AF                            ; FA9C24  [11]   RAM 0x79AF
	.long 0x000079EF                            ; FA9C28  [12]   RAM 0x79EF
	.long 0x00007A2F                            ; FA9C2C  [13]   RAM 0x7A2F
	.long 0x00007A6F                            ; FA9C30  [14]   RAM 0x7A6F
	.long 0x00007AAF                            ; FA9C34  [15]   RAM 0x7AAF
	.long 0x00007AEF                            ; FA9C38  [16]   RAM 0x7AEF
	.long 0x00007B2F                            ; FA9C3C  [17]   RAM 0x7B2F
	.long 0x00007B6F                            ; FA9C40  [18]   RAM 0x7B6F
	.long 0x00007BAF                            ; FA9C44  [19]   RAM 0x7BAF
	.long 0x00007BEF                            ; FA9C48  [20]   RAM 0x7BEF
	.long 0x00007C2F                            ; FA9C4C  [21]   RAM 0x7C2F
	.long 0x00007C6F                            ; FA9C50  [22]   RAM 0x7C6F
	.long 0x00007CAF                            ; FA9C54  [23]   RAM 0x7CAF
	.long 0x00007CEF                            ; FA9C58  [24]   RAM 0x7CEF
	.long 0x00007D2F                            ; FA9C5C  [25]   RAM 0x7D2F
	.long 0x00007D6F                            ; FA9C60  [26]   RAM 0x7D6F
	.long 0x00007DAF                            ; FA9C64  [27]   RAM 0x7DAF
	.long 0x00007DEF                            ; FA9C68  [28]   RAM 0x7DEF
	.long 0x00007E2F                            ; FA9C6C  [29]   RAM 0x7E2F
	.long 0x00007E6F                            ; FA9C70  [30]   RAM 0x7E6F
	.long 0x00007EAF                            ; FA9C74  [31]   RAM 0x7EAF

; --- 0xFA9C78-0xFA9E71  0x00 pad (506 bytes) ---
	.fill 506, 1, 0x00

; --- 0xFA9E72-0xFA9FFF  0x0E pad (398 bytes) ---
	.fill 398, 1, 0x0E
