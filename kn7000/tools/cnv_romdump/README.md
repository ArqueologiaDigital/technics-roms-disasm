# KN7000 ROM dumper: a floppy loader plus an application on the SD card

A way to dump a KN7000's ROMs with nothing but the instrument, one floppy and an SD card. It runs on
the stock firmware through **STYLE CONVERT**, the instrument's own way of running a program from a
floppy (`notes/style-converter.md`). No SP7001, no opened case.

| file on      | name          | what                                                                                       |
|--------------|---------------|--------------------------------------------------------------------------------------------|
| the floppy   | `KN7LOAD.CNV` | a loader (`loader.s`): finds the firmware's routines, loads and starts the application     |
| the SD card  | `KN7APP.BIN`  | the application, in the card's root folder; here the ROM dumper (`romdump.s`)              |

The floppy is made once. After that, a new version of the dumper (or any other application) is just a
new `KN7APP.BIN` copied onto the SD card from a computer.

## Using it

1. `make` writes `build/KN7LOAD.CNV`, `build/KN7APP.BIN` and `build/kn7load_floppy.img`. The floppy
   image is the loader alone, on a blank disk the KN7000 formatted (kn7000_mame
   `tools/floppy-images`). Write it to a 1.44 MB disk.
2. Copy `build/KN7APP.BIN` to the root folder of the SD card. Put the card in.
3. On the KN7000: **DISK MENU**, **STYLE CONVERT**, choose `KN7LOAD.CNV`, **OK**.
4. The loader's screen appears, then the dumper's. It shows each ROM's MAME name, the address range
   or port being read, and a progress bar. Below them is the list of all ROMs with their CRC-32 once
   done. Dumping everything takes about 74 MB of writing. In MAME that is roughly 10 minutes of
   emulated time; on the instrument it depends on the card.
5. When it says **Done**, the results stay on screen for 15 seconds. Then the firmware asks
   "Continue Next?": **NO** leaves, **YES** loads `KN7APP.BIN` again and dumps again.
6. On a computer, `C:\KN7DUMP` holds the files under MAME's names, plus `DUMPLIST.TXT`. That file
   lists each one's size, CRC-32 and byte sum, and what the loader found in the firmware. For the
   wave ROMs it also gives the byte sum the firmware's own WAVE ROM test expects, so a bad wave dump
   shows up on the instrument already (`[SUM?]`).

## The SAFE build: the first run on a real instrument

`make` also writes `build/safe/KN7APP.BIN`, the same program built with `mkapp.py --options 0x303E0`
(`romdump.inc` `OPTS_SAFE`). The dumper shows its name, "KN7000 ROM DUMPER 1.0 SAFE", in yellow at
the top right. It dumps only what is fully understood: the program flash, the table flash and IC21, all plain CPU reads of memory
the firmware itself reads. The wave ROMs and the picture window are listed as `[SKIP]`.

On the card it touches nothing but ordinary files. Its only firmware calls are file open, write and
close, the same routines the loader uses to read `KN7APP.BIN`:

- no `KN7DUMP` folder: `PRGEVEN.BIN`, `PRGODD.BIN`, `TBLEVEN.BIN`, `TBLODD.BIN`, `IC21.BIN` and
  `DUMPLIST.TXT` go to the root folder;
- no long-name pass, so no raw sector access at all; `DUMPLIST.TXT` gives each 8.3 file its MAME
  name.

About 10 MB in all.

`build/ic19/KN7APP.BIN` (`--options 0x301FF`, `OPTS_PICTURE`, shown as "KN7000 ROM DUMPER 1.0 IC19")
is the second pass, the same way: the picture flash window alone, 8 MB. The firmware's own picture
code addresses `0x57800000` (941: `mov 0x57800000, a0` at `0x48580A38`), but the window's 8 MB
extent is an assumption, so it gets a pass of its own after the first one is safe on the computer.
The wave ROMs wait for a better-understood approach (`notes/wave-rom-port.md`).

Afterwards, `check_real_dump.py DIR [DIR2]` checks on the computer what came
back from the card:
- each file's size and CRC-32 against the ones the instrument computed while writing it;
- whether each file is a ROM we already have;
- the program's release byte, build numbers and firmware search, read from the image itself;
- given a second run, that both runs are byte-identical.

## What it dumps

| MAME name                                  | read from                                                    | size  | 941 address source                   |
|--------------------------------------------|--------------------------------------------------------------|-------|--------------------------------------|
| `kn7000_program_even_v<rel>_b<build>.ic17` | CPU `0x48400000`-`0x487FFFFF`, bytes 0-1 of each 32-bit word | 2 MB  | the program flash pair, IC17 half    |
| `kn7000_program_odd_v<rel>_b<build>.ic16`  | the same window, bytes 2-3                                   | 2 MB  | IC16 half                            |
| `kn7000_table_even_b<table>.ic17`          | CPU `0x48000000`-`0x483FFFFF`, bytes 0-1                     | 2 MB  | the same pair, A22 low               |
| `kn7000_table_odd_b<table>.ic16`           | the same window, bytes 2-3                                   | 2 MB  |                                      |
| `custom_data.ic21`                         | CPU `0x96800000`-`0x969FFFFF`, the whole chip                | 2 MB  | the writable custom-data flash       |
| `c3cbqd000002.ic203`                       | main TG port `0x98050000`, select 0, banks 0-0x1FF           | 16 MB | the WAVE ROM test's protocol         |
| `c3cbqd000001.ic204`                       | main TG port `0x98050000`, select 1                          | 16 MB |                                      |
| `c3cbqd000004.ic207`                       | sub TG port `0x98040000`, select 0                           | 16 MB |                                      |
| `c3cbqd000003.ic208`                       | sub TG port `0x98040000`, select 1                           | 16 MB |                                      |
| `c3cbmd000098.ic19`                        | CPU `0x57800000`-`0x57FFFFFF`                                | 8 MB  | picture flash; the window is a guess |

- **Names.** These are the names in MAME's `kn7000` driver (upstream). The program and table names
  are built from the firmware's own build numbers, so a different firmware gets names in the same
  pattern. For 941 these are `kn7000_program_even_v1.6_b941.ic17` and `kn7000_table_even_b84.ic17`;
  SP7001 uses `_sp7001_b942`. IC21's whole chip has no name in the driver, so it is called
  `custom_data.ic21` after its region. The driver's `01ctmini.ic21` is the part of it from
  `0x20000` on.
- **Wave ROMs.** They are read exactly as the firmware's service-mode test reads them
  (`notes/wave-rom-port.md`):
  1. Write `0x8000` to P+6, then wait a tick.
  2. Per bank, write `0x8000 | bank` to P+6.
  3. Per word, write `0x8000 | offset | select` to P+8 and read P+A, low byte first.
  4. At the end, write 0 to P+6.

  The chip labels are the ones on the firmware's test screen.

**Other parts worth dumping, from what is known so far** (survey: `notes/wave-rom-port.md`):

- **IC18, rhythm data** (`c3cbnd000046.ic18`, 8 MB) is not dumped yet. No CPU window for it is
  confirmed (`0x54E00000` is a software fallback, not the chip). A candidate window would have to
  be identified first.
- **IC23, the 256 KB battery-backed SRAM** at `0x44000000` holds the panel memories and settings.
  It is user data, not a ROM, and MAME has no file for it. It could be added easily if wanted.
- **Not readable from the main CPU:**
  - the SD sub-CPU's flash IC414 (`c3fbkd000162.ic414`), private to the MN102H60;
  - the panel MCUs' mask ROMs (M37471);
  - the effects DSP, which has no ROM.

## How it stays out of the firmware's way

- **Memory.** Everything it writes is in the 192 KB the firmware sets aside for a style converter
  (`0x502B8000`-`0x502E7FFF`, zeroed on load). The only exceptions are the converter mailbox, the
  LCD frame, and the tone generators' wave-test latches.

  | range                     | what                                             |
  |---------------------------|--------------------------------------------------|
  | `0x502B8000`              | loader                                           |
  | `0x502B9D00`              | loader variables                                 |
  | `0x502B9E00`              | service table                                    |
  | `0x502BA000`              | application                                      |
  | `0x502C0000`-`0x502CFFFF` | two 32 KB buffers                                |
  | `0x502E0000`              | the application's variables and tables           |

- **No firmware addresses are built in.** The firmware routines it calls are not taken from a table
  of 941 addresses: the loader finds them in the program flash. A signature masks only the operands
  that move between builds, and must match exactly once, or that service counts as not found.
- **The point is firmware nobody has dumped, so it gets as far as it can.** Only file access on the
  SD card is required, and it has two independent sources. Every other service is optional, and the
  dumper works around a missing one:

  | service                          | found by                                                              | without it                                                              |
  |----------------------------------|-----------------------------------------------------------------------|-------------------------------------------------------------------------|
  | SD file open, close, read, write | the fmm dispatch tables, by their shape; or the fmm dispatchers' code | nothing can be read or written: the loader says so (15 s) and ends      |
  | raw SD sector read and write     | code signature                                                        | no long names: the files keep their 8.3 names, `DUMPLIST.TXT` maps them |
  | `sdfmmkdir`, `sdfmpath`          | code signature                                                        | no `KN7DUMP` folder: the files go to the card's current folder          |
  | PROGRAM build number             | the SOFT VERSION code's signature                                     | `_bunknown` in the file names, `?` on the screen                        |
  | TABLE build number               | the ASCII build string the table header points to, range-checked      | the same                                                                |
  | kernel millisecond counter       | the tick handler's signature                                          | the result screen is held 3000 calls instead of 15 s                    |

  - **The dispatch tables** are eleven 12-byte records of three code pointers (floppy, SD, a third
    backend). The search asks only for that shape: every pointer in the program flash, the floppy
    and SD columns each strictly ascending within 64 KB, the three columns in disjoint ranges. That
    holds exactly once in 941, 942, 935, and even in the surviving upper half of 929, which has
    none of the dispatchers' code. With the tables the SD backends are called directly, and the
    drive byte is never touched. When the dispatchers are found too, they must point at the same
    tables (`fmmopen`'s table = the tables + 12), or the tables are not used.
  - **What is read is never judged.** Each ROM is read whatever it holds and written as it comes.
    The wave ROMs' byte sums are compared with the sums the firmware's own test expects, but only to
    mark a file `[SUM?]`. The release byte at `0x4840000F` goes into the names as it is.
  - **A file that cannot be written** (open or write failed, card full) is marked `[FAIL]` on the
    screen and `NOT WRITTEN` with its error code in `DUMPLIST.TXT`, and the dump goes on with the
    next ROM. If opening a file in `KN7DUMP` fails, that file and the rest go to the current folder.
  - **The loader's screen** says what it found: the build numbers, or `?`, and a line
    `file routines: by tables | by code  sectors: yes/no  folders: yes/no  clock: yes/no`.
    `DUMPLIST.TXT` repeats it as a bit mask, with the tables' and `open`'s addresses.

  `find_fw.py` runs the same searches over every program image we have; `run_test.sh --loader-test`
  switches searches off in MAME, to run each fallback (see the results).
- **One step per call.** Each converter call writes one 32 KB chunk and returns. It parks the
  firmware with request 1, which calls again without repainting the screen; request 5 would repaint
  it over the dumper's own. The file layer is switched to the SD card only during a call. The SD
  "current folder" is emptied around each call and put back.
- **Long names.** The firmware's FAT library refuses long names (`fmmopen` returns -3), so the files
  are written with 8.3 names (`PRGEVEN.BIN`, ...). After the last file is closed, the dumper
  rewrites `C:\KN7DUMP`'s directory cluster with VFAT long-name entries in front of the unchanged
  8.3 entries, then reads it back to check. Every probe for this is in `probes/README.md`. The pass
  leaves the card alone unless the folder holds only the dump files and fits in its first cluster;
  it then says why it skipped. A ROM whose file could not be written is simply left out.
  `DUMPLIST.TXT` lists both names in either case. `fsck.fat -n` reports no errors on a card written
  this way.
- **Not tried on a real instrument yet.** The owner's KN7000 runs **PROGRAM 893 / TABLE 80**,
  release v1.3, which nobody has dumped. If neither the tables nor the dispatchers are found in 893,
  the loader cannot even read `KN7APP.BIN`, and says so. That is the one case where nothing is
  written. The way past it would be an SD driver of our own (SPI at `0x9805000C`, chip select at
  `0x36008004` bit 1). That is not written: each byte sent raises IRQ5, which the firmware's own
  handler answers, and that handshake and its timing cannot be checked in MAME first.

## Files

| file                          | what                                                                                      |
|-------------------------------|-------------------------------------------------------------------------------------------|
| `loader.s`                    | `KN7LOAD.CNV`: firmware search, service table, loading and checking `KN7APP.BIN`, drawing |
| `kn7cnv.inc`                  | the contract between loader and application: memory layout, service table, header         |
| `romdump.s`, `romdump.inc`    | the ROM dumper application                                                                |
| `mkapp.py`                    | fills the application header's size and CRC-32                                            |
| `mkfloppy.py`                 | files onto a blank disk the KN7000 formatted                                              |
| `gen_font.py`, `font8x13.inc` | the 8x13 text font, from the X11 misc-fixed font (public domain)                          |
| `find_fw.py`                  | the loader's firmware search, in Python, over every program image we have                 |
| `check_real_dump.py`          | after a real run: files whole, known or new, build numbers, two runs identical            |
| `fatls.py`                    | lists or extracts the files on an SD card image, showing long names                       |
| `test/run_test.sh`            | the dumper end to end in MAME, then `verify_dump.py`                                      |
| `test/prefill.lua`            | test data for the undumped ROMs (the wave ROM regions, the picture window)                |
| `test/verify_dump.py`         | checks every file: MAME name, and bytes against MAME's hashes or the test data            |
| `probes/`                     | the probes behind the design (SD write, long names, raw sectors, folders)                 |

## How it was tested

Results are in the next section. Command:

    test/run_test.sh ~/compartilhado/mame-pr-kn-flop-rebuild/knfl-tip $T/run   # [--fast] [--loader-test N] [--safe]

The test runs upstream MAME's `kn7000`, built from the `technics-kn-flop-rebuild` worktree. It boots
with the loader floppy and a copy of the real KN7000's SD card with `KN7APP.BIN` added.
`prefill.lua` fills the four wave ROM regions with seeded pseudo-random data and answers reads of
the picture window with more of it. The script runs STYLE CONVERT > OK and waits for the dumper to
finish. `verify_dump.py` then checks every file in `C:\KN7DUMP` (or in the root, when the dumper
had no folder), by its 8.3 name:

- all 11 files are there;
- its long name is one of the driver's ROM names (with `--loader-test`: or 8.3 only, or `_bunknown`);
- the program and table files match the driver's CRC-32 and SHA-1 for that half;
- `custom_data.ic21` matches what the CPU reads at `0x96800000` when the dump ends. The firmware
  writes its homepage record there at boot, so the chip is not factory-blank below `0x20000`;
- the wave and picture files match the test data.

Upstream maps port `0x98050000` to `waveform_sub_*` and `0x98040000` to `waveform_main_*`. The
firmware's test screen says the opposite (`MAIN TG` = `0x98050000` = IC203/IC204), so the verifier
compares the IC203 file with `waveform_sub_y`, and so on. That is a driver issue, not a dumper one.

## Results (2026-10-19)

The full run used upstream MAME `kn7000` from the `technics-kn-flop-rebuild` worktree (binary
`knfl-tip`). Its build was `KN7LOAD.CNV` SHA-1 `4fa225578d95…` and `KN7APP.BIN` SHA-1
`5de28284c5be…`; `make` rebuilds both byte for byte from these sources.

| file (long name on the card)         | 8.3 name    | bytes    | CRC-32     | checked against                                                      |
|--------------------------------------|-------------|----------|------------|----------------------------------------------------------------------|
| `kn7000_program_even_v1.6_b941.ic17` | PRGEVEN.BIN | 2097152  | `529b87ce` | MAME's CRC-32 and SHA-1 for that name                                |
| `kn7000_program_odd_v1.6_b941.ic16`  | PRGODD.BIN  | 2097152  | `a36e6222` | the same                                                             |
| `kn7000_table_even_b84.ic17`         | TBLEVEN.BIN | 2097152  | `005a6db2` | the same                                                             |
| `kn7000_table_odd_b84.ic16`          | TBLODD.BIN  | 2097152  | `7e1a312e` | the same                                                             |
| `custom_data.ic21`                   | IC21.BIN    | 2097152  | `ddea6b9b` | what the CPU reads at `0x96800000`; from `0x20000` = `01ctmini.ic21` |
| `c3cbqd000002.ic203`                 | IC203.BIN   | 16777216 | `f777fbfd` | the test data in upstream's `waveform_sub_y`                         |
| `c3cbqd000001.ic204`                 | IC204.BIN   | 16777216 | `24ee0c01` | the test data in `waveform_sub_x`                                    |
| `c3cbqd000004.ic207`                 | IC207.BIN   | 16777216 | `db8a87e9` | the test data in `waveform_main_y`                                   |
| `c3cbqd000003.ic208`                 | IC208.BIN   | 16777216 | `7d57f5a9` | the test data in `waveform_main_x`                                   |
| `c3cbmd000098.ic19`                  | IC19.BIN    | 8388608  | `768969e1` | the test data served at `0x57800000`                                 |

- **The full run.** All 11 files are as expected, `DUMPLIST.TXT` included. It finished at 653 s of
  emulated time, about 4 converter calls a second at 32 KB each; the SD writes set the pace.
- **Long names.** The pass wrote them and read them back. `fsck.fat -n` on the partition reports
  only the volume label being in the root directory and the dirty bit, both already true of the
  instrument's own card.
- **Shorter checks.** `--fast` cuts every ROM to 64 KB and gives 11 of 11. An SD card without
  `KN7APP.BIN` gets the loader's "No C:\KN7APP.BIN" screen, held 15 s. The dumper's done screen is
  also still up 5 s after the end.
- **Overlay build.** On the kn7000_mame overlay (`kn7000-emulator`) the same path works, including
  the long names. Its four wave ports all read one synthetic pack, so it cannot tell the chips apart.

The bulk outputs (the card image, about 74 MB of dumps, the snapshots) are not kept. `run_test.sh`
regenerates them.
