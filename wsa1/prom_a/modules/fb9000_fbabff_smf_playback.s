
	push XIZ                                             ; FB9000  3e
	ld XIZ,XSP                                           ; FB9001  ef 8e
	push XIX                                             ; FB9003  3c
	push XHL                                             ; FB9004  3b
	push XDE                                             ; FB9005  3a
	ld BC,(XIZ+0x08)                                     ; FB9006  9e 08 21
	ld E,C                                               ; FB9009  cb 8d
	ld BC,(XIZ+0x0a)                                     ; FB900B  9e 0a 21
	ld D,C                                               ; FB900E  cb 8c
	ld BC,(XIZ+0x0c)                                     ; FB9010  9e 0c 21
	ld A,C                                               ; FB9013  cb 89
	ld BC,(XIZ+0x0e)                                     ; FB9015  9e 0e 21
	ld W,C                                               ; FB9018  cb 88
	call T_Queue2C00_AppendRegs                          ; FB901A  1d 38 0f f4
	pop XDE                                              ; FB901E  5a
	pop XHL                                              ; FB901F  5b
	pop XIX                                              ; FB9020  5c
	pop XIZ                                              ; FB9021  5e
	ret                                                  ; FB9022  0e
	push XIZ                                             ; FB9023  3e
	ld XIZ,XSP                                           ; FB9024  ef 8e
	push XIX                                             ; FB9026  3c
	push XHL                                             ; FB9027  3b
	push XDE                                             ; FB9028  3a
	ld BC,(XIZ+0x08)                                     ; FB9029  9e 08 21
	ld E,C                                               ; FB902C  cb 8d
	ld BC,(XIZ+0x0a)                                     ; FB902E  9e 0a 21
	ld D,C                                               ; FB9031  cb 8c
	ld BC,(XIZ+0x0c)                                     ; FB9033  9e 0c 21
	ld A,C                                               ; FB9036  cb 89
	ld BC,(XIZ+0x0e)                                     ; FB9038  9e 0e 21
	ld W,C                                               ; FB903B  cb 88
	call T_Tempo_ApplyBpm                                        ; FB903D  1d 94 07 f4
	pop XDE                                              ; FB9041  5a
	pop XHL                                              ; FB9042  5b
	pop XIX                                              ; FB9043  5c
	pop XIZ                                              ; FB9044  5e
	ret                                                  ; FB9045  0e
; Transport_StopAllRunning_SaveRegs: calls Transport_StopAllRunning with the registers it pushes saved around it -- `push XIX / push XIZ / push XHL / push XDE / call T_Transport_StopAllRunning / pop XDE / pop XHL / pop XIZ / pop XIX / ret`.
Transport_StopAllRunning_SaveRegs:
	push XIX                                             ; FB9046  3c
	push XIZ                                             ; FB9047  3e
	push XHL                                             ; FB9048  3b
	push XDE                                             ; FB9049  3a
	call T_Transport_StopAllRunning                                        ; FB904A  1d ac 09 f4
	pop XDE                                              ; FB904E  5a
	pop XHL                                              ; FB904F  5b
	pop XIZ                                              ; FB9050  5e
	pop XIX                                              ; FB9051  5c
	ret                                                  ; FB9052  0e
; Transport_StartCAndB_SaveRegs: calls Transport_StartCAndB with the registers it pushes saved around it -- `push XIX / push XIZ / push XHL / push XDE / call T_Transport_StartCAndB / pop XDE / pop XHL / pop XIZ / pop XIX / ret`.
Transport_StartCAndB_SaveRegs:
	push XIX                                             ; FB9053  3c
	push XIZ                                             ; FB9054  3e
	push XHL                                             ; FB9055  3b
	push XDE                                             ; FB9056  3a
	call T_Transport_StartCAndB                                        ; FB9057  1d a4 09 f4
	pop XDE                                              ; FB905B  5a
	pop XHL                                              ; FB905C  5b
	pop XIZ                                              ; FB905D  5e
	pop XIX                                              ; FB905E  5c
	ret                                                  ; FB905F  0e
; Msg0716_AllPartsResetBendAndModulation_SaveRegs: calls Msg0716_AllPartsResetBendAndModulation with the registers it pushes saved around it -- `push XIX / push XIZ / push XHL / push XDE / call T_Msg0716_AllPartsResetBendAndModulation / pop XDE / pop XHL / pop XIZ / pop XIX / ret`.
Msg0716_AllPartsResetBendAndModulation_SaveRegs:
	push XIX                                             ; FB9060  3c
	push XIZ                                             ; FB9061  3e
	push XHL                                             ; FB9062  3b
	push XDE                                             ; FB9063  3a
	call T_Msg0716_AllPartsResetBendAndModulation                                        ; FB9064  1d d0 0f f4
	pop XDE                                              ; FB9068  5a
	pop XHL                                              ; FB9069  5b
	pop XIZ                                              ; FB906A  5e
	pop XIX                                              ; FB906B  5c
	ret                                                  ; FB906C  0e
; Medley_ScheduleNextMidiFile_SaveRegs: Medley_ScheduleNextMidiFile with XIX/XIZ/XHL/XDE pushed around it (`call
;   T_Medley_ScheduleNextMidiFile`). Called when an FD MIDI-file medley song cannot be opened
;   (Medley_ToggleMidiFileStream) or has stopped (SequencerMedley_MidiFileTick, after MidiFilePlay_Stop), so
;   Medley_Countdown := 10 starts the next file. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
Medley_ScheduleNextMidiFile_SaveRegs:
	push XIX                                             ; FB906D  3c
	push XIZ                                             ; FB906E  3e
	push XHL                                             ; FB906F  3b
	push XDE                                             ; FB9070  3a
	call T_Medley_ScheduleNextMidiFile                                        ; FB9071  1d 28 30 f4
	pop XDE                                              ; FB9075  5a
	pop XHL                                              ; FB9076  5b
	pop XIZ                                              ; FB9077  5e
	pop XIX                                              ; FB9078  5c
	ret                                                  ; FB9079  0e
	push XIX                                             ; FB907A  3c
	push XIZ                                             ; FB907B  3e
	push XHL                                             ; FB907C  3b
	push XDE                                             ; FB907D  3a
	push XWA                                             ; FB907E  38
	call SmfPlay_ScaleDeltaTo96Ppq                                      ; FB907F  1d 98 90 fb
	pop XWA                                              ; FB9083  58
	pop XDE                                              ; FB9084  5a
	pop XHL                                              ; FB9085  5b
	pop XIZ                                              ; FB9086  5e
	pop XIX                                              ; FB9087  5c
	ret                                                  ; FB9088  0e
; TimedEventRing_Discard_SaveRegs_B: calls TimedEventRing_Discard with the registers it pushes saved around it -- `push XIX / push XIZ / push XHL / push XDE / push XWA / call T_TimedEventRing_Discard / pop XWA / pop XDE / pop XHL / pop XIZ / pop XIX / ret`.
TimedEventRing_Discard_SaveRegs_B:
	push XIX                                             ; FB9089  3c
	push XIZ                                             ; FB908A  3e
	push XHL                                             ; FB908B  3b
	push XDE                                             ; FB908C  3a
	push XWA                                             ; FB908D  38
	call T_TimedEventRing_Discard                                        ; FB908E  1d 14 0a f4
	pop XWA                                              ; FB9092  58
	pop XDE                                              ; FB9093  5a
	pop XHL                                              ; FB9094  5b
	pop XIZ                                              ; FB9095  5e
	pop XIX                                              ; FB9096  5c
	ret                                                  ; FB9097  0e
; SmfPlay_ScaleDeltaTo96Ppq: when the file's division (0x605066) is not 0x60: (0x60505F) = delta x 0x60 / division, + 1 when the
;   remainder checks against (0x60506A) / (0x60506E) say so.
SmfPlay_ScaleDeltaTo96Ppq:
	xor XWA,XWA                                          ; FB9098  e8 d0
	xor XHL,XHL                                          ; FB909A  eb d3
	xor XDE,XDE                                          ; FB909C  ea d2
	ld wa, (SmfPlay_Division:24)                                ; FB909E  d2 66 50 60 20
	cp WA,0x0060                                         ; FB90A3  d8 cf 60 00
	jr z, .LFB90EA                                       ; FB90A7  66 41
	ld xwa, (SmfPlay_VlqValue:24)                               ; FB90A9  e2 5f 50 60 20
	ldw hl, 0x60                                         ; FB90AE  33 60 00
	mul xwa, hl                                         ; FB90B1  db 40
	ld hl, (SmfPlay_Division:24)                                ; FB90B3  d2 66 50 60 23
	div xwa, hl                                         ; FB90B8  db 50
	xor XDE,XDE                                          ; FB90BA  ea d2
	ld DE,QWA                                            ; FB90BC  d7 e2 8a
	xor HL,HL                                            ; FB90BF  db d3
	ld QWA,HL                                            ; FB90C1  d7 e2 9b
	ld (SmfPlay_VlqValue:24), xwa                               ; FB90C4  f2 5f 50 60 60
	cpw	(SmfPlay_Division:24), 0x0060                        ; FB90C9  d2 66 50 60 3f 60 00
	jr ule, .LFB90EA                                     ; FB90D0  63 18
	cp	xwa, (0x60506a:24)                           ; FB90D2  e2 6a 50 60 f0
	jr nc, .LFB90EA                                      ; FB90D7  6f 11
	cp	xwa, (0x60506e:24)                           ; FB90D9  e2 6e 50 60 f0
	jr ule, .LFB90EA                                     ; FB90DE  63 0a
	ld XIZ,0x00000001                                    ; FB90E0  46 01 00 00 00
	add (SmfPlay_VlqValue:24), xiz                              ; FB90E5  e2 5f 50 60 8e
.LFB90EA:
	ret                                                  ; FB90EA  0e
; SmfPlay_ApplyTempo_SaveAll: SmfPlay_ApplyTempoAsBpm with every register pair saved.
SmfPlay_ApplyTempo_SaveAll:
	push XIX                                             ; FB90EB  3c
	push XIZ                                             ; FB90EC  3e
	push XHL                                             ; FB90ED  3b
	push XDE                                             ; FB90EE  3a
	push XWA                                             ; FB90EF  38
	push XIY                                             ; FB90F0  3d
	push XBC                                             ; FB90F1  39
	call SmfPlay_ApplyTempoAsBpm                                      ; FB90F2  1d fe 90 fb
	pop XBC                                              ; FB90F6  59
	pop XIY                                              ; FB90F7  5d
	pop XWA                                              ; FB90F8  58
	pop XDE                                              ; FB90F9  5a
	pop XHL                                              ; FB90FA  5b
	pop XIZ                                              ; FB90FB  5e
	pop XIX                                              ; FB90FC  5c
	ret                                                  ; FB90FD  0e
; SmfPlay_ApplyTempoAsBpm: BPM = 0x39387 (60,000,000 / 256) / ((0x605063) << 8 | (0x605064)), clamped 40..300; to (0x7EE2); queued as
;   parameter 0x7A (Queue2C00); T_Tempo_ApplyBpm.
SmfPlay_ApplyTempoAsBpm:
	xor XWA,XWA                                          ; FB90FE  e8 d0
	ld h, (SmfPlay_TempoMicros:24)                                 ; FB9100  c2 63 50 60 26
	ld l, (0x605064:24)                                 ; FB9105  c2 64 50 60 27
	ldw wa, 0x9387                                       ; FB910A  30 87 93
	ldw de, 0x03                                         ; FB910D  32 03 00
	ld QWA,DE                                            ; FB9110  d7 e2 9a
	div xwa, hl                                         ; FB9113  db 50
	ld DE,QWA                                            ; FB9115  d7 e2 8a
	cp WA,0x0028                                         ; FB9118  d8 cf 28 00
	jr ugt, .LFB9123                                     ; FB911C  6b 05
	ldw wa, 0x28                                         ; FB911E  30 28 00
	jr .LFB912C                                          ; FB9121  68 09
.LFB9123:
	cp WA,0x012c                                         ; FB9123  d8 cf 2c 01
	jr c, .LFB912C                                       ; FB9127  67 03
	ldw wa, 0x012c                                       ; FB9129  30 2c 01
.LFB912C:
	and W,0x01                                           ; FB912C  c8 cc 01
	xor HL,HL                                            ; FB912F  db d3
	ld XIY,0x00007ee2                                    ; FB9131  45 e2 7e 00 00
	ld	(xiy+0:8), a                                 ; FB9136  bd 00 41
	ld L,A                                               ; FB9139  c9 8f
	and (XIY+0x01),0xfe                                  ; FB913B  8d 01 3c fe
	and H,0xfe                                           ; FB913F  ce cc fe
	bit 0x00,W                                           ; FB9142  c8 33 00
	jr z, .LFB914E                                       ; FB9145  66 07
	or	(xiy+1), 0x01                                ; FB9147  8d 01 3e 01
	or H,0x01                                            ; FB914B  ce ce 01
.LFB914E:
	ld (0x605068:24), hl                                ; FB914E  f2 68 50 60 53
	orw	(0x605068:24), 0x8000                ; FB9153  d2 68 50 60 3e 00 80
	ld e, 0x7a:opc                                          ; FB915A  25 7a
	ld d, 0x00:opc                                          ; FB915C  24 00
	ld w, 0xff:opc                                          ; FB915E  20 ff
	call T_Queue2C00_AppendRegs                          ; FB9160  1d 38 0f f4
	call T_Tempo_ApplyBpm                                        ; FB9164  1d 94 07 f4
	ret                                                  ; FB9168  0e
	ret                                                  ; FB9169  0e
; SeqClock_ResetBeatAndTick: with interrupts masked (ei 6 ... ei 0): the beat word (0x91) = 0 and Seq_BeatTick = 0.
SeqClock_ResetBeatAndTick:
	ei 0x06                                              ; FB916A  06 06
	ldw (TransportB_Beat:8), 0x00:io                                     ; FB916C  0a 91 00 00
	ld (Seq_BeatTick:8), 0x00:io                                      ; FB9170  08 93 00
	ei 0x00                                              ; FB9173  06 00
	ret                                                  ; FB9175  0e
; SmfPlay_StopAtEndOfTrack: (0x60505E) bit 0 cleared; all notes off and hold off injected on every channel, positions cleared, bend /
;   modulation reset, transports stopped (waits for TransportB), clock reset, T_MidiFileStream_Close,
;   (0x60505E) bit 1 and (0x605148) cleared.
SmfPlay_StopAtEndOfTrack:
	pushw hl                                             ; FB9176  2b
	pushw de                                             ; FB9177  2a
	push XIX                                             ; FB9178  3c
	lda xix, (0x60505e:24)                               ; FB9179  f2 5e 50 60 34
	and (XIX),0xfe                                       ; FB917E  84 3c fe
	ld (0x60504c:24), 0x00                             ; FB9181  f2 4c 50 60 00 00
	calr MidiInQueue_InjectAllNotesOff_AllChannels                                      ; FB9187  1e 92 00
	calr MidiFilePlay_ClearPosition                                      ; FB918A  1e 8e 07
	calr MidiFilePlay_ClearPosition_Copy                                      ; FB918D  1e d1 0c
	calr SmfPlay_ClearEventTimes                                      ; FB9190  1e d6 0c
	call Msg0716_AllPartsResetBendAndModulation_SaveRegs                                      ; FB9193  1d 60 90 fb
	calr MidiInQueue_InjectHoldPedalOff_AllChannels                                      ; FB9197  1e 02 01
	call Transport_StopAllRunning_SaveRegs                                      ; FB919A  1d 46 90 fb
	ld	d, (TransportB_State:8)                                      ; FB919E  c0 96 24
	and D,0x04                                           ; FB91A1  cc cc 04
	ldw hl, 0x7fff                                       ; FB91A4  33 ff 7f
.LFB91A7:
	cp d, 0x00:i3                                          ; FB91A7  cc d8
	jr nz, .LFB91B1                                      ; FB91A9  6e 06
	dec 1,HL                                             ; FB91AB  db 69
	cp hl, 0x00:i3                                         ; FB91AD  db d8
	jr nz, .LFB91A7                                      ; FB91AF  6e f6
.LFB91B1:
	calr SeqClock_ResetBeatAndTick                                      ; FB91B1  1e b6 ff
	set	4, (UI_ScreenFlags:16)                               ; FB91B4  f1 95 20 bc
	call T_MidiFileStream_Close                                        ; FB91B8  1d 20 26 f4
	and (XIX),0xfd                                       ; FB91BC  84 3c fd
	ld (SmfPlay_Playing:24), 0x00                             ; FB91BF  f2 48 51 60 00 00
	pop XIX                                              ; FB91C5  5c
	popw de                                              ; FB91C6  4a
	popw hl                                              ; FB91C7  4b
	ret                                                  ; FB91C8  0e
; MidiFilePlay_Stop: clears (0x60505E) bit 0 and (0x60504C), MidiInQueue_InjectAllNotesOff_AllChannels, T_PartNotes_ReleaseAllReceivedMidiIn, then clears the
;   position (0x605040) and (0x605044) / (0x605048).  Called by MidiFileDirectPlay_LcdKeyRow1, both ticks, and the leave.
MidiFilePlay_Stop:
	pushw hl                                             ; FB91C9  2b
	pushw de                                             ; FB91CA  2a
	push XIX                                             ; FB91CB  3c
	lda xix, (0x60505e:24)                               ; FB91CC  f2 5e 50 60 34
	and (XIX),0xfe                                       ; FB91D1  84 3c fe
	ld (0x60504c:24), 0x00                             ; FB91D4  f2 4c 50 60 00 00
	calr MidiInQueue_InjectAllNotesOff_AllChannels                                      ; FB91DA  1e 3f 00
	call T_PartNotes_ReleaseAllReceivedMidiIn                                        ; FB91DD  1d c0 13 f4
	calr MidiFilePlay_ClearPosition                                      ; FB91E1  1e 37 07
	calr MidiFilePlay_ClearPosition_Copy                                      ; FB91E4  1e 7a 0c
	calr SmfPlay_ClearEventTimes                                      ; FB91E7  1e 7f 0c
	call Msg0716_AllPartsResetBendAndModulation_SaveRegs                                      ; FB91EA  1d 60 90 fb
; (sub_FB91EE removed 2026-10-04: no code names it and the line above falls through into it -- part of MidiFilePlay_Stop;
;  notes/prom_a_stray_label_removal.py)
	calr MidiInQueue_InjectHoldPedalOff_AllChannels                                      ; FB91EE  1e ab 00
	call Transport_StopAllRunning_SaveRegs                                      ; FB91F1  1d 46 90 fb
	ld	d, (TransportB_State:8)                                      ; FB91F5  c0 96 24
	and D,0x04                                           ; FB91F8  cc cc 04
	ldw hl, 0x7fff                                       ; FB91FB  33 ff 7f
MidiFilePlay_Stop_Loop:
	cp d, 0x00:i3                                          ; FB91FE  cc d8
	jr nz, .LFB9208                                      ; FB9200  6e 06
	dec 1,HL                                             ; FB9202  db 69
	cp hl, 0x00:i3                                         ; FB9204  db d8
	jr nz, MidiFilePlay_Stop_Loop                                    ; FB9206  6e f6
.LFB9208:
	calr SeqClock_ResetBeatAndTick                                      ; FB9208  1e 5f ff
	call T_MidiFileStream_Close                                        ; FB920B  1d 20 26 f4
	and (XIX),0xfd                                       ; FB920F  84 3c fd
	ld (SmfPlay_Playing:24), 0x00                             ; FB9212  f2 48 51 60 00 00
	pop XIX                                              ; FB9218  5c
	popw de                                              ; FB9219  4a
	popw hl                                              ; FB921A  4b
	ret                                                  ; FB921B  0e
; ---------------------------------------------------------------------
; MidiInQueue_InjectAllNotesOff_AllChannels -- appends `Bn 7B 00` to the MIDI INPUT queue for n = 0..0x0F
;
; Evidence: 0xFB921E loads the thunk 0xF41DAC, which prom_b publishes as
;           T_MidiInARing_Put, and 0x600C1E is the ring
;           MIDI_RX_DeliverTwo appends received bytes to (0xFA57B3 `ld
;           XIX,0x00600c1e`), so this INJECTS into the receive path
;           rather than transmitting; 0xFB9227 `or H,0xb0` builds the
;           status byte from the loop counter, which runs 0x00..0x0F
;           (0xFB9223 `ldb l,0x00`, 0xFB9254 `cp L,0x0f`, 0xFB9257 `jr
;           ule`); the three calls at 0xFB9236, 0xFB9241 and 0xFB924C
;           push 0x00/H, 0x7B and 0x00, and 0xFB924E `inc 6,XSP`
;           reclaims exactly those three words. CC 0x7B with value 0 is
;           All Notes Off, which the tree already documents at
;           MIDI_AllNotesOffTemplate
; Unknown:  who calls it and when: its two callers, 0xFB9187 and
;           0xFB91DA, are themselves unnamed
; Was `sub_FB921C`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
MidiInQueue_InjectAllNotesOff_AllChannels:
	pushw hl                                             ; FB921C  2b
	push XIX                                             ; FB921D  3c
	lda xix, (T_MidiInARing_Put:24)                       ; FB921E  f2 ac 1d f4 34
	ld l, 0x00:opc                                          ; FB9223  27 00
.LFB9225:
	ld H,L                                               ; FB9225  cf 8e
	or H,0xb0                                            ; FB9227  ce ce b0
	ei 0x06                                              ; FB922A  06 06
	push 0x00                                            ; FB922C  09 00
	push H                                               ; FB922E  ce 04
	lda xiy, (.LFB9238:24)                               ; FB9230  f2 38 92 fb 35
	push XIY                                             ; FB9235  3d
	jp (xix)                                             ; FB9236  b4 d8
.LFB9238:
	pushw 0x7b                                           ; FB9238  0b 7b 00
	lda xiy, (.LFB9243:24)                               ; FB923B  f2 43 92 fb 35
	push XIY                                             ; FB9240  3d
	jp (xix)                                             ; FB9241  b4 d8
.LFB9243:
	pushw 0x00                                           ; FB9243  0b 00 00
	lda xiy, (.LFB924E:24)                               ; FB9246  f2 4e 92 fb 35
	push XIY                                             ; FB924B  3d
	jp (xix)                                             ; FB924C  b4 d8
.LFB924E:
	inc 6,XSP                                            ; FB924E  ef 66
	ei 0x00                                              ; FB9250  06 00
	inc 1,L                                              ; FB9252  cf 61
	cp L,0x0f                                            ; FB9254  cf cf 0f
	jr ule, .LFB9225                                     ; FB9257  63 cc
	pop XIX                                              ; FB9259  5c
	popw hl                                              ; FB925A  4b
	ret                                                  ; FB925B  0e
; ---------------------------------------------------------------------
; MidiInQueue_InjectController0_AllChannels -- appends `Bn 00 40` to the MIDI INPUT queue for n = 0..0x0F
;
; Evidence: the three injectors are 64 bytes each and EVERY byte that
;           differs is either one of the two pushed data bytes -- offset
;           29 and offset 40, 0x7B/0x00 in the sibling and 0x00/0x40
;           here (0xFB9278 `pushw 0x00`, 0xFB9283 `pushw 0x40`) -- or
;           the low byte of one of the three `lda_24 xiy` return-address
;           literals at offsets 21, 32 and 43, which is position and not
;           content. Same ring (0xFB925E), same 0xB0 (0xFB9267), same
;           0x00..0x0F bound (0xFB9294)
; Unknown:  ⚠ what controller 0 means to this machine. On the wire CC 0
;           is Bank Select MSB and 0x40 would be bank 64, but the
;           destination here is the INPUT queue, not the wire, and
;           nothing in this tree maps the receiver's controller numbers.
;           The name states the number and claims nothing about it
; Was `sub_FB925C`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
MidiInQueue_InjectController0_AllChannels:
	pushw hl                                             ; FB925C  2b
	push XIX                                             ; FB925D  3c
	lda xix, (T_MidiInARing_Put:24)                       ; FB925E  f2 ac 1d f4 34
	ld l, 0x00:opc                                          ; FB9263  27 00
.LFB9265:
	ld H,L                                               ; FB9265  cf 8e
	or H,0xb0                                            ; FB9267  ce ce b0
	ei 0x06                                              ; FB926A  06 06
	push 0x00                                            ; FB926C  09 00
	push H                                               ; FB926E  ce 04
	lda xiy, (.LFB9278:24)                               ; FB9270  f2 78 92 fb 35
	push XIY                                             ; FB9275  3d
	jp (xix)                                             ; FB9276  b4 d8
.LFB9278:
	pushw 0x00                                           ; FB9278  0b 00 00
	lda xiy, (.LFB9283:24)                               ; FB927B  f2 83 92 fb 35
	push XIY                                             ; FB9280  3d
	jp (xix)                                             ; FB9281  b4 d8
.LFB9283:
	pushw 0x40                                           ; FB9283  0b 40 00
	lda xiy, (.LFB928E:24)                               ; FB9286  f2 8e 92 fb 35
	push XIY                                             ; FB928B  3d
	jp (xix)                                             ; FB928C  b4 d8
.LFB928E:
	inc 6,XSP                                            ; FB928E  ef 66
	ei 0x00                                              ; FB9290  06 00
	inc 1,L                                              ; FB9292  cf 61
	cp L,0x0f                                            ; FB9294  cf cf 0f
	jr ule, .LFB9265                                     ; FB9297  63 cc
	pop XIX                                              ; FB9299  5c
	popw hl                                              ; FB929A  4b
	ret                                                  ; FB929B  0e
; ---------------------------------------------------------------------
; MidiInQueue_InjectHoldPedalOff_AllChannels -- appends `Bn 40 00` to the MIDI INPUT queue for n = 0..0x0F
;
; Evidence: the same 64 bytes again, with 0xFB92B8 `pushw 0x40` as the
;           first data byte; it differs from the CC 0x7B routine in FOUR
;           bytes, the three position-dependent return-address literals
;           and offset 29, because both routines push 0x00 as the second
;           data byte. CC 0x40 with value 0 is Hold 1 (damper) OFF, and
;           that reading is corroborated by the sibling that emits CC
;           0x7B: two of the three routines spell a standard controller
;           reset in the standard order, which is what fixes the
;           argument order as status, data 1, data 2
; Unknown:  as for the sibling -- the receiver's controller map is not
;           established
; Was `sub_FB929C`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
MidiInQueue_InjectHoldPedalOff_AllChannels:
	pushw hl                                             ; FB929C  2b
	push XIX                                             ; FB929D  3c
	lda xix, (T_MidiInARing_Put:24)                       ; FB929E  f2 ac 1d f4 34
	ld l, 0x00:opc                                          ; FB92A3  27 00
.LFB92A5:
	ld H,L                                               ; FB92A5  cf 8e
	or H,0xb0                                            ; FB92A7  ce ce b0
	ei 0x06                                              ; FB92AA  06 06
	push 0x00                                            ; FB92AC  09 00
	push H                                               ; FB92AE  ce 04
	lda xiy, (.LFB92B8:24)                               ; FB92B0  f2 b8 92 fb 35
	push XIY                                             ; FB92B5  3d
	jp (xix)                                             ; FB92B6  b4 d8
.LFB92B8:
	pushw 0x40                                           ; FB92B8  0b 40 00
	lda xiy, (.LFB92C3:24)                               ; FB92BB  f2 c3 92 fb 35
	push XIY                                             ; FB92C0  3d
	jp (xix)                                             ; FB92C1  b4 d8
.LFB92C3:
	pushw 0x00                                           ; FB92C3  0b 00 00
	lda xiy, (.LFB92CE:24)                               ; FB92C6  f2 ce 92 fb 35
	push XIY                                             ; FB92CB  3d
	jp (xix)                                             ; FB92CC  b4 d8
.LFB92CE:
	inc 6,XSP                                            ; FB92CE  ef 66
	ei 0x00                                              ; FB92D0  06 00
	inc 1,L                                              ; FB92D2  cf 61
	cp L,0x0f                                            ; FB92D4  cf cf 0f
	jr ule, .LFB92A5                                     ; FB92D7  63 cc
	pop XIX                                              ; FB92D9  5c
	popw hl                                              ; FB92DA  4b
	ret                                                  ; FB92DB  0e
; SmfPlay_ReadChannelEvent: SmfPlay_ReadEventWithStatus when the byte just read (0x605056) has bit 7, else SmfPlay_ReadEventRunningStatus.
SmfPlay_ReadChannelEvent:
	ld c, (SmfPlay_LastByte:24)                                 ; FB92DC  c2 56 50 60 23
	and C,0x80                                           ; FB92E1  cb cc 80
	jr z, .LFB92EB                                       ; FB92E4  66 05
	calr SmfPlay_ReadEventWithStatus                                      ; FB92E6  1e 5c 00
	jr .LFB92EE                                          ; FB92E9  68 03
.LFB92EB:
	calr SmfPlay_ReadEventRunningStatus                                      ; FB92EB  1e 01 00
.LFB92EE:
	ret                                                  ; FB92EE  0e
; SmfPlay_ReadEventRunningStatus: status = Smf_RunningStatus, the byte just read is data 1, data 2 read unless 0xCn / 0xDn;
;   SmfPlay_SendChannelEvent.
SmfPlay_ReadEventRunningStatus:
	pushw hl                                             ; FB92EF  2b
	push XIX                                             ; FB92F0  3c
	lda xix, (Smf_EventStatus:16)                                ; FB92F1  f1 d0 10 34
	ld c, (Smf_RunningStatus:16)                                   ; FB92F5  c1 cc 10 23
	ld (XIX),C                                           ; FB92F9  b4 43
	ld h, (Smf_RunningStatus:16)                                   ; FB92FB  c1 cc 10 26
	extz XIX                                             ; FB92FF  ec 12
	ld c, (SmfPlay_LastByte:24)                                 ; FB9301  c2 56 50 60 23
	ld (XIX+0x01),C                                      ; FB9306  bc 01 43
	ld C,H                                               ; FB9309  ce 8b
	and C,0xf0                                           ; FB930B  cb cc f0
	extz BC                                              ; FB930E  d9 12
	cp BC,0x00c0                                         ; FB9310  d9 cf c0 00
	jr z, .LFB933F                                       ; FB9314  66 29
	cp BC,0x00d0                                         ; FB9316  d9 cf d0 00
	jr z, .LFB933F                                       ; FB931A  66 23
	call T_MidiFileStream_GetByte                                        ; FB931C  1d 1c 26 f4
	ld HL,WA                                             ; FB9320  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9322  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9327  db d8
	jr ge, .LFB9330                                      ; FB9329  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB932B  f2 47 51 60 b8
.LFB9330:
	ld h, (SmfPlay_LastRead:24)                                 ; FB9330  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB9335  f2 56 50 60 46
	extz XIX                                             ; FB933A  ec 12
	ld (XIX+0x02),H                                      ; FB933C  bc 02 46
.LFB933F:
	calr SmfPlay_SendChannelEvent                                      ; FB933F  1e 97 02
	pop XIX                                              ; FB9342  5c
	popw hl                                              ; FB9343  4b
	ret                                                  ; FB9344  0e
; SmfPlay_ReadEventWithStatus: Smf_RunningStatus = Smf_EventStatus = the status; one data byte for 0xCn / 0xDn, two otherwise;
;   SmfPlay_SendChannelEvent.
SmfPlay_ReadEventWithStatus:
	link XIZ,0xfffc                                      ; FB9345  ee 0c fc ff
	pushw hl                                             ; FB9349  2b
	pushw de                                             ; FB934A  2a
	pushw ix                                             ; FB934B  2c
	ld c, (SmfPlay_LastByte:24)                                 ; FB934C  c2 56 50 60 23
	ld (Smf_RunningStatus:16), c                                   ; FB9351  f1 cc 10 43
	ld a, (SmfPlay_LastByte:24)                                 ; FB9355  c2 56 50 60 21
	ld (Smf_EventStatus:16), a                                   ; FB935A  f1 d0 10 41
	ld c, (SmfPlay_LastByte:24)                                 ; FB935E  c2 56 50 60 23
	and C,0xf0                                           ; FB9363  cb cc f0
	extz BC                                              ; FB9366  d9 12
	cp BC,0x00c0                                         ; FB9368  d9 cf c0 00
	jr z, .LFB9376                                       ; FB936C  66 08
	cp BC,0x00d0                                         ; FB936E  d9 cf d0 00
	jr z, .LFB9376                                       ; FB9372  66 02
	jr .LFB937B                                          ; FB9374  68 05
.LFB9376:
	ldw ix, 0x01                                         ; FB9376  34 01 00
	jr .LFB937E                                          ; FB9379  68 03
.LFB937B:
	ldw ix, 0x02                                         ; FB937B  34 02 00
.LFB937E:
	ldw de, 0x00                                         ; FB937E  32 00 00
	cp ix, 0x00:i3                                         ; FB9381  dc d8
	jr ule, .LFB93C7                                     ; FB9383  63 42
	ldw hl, 0x01                                         ; FB9385  33 01 00
.LFB9388:
	call T_MidiFileStream_GetByte                                        ; FB9388  1d 1c 26 f4
	ld (xiz-2), wa                                       ; FB938C  be fe 50
	ld (SmfPlay_LastRead:24), wa                                ; FB938F  f2 45 51 60 50
	cpw	(xiz-2), 0x0000                              ; FB9394  9e fe 3f 00 00
	jr ge, .LFB93A0                                      ; FB9399  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB939B  f2 47 51 60 b8
.LFB93A0:
	ld c, (SmfPlay_LastRead:24)                                 ; FB93A0  c2 45 51 60 23
	ld (xiz-2), c                                        ; FB93A5  be fe 43
	ld (SmfPlay_LastByte:24), c                                 ; FB93A8  f2 56 50 60 43
	ld (xiz-4), hl                                       ; FB93AD  be fc 53
	ld bc, (xiz-4)                                       ; FB93B0  9e fc 21
	extz XBC                                             ; FB93B3  e9 12
	ld a, (xiz-2)                                        ; FB93B5  8e fe 21
	ld (XBC+Smf_EventStatus),A                                    ; FB93B8  f3 e5 d0 10 41
	ld HL,BC                                             ; FB93BD  d9 8b
	inc 1,HL                                             ; FB93BF  db 61
	inc 1,DE                                             ; FB93C1  da 61
	cp DE,IX                                             ; FB93C3  dc f2
	jr c, .LFB9388                                       ; FB93C5  67 c1
.LFB93C7:
	calr SmfPlay_SendChannelEvent                                      ; FB93C7  1e 0f 02
	popw ix                                              ; FB93CA  4c
	popw de                                              ; FB93CB  4a
	popw hl                                              ; FB93CC  4b
	unlk XIZ                                             ; FB93CD  ee 0d
	ret                                                  ; FB93CF  0e
; SmfPlay_ReadVlqBytes: reads bytes (MidiFileStream_GetByte) into Smf_VlqBytes until one has bit 7 clear; A = the count; a negative
;   read (end of stream) sets (0x605147) bit 0.
SmfPlay_ReadVlqBytes:
	pushw hl                                             ; FB93D0  2b
	push XDE                                             ; FB93D1  3a
	push XIX                                             ; FB93D2  3c
	lda xix, (SmfPlay_LastRead:24)                               ; FB93D3  f2 45 51 60 34
	ld h, 0x01:opc                                          ; FB93D8  26 01
.LFB93DA:
	call T_MidiFileStream_GetByte                                        ; FB93DA  1d 1c 26 f4
	ld DE,WA                                             ; FB93DE  d8 8a
	ld (XIX),WA                                          ; FB93E0  b4 50
	cp de, 0x00:i3                                         ; FB93E2  da d8
	jr lt, .LFB9402                                      ; FB93E4  61 1c
	ld C,H                                               ; FB93E6  ce 8b
	extz BC                                              ; FB93E8  d9 12
	ld DE,BC                                             ; FB93EA  d9 8a
	dec 1,DE                                             ; FB93EC  da 69
	ld BC,(XIX)                                          ; FB93EE  94 21
	ld L,C                                               ; FB93F0  cb 8f
	extz XDE                                             ; FB93F2  ea 12
	ld (XDE+Smf_VlqBytes),C                                    ; FB93F4  f3 e9 93 11 43
	and C,0x80                                           ; FB93F9  cb cc 80
	jr z, .LFB9402                                       ; FB93FC  66 04
	inc 1,H                                              ; FB93FE  ce 61
	jr .LFB93DA                                          ; FB9400  68 d8
.LFB9402:
	ld BC,(XIX)                                          ; FB9402  94 21
	cp bc, 0x00:i3                                         ; FB9404  d9 d8
	jr ge, .LFB940D                                      ; FB9406  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB9408  f2 47 51 60 b8
.LFB940D:
	ld A,H                                               ; FB940D  ce 89
	pop XIX                                              ; FB940F  5c
	pop XDE                                              ; FB9410  5a
	popw hl                                              ; FB9411  4b
	ret                                                  ; FB9412  0e
; SmfPlay_ReadDeltaTime: (0x60505F) = 0, SmfPlay_ReadVlqBytes, then the decoder for 1 / 2 / 3 bytes.
SmfPlay_ReadDeltaTime:
	sub XBC,XBC                                          ; FB9413  e9 a1
	ld (SmfPlay_VlqValue:24), xbc                               ; FB9415  f2 5f 50 60 61
	calr SmfPlay_ReadVlqBytes                                      ; FB941A  1e b3 ff
	extz WA                                              ; FB941D  d8 12
	cp wa, 0x01:i3                                         ; FB941F  d8 d9
	jr z, .LFB9429                                       ; FB9421  66 06
	cp wa, 0x02:i3                                         ; FB9423  d8 da
	jr z, .LFB942E                                       ; FB9425  66 07
	jr .LFB9433                                          ; FB9427  68 0a
.LFB9429:
	calr SmfPlay_DecodeVlq1                                      ; FB9429  1e 0b 00
	jr .LFB9436                                          ; FB942C  68 08
.LFB942E:
	calr SmfPlay_DecodeVlq2                                      ; FB942E  1e 17 00
	jr .LFB9436                                          ; FB9431  68 03
.LFB9433:
	calr SmfPlay_DecodeVlq3                                      ; FB9433  1e 5a 00
.LFB9436:
	ret                                                  ; FB9436  0e
; SmfPlay_DecodeVlq1: (0x60505F) = Smf_VlqBytes[0] & 0x7F.
SmfPlay_DecodeVlq1:
	ld c, (Smf_VlqBytes:16)                                   ; FB9437  c1 93 11 23
	res 0x07,C                                           ; FB943B  cb 30 07
	extz BC                                              ; FB943E  d9 12
	extz XBC                                             ; FB9440  e9 12
	ld (SmfPlay_VlqValue:24), xbc                               ; FB9442  f2 5f 50 60 61
	ret                                                  ; FB9447  0e
; SmfPlay_DecodeVlq2: (0x60505F) = the 14-bit value of two VLQ bytes.
SmfPlay_DecodeVlq2:
	pushw hl                                             ; FB9448  2b
	pushw de                                             ; FB9449  2a
	push XIX                                             ; FB944A  3c
	ld h, (Smf_VlqBytes:16)                                   ; FB944B  c1 93 11 26
	ld L,H                                               ; FB944F  ce 8f
	res 0x07,L                                           ; FB9451  cf 30 07
	ld c, (0x1194:16)                                   ; FB9454  c1 94 11 23
	ld D,C                                               ; FB9458  cb 8c
	res 0x07,D                                           ; FB945A  cc 30 07
	ld C,H                                               ; FB945D  ce 8b
	and C,0x7e                                           ; FB945F  cb cc 7e
	ld H,C                                               ; FB9462  cb 8e
	srl h, 0x01                                          ; FB9464  ce ef 01
	ld C,L                                               ; FB9467  cf 8b
	sll c, 0x07                                          ; FB9469  cb ee 07
	ld L,C                                               ; FB946C  cb 8f
	or L,D                                               ; FB946E  cc e7
	ld C,H                                               ; FB9470  ce 8b
	extz BC                                              ; FB9472  d9 12
	mul BC,0x0100                                        ; FB9474  d9 08 00 01
	ld XIX,XBC                                           ; FB9478  e9 8c
	ld (SmfPlay_VlqValue:24), xbc                               ; FB947A  f2 5f 50 60 61
	ld A,L                                               ; FB947F  cf 89
	extz WA                                              ; FB9481  d8 12
	extz XWA                                             ; FB9483  e8 12
	add XWA,XIX                                          ; FB9485  ec 80
	ld (SmfPlay_VlqValue:24), xwa                               ; FB9487  f2 5f 50 60 60
	pop XIX                                              ; FB948C  5c
	popw de                                              ; FB948D  4a
	popw hl                                              ; FB948E  4b
	ret                                                  ; FB948F  0e
; SmfPlay_DecodeVlq3: (0x60505F) = the 21-bit value of three VLQ bytes.
SmfPlay_DecodeVlq3:
	link XIZ,0xfff4                                      ; FB9490  ee 0c f4 ff
	pushw hl                                             ; FB9494  2b
	pushw de                                             ; FB9495  2a
	push XIX                                             ; FB9496  3c
	lda xix, (SmfPlay_VlqValue:24)                               ; FB9497  f2 5f 50 60 34
	ld h, (Smf_VlqBytes:16)                                   ; FB949C  c1 93 11 26
	ld L,H                                               ; FB94A0  ce 8f
	res 0x07,L                                           ; FB94A2  cf 30 07
	ld d, (0x1194:16)                                   ; FB94A5  c1 94 11 24
	ld E,D                                               ; FB94A9  cc 8d
	res 0x07,E                                           ; FB94AB  cd 30 07
	ld c, (0x1195:16)                                   ; FB94AE  c1 95 11 23
	res 0x07,C                                           ; FB94B2  cb 30 07
	ld (xiz-2), c                                        ; FB94B5  be fe 43
	ld A,H                                               ; FB94B8  ce 89
	and A,0x7e                                           ; FB94BA  c9 cc 7e
	ld H,A                                               ; FB94BD  c9 8e
	srl h, 0x01                                          ; FB94BF  ce ef 01
	ld B,L                                               ; FB94C2  cf 8a
	sll b, 0x07                                          ; FB94C4  ca ee 07
	ld (xiz-4), b                                        ; FB94C7  be fc 42
	ld A,D                                               ; FB94CA  cc 89
	and A,0x7e                                           ; FB94CC  c9 cc 7e
	ld L,A                                               ; FB94CF  c9 8f
	srl l, 0x01                                          ; FB94D1  cf ef 01
	ld D,E                                               ; FB94D4  cd 8c
	sll d, 0x07                                          ; FB94D6  cc ee 07
	ld E,B                                               ; FB94D9  ca 8d
; (sub_FB94DB removed 2026-10-04: no code names it and the line above falls through into it -- part of SmfPlay_DecodeVlq3;
;  notes/prom_a_stray_label_removal.py)
	or E,L                                               ; FB94DB  cf e5
	ld L,C                                               ; FB94DD  cb 8f
	or L,D                                               ; FB94DF  cc e7
	ld C,H                                               ; FB94E1  ce 8b
	extz BC                                              ; FB94E3  d9 12
	extz XBC                                             ; FB94E5  e9 12
	sll xbc, 16                                        ; FB94E7  e9 ee 00
	ld (xiz-8), xbc                                      ; FB94EA  be f8 61
	ld (XIX),XBC                                         ; FB94ED  b4 61
	ld C,E                                               ; FB94EF  cd 8b
	extz BC                                              ; FB94F1  d9 12
	mul BC,0x0100                                        ; FB94F3  d9 08 00 01
	add	xbc, (xiz-8)                                 ; FB94F7  ae f8 81
	ld (xiz-12), xbc                                     ; FB94FA  be f4 61
	ld (XIX),XBC                                         ; FB94FD  b4 61
	ld C,L                                               ; FB94FF  cf 8b
	extz BC                                              ; FB9501  d9 12
	extz XBC                                             ; FB9503  e9 12
	add	xbc, (xiz-12)                                ; FB9505  ae f4 81
	ld (XIX),XBC                                         ; FB9508  b4 61
	pop XIX                                              ; FB950A  5c
	popw de                                              ; FB950B  4a
	popw hl                                              ; FB950C  4b
	unlk XIZ                                             ; FB950D  ee 0d
	ret                                                  ; FB950F  0e
; SmfPlay_AdvanceEventTime: (0x605044) += (0x60505F): the next event's time.
SmfPlay_AdvanceEventTime:
	ld xbc, (SmfPlay_VlqValue:24)                               ; FB9510  e2 5f 50 60 21
	add (SmfPlay_NextEventTime:24), xbc                              ; FB9515  e2 44 50 60 89
	ret                                                  ; FB951A  0e
; SmfPlay_ClearVlqBytes: Smf_VlqBytes[0..5] = 0.
SmfPlay_ClearVlqBytes:
	pushw hl                                             ; FB951B  2b
	ld h, 0x00:opc                                          ; FB951C  26 00
.LFB951E:
	ld C,H                                               ; FB951E  ce 8b
	extz BC                                              ; FB9520  d9 12
	extz XBC                                             ; FB9522  e9 12
	ld (XBC+Smf_VlqBytes),0x00                                 ; FB9524  f3 e5 93 11 00 00
	inc 1,H                                              ; FB952A  ce 61
	cp h, 0x05:i3                                          ; FB952C  ce dd
	jr ule, .LFB951E                                     ; FB952E  63 ee
	popw hl                                              ; FB9530  4b
	ret                                                  ; FB9531  0e
; SmfPlay_ReadVlqBytes_Copy: a byte-for-byte copy of SmfPlay_ReadVlqBytes, used by SmfPlay_ReadVlqValue.
SmfPlay_ReadVlqBytes_Copy:
	pushw hl                                             ; FB9532  2b
	push XDE                                             ; FB9533  3a
	push XIX                                             ; FB9534  3c
	lda xix, (SmfPlay_LastRead:24)                               ; FB9535  f2 45 51 60 34
	ld h, 0x01:opc                                          ; FB953A  26 01
.LFB953C:
	call T_MidiFileStream_GetByte                                        ; FB953C  1d 1c 26 f4
	ld DE,WA                                             ; FB9540  d8 8a
	ld (XIX),WA                                          ; FB9542  b4 50
	cp de, 0x00:i3                                         ; FB9544  da d8
	jr lt, .LFB9564                                      ; FB9546  61 1c
	ld C,H                                               ; FB9548  ce 8b
	extz BC                                              ; FB954A  d9 12
	ld DE,BC                                             ; FB954C  d9 8a
	dec 1,DE                                             ; FB954E  da 69
	ld BC,(XIX)                                          ; FB9550  94 21
	ld L,C                                               ; FB9552  cb 8f
	extz XDE                                             ; FB9554  ea 12
	ld (XDE+Smf_VlqBytes),C                                    ; FB9556  f3 e9 93 11 43
	and C,0x80                                           ; FB955B  cb cc 80
	jr z, .LFB9564                                       ; FB955E  66 04
	inc 1,H                                              ; FB9560  ce 61
	jr .LFB953C                                          ; FB9562  68 d8
.LFB9564:
	ld BC,(XIX)                                          ; FB9564  94 21
	cp bc, 0x00:i3                                         ; FB9566  d9 d8
	jr ge, .LFB956F                                      ; FB9568  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB956A  f2 47 51 60 b8
.LFB956F:
	ld A,H                                               ; FB956F  ce 89
	pop XIX                                              ; FB9571  5c
	pop XDE                                              ; FB9572  5a
	popw hl                                              ; FB9573  4b
	ret                                                  ; FB9574  0e
; SmfPlay_ReadVlqValue: the same through SmfPlay_ReadVlqBytes_Copy -- event lengths.
SmfPlay_ReadVlqValue:
	sub XBC,XBC                                          ; FB9575  e9 a1
	ld (SmfPlay_VlqValue:24), xbc                               ; FB9577  f2 5f 50 60 61
	calr SmfPlay_ReadVlqBytes_Copy                                      ; FB957C  1e b3 ff
	extz WA                                              ; FB957F  d8 12
	cp wa, 0x01:i3                                         ; FB9581  d8 d9
	jr z, .LFB958B                                       ; FB9583  66 06
	cp wa, 0x02:i3                                         ; FB9585  d8 da
	jr z, .LFB9590                                       ; FB9587  66 07
	jr .LFB9595                                          ; FB9589  68 0a
.LFB958B:
	calr SmfPlay_DecodeVlq1                                      ; FB958B  1e a9 fe
	jr .LFB9598                                          ; FB958E  68 08
.LFB9590:
	calr SmfPlay_DecodeVlq2                                      ; FB9590  1e b5 fe
	jr .LFB9598                                          ; FB9593  68 03
.LFB9595:
	calr SmfPlay_DecodeVlq3                                      ; FB9595  1e f8 fe
.LFB9598:
	ret                                                  ; FB9598  0e
; SmfPlay_SkipBytes: reads and drops (0x60505F) bytes (the last kept in (0x605056)); (0x60505F) = 0.
SmfPlay_SkipBytes:
	pushw hl                                             ; FB9599  2b
	pushw de                                             ; FB959A  2a
	pushw ix                                             ; FB959B  2c
	ld ix, (SmfPlay_VlqValue:24)                                ; FB959C  d2 5f 50 60 24
	ldw hl, 0x00                                         ; FB95A1  33 00 00
	ld DE,IX                                             ; FB95A4  dc 8a
	dec 1,DE                                             ; FB95A6  da 69
.LFB95A8:
	cp HL,DE                                             ; FB95A8  da f3
	jr ugt, .LFB95CE                                     ; FB95AA  6b 22
	call T_MidiFileStream_GetByte                                        ; FB95AC  1d 1c 26 f4
	ld IX,WA                                             ; FB95B0  d8 8c
	ld (SmfPlay_LastRead:24), wa                                ; FB95B2  f2 45 51 60 50
	cp ix, 0x00:i3                                         ; FB95B7  dc d8
	jr ge, .LFB95C0                                      ; FB95B9  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB95BB  f2 47 51 60 b8
.LFB95C0:
	ld c, (SmfPlay_LastRead:24)                                 ; FB95C0  c2 45 51 60 23
	ld (SmfPlay_LastByte:24), c                                 ; FB95C5  f2 56 50 60 43
	inc 1,HL                                             ; FB95CA  db 61
	jr .LFB95A8                                          ; FB95CC  68 da
.LFB95CE:
	sub XBC,XBC                                          ; FB95CE  e9 a1
	ld (SmfPlay_VlqValue:24), xbc                               ; FB95D0  f2 5f 50 60 61
	popw ix                                              ; FB95D5  4c
	popw de                                              ; FB95D6  4a
	popw hl                                              ; FB95D7  4b
	ret                                                  ; FB95D8  0e
; SmfPlay_SendChannelEvent: data bytes clamped to 0x7F; the 2-byte (0xCn / 0xDn) or 3-byte message at Smf_EventStatus put on the MIDI
;   input ring (T_MidiInARing_PutBlock) with interrupts held.
SmfPlay_SendChannelEvent:
	pushw hl                                             ; FB95D9  2b
	push XIX                                             ; FB95DA  3c
	lda xix, (Smf_EventStatus:16)                                ; FB95DB  f1 d0 10 34
	extz XIX                                             ; FB95DF  ec 12
	ld C,(XIX+0x01)                                      ; FB95E1  8c 01 23
	cp C,0x7f                                            ; FB95E4  cb cf 7f
	jr ule, .LFB95EF                                     ; FB95E7  63 06
	extz XIX                                             ; FB95E9  ec 12
	ld (XIX+0x01),0x7f                                   ; FB95EB  bc 01 00 7f
.LFB95EF:
	extz XIX                                             ; FB95EF  ec 12
	ld C,(XIX+0x02)                                      ; FB95F1  8c 02 23
	cp C,0x7f                                            ; FB95F4  cb cf 7f
	jr ule, .LFB95FF                                     ; FB95F7  63 06
	extz XIX                                             ; FB95F9  ec 12
	ld (XIX+0x02),0x7f                                   ; FB95FB  bc 02 00 7f
.LFB95FF:
	ld C,(XIX)                                           ; FB95FF  84 23
	and C,0xf0                                           ; FB9601  cb cc f0
	extz BC                                              ; FB9604  d9 12
	cp BC,0x00c0                                         ; FB9606  d9 cf c0 00
	jr z, .LFB9614                                       ; FB960A  66 08
	cp BC,0x00d0                                         ; FB960C  d9 cf d0 00
	jr z, .LFB9614                                       ; FB9610  66 02
	jr .LFB9619                                          ; FB9612  68 05
.LFB9614:
	ldw hl, 0x02                                         ; FB9614  33 02 00
	jr .LFB961C                                          ; FB9617  68 03
.LFB9619:
	ldw hl, 0x03                                         ; FB9619  33 03 00
.LFB961C:
	ld (0x605140:24), xix                               ; FB961C  f2 40 51 60 64
	ei 0x06                                              ; FB9621  06 06
	ld xbc, (0x605140:24)                               ; FB9623  e2 40 51 60 21
	push XBC                                             ; FB9628  39
	pushw hl                                             ; FB9629  2b
	call T_MidiInARing_PutBlock                           ; FB962A  1d b0 1d f4
	inc 6,XSP                                            ; FB962E  ef 66
	ei 0x00                                              ; FB9630  06 00
	pop XIX                                              ; FB9632  5c
	popw hl                                              ; FB9633  4b
	ret                                                  ; FB9634  0e
; SmfPlay_ReadTempoEvent: the three tempo bytes to 0x605063..0x605065, then SmfPlay_ApplyTempo_SaveAll.
SmfPlay_ReadTempoEvent:
	pushw hl                                             ; FB9635  2b
	push XIX                                             ; FB9636  3c
	lda xix, (SmfPlay_StreamFlags:24)                               ; FB9637  f2 47 51 60 34
	call T_MidiFileStream_GetByte                                        ; FB963C  1d 1c 26 f4
	ld HL,WA                                             ; FB9640  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9642  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9647  db d8
	jr ge, .LFB964E                                      ; FB9649  69 03
	or	(xix), 0x01                                  ; FB964B  84 3e 01
.LFB964E:
	ld c, (SmfPlay_LastRead:24)                                 ; FB964E  c2 45 51 60 23
	ld (SmfPlay_TempoMicros:24), c                                 ; FB9653  f2 63 50 60 43
	call T_MidiFileStream_GetByte                                        ; FB9658  1d 1c 26 f4
	ld HL,WA                                             ; FB965C  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB965E  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9663  db d8
	jr ge, .LFB966A                                      ; FB9665  69 03
	or	(xix), 0x01                                  ; FB9667  84 3e 01
.LFB966A:
	ld c, (SmfPlay_LastRead:24)                                 ; FB966A  c2 45 51 60 23
	ld (0x605064:24), c                                 ; FB966F  f2 64 50 60 43
	call T_MidiFileStream_GetByte                                        ; FB9674  1d 1c 26 f4
	ld HL,WA                                             ; FB9678  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB967A  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB967F  db d8
	jr ge, .LFB9686                                      ; FB9681  69 03
	or	(xix), 0x01                                  ; FB9683  84 3e 01
.LFB9686:
	ld c, (SmfPlay_LastRead:24)                                 ; FB9686  c2 45 51 60 23
	ld (0x605065:24), c                                 ; FB968B  f2 65 50 60 43
	call SmfPlay_ApplyTempo_SaveAll                                      ; FB9690  1d eb 90 fb
	pop XIX                                              ; FB9694  5c
	popw hl                                              ; FB9695  4b
	ret                                                  ; FB9696  0e
; ---------------------------------------------------------------------
; SmfPlay_ReadHeader -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_a SequencerMedley_MidiFileTick (`calr`) at 0xFB9EC9
;          prom_a MidiFileDirectPlay_Tick (`calr`) at 0xFBA004
;
;     0xFB96A3 loads 0xFBA169, where the ROM reads:
;        "MThdMTrk~"
;     0xFB96AB loads 0xFBA16D, where the ROM reads:
;        "MTrk~"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; SmfPlay_ReadHeader: reads four bytes and compares them with 'MThd' (MidiFile_Tables_FBA169); when they differ, 0x7C more bytes
;   are skipped before it reads on -- a 0x80-byte prefix is tolerated.
SmfPlay_ReadHeader:
	link XIZ,0xfff0                                      ; FB9697  ee 0c f0 ff
	pushw hl                                             ; FB969B  2b
	pushw de                                             ; FB969C  2a
	push XIX                                             ; FB969D  3c
	lda xix, (SmfPlay_StreamFlags:24)                               ; FB969E  f2 47 51 60 34
	ld xbc, (MidiFile_Tables_FBA169:24)                               ; FB96A3  e2 69 a1 fb 21
	ld (xiz-4), xbc                                      ; FB96A8  be fc 61
	ld xwa, (MidiFile_Tables_FBA169+4:24)                               ; FB96AB  e2 6d a1 fb 20
	ld (xiz-8), xwa                                      ; FB96B0  be f8 60
	ld h, 0x00:opc                                          ; FB96B3  26 00
.LFB96B5:
	call T_MidiFileStream_GetByte                                        ; FB96B5  1d 1c 26 f4
	ld DE,WA                                             ; FB96B9  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB96BB  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB96C0  da d8
	jr ge, .LFB96C7                                      ; FB96C2  69 03
	or	(xix), 0x01                                  ; FB96C4  84 3e 01
.LFB96C7:
	ld l, (SmfPlay_LastRead:24)                                 ; FB96C7  c2 45 51 60 27
	ld (SmfPlay_LastByte:24), l                                 ; FB96CC  f2 56 50 60 47
	ld C,H                                               ; FB96D1  ce 8b
	extz BC                                              ; FB96D3  d9 12
	extz XBC                                             ; FB96D5  e9 12
	add XBC,XIZ                                          ; FB96D7  ee 81
	ld (xbc-12), l                                       ; FB96D9  b9 f4 47
	inc 1,H                                              ; FB96DC  ce 61
	cp h, 0x03:i3                                          ; FB96DE  ce db
	jr ule, .LFB96B5                                     ; FB96E0  63 d3
	ldw hl, 0x00                                         ; FB96E2  33 00 00
.LFB96E5:
	ld BC,HL                                             ; FB96E5  db 89
	extz XBC                                             ; FB96E7  e9 12
	ld (xiz-16), xbc                                     ; FB96E9  be f0 61
	add XBC,XIZ                                          ; FB96EC  ee 81
	ld d, (xbc-4)                                        ; FB96EE  89 fc 24
	ld xbc, (xiz-16)                                     ; FB96F1  ae f0 21
	add XBC,XIZ                                          ; FB96F4  ee 81
	ld a, (xbc-12)                                       ; FB96F6  89 f4 21
	cp A,D                                               ; FB96F9  cc f1
	jr nz, .LFB9703                                      ; FB96FB  6e 06
	inc 1,HL                                             ; FB96FD  db 61
	cp hl, 0x03:i3                                         ; FB96FF  db db
	jr ule, .LFB96E5                                     ; FB9701  63 e2
.LFB9703:
	cp hl, 0x04:i3                                         ; FB9703  db dc
	jrl z, .LFB9781                                      ; FB9705  76 79 00
	ld h, 0x7c:opc                                          ; FB9708  26 7c
.LFB970A:
	call T_MidiFileStream_GetByte                                        ; FB970A  1d 1c 26 f4
	ld DE,WA                                             ; FB970E  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB9710  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB9715  da d8
	jr ge, .LFB971C                                      ; FB9717  69 03
	or	(xix), 0x01                                  ; FB9719  84 3e 01
.LFB971C:
	ld c, (SmfPlay_LastRead:24)                                 ; FB971C  c2 45 51 60 23
	ld (SmfPlay_LastByte:24), c                                 ; FB9721  f2 56 50 60 43
	dec 1,H                                              ; FB9726  ce 69
	cp h, 0x00:i3                                          ; FB9728  ce d8
	jr nz, .LFB970A                                      ; FB972A  6e de
	ld h, 0x00:opc                                          ; FB972C  26 00
.LFB972E:
	call T_MidiFileStream_GetByte                                        ; FB972E  1d 1c 26 f4
	ld DE,WA                                             ; FB9732  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB9734  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB9739  da d8
	jr ge, .LFB9740                                      ; FB973B  69 03
	or	(xix), 0x01                                  ; FB973D  84 3e 01
.LFB9740:
	ld l, (SmfPlay_LastRead:24)                                 ; FB9740  c2 45 51 60 27
	ld (SmfPlay_LastByte:24), l                                 ; FB9745  f2 56 50 60 47
	ld C,H                                               ; FB974A  ce 8b
	extz BC                                              ; FB974C  d9 12
	extz XBC                                             ; FB974E  e9 12
	add XBC,XIZ                                          ; FB9750  ee 81
	ld (xbc-12), l                                       ; FB9752  b9 f4 47
	inc 1,H                                              ; FB9755  ce 61
	cp h, 0x03:i3                                          ; FB9757  ce db
	jr ule, .LFB972E                                     ; FB9759  63 d3
	ldw hl, 0x00                                         ; FB975B  33 00 00
.LFB975E:
	ld BC,HL                                             ; FB975E  db 89
	extz XBC                                             ; FB9760  e9 12
	ld (xiz-16), xbc                                     ; FB9762  be f0 61
	add XBC,XIZ                                          ; FB9765  ee 81
	ld d, (xbc-4)                                        ; FB9767  89 fc 24
	ld xbc, (xiz-16)                                     ; FB976A  ae f0 21
	add XBC,XIZ                                          ; FB976D  ee 81
	ld a, (xbc-12)                                       ; FB976F  89 f4 21
	cp A,D                                               ; FB9772  cc f1
	jr nz, .LFB977C                                      ; FB9774  6e 06
	inc 1,HL                                             ; FB9776  db 61
	cp hl, 0x03:i3                                         ; FB9778  db db
	jr ule, .LFB975E                                     ; FB977A  63 e2
.LFB977C:
	cp hl, 0x04:i3                                         ; FB977C  db dc
	jrl nz, .LFB9915                                     ; FB977E  7e 94 01
.LFB9781:
	calr SmfPlay_StartPlayback                                      ; FB9781  1e bb 06
	ld h, 0x05:opc                                          ; FB9784  26 05
.LFB9786:
	call T_MidiFileStream_GetByte                                        ; FB9786  1d 1c 26 f4
	ld DE,WA                                             ; FB978A  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB978C  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB9791  da d8
	jr ge, .LFB9798                                      ; FB9793  69 03
	or	(xix), 0x01                                  ; FB9795  84 3e 01
.LFB9798:
	ld c, (SmfPlay_LastRead:24)                                 ; FB9798  c2 45 51 60 23
	ld (SmfPlay_LastByte:24), c                                 ; FB979D  f2 56 50 60 43
	dec 1,H                                              ; FB97A2  ce 69
	cp h, 0x00:i3                                          ; FB97A4  ce d8
	jr nz, .LFB9786                                      ; FB97A6  6e de
	call T_MidiFileStream_GetByte                                        ; FB97A8  1d 1c 26 f4
	ld HL,WA                                             ; FB97AC  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB97AE  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB97B3  db d8
	jr ge, .LFB97BA                                      ; FB97B5  69 03
	or	(xix), 0x01                                  ; FB97B7  84 3e 01
.LFB97BA:
	ld h, (SmfPlay_LastRead:24)                                 ; FB97BA  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB97BF  f2 56 50 60 46
	ld (0x60505a:24), h                                 ; FB97C4  f2 5a 50 60 46
	cp h, 0x00:i3                                          ; FB97C9  ce d8
	jrl nz, .LFB9915                                     ; FB97CB  7e 47 01
	call T_MidiFileStream_GetByte                                        ; FB97CE  1d 1c 26 f4
	ld HL,WA                                             ; FB97D2  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB97D4  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB97D9  db d8
	jr ge, .LFB97E0                                      ; FB97DB  69 03
	or	(xix), 0x01                                  ; FB97DD  84 3e 01
.LFB97E0:
	ld h, (SmfPlay_LastRead:24)                                 ; FB97E0  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB97E5  f2 56 50 60 46
	ld (0x605059:24), h                                 ; FB97EA  f2 59 50 60 46
	call T_MidiFileStream_GetByte                                        ; FB97EF  1d 1c 26 f4
	ld HL,WA                                             ; FB97F3  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB97F5  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB97FA  db d8
	jr ge, .LFB9801                                      ; FB97FC  69 03
	or	(xix), 0x01                                  ; FB97FE  84 3e 01
.LFB9801:
	ld h, (SmfPlay_LastRead:24)                                 ; FB9801  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB9806  f2 56 50 60 46
	ld (0x605058:24), h                                 ; FB980B  f2 58 50 60 46
	call T_MidiFileStream_GetByte                                        ; FB9810  1d 1c 26 f4
	ld HL,WA                                             ; FB9814  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9816  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB981B  db d8
	jr ge, .LFB9822                                      ; FB981D  69 03
	or	(xix), 0x01                                  ; FB981F  84 3e 01
.LFB9822:
	ld h, (SmfPlay_LastRead:24)                                 ; FB9822  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB9827  f2 56 50 60 46
	ld (0x60505d:24), h                                 ; FB982C  f2 5d 50 60 46
	ld C,H                                               ; FB9831  ce 8b
	extz BC                                              ; FB9833  d9 12
	sll bc, 0x08                                         ; FB9835  d9 ee 08
	ld (SmfPlay_Division:24), bc                                ; FB9838  f2 66 50 60 51
	call T_MidiFileStream_GetByte                                        ; FB983D  1d 1c 26 f4
	ld HL,WA                                             ; FB9841  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9843  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9848  db d8
	jr ge, .LFB984F                                      ; FB984A  69 03
	or	(xix), 0x01                                  ; FB984C  84 3e 01
.LFB984F:
	ld h, (SmfPlay_LastRead:24)                                 ; FB984F  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB9854  f2 56 50 60 46
	ld (0x60505c:24), h                                 ; FB9859  f2 5c 50 60 46
	ld C,H                                               ; FB985E  ce 8b
	extz BC                                              ; FB9860  d9 12
	add (SmfPlay_Division:24), bc                            ; FB9862  d2 66 50 60 89
	ld bc, (SmfPlay_Division:24)                                ; FB9867  d2 66 50 60 21
	extz XBC                                             ; FB986C  e9 12
	div BC,0x0060                                        ; FB986E  d9 0a 60 00
	extz XBC                                             ; FB9872  e9 12
	ld (xiz-16), xbc                                     ; FB9874  be f0 61
	ld (0x60506a:24), xbc                               ; FB9877  f2 6a 50 60 61
	ld xiy, (xiz-16)                                     ; FB987C  ae f0 25
	srl xiy, 0x01                                        ; FB987F  ed ef 01
	ld (0x60506e:24), xiy                               ; FB9882  f2 6e 50 60 65
	calr MidiFilePlay_ClearPosition                                      ; FB9887  1e 91 00
	ld h, 0x00:opc                                          ; FB988A  26 00
.LFB988C:
	call T_MidiFileStream_GetByte                                        ; FB988C  1d 1c 26 f4
	ld DE,WA                                             ; FB9890  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB9892  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB9897  da d8
	jr ge, .LFB989E                                      ; FB9899  69 03
	or	(xix), 0x01                                  ; FB989B  84 3e 01
.LFB989E:
	ld l, (SmfPlay_LastRead:24)                                 ; FB989E  c2 45 51 60 27
	ld (SmfPlay_LastByte:24), l                                 ; FB98A3  f2 56 50 60 47
	ld C,H                                               ; FB98A8  ce 8b
	extz BC                                              ; FB98AA  d9 12
	extz XBC                                             ; FB98AC  e9 12
	add XBC,XIZ                                          ; FB98AE  ee 81
	ld (xbc-12), l                                       ; FB98B0  b9 f4 47
	inc 1,H                                              ; FB98B3  ce 61
	cp h, 0x03:i3                                          ; FB98B5  ce db
	jr ule, .LFB988C                                     ; FB98B7  63 d3
	ldw hl, 0x00                                         ; FB98B9  33 00 00
.LFB98BC:
	ld BC,HL                                             ; FB98BC  db 89
	extz XBC                                             ; FB98BE  e9 12
	ld (xiz-16), xbc                                     ; FB98C0  be f0 61
	add XBC,XIZ                                          ; FB98C3  ee 81
	ld d, (xbc-8)                                        ; FB98C5  89 f8 24
	ld xbc, (xiz-16)                                     ; FB98C8  ae f0 21
	add XBC,XIZ                                          ; FB98CB  ee 81
	ld a, (xbc-12)                                       ; FB98CD  89 f4 21
	cp A,D                                               ; FB98D0  cc f1
	jr nz, .LFB98DA                                      ; FB98D2  6e 06
	inc 1,HL                                             ; FB98D4  db 61
	cp hl, 0x03:i3                                         ; FB98D6  db db
	jr ule, .LFB98BC                                     ; FB98D8  63 e2
.LFB98DA:
	cp hl, 0x04:i3                                         ; FB98DA  db dc
	jr nz, .LFB9915                                      ; FB98DC  6e 37
	ld h, 0x04:opc                                          ; FB98DE  26 04
.LFB98E0:
	call T_MidiFileStream_GetByte                                        ; FB98E0  1d 1c 26 f4
	ld DE,WA                                             ; FB98E4  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB98E6  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB98EB  da d8
	jr ge, .LFB98F2                                      ; FB98ED  69 03
	or	(xix), 0x01                                  ; FB98EF  84 3e 01
.LFB98F2:
	ld c, (SmfPlay_LastRead:24)                                 ; FB98F2  c2 45 51 60 23
	ld (SmfPlay_LastByte:24), c                                 ; FB98F7  f2 56 50 60 43
	dec 1,H                                              ; FB98FC  ce 69
	cp h, 0x00:i3                                          ; FB98FE  ce d8
	jr nz, .LFB98E0                                      ; FB9900  6e de
	ld (0x10cb:16), 0x00                                 ; FB9902  f1 cb 10 00 00
	calr SmfPlay_ClearEventTimes                                      ; FB9907  1e 5f 05
	set	0, (0x60505e:24)                             ; FB990A  f2 5e 50 60 b8
	calr SmfPlay_ReadDeltaTime                                      ; FB990F  1e 01 fb
	calr SmfPlay_AdvanceEventTime                                      ; FB9912  1e fb fb
.LFB9915:
	pop XIX                                              ; FB9915  5c
	popw de                                              ; FB9916  4a
	popw hl                                              ; FB9917  4b
	unlk XIZ                                             ; FB9918  ee 0d
	ret                                                  ; FB991A  0e
; MidiFilePlay_ClearPosition: (0x605040) = 0: the 32-bit song position the ticks build as beat * 96 + tick.
MidiFilePlay_ClearPosition:
	sub XBC,XBC                                          ; FB991B  e9 a1
	ld (0x605040:24), xbc                               ; FB991D  f2 40 50 60 61
	ret                                                  ; FB9922  0e
; SmfPlay_HandleMetaEvent: meta type: 0x2F -> its length byte, (0x10CB) = 0xFF, SmfPlay_StopAtEndOfTrack; 0x51 -> its length byte,
;   SmfPlay_ReadTempoEvent; anything else skipped by its VLQ length.
SmfPlay_HandleMetaEvent:
	pushw hl                                             ; FB9923  2b
	push XIX                                             ; FB9924  3c
	lda xix, (SmfPlay_StreamFlags:24)                               ; FB9925  f2 47 51 60 34
	call T_MidiFileStream_GetByte                                        ; FB992A  1d 1c 26 f4
	ld HL,WA                                             ; FB992E  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9930  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9935  db d8
	jr ge, .LFB993C                                      ; FB9937  69 03
	or	(xix), 0x01                                  ; FB9939  84 3e 01
.LFB993C:
	ld h, (SmfPlay_LastRead:24)                                 ; FB993C  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB9941  f2 56 50 60 46
	ld C,H                                               ; FB9946  ce 8b
	extz BC                                              ; FB9948  d9 12
	cp BC,0x002f                                         ; FB994A  d9 cf 2f 00
	jr z, .LFB9958                                       ; FB994E  66 08
	cp BC,0x0051                                         ; FB9950  d9 cf 51 00
	jr z, .LFB997E                                       ; FB9954  66 28
	jr .LFB999F                                          ; FB9956  68 47
.LFB9958:
	call T_MidiFileStream_GetByte                                        ; FB9958  1d 1c 26 f4
	ld HL,WA                                             ; FB995C  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB995E  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9963  db d8
	jr ge, .LFB996A                                      ; FB9965  69 03
	or	(xix), 0x01                                  ; FB9967  84 3e 01
.LFB996A:
	ld c, (SmfPlay_LastRead:24)                                 ; FB996A  c2 45 51 60 23
	ld (SmfPlay_LastByte:24), c                                 ; FB996F  f2 56 50 60 43
	ld (0x10cb:16), 0xff                                 ; FB9974  f1 cb 10 00 ff
	calr SmfPlay_StopAtEndOfTrack                                      ; FB9979  1e fa f7
	jr .LFB99A8                                          ; FB997C  68 2a
.LFB997E:
	call T_MidiFileStream_GetByte                                        ; FB997E  1d 1c 26 f4
	ld HL,WA                                             ; FB9982  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9984  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9989  db d8
	jr ge, .LFB9990                                      ; FB998B  69 03
	or	(xix), 0x01                                  ; FB998D  84 3e 01
.LFB9990:
	ld c, (SmfPlay_LastRead:24)                                 ; FB9990  c2 45 51 60 23
	ld (SmfPlay_LastByte:24), c                                 ; FB9995  f2 56 50 60 43
	calr SmfPlay_ReadTempoEvent                                      ; FB999A  1e 98 fc
	jr .LFB99A8                                          ; FB999D  68 09
.LFB999F:
	calr SmfPlay_ClearVlqBytes                                      ; FB999F  1e 79 fb
	calr SmfPlay_ReadVlqValue                                      ; FB99A2  1e d0 fb
	calr SmfPlay_SkipBytes                                      ; FB99A5  1e f1 fb
.LFB99A8:
	pop XIX                                              ; FB99A8  5c
	popw hl                                              ; FB99A9  4b
	ret                                                  ; FB99AA  0e
; SmfPlay_ForwardGmSystemOn: unless (0x605053) already matches the mode (0x7F4D) bit 2 implies: waits for the MIDI SysEx receiver to be idle
;   and puts the 6-byte F0 7E 7F 09 .. F7 on Ring601646.
SmfPlay_ForwardGmSystemOn:
	pushw hl                                             ; FB99AB  2b
	ldw bc, 0x7f4a                                       ; FB99AC  31 4a 7f
	extz XBC                                             ; FB99AF  e9 12
	ld A,(XBC+0x03)                                      ; FB99B1  89 03 21
	and A,0x04                                           ; FB99B4  c9 cc 04
	jr nz, .LFB99BE                                      ; FB99B7  6e 05
	ldw hl, 0x02                                         ; FB99B9  33 02 00
	jr .LFB99C1                                          ; FB99BC  68 03
.LFB99BE:
	ldw hl, 0x01                                         ; FB99BE  33 01 00
.LFB99C1:
	ld c, (0x605053:24)                                 ; FB99C1  c2 53 50 60 23
	extz BC                                              ; FB99C6  d9 12
	cp HL,BC                                             ; FB99C8  d9 f3
	jr z, .LFB99F3                                       ; FB99CA  66 27
	ld	h, (MIDI_RX_SysExState:8)                                      ; FB99CC  c0 a9 26
	and H,0x01                                           ; FB99CF  ce cc 01
.LFB99D2:
	cp h, 0x00:i3                                          ; FB99D2  ce d8
	jr nz, .LFB99D2                                      ; FB99D4  6e fc
	lda xbc, (0x60504f:24)                               ; FB99D6  f2 4f 50 60 31
	ld (0x605140:24), xbc                               ; FB99DB  f2 40 51 60 61
	ei 0x06                                              ; FB99E0  06 06
	ld xbc, (0x605140:24)                               ; FB99E2  e2 40 51 60 21
	push XBC                                             ; FB99E7  39
	pushw 0x06                                           ; FB99E8  0b 06 00
	call T_Ring601646_PutBlock                           ; FB99EB  1d 40 1e f4
	inc 6,XSP                                            ; FB99EF  ef 66
	ei 0x00                                              ; FB99F1  06 00
.LFB99F3:
	popw hl                                              ; FB99F3  4b
	ret                                                  ; FB99F4  0e
; SmfPlay_HandleSysExEvent: length (0x60505F) = 5 and the body starting 7E 7F 09 (GM System On) -> SmfPlay_ForwardGmSystemOn; length 16
;   with first byte 0x50 -> F0 + the 16 bytes to Ring601646; other lengths skipped.
SmfPlay_HandleSysExEvent:
	link XIZ,0xfff9                                      ; FB99F5  ee 0c f9 ff
	pushw hl                                             ; FB99F9  2b
	pushw de                                             ; FB99FA  2a
	push XIX                                             ; FB99FB  3c
	ldw bc, 0x03                                         ; FB99FC  31 03 00
	lda xiy, (MidiFile_Tables_FBA169+0x8:24)             ; FB99FF  f2 71 a1 fb 35
	lda xix, (xiz-3)                                     ; FB9A04  be fd 34
	ldir85                                               ; FB9A07  85 11
	ld hl, (SmfPlay_VlqValue:24)                                ; FB9A09  d2 5f 50 60 23
	ld (0x605149:24), hl                                ; FB9A0E  f2 49 51 60 53
	cp hl, 0x05:i3                                         ; FB9A13  db dd
	jrl nz, .LFB9A96                                     ; FB9A15  7e 7e 00
	ldw hl, 0x00                                         ; FB9A18  33 00 00
	ld XIX,0x00000001                                    ; FB9A1B  44 01 00 00 00
.LFB9A20:
	ld bc, (0x605149:24)                                ; FB9A20  d2 49 51 60 21
	dec 1,BC                                             ; FB9A25  d9 69
	cp HL,BC                                             ; FB9A27  d9 f3
	jr ugt, .LFB9A5F                                     ; FB9A29  6b 34
	call T_MidiFileStream_GetByte                                        ; FB9A2B  1d 1c 26 f4
	ld DE,WA                                             ; FB9A2F  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB9A31  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB9A36  da d8
	jr ge, .LFB9A3F                                      ; FB9A38  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB9A3A  f2 47 51 60 b8
.LFB9A3F:
	ld d, (SmfPlay_LastRead:24)                                 ; FB9A3F  c2 45 51 60 24
	ld (SmfPlay_LastByte:24), d                                 ; FB9A44  f2 56 50 60 44
	ld (xiz-7), xix                                      ; FB9A49  be f9 64
	lda xbc, (0x60504f:24)                               ; FB9A4C  f2 4f 50 60 31
	add	xbc, (xiz-7)                                 ; FB9A51  ae f9 81
	ld (XBC),D                                           ; FB9A54  b1 44
	ld xix, (xiz-7)                                      ; FB9A56  ae f9 24
	inc 1,XIX                                            ; FB9A59  ec 61
	inc 1,HL                                             ; FB9A5B  db 61
	jr .LFB9A20                                          ; FB9A5D  68 c1
.LFB9A5F:
	ldw hl, 0x00                                         ; FB9A5F  33 00 00
	ld XIX,0x00000001                                    ; FB9A62  44 01 00 00 00
.LFB9A67:
	lda xbc, (0x60504f:24)                               ; FB9A67  f2 4f 50 60 31
	add XBC,XIX                                          ; FB9A6C  ec 81
	ld D,(XBC)                                           ; FB9A6E  81 24
	ld BC,HL                                             ; FB9A70  db 89
	extz XBC                                             ; FB9A72  e9 12
	add XBC,XIZ                                          ; FB9A74  ee 81
	ld a, (xbc-3)                                        ; FB9A76  89 fd 21
	cp D,A                                               ; FB9A79  c9 f4
	jr nz, .LFB9A85                                      ; FB9A7B  6e 08
	inc 1,XIX                                            ; FB9A7D  ec 61
	inc 1,HL                                             ; FB9A7F  db 61
	cp hl, 0x03:i3                                         ; FB9A81  db db
	jr c, .LFB9A67                                       ; FB9A83  67 e2
.LFB9A85:
	cp hl, 0x03:i3                                         ; FB9A85  db db
	jrl nz, .LFB9B2A                                     ; FB9A87  7e a0 00
	ld (0x60504f:24), 0xf0                             ; FB9A8A  f2 4f 50 60 00 f0
	calr SmfPlay_ForwardGmSystemOn                                      ; FB9A90  1e 18 ff
	jrl .LFB9B23                                         ; FB9A93  78 8d 00
.LFB9A96:
	cpw	(0x605149:24), 0x0010                        ; FB9A96  d2 49 51 60 3f 10 00
	jrl nz, .LFB9B20                                     ; FB9A9D  7e 80 00
	ldw hl, 0x00                                         ; FB9AA0  33 00 00
	ld XIX,0x00000001                                    ; FB9AA3  44 01 00 00 00
.LFB9AA8:
	ld bc, (0x605149:24)                                ; FB9AA8  d2 49 51 60 21
	dec 1,BC                                             ; FB9AAD  d9 69
	cp HL,BC                                             ; FB9AAF  d9 f3
	jr ugt, .LFB9AE7                                     ; FB9AB1  6b 34
	call T_MidiFileStream_GetByte                                        ; FB9AB3  1d 1c 26 f4
	ld DE,WA                                             ; FB9AB7  d8 8a
	ld (SmfPlay_LastRead:24), wa                                ; FB9AB9  f2 45 51 60 50
	cp de, 0x00:i3                                         ; FB9ABE  da d8
	jr ge, .LFB9AC7                                      ; FB9AC0  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB9AC2  f2 47 51 60 b8
.LFB9AC7:
	ld d, (SmfPlay_LastRead:24)                                 ; FB9AC7  c2 45 51 60 24
	ld (SmfPlay_LastByte:24), d                                 ; FB9ACC  f2 56 50 60 44
	ld (xiz-7), xix                                      ; FB9AD1  be f9 64
	lda xbc, (0x60514d:24)                               ; FB9AD4  f2 4d 51 60 31
	add	xbc, (xiz-7)                                 ; FB9AD9  ae f9 81
	ld (XBC),D                                           ; FB9ADC  b1 44
	ld xix, (xiz-7)                                      ; FB9ADE  ae f9 24
	inc 1,XIX                                            ; FB9AE1  ec 61
	inc 1,HL                                             ; FB9AE3  db 61
	jr .LFB9AA8                                          ; FB9AE5  68 c1
.LFB9AE7:
	ld (0x60514d:24), 0xf0                             ; FB9AE7  f2 4d 51 60 00 f0
	ld c, (0x60514e:24)                                 ; FB9AED  c2 4e 51 60 23
	cp C,0x50                                            ; FB9AF2  cb cf 50
	jr nz, .LFB9B23                                      ; FB9AF5  6e 2c
	ld	h, (MIDI_RX_SysExState:8)                                      ; FB9AF7  c0 a9 26
	and H,0x01                                           ; FB9AFA  ce cc 01
.LFB9AFD:
	cp h, 0x00:i3                                          ; FB9AFD  ce d8
	jr nz, .LFB9AFD                                      ; FB9AFF  6e fc
	lda xbc, (0x60514d:24)                               ; FB9B01  f2 4d 51 60 31
	ld (0x605140:24), xbc                               ; FB9B06  f2 40 51 60 61
	ei 0x06                                              ; FB9B0B  06 06
	ld xbc, (0x605140:24)                               ; FB9B0D  e2 40 51 60 21
	push XBC                                             ; FB9B12  39
	pushw 0x11                                           ; FB9B13  0b 11 00
	call T_Ring601646_PutBlock                           ; FB9B16  1d 40 1e f4
	inc 6,XSP                                            ; FB9B1A  ef 66
	ei 0x00                                              ; FB9B1C  06 00
	jr .LFB9B23                                          ; FB9B1E  68 03
.LFB9B20:
	calr SmfPlay_SkipBytes                                      ; FB9B20  1e 76 fa
.LFB9B23:
	sub XBC,XBC                                          ; FB9B23  e9 a1
	ld (SmfPlay_VlqValue:24), xbc                               ; FB9B25  f2 5f 50 60 61
.LFB9B2A:
	pop XIX                                              ; FB9B2A  5c
	popw de                                              ; FB9B2B  4a
	popw hl                                              ; FB9B2C  4b
	unlk XIZ                                             ; FB9B2D  ee 0d
	ret                                                  ; FB9B2F  0e
; SmfPlay_ReadSysExEvent: (0x605149) = 0, SmfPlay_ClearVlqBytes, SmfPlay_ReadVlqValue (the length), SmfPlay_HandleSysExEvent.
SmfPlay_ReadSysExEvent:
	ldw (0x605149:24), 0x00                             ; FB9B30  f2 49 51 60 02 00 00
	calr SmfPlay_ClearVlqBytes                                      ; FB9B37  1e e1 f9
	calr SmfPlay_ReadVlqValue                                      ; FB9B3A  1e 38 fa
	calr SmfPlay_HandleSysExEvent                                      ; FB9B3D  1e b5 fe
	ret                                                  ; FB9B40  0e
; MidiFileDirectPlay_InitOnEntry: (0x605069) bit 7 set; saves (0x60341E) in (0x605072) and clears it; (0x34BB) bit 2 cleared; (0x60505E) = 0;
;   (0x605144) = the byte at 0x7F4D; then 0xFB9089.  Called by Paint_MidiFileDirectPlay, the screen's enter.
MidiFileDirectPlay_InitOnEntry:
	set	7, (0x605069:24)                             ; FB9B41  f2 69 50 60 bf
	ld xbc, (0x60341e:24)                               ; FB9B46  e2 1e 34 60 21
	ld (0x605072:24), xbc                               ; FB9B4B  f2 72 50 60 61
	sub XWA,XWA                                          ; FB9B50  e8 a0
	ld (0x60341e:24), xwa                               ; FB9B52  f2 1e 34 60 60
	res	2, (0x34bb:16)                               ; FB9B57  f1 bb 34 b2
	ld (0x60505e:24), 0x00                             ; FB9B5B  f2 5e 50 60 00 00
	ldw bc, 0x7f4a                                       ; FB9B61  31 4a 7f
	extz XBC                                             ; FB9B64  e9 12
	ld A,(XBC+0x03)                                      ; FB9B66  89 03 21
	ld (0x605144:24), a                                 ; FB9B69  f2 44 51 60 41
	call TimedEventRing_Discard_SaveRegs_B                                      ; FB9B6E  1d 89 90 fb
	ret                                                  ; FB9B72  0e
; MidiFileDirectPlay_RestoreOnLeave: (0x605068) = 0; restores (0x60341E) from (0x605072); MidiFilePlay_Stop; (0x60505E) = 0; then 0xFB9C52 or, when
;   (0x605144) bit 2, 0xFB9BA4 (which installs the 17-byte part map from MidiFile_Tables_FBA169 into 0x603422).
;   Called by ScreenLeave_MidiFileDirectPlay.
MidiFileDirectPlay_RestoreOnLeave:
	ldw (0x605068:24), 0x00                             ; FB9B73  f2 68 50 60 02 00 00
	ld xbc, (0x605072:24)                               ; FB9B7A  e2 72 50 60 21
	ld (0x60341e:24), xbc                               ; FB9B7F  f2 1e 34 60 61
	res	2, (0x34bb:16)                               ; FB9B84  f1 bb 34 b2
	calr MidiFilePlay_Stop                                      ; FB9B88  1e 3e f6
	ld (0x60505e:24), 0x00                             ; FB9B8B  f2 5e 50 60 00 00
	ld c, (0x605144:24)                                 ; FB9B91  c2 44 51 60 23
	and C,0x04                                           ; FB9B96  cb cc 04
	jr nz, .LFB9BA0                                      ; FB9B99  6e 05
	calr MidiFilePlay_ApplyGmOffPartSetup                                      ; FB9B9B  1e b4 00
	jr .LFB9BA3                                          ; FB9B9E  68 03
.LFB9BA0:
	calr MidiFilePlay_ApplyGmOnPartSetup                                      ; FB9BA0  1e 01 00
.LFB9BA3:
	ret                                                  ; FB9BA3  0e
; MidiFilePlay_ApplyGmOnPartSetup: BStore_TrackToPart[0..16] := 0..15, 0x20; part records 0..15 +0x0D (MIDI channel)
;   := 0..8, 10..15, 9, each posted as {part, 0x0D, ch, 0x0F}; GM bit (0x7F4D) bit 2 set, (0x124C) := 1 and {0x91, 3,
;   4, 0xFF} posted -- all from MidiFile_Tables_FBA169's first half. MidiFileDirectPlay_RestoreOnLeave runs it when
;   the GM byte it saved on entry ((0x605144)) had bit 2 set; GM-off twin MidiFilePlay_ApplyGmOffPartSetup. Basis:
;   caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
MidiFilePlay_ApplyGmOnPartSetup:
	link XIZ,0xff9d                                      ; FB9BA4  ee 0c 9d ff
	pushw hl                                             ; FB9BA8  2b
	pushw de                                             ; FB9BA9  2a
	push XIX                                             ; FB9BAA  3c
	ldw bc, 0x11                                         ; FB9BAB  31 11 00
	lda xiy, (MidiFile_Tables_FBA169+0xB:24)             ; FB9BAE  f2 74 a1 fb 35
	lda xix, (xiz-17)                                    ; FB9BB3  be ef 34
	ldir85                                               ; FB9BB6  85 11
	ldw bc, 0x08                                         ; FB9BB8  31 08 00
	lda xiy, (MidiFile_Tables_FBA169+0x1C:24)            ; FB9BBB  f2 85 a1 fb 35
	lda xix, (xiz-33)                                    ; FB9BC0  be df 34
	ldirw                                                ; FB9BC3  95 11
	ldw bc, 0x20                                         ; FB9BC5  31 20 00
	lda xiy, (MidiFile_Tables_FBA169+0x2C:24)            ; FB9BC8  f2 95 a1 fb 35
	lda xix, (xiz-97)                                    ; FB9BCD  be 9f 34
	ldirw                                                ; FB9BD0  95 11
	ld d, 0x00:opc                                          ; FB9BD2  24 00
	ldw hl, 0x00                                         ; FB9BD4  33 00 00
.LFB9BD7:
	ld C,D                                               ; FB9BD7  cc 8b
	extz BC                                              ; FB9BD9  d9 12
	extz XBC                                             ; FB9BDB  e9 12
	ld XIX,XBC                                           ; FB9BDD  e9 8c
	add XBC,XIZ                                          ; FB9BDF  ee 81
	ld a, (xbc-17)                                       ; FB9BE1  89 ef 21
	lda xbc, (BStore_TrackToPart:24)                               ; FB9BE4  f2 22 34 60 31
	add XBC,XIX                                          ; FB9BE9  ec 81
	ld (XBC),A                                           ; FB9BEB  b1 41
	ld XBC,XIX                                           ; FB9BED  ec 89
	add XBC,XIZ                                          ; FB9BEF  ee 81
	ld e, (xbc-33)                                       ; FB9BF1  89 df 25
	ld (xiz-99), hl                                      ; FB9BF4  be 9d 53
	ld bc, (xiz-99)                                      ; FB9BF7  9e 9d 21
	extz XBC                                             ; FB9BFA  e9 12
	add XBC,XIZ                                          ; FB9BFC  ee 81
	ld xbc, (xbc-97)                                     ; FB9BFE  a9 9f 21
	ld (XBC),E                                           ; FB9C01  b1 45
	ld XBC,XIX                                           ; FB9C03  ec 89
	add XBC,XIZ                                          ; FB9C05  ee 81
	ld e, (xbc-33)                                       ; FB9C07  89 df 25
	pushw 0x0f                                           ; FB9C0A  0b 0f 00
	ld C,E                                               ; FB9C0D  cd 8b
	extz BC                                              ; FB9C0F  d9 12
	pushw bc                                             ; FB9C11  29
	pushw 0x0d                                           ; FB9C12  0b 0d 00
	ld C,D                                               ; FB9C15  cc 8b
	extz BC                                              ; FB9C17  d9 12
	pushw bc                                             ; FB9C19  29
	call T_EventQueue_AppendStackArgs                                        ; FB9C1A  1d 14 1b f4
	ld hl, (xiz-99)                                      ; FB9C1E  9e 9d 23
	inc 4,HL                                             ; FB9C21  db 64
	inc 1,D                                              ; FB9C23  cc 61
	inc 8,XSP                                            ; FB9C25  ef 60
	cp D,0x0f                                            ; FB9C27  cc cf 0f
	jr ule, .LFB9BD7                                     ; FB9C2A  63 ab
	ldw bc, 0x7f4a                                       ; FB9C2C  31 4a 7f
	extz XBC                                             ; FB9C2F  e9 12
	or	(xbc+3), 0x04                                ; FB9C31  89 03 3e 04
	ld (0x124c:16), 0x01                                 ; FB9C35  f1 4c 12 00 01
	pushw 0xff                                           ; FB9C3A  0b ff 00
	pushw 0x04                                           ; FB9C3D  0b 04 00
	pushw 0x03                                           ; FB9C40  0b 03 00
	pushw 0x91                                           ; FB9C43  0b 91 00
	call T_EventQueue_AppendStackArgs                                        ; FB9C46  1d 14 1b f4
	inc 8,XSP                                            ; FB9C4A  ef 60
	pop XIX                                              ; FB9C4C  5c
	popw de                                              ; FB9C4D  4a
	popw hl                                              ; FB9C4E  4b
	unlk XIZ                                             ; FB9C4F  ee 0d
	ret                                                  ; FB9C51  0e
; MidiFilePlay_ApplyGmOffPartSetup: GM-off twin of MidiFilePlay_ApplyGmOnPartSetup: BStore_TrackToPart[0..16] :=
;   0..15, 0x20; part records 0..15 +0x0D (MIDI channel) := 0..15 in order, each posted as {part, 0x0D, ch, 0x0F}; GM
;   bit (0x7F4D) bit 2 cleared, (0x124C) := 1 and {0x91, 3, new value, 0xFF} posted -- MidiFile_Tables_FBA169's second
;   half. MidiFileDirectPlay_RestoreOnLeave runs it when the saved GM byte had bit 2 clear. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
MidiFilePlay_ApplyGmOffPartSetup:
	link XIZ,0xff9d                                      ; FB9C52  ee 0c 9d ff
	push XHL                                             ; FB9C56  3b
	pushw de                                             ; FB9C57  2a
	push XIX                                             ; FB9C58  3c
	ldw bc, 0x11                                         ; FB9C59  31 11 00
	lda xiy, (MidiFile_Tables_FBA169+0x6C:24)            ; FB9C5C  f2 d5 a1 fb 35
	lda xix, (xiz-17)                                    ; FB9C61  be ef 34
	ldir85                                               ; FB9C64  85 11
	ldw bc, 0x08                                         ; FB9C66  31 08 00
	lda xiy, (MidiFile_Tables_FBA169+0x7D:24)            ; FB9C69  f2 e6 a1 fb 35
	lda xix, (xiz-33)                                    ; FB9C6E  be df 34
	ldirw                                                ; FB9C71  95 11
	ldw bc, 0x20                                         ; FB9C73  31 20 00
	lda xiy, (MidiFile_Tables_FBA169+0x8D:24)            ; FB9C76  f2 f6 a1 fb 35
	lda xix, (xiz-97)                                    ; FB9C7B  be 9f 34
	ldirw                                                ; FB9C7E  95 11
	ld d, 0x00:opc                                          ; FB9C80  24 00
	ldw hl, 0x00                                         ; FB9C82  33 00 00
.LFB9C85:
	ld C,D                                               ; FB9C85  cc 8b
	extz BC                                              ; FB9C87  d9 12
	extz XBC                                             ; FB9C89  e9 12
	ld XIX,XBC                                           ; FB9C8B  e9 8c
	add XBC,XIZ                                          ; FB9C8D  ee 81
	ld a, (xbc-17)                                       ; FB9C8F  89 ef 21
	lda xbc, (BStore_TrackToPart:24)                               ; FB9C92  f2 22 34 60 31
	add XBC,XIX                                          ; FB9C97  ec 81
	ld (XBC),A                                           ; FB9C99  b1 41
	ld XBC,XIX                                           ; FB9C9B  ec 89
	add XBC,XIZ                                          ; FB9C9D  ee 81
	ld e, (xbc-33)                                       ; FB9C9F  89 df 25
	ld (xiz-99), hl                                      ; FB9CA2  be 9d 53
	ld bc, (xiz-99)                                      ; FB9CA5  9e 9d 21
	extz XBC                                             ; FB9CA8  e9 12
	add XBC,XIZ                                          ; FB9CAA  ee 81
	ld xbc, (xbc-97)                                     ; FB9CAC  a9 9f 21
	ld (XBC),E                                           ; FB9CAF  b1 45
	ld XBC,XIX                                           ; FB9CB1  ec 89
	add XBC,XIZ                                          ; FB9CB3  ee 81
	ld e, (xbc-33)                                       ; FB9CB5  89 df 25
	pushw 0x0f                                           ; FB9CB8  0b 0f 00
	ld C,E                                               ; FB9CBB  cd 8b
	extz BC                                              ; FB9CBD  d9 12
	pushw bc                                             ; FB9CBF  29
	pushw 0x0d                                           ; FB9CC0  0b 0d 00
	ld C,D                                               ; FB9CC3  cc 8b
	extz BC                                              ; FB9CC5  d9 12
	pushw bc                                             ; FB9CC7  29
	call T_EventQueue_AppendStackArgs                                        ; FB9CC8  1d 14 1b f4
	ld hl, (xiz-99)                                      ; FB9CCC  9e 9d 23
	inc 4,HL                                             ; FB9CCF  db 64
	inc 1,D                                              ; FB9CD1  cc 61
	inc 8,XSP                                            ; FB9CD3  ef 60
	cp D,0x0f                                            ; FB9CD5  cc cf 0f
	jr ule, .LFB9C85                                     ; FB9CD8  63 ab
	ldw bc, 0x7f4a                                       ; FB9CDA  31 4a 7f
	ld HL,BC                                             ; FB9CDD  d9 8b
	inc 3,HL                                             ; FB9CDF  db 63
	extz XHL                                             ; FB9CE1  eb 12
	and (XHL),0xfb                                       ; FB9CE3  83 3c fb
	ld D,(XHL)                                           ; FB9CE6  83 24
	ld (0x124c:16), 0x01                                 ; FB9CE8  f1 4c 12 00 01
	pushw 0xff                                           ; FB9CED  0b ff 00
	ld C,D                                               ; FB9CF0  cc 8b
	extz BC                                              ; FB9CF2  d9 12
	pushw bc                                             ; FB9CF4  29
	pushw 0x03                                           ; FB9CF5  0b 03 00
	pushw 0x91                                           ; FB9CF8  0b 91 00
	call T_EventQueue_AppendStackArgs                                        ; FB9CFB  1d 14 1b f4
	inc 8,XSP                                            ; FB9CFF  ef 60
	pop XIX                                              ; FB9D01  5c
	popw de                                              ; FB9D02  4a
	pop XHL                                              ; FB9D03  5b
	unlk XIZ                                             ; FB9D04  ee 0d
	ret                                                  ; FB9D06  0e
; Medley_ReassertGmModeIfOn: If GENERAL MIDI MODE is on ((0x7F4D) bit 2): (0x124C) := 1 and posts the event {0x91, 3,
;   4, 0xFF} (GM setting = on, through T_EventQueue_AppendStackArgs), so GmMode_HandleChange re-applies GM without
;   storing the parameter image ((0x124C) bit 0). Medley_ToggleMidiFileStream calls it after T_MidiFileStream_Open
;   succeeds. Basis: caller + body + twin (MidiFilePlay_ApplyGmOnPartSetup posts the same event). (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
Medley_ReassertGmModeIfOn:
	ldw bc, 0x7f4a                                       ; FB9D07  31 4a 7f
	extz XBC                                             ; FB9D0A  e9 12
	ld A,(XBC+0x03)                                      ; FB9D0C  89 03 21
	and A,0x04                                           ; FB9D0F  c9 cc 04
	jr z, .LFB9D2B                                       ; FB9D12  66 17
	ld (0x124c:16), 0x01                                 ; FB9D14  f1 4c 12 00 01
	pushw 0xff                                           ; FB9D19  0b ff 00
	pushw 0x04                                           ; FB9D1C  0b 04 00
	pushw 0x03                                           ; FB9D1F  0b 03 00
	pushw 0x91                                           ; FB9D22  0b 91 00
	call T_EventQueue_AppendStackArgs                                        ; FB9D25  1d 14 1b f4
	inc 8,XSP                                            ; FB9D29  ef 60
.LFB9D2B:
	ret                                                  ; FB9D2B  0e
sub_FB9D2C:
	cp	(Medley_Source:16), 0x01                            ; FB9D2C  c1 0b 22 3f 01
	jr nz, .LFB9D42                                      ; FB9D31  6e 0f
	cp	(Medley_FileType:16), 0x01                            ; FB9D33  c1 35 0e 3f 01
	jr nz, .LFB9D42                                      ; FB9D38  6e 08
	calr MidiFilePlay_ApplyGmOnPartSetup                                      ; FB9D3A  1e 67 fe
	set	7, (0x605069:24)                             ; FB9D3D  f2 69 50 60 bf
.LFB9D42:
	ret                                                  ; FB9D42  0e
sub_FB9D43:
	cp	(Medley_Source:16), 0x01                            ; FB9D43  c1 0b 22 3f 01
	jr nz, .LFB9D59                                      ; FB9D48  6e 0f
	cp	(Medley_FileType:16), 0x01                            ; FB9D4A  c1 35 0e 3f 01
	jr nz, .LFB9D59                                      ; FB9D4F  6e 08
	calr MidiFilePlay_ApplyGmOffPartSetup                                      ; FB9D51  1e fe fe
	res	7, (0x605069:24)                             ; FB9D54  f2 69 50 60 b7
.LFB9D59:
	ret                                                  ; FB9D59  0e
; MidiFileDirectPlay_ApplyPlayAsGm: Applies MIDI FILE DIRECT PLAY's PLAY AS GM switch (0x2732, ON = 0xFF): ON ->
;   MidiFilePlay_ApplyGmOnPartSetup; OFF while GM mode ((0x7F4D) bit 2) is on -> MidiFilePlay_ApplyGmOffPartSetup; OFF
;   with GM off -> nothing. MidiFileDirectPlay_LcdKeyRow1 runs it after T_MidiFileStream_Open succeeds. Basis: caller
;   + body + the screen field. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
MidiFileDirectPlay_ApplyPlayAsGm:
	pushw hl                                             ; FB9D5A  2b
	ld l, (0x2732:16)                                   ; FB9D5B  c1 32 27 27
	ldw bc, 0x7f4a                                       ; FB9D5F  31 4a 7f
	extz XBC                                             ; FB9D62  e9 12
	ld A,(XBC+0x03)                                      ; FB9D64  89 03 21
	and A,0x04                                           ; FB9D67  c9 cc 04
	jr nz, .LFB9D70                                      ; FB9D6A  6e 04
	ld h, 0x00:opc                                          ; FB9D6C  26 00
	jr .LFB9D72                                          ; FB9D6E  68 02
.LFB9D70:
	ld h, 0xff:opc                                          ; FB9D70  26 ff
.LFB9D72:
	cp L,H                                               ; FB9D72  ce f7
	jr nz, .LFB9D7A                                      ; FB9D74  6e 04
	cp l, 0x00:i3                                          ; FB9D76  cf d8
	jr z, .LFB9D86                                       ; FB9D78  66 0c
.LFB9D7A:
	cp l, 0x00:i3                                          ; FB9D7A  cf d8
	jr nz, .LFB9D83                                      ; FB9D7C  6e 05
	calr MidiFilePlay_ApplyGmOffPartSetup                                      ; FB9D7E  1e d1 fe
	jr .LFB9D86                                          ; FB9D81  68 03
.LFB9D83:
	calr MidiFilePlay_ApplyGmOnPartSetup                                      ; FB9D83  1e 1e fe
.LFB9D86:
	popw hl                                              ; FB9D86  4b
	ret                                                  ; FB9D87  0e
; MidiCfg_ClearInputMode: MidiCfg_InOutMode bits 0-3 (INPUT MODE) = 0, then the parameter event (record 0x80, byte 3, value 0, changed bits
;   0x0F) through T_EventQueue_AppendStackArgs -- the same byte and nibble MidiTotalMode_EditInputMode edits.  Called
;   from MidiFileDirectPlay_LcdKeyRow1 and after a successful T_MidiFileStream_Open in Medley_ToggleMidiFileStream.  Basis: body.
MidiCfg_ClearInputMode:
	and	(MidiCfg_InOutMode:16), 0xf0                            ; FB9D88  c1 35 7f 3c f0
	pushw 0x0f                                           ; FB9D8D  0b 0f 00
	pushw 0x00                                           ; FB9D90  0b 00 00
	pushw 0x03                                           ; FB9D93  0b 03 00
	pushw 0x80                                           ; FB9D96  0b 80 00
	call T_EventQueue_AppendStackArgs                                        ; FB9D99  1d 14 1b f4
	inc 8,XSP                                            ; FB9D9D  ef 60
	ret                                                  ; FB9D9F  0e
; Medley_ToggleMidiFileStream: Medley MIDI-file play toggle: with transport B idle, saves and clears the playing-track
;   mask (0x60341E -> 0x3010) and opens Disk_FileName's stream (MidiFileStream_Open) -- failure: stream-ended flag +
;   Medley_ScheduleNextMidiFile; success: (0x60505E) bit 1, Medley_ReassertGmModeIfOn, MidiCfg_ClearInputMode. With transport B
;   running: MidiFilePlay_Stop, repaint, mask restored. Called by Medley_StartMidiFile and Medley_StopMidiFile; twin
;   of MidiFileDirectPlay_LcdKeyRow1. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
Medley_ToggleMidiFileStream:
	push XIX                                             ; FB9DA0  3c
	lda xix, (0x60505e:24)                               ; FB9DA1  f2 5e 50 60 34
	ld (SmfPlay_StreamFlags:24), 0x00                             ; FB9DA6  f2 47 51 60 00 00
	ld	c, (TransportB_State:8)                                      ; FB9DAC  c0 96 23
	and C,0x04                                           ; FB9DAF  cb cc 04
	jr nz, .LFB9DE9                                      ; FB9DB2  6e 35
	res	2, (0x34bb:16)                               ; FB9DB4  f1 bb 34 b2
	ld xbc, (0x60341e:24)                               ; FB9DB8  e2 1e 34 60 21
	ld (0x3010:16), xbc                                 ; FB9DBD  f1 10 30 61
	sub XWA,XWA                                          ; FB9DC1  e8 a0
	ld (0x60341e:24), xwa                               ; FB9DC3  f2 1e 34 60 60
	ld (XIX),0x00                                        ; FB9DC8  b4 00 00
	call T_MidiFileStream_Open                                        ; FB9DCB  1d 18 26 f4
	cp wa, 0x00:i3                                         ; FB9DCF  d8 d8
	jr ge, .LFB9DDE                                      ; FB9DD1  69 0b
	set	0, (SmfPlay_StreamFlags:24)                             ; FB9DD3  f2 47 51 60 b8
	call Medley_ScheduleNextMidiFile_SaveRegs                                      ; FB9DD8  1d 6d 90 fb
	jr .LFB9DFC                                          ; FB9DDC  68 1e
.LFB9DDE:
	or	(xix), 0x02                                  ; FB9DDE  84 3e 02
	calr Medley_ReassertGmModeIfOn                                      ; FB9DE1  1e 23 ff
	calr MidiCfg_ClearInputMode                                      ; FB9DE4  1e a1 ff
	jr .LFB9DFC                                          ; FB9DE7  68 13
.LFB9DE9:
	calr MidiFilePlay_Stop                                      ; FB9DE9  1e dd f3
	set	4, (UI_ScreenFlags:16)                               ; FB9DEC  f1 95 20 bc
	ld xbc, (0x3010:16)                                 ; FB9DF0  e1 10 30 21
	ld (0x60341e:24), xbc                               ; FB9DF4  f2 1e 34 60 61
	ld (XIX),0x00                                        ; FB9DF9  b4 00 00
.LFB9DFC:
	pop XIX                                              ; FB9DFC  5c
	ret                                                  ; FB9DFD  0e
; MidiFileDirectPlay_LcdKeyRow1: the LcdKeyRow1 action of MidiFileDirectPlay -- called only by LcdKeyRow1_MidiFileDirectPlay.
MidiFileDirectPlay_LcdKeyRow1:
	push XIX                                             ; FB9DFE  3c
	lda xix, (SmfPlay_StreamFlags:24)                               ; FB9DFF  f2 47 51 60 34
	ld (XIX),0x00                                        ; FB9E04  b4 00 00
	ld	c, (TransportB_State:8)                                      ; FB9E07  c0 96 23
	and C,0x04                                           ; FB9E0A  cb cc 04
	jr nz, .LFB9E36                                      ; FB9E0D  6e 27
	res	2, (0x34bb:16)                               ; FB9E0F  f1 bb 34 b2
	call T_MidiFileStream_Open                                        ; FB9E13  1d 18 26 f4
	cp wa, 0x00:i3                                         ; FB9E17  d8 d8
	jr ge, .LFB9E20                                      ; FB9E19  69 05
	or	(xix), 0x01                                  ; FB9E1B  84 3e 01
	jr .LFB9E3D                                          ; FB9E1E  68 1d
.LFB9E20:
	set	1, (0x60505e:24)                             ; FB9E20  f2 5e 50 60 b9
	ld (SmfPlay_Playing:24), 0x00                             ; FB9E25  f2 48 51 60 00 00
	calr MidiInQueue_InjectController0_AllChannels                                      ; FB9E2B  1e 2e f4
	calr MidiFileDirectPlay_ApplyPlayAsGm                                      ; FB9E2E  1e 29 ff
	calr MidiCfg_ClearInputMode                                      ; FB9E31  1e 54 ff
	jr .LFB9E3D                                          ; FB9E34  68 07
.LFB9E36:
	calr MidiFilePlay_Stop                                      ; FB9E36  1e 90 f3
	set	4, (UI_ScreenFlags:16)                               ; FB9E39  f1 95 20 bc
.LFB9E3D:
	pop XIX                                              ; FB9E3D  5c
	ret                                                  ; FB9E3E  0e
; SmfPlay_StartPlayback: clock reset, flags in (0x34D9) / (0x34BB) cleared, (0x605148) = 1, Transport_StartCAndB, repaint.
SmfPlay_StartPlayback:
	push XIX                                             ; FB9E3F  3c
	lda xix, (0x34d9:16)                                ; FB9E40  f1 d9 34 34
	calr SeqClock_ResetBeatAndTick                                      ; FB9E44  1e 23 f3
	and (XIX),0xfd                                       ; FB9E47  84 3c fd
	and (XIX),0xfb                                       ; FB9E4A  84 3c fb
	res	3, (0x34bb:16)                               ; FB9E4D  f1 bb 34 b3
	ld (SmfPlay_Playing:24), 0x01                             ; FB9E51  f2 48 51 60 00 01
	call Transport_StartCAndB_SaveRegs                                      ; FB9E57  1d 53 90 fb
	set	4, (UI_ScreenFlags:16)                               ; FB9E5B  f1 95 20 bc
	pop XIX                                              ; FB9E5F  5c
	ret                                                  ; FB9E60  0e
; MidiFilePlay_ClearPosition_Copy: byte-for-byte MidiFilePlay_ClearPosition.
MidiFilePlay_ClearPosition_Copy:
	sub XBC,XBC                                          ; FB9E61  e9 a1
	ld (0x605040:24), xbc                               ; FB9E63  f2 40 50 60 61
	ret                                                  ; FB9E68  0e
; SmfPlay_ClearEventTimes: (0x605044) = 0, (0x605048) = 0.
SmfPlay_ClearEventTimes:
	sub XBC,XBC                                          ; FB9E69  e9 a1
	ld (SmfPlay_NextEventTime:24), xbc                               ; FB9E6B  f2 44 50 60 61
	sub XWA,XWA                                          ; FB9E70  e8 a0
	ld (0x605048:24), xwa                               ; FB9E72  f2 48 50 60 60
	ret                                                  ; FB9E77  0e
	ret                                                  ; FB9E78  0e
; MidiFilePlay_Tick: UI_ScreenLatch 0x13 (SequencerMedley) -> SequencerMedley_MidiFileTick; 0x45 (MidiFileDirectPlay) ->
;   MidiFileDirectPlay_Tick; anything else, nothing.  Reached from the table at Data_F82000.
MidiFilePlay_Tick:
	ld bc, (UI_ScreenLatch:16)                                 ; FB9E79  d1 7a 20 21
	extz BC                                              ; FB9E7D  d9 12
	cp BC,0x0013                                         ; FB9E7F  d9 cf 13 00
	jr z, .LFB9E92                                       ; FB9E83  66 0d
	cp BC,0x0045                                         ; FB9E85  d9 cf 45 00
	jr z, .LFB9E8D                                       ; FB9E89  66 02
	jr .LFB9E95                                          ; FB9E8B  68 08
.LFB9E8D:
	calr MidiFileDirectPlay_Tick                                      ; FB9E8D  1e 51 01
	jr .LFB9E95                                          ; FB9E90  68 03
.LFB9E92:
	calr SequencerMedley_MidiFileTick                                      ; FB9E92  1e 01 00
.LFB9E95:
	ret                                                  ; FB9E95  0e
; SequencerMedley_MidiFileTick: acts only on screen 0x13 with Medley_Source 1 (FD) and Medley_FileType 1 (MIDI FILE) and (0x60505E) bit 1;
;   unless bit 0, runs 0xFB9697; a pending stop (0x605147 bit 0) -> MidiFilePlay_Stop; otherwise builds the song
;   position (0x605040) = beat (0x91) * 96 + Seq_BeatTick.
SequencerMedley_MidiFileTick:
	link XIZ,0xfff8                                      ; FB9E96  ee 0c f8 ff
	pushw hl                                             ; FB9E9A  2b
	push XIX                                             ; FB9E9B  3c
	cp	(UI_ScreenLatch:16), 0x13                            ; FB9E9C  c1 7a 20 3f 13
	jrl nz, .LFB9FDC                                     ; FB9EA1  7e 38 01
	cp	(Medley_Source:16), 0x01                            ; FB9EA4  c1 0b 22 3f 01
	jrl nz, .LFB9FDC                                     ; FB9EA9  7e 30 01
	cp	(Medley_FileType:16), 0x01                            ; FB9EAC  c1 35 0e 3f 01
	jrl nz, .LFB9FDC                                     ; FB9EB1  7e 28 01
	ld c, (0x60505e:24)                                 ; FB9EB4  c2 5e 50 60 23
	and C,0x02                                           ; FB9EB9  cb cc 02
	jrl z, .LFB9FDC                                      ; FB9EBC  76 1d 01
	ld c, (0x60505e:24)                                 ; FB9EBF  c2 5e 50 60 23
	and C,0x01                                           ; FB9EC4  cb cc 01
	jr nz, .LFB9ECC                                      ; FB9EC7  6e 03
	calr SmfPlay_ReadHeader                                      ; FB9EC9  1e cb f7
.LFB9ECC:
	ld c, (SmfPlay_StreamFlags:24)                                 ; FB9ECC  c2 47 51 60 23
	and C,0x01                                           ; FB9ED1  cb cc 01
	jr z, .LFB9EE4                                       ; FB9ED4  66 0e
	res	0, (SmfPlay_StreamFlags:24)                             ; FB9ED6  f2 47 51 60 b0
	calr MidiFilePlay_Stop                                      ; FB9EDB  1e eb f2
	call Medley_ScheduleNextMidiFile_SaveRegs                                      ; FB9EDE  1d 6d 90 fb
	jr .LFB9F03                                          ; FB9EE2  68 1f
.LFB9EE4:
	ld c, (0x60505a:24)                                 ; FB9EE4  c2 5a 50 60 23
	cp c, 0x00:i3                                          ; FB9EE9  cb d8
	jr z, .LFB9F0A                                       ; FB9EEB  66 1d
	calr MidiFilePlay_Stop                                      ; FB9EED  1e d9 f2
	call Medley_ScheduleNextMidiFile_SaveRegs                                      ; FB9EF0  1d 6d 90 fb
	ld (UI_Request:16), 0xab                                 ; FB9EF4  f1 70 20 00 ab
	ld (UI_Request_Hi:16), 0x40                                 ; FB9EF9  f1 71 20 00 40
	ld (UI_StatusCode:16), 0x3f                                 ; FB9EFE  f1 80 28 00 3f
.LFB9F03:
	set	4, (UI_ScreenFlags:16)                               ; FB9F03  f1 95 20 bc
	jrl .LFB9FDC                                         ; FB9F07  78 d2 00
.LFB9F0A:
	ei 0x06                                              ; FB9F0A  06 06
	ldw	(0x3452:16), (TransportB_Beat:8)                ; FB9F0C  d0 91 19 52 34
	ld	(0x3454:16), (Seq_BeatTick:8)                ; FB9F11  c0 93 19 54 34
	ei 0x00                                              ; FB9F16  06 00
	lda xix, (0x605040:24)                               ; FB9F18  f2 40 50 60 34
	ldw bc, 0x60                                         ; FB9F1D  31 60 00
	mul	xbc, (0x3452:16)                             ; FB9F20  d1 52 34 41
	ld (xiz-4), xbc                                      ; FB9F24  be fc 61
	ld (XIX),XBC                                         ; FB9F27  b4 61
	ld bc, (0x3454:16)                                 ; FB9F29  d1 54 34 21
	extz BC                                              ; FB9F2D  d9 12
	extz XBC                                             ; FB9F2F  e9 12
	add	xbc, (xiz-4)                                 ; FB9F31  ae fc 81
	ld (xiz-8), xbc                                      ; FB9F34  be f8 61
	ld (XIX),XBC                                         ; FB9F37  b4 61
	ld bc, (SmfPlay_Division:24)                                ; FB9F39  d2 66 50 60 21
	extz XBC                                             ; FB9F3E  e9 12
	push XBC                                             ; FB9F40  39
	pushw	(xiz-6)                                      ; FB9F41  9e fa 04
	pushw	(xiz-8)                                      ; FB9F44  9e f8 04
	call Multiply32                                      ; FB9F47  1d 0d a1 fb
	pushw 0x00                                           ; FB9F4B  0b 00 00
	pushw 0x60                                           ; FB9F4E  0b 60 00
	push XIY                                             ; FB9F51  3d
	call Divide32_Unsigned_Quotient_Copy2                                      ; FB9F52  1d 33 a1 fb
	ld (XIX),XIY                                         ; FB9F56  b4 65
.LFB9F58:
	cp	(0x10cb:16), 0xff                            ; FB9F58  c1 cb 10 3f ff
	jr nz, .LFB9F6B                                      ; FB9F5D  6e 0c
	res	0, (SmfPlay_StreamFlags:24)                             ; FB9F5F  f2 47 51 60 b0
	call Medley_ScheduleNextMidiFile_SaveRegs                                      ; FB9F64  1d 6d 90 fb
	jrl .LFB9FDC                                         ; FB9F68  78 71 00
.LFB9F6B:
	ld c, (SmfPlay_StreamFlags:24)                                 ; FB9F6B  c2 47 51 60 23
	and C,0x01                                           ; FB9F70  cb cc 01
	jr z, .LFB9F87                                       ; FB9F73  66 12
	res	0, (SmfPlay_StreamFlags:24)                             ; FB9F75  f2 47 51 60 b0
	calr MidiFilePlay_Stop                                      ; FB9F7A  1e 4c f2
	call Medley_ScheduleNextMidiFile_SaveRegs                                      ; FB9F7D  1d 6d 90 fb
	set	4, (UI_ScreenFlags:16)                               ; FB9F81  f1 95 20 bc
	jr .LFB9FDC                                          ; FB9F85  68 55
.LFB9F87:
	ld XBC,(XIX)                                         ; FB9F87  a4 21
	cp	xbc, (SmfPlay_NextEventTime:24)                           ; FB9F89  e2 44 50 60 f1
	jr c, .LFB9FDC                                       ; FB9F8E  67 4c
	call T_MidiFileStream_GetByte                                        ; FB9F90  1d 1c 26 f4
	ld HL,WA                                             ; FB9F94  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FB9F96  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FB9F9B  db d8
	jr ge, .LFB9FA4                                      ; FB9F9D  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FB9F9F  f2 47 51 60 b8
.LFB9FA4:
	ld h, (SmfPlay_LastRead:24)                                 ; FB9FA4  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FB9FA9  f2 56 50 60 46
	ld C,H                                               ; FB9FAE  ce 8b
	extz BC                                              ; FB9FB0  d9 12
	cp BC,0x00f0                                         ; FB9FB2  d9 cf f0 00
	jr z, .LFB9FCB                                       ; FB9FB6  66 13
	cp BC,0x00f7                                         ; FB9FB8  d9 cf f7 00
	jr z, .LFB9FCB                                       ; FB9FBC  66 0d
	cp BC,0x00ff                                         ; FB9FBE  d9 cf ff 00
	jr z, .LFB9FC6                                       ; FB9FC2  66 02
	jr .LFB9FD0                                          ; FB9FC4  68 0a
.LFB9FC6:
	calr SmfPlay_HandleMetaEvent                                      ; FB9FC6  1e 5a f9
	jr .LFB9FD3                                          ; FB9FC9  68 08
.LFB9FCB:
	calr SmfPlay_ReadSysExEvent                                      ; FB9FCB  1e 62 fb
	jr .LFB9FD3                                          ; FB9FCE  68 03
.LFB9FD0:
	calr SmfPlay_ReadChannelEvent                                      ; FB9FD0  1e 09 f3
.LFB9FD3:
	calr SmfPlay_ReadDeltaTime                                      ; FB9FD3  1e 3d f4
	calr SmfPlay_AdvanceEventTime                                      ; FB9FD6  1e 37 f5
	jrl .LFB9F58                                         ; FB9FD9  78 7c ff
.LFB9FDC:
	pop XIX                                              ; FB9FDC  5c
	popw hl                                              ; FB9FDD  4b
	unlk XIZ                                             ; FB9FDE  ee 0d
	ret                                                  ; FB9FE0  0e
; MidiFileDirectPlay_Tick: the same as SequencerMedley_MidiFileTick for screen 0x45 (no medley-source test).
MidiFileDirectPlay_Tick:
	link XIZ,0xfff8                                      ; FB9FE1  ee 0c f8 ff
	pushw hl                                             ; FB9FE5  2b
	push XIX                                             ; FB9FE6  3c
	cp	(UI_ScreenLatch:16), 0x45                            ; FB9FE7  c1 7a 20 3f 45
	jrl nz, .LFBA108                                     ; FB9FEC  7e 19 01
	ld c, (0x60505e:24)                                 ; FB9FEF  c2 5e 50 60 23
	and C,0x02                                           ; FB9FF4  cb cc 02
	jrl z, .LFBA108                                      ; FB9FF7  76 0e 01
	ld c, (0x60505e:24)                                 ; FB9FFA  c2 5e 50 60 23
	and C,0x01                                           ; FB9FFF  cb cc 01
	jr nz, .LFBA007                                      ; FBA002  6e 03
	calr SmfPlay_ReadHeader                                      ; FBA004  1e 90 f6
.LFBA007:
	ld c, (SmfPlay_StreamFlags:24)                                 ; FBA007  c2 47 51 60 23
	and C,0x01                                           ; FBA00C  cb cc 01
	jr z, .LFBA01C                                       ; FBA00F  66 0b
	res	0, (SmfPlay_StreamFlags:24)                             ; FBA011  f2 47 51 60 b0
	calr MidiFilePlay_Stop                                      ; FBA016  1e b0 f1
	jrl .LFBA108                                         ; FBA019  78 ec 00
.LFBA01C:
	ld c, (0x60505a:24)                                 ; FBA01C  c2 5a 50 60 23
	cp c, 0x00:i3                                          ; FBA021  cb d8
	jr z, .LFBA03A                                       ; FBA023  66 15
	calr MidiFilePlay_Stop                                      ; FBA025  1e a1 f1
	ld (UI_Request:16), 0xab                                 ; FBA028  f1 70 20 00 ab
	ld (UI_Request_Hi:16), 0x40                                 ; FBA02D  f1 71 20 00 40
	ld (UI_StatusCode:16), 0x3f                                 ; FBA032  f1 80 28 00 3f
	jrl .LFBA108                                         ; FBA037  78 ce 00
.LFBA03A:
	ei 0x06                                              ; FBA03A  06 06
	ldw	(0x3452:16), (TransportB_Beat:8)                ; FBA03C  d0 91 19 52 34
	ld	(0x3454:16), (Seq_BeatTick:8)                ; FBA041  c0 93 19 54 34
	ei 0x00                                              ; FBA046  06 00
	lda xix, (0x605040:24)                               ; FBA048  f2 40 50 60 34
	ldw bc, 0x60                                         ; FBA04D  31 60 00
	mul	xbc, (0x3452:16)                             ; FBA050  d1 52 34 41
	ld (xiz-4), xbc                                      ; FBA054  be fc 61
	ld (XIX),XBC                                         ; FBA057  b4 61
	ld bc, (0x3454:16)                                 ; FBA059  d1 54 34 21
	extz BC                                              ; FBA05D  d9 12
	extz XBC                                             ; FBA05F  e9 12
	add	xbc, (xiz-4)                                 ; FBA061  ae fc 81
	ld (xiz-8), xbc                                      ; FBA064  be f8 61
	ld (XIX),XBC                                         ; FBA067  b4 61
	ld bc, (SmfPlay_Division:24)                                ; FBA069  d2 66 50 60 21
	extz XBC                                             ; FBA06E  e9 12
	push XBC                                             ; FBA070  39
	pushw	(xiz-6)                                      ; FBA071  9e fa 04
	pushw	(xiz-8)                                      ; FBA074  9e f8 04
	call Multiply32                                      ; FBA077  1d 0d a1 fb
	pushw 0x00                                           ; FBA07B  0b 00 00
	pushw 0x60                                           ; FBA07E  0b 60 00
	push XIY                                             ; FBA081  3d
	call Divide32_Unsigned_Quotient_Copy2                                      ; FBA082  1d 33 a1 fb
	ld (XIX),XIY                                         ; FBA086  b4 65
.LFBA088:
	cp	(0x10cb:16), 0xff                            ; FBA088  c1 cb 10 3f ff
	jr nz, .LFBA097                                      ; FBA08D  6e 08
	res	0, (SmfPlay_StreamFlags:24)                             ; FBA08F  f2 47 51 60 b0
	jrl .LFBA108                                         ; FBA094  78 71 00
.LFBA097:
	ld c, (SmfPlay_StreamFlags:24)                                 ; FBA097  c2 47 51 60 23
	and C,0x01                                           ; FBA09C  cb cc 01
	jr z, .LFBA0AB                                       ; FBA09F  66 0a
	res	0, (SmfPlay_StreamFlags:24)                             ; FBA0A1  f2 47 51 60 b0
	calr MidiFilePlay_Stop                                      ; FBA0A6  1e 20 f1
	jr .LFBA108                                          ; FBA0A9  68 5d
.LFBA0AB:
	ld XBC,(XIX)                                         ; FBA0AB  a4 21
	cp	xbc, (SmfPlay_NextEventTime:24)                           ; FBA0AD  e2 44 50 60 f1
	jr nc, .LFBA0BD                                      ; FBA0B2  6f 09
	ldw (0x60514b:24), 0x00                             ; FBA0B4  f2 4b 51 60 02 00 00
	jr .LFBA108                                          ; FBA0BB  68 4b
.LFBA0BD:
	call T_MidiFileStream_GetByte                                        ; FBA0BD  1d 1c 26 f4
	ld HL,WA                                             ; FBA0C1  d8 8b
	ld (SmfPlay_LastRead:24), wa                                ; FBA0C3  f2 45 51 60 50
	cp hl, 0x00:i3                                         ; FBA0C8  db d8
	jr ge, .LFBA0D1                                      ; FBA0CA  69 05
	set	0, (SmfPlay_StreamFlags:24)                             ; FBA0CC  f2 47 51 60 b8
.LFBA0D1:
	ld h, (SmfPlay_LastRead:24)                                 ; FBA0D1  c2 45 51 60 26
	ld (SmfPlay_LastByte:24), h                                 ; FBA0D6  f2 56 50 60 46
	ld C,H                                               ; FBA0DB  ce 8b
	extz BC                                              ; FBA0DD  d9 12
	cp BC,0x00f0                                         ; FBA0DF  d9 cf f0 00
	jr z, .LFBA0F8                                       ; FBA0E3  66 13
	cp BC,0x00f7                                         ; FBA0E5  d9 cf f7 00
	jr z, .LFBA0F8                                       ; FBA0E9  66 0d
	cp BC,0x00ff                                         ; FBA0EB  d9 cf ff 00
	jr z, .LFBA0F3                                       ; FBA0EF  66 02
	jr .LFBA0FD                                          ; FBA0F1  68 0a
.LFBA0F3:
	calr SmfPlay_HandleMetaEvent                                      ; FBA0F3  1e 2d f8
	jr .LFBA100                                          ; FBA0F6  68 08
.LFBA0F8:
	calr SmfPlay_ReadSysExEvent                                      ; FBA0F8  1e 35 fa
	jr .LFBA100                                          ; FBA0FB  68 03
.LFBA0FD:
	calr SmfPlay_ReadChannelEvent                                      ; FBA0FD  1e dc f1
.LFBA100:
	calr SmfPlay_ReadDeltaTime                                      ; FBA100  1e 10 f3
	calr SmfPlay_AdvanceEventTime                                      ; FBA103  1e 0a f4
	jr .LFBA088                                          ; FBA106  68 80
.LFBA108:
	pop XIX                                              ; FBA108  5c
	popw hl                                              ; FBA109  4b
	unlk XIZ                                             ; FBA10A  ee 0d
	ret                                                  ; FBA10C  0e
; ---------------------------------------------------------------------
; Multiply32 -- 32x32 -> 32 multiply, the two low-by-high partial products
;                           shifted 16 and added, the high-by-high dropped
;
; ★ BORROWED FROM prom_c, WITH THE DIFF: prom_c 0xFCB11B carries this name
;          already and the two routines are the same 38 bytes with **0
;          differing** -- ROM_A[0xFBA10D..0xFBA132] ==
;          ROM_C[0xFCB11B..0xFCB140].  Check T1 of --twins recomputes both
;          numbers; a borrowed name with no diff behind it is exactly what
;          this tree's rules forbid.
; ★ AND IT IS THE ONLY ONE.  --twins asks the general question -- is any
;          prom_a sub_XXXXXX byte-identical, at the same label-to-label
;          extent, to a NAMED routine in prom_a or prom_c? -- and the
;          answer is one routine, this one.  The byte-identical-twin lever
;          that the round-4 brief points at is otherwise empty, because the
;          two images do not split routines at the same boundaries.
; Inputs:  (XIZ+0x08) and (XIZ+0x0C) longs.  Outputs: XIY.  `retd 0x0008`.
; Evidence: `mul XIY,IX` at 0xFBA11A on the two low halves, then
;          `mul XIX,(XIZ+0x0a)` at 0xFBA11C and `mul XIX,(XIZ+0x0e)` at
;          0xFBA126, each shifted left 16 by `sll A,XIX` with A = 0x10
;          loaded once at 0xFBA112, and added.  The high-by-high product is
;          never computed, which is right for a result truncated to 32
;          bits -- the same sentence prom_c's header already carries.
; Called from: 3 textual references in prom_a.
; ---------------------------------------------------------------------
Multiply32:
	link XIZ,0x0000                                      ; FBA10D  ee 0c 00 00
	push XIX                                             ; FBA111  3c
	ld a, 0x10:opc                                          ; FBA112  21 10
	ld IY,(XIZ+0x08)                                     ; FBA114  9e 08 25
	ld IX,(XIZ+0x0c)                                     ; FBA117  9e 0c 24
	mul xiy, ix                                         ; FBA11A  dc 45
	mul	xix, (xiz+10)                                ; FBA11C  9e 0a 44
	.byte 0xec, 0xfe                                     ; FBA11F  ec fe   sll A,XIX
	add XIY,XIX                                          ; FBA121  ec 85
	ld IX,(XIZ+0x08)                                     ; FBA123  9e 08 24
	mul	xix, (xiz+14)                                ; FBA126  9e 0e 44
	.byte 0xec, 0xfe                                     ; FBA129  ec fe   sll A,XIX
	add XIY,XIX                                          ; FBA12B  ec 85
	pop XIX                                              ; FBA12D  5c
	unlk XIZ                                             ; FBA12E  ee 0d
	retd 0x0008                                          ; FBA130  0f 08 00
; Divide32_Unsigned_Quotient_Copy2: an exact copy of Divide32_Unsigned_Quotient (prom_b 0xF37F3A) -- all 22 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
Divide32_Unsigned_Quotient_Copy2:
	link XIZ,0x0000                                      ; FBA133  ee 0c 00 00
	push XIX                                             ; FBA137  3c
	ld b, 0x20:opc                                          ; FBA138  22 20
	sub WA,WA                                            ; FBA13A  d8 a0
	sub XIY,XIY                                          ; FBA13C  ed a5
	sub XIX,XIX                                          ; FBA13E  ec a4
.LFBA140:
	sll xix, 0x01                                        ; FBA140  ec ee 01
	sllw (xiz+0x08)                                      ; FBA143  9e 08 7e   sllw (XIZ+0x08)
	.byte 0xd8, 0x24, 0x00                               ; FBA146  d8 24 00   stcf 0x00,WA
	sllw (xiz+0x0a)                                      ; FBA149  9e 0a 7e   sllw (XIZ+0x0a)
	.byte 0xdc, 0x24, 0x00                               ; FBA14C  dc 24 00   stcf 0x00,IX
	add (XIZ+0x0a),WA                                    ; FBA14F  9e 0a 88
	sll xiy, 0x01                                        ; FBA152  ed ee 01
	cp XIX,(XIZ+0x0c)                                    ; FBA155  ae 0c f4
	jr c, .LFBA15F                                       ; FBA158  67 05
	sub XIX,(XIZ+0x0c)                                   ; FBA15A  ae 0c a4
	inc 1,XIY                                            ; FBA15D  ed 61
.LFBA15F:
	dec 1,B                                              ; FBA15F  ca 69
	jr nz, .LFBA140                                      ; FBA161  6e dd
	pop XIX                                              ; FBA163  5c
	unlk XIZ                                             ; FBA164  ee 0d
	retd 0x0008                                          ; FBA166  0f 08 00

; ---------------------------------------------------------------------
; MidiFile_Tables_FBA169 -- 205 bytes of DATA: the SMF chunk magics and two
;                           parallel tables
;
; ★ "MThd" AND "MTrk", the two chunk types of a Standard MIDI File, are the
; eight ASCII bytes at 0xFBA169-0xFBA170.  That makes the 0xFB9000 module an SMF
; reader or writer; NOTHING HERE SAYS WHICH, and no note in this tree has
; claimed either.  (Three other printable-looking runs exist in
; 0xFAD800-0xFBFFFF -- 0xFB8A7C, 0xFB8A93 and 0xFBDA01 -- and all three are
; numeric tables whose values happen to land in the ASCII range, not text.)
;
; THE WHOLE BLOCK, byte for byte, 205 bytes:
;   0xFBA169   4   "MThd"
;   0xFBA16D   4   "MTrk"
;   0xFBA171   2   0x7E 0x7F
;   0xFBA173   1   0x09
;   0xFBA174  16   0x00..0x0F in order
;   0xFBA184   1   0x20
;   0xFBA185  16   0x00..0x08, 0x0A..0x0F, 0x09  -- the SAME sixteen values,
;                  with 9 moved to the end
;   0xFBA195  64   sixteen LE32 words: 0x000076AF 0x000076EF 0x0000772F
;                  0x0000776F 0x000077AF 0x000077EF 0x0000782F 0x0000786F
;                  0x000078EF 0x0000792F 0x0000796F 0x000079AF 0x000079EF
;                  0x00007A2F 0x00007A6F 0x00007AAF -- RAM addresses stepping
;                  by 0x40 EXCEPT between entries 7 and 8, where the step is
;                  0x80 and 0x000078AF is skipped
;   0xFBA1D5  16   0x00..0x0F in order
;   0xFBA1E5   1   0x20
;   0xFBA1E6  16   0x00..0x0F in order
;   0xFBA1F6  64   the SAME sixteen LE32 words again, byte for byte
;
; ⚠ SO THE TWO HALVES ARE NOT COPIES: the second has no leading 0x09 and its
; second ramp is in order where the first's is not.  A reading in which the
; permuted ramp and the skipped address belong together -- sixteen 0x40-byte RAM
; records with entry 9 relocated -- fits every byte, and is NOT claimed here
; because no reader of either table has been found.  Emitted as `.byte`.
; START AND END: 0xFBA168 is the last byte of `retd 8`; 0xFBA236 is the first of
; the module's 2,506-byte 0x0E pad.
; ---------------------------------------------------------------------
MidiFile_Tables_FBA169:
	.byte 0x4d, 0x54, 0x68, 0x64, 0x4d, 0x54, 0x72, 0x6b, 0x7e, 0x7f, 0x09, 0x00, 0x01, 0x02, 0x03, 0x04  ; FBA169
	.byte 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x20, 0x00, 0x01, 0x02, 0x03  ; FBA179
	.byte 0x04, 0x05, 0x06, 0x07, 0x08, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x09, 0xaf, 0x76, 0x00, 0x00  ; FBA189
	.byte 0xef, 0x76, 0x00, 0x00, 0x2f, 0x77, 0x00, 0x00, 0x6f, 0x77, 0x00, 0x00, 0xaf, 0x77, 0x00, 0x00  ; FBA199
	.byte 0xef, 0x77, 0x00, 0x00, 0x2f, 0x78, 0x00, 0x00, 0x6f, 0x78, 0x00, 0x00, 0xef, 0x78, 0x00, 0x00  ; FBA1A9
	.byte 0x2f, 0x79, 0x00, 0x00, 0x6f, 0x79, 0x00, 0x00, 0xaf, 0x79, 0x00, 0x00, 0xef, 0x79, 0x00, 0x00  ; FBA1B9
	.byte 0x2f, 0x7a, 0x00, 0x00, 0x6f, 0x7a, 0x00, 0x00, 0xaf, 0x7a, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03  ; FBA1C9
	.byte 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x20, 0x00, 0x01, 0x02  ; FBA1D9
	.byte 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0xaf, 0x76, 0x00  ; FBA1E9
	.byte 0x00, 0xef, 0x76, 0x00, 0x00, 0x2f, 0x77, 0x00, 0x00, 0x6f, 0x77, 0x00, 0x00, 0xaf, 0x77, 0x00  ; FBA1F9
	.byte 0x00, 0xef, 0x77, 0x00, 0x00, 0x2f, 0x78, 0x00, 0x00, 0x6f, 0x78, 0x00, 0x00, 0xef, 0x78, 0x00  ; FBA209
	.byte 0x00, 0x2f, 0x79, 0x00, 0x00, 0x6f, 0x79, 0x00, 0x00, 0xaf, 0x79, 0x00, 0x00, 0xef, 0x79, 0x00  ; FBA219
	.byte 0x00, 0x2f, 0x7a, 0x00, 0x00, 0x6f, 0x7a, 0x00, 0x00, 0xaf, 0x7a, 0x00, 0x00  ; FBA229
	ret                                                  ; FBA236  0e

; 0xFBA237-0xFBABFF -- 2505 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 2505, 1, 0x0E
