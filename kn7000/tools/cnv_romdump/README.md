# KN7000 ROM dumper: a floppy loader plus an application on the SD card

A way to dump a KN7000's ROMs with nothing but the instrument, one floppy and an SD card. It runs on
the stock firmware through **STYLE CONVERT**, the instrument's own way of running a program from a
floppy (`notes/style-converter.md`). No SP7001, no opened case.

| file on     | name          | what                                                                                   |
|-------------|---------------|----------------------------------------------------------------------------------------|
| the floppy  | `KN7LOAD.CNV` | a loader (`loader.s`): finds the firmware's routines, loads and starts the application |
| the SD card | `KN7APP.BIN`  | the application, in the card's root folder; here the ROM dumper (`romdump.s`)          |

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

`build/wave/KN7APP.BIN` (`--options 0x3021F`, `OPTS_WAVE`, shown as "KN7000 ROM DUMPER 1.0 WAVE") is
the third pass: the four wave ROMs alone, 16 MB each, in plain files in the root as before. They are
off the CPU's bus, so it reads them through the tone generators' test latches, repeating the
firmware's own WAVE ROM test (`notes/wave-rom-port.md`). It does this bank by bank, entering test mode
for each 32 KB bank and leaving it again, with a settle after each switch: about 10 ms in MAME,
where the firmware sleeps one 1 ms tick.
- **Why this can be trusted.** PROGRAM 893's checksum routine is the same instruction stream as
  941's, and every build carries the same four expected sums: `0x8164C77C`, `0x815CFC83`,
  `0x8331EF0B` and `0x83254F9D`, at 893 `0x485CE974`.
- **What the sums show.** A dumped chip whose byte sum equals the firmware's has had every byte
  read. The sum cannot show the byte or word order. `check_real_dump.py` reports the sum check in
  its last column.

`build/survey/KN7APP.BIN` (`--options 0x703C0`, `OPTS_SURVEY`, shown as "KN7000 ROM DUMPER 1.0
SURVEY") is the fourth pass. It looks for the rhythm ROM, whose CPU address nobody knows. Option bit
`OPT_SURVEY` swaps `RomTable` for `SurveyTable`. That table holds six plain CPU windows of 8 MB
each, written to the root as `R4000000.BIN` and so on, with MAME-style names
`survey_40000000.bin` in `DUMPLIST.TXT`:
- CS0, `0x40000000`-`0x40FFFFFF`;
- CS5, `0x54000000`-`0x55FFFFFF`.

These cover every address where the firmware looks for the rhythm resource:
- the firmware compares 16 bytes against "Technics Rhythms" at `0x48010000`, `0x40610000`,
  `0x40010000`, `0x54E10000` and `0x40810000`, and otherwise uses `0x54E00000` unchecked
  (`StyleResourceWindowProbe`, 941 `0x4843D6DC`, 893 `0x4843D69A`, same list);
- `0x48010000` is the table flash, already dumped. Table 80 has no signature anywhere, and its
  rhythm entry `*(0x4800014C)` points at a `"DMY\n"` stub;
- a 4 MB device at `0x54E00000` runs on to `0x551FFFFF`. That is why CS5 is surveyed up to
  `0x55FFFFFF`.

The firmware's windows `0x56000000`, `0x57000000`, `0x41000000` and `0x41800000` are the expansion
boards' (`VoiceArchiveScanBoot`) and are not surveyed. `find_rhythm.py` analyses the windows
afterwards; `check_real_dump.py` runs it on any `R*.BIN` it is given. It:
- joins adjacent windows;
- maps mirrors and blank areas;
- finds each signature and repeats the firmware's own check on it, `StyleResourceVerify` (941
  `0x484338B4`). That check is a 16-bit sum of big-endian words; the header declares the expected
  sum (u16 at +0x10), the offset (u24 at +0x12) and the word count (u24 at +0x15);
- reads the RHYTHM number the firmware's version code computes (a row of the SP7001 DEBUG TOOLS screen; the
  SOFT VERSION screen shows only PROGRAM and TABLE);
- compares the data with the truncated copy of the header that table 84 carries at `0x483E828C`.

`find_rhythm.py --self-test` exercises all of this on a made-up device split across two windows.

`build/survey2/KN7APP.BIN` (`--options 0xB0000`, `OPTS_SURVEY2`, shown as "KN7000 ROM DUMPER 1.0
SURVEY2") is the fifth pass: everything still to read from the owner's instrument, in one run.
Option bit `OPT_SURVEY2` swaps in `Survey2Table`. It holds 14 plain CPU windows, all of them memory;
no I/O window (`0x98xxxxxx`, `0x9Cxxxxxx`, `0x34xxxxxx`, `0x36xxxxxx`) is among them. The files go
to the root, 8.3 names `R` + the base's top seven hex digits, MAME-style names `survey_<base>.bin`:

| entry | file           | CPU window                | bytes     | what                                          |
|-------|----------------|---------------------------|-----------|-----------------------------------------------|
| 0     | `R4000000.BIN` | `0x40000000`-`0x407FFFFF` | 8 MB      | pass 4's window again: IC18, twice (CS0)      |
| 1     | `R4080000.BIN` | `0x40800000`-`0x40FFFFFF` | 8 MB      | pass 4's window again: open bus               |
| 2     | `R5400000.BIN` | `0x54000000`-`0x547FFFFF` | 8 MB      | pass 4's window again: open bus               |
| 3     | `R5480000.BIN` | `0x54800000`-`0x54FFFFFF` | 8 MB      | pass 4's window again: IC21, four times (CS5) |
| 4     | `R5500000.BIN` | `0x55000000`-`0x557FFFFF` | 8 MB      | pass 4's window again: open bus               |
| 5     | `R5580000.BIN` | `0x55800000`-`0x55FFFFFF` | 8 MB      | pass 4's window again: IC19, four times (CS5) |
| 6     | `R8400000.BIN` | `0x84000000`-`0x841FFFFF` | 2 MB      | IC23, the battery-backed SRAM (CS1, uncached) |
| 7     | `R5018000.BIN` | `0x50180000`-`0x50297FFF` | 1,146,880 | the work RAM the firmware never clears        |
| 8     | `R4C00000.BIN` | `0x4C000000`-`0x4C03FFFF` | 256 KB    | the library RAM (CS3)                         |
| 9     | `R5680000.BIN` | `0x56800000`-`0x569FFFFF` | 2 MB      | IC21 again, if CS5 ignores A25                |
| 10    | `R4100000.BIN` | `0x41000000`-`0x4100FFFF` | 64 KB     | an expansion slot (CS0)                       |
| 11    | `R4180000.BIN` | `0x41800000`-`0x4180FFFF` | 64 KB     | an expansion slot (CS0)                       |
| 12    | `R5600000.BIN` | `0x56000000`-`0x5600FFFF` | 64 KB     | an expansion slot (CS5)                       |
| 13    | `R5700000.BIN` | `0x57000000`-`0x5700FFFF` | 64 KB     | an expansion slot (CS5)                       |

- **Entries 0-5** are `SurveyTable`'s six windows: the same addresses, sizes, file names and
  manifest lines as pass 4. They are the second read of IC18, and of IC21 and IC19 through CS5.
  `check_real_dump.py --pass4` compares them with pass 4 byte for byte.
- **Entry 6**, IC23: eight copies if the chip repeats every 256 KB. It is read at `0x84000000`, the
  uncached view of `0x44000000`, through which the firmware itself reads and writes IC23: the file
  is what is in the chip, with no cache in between. It covers every offset the Another World port
  would touch (`0x44000000`-`0x4413FFFF`).
- **Entry 7** holds the COMPOSER styles, songs, pads and the slideshow pool
  (`notes/work-ram-map.md`).
- **Entry 8** is a cross-check: the boot copies the library there from the program flash.
- **Entry 9**: pass 1 read IC21 at `0x96800000`, and pass 4 found it at `0x54800000`.
- **Entries 10-13** are the four windows the firmware probes at boot for expansion boards
  (`VoiceArchiveScanBoot`). They show what an empty slot reads. They come last, so that everything
  else is on the card first.
- **Size.** 56,197,120 bytes (53.6 MiB) and `DUMPLIST.TXT`: about 1.12 times pass 4. The card
  needs about 60 MB free. The image of the owner's card (`sdcard_from_real_kn7000.img`) is a
  128 MB FAT16 volume, 16 KB clusters, 126.5 MB free; every window is a whole number of clusters.
- **Why 2 MB of CS1.** By the service manual, CPU pin 52 (`RAS1/CS1`) goes to nothing but
  IC23's `/CE`, through the power-fail switch Q3 (`probes/cs1_trace.py`, `probes/README.md`).
  IC23 (2 Mbit x16) has address pins A1-A17. So all of CS1 is IC23 and its mirrors, with no
  register to disturb. The firmware itself writes only `0x44000000`-`0x4403FFFF`
  (`notes/style-converter.md`).
- **Live memory.** The firmware keeps running between the dumper's 32 KB steps, so IC23 and the work
  RAM are read as they are at each step. A word the firmware changes between the reads of two
  IC23 copies makes the copies differ there. That is a finding to read, not a read error; a stale
  cache line cannot be the cause, since `0x84000000` is uncached.
- **The table's length.** `V_NROMS` holds it: 10 for `RomTable` and `SurveyTable`, 14 for
  `Survey2Table`. Skip bits 0-15 can cover up to `MAX_ROMS` = 16 entries. Every loop over the
  ROMs, the files (`DUMPLIST.TXT` comes after them) and the screen list now reads `V_NROMS`.
  The counter reads "ROM n/14". The list of more than 10 entries is drawn in two columns of seven,
  each line `[ OK ] name crc32`. The older builds still show 10 entries in one column and "ROM n/10".

Afterwards, `check_real_dump.py DIR [DIR2] [--pass4 P4DIR] [--pass1 P1DIR]` checks on the computer
what came back from the card:
- each file's size and CRC-32 against the ones the instrument computed while writing it;
- whether each file is a ROM we already have, or a window holding copies of one
  (`c3cbnd000046.ic18 x2`);
- the program's release byte, build numbers and firmware search, read from the image itself;
- given a second run, that both runs are byte-identical.

For the SURVEY2 files it adds:
- `--pass4`: every window compared with pass 4's, per 1 MB slice. A difference where pass 4
  read open bus (FF with a few residue values) is not counted;
- `--pass1`: `0x56800000` against pass 1's `IC21.BIN`, and the library RAM against the program
  flash (where the copy comes from, how much agrees);
- IC23: each 256 KB copy against the first, and the first checked for a shorter period;
- the expansion slots and the work RAM: what they hold.

`check_real_dump.py --self-test` runs these on made-up files.

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

- **IC18, rhythm data** (`c3cbnd000046.ic18`): found by the SURVEY build on the owner's instrument
  (2026-10-19), at `0x40000000`-`0x403FFFFF`, repeating at `0x40400000`. Its address pins take
  A1-A21, and JP7 sets its top pin, so the CPU sees 4 MB of the 64 Mbit chip.
  - **Checks.** `find_rhythm.py` finds the header at `0x40010000`, the firmware's third probe; its
    checksum passes; 220 styles; RHYTHM 33 (`"jkr_33.ssf"`).
  - **The first 64 KB is the boot ROM.** It is the CPU's reset code (`jmp 0x40000594`, and finally
    `jmp 0x48400000`) and the flash updater.
  - **The rest of the survey.** It also shows IC21 at `0x54800000` and IC19 at `0x55800000`,
    byte for byte; the rest is open bus.
  - **Not yet in the default build.** `RomTable` has no IC18 entry: adding one means an eleventh
    skip bit for every build.
- **IC23, the 256 KB battery-backed SRAM** at `0x44000000` holds the panel memories and settings.
  It is user data, not a ROM, and MAME has no file for it. The SURVEY2 build reads it, with its
  mirrors: 2 MB at `0x84000000`, the uncached view the firmware uses.
- **Not readable from the main CPU:**
  - the SD sub-CPU's flash IC414 (`c3fbkd000162.ic414`), private to the MN102H60;
  - the panel MCUs' mask ROMs (M37471);
  - the effects DSP, which has no ROM.

## The DSP probe: the effects DSP, read through the firmware's own routines

Two more builds of the same application look at the effects DSP, IC306, an ADSP-21065L that the main CPU
host-boots at every power-up (`kn7000_mame/notes/dsp-host-interface.md`). The DSP's host port is 16 bits
wide and register-indirect:
- the IOP register address goes to `0x98000000`;
- the contents move through `0x9C000000`, two 16-bit halves per 32-bit register, low half first.

The title reads "KN7000 DSP PROBE". The files are plain 8.3 files in the root, as in SAFE.

| build             | options    | name on screen                 | files                                      |
|-------------------|------------|--------------------------------|--------------------------------------------|
| `build/dspprobe/` | `0x130000` | "KN7000 DSP PROBE 1.0 PHASE 1" | `DSPHOST.BIN`, `DSPIOP.BIN`, `DSPTIME.BIN` |
| `build/dspmem/`   | `0x230000` | "KN7000 DSP PROBE 1.0 PHASE 2" | `DSPPM.BIN`, `DSPDM.BIN`                   |

**It drives no port itself.** `DspFind` (`romdump_dsp.s`) finds the firmware's own host-port routines by
masked signatures, the way the loader finds its file routines, and the probe `calls` them. They keep the
firmware's lock, its handshake wait (INTC group 0x17) and its "DSP dead" guard.

| routine                             | 893          | 941          | how it is found                                      |
|-------------------------------------|--------------|--------------|------------------------------------------------------|
| register read, 2x16 (`calls` entry) | `0x4840B433` | `0x4840531B` | `sig_dspregs` + 0x3E                                 |
| register write, 2x16                | `0x4840B3F5` | `0x484052DD` | `sig_dspregs` + 0                                    |
| index write (guarded)               | `0x4840B19B` | `0x48405083` | the read's call at body + 6                          |
| data-port read, 16 bits (guarded)   | `0x4840B090` | `0x48404F78` | the read's call at body + 0xE                        |
| handshake wait                      | `0x4840AE77` | `0x48404D25` | `sig_dspwait`                                        |
| "DSP dead" flag                     | `0x500066D8` | `0x500066CC` | the wait's operand at +0x36, and the data read's own |
| "kernel downloaded" flag            | `0x500066D9` | `0x500066CD` | the wait's operand at +0x0F                          |

- **The checks.** Each signature must match once in `0x48400000`-`0x487FFFFF`. Each call target must
  be preceded by the `add -frame, sp` its call allocates. The data read must test the same dead flag
  as the wait. Short of all of that the probe leaves the DSP alone and says so in every file's
  status word.
- **`find_dsp.py`** repeats the search over every program image we have. It finds the same routines in
  941, 942, 935 and 893; 929's lower half is not dumped.
- **Same code.** `find_dsp.py` disassembles the routines and everything they call (unidasm) and
  compares them with 941's, stack slots and frame sizes aside. In 893 nine of the eleven routines
  are the same code. The two data-port accessors lack 941's bus-timing bracket around the port access
  (save `0x32000026`, write `0x924`, restore); their logic is otherwise the same.
- **The firmware's register read** returns `(high << 16) +` the low half sign-extended, `0x10000` short
  when bit 15 of the low half is set. The probe adds it back, so the files hold the registers as they
  are.

**Phase 1 only reads.**
- **`DSPHOST.BIN`, the main CPU's side.**
  - The interrupt control registers G0ICR-G63ICR, `0x34000100`-`0x340001FF`; G17ICR (`0x3400015C`) is
    the DSP handshake group. No other I/O bank is read.
  - The firmware's DSP variables, `0x500` bytes from the dead flag's 256-byte page minus `0x100`
    (893: `0x50006500`-`0x500069FF`, which holds both flags and the 146-entry effect pointer table at
    `0x500066DC`; 941 has the table at `0x500066E0`).
  - The addresses the probe found.
- **`DSPIOP.BIN`, the IOP registers.** A snapshot of every register Table E-15 of the ADSP-21065L
  Technical Reference defines, read twice (pass A, pass B), 102 of them. Not read, and marked in a
  bitmap in the file:
  - `EPB0`/`EPB1` (`0x04`/`0x05`): the external port FIFOs; a read pops a word (Table E-12);
  - the SPORT data buffers `TX0_A`, `RX0_A`, `TX0_B`, `RX0_B`, `TX1_A`, `RX1_A`, `TX1_B`, `RX1_B`
    (`0xE2`, `0xE3`, `0xEE`, `0xEF`, `0xF2`, `0xF3`, `0xFE`, `0xFF`); a receive read takes the word
    away (Table E-13);
  - every address Table E-15 lists as reserved.
- **`DSPTIME.BIN`, a time series.**
  - 200 samples 5 ms apart by the firmware's millisecond counter (the loader finds it).
  - Each sample has the time at start and end, `TCOUNT0`, `TCOUNT1`, `DMASTAT`, the eight SPORT DMA
    counts `CR0A`-`CT1B` and their chain pointers.
  - Then 256 samples back to back of `TCOUNT0`, `TCOUNT1`, `CT0A` and `CR0A`, for counts that reload
    faster than 5 ms.
- **What phase 1 writes.** Only what the firmware writes for any DSP access:
  - the index latch `0x98000000`;
  - inside its data-port routine, `0x0001` to G17ICR before it waits for the DSP's answer.

  If the DSP did not answer within the routine's `0x3FFFF` polls, the firmware's own routine would set
  its dead flag; it would then send the DSP nothing until the next power-up. The probe checks the flag
  before every read and stops.

**Phase 2 reads DSP memory back** through external-port DMA channel 8 in transmit direction: internal
memory to `EPB0` to the host.
- **`DMAC0`** is `0xA5` for program memory and `0x45` for data memory (Table E-16):
  - DEN (bit 0);
  - TRAN (bit 2, transmit, internal to external);
  - DTYPE (bit 5, 48-bit instructions, PM only);
  - PMODE (bits 6-7: 10 = 16 to 48 bits for PM, 01 = 16 to 32 bits for DM);
  - MSWF 0 (least significant 16 bits first);
  - MASTER, HSHAKE and EXTERN 0: slave mode, the host reads.

  These are the firmware's own upload values, `0xA1` and `0x41`, with TRAN added. Its uploads run the
  same channel in receive direction.
- **The sequence, per range.**
  1. `DMAC0` = `0x2000` (FLSH: flush `EPB0` and the packing state; DEN 0).
  2. `IIEP0` = first address, `IMEP0` = 1, `CEP0` = words.
  3. `DMAC0` = `0xA5` or `0x45`.
  4. Per word, read `DMAC0` until its FS bits say `EPB0` holds data, at most 1000 times. With SYSCON's
     BHD clear, a host read of an empty `EPB0` would hold the bus until data came.
  5. Latch index 4 (`EPB0`) and read three (PM) or two (DM) 16-bit halves, least significant first.
  6. At the end, `DMAC0` = `0x2000` again.
- **What it reads.**
  - `DSPPM.BIN`: PM `0x8000`-`0x8DFF`.
  - `DSPDM.BIN`: DM `0x9800`-`0x9FFF` and `0xC000`-`0xC4FF`, then for each SPORT DMA chain pointer its
    value and the 16 DM words around it (the TCBs).
- **Before.** It reads SYSCON and the channel's registers (`DMAC0`, `IIEP0`, `IMEP0`, `CEP0`, `CPEP0`,
  `DMASTAT`). It goes ahead only if:
  - SYSCON is the firmware's 16-bit, LSW-first set-up;
  - `DMAC0` has DEN and CHEN clear;
  - `DMASTAT` shows channel 8 neither active nor chaining.
- **After.** It writes back `IIEP0`, `IMEP0`, `CEP0` and `DMAC0`'s control bits as they were, then
  reads them again into the file.
- **What phase 2 writes.** `DMAC0`, `IIEP0`, `IMEP0` and `CEP0`, nothing else:
  - no SYSCON, SPORT or timer register;
  - no DSP memory.
- **A power cycle undoes it all.** At every power-up the firmware resets the DSP and boots it again:
  - it pulses `0x36008004` bit 7;
  - it writes SYSCON's software reset;
  - it downloads the kernel, and with it `IIEP0`, `IMEP0`, `CEP0` and `DMAC0` are written anew.

**`check_dsp_probe.py DIR [--program P1DIR]`** decodes all of it:
- the files' integrity;
- the found routines;
- G17ICR and the flags;
- every register by name, with SYSCON, `DMACx`, `DMASTAT`, `STCTLx`/`SRCTLx` and the divisors decoded;
- the timer and SPORT rates, with the arithmetic and what it assumes;
- the rate of the firmware's own DSP accesses (the burst's time stamps) and the movement of MSGR2,
  which mirrors the kernel's ring-3 pointer I3;
- the readback, against the kernel the firmware uploads (its download record, found in the program
  flash).

`--self-test` runs the decoders on made-up files; `--mask-asm` prints the read mask `romdump_dsp.s`
carries, from the same register list.

### Phase 1 on the owner's KN7000 (pass 6, 2026-10-20)

Felipe ran the phase-1 release the same day. The files are private, in `technics_roms`
`roms/kn7000/real_dump_v1.3_b893/pass6-run1/`, with the checker's whole output beside them. All three
came back whole; the routines were found at the 893 addresses MAME found; the DSP stayed alive (dead
flag 0 before and after every file). What it showed:

- **The set-up matches the emulator's** where both have a value: SYSCON `0x410`, the eight chain
  pointers, `DMAC0` `0xA0`, `WAIT`, `SDRDIV`, and the control bits of `STCTLx`/`SRCTLx`.
- **The chip has state the emulator does not model**: `DMASTAT` `0x33F` (all eight SPORT DMA channels
  active), SYSTAT `0x13`, IOSTAT `0x80000000`, the `STCTLx` status bits (`0xF9`/`0xD9` in the top
  byte), `IOCTL` reading `0x0852205B` where the kernel wrote `0x8852A05B` (bits 31 and 15 read 0),
  MSGR3 `0` (the emulator answers `0x1065`), and the rings' positions: every receive channel at its
  base + 3 with a count of 5, every transmit channel at base + 5 with a count of 3.
- **The timers are not used** (TPERIOD0/1 0), so they give no clock.
- **The SPORT counts do not move between reads, though the DMA runs.** Every firmware data-port
  access first waits for the DSP's handshake, so every read lands at the same point of the DSP's
  frame.
- **What does give a rate:** the firmware's accesses run at 24.15 us each, 41.4 per ms. MSGR2,
  the ring-3 pointer, moved 111 words in about 4.93 ms, 22.5 per ms. Two readings fit, and
  pass 6 cannot tell them apart:
  - frames at about 22.5 kHz, with FLAG3 always high;
  - or frames at 41.4 kHz or more, with FLAG3 high on about half of them (44.1 kHz would fit).
- **Phase 2's pre-checks hold** on the chip: SYSCON `0x410`, `DMAC0` DEN and CHEN clear, channel 8
  neither active nor chaining.

## How it stays out of the firmware's way

- **Memory.** Everything it writes is in the 192 KB the firmware sets aside for a style converter
  (`0x502B8000`-`0x502E7FFF`, zeroed on load). The only exceptions are the converter mailbox, the
  LCD frame, and the tone generators' wave-test latches.

  | range                     | what                                             |
  |---------------------------|--------------------------------------------------|
  | `0x502B8000`              | loader (less than 0x1C00 bytes, `make` checks)   |
  | `0x502B9C00`              | the loader's 128-byte line buffer                |
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
  | kernel millisecond counter       | the tick handler's signature                                          | 15 s become 23,000 calls slowed by a delay loop (15 s in MAME)          |

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
- **On a real instrument (2026-10-19).** The owner's KN7000 runs **PROGRAM 893 / TABLE 80**,
  release v1.3, which nobody had dumped. The SAFE build ran there on the first try. The loader found
  all seven services (`0x7F`): the fmm tables at `0x48662E6C` and SD `open` at `0x48564A88`. All
  five files came off the card intact (`check_real_dump.py`: size, CRC-32 and byte sum equal what
  the instrument computed). The table flash is byte-identical to SP7001's table 83 apart from the
  build digit and the SP7001's added data at the end. The IC19 build read the picture ROM intact
  too, and the WAVE build the four wave ROMs, each one's byte sum the firmware's expected sum. Each build was run a second time the same day, and both reads were byte-identical, files
  and manifests alike. The dump is kept privately, with those checks, in the private ROM
  repository (`roms/kn7000/real_dump_v1.3_b893/`, `pass1-run1/2`, `pass2-run1/2`).
- **SURVEY2 on the instrument (2026-10-20).** One run, every file whole; `check_real_dump.py
  pass5-run1 --pass4 pass4-run1 --pass1 pass1-run1` says "everything checks out". IC18 is identical to
  pass 4 (its second read). **IC23 repeats every 256 KB through its window** (7 of 7 copies equal the
  first, no shorter period), and its header checksum is valid. `0x56800000` is IC21 byte for byte. The
  library at `0x4C000000` is program flash from `0x487B76B1`, `0x3DF02` bytes. The four empty expansion
  slots read 99.9% `FF`. Kept privately as `pass5-run1/`, with the checker's output.
- **A firmware without file access** is the one case where nothing is written: if neither the
  tables nor the dispatchers are found, the loader cannot even read `KN7APP.BIN`, and says so.
  The way past it would be an SD driver of our own (SPI at `0x9805000C`, chip select at
  `0x36008004` bit 1). That is not written: each byte sent raises IRQ5, which the firmware's own
  handler answers, and that handshake and its timing cannot be checked in MAME first.

## Files

| file                            | what                                                                                      |
|---------------------------------|-------------------------------------------------------------------------------------------|
| `loader.s`                      | `KN7LOAD.CNV`: firmware search, service table, loading and checking `KN7APP.BIN`, drawing |
| `kn7cnv.inc`                    | the contract between loader and application: memory layout, service table, header         |
| `romdump.s`, `romdump.inc`      | the ROM dumper application                                                                |
| `romdump_dsp.s`                 | the DSP probe: the firmware's DSP routines found and called, the five DSP files           |
| `mkapp.py`                      | fills the application header's size and CRC-32                                            |
| `mkfloppy.py`                   | files onto a blank disk the KN7000 formatted                                              |
| `gen_font.py`, `font8x13.inc`   | the 8x13 text font, from the X11 misc-fixed font (public domain)                          |
| `find_fw.py`                    | the loader's firmware search, in Python, over every program image we have                 |
| `check_real_dump.py`            | after a real run: files whole, known or new, builds, two runs identical; SURVEY2 checks   |
| `find_rhythm.py`                | the SURVEY windows: where the rhythm ROM is, the firmware's checksum on it, its version   |
| `find_dsp.py`                   | the DSP probe's search in Python over every program image, and the same-code check        |
| `check_dsp_probe.py`            | decodes the DSP probe's files: registers, rates, the readback against the kernel          |
| `fatls.py`                      | lists or extracts the files on an SD card image, showing long names                       |
| `test/run_test.sh`              | the dumper end to end in MAME, then `verify_dump.py`                                      |
| `test/prefill.lua`              | test data for the undumped ROMs (wave ROM regions, picture window, survey windows)        |
| `test/prefill_survey2.lua`      | the SURVEY2 test's data, after the boot; references and write logs of the RAM windows     |
| `test/dsp_tap.lua`              | the DSP probe's host-port traffic, and the emulator's IOP registers and DSP memory        |
| `test/verify_dump.py`           | checks every file: MAME name, and bytes against MAME's hashes or the test data            |
| `probes/`                       | the probes behind the design (SD write, long names, raw sectors, folders; CS1 = IC23)     |
| `releases/2026-10-19/`          | exactly what went to the real KN7000 (binaries of `f673f55`, procedure, `SHA1SUMS`)       |
| `releases/2026-10-19-wave/`     | the same for the WAVE build (pass 3)                                                      |
| `releases/2026-10-19-survey/`   | the same for the SURVEY build (pass 4)                                                    |
| `releases/2026-10-20-survey2/`  | the same for the SURVEY2 build (pass 5)                                                   |
| `releases/2026-10-20-dspprobe/` | the same for the DSP probe, phase 1 (pass 6)                                              |
| `releases/2026-10-20-dspmem/`   | the same for the DSP probe, phase 2 (pass 7)                                              |

## How it was tested

Results are in the next section. Command:

    test/run_test.sh ~/compartilhado/mame-pr-kn-flop-rebuild/knfl-tip $T/run   # [--fast] [--loader-test N] [--safe|--ic19|--wave|--survey|--survey2]
    test/run_test.sh ~/compartilhado/kn7000-emulator/kn7000 $T/run --survey2 --bios v13 --rompath ~/compartilhado/kn7000-emulator/roms
    test/run_test.sh ~/compartilhado/kn7000-emulator/kn7000 $T/run --dsp --bios v13 --rompath ~/compartilhado/kn7000-emulator/roms
    test/run_test.sh ~/compartilhado/kn7000-emulator/kn7000 $T/run --dspmem [--fake-syscon --fake-fs] --bios v13 --rompath ...

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

All runs used upstream MAME `kn7000` from the `technics-kn-flop-rebuild` worktree (binary
`knfl-tip`). The final runs tested exactly the files handed over for the real instrument; `make`
rebuilds them byte for byte from these sources:

| file                      | SHA-1                                      |
|---------------------------|--------------------------------------------|
| `KN7LOAD.CNV`             | `6b81f382fd29b9bc5a025854af0e20a194e68bec` |
| `kn7load_floppy.img`      | `b7a67de602694fd2257d59ce4509ca154b0b3064` |
| `KN7APP.BIN` (everything) | `60de66c68727a10ada0db8fccd0ff70ef40f5dd2` |
| `safe/KN7APP.BIN` (SAFE)  | `83f579ce0a1b05d8dcd71b6745a015a3a543aa4b` |
| `ic19/KN7APP.BIN` (IC19)  | `0a82abcfbc73a42d2f59f6c734eff483aa309b88` |

| run              | `run_test.sh` options       | what it exercises                                                | ends at | outcome                                                                                |
|------------------|-----------------------------|------------------------------------------------------------------|---------|----------------------------------------------------------------------------------------|
| `safe_full`      | `--safe`                    | the SAFE build, every ROM full size                              | 124 s   | 11 of 11: the five files and `DUMPLIST.TXT` match, the five left out are absent        |
| `safe_lt`        | `--safe --loader-test 0x3D` | the same with only the fmm tables found: no code, sectors, clock | 119 s   | 11 of 11; held by the delay loop (1,533 calls a second)                                |
| `ic19_full`      | `--ic19`                    | the IC19 build: the picture window alone, 8 MB                   | 110 s   | 11 of 11                                                                               |
| `nofile_noclock` | `--safe --loader-test 0x23` | no file routines and no clock                                    | 50 s    | the loader's failure screen, held; nothing written (the verifier exits 1: all missing) |
| `all_full`       | (none)                      | everything, wave ROMs and picture window included                | 655 s   | 11 of 11, the table below                                                              |

"Ends at" is the emulated time of `dump.cmd.in`'s end line. The failure screen of `nofile_noclock`
reads `file routines: none  sectors: yes  folders: yes  clock: no` and `search: fmm table shapes
found 0, file code steps 0 of 5`. The first full run, with an earlier build (`KN7LOAD.CNV`
`4fa225578d95…`, `KN7APP.BIN` `5de28284c5be…`), gave the same files at 653 s.

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

- **The full run.** All 11 files are as expected, `DUMPLIST.TXT` included. It finished at 655 s of
  emulated time, about 4 converter calls a second at 32 KB each; the SD writes set the pace.
- **The hold without a clock.** Parked with request 1 after the end, the firmware calls the
  converter 20,187 to 20,411 times in the first emulated second (`calls_in_1s_after_done`), and up
  to about 300,000 on lighter paths, so bare calls are no clock. With the 10,000-iteration delay loop
  per call (`HOLD_SPIN`) it is 1,531 to 1,533 calls a second, so `HOLD_CALLS` 23,000 holds the screen
  about 15 s. On the instrument the loop's speed may differ; it only matters when the counter is not
  found.
- **Long names.** The pass wrote them and read them back. `fsck.fat -n` on the partition reports
  only the volume label being in the root directory and the dirty bit, both already true of the
  instrument's own card.
- **The WAVE build** (`run_test.sh --wave`, binary SHA-1 `fdcce57a...`, `releases/2026-10-19-wave/`):
  the four wave files, 16 MB each, match the test data in MAME; the run ends at 555 s of emulated
  time (12 min real). The test data cannot have the firmware's sums, so all four show `[SUM?]`.
  `check_real_dump.py` reports them as DIFFERS and exits 1. With the expected sums set to the
  files' own sums, it reports "=" and exits 0, so both of its paths have been exercised. It was
  built from `1822dbbcc`. The SURVEY change adds code to the application every build shares, so
  from then on `make` gives every build a new SHA-1. Each release folder keeps its own binaries.
- **The SURVEY build** (`run_test.sh --survey`, binary SHA-1 `cb20763e...`,
  `releases/2026-10-19-survey/`):
  - `prefill.lua` answers each window with its own seeded stream. All six 8 MB files match it
    (7 of 7 with `DUMPLIST.TXT`); no `UNUSED.BIN` is written. The run ends at 396 s of emulated
    time (15 min real).
  - The files taken off the card image with `fatls.py` pass `check_real_dump.py`. It passes them
    to `find_rhythm.py`, which joins the windows into the two spans and finds no signature in
    the test data, as it should.
  - `find_rhythm.py --self-test` covers the case of a signature being there.
  - `--fast` gives 7 of 7, and the default build still 11 of 11.
- **Shorter checks.** `--fast` cuts every ROM to 64 KB and gives 11 of 11. An SD card without
  `KN7APP.BIN` gets the loader's "No C:\KN7APP.BIN" screen, held 15 s. The dumper's done screen is
  also still up 5 s after the end.
- **Overlay build.** On the kn7000_mame overlay (`kn7000-emulator`) the same path works, including
  the long names. Its four wave ports all read one synthetic pack, so it cannot tell the chips apart.
- **The SURVEY2 build** (2026-10-20, binary SHA-1 `24bdc35d...`, `releases/2026-10-20-survey2/`;
  IC23 read at `0x84000000`). It ran on the published overlay binary (`kn7000-emulator/kn7000`,
  2026-10-19 23:47) with `-bios v13`, the owner's program 893 / table 80:

      test/run_test.sh ~/compartilhado/kn7000-emulator/kn7000 $T/run --survey2 --bios v13 \
          --rompath ~/compartilhado/kn7000-emulator/roms

  - **All 15 files** (14 windows and `DUMPLIST.TXT`) are as expected. The eleven tapped windows
    hold their seeded streams. Each RAM window equals what the CPU read there at the end. The
    write taps logged no word written into any of them while the dumper ran, so those comparisons
    are exact.
  - **IC23 in that binary is plain RAM.** CS1 is still the 16 MB placeholder at `0x44000000` and
    `0x84000000`, so `0x84040000`-`0x841FFFFF` held the test data (seed `0x8404`), and the dump
    has it.
  - **The end.** The run ends at 433 s of emulated time; pass 4's SURVEY test ended at 396 s.
  - **The checker.** `check_real_dump.py` on the files taken off the card image with `fatls.py`
    exits 0. Pass 1 was stood in for by MAME's v1.3 program halves and the IC21 it held, and pass 4
    by the run's own six windows.
    - It finds all six windows identical, and 0x56800000 not IC21 (a tap serves it here).
    - It finds the library RAM to be the program flash from `0x487B76B1`, `0x3DF02` bytes, then
      zeroes but for `0xDE` at `0x4C03FFF0`. In 941 the copy is from `0x487B8FD1`, `0x3DF18` bytes.
    - It finds 'TCMP' at `0x50180000` and 'TPAD' at `0x501F91A0`, where `notes/work-ram-map.md`
      puts them.
    - Its IC23 analysis calls the seven windows after the first "not a copy".
  - **IC23 as a mirrored chip.** The same binary ran on a snapshot of the overlay build that models
    IC23 as 256 KB mirrored through CS1 (`kn7000_mame_build/kn7000` of 2026-10-20 00:48, SHA-1
    `b38ce4e1...`). The full run and a `--fast` run each give 15 of 15. The prefill finds the
    mirror (it writes `0x84040100`, sees `0x84000100` follow, puts the word back) and leaves the
    window alone. On the full run, `check_real_dump.py` reports "7 of 7 copies after the first
    equal it: IC23 repeats every 256 KB through the window".
  - **Self-test.** `check_real_dump.py --self-test` covers the paths the emulator cannot produce:
    open-bus noise in a pass-4 slice (not a problem), a changed data byte (one problem), IC23
    copies equal but for two bytes, and IC21 found at `0x56800000`.
  - **The older builds are unchanged.** `--fast` on upstream `knfl-tip` gives 11 of 11 for the
    default build, its long-name pass included (`lfn=1`), 11 of 11 for `--safe` and 7 of 7 for
    `--survey`. The SURVEY run's end screen still shows one column, with the four `[SKIP]` lines;
    the counter prints `V_NROMS`, which is 10 for these builds. Those runs used a ROM path
    without the 4 MB IC18 and 2 MB IC19 images that `technics_romsets` gained on 2026-10-19, as the
    earlier runs had; upstream's driver declares both as 8 MB.

- **The DSP probe** (2026-10-20; phase 1 SHA-1 `ddc23b53...`, phase 2 `9a5077d3...`,
  `releases/2026-10-20-dspprobe/`, `-dspmem/`). It ran on the kn7000_mame overlay published
  2026-10-20 (`kn7000-emulator/kn7000`, md5 `889b6f48...`, kn7000_mame `45a1459`) with `-bios v13`.
  That overlay keeps the 21065L's IOP registers and hands back internal memory through `EPB0`; it
  does not run the timers or the SPORT DMA. `dsp_tap.lua` counted every host-port access.

  | run                    | options                                | outcome                                                          |
  |------------------------|----------------------------------------|------------------------------------------------------------------|
  | phase 1                | `--dsp`                                | 5 of 5; 101 of 102 registers as the port answers after the run   |
  | phase 2                | `--dspmem`                             | 4 of 4; refused at the pre-check, nothing written                |
  | phase 2, stand-ins     | `--dspmem --fake-syscon --fake-fs`     | 4 of 4; PM 3584 of 3584 words = the DSP's own memory             |

  - **Phase 1.**
    - It found the 893 routines (read `0x4840B433` ... as `find_dsp.py` finds them).
    - It wrote the index latch 5,028 times, only for the 102 registers it reads, and never wrote
      the data port.
    - All 102 registers read the same in both passes. They equal what the port answers after the
      run, but for IOSTAT, the DSP's flag pins (0, then 1).
    - Values (v13):
      - the SPORT chain pointers read `0x4309`/`0x4311`/`0x4319`/`0x4321`/`0x4329`/`0x4331`/`0x4339`/`0x4341`
        at `0x73`/`0x53`/`0x7B`/`0x5B`/`0x63`/`0x33`/`0x6B`/`0x3B`, as on v16;
      - `STCTLx` `0x013CB173` and `SRCTLx` `0x013C3173`: both channels on, 24-bit sign-extended
        words, external clock and frame sync, DMA chained on A and B;
      - `WAIT` `0x200D0001`, `IOCTL` `0x8852A05B`, `DMAC0` `0xA0` (the firmware's idle value).
    - SYSCON reads `0x00200020` and MSGR3 `0x10651065`: there the overlay keeps the boot protocol's
      answers on every read.
    - The time series is flat, as expected there, and the decoder says so.
  - **Phase 2.**
    - SYSCON reads `0x20` in MAME, so the pre-check refused, as it should on anything but the
      firmware's 16-bit set-up.
    - With SYSCON faked to `0x410` and `DMAC0` FS to "full" while armed (the overlay leaves FS 0), it
      read everything.
    - PM equals the DSP's memory word for word.
    - DM equals it at 3,317 of 3,328 words; the kernel's variables move.
    - It wrote only `DMAC0` (`0x2000`, `0xA5`, `0x45`, `0xA0`), `IIEP0`, `IMEP0` and `CEP0`, and left
      them as found (`DMAC0` `0xA0`, `IIEP0` `0x8093`, `IMEP0` 1, `CEP0` 1).
    - Against the kernel record in the v1.3 program flash:
      - PM `0x8300` is equal throughout;
      - `0x8000` is equal but for the unit CALL slots `0x8080`-`0x80A0`, which the firmware patches;
      - `0x8400` and `0x8D00` hold effect programs.
    - The TCBs show `CP`, `C` 8, `IM` 1 and `II` `0xC342` ...: each SPORT channel runs an 8-word ring.
  - **The emulator side was a stand-in for two bits.** On the chip, SYSCON reads `0x410` after the
    firmware's set-up, and FS shows `EPB0`'s data (TRM Table E-16). In that overlay neither did, and
    phase 2 would wait out its 1,000 polls and stop without these stand-ins (the earlier run on the
    2026-10-19 overlay did exactly that, and wrote the four registers back).
  - **Without stand-ins** (the same day, kn7000_mame `70aa725`, binary md5 `97d2f383...`). That overlay
    answers SYSCON from the register file, packed per its HBW bits (`0x410` after boot), and shows FS
    full while a readback has words. With `-bios v13` and the same release binaries:

    | run     | options    | outcome                                                                                       |
    |---------|------------|-----------------------------------------------------------------------------------------------|
    | phase 1 | `--dsp`    | 5 of 5; SYSCON `0x00000410`, decoded as a 16-bit host bus, LSW first                          |
    | phase 2 | `--dspmem` | 4 of 4; PM 3584 of 3584 words and DM 3317 of 3328 = the DSP's memory; registers left as found |

    `check_dsp_probe.py` says "everything checks out" for both, phase 2 with `--program` and the
    v1.3 `pass1-run1`; the kernel comparison is the same as with the stand-ins. Phase 2 found FS full
    at the first look for every word (0 repeat polls), as that emulator fills `EPB0` at once.
  - **The older builds, with the DSP code in.** On the same overlay, all with `--fast`:
    - the default build (`--no-prefill --bios v16`) wrote its long names (`lfn=1`), and its
      program, table and IC21 files match. Without prefill its five wave and picture files have
      no test data to compare;
    - `--safe --no-prefill --bios v16` gives 11 of 11;
    - `--survey2 --bios v13` gives 15 of 15.

    Upstream `knfl-tip` would not start on 2026-10-20: even a three-line autoboot script never ran
    in four minutes. So the upstream runs were not repeated.

The bulk outputs (the card image, about 74 MB of dumps, the snapshots) are not kept. `run_test.sh`
regenerates them.
