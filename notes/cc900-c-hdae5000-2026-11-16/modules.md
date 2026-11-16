## Modules inferred from calr / call (591 calr pairs, 750 near absolute calls)

45 boundaries, so 46 modules; 0 near calls cannot be separated (listed below).

| from   | to     | first routine                               | routines | hand source           |
|--------|--------|---------------------------------------------|----------|-----------------------|
| 280008 | 28f543 | HDAE5000_ENTRY_1                            | 599      | hd-ae5000_v2_06i.s    |
| 28f543 | 28f90b | HDAE5000_Alloc_Memory                       | 7        | hdae5000_ui_display.s |
| 28f90b | 294414 | HDAE5000_Finalize_Init                      | 84       | hdae5000_ui_display.s |
| 294414 | 29506a | HDAE5000_DebugTrace                         | 30       | hdae5000_ui_display.s |
| 29506a | 2952f8 | HDAE5000_PPORT_StartLink                    | 7        | hdae5000_ui_display.s |
| 2952f8 | 2967b4 | HDAE5000_PPORT_Execute                      | 22       | hdae5000_ui_display.s |
| 2967b4 | 296900 | HDAE5000_PPORT_LatchPacketArgs              | 5        | hdae5000_ui_display.s |
| 296900 | 296af8 | HDAE5000_PPORT_RecvByte                     | 6        | hdae5000_ui_display.s |
| 296af8 | 296fc6 | HDAE5000_PPORT_SendBlock                    | 6        | hdae5000_ui_display.s |
| 296fc6 | 2971b7 | HDAE5000_PPORT_InitRegionDescriptors_Lookup | 3        | hdae5000_ui_display.s |
| 2971b7 | 29747a | HDAE5000_HD_Init                            | 3        | hdae5000_ui_display.s |
| 29747a | 2974c7 | HDAE5000_ATA_SoftReset                      | 2        | hdae5000_ui_display.s |
| 2974c7 | 2975ad | HDAE5000_ATA_Standby                        | 3        | hdae5000_ui_display.s |
| 2975ad | 29769b | HDAE5000_HD_ParseIdentify                   | 1        | hdae5000_ui_display.s |
| 29769b | 29797f | HDAE5000_ATA_WriteSector                    | 5        | hdae5000_ui_display.s |
| 29797f | 297a8d | HDAE5000_HD_InitTables                      | 2        | hdae5000_ui_display.s |
| 297a8d | 297be9 | HDAE5000_HD_WriteTables                     | 2        | hdae5000_ui_display.s |
| 297be9 | 297d49 | HDAE5000_HD_ReadTables                      | 2        | hdae5000_ui_display.s |
| 297d49 | 298005 | HDAE5000_HD_CountFreeClusters               | 3        | hdae5000_ui_display.s |
| 298005 | 298150 | HDAE5000_HD_AppendFile_Worker               | 2        | hdae5000_ui_display.s |
| 298150 | 2981f4 | HDAE5000_HD_ReadFile_Worker                 | 2        | hdae5000_ui_display.s |
| 2981f4 | 29842a | HDAE5000_HD_ReadFileNext_Worker             | 4        | hdae5000_ui_display.s |
| 29842a | 298541 | HDAE5000_HD_FatLoadSector                   | 4        | hdae5000_ui_display.s |
| 298541 | 29859a | HDAE5000_HD_FatNextCluster                  | 2        | hdae5000_ui_display.s |
| 29859a | 298638 | HDAE5000_HD_FreeChain_Worker                | 2        | hdae5000_ui_display.s |
| 298638 | 298896 | HDAE5000_HD_Format_Worker                   | 1        | hdae5000_ui_display.s |
| 298896 | 2988af | HDAE5000_HD_ZeroSector                      | 1        | hdae5000_ui_display.s |
| 2988af | 298a8e | HDAE5000_HD_BuildSettingsSector             | 9        | hdae5000_ui_display.s |
| 298a8e | 298b92 | HDAE5000_FormatDecimal12_ZeroFill           | 5        | hdae5000_ui_display.s |
| 298b92 | 298c86 | HDAE5000_HD_ComputeDiskUsage                | 4        | hdae5000_ui_display.s |
| 298c86 | 2991ad | HDAE5000_HD_BytesToClusters                 | 16       | hdae5000_ui_display.s |
| 2991ad | 299487 | HDAE5000_DirBrowser_GetRowByte              | 9        | hdae5000_ui_display.s |
| 299487 | 2996b7 | HDAE5000_DirBrowser_GetCursor               | 8        | hdae5000_ui_display.s |
| 2996b7 | 29973f | HDAE5000_FlsBrowser_RowAddress              | 1        | hdae5000_ui_display.s |
| 29973f | 299752 | HDAE5000_FlsBrowser_GetCursor               | 1        | hdae5000_ui_display.s |
| 299752 | 29989f | HDAE5000_FlsBrowser_GetRowByte              | 6        | hdae5000_ui_display.s |
| 29989f | 29abd8 | HDAE5000_DeadLib_Copy64Back                 | 21       | hdae5000_ui_display.s |
| 29abd8 | 29ad44 | HDAE5000_SPrintf                            | 6        | hdae5000_ui_display.s |
| 29ad44 | 29ae0c | HDAE5000_ULToA                              | 2        | hdae5000_ui_display.s |
| 29ae0c | 29af2d | HDAE5000_MemChr                             | 5        | hdae5000_ui_display.s |
| 29af2d | 29af71 | HDAE5000_StrPrefixCmp                       | 2        | hdae5000_utilities.s  |
| 29af71 | 29b01b | HDAE5000_StrLen                             | 4        | hdae5000_utilities.s  |
| 29b01b | 29b72d | HDAE5000_StrRev                             | 13       | hdae5000_utilities.s  |
| 29b72d | 29b7fa | HDAE5000_Multiply                           | 5        | hdae5000_utilities.s  |
| 29b7fa | 29b9ac | HDAE5000_LongToFloat                        | 10       | hdae5000_utilities.s  |
| 29b9ac | 300000 | HDAE5000_Long_To_Unpacked                   | 9        | hdae5000_utilities.s  |

Near absolute calls inside one calr-joined span:

