#!/usr/bin/env python3
r"""hdae5000_symbolize_ram.py -- named RAM variables for the HD-AE5000 code.

QUESTION ANSWERED / JOB IT DOES
-------------------------------
The code addresses its RAM (0x200000-0x23FFFF, the expansion's SRAM) by
number: `ld xwa,(0x23a1a2)` 957 times, `cp (0x200222:24),0` after every disk
operation, `(0x23a092:24)` for the selected directory.  This tool gives a
curated set of those addresses a name -- only variables whose role the code
shows, each with the evidence in its `.equ` comment -- and rewrites every
operand that is exactly that address (`(N)`, `(N:24)`, `N` immediates, hex or
decimal).  The values are unchanged, so the encodings are too.  For the arrays
and records listed in EXTENT, an operand inside one becomes NAME+offset.

The `.equ` block is written right after the `.include "shared/event_codes.s"`
line of hd-ae5000_v2_06i.s, before any code, so every use is a backward
reference.

RUN
    python3 scripts/converters/hdae5000_symbolize_ram.py [--apply]
--apply re-links through scripts/analysis/hdae5000_line_map.py (refuses unless
the tree is byte-identical).
"""
import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "analysis"))
import hdae5000_line_map as hlm  # noqa: E402

# address: (name, evidence)
RAM = {
    0x23A1A2: ("MainWorkspacePtr", "the main CPU's workspace; every call into it is (this)->0x0E88 or"
                                   " ->0x0E0A table + offset (init image: 4 bytes after HDAE5000_LyricBoxObj_Init;"
                                   " the object table at 0x027ED2)"),
    0x200222: ("AtaError", "drive error byte: 0 = ok; set by the HDAE5000_ATA_* routines, tested"
                           " after every disk operation"),
    0x229D92: ("HdInitResult", "HDAE5000_HD_Init's step code, returned by HDAE5000_Check_HD_Present"),
    0x229D98: ("HdSignatureOk", "1 when sector 1 carries AA55AA55 F4F1F2F3 (HDAE5000_HD_CheckSignature)"),
    0x229C58: ("ClusterBytes", "cluster size in bytes (HDAE5000_HD_ParseIdentify)"),
    0x229C5C: ("SectorsPerCluster", "0x20, or 0x40 on drives of >= 0x14DC93 sectors (HD_ParseIdentify)"),
    0x229C64: ("TablesStartSector", "first of the 323 filesystem-table sectors, 3908 (HD_ParseIdentify)"),
    0x229C68: ("FatStartSector", "2 (HD_ParseIdentify)"),
    0x229C6C: ("DataStartSector", "4231, cluster 1's first sector (HD_ParseIdentify)"),
    0x229C70: ("FatEntryCount", "FAT entries, whole 128-entry sectors (HD_ParseIdentify)"),
    0x229C80: ("FreeClusters", "free-cluster count (HDAE5000_HD_CountFreeClusters, WriteFile, FreeChain)"),
    0x229C94: ("DataSectorCount", "sectors from DataStartSector to the end (HD_ParseIdentify)"),
    0x229D99: ("WriteProtect", "\"WRITE PROTECTION\" of HDAE5000_TitleInfo_Template, 0/1 = OFF/ON"),
    0x229D9A: ("WriteConfirm", "\"WRITE CONFIRM\" of HDAE5000_TitleInfo_Template, 0/1 = OFF/ON"),
    0x229DA9: ("QuickLoadMode", "\"QUICK LOAD MODE\" (TitleInfo); one of the six setting bytes of sector 1"),
    0x229DAA: ("LoadByNumberMode", "\"LOAD BY NUMBER MODE\" (TitleInfo); sector-1 setting byte"),
    0x229DAB: ("JumpAfterLoad", "\"JUMP AFTER LOAD\" (TitleInfo); sector-1 setting byte"),
    0x201632: ("DirNames", "directory names, 16 B x 120 (HDAE5000_HD_GetBlockInfo block 0)"),
    0x201DB2: ("SongRecords", "song records, 76 B x 1920 (HDAE5000_HD_GetBlockInfo block 1)"),
    0x2257B2: ("FlsRecords", "FLS records, 144 B x 120 (HDAE5000_HD_GetBlockInfo block 2)"),
    0x23A08E: ("DirPageBase", "first directory of the list page (HDAE5000_DirList_BuildPage)"),
    0x23A090: ("FlsPageBase", "first FLS of the list page (HDAE5000_FlsList_BuildPage)"),
    0x23A092: ("CurDir", "selected directory (HDAE5000_SongScreen_Refresh, Song_PartMask callers)"),
    0x23A094: ("CurSong", "selected song within CurDir (HDAE5000_SongScreen_Refresh)"),
    0x23A096: ("CurFls", "selected FLS (HDAE5000_FlsScreen_Refresh)"),
    0x22AA4C: ("SaveOptions", "12-byte part-selection record of the save options: u16 mask, then"
                              " flags 0x22AA4E+k (HDAE5000_TypeSel_*)"),
    0x22ABE6: ("DeleteOptions", "12-byte part-selection record of the delete options (HDAE5000_DelOpt_*)"),
    0x22AA5C: ("LbnDigitPos", "load-by-number digit position 0..5 (HDAE5000_Lbn_TypeDigit)"),
    0x22AA5E: ("LbnDir", "load-by-number directory number being typed (HDAE5000_Lbn_TypeDigit)"),
    0x22AA60: ("LbnSong", "load-by-number song number being typed (HDAE5000_Lbn_TypeDigit)"),
    0x22B2F4: ("SeparateOutputMode", "0..3 = OFF / DRUMS L/R / BASS+DRUMS MIX / BASS/DRUMS MONO"
                                     " (HDAE5000_SeparateOutput_Apply)"),
    0x23A0A0: ("SeparateDrumPart", "drum part, 0 = NONE (SeparateDrumPartCheck's value; _Apply)"),
    0x23A09E: ("SeparateBassPart", "bass part, 0 = NONE (SeparateBassPartCheck's value; _Apply)"),
    0x23A0A2: ("SeparateDrumPartSent", "drum part last sent by HDAE5000_SeparateOutput_Apply"),
    0x23A0A4: ("SeparateBassPartSent", "bass part last sent by HDAE5000_SeparateOutput_Apply"),
    0x230F1C: ("HdStreamBuffer", "0x8000-byte buffer of the streamed file writes/reads"
                                 " (HDAE5000_HD_WriteStream, the part loaders/savers)"),
    0x238F1C: ("HdStreamBufferEnd", "end of HdStreamBuffer (HDAE5000_HD_WriteStream)"),
    0x238F24: ("HdStreamFill", "fill pointer into HdStreamBuffer (HDAE5000_HD_WriteOpen/_WriteStream)"),
    0x238F28: ("HdStreamSlot", "the first-cluster slot of the open buffered write (HD_WriteOpen)"),
    0x238F2C: ("HdStreamState", "0 closed, 1 open and nothing written, 2 written (HD_WriteOpen)"),
    0x239168: ("PportPacket", "the 256-byte PC-link packet (HDAE5000_PPORT_SendPacket/RecvPacket)"),
    0x2390D4: ("PportError", "PC-link error flag, set to 1 by PPORT_RecvByte/SendByte/EndBlock"),
    0x2390FC: ("PportChecksum", "32-bit running sum of the PC-link block in transfer"),
    # second run (lyrics player; the three setting names are the firmware's
    # own handler names in HDAE5000_ObjHandler_Table, each returning the
    # address of its byte)
    0x229DAC: ("LyricJump", "sector-1 setting byte; handler \"LyricJumpEditCheck\" returns its address"),
    0x229DAD: ("LyricForeColor", "sector-1 setting byte 0..4; \"LyricForeColorCheck\"; palette code"
                                 " via HDAE5000_Lyrics_ResetState"),
    0x229DAE: ("LyricBackColor", "sector-1 setting byte 0..4; \"LyricBackColorCheck\"; palette code"
                                 " via HDAE5000_Lyrics_ResetState"),
    0x22B430: ("LyricBuffer", "the lyric file, 0x5000 bytes: TLhd/TLtr chunks, events from +22"
                              " (HDAE5000_Lyrics_ClearBuffer, _ParseEvent)"),
    0x23A0AA: ("LyricLines", "six 40-byte text lines of the lyric window (HDAE5000_Lyrics_FillLines)"),
    0x23A19C: ("LyricLoaded", "1 once a lyric file passed its checks (HDAE5000_Lyrics_CheckFile)"),
    # third run: the frame handler's view of the main CPU's sequencer
    0x230ECC: ("SqSrtcPtr", "address of the main CPU's sqsrtc byte (HamaFn_GetAdr_sqsrtc = 0x0421,"
                            " HDAE5000_Boot_Init); HDAE5000_Frame_Handler watches its bit 2"),
    0x230ED2: ("SqBtofPtr", "address of the main CPU's sqbtof word (HamaFn_GetAdr_sqbtof = 0x041C,"
                            " HDAE5000_Boot_Init)"),
    0x230ED6: ("SqBeadtPtr", "address of the main CPU's sq_beadt byte (HamaFn_GetAdr_sq_beadt = 0x041B,"
                             " HDAE5000_Boot_Init)"),
    0x230ED0: ("SqSrtcBit2Prev", "bit 2 of sqsrtc at the previous frame (HDAE5000_Frame_Handler_Status)"),
    0x230EDA: ("HdPresent", "HDAE5000_Check_HD_Present's result (HDAE5000_Boot_Init; HDAE5000_Get_Init_Flag)"),
    0x230EC2: ("LyricPosEvt", "parameter block of event 0x01CA0004 to the lyric box: +0 sqbtof word,"
                              " +2 LyricPosStep, +4 LyricPosition (HDAE5000_Frame_Handler)"),
    0x230EC4: ("LyricPosStep", "(sq_beadt >> 3) + 1 at the last post; a change triggers the next one"),
    0x230EC6: ("LyricPosition", "sqbtof * 12 + (sq_beadt >> 3) + 2: the position"
                                " HDAE5000_Lyrics_PlayToPosition scales by division / 12"),
    # fourth run: the floppy lyric list (HDAE5000_FdLyricList_Scan)
    0x230884: ("FdLyricNames", "40 x 9-byte base names of the *.TLX files on the floppy, sorted"
                               " (HDAE5000_FdLyricList_AddTlx)"),
    0x230E72: ("FdLyricCount", "entries in FdLyricNames, at most 40 (HDAE5000_FdLyricList_AddTlx)"),
    0x2309F6: ("FdLyricTitles", "40 x 27 bytes: the first 26 bytes of each <name>.TTX"
                                " (HDAE5000_FdLyricList_Scan)"),
    0x230E4A: ("FdLyricHasMid", "40 flags: <name>.MID opens (HDAE5000_FdLyricList_Scan)"),
    0x230E7A: ("FdVolumeLabel", "the floppy's volume label (HamaFn_GetVolumeLabel) + \" ->\""
                                " (HDAE5000_FdLyricList_Scan)"),
    0x23A19E: ("LyricBoxObj", "the open lyric box's object id, 0xFFFFFFFF when closed"
                              " (HDAE5000_LyricBoxProc); redraw events go to it"),
    # fifth run (2026-10-24): the PC-link coroutine's mailbox (layout block above
    # HDAE5000_PPORT_ServicePending) and the printf engine's state
    0x239000: ("PportLinkActive", "1 while the PC-link context exists (HDAE5000_PPORT_StartLink sets it;"
                                  " _ReturnToLink / _Reset clear it); HDAE5000_PPORT_ServicePending tests it"),
    0x239002: ("PportLinkSp", "the PC-link context's saved XSP (HDAE5000_PPORT_YieldToMain stores,"
                              " HDAE5000_PPORT_SwitchToLink loads)"),
    0x239006: ("PportMainSp", "the main context's saved XSP (HDAE5000_PPORT_SwitchToLink stores,"
                              " HDAE5000_PPORT_YieldToMain loads)"),
    0x23900A: ("PportService", "word: service number posted by HDAE5000_PPORT_CallService (its WA); the"
                               " service's HL result after HDAE5000_PPORT_ServiceDispatch; 0xFFFF once the"
                               " link has ended"),
    0x23900C: ("PportServiceArgBc", "XBC argument of the posted service (HDAE5000_PPORT_CallService)"),
    0x239010: ("PportServiceArgDe", "XDE argument of the posted service (HDAE5000_PPORT_CallService)"),
    0x239014: ("PportServiceRequested", "1 while a posted service waits: HDAE5000_PPORT_CallService sets it"
                                        " before yielding and clears it on return; a yield with it clear"
                                        " means the link program ended"),
    0x23FFFC: ("PportLinkStackTop", "top of the PC-link context's stack; HDAE5000_PPORT_StartLink plants"
                                    " HDAE5000_PPORT_LinkEntry there as its first return address"),
    0x239482: ("SPrintfCursor", "output pointer of HDAE5000_SPrintf / _VSPrintf; HDAE5000_SPrintf_PutChar"
                                " stores a byte there, advances it and keeps the string terminated"),
    0x239486: ("PrintfPadChar", "word: the padding character of the conversion in progress, 32 (' ') or"
                                " 48 ('0' after a 0 flag) (HDAE5000_DoPrintf; HDAE5000_FormatFloat pads with it)"),
    0x239488: ("PrintfFloatCount", "word: characters HDAE5000_FormatFloat has emitted; cleared at its start,"
                                   " added to HDAE5000_DoPrintf's count after it"),
    0x23948A: ("FltDecDigits", "32-byte decimal digit string of HDAE5000_FltDec_Convert / _AddDigit"),
    0x2394AA: ("FltDecMantissa", "the binary mantissa as byte-wide u16 limbs (HDAE5000_FltDec_Convert)"),
    0x2394EA: ("FltDecFraction", "10-limb fraction work area (HDAE5000_FltDec_FractionDigits / _FracMulBy10)"),
    # seventh run: the HD file-system driver's working variables (HDAE5000_HD_WriteFile / _AppendFile /
    # _ReadFile / _ReadFileNext and the cluster and FAT routines they call)
    0x229D40: ("HdXferPtr", "buffer pointer of the file transfer in progress (XWA of HD_WriteFile / _AppendFile /"
                            " _ReadFile / _ReadFileNext); HD_WriteCluster / _ReadClusterFrom advance it 512"
                            " per sector"),
    0x229D38: ("HdXferBytes", "byte count of the transfer (XBC); HD_ReadClusterFrom counts it down"),
    0x229D2C: ("HdXferSlotPtr", "pointer to the file's first-cluster slot (XDE of the four transfer routines)"),
    0x229C98: ("HdXferClusters", "clusters a write needs: ceil(HdXferBytes / ClusterBytes)"),
    0x229CA4: ("HdXferClustersDone", "clusters written so far (HD_WriteFile / _AppendFile)"),
    0x229D94: ("HdXferLinkFromPrev", "0 for a write's first new cluster, then 1: from the second on, each"
                                     " cluster is linked from HdFatSetCluster (HD_WriteFile / _AppendFile)"),
    0x229D95: ("HdXferSlotSet", "1 once HD_WriteFile has stored the first cluster in *HdXferSlotPtr"),
    0x229DBC: ("HdDiskFull", "1 when HD_FindFreeCluster found no free cluster during a write"),
    0x229C9C: ("HdFatSetCluster", "the cluster whose FAT entry HD_FatSetEntry writes: the chain's last cluster"),
    0x229CA0: ("HdFatSetValue", "the value HD_FatSetEntry stores: the next cluster, 0xFFFFFFFE (end of chain)"
                                " or 0xFFFFFFFF (after a failed cluster write)"),
    0x229CA8: ("HdFreeCluster", "HD_FindFreeCluster's result, 1-based, 0xFFFFFFFD = none; the cluster"
                                " HD_WriteCluster writes"),
    0x229CAC: ("HdFreeScanOffset", "byte offset of HD_FindFreeCluster's scan in HdFreeScanBuffer; 512 = load"
                                   " the next FAT sector"),
    0x229CB0: ("HdFreeScanFatSector", "FAT sector index of HD_FindFreeCluster's scan"),
    0x229CB4: ("HdFreeScanDiskSector", "disk sector of HdFreeScanFatSector (FatStartSector + index)"),
    0x229D96: ("HdFreeScanStarted", "0 until HD_FindFreeCluster loaded its first FAT sector, then 1 (the step"
                                    " it adds to HdFreeScanFatSector / _DiskSector)"),
    0x200898: ("HdFreeScanBuffer", "512-byte FAT sector buffer of HD_FindFreeCluster"),
    0x229CBC: ("HdWriteClusterPtr0", "HdXferPtr at HD_WriteCluster's entry, put back when a sector write fails"),
    0x229CC0: ("HdWriteClusterSector", "sector index within the cluster HD_WriteCluster is writing"),
    0x229D97: ("HdWriteClusterError", "1 when a sector write of HD_WriteCluster failed"),
    0x229D28: ("HdFatCacheSector", "index of the FAT sector held in HdFatCache, 0xFFFFFFFF = none"),
    0x200A98: ("HdFatCache", "512-byte cache of one FAT sector (HD_FatSetEntry / _FatNextCluster / _FreeChain)"),
    0x229D48: ("HdFatSector", "FAT sector index of the entry HD_FatSetEntry / _FatNextCluster address:"
                              " (cluster - 1) / 128"),
    0x229D4C: ("HdFatEntryOffset", "byte offset of that entry in its sector: ((cluster - 1) % 128) * 4"),
    0x229D30: ("HdChainCluster", "current cluster of the chain being read (HD_ReadFile / _ReadFileNext) or"
                                 " released (HD_FreeChain_Worker)"),
    0x229D34: ("HdChainSector", "sector within HdChainCluster where reading continues (HD_ReadClusterFrom)"),
    0x229D3C: ("HdSectorBytes", "bytes HD_ReadClusterFrom reads from the current sector: 512, or the rest"
                                " of HdXferBytes in the last one"),
    0x229DBE: ("HdReadClusterError", "1 when a sector read of HD_ReadClusterFrom failed"),
    0x229DBF: ("HdReadLastSector", "1 when HdXferBytes ran out inside the sector just read"),
    0x229CB8: ("HdFreeChainStart", "first cluster of the chain HD_FreeChain_Worker releases"),
    0x229D24: ("HdFreeChainCount", "clusters HD_FreeChain_Worker has released, added to FreeClusters"),
    # eighth run: the ATA layer (HDAE5000_ATA_* and HDAE5000_HD_ParseIdentify)
    0x200000: ("AtaIdentifyBuffer", "the 512-byte IDENTIFY DEVICE answer (HDAE5000_ATA_IdentifyDevice);"
                                    " HDAE5000_HD_ParseIdentify reads words 27-46 and 54-58"),
    0x200200: ("HdSectorsPerHead", "cylinders x sectors per track: the head stride of the CHS split in"
                                   " HDAE5000_ATA_ReadSector / _WriteSector (HD_ParseIdentify)"),
    0x200204: ("AtaWriteSectorNo", "1-based sector number of HDAE5000_ATA_WriteSector (its XHL)"),
    0x200208: ("AtaWriteData", "data pointer of HDAE5000_ATA_WriteSector (its XIX)"),
    0x20020C: ("AtaReadSectorNo", "1-based sector number of HDAE5000_ATA_ReadSector (its XHL)"),
    0x200210: ("AtaReadData", "buffer pointer of HDAE5000_ATA_ReadSector (its XIX)"),
    0x200214: ("AtaReadKeepBytes", "bytes of the sector HDAE5000_ATA_ReadSector stores (its XDE)"),
    0x200218: ("AtaWriteHeadBase", "head * HdSectorsPerHead in HDAE5000_ATA_WriteSector's CHS split"),
    0x20021C: ("AtaReadHeadBase", "head * HdSectorsPerHead in HDAE5000_ATA_ReadSector's CHS split"),
    0x200220: ("HdSectorsPerTrack", "word: IDENTIFY word 56, current sectors per track (HD_ParseIdentify)"),
    0x200223: ("HdUsableSectors", "long at an odd address: IDENTIFY words 57-58 (current capacity) - 2"
                                  " (HD_ParseIdentify)"),
    0x229C32: ("HdCylinders", "word: IDENTIFY word 54, current cylinders (HD_ParseIdentify)"),
    0x229C34: ("HdHeads", "word: IDENTIFY word 55, current heads (HD_ParseIdentify)"),
    0x20083C: ("HdModelString", "40 bytes: IDENTIFY words 27-46 (model number), byte-swapped"
                                " (HD_ParseIdentify; HDAE5000_HD_GetGeometry copies it out)"),
    0x200628: ("HdSettingsSector", "512-byte image of disk sector 1: AA55AA55 F4F1F2F3 signature"
                                   " (HDAE5000_HD_CheckSignature) and the settings (HDAE5000_HD_SaveSettings)"),
    # ninth run: table, format and usage bookkeeping of the HD driver
    0x200228: ("HdSectorBuffer", "512-byte sector buffer: read-back of HD_WriteTables / _ReadTables, the FAT"
                                 " sectors HD_CountFreeClusters scans, HD_Format's zero sector"),
    0x200428: ("HdVerifyBuffer", "512-byte read-back buffer of HD_Format's verify pass"),
    0x229C60: ("HdVersionKeyWord", "0x0000FFEE after HD_ResetVersionKeyWord; HD_CheckVersionKey compares it"
                                   " with HDAE5000_Version_Key"),
    0x229C74: ("HdTablesSector", "disk sector of HD_WriteTables / _ReadTables' current table sector"),
    0x229C78: ("HdTablesPtr", "RAM pointer of that sector within the tables (from DirNames on)"),
    0x229C7C: ("HdTablesCount", "table sectors transferred so far, of 323"),
    0x229C84: ("HdCountSector", "FAT sector HD_CountFreeClusters is scanning"),
    0x229C88: ("HdCountEntries", "FAT entries HD_CountFreeClusters has scanned"),
    0x229C8C: ("HdFormatSector", "disk sector HD_Format_Worker is clearing or verifying"),
    0x229C90: ("HdFormatCount", "sectors done in that pass, of 3906"),
    0x229D93: ("HdRetries", "retries left: 7 for HD_WriteTables / _ReadTables, 5 for HD_CountFreeClusters"),
    0x229D10: ("HdUsageData", "data area in units of 10,000 bytes (HD_ComputeDiskUsage)"),
    0x229D14: ("HdUsageFree", "free space in units of 10,000 bytes (HD_ComputeDiskUsage)"),
    0x229D18: ("HdUsageDrive", "the drive in units of 10,000 bytes (HD_ComputeDiskUsage)"),
    0x229D1C: ("HdUsageSystem", "the system area (sectors before the data area) in units of 10,000 bytes"),
    0x229DAF: ("HdStatusBytes", "ten bytes HD_ClearStatusBytes zeroes; no reader found"),
    # tenth run: the PC-link services' shared block (its address is what service 1, GetInfoBlockPointer,
    # hands to the PC; the trace strings of services 3-6, 13 and 19 name its fields)
    0x238F2E: ("PportInfoBlock", "the PC-link info block, 0xD2 bytes: +0 part mask, +2 song name (26),"
                                 " +0x1C directory name (16), +0x2C/+0x34/+0x3C the FGB/FEB/FLS block"
                                 " descriptors (HDAE5000_HD_GetBlockInfo), +0x46 nine-byte part records"
                                 " (service 13), +0x97 drive model (30), +0xB5.. geometry (service 3),"
                                 " +0xCA work buffer address (service 19), +0xCE the slot of the open read"),
    0x23A1A6: ("PportReadState", "0 no read open, 1 opened by service 24 (ReadOpenHD), 2 reading (service"
                                 " 25 continues with HD_ReadFileNext)"),
    0x2390D6: ("PportArg1", "byte 1 of the command packet, latched by HDAE5000_PPORT_LatchPacketArgs"
                            " (stored in a word slot, as are Arg2..4)"),
    0x2390D8: ("PportArg2", "byte 2 of the command packet (HDAE5000_PPORT_LatchPacketArgs)"),
    0x2390DA: ("PportArg3", "byte 3 of the command packet (HDAE5000_PPORT_LatchPacketArgs)"),
    0x2390DC: ("PportArg4", "byte 4 of the command packet (HDAE5000_PPORT_LatchPacketArgs)"),
    0x239100: ("PportInfoPtr", "XIX of service 1 (the address of PportInfoBlock), kept by"
                               " HDAE5000_PPORT_GetInfoBlock / _CopyInfoToPacket"),
    0x239158: ("PportBlockPtr", "start of the block HDAE5000_PPORT_SendBlock / _RecvBlock moves; a retry"
                                " restarts from it"),
    0x23915C: ("PportBlockLen", "byte count of that block"),
    0x239268: ("PportSectorBuffer", "512 bytes: a sector received by HDAE5000_PPORT_RecvSector, or read for"
                                    " HDAE5000_PPORT_InitRegionDescriptors_Lookup"),
    0x2390E2: ("PportPartMask", "the parts (bits 0-7) a link command works on; InitRegionDescriptors"
                                " sizes one region per set bit"),
    0x2390E4: ("PportPartMaskHi", "bit 0: the ninth part (TLX), with PportPartMask"),
    0x2390E6: ("PportStepError", "1 when a service call of InitRegionDescriptors_Lookup / SendRegionToPc"
                                 " (or a command handler) failed"),
    0x2390EC: ("PportSizeFieldOffset", "byte offset of the size field in a part file's first sector"
                                       " (InitRegionDescriptors -> _Lookup)"),
    0x2390EE: ("PportSizeFieldWidth", "0x20: that field is a long; 0x10: a word counting 16-byte units"),
    0x2390F0: ("PportSendMaskLo", "low byte of the part mask SendRegionToPc puts in PportInfoBlock+0 before"
                                  " opening the read (service 24)"),
    0x2390F2: ("PportSendMaskHi", "its high byte"),
    0x2390F8: ("PportSectorOffset", "word: byte offset into PportSectorBuffer while SendRegionToPc sends it;"
                                    " 512 = read the next sector"),
    0x239164: ("PportBytesLeft", "bytes SendRegionToPc still has to send"),
    0x239108: ("PportRegions", "(address, size) long pairs: SendTwoRegions sends pairs 0 and 1;"
                               " InitRegionDescriptors stores part sizes in the slots"),
    0x22ABC4: ("PcLinkStatusText", "the text of the PC-link page's PP_STATUS object; the status string goes"
                                   " in at +7, at most 25 characters (HDAE5000_PcLink_ShowStatus, service 26)"),
    # sixth run: list texts the UI objects display (EVT_HDAE_SET_STR_ADR points them here)
    0x22B274: ("PartListText", "nine 14-byte tab-ended part names + NUL (0x7F bytes), HDAE5000_PartList_Build"),
    0x22A0D0: ("DirListText", "24 rows x 21 bytes + NUL: \"NNN:\" and the 16-byte directory name at +4"
                              " (HDAE5000_DirList_BuildPage)"),
}
# arrays and records whose interior the code addresses directly: an operand inside one is written
# NAME+offset (decimal), e.g. the fourth 14-byte field of PartListText is HDAE5000_RAM_PartListText+42
EXTENT = {
    0x22B274: 0x7F,
    0x22A0D0: 0x1F9,
    0x200000: 0x200,
    0x200628: 0x200,
    0x229DAF: 10,
    0x238F2E: 0xD2,
    0x239268: 0x200,
    0x239108: 0x50,
    0x22ABC4: 0x21,
}
# I/O registers (full names; same rewriting): the 8255 of the PC link and the drive's ATA task file.  The
# ATA registers are the standard eight at 0x130010 + 2 * index: the code writes the ATA command opcodes
# 0x94 STANDBY IMMEDIATE, 0xEC IDENTIFY DEVICE, 0x20 READ SECTORS and 0x30 WRITE SECTORS to index 7 and
# polls BSY / DRDY / DRQ (0x80 / 0x40 / 0x08) there, and moves sector data through index 0 as words.
IO = {
    0x160000: ("HDAE5000_IO_PpiPortA", "8255 port A: the PC-link data byte (HDAE5000_PPORT_SendByte writes,"
                                       " _RecvByte reads; HDAE5000_PPI_LoopbackByte reads it back)"),
    0x160002: ("HDAE5000_IO_PpiPortB", "8255 port B: PC-link strobe in bit 3 (HDAE5000_PPORT_SendByte)"),
    0x160004: ("HDAE5000_IO_PpiPortC", "8255 port C: PC-link handshake inputs, bit 0 ready, bit 1 ack, bit 2"
                                       " link present (HDAE5000_PPORT_SendByte)"),
    0x160006: ("HDAE5000_IO_PpiControl", "8255 control word: 0x90 = mode 0, port A input (HDAE5000_PPI_Init);"
                                         " 0x89 = port A output, port C low nibble input"
                                         " (HDAE5000_PPORT_InitPort / _CommandLoop)"),
    0x130010: ("HDAE5000_IO_AtaData", "ATA data register (16-bit sector data, HDAE5000_ATA_ReadSector /"
                                      " _WriteSector / _Identify)"),
    0x130012: ("HDAE5000_IO_AtaFeatures", "ATA features / error register; 0xFF before STANDBY IMMEDIATE and"
                                          " IDENTIFY DEVICE"),
    0x130014: ("HDAE5000_IO_AtaSectorCount", "ATA sector count; 1 for every read and write"),
    0x130016: ("HDAE5000_IO_AtaSectorNumber", "ATA sector number (CHS) of HDAE5000_ATA_ReadSector / _WriteSector"),
    0x130018: ("HDAE5000_IO_AtaCylinderLow", "ATA cylinder, low byte"),
    0x13001A: ("HDAE5000_IO_AtaCylinderHigh", "ATA cylinder, high byte"),
    0x13001C: ("HDAE5000_IO_AtaDriveHead", "ATA drive/head; 0xA0 = master + head 0"),
    0x13001E: ("HDAE5000_IO_AtaStatusCommand", "ATA status (read) / command (write)"),
    0x130020: ("HDAE5000_IO_AtaDeviceControl", "ATA device control: 0x0E (SRST + nIEN) then 0x0A (nIEN)"
                                               " is HDAE5000_ATA_SoftReset"),
}
FILE_MAIN = "hd-ae5000_v2_06i.s"
NUM = re.compile(r"(?<![\w.$+\-])(0x[0-9a-fA-F]+|\d{6,})(?![\w.$])")


def main(apply):
    src = {rel: open(os.path.join(hlm.HDAE, rel), encoding="latin-1").read().split("\n") for rel in hlm.FILES}
    sym = {a: "HDAE5000_RAM_" + n for a, (n, ev) in RAM.items()}
    sym.update({a: n for a, (n, ev) in IO.items()})
    evidence = {a: ev for a, (n, ev) in list(RAM.items()) + list(IO.items())}
    counts = collections.Counter()
    for rel in ("hd-ae5000_v2_06i.s", "hdae5000_hd_driver.s", "hdae5000_filesystem.s",
                "hdae5000_ui_display.s", "hdae5000_utilities.s"):
        L = src[rel]
        for i, ln in enumerate(L):
            code, sep, com = ln.partition(";")
            s = code.strip()
            if not s or s.startswith(".") or s.endswith(":"):
                continue
            if re.match(r"^[.\w$]+:\s*$", s):
                continue
            mn = s.split()[0].lower() if not re.match(r"^[.\w$]+:", s) else s.split(":", 1)[1].split()[0].lower() if s.split(":", 1)[1].split() else ""
            if mn.startswith("."):
                continue

            def sub(m):
                v = int(m.group(1), 16) if m.group(1).lower().startswith("0x") else int(m.group(1))
                if v in sym:
                    counts[sym[v]] += 1
                    return sym[v]
                for base, size in EXTENT.items():
                    if base < v < base + size:
                        counts["%s+N" % sym[base]] += 1
                        return "%s+%d" % (sym[base], v - base)
                return m.group(0)
            new = NUM.sub(sub, code)
            if new != code:
                L[i] = new + sep + com
    print("RAM names %d; operands replaced %d" % (len(sym), sum(counts.values())))
    for k, v in counts.most_common():
        print("  %5d %s" % (v, k))
    if not apply:
        return
    L = src[FILE_MAIN]
    have = [i for i, ln in enumerate(L) if ln.startswith(("\t.equ HDAE5000_RAM_", "\t.equ HDAE5000_IO_"))]
    if have:
        # a block from an earlier run exists: add only the missing names, in
        # address order, after its last line (re-running is idempotent)
        present = {re.match(r"\t\.equ (\w+),", L[i]).group(1) for i in have}
        new = ["\t.equ %s, 0x%06x\t; %s" % (sym[a], a, evidence[a]) for a in sorted(evidence)
               if sym[a] not in present]
        L[have[-1] + 1:have[-1] + 1] = new
        print("added %d .equ lines to the existing block" % len(new))
        for rel, L2 in src.items():
            open(os.path.join(hlm.HDAE, rel), "w", encoding="latin-1").write("\n".join(L2))
        hlm.build_map()
        print("applied; relinked mirror byte-identical")
        return
    at = next(i for i, ln in enumerate(L) if ln.strip().startswith('.include "shared/event_codes.s"'))
    block = ["",
             "; ----------------------------------------------------------------------------",
             "; RAM variables (the expansion's SRAM 0x200000-0x23FFFF) whose role the code",
             "; shows; each comment names the evidence.  Operands equal to one of these",
             "; addresses were rewritten by scripts/converters/hdae5000_symbolize_ram.py.",
             "; ----------------------------------------------------------------------------"]
    for a in sorted(RAM):
        n, ev = RAM[a]
        block.append("\t.equ %s, 0x%06x\t; %s" % (sym[a], a, ev))
    L[at + 1:at + 1] = block
    for rel, L in src.items():
        open(os.path.join(hlm.HDAE, rel), "w", encoding="latin-1").write("\n".join(L))
    hlm.build_map()
    print("applied; relinked mirror byte-identical")


if __name__ == "__main__":
    main("--apply" in sys.argv[1:])
