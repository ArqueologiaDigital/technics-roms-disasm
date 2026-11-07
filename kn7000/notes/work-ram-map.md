# KN7000 work RAM: the map below 0x502B8000, and where image files land

Build 941 (PROGRAM v1.6). Work RAM is 4 MB of DRAM at 0x50000000..0x503FFFFF (the
reset clear ends at 0x50400000; the service manual lists IC12/IC13 as two 16-Mbit
DRAMs). Written on 2026-10-18 from a research workflow in which each question was
traced by one agent and re-derived by an independent verifier told to assume the
tracer was wrong; the RAM map itself was built twice, once from the boot and
allocator code and once from a sweep of every RAM reference in the ROM, and the two
were reconciled (their censuses agree: 4130 vs 4129 addresses). Probes:
`notes/work-ram-map-probes/` (README there). Routine names used below are in
`kn7000_manual.sym`, section "FILES, PICTURES, SLIDE SHOW".

## Where an image file lands in RAM

| path                                   | reads into                                  | length / limit                                 | then                                                                              |
|----------------------------------------|---------------------------------------------|------------------------------------------------|-----------------------------------------------------------------------------------|
| PICTURE LOAD (floppy, SD, 3rd backend) | INSTALL_SCRATCH 0x502B8000                  | whole file; files over 0x4D800 refused (-0x6D) | optional crop to 240 rows, then memcpy into a slide-show pool block (0x4858154C)  |
| slide-show script images (.ACT tags)   | a pool block directly (SswImageFileLoad)    | whole file, no limit but pool space            | refused and freed if larger than 640x240                                          |
| FEATURE.PRE demo                       | .SQT at 0x502C0000; images into a demo pool | whole files                                    | demo pool 0x502C0000+round4(SQT)..0x50380000                                      |
| debug BITMAP LOAD                      | 0x502B8000                                  | fixed 0x18000-byte read, no size check         | drawn by Draw2BpFile at (0,0)                                                     |
| homepage .HMP                          | 0x503BB810 (zlib arena, first block)        | fixed 0x4442-byte read, no size check          | 'JK' record to RAM 0x5006B5F8 and flash 0x96811000; BMP to flash 0x9681118C       |
| homepage PICTURE LOAD (.BMP)           | 0x503BB810 (zlib arena, first block)        | fixed 0x42B6-byte read                         | checked (<= 160x100, <= 8 bpp), ConvertBitmapFile, programmed to flash 0x9681118C |

**The PICTURE LOAD import (PictureImport 0x485812E8).** 0x4D800 is the size of its
file buffer: the same immediate is the size check (0x48581327), the read length
(0x48581369) and the offset of the second work buffer, 0x502B8000 + 0x4D800 =
0x50305800 (0x485814B5, 0x485814E3). That buffer holds a JPEG decoded to 640 x 240 x 3
bytes (0x70800) when a JPEG taller than 240 rows is trimmed; JpegDecodeCrop keeps the
top, centre or bottom 240 rows and JpegEncode re-encodes them into 0x502B8000. BMPs
are cropped in place (SswBmpCropRows). The highest byte an import writes is
0x50375FFF. The read is already capped, so the size check does not prevent an
overflow; it refuses a file that would be stored cut short. Why exactly 310 KiB is not
in the code. Most likely it is the largest BMP the parser accepts at the manual's
640 x 480 maximum (8 bpp with 256 colours = 308,278 bytes) rounded up; the song event
store is also exactly 0x4D800 bytes, with no code link (`limit_arith.py` prints the
candidates). The PICTURE LOAD screens send All Notes Off when they open: the floppy
screen always (func_4851ABA9 at 0x4852270F; it sends control change 0x7B to every part
through func_48451F1C and stops the sequencer), the SD screen only through SdUiBusyBegin,
which it calls when SdCardUsableCheck fails (0x4855D148) or when its picture list is not
built yet, (0x50083BB0) < 0 (0x4855D167). That is not tied to the buffer, and it does not
explain the manual's "After the PICTURE LOAD display appears, no sound is produced"
(open question below).

**The slide-show pool.** SswPoolAlloc is a bump allocator: a block is
round4(n) + 4 bytes with its length word in front, and the payload starts at
(pool+0x18) + 4. In the main pool (base 0x502031A0, heap from 0x50203F90) the first
payload is 0x50203F94, and payloads lie in 0x50203F94..0x50297FFB (..0x50257FFB when
TgStrapProbe() != 1, which shrinks the pool by 0x40000; MAME returns 1; real hardware
unchecked: the word at 0x502031AC is 0x94E5C or 0x54E5C). USER PICTURE slot k is the
record at 0x502033D0 + k*0x20: name[16], pointer at +0x10 (0x502033E0 + k*0x20), size
at +0x14. SswPoolFree compacts, so a picture's address moves when an earlier block is
freed. Pool header: +8 base, +0xC size, +0x10 heap start, +0x14 heap size, +0x18 bump
pointer, +0x1C free bytes, +0x20/+0x24/+0x28 script and section blocks, +0x30 128
`<ACT NO=n>` pointers, +0x230 30 slot records, +0x5F0 64 named-image records, +0xDF0
heap. Nothing writes picture flash (0x57800000 is read only); pictures leave RAM only
through the slide-show save to disk. The pool is wiped by every song load from disk
(SeqActFileLoad -> SswSongActLoad).

**Script images and the FEATURE demo.** SswImageFileLoad reads straight into a pool
block, no intermediate copy. On the song route the pool holds the script text, then
the `<SLIDESHOW>` and `<ACTION>` sections, then the images in tag order. The FEATURE
demo (FeaturePreLoad, FeatureDemoSqtLoad, FeatureDemoActLoad) reads the .SQT whole to
0x502C0000 and builds its pool after it, up to 0x5037FFFF; the built-in feature demos
(StartFeatureDemo 1..10, pool 0x502B8000..0x502BFFFF) load no files.

**Debug BITMAP LOAD (DbBitmapLoadProc).** 0x18000 (96 KiB) is only a read length;
there is no size check, so a larger file is cut silently and Draw2BpFile still draws
every row the header promises, from stale RAM. It does not derive from 0x4D800. Most
likely it is 3 x 32 KiB chosen to hold a full-screen 4-bpp BMP (76,918 bytes), which is
what CaptureLcd writes in the 2-bit LCD mode (`bmp_sizes.py`).

**Homepage (.HMP and .BMP).** Both buffers come from the zlib arena 0x503BB800..
0x503FFDBF (0x445C0 = 280,000 bytes; ZArenaReset/ZArenaAlloc/ZArenaFree, 16-byte block
headers), and each homepage routine resets the arena just before allocating, so the
data always starts at 0x503BB810: 0x4442 bytes for .HMP (to 0x503BFC51), 0x42B6 for
the BMP (to 0x503BFAC5). MAME confirmed 0x503BB810 on the boot path that reprograms
the default homepage BMP (`arena_verify.lua`). 0x42B6 = 54 + 1024 + 160 x 100, the
largest 160 x 100 BMP the manual allows; 0x4442 = the 0x18C-byte 'JK' settings record
+ that BMP, a byte image of the custom-flash blob at 0x96811000 (the factory
04HPGINI.HMP is 17,474 bytes).

## Above 0x502B8000

| range                  | use                                                                         |
|------------------------|-----------------------------------------------------------------------------|
| 0x502B8000..0x5037FFFF | INSTALL_SCRATCH: shared, short-lived users that never run together (below)  |
| 0x50380000..0x50387FFF | RTOS system area                                                            |
| 0x50388000..0x503BBFFF | RTOS memory pool, task stacks (about 0x23860 bytes used after boot in MAME) |
| 0x503BB800..0x503FFDBF | zlib arena (overlaps the RTOS pool's configured tail by 0x800 bytes)        |
| 0x503FFDC0..0x503FFFFF | no reference found                                                          |

Users of INSTALL_SCRATCH: the .AST custom-data install ({0x502B8000, 0xC0000}), the
PICTURE LOAD import (file 0x502B8000..0x503057FF, JPEG crop buffer 0x50305800..
0x50375FFF), the built-in feature-demo pool 0x502B8000..0x502BFFFF and the FEATURE
demo 0x502C0000..0x5037FFFF, the SD-SOUND lists (memset 0x89E00), the style-convert
screens, the file-copy bounce buffer (0x4000-byte chunks), CmpConvLoad (0x25800
bytes), the debug BITMAP LOAD (0x18000 bytes), the song-page gather buffer, and the
custom-flash directory edit buffer 0x5037A000..0x5037FFFF.

## Top level

| start      | end (excl.) | size     | reset treatment                 | what                                                                                    |
|------------|-------------|----------|---------------------------------|-----------------------------------------------------------------------------------------|
| 0x50000000 | 0x50000010  | 0x10     | stubs written via 0x90000000    | two jump stubs, a spare u16, the RAM-init marker u16 (note 1)                           |
| 0x50000010 | 0x50007F44  | 0x7F34   | copied from ROM 0x487B0B78      | .data (initialised globals)                                                             |
| 0x50007F44 | 0x50180000  | 0x1780BC | zeroed (0x48410027..0x4841003C) | .bss: firmware globals, buffers, frame buffers, boot stack; unused tail from 0x501749E8 |
| 0x50180000 | 0x50298000  | 0x118000 | never cleared                   | user memory: composer styles, songs, pads, slideshow pictures                           |
| 0x50298000 | 0x502B8000  | 0x20000  | zeroed (0x4841003E..0x48410053) | unused in 941 (SD plug-in RAM in 942)                                                   |

## Detailed map

| start      | end (excl.) | size    | what                                                                                           | evidence (CPU addresses)                                                       |
|------------|-------------|---------|------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| 0x50000000 | 0x50000006  | 0x6     | Jump stub `nop; jmp 0x4C03DE26` (LibIrqScheduler)                                              | written via 0x90000000 at 0x48410070..0x48410096                               |
| 0x50000006 | 0x5000000C  | 0x6     | Jump stub `nop; jmp 0x484D77CF` (= ROM jmp at 0x4840000A)                                      | 0x484100CE..0x484100F4                                                         |
| 0x5000000C | 0x5000000E  | 0x2     | Spare u16 of the 16-byte reserved header: no reference in any build                            | ramgui_ramrefs.py over 941, 942 + plug-in, 935, 893                            |
| 0x5000000E | 0x50000010  | 0x2     | RAM-init marker u16 (RamInitMarker): 0x5AA5 across the power-on factory-reset restart (note 1) | `0x9000000e`: read 0x484D76A6, set 0x484D76FD, cleared 0x484D7306 / 0x484D77F5 |
| 0x50000010 | 0x50007F44  | 0x7F34  | .data: initialised globals of every module (see note 2)                                        | copy loop 0x48410055..0x4841006E (len 0x7F34)                                  |
| 0x50007F44 | 0x50008698  | 0x754   | DSP-host vars, tone-generator (TG) globals, drum key-off scratch                               | .bss start 0x48410031; lib 0x4C00BF2A                                          |
| 0x50008698 | 0x50009930  | 0x1298  | TG drawbar tone records, 34 parts x 0x8C                                                       | lib 0x4C00A1F9..0x4C00A20E                                                     |
| 0x50009930 | 0x50009F70  | 0x640   | TG drawbar / key-off / EG-ramp scratch                                                         | lib 0x4C00A491, 0x4C01176F                                                     |
| 0x50009F70 | 0x5000B208  | 0x1298  | TG element-map scratch, 34 x 0x8C                                                              | lib 0x4C0386C0..0x4C0386C8                                                     |
| 0x5000B208 | 0x5000B7E4  | 0x5DC   | TG voice-allocator scratch                                                                     | lib 0x4C03AE49, 0x4C03AA86                                                     |
| 0x5000B7E4 | 0x50014808  | 0x9024  | 9 library message queues x 0x1004                                                              | lib 0x4C01D1B8..0x4C01D216                                                     |
| 0x50014808 | 0x50016030  | 0x1828  | Library message-engine globals                                                                 | lib 0x4C01D5FB and neighbours                                                  |
| 0x50016030 | 0x5001EC50  | 0x8C20  | 4 library FIFOs (0x50016030, then 3 x 0x2408)                                                  | lib 0x4C02458C, 0x4C0245E8                                                     |
| 0x5001EC50 | 0x500214F0  | 0x28A0  | 8 MIDI receive byte FIFOs + descriptors                                                        | lib 0x4C024BED..0x4C024CB2                                                     |
| 0x500214F0 | 0x500214F8  | 0x8     | Library vars 0x500214F0/F2/F4/F6                                                               | lib 0x4C02B979                                                                 |
| 0x500214F8 | 0x50021CF8  | 0x800   | Boot (pre-kernel) stack, 0x800 bytes, top = INITIAL_SP (note 1)                                | SP set 0x4840FFF9; replaced at 0x487B8FA4; 0x800 in all four builds            |
| 0x50021CF8 | 0x50021F8C  | 0x294   | 10 records x 0x42 (RAM twin of SRAM 0x840301B8 + n*0x42)                                       | func_48412C25 0x48412C3C..0x48412C55; count from the gap                       |
| 0x50021F8C | 0x50022004  | 0x78    | Panel LED / index-switch state                                                                 | 0x48416515..0x48416587                                                         |
| 0x50022004 | 0x5002A004  | 0x8000  | Malloc arena, 32 KB                                                                            | .data 0x500006E0/E4; Malloc 0x48416625                                         |
| 0x5002A004 | 0x5002A034  | 0x30    | Malloc lock id, graphics globals (draw enable 0x5002A01C)                                      | 0x484165D0, InitializeGraphics_entry                                           |
| 0x5002A034 | 0x5002C034  | 0x2000  | Draw-record arena, 8 KB, circular                                                              | DrawQueue_Alloc, cmp 0x2000 at 0x48421B74                                      |
| 0x5002C034 | 0x5002C044  | 0x10    | Draw-arena cursors and flags                                                                   | 0x48421A4F, 0x48421A55                                                         |
| 0x5002C044 | 0x5003148C  | 0x5448  | Message buffers of the 4 GUI-task queues (slot table 0x5000757C)                               | .data slot words 0x500075A8..0x50007658                                        |
| 0x5003148C | 0x50031490  | 0x4     | Title control u16                                                                              | MainTitleControl 0x4842B781                                                    |
| 0x50031490 | 0x50031890  | 0x400   | CLUT, 256 x u32                                                                                | SetPaletteRGB 0x4842DB18, GetPaletteRGB 0x4842DB25                             |
| 0x50031890 | 0x50031A64  | 0x1D4   | Resource / text-layout vars                                                                    | 0x4842DCF5, 0x48431697                                                         |
| 0x50031A64 | 0x50031C64  | 0x200   | Mode object table (class 0xE, 0x20 entries)                                                    | RegisterObjectTable at 0x4843179E                                              |
| 0x50031C64 | 0x50033F64  | 0x2300  | Title object table (class 0xF, 0x140 entries)                                                  | RegisterObjectTable at 0x484317C4                                              |
| 0x50033F64 | 0x50034B64  | 0xC00   | Panel-function subscription queue, easy-set records                                            | 0x48431894                                                                     |
| 0x50034B64 | 0x5003A5BC  | 0x5A58  | Rhythm/style name module, style-ID queues, pattern player                                      | StyleIdQueueDequeue, StyleBuiltinNameResolve                                   |
| 0x5003A5BC | 0x5003D308  | 0x2D4C  | Chord detection and accompaniment control                                                      | GetChordToneList                                                               |
| 0x5003D308 | 0x5003D36C  | 0x64    | Sequencer play vars (0x5003D34C = demo page base)                                              | 0x4845740A, 0x484563FC                                                         |
| 0x5003D36C | 0x50046B6C  | 0x9800  | Built-in demo song event pages (note 3)                                                        | 0x484573CE..0x484573DE; note 3                                                 |
| 0x50046B6C | 0x5004A5FC  | 0x3A90  | Save copy of PANEL MEMORY bank 1 (note 4)                                                      | 0x4845742B..0x48457466; note 4                                                 |
| 0x5004A5FC | 0x5004A76C  | 0x170   | Slack of the 0x3C00 slot: the copy length is the constant 0x3A90 (note 4)                      | no reference in any build; func_4C021ADE                                       |
| 0x5004A76C | 0x5004FB68  | 0x53FC  | Sequencer engine, disk-job, Techni-Chord and style-converter vars                              | 0x4845A..0x4846D code, MainStylCnvFunc                                         |
| 0x5004FB68 | 0x5005FB68  | 0x10000 | Custom-flash 64 KB sector read-modify-write buffer                                             | func_4847F8A8_entry: 0x4847F91D, 0x4847F939, 0x4847F95A                        |
| 0x5005FB68 | 0x500615F4  | 0x1A8C  | Custom-data / flash module state and buffers                                                   | 0x48481F4E, 0x48482076, 0x484821A1                                             |
| 0x500615F4 | 0x50061604  | 0x10    | 16-byte block zeroed before the record scan                                                    | DpSmf1ReaderTask: 0x48482623..0x48482634                                       |
| 0x50061604 | 0x5006A984  | 0x9380  | Record table, stride 0x49C (note 5)                                                            | func_4848275F_entry: base 0x4848278C, add 0x49C at 0x484828D3                  |
| 0x5006A984 | 0x5006B4E4  | 0xB60   | Loader flag/handle, custom-data vars, MEMO LOG text                                            | func_48482725, DbMemoProc                                                      |
| 0x5006B4E4 | 0x5006CEF0  | 0x1A0C  | UI screen vars, panel serial, MIDI settings (note 10)                                          | DbBitmapFileProc, 0x484970B2                                                   |
| 0x5006CEF0 | 0x500712D0  | 0x43E0  | Step/app-event buffers, load/save screens, fmm file layer                                      | fmmformat, SingleLoadModeFunc                                                  |
| 0x500712D0 | 0x500812D0  | 0x10000 | 64 KB compressed-file stream buffer (0x78 0x9C + 0xFFFE file bytes)                            | 0x485330EB..0x4853310E, 0x4853363A..0x4853365D                                 |
| 0x500812D0 | 0x50083D72  | 0x2AA2  | Stream state, edit vars, SMF load/save, SD-card state                                          | LoadSmf, SaveSmf, AcStepRecBoxProc                                             |
| 0x50083D72 | 0x50091392  | 0xD620  | SD directory / favourites block (RAM working copy, 0xD620)                                     | FavFormat 0x4855EC37..0x4855EC7A; 0xD620 at 0x4855EB9E                         |
| 0x50091392 | 0x500934F5  | 0x2163  | SD bank / playlist vars                                                                        | SdSndListEntryCountGet                                                         |
| 0x500934F5 | 0x5009CEBC  | 0x99C7  | SD sound / audio list buffers (0x3E70 + 0x7CE + 0x5388)                                        | func_4857BE94_entry: 0x4857BE9E..0x4857BEC9                                    |
| 0x5009CEBC | 0x5009E724  | 0x1868  | Slideshow screens: image-name list (60 x 0x50), vars                                           | AcSswImgListProc                                                               |
| 0x5009E724 | 0x500A04C4  | 0x1DA0  | DSP host: DMA interface, parameter blocks, effect select                                       | DspManagerInit 0x48405E7B..0x48405F2D                                          |
| 0x500A04C4 | 0x500AD37C  | 0xCEB8  | 10 DSP unit state structs x 0x14AC                                                             | DspManagerInit 0x48405E2E..0x48405E6C                                          |
| 0x500AD37C | 0x500AD5A8  | 0x22C   | errno, sound-command stream ring                                                               | SndCmdStreamWrite                                                              |
| 0x500AD5A8 | 0x500D28AC  | 0x25304 | Tone-generator driver tables (library), note 6                                                 | lib TG code; see note 6                                                        |
| 0x500D28AC | 0x500D2B10  | 0x264   | Library table (loop bound 0x500D2B10)                                                          | lib 0x4C01D5FB, 0x4C01F880..0x4C01F8C2                                         |
| 0x500D2B10 | 0x500D35B8  | 0xAA8   | RAM copy of custom-flash settings 0x96804000..0x96804AA4                                       | lib 0x4C024033 (jump table 0x4858D794), 0x4C02404D..                           |
| 0x500D35B8 | 0x500D407C  | 0xAC4   | Library/kernel vars (ms counter 0x500D3C58), focus ids, GroupBox table                         | KernelTickHandler 0x4C02BB0A, func_484141DB_entry, GroupBoxProc                |
| 0x500D407C | 0x500D4080  | 0x4     | Pointer to picture plane 2                                                                     | 0x4842181A..0x48421820                                                         |
| 0x500D4080 | 0x500F9880  | 0x25800 | Frame buffer, 640 x 240 x 8 bpp                                                                | 0x4842182B, 0x4842183F; LcdOut 0x48414D71                                      |
| 0x500F9880 | 0x5011F080  | 0x25800 | PICTURE_PLANE2, 640 x 240                                                                      | LcdOut 0x48414D7A                                                              |
| 0x5011F080 | 0x5011F480  | 0x400   | WPAL1 (942's firmware name), 1 KB; no reference in 941/935/893                                 | 942: GetWPAL1Addr 0x48585C8C (plug-in export)                                  |
| 0x5011F480 | 0x5011F880  | 0x400   | WPAL2 (942's firmware name), 1 KB; no reference in 941/935/893                                 | 942: GetWPAL2Addr 0x48585C95 (plug-in export)                                  |
| 0x5011F880 | 0x5011FAAC  | 0x22C   | Draw-ring, change-rectangle, AP-timer vars                                                     | 0x48421A28..0x48421A43, DrawRing_Post                                          |
| 0x5011FAAC | 0x50122AAC  | 0x3000  | Object/class registry, 0x300 x 0x10                                                            | 0x4842949F..0x484294A6                                                         |
| 0x50122AAC | 0x50122CAC  | 0x200   | RGB565 palette, 256 x u16 (used by LcdOut)                                                     | 0x48414DA4                                                                     |
| 0x50122CAC | 0x50122E28  | 0x17C   | Colour-mode palette, font table pointer, style view                                            | kn7000_manual.sym                                                              |
| 0x50122E28 | 0x50148628  | 0x25800 | Backup of MEM_STYLE_AREA, taken before a style conversion                                      | 0x4847A6E8, 0x48437EC3 (copy), 0x48437EDE (restore)                            |
| 0x50148628 | 0x50149628  | 0x1000  | Rhythm pattern-scan tables, 2 x 0x800                                                          | memset 0x800 at 0x4843301A, 0x48439439                                         |
| 0x50149628 | 0x50149850  | 0x228   | Tempo / clock blocks, MIDI sync, VFS vars                                                      | .data 0x50007A40 = 0x50149730                                                  |
| 0x50149850 | 0x5014AD68  | 0x1518  | VFS file control blocks, 10 x 0x21C                                                            | func_4846E0D5_entry 0x4846E0EB..0x4846E13C                                     |
| 0x5014AD68 | 0x5014DFE0  | 0x3278  | Floppy/VFS find state, directory buffers (0x1C00 at 0x5014AD70, ...)                           | _findfirst/_findnext                                                           |
| 0x5014DFE0 | 0x50150A34  | 0x2A54  | Style-converter buffer (0x2800) and vars                                                       | StylCnvModlTtlFunc                                                             |
| 0x50150A34 | 0x501523E4  | 0x19B0  | Panel LED shadows, MIDI serial state, 2 ms time base, lyrics vars                              | PanelEventPost, MidiSerialInit                                                 |
| 0x501523E4 | 0x501605F4  | 0xE210  | LZSS encoder trees, N = 0x2000 (window, dad, lson, rson)                                       | InitTree 0x4853397B..0x485339A3; 0x485339AB                                    |
| 0x501605F4 | 0x501605F8  | 0x4     | LZSS match position / length                                                                   | 0x48533A90, 0x485339E2                                                         |
| 0x501605F8 | 0x50160608  | 0x10    | Second-allocator sentinel (arena 0x503BB800, note 9)                                           | 0x485340BE..0x48534111                                                         |
| 0x50160608 | 0x50160E98  | 0x890   | Sequencer edit vars, SD/disk driver state 0x50160644, playlist header                          | AcStepRecBoxProc, DiskInit, SdWorkerCmdHandler                                 |
| 0x50160E98 | 0x50172A50  | 0x11BB8 | SD playlist / audio-list database                                                              | SdPlaylistDbClear 0x4854CB1B..0x4854CBB3                                       |
| 0x50172A50 | 0x5017317C  | 0x72C   | Slideshow / third-backend vars (pool header ptr 0x50172C90)                                    | 0x4857F0B5, 0x4857F154                                                         |
| 0x5017317C | 0x5017397C  | 0x800   | 2 KB read buffer of the third fmm backend                                                      | 0x48584185, 0x48584265, 0x4858428F                                             |
| 0x5017397C | 0x50174868  | 0xEEC   | JPEG decoder state and Huffman tables                                                          | func_4840D3FD_entry, func_4840D7B5_entry                                       |
| 0x50174868 | 0x501749E8  | 0x180   | JPEG 8x8 sample blocks, 6 x 0x40                                                               | ROM table 0x487390C0..0x487390EC; 0x48486123                                   |
| 0x501749E8 | 0x50180000  | 0xB618  | Unused .bss tail: .bss ends at the fixed 0x50180000 in every build                             | no reference in any build; no MAME boot write                                  |
| 0x50180000 | 0x501A5800  | 0x25800 | MEM_STYLE_AREA: COMPOSER (MEMORY) styles, 'TCMP' container                                     | 0x4843B160..0x4843B16E, 0x484355C8, 0x4843A59D..0x4843A5A5                     |
| 0x501A5800 | 0x501AB9A0  | 0x61A0  | 11 song records x 0x8E0                                                                        | Rec8E0TablePtr 0x48456E49..0x48456E5D                                          |
| 0x501AB9A0 | 0x501F91A0  | 0x4D800 | Song event-page store, 0x4D8 pages x 0x100                                                     | 0x4845641B..0x48456425, 0x48456E94..0x48456EA2                                 |
| 0x501F91A0 | 0x502031A0  | 0xA000  | PERFORMANCE PAD user memory, 'TPAD' container                                                  | 0x4843217A..0x484321C2; 0x48437C5C..0x48437C69                                 |
| 0x502031A0 | 0x50297FFC  | 0x94E5C | Slideshow picture pool (note 7)                                                                | 0x4857F0C1..0x4857F147                                                         |
| 0x50297FFC | 0x50298000  | 0x4     | Unused: the pool size is 0x50297FFC - base, and a block may end there (note 7)                 | 0x4857F0E8, 0x4857F104; SswPoolAlloc 0x4857EF6F                                |
| 0x50298000 | 0x502B8000  | 0x20000 | Unreferenced in 941, zeroed at reset (942: plug-in RAM, note 8)                                | clear 0x4841003E..0x48410053 only                                              |

## Notes

**1. How reset sets RAM up** (read from 0x4840FF7E..0x48410156):
- SP is set to 0x50021CF8 (0x4840FFF9). The boot stack below it is 0x800 bytes: in all four builds the last library variable below INITIAL_SP ends exactly 0x800 bytes under it (941 0x500214F6 / INITIAL_SP 0x50021CF8, 942 0x50021506 / 0x50021D08, 935 0x500214CA / 0x50021CCC, 893 0x500214C6 / 0x50021CC8), while the variables around it move by -0x30..+0x10 (`ramgui_ramrefs.py`). 0x50021CF8 is also the base of the 10 x 0x42 records above it (`add INITIAL_SP, a0` in func_48412C25).
- `.bss` 0x50007F44..0x50180000 is zeroed (0x48410027..0x4841003C).
- 0x50298000..0x50400000 is zeroed (0x4841003E..0x48410053). This covers INSTALL_SCRATCH and the RTOS area.
- `.data` is copied (0x48410055..0x4841006E).
- The two stubs are written through 0x90000000 (0x48410070..0x484100F4). 0x50000000..0x5000000F is a reserved header in every build: `.data` starts at 0x50000010 in 941, 942, 935 and 893 although its length (0x7F34 / 0x7F44 / 0x7F34 / 0x7F30) is no multiple of 16 and `.bss` follows it unaligned, so the 16 bytes are not section alignment. Its last u16, 0x5000000E (`0x9000000e`), is the **RAM-init marker**: at the start of TickJobsTask, func_484D72AA asks the panel for its power-on state (PanelSignOnRequest, PanelTypeDetect -> 0x5006CC82) and calls func_484D76A1. When the marker is not 0x5AA5 and the state is 1 or 6 (6 first reprograms the custom-flash settings 0x96804000 from ROM, func_4C023F80; 1 keeps a few, func_4C023F9B), it disables interrupts, zeroes work RAM 0x90000010..0x903FFFFF (0x484D76D9) and battery SRAM 0x84000010..0x8403FFFF, writes 0x5AA5 (0x484D76FD) and calls func_4840FFF9 (0x484D7709) (SP setup, clears, .data copy). The second pass finds 0x5AA5, skips the wipe, and func_484D72AA clears the marker to 0 (0x484D7306); the second stub's target func_484D77CF clears it too. That is the owner's manual's power-on reset ("while pressing the three lower left buttons in the RHYTHM GROUP section ... all programmable settings, functions and memories return to their factory-preset status"); which of the codes 1 and 6 is that combination was not traced. The wipe also clears 0x50180000..0x50297FFF (songs, styles, pads, pictures).
- The block loader 0x484D7A40 copies only the library image to 0x4C000000 and 3 bytes to 0x4C03FFF0. Nothing else is copied into work RAM.
- The kernel then switches SP to 0x50381408 (0x487B8FA4). Task stacks come from the RTOS pool 0x50388000..0x503BBFFF (lib 0x4C03D1DC -> 0x4C03CC89).

**Retention.** 0x50180000..0x50298000 is never cleared by a reset; only the power-on factory reset (note 1) wipes it. Its owners validate their data and load factory data only when the check fails (pads: 0x48437C70 chooses 0x484321D4 or MemPadAreaLoadFactory_entry, 0x4843217A). The service manual lists SEQUENCER, COMPOSER (MEMORY contents) and PERFORMANCE PADS as kept "about 80 minutes" (service manual, memory-backup table). That matches song records and pages, 'TCMP' and 'TPAD'; the DRAM mechanism is inferred. RAM is 4 MB: the clear ends at 0x50400000, and the parts list has IC12/IC13 as two 16-Mbit DRAMs (service manual parts list).

**2. `.data` contents** (ROM image 0x487B0B78; values printed by `notes/work-ram-map-probes/rom_facts.py`):
- Malloc control 0x500006E0..0x500006EB: cursor 0x50022004, remaining 0x8000, free list.
- The 4 GUI-task queue slots at 0x5000757C (0x38 bytes each). Their buffer pointers run from 0x5002C044 to 0x50031474.
- The demo-song stream tables 0x50000C20, 0x50000C50 and 0x50000C80.
- Pointer words: 0x500058B8 = 0x502B8000, 0x50007A40 = 0x50149730, 0x50007DC0 = 0x50060DA4.
- The finer split of `.data` into module variables is not in this note; `work-ram-map-probes/scan_ramrefs.py` produces the reference census it can be built from.

**3. Built-in demo song** (0x484573A4..0x48457403):
- 0x4853375D is zlib 1.0.4 `uncompress`. It calls inflateInit with version string 0x48664864 and inflate with Z_FINISH, and expects Z_STREAM_END.
- For demo n (clamped to 1..12 at 0x48457393), it inflates three ROM streams:
  - into song record 0 (0x501A5800, 0x8E0 bytes);
  - into 0x5003D36C (0x9800 bytes = 0x98 pages of 0x100);
  - into battery SRAM 0x84000824 (0x3A90 bytes).
- It then stores 0x5003D36C in 0x5003D34C. The page accessor uses that base instead of 0x501AB9A0 when the mode byte is 3 (0x484563F2..0x4845640E).

**4. 0x50046B6C**:
- 0x48457426 does memcpy(0x50046B6C, 0x84000824, 0x3A90), and 0x4845744B copies it back. The pointer and length come from lib 0x4C021A4E and 0x4C021ADE.
- 0x84000824 + 0x3A90 is PANEL MEMORY bank 1 in the battery SRAM (0x10 + 8 x 0x750; kn7000_manual.sym ~2426).
- The sequencer saves it at 0x48545FCE and restores it at 0x48546191 / 0x485462D8. Inferred: this keeps the user's bank 1 while a demo's own bank is loaded there.
- The slot is 0x3C00 bytes; its last 0x170 bytes are slack. In all four builds the copy length comes from a library getter that returns the constant 0x3A90 (941/935 func_4C021ADE, 942 func_4C021B38, 893 func_4C021AC9), the only references to the slot are the two memcpy calls (slot 0x50046B6C in 941/935, 0x50046B7C in 942, 0x50046B68 in 893), and the next referenced address is the slot + 0x3C00 (`ramgui_ramrefs.py`). [INFERENCE] 0x3C00 is 0x3A90 rounded up to 1 KiB, like the 0x9800 demo-page buffer just below it.

**5. Record table 0x50061604**:
- Records are 0x49C bytes (0x4848278C, 0x484828D3, 0x48482979). They are read by the VFS block read 0x4846DA31 from handle 0x5006A988, which is opened at 0x4848335C (VFS open 0x4846D800, "rb", name/config buffer 0x50060DA4).
- The count is the u16 at 0x50007BA2, taken from big-endian header bytes (0x4847FF9B..0x4847FFBD, 0x48481D80..0x48481D8F). No clamp was found in the code read.
- 32 x 0x49C = 0x9380 fills the span exactly, so 32 is the implied maximum (inferred).
- Which file this is: unknown.

**6. Tone-generator tables** (library), each from 0x500AD5A8:
- 34 x 0x10C glide/repeat-note state;
- 128 x 0xB4 voice records (0x500AF940);
- 34 x 0x54C part records (0x500B5340);
- master globals (0x500C0758) and SOUND EDIT records;
- 128 x 0x8E local-edit shadows (0x500C1183);
- 128 x 0x84 register shadows (0x500CA0B0);
- the TG-enable gate (0x500CE380);
- 34 x 0x130 part tone blocks (0x500CE404);
- voice-allocator lists and masks (0x500D0C64..0x500D28AC).

Each gap between referenced bases equals count x stride. The strides come from the code and from kn7000_manual.sym.

**7. Slideshow pool**:
- Size: TgStrapProbe (0x484D7713) returns 1 only when bits 0x02 and 0x04 of 0x98070000 are both set; it returns 2 when 0x04 is clear and 3 when 0x02 is clear (no TG). With 1, the test at 0x4857F0CD..0x4857F0DF is constant-false and the pool gets the full 0x94E5C bytes (0x4857F0FD). Any other value takes 0x4857F0E1, which subtracts 0x40000: the pool is then 0x54E5C bytes and ends at 0x50257FFC.
- Init 0x4857F116 zeroes the pool and writes a header at the base: +8 base, +0xC size, +0x10/+0x18 heap start = base + 0xDF0, +0x14/+0x1C free bytes.
- The 4 bytes 0x50297FFC..0x50297FFF: SswPoolMainInit computes the size as 0x50297FFC - 0x502031A0 (0x4857F0E8 / 0x4857F104, minus 0x40000 on the short path), SswPoolInit stores it unchanged, and SswPoolAlloc refuses a block only when round4(n) + 4 > free bytes (`bhi`), so a block can end exactly at 0x50297FFC and nothing reads or writes past it. The same constant is in 942, 935 and 893; 942's plug-in RAM starts at 0x50298000. [INFERENCE] the constant names the last u32 of the area and is used as an exclusive end.
- It runs through the wrappers 0x4857EDAA, 0x4857EE02 and 0x4857EE8D (callers include 0x484579AE and 0x4851E2A8). Whether it runs at power-on, and so whether pictures survive a power cycle, is unknown. The service manual's retention list does not mention pictures.

**8. 0x50298000..0x502B8000**:
- In 941 its only reference is the reset clear. A raw scan of both 941 ROMs found 106 words with values in this range. Only 0x4841004A is a decoded operand. The other 105 are 21 instruction overlaps, 22 data bytes in the program data area and 62 in the table ROM; none forms a pointer table.
- The 40 s idle MAME boot made no writes there (ramboot log).
- Program 942 clears the same span at reset. Its resident plug-in then copies its `.data` to 0x50298000..0x50299498 and clears `.bss` to 0x50299EE0 (table.s func_483E803E). It loads BASEEXT.XAP, at most 0x1D000 bytes, at 0x5029B000; 0x5029B000 + 0x1D000 = 0x502B8000 exactly.

**9. Second allocator**:
- The sentinel is in `.bss` at 0x501605F8. The arena is 0x503BB800, 0x445C0 bytes, so it lies above the asked range.
- Allocation is first fit and returns block + 0x10.
- uncompress, the .HMP load and the homepage BMP load each re-initialise the arena first. Their buffers therefore start at 0x503BB810: 0x4442 bytes for .HMP, 0x42B6 for the BMP.
- The arena overlaps the RTOS pool tail 0x503BB800..0x503BBFFF.

**10. UI variables used by the other questions**:
- 0x5006B52C: BITMAP LOAD index.
- 0x5006B52E: BITMAP LOAD file name.
- 0x5006B5F8: homepage settings record (0x18C bytes).
- 0x5006B798: .HMP buffer pointer (written at 0x484970B2).

**11. Read versus named.** The verifier re-read the boot code, the allocators, every buffer bound and the TG, DSP, LZSS, zlib, JPEG, pool, MEM_STYLE, TPAD and song code cited above. For the small variable clusters, the owner is named only from the functions that reference them; both lanes agree on those names. The two lanes' censuses match: 4130 vs 4129 addresses, differing only at 0x5004AD64.

## Spans that remain unexplained

| start      | end (excl.) | size    | what is known                                                                                                                                                                                |
|------------|-------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x5000000C | 0x50000010  | 0x4     | after the two stubs; no MAME boot write (Resolved 2026-11-02: 0x5000000E is the RAM-init marker u16, note 1; 0x5000000C is a spare u16 nothing references in any build.)                     |
| 0x500214F8 | 0x50021CF8  | 0x800   | boot stack by position below INITIAL_SP; MAME deepest write 0x50021C98 (Resolved 2026-11-02: 0x800 bytes in all four builds, note 1.)                                                        |
| 0x5004A5FC | 0x5004A76C  | 0x170   | tail of the 0x3C00 slot holding the 0x3A90 PANEL MEMORY copy (Resolved 2026-11-02: slot slack, note 4.)                                                                                      |
| 0x5011F080 | 0x5011F880  | 0x800   | after PICTURE_PLANE2; no MAME boot write (Resolved 2026-11-02: WPAL1 and WPAL2, 2 x 0x400, named by 942's plug-in exports GetWPAL1Addr / GetWPAL2Addr; unreferenced in 941, 935, 893.)       |
| 0x501749E8 | 0x50180000  | 0xB618  | end of .bss after the JPEG blocks; no MAME boot write (Resolved 2026-11-02: unused .bss tail; no reference, constant or data pointer in any build or the plug-in.)                           |
| 0x50297FFC | 0x50298000  | 0x4     | past the pool end constant; no MAME boot write (Resolved 2026-11-02: unused, note 7; same constant in all four builds.)                                                                      |
| 0x50298000 | 0x502B8000  | 0x20000 | only the reset clear touches it in 941; no MAME boot write (Resolved: note 8, program 942's plug-in .data / .bss and BASEEXT.XAP at 0x5029B000..0x502B8000; open-items register 2026-10-31.) |

"No MAME boot write" covers only a 40 s idle boot. SD, slideshow, demo and install paths were not exercised at runtime.

## Open questions

- Which value TgStrapProbe returns on real hardware (main pool 0x94E5C or 0x54E5C
  bytes); read the u32 at 0x502031AC on a v1.6 unit.
- Whether 0x50180000..0x50297FFF (songs, styles, pads, pictures) survives power-off
  for the "about 80 minutes" the service manual gives for the sequencer data; the RAM
  is DRAM, so the mechanism is not visible in the code.
- What keeps the keyboard silent for the whole time the PICTURE LOAD screen is shown
  (only the open-time All Notes Off was traced). Excluded on 2026-11-02: the open-time DiskCmdTransact(0x14) only sets the disk phase 3 (SdDrvPhaseSet, 0x50160648), which makes DiskCmdPostAsync refuse (0x8002); SetExtMode / ResetExtMode select the fmm backend (0x5007125A); SDModuleModeReq(0, 0) at close drives the SD-audio module. The owner's manual (SD card chapter) lists the same silence for LOAD (TECH) PAGE 3, SD SONG MEDLEY, COPY FROM DISK and SD-SOUND EXPORT/IMPORT. (OPEN, lane kn7000-names 2026-11-06.) The key path is now traced statically, end to end:
  the key-bed FIFO TGA_KEY_FIFO 0x98050004 is read by func_48448077 (one {key, velocity} word; key bit 7 = break)
  under func_48447FCD, which turns it into M3 message 0x10700000 with data key | velocity << 8. TickJobsTask polls it
  on every pass (`call func_4C014E41` at 0x4C02BD80, unconditionally; func_4C014E41 loops func_48447FCD ->
  func_4C01B6DA). func_4C01B6DA sends every id with low 24 bits 0x700000 to func_48451AA7. That diverts the key to
  M3SendProcess only when func_484A3A2A is true: the service test state byte 0x5006BA20+0x1F9 is 0xF6, or it is 0xFC
  with +0x1F8 = 0xB (the factory test modes, not PICTURE LOAD). Otherwise func_484524EB routes it: func_4844FD70 gives
  kind 1 for 0x700000, the key's zone record (func_4845124C / func_4845127C) gives the part, a negative part or a
  failed slot (HeldKeyListUpdate, 64 held-key slots of 6 bytes at 0x5003AC4C) drops it, and func_4844FAF1 posts the
  part's note to func_4C024DD8, the M3 -> TG translator, whose note case calls func_4C029793 (status 0x90..0x94 by
  source) -> TgcBufWrite; the library's SndCmdStreamInterpret (0x4C003B2C) hands status 0x9n to TgPartKeyEvent.
  TgcBufWrite itself has no gate (it only waits for ring space). `work-ram-map-probes/picload_key_gate.py` intersects
  the absolute work-RAM operands the key path reads (878 functions to depth 8; 336 addresses) with those written by
  everything the two PICTURE LOAD procedures call to depth 3 (193 functions; 104 addresses): 19 in common, and none
  is a gate. They are the allocator (0x500006E0..E8), the chord detector the open-time All Notes Off resets
  (0x50000B0F..B3C, func_4844DA79), 0x50000C10 / 0x50000CE8 (read-modify-write inside one routine), the index
  switch refresh (0x50021FD8..E0) and sequencer / tempo state (0x50149662..96). The test-mode setters
  (func_4849FBC3 / func_4849FBF6) are not reachable from either procedure even at depth 6. So no direct-address
  flag set by PICTURE LOAD stops the key before the TG command stream. What is left: indexed state (the per-part
  records at 0x500B5340 + part*0x54C, whose +0x1D byte TgLevelResolve reads as muted / solo; the zone records), state
  changed through messages the probe does not follow (ApPostEvent / SendEvent to DiskWaitWin and the parent
  window), or something after the TG (the audio path). Next step, in MAME: open PICTURE LOAD, hold a key, and
  break on func_4C029793 (0x4C029793) and TgcBufWrite (0x4C003A60). If a {0x9n, part, key, velocity} message
  reaches TgcBufWrite, the gate is in the TG library or the audio path (then tap TgPartKeyEvent 0x4C036E9E and
  TgLevelResolve 0x4C02FBDE's result); if not, step func_484524EB for the test that returns.
  **Run in MAME 2026-11-06 (lane kn7000-research; observed in emulation, not on hardware;
  `picload-silence-probes/README.md`):** with SD PICTURE LOAD opened the manual's way (PICTURE LIST ->
  PICTURE LOAD, the firmware's own `InterruptTitle(0x12B)`), a held key goes through every routine above,
  TgcNoteOnSend and TgcBufWrite included (`04 90 10 3c 42` note on, RIGHT1), the tone generators get the
  same 118 register writes as on the home screen, and the captured audio is as loud (RMS 322.5 against
  321.2).  Opening the screen writes no DSP port and no TG register but the idle FC08..FC0B; it moves
  only GPIO 0x36008004 bit 1 (the SD chip select, the folder scan) and 0x36008024 / 0x36008064; while the
  screen stays up the I/O writes equal the PICTURE LIST's.  So no code path the emulation runs silences
  the keys; [INFERENCE] the silence comes from hardware the driver does not model.
  **Mute lines, 2026-11-06 (lane kn7000-research2; `audio-mute-probes/README.md`):** the service manual's
  MUTE line to the power amplifiers (CN506 pin 1 = +15PM, switched by the PMUT net) comes from CPU pin 148,
  P04 (0x36008004) bit 2; the speaker / headphone switch SPSW and the D/A converter's mode port are bits of
  the latch at 0x98060000.  The firmware clears PMUT only at reset and in the NMI handler (set at the end of
  `BootPanelResetCheck`), sends the D/A converter two mode words at boot only, and drives SPSW from M3 id
  0x600009; in MAME (941 and 893) none of them changes from boot through SD PICTURE LOAD and a key on it.
  So the silence is made by no mute line either.  BLOCKED on the instrument: play a key on SD PICTURE LOAD
  with a card holding pictures and note whether the sound stops for the whole screen or only while the
  card is read (the emulated card answers at once).
