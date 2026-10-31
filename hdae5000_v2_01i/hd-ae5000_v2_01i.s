; =============================================================================
; HD-AE5000 expansion ROM v2.01i  (IC4, 512 KiB at 0x280000)
; =============================================================================
; PORTED from the v2.06i tree (hdae5000/) by scripts/tools/port_hdae5000_version.py,
; then by hand: notes/hdae5000-versions-2026-10-24/README.md lists what differs and
; port-edits/ there holds every hand edit as a script.  Names and routine headers
; are v2.06i's wherever the code is the same.  `make gate` rebuilds this tree
; byte-identical to the v2.01i dump (SHA-1 0160c17baa7b026771872126d8146038a19ef53b).
;
; ADDRESSES AND OBJECT NUMBERS QUOTED IN COMMENTS ARE v2.06i'S unless a comment
;   says otherwise: the comments came with the code.  Most of the v2.01i image lies
;   0x7F2 or 0xB0A bytes below its v2.06i twin (scripts/analysis/hdae5000_version_delta.py),
;   the RAM variables from 0x229DAD up 2 to 0x96 bytes below.  Trust the labels:
;   rebuilt_ROMs/hd-ae5000_v2_01i.llvm.elf and symbols/hdae5000_v2_01i_symbols_reference.txt
;   give every name's v2.01i address.  The UI object section of hdae5000_data_tables.s
;   is the exception: it is generated from this ROM and numbers objects as v2.01i does.
;
; What this tree does not hold -- shared/event_codes.s and the pictures that did not
; change -- comes from hdae5000/ through the build's second -I.
; =============================================================================


	.text

	.include "shared/event_codes.s"

; ----------------------------------------------------------------------------
; RAM variables (the expansion's SRAM 0x200000-0x23FFFF) whose role the code
; shows; each comment names the evidence.  Operands equal to one of these
; addresses were rewritten by scripts/converters/hdae5000_symbolize_ram.py.
; ----------------------------------------------------------------------------
	.equ HDAE5000_RAM_AtaError, 0x200222	; drive error byte: 0 = ok; set by the HDAE5000_ATA_* routines, tested after every disk operation
	.equ HDAE5000_RAM_DirNames, 0x201632	; directory names, 16 B x 120 (HDAE5000_HD_GetBlockInfo block 0)
	.equ HDAE5000_RAM_SongRecords, 0x201db2	; song records, 76 B x 1920 (HDAE5000_HD_GetBlockInfo block 1)
	.equ HDAE5000_RAM_FlsRecords, 0x2257b2	; FLS records, 144 B x 120 (HDAE5000_HD_GetBlockInfo block 2)
	.equ HDAE5000_RAM_ClusterBytes, 0x229c58	; cluster size in bytes (HDAE5000_HD_ParseIdentify)
	.equ HDAE5000_RAM_SectorsPerCluster, 0x229c5c	; 0x20, or 0x40 on drives of >= 0x14DC93 sectors (HD_ParseIdentify)
	.equ HDAE5000_RAM_TablesStartSector, 0x229c64	; first of the 323 filesystem-table sectors, 3908 (HD_ParseIdentify)
	.equ HDAE5000_RAM_FatStartSector, 0x229c68	; 2 (HD_ParseIdentify)
	.equ HDAE5000_RAM_DataStartSector, 0x229c6c	; 4231, cluster 1's first sector (HD_ParseIdentify)
	.equ HDAE5000_RAM_FatEntryCount, 0x229c70	; FAT entries, whole 128-entry sectors (HD_ParseIdentify)
	.equ HDAE5000_RAM_FreeClusters, 0x229c80	; free-cluster count (HDAE5000_HD_CountFreeClusters, WriteFile, FreeChain)
	.equ HDAE5000_RAM_DataSectorCount, 0x229c94	; sectors from DataStartSector to the end (HD_ParseIdentify)
	.equ HDAE5000_RAM_HdInitResult, 0x229d92	; HDAE5000_HD_Init's step code, returned by HDAE5000_Check_HD_Present
	.equ HDAE5000_RAM_HdSignatureOk, 0x229d98	; 1 when sector 1 carries AA55AA55 F4F1F2F3 (HDAE5000_HD_CheckSignature)
	.equ HDAE5000_RAM_WriteProtect, 0x229d99	; "WRITE PROTECTION" of HDAE5000_TitleInfo_Template, 0/1 = OFF/ON
	.equ HDAE5000_RAM_WriteConfirm, 0x229d9a	; "WRITE CONFIRM" of HDAE5000_TitleInfo_Template, 0/1 = OFF/ON
	.equ HDAE5000_RAM_QuickLoadMode, 0x229da9	; "QUICK LOAD MODE" (TitleInfo); one of the six setting bytes of sector 1
	.equ HDAE5000_RAM_LoadByNumberMode, 0x229daa	; "LOAD BY NUMBER MODE" (TitleInfo); sector-1 setting byte
	.equ HDAE5000_RAM_JumpAfterLoad, 0x229dab	; "JUMP AFTER LOAD" (TitleInfo); sector-1 setting byte
	.equ HDAE5000_RAM_SaveOptions, 0x22aa4c	; 12-byte part-selection record of the save options: u16 mask, then flags 0x22AA4E+k (HDAE5000_TypeSel_*)
	.equ HDAE5000_RAM_LbnDigitPos, 0x22aa5c	; load-by-number digit position 0..5 (HDAE5000_Lbn_TypeDigit)
	.equ HDAE5000_RAM_LbnDir, 0x22aa5e	; load-by-number directory number being typed (HDAE5000_Lbn_TypeDigit)
	.equ HDAE5000_RAM_LbnSong, 0x22aa60	; load-by-number song number being typed (HDAE5000_Lbn_TypeDigit)
	.equ HDAE5000_RAM_DeleteOptions, 0x22abe6	; 12-byte part-selection record of the delete options (HDAE5000_DelOpt_*)
	.equ HDAE5000_RAM_SeparateOutputMode, 0x22b2f4	; 0..3 = OFF / DRUMS L/R / BASS+DRUMS MIX / BASS/DRUMS MONO (HDAE5000_SeparateOutput_Apply)
	.equ HDAE5000_RAM_HdStreamBuffer, 0x230ec0	; 0x8000-byte buffer of the streamed file writes/reads (HDAE5000_HD_WriteStream, the part loaders/savers)
	.equ HDAE5000_RAM_HdStreamBufferEnd, 0x238ec0	; end of HdStreamBuffer (HDAE5000_HD_WriteStream)
	.equ HDAE5000_RAM_HdStreamFill, 0x238ec8	; fill pointer into HdStreamBuffer (HDAE5000_HD_WriteOpen/_WriteStream)
	.equ HDAE5000_RAM_HdStreamSlot, 0x238ecc	; the first-cluster slot of the open buffered write (HD_WriteOpen)
	.equ HDAE5000_RAM_HdStreamState, 0x238ed0	; 0 closed, 1 open and nothing written, 2 written (HD_WriteOpen)
	.equ HDAE5000_RAM_PportError, 0x239078	; PC-link error flag, set to 1 by PPORT_RecvByte/SendByte/EndBlock
	.equ HDAE5000_RAM_PportChecksum, 0x2390a0	; 32-bit running sum of the PC-link block in transfer
	.equ HDAE5000_RAM_PportPacket, 0x23910c	; the 256-byte PC-link packet (HDAE5000_PPORT_SendPacket/RecvPacket)
	.equ HDAE5000_RAM_DirPageBase, 0x23a016	; first directory of the list page (HDAE5000_DirList_BuildPage)
	.equ HDAE5000_RAM_FlsPageBase, 0x23a018	; first FLS of the list page (HDAE5000_FlsList_BuildPage)
	.equ HDAE5000_RAM_CurDir, 0x23a01a	; selected directory (HDAE5000_SongScreen_Refresh, Song_PartMask callers)
	.equ HDAE5000_RAM_CurSong, 0x23a01c	; selected song within CurDir (HDAE5000_SongScreen_Refresh)
	.equ HDAE5000_RAM_CurFls, 0x23a01e	; selected FLS (HDAE5000_FlsScreen_Refresh)
	.equ HDAE5000_RAM_SeparateBassPart, 0x23a026	; bass part, 0 = NONE (SeparateBassPartCheck's value; _Apply)
	.equ HDAE5000_RAM_SeparateDrumPart, 0x23a028	; drum part, 0 = NONE (SeparateDrumPartCheck's value; _Apply)
	.equ HDAE5000_RAM_SeparateDrumPartSent, 0x23a02a	; drum part last sent by HDAE5000_SeparateOutput_Apply
	.equ HDAE5000_RAM_SeparateBassPartSent, 0x23a02c	; bass part last sent by HDAE5000_SeparateOutput_Apply
	.equ HDAE5000_RAM_MainWorkspacePtr, 0x23a10c	; the main CPU's workspace; every call into it is (this)->0x0E88 or ->0x0E0A table + offset (init image: 4 bytes after HDAE5000_LyricBoxObj_Init; the object table at 0x027ED2)
	.equ HDAE5000_RAM_LyricJump, 0x229dac	; sector-1 setting byte; handler "LyricJumpEditCheck" returns its address
	.equ HDAE5000_RAM_LyricBuffer, 0x22b430	; the lyric file, 0x5000 bytes: TLhd/TLtr chunks, events from +22 (HDAE5000_Lyrics_ClearBuffer, _ParseEvent)
	.equ HDAE5000_RAM_LyricLines, 0x23a032	; six 40-byte text lines of the lyric window (HDAE5000_Lyrics_FillLines)
	.equ HDAE5000_RAM_LyricLoaded, 0x23a106	; 1 once a lyric file passed its checks (HDAE5000_Lyrics_CheckFile)
	.equ HDAE5000_RAM_LyricBoxObj, 0x23a108	; the open lyric box's object id, 0xFFFFFFFF when closed (HDAE5000_LyricBoxProc); redraw events go to it
	.equ HDAE5000_RAM_LyricPosEvt, 0x230e66	; parameter block of event 0x01CA0004 to the lyric box: +0 sqbtof word, +2 LyricPosStep, +4 LyricPosition (HDAE5000_Frame_Handler)
	.equ HDAE5000_RAM_LyricPosStep, 0x230e68	; (sq_beadt >> 3) + 1 at the last post; a change triggers the next one
	.equ HDAE5000_RAM_LyricPosition, 0x230e6a	; sqbtof * 12 + (sq_beadt >> 3) + 2: the position HDAE5000_Lyrics_PlayToPosition scales by division / 12
	.equ HDAE5000_RAM_SqSrtcPtr, 0x230e70	; address of the main CPU's sqsrtc byte (HamaFn_GetAdr_sqsrtc = 0x0421, HDAE5000_Boot_Init); HDAE5000_Frame_Handler watches its bit 2
	.equ HDAE5000_RAM_SqSrtcBit2Prev, 0x230e74	; bit 2 of sqsrtc at the previous frame (HDAE5000_Frame_Handler_Status)
	.equ HDAE5000_RAM_SqBtofPtr, 0x230e76	; address of the main CPU's sqbtof word (HamaFn_GetAdr_sqbtof = 0x041C, HDAE5000_Boot_Init)
	.equ HDAE5000_RAM_SqBeadtPtr, 0x230e7a	; address of the main CPU's sq_beadt byte (HamaFn_GetAdr_sq_beadt = 0x041B, HDAE5000_Boot_Init)
	.equ HDAE5000_RAM_HdPresent, 0x230e7e	; HDAE5000_Check_HD_Present's result (HDAE5000_Boot_Init; HDAE5000_Get_Init_Flag)
	.equ HDAE5000_RAM_FdLyricNames, 0x230828	; 40 x 9-byte base names of the *.TLX files on the floppy, sorted (HDAE5000_FdLyricList_AddTlx)
	.equ HDAE5000_RAM_FdLyricTitles, 0x23099a	; 40 x 27 bytes: the first 26 bytes of each <name>.TTX (HDAE5000_FdLyricList_Scan)
	.equ HDAE5000_RAM_FdLyricHasMid, 0x230dee	; 40 flags: <name>.MID opens (HDAE5000_FdLyricList_Scan)
	.equ HDAE5000_RAM_FdLyricCount, 0x230e16	; entries in FdLyricNames, at most 40 (HDAE5000_FdLyricList_AddTlx)
	.equ HDAE5000_RAM_FdVolumeLabel, 0x230e1e	; the floppy's volume label (HamaFn_GetVolumeLabel) + " ->" (HDAE5000_FdLyricList_Scan)
	.equ HDAE5000_RAM_PportLinkActive, 0x238fa4	; 1 while the PC-link context exists (HDAE5000_PPORT_StartLink sets it; _ReturnToLink / _Reset clear it); HDAE5000_PPORT_ServicePending tests it
	.equ HDAE5000_RAM_PportLinkSp, 0x238fa6	; the PC-link context's saved XSP (HDAE5000_PPORT_YieldToMain stores, HDAE5000_PPORT_SwitchToLink loads)
	.equ HDAE5000_RAM_PportMainSp, 0x238faa	; the main context's saved XSP (HDAE5000_PPORT_SwitchToLink stores, HDAE5000_PPORT_YieldToMain loads)
	.equ HDAE5000_RAM_PportService, 0x238fae	; word: service number posted by HDAE5000_PPORT_CallService (its WA); the service's HL result after HDAE5000_PPORT_ServiceDispatch; 0xFFFF once the link has ended
	.equ HDAE5000_RAM_PportServiceArgBc, 0x238fb0	; XBC argument of the posted service (HDAE5000_PPORT_CallService)
	.equ HDAE5000_RAM_PportServiceArgDe, 0x238fb4	; XDE argument of the posted service (HDAE5000_PPORT_CallService)
	.equ HDAE5000_RAM_PportServiceRequested, 0x238fb8	; 1 while a posted service waits: HDAE5000_PPORT_CallService sets it before yielding and clears it on return; a yield with it clear means the link program ended
	.equ HDAE5000_RAM_SPrintfCursor, 0x239426	; output pointer of HDAE5000_SPrintf / _VSPrintf; HDAE5000_SPrintf_PutChar stores a byte there, advances it and keeps the string terminated
	.equ HDAE5000_RAM_PrintfPadChar, 0x23942a	; word: the padding character of the conversion in progress, 32 (' ') or 48 ('0' after a 0 flag) (HDAE5000_DoPrintf; HDAE5000_FormatFloat pads with it)
	.equ HDAE5000_RAM_PrintfFloatCount, 0x23942c	; word: characters HDAE5000_FormatFloat has emitted; cleared at its start, added to HDAE5000_DoPrintf's count after it
	.equ HDAE5000_RAM_FltDecDigits, 0x23942e	; 32-byte decimal digit string of HDAE5000_FltDec_Convert / _AddDigit
	.equ HDAE5000_RAM_FltDecMantissa, 0x23944e	; the binary mantissa as byte-wide u16 limbs (HDAE5000_FltDec_Convert)
	.equ HDAE5000_RAM_FltDecFraction, 0x23948e	; 10-limb fraction work area (HDAE5000_FltDec_FractionDigits / _FracMulBy10)
	.equ HDAE5000_RAM_PportLinkStackTop, 0x23fffc	; top of the PC-link context's stack; HDAE5000_PPORT_StartLink plants HDAE5000_PPORT_LinkEntry there as its first return address
	.equ HDAE5000_IO_AtaData, 0x130010	; ATA data register (16-bit sector data, HDAE5000_ATA_ReadSector / _WriteSector / _Identify)
	.equ HDAE5000_IO_AtaFeatures, 0x130012	; ATA features / error register; 0xFF before STANDBY IMMEDIATE and IDENTIFY DEVICE
	.equ HDAE5000_IO_AtaSectorCount, 0x130014	; ATA sector count; 1 for every read and write
	.equ HDAE5000_IO_AtaSectorNumber, 0x130016	; ATA sector number (CHS) of HDAE5000_ATA_ReadSector / _WriteSector
	.equ HDAE5000_IO_AtaCylinderLow, 0x130018	; ATA cylinder, low byte
	.equ HDAE5000_IO_AtaCylinderHigh, 0x13001a	; ATA cylinder, high byte
	.equ HDAE5000_IO_AtaDriveHead, 0x13001c	; ATA drive/head; 0xA0 = master + head 0
	.equ HDAE5000_IO_AtaStatusCommand, 0x13001e	; ATA status (read) / command (write)
	.equ HDAE5000_IO_PpiPortA, 0x160000	; 8255 port A: the PC-link data byte (HDAE5000_PPORT_SendByte writes, _RecvByte reads; HDAE5000_PPI_LoopbackByte reads it back)
	.equ HDAE5000_IO_PpiPortB, 0x160002	; 8255 port B: PC-link strobe in bit 3 (HDAE5000_PPORT_SendByte)
	.equ HDAE5000_IO_PpiPortC, 0x160004	; 8255 port C: PC-link handshake inputs, bit 0 ready, bit 1 ack, bit 2 link present (HDAE5000_PPORT_SendByte)
	.equ HDAE5000_IO_PpiControl, 0x160006	; 8255 control word: 0x90 = mode 0, port A input (HDAE5000_PPI_Init); 0x89 = port A output, port C low nibble input (HDAE5000_PPORT_InitPort / _CommandLoop)
	.equ HDAE5000_RAM_DirListText, 0x22a0d0	; 24 rows x 21 bytes + NUL: "NNN:" and the 16-byte directory name at +4 (HDAE5000_DirList_BuildPage)
	.equ HDAE5000_RAM_PartListText, 0x22b274	; nine 14-byte tab-ended part names + NUL (0x7F bytes), HDAE5000_PartList_Build
	.equ HDAE5000_RAM_HdFreeScanBuffer, 0x200898	; 512-byte FAT sector buffer of HD_FindFreeCluster
	.equ HDAE5000_RAM_HdFatCache, 0x200a98	; 512-byte cache of one FAT sector (HD_FatSetEntry / _FatNextCluster / _FreeChain)
	.equ HDAE5000_RAM_HdXferClusters, 0x229c98	; clusters a write needs: ceil(HdXferBytes / ClusterBytes)
	.equ HDAE5000_RAM_HdFatSetCluster, 0x229c9c	; the cluster whose FAT entry HD_FatSetEntry writes: the chain's last cluster
	.equ HDAE5000_RAM_HdFatSetValue, 0x229ca0	; the value HD_FatSetEntry stores: the next cluster, 0xFFFFFFFE (end of chain) or 0xFFFFFFFF (after a failed cluster write)
	.equ HDAE5000_RAM_HdXferClustersDone, 0x229ca4	; clusters written so far (HD_WriteFile / _AppendFile)
	.equ HDAE5000_RAM_HdFreeCluster, 0x229ca8	; HD_FindFreeCluster's result, 1-based, 0xFFFFFFFD = none; the cluster HD_WriteCluster writes
	.equ HDAE5000_RAM_HdFreeScanOffset, 0x229cac	; byte offset of HD_FindFreeCluster's scan in HdFreeScanBuffer; 512 = load the next FAT sector
	.equ HDAE5000_RAM_HdFreeScanFatSector, 0x229cb0	; FAT sector index of HD_FindFreeCluster's scan
	.equ HDAE5000_RAM_HdFreeScanDiskSector, 0x229cb4	; disk sector of HdFreeScanFatSector (FatStartSector + index)
	.equ HDAE5000_RAM_HdFreeChainStart, 0x229cb8	; first cluster of the chain HD_FreeChain_Worker releases
	.equ HDAE5000_RAM_HdWriteClusterPtr0, 0x229cbc	; HdXferPtr at HD_WriteCluster's entry, put back when a sector write fails
	.equ HDAE5000_RAM_HdWriteClusterSector, 0x229cc0	; sector index within the cluster HD_WriteCluster is writing
	.equ HDAE5000_RAM_HdFreeChainCount, 0x229d24	; clusters HD_FreeChain_Worker has released, added to FreeClusters
	.equ HDAE5000_RAM_HdFatCacheSector, 0x229d28	; index of the FAT sector held in HdFatCache, 0xFFFFFFFF = none
	.equ HDAE5000_RAM_HdXferSlotPtr, 0x229d2c	; pointer to the file's first-cluster slot (XDE of the four transfer routines)
	.equ HDAE5000_RAM_HdChainCluster, 0x229d30	; current cluster of the chain being read (HD_ReadFile / _ReadFileNext) or released (HD_FreeChain_Worker)
	.equ HDAE5000_RAM_HdChainSector, 0x229d34	; sector within HdChainCluster where reading continues (HD_ReadClusterFrom)
	.equ HDAE5000_RAM_HdXferBytes, 0x229d38	; byte count of the transfer (XBC); HD_ReadClusterFrom counts it down
	.equ HDAE5000_RAM_HdSectorBytes, 0x229d3c	; bytes HD_ReadClusterFrom reads from the current sector: 512, or the rest of HdXferBytes in the last one
	.equ HDAE5000_RAM_HdXferPtr, 0x229d40	; buffer pointer of the file transfer in progress (XWA of HD_WriteFile / _AppendFile / _ReadFile / _ReadFileNext); HD_WriteCluster / _ReadClusterFrom advance it 512 per sector
	.equ HDAE5000_RAM_HdFatSector, 0x229d48	; FAT sector index of the entry HD_FatSetEntry / _FatNextCluster address: (cluster - 1) / 128
	.equ HDAE5000_RAM_HdFatEntryOffset, 0x229d4c	; byte offset of that entry in its sector: ((cluster - 1) % 128) * 4
	.equ HDAE5000_RAM_HdXferLinkFromPrev, 0x229d94	; 0 for a write's first new cluster, then 1: from the second on, each cluster is linked from HdFatSetCluster (HD_WriteFile / _AppendFile)
	.equ HDAE5000_RAM_HdXferSlotSet, 0x229d95	; 1 once HD_WriteFile has stored the first cluster in *HdXferSlotPtr
	.equ HDAE5000_RAM_HdFreeScanStarted, 0x229d96	; 0 until HD_FindFreeCluster loaded its first FAT sector, then 1 (the step it adds to HdFreeScanFatSector / _DiskSector)
	.equ HDAE5000_RAM_HdWriteClusterError, 0x229d97	; 1 when a sector write of HD_WriteCluster failed
	.equ HDAE5000_RAM_HdDiskFull, 0x229dba	; 1 when HD_FindFreeCluster found no free cluster during a write
	.equ HDAE5000_RAM_HdReadClusterError, 0x229dbc	; 1 when a sector read of HD_ReadClusterFrom failed
	.equ HDAE5000_RAM_HdReadLastSector, 0x229dbd	; 1 when HdXferBytes ran out inside the sector just read
	.equ HDAE5000_IO_AtaDeviceControl, 0x130020	; ATA device control: 0x0E (SRST + nIEN) then 0x0A (nIEN) is HDAE5000_ATA_SoftReset
	.equ HDAE5000_RAM_AtaIdentifyBuffer, 0x200000	; the 512-byte IDENTIFY DEVICE answer (HDAE5000_ATA_IdentifyDevice); HDAE5000_HD_ParseIdentify reads words 27-46 and 54-58
	.equ HDAE5000_RAM_HdSectorsPerHead, 0x200200	; cylinders x sectors per track: the head stride of the CHS split in HDAE5000_ATA_ReadSector / _WriteSector (HD_ParseIdentify)
	.equ HDAE5000_RAM_AtaWriteSectorNo, 0x200204	; 1-based sector number of HDAE5000_ATA_WriteSector (its XHL)
	.equ HDAE5000_RAM_AtaWriteData, 0x200208	; data pointer of HDAE5000_ATA_WriteSector (its XIX)
	.equ HDAE5000_RAM_AtaReadSectorNo, 0x20020c	; 1-based sector number of HDAE5000_ATA_ReadSector (its XHL)
	.equ HDAE5000_RAM_AtaReadData, 0x200210	; buffer pointer of HDAE5000_ATA_ReadSector (its XIX)
	.equ HDAE5000_RAM_AtaReadKeepBytes, 0x200214	; bytes of the sector HDAE5000_ATA_ReadSector stores (its XDE)
	.equ HDAE5000_RAM_AtaWriteHeadBase, 0x200218	; head * HdSectorsPerHead in HDAE5000_ATA_WriteSector's CHS split
	.equ HDAE5000_RAM_AtaReadHeadBase, 0x20021c	; head * HdSectorsPerHead in HDAE5000_ATA_ReadSector's CHS split
	.equ HDAE5000_RAM_HdSectorsPerTrack, 0x200220	; word: IDENTIFY word 56, current sectors per track (HD_ParseIdentify)
	.equ HDAE5000_RAM_HdUsableSectors, 0x200223	; long at an odd address: IDENTIFY words 57-58 (current capacity) - 2 (HD_ParseIdentify)
	.equ HDAE5000_RAM_HdSettingsSector, 0x200628	; 512-byte image of disk sector 1: AA55AA55 F4F1F2F3 signature (HDAE5000_HD_CheckSignature) and the settings (HDAE5000_HD_SaveSettings)
	.equ HDAE5000_RAM_HdModelString, 0x20083c	; 40 bytes: IDENTIFY words 27-46 (model number), byte-swapped (HD_ParseIdentify; HDAE5000_HD_GetGeometry copies it out)
	.equ HDAE5000_RAM_HdCylinders, 0x229c32	; word: IDENTIFY word 54, current cylinders (HD_ParseIdentify)
	.equ HDAE5000_RAM_HdHeads, 0x229c34	; word: IDENTIFY word 55, current heads (HD_ParseIdentify)
	.equ HDAE5000_RAM_HdSectorBuffer, 0x200228	; 512-byte sector buffer: read-back of HD_WriteTables / _ReadTables, the FAT sectors HD_CountFreeClusters scans, HD_Format's zero sector
	.equ HDAE5000_RAM_HdVerifyBuffer, 0x200428	; 512-byte read-back buffer of HD_Format's verify pass
	.equ HDAE5000_RAM_HdVersionKeyWord, 0x229c60	; 0x0000FFEE after HD_ResetVersionKeyWord; HD_CheckVersionKey compares it with HDAE5000_Version_Key
	.equ HDAE5000_RAM_HdTablesSector, 0x229c74	; disk sector of HD_WriteTables / _ReadTables' current table sector
	.equ HDAE5000_RAM_HdTablesPtr, 0x229c78	; RAM pointer of that sector within the tables (from DirNames on)
	.equ HDAE5000_RAM_HdTablesCount, 0x229c7c	; table sectors transferred so far, of 323
	.equ HDAE5000_RAM_HdCountSector, 0x229c84	; FAT sector HD_CountFreeClusters is scanning
	.equ HDAE5000_RAM_HdCountEntries, 0x229c88	; FAT entries HD_CountFreeClusters has scanned
	.equ HDAE5000_RAM_HdFormatSector, 0x229c8c	; disk sector HD_Format_Worker is clearing or verifying
	.equ HDAE5000_RAM_HdFormatCount, 0x229c90	; sectors done in that pass, of 3906
	.equ HDAE5000_RAM_HdUsageData, 0x229d10	; data area in units of 10,000 bytes (HD_ComputeDiskUsage)
	.equ HDAE5000_RAM_HdUsageFree, 0x229d14	; free space in units of 10,000 bytes (HD_ComputeDiskUsage)
	.equ HDAE5000_RAM_HdUsageDrive, 0x229d18	; the drive in units of 10,000 bytes (HD_ComputeDiskUsage)
	.equ HDAE5000_RAM_HdUsageSystem, 0x229d1c	; the system area (sectors before the data area) in units of 10,000 bytes
	.equ HDAE5000_RAM_HdRetries, 0x229d93	; retries left: 7 for HD_WriteTables / _ReadTables, 5 for HD_CountFreeClusters
	.equ HDAE5000_RAM_HdStatusBytes, 0x229dad	; ten bytes HD_ClearStatusBytes zeroes; no reader found
	.equ HDAE5000_RAM_PportInfoBlock, 0x238ed2	; the PC-link info block, 0xD2 bytes: +0 part mask, +2 song name (26), +0x1C directory name (16), +0x2C/+0x34/+0x3C the FGB/FEB/FLS block descriptors (HDAE5000_HD_GetBlockInfo), +0x46 nine-byte part records (service 13), +0x97 drive model (30), +0xB5.. geometry (service 3), +0xCA work buffer address (service 19), +0xCE the slot of the open read
	.equ HDAE5000_RAM_PportReadState, 0x23a110	; 0 no read open, 1 opened by service 24 (ReadOpenHD), 2 reading (service 25 continues with HD_ReadFileNext)
	.equ HDAE5000_RAM_PportArg1, 0x23907a	; byte 1 of the command packet, latched by HDAE5000_PPORT_LatchPacketArgs (stored in a word slot, as are Arg2..4)
	.equ HDAE5000_RAM_PportArg2, 0x23907c	; byte 2 of the command packet (HDAE5000_PPORT_LatchPacketArgs)
	.equ HDAE5000_RAM_PportArg3, 0x23907e	; byte 3 of the command packet (HDAE5000_PPORT_LatchPacketArgs)
	.equ HDAE5000_RAM_PportArg4, 0x239080	; byte 4 of the command packet (HDAE5000_PPORT_LatchPacketArgs)
	.equ HDAE5000_RAM_PportInfoPtr, 0x2390a4	; XIX of service 1 (the address of PportInfoBlock), kept by HDAE5000_PPORT_GetInfoBlock / _CopyInfoToPacket
	.equ HDAE5000_RAM_PportBlockPtr, 0x2390fc	; start of the block HDAE5000_PPORT_SendBlock / _RecvBlock moves; a retry restarts from it
	.equ HDAE5000_RAM_PportBlockLen, 0x239100	; byte count of that block
	.equ HDAE5000_RAM_PportSectorBuffer, 0x23920c	; 512 bytes: a sector received by HDAE5000_PPORT_RecvSector, or read for HDAE5000_PPORT_InitRegionDescriptors_Lookup
	.equ HDAE5000_RAM_PcLinkStatusText, 0x22abc4	; the text of the PC-link page's PP_STATUS object; the status string goes in at +7, at most 25 characters (HDAE5000_PcLink_ShowStatus, service 26)
	.equ HDAE5000_RAM_PportPartMask, 0x239086	; the parts (bits 0-7) a link command works on; InitRegionDescriptors sizes one region per set bit
	.equ HDAE5000_RAM_PportPartMaskHi, 0x239088	; bit 0: the ninth part (TLX), with PportPartMask
	.equ HDAE5000_RAM_PportStepError, 0x23908a	; 1 when a service call of InitRegionDescriptors_Lookup / SendRegionToPc (or a command handler) failed
	.equ HDAE5000_RAM_PportSizeFieldOffset, 0x239090	; byte offset of the size field in a part file's first sector (InitRegionDescriptors -> _Lookup)
	.equ HDAE5000_RAM_PportSizeFieldWidth, 0x239092	; 0x20: that field is a long; 0x10: a word counting 16-byte units
	.equ HDAE5000_RAM_PportSendMaskLo, 0x239094	; low byte of the part mask SendRegionToPc puts in PportInfoBlock+0 before opening the read (service 24)
	.equ HDAE5000_RAM_PportSendMaskHi, 0x239096	; its high byte
	.equ HDAE5000_RAM_PportSectorOffset, 0x23909c	; word: byte offset into PportSectorBuffer while SendRegionToPc sends it; 512 = read the next sector
	.equ HDAE5000_RAM_PportRegions, 0x2390ac	; (address, size) long pairs: SendTwoRegions sends pairs 0 and 1; InitRegionDescriptors stores part sizes in the slots
	.equ HDAE5000_RAM_PportBytesLeft, 0x239108	; bytes SendRegionToPc still has to send
	.equ HDAE5000_RAM_Errno, 0x230e6e	; word: set to 34 (ERANGE) by HDAE5000_Float_Pack / _Double_Pack on overflow
	.equ HDAE5000_RAM_MathErrorHook, 0x23a112	; routine pointer HDAE5000_Float_Pack / _Double_Pack call after setting Errno, when it is non-zero
	.equ HDAE5000_RAM_LyricEvent, 0x230430	; the lyric event just parsed, right after LyricBuffer: +0 word meta type (HDAE5000_Lyrics_ParseEvent stores it, 0x2F = end of track; FindEvent compares it), +4 end-of-track flag, +6 its data (Lyrics_ParseEvent, _FindEvent, _PlayToPosition, _ReadSongInfo)
	.equ HDAE5000_RAM_LyricFileLength, 0x2304f2	; the TLX file's length: the TLtr length (big-endian at LyricBuffer+18) + 22; 0 after HDAE5000_Lyrics_ClearBuffer (Lyrics_CheckTrackChunk, TlxPart_Describe)
	.equ HDAE5000_RAM_RcmStreamDir, 0x238ec2	; directory of the song whose RCM part is streamed (HDAE5000_LoadSong_Rcm / _SaveSong_Rcm; read by HDAE5000_RcmStream_Read / _Write)
	.equ HDAE5000_RAM_RcmStreamSong, 0x238ec4	; song of that RCM stream
	.equ HDAE5000_RAM_RcmStreamResult, 0x238ec6	; word: the last HD result of the RCM stream (HDAE5000_RcmStream_LastResult returns it)
	.equ HDAE5000_RAM_DirBrowserPage, 0x229d9f	; page of the directory browser (unreachable library; HD_Init sets it)
	.equ HDAE5000_RAM_FlsBrowserPage, 0x229da0	; page of the FLS browser (unreachable library; HD_Init sets it)
	.equ HDAE5000_RAM_DirBrowserCursors, 0x229dd8	; 5 cursor bytes, one per directory-browser page (unreachable library)
	.equ HDAE5000_RAM_DirBrowserRowBytes, 0x229ddd	; 120 bytes, one per directory row (unreachable library)
	.equ HDAE5000_RAM_FlsBrowserCursors, 0x229e55	; 5 cursor bytes, one per FLS-browser page (unreachable library)
	.equ HDAE5000_RAM_FlsBrowserRowBytes, 0x229e5a	; 120 bytes, one per FLS row (unreachable library)
	.equ HDAE5000_RAM_DirNameHistory, 0x22abf2	; 5-entry history of directory names: {u8 count, u8 recall index, u8 next slot, pad, 5 x 27 bytes} (HDAE5000_NameHistory_Push / _Recall)
	.equ HDAE5000_RAM_FlsNameHistory, 0x22ad0a	; 5-entry history of FLS names, same layout as DirNameHistory
	.equ HDAE5000_IO_VgaPorts, 0x170000	; the display controller's I/O ports: port N is at this + N (HDAE5000_VGA_Port_Write; 0x3C8 palette index, 0x3C9 palette data)
	.equ HDAE5000_RAM_FdList, 0x22aa9c	; the floppy song list: +0 title text (14), +14 the 20 row texts, +0x100 20 present flags (HDAE5000_FdList_Scan), +0x114 20 selected flags (the copy screen toggles them; HDAE5000_FdList_Redisplay marks those rows "*")
	.equ HDAE5000_RAM_SmfHeader, 0x230e50	; 14 bytes: the header HDAE5000_Smf_ReadHeader reads from a floppy file
	.equ HDAE5000_RAM_SmfFormat, 0x230e5e	; word: SMF format of the checked header, <= 1 (HDAE5000_Smf_CheckHeader)
	.equ HDAE5000_RAM_SmfTrackCount, 0x230e60	; word: its track count
	.equ HDAE5000_RAM_SmfDivision, 0x230e62	; word: its division; bit 15 (SMPTE) must be clear
	.equ HDAE5000_RAM_SongScreenTitle, 0x22a038	; "DIRECTORY NN:<name>" of the song screen (HDAE5000_SongScreen_Refresh)
	.equ HDAE5000_RAM_FlsListText, 0x22a2ca	; 24 rows x 21 bytes + NUL: "NNN:" and the 16-byte FLS name at +4 (HDAE5000_FlsList_BuildPage)
	.equ HDAE5000_RAM_LbnEntryText, 0x22aa62	; the load-by-number entry: digits, directory and song name (HDAE5000_Lbn_ShowEntry)
	.equ HDAE5000_RAM_FormatCodeDigits, 0x22ad9e	; the six digits typed on the HD-format attention dialog (HDAE5000_FormatDialog_CodeDigit)
	.equ HDAE5000_RAM_TitleInfoText, 0x22ada6	; the settings / free-space text of the HD title screen (HDAE5000_TitleInfo_Build)
	.equ HDAE5000_RAM_SongListText, 0x22ae3e	; the 16 song rows of the song screen, 30 bytes each (HDAE5000_SongScreen_Refresh)
	.equ HDAE5000_RAM_NamingText, 0x22a000	; the name being edited in the naming window, up to 32 characters + NUL (OnSetString / OnGetString hand it over)
	.equ HDAE5000_RAM_NamingApFunction, 0x22a022	; the application function of the naming window, NAKA_APFUNC_NamingCheck unless OnSetApFunction set another; asked for the length and fill character
	.equ HDAE5000_RAM_NamingLength, 0x22a026	; word: length of the edited name, at most 32
	.equ HDAE5000_RAM_NamingCursor, 0x22a028	; word: cursor position in the name (OnPositionLeft / OnPositionRight)
	.equ HDAE5000_RAM_NamingSelChar, 0x22a02e	; word: the selected character of the character table (OnPrevCharacter / OnNextCharacter +-1, OnCharacterRowUpDown +-13)
	.equ HDAE5000_RAM_NamingSelCharDrawn, 0x22a030	; word: the selection last drawn, 0xFFFF = none (OnSeleDraw redraws on a change)
	.equ HDAE5000_RAM_NamingFillCharPtr, 0x22a034	; pointer to the character the name is padded with (OnClear, OnInsert, OnDelete, OnCenterName)
	.equ HDAE5000_RAM_FlsItemPageBase, 0x22b272	; word: first item of the FLS item page shown, 0 or 16 (the list's overflow / underflow events switch it)
	.equ HDAE5000_RAM_NameEditBuffer, 0x239ff6	; 16-byte name the naming checks exchange with the naming window (EVT_GET_STRING into it, then HDAE5000_FlsName_StoreWithUi / DirName_...)
	.equ HDAE5000_RAM_CurFlsItem, 0x23a020	; the selected item of the current FLS: FlsItemPageBase + the list selection

; ----------------------------------------------------------------------------
; The main CPU's function tables, as the HD-AE5000 reaches them: workspace
; (= object table 0x027ED2, 14-byte records {id, proc, count, data}) + 0x0E0A
; is the data pointer of table 0x100, + 0x0E88 that of table 0x109.  The
; constant names are the firmware's own, read from the name table the main
; CPU registers beside each function table (0x400 / 0x409); generated by
; scripts/converters/hdae5000_symbolize_fn_tables.py, which checks each
; against original_ROMs/kn5000_v10_program.rom.
; ----------------------------------------------------------------------------
	.equ WS_RootFnTable, 0x0e0a	; 14 * 0x100 + 10: table 0x100 = 0xEAFA6E (InitializeRoot: RegObjTabl 0x1600001, FunctionProc, 0x160, 0xeafa6e, 0x100)
	.equ WS_HamaFnTable, 0x0e88	; 14 * 0x109 + 10: table 0x109 = 0xE1F0EC (InitializeHama: RegObjTablHama 0x1600001, FunctionProc, 0x4b, 0xe1f0ec, 0x109)
	.equ RootFn_UpdateScreen, 0x0084	; -> 0xFAA61D (index 33); v10 build label LcdOff_Epilogue
	.equ RootFn_DrawLine, 0x009c	; -> 0xFAA98A (index 39)
	.equ RootFn_DrawBox, 0x00a4	; -> 0xFAB273 (index 41)
	.equ RootFn_DrawFrame, 0x00a8	; -> 0xFAB3DE (index 42)
	.equ RootFn_MovePixels, 0x00b0	; -> 0xFABA53 (index 44)
	.equ RootFn_DrawString, 0x00c4	; -> 0xFACACA (index 49)
	.equ RootFn_InheritedProc, 0x00dc	; -> 0xFA4409 (index 55)
	.equ RootFn_RegisterObjectTable, 0x00e4	; -> 0xFA42FB (index 57)
	.equ RootFn_SendEvent, 0x0100	; -> 0xFA9660 (index 64)
	.equ RootFn_PostEvent, 0x0104	; -> 0xFA9752 (index 65)
	.equ RootFn_ApPostEvent, 0x0124	; -> 0xFA9D58 (index 73)
	.equ RootFn_ResEventProc, 0x013c	; -> 0xFA58FB (index 79)
	.equ RootFn_ResMethodProc, 0x0140	; -> 0xFA5948 (index 80)
	.equ RootFn_ResNameProc, 0x0148	; -> 0xFA62CB (index 82)
	.equ RootFn_GetCharHeight, 0x0150	; -> 0xFB260A (index 84)
	.equ RootFn_GetCharDescent, 0x0154	; -> 0xFB2617 (index 85)
	.equ RootFn_GetCenteredDelta, 0x0158	; -> 0xFB2624 (index 86)
	.equ RootFn_ConvertStrings, 0x015c	; -> 0xFB2640 (index 87)
	.equ RootFn_ClassProc, 0x0168	; -> 0xFA44E2 (index 90)
	.equ RootFn_FunctionProc, 0x0244	; -> 0xFA48A9 (index 145)
	.equ RootFn_ApFunctionProc, 0x0248	; -> 0xFA496C (index 146)
	.equ RootFn_MainFunctionProc, 0x024c	; -> 0xFA4A18 (index 147)
	.equ RootFn_ApFuncCall, 0x0250	; -> 0xFA49B7 (index 148)
	.equ RootFn_MainFuncCall, 0x0254	; -> 0xFA4A63 (index 149)
	.equ RootFn_RegisterTitle, 0x0270	; -> 0xFA4D80 (index 156)
	.equ RootFn_GetTitleNow, 0x0278	; -> 0xFA5867 (index 158)
	.equ RootFn_ViewableProc, 0x0280	; -> 0xFA5995 (index 160)
	.equ RootFn_SetVisible, 0x0294	; -> 0xFA5E8C (index 165)
	.equ RootFn_GetViewInstance, 0x02c4	; -> 0xFA6266 (index 177)
	.equ RootFn_GetClientBox, 0x02d4	; -> 0xF995DD (index 181)
	.equ RootFn_DrawDesignBox, 0x02dc	; -> 0xFAD559 (index 183)
	.equ RootFn_SetDialEnable, 0x03c4	; -> 0xF9A53B (index 241)
	.equ RootFn_SetDialUp, 0x03c8	; -> 0xF9A579 (index 242)
	.equ RootFn_SetDialDown, 0x03cc	; -> 0xF9A58A (index 243)
	.equ RootFn_SetApTimer, 0x0410	; -> 0xFAA135 (index 260)
	.equ RootFn_KillApTimer, 0x0418	; -> 0xFAA257 (index 262)
	.equ RootFn_SetAutoInc, 0x042c	; -> 0xF9A5BD (index 267)
	.equ RootFn_GetNamingWindowID, 0x050c	; -> 0xFA1FC7 (index 323)
	.equ RootFn_DeleteEvent, 0x0534	; -> 0xFA9868 (index 333)
	.equ RootFn_SleepMainTask, 0x0538	; -> 0xF9883C (index 334)
	.equ RootFn_WakeUpMainTask, 0x053c	; -> 0xF9884B (index 335)
	.equ HamaFn_FDLoadSaveTest, 0x0004	; -> 0xF1E5DA (index 1)
	.equ HamaFn_GetMediaType, 0x0008	; -> 0xF525EC (index 2)
	.equ HamaFn_PreLswLoad, 0x000c	; -> 0xFDB434 (index 3)
	.equ HamaFn_PostLswLoad, 0x0010	; -> 0xFDB43B (index 4)
	.equ HamaFn_PreLswSave, 0x0014	; -> 0xFDB48E (index 5)
	.equ HamaFn_PostLswSave, 0x0018	; -> 0xFDB48F (index 6)
	.equ HamaFn_PrePmLoad, 0x001c	; -> 0xFDB490 (index 7)
	.equ HamaFn_PostPmLoad, 0x0020	; -> 0xFDB491 (index 8)
	.equ HamaFn_PrePmSave, 0x0024	; -> 0xFDB49E (index 9)
	.equ HamaFn_PostPmSave, 0x0028	; -> 0xFDB49F (index 10)
	.equ HamaFn_SeqLoadPre, 0x002c	; -> 0xF47850 (index 11)
	.equ HamaFn_SeqLoadPost, 0x0030	; -> 0xF47858 (index 12)
	.equ HamaFn_SeqSavePre, 0x0034	; -> 0xF47923 (index 13)
	.equ HamaFn_SeqSavePost, 0x0038	; -> 0xF47943 (index 14)
	.equ HamaFn_cmp_ld_mae, 0x003c	; -> 0xF6BC24 (index 15)
	.equ HamaFn_cmp_ld_ato, 0x0040	; -> 0xF6BC2F (index 16)
	.equ HamaFn_cmp_sv_mae, 0x0044	; -> 0xF6BC48 (index 17)
	.equ HamaFn_cmp_sv_ato, 0x0048	; -> 0xF6BC5A (index 18)
	.equ HamaFn_PreTmLoad, 0x004c	; -> 0xFF049F (index 19)
	.equ HamaFn_PostTmLoad, 0x0050	; -> 0xFF04A0 (index 20)
	.equ HamaFn_PreTmSave, 0x0054	; -> 0xFF04E4 (index 21)
	.equ HamaFn_PostTmSave, 0x0058	; -> 0xFF04E5 (index 22)
	.equ HamaFn_msp_ld_mae, 0x005c	; -> 0xF6BC66 (index 23)
	.equ HamaFn_msp_ld_ato, 0x0060	; -> 0xF6BC71 (index 24)
	.equ HamaFn_msp_sv_mae, 0x0064	; -> 0xF6BC82 (index 25)
	.equ HamaFn_msp_sv_ato, 0x0068	; -> 0xF6BC99 (index 26)
	.equ HamaFn_PreMidiLoad, 0x006c	; -> 0xFDB4A0 (index 27)
	.equ HamaFn_PostMidiLoad, 0x0070	; -> 0xFDB4A1 (index 28)
	.equ HamaFn_PreMidiSave, 0x0074	; -> 0xFDB4A2 (index 29)
	.equ HamaFn_PostMidiSave, 0x0078	; -> 0xFDB4A3 (index 30)
	.equ HamaFn_FlashWrite, 0x007c	; -> 0xEF3C3C (index 31)
	.equ HamaFn_GetResouceInfo, 0x0080	; -> 0xF1EA30 (index 32)
	.equ HamaFn_SetSepaOutMode, 0x0084	; -> 0xF1EB30 (index 33)
	.equ HamaFn_GetVolumeLabel, 0x0090	; -> 0xF527CE (index 36)
	.equ HamaFn__findfirst, 0x0094	; -> 0xF5298A (index 37)
	.equ HamaFn__findnext, 0x0098	; -> 0xF52AE8 (index 38)
	.equ HamaFn__findclose, 0x009c	; -> 0xF52AAA (index 39)
	.equ HamaFn_fopen_ext, 0x00a0	; -> 0xF1ED24 (index 40)
	.equ HamaFn_fread_ext, 0x00a8	; -> 0xF1ED2C (index 42)
	.equ HamaFn_fclose_ext, 0x00ac	; -> 0xF1ED30 (index 43)
	.equ HamaFn_rcm_ld_XAPR_j, 0x00b0	; -> 0xF1EB28 (index 44)
	.equ HamaFn_rcm_sv_XAPR_j, 0x00b4	; -> 0xF1EB2C (index 45)
	.equ HamaFn_rot_rdq_X, 0x00b8	; -> 0xF1ED38 (index 46)
	.equ HamaFn_ref_sem_X, 0x00d0	; -> 0xF1ED50 (index 52)
	.equ HamaFn_pdly_tim_X, 0x00e4	; -> 0xF1ED64 (index 57)
	.equ HamaFn_PlayHalt, 0x00e8	; -> 0xF1ED68 (index 58)
	.equ HamaFn_PlayStandBy, 0x00ec	; -> 0xF1EDA8 (index 59)
	.equ HamaFn_EditSwRefresh, 0x00f0	; -> 0xF1EDBE (index 60)
	.equ HamaFn_GetAdr_sqbtof, 0x0100	; -> 0xF1EDE2 (index 64)
	.equ HamaFn_GetAdr_sq_beadt, 0x0104	; -> 0xF1EDE7 (index 65)
	.equ HamaFn_GetAdr_sqsrtc, 0x0108	; -> 0xF1EDEC (index 66)
	.equ HamaFn_sendCOMM, 0x0114	; -> 0xEF32F4 (index 69)
	.equ HamaFn_SwbtWr, 0x0120	; -> 0xFDB255 (index 72)
	.equ HamaFn_SetGlobalError, 0x012c	; -> 0xF1EDF6 (index 75)
	.equ HamaFn_malloc_X, 0x0130	; -> 0xF1EDFB (index 76)
	.equ HamaFn_free_X, 0x0134	; -> 0xF1EE03 (index 77)
	.equ HamaFn_ChangePalette, 0x0138	; -> 0xFAF2C7 (index 78)
	.equ HamaFn_ChangeWall, 0x013c	; -> 0xFAF20B (index 79)

; HD-AE5000 Hard Disk Expansion ROM, v2.01i
;   Version string "V2.01i" (HDAE5000_Str_V201i).  The credits block
;   HDAE5000_Version_Info ("Technics Software section M. Kitajima 2.33J 2.21
;   TECHNICS KN5000 Juli-Oktober 1996") is the same in all four dumped versions.
;   Entry vectors at 0x280008 / 0x280010: jp HDAE5000_Boot_Init, jp
;   HDAE5000_Frame_Handler, as in v2.06i.
;   The ROM layout, the hardware it drives and the PC-link (PPORT) command menu are
;   described in the same place in hdae5000/hd-ae5000_v2_06i.s; this version has
;   the same parts in the same order, at the addresses the symbol file gives.


	.org 0x280000 - 0x280000, 0xFF

; ============================================================================
; ROM HEADER
; ============================================================================

HDAE5000_ROM_HEADER:
	.ascii "XAPR"		; magic identifier ("XAPR" checked by the main CPU)
	.long HDAE5000_Init_Data_End	; the end of the .data image (every version: its own image's end)

; Entry point 1 - Jump to boot initialization
HDAE5000_ENTRY_1:
	jp HDAE5000_Boot_Init	; Called when main CPU validates HDAE5000 presence

; Padding after vector
	ret
	nop
	nop
	nop

; Entry point 2 - Jump to frame handler (called periodically)
HDAE5000_ENTRY_2:
	jp HDAE5000_Frame_Handler	; Called from main loop for HD status updates

; Padding after vector
	ret
	nop
	nop
	nop

; Unused entry vectors (return immediately)
HDAE5000_ENTRY_3:
	ret
	nop
	nop
	nop

HDAE5000_ENTRY_4:
	ret
	nop
	nop
	nop

; ============================================================================
; CODE SECTION 1 (0x280020 - 0x28F575)
;
; Key routines:
;   0x280020  Handler_Registration - Register 11 handlers with main CPU workspace
;   0x28030E  Alloc_Memory_1 - Bitmap resource descriptor, HDAE5000_Bitmap_TitleLogo
;                             (A1 = 0x2A898E bitmap data, not a palette)
;   0x28033B  Alloc_Memory_2 - Bitmap resource descriptor, HDAE5000_Bitmap_DriveMech
;                             (A1 = 0x2BB98E bitmap data, not a palette)
;   0x280368  Alloc_Memory_3 - Bitmap resource descriptor, HDAE5000_Bitmap_FilePanel
;                             (A1 = 0x2CE98E bitmap data, not a palette)
;   0x280395  BitmapHdd_icon - Bitmap resource descriptor, HDAE5000_Bitmap_HddIcon
;                             (A1 = 0x2E198E bitmap data, not a palette; unlike
;                              its three neighbours this one carries the
;                              firmware's own registry name)
;   0x2803C2  HDAE5000_UiState_Reset - (was Register_Frame; see its header)
;   0x28F543  Alloc_Memory - Bitmap resource descriptor for the boot splash
;                             (A1 = 0x2E61CE HDAE5000_Bitmap_BootSplash, A2 = 320,
;                              A3 = 240 -- bitmap data, not a palette)
; ============================================================================

; ----------------------------------------------------------------------------
; HDAE5000_Handler_Registration (0x280020 - 0x28030D)
;
; Registers this module's eleven object tables with the main CPU's
; RootFn_RegisterObjectTable, then its title with RootFn_RegisterTitle -- the
; same sequence, with the same class ids and procs, as the main CPU's own
; InitializeRoot (module 0) and InitializeHama (module 9) in the v10 source;
; the HD-AE5000 is module 0x0A: table index = kind + 0x0A.
; Called from HDAE5000_Boot_Init after the workspace pointer is stored.
;
; The workspace is the main CPU's object table at 0x027ED2: 14-byte records
; at 0x027ED2 + 14 * index (RegisterObjectTable), each {+0 class id,
; +4 proc, +8 count, +10 data}.  (Tables 0x100 and 0x109 are the ones this ROM
; calls through: WS_RootFnTable / WS_HamaFnTable.)
;
; Registration record (14 bytes on the stack):
;   (XSP+0x00): class id of the proc (0x016000nn -- InitializeRoot pairs the
;               same ids with the same procs)
;   (XSP+0x04): the proc, read from the main CPU's function table
;   (XSP+0x08): entry count
;   (XSP+0x0A): table pointer
;
; Handler Registration Table:
;   index  class id                proc              count                        table
;   0x016A NAKA_CLASS_Class        ClassProc         HDAE5000_RECORD_COUNT        HDAE5000_RECORD_TABLE (13 classes)
;   0x01CA NAKA_CLASS_ResEvent     ResEventProc      HDAE5000_RAM_EventName_Count HDAE5000_RAM_EventName_Table (EV_* names)
;   0x01EA NAKA_CLASS_ResMethod    ResMethodProc     HDAE5000_RAM_MessageName_Count HDAE5000_RAM_MessageName_Table (MT_* names)
;   0x012A NAKA_CLASS_ApFunction   ApFunctionProc    0x45                         HDAE5000_RAM_ObjHandler_Table (ApFunction table)
;   0x042A NAKA_CLASS_ApFunction   ApFunctionProc    0x45                         HDAE5000_RAM_ObjName_Table (... its names)
;   0x010A NAKA_CLASS_Function     FunctionProc      0x0D                         HDAE5000_RAM_ClassProc_Table (Function table: the class procs)
;   0x040A NAKA_CLASS_Function     FunctionProc      0x0D                         HDAE5000_RAM_ClassName_Table (... their names)
;   0x014A NAKA_CLASS_MainFunction MainFunctionProc  0x0E                         HDAE5000_RAM_ScreenProc_Table (MainFunction table)
;   0x044A NAKA_CLASS_MainFunction MainFunctionProc  0x0E                         HDAE5000_RAM_ScreenName_Table (... its names)
;   0x007F NAKA_CLASS_Viewable     ViewableProc      HDAE5000_UI_OBJECT_COUNT     HDAE5000_UiObject_PtrTable (UI objects, hdae5000_ui_tree.s)
;   0x037F NAKA_CLASS_ResName      ResNameProc       HDAE5000_UI_OBJECT_COUNT     HDAE5000_UiObjectName_PtrTable (their names)
;   The HDAE5000_RAM_* tables are the RAM copies of the hdae5000_init_data.s labels of the
;   same name (defined at its end); the .data image is copied there at boot.
;   (0x7F / 0x37F replace the empty tables InitializeHama registers there.)
;          (for these two the "Size" word is an ENTRY COUNT: 0x315 = 789
;           objects; both tables hold 790 .long entries, the last a
;           terminator - see hdae5000_data_tables.s)
;   then RegisterTitle(0x7F, 0x014A0000, HDAE5000_OBJ_IV_HDDMENU; stack: name
;   "TT_HDDEXT" at 0x2A849A, module 0x0A) -- InitializeHama registers title
;   0x7F the same way with 0x01490000 and module 9.
;
; Each registration calls RootFn_RegisterObjectTable with:
;   WA = table index
;   XBC = pointer to the record on the stack
; ----------------------------------------------------------------------------

HDAE5000_Handler_Registration:
	; Allocate 14-byte parameter block on stack
	lda xsp, (xsp - 14)	; lda XSP, XSP - 0Eh  (allocate 14 bytes)

	; === table 0x16A: ClassProc, the module's 13 classes (class id 0x01600004) ===
	; Record count = 13 (from ROM at 0x29D97E)
	; Data table = 0x29C0AA (13 records x 24 bytes each)
	; Handler function = ClassProc (0xFA44E2) via workspace[0x0E0A][0x0168]
	ld xwa, NAKA_CLASS_Class	; class id
	ld (xsp + 0:8), xwa	; ld (XSP+0x00), XWA  ; class id
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)             ; Handler dispatch table
	ld XWA, (xwa + RootFn_ClassProc)             ; Handler function via table offset 0x0168
	ld (xsp + 4), xwa	; ld (XSP+0x04), XWA  ; handler function ptr
	ld wa, (HDAE5000_RECORD_COUNT:24)
	ld (xsp + 8), wa	; ld (XSP+0x08), WA   ; record count (= 13)
	lda xwa, (HDAE5000_RECORD_TABLE:24)
	ld (xsp + 10), xwa	; ld (XSP+0x0A), XWA  ; data pointer
	lda xwa, (xsp)	; lda XWA, XSP  ; XWA = param block ptr
	ld xbc, xwa	; XBC = param block ptr
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable function
	ldw wa, 0x16A	; Handler ID
	call (xhl)	; Register handler

	; === table 0x1CA: ResEventProc (class id 0x0160000C) ===
	ld xwa, NAKA_CLASS_ResEvent	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_ResEventProc)             ; Handler function via table offset 0x013C
	ld (xsp + 4), xwa
	ld wa, (HDAE5000_RAM_EventName_Count:24)
	ld (xsp + 8), wa	; ld (XSP+0x08), WA   ; data size (variable)
	lda xwa, (HDAE5000_RAM_EventName_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x1CA	; Handler ID
	call (xhl)

	; === table 0x1EA: ResMethodProc (class id 0x0160000D) ===
	ld xwa, NAKA_CLASS_ResMethod	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_ResMethodProc)             ; Handler function via table offset 0x0140
	ld (xsp + 4), xwa
	ld wa, (HDAE5000_RAM_MessageName_Count:24)
	ld (xsp + 8), wa	; ld (XSP+0x08), WA   ; data size (variable)
	lda xwa, (HDAE5000_RAM_MessageName_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x1EA	; Handler ID
	call (xhl)

	; === table 0x12A: ApFunctionProc, the module's ApFunction table (class id 0x01600002) ===
	ld xwa, NAKA_CLASS_ApFunction	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_ApFunctionProc)             ; Handler function via table offset 0x0248
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0x43	; entry count = 67 (v2.06i: 0x45 = 69)
	lda xwa, (HDAE5000_RAM_ObjHandler_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x12A	; Handler ID
	call (xhl)

	; === table 0x42A: the names of table 0x12A ===
	ld xwa, NAKA_CLASS_ApFunction	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_ApFunctionProc)             ; Handler function via table offset 0x0248
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0x43	; entry count = 67 (v2.06i: 0x45 = 69)
	lda xwa, (HDAE5000_RAM_ObjName_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x42A	; Handler ID
	call (xhl)

	; === table 0x10A: FunctionProc, the module's Function table (class id 0x01600001) ===
	ld xwa, NAKA_CLASS_Function	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_FunctionProc)             ; Handler function via table offset 0x0244
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0xD	; ld (XSP+0x08), 000Dh  ; size = 13 bytes
	lda xwa, (HDAE5000_RAM_ClassProc_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x10A	; Handler ID
	call (xhl)

	; === table 0x40A: the names of table 0x10A ===
	ld xwa, NAKA_CLASS_Function	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_FunctionProc)             ; Handler function via table offset 0x0244
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0xD	; ld (XSP+0x08), 000Dh  ; size = 13 bytes
	lda xwa, (HDAE5000_RAM_ClassName_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x40A	; Handler ID
	call (xhl)

	; === table 0x14A: MainFunctionProc, the module's MainFunction table (class id 0x01600003) ===
	ld xwa, NAKA_CLASS_MainFunction	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_MainFunctionProc)             ; Handler function via table offset 0x024C
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0xE	; ld (XSP+0x08), 000Eh  ; size = 14 bytes
	lda xwa, (HDAE5000_RAM_ScreenProc_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x14A	; Handler ID
	call (xhl)

	; === table 0x44A: the names of table 0x14A ===
	ld xwa, NAKA_CLASS_MainFunction	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_MainFunctionProc)             ; Handler function via table offset 0x024C
	ld (xsp + 4), xwa
	ldw (xsp + 8), 0xE	; ld (XSP+0x08), 000Eh  ; size = 14 bytes
	lda xwa, (HDAE5000_RAM_ScreenName_Table:24)
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x44A	; Handler ID
	call (xhl)

	; === table 0x7F: ViewableProc, the UI object descriptor table (class id 0x01600010) ===
	ld xwa, NAKA_CLASS_Viewable	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_ViewableProc)             ; Handler function via table offset 0x0280
	ld (xsp + 4), xwa
	ldw (xsp + 8), HDAE5000_UI_OBJECT_COUNT	; entry count: the objects of hdae5000_ui_tree.s (786)
	lda xwa, (HDAE5000_UiObject_PtrTable:24)	; = HDAE5000_UiObject_PtrTable
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x7F	; Handler ID
	call (xhl)

	; === table 0x37F: ResNameProc, the UI object names (class id 0x0160000F) ===
	ld xwa, NAKA_CLASS_ResName	; class id
	ld (xsp + 0:8), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XWA, (xwa + RootFn_ResNameProc)             ; Handler function via table offset 0x0148
	ld (xsp + 4), xwa
	ldw (xsp + 8), HDAE5000_UI_OBJECT_COUNT	; entry count: the objects of hdae5000_ui_tree.s (786)
	lda xwa, (HDAE5000_UiObjectName_PtrTable:24)	; = HDAE5000_UiObjectName_PtrTable
	ld (xsp + 10), xwa
	lda xwa, (xsp)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld_sril XHL, (xwa + RootFn_RegisterObjectTable)             ; RegisterObjectTable
	ldw wa, 0x37F	; Handler ID
	call (xhl)

	; === RootFn_RegisterTitle: title 0x7F = "TT_HDDEXT" ===
	pushw 0xA	; module number 0x0A (InitializeHama pushes 9)
	lda xwa, (HDAE5000_GFX_INIT_PARAMS:24)
	push xwa	; the title's name, "TT_HDDEXT"
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_RegisterTitle)
	ld xwa, 0x7F	; title number
	ld xbc, NAKA_MAINFUNC_HDAETitleFunc	; entry 0 of MainFunction table 0x14A
	ld xde, HDAE5000_OBJ_IV_HDDMENU	; the title's view object
	call (xhl)

	; Deallocate the 14-byte record (RegisterTitle's retd 6 popped its pushes)
	lda xsp, (xsp + 14)	; lda XSP, XSP + 0Eh  (deallocate 14 bytes)
	ret

; ----------------------------------------------------------------------------
; Bitmap resource descriptors (0x28030E - 0x2803C1)
;
; Four constant lookups, one per embedded bitmap.  They allocate nothing, so
; the "Alloc_Memory" spelling is a misnomer; the first three keep it only
; because the firmware publishes no name for them.  The fourth one it does
; publish: HDAE5000_ObjHandler_Table entry 39 is 0x280395 and the parallel
; HDAE5000_ObjName_Table entry points at 0x29BD0A = "BitmapHdd_icon".
;
; Input:  XBC = request type
;           0x01E000A1 -> base address of the bitmap DATA, not a palette (the
;                        same immediates are the MemCopy sources at 0x2804BB,
;                        0x280599 and 0x280677 -- see hdae5000_data_tables.s)
;           0x01E000A2 -> width
;           0x01E000A3 -> height
; Output: XHL = the answer, or 0 for any other request
; ----------------------------------------------------------------------------

HDAE5000_Alloc_Memory_1:
	; Returns 0x2A898E for A1, 0x140 for A2, 0xF0 for A3
	cp xbc, EVT_GET_BITMAP_HEIGHT
	jr z, HDAE5000_Alloc_Memory_1__type_A3
	cp xbc, EVT_GET_BITMAP_WIDTH
	jr z, HDAE5000_Alloc_Memory_1__type_A2
	cp xbc, EVT_GET_BITMAP_DATA
	jr z, HDAE5000_Alloc_Memory_1__type_A1
	ld xhl, 0:i3
	ret
HDAE5000_Alloc_Memory_1__type_A1:
	lda xhl, (HDAE5000_Bitmap_TitleLogo:24); Palette data pointer 1
	ret
HDAE5000_Alloc_Memory_1__type_A2:
	ld xhl, 0x140	; 320 (width)
	ret
HDAE5000_Alloc_Memory_1__type_A3:
	ld xhl, 0xF0	; 240 (height)
	ret

; ---------------------------------------------------------------------------
; Bitmap resource descriptor of HDAE5000_Bitmap_DriveMech, as
; HDAE5000_Alloc_Memory (which it allocates nothing either).
; In:  XBC = EVT_GET_BITMAP_DATA / _WIDTH / _HEIGHT
; Out: XHL = the bitmap, 0x140 (320) or 0xF0 (240); 0 for any other event.
; ---------------------------------------------------------------------------
HDAE5000_Alloc_Memory_2:
	cp xbc, EVT_GET_BITMAP_HEIGHT
	jr z, HDAE5000_Alloc_Memory_2__type_A3
	cp xbc, EVT_GET_BITMAP_WIDTH
	jr z, HDAE5000_Alloc_Memory_2__type_A2
	cp xbc, EVT_GET_BITMAP_DATA
	jr z, HDAE5000_Alloc_Memory_2__type_A1
	ld xhl, 0:i3
	ret
HDAE5000_Alloc_Memory_2__type_A1:
	lda xhl, (HDAE5000_Bitmap_DriveMech:24)
	ret
HDAE5000_Alloc_Memory_2__type_A2:
	ld xhl, 0x140
	ret
HDAE5000_Alloc_Memory_2__type_A3:
	ld xhl, 0xF0
	ret

; ---------------------------------------------------------------------------
; Bitmap resource descriptor of HDAE5000_Bitmap_FilePanel, as
; HDAE5000_Alloc_Memory.
; In:  XBC = EVT_GET_BITMAP_DATA / _WIDTH / _HEIGHT
; Out: XHL = the bitmap, 0x140 (320) or 0xF0 (240); 0 for any other event.
; ---------------------------------------------------------------------------
HDAE5000_Alloc_Memory_3:
	cp xbc, EVT_GET_BITMAP_HEIGHT
	jr z, HDAE5000_Alloc_Memory_3__type_A3
	cp xbc, EVT_GET_BITMAP_WIDTH
	jr z, HDAE5000_Alloc_Memory_3__type_A2
	cp xbc, EVT_GET_BITMAP_DATA
	jr z, HDAE5000_Alloc_Memory_3__type_A1
	ld xhl, 0:i3
	ret
HDAE5000_Alloc_Memory_3__type_A1:
	lda xhl, (HDAE5000_Bitmap_FilePanel:24)
	ret
HDAE5000_Alloc_Memory_3__type_A2:
	ld xhl, 0x140
	ret
HDAE5000_Alloc_Memory_3__type_A3:
	ld xhl, 0xF0
	ret

; --- HDAE5000_BitmapHdd_icon (was HDAE5000_Alloc_Memory_4) -------------------
; The label is the firmware's own name.  HDAE5000_ObjHandler_Table entry 39
; (ROM 0x2F94B2 + 0x9C) holds 0x280395, and the parallel HDAE5000_ObjName_Table
; entry (ROM 0x2F95CA + 0x9C) points at 0x29BD0A = "BitmapHdd_icon".
HDAE5000_BitmapHdd_icon:
	; Resource descriptor for HDAE5000_Bitmap_HddIcon.  Allocates nothing.
	cp xbc, EVT_GET_BITMAP_HEIGHT
	jr z, HDAE5000_BitmapHdd_icon__type_A3
	cp xbc, EVT_GET_BITMAP_WIDTH
	jr z, HDAE5000_BitmapHdd_icon__type_A2
	cp xbc, EVT_GET_BITMAP_DATA
	jr z, HDAE5000_BitmapHdd_icon__type_A1
	ld xhl, 0:i3
	ret
HDAE5000_BitmapHdd_icon__type_A1:
	lda xhl, (HDAE5000_Bitmap_HddIcon:24); HDAE5000_Bitmap_HddIcon data, NOT a palette
	ret
HDAE5000_BitmapHdd_icon__type_A2:
	ld xhl, 0x1B	; 27 (icon width)
	ret
HDAE5000_BitmapHdd_icon__type_A3:
	ld xhl, 0x1B	; 27 (icon height)
	ret

; ============================================================================
; CODE SECTION 1: Setup, HD interface, filesystem, and UI routines
; 0x2803C2-0x28F542 (61,825 bytes, 64 identified routines)
;
; Hardware access:
;   PPI 8255 ports at 0x160000-0x160006 (IDE/ATA bridge to HD)
;   VGA registers via memory-mapped I/O
;   HD config flags at 0x229D90-0x229DAE
;   Workspace at 0x23A1A2 (shared with main CPU)
;
; Subsystem groups:
;   0x2803C2-0x2827F3  Frame registration and event dispatch (9,266 bytes)
;   0x2827F4-0x282B97  Event handler (932 bytes)
;   0x282B98-0x282E3B  PPI/IDE low-level I/O (1,188 bytes)
;   0x282E8D-0x28541B  HD drive setup and configuration (9,615 bytes)
;   0x28541C-0x287054  HD config manager and CHS geometry (7,225 bytes)
;   0x2870D6-0x28A2EF  Filesystem operations (12,826 bytes)
;   0x28A2F0-0x28B3E9  Display, menu, and utility routines (4,346 bytes)
;   0x28B3EA-0x28F542  UI handler, file ops, path/string utilities (16,857 bytes)
; ============================================================================

HDAE5000_UiState_Reset:
	; Reset the browser selection (0x23A08E, 0x23A092 directory, 0x23A094
	; song = 0), the load-by-number block 0x22AA58 (template 0x2E1CA2), and
	; the save-option record 0x22AA4C (template 0x2E1C96, mask 0x1FF, then
	; "YES" for the parts the selected song holds -- HDAE5000_TypeSel_Init);
	; ends in HDAE5000_Set_Menu_Visibility(1).  Caller: HDAE5000_Boot_Init.
	; (Was Register_Frame, "(9266 bytes)".)
; LRF: 0x2803C2 (9266 bytes)
	; ^ conversion-region size (local-label prefix .LRF_), not a routine size.

	ldw	(HDAE5000_RAM_DirPageBase:24), 0
	ldw	(HDAE5000_RAM_CurDir:24), 0
	ldw	(HDAE5000_RAM_CurSong:24), 0
	ld	xiy, HDAE5000_Lbn_BlockTemplate
	ld	xix, 0x0022aa58
	ld	bc, 5:i3
	ldirw
	ld	xiy, HDAE5000_TypeSel_TemplateBlank
	ld	xix, HDAE5000_RAM_SaveOptions
	ld	bc, 6:i3
	ldirw
	ldw	(HDAE5000_RAM_SaveOptions:24), 511
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld	wa, hl
	cp	wa, 0xffff
	jr	z, HDAE5000_UiState_Reset_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	ld	bc, hl
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	calr	HDAE5000_TypeSel_Init
	jr	t, HDAE5000_UiState_Reset_Join
HDAE5000_UiState_Reset_Skip:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	ld	bc, 0:i3
	calr	HDAE5000_TypeSel_Init
HDAE5000_UiState_Reset_Join:
	ld	wa, 1:i3
	jp HDAE5000_Set_Menu_Visibility

HDAE5000_AcWindowPage1Proc:
	; registered as "AcWindowPage1Proc" in HDAE5000_ClassProc_Table
	dec 8, xsp
	push xiz
	ld (xsp + 0x04), xde
	ld (xsp + 0x08), xbc
	ld	xiz, xwa
	ld xwa, (xsp + 0x08)
	cp	xwa, EVT_SHOW
	jr	nz, HDAE5000_AcWindowPage1Proc_Join
	ld	xwa, xiz
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_PAGE
	ld	xde, 1:i3
	call	(xhl)
HDAE5000_AcWindowPage1Proc_Join:
	ld	xwa, xiz
	ld xbc, (xsp + 0x08)
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	pop xiz
	inc 8, xsp
	ret

HDAE5000_TtlScreenRProc:
	; registered as "TtlScreenRProc" in HDAE5000_ClassProc_Table
	dec 8, xsp
	push xiz
	ld (xsp + 0x04), xde
	ld	xiz, xbc
	ld (xsp + 0x08), xwa
	ld	xwa, xiz
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_TtlScreenRProc_OnHide
	cp	xwa, EVT_DRAW
	jrl	nz, HDAE5000_TtlScreenRProc_Join2
	ld	xwa, 0:i3
	ld	xbc, EVT_GET_BITMAP_DATA
	ld	xde, 0:i3
	calr	HDAE5000_Alloc_Memory_1
	or xhl, xhl
	jr	z, HDAE5000_TtlScreenRProc_Join
	pushw 0x9600
	lda xwa, (HDAE5000_Bitmap_TitleLogo:24)
	push xwa
	ld	xwa, 0x00056800
	push xwa
	call HDAE5000_MemCopy
	pushw 0x9600
	lda xwa, (HDAE5000_Bitmap_TitleLogo+0x9600:24)	; its second half (0x12C00 bytes in two 0x9600 copies)
	push xwa
	ld	xwa, 0x0005fe00
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0400
	lda xwa, (HDAE5000_Palette_TitleLogo:24)
	push xwa
	ld	xwa, 0x00069400
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+30)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangeWall)
	ld	wa, 3:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 3:i3
	call	(xhl)
HDAE5000_TtlScreenRProc_Join:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_TtlScreenRProc_Epilogue
HDAE5000_TtlScreenRProc_OnHide:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 2:i3
	call	(xhl)
HDAE5000_TtlScreenRProc_Join2:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_TtlScreenRProc_Epilogue:
	pop xiz
	inc 8, xsp
	ret

HDAE5000_TtlScreenR2Proc:
	; registered as "TtlScreenR2Proc" in HDAE5000_ClassProc_Table
	dec 8, xsp
	push xiz
	ld (xsp + 0x04), xde
	ld	xiz, xbc
	ld (xsp + 0x08), xwa
	ld	xwa, xiz
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_TtlScreenR2Proc_OnHide
	cp	xwa, EVT_DRAW
	jrl	nz, HDAE5000_TtlScreenR2Proc_Join2
	ld	xwa, 0:i3
	ld	xbc, EVT_GET_BITMAP_DATA
	ld	xde, 0:i3
	calr	HDAE5000_Alloc_Memory_2
	or xhl, xhl
	jr	z, HDAE5000_TtlScreenR2Proc_Join
	pushw 0x9600
	lda xwa, (HDAE5000_Bitmap_DriveMech:24)
	push xwa
	ld	xwa, 0x00056800
	push xwa
	call HDAE5000_MemCopy
	pushw 0x9600
	lda xwa, (HDAE5000_Bitmap_DriveMech+0x9600:24)	; its second half
	push xwa
	ld	xwa, 0x0005fe00
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0400
	lda xwa, (HDAE5000_Palette_DriveMech:24)
	push xwa
	ld	xwa, 0x00069400
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+30)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangeWall)
	ld	wa, 3:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 3:i3
	call	(xhl)
HDAE5000_TtlScreenR2Proc_Join:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_TtlScreenR2Proc_Epilogue
HDAE5000_TtlScreenR2Proc_OnHide:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 2:i3
	call	(xhl)
HDAE5000_TtlScreenR2Proc_Join2:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_TtlScreenR2Proc_Epilogue:
	pop xiz
	inc 8, xsp
	ret

HDAE5000_TtlScreenR3Proc:
	; registered as "TtlScreenR3Proc" in HDAE5000_ClassProc_Table
	dec 8, xsp
	push xiz
	ld (xsp + 0x04), xde
	ld	xiz, xbc
	ld (xsp + 0x08), xwa
	ld	xwa, xiz
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_TtlScreenR3Proc_OnHide
	cp	xwa, EVT_DRAW
	jrl	nz, HDAE5000_TtlScreenR3Proc_Join2
	ld	xwa, 0:i3
	ld	xbc, EVT_GET_BITMAP_DATA
	ld	xde, 0:i3
	calr	HDAE5000_Alloc_Memory_3
	or xhl, xhl
	jr	z, HDAE5000_TtlScreenR3Proc_Join
	pushw 0x9600
	lda xwa, (HDAE5000_Bitmap_FilePanel:24)
	push xwa
	ld	xwa, 0x00056800
	push xwa
	call HDAE5000_MemCopy
	pushw 0x9600
	lda xwa, (HDAE5000_Bitmap_FilePanel+0x9600:24)	; its second half
	push xwa
	ld	xwa, 0x0005fe00
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0400
	lda xwa, (HDAE5000_Palette_FilePanel:24)
	push xwa
	ld	xwa, 0x00069400
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+30)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangeWall)
	ld	wa, 3:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 3:i3
	call	(xhl)
HDAE5000_TtlScreenR3Proc_Join:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_TtlScreenR3Proc_Epilogue
HDAE5000_TtlScreenR3Proc_OnHide:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 2:i3
	call	(xhl)
HDAE5000_TtlScreenR3Proc_Join2:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_TtlScreenR3Proc_Epilogue:
	pop xiz
	inc 8, xsp
	ret

HDAE5000_IvScreenR2Proc:
	; registered as "IvScreenR2Proc" in HDAE5000_ClassProc_Table
	dec 8, xsp
	push xiz
	ld (xsp + 0x04), xde
	ld	xiz, xbc
	ld (xsp + 0x08), xwa
	ld	xwa, xiz
	cp	xwa, EVT_HIDE
	jr	z, HDAE5000_IvScreenR2Proc_OnHide
	cp	xwa, EVT_DRAW
	jr	nz, HDAE5000_IvScreenR2Proc_Join2
	ld	xwa, 0:i3
	ld	xbc, EVT_GET_BITMAP_DATA
	ld	xde, 0:i3
	calr	HDAE5000_Alloc_Memory_2
	or xhl, xhl
	jr	z, HDAE5000_IvScreenR2Proc_Join
	pushw 0x0400
	lda xwa, (HDAE5000_Palette_DriveMech:24)
	push xwa
	ld	xwa, 0x00069400
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangeWall)
	ld	wa, 3:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 3:i3
	call	(xhl)
HDAE5000_IvScreenR2Proc_Join:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_IvScreenR2Proc_Epilogue
HDAE5000_IvScreenR2Proc_OnHide:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_ChangePalette)
	ld	wa, 2:i3
	call	(xhl)
HDAE5000_IvScreenR2Proc_Join2:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_IvScreenR2Proc_Epilogue:
	pop xiz
	inc 8, xsp
	ret

HDAE5000_SelectListProc:
	; registered as "SelectListProc" in HDAE5000_ClassProc_Table
	lda	xsp, (xsp-104)
	push xiz
	ld (xsp + 0x60), xde
	ld (xsp + 0x64), xbc
	ld (xsp + 0x68), xwa
	ld xwa, (xsp + 0x64)
	cp	xwa, EVT_HDAE_TIMER_BACK
	jrl	z, HDAE5000_SelectListProc_Skip21
	cp	xwa, EVT_HDAE_AFTER_LOAD
	jrl	z, HDAE5000_SelectListProc_Skip21
	cp	xwa, EVT_HDAE_SEQ_STOP
	jrl	z, HDAE5000_SelectListProc_Skip21
	cp	xwa, EVT_INDEXSW_DOWN
	jrl	z, HDAE5000_SelectListProc_Skip10
	cp	xwa, EVT_INDEXSW_DOWN_AIC
	jrl	z, HDAE5000_SelectListProc_Skip10
	cp	xwa, EVT_INDEXSW_UP
	jrl	z, HDAE5000_SelectListProc_Skip10
	cp	xwa, EVT_INDEXSW_UP_AIC
	jrl	z, HDAE5000_SelectListProc_Skip10
	cp	xwa, EVT_HDAE_SET_STR_ADR
	jrl	z, HDAE5000_SelectListProc_OnHdaeSetStrAdr
	cp	xwa, EVT_HDAE_REQ_SEL_NUM
	jrl	z, HDAE5000_SelectListProc_OnHdaeReqSelNum
	cp	xwa, EVT_HDAE_SET_SEL_NUM
	jrl	z, HDAE5000_SelectListProc_OnHdaeSetSelNum
	cp	xwa, EVT_HDAE_CHANGE_SEL_NUM
	jrl	z, HDAE5000_SelectListProc_OnHdaeChangeSelNum
	cp	xwa, EVT_PARA_DRAW
	jrl	z, HDAE5000_SelectListProc_OnParaDraw
	cp	xwa, EVT_PAINT
	jrl	z, HDAE5000_SelectListProc_OnPaint
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_SelectListProc_OnHide
	cp	xwa, EVT_SHOW
	jr	z, HDAE5000_SelectListProc_OnShow
	cp	xwa, EVT_DRAW
	jrl	nz, HDAE5000_SelectListProc_Join13
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnShow:
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x36)
	ldw	(xwa), 0x0001
	ld xwa, (xsp + 0x04)
	cpw	(xwa+50), 0x0000
	jr	z, HDAE5000_SelectListProc_Join
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_SetDialUp)
	ld	xbc, EVT_INDEXSW_DOWN
	ld	xde, 0:i3
	call	(xhl)
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_SetDialDown)
	ld	xbc, EVT_INDEXSW_UP
	ld	xde, 0:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetDialEnable)
	ld	wa, 1:i3
	call	(xhl)
HDAE5000_SelectListProc_Join:
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnHide:
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x36)
	ldw	(xwa), 0x0000
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnPaint:
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	cpw	(xwa+42), 0x0002
	jrl	lt, HDAE5000_SelectListProc_Join3
	lda	xwa, (xsp+80)
	ld	xbc, xwa
	ld xwa, (xsp + 0x68)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_GetClientBox)
	call	(xhl)
	ld	bc, (xsp+84)
	sub	bc, (xsp+80)
	exts xbc
	ld xwa, (xsp + 0x04)
	divs xbc, (xwa+42)
	ld (xsp + 0x0c), bc
	ld	wa, (xsp+82)
	inc	1, wa
	ld (xsp + 0x5e), wa
	ld	wa, (xsp+86)
	dec	1, wa
	ld (xsp + 0x5a), wa
	ldw (xsp + 0x08), 1
	jr	t, HDAE5000_SelectListProc_Next
HDAE5000_SelectListProc_Loop:
	ld	wa, (xsp+12)
	mul xwa, (xsp+8)
	ld	bc, (xsp+80)
	add	bc, wa
	dec	1, bc
	ld (xsp + 0x5c), bc
	ld (xsp + 0x58), bc
	ld xwa, (xsp + 0x04)
	cpw	(xwa+22), 0x0007
	jr	nz, HDAE5000_SelectListProc_Skip
	lda	xwa, (xsp+92)
	ld	xde, xwa
	lda	xwa, (xsp+88)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_DrawLine)
	ldw	de, 0x00ff
	call	(xhl)
	jr	t, HDAE5000_SelectListProc_Join2
HDAE5000_SelectListProc_Skip:
	lda	xwa, (xsp+92)
	ld	xde, xwa
	lda	xwa, (xsp+88)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_DrawLine)
	ld	de, 7:i3
	call	(xhl)
HDAE5000_SelectListProc_Join2:
	incw	1, (xsp+8)
HDAE5000_SelectListProc_Next:
	ld xwa, (xsp + 0x04)
	ld	wa, (xwa+42)
	cp	(xsp+8), wa
	jr	c, HDAE5000_SelectListProc_Loop
HDAE5000_SelectListProc_Join3:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnParaDraw:
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x26)
	ld xwa, (xwa)
	or xwa, xwa
	jr	nz, HDAE5000_SelectListProc_Skip2
	ld	xwa, (HDAE5000_TextPtrs_01Selectlist0203040506070809)
	ld (xsp + 0x10), xwa
	jr	t, HDAE5000_SelectListProc_Join4
HDAE5000_SelectListProc_Skip2:
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x26)
	ld xwa, (xwa)
	ld (xsp + 0x10), xwa
HDAE5000_SelectListProc_Join4:
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x36)
	cpw	(xwa), 0x0001
	jr	z, HDAE5000_SelectListProc_Skip3
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip3:
	lda	xwa, (xsp+80)
	ld	xbc, xwa
	ld xwa, (xsp + 0x68)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_GetClientBox)
	call	(xhl)
	ld	bc, (xsp+84)
	sub	bc, (xsp+80)
	exts xbc
	ld xwa, (xsp + 0x04)
	divs xbc, (xwa+42)
	ld (xsp + 0x0c), bc
	ld	bc, (xsp+86)
	sub	bc, (xsp+82)
	exts xbc
	ld xwa, (xsp + 0x04)
	divs xbc, (xwa+44)
	ld (xsp + 0x0e), bc
	ldw (xsp + 0x08), 0
	ldw (xsp + 0x0a), 0
	ldw (xsp + 0x14), 0
	jrl	t, HDAE5000_SelectListProc_Next3
HDAE5000_SelectListProc_Loop2:
	ld	(xsp+22), 0x00
	jr	t, HDAE5000_SelectListProc_Next2
HDAE5000_SelectListProc_Loop3:
	ld	wa, (xsp+10)
	extz xwa
	add	xwa, (xsp+16)
	cp	(xwa), 0x09
	jr	nz, HDAE5000_SelectListProc_Skip4
	lda	xbc, (xsp+22)
	ld	wa, (xsp+20)
	ld	(xbc+wa), 0x00
	incw	1, (xsp+10)
	ldw (xsp + 0x14), 0
	jr	t, HDAE5000_SelectListProc_Join5
HDAE5000_SelectListProc_Skip4:
	lda	xde, (xsp+22)
	ld	wa, (xsp+10)
	extz xwa
	ld	xbc, xwa
	add	xbc, (xsp+16)
	ld	wa, (xsp+20)
	ld	c, (xbc)
	ld	(xde+wa), c
	incw	1, (xsp+20)
	incw	1, (xsp+10)
HDAE5000_SelectListProc_Next2:
	ld	wa, (xsp+10)
	extz xwa
	add	xwa, (xsp+16)
	cp	(xwa), 0x00
	jr	nz, HDAE5000_SelectListProc_Loop3
HDAE5000_SelectListProc_Join5:
	ld xwa, (xsp + 0x60)
	cp	xwa, 0xffffffff
	jr	z, HDAE5000_SelectListProc_Join6
	ld	wa, (xsp+8)
	extz xwa
	ld xbc, (xsp + 0x60)
	cp	xbc, xwa
	jrl	nz, HDAE5000_SelectListProc_Join7
HDAE5000_SelectListProc_Join6:
	ld xwa, (xsp + 0x04)
	ld	bc, (xwa+44)
	ld	wa, (xsp+8)
	extz xwa
	div	xwa, bc
	ld	hl, qwa
	ld xwa, (xsp + 0x04)
	ld	bc, (xwa+44)
	ld	wa, (xsp+8)
	extz xwa
	div	xwa, bc
	ld	de, wa
	ld	wa, (xsp+14)
	mul	xwa, hl
	ld	bc, (xsp+82)
	add	bc, wa
	inc	1, bc
	ld (xsp + 0x4a), bc
	ld	wa, bc
	add	wa, (xsp+14)
	dec	1, wa
	ld (xsp + 0x4e), wa
	ld	wa, (xsp+12)
	mul	xwa, de
	ld	bc, (xsp+80)
	add	bc, wa
	inc	1, bc
	ld (xsp + 0x48), bc
	ld	wa, bc
	add	wa, (xsp+12)
	dec	4, wa
	ld (xsp + 0x4c), wa
	ld	wa, (xsp+72)
	ld (xsp + 0x5c), wa
	ld	wa, (xsp+14)
	srl	wa, 0x01
	ld	bc, (xsp+74)
	add	bc, wa
	ld (xsp + 0x5e), bc
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_GetCharDescent)
	call	(xhl)
	ld	iz, hl
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetCharHeight)
	call	(xix)
	sub	hl, iz
	ld	wa, hl
	neg	wa
	exts xwa
	divs	wa, 0x0002
	ld	iz, wa
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetCenteredDelta)
	call	(xix)
	add	hl, iz
	add	(xsp+94), hl
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	wa, (xwa)
	cp	wa, (xsp+8)
	jrl	nz, HDAE5000_SelectListProc_Skip6
	ld xwa, (xsp + 0x04)
	cpw	(xwa+58), 0x0000
	jr	nz, HDAE5000_SelectListProc_Skip5
	lda	xwa, (xsp+72)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_DrawBox)
	ldw	bc, 0x00ff
	call	(xhl)
	lda	xwa, (xsp+72)
	ld	xhl, xwa
	lda	xwa, (xsp+92)
	ld	xbc, xwa
	lda	xwa, (xsp+22)
	ld	xde, xwa
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	push xwa
	pushw 0x0000
	pushw 0x00f7
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jrl	t, HDAE5000_SelectListProc_Join7
HDAE5000_SelectListProc_Skip5:
	lda	xwa, (xsp+72)
	ld xbc, (xsp + 0x04)
	ld	bc, (xbc+22)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_DrawBox)
	call	(xhl)
	lda	xhl, (xsp+72)
	lda	xbc, (xsp+92)
	lda	xde, (xsp+22)
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	push xwa
	ld xwa, (xsp + 0x08)
	pushm	(xwa+32)
	ld xwa, (xsp + 0x0a)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	lda	xwa, (xsp+72)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_DrawFrame)
	ldw	bc, 0x00f2
	call	(xhl)
	jrl	t, HDAE5000_SelectListProc_Join7
HDAE5000_SelectListProc_Skip6:
	ld xwa, (xsp + 0x04)
	cpw	(xwa+58), 0x0000
	jr	nz, HDAE5000_SelectListProc_Skip7
	lda	xwa, (xsp+72)
	ld xbc, (xsp + 0x04)
	ld	bc, (xbc+22)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_DrawBox)
	call	(xhl)
	lda	xhl, (xsp+72)
	lda	xbc, (xsp+92)
	lda	xde, (xsp+22)
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	push xwa
	ld xwa, (xsp + 0x08)
	pushm	(xwa+32)
	ld xwa, (xsp + 0x0a)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jr	t, HDAE5000_SelectListProc_Join7
HDAE5000_SelectListProc_Skip7:
	lda	xwa, (xsp+72)
	ld xbc, (xsp + 0x04)
	ld	bc, (xbc+22)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_DrawBox)
	call	(xhl)
	lda	xhl, (xsp+72)
	lda	xbc, (xsp+92)
	lda	xde, (xsp+22)
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x1c)
	push xwa
	ld xwa, (xsp + 0x08)
	pushm	(xwa+32)
	ld xwa, (xsp + 0x0a)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
HDAE5000_SelectListProc_Join7:
	incw	1, (xsp+8)
HDAE5000_SelectListProc_Next3:
	ld xwa, (xsp + 0x04)
	ld	bc, (xwa+42)
	ld xwa, (xsp + 0x04)
	muls xbc, (xwa+44)
	cp	(xsp+8), bc
	jrl	c, HDAE5000_SelectListProc_Loop2
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnHdaeChangeSelNum:
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	ld xwa, (xsp + 0x60)
	add	de, wa
	jr	ge, HDAE5000_SelectListProc_Skip8
	ld	bc, de
	exts xbc
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_UNDER_FLOW
	call	(xhl)
	jr	t, HDAE5000_SelectListProc_Join8
HDAE5000_SelectListProc_Skip8:
	ld xwa, (xsp + 0x04)
	ld	bc, (xwa+44)
	ld xwa, (xsp + 0x04)
	muls xbc, (xwa+42)
	cp	de, bc
	jr	lt, HDAE5000_SelectListProc_Skip9
	ld	bc, de
	exts xbc
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_OVER_FLOW
	call	(xhl)
	jr	t, HDAE5000_SelectListProc_Join8
HDAE5000_SelectListProc_Skip9:
	ld	bc, de
	exts xbc
	ld xwa, (xsp + 0x68)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
HDAE5000_SelectListProc_Join8:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnHdaeSetSelNum:
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	ld xwa, (xsp + 0x04)
	ld xbc, (xwa + 0x2e)
	ld xwa, (xsp + 0x60)
	ld (xbc), wa
	ld	bc, de
	exts xbc
	ld xwa, (xsp + 0x68)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnHdaeReqSelNum:
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_ACK_SEL_NUM
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_OnHdaeSetStrAdr:
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xbc, (xwa + 0x26)
	ld xwa, (xsp + 0x60)
	ld (xbc), xwa
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip10:
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	wa, 0:i3
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_GET_INDEX
	ld	xde, 0:i3
	call	(xhl)
	ld	xiz, xhl
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	cp	(xsp+96), xiz
	jrl	nz, HDAE5000_SelectListProc_Skip12
	ld xwa, (xsp + 0x64)
	cp	xwa, EVT_INDEXSW_UP
	jr	z, HDAE5000_SelectListProc_Join9
	cp	xwa, EVT_INDEXSW_UP_AIC
	jrl	nz, HDAE5000_SelectListProc_Skip11
HDAE5000_SelectListProc_Join9:
	ldw	wa, 0xffff
HDAE5000_SelectListProc_Join10:
	ld	bc, wa
	exts xbc
	ld xwa, (xsp + 0x68)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	call	(xhl)
	ld xwa, (xsp + 0x04)
	cpw	(xwa+52), 0x0000
	jr	z, HDAE5000_SelectListProc_Join11
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
HDAE5000_SelectListProc_Join11:
	ld xwa, (xsp + 0x04)
	cpw	(xwa+50), 0x0000
	jr	z, HDAE5000_SelectListProc_Join12
	ld xwa, (xsp + 0x68)
	ld	xde, xiz
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_SetDialUp)
	ld	xbc, EVT_INDEXSW_DOWN
	call	(xhl)
	ld xwa, (xsp + 0x68)
	ld	xde, xiz
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_SetDialDown)
	ld	xbc, EVT_INDEXSW_UP
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetDialEnable)
	ld	wa, 1:i3
	call	(xhl)
HDAE5000_SelectListProc_Join12:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip11:
	ld	wa, 1:i3
	jrl	t, HDAE5000_SelectListProc_Join10
HDAE5000_SelectListProc_Skip12:
	ld	xwa, xiz
	inc 1, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip13
	ld xwa, (xsp + 0x04)
	ld	wa, (xwa+44)
	jrl	t, HDAE5000_SelectListProc_Join10
HDAE5000_SelectListProc_Skip13:
	ld	xwa, xiz
	inc 2, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip14
	ld xwa, (xsp + 0x04)
	ld	wa, (xwa+44)
	neg	wa
	jrl	t, HDAE5000_SelectListProc_Join10
HDAE5000_SelectListProc_Skip14:
	ld	xwa, xiz
	inc	3, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip15
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_SELECT_OK
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip15:
	ld	xwa, xiz
	inc 4, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip16
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_SELECT_SAVE
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip16:
	ld	xwa, xiz
	inc	5, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip17
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_SELECT_DEL_FILE
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip17:
	ld	xwa, xiz
	inc	6, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip18
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_SELECT_OK2
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip18:
	ld	xwa, xiz
	inc	7, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip19
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_SELECT_DEL
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip19:
	ld	xwa, xiz
	inc 8, xwa
	cp	xwa, (xsp+96)
	jr	nz, HDAE5000_SelectListProc_Skip20
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x2e)
	ld	de, (xwa)
	exts xde
	ld xwa, (xsp + 0x04)
	ld xwa, (xwa + 0x22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_MainFuncCall)
	ld	xbc, EVT_HDAE_SELECT_ALL
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip20:
	ld	xhl, 0:i3
	jr	t, HDAE5000_SelectListProc_Epilogue
HDAE5000_SelectListProc_Skip21:
	ld xwa, (xsp + 0x68)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	ld xwa, (xwa + 0x22)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_MainFuncCall)
	call	(xhl)
HDAE5000_SelectListProc_Join13:
	ld xwa, (xsp + 0x68)
	ld xbc, (xsp + 0x64)
	ld xde, (xsp + 0x60)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_SelectListProc_Epilogue:
	pop xiz
	lda	xsp, (xsp+104)
	ret

HDAE5000_DbMemoClProc:
	; registered as "DbMemoClProc" in HDAE5000_ClassProc_Table
	lda	xsp, (xsp-106)
	push xiz
	ld (xsp + 0x6a), xde
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_MEMO_DRAW
	jrl	z, HDAE5000_DbMemoClProc_OnMemoDraw
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_DbMemoClProc_OnDraw
	ld	xwa, xiz
	ld xde, (xsp + 0x6a)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_DbMemoClProc_Epilogue
HDAE5000_DbMemoClProc_OnDraw:
	ld	xwa, xiz
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	lda	xwa, (xwa+14)
	ld xbc, (xsp + 0x04)
	ld	de, (xbc+22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_DrawDesignBox)
	ldw	bc, 0x00c5
	call	(xhl)
	ld xwa, (xsp + 0x04)
	lda	xiy, (xwa+14)
	lda	xix, (xsp+98)
	ld	bc, 4:i3
	ldirw
	incw	4, (xsp+100)
	incw	4, (xsp+98)
	decm	4, (xsp+102)
	decm	4, (xsp+104)
	lda	xwa, (xsp+98)
	ld xbc, (xsp + 0x04)
	ld	de, (xbc+22)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_DrawDesignBox)
	ldw	bc, 0x00c6
	call	(xhl)
	lda xwa, (HDAE5000_Str_DebugTime:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_MEMO_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_DbMemoClProc_Epilogue
HDAE5000_DbMemoClProc_OnMemoDraw:
	ld	xwa, xiz
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld (xsp + 0x04), xhl
	ld	xwa, xhl
	lda	xiy, (xwa+14)
	lda	xix, (xsp+98)
	ld	bc, 4:i3
	ldirw
	incw	5, (xsp+100)
	incw	5, (xsp+98)
	decm	5, (xsp+102)
	decm	5, (xsp+104)
	ld	wa, (xsp+102)
	sub	wa, (xsp+98)
	exts xwa
	divs	wa, 0x0006
	ld (xsp + 0x08), wa
	ld	wa, (xsp+98)
	ld (xsp + 0x4e), wa
	ld	wa, (xsp+104)
	dec 8, wa
	ld (xsp + 0x50), wa
	lda	xiy, (xsp+98)
	lda	xix, (xsp+90)
	ld	bc, 4:i3
	ldirw
	incw	8, (xsp+92)
	lda	xiy, (xsp+98)
	lda	xix, (xsp+82)
	ld	bc, 4:i3
	ldirw
	ld	wa, (xsp+88)
	dec 8, wa
	ld (xsp + 0x54), wa
	ld	wa, (xsp+98)
	ld (xsp + 0x4a), wa
	ld	wa, (xsp+100)
	ld (xsp + 0x4c), wa
	ld xwa, (xsp + 0x6a)
	ld (xsp + 0x0a), xwa
HDAE5000_DbMemoClProc_Loop:
	lda	xwa, (xsp+90)
	ld	xde, xwa
	lda	xwa, (xsp+74)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_MovePixels)
	call	(xhl)
	lda	xwa, (xsp+82)
	ld xbc, (xsp + 0x04)
	ld	bc, (xbc+22)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld_sril	xhl, (xde + RootFn_DrawBox)
	call	(xhl)
	ld	wa, (xsp+8)
	pushw wa
	ld xwa, (xsp + 0x0c)
	push xwa
	lda	xwa, (xsp+20)
	push xwa
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	ld	wa, (xsp+8)
	extz xwa
	lda	xbc, (xsp+14)
	add	xbc, xwa
	ld	(xbc), 0x00
	lda	xhl, (xsp+98)
	lda	xbc, (xsp+78)
	lda	xwa, (xsp+14)
	ld	xde, xwa
	ld	xwa, 3:i3
	push xwa
	ld xwa, (xsp + 0x08)
	pushm	(xwa+24)
	ld xwa, (xsp + 0x0a)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	cp	hl, (xsp+8)
	jr	nz, HDAE5000_DbMemoClProc_Done
	ld	wa, (xsp+8)
	extz xwa
	add	(xsp+10), xwa
	jrl	t, HDAE5000_DbMemoClProc_Loop
HDAE5000_DbMemoClProc_Done:
	ld	xhl, 0:i3
HDAE5000_DbMemoClProc_Epilogue:
	pop xiz
	lda	xsp, (xsp+106)
	ret

HDAE5000_AcHddNamingWindowProc:
	; registered as "AcHddNamingWindowProc" in HDAE5000_ClassProc_Table
	lda	xsp, (xsp-48)
	push xiz
	ld (xsp + 0x28), xde
	ld (xsp + 0x2c), xbc
	ld (xsp + 0x30), xwa
	ld xwa, (xsp + 0x2c)
	cp	xwa, EVT_I_AM_SELECTED
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnIAmSelected
	cp	xwa, EVT_SET_CHARA
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnSetChara
	cp	xwa, EVT_SET_CURSOR
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnSetCursor
	cp	xwa, EVT_SET_PAGE
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnSetPage
	cp	xwa, EVT_SET_AP_FUNCTION
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnSetApFunction
	cp	xwa, EVT_GET_STRING
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnGetString
	cp	xwa, EVT_SET_STRING
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnSetString
	cp	xwa, EVT_INDEXSW_DOWN
	jrl	z, HDAE5000_AcHddNamingWindowProc_Skip3
	cp	xwa, EVT_INDEXSW_DOWN_AIC
	jrl	z, HDAE5000_AcHddNamingWindowProc_Skip3
	cp	xwa, EVT_INDEXSW_UP
	jrl	z, HDAE5000_AcHddNamingWindowProc_Skip3
	cp	xwa, EVT_INDEXSW_UP_AIC
	jrl	z, HDAE5000_AcHddNamingWindowProc_Skip3
	cp	xwa, EVT_PARA_DRAW
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnParaDraw
	cp	xwa, EVT_SELE_DRAW
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnSeleDraw
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnHide
	cp	xwa, EVT_REPAINT
	jrl	z, HDAE5000_AcHddNamingWindowProc_Skip2
	cp	xwa, EVT_PAINT
	jrl	z, HDAE5000_AcHddNamingWindowProc_Skip2
	cp	xwa, EVT_SHOW
	jrl	nz, HDAE5000_AcHddNamingWindowProc_Skip4
	ld xwa, (xsp + 0x28)
	or xwa, xwa
	jr	z, HDAE5000_AcHddNamingWindowProc_Join
	ld xwa, (xsp + 0x28)
	cp	xwa, 0x00000003
	jr	z, HDAE5000_AcHddNamingWindowProc_Join
	ld xwa, (xsp + 0x28)
	cp	xwa, 0x00000005
	jrl	nz, HDAE5000_AcHddNamingWindowProc_Join6
HDAE5000_AcHddNamingWindowProc_Join:
	ld	xwa, (HDAE5000_RAM_NamingApFunction)
	or xwa, xwa
	jr	nz, HDAE5000_AcHddNamingWindowProc_Join2
	ld	xwa, NAKA_APFUNC_NamingCheck
	ld	(HDAE5000_RAM_NamingApFunction), xwa
HDAE5000_AcHddNamingWindowProc_Join2:
	ldw	(HDAE5000_RAM_NamingCursor:24), 0
	ldw	(0x22A02A:24), 0
	ld	xwa, (HDAE5000_RAM_NamingApFunction)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_ApFuncCall)
	ld	xbc, EVT_GET_STRING_LENGTH
	ld	xde, 0:i3
	call	(xix)
	ld	(HDAE5000_RAM_NamingLength), hl
	cpw	(HDAE5000_RAM_NamingLength:24), 32
	jr	ule, HDAE5000_AcHddNamingWindowProc_Join3
	ldw	(HDAE5000_RAM_NamingLength:24), 32
HDAE5000_AcHddNamingWindowProc_Join3:
	ld	xwa, (HDAE5000_RAM_NamingApFunction)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_ApFuncCall)
	ld	xbc, EVT_GET_NAMING_MODE
	ld	xde, 0:i3
	call	(xix)
	ld	(0x22a032), hl
	ld	wa, (0x22A032:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Blank1_Chr5F
	add	xbc, xwa
	ld xwa, (xbc)
	ld	(HDAE5000_RAM_NamingFillCharPtr), xwa
	cpw	(0x22A032:24), 0
	jr	z, HDAE5000_AcHddNamingWindowProc_Skip
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetVisible)
	ld	xwa, HDAE5000_OBJ_HddNamingABC
	ld	bc, 0:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetVisible)
	ld	xwa, HDAE5000_OBJ_HddNamingabc
	ld	bc, 0:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetVisible)
	ld	xwa, HDAE5000_OBJ_HddNamingSymbol
	ld	bc, 0:i3
	call	(xhl)
	jr	t, HDAE5000_AcHddNamingWindowProc_Join4
HDAE5000_AcHddNamingWindowProc_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetVisible)
	ld	xwa, HDAE5000_OBJ_HddNamingABC
	ld	bc, 1:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetVisible)
	ld	xwa, HDAE5000_OBJ_HddNamingabc
	ld	bc, 1:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetVisible)
	ld	xwa, HDAE5000_OBJ_HddNamingSymbol
	ld	bc, 1:i3
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_Join4:
	ld	iz, 0:i3
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	nc, HDAE5000_AcHddNamingWindowProc_Join5
HDAE5000_AcHddNamingWindowProc_Loop:
	ld	wa, iz
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	inc	1, iz
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	c, HDAE5000_AcHddNamingWindowProc_Loop
HDAE5000_AcHddNamingWindowProc_Join5:
	ld	wa, iz
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	(xbc), 0x00
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingApFunction)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_ApFuncCall)
	ld	xbc, EVT_GET_STRING
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_Join6:
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_SetDialUp)
	ld	xbc, EVT_INDEXSW_UP
	ld	xde, 5:i3
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_SetDialDown)
	ld	xbc, EVT_INDEXSW_DOWN
	ld	xde, 3:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetDialEnable)
	ld	wa, 1:i3
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_Skip2:
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ldw	(0x22A02C:24), 65535
	ldw	(HDAE5000_RAM_NamingSelCharDrawn:24), 65535
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnHide:
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnSeleDraw:
	ld xwa, (xsp + 0x28)
	ld	(HDAE5000_RAM_NamingSelChar), wa
	ld	wa, (HDAE5000_RAM_NamingSelCharDrawn:24)
	cp	wa, (HDAE5000_RAM_NamingSelChar:24)
	jrl	z, HDAE5000_AcHddNamingWindowProc_Join8
	lda	xwa, (xsp+32)
	ld	xbc, xwa
	ld xwa, (xsp + 0x30)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_GetClientBox)
	call	(xhl)
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	cpw	(HDAE5000_RAM_NamingSelCharDrawn:24), 65535
	jrl	z, HDAE5000_AcHddNamingWindowProc_Join7
	ld	wa, (HDAE5000_RAM_NamingSelCharDrawn:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingSelCharDrawn:24)
	extz xwa
	div wa, 0x000d
	mul	wa, 0x0018
	ld	bc, wa
	ld	wa, (xsp+34)
	add	wa, 0x000a
	add	wa, bc
	ld (xsp + 0x1a), wa
	ld	wa, (HDAE5000_RAM_NamingSelCharDrawn:24)
	extz xwa
	div wa, 0x000d
	ld	wa, qwa
	ld	bc, wa
	sll	bc, 0x04
	ld	wa, (xsp+32)
	add	wa, 0x000e
	add	wa, bc
	dec	1, wa
	ld (xsp + 0x18), wa
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	sll	hl, 0x03
	ld	wa, (xsp+24)
	add	wa, hl
	inc	2, wa
	ld (xsp + 0x1c), wa
	ld	wa, (xsp+26)
	add	wa, 0x0011
	ld (xsp + 0x1e), wa
	lda	xwa, (xsp+24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_DrawFrame)
	ldw	bc, 0x00f5
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_Join7:
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	div wa, 0x000d
	mul	wa, 0x0018
	ld	bc, wa
	ld	wa, (xsp+34)
	add	wa, 0x000a
	add	wa, bc
	ld (xsp + 0x1a), wa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	div wa, 0x000d
	ld	wa, qwa
	ld	bc, wa
	sll	bc, 0x04
	ld	wa, (xsp+32)
	add	wa, 0x000e
	add	wa, bc
	dec	1, wa
	ld (xsp + 0x18), wa
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	sll	hl, 0x03
	ld	wa, (xsp+24)
	add	wa, hl
	inc	2, wa
	ld (xsp + 0x1c), wa
	ld	wa, (xsp+26)
	add	wa, 0x0011
	ld (xsp + 0x1e), wa
	lda	xwa, (xsp+24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_DrawFrame)
	ldw	bc, 0x00f2
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	ld	(HDAE5000_RAM_NamingSelCharDrawn), wa
HDAE5000_AcHddNamingWindowProc_Join8:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnParaDraw:
	ld	wa, (0x22A02C:24)
	cp	wa, (0x22A02A:24)
	jrl	z, HDAE5000_AcHddNamingWindowProc_Join9
	ldw	(HDAE5000_RAM_NamingSelCharDrawn:24), 65535
	lda	xwa, (xsp+32)
	ld	xbc, xwa
	ld xwa, (xsp + 0x30)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_GetClientBox)
	call	(xhl)
	lda	xwa, (xsp+32)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_DrawBox)
	ldw	bc, 0x00f5
	call	(xhl)
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	ld	iz, 0:i3
	jr	t, HDAE5000_AcHddNamingWindowProc_Next
HDAE5000_AcHddNamingWindowProc_Loop2:
	ld	wa, iz
	extz xwa
	div wa, 0x000d
	ld	wa, qwa
	ld	bc, wa
	sll	bc, 0x04
	ld	wa, (xsp+32)
	add	wa, 0x000e
	add	wa, bc
	ld (xsp + 0x14), wa
	ld	wa, iz
	extz xwa
	div wa, 0x000d
	mul	wa, 0x0018
	ld	bc, wa
	ld	wa, (xsp+34)
	add	wa, 0x000a
	add	wa, bc
	ld (xsp + 0x16), wa
	lda	xwa, (xsp+32)
	ld	xhl, xwa
	lda	xwa, (xsp+20)
	ld	xbc, xwa
	ld	wa, iz
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	ld	xwa, 0:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f7
	ld	xwa, xhl
	ld xde, (xde)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	inc	1, iz
HDAE5000_AcHddNamingWindowProc_Next:
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	add	wa, (0x22A02A:24)
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	cp	iz, (xbc)
	jrl	ule, HDAE5000_AcHddNamingWindowProc_Loop2
	ld	wa, (0x22A02A:24)
	ld	(0x22a02c), wa
HDAE5000_AcHddNamingWindowProc_Join9:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_Skip3:
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x28)
	dec	1, xwa
	cp	xwa, 0x00000000
	jrl	c, HDAE5000_AcHddNamingWindowProc_Join10
	cp	xwa, 0x00000008
	jrl	ugt, HDAE5000_AcHddNamingWindowProc_Join10
	add	xwa, xwa
	add	xwa, HDAE5000_AcHddNamingWindowProc_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_AcHddNamingWindowProc_OnPositionLeft:24)
	jp	t, (xix+wa)
; HDAE5000_AcHddNamingWindowProc_OnPositionLeft: index switch 1, the left key under POSITION: move the name cursor one
;   place left (auto-repeats)
HDAE5000_AcHddNamingWindowProc_OnPositionLeft:
	cpw	(HDAE5000_RAM_NamingCursor:24), 0
	jrl	z, HDAE5000_AcHddNamingWindowProc_Join10
	decw	1, (HDAE5000_RAM_NamingCursor:24)
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnPositionRight: index switch 2, the right key under POSITION: move the name cursor
;   one place right, below the name length 0x22A026 (auto-repeats)
HDAE5000_AcHddNamingWindowProc_OnPositionRight:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	inc	1, wa
	cp	wa, (HDAE5000_RAM_NamingLength:24)
	jrl	nc, HDAE5000_AcHddNamingWindowProc_Join10
	incw	1, (HDAE5000_RAM_NamingCursor:24)
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnPrevCharacter: index switch 3 (also the dial-down binding): select the previous
;   character of the page and write it at the cursor
HDAE5000_AcHddNamingWindowProc_OnPrevCharacter:
	cpw	(HDAE5000_RAM_NamingSelChar:24), 0
	jrl	z, HDAE5000_AcHddNamingWindowProc_Join10
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	decw	1, (HDAE5000_RAM_NamingSelChar:24)
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xsp+10)
	ld	(xbc), a
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingSelChar:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SELE_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown: index switch 4: UP moves the character selection one row (13
;   characters) back, DOWN one row forward, and writes it at the cursor
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown:
	ld xwa, (xsp + 0x2c)
	cp	xwa, EVT_INDEXSW_DOWN
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Skip
	cp	xwa, EVT_INDEXSW_DOWN_AIC
	jrl	z, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Skip
	cp	xwa, EVT_INDEXSW_UP
	jr	z, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join
	cp	xwa, EVT_INDEXSW_UP_AIC
	jrl	nz, HDAE5000_AcHddNamingWindowProc_Join10
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join:
	cpw	(HDAE5000_RAM_NamingSelChar:24), 13
	jrl	c, HDAE5000_AcHddNamingWindowProc_Join10
	subw	(HDAE5000_RAM_NamingSelChar:24), 13
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xsp+10)
	ld	(xbc), a
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingSelChar:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SELE_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Skip:
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	add	wa, (0x22A02A:24)
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	add	wa, 0x000c
	cp	wa, (xbc)
	jr	ugt, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join3
	cp	(xsp+10), 0x5a
	jr	z, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join2
	cp	(xsp+10), 0x7a
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join3
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join2:
	decw	1, (HDAE5000_RAM_NamingSelChar:24)
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join3:
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	add	wa, (0x22A02A:24)
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	add	wa, 0x000d
	cp	wa, (xbc)
	jrl	ugt, HDAE5000_AcHddNamingWindowProc_Join10
	addw	(HDAE5000_RAM_NamingSelChar:24), 13
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	cp	(xsp+10), 0x53
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Skip2
	cp	(xsp+11), 0x50
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Skip2
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	jr	t, HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join4
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Skip2:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xsp+10)
	ld	(xbc), a
HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown_Join4:
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingSelChar:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SELE_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnNextCharacter: index switch 5 (also the dial-up binding): select the next character
;   of the page and write it at the cursor
HDAE5000_AcHddNamingWindowProc_OnNextCharacter:
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	add	wa, (0x22A02A:24)
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	inc	1, wa
	cp	wa, (xbc)
	jrl	ugt, HDAE5000_AcHddNamingWindowProc_Join10
	incw	1, (HDAE5000_RAM_NamingSelChar:24)
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	cp	(xsp+10), 0x53
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnNextCharacter_Skip
	cp	(xsp+11), 0x50
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnNextCharacter_Skip
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	jr	t, HDAE5000_AcHddNamingWindowProc_OnNextCharacter_Join
HDAE5000_AcHddNamingWindowProc_OnNextCharacter_Skip:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xsp+10)
	ld	(xbc), a
HDAE5000_AcHddNamingWindowProc_OnNextCharacter_Join:
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingSelChar:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SELE_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld	xhl, (xhl + RootFn_SetAutoInc)
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnInsert: INS: shift the name right from the cursor and put the fill character
;   (0x22A034) at the cursor
HDAE5000_AcHddNamingWindowProc_OnInsert:
	ld	iz, (HDAE5000_RAM_NamingLength:24)
	dec	1, iz
	cp	iz, (HDAE5000_RAM_NamingCursor:24)
	jr	ule, HDAE5000_AcHddNamingWindowProc_OnInsert_Join
HDAE5000_AcHddNamingWindowProc_OnInsert_Loop:
	ld	wa, iz
	extz xwa
	ld	xde, HDAE5000_RAM_NamingText
	add	xde, xwa
	ld	wa, iz
	dec	1, wa
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	ld	(xde), a
	dec	1, iz
	cp	iz, (HDAE5000_RAM_NamingCursor:24)
	jr	ugt, HDAE5000_AcHddNamingWindowProc_OnInsert_Loop
HDAE5000_AcHddNamingWindowProc_OnInsert_Join:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnDelete: DEL: shift the name left over the cursor and put the fill character at the
;   end
HDAE5000_AcHddNamingWindowProc_OnDelete:
	ld	iz, (HDAE5000_RAM_NamingCursor:24)
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	nc, HDAE5000_AcHddNamingWindowProc_OnDelete_Join
HDAE5000_AcHddNamingWindowProc_OnDelete_Loop:
	ld	wa, iz
	extz xwa
	ld	xde, HDAE5000_RAM_NamingText
	add	xde, xwa
	ld	wa, iz
	inc	1, wa
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	ld	(xde), a
	inc	1, iz
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	c, HDAE5000_AcHddNamingWindowProc_OnDelete_Loop
HDAE5000_AcHddNamingWindowProc_OnDelete_Join:
	ld	wa, (HDAE5000_RAM_NamingLength:24)
	dec	1, wa
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnCenterName: centre the name: count leading and trailing fill characters and re-pad
;   the trimmed text with half of them on each side
HDAE5000_AcHddNamingWindowProc_OnCenterName:
	ldw (xsp + 0x04), 0
	ld	iz, 0:i3
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	nc, HDAE5000_AcHddNamingWindowProc_OnCenterName_Join
HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop:
	ld	wa, iz
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	cp	a, (xbc)
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnCenterName_Join
	incw	1, (xsp+4)
	inc	1, iz
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	c, HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop
HDAE5000_AcHddNamingWindowProc_OnCenterName_Join:
	ld	wa, (xsp+4)
	cp	wa, (HDAE5000_RAM_NamingLength:24)
	jrl	z, HDAE5000_AcHddNamingWindowProc_Join10
	ldw (xsp + 0x06), 0
	ld	iz, 0:i3
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	nc, HDAE5000_AcHddNamingWindowProc_OnCenterName_Join2
HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop2:
	ld	wa, (HDAE5000_RAM_NamingLength:24)
	sub	wa, iz
	dec	1, wa
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	cp	a, (xbc)
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnCenterName_Join2
	incw	1, (xsp+6)
	inc	1, iz
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	c, HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop2
HDAE5000_AcHddNamingWindowProc_OnCenterName_Join2:
	ld	wa, (xsp+4)
	ld (xsp + 0x08), wa
	ld	wa, (xsp+6)
	add	(xsp+8), wa
	srlw_rid8 xsp, 0x08		; srlw (XSP+0x08)
	ld	wa, (HDAE5000_RAM_NamingLength:24)
	inc	1, wa
	extz xwa
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld	xix, (xbc + HamaFn_malloc_X)
	call	(xix)
	ld	xiz, xhl
	ld	wa, (xsp+4)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	push xbc
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrCpy
	ld	wa, (HDAE5000_RAM_NamingLength:24)
	sub	wa, (xsp+12)
	sub	wa, (xsp+14)
	extz xwa
	add	xwa, xiz
	ld	(xwa), 0x00
	ld	xwa, xiz
	push xwa
	ld	wa, (xsp+20)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	push xbc
	call HDAE5000_StrCpy
	lda	xsp, (xsp+16)
	ld	xwa, xiz
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld	xhl, (xbc + HamaFn_free_X)
	call	(xhl)
	ld	iz, 0:i3
	cp	iz, (xsp+8)
	jr	nc, HDAE5000_AcHddNamingWindowProc_OnCenterName_Join3
HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop3:
	ld	wa, iz
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	inc	1, iz
	cp	iz, (xsp+8)
	jr	c, HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop3
HDAE5000_AcHddNamingWindowProc_OnCenterName_Join3:
	ld	wa, (xsp+4)
	add	wa, (xsp+6)
	sub	wa, (xsp+8)
	ld	iz, (HDAE5000_RAM_NamingLength:24)
	sub	iz, wa
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	nc, HDAE5000_AcHddNamingWindowProc_OnCenterName_Join4
HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop4:
	ld	wa, iz
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	inc	1, iz
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	c, HDAE5000_AcHddNamingWindowProc_OnCenterName_Loop4
HDAE5000_AcHddNamingWindowProc_OnCenterName_Join4:
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	jrl	t, HDAE5000_AcHddNamingWindowProc_Join10
; HDAE5000_AcHddNamingWindowProc_OnClear: CLR: fill the whole name with the fill character and put the cursor at 0
HDAE5000_AcHddNamingWindowProc_OnClear:
	ld	iz, 0:i3
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	nc, HDAE5000_AcHddNamingWindowProc_OnClear_Join
HDAE5000_AcHddNamingWindowProc_OnClear_Loop:
	ld	wa, iz
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	(xbc), a
	inc	1, iz
	cp	iz, (HDAE5000_RAM_NamingLength:24)
	jr	c, HDAE5000_AcHddNamingWindowProc_OnClear_Loop
HDAE5000_AcHddNamingWindowProc_OnClear_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_SET_CURSOR
	ld	xde, 0:i3
	call	(xhl)
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_Join10:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnSetString:
	ld xwa, (xsp + 0x28)
	push xwa
	lda xwa, (HDAE5000_RAM_NamingText:24)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnGetString:
	lda xwa, (HDAE5000_RAM_NamingText:24)
	push xwa
	ld xwa, (xsp + 0x2c)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnSetApFunction:
	ld xwa, (xsp + 0x28)
	ld	(HDAE5000_RAM_NamingApFunction), xwa
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnSetPage:
	ld xwa, (xsp + 0x28)
	ld	(0x22a02a), wa
	cpw	(0x22A032:24), 0
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join2
	ld xwa, (xsp + 0x28)
	extz xwa
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, 0xffffffff
	ld	xbc, EVT_YOU_ARE_SELECTED
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_OnClear_Join2:
	ld	de, (0x22A02A:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526
	add	xbc, xwa
	ld xde, (xbc)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingLabel
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnSetCursor:
	ld xwa, (xsp + 0x28)
	ld	(HDAE5000_RAM_NamingCursor), wa
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	lda xwa, (HDAE5000_RAM_NamingText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingCursorBox
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	extz wa
	lda xbc, (HDAE5000_CType_Table:24)
	bit	0, (xbc+wa)
	jr	z, HDAE5000_AcHddNamingWindowProc_OnClear_Skip
	ldw	(0x22A02A:24), 0
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	sub	a, 0x41
	extz wa
	ld	(HDAE5000_RAM_NamingSelChar), wa
	jrl	t, HDAE5000_AcHddNamingWindowProc_OnClear_Join7
HDAE5000_AcHddNamingWindowProc_OnClear_Skip:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	extz wa
	lda xbc, (HDAE5000_CType_Table:24)
	bit	1, (xbc+wa)
	jr	z, HDAE5000_AcHddNamingWindowProc_OnClear_Skip2
	ldw	(0x22A02A:24), 1
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	sub	a, 0x61
	extz wa
	ld	(HDAE5000_RAM_NamingSelChar), wa
	jrl	t, HDAE5000_AcHddNamingWindowProc_OnClear_Join7
HDAE5000_AcHddNamingWindowProc_OnClear_Skip2:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	extz wa
	lda xbc, (HDAE5000_CType_Table:24)
	bit	2, (xbc+wa)
	jr	z, HDAE5000_AcHddNamingWindowProc_OnClear_Skip3
	cpw	(0x22A02A:24), 2
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join3
	ldw	(0x22A02A:24), 0
HDAE5000_AcHddNamingWindowProc_OnClear_Join3:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	sub	a, 0x15
	extz wa
	ld	(HDAE5000_RAM_NamingSelChar), wa
	jrl	t, HDAE5000_AcHddNamingWindowProc_OnClear_Join7
HDAE5000_AcHddNamingWindowProc_OnClear_Skip3:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	cp	(xbc), 0x20
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Skip4
	cpw	(0x22A032:24), 0
	jrl	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join7
	cpw	(0x22A02A:24), 2
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join4
	ldw	(0x22A02A:24), 0
HDAE5000_AcHddNamingWindowProc_OnClear_Join4:
	ldw	(HDAE5000_RAM_NamingSelChar:24), 37
	jrl	t, HDAE5000_AcHddNamingWindowProc_OnClear_Join7
HDAE5000_AcHddNamingWindowProc_OnClear_Skip4:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	cp	(xbc), 0x5f
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Skip5
	cpw	(0x22A02A:24), 2
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join5
	ldw	(0x22A02A:24), 0
HDAE5000_AcHddNamingWindowProc_OnClear_Join5:
	ldw	(HDAE5000_RAM_NamingSelChar:24), 26
	jr	t, HDAE5000_AcHddNamingWindowProc_OnClear_Join7
HDAE5000_AcHddNamingWindowProc_OnClear_Skip5:
	lda xwa, (HDAE5000_TextPtrs_Chr21_to_Chr7D:24)
	ld (xsp + 0x06), xwa
	ld	iz, 0:i3
	jr	t, HDAE5000_AcHddNamingWindowProc_OnClear_Next
HDAE5000_AcHddNamingWindowProc_OnClear_Loop2:
	ld	wa, iz
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld	a, (xbc)
	cp	a, (xsp+10)
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join6
	ldw	(0x22A02A:24), 2
	ld	(HDAE5000_RAM_NamingSelChar), iz
HDAE5000_AcHddNamingWindowProc_OnClear_Join6:
	inc	1, iz
HDAE5000_AcHddNamingWindowProc_OnClear_Next:
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	inc	2, wa
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	cp	iz, (xbc)
	jr	ule, HDAE5000_AcHddNamingWindowProc_OnClear_Loop2
HDAE5000_AcHddNamingWindowProc_OnClear_Join7:
	ld	de, (0x22A02A:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_PAGE
	call	(xhl)
	ld	de, (HDAE5000_RAM_NamingSelChar:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SELE_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnSetChara:
	ld	wa, (HDAE5000_RAM_NamingCursor:24)
	extz xwa
	ld	xbc, HDAE5000_RAM_NamingText
	add	xbc, xwa
	ld xwa, (xsp + 0x28)
	ld	(xbc), a
	ld	de, (HDAE5000_RAM_NamingCursor:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CURSOR
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_OnIAmSelected:
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x28)
	srl	xwa, 16
	ld	qwa, 0
	cp	wa, 0:i3
	jrl	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Join10
	ld xwa, (xsp + 0x28)
	ld	bc, wa
	extz xbc
	ld xwa, (xsp + 0x30)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_PAGE
	call	(xhl)
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	add	wa, (0x22A02A:24)
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	cp	wa, (xbc)
	jr	ule, HDAE5000_AcHddNamingWindowProc_OnClear_Join8
	ld	wa, (0x22A032:24)
	mul	wa, 0x0003
	add	wa, (0x22A02A:24)
	extz xwa
	add	xwa, xwa
	ld	xbc, HDAE5000_Str_Chr25_AcHddNamingWindowProc
	add	xbc, xwa
	ld	wa, (xbc)
	ld	(HDAE5000_RAM_NamingSelChar), wa
HDAE5000_AcHddNamingWindowProc_OnClear_Join8:
	ld	wa, (0x22A02A:24)
	extz xwa
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TablePtrs_AcHddNamingWindowProc
	add	xbc, xwa
	ld xwa, (xbc)
	ld (xsp + 0x06), xwa
	ld	wa, (HDAE5000_RAM_NamingSelChar:24)
	extz xwa
	sll	xwa, 0x02
	ld	xde, xwa
	add	xde, (xsp+6)
	lda	xwa, (xsp+10)
	ld	xbc, xwa
	ld xwa, (xde)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_ConvertStrings)
	call	(xhl)
	cp	(xsp+10), 0x53
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Skip6
	cp	(xsp+11), 0x50
	jr	nz, HDAE5000_AcHddNamingWindowProc_OnClear_Skip6
	ld	xwa, (HDAE5000_RAM_NamingFillCharPtr)
	ld	a, (xwa)
	ld	xbc, 0:i3
	ld	c, a
	ld xwa, (xsp + 0x30)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CHARA
	call	(xhl)
	jr	t, HDAE5000_AcHddNamingWindowProc_OnClear_Join9
HDAE5000_AcHddNamingWindowProc_OnClear_Skip6:
	ld	a, (xsp+10)
	ld	xbc, 0:i3
	ld	c, a
	ld xwa, (xsp + 0x30)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_CHARA
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_OnClear_Join9:
	ld	de, (HDAE5000_RAM_NamingSelChar:24)
	extz xde
	ld xwa, (xsp + 0x30)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SELE_DRAW
	call	(xhl)
HDAE5000_AcHddNamingWindowProc_OnClear_Join10:
	ld	xhl, 0:i3
	jr	t, HDAE5000_AcHddNamingWindowProc_Epilogue
HDAE5000_AcHddNamingWindowProc_Skip4:
	ld xwa, (xsp + 0x30)
	ld xbc, (xsp + 0x2c)
	ld xde, (xsp + 0x28)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_AcHddNamingWindowProc_Epilogue:
	pop xiz
	lda	xsp, (xsp+48)
	ret

HDAE5000_IvHddNamingProc:
	; registered as "IvHddNamingProc" in HDAE5000_ClassProc_Table
	dec 8, xsp
	push xiz
	ld	xiz, xde
	ld (xsp + 0x04), xbc
	ld (xsp + 0x08), xwa
	ld xwa, (xsp + 0x04)
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_IvHddNamingProc_OnHide
	cp	xwa, EVT_SHOW
	jr	z, HDAE5000_IvHddNamingProc_OnShow
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_IvHddNamingProc_OnDraw
	ld xwa, (xsp + 0x08)
	ld xbc, (xsp + 0x04)
	ld	xde, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_IvHddNamingProc_Epilogue
HDAE5000_IvHddNamingProc_OnDraw:
	ld xwa, (xsp + 0x08)
	ld xbc, (xsp + 0x04)
	ld	xde, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_Name:24)
	ld	xbc, xwa
	ld xwa, (xsp + 0x08)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_IvHddNamingProc_Epilogue
HDAE5000_IvHddNamingProc_OnShow:
	ld xwa, (xsp + 0x08)
	ld xbc, (xsp + 0x04)
	ld	xde, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x08)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld xde, (xhl + 0x16)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xbc, EVT_SET_AP_FUNCTION
	call	(xhl)
	ld xbc, (xsp + 0x04)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_IvHddNamingProc_Epilogue
HDAE5000_IvHddNamingProc_OnHide:
	ld xbc, (xsp + 0x04)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xde, 0:i3
	call	(xhl)
	ld xwa, (xsp + 0x08)
	ld xbc, (xsp + 0x04)
	ld	xde, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
HDAE5000_IvHddNamingProc_Epilogue:
	pop xiz
	inc 8, xsp
	ret

HDAE5000_HDTitleMenuProc:
	; registered as "HDTitleMenuProc" in HDAE5000_ClassProc_Table
	ld	xhl, xbc
	cp	xhl, EVT_PARA_DRAW
	jr	z, HDAE5000_HDTitleMenuProc_OnParaDraw
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	jp	(xix)
HDAE5000_HDTitleMenuProc_OnParaDraw:
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HD_MENU_BMP
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
	ret


; ---------------------------------------------------------------------------
; Print a line on the hardware-test page: tail-jumps to the main CPU's
; RootFn_SendEvent with XWA = 0xFFFFFFFF (object id), XBC = EVT_MEMO_DRAW,
; XDE = the string.  Callers: HDAE5000_HardTestPage and its tests
; HDAE5000_HardTest_PortTest / _HddIdRead.
; In:  XWA = string
; Out: whatever RootFn_SendEvent returns.
; RAM: HDAE5000_RAM_MainWorkspacePtr
; ---------------------------------------------------------------------------
HDAE5000_HardTest_Print:
	ld xde, xwa					; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20 — load context base
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — xwa = (xwa+0x0e0a) vtable ptr
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — xhl = (xwa+0x0100) callback
	ld xwa, 0xffffffff				; 40 ff ff ff ff
	ld xbc, EVT_MEMO_DRAW				; 41 25 00 c0 01
	jp (xhl)					; b3 d8
	; Entry point 2: main event handler dispatcher
HDAE5000_HardTestPage:
	; registered as "HardTestPage" in HDAE5000_ObjHandler_Table
	dec 8, xsp					; ef 68 — allocate stack frame
	push xiz					; 3e
	ld (xsp + 0x04), xde				; bf 04 62 — save XDE
	ld (xsp + 0x08), xbc				; bf 08 61 — save XBC
	ld xiz, xwa					; e8 8e — save context in XIZ
	ld xwa, (xsp + 0x08)				; af 08 20 — load event code
	cp xwa, EVT_SW_IN				; e8 cf 07 00 c0 01
	jr z, .Leh_event_c00007			; 66 55
	cp xwa, EVT_DRAW				; e8 cf 0d 00 c0 01
	jr z, .Leh_event_c0000d			; 66 0e
	cp xwa, EVT_ARE_YOU_CLASS_PROC				; e8 cf 85 00 e0 01
	jrl nz, .Leh_epilogue				; 7e 43 03
	; Event 0x01E00085: return 1 (acknowledge)
	ld xhl, 1:i3					; eb a9
	jrl t, .Leh_return				; 78 57 03
	; Event 0x01C0000D: forward to vtable callback
.Leh_event_c0000d:
	ld xwa, xiz					; ee 88 — restore context
	ld xbc, (xsp + 0x08)				; af 08 21
	ld xde, (xsp + 0x04)				; af 04 22
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23 — xhl = (xhl+0x0e0a)
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 23 — xhl = (xhl+0x00dc) indirect call
	call (xhl)					; b3 e8
	lda xwa, (HDAE5000_Str_Test:24); f2 ec 19 2e 30
	ld xbc, xwa					; e8 89
	ld xwa, xiz					; ee 88
	ld xde, xbc					; e9 8a
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21 — xbc = (xbc+0x0e0a)
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; e3 e5 00 01 23 — xhl = (xbc+0x0100) callback
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	call (xhl)					; b3 e8
	ld xhl, 0:i3					; eb a8
	jrl t, .Leh_return				; 78 18 03
	; Event 0x01C00007: sub-dispatch on XDE value
.Leh_event_c00007:
	ld xwa, (xsp + 0x04)				; af 04 20 — load XDE arg
	cp xwa, 0x0000000c				; e8 cf 0c 00 00 00
	jrl z, .Leh_xde_0c				; 76 62 02
	cp xwa, 0x0000000b				; e8 cf 0b 00 00 00
	jrl z, .Leh_xde_0b				; 76 6a 01
	cp xwa, 0x0000000a				; e8 cf 0a 00 00 00
	jrl z, .Leh_xde_0a				; 76 b5 00
	cp xwa, 0x00000009				; e8 cf 09 00 00 00
	jrl nz, .Leh_epilogue				; 7e d8 02
	; XDE == 0x09: register event 0x4B, call init, register vtable callback
.Leh_xde_09:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — callback ptr
	ld xwa, HDAE5000_OBJ_PPORT_SW				; 40 4c 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 1:i3					; ea a9
	call (xhl)					; b3 e8 — register event
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_UpdateScreen)             ; e3 e1 84 00 23 — (xwa+0x0084) init fn
	call (xhl)					; b3 e8 — call init
	call HDAE5000_YieldUntilSem1Zero		; 1d f3 ac 28
	lda xwa, (HDAE5000_Str_PPORTTEST:24); f2 f2 19 2e 30
	calr HDAE5000_HardTest_Print			; 1e 17 ff — register handler
	calr HDAE5000_HardTest_PortTest		; 1e 47 03
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_PPORT_SW				; 40 4c 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8 — unregister event
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24 — xix = callback
	ld xwa, HDAE5000_OBJ_RUN_STOP				; 40 4a 00 7f 00
	ld xbc, EVT_GET_PARAM				; 41 6b 00 e0 01
	ld xde, 0:i3					; ea a8
	call (xix)					; b4 e8
	cp xhl, 0x00000001				; eb cf 01 00 00 00
	jrl nz, .Leh_epilogue				; 7e 58 02
	; Post-call: push event/subcode, invoke dispatch
	ld xwa, EVT_SW_IN				; 40 07 00 c0 01
	push xwa					; 38
	ld xwa, 0x0000000a				; 40 0a 00 00 00
	push xwa					; 38
	ld xbc, xiz					; ee 89
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23 — (xwa+0x0410) dispatch
	ld xwa, 0x00000029				; 40 29 00 00 00
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	jrl t, .Leh_epilogue				; 78 2c 02
	; XDE == 0x0A: register event 0x4D, write sector
.Leh_xde_0a:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_HDD_SW				; 40 4e 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 1:i3					; ea a9
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_UpdateScreen)             ; e3 e1 84 00 23 — init fn
	call (xhl)					; b3 e8
	call HDAE5000_YieldUntilSem1Zero		; 1d f3 ac 28
	lda xwa, (HDAE5000_Str_HDDIDREAD:24); f2 fe 19 2e 30
	calr HDAE5000_HardTest_Print			; 1e 6b fe
	calr HDAE5000_HardTest_HddIdRead			; 1e e2 02
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_HDD_SW				; 40 4e 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24
	ld xwa, HDAE5000_OBJ_RUN_STOP				; 40 4a 00 7f 00
	ld xbc, EVT_GET_PARAM				; 41 6b 00 e0 01
	ld xde, 0:i3					; ea a8
	call (xix)					; b4 e8
	cp xhl, 0x00000001				; eb cf 01 00 00 00
	jrl nz, .Leh_epilogue				; 7e ac 01
	ld xwa, EVT_SW_IN				; 40 07 00 c0 01
	push xwa					; 38
	ld xwa, 0x0000000b				; 40 0b 00 00 00
	push xwa					; 38
	ld xbc, xiz					; ee 89
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23
	ld xwa, 0x00000029				; 40 29 00 00 00
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	jrl t, .Leh_epilogue				; 78 80 01
	; XDE == 0x0B: register event 0x4C, read/check disk status
.Leh_xde_0b:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_FD_SW				; 40 4d 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 1:i3					; ea a9
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_UpdateScreen)             ; e3 e1 84 00 23
	call (xhl)					; b3 e8
	call HDAE5000_YieldUntilSem1Zero		; 1d f3 ac 28
	lda xwa, (HDAE5000_Str_FDTEST:24); f2 0a 1a 2e 30
	calr HDAE5000_HardTest_Print			; 1e bf fd
	; Check disk status via 0x0e88 table
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_HamaFnTable)             ; e3 e1 88 0e 20 — (xwa+0x0e88)
	ld xix, (xwa + HamaFn_GetMediaType)				; a8 08 24
	call (xix)					; b4 e8
	cp l, 3:i3					; cf db
	jr z, .Leh_status_2or3			; 66 04
	cp l, 2:i3					; cf da
	jr nz, .Leh_status_other			; 6e 27
.Leh_status_2or3:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_HamaFnTable)             ; e3 e1 88 0e 20
	ld xix, (xwa + HamaFn_FDLoadSaveTest)				; a8 04 24
	call (xix)					; b4 e8
	cp hl, 0:i3					; db d8
	jr nz, .Leh_status_nonzero			; 6e 0a
	lda xwa, (HDAE5000_Str_OK:24); f2 12 1a 2e 30
	calr HDAE5000_HardTest_Print			; 1e 8d fd
	jr t, .Leh_after_status			; 68 12
.Leh_status_nonzero:
	lda xwa, (HDAE5000_Str_ERROR:24); f2 16 1a 2e 30
	calr HDAE5000_HardTest_Print			; 1e 83 fd
	jr t, .Leh_after_status			; 68 08
.Leh_status_other:
	lda xwa, (HDAE5000_Str_ERROR_HardTestPage:24); f2 1c 1a 2e 30
	calr HDAE5000_HardTest_Print			; 1e 79 fd
.Leh_after_status:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_FD_SW				; 40 4d 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24
	ld xwa, HDAE5000_OBJ_RUN_STOP				; 40 4a 00 7f 00
	ld xbc, EVT_GET_PARAM				; 41 6b 00 e0 01
	ld xde, 0:i3					; ea a8
	call (xix)					; b4 e8
	cp xhl, 0x00000001				; eb cf 01 00 00 00
	jrl nz, .Leh_epilogue				; 7e bd 00
	ld xwa, EVT_SW_IN				; 40 07 00 c0 01
	push xwa					; 38
	ld xwa, 0x00000009				; 40 09 00 00 00
	push xwa					; 38
	ld xbc, xiz					; ee 89
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23
	ld xwa, 0x00000029				; 40 29 00 00 00
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	jrl t, .Leh_epilogue				; 78 91 00
	; XDE == 0x0C: check device, show status messages
.Leh_xde_0c:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24
	ld xwa, HDAE5000_OBJ_RUN_STOP				; 40 4a 00 7f 00
	ld xbc, EVT_GET_PARAM				; 41 6b 00 e0 01
	ld xde, 0:i3					; ea a8
	call (xix)					; b4 e8
	cp xhl, 0x00000001				; eb cf 01 00 00 00
	jr nz, .Leh_xde_0c_no_device			; 6e 27
	; Device present: show "connected" message
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_RUN_STOP				; 40 4a 00 7f 00
	ld xbc, EVT_SET_PARAM				; 41 3b 00 e0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	lda xwa, (HDAE5000_Str_STOPTESTLOOP:24); f2 22 1a 2e 30
	calr HDAE5000_HardTest_Print			; 1e c0 fc
	jr t, .Leh_epilogue				; 68 45
.Leh_xde_0c_no_device:
	; Device not present: show "not connected" message
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23
	ld xwa, HDAE5000_OBJ_RUN_STOP				; 40 4a 00 7f 00
	ld xbc, EVT_SET_PARAM				; 41 3b 00 e0 01
	ld xde, 1:i3					; ea a9
	call (xhl)					; b3 e8
	lda xwa, (HDAE5000_Str_STARTTESTLOOP:24); f2 32 1a 2e 30
	calr HDAE5000_HardTest_Print			; 1e 99 fc
	; Final cleanup: call deregister via vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23 — (xwa+0x0104) deregister
	ld xwa, 0xffffffff				; 40 ff ff ff ff
	ld xbc, EVT_SW_IN				; 41 07 00 c0 01
	ld xde, 0x00000009				; 42 09 00 00 00
	call (xhl)					; b3 e8
	; Epilogue: restore regs, call cleanup callback, return
.Leh_epilogue:
	ld xwa, xiz					; ee 88
	ld xbc, (xsp + 0x08)				; af 08 21
	ld xde, (xsp + 0x04)				; af 04 22
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23 — xhl = (xhl+0x0e0a)
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 24 — xix = (xhl+0x00dc)
	call (xix)					; b4 e8
.Leh_return:
	pop xiz					; 5e
	inc 8, xsp					; ef 60 — deallocate stack frame
	ret						; 0e

; --- PPI/IDE Low-Level I/O ---
HDAE5000_PPI_Init:	; (13 bytes)
	; 8255 control word 0x90: mode 0, port A input, ports B and C output;
	; then 0xFF to port A.
	ld (HDAE5000_IO_PpiControl:24), 0x90
	ld (HDAE5000_IO_PpiPortA:24), 0xff
	ret

; ---------------------------------------------------------------------------
; Send byte A through the 8255 in two nibbles (ports B and C, handshake on
; port A bit 4) and read it back from port A -- the loopback of the hardware
; test's "PPORT TEST".  (Not the drive: that sits on the ATA registers,
; HDAE5000_ATA_*.)
; In:  A = byte
; Out: L = 0x00 when it came back unchanged, 0xFF otherwise.
; ---------------------------------------------------------------------------
HDAE5000_PPI_LoopbackByte:
	ld l, a				; save original byte
	and a, 0x0f			; mask low nibble
	set 4, a			; set bit 4 (data strobe)
	sll a, 3			; shift left 3
	ld (HDAE5000_IO_PpiPortB:24), a
	ld c, a				; save port B value
	srl c, 6			; shift right 6 for port C
	ld (HDAE5000_IO_PpiPortC:24), c
	res 7, a			; clear bit 7 (handshake low)
	srl a, 6			; shift right 6
	ld (HDAE5000_IO_PpiPortC:24), a
	ld xwa, 0x000003E8		; timeout counter (1000)
.Lppi_wait_high:
	bit 4, (HDAE5000_IO_PpiPortA:24)	; check ACK
	jr z, .Lppi_wait_high		; wait until bit 4 set
	ld a, (HDAE5000_IO_PpiPortA:24)	; read port A
	and a, 0x0f			; mask low nibble
	ld e, a				; save low nibble in E
	; --- High nibble phase ---
	ld a, l				; restore original byte
	srl a, 1			; shift right 1
	res 7, a			; clear bit 7
	ld (HDAE5000_IO_PpiPortB:24), a
	ld c, a				; save port B value
	srl c, 6			; shift right 6 for port C
	ld (HDAE5000_IO_PpiPortC:24), c
	set 7, a			; set bit 7 (handshake high)
	srl a, 6			; shift right 6
	ld (HDAE5000_IO_PpiPortC:24), a
	ld xwa, 0x000003E8		; timeout counter (1000)
.Lppi_wait_low:
	bit 4, (HDAE5000_IO_PpiPortA:24)	; check ACK
	jr nz, .Lppi_wait_low		; wait until bit 4 clear
	; --- Reassemble and verify ---
	ld c, e				; C = low nibble
	ld a, (HDAE5000_IO_PpiPortA:24)	; read port A
	and a, 0x0f			; mask low nibble (high nibble of result)
	sll a, 4			; shift left 4 to high position
	or a, c				; combine with low nibble
	cp a, l				; compare with original byte
	jr nz, .Lppi_fail		; if mismatch, fail
	ld l, 0x00:opc			; success: L = 0
	ret
.Lppi_fail:
	ld l, 0xFF:opc			; failure: L = 0xFF
	ret

; ---------------------------------------------------------------------------
; "PPORT TEST" of the hardware-test page: HDAE5000_PPI_Init, then all 256 byte
; values through HDAE5000_PPI_LoopbackByte with the failures ORed together;
; prints HDAE5000_Str_PortTestOK when none failed, else
; HDAE5000_Str_PortTestError (HDAE5000_HardTest_Print).  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HardTest_PortTest:
	dec 2, xsp
	pushw iz
	ldw (xsp + 2), 0x0000
	calr HDAE5000_PPI_Init
	ld iz, 0:i3
	cp iz, 0x0100
	jr ge, .Lppi_rd_loop_end
.Lppi_rd_loop:
	ldto_berp a, 0xf8
	extz wa
	calr HDAE5000_PPI_LoopbackByte
	ld a, l
	exts wa
	or (xsp + 2), wa
	inc 1, iz
	cp iz, 0x0100
	jr lt, .Lppi_rd_loop
.Lppi_rd_loop_end:
	cpw (xsp + 2), 0x0000
	jr nz, .Lppi_rd_nonzero
	lda xwa, (HDAE5000_Str_PortTestOK:24)
	calr HDAE5000_HardTest_Print
	jr t, .Lppi_rd_done
.Lppi_rd_nonzero:
	lda xwa, (HDAE5000_Str_PortTestError:24)
	calr HDAE5000_HardTest_Print
.Lppi_rd_done:
	popw iz
	inc 2, xsp
	ret

; ---------------------------------------------------------------------------
; "HDD ID READ" of the hardware-test page: HDAE5000_HD_LoadTables,
; HDAE5000_HD_GetGeometry, then prints "HD-TYPE : <model>", "Fre Capa: %3.1f
; [MB]" (the free space / 100.0 as a float) and "=======> HDD OK" or "...
; HDD NG!" (HDAE5000_HardTest_Print).
; ---------------------------------------------------------------------------
HDAE5000_HardTest_HddIdRead:
	lda xsp, (xsp - 124)		; allocate stack frame
	ld wa, 0:i3
	call HDAE5000_HD_LoadTables
	cp hl, 0:i3
	jrl nz, .Lpws_error
	lda xwa, (xsp + 72)
	call HDAE5000_HD_GetGeometry
	; MemFill: clear 32-byte buffer
	pushw 0x0020			; count = 32
	pushw 0x0000			; fill value = 0
	lda xwa, (xsp + 28)
	push xwa			; buffer address
	call HDAE5000_MemFill
	; MemCopy_Block: copy 46 bytes from 0x2264 offset
	pushw	HDAE5000_Str_HDTYPE@hi16
	pushw	HDAE5000_Str_HDTYPE@lo16		; low half of HDAE5000_Str_HDTYPE
	lda xwa, (xsp + 36)
	push xwa			; dest address
	call HDAE5000_StrCpy
	; MemCopy: copy 10 bytes between buffers
	pushw 0x000A			; count = 10
	lda xwa, (xsp + 100)
	push xwa			; source
	lda xwa, (xsp + 56)
	push xwa			; dest
	call HDAE5000_MemCopy
	lda xsp, (xsp + 26)		; pop all args (26 bytes)
	; Transfer byte to PPI
	lda xwa, (xsp + 24)
	calr HDAE5000_HardTest_Print
	; Write sector data
	lda xwa, (xsp + 56)
	call HDAE5000_HD_GetDiskUsage
	; MemFill: clear buffer again
	pushw 0x0020			; count = 32
	pushw 0x0000			; fill value = 0
	lda xwa, (xsp + 28)
	push xwa			; buffer address
	call HDAE5000_MemFill
	; Compare and copy operations
	lda xbc, (xsp + 76)
	lda xwa, (xsp + 20)
	call HDAE5000_ULongToFloat
	lda xbc, (xsp + 20)
	lda xde, (HDAE5000_Float_100_HddIdRead:24); 0x2E1AB8
	lda xwa, (xsp + 20)
	call HDAE5000_FloatDiv
	lda xbc, (xsp + 20)
	lda xwa, (xsp + 24)
	call HDAE5000_FloatToDouble
	; Copy block via PPI
	lda xiy, (xsp + 24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy + 0)
	push xix
	pushw HDAE5000_Fmt_Fre_Capa_3_1f_MB@hi16			; count = 46 -- high half of HDAE5000_Fmt_Fre_Capa_3_1f_MB
	pushw	HDAE5000_Fmt_Fre_Capa_3_1f_MB@lo16		; low half of HDAE5000_Fmt_Fre_Capa_3_1f_MB
	lda xwa, (xsp + 44)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 24)		; pop args
	; Transfer results
	lda xwa, (xsp + 24)
	calr HDAE5000_HardTest_Print
	lda xwa, (HDAE5000_Str_Empty:24); 0x2E1A94
	calr HDAE5000_HardTest_Print
	lda xwa, (HDAE5000_Str_HDDOK:24); 0x2E1A96
	calr HDAE5000_HardTest_Print
	jr t, .Lpws_done
.Lpws_error:
	lda xwa, (HDAE5000_Str_HDDNG:24); 0x2E1AA6
	calr HDAE5000_HardTest_Print
.Lpws_done:
	lda xsp, (xsp + 124)		; deallocate stack frame
	ret

; ---------------------------------------------------------------------------
; Blank the floppy-list screen: the empty title and the "01:" .. "20:" row
; templates into HDAE5000_RAM_FdList, shown in objects 0x7F00DE / 0x7F00D7
; (EVT_HDAE_SET_STR_ADR, then EVT_PARA_DRAW), 0x7F00D9 / 0x7F00D8 hidden, and
; the present / selected flag arrays (FdList+0x100, +0x114) cleared.
; ---------------------------------------------------------------------------
HDAE5000_FdList_Clear:
	pushw 0x000E
	lda xwa, (HDAE5000_Str_Blank12Tab:24)
	push xwa
	lda xwa, (HDAE5000_RAM_FdList:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 10)
	; Register PPI device: first handler pair (0xDE)
	lda xwa, (HDAE5000_RAM_FdList:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL
	ld xbc, EVT_HDAE_SET_STR_ADR
	call (xhl)
	; Register second handler (0xDE, different params)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xFFFFFFFF
	call (xhl)
	; Copy 241 bytes: second table → PPI buffer
	pushw 0x00F1
	lda xwa, (HDAE5000_FdList_RowsTemplate:24)
	push xwa
	lda xwa, (HDAE5000_RAM_FdList+14:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 10)
	; Register PPI device: second handler pair (0xD7)
	lda xwa, (HDAE5000_RAM_FdList+14:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_LIST
	ld xbc, EVT_HDAE_SET_STR_ADR
	call (xhl)
	; Second handler (0xD7, different params)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_LIST
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xFFFFFFFF
	call (xhl)
	; Register third handler (0xD9)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_LINE1
	ld xbc, EVT_DRAW
	ld xde, 0:i3
	call (xhl)
	; Register fourth handler (0xD8)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_LINE2
	ld xbc, EVT_DRAW
	ld xde, 0:i3
	call (xhl)
	; Clear two 20-byte buffers
	pushw 0x0014
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_FdList+256:24)
	push xwa
	call HDAE5000_MemFill
	pushw 0x0014
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_FdList+276:24)
	push xwa
	call HDAE5000_MemFill
	lda xsp, (xsp + 16)
	ret

; ---------------------------------------------------------------------------
; The song number a floppy file name starts with: n = 1..20 when the name
; begins with n as two digits (HDAE5000_SPrintf "%2.2d", HDAE5000_StrNCmp over
; its length).
; In:  XWA = file name
; Out: HL = n - 1, or 0xFFFF.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_FdName_SongNumber:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld iz, 1:i3
	cp iz, 0x0014
	jr gt, .Lptb_not_found
.Lptb_loop:
	pushw iz
	pushw HDAE5000_Fmt_2_2d@hi16
	pushw	HDAE5000_Fmt_2_2d@lo16		; low half of HDAE5000_Fmt_2_2d
	lda xwa, (xsp + 8)
	push xwa
	call HDAE5000_SPrintf
	lda xwa, (xsp + 0x0c)
	push xwa
	call HDAE5000_StrLen
	pushw hl
	ld xwa, (xsp + 0x16)
	push xwa
	lda xwa, (xsp + 0x16)
	push xwa
	call HDAE5000_StrNCmp
	add xsp, 0x00000018
	cp hl, 0:i3
	jr nz, .Lptb_found
	ld hl, iz
	dec 1, hl
	jr t, .Lptb_done
.Lptb_found:
	inc 1, iz
	cp iz, 0x0014
	jr le, .Lptb_loop
.Lptb_not_found:
	ldw hl, 0xFFFF
.Lptb_done:
	popw iz
	inc 8, xsp
	ret

; --- HD Drive Setup and Configuration ---

; --- HD (IDE/ATA) Driver ---
	.include "hdae5000_hd_driver.s"

; --- FAT16 Filesystem ---
	.include "hdae5000_filesystem.s"

; --- Menu UI & Display ---
	.include "hdae5000_ui_display.s"

; --- Utility & Math Functions ---
	.include "hdae5000_utilities.s"

; --- Data Tables, Config, Graphics & Strings ---
	.include "hdae5000_data_tables.s"

