# HD-AE5000 open items, wave 4 (sub-lane kn5000-b / hdae, 2026-10-31)

Issues: kn5000-44c (filesystem open questions), kn5000-t8n (PC-link packet layout), kn5000-e7f (PC-link XAP
flash path), kn5000-mzz (interface connector pinout), kn5000-qnf (HD-TechManager5000 software), and the
HD-AE5000 leads of kn5000-nl6.  Every address below is v2.06i (`hdae5000/`) unless a version is named; the
labels are the current ones (after this lane's renames).  `probes/README.md` lists the scripts.

## kn5000-44c: the filesystem's open questions

`hdae5000-filesystem.md#open-questions` listed three questions.  All three are now answered from the code.

### The song record's ten flag bytes and ten slots

The 76-byte song record (`HDAE5000_RAM_SongRecords + dir × 0x4C0 + song × 0x4C`) is

| Offset | Size   | Contents                                                           |
|--------|--------|--------------------------------------------------------------------|
| +0     | 26     | name, space-padded                                                 |
| +26    | 10 × 1 | part-present flags: part *k* at +26 + *k*; 1 = saved, 0 = deleted  |
| +36    | 10 × 4 | first-cluster slots: part *k* at +36 + 4*k*; `0xFFFFFFFF` = absent |

Part numbers are the order of the nine `HDAE5000_SaveSong_*` / `LoadSong_*` / `DeleteSongPart_*` routines and of
the mask bits: 0 LSW, 1 PMT, 2 SQT, 3 CMP, 4 TM, 5 MSP, 6 RCM, 7 MD, 8 TLX.  Evidence:

- every `HDAE5000_SaveSong_<part>` writes the new chain's first cluster to slot +36 + 4*k* through
  `HDAE5000_HD_WriteFile`, then stores 1 in flag byte +26 + *k* (e.g. `HDAE5000_SaveSong_Lsw`: slot +36,
  flag +26; `HDAE5000_RcmStream_Write`: flag +32 for RCM); every `HDAE5000_DeleteSongPart_<part>` frees the
  chain, stores `0xFFFFFFFF` in the slot and 0 in the flag (e.g. `HDAE5000_DeleteSongPart_Lsw`);
- `HDAE5000_LoadSong_Rcm` reads slot +60 (= 36 + 4 × 6), `HDAE5000_LoadSong_Md` slot +64 (= 36 + 4 × 7);
- the code of every tree uses exactly the flag offsets +26..+34 and the slot offsets +36..+68 (v2.06i, v2.01i)
  or +26..+33 and +36..+64 (v1.15i, v1.10i: eight parts, no TLX).  Flag byte +35 and slot +72 (index 9) are
  written only by `HDAE5000_HD_InitTables` (format: 10 zero bytes from +26, 10 × `0xFFFFFFFF` from +36);
- `HDAE5000_HD_GetSongInfo` copies all ten flag bytes (+26..+35) to its destination +44 (service 13 hands them
  to the PC, see kn5000-t8n below).

So the record reserves ten parts and uses nine; the tenth flag and slot are spare.  v2.0 used the ninth (TLX, the
lyrics) that v1.x left spare.  [INFERENCE] The tenth was reserved the same way.

### The FLS item bytes +80 and +112: AS and AL

The 144-byte FLS record is a 16-byte name and four 32-byte arrays indexed by item:

| Offset | Size   | Contents                                                       |
|--------|--------|----------------------------------------------------------------|
| +0     | 16     | name                                                           |
| +16    | 32 × 1 | directory + 1 (0 = empty item)                                 |
| +48    | 32 × 1 | song + 1                                                       |
| +80    | 32 × 1 | **AS** (AUTO START): 1 = start the sequencer after loading     |
| +112   | 32 × 1 | **AL** (AUTO LOAD): 1 = load the next item when playback stops |

Evidence:

- the FLS edit screen (`HDAE5000_FlsEditScreen_OnSwIn`) toggles +80 through edit switch 6 and +112 through edit
  switch 7, setting 0 or 1 from the switch state (bit 7 of IZ), with `HDAE5000_FlsItem_SetAutoStart` /
  `HDAE5000_FlsItem_SetAutoLoad` (were `SetByte80` / `SetByte112`);
- the FLS lists (`HDAE5000_FlsScreen_Refresh`) draw a `*` in column 0x20 when +80 is 1 and in column 0x23 when
  +112 is 1;
- loading an item (`HDAE5000_FlsLoadScreen_OnHdaeSelectOk` / `_OnHdaeAfterLoad`): when +80 is 1 the loader
  calls `HamaFn_SwbtWr(0x48, 5, 1)` after `HDAE5000_LoadSongWithUi`, i.e. presses the sequencer start; when +112
  is 1 it sets `HDAE5000_RAM_FlsAutoLoadPending` and keeps the FLS and item in `HDAE5000_RAM_FlsChainFls` /
  `HDAE5000_RAM_FlsChainItem`;
- the frame handler (`HDAE5000_Frame_Handler_Status`) watches bit 2 of the main CPU's `sqsrtc` byte; when it falls
  (the sequencer stopped) and `HDAE5000_Fls_GetAutoLoadPending` returns 1, it shows the FLS load page (on the HD
  title) or sets `HDAE5000_RAM_FlsSeqStopPending` (`HDAE5000_Fls_SetSeqStopPending`) and requests the HD title;
  `HDAE5000_HDAETitleFunc` then posts `EVT_HDAE_SEQ_STOP` to the FLS load page.  On `EVT_HDAE_SEQ_STOP` the page
  arms an application timer of 0x53 ticks (`RootFn_SetApTimer`) that delivers `EVT_HDAE_AFTER_LOAD`, which loads
  item + 1 (wrapping to item 0 of the next FLS after item 31, and to FLS 0 after FLS 119);
- the owner's manual (`hdae5000/hd-techmanager5000/hd-ae5000manual-e.pdf`, "SELECT FILE LOAD SCRIPT (FLS)"):
  "you can use AUTO START (AS) and AUTO LOAD (AL) to create a load/play chain ... If the first song has AS
  indicated, the sequencer will start playing the music immediately after loading is complete. With AL
  indicated, the next song will be automatically loaded after sequencer has stopped ... you have 2 second's to
  interrupt the play/load chain with the PANIC button."  [INFERENCE] the 0x53-tick timer is those 2 seconds.

The four chain bytes are at 0x22AD96 / 98 / 9A / 9B in v2.x and 0x22AD4E / 50 / 52 / 53 in v1.x (the v1 headers had
quoted the v2 addresses).

### "FSB" is the whole table set

PC-link commands 03-06 move all three blocks, not one:

- command 03 (`HDAE5000_PPORT_Cmd03_ReadFsbFromHd`) runs service 7, which is `HDAE5000_HD_LoadTables(1)`: all 323
  table sectors (services 8 and 9 are the same call);
- command 04 (`HDAE5000_PPORT_Cmd04_SendFsbToPc`) runs services 4, 5 and 6, copies the three block descriptors
  (info block +0x2C..+0x45) into its reply and then sends block 0, block 1 and block 2, each *width* × *count*
  bytes (`HDAE5000_PPORT_SendBlock`);
- command 05 receives the three blocks the same way (`HDAE5000_PPORT_RecvBlock`);
- command 06 runs service 10, `HDAE5000_HD_StoreTables(1)` (11 and 12 are the same call).

ppkn50.dll's `PP50ReadFsbFromKnHdToKnMem` / `PP50SendFsbFromKnMemToPC` / `PP50SendFsbFromPCToKnMem` /
`PP50WriteFsbFromKnMemToKnHd` send exactly commands 3, 4, 5 and 6 (`probes/ppkn50_command_map.py`), and
HD-TechManager5000 keeps the three blocks on the PC as `Dirblk.dat`, `Fileblk.dat` and `Flsblk.dat` (strings of the
program, see kn5000-qnf).  The developers' "FGB" (block 0) and "FEB" (block 1) are the per-block names of the
services' debug trace.

### Website page draft (hdae5000-filesystem.md)

Replace the "Song record (76 bytes)" table, the "FLS record (144 bytes)" paragraph, the last paragraph of "The
developers' names for the blocks" and the first three bullets of "Open Questions" with:

> **Song record (76 bytes)**:
>
> | Offset | Size   | Contents                                                           |
> |--------|--------|--------------------------------------------------------------------|
> | +0     | 26     | name, space-padded (blank = 26 spaces)                             |
> | +26    | 10 × 1 | part-present flags, part *k* at +26 + *k*: 1 = saved, 0 = deleted  |
> | +36    | 10 × 4 | first-cluster slots, part *k* at +36 + 4*k*; `0xFFFFFFFF` = absent |
>
> Parts: 0 LSW, 1 PMT, 2 SQT, 3 CMP, 4 TM, 5 MSP, 6 RCM, 7 MD, 8 TLX.  Each `HDAE5000_SaveSong_<part>` stores the
> chain's first cluster in its slot and 1 in its flag; each `HDAE5000_DeleteSongPart_<part>` frees the chain and
> stores `0xFFFFFFFF` and 0.  The tenth flag (+35) and slot (+72) are written only by a format: spare.  The v1.x
> firmware has eight parts (no TLX) and leaves the ninth spare as well.  `HDAE5000_HD_GetSongInfo` hands all ten
> flags to the PC link (service 13).
>
> **FLS record (144 bytes)**: a 16-byte name, then four 32-byte arrays indexed by item: the directory + 1 (+16),
> the song + 1 (+48), **AS** "auto start" (+80) and **AL** "auto load" (+112).  An item is set when its directory
> and song bytes are non-zero (`HDAE5000_FlsItem_IsSet`).  Edit switches 6 and 7 of the FLS edit page set AS and
> AL (`HDAE5000_FlsItem_SetAutoStart` / `_SetAutoLoad`); the lists mark them with `*`.  Loading an AS item presses
> the sequencer start (`HamaFn_SwbtWr(0x48, 5, 1)`).  Loading an AL item arms a chain
> (`HDAE5000_RAM_FlsAutoLoadPending`, with the FLS and item in `HDAE5000_RAM_FlsChainFls` / `_FlsChainItem`): when
> bit 2 of the main CPU's `sqsrtc` falls (the sequencer stopped), the FLS load page gets `EVT_HDAE_SEQ_STOP`, waits
> 0x53 ticks (the manual's two seconds to press PANIC) and loads the next item, wrapping to the next FLS after item
> 31.
>
> **"FSB" is the whole table set.** PC-link command 03 runs `HDAE5000_HD_LoadTables` (all 323 sectors), 04 sends
> blocks 0, 1 and 2 after a reply that carries their three descriptors, 05 receives them, and 06 runs
> `HDAE5000_HD_StoreTables`.  HD-TechManager5000 stores the blocks as `Dirblk.dat`, `Fileblk.dat` and
> `Flsblk.dat`.  "FGB" (block 0) and "FEB" (block 1) are the per-block names of the services' debug trace.

and in "Open Questions" keep only the lyric-player bullet.

## kn5000-t8n: the PC-link packet, verified per command

Everything moves in 256-byte packets (`HDAE5000_RAM_PportPacket`, `HDAE5000_PPORT_RecvPacket` /
`_SendPacket`), each followed by the 32-bit byte sum, little-endian, and `HDAE5000_PPORT_EndBlock`; the packet is
repeated while EndBlock reports a retry.  Bulk data moves in blocks of any length with the same sum and end
handshake (`HDAE5000_PPORT_SendBlock` / `_RecvBlock`).  `probes/pport_packet_map.py` lists, per handler, the
services, packet offsets and transfers quoted below.

**Request (PC to HD-AE5000).**  Byte 0 is the command, 1-20 (`HDAE5000_PPORT_CommandLoop` rejects only values
above 20: a 0 would jump through the long before `HDAE5000_PPORT_CommandTable`).  The rest depends on the command:

| Command                | Request bytes                                                                                 |
|------------------------|-----------------------------------------------------------------------------------------------|
| 01                     | +1 / +2 = the PC program's version major / minor                                              |
| 07, 08, 09, 11, 14, 16 | +1 directory, +2 song, +3 / +4 part mask low / high (`HDAE5000_PPORT_LatchPacketArgs`)        |
| 10                     | +1 / +2 part mask low / high, +3.. eight u32 part sizes: LSW, PMT, SQT, CMP, TM, MSP, MD, TLX |
| 11                     | (also) +5 the 26-byte song name                                                               |
| 13                     | +1..+4 as 07; +5 u32 sector count; +9 the 26-byte song name                                   |
| 20                     | +2 u32 byte count                                                                             |
| 02-06, 12, 15, 17-19   | nothing beyond byte 0                                                                         |

The part mask is the song-part numbering of kn5000-44c: bits 0-7 of the low byte = parts 0-7, bit 0 of the high
byte = part 8 (TLX).

**Reply (HD-AE5000 to PC).**  A reply packet is cleared (`HDAE5000_PPORT_ClearPacket`), filled with a byte range
of the info block `HDAE5000_RAM_PportInfoBlock` copied to the same offsets (`HDAE5000_PPORT_CopyInfoToPacket`), and
byte 255 is set to 0xFF on failure (`HDAE5000_PPORT_FlagPacketError`; ppkn50.dll reads it at 0x100121BF and returns
-5).  The info block:

| Offset | Size  | Contents                                                                                                  | Filled by  |
|--------|-------|-----------------------------------------------------------------------------------------------------------|------------|
| +0x00  | 2     | the song's part mask                                                                                      | service 13 |
| +0x02  | 26    | song name                                                                                                 | service 13 |
| +0x1C  | 16    | directory name                                                                                            | service 13 |
| +0x2C  | 8     | block 0 (directory names): u32 address, u16 record width, u16 count                                       | service 4  |
| +0x34  | 8     | block 1 (song records), same layout                                                                       | service 5  |
| +0x3C  | 10    | block 2 (FLS records), same plus u16 items per record                                                     | service 6  |
| +0x46  | 9 × 9 | part records {u32 address, u32 size, u8 present}: LSW area A, LSW area B, PMT, SQT, CMP, TM, MSP, RCM, MD | service 13 |
| +0x97  | 30    | drive model                                                                                               | service 3  |
| +0xB5  | 4     | cylinders                                                                                                 | service 3  |
| +0xB9  | 2     | heads                                                                                                     | service 3  |
| +0xBB  | 2     | sectors per track                                                                                         | service 3  |
| +0xBD  | 2     | 512 (bytes per sector)                                                                                    | service 3  |
| +0xBF  | 9     | the TLX part record                                                                                       | service 13 |
| +0xC8  | 2     | file-format version major / minor (`HDAE5000_RAM_FileFormat_VersionMajor` / `_Minor`)                     | service 3  |
| +0xCA  | -     | free work area (service 19 returns its address)                                                           | -          |

The part records come from the main CPU (`HamaFn_GetResouceInfo` resources 0-3 and 5-9), with the sizes of SQT,
CMP and MSP from `HamaFn_SeqSavePre` (added), `HamaFn_cmp_sv_mae` and `HamaFn_msp_sv_mae`, 0x72AA for TM and
0xAD000 for RCM; the present bytes are the song record's flags +26..+34 (LSW area B's is always 0).

Per command:

| Command    | Handler                  | Services      | Reply / transfers                                                                                                                                                                              |
|------------|--------------------------|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 01         | `Cmd01_SendInfosAboutHd` | 3             | info +0x97..+0xC9 (geometry, file-format version); failure when request +1 differs from the version major ("Error Wrong Dll Ver")                                                              |
| 02         | `Cmd02_ExitPport`        | 1, 18         | no reply; writes 0x00FF at info +0, then service 18 posts `EVT_CHANGE_MODE` `NAKA_MODE_MD_NORMAL` (back to play)                                                                               |
| 03         | `Cmd03_ReadFsbFromHd`    | 7             | status only (`HDAE5000_HD_LoadTables`)                                                                                                                                                         |
| 04         | `Cmd04_SendFsbToPc`      | 4, 5, 6       | info +0x2C..+0x45, then blocks 0, 1, 2 to the PC                                                                                                                                               |
| 05         | `Cmd05_RcvFsbFromPc`     | 4, 5, 6       | info +0x2C..+0x45, then blocks 0, 1, 2 from the PC                                                                                                                                             |
| 06         | `Cmd06_WriteFsbToHd`     | 10            | status only (`HDAE5000_HD_StoreTables`)                                                                                                                                                        |
| 07         | `Cmd07_LoadHdToMemory`   | 13, 14        | info +0x00..+0xC7, then (mask non-zero) service 14 loads the parts into the keyboard's memory and a status packet follows                                                                      |
| 08         | `Cmd08_SendDataToPc`     | 13, 14        | info +0x00..+0x2B with the mask (RCM bit 6 cleared); then load as 07, info +0x00..+0xC7, and one block per mask bit from the part's memory (LSW: areas A and B)                                |
| 09         | `Cmd09_SendFilesToPc`    | 13, 24, 25    | info +0x00..+0x2B, mask in +0/+1, nine u32 part sizes from +0x2C; then each part streamed from the disk (`HDAE5000_PPORT_SendRegionToPc`)                                                      |
| 10         | `Cmd10_RcvDataFromPc`    | 1, 20, 16     | receives each masked part into fixed main-CPU RAM: PMT 0x1ED350, SQT 0x0AB000, CMP 0x094800, TM 0x1E0000, MSP 0x1E8800, MD 0x3D3000, TLX the lyric buffer, LSW `HDAE5000_PPORT_RecvCustomData` |
| 11         | `Cmd11_SaveMemoryToHd`   | 1, 15         | mask and name into the info block, service 15 saves the song from memory to disk; status                                                                                                       |
| 12, 15, 19 | `Cmd12/15/19_Nothing`    | -             | status record only, no reply                                                                                                                                                                   |
| 13         | `Cmd13_RcvDataFromPc`    | 1, 21, 23, 22 | writes the PC's sectors straight to a new chain (WriteOpenHD / WriteFileHD per 512-byte sector / WriteCloseHD), one status byte per step (`HDAE5000_PPORT_SendByte`)                           |
| 14         | `Cmd14_SendInfosToPc`    | 13            | the reply of 09 without the data                                                                                                                                                               |
| 16         | `Cmd16_DeleteFiles`      | 13, 27        | info +0x00..+0xC7 with the masked mask; service 27 deletes those parts; status                                                                                                                 |
| 17         | `Cmd17_FormatHd`         | 17            | status only                                                                                                                                                                                    |
| 18         | `Cmd18_SwitchHdMotorOff` | 2             | status only                                                                                                                                                                                    |
| 20         | `Cmd20_SendXapFileFlash` | 29, 28, 30    | see kn5000-e7f; no reply packet                                                                                                                                                                |

(Service 26, the status record, runs first in every handler and is left out of the column.)

Two things the code does that a PC implementation must copy: in command 07 the masked high byte is stored in reply
byte 0, not 1 (`ld (xix), w` in `HDAE5000_PPORT_Cmd07_LoadHdToMemory`; command 08 stores it in byte 1); and
commands 07, 08 and 16 AND the requested mask with the song's own mask, so asking for a part the song lacks is not
an error.

So the "older reading" on the website was the reply of commands 09 / 14: bytes 0 and 1 are the mask, and the nine
longs from +0x2C are part **sizes** (LSW, PMT, SQT, CMP, TM, MSP, RCM, MD, TLX), not sector addresses.

### Website page draft (hdae5000-filesystem.md, "PPORT transfer packet")

Replace the section "PPORT transfer packet (older reading, not re-verified)" with the three tables above (request,
info block, per command) under the heading "PC-link packets", preceded by the paragraph "Everything moves in
256-byte packets ..." and followed by the two "things the code does" and the last paragraph.  In hdae5000.md's
command table (row 02 and the rows of the twenty commands) use the handler names and the "Reply / transfers"
column.

## kn5000-e7f: the PC-link XAP flash path (command 20)

Command 20 exists only in v2.x (v1.x has services 0-27, no 28-30).  `HDAE5000_PPORT_Cmd20_SendXapFileFlash`:

1. shows "20>Send XapFile flash" (service 26) and runs service 29, `HDAE5000_PPORT_Svc29_SleepMainTask`
   (`RootFn_SleepMainTask`; was `MainHook0538`);
2. reads the u32 byte count at request +2 into RAM 0x239104 and receives that many bytes into **main-CPU work
   DRAM 0x010000** (`HDAE5000_PPORT_RecvBlock`, XIY = 0x10000): one block per command, so 64 KB at most before it
   overwrites what lies above 0x20000 [INFERENCE: the PC sends the image in 64 KB pieces, one command each];
3. runs service 28, `HDAE5000_PPORT_Svc28_FlashXapFile`, with XBC = 0x10000 and XDE = 0x239104: it builds the
   descriptor {"XAP", &count, `HDAE5000_ROM_HEADER` (0x280000), 0x2F0000} on the stack and calls
   `HDAE5000_RAM_XAP_FLASH_ENTRY` (SRAM 0x23FEB0) with XWA = 0x10000, XBC = the descriptor; the result is kept at
   RAM 0x2390FA;
4. runs service 30, `HDAE5000_PPORT_Svc30_WakeUpMainTask`, and shows "End Flash Right" when the result is 0x58,
   else "End Flash False".  No reply packet is sent.

**No version check.**  Command 20 checks neither the data nor a version: the only test is the flasher's result
0x58.  The one version check of the link is command 01's (request +1 against the file-format version major,
"Error Wrong Dll Ver"); the floppy path (type 6) has none either (firmware-update-procedure.md).

**What runs at 0x23FEB0 is not in any image here.**  Searched, as text over every tree and for the literal
address: no HD-AE5000 version writes SRAM 0x23F000-0x23FFFF other than the PC-link context's stack (top
0x23FFFC, `HDAE5000_RAM_PportLinkStackTop`, 0x14C bytes above the entry), the `.data` image lands at
0x23952A-0x23A1AC, and no main-CPU, table-data or custom-data source names 0x23Fxxx.  No PC-link command writes to a
PC-chosen address: every receive (05, 10, 13, 20) goes to a fixed or HD-chosen place.  And the only PC software in
hand, HD-TechManager5000 v1.40 (`hdae5000/hd-techmanager5000/setup.EXE`), never sends command 20: ppkn50.dll has
no export that does (`probes/ppkn50_command_map.py`: its exports send 1-11, 13, 14, 16, 17, 18).  So, with the
firmware and software in hand, command 20 calls an empty SRAM location: [INFERENCE] a feature for a later PC
program that had to bring its own flasher by a route not in these ROMs.

### Website page draft (hdae5000.md, after the type-6 floppy update; and firmware-update-procedure.md)

> **PC-link flash (command 20, v2.x only).**  `HDAE5000_PPORT_Cmd20_SendXapFileFlash` puts the main CPU's task to
> sleep (service 29, `RootFn_SleepMainTask`), receives as many bytes as request bytes 2-5 say into work DRAM
> 0x010000, and runs service 28, which calls SRAM 0x23FEB0 with XWA = 0x010000 and XBC = a descriptor {"XAP",
> pointer to the byte count, 0x280000, 0x2F0000}.  It then wakes the main task (service 30) and shows "End Flash
> Right" when the call returned 0x58, else "End Flash False".  Nothing checks a version or the data.  Nothing in
> the HD-AE5000, main-CPU, table-data or custom-data ROMs puts code at 0x23FEB0, no link command can write there,
> and HD-TechManager5000 v1.40's ppkn50.dll never sends command 20, so this path cannot be used with the firmware
> and software that survive.  The type-6 floppy is the working update path.

## kn5000-mzz: the option connector CN6

The service manual (`technics-docs/service_manual/technics_sx-kn5000.pdf`, image-only) draws the HD-AE5000's
connection on two sheets:

- **WIRING CONNECTION diagram** (sheet II-1/II-2, PDF page 27): the MAIN board's **CN6**, a two-row connector
  "1 ... 34 / 35 ... 68", with the arrow "FOR HSO (OPTION)".  No cable is drawn to it.  **W3 (QEXGZA34060B) is a
  different cable**: it runs from MAIN's CN5 (17 pins), through a ferrite core, to another board.  hdae5000.md
  said the HD-AE5000 connects "via cable W3 (part number QEX0ZA34008)", and that the connector is labeled
  "HSQ(OPTION)" on the block diagram (II-3) and "FOR H.D. (OPTION)" on the wiring diagram (II-1).  Against the
  wiring sheet: W3 is not the option's cable, and the arrow there reads **"FOR HSO (OPTION)"**.  The block
  diagram's label (II-3) was not re-read here; "HSQ" there is [INFERENCE] the same "HSO" misread.  (Corrected
  2026-11-02: this paragraph used to misquote the page as calling W3 itself "labeled HSQ(OPTION)".)
- **MAIN P.C. diagram** (sheet II-8, PDF page 30) lists CN6 pin by pin, 70 pins (the wiring sheet's "68" counts
  without the last two ground pins, 69 and 70):

| Pin | Signal | Pin | Signal | Pin | Signal | Pin | Signal | Pin | Signal |
|-----|--------|-----|--------|-----|--------|-----|--------|-----|--------|
| 1   | E      | 15  | D2     | 29  | A9     | 43  | A5     | 57  | D4     |
| 2   | E      | 16  | D9     | 30  | IORST  | 44  | A4     | 58  | HDINT  |
| 3   | +15M   | 17  | D1     | 31  | RYBY   | 45  | A3     | 59  | PPIFCS |
| 4   | +5A    | 18  | D8     | 32  | A1     | 46  | A2     | 60  | +5D    |
| 5   | E      | 19  | D0     | 33  | E      | 47  | E      | 61  | LRCK   |
| 6   | E      | 20  | HSORAM | 34  | E      | 48  | HSOROM | 62  | D03    |
| 7   | DACCK  | 21  | A18    | 35  | E      | 49  | RD     | 63  | E      |
| 8   | BCK    | 22  | A17    | 36  | E      | 50  | D15    | 64  | E      |
| 9   | +5D    | 23  | A16    | 37  | WRLL   | 51  | D7     | 65  | +15A   |
| 10  | HDDCS  | 24  | A15    | 38  | WRLH   | 52  | D14    | 66  | -15A   |
| 11  | HDRDY  | 25  | A14    | 39  | A10    | 53  | D6     | 67  | E      |
| 12  | D11    | 26  | A13    | 40  | A8     | 54  | D13    | 68  | E      |
| 13  | D3     | 27  | A12    | 41  | A7     | 55  | D5     | 69  | E      |
| 14  | D10    | 28  | A11    | 42  | A6     | 56  | D12    | 70  | E      |

(E = ground.  "D03" is printed so on the sheet; next to BCK / LRCK / DACCK it is [INFERENCE] a serial audio data
line, not a data-bus bit.)

What it shows:

- a 16-bit data bus D0-D15, address lines A1-A18 (no A0: word bus), read strobe RD and separate low/high write
  strobes WRLL / WRLH;
- the chip selects HSOROM (the option's ROM, 0x280000), HSORAM (its SRAM, 0x200000), HDDCS (the ATA registers) and
  PPIFCS (the PPI at 0x160000); the CPU sheet II-11 names the same signals HSOROM, HSORAM, HDDCS, PPIFCS (the site's
  "PPPCS" and "HDOCS" are misreadings);
- HDINT (pin 58) and HDRDY (pin 11), the drive's interrupt and ready lines (HDDINT / HDDRDY on the CPU sheet);
  IORST (pin 30) and RYBY (pin 31, the flash's ready/busy);
- the digital audio clocks DACCK, BCK, LRCK and D03, and analog supplies +15M, +15A, -15A, +5A beside +5D: the
  connector carries audio, which the HD-AE5000 does not use [INFERENCE: CN6 is a general option port, "HSO"].

The presence line PE.0 the firmware tests is not on this list by that name.  [INFERENCE] it is one of the lines
above seen from the CPU sheet (PE.0 would need tracing on sheet II-11).

**Blocked**: the board side (the HD-AE5000's own connector, its PPI / ATA / flash wiring) needs the HD-AE5000
board or its service manual; neither is in hand.

Recipe (renders go to scratch; nothing is committed): `pdftoppm -f 30 -l 30 -r 300 -png technics_sx-kn5000.pdf m`,
then crop x 0.585-0.70, y 0.13-0.95 of the page; the wiring sheet is PDF page 27, x 0.62-0.85, y 0.55-0.85.

### Website page draft (hdae5000.md, "Physical Connection" and "Main CPU Bus Signals")

> The HD-AE5000 connects to the MAIN board's **CN6**, a 70-pin two-row connector marked "FOR HSO (OPTION)" on the
> wiring diagram (service manual II-1; the pin list is on the MAIN P.C. diagram, II-8).  The wiring sheet draws no
> cable to it; the cable W3 (QEXGZA34060B) on that sheet belongs to CN5.
>
> (the CN6 table above)
>
> The connector carries the 16-bit bus (D0-D15, A1-A18, RD, WRLL/WRLH), four chip selects (HSOROM for the option
> ROM at 0x280000, HSORAM for its SRAM at 0x200000, HDDCS for the drive registers, PPIFCS for the PPI at
> 0x160000), the drive's HDINT and HDRDY, IORST and RYBY, and also digital audio (DACCK, BCK, LRCK, D03) and analog
> supplies (+15M, +15A, -15A, +5A), which the HD-AE5000 does not use.  The board side is not documented: the
> KN5000 service manual has no HD-AE5000 sheet.

and in "Main CPU Bus Signals" rename PPPCS to PPIFCS, HDOCS to HDDCS and HSQRAM to HSORAM (the SRAM chip
select, not an "address space qualifier"; the page's "HD control signals (HDOCS, HDDRDY, HSQRAM)" line too).
(HSQRAM added 2026-11-02; the draft had missed it.)

## kn5000-qnf: HD-TechManager5000

The archived disks hold two different programs.  Both are Wise installers (Great Lakes Business Solutions): each
file is a raw deflate stream followed by its CRC-32.  `probes/wise_scan.py` finds every member by trying an
inflate at each offset; it unpacks the setup set (`setup.EXE` + `setup.W02`) into 71 members and the
`HDTMD120.EXE` + `.W02` set into 80.  The unpacked files stay in scratch.

**setup.EXE: HD-TechManager5000 v1.40 (32-bit).**  Its install script names: `HD-TechManager5000.exe` (a Visual
Basic 5 program, 1,353,728 bytes, importing only `MSVBVM50.DLL`), `ppkn50.dll` (byte-identical to the copy in
`hdae5000/hd-techmanager5000/`), `E_help.hlp`, `D_hilfe.hlp`, `ReadMe.doc`, `Fls.ini`, and sample songs
(`samples\01entent`, `02hawaii`, `03chatta`, `04i_mit_` as .lsw / .pmt / .sqt / .tm / .cmp; the .tm members are
0x72AA bytes beginning "KN5000 SOUND RAM").  Its install notes (in the script) call it "Version 1.40", from
keysoftservice.ch.

- **The DLL interface.**  ppkn50.dll exports 26 functions: 23 named `PP50*`, and `AskTheConvMem`,
  `OpenThisFile`, `SaveThisFile`.  19 of the `PP50*` send a PC-link command (the table).  The other four,
  `PP50OpenThePortNumber`, `PP50CloseThePort`, `PP50InitializeTheDll` and `PP50TestParallelModus`, send none,
  and nor do the three others.  (Corrected 2026-11-02 from a re-run of the probe: this said the program declares
  23 `PP50*` functions and the DLL exports "four more"; how many the VB program declares was not counted.)
  Which command each sends (`probes/ppkn50_command_map.py`, from the `push <command>; push <port>; call 0x10002810` before each link
  transaction):

| Export                           | Commands | Export                            | Commands |
|----------------------------------|----------|-----------------------------------|----------|
| `PP50TestTheKNPP`                | 1        | `PP50SendFileFromPCToKNMem`       | 10       |
| `PP50EscapeKeyboardToPlay`       | 2        | `PP50SendFileFromPCToKNHD`        | 10       |
| `PP50ReadFsbFromKnHdToKnMem`     | 3        | `PP50SaveFileFromKNMemToKNHd`     | 11       |
| `PP50SendFsbFromKnMemToPC`       | 4        | `PP50SaveFileFromPCDirectToKNHd`  | 13       |
| `PP50SendFsbFromPCToKnMem`       | 5        | `PP50SavePCMemDirectToKNHd`       | 13       |
| `PP50WriteFsbFromKnMemToKnHd`    | 6        | `PP50SendSeveralFileDirectToKNHD` | 13, 6    |
| `PP50LoadFileFromKnHdToKnMem`    | 7        | `PP50TestSongInfoFromKnHd`        | 14       |
| `PP50LoadFileFromKnHdToPC`       | 8        | `PP50DeleteFileOnKnHd`            | 16       |
| `PP50LoadFileFromKnHdDirectToPC` | 9        | `PP50FormatTheKn50HardDisk`       | 17       |
|                                  |          | `PP50TurnOffTheKn50HdMotor`       | 18       |

  Commands 12, 15, 19 ("nothing") and 20 (XAP flash) are never sent.  This corrects
  `hdae5000/hd-techmanager5000/ppkn50-protocol-analysis.md`, whose command table had 02 as "TestTheKNPP" and wrote
  the decimal commands 10, 11, 16, 17, 18 as 0x10 ... 0x18 (fixed in this lane's commit).
- **Files on the PC.**  The program's strings name the PC copies of the three table blocks, `Dirblk.dat`,
  `Fileblk.dat`, `Flsblk.dat`, with `Dirdumy.dat` / `Filedumy.dat` / `Flsdumy.dat` and `Filesic.dat` /
  `Flssic.dat` beside them, a `Manager.ini`, a `Backup.log`, and the file filter `*.cmp;*.sqt;*.tm;*.lsw;*.msp`.
  [INFERENCE from the names] "dumy" are blank images and "sic" (Sicherung) safety copies; the block files are the
  raw blocks of kn5000-44c (16 × 120, 76 × 1,920 and 144 × 120 bytes).  The install notes say the backup stores
  each song's parts plus a `.TTX` file "with long name" per song, so a disk backup can be restored with the
  26-character names; and that "COPY TO HD-AE" sends a floppy of Technics files with a text file of titles
  supplied by the software publishers (Tech-Note, Taiyo, Mister Music, Technisoft, Musikstudio Witten).
- **What is not analysed.**  The VB5 program's P-code/native body (form logic) was not decompiled: no VB
  decompiler is installed here.  Its strings and its DLL calls (above) are what this note uses.

**HDTMD120.EXE: a different, 16-bit product.**  Its script installs `Demo.exe` with `Kn30pp16.dll`,
`Ppbas16.dll`, `Ppbcre16.dll`, `Psccprog.dll`, `Disk.dll`, `Filedir.dat` / `Fls.dat` / `Groupdir.dat` databases,
Crystal-Reports `.rpt` files and Visual Basic 4 (16-bit) runtimes, and its sample database lists folders named "KN
3000 1" ... "KN 3000 17": the KN3000-era hard-disk manager (the plan's "HD-TE96.exe" and "ConvKN.dll" are not on
either disk set).  It is out of this repository's scope beyond this identification.

### Website page draft (hdae5000-techmanager.md, new section "The software")

> The archived disks are Wise installers.  `setup.EXE` / `setup.W02` install **HD-TechManager5000 v1.40**, a
> Visual Basic 5 program (`HD-TechManager5000.exe`) over `ppkn50.dll`, with German and English help, `Fls.ini` and
> sample songs.  19 of the DLL's 23 `PP50*` functions send one of the HD-AE5000's PC-link commands, as follows
> (table above); port open / close, initialisation and `PP50TestParallelModus` send none.  Commands 12, 15, 19 and 20 are never sent: this software cannot use the v2.x XAP flash command.  The
> program keeps the three table blocks on the PC as `Dirblk.dat`, `Fileblk.dat` and `Flsblk.dat` and backs up
> songs part by part with a `.TTX` long-name file each.  `HDTMD120.EXE` / `.W02` is a different, 16-bit program
> for the KN3000's hard disk (`Kn30pp16.dll`), not for the HD-AE5000.

and replace the "DLL exports 23 `PP50*` functions" table with the export/command table.

## kn5000-nl6: the HD-AE5000 leads

| Lead                                                                                 | Outcome                                                                                                                                                                                                                                                                                                                                                               |
|--------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `HDAE5000_LoadSong_Rcm` / `SaveSong_Rcm` comments have the LDIRW direction backwards | Already fixed before this lane (the swapped comments are gone; `HDAE5000_RcmStream_InitialState` documents `95 11` = LDIRW (XIX+),(XIY+)).  This lane named the destination: `HDAE5000_RAM_HdStreamBufferEnd` was only ever the RCM stream context, now `HDAE5000_RAM_RcmStreamState`, all four trees                                                                 |
| the signature table's pointers are `.byte` + `.asciz "/"` (respell as .long)         | Already fixed by `d8574de89`: `HDAE5000_PartSignatureTable` is nine `{.long HDAE5000_PartSig_<part>; .short offset, length}` records in every tree (checked)                                                                                                                                                                                                          |
| the CMP signature is 'H\0K', not 'HK\0'                                              | Already right: `HDAE5000_PartSig_CMP` / `_MSP` / `_RCM` are `.asciz "H"` + `.asciz "K"` (bytes 48 00 4B), compare length 3                                                                                                                                                                                                                                            |
| `HdaeRom_DataHandler` / `HdaeRom_AltHandler` convert older models' sound-RAM images  | Confirmed (main CPU, not HD-AE5000).  Renamed by the naming sub-lane, open4/kn5000-b-naming `3832a6dfc` (`scripts/renaming/rename_open4_naming.sed`): `SoundRam_IdentifyImage`, `SoundRam_ConvertSounds`, `SoundRam_ConvertUserKit`, `SoundRam_ConvertKn3000UserKit`, `SoundRam_WriteChecksum`.  This lane's own rename of the same family was reverted (`11a3b6d5b`) |

What this lane read in that code, for the naming sub-lane's notes (names as in `3832a6dfc`): after a .TM file
(`PostTmLoad`) or one SOUND MEMORY entry (`PostTmLoadEntry`) is read into the image at 0x1E0000,
`SoundRam_IdentifyImage` compares the 16-byte id with the KN5000 / KN1500 / KN3000 ids (whole) and the KN2000 / MKA /
MKB ids (bytes 5-7) and returns 6, 5, 4, 1, 2, 3, or 0; `SoundRam_ConvertSounds` rewrites the 40 user sounds
(470 B from +0x10): ids 1-3 from 144-byte records at +80, id 5 from 289-byte records at +16, ids 4 and 6 unchanged,
id 0 returns 0xFF9A; `SoundRam_ConvertUserKit` converts the user kit at +0x4980 only for id 4
(`SoundRam_ConvertKn3000UserKit`: opens kit byte +0x11 = 1 by moving +0x4991..+0x72A5 up one, sets bit 5 "user RAM
entry" in the 128 per-note words at +0x49A7), leaves id 6 and returns 0xFF9A for the others.  In v10/v9 the two
switch tables were also reached through `.set` aliases `COMM_InitFuncTable + 540` / `+ 552` at the same addresses
(llvm-nm); whether `3832a6dfc` merged those is for the naming sub-lane to say.

## Also renamed (HD-AE5000, all trees that have them)

| Old                                   | New                                                                                         | Why                                                        |
|---------------------------------------|---------------------------------------------------------------------------------------------|------------------------------------------------------------|
| `HDAE5000_FlsItem_SetByte80`          | `HDAE5000_FlsItem_SetAutoStart`                                                             | kn5000-44c                                                 |
| `HDAE5000_FlsItem_SetByte112`         | `HDAE5000_FlsItem_SetAutoLoad`                                                              | kn5000-44c                                                 |
| `HDAE5000_Get_Status_Byte`            | `HDAE5000_Fls_GetAutoLoadPending`                                                           | kn5000-44c                                                 |
| `HDAE5000_Set_Status_Byte`            | `HDAE5000_Fls_SetSeqStopPending`                                                            | kn5000-44c                                                 |
| RAM 0x22AD96/98/9A/9B (v1 0x22AD4E..) | `HDAE5000_RAM_FlsChainFls` / `_FlsChainItem` / `_FlsAutoLoadPending` / `_FlsSeqStopPending` | kn5000-44c                                                 |
| `HDAE5000_RAM_HdStreamBufferEnd`      | `HDAE5000_RAM_RcmStreamState`                                                               | kn5000-nl6 lead                                            |
| `HDAE5000_PPORT_Svc18`                | `HDAE5000_PPORT_Svc18_RequestNormalMode`                                                    | kn5000-t8n (posts `EVT_CHANGE_MODE` `NAKA_MODE_MD_NORMAL`) |
| `HDAE5000_PPORT_Svc27`                | `HDAE5000_PPORT_Svc27_DeleteSongParts`                                                      | kn5000-t8n (calls `HDAE5000_DeleteSongParts`)              |
| `HDAE5000_PPORT_Svc29_MainHook0538`   | `HDAE5000_PPORT_Svc29_SleepMainTask`                                                        | kn5000-e7f (`RootFn_SleepMainTask`), v2.x                  |
| `HDAE5000_PPORT_Svc30_MainHook053C`   | `HDAE5000_PPORT_Svc30_WakeUpMainTask`                                                       | kn5000-e7f (`RootFn_WakeUpMainTask`), v2.x                 |

The technics-docs pages that quote old names: boot-sequence.md and hdae5000.md (`HDAE5000_Get_Status_Byte`), and
hdae5000.md (line 554) and hdae5000-filesystem.md (line 361) (`HDAE5000_PPORT_Svc30_MainHook053C`, added
2026-11-02).

## Outcomes

| Issue      | Outcome | Evidence / blocker                                                                                                                                       |
|------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| kn5000-44c | CLOSED  | this README "kn5000-44c"; renames in the four HD-AE5000 trees; draft for hdae5000-filesystem.md                                                          |
| kn5000-t8n | CLOSED  | this README "kn5000-t8n", `probes/pport_packet_map.py`; draft for hdae5000-filesystem.md / hdae5000.md                                                   |
| kn5000-e7f | CLOSED  | this README "kn5000-e7f" (HD-AE5000 side traced, no version check; the 0x23FEB0 flasher is shown absent from every image and from the v1.40 software)    |
| kn5000-mzz | BLOCKED | main-board end transcribed (CN6, 70 pins; W3 correction); the HD-AE5000 board side needs the board or its service manual                                 |
| kn5000-qnf | CLOSED  | this README "kn5000-qnf", `probes/wise_scan.py`, `probes/ppkn50_command_map.py`; the VB5 form logic is not decompiled (no decompiler), stated as a limit |
