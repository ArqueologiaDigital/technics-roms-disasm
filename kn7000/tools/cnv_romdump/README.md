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
5. When it says **Done**, press **EXIT**, then **NO**. (**YES** loads `KN7APP.BIN` again and dumps
   again.)
6. On a computer, `C:\KN7DUMP` holds the files under MAME's names, plus `DUMPLIST.TXT`. That file
   lists each one's size, CRC-32 and byte sum. For the wave ROMs it also gives the byte sum the
   firmware's own WAVE ROM test expects, so a bad wave dump shows up on the instrument already
   (`[SUM?]`).

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

- **It never runs on unknown code.** The firmware routines it calls are not taken from a table of
  941 addresses. The loader finds them in the program flash by their code, with only the operands
  that move between builds masked:
  - the fmm file layer's drive switch, `fmmopen`, `fmmclose`, `fmmread` and `fmmwrite`;
  - raw SD sector read and write;
  - `sdfmmkdir` and `sdfmpath`;
  - the SOFT VERSION code that holds the build number.

  Each must be found exactly once. If one is not, it stops with "Unsupported firmware" before
  touching anything. `find_fw.py` runs the same search on every program image we have: 941, 942
  (SP7001) and 935 each give one hit for every routine. The surviving half of 929 lacks that code.
- **One step per call.** Each converter call writes one 32 KB chunk and returns. It parks the
  firmware with request 1, which calls again without repainting the screen; request 5 would repaint
  it over the dumper's own. The file layer is switched to the SD card only during a call. The SD
  "current folder" is emptied around each call and put back.
- **Long names.** The firmware's FAT library refuses long names (`fmmopen` returns -3), so the files
  are written with 8.3 names (`PRGEVEN.BIN`, ...). After the last file is closed, the dumper
  rewrites `C:\KN7DUMP`'s directory cluster with VFAT long-name entries in front of the unchanged
  8.3 entries, then reads it back to check. Every probe for this is in `probes/README.md`. The pass
  leaves the card alone unless the folder holds only the dump files and fits in its first cluster;
  it then says why it skipped. `DUMPLIST.TXT` lists both names in either case. `fsck.fat -n`
  reports no errors on a card written this way.
- **Not tried on a real instrument yet.** The owner's KN7000 runs **PROGRAM 893 / TABLE 80**,
  release v1.3, which nobody has dumped. The loader looks for its routines by their code, so it may
  well find them. If it does not, it says so and writes nothing. Either way, the first run on 893
  tells us.

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
| `fatls.py`                    | lists or extracts the files on an SD card image, showing long names                       |
| `test/run_test.sh`            | the dumper end to end in MAME, then `verify_dump.py`                                      |
| `test/prefill.lua`            | test data for the undumped ROMs (the wave ROM regions, the picture window)                |
| `test/verify_dump.py`         | checks every file: MAME name, and bytes against MAME's hashes or the test data            |
| `probes/`                     | the probes behind the design (SD write, long names, raw sectors, folders)                 |

## How it was tested

See "Results" below. Command:

    test/run_test.sh ~/compartilhado/mame-pr-kn-flop-rebuild/knfl-tip $T/run   # [--fast]

The test runs upstream MAME's `kn7000`, built from the `technics-kn-flop-rebuild` worktree. It boots
with the loader floppy and a copy of the real KN7000's SD card with `KN7APP.BIN` added.
`prefill.lua` fills the four wave ROM regions with seeded pseudo-random data and answers reads of
the picture window with more of it. The script runs STYLE CONVERT > OK and waits for the dumper to
finish. `verify_dump.py` then checks every file in `C:\KN7DUMP`:

- its long name is one of the driver's ROM names;
- the program and table files match the driver's CRC-32 and SHA-1;
- `custom_data.ic21` matches what the CPU reads at `0x96800000` when the dump ends. The firmware
  writes its homepage record there at boot, so the chip is not factory-blank below `0x20000`;
- the wave and picture files match the test data.

Upstream maps port `0x98050000` to `waveform_sub_*` and `0x98040000` to `waveform_main_*`. The
firmware's test screen says the opposite (`MAIN TG` = `0x98050000` = IC203/IC204), so the verifier
compares the IC203 file with `waveform_sub_y`, and so on. That is a driver issue, not a dumper one.
