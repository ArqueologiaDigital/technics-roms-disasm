# Wave 4, lane kn5000-b, sub-lane `tools` (2026-10-31)

Five tracker issues: kn5000-0bq (Feature Demo sequence and timing), kn5000-waa (slide viewer), kn5000-87m
(update-disc parser), kn5000-dkx (flash sector erase), kn5000-3ei (source-coverage figure on the website).
Base: main at 130735749.  Addresses are v10 program ROM, from `symbols/maincpu_v10_symbols_reference.txt`.

| issue      | outcome | evidence                                                                             | website draft                              |
|------------|---------|--------------------------------------------------------------------------------------|--------------------------------------------|
| kn5000-0bq | CLOSED  | this README section 1 (cue table from the 2026-10-18 note; end/loop read from code)  | feature-demo.md, section 1 below           |
| kn5000-waa | CLOSED  | `scripts/generators/render_ftdemo_slides.py` (293f4cae0)                             | feature-demo.md + image gallery, section 2 |
| kn5000-87m | CLOSED  | `scripts/analysis/parse_update_disc.py` (03e5bbcd5), probe `make_synthetic_type6.py` | system-update-discs.md, section 3          |
| kn5000-dkx | CLOSED  | this README section 4 (traced from `boot/system_handlers.s`)                         | flash-programming.md, section 4            |
| kn5000-3ei | CLOSED  | this README section 5 (`kn5000_source_coverage.py` at 130735749)                     | rom-reconstruction.md, section 5           |

"CLOSED" means the repository side is done; each tracker issue stays open until the docs lane publishes its draft.

---

## 1. kn5000-0bq -- Feature Demo sequence and timing

**What drives it.** Established on 2026-10-18 (`notes/feature-presentation-cues-2026-10-18.md`, probes in
`notes/feature-presentation-cues-probes/`): the slides are cued by the presentation's own song, demo preset 18
(`DemoSongPreset18`, Table Data ROM 0x8E0000).  Its track 14 (assigned to PART15) holds 23 panel-record writes
`B0 tick 0E 08 n 7F` that set PART15's pan to n; the change reaches `AcPresentCtrl_CheckSSFStart` (0xF84625) as
`EVT_LSW_DATA {0xB80A, n}`, which posts `EVT_ACTION(n)`, and `FDemo_ProcessDisplayStateQuery` (0xF867B2) runs the
`<ACT>` stored in slot n of the 128-entry table at RAM 0x024FD8.  There is no timer between slides: the song's
beat position is the timing.  Nothing in the cue path waits for the player (whether panel buttons other than
the exit do anything during the presentation was not traced).

**The script** (`Feature_Demo_XML`, table_data/kn5000_table_data.s) is 27 ACTs, each one `<SHOW OBJ>`; the song
cues 23 of them.  ACTs 9, 10, 11 (ftdemo46-48) and 20 (the second `Drawbar`) are never cued by the factory song.

**Start.** `MainPreControl_OnStartPresentation` (0xF86672) sets `DEMO_ACTIVE_ENTRY` to 19 and calls
`Demo_SelectEntry_ProcessSongList`; the song starts through the demo countdown (`Demo_SelectEntry_TimerTick`).

**End and loop (read from the code; not verified on hardware).** When the sequencer parts stop,
`Demo_SelectEntry_ProcessSongList` -> `Demo_SelectEntry_AfterSongLoad` (0xF86C5F) re-dispatches the entry; if the
auto-play flag (bit 3 of `DEMO_CONTROL_FLAGS`) is set and `ACTIVE_TITLE` is 0xE4, `DEMO_CURRENT_SONG` is clamped
back to 18 (to 19 while a melody is active), `Demo_SelectEntry_LoadPattern` reloads `DEMO_ACTIVE_ENTRY` from the
demo order table (`DemoSong_EntryCol`, 0xEA00AC: entries 18-22 are the five 0xE4 songs, entry 18 = demo 18) and
the countdown restarts, so the presentation song is played again.  Whether bit 3 is set during the Feature
Presentation was not traced, and the 2026-08 kn7000_mame overlay run (feature-demo.md, "Demo Timer Behavior in
MAME") stopped after one pass (about 139 s) without re-arming the countdown, so "it loops" is an inference.

### Website page draft (feature-demo.md, "How the song drives the presentation", after the first bullet)

> **The cue sheet.** The 23 cues of the factory song, with the beat (the count of `0x81` beat markers on
> track 14) and the ACT each one runs:
>
> | beat | tick | ACT | shows    | beat | tick | ACT | shows     |
> |------|------|-----|----------|------|------|-----|-----------|
> | 0    | 0x05 | 1   | ftdemo01 | 78   | 0x00 | 16  | Accordion |
> | 22   | 0x40 | 2   | ftdemo04 | 82   | 0x00 | 17  | Accordion |
> | 41   | 0x30 | 3   | ftdemo05 | 88   | 0x00 | 18  | ftdemo10  |
> | 48   | 0x00 | 4   | ftdemo41 | 94   | 0x00 | 19  | Drawbar   |
> | 49   | 0x00 | 5   | ftdemo42 | 123  | 0x00 | 21  | ftdemo20  |
> | 50   | 0x00 | 6   | ftdemo43 | 133  | 0x00 | 22  | ftdemo21  |
> | 52   | 0x00 | 7   | ftdemo44 | 138  | 0x00 | 23  | ftdemo22  |
> | 53   | 0x00 | 8   | ftdemo45 | 142  | 0x00 | 24  | ftdemo23  |
> | 55   | 0x00 | 12  | ftdemo06 | 143  | 0x00 | 25  | Sdmixer   |
> | 61   | 0x00 | 13  | ftdemo07 | 150  | 0x00 | 26  | ftdemo24  |
> | 67   | 0x00 | 14  | ftdemo08 | 156  | 0x00 | 27  | ftdemo25  |
> | 73   | 0x00 | 15  | ftdemo09 |      |      |     |           |
>
> There is no slide timer: each slide stays until the song reaches the next cue, and nothing waits for the
> player.  The drawbars of ACT 19 move at beat 104, when track 0 writes RIGHT1's drawbar record.
>
> **Start and end.** Starting the presentation sets the demo entry to 19 (`MainPreControl_OnStartPresentation`,
> 0xF86672) and runs the demo countdown, which starts the song.  When the song stops and the demo's auto-play
> flag is set, `Demo_SelectEntry_AfterSongLoad` (0xF86C5F) clamps the song index back to the presentation's
> entry on title 0xE4 and restarts the countdown, so the code reads as a loop until the player leaves the
> screen.  Not verified on hardware; the 2026-08 MAME overlay build stopped after one pass (see below).
> Rendered slides: see "Slide renders" below (kn5000-waa).

---

## 2. kn5000-waa -- slide viewer (`scripts/generators/render_ftdemo_slides.py`)

    python3 scripts/generators/render_ftdemo_slides.py [OUTDIR] [--all] [--scale N] [--wallpaper 0|1|none]

Writes `act01_ftdemo01.png` .. `act27_ftdemo25.png` (one per ACT; with `--all` also `screen_ftdemo02/03/26/40`, the
four ftdemo screens no ACT shows) and `index.txt` into OUTDIR, default `rebuilt_ROMs/ftdemo_slides/` (git-ignored).
It reads only tracked files: the NAKA GUI records (through `naka_gui_model.py`), `Feature_Demo_XML`, the system
palette `Palette_8bit_RGBA.bin`, the font sheets `table_data/images/fonts/`, the `FTBMP0n.png` and `Wallpaper_1.png`
pictures, and the captions from the tracked v10 ROM image.  Run on 2026-10-31 with `--all`: 31 PNGs (the 27 ACTs and the 4 screens; 27 without `--all`) in about 6 s.

**What the firmware does, and the tool repeats** (each traced in v10):

| step               | firmware                                                                                                                      | in the tool                      |
|--------------------|-------------------------------------------------------------------------------------------------------------------------------|----------------------------------|
| screen background  | `TtlScreenProc` (0xF9AA6D) -> `ScreenProc` -> `Screen_Paint` (0xF9A864) = `DrawWall`: the wallpaper, not the record's `color` | Wallpaper_1 (the factory one)    |
| title              | `DrawTitleBar` (0xF9AACB): white, font 4 (font 1 if it does not fit), centred in a 28-px band                                 | same; vertical placement approx. |
| Label              | `LabelProc` (0xF9C4B6): `DrawString` at (x1 + 2, y1 + 1), font = record's font id = `FontDescriptor_Table` index, bg 0xF7     | exact                            |
| strings            | `ConvertStrings` (0xFB2640): `~XX` = character 0xXX (the arrows `~85`, `~7f`), control characters -> space                    | exact                            |
| captions           | `AcLanguageText` asks its ApFunction FtLangTextNN for a 6-entry language table; entry 0 is English                            | read from the ROM image          |
| FTBMP pictures     | `DrawBitmapFile_Impl` (0xFAC6F3) + `Gfx_DecodeImageToBuffer` (0xFAED27) + `ChangePalette_Impl(3)` (0xFAF2F3), see below       | exact                            |
| Box / Line / Frame | fill + border; line by mode; outline                                                                                          | borders approx.                  |
| other classes      | (faders, mixer, drawbar organ, part mixer ...)                                                                                | dotted outline + class name      |

**How a slide picture reaches the screen** (a correction to feature-demo.md's "the 8-bit BMP palette is loaded to the
hardware palette register"): the BMP is tiled into a 320 x 240 buffer; a histogram of pixel values is taken in 16-bit
counters (they wrap); the BMP palette is comb-sorted by count, most used first (gap * 1,000,000 / 1,300,000, gaps 9
and 10 become 11); when more than 192 colours are used, ranks 192 and up are mapped to the nearest of ranks 0-191 by
squared RGB distance; ranks 0-191 become pixel values and palette entries **0x20-0xDF**; `ChangePalette_Impl` loads
only entries 0x20-0xDF.  Entries 0x00-0x1F (CL_Black, CL_Silver, CL_DarkGray, CL_Orange ...) and 0xE0-0xFF (the
wallpaper ramp and CL_Gray .. CL_White) keep their system values, so the UI colours survive a picture.

**Result.** The 27 ACT renders show every slide's layout, text and picture; compared side by side with the
images in feature-demo.md they agree in layout (screenshots from hardware were not available to compare
pixel by pixel).  `index.txt` of the run:

| ACT   | object      | widgets | picture | drawn only as an outline                               |
|-------|-------------|---------|---------|--------------------------------------------------------|
| 1     | ftdemo01    | 2       | FTBMP01 | -                                                      |
| 2     | ftdemo04    | 6       | FTBMP02 | -                                                      |
| 3     | ftdemo05    | 3       | -       | -                                                      |
| 4-6   | ftdemo41-43 | 38      | -       | -                                                      |
| 7-9   | ftdemo44-46 | 23      | -       | -                                                      |
| 10-11 | ftdemo47-48 | 21      | -       | -                                                      |
| 12    | ftdemo06    | 3       | FTBMP03 | -                                                      |
| 13    | ftdemo07    | 3       | FTBMP04 | -                                                      |
| 14    | ftdemo08    | 2       | -       | -                                                      |
| 15    | ftdemo09    | 3       | -       | -                                                      |
| 16-17 | Accordion   | 9       | -       | AcIndexEditSw, Icon, IvAccordion, IvIntVari, PsParaBox |
| 18    | ftdemo10    | 3       | -       | -                                                      |
| 19-20 | Drawbar     | 7       | -       | AcIndexToggle, IvIntVari                               |
| 21    | ftdemo20    | 4       | FTBMP05 | -                                                      |
| 22    | ftdemo21    | 2       | -       | -                                                      |
| 23    | ftdemo22    | 6       | -       | -                                                      |
| 24    | ftdemo23    | 23      | -       | Bitmap (the five transport icons)                      |
| 25    | Sdmixer     | 3       | -       | AcPartMixer, AcResetPage                               |
| 26    | ftdemo24    | 39      | -       | -                                                      |
| 27    | ftdemo25    | 2       | FTBMP06 | -                                                      |

**Limits.** The three live screens (Accordion, Drawbar, Sdmixer) are custom widget classes whose painting is not
modelled; the Bitmap icons are not looked up; borders other than plain lines are approximations (BoxProc's exact
pixels belong to kn5000-5dc); the screens without a picture show the system palette's 0x20-0xDF (on the keyboard,
whatever the last `ChangePalette` left, normally the wallpaper's: inference).  It is a viewer, not an editor: to
change a slide, edit the record in `v10/maincpu/ui_widgets/naka_perf_style.c` (the build regenerates the bytes) and
re-render.

### Website page draft (feature-demo.md, new section "Slide renders", after "Bitmap Loading Chain")

> ## Slide renders
>
> `scripts/generators/render_ftdemo_slides.py` (disassembly repository) draws each ACT of the presentation to a
> 320 x 240 PNG from the GUI records of the v10 source: the wallpaper and title bar every screen paints, the
> labels in the ROM's own fonts, the English captions, and the six FTBMP pictures with the firmware's own colour
> handling.  The live screens (Accordion, Drawbar, Sdmixer) appear with their widgets outlined.
>
> *(Docs lane: run `python3 scripts/generators/render_ftdemo_slides.py --scale 2 OUT/`, copy the 27
> `actNN_*.png` to `assets/images/ftdemo-slides/`, and add one gallery row per ACT under this heading.)*
>
> **How a slide picture is drawn.** `DrawBitmapFile_Impl` (0xFAC6F3) does not load the BMP's palette as it is.
> It counts how often each colour is used, sorts the palette most used first, folds colours past the 192nd onto
> their nearest neighbour, and loads the 192 survivors into palette entries 0x20-0xDF (`ChangePalette_Impl`,
> 0xFAF2F3, palette 3 = RAM 0x69400).  Entries 0x00-0x1F and 0xE0-0xFF keep the UI colours, so text and frames
> keep their colours over a picture.
>
> (Replace "The 8-bit BMP palette is loaded to the hardware palette register" in "Bitmap Loading Chain" step 5
> with a link to this paragraph.)

---

## 3. kn5000-87m -- update-disc parser (`scripts/analysis/parse_update_disc.py`)

    python3 scripts/analysis/parse_update_disc.py IMAGE.img [...] [--extract DIR]

It prints the FAT12 view (`floppy/tools/fat12lib.py`) and the firmware's view: `Detect_Disk_Type` (0xEF42FE) reads
logical sector 0x21 and compares 38 bytes with the eight `FILETYPE_SIG_*` strings (read from
`boot/boot_data_tables.s`); every handler reads its payload from logical sector 0x24, never by file name.  For
type 7 it decodes both SLIDE4K streams with the firmware's stop rule (`LZ_Decompress_Init` 0xEF4D95: 8 magic
bytes, 24-bit big-endian size, stop when the output reaches it; `LZSS_Decompress_ToFlash` 0xEF4CF8: the second
stream must start with "SLIDE"), prints the version byte at 0xFFFFE8, and identifies every image by SHA-1
(program v5-v10, sub-CPU v1.40-v1.42 raw and compressed, HD-AE5000 v1.10i-v2.06i).  There is no checksum on the
disc and the firmware checks none; the SHA-1 table is the tool's own identification.

**Tested on** (2026-10-31; outputs abbreviated):

| image (read-only)                                                                                    | result                                                                                                                                                                                                                                                                                                              |
|------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `~/compartilhado/kn5000_project/kn5000_v10_disk.img` (SHA-1 a892bedc...)                             | type 7; TECHNICS.PRP / DUMMY.1 / DUMMY.2 / HKMSPRG.SLD at sectors 33-36; stream 1 2,097,152 B from 965,534 compressed = program v10, version byte 0x0A; stream 2 at disc-image offset 0xF03A9 (file offset 0xEBBA9 = 965,545 in HKMSPRG.SLD, which starts at sector 36 = image offset 0x4800), 93,203 B = sub-CPU v1.42 compressed byte for byte, decompresses to sub-CPU v1.42; HKMSPRG.SLD (1,058,748 B) is exactly the two streams |
| synthetic type-6 disc (`probes/make_synthetic_type6.py`)                                             | type 6; 1024 sectors from 0x24 = HD-AE5000 v2.06i, XAPR at +0                                                                                                                                                                                                                                                       |
| `~/compartilhado/kn5000_project/test_floppy.img`, `technics-anotherworld/kn5000cnv/build/aw5000.img` | FAT listing; type 0xFF (not an update disc)                                                                                                                                                                                                                                                                         |
| the 14 softlist floppies `floppy/build/kn5000/*.img` (built in main)                                 | all type 0xFF                                                                                                                                                                                                                                                                                                       |

Only the v10 update disc is on this machine; the v5-v9 discs (archive.org "technics-kn5000-system-update-disks")
were not available to run.  Creating discs stays with `make_update_disc.py` (technics-anotherworld), which the
parser can check: a disc it builds should show stream 1 = the input image and, being single-stream, "stream 2:
none".

Observation, not chased: the website says stream 2 is written "exactly 0x20000 bytes"; the v1.42 stream is
93,203 B, so the firmware's write count (it adds 0x20000 to the size variable in `LZSS_Decompress_ToFlash`) runs
past the stream into whatever follows it on the disc.  Also, the byte reader that both routines call is named
`Parport_ReadNextByte` but reads the floppy track buffer at RAM 0x69800 (`LZ_Decompress_ReadTracks`); a rename
candidate for the naming lane.

### Website page draft (system-update-discs.md, "Creating Update Discs", new subsection before it: "Reading an update disc")

> ## Reading an update disc
>
> `scripts/analysis/parse_update_disc.py IMAGE.img` (disassembly repository) shows a disc the way the firmware
> sees it: the type `Detect_Disk_Type` returns for logical sector 33, the payload each handler reads from
> logical sector 36, and for a type-7 disc both SLIDE4K streams, the firmware version byte at 0xFFFFE8 and the
> release each image matches (by SHA-1).  `--extract DIR` writes the files and the decompressed images.
>
> On the v10 disc it reports: type 7, program v10 (version byte 0x0A), and a second stream at disc-image
> offset 0xF03A9 (offset 0xEBBA9 in `HKMSPRG.SLD`, which starts at sector 36) that is the sub-CPU v1.42 update image byte for byte; `HKMSPRG.SLD` is exactly the two streams
> (965,545 + 93,203 = 1,058,748 bytes).

---

## 4. kn5000-dkx -- flash erase

Traced in `v10/maincpu/boot/system_handlers.s` (the same routines are in v9/v7):

**Command sequence.** Both erases use the AMD/JEDEC 16-bit protocol: word writes of 0xAA to base + 0xAAAA, 0x55 to
base + 0x5554, 0x80 to base + 0xAAAA, 0xAA to base + 0xAAAA, 0x55 to base + 0x5554, then **0x10 to base + 0xAAAA**
(chip erase, `Flash_ChipErase` 0xEF387A) or **0x30 to the sector address** (sector erase,
`Flash_EraseSectorWithBankSelect` 0xEF3929).  Interrupts run at level 6 during the sequence (`ei 6`, back to
`ei 0` after).  The 32-bit Table Data pair uses the same command words doubled (`TableDataFlash_ChipErase`
0xEF3DBB, already on the page).

**Which chip.** A = 1 selects the Custom Data Flash IC19 at 0x300000, anything else the HD-AE5000 flash at
0x280000.  On region-4 units (`Get_Region_Code` 0xEF0865 = 4, PH.2 = PH.1 = 0) IC19 is two chips: the chip erase
is sent to 0x300000 and again to 0x380000, and a sector at 0x380000 or above gets its command base moved to
base + 0x80000.

**Sector address.** XBC & 0xFF0000 (the 64 KB sector containing it).  Boot-block sub-sectors are added by
appending further 0x30 writes, with no new unlock, right after the first (inside the chips' sector-erase
window), chosen by the device id `Flash_InitAllBanks` (0xEF3B05) stored at RAM 0x205E0 (IC19) / 0x205E2 (HD-AE5000):

| case                               | sector erased        | extra 0x30 writes                                                       | id test                                           |
|------------------------------------|----------------------|-------------------------------------------------------------------------|---------------------------------------------------|
| IC19, id 0x2258 (bottom boot)      | 0x300000             | +0x4000, +0x6000, +0x8000                                               | `cpw (0x205e0), 8792`                             |
| IC19, other id (top boot)          | 0x3F0000             | +0xF8000, +0xFA000, +0xFC000; if XBC = 0x3FFFFF also +0xE0000           | (`Flash_EraseSector_TopSector` 0xEF3A3E)          |
| IC19 region 4                      | 0x370000 or 0x3F0000 | chip base +0x78000, +0x7A000, +0x7C000; if XBC = 0x3FFFFF also +0x60000 | (`Flash_EraseSector_BootBlock_HighBank` 0xEF39D6) |
| HD-AE5000, id 0x22AB (bottom boot) | 0x280000             | +0x4000, +0x6000, +0x8000                                               | `cpw (0x205e2), 8875`                             |
| HD-AE5000, other id (top boot)     | 0x2F0000             | +0x78000, +0x7A000, +0x7C000                                            | (`Flash_EraseSector_Bank2Check` 0xEF3A82)         |

0x2258 / 0x22AB are the AMD device ids of the Am29F800B / Am29F400B bottom-boot parts (datasheet; the chip part
numbers on the boards were not checked here).  The "if XBC = 0x3FFFFF" extra erase of the sector 0x20000 below is
what the code does; no caller passing 0x3FFFFF was found (the type-7 handler passes 0x3E0000 and 0x3F0000).

**Verification and timeouts: none.**  Neither routine reads anything back.  Completion is the chip's ready line,
port 7 bit 5 (`Flash_CheckReady` 0xEF3AE1); `Flash_WaitUntilReady` (0xEF3AED, chip erase + wait),
`Flash_EraseSectorAndWrite` (0xEF3BFC) and `FlashWrite` (0xEF3C3C) poll it with no timeout.  The type-7 update
handler (`HANDLE_UPDATE_FILE_TYPE_ID_007h`, 0xEF47FA) issues the two sector erases of 0x3E0000 and 0x3F0000 back
to back without polling between them; how the chip treats the second unlock sequence while the first erase is
starting was not determined (an AMD part ignores or rejects commands other than 0x30/0xB0 inside the erase
window: datasheet, inference).

**Callers.** Chip erase: `Flash_WaitUntilReady` for update types 5 (IC19) and 6 (HD-AE5000), the boot-time
verify path (`HDAE5000_TableData_Write_Skip3`).  The 32-bit Table Data pair's chip erase: update types 1, 3, 7 and
8 each call `Flash_BurnWithProgress` (0xEF4702, `v10/maincpu/boot/system_handlers.s`), whose first call is
`TableDataFlash_ChipErase` (added 2026-11-02: the draft below claimed chip erases for types 1/3/8 without this).  Sector erase: the type-7 handler, `Flash_EraseSectorAndWrite`
(splash-screen save `Flash_SaveSplashScreen`), `FlashWrite` (custom-data saves from the file, tone-generator
and MIDI code).

### Website page draft (flash-programming.md, new section "Sector Erase (Program ROM)" after "TableDataFlash_ChipErase")

> ### Flash_ChipErase (0xEF387A) and Flash_EraseSectorWithBankSelect (0xEF3929)
>
> The 16-bit flash chips (Custom Data Flash IC19 at 0x300000 when A = 1, otherwise the HD-AE5000 flash at
> 0x280000) are erased with the AMD/JEDEC sequence: `AA` to base+0xAAAA, `55` to base+0x5554, `80`, `AA`, `55`,
> then `10` to base+0xAAAA for a chip erase or `30` to the sector address for a sector erase.  The sector is
> `address & 0xFF0000`.  On region-4 units IC19 is two chips: the chip erase goes to 0x300000 and 0x380000, and
> sectors from 0x380000 use the second chip's command base.
>
> The boot-block sub-sectors are added by more `30` writes right after the first, chosen by the device id read
> at start-up (`Flash_InitAllBanks`, RAM 0x205E0 / 0x205E2): a bottom-boot part (0x2258 for IC19, 0x22AB for
> the HD-AE5000 chip) erasing its lowest sector also erases +0x4000, +0x6000 and +0x8000; a top-boot part
> erasing its top sector also erases +0xF8000/+0xFA000/+0xFC000 (IC19) or +0x78000/+0x7A000/+0x7C000.
>
> Nothing is read back, and there is no timeout: callers wait on the ready line (port 7 bit 5,
> `Flash_CheckReady` 0xEF3AE1) for as long as it takes.  The type-7 updater erases 0x3E0000 and 0x3F0000 back
> to back without waiting between them.
>
> (Then fix the Overview/AMD tables: "Chip Erase | See below" can link here, and the "Update Flow" step 4 can
> say which erase each update type uses: chip erase for types 1/3/5/6/8, two sector erases for type 7's sub-CPU
> area plus the Table Data chip erase.)

---

## 5. kn5000-3ei -- the website's source-coverage figure

The issue's last comment (2026-10-24) said: close when the table-data and v7 verbatim columns reach 0, and update
rom-reconstruction.md.  Re-run at 130735749 (2026-10-31), `python3 scripts/analysis/kn5000_source_coverage.py`
(in the built main tree, read-only):

| image                                                     | ROM bytes  | verbatim debt | % source |
|-----------------------------------------------------------|------------|---------------|----------|
| maincpu v10, v9, v7                                       | 2,097,152  | 0             | 100.0%   |
| maincpu v6                                                | 2,097,152  | 13,756        | 99.3%    |
| maincpu v5                                                | 2,097,152  | 15,910        | 99.2%    |
| subcpu v142, boot, table data, custom data, HD-AE5000 x 4 | (each)     | 0             | 100.0%   |
| KN5000, 13 images                                         | 16,056,320 | 29,666        | 99.8%    |
| all 17 (with WSA1R)                                       | 18,153,472 | 29,666        | 99.8%    |

v7 and table data are at 0 B, which meets the close condition.  The v6/v5 debt is their `TODO(port)` rows, tracked
by the kn5000-ports lane, not by this issue.  rom-reconstruction.md's "Verbatim debt" section already carries these
130735749 figures; only the summary row near its top is stale (it says 8 measured images, v7 99.7 %, a 6,591 B
blob, measured at `2319e9b94`).  The repo-root CLAUDE.md "ROM Components" table also shows older v6/v5 figures
(17,159 B / 19,978 B); that table is the integrator's, so it is reported here rather than edited.

### Website page draft (rom-reconstruction.md, the KN5000 row of the per-model coverage table)

> | KN5000 | 99.8% of its 13 measured images (16,056,320 B); 11 at 100% (v7 and table data reached 0 B verbatim on 2026-10-24); the ported v6 (99.3%, 13,756 B) and v5 (99.2%, 15,910 B) carry their `TODO(port)` rows. v8 is v9's source; v1.41/v1.40 are not measured on their own | `python3 scripts/analysis/kn5000_source_coverage.py` |
>
> and "(run at disassembly `2319e9b94`, 2026-10-24)" above the table becomes "(KN5000 row re-run at `130735749`,
> 2026-10-31)".
