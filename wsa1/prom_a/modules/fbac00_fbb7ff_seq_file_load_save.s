
; SeqFile_Load: DiskLoad_Sequencer's body (T_SeqFile_Load, through SeqFile_Load_SaveRegs).  SeqFile_ProbeSqfHeader: 1 -> SeqFile_LoadAllBanks;
;   0 -> one song into bank Disk_SeqBank.  The workspace 0x603400 goes to its bank copy, the free chain is stashed,
;   bank Disk_SeqBank's copy becomes the workspace and BStore_CurrentBank, and the SQF is read over it
;   (Disk_LoadSqfToWorkspace_Entry).  If its blocks ((0x603452) >> 4) fit in the stashed free count (else result
;   0x1E), they are read after the free head and relocated (SeqFile_LoadSongBlocks).  Result -> (0x23CB).
SeqFile_Load:
	push XIZ                                             ; FBAC00  3e
	push XIX                                             ; FBAC01  3c
	push XHL                                             ; FBAC02  3b
	push XDE                                             ; FBAC03  3a
	call SeqFile_ProbeSqfHeader                                      ; FBAC04  1d 99 b1 fb
	cp a, 0x00:i3                                          ; FBAC08  c9 d8
	jr z, .LFBAC1F                                       ; FBAC0A  66 13
	cp a, 0x01:i3                                          ; FBAC0C  c9 d9
	jr z, .LFBAC18                                       ; FBAC0E  66 08
	cp a, 0x03:i3                                          ; FBAC10  c9 db
	jrl z, .LFBACEE                                      ; FBAC12  76 d9 00
	jrl .LFBACEE                                         ; FBAC15  78 d6 00
.LFBAC18:
	call SeqFile_LoadAllBanks                                      ; FBAC18  1d 0b b2 fb
	jrl .LFBACEE                                         ; FBAC1C  78 cf 00
.LFBAC1F:
	ld xwa, (0x360c:16)                                 ; FBAC1F  e1 0c 36 20
	ld (0x60341e:24), xwa                               ; FBAC23  f2 1e 34 60 60
	ld XIY,0x00603400                                    ; FBAC28  45 00 34 60 00
	call BStore_CurrentBankCopyAddr                                      ; FBAC2D  1d c3 b0 fb
	ldir85                                               ; FBAC31  85 11
	call BStore_StashFreeChain                                      ; FBAC33  1d ea ad fb
	ld XIX,0x00603400                                    ; FBAC37  44 00 34 60 00
	call BStore_DiskBankCopyAddr                                      ; FBAC3C  1d d6 b0 fb
	ldir85                                               ; FBAC40  85 11
	call BStore_UnstashFreeChain                                      ; FBAC42  1d fd ad fb
	ld a, (Disk_SeqBank:16)                                   ; FBAC46  c1 2b 27 21
	ld (BStore_CurrentBank:16), a                                   ; FBAC4A  f1 0a 36 41
	call T_SongClear_ClearCurrentBank                                        ; FBAC4E  1d 08 27 f4
	call BStore_StashFreeChain                                      ; FBAC52  1d ea ad fb
	ld XIY,0x00603400                                    ; FBAC56  45 00 34 60 00
	call BStore_CurrentBankCopyAddr                                      ; FBAC5B  1d c3 b0 fb
	ldir85                                               ; FBAC5F  85 11
	call T_Disk_LoadSqfToWorkspace_Entry                                        ; FBAC61  1d 24 26 f4
	cp	(Disk_LastError:16), 0x01                            ; FBAC65  c1 43 22 3f 01
	jrl nz, .LFBACD2                                     ; FBAC6A  7e 65 00
	call T_Seq_ApplySongBeatsPerBar                                        ; FBAC6D  1d c8 0a f4
	ld wa, (0x603452:24)                                ; FBAC71  d2 52 34 60 20
	ld bc, (0x23ba:16)                                 ; FBAC76  d1 ba 23 21
	srl wa, 0x04                                         ; FBAC7A  d8 ef 04
	cp BC,WA                                             ; FBAC7D  d8 f1
	jr c, .LFBACCB                                       ; FBAC7F  67 4a
	call BStore_UnstashFreeChain                                      ; FBAC81  1d fd ad fb
	pushw	(0x603452:24)                                ; FBAC85  d2 52 34 60 04
	call T_BStore_CompactBlocks_Veneer                                        ; FBAC8A  1d b0 14 f4
	popw	(0x603452:24)                                ; FBAC8E  f2 52 34 60 06
	cpw	(0x603452:24), 0x0000                        ; FBAC93  d2 52 34 60 3f 00 00
	jr z, .LFBACAC                                       ; FBAC9A  66 10
	call SeqFile_LoadSongBlocks                                      ; FBAC9C  1d 07 ad fb
	cp	(Disk_LastError:16), 0x01                            ; FBACA0  c1 43 22 3f 01
	jr nz, .LFBACD2                                      ; FBACA5  6e 2b
	ld (0x3552:16), 0x01                                 ; FBACA7  f1 52 35 00 01
.LFBACAC:
	call	T_F40A34_Zeroed                                ; FBACAC  1d 34 0a f4
	call T_Seq_RewindAfterSongLoad                                        ; FBACB0  1d cc 09 f4
	ld xwa, (0x60341e:24)                               ; FBACB4  e2 1e 34 60 20
	ld (0x360c:16), xwa                                 ; FBACB9  f1 0c 36 60
	call SeqMasterTrack_SetFlagFromTrackMask                                      ; FBACBD  1d f3 ac fb
	ld a, (Disk_LastError:16)                                   ; FBACC1  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBACC5  f1 cb 23 41
	jr .LFBACEE                                          ; FBACC9  68 23
.LFBACCB:
	ld (0x23cb:16), 0x1e                                 ; FBACCB  f1 cb 23 00 1e
	jr .LFBACDA                                          ; FBACD0  68 08
.LFBACD2:
	ld a, (Disk_LastError:16)                                   ; FBACD2  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBACD6  f1 cb 23 41
.LFBACDA:
	ld XIX,0x00603400                                    ; FBACDA  44 00 34 60 00
	call BStore_DiskBankCopyAddr                                      ; FBACDF  1d d6 b0 fb
	ldir85                                               ; FBACE3  85 11
	ld xwa, (0x60341e:24)                               ; FBACE5  e2 1e 34 60 20
	ld (0x360c:16), xwa                                 ; FBACEA  f1 0c 36 60
.LFBACEE:
	pop XDE                                              ; FBACEE  5a
	pop XHL                                              ; FBACEF  5b
	pop XIX                                              ; FBACF0  5c
	pop XIZ                                              ; FBACF1  5e
	ret                                                  ; FBACF2  0e
; SeqMasterTrack_SetFlagFromTrackMask: (0x3752) := 1 if bit 0 of (0x603420) -- bit 16, the 17th (master) track, of the
;   song's playing-track mask (0x60341E) -- is set, else 0. (0x3752) is the '(MASTER:' ON/OFF flag
;   SeqMasterTrack_SwitchOff clears. SeqFile_Load and SeqFile_LoadAllBanks call it after a song is loaded; prom_a
;   0xF8185B does the same inline after a bank load. Basis: callers + body + the flag's other users. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
SeqMasterTrack_SetFlagFromTrackMask:
	bit	0, (0x603420:24)                             ; FBACF3  f2 20 34 60 c8
	jr z, .LFBAD01                                       ; FBACF8  66 07
	ld (0x3752:16), 0x01                                 ; FBACFA  f1 52 37 00 01
	jr .LFBAD06                                          ; FBACFF  68 05
.LFBAD01:
	ld (0x3752:16), 0x00                                 ; FBAD01  f1 52 37 00 00
.LFBAD06:
	ret                                                  ; FBAD06  0e
; SeqFile_LoadSongBlocks: reads the SEQ with BStore_HeapBase moved to the free head's block (BStore_FreeHeadBlockAddr), restores the
;   base, then adds FreeHead-1 (BStore_FreeHeadIndex) to every block number the song holds: the 17 directory
;   start blocks (0x603501, stride 3), the 17 words at 0x60347E, and each loaded block's previous / next links
;   (BStore_RelocateBlockNumber); then BStore_RebuildFreeChain.
SeqFile_LoadSongBlocks:
	ld xwa, (BStore_HeapBase:16)                                 ; FBAD07  e1 04 36 20
	push XWA                                             ; FBAD0B  38
	call BStore_FreeHeadBlockAddr                                      ; FBAD0C  1d 2a ae fb
	ld (BStore_HeapBase:16), xix                                 ; FBAD10  f1 04 36 64
	call T_Disk_LoadSeqToHeap_Entry                                        ; FBAD14  1d 28 26 f4
	pop XWA                                              ; FBAD18  58
	ld (BStore_HeapBase:16), xwa                                 ; FBAD19  f1 04 36 60
	cp	(Disk_LastError:16), 0x01                            ; FBAD1D  c1 43 22 3f 01
	jr nz, .LFBAD81                                      ; FBAD22  6e 5d
	call BStore_FreeHeadIndex                                      ; FBAD24  1d 3b ae fb
	ld XIX,0x00603500                                    ; FBAD28  44 00 35 60 00
	inc 1,XIX                                            ; FBAD2D  ec 61
	ldw bc, 0x11                                         ; FBAD2F  31 11 00
.LFBAD32:
	call BStore_RelocateBlockNumber                                      ; FBAD32  1d 49 ae fb
	add XIX,0x00000003                                   ; FBAD36  ec c8 03 00 00 00
	djnz16 bc, .LFBAD32                                  ; FBAD3C  d9 1c f3
	call BStore_FreeHeadIndex                                      ; FBAD3F  1d 3b ae fb
	ld XIX,0x0060347e                                    ; FBAD43  44 7e 34 60 00
	ldw bc, 0x11                                         ; FBAD48  31 11 00
.LFBAD4B:
	call BStore_RelocateBlockNumber                                      ; FBAD4B  1d 49 ae fb
	inc 2,XIX                                            ; FBAD4F  ec 62
	djnz16 bc, .LFBAD4B                                  ; FBAD51  d9 1c f7
	call BStore_FreeHeadBlockAddr                                      ; FBAD54  1d 2a ae fb
	inc 1,XIX                                            ; FBAD58  ec 61
	call BStore_FreeHeadIndex                                      ; FBAD5A  1d 3b ae fb
	ld bc, (0x603452:24)                                ; FBAD5E  d2 52 34 60 21
	srl bc, 0x04                                         ; FBAD63  d9 ef 04
.LFBAD66:
	call BStore_RelocateBlockNumber                                      ; FBAD66  1d 49 ae fb
	add XIX,0x00000002                                   ; FBAD6A  ec c8 02 00 00 00
	call BStore_RelocateBlockNumber                                      ; FBAD70  1d 49 ae fb
	add XIX,0x000000fe                                   ; FBAD74  ec c8 fe 00 00 00
	djnz16 bc, .LFBAD66                                  ; FBAD7A  d9 1c e9
	call BStore_RebuildFreeChain                                      ; FBAD7D  1d 82 ad fb
.LFBAD81:
	ret                                                  ; FBAD81  0e
; BStore_RebuildFreeChain: BStore_FreeHead += the loaded block count ((0x603452) >> 4), or 0xFFFF past BStore_BlockCount;
;   BStore_FreeCount = BlockCount - FreeHead + 1; when any are free, blocks FreeHead .. BlockCount are linked as a
;   free chain (BStore_InitFreeBlock) and the last one's next is 0xFFFF.
BStore_RebuildFreeChain:
	ld wa, (BStore_FreeHead:24)                                ; FBAD82  d2 b8 34 60 20
	ld bc, (0x603452:24)                                ; FBAD87  d2 52 34 60 21
	srl bc, 0x04                                         ; FBAD8C  d9 ef 04
	add WA,BC                                            ; FBAD8F  d9 80
	ld bc, (BStore_BlockCount:16)                                 ; FBAD91  d1 08 36 21
	cp WA,BC                                             ; FBAD95  d9 f0
	jr ule, .LFBADA2                                     ; FBAD97  63 09
	ldw (BStore_FreeHead:24), 0xffff                           ; FBAD99  f2 b8 34 60 02 ff ff
	jr .LFBADA7                                          ; FBADA0  68 05
.LFBADA2:
	ld (BStore_FreeHead:24), wa                                ; FBADA2  f2 b8 34 60 50
.LFBADA7:
	sub BC,WA                                            ; FBADA7  d8 a1
	inc 1,BC                                             ; FBADA9  d9 61
	ld (BStore_FreeCount:24), bc                                ; FBADAB  f2 ba 34 60 51
	cp bc, 0x00:i3                                         ; FBADB0  d9 d8
	jr z, .LFBADE9                                       ; FBADB2  66 35
	call BStore_FreeHeadBlockAddr                                      ; FBADB4  1d 2a ae fb
	ld bc, (BStore_FreeCount:24)                                ; FBADB8  d2 ba 34 60 21
	ld wa, (BStore_FreeHead:24)                                ; FBADBD  d2 b8 34 60 20
.LFBADC2:
	call BStore_InitFreeBlock                                      ; FBADC2  1d 10 ae fb
	inc 1,WA                                             ; FBADC6  d8 61
	add XIX,0x00000100                                   ; FBADC8  ec c8 00 01 00 00
	djnz16 bc, .LFBADC2                                  ; FBADCE  d9 1c f1
	call BStore_FreeHeadBlockAddr                                      ; FBADD1  1d 2a ae fb
	xor HL,HL                                            ; FBADD5  db d3
	ld (XIX+0x01),HL                                     ; FBADD7  bc 01 53
	xor XWA,XWA                                          ; FBADDA  e8 d0
	ld wa, (BStore_BlockCount:16)                                 ; FBADDC  d1 08 36 20
	call BStore_BlockAddr                                      ; FBADE0  1d 35 b1 fb
	ldw	(xix+3), 0xffff                              ; FBADE4  bc 03 02 ff ff
.LFBADE9:
	ret                                                  ; FBADE9  0e
; BStore_StashFreeChain: BStore_FreeHead / BStore_FreeCount -- workspace words, so per bank -- to (0x23B8) / (0x23BA), before
;   SeqFile_Load swaps the workspace.
BStore_StashFreeChain:
	ld wa, (BStore_FreeHead:24)                                ; FBADEA  d2 b8 34 60 20
	ld (0x23b8:16), wa                                  ; FBADEF  f1 b8 23 50
	ld wa, (BStore_FreeCount:24)                                ; FBADF3  d2 ba 34 60 20
	ld (0x23ba:16), wa                                  ; FBADF8  f1 ba 23 50
	ret                                                  ; FBADFC  0e
; BStore_UnstashFreeChain: (0x23B8) / (0x23BA) back to BStore_FreeHead / BStore_FreeCount: the shared heap's free chain carried into
;   the new bank's workspace.
BStore_UnstashFreeChain:
	ld wa, (0x23b8:16)                                 ; FBADFD  d1 b8 23 20
	ld (BStore_FreeHead:24), wa                                ; FBAE01  f2 b8 34 60 50
	ld wa, (0x23ba:16)                                 ; FBAE06  d1 ba 23 20
	ld (BStore_FreeCount:24), wa                                ; FBAE0A  f2 ba 34 60 50
	ret                                                  ; FBAE0F  0e
; BStore_InitFreeBlock: block XIX, number WA: flags +0 = 0 (free), payload tag +5 = 0x82, previous = WA-1 (0 for 0), next = WA+1.
BStore_InitFreeBlock:
	ld (XIX),0x00                                        ; FBAE10  b4 00 00
	ld (XIX+0x05),0x82                                   ; FBAE13  bc 05 00 82
	ld HL,WA                                             ; FBAE17  d8 8b
	cp hl, 0x00:i3                                         ; FBAE19  db d8
	jr z, .LFBAE1F                                       ; FBAE1B  66 02
	dec 1,HL                                             ; FBAE1D  db 69
.LFBAE1F:
	ld (XIX+0x01),HL                                     ; FBAE1F  bc 01 53
	ld HL,WA                                             ; FBAE22  d8 8b
	inc 1,HL                                             ; FBAE24  db 61
	ld (XIX+0x03),HL                                     ; FBAE26  bc 03 53
	ret                                                  ; FBAE29  0e
; BStore_FreeHeadBlockAddr: XIX = 0x617800 + (BStore_FreeHead - 1) x 0x100 (BStore_FreeHeadIndex), the free head's block.
BStore_FreeHeadBlockAddr:
	call BStore_FreeHeadIndex                                      ; FBAE2A  1d 3b ae fb
	ld XIX,0x00617800                                    ; FBAE2E  44 00 78 61 00
	ldw bc, 0x0100                                       ; FBAE33  31 00 01
	mul xwa, bc                                         ; FBAE36  d9 40
	add XIX,XWA                                          ; FBAE38  e8 84
	ret                                                  ; FBAE3A  0e
; BStore_FreeHeadIndex: WA = BStore_FreeHead - 1, or 0 when it is 0: the number of blocks before the free head.
BStore_FreeHeadIndex:
	xor XWA,XWA                                          ; FBAE3B  e8 d0
	ld wa, (BStore_FreeHead:24)                                ; FBAE3D  d2 b8 34 60 20
	cp wa, 0x00:i3                                         ; FBAE42  d8 d8
	jr z, .LFBAE48                                       ; FBAE44  66 02
	dec 1,WA                                             ; FBAE46  d8 69
.LFBAE48:
	ret                                                  ; FBAE48  0e
; BStore_RelocateBlockNumber: adds WA to the word at (XIX) unless it is 0 or 0xFFFF (no block / end of chain).
BStore_RelocateBlockNumber:
	ld HL,(XIX)                                          ; FBAE49  94 23
	cp HL,0xffff                                         ; FBAE4B  db cf ff ff
	jr z, .LFBAE59                                       ; FBAE4F  66 08
	cp hl, 0x00:i3                                         ; FBAE51  db d8
	jr z, .LFBAE59                                       ; FBAE53  66 04
	add HL,WA                                            ; FBAE55  d8 83
	ld (XIX),HL                                          ; FBAE57  b4 53
.LFBAE59:
	ret                                                  ; FBAE59  0e
; SeqFile_Save: DiskSave_Sequencer's body (T_SeqFile_Save, through SeqFile_Save_SaveRegs).  Content type ALL -> SeqFile_SaveAllBanks.
;   Otherwise: workspace -> its bank copy; bank Disk_SeqBank's copy -> staging 0x609400, all-banks flag +4 = 0;
;   each in-use directory entry's chain (+0x100, stride 3, bit 7) is counted and renumbered from 1 in order, the
;   running total stored at +0x7E + 2k and x 16 at +0x52; the SQF is written (Disk_SaveSqfFromStaging_Entry);
;   then, if (total, or 4) x 16 paragraphs fit on the disk (result 7 if not), SeqFile_WriteSeqCompacted.
SeqFile_Save:
	push XIZ                                             ; FBAE5A  3e
	push XIX                                             ; FBAE5B  3c
	push XHL                                             ; FBAE5C  3b
	push XDE                                             ; FBAE5D  3a
	cp	(Disk_ContentType:16), 0x00                            ; FBAE5E  c1 25 27 3f 00
	jr nz, .LFBAE6C                                      ; FBAE63  6e 07
	call SeqFile_SaveAllBanks                                      ; FBAE65  1d d5 b2 fb
	jrl .LFBAF3D                                         ; FBAE69  78 d1 00
.LFBAE6C:
	ld a, (BStore_CurrentBank:16)                                   ; FBAE6C  c1 0a 36 21
	cp (Disk_SeqBank:16), a                                    ; FBAE70  c1 2b 27 f9
	jr nz, .LFBAE7F                                      ; FBAE74  6e 09
	ld xwa, (0x360c:16)                                 ; FBAE76  e1 0c 36 20
	ld (0x60341e:24), xwa                               ; FBAE7A  f2 1e 34 60 60
.LFBAE7F:
	ld XIY,0x00603400                                    ; FBAE7F  45 00 34 60 00
	call BStore_CurrentBankCopyAddr                                      ; FBAE84  1d c3 b0 fb
	ldir85                                               ; FBAE88  85 11
	ld XIX,0x00609400                                    ; FBAE8A  44 00 94 60 00
	call BStore_DiskBankCopyAddr                                      ; FBAE8F  1d d6 b0 fb
	ldir85                                               ; FBAE93  85 11
	ld (0x609404:24), 0x00                             ; FBAE95  f2 04 94 60 00 00
	ld XIY,0x00609500                                    ; FBAE9B  45 00 95 60 00
	ld XIX,0x0060947e                                    ; FBAEA0  44 7e 94 60 00
	xor WA,WA                                            ; FBAEA5  d8 d0
	ld (0x23bc:16), wa                                  ; FBAEA7  f1 bc 23 50
	ld (0x23be:16), wa                                  ; FBAEAB  f1 be 23 50
	ldw bc, 0x11                                         ; FBAEAF  31 11 00
.LFBAEB2:
	pushw bc                                             ; FBAEB2  29
	ld A,(XIY)                                           ; FBAEB3  85 21
	and A,0x80                                           ; FBAEB5  c9 cc 80
	jr z, .LFBAEE9                                       ; FBAEB8  66 2f
	xor XWA,XWA                                          ; FBAEBA  e8 d0
	ld WA,(XIY+0x01)                                     ; FBAEBC  9d 01 20
.LFBAEBF:
	incw 0x01, (0x23bc:16)                               ; FBAEBF  d1 bc 23 61
	push XIX                                             ; FBAEC3  3c
	call BStore_BlockAddr                                      ; FBAEC4  1d 35 b1 fb
	ld WA,(XIX+0x03)                                     ; FBAEC8  9c 03 20
	pop XIX                                              ; FBAECB  5c
	cp WA,0xffff                                         ; FBAECC  d8 cf ff ff
	jr nz, .LFBAEBF                                      ; FBAED0  6e ed
	ld wa, (0x23be:16)                                 ; FBAED2  d1 be 23 20
	inc 1,WA                                             ; FBAED6  d8 61
	ld (XIY+0x01),WA                                     ; FBAED8  bd 01 50
	ld bc, (0x23bc:16)                                 ; FBAEDB  d1 bc 23 21
	ld (XIX),BC                                          ; FBAEDF  b4 51
	ld wa, (0x23bc:16)                                 ; FBAEE1  d1 bc 23 20
	ld (0x23be:16), wa                                  ; FBAEE5  f1 be 23 50
.LFBAEE9:
	popw bc                                              ; FBAEE9  49
	add XIY,0x00000003                                   ; FBAEEA  ed c8 03 00 00 00
	inc 2,XIX                                            ; FBAEF0  ec 62
	djnz16 bc, .LFBAEB2                                  ; FBAEF2  d9 1c bd
	xor XWA,XWA                                          ; FBAEF5  e8 d0
	ld wa, (0x23bc:16)                                 ; FBAEF7  d1 bc 23 20
	sla wa, 0x04                                         ; FBAEFB  d8 ec 04
	ld XIY,0x00609452                                    ; FBAEFE  45 52 94 60 00
	ld (XIY),WA                                          ; FBAF03  b5 50
	call T_Disk_SaveSqfFromStaging_Entry                                        ; FBAF05  1d 2c 26 f4
	ld a, (Disk_LastError:16)                                   ; FBAF09  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBAF0D  f1 cb 23 41
	cp a, 0x03:i3                                          ; FBAF11  c9 db
	jr nz, .LFBAF3D                                      ; FBAF13  6e 28
	ld wa, (0x23bc:16)                                 ; FBAF15  d1 bc 23 20
	cp wa, 0x00:i3                                         ; FBAF19  d8 d8
	jr nz, .LFBAF20                                      ; FBAF1B  6e 03
	ldw wa, 0x04                                         ; FBAF1D  30 04 00
.LFBAF20:
	sla wa, 0x04                                         ; FBAF20  d8 ec 04
	ld (0x2245:16), wa                                  ; FBAF23  f1 45 22 50
	call T_DiskSave_CheckFreeSpace                                        ; FBAF27  1d e8 25 f4
	cp	(Disk_LastError:16), 0x00                            ; FBAF2B  c1 43 22 3f 00
	jr z, .LFBAF39                                       ; FBAF30  66 07
	ld (0x23cb:16), 0x07                                 ; FBAF32  f1 cb 23 00 07
	jr .LFBAF3D                                          ; FBAF37  68 04
.LFBAF39:
	call SeqFile_WriteSeqCompacted                                      ; FBAF39  1d 42 af fb
.LFBAF3D:
	pop XDE                                              ; FBAF3D  5a
	pop XHL                                              ; FBAF3E  5b
	pop XIX                                              ; FBAF3F  5c
	pop XIZ                                              ; FBAF40  5e
	ret                                                  ; FBAF41  0e
; SeqFile_WriteSeqCompacted: walks bank Disk_SeqBank's 17 directory chains block by block, copying each into a 4-block staging buffer at
;   0x609400 (SeqFile_StageBlock) with its links renumbered (SeqFile_RelinkStagedBlock); every 4 blocks and at
;   the end SeqFile_FlushStagingBlocks, then T_DiskApi_CloseFile_Call.  An empty store: SeqFile_WriteEmptySeq.
SeqFile_WriteSeqCompacted:
	cpw	(0x23bc:16), 0x0000                          ; FBAF42  d1 bc 23 3f 00 00
	jr nz, .LFBAF51                                      ; FBAF48  6e 07
	call SeqFile_WriteEmptySeq                                      ; FBAF4A  1d 7e b0 fb
	jrl .LFBB04E                                         ; FBAF4E  78 fd 00
.LFBAF51:
	call BStore_DiskBankCopyAddr                                      ; FBAF51  1d d6 b0 fb
	add XIY,0x00000101                                   ; FBAF55  ed c8 01 01 00 00
	ld (0x23c0:16), xiy                                 ; FBAF5B  f1 c0 23 65
	xor WA,WA                                            ; FBAF5F  d8 d0
	ld (0x23c9:16), a                                   ; FBAF61  f1 c9 23 41
	ld (0x23c8:16), a                                   ; FBAF65  f1 c8 23 41
	ld (0x23c4:16), wa                                  ; FBAF69  f1 c4 23 50
	incw 0x01, (0x23c4:16)                               ; FBAF6D  d1 c4 23 61
	ld (0x23cc:16), wa                                  ; FBAF71  f1 cc 23 50
	ld (0x23ca:16), a                                   ; FBAF75  f1 ca 23 41
	call SeqFile_ClearStagingBlockFlags                                      ; FBAF79  1d e9 b0 fb
.LFBAF7D:
	or	(0x23ca:16), 0x01                            ; FBAF7D  c1 ca 23 3e 01
	ld xiy, (0x23c0:16)                                 ; FBAF82  e1 c0 23 25
	ld WA,(XIY)                                          ; FBAF86  95 20
	ld (0x23c6:16), wa                                  ; FBAF88  f1 c6 23 50
	cp WA,0xffff                                         ; FBAF8C  d8 cf ff ff
	jr nz, .LFBAFBC                                      ; FBAF90  6e 2a
	ld a, (0x23c9:16)                                   ; FBAF92  c1 c9 23 21
	inc 1,A                                              ; FBAF96  c9 61
	cp A,0x11                                            ; FBAF98  c9 cf 11
	jr z, .LFBAFB1                                       ; FBAF9B  66 14
	ld (0x23c9:16), a                                   ; FBAF9D  f1 c9 23 41
	ld xiy, (0x23c0:16)                                 ; FBAFA1  e1 c0 23 25
	add XIY,0x00000003                                   ; FBAFA5  ed c8 03 00 00 00
	ld (0x23c0:16), xiy                                 ; FBAFAB  f1 c0 23 65
	jr .LFBAF7D                                          ; FBAFAF  68 cc
.LFBAFB1:
	ld a, (0x23c8:16)                                   ; FBAFB1  c1 c8 23 21
	cp a, 0x00:i3                                          ; FBAFB5  c9 d8
	jr nz, .LFBB001                                      ; FBAFB7  6e 48
	jrl .LFBB03D                                         ; FBAFB9  78 81 00
.LFBAFBC:
	call SeqFile_StageBlock                                      ; FBAFBC  1d 1f b1 fb
	xor XWA,XWA                                          ; FBAFC0  e8 d0
	ld wa, (0x23c6:16)                                 ; FBAFC2  d1 c6 23 20
	call BStore_BlockAddr                                      ; FBAFC6  1d 35 b1 fb
	ld WA,(XIX+0x03)                                     ; FBAFCA  9c 03 20
	cp WA,0xffff                                         ; FBAFCD  d8 cf ff ff
	jr z, .LFBAFDF                                       ; FBAFD1  66 0c
	pushw wa                                             ; FBAFD3  28
	call SeqFile_RelinkStagedBlock                                      ; FBAFD4  1d 59 b1 fb
	popw wa                                              ; FBAFD8  48
	ld (0x23c6:16), wa                                  ; FBAFD9  f1 c6 23 50
	jr .LFBB007                                          ; FBAFDD  68 28
.LFBAFDF:
	ld xiy, (0x23c0:16)                                 ; FBAFDF  e1 c0 23 25
	add XIY,0x00000003                                   ; FBAFE3  ed c8 03 00 00 00
	ld (0x23c0:16), xiy                                 ; FBAFE9  f1 c0 23 65
	or	(0x23ca:16), 0x02                            ; FBAFED  c1 ca 23 3e 02
	call SeqFile_RelinkStagedBlock                                      ; FBAFF2  1d 59 b1 fb
	inc 0x01, (0x23c9:16)                                ; FBAFF6  c1 c9 23 61
	cp	(0x23c9:16), 0x11                            ; FBAFFA  c1 c9 23 3f 11
	jr nz, .LFBB007                                      ; FBAFFF  6e 06
.LFBB001:
	call SeqFile_FlushStagingBlocks                                      ; FBB001  1d 4f b0 fb
	jr .LFBB03D                                          ; FBB005  68 36
.LFBB007:
	ld a, (0x23c8:16)                                   ; FBB007  c1 c8 23 21
	inc 1,A                                              ; FBB00B  c9 61
	cp a, 0x04:i3                                          ; FBB00D  c9 dc
	jr z, .LFBB017                                       ; FBB00F  66 06
	ld (0x23c8:16), a                                   ; FBB011  f1 c8 23 41
	jr .LFBB02C                                          ; FBB015  68 15
.LFBB017:
	xor A,A                                              ; FBB017  c9 d1
	ld (0x23c8:16), a                                   ; FBB019  f1 c8 23 41
	call SeqFile_FlushStagingBlocks                                      ; FBB01D  1d 4f b0 fb
	cp	(Disk_LastError:16), 0x03                            ; FBB021  c1 43 22 3f 03
	jr nz, .LFBB03D                                      ; FBB026  6e 15
	call SeqFile_ClearStagingBlockFlags                                      ; FBB028  1d e9 b0 fb
.LFBB02C:
	ld a, (0x23ca:16)                                   ; FBB02C  c1 ca 23 21
	and A,0x02                                           ; FBB030  c9 cc 02
	jr z, .LFBAFBC                                       ; FBB033  66 87
	and	(0x23ca:16), 0xfd                            ; FBB035  c1 ca 23 3c fd
	jrl .LFBAF7D                                         ; FBB03A  78 40 ff
.LFBB03D:
	and	(0x23ca:16), 0xfd                            ; FBB03D  c1 ca 23 3c fd
	call T_DiskApi_CloseFile_Call                                        ; FBB042  1d e4 25 f4
	ld a, (Disk_LastError:16)                                   ; FBB046  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBB04A  f1 cb 23 41
.LFBB04E:
	ret                                                  ; FBB04E  0e
; SeqFile_FlushStagingBlocks: writes the staging buffer: the first time ((0x23CC) = 0) after SeqFile_SetSeqStagingWindow with Disk_Flags
;   bit 5 set, later times with bit 1 set; (0x23CC) += 1.
SeqFile_FlushStagingBlocks:
	cpw	(0x23cc:16), 0x0000                          ; FBB04F  d1 cc 23 3f 00 00
	jr nz, .LFBB06B                                      ; FBB055  6e 14
	call SeqFile_SetSeqStagingWindow                                      ; FBB057  1d a1 b0 fb
	or	(Disk_Flags:16), 0x20                            ; FBB05B  c1 e7 21 3e 20
	call T_DiskApi_WriteFileFromWindow_Entry                                        ; FBB060  1d ac 25 f4
	and	(Disk_Flags:16), 0xdf                            ; FBB064  c1 e7 21 3c df
	jr .LFBB079                                          ; FBB069  68 0e
.LFBB06B:
	or	(Disk_Flags:16), 0x02                            ; FBB06B  c1 e7 21 3e 02
	call T_DiskApi_WriteFileFromWindow_Entry                                        ; FBB070  1d ac 25 f4
	and	(Disk_Flags:16), 0xfd                            ; FBB074  c1 e7 21 3c fd
.LFBB079:
	incw 0x01, (0x23cc:16)                               ; FBB079  d1 cc 23 61
	ret                                                  ; FBB07D  0e
; SeqFile_WriteEmptySeq: four staging blocks cleared (SeqFile_ClearStagingBlockFlags) and linked (SeqFile_LinkStagingBlocks), written
;   as a 0x400-byte SEQ file.
SeqFile_WriteEmptySeq:
	call SeqFile_ClearStagingBlockFlags                                      ; FBB07E  1d e9 b0 fb
	call SeqFile_LinkStagingBlocks                                      ; FBB082  1d ff b0 fb
	call SeqFile_SetSeqStagingWindow                                      ; FBB086  1d a1 b0 fb
	and	(Disk_Flags:16), 0xdf                            ; FBB08A  c1 e7 21 3c df
	and	(Disk_Flags:16), 0xfd                            ; FBB08F  c1 e7 21 3c fd
	call T_DiskApi_WriteFileFromWindow_Entry                                        ; FBB094  1d ac 25 f4
	ld a, (Disk_LastError:16)                                   ; FBB098  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBB09C  f1 cb 23 41
	ret                                                  ; FBB0A0  0e
; SeqFile_SetSeqStagingWindow: Disk_WindowStart / End = 0x609400 / 0x6097FF (four blocks), extension SEQ.
SeqFile_SetSeqStagingWindow:
	ld XWA,0x00609400                                    ; FBB0A1  40 00 94 60 00
	ld (Disk_WindowStart:16), xwa                                 ; FBB0A6  f1 d3 21 60
	ld XWA,0x006097ff                                    ; FBB0AA  40 ff 97 60 00
	ld (Disk_WindowEnd:16), xwa                                 ; FBB0AF  f1 d7 21 60
	ld (Disk_FileName+8:16), 0x53                                 ; FBB0B3  f1 d0 21 00 53
	ld (Disk_FileName+9:16), 0x45                                 ; FBB0B8  f1 d1 21 00 45
	ld (Disk_FileName+10:16), 0x51                                 ; FBB0BD  f1 d2 21 00 51
	ret                                                  ; FBB0C2  0e
; BStore_CurrentBankCopyAddr: XIX = 0x610000 + BStore_CurrentBank x 0xC00, the current bank's copy of the workspace.
BStore_CurrentBankCopyAddr:
	ld XIX,0x00610000                                    ; FBB0C3  44 00 00 61 00
	xor XWA,XWA                                          ; FBB0C8  e8 d0
	ld a, (BStore_CurrentBank:16)                                   ; FBB0CA  c1 0a 36 21
	ldw bc, 0x0c00                                       ; FBB0CE  31 00 0c
	mul xwa, bc                                         ; FBB0D1  d9 40
	add XIX,XWA                                          ; FBB0D3  e8 84
	ret                                                  ; FBB0D5  0e
; BStore_DiskBankCopyAddr: XIY = 0x610000 + Disk_SeqBank x 0xC00, the copy of the bank the disk screen selected.
BStore_DiskBankCopyAddr:
	ld XIY,0x00610000                                    ; FBB0D6  45 00 00 61 00
	xor XWA,XWA                                          ; FBB0DB  e8 d0
	ld a, (Disk_SeqBank:16)                                   ; FBB0DD  c1 2b 27 21
	ldw bc, 0x0c00                                       ; FBB0E1  31 00 0c
	mul xwa, bc                                         ; FBB0E4  d9 40
	add XIY,XWA                                          ; FBB0E6  e8 85
	ret                                                  ; FBB0E8  0e
; SeqFile_ClearStagingBlockFlags: flags byte +0 = 0 in the four staging blocks at 0x609400.
SeqFile_ClearStagingBlockFlags:
	ld XIX,0x00609400                                    ; FBB0E9  44 00 94 60 00
	xor A,A                                              ; FBB0EE  c9 d1
	ldw bc, 0x04                                         ; FBB0F0  31 04 00
.LFBB0F3:
	ld (XIX),A                                           ; FBB0F3  b4 41
	add XIX,0x00000100                                   ; FBB0F5  ec c8 00 01 00 00
	djnz16 bc, .LFBB0F3                                  ; FBB0FB  d9 1c f5
	ret                                                  ; FBB0FE  0e
; SeqFile_LinkStagingBlocks: staging block k (0..3): previous = k, next = k+2 -- the links of block k+1 of a 1-based chain.
SeqFile_LinkStagingBlocks:
	ld XIX,0x00609401                                    ; FBB0FF  44 01 94 60 00
	xor WA,WA                                            ; FBB104  d8 d0
	ldw hl, 0x02                                         ; FBB106  33 02 00
	ldw bc, 0x04                                         ; FBB109  31 04 00
.LFBB10C:
	ld (XIX),WA                                          ; FBB10C  b4 50
	ld (XIX+0x02),HL                                     ; FBB10E  bc 02 53
	inc 1,WA                                             ; FBB111  d8 61
	inc 1,HL                                             ; FBB113  db 61
	add XIX,0x00000100                                   ; FBB115  ec c8 00 01 00 00
	djnz16 bc, .LFBB10C                                  ; FBB11B  d9 1c ee
	ret                                                  ; FBB11E  0e
; SeqFile_StageBlock: copies block (0x23C6) (BStore_BlockAddr) into staging slot (0x23C8) (SeqFile_StagingSlotAddr), 0x100 bytes.
SeqFile_StageBlock:
	xor XWA,XWA                                          ; FBB11F  e8 d0
	ld wa, (0x23c6:16)                                 ; FBB121  d1 c6 23 20
	call BStore_BlockAddr                                      ; FBB125  1d 35 b1 fb
	ld XIY,XIX                                           ; FBB129  ec 8d
	call SeqFile_StagingSlotAddr                                      ; FBB12B  1d 46 b1 fb
	ldw bc, 0x0100                                       ; FBB12F  31 00 01
	ldir85                                               ; FBB132  85 11
	ret                                                  ; FBB134  0e
; BStore_BlockAddr: XIX = 0x617800 + (WA - 1) x 0x100 for the 1-based block number WA -- BStore_SeekBlock's arithmetic with the
;   heap base as a literal.
BStore_BlockAddr:
	extz XWA                                             ; FBB135  e8 12
	dec 1,WA                                             ; FBB137  d8 69
	ld XIX,0x00617800                                    ; FBB139  44 00 78 61 00
	ldw bc, 0x0100                                       ; FBB13E  31 00 01
	mul xwa, bc                                         ; FBB141  d9 40
	add XIX,XWA                                          ; FBB143  e8 84
	ret                                                  ; FBB145  0e
; SeqFile_StagingSlotAddr: XIX = 0x609400 + (0x23C8) x 0x100.
SeqFile_StagingSlotAddr:
	ld XIX,0x00609400                                    ; FBB146  44 00 94 60 00
	xor XWA,XWA                                          ; FBB14B  e8 d0
	ld a, (0x23c8:16)                                   ; FBB14D  c1 c8 23 21
	ldw bc, 0x0100                                       ; FBB151  31 00 01
	mul xwa, bc                                         ; FBB154  d9 40
	add XIX,XWA                                          ; FBB156  e8 84
	ret                                                  ; FBB158  0e
; SeqFile_RelinkStagedBlock: the staged block becomes number (0x23C4): previous = 0 when it opens a chain ((0x23CA) bit 0), else
;   number-1; next = 0xFFFF when it closes one (bit 1), else number+1; (0x23C4) += 1.
SeqFile_RelinkStagedBlock:
	call SeqFile_StagingSlotAddr                                      ; FBB159  1d 46 b1 fb
	ld wa, (0x23c4:16)                                 ; FBB15D  d1 c4 23 20
	ld h, (0x23ca:16)                                   ; FBB161  c1 ca 23 26
	and H,0x01                                           ; FBB165  ce cc 01
	jr z, .LFBB176                                       ; FBB168  66 0c
	and	(0x23ca:16), 0xfe                            ; FBB16A  c1 ca 23 3c fe
	ldw	(xix+1), 0x0000                              ; FBB16F  bc 01 02 00 00
	jr .LFBB17D                                          ; FBB174  68 07
.LFBB176:
	ld BC,WA                                             ; FBB176  d8 89
	dec 1,BC                                             ; FBB178  d9 69
	ld (XIX+0x01),BC                                     ; FBB17A  bc 01 51
.LFBB17D:
	ld h, (0x23ca:16)                                   ; FBB17D  c1 ca 23 26
	and H,0x02                                           ; FBB181  ce cc 02
	jr z, .LFBB18D                                       ; FBB184  66 07
	ldw	(xix+3), 0xffff                              ; FBB186  bc 03 02 ff ff
	jr .LFBB194                                          ; FBB18B  68 07
.LFBB18D:
	ld BC,WA                                             ; FBB18D  d8 89
	inc 1,BC                                             ; FBB18F  d9 61
	ld (XIX+0x03),BC                                     ; FBB191  bc 03 51
.LFBB194:
	incw 0x01, (0x23c4:16)                               ; FBB194  d1 c4 23 61
	ret                                                  ; FBB198  0e
; SeqFile_ProbeSqfHeader: reads the SQF's first 0x600 bytes to 0x609400.  A = 1 when word +5 is 4 and byte +4 is 1 (all banks:
;   SeqFile_SaveAllBanks writes +4 = 1), 0 when word +5 is 4 otherwise, 2 when the read fails (result = the
;   error, or 1 for content type ALL), 3 when word +5 is not 4 (result 0x10).
SeqFile_ProbeSqfHeader:
	ld XWA,0x00609400                                    ; FBB199  40 00 94 60 00
	ld (Disk_WindowStart:16), xwa                                 ; FBB19E  f1 d3 21 60
	add XWA,0x00000600                                   ; FBB1A2  e8 c8 00 06 00 00
	ld (Disk_WindowEnd:16), xwa                                 ; FBB1A8  f1 d7 21 60
	ld (Disk_FileName+8:16), 0x53                                 ; FBB1AC  f1 d0 21 00 53
	ld (Disk_FileName+9:16), 0x51                                 ; FBB1B1  f1 d1 21 00 51
	ld (Disk_FileName+10:16), 0x46                                 ; FBB1B6  f1 d2 21 00 46
	and	(Disk_Flags:16), 0xdf                            ; FBB1BB  c1 e7 21 3c df
	and	(Disk_Flags:16), 0xfd                            ; FBB1C0  c1 e7 21 3c fd
	call T_DiskApi_ReadFileToWindow_Entry                                        ; FBB1C5  1d a8 25 f4
	cp	(Disk_LastError:16), 0x01                            ; FBB1C9  c1 43 22 3f 01
	jr z, .LFBB1EA                                       ; FBB1CE  66 1a
	cp	(Disk_ContentType:16), 0x00                            ; FBB1D0  c1 25 27 3f 00
	jr nz, .LFBB1DE                                      ; FBB1D5  6e 07
	ld (0x23cb:16), 0x01                                 ; FBB1D7  f1 cb 23 00 01
	jr .LFBB1E6                                          ; FBB1DC  68 08
.LFBB1DE:
	ld a, (Disk_LastError:16)                                   ; FBB1DE  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBB1E2  f1 cb 23 41
.LFBB1E6:
	ld a, 0x02:opc                                          ; FBB1E6  21 02
	jr .LFBB20A                                          ; FBB1E8  68 20
.LFBB1EA:
	ld XIX,0x00609404                                    ; FBB1EA  44 04 94 60 00
	cpw	(xix+1), 0x0004                              ; FBB1EF  9c 01 3f 04 00
	jr nz, .LFBB203                                      ; FBB1F4  6e 0d
	cp (XIX),0x01                                        ; FBB1F6  84 3f 01
	jr z, .LFBB1FF                                       ; FBB1F9  66 04
	ld a, 0x00:opc                                          ; FBB1FB  21 00
	jr .LFBB20A                                          ; FBB1FD  68 0b
.LFBB1FF:
	ld a, 0x01:opc                                          ; FBB1FF  21 01
	jr .LFBB20A                                          ; FBB201  68 07
.LFBB203:
	ld a, 0x03:opc                                          ; FBB203  21 03
	ld (0x23cb:16), 0x10                                 ; FBB205  f1 cb 23 00 10
.LFBB20A:
	ret                                                  ; FBB20A  0e
; SeqFile_LoadAllBanks: reads the SQF as 0x7800 bytes into the ten bank copies at 0x610000 (10 x 0xC00), clears the all-banks flag
;   (0x610004), copies the current bank's copy into the workspace, and reads the SEQ into the heap from 0x617800,
;   (0x603452) x 16 bytes -- or, for an empty store ((0x603452) = 0), sets the free head to 1 and
;   BStore_RebuildFreeChain.  Result -> (0x23CB).
SeqFile_LoadAllBanks:
	ld XWA,0x00610000                                    ; FBB20B  40 00 00 61 00
	ld (Disk_WindowStart:16), xwa                                 ; FBB210  f1 d3 21 60
	add XWA,0x00007800                                   ; FBB214  e8 c8 00 78 00 00
	ld (Disk_WindowEnd:16), xwa                                 ; FBB21A  f1 d7 21 60
	ld XIZ,Disk_FileName+8                                    ; FBB21E  46 d0 21 00 00
	ldw (xiz+), 0x5153                            ; FBB223  f5 f9 02 53 51
	ld (XIZ),0x46                                        ; FBB228  b6 00 46
	ld XIZ,Disk_Flags                                    ; FBB22B  46 e7 21 00 00
	and (XIZ),0xdf                                       ; FBB230  86 3c df
	and (XIZ),0xfd                                       ; FBB233  86 3c fd
	call T_DiskApi_ReadFileToWindow_Entry                                        ; FBB236  1d a8 25 f4
	cp	(Disk_LastError:16), 0x01                            ; FBB23A  c1 43 22 3f 01
	jr z, .LFBB244                                       ; FBB23F  66 03
	jrl .LFBB2CC                                         ; FBB241  78 88 00
.LFBB244:
	ld (0x610004:24), 0x00                             ; FBB244  f2 04 00 61 00 00
	call T_SeqFile_RestoreSavedCurrentBank                                        ; FBB24A  1d c0 14 f4
	call BStore_CurrentBankCopyAddr                                      ; FBB24E  1d c3 b0 fb
	ld XIY,XIX                                           ; FBB252  ec 8d
	ld XIX,0x00603400                                    ; FBB254  44 00 34 60 00
	ldir85                                               ; FBB259  85 11
	call T_Seq_ApplySongBeatsPerBar                                        ; FBB25B  1d c8 0a f4
	cpw	(0x603452:24), 0x0000                        ; FBB25F  d2 52 34 60 3f 00 00
	jr nz, .LFBB275                                      ; FBB266  6e 0d
	ldw (BStore_FreeHead:24), 0x01                             ; FBB268  f2 b8 34 60 02 01 00
	call BStore_RebuildFreeChain                                      ; FBB26F  1d 82 ad fb
	jr .LFBB2C4                                          ; FBB273  68 4f
.LFBB275:
	ld XWA,0x00617800                                    ; FBB275  40 00 78 61 00
	ld (Disk_WindowStart:16), xwa                                 ; FBB27A  f1 d3 21 60
	xor XBC,XBC                                          ; FBB27E  e9 d1
	ld bc, (0x603452:24)                                ; FBB280  d2 52 34 60 21
	sla xbc, 0x04                                        ; FBB285  e9 ec 04
	add XWA,XBC                                          ; FBB288  e9 80
	ld (Disk_WindowEnd:16), xwa                                 ; FBB28A  f1 d7 21 60
	ld XIZ,Disk_FileName+8                                    ; FBB28E  46 d0 21 00 00
	ldw (xiz+), 0x4553                            ; FBB293  f5 f9 02 53 45
	ld (XIZ),0x51                                        ; FBB298  b6 00 51
	ld XIZ,Disk_Flags                                    ; FBB29B  46 e7 21 00 00
	and (XIZ),0xdf                                       ; FBB2A0  86 3c df
	and (XIZ),0xfd                                       ; FBB2A3  86 3c fd
	call T_DiskApi_ReadFileToWindow_Entry                                        ; FBB2A6  1d a8 25 f4
	cp	(Disk_LastError:16), 0x01                            ; FBB2AA  c1 43 22 3f 01
	jr z, .LFBB2B3                                       ; FBB2AF  66 02
	jr .LFBB2CC                                          ; FBB2B1  68 19
.LFBB2B3:
	call T_BStore_RebuildFreeListAfterLoad_Veneer                                        ; FBB2B3  1d b4 14 f4
	ld xwa, (0x360c:16)                                 ; FBB2B7  e1 0c 36 20
	ld (0x60341e:24), xwa                               ; FBB2BB  f2 1e 34 60 60
	call SeqMasterTrack_SetFlagFromTrackMask                                      ; FBB2C0  1d f3 ac fb
.LFBB2C4:
	call	T_F40A34_Zeroed                                ; FBB2C4  1d 34 0a f4
	call T_Seq_RewindAfterSongLoad                                        ; FBB2C8  1d cc 09 f4
.LFBB2CC:
	ld a, (Disk_LastError:16)                                   ; FBB2CC  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBB2D0  f1 cb 23 41
	ret                                                  ; FBB2D4  0e
; SeqFile_SaveAllBanks: needs 0x780 + (0x603452) paragraphs of disk (result 7 if short); workspace -> its bank copy; all-banks flag
;   (0x610004) = 1; writes the ten bank copies as the SQF (0x610000-0x617800), then the SEQ from 0x617800,
;   (0x603452) x 16 bytes, or SeqFile_WriteEmptySeq when that is 0; clears the flag.
SeqFile_SaveAllBanks:
	call T_SeqFile_PrepareSaveAllBanks                                        ; FBB2D5  1d c4 14 f4
	ldw wa, 0x0780                                       ; FBB2D9  30 80 07
	add wa, (0x603452:24)                            ; FBB2DC  d2 52 34 60 80
	ld (0x2245:16), wa                                  ; FBB2E1  f1 45 22 50
	call T_DiskSave_CheckFreeSpace                                        ; FBB2E5  1d e8 25 f4
	cp	(Disk_LastError:16), 0x00                            ; FBB2E9  c1 43 22 3f 00
	jr z, .LFBB2F8                                       ; FBB2EE  66 08
	ld (0x23cb:16), 0x07                                 ; FBB2F0  f1 cb 23 00 07
	jrl .LFBB38B                                         ; FBB2F5  78 93 00
.LFBB2F8:
	ld XIY,0x00603400                                    ; FBB2F8  45 00 34 60 00
	call BStore_CurrentBankCopyAddr                                      ; FBB2FD  1d c3 b0 fb
	ldir85                                               ; FBB301  85 11
	ld (0x610004:24), 0x01                             ; FBB303  f2 04 00 61 00 01
	ld XWA,0x00610000                                    ; FBB309  40 00 00 61 00
	ld (Disk_WindowStart:16), xwa                                 ; FBB30E  f1 d3 21 60
	add XWA,0x00007800                                   ; FBB312  e8 c8 00 78 00 00
	ld (Disk_WindowEnd:16), xwa                                 ; FBB318  f1 d7 21 60
	ld XIZ,Disk_FileName+8                                    ; FBB31C  46 d0 21 00 00
	ldw (xiz+), 0x5153                            ; FBB321  f5 f9 02 53 51
	ld (XIZ),0x46                                        ; FBB326  b6 00 46
	ld XIZ,Disk_Flags                                    ; FBB329  46 e7 21 00 00
	and (XIZ),0xdf                                       ; FBB32E  86 3c df
	and (XIZ),0xfd                                       ; FBB331  86 3c fd
	call T_DiskApi_WriteFileFromWindow_Entry                                        ; FBB334  1d ac 25 f4
	cp	(Disk_LastError:16), 0x03                            ; FBB338  c1 43 22 3f 03
	jr nz, .LFBB383                                      ; FBB33D  6e 44
	ld bc, (0x603452:24)                                ; FBB33F  d2 52 34 60 21
	cp bc, 0x00:i3                                         ; FBB344  d9 d8
	jr nz, .LFBB34E                                      ; FBB346  6e 06
	call SeqFile_WriteEmptySeq                                      ; FBB348  1d 7e b0 fb
	jr .LFBB38B                                          ; FBB34C  68 3d
.LFBB34E:
	ld XWA,0x00617800                                    ; FBB34E  40 00 78 61 00
	ld (Disk_WindowStart:16), xwa                                 ; FBB353  f1 d3 21 60
	xor XBC,XBC                                          ; FBB357  e9 d1
	ld bc, (0x603452:24)                                ; FBB359  d2 52 34 60 21
	sla xbc, 0x04                                        ; FBB35E  e9 ec 04
	add XWA,XBC                                          ; FBB361  e9 80
	ld (Disk_WindowEnd:16), xwa                                 ; FBB363  f1 d7 21 60
	ld XIZ,Disk_FileName+8                                    ; FBB367  46 d0 21 00 00
	ldw (xiz+), 0x4553                            ; FBB36C  f5 f9 02 53 45
	ld (XIZ),0x51                                        ; FBB371  b6 00 51
	ld XIZ,Disk_Flags                                    ; FBB374  46 e7 21 00 00
	and (XIZ),0xdf                                       ; FBB379  86 3c df
	and (XIZ),0xfd                                       ; FBB37C  86 3c fd
	call T_DiskApi_WriteFileFromWindow_Entry                                        ; FBB37F  1d ac 25 f4
.LFBB383:
	ld a, (Disk_LastError:16)                                   ; FBB383  c1 43 22 21
	ld (0x23cb:16), a                                   ; FBB387  f1 cb 23 41
.LFBB38B:
	ld (0x610004:24), 0x00                             ; FBB38B  f2 04 00 61 00 00
	ret                                                  ; FBB391  0e
; BStore_GetDiskBankPassword: gathers word +0x1C of the ten bank copies (0x61001C + n x 0xC00) into 0x60A000[n], the live workspace's
;   (0x60341C) for the current bank, and returns bank Disk_SeqBank's in (0x23CE).  Thunk T_BStore_GetDiskBankPassword.
BStore_GetDiskBankPassword:
	ldw bc, 0x0a                                         ; FBB392  31 0a 00
	ld XIY,0x0061001c                                    ; FBB395  45 1c 00 61 00
	ld XIX,0x0060a000                                    ; FBB39A  44 00 a0 60 00
.LFBB39F:
	ld HL,(XIY)                                          ; FBB39F  95 23
	ld (XIX),HL                                          ; FBB3A1  b4 53
	add XIY,0x00000c00                                   ; FBB3A3  ed c8 00 0c 00 00
	inc 2,XIX                                            ; FBB3A9  ec 62
	djnz16 bc, .LFBB39F                                  ; FBB3AB  d9 1c f1
	ld hl, (BStore_Password:24)                                ; FBB3AE  d2 1c 34 60 23
	ld XIX,0x0060a000                                    ; FBB3B3  44 00 a0 60 00
	xor XWA,XWA                                          ; FBB3B8  e8 d0
	ld a, (BStore_CurrentBank:16)                                   ; FBB3BA  c1 0a 36 21
	sla xwa, 0x01                                        ; FBB3BE  e8 ec 01
	add XIX,XWA                                          ; FBB3C1  e8 84
	ld (XIX),HL                                          ; FBB3C3  b4 53
	ld XIX,0x0060a000                                    ; FBB3C5  44 00 a0 60 00
	xor XWA,XWA                                          ; FBB3CA  e8 d0
	ld a, (Disk_SeqBank:16)                                   ; FBB3CC  c1 2b 27 21
	sla xwa, 0x01                                        ; FBB3D0  e8 ec 01
	add XIX,XWA                                          ; FBB3D3  e8 84
	ld HL,(XIX)                                          ; FBB3D5  94 23
	ld (DiskSave_StoredPassword:16), hl                                  ; FBB3D7  f1 ce 23 53
	ret                                                  ; FBB3DB  0e
; BStore_GetAnyBankPassword: the same gathering, then (0x23CE) = the first non-zero of the ten, or 0.  Thunk T_BStore_GetAnyBankPassword.
BStore_GetAnyBankPassword:
	ldw bc, 0x0a                                         ; FBB3DC  31 0a 00
	ld XIY,0x0061001c                                    ; FBB3DF  45 1c 00 61 00
	ld XIX,0x0060a000                                    ; FBB3E4  44 00 a0 60 00
.LFBB3E9:
	ld HL,(XIY)                                          ; FBB3E9  95 23
	ld (XIX),HL                                          ; FBB3EB  b4 53
	add XIY,0x00000c00                                   ; FBB3ED  ed c8 00 0c 00 00
	inc 2,XIX                                            ; FBB3F3  ec 62
	djnz16 bc, .LFBB3E9                                  ; FBB3F5  d9 1c f1
	ld hl, (BStore_Password:24)                                ; FBB3F8  d2 1c 34 60 23
	ld XIX,0x0060a000                                    ; FBB3FD  44 00 a0 60 00
	xor XWA,XWA                                          ; FBB402  e8 d0
	ld a, (BStore_CurrentBank:16)                                   ; FBB404  c1 0a 36 21
	sla xwa, 0x01                                        ; FBB408  e8 ec 01
	add XIX,XWA                                          ; FBB40B  e8 84
	ld (XIX),HL                                          ; FBB40D  b4 53
	ldw bc, 0x0a                                         ; FBB40F  31 0a 00
	ld XIX,0x0060a000                                    ; FBB412  44 00 a0 60 00
.LFBB417:
	ld HL,(XIX)                                          ; FBB417  94 23
	cp hl, 0x00:i3                                         ; FBB419  db d8
	jr z, .LFBB423                                       ; FBB41B  66 06
	ld (DiskSave_StoredPassword:16), hl                                  ; FBB41D  f1 ce 23 53
	jr .LFBB42E                                          ; FBB421  68 0b
.LFBB423:
	inc 2,XIX                                            ; FBB423  ec 62
	djnz16 bc, .LFBB417                                  ; FBB425  d9 1c ef
	ldw (DiskSave_StoredPassword:16), 0x00                                ; FBB428  f1 ce 23 02 00 00
.LFBB42E:
	ret                                                  ; FBB42E  0e

; 0xFBB42F-0xFBB7FF -- 977 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 977, 1, 0x0E
