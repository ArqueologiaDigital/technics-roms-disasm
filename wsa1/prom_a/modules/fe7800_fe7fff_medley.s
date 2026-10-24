
; Medley_Start: T_Medley_Start: INT -> Medley_PlayingSong = Medley_FirstSong, Medley_LoadInternalSong; FD + MIDI FILE -> the same
;   start, Medley_StartMidiFile.
Medley_Start:
	ld a, (Medley_Source:16)                                   ; FE7800  c1 0b 22 21
	cp a, 0x00:i3                                          ; FE7804  c9 d8
	jr nz, .LFE7815                                      ; FE7806  6e 0d
	ld a, (Medley_FirstSong:16)                                   ; FE7808  c1 08 22 21
	ld (Medley_PlayingSong:16), a                                   ; FE780C  f1 0a 22 41
	calr Medley_LoadInternalSong                                      ; FE7810  1e 51 00
	jr .LFE782B                                          ; FE7813  68 16
.LFE7815:
	cp a, 0x01:i3                                          ; FE7815  c9 d9
	jr nz, .LFE782B                                      ; FE7817  6e 12
	cp	(Medley_FileType:16), 0x01                            ; FE7819  c1 35 0e 3f 01
	jr nz, .LFE782B                                      ; FE781E  6e 0b
	ld a, (Medley_FirstSong:16)                                   ; FE7820  c1 08 22 21
	ld (Medley_PlayingSong:16), a                                   ; FE7824  f1 0a 22 41
	calr Medley_StartMidiFile                                      ; FE7828  1e 8c 01
.LFE782B:
	ret                                                  ; FE782B  0e
; Medley_Stop: T_Medley_Stop: INT -> Medley_StopInternal; FD + MIDI FILE -> Medley_StopMidiFile.
Medley_Stop:
	ld a, (Medley_Source:16)                                   ; FE782C  c1 0b 22 21
	cp a, 0x00:i3                                          ; FE7830  c9 d8
	jr nz, .LFE7839                                      ; FE7832  6e 05
	calr Medley_StopInternal                                      ; FE7834  1e c4 00
	jr .LFE7847                                          ; FE7837  68 0e
.LFE7839:
	cp a, 0x01:i3                                          ; FE7839  c9 d9
	jr nz, .LFE7847                                      ; FE783B  6e 0a
	cp	(Medley_FileType:16), 0x01                            ; FE783D  c1 35 0e 3f 01
	jr nz, .LFE7847                                      ; FE7842  6e 03
	calr Medley_StopMidiFile                                      ; FE7844  1e e9 01
.LFE7847:
	ret                                                  ; FE7847  0e
; Medley_Next: T_Medley_Next: INT -> Medley_SkipToNextInternalSong; FD + MIDI FILE -> Medley_SkipToNextMidiFile.
Medley_Next:
	ld a, (Medley_Source:16)                                   ; FE7848  c1 0b 22 21
	cp a, 0x00:i3                                          ; FE784C  c9 d8
	jr nz, .LFE7855                                      ; FE784E  6e 05
	calr Medley_SkipToNextInternalSong                                      ; FE7850  1e b5 00
	jr .LFE7863                                          ; FE7853  68 0e
.LFE7855:
	cp a, 0x01:i3                                          ; FE7855  c9 d9
	jr nz, .LFE7863                                      ; FE7857  6e 0a
	cp	(Medley_FileType:16), 0x01                            ; FE7859  c1 35 0e 3f 01
	jr nz, .LFE7863                                      ; FE785E  6e 03
	calr Medley_SkipToNextMidiFile                                      ; FE7860  1e dd 01
.LFE7863:
	ret                                                  ; FE7863  0e
; Medley_LoadInternalSong: from Medley_PlayingSong to Medley_LastSong (then from Medley_FirstSong once more), the first bank whose copy
;   (0x610100 + bank x 0xC00) has an in-use directory entry: Medley_PlayingSong = BStore_CurrentBank = it,
;   T_BStore_LoadSongFromCurrentBank, (0x34D0) |= 4, its 6-character name (0x6034CA) to 0x0E38 + 5 blanks, (0x22D0) = 10.  None in range:
;   UI_StatusCode 0x2F, request 0x40AB, Medley_Playing = 0.
Medley_LoadInternalSong:
	ld a, (Medley_PlayingSong:16)                                   ; FE7864  c1 0a 22 21
	cp	a, (Medley_LastSong:16)                               ; FE7868  c1 09 22 f1
	jrl ugt, .LFE78FA                                    ; FE786C  7b 8b 00
	ld c, 0x00:opc                                          ; FE786F  23 00
.LFE7871:
	ld L,A                                               ; FE7871  c9 8f
	extz HL                                              ; FE7873  db 12
	mul HL,0x0c00                                        ; FE7875  db 08 00 0c
	add XHL,0x00610100                                   ; FE7879  eb c8 00 01 61 00
.LFE787F:
	ld XIY,XHL                                           ; FE787F  eb 8d
	ld b, 0x10:opc                                          ; FE7881  22 10
	xor XIZ,XIZ                                          ; FE7883  ee d6
	cp	xiz, (xiy-226)                       ; FE7885  e3 f5 1e ff f6
	jr z, .LFE7895                                       ; FE788A  66 09
.LFE788C:
	bit 7,(XIY)                                          ; FE788C  b5 cf
	jr nz, .LFE78CB                                      ; FE788E  6e 3b
	inc 3,XIY                                            ; FE7890  ed 63
	djnz8 b, .LFE788C                                    ; FE7892  ca 1c f7
.LFE7895:
	add XHL,0x00000c00                                   ; FE7895  eb c8 00 0c 00 00
	inc 1,A                                              ; FE789B  c9 61
	inc 1,C                                              ; FE789D  cb 61
	cp	a, (Medley_LastSong:16)                               ; FE789F  c1 09 22 f1
	jr ule, .LFE787F                                     ; FE78A3  63 da
	ld e, (Medley_LastSong:16)                                   ; FE78A5  c1 09 22 25
	sub e, (Medley_FirstSong:16)                                   ; FE78A9  c1 08 22 a5
	inc 1,E                                              ; FE78AD  cd 61
	cp C,E                                               ; FE78AF  cd f3
	jr c, .LFE78C5                                       ; FE78B1  67 12
	ld (UI_StatusCode:16), 0x2f                                 ; FE78B3  f1 80 28 00 2f
	ldw (UI_Request:16), 0x40ab                              ; FE78B8  f1 70 20 02 ab 40
	ld (Medley_Playing:16), 0x00                                 ; FE78BE  f1 c1 0d 00 00
	jr .LFE78FA                                          ; FE78C3  68 35
.LFE78C5:
	ld a, (Medley_FirstSong:16)                                   ; FE78C5  c1 08 22 21
	jr .LFE7871                                          ; FE78C9  68 a6
.LFE78CB:
	ld (Medley_PlayingSong:16), a                                   ; FE78CB  f1 0a 22 41
	ld (BStore_CurrentBank:16), a                                   ; FE78CF  f1 0a 36 41
	call T_BStore_LoadSongFromCurrentBank                                        ; FE78D3  1d 2c 28 f4
	or	(0x34d0:16), 0x04                            ; FE78D7  c1 d0 34 3e 04
	ld XIY,BStore_SongName                                    ; FE78DC  45 ca 34 60 00
	ld XIX,Medley_DisplayName                                    ; FE78E1  44 38 0e 00 00
	ldw bc, 0x03                                         ; FE78E6  31 03 00
	ldirw                                                ; FE78E9  95 11
	ld a, 0x20:opc                                          ; FE78EB  21 20
	ld b, 0x05:opc                                          ; FE78ED  22 05
.LFE78EF:
	ld (xix+), a                                    ; FE78EF  f5 f0 41
	djnz8 b, .LFE78EF                                    ; FE78F2  ca 1c fa
	ld (Medley_Countdown:16), 0x0a                                 ; FE78F5  f1 d0 22 00 0a
.LFE78FA:
	ret                                                  ; FE78FA  0e
; Medley_StopInternal: T_Transport_StopAllRunning, (0x34D0) bit 2 cleared, Name11At0E38_Blank.
Medley_StopInternal:
	call T_Transport_StopAllRunning                                        ; FE78FB  1d ac 09 f4
	and	(0x34d0:16), 0xfb                            ; FE78FF  c1 d0 34 3c fb
	calr Name11At0E38_Blank                                      ; FE7904  1e 5c 01
	ret                                                  ; FE7907  0e
; Medley_SkipToNextInternalSong: Medley_StopInternal, Medley_PlayingSong + 1 (past Medley_LastSong: from Medley_FirstSong), Medley_LoadInternalSong.
Medley_SkipToNextInternalSong:
	calr Medley_StopInternal                                      ; FE7908  1e f0 ff
	ld a, (Medley_PlayingSong:16)                                   ; FE790B  c1 0a 22 21
	cp	a, (Medley_LastSong:16)                               ; FE790F  c1 09 22 f1
	jr c, .LFE791F                                       ; FE7913  67 0a
	ld a, (Medley_FirstSong:16)                                   ; FE7915  c1 08 22 21
	dec 1,A                                              ; FE7919  c9 69
	ld (Medley_PlayingSong:16), a                                   ; FE791B  f1 0a 22 41
.LFE791F:
	inc 0x01, (Medley_PlayingSong:16)                                ; FE791F  c1 0a 22 61
	calr Medley_LoadInternalSong                                      ; FE7923  1e 3e ff
	ret                                                  ; FE7926  0e
; Medley_AdvanceInternalSong: T_Medley_AdvanceInternalSong, called by the sequencer at a song's end: when an INT medley plays ((0x34D0) bit 2), the next song as
;   in Medley_SkipToNextInternalSong, without stopping first.
Medley_AdvanceInternalSong:
	cp	(Medley_Source:16), 0x00                            ; FE7927  c1 0b 22 3f 00
	jr nz, .LFE794F                                      ; FE792C  6e 21
	bit	2, (0x34d0:16)                               ; FE792E  f1 d0 34 ca
	jr z, .LFE794F                                       ; FE7932  66 1b
	ld a, (Medley_PlayingSong:16)                                   ; FE7934  c1 0a 22 21
	cp	a, (Medley_LastSong:16)                               ; FE7938  c1 09 22 f1
	jr c, .LFE7948                                       ; FE793C  67 0a
	ld a, (Medley_FirstSong:16)                                   ; FE793E  c1 08 22 21
	dec 1,A                                              ; FE7942  c9 69
	ld (Medley_PlayingSong:16), a                                   ; FE7944  f1 0a 22 41
.LFE7948:
	inc 0x01, (Medley_PlayingSong:16)                                ; FE7948  c1 0a 22 61
	calr Medley_LoadInternalSong                                      ; FE794C  1e 15 ff
.LFE794F:
	ret                                                  ; FE794F  0e
; Medley_Tick: T_Medley_Tick: counts (0x22D0) down; at 5 for INT: playback flags cleared and T_Seq_RewindAfterSongLoad; at 0: INT -> T_Transport_ResetAndStartBC (the
;   transports from zero), FD + MIDI FILE -> the next song (wrapping) and Medley_StartMidiFile.
Medley_Tick:
	ld w, (Medley_Countdown:16)                                   ; FE7950  c1 d0 22 20
	cp w, 0x00:i3                                          ; FE7954  c8 d8
	jr z, .LFE79B6                                       ; FE7956  66 5e
	dec 1,W                                              ; FE7958  c8 69
	cp w, 0x05:i3                                          ; FE795A  c8 dd
	jr nz, .LFE7978                                      ; FE795C  6e 1a
	ld a, (Medley_Source:16)                                   ; FE795E  c1 0b 22 21
	cp a, 0x00:i3                                          ; FE7962  c9 d8
	jr nz, .LFE79B2                                      ; FE7964  6e 4c
	pushw wa                                             ; FE7966  28
	and	(0x34d9:16), 0xf9                            ; FE7967  c1 d9 34 3c f9
	and	(0x34bb:16), 0xf7                            ; FE796C  c1 bb 34 3c f7
	call T_Seq_RewindAfterSongLoad                                        ; FE7971  1d cc 09 f4
	popw wa                                              ; FE7975  48
	jr .LFE79B2                                          ; FE7976  68 3a
.LFE7978:
	cp w, 0x00:i3                                          ; FE7978  c8 d8
	jr nz, .LFE79B2                                      ; FE797A  6e 36
	ld a, (Medley_Source:16)                                   ; FE797C  c1 0b 22 21
	cp a, 0x00:i3                                          ; FE7980  c9 d8
	jr z, .LFE79AC                                       ; FE7982  66 28
	cp a, 0x01:i3                                          ; FE7984  c9 d9
	jr nz, .LFE79B2                                      ; FE7986  6e 2a
	cp	(Medley_FileType:16), 0x01                            ; FE7988  c1 35 0e 3f 01
	jr nz, .LFE79B2                                      ; FE798D  6e 23
	ld a, (Medley_LastSong:16)                                   ; FE798F  c1 09 22 21
	inc 0x01, (Medley_PlayingSong:16)                                ; FE7993  c1 0a 22 61
	cp (Medley_PlayingSong:16), a                                    ; FE7997  c1 0a 22 f9
	jr ule, .LFE79A5                                     ; FE799B  63 08
	ld a, (Medley_FirstSong:16)                                   ; FE799D  c1 08 22 21
	ld (Medley_PlayingSong:16), a                                   ; FE79A1  f1 0a 22 41
.LFE79A5:
	pushw wa                                             ; FE79A5  28
	calr Medley_StartMidiFile                                      ; FE79A6  1e 0e 00
	popw wa                                              ; FE79A9  48
	jr .LFE79B2                                          ; FE79AA  68 06
.LFE79AC:
	pushw wa                                             ; FE79AC  28
	call T_Transport_ResetAndStartBC                                        ; FE79AD  1d 04 03 f4
	popw wa                                              ; FE79B1  48
.LFE79B2:
	ld (Medley_Countdown:16), w                                   ; FE79B2  f1 d0 22 40
.LFE79B6:
	ret                                                  ; FE79B6  0e
; Medley_StartMidiFile: (0x34D0) |= 4, T_Disk_MountAndScanMidiFilesResetRings (mount and list the MIDI files); from Medley_PlayingSong, the first listing entry
;   (0x60A480 + 8 n) that is not blank: its name to Disk_FileName and to 0x0E38, T_Medley_ToggleMidiFileStream.  None: Medley_StopMidiFile,
;   status 3.
Medley_StartMidiFile:
	or	(0x34d0:16), 0x04                            ; FE79B7  c1 d0 34 3e 04
	call T_Disk_MountAndScanMidiFilesResetRings                                        ; FE79BC  1d 14 26 f4
.LFE79C0:
	ld a, (Medley_PlayingSong:16)                                   ; FE79C0  c1 0a 22 21
	mul A,0x08                                           ; FE79C4  c9 08 08
	extz XWA                                             ; FE79C7  e8 12
	add XWA,0x0060a480                                   ; FE79C9  e8 c8 80 a4 60 00
	ldw bc, 0x0800                                       ; FE79CF  31 00 08
.LFE79D2:
	.byte 0xc3, 0x03, 0xe0, 0xe4, 0x3f, 0x20             ; FE79D2  c3 03 e0 e4 3f 20   cp (XWA+C),0x20
	jr nz, .LFE7A09                                      ; FE79D8  6e 2f
	inc 1,C                                              ; FE79DA  cb 61
	djnz8 b, .LFE79D2                                    ; FE79DC  ca 1c f3
	ld c, (Medley_FirstSong:16)                                   ; FE79DF  c1 08 22 23
	cp	c, (Medley_PlayingSong:16)                               ; FE79E3  c1 0a 22 f3
	jr z, .LFE79EF                                       ; FE79E7  66 06
	ld (Medley_PlayingSong:16), c                                   ; FE79E9  f1 0a 22 43
	jr .LFE79C0                                          ; FE79ED  68 d1
.LFE79EF:
	calr Medley_StopMidiFile                                      ; FE79EF  1e 3e 00
	or	(UI_Request_Hi:16), 0x10                            ; FE79F2  c1 71 20 3e 10
	and	(Medley_Playing:16), 0xfe                            ; FE79F7  c1 c1 0d 3c fe
	ld (UI_StatusCode:16), 0x03                                 ; FE79FC  f1 80 28 00 03
	ldw (UI_Request:16), 0x40ab                              ; FE7A01  f1 70 20 02 ab 40
	jr .LFE7A2F                                          ; FE7A07  68 26
.LFE7A09:
	ld XIY,XWA                                           ; FE7A09  e8 8d
	ld XIX,Disk_FileName                                    ; FE7A0B  44 c8 21 00 00
	ldw bc, 0x04                                         ; FE7A10  31 04 00
	ldirw                                                ; FE7A13  95 11
	ld XIY,XWA                                           ; FE7A15  e8 8d
	ld XIX,Medley_DisplayName                                    ; FE7A17  44 38 0e 00 00
	ldw bc, 0x04                                         ; FE7A1C  31 04 00
	ldirw                                                ; FE7A1F  95 11
	ld a, 0x20:opc                                          ; FE7A21  21 20
	ld b, 0x03:opc                                          ; FE7A23  22 03
.LFE7A25:
	ld (xix+), a                                    ; FE7A25  f5 f0 41
	djnz8 b, .LFE7A25                                    ; FE7A28  ca 1c fa
	call T_Medley_ToggleMidiFileStream                                        ; FE7A2B  1d 90 2e f4
.LFE7A2F:
	ret                                                  ; FE7A2F  0e
; Medley_StopMidiFile: (0x34D0) bit 2 cleared, Disk_BlankFileNameBase, T_Medley_ToggleMidiFileStream, Name11At0E38_Blank.
Medley_StopMidiFile:
	and	(0x34d0:16), 0xfb                            ; FE7A30  c1 d0 34 3c fb
	calr Disk_BlankFileNameBase                                      ; FE7A35  1e 3b 00
	call T_Medley_ToggleMidiFileStream                                        ; FE7A38  1d 90 2e f4
	calr Name11At0E38_Blank                                      ; FE7A3C  1e 24 00
	ret                                                  ; FE7A3F  0e
; Medley_SkipToNextMidiFile: Medley_StopMidiFile, then (0x22D0) = 10 so Medley_Tick starts the next file.
Medley_SkipToNextMidiFile:
	calr Medley_StopMidiFile                                      ; FE7A40  1e ed ff
	ld (Medley_Countdown:16), 0x0a                                 ; FE7A43  f1 d0 22 00 0a
	ret                                                  ; FE7A48  0e
; Medley_ScheduleNextMidiFile: T_Medley_ScheduleNextMidiFile: with an FD MIDI-file medley playing, (0x22D0) = 10.
Medley_ScheduleNextMidiFile:
	cp	(Medley_Source:16), 0x01                            ; FE7A49  c1 0b 22 3f 01
	jr nz, .LFE7A62                                      ; FE7A4E  6e 12
	cp	(Medley_FileType:16), 0x01                            ; FE7A50  c1 35 0e 3f 01
	jr nz, .LFE7A62                                      ; FE7A55  6e 0b
	bit	2, (0x34d0:16)                               ; FE7A57  f1 d0 34 ca
	jr z, .LFE7A62                                       ; FE7A5B  66 05
	ld (Medley_Countdown:16), 0x0a                                 ; FE7A5D  f1 d0 22 00 0a
.LFE7A62:
	ret                                                  ; FE7A62  0e
; Name11At0E38_Blank: fill the 11 bytes at RAM 0x0E38 with spaces.
Name11At0E38_Blank:
	ld XIX,Medley_DisplayName                                    ; FE7A63  44 38 0e 00 00
	ld a, 0x20:opc                                          ; FE7A68  21 20
	ld b, 0x0b:opc                                          ; FE7A6A  22 0b
.LFE7A6C:
	ld (xix+), a                                    ; FE7A6C  f5 f0 41
	djnz8 b, .LFE7A6C                                    ; FE7A6F  ca 1c fa
	ret                                                  ; FE7A72  0e
; Disk_BlankFileNameBase: Disk_FileName[0..7] = eight spaces.
Disk_BlankFileNameBase:
	ld XIX,Disk_FileName                                    ; FE7A73  44 c8 21 00 00
	ld XWA,0x20202020                                    ; FE7A78  40 20 20 20 20
	ld b, 0x02:opc                                          ; FE7A7D  22 02
.LFE7A7F:
	ld (xix+), xwa                                    ; FE7A7F  f5 f2 60
	djnz8 b, .LFE7A7F                                    ; FE7A82  ca 1c fa
	ret                                                  ; FE7A85  0e
; ---------------------------------------------------------------------
; 0xFE7A86-0xFE7FB0 -- 1,323 bytes of 0x00 after this module's last `ret`
;
; Was framed as 1,323 `nop` instructions.  It is not code: the byte before
; it is the `ret` of Disk_BlankFileNameBase, no label lies inside it, no branch in this
; source reaches it, and no 32-bit immediate or `.long` in prom_a or prom_b
; (hex or decimal) names an address in it.  It runs up to the module's 0x0E
; pad at 0xFE7FB1.  Checked byte by byte: notes/proma-2026-09-25/
; retire_zero_runs.py (repo root) refuses unless every byte is 0x00.
; ⚠ Whether it is a zero-initialised table something reaches through a
;   computed pointer, or linker slack, is not established; no reader is known.
; ---------------------------------------------------------------------
	.fill 1323, 1, 0x00                                ; FE7A86
	ret                                                  ; FE7FB1  0e

; 0xFE7FB2-0xFE7FFF -- 78 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 78, 1, 0x0E
