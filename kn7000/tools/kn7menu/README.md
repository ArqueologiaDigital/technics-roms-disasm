# KN7MENU: a program menu for the KN7000's SD card

All custom code on the owner's KN7000 is started by one floppy, `KN7LOAD.CNV` (the loader in
`../cnv_romdump`, SHA-1 `6b81f382fd29b9bc5a025854af0e20a194e68bec`, unchanged since 2026-10-19). The
loader always reads `C:\KN7APP.BIN`, so until now only one program could be on the card at a time.

KN7MENU is that `C:\KN7APP.BIN`. It lists the programs it finds on the card, one per folder, each with
the name and icon the folder's `MANIFEST.TXT` gives, and starts the one picked with the panel
buttons. The program then runs exactly as if the loader had loaded it. When it ends, "Continue
Next?" **YES** brings the menu back. The loader and the floppy stay as they are.

Contents: [Using it](#using-it) · [The card](#the-card) · [Adding a program](#adding-a-program) ·
[The manifest](#the-manifest) · [The icon](#the-icon) · [How it finds the programs](#how-it-finds-the-programs) ·
[Starting a program](#starting-a-program) · [The launch block](#the-launch-block-for-program-authors) ·
[Caches](#caches) · [Buttons](#buttons) · [Memory](#memory) · [Safety](#safety) ·
[What is new on the unit](#what-is-new-on-the-unit) · [How it was tested](#how-it-was-tested) · [Files](#files)

## Using it

1. `make card` writes `build/card/`, everything for the SD card, and `build/card.txt`, every file
   with its size and SHA-1. It builds the two games first, each with its own Makefile:
   - Another World from `AW_DIR`, its data from `~/compartilhado/MSDOS/`, as that game's Makefile
     takes it;
   - Pinball Fantasies from `PF_DIR` (`~/compartilhado/Pinball/kn7000`, `make card-dir`), its data
     from `PF_DATA` (default `~/compartilhado/Projeto_Pinball/data`: `TABLE1.PRG` .. `TABLE4.MOD`
     of the 1994 DOS game).
2. Copy **the contents of** `build/card/` to the SD card's root: `KN7APP.BIN` and the eight folders.
3. On the KN7000: **DISK MENU**, **STYLE CONVERT** (left button 3), `KN7LOAD.CNV`, **OK** (right
   button 4), as for every pass so far.
4. The loader's screen flashes by, then "Looking for the panel's buttons in the firmware...", then
   the list.

The screen is laid out like the firmware's own: a title bar, then five rows, each beside one of the
buttons left and right of the display.

| button                      | what it does                                                                    |
|-----------------------------|---------------------------------------------------------------------------------|
| left buttons 1-5            | select the program on that row; a folder's row opens the folder                 |
| PART SELECT LEFT / RIGHT 1  | select the entry above / below (across pages)                                   |
| PAGE UP, PAGE DOWN          | the page before, the page after                                                 |
| right button 1, **BACK**    | in a folder: the folder above it (the label shows only in a folder)             |
| right button 5, **RUN**     | read the selected program's `KN7APP.BIN`, check it, start it (**OPEN**: folder) |
| right button 4, **LEAVE**   | leave (when let go): the firmware's main screen, no message (Ending)            |
| EXIT, held 1.5 s and let go | the same as LEAVE                                                               |

Under each program's name the row shows its folder and what it is (`C:\AW\   Eric Chahi's 1991 cinematic
adventure`: the manifest's `DESC=`), and a note when its manifest or icon could not be used; under a menu folder's,
what kind of programs it holds (`mktoc.py` `FOLDER_DESC`), or nothing. (Until 2026-11-03 the line named the file,
`KN7APP.BIN` for every program, and its size, and a folder's said how many entries it held.) When RUN refuses a program, the reason
replaces that line in red: the file is damaged (its CRC-32), not an application of this loader (its
header), built for another loader version, empty or too large, or unreadable. The menu stays.

A program started from the menu runs as it always has. When it ends the conversion, the firmware
shows its message for a few seconds, then "Continue Next?" (EXIT on the message dismisses it sooner;
EXIT on "Continue Next?" cancels to the STYLE CONVERT screen). **YES** makes the loader load
`C:\KN7APP.BIN` again, which is the menu. **NO** leaves STYLE CONVERT.

## The card

`make card` lays it out as follows (`mkcard.py`; every folder name is a plain 8.3 name, so nothing
depends on how a computer makes short names):

| on the card  | what                                                                                                                                                                 | its `KN7APP.BIN`: from, bytes, SHA-1                                                                                   |
|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `KN7APP.BIN` | the menu                                                                                                                                                             | `build/KN7APP.BIN`, 12,739, `0566fba32f5588761de0cbbb34e3f84c2ae1c16d`                                                 |
| `AW\`        | Another World: `KN7APP.BIN` and its 61 game files (DSP sound, the coded bank `AWSB0-D.AW`, round 3)                                                                  | technics-anotherworld `kn7000/build/sdcard/` (`main` `e4b87fa`), 32,332, `94910f68eec0fd4839ab2eb2842311e4ed07028f`    |
| `PINBALL\`   | Pinball Fantasies: `KN7APP.BIN`, the table programs `PF1-4.BIN` and the game files made from your copy (`PFn.IMG/PIC/MOD`, the DSP bank `PFBANK.BIN`, `PFSB0-E.BIN`) | `~/compartilhado/Pinball` `kn7000/build/card/PINBALL/` (`a1caf99`), 14,834, `c2e1af4c5c86b040162a306631c7d355979e84ea` |
| `SURVEY2\`   | pass 5, the ROM dumper's SURVEY2 (IC23, the work RAM, the windows)                                                                                                   | `../cnv_romdump/releases/2026-10-20-survey2/`, 11,412, `24bdc35ded21b1a5742bd8c77320b471bf302b2e`                      |
| `DSPPROBE\`  | pass 6, the DSP probe, phase 1                                                                                                                                       | `../cnv_romdump/releases/2026-10-20-dspprobe/`, 15,440, `ddc23b5328c22c73fdef45f409ec4dabe63af374`                     |
| `DSPMEM\`    | pass 7, the DSP probe, phase 2                                                                                                                                       | `../cnv_romdump/releases/2026-10-20-dspmem/`, 15,440, `9a5077d387cb73cd36331a616ca35cb3e1e85c57`                       |
| `DSPRATE\`   | pass 8, the DSP probe's frame rate                                                                                                                                   | `../cnv_romdump/releases/2026-10-20-dsprate/`, 16,640, `c8334f68c9e3450312db35052cd96bc5fd94a13a`                      |
| `CPUTIME\`   | pass 9, the CPU timing probe                                                                                                                                         | `../cnv_romdump/releases/2026-10-20-cputime/`, 21,496, `91022a0f7239bd85049a56ecd914202673475847`                      |
| `DSPTONE\`   | our own program on the effects DSP, iteration 1 (`../dsptone`)                                                                                                       | `../dsptone/releases/2026-10-20-iter1/`, 99,596, `5d7d5df5b59494effed0cdc32256d59b425ae994`                            |

Each folder also holds a `MANIFEST.TXT` (its name in the list) and an `ICON.BMP` (drawn by
`gen_icons.py`, converted by `png2icon.py`); `build/card.txt` lists every file with its SHA-1 (the game
files' among them: they are made from your own copy of each game and never committed). `PINBALL\`'s
own `MANIFEST.TXT` is replaced by one that also names its icon. The probes' binaries are the released ones, byte for
byte: `mkcard.py` checks each against its release's `SHA1SUMS`.

**Where the probes write.** Exactly where they did when they were the root's `KN7APP.BIN`: the loader
keeps the SD card's current folder empty around every call, so a file name an application opens is
relative to `C:\`. Passes 5 to 9 are all "plain files in the root" builds (`romdump.inc` `OPT_NOFOLDER`
and `OPT_NOLFN`): `R*.BIN` and `DUMPLIST.TXT` (pass 5), `DSP*.BIN` and `DUMPLIST.TXT` (passes 6 to 8),
`CPUTIME.BIN` and `DUMPLIST.TXT` (pass 9), all in the card's root, as before. Started from its folder,
none of them looks at the launch block.

## Adding a program

A program is a folder in the card's root with a `KN7APP.BIN` in it: any application of `KN7LOAD.CNV`
(`../cnv_romdump/kn7cnv.inc`, made with `mkapp.py`), at most 188,160 bytes (the loader takes 188,416;
the last 256 bytes of its area are the launch block's). Optionally:

1. a `MANIFEST.TXT` beside it, with the name to show and the icon file to use (next section);
2. the icon: `python3 -I png2icon.py my.png ICON.BMP` makes one from any PNG.

`python3 -I fatscan.py FOLDER` shows, before anything is copied, what the menu will list for a card
with `FOLDER`'s contents in its root (the same rules, worked out on the computer), and whether RUN would
start each program. The menu reads the card afresh every time it starts. Up to 64 folders are looked
at; five programs show per page.

A program that only ever opens files by their own names (as every application so far does) runs from a
folder unchanged; it just keeps reading and writing the card's root. To read its own files from its
folder, it reads the launch block (below), as Another World now does.

## The manifest

`MANIFEST.TXT`, an 8.3 name, plain text, any line ending. Example:

    # Another World for the KN7000
    NAME=Another World
    ICON=ICON.BMP
    FOLDER=Games
    DESC=Eric Chahi's 1991 cinematic adventure

- One `KEY=VALUE` per line. The keys are `NAME`, `ICON`, `FOLDER` and `DESC`, in any case; blanks around the key, the
  `=` and the value do not count. Other keys, blank lines and lines starting with `#` are ignored. A
  UTF-8 byte-order mark at the start is skipped. The menu reads the first 2,047 bytes.
- `NAME`: what the list shows, up to 63 characters (a row shows the first 57). ASCII only: any other
  byte shows as `?`. An empty `NAME=` is ignored.
- `ICON`: the icon file, an 8.3 name in the same folder (`ICON.BMP`, `aw.bmp`: case does not matter).
  A value that is not a valid 8.3 name is ignored; a later valid `ICON=` line wins over an earlier one.
- **Without a manifest, or without a usable `NAME`**, the list shows the folder's long name (from the
  FAT's VFAT entries) or, without one, its 8.3 name. **Without a usable icon** (no `ICON=`, a missing
  file, a file the menu cannot read) it shows the built-in default icon, a small window, and the row's
  second line says "(its icon file is unusable)" when an `ICON=` named one.
- `DESC`: what the row's second line says after the program's folder (`C:\AW\`): what it is, in a few words. The
  line shows 57 characters, so with an 8-letter folder 42 of them; `mktoc.py` says when one is cut short. Read only
  by `mktoc.py`, as `FOLDER` is.
- `FOLDER`: the menu folder the program is listed in, by name (`FOLDER=Games`), or a path of folders
  (`FOLDER=HW Probes/Pinball probes`). Without it, the top of the menu. It is read only by `mktoc.py`, as
  the card is made: a folder not in `KN7MENU.TOC` is listed at the top.

## The icon

A Windows BMP of **exactly 32 x 32 pixels**, **24 or 32 bits per pixel, uncompressed** (`BI_RGB`),
rows bottom-up (positive height) or top-down (negative height), any info header from
`BITMAPINFOHEADER` (40 bytes) on (GIMP's 124-byte V5 header is fine), the pixels within the file's first
12 KB. The menu converts it to the LCD's RGB565. Anything else gives the default icon.

`png2icon.py` makes exactly this from any PNG (8- and 16-bit grey, RGB, palette, grey + alpha, RGBA;
not interlaced): a larger picture is scaled down by area averaging, a smaller one up by the nearest
pixel, and transparency is drawn over black, the list's background. The result is 3,126 bytes, the
plainest BMP: 24 bits, bottom-up, a 40-byte header. No library is needed.

    python3 -I png2icon.py my-icon.png ICON.BMP     # convert
    python3 -I png2icon.py --check ICON.BMP         # would the menu take it?
    python3 -I png2icon.py --self-test              # the decoder against Pillow, when it is installed

## The table of contents

`make card` (and KN7000's `tools/sdcard/stage.sh`, over the whole staged tree) ends with `mktoc.py`, which writes
`C:\KN7MENU.TOC`: every folder of the root with a `KN7APP.BIN`, the name and the menu folder its manifest gives,
its icon decoded as the menu decodes it, and `KN7APP.BIN`'s size; and the menu's folders, made from the
manifests' `FOLDER=` paths, each with a folder icon (`gen_icons.py`). Its layout is in `mktoc.py`'s header and
`menu.inc` (`TH_*`, `TF_*`, `TP_*`); a CRC-32 covers it.

As it starts, the menu reads the root directory and that one file, and nothing in the program folders: before, it
read every folder's directory (twice, once for the icon), its manifest and its icon, which grew with every probe
added to the card. It finds a program's `KN7APP.BIN` in its folder when the program is run. A folder of the root
that the file does not list (copied to the card by hand afterwards) is looked into as before, and listed at the
top. A file it cannot use (its size, its header, its counts, its CRC-32) is ignored, and every folder is looked into.

The top of the menu lists the menu's folders first, then the programs placed there; a folder lists its own folders,
then its programs; each part sorted by name. A folder's second line says what it holds (`FOLDER_DESC`).

## How it finds the programs

Every time it starts, and only by reading. The loader hands the menu one way to read the card that
touches nothing else: the firmware's raw sector read (`SV_RAWREAD`, the routine the firmware's own FAT
library calls for every sector it reads; the loader found it on the owner's unit, `SV_FOUND` `0x7F`).
On top of it the menu has a FAT16 reader of its own (`menu_card.s`), read-only:

1. **The card's geometry.** Sector 0: a boot sector (a card without partitions), or an MBR whose first
   partition holds it. From the boot sector: 512-byte sectors, 1 to 64 sectors per cluster, one or two
   FATs, a fixed root directory, 4,085 to 65,524 clusters (FAT16, which is what the instrument's own
   library reads and formats). Anything else: "the SD card is not FAT16 ...", and the menu ends.
2. **The root directory**, up to 256 sectors: each folder (not `.`, `..`, a volume label, a deleted
   entry) is a candidate, with its 8.3 name and, when the VFAT entries before it carry one whose
   checksum matches, its long name (ASCII kept, anything else `?`, up to 63 characters). Up to 64.
3. **Each candidate's directory**, its cluster chain followed through the FAT (up to 64 clusters):
   `KN7APP.BIN` makes it a program; `MANIFEST.TXT` is read (2,047 bytes at most) and parsed; the
   `ICON=` file is looked up in the same directory, read (12 KB at most) and decoded into 32 x 32
   RGB565. As much of this as fits in 120 ms is done per converter call, so that the firmware gets its
   main task back between calls; the screen counts the folders as they go.
4. **The list**: the programs sorted by the name shown (ASCII, case ignored), five per page.

Every loop is bounded: by those limits, by the file's own size, and by the cluster count a file of
its size can have (a chain that loops or breaks is an error, never an endless walk). A sector read
that the firmware reports as "the card has changed" (code 6) is tried once more.

## Starting a program

RUN does what the loader does with `C:\KN7APP.BIN`, in three steps:

1. **Read** the selected folder's `KN7APP.BIN` into `STAGE` (`0x502E8000`, above the area the menu
   runs in), up to four clusters (64 KB) per converter call, with the same raw sector reads.
2. **Check** it there exactly as the loader checks what it loads, in the loader's order: at least 0x40
   bytes, magic `KN7A`, loader ABI 1, linked at `APP_BASE`, `AH_SIZE` equal to the file's size, the
   entry inside the file after the header; then the CRC-32 of the bytes from `AH_NAME` on against
   `AH_CRC`. A file that fails is not started, and its row says why. Nothing has been overwritten.
3. **Start** it through the trampoline (`tramp.s`). The menu copies the trampoline's 468 bytes to
   `T_CODE` (`0x50368000`), its data to `T_DATA`, and a 32 KB sled of `nop`s to `T_SLED`, all in RAM no
   program uses at that moment; then it calls it. The trampoline, running outside the area it
   overwrites:
   - copies the file from `STAGE` to `APP_BASE` (over the menu), and zeroes the rest of the application
     area up to and including the launch block, as the loader zeroes the whole area before it loads;
   - compares `APP_BASE` with `STAGE`, byte for byte (so the CRC-32 checked on `STAGE` holds for what
     will run), and checks the header once more;
   - writes the launch block;
   - empties the caches (next sections but one);
   - answers request 1 (call again at once, no repaint) and returns **to the loader directly**, with
     the stack pointer and registers the loader called the menu with.

   From the next converter call on, the loader calls the new program's `AH_ENTRY`, as it would have if
   it had loaded the program itself: the same bytes at `APP_BASE`, the same zeros after them, the
   loader's state "running". If the comparison failed (it cannot, short of a hardware fault: the copy
   is RAM to RAM), the trampoline instead leaves a header whose entry is its own `ErrApp`, which shows
   "PROGRAM NOT STARTED: YES = MENU" for 15 s and ends the conversion; YES then loads the menu.

**What is not as the loader leaves it.** Two of the loader's own words in its service table:
`SV_CALLS` (converter calls since the load) goes on counting from the menu's calls, and `SV_APPSIZE`
(the bytes the loader read) still says the menu's size. Writing them would mean writing the loader's
resident area, which the menu never does. No application here reads either. And the menu needs the
launch block's 256 bytes, so a program may be up to 188,160 bytes, not the loader's 188,416.

## The launch block (for program authors)

256 bytes at `LB_ADDR` = `0x502E7F00`, the last of the application area. Defined in
`../cnv_romdump/kn7cnv.inc` (`LB_*`), with the rest of the loader's contract. The trampoline writes it
after it has zeroed the area; the loader zeroes the whole area (the block included) before it loads
anything, so a program the loader starts directly (from `C:\KN7APP.BIN`, without the menu) finds
zeros there. A block is valid when `LB_MAGIC` and `LB_CHECK` both hold. No program may keep data of
its own in these 256 bytes.

| offset | field       | size | what                                                                       |
|--------|-------------|------|----------------------------------------------------------------------------|
| `0x00` | `LB_MAGIC`  | 4    | `LAUNCH_MAGIC` `0x4C374E4B` ("KN7L")                                       |
| `0x04` | `LB_ABI`    | 4    | `LAUNCH_ABI`, 1                                                            |
| `0x08` | `LB_SIZE`   | 4    | bytes of `KN7APP.BIN` the menu put at `APP_BASE` (= `AH_SIZE`)             |
| `0x0C` | `LB_CRC`    | 4    | its `AH_CRC`                                                               |
| `0x10` | `LB_DIR`    | 16   | the folder's 8.3 name as the card's FAT holds it, `AW`, NUL-ended          |
| `0x20` | `LB_PREFIX` | 16   | the same and a backslash, `AW\`: put in front of a file name for `SV_OPEN` |
| `0x30` | `LB_PATH`   | 32   | `C:\AW`, the form `SV_SETPATH` (`sdfmpath`) takes                          |
| `0x50` | `LB_NAME`   | 64   | the name the menu showed, NUL-ended                                        |
| `0xFC` | `LB_CHECK`  | 4    | `LAUNCH_CHECK` `0xB3C8B1B4`, the bitwise NOT of the magic                  |

How Another World uses it (technics-anotherworld `kn7000/src/cnv_main.s`, `LaunchFolder` and `AppPath`):
on its first call it copies `LB_PREFIX` into a variable of its own when the block is valid (else it
leaves it empty); every file it opens is then that prefix and the file's 8.3 name (`AW\AWR11.AW`),
opened with the loader's `SV_OPEN` as before. In the root, with no menu, the prefix is empty and the
names are the old ones. The prefix route needs nothing the loader may not have found; `SV_SETPATH` is
the firmware's own way (it sets the folder, opens, clears it), but it is an optional service.

## Caches

The KN7000's CPU (an MN103002A, AM31 core) has an instruction cache and a data cache. The firmware
runs the data cache in write-back mode (CHCTR `0x30`, then `3`, then `| 0x80` at boot; its only data
cache flush, `0x484101C9` in 941, runs at power-off, and nothing calls its instruction cache
invalidation `0x4841015B` at run time: `../cnv_romdump/README.md`, pass 9, and the disassembly). MAME
models neither cache, so nothing in MAME can show a cache problem; the menu is built not to have one
by reasoning:

- **The danger.** The menu has run, and read its data, at the very addresses where the new program's
  code goes. A copy through the data cache can leave the new code in dirty cache lines and not in RAM,
  and the instruction cache can still hold the menu's code for those addresses. The loader never meets
  this: it loads into an area nothing has executed since STYLE CONVERT zeroed it, and "Continue Next?"
  YES reloads the same file over itself (or, with the menu, comes after seconds of the firmware's own
  screens).
- **What is done** (`cachesync.inc`, CacheSync), as program 893's own routines do it (its instruction-cache
  routine at `0x48407B..` and its data-cache purge `func_48407C39`), with interrupts off for the few
  microseconds it takes: the data cache off (CHCTR bit 1), waited for (bit 3), each line of both ways
  written back by reading the purge window `0x28400000` and `0x28401000` at 16-byte steps (unless it
  writes through, bit 6, or a way is locked, bits 12-13), invalidated (bit 5) and on again; then the
  instruction cache off (bit 0), waited for (bit 2), invalidated (bit 4) and on again. Interrupts are off
  because, while the data cache is off, a handler would read RAM that its dirty lines have not reached.
- **The order.** The menu copies the trampoline and its data, syncs the caches and calls the trampoline.
  The trampoline copies the program, zeroes, checks, writes the launch block, syncs the caches, and only
  then returns to the loader.
- **Until 2026-10-27** both emptied the data cache by reading 64 KB of program flash a line at a time and
  emptied the instruction cache by running a 32 KB sled of `nop`s twice, without touching CHCTR. The
  Pinball port did the same between its programs, and on the owner's unit the CPU stopped in its sled
  (a system error NMI at `0x5031C75C`, 0x75C into it) as its menu came back after a table: a line of the
  sled was still in the data cache, and the instruction fetch read what RAM held there before (Pinball
  `notes/session-2026-10-27`, "The caches"). The menu had shown nothing of the kind, but rested on the
  same assumption, so it now does what the firmware does.

## Buttons

The menu reads fifteen buttons from the firmware's switch bitmaps: the five on each side of the display
(LCDL 1-5 on CPL segment 0, LCDR 1-5 on CPR segments 5 to 7), EXIT, PAGE UP, PAGE DOWN (CPC segment 11),
PART SELECT LEFT and RIGHT 1. Another World had measured PART SELECT LEFT / RIGHT 1, PAGE DOWN and EXIT
to change no setting while a converter is parked; the display's buttons had never been pressed under a
converter. `run_menu_tests.sh buttons` measures all fifteen the same way, with a build of the menu that
reads no button at all (`-D BUTTONS_USED=0`), so that only the firmware's own reaction shows: each button
pressed in turn on the menu's screen, 2.5 s apart, on the card `make card` builds.

| button              | in the firmware's bitmap | IC23 (all 256 KB) | firmware LCD stores | converter calls in the 3.3 s after |
|---------------------|--------------------------|-------------------|---------------------|------------------------------------|
| LCDL 1, 2, 3, 5     | seen                     | unchanged         | 0                   | 66                                 |
| LCDL 4              | seen                     | unchanged         | 0                   | 67                                 |
| LCDR 1, 3, 4        | seen                     | unchanged         | 0                   | 67                                 |
| LCDR 2, 5           | seen                     | unchanged         | 0                   | 66                                 |
| PART SELECT LEFT    | seen                     | unchanged         | 0                   | 67                                 |
| PART SELECT RIGHT 1 | seen                     | unchanged         | 0                   | 66                                 |
| PAGE UP             | seen                     | unchanged         | 0                   | 66                                 |
| PAGE DOWN           | seen                     | unchanged         | 0                   | 67                                 |
| EXIT                | seen                     | unchanged         | 0                   | 65                                 |

So none of them changes a setting, none makes the firmware draw, and the firmware goes on calling the menu
about 20 times a second through each. The menu uses all but LCDR 3, which it has no use for
(`BUTTONS_USED`). R1/R2 OCTAVE + / - and SUSTAIN, which do change settings while a converter runs
(technics-anotherworld `probes/cnv/README.md`), and DISPLAY HOLD, which repaints and once stopped the calls,
are not read. On the unit, other firmware might act on a button where MAME's does not: the IC23 record
before and after (SURVEY2, now on the menu) would show it.

Two things the tests taught about ending: the menu ends only when EXIT (held 1.5 s) or LEAVE is
**let go**, so the press never reaches the screen the firmware opens next; and, when a conversion ends with
0xFE, after the message (about 4 s) the firmware puts up "Continue Next?" by itself, where EXIT cancels instead
of confirming.

## Ending

LEAVE and EXIT (held 1.5 s), each when let go, end the menu; so does a failure screen, once EXIT has been held
(or after 15 s). What the user sees on the instrument:

1. The menu's screen goes, and the firmware's own frame is on the LCD again (`LcdGive`).
2. The firmware's main screen comes up, as after NO on "Continue Next?". There is no message and no "Continue
   Next?".
3. To have the menu again: DISK MENU, STYLE CONVERT, `KN7LOAD.CNV`, OK, as at first. The firmware loads the loader
   from the floppy afresh, and the loader loads the menu.

A program started from the menu still ends its own way. DSPTONE (`../dsptone`, `te_answer`) and the ROM dumper's
passes 5-9 (released binaries) end with 0xFE, so they still show "ERROR!" (next paragraphs) before "Continue Next?",
where YES brings the menu back; Another World goes back to the menu by itself.

**The red ERROR (until 2026-11-06).** The menu used to end with request 0xFE, and the firmware answered every 0xFE with
a red "ERROR!", for about 4 s, before "Continue Next?" (`end`, below). Program 893 (`src/b893/program/region1_03.s`, `region1_04.s`,
`data/data_00.s`; 941 has the same code at other addresses):

- The request loop (`0x4847977E`) serves 0xFE with `movbu 0xff, (0x5004ED99)` and ChangeTitle(0x4C, `_TT_STYLCNVCONT`,
  "Continue Next?").
- On its activation, `StylCnvContTtlFunc` (`0x4847944A`) calls InterruptTitle(3, 0x4A) while that byte is not 0,
  then clears it.
- InterruptTitle(3, n) posts `EV_INTERRUPT_TITLE` to title 3, `TT_MESSAGE`. Its `TtMessage` (`0x48489C68`) keeps n
  at `0x5006B59C`, and `IvMessageProc` takes record n of `func_48489C68_Table` (113 records of 16 bytes). Record 0x4A
  is of kind 4, which `func_48489CCA_Table` maps to the window `Other` (`0x0050000E`, a single text). Its text,
  `ptrs_485D7E74`, is "ERROR!" in every language ("ERREUR!" in French).

So the message names no error: the firmware shows it for any 0xFE, from any converter. (Record 0x0F, "Memory full",
is the one for a failed style install, `0x5004ED98` = 1.)

**How the menu ends now.** It asks for the main screen itself and then gives the firmware a request it serves by
returning, without opening a title:

- `ChangeMode(1, 0)` (`0x4842B301`) posts the change to mode 1, `MD_NORMAL`, the main screen. It is what the firmware
  itself calls for NO on "Continue Next?" and when its own `TECHNICS.CNV` finishes (request 0, after installing the
  converted style). It only posts an event. When the event is served, title 0x4A, where the menu ran, closes with the
  firmware's own clean-up for leaving STYLE CONVERT (`MidiRealtimeModeSet(0)`, as for NO).
- The last answer is request 4 (`RQ_QUIET`), with STYLE CONVERT's state byte (`0x5004E3F8`) set to 1 first. Request 4
  dispatches on that byte (`0x48479BA1`). At 1 (and at 2) it returns at once unless the title is "Continue Next?":
  it posts nothing, and it does not set `0x5004ED99`. Requests 2 and 5 write this byte in the course of a conversion
  (request 5 leaves it at 5). The firmware zeroes it each time STYLE CONVERT is entered from DISK MENU.

The menu finds both by their code (`FindEnd`, as it finds the panel): the head of the request loop
(`sig_reqloop`, one hit in the program flash), with the request-4 dispatch exactly `EG_RQ4` bytes after it
(`sig_rq4`). Both ChangeTitle calls must go to the same place, and ChangeMode somewhere else, starting with its
prologue (`sig_prolog`). The state byte must be in work RAM. If any of this fails, the menu ends with 0xFE as
before. `test/endsig.py` does the same on each program build:

| build        | head of the loop | ChangeMode   | state byte   | the byte 0xFE sets |
|--------------|------------------|--------------|--------------|--------------------|
| 893 (v1.3)   | `0x4847977E`     | `0x4842B301` | `0x5004E3F8` | `0x5004ED99`       |
| 935 (v1.5)   | `0x484798FF`     | `0x4842B301` | `0x5004E3FC` | `0x5004ED9D`       |
| 941 (v1.6)   | `0x48479941`     | `0x4842B343` | `0x5004E3FC` | `0x5004ED9D`       |
| 942 (SP7001) | `0x48479930`     | `0x4842B345` | `0x5004E40C` | `0x5004EDAD`       |

The 929 image here is only its upper half, and the signature is not in it.

**What else was considered.**

- *0xFE, with ChangeMode(1, 0) posted first* (test build `END_FE_AFTER_MODE`). The firmware still sets `0x5004ED99`
  and posts ChangeTitle(0x4C) after the menu's event: in MAME the main screen came up 0.47 s after LEAVE, then
  "Continue Next?" opened over it at 0.60 s, the message at 0.67 s (message 0x4A), "Continue Next?" again at 4.67 s.
- *Request 0, conversion finished.* For a converter that is not `TECHNICS.CNV` the firmware opens STORAGE DATA
  (title 0x49), the screen that stores a converted style. For `TECHNICS.CNV` (a halfword at `0x5004ED6C`, set from the
  converter's name) it first runs `func_4847A68F`, which installs the converted style (`func_48437DAF`, a copy to
  `0x840327E8`), and only then ChangeMode. Both write the instrument's memory.
- *Request 5, or any other, after ChangeMode.* The firmware's own ChangeTitle (0x4A, 0x46, ...) follows the menu's
  event, and title 0x4A calls the converter again on its activation.
- *Going straight to "Continue Next?"*, without the message: ChangeTitle(0x4C) from the menu, then the same quiet
  request 4. YES would then call the menu again rather than load it afresh, because the loader reloads only after
  0xFE (`loader.s`, `LV_STATE` 3), and the released loader is not changed. LEAVE means leave, so the menu goes to
  the main screen.

## Memory

Everything the menu writes is in the RAM a converter may use, `0x502BA000`-`0x50379FFF`, off the
firmware's mailbox page and clear of the loader's resident area below `APP_BASE`, but one byte as it ends: STYLE
CONVERT's state byte, set to 1 (Ending). It writes it with the address it found in the firmware's code: the range Another
World measured untouched by the firmware on programs 893 and 941 (technics-anotherworld
`kn7000/README-CNV.md`, "Memory"). `guard.py` checks the map at every build (`menu.inc`):

| range                     | what                                                                    |
|---------------------------|-------------------------------------------------------------------------|
| `0x502B8000`-`0x502B9FFF` | KN7LOAD.CNV, its variables and service table: read only (five services) |
| `0x502BA000`-`0x502BDB69` | the menu's image (15,210 bytes; `IMAGE_MAX` `0x502C0000`)               |
| `0x502C0000`-`0x502C03FF` | `M_VARS`: variables                                                     |
| `0x502C1000`-`0x502C37FF` | `PROG_TAB`: 64 program records of 160 bytes                             |
| `0x502C3800`-`0x502C38FF` | `ORDER`: the sorted list                                                |
| `0x502C4000`-`0x502CBFFF` | `WORKBUF`: directory clusters, the root directory (64 sectors)          |
| `0x502CC000`-`0x502CCDFF` | `FATBUF`, `SECBUF`, `TEXTBUF` (the manifest), `LINEBUF`, `LFNBUF`       |
| `0x502CD000`-`0x502CFFFF` | `BMPBUF`: an icon file                                                  |
| `0x502D0000`-`0x502D03FF` | `CRCTAB`: the CRC-32 table                                              |
| `0x502D0400`-`0x502D13FF` | `DESC_TAB`: 64 descriptions of 64 bytes (`KN7MENU.TOC`)                 |
| `0x502E7F00`-`0x502E7FFF` | the launch block (written by the trampoline only)                       |
| `0x502E8000`-`0x50315EFF` | `STAGE`: the program being checked (188,160 bytes)                      |
| `0x5031B000`-`0x5031BFFF` | the firmware's mailbox page: only the request is written                |
| `0x50320000`-`0x5033FFFF` | `ICONS`: 64 decoded icons of 2 KB                                       |
| `0x50360000`-`0x50367FFF` | `T_SLED`: the instruction-cache sled                                    |
| `0x50368000`-`0x503681D3` | `T_CODE`: the trampoline (`tramp.s`, 468 bytes)                         |
| `0x50369800`-`0x5036997F` | `T_DATA`: what the menu hands the trampoline                            |

The menu's own area (`0x502BA000`-`0x502D13FF`) is zeroed by the loader before it loads the menu; what
lies above it (`STAGE`, `ICONS`, the trampoline's region) the menu writes before it reads. A program
started from the menu finds the application area as the loader leaves it, and may use all of the
converter's RAM again: the trampoline has finished when the program's first call comes.

**The LCD.** The menu draws in a frame of its own, `MFB`, at `0x50000` in the LCD controller's display memory, past
the firmware's frame (its bytes `0`-`0x4B4FF`); Pinball Fantasies keeps its table at the same offset on the owner's
unit. On its first call (`LcdTake`, `menu_draw.s`) the menu saves the controller's start address, clears `MFB` and
moves the start address on by `0x50000 / 2` words (same line offset, bits a pixel and SwivelView): from then on
the LCD shows only the menu, whatever the firmware draws in its own frame. Before `RQ_END` (LEAVE, EXIT, a failure)
and before a program is started (`Launch`), `LcdGive` writes the firmware's start address back, so its message,
"Continue Next?" and the program find the LCD as the loader left it. If something else sets the start address while
the menu is up, `LcdCheck` takes that as the firmware's and sets the menu's again (`V_LCDRESET` counts it).
(Until 2026-11-03 the menu drew in the firmware's frame and drew itself again whenever the firmware had painted
over it.)

## Safety

The menu keeps every guarantee the loader's other applications keep:

- **Nothing written to the card.** It names no routine that writes: of the loader's service table it
  reads only `SV_MAGIC`, `SV_ABI`, `SV_FOUND`, `SV_MSCOUNT` and `SV_RAWREAD` (`guard.py` allows exactly
  these five loads and nothing else in the loader's area; `test/guard_selftest.s` proves it finds a
  load of `SV_WRITE`, `SV_RAWWRITE`, `SV_MKDIR` or `SV_SETPATH`). The trampoline calls nothing at all.
- **No write to IC23** (chip select CS1, `0x44000000`/`0x84000000`) **or the user-memory pools**
  (`0x50180000`-`0x50297FFF`): no address there appears in the menu or the trampoline (`guard.py`), and
  every address they compute at run time is one of the regions above. The MAME taps count any write
  there from the menu's, the trampoline's or a program's code.
- **The loader's resident area is never written**, not even the service table's `SV_FG`/`SV_BG`: the
  menu draws with its own copy of the loader's font and routines.
- **Every loop is bounded** (the limits in `menu.inc`: folders, sectors, clusters, bytes).
- **A firmware the menu does not know** gets a screen saying why it stops, never a guess: no raw sector
  read in the loader's table, no panel bitmaps (found as Another World finds them: two code sites that
  must agree, one hit each), a card that is not FAT16. EXIT held, or 15 s without the panel, ends it.
- **The buttons** it reads change nothing in the firmware while the converter runs (next section).
- **Its ending** calls one firmware routine besides the sector read, ChangeMode, which only posts an event, and
  writes one byte of STYLE CONVERT's state (Ending); both are found by code, else it ends with 0xFE.

## What is new on the unit

What the menu route runs, against what has already run on the owner's KN7000 (passes 1 to 9 of the
ROM dumper, 2026-10-19 and 20, and Another World from the root):

| step                                                              | on the unit before?                                                                                                                                                                            |
|-------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| the loader: its search, loading `C:\KN7APP.BIN`, the CRC check    | yes, unchanged: every pass                                                                                                                                                                     |
| answering request 5 every call (parking on the text screen)       | yes: Another World                                                                                                                                                                             |
| the panel's switch bitmaps, found by the decoder's two code sites | yes: Another World (PART SELECT, OCTAVE, SUSTAIN, HELP, PAGE, EXIT)                                                                                                                            |
| the left and right buttons beside the display, read while parked  | **no**: measured in MAME only, none changes a setting (Buttons)                                                                                                                                |
| the firmware's raw SD sector read (`SV_RAWREAD`)                  | the routine itself runs under every file the firmware reads (the loader's `KN7APP.BIN` included); **called directly from a converter: no** (MAME: these tests, and the dumper's probes on 941) |
| a FAT16 reader of our own (MBR, boot sector, root, chains, LFN)   | **no**: our code, tested in MAME on a copy of the owner's card                                                                                                                                 |
| drawing on the LCD                                                | yes: every pass (the same font and routines as the loader)                                                                                                                                     |
| answering request 1 after request 5, in one session               | **no**: the trampoline's last answer; the program's own requests follow                                                                                                                        |
| copying a program over the code that ran, and the cache handling  | **no** (Caches)                                                                                                                                                                                |
| a program reading its files from a folder (`AW\AWR11.AW`)         | **no**: the firmware's FAT library walks folder paths for its own SD screens; through `SV_OPEN` from a converter, only in MAME                                                                 |
| ending with ChangeMode(1, 0) and request 4 (Ending)               | **no**: MAME only; the firmware's own path for NO and for `TECHNICS.CNV`, called from a converter for the first time                                                                           |
| "Continue Next?" YES reloading `C:\KN7APP.BIN`                    | the loader's own path, unchanged (in MAME here after the menu and after pass 9); on the unit only if YES was ever answered there                                                               |

## How it was tested

In the published overlay emulator (`kn7000-emulator/kn7000`, md5 `5dfebca3...`, a copy in scratch with its
`roms/` and `plugins/`), `-bios v13` (program 893 / table 80, the owner's firmware), with the owner's loader
floppy exactly as released (`kn7load_floppy.img` `b7a67de6...`, `KN7LOAD.CNV` `6b81f382...`) and a fresh copy
of the real KN7000's SD card (`sdcard_from_real_kn7000.img` `3a622729...`) with a card tree copied into its
root by `fatimg.py`. `test/menu_test.lua` drives the panel through MAME's control-panel fields and confirms
each press in the firmware's own switch bitmap; it reads the menu's state from RAM (addresses from
`test/syms.py`, which reads `menu.inc`, `kn7cnv.inc` and the maps) and the LCD from its frame buffer.

    T=~/compartilhado/tmp/kn7menu-tests        # EMU=a copy of kn7000-emulator (kn7000, roms/, plugins/, the card image)
    test/run_menu_tests.sh $T guard card fallback buttons cputime end

Its write taps run through every case: any write into CS1 (IC23, both views) or the user-memory pools from
the converter's code (the loader, the menu, a program, the trampoline), any write into the loader's resident
area but the loader's own, and any write into the converter's RAM while the menu runs that is neither the
menu's nor a sector read the menu asked for, into its destination (`taps.txt` in each run).

### Results (2026-11-06): the ending

The menu `KN7APP.BIN` `7f0c53b99660560ee3e324d98ae4e619b832b3e0` (15,210 bytes), on the same emulator as the tests
below it (md5 `8b9865bd`), `-bios v13`. `test/results-2026-11-06/`:
- `guard`, `card`, `fallback` (`guard-card-fallback-summary.txt`): guard clean, 12 of 12 planted references; `card`
  10 of 10, `fallback` 7 of 7. `findend`: ChangeMode `0x4842B301`, state byte `0x5004E3F8` (5 while the menu runs).
  EXIT held: the main screen (mode `E0001`, title `F0001`) 2.15 s after the press began, which is the 2 s hold and
  the release; LEAVE: 0.47 s after the press. The mode and title words show no message (`F0003`) and no "Continue
  Next?" (`F004C`). The menu's last answer is 4, the converter is not called again, and the LCD's start address is
  the firmware's. After EXIT, DISK MENU, STYLE CONVERT and OK start the menu again. While EXIT is held, the title word reads `F0046`
  for 0.05 s (the firmware's reaction to EXIT; the menu's next request 5 puts `F004A` back).
- `end` (`end-summary.txt`) on the fallback card, three builds, LEAVE:

| build                          | after LEAVE (mode/title words, seconds)                            | message word `0x5006B59C` | ends on                    |
|--------------------------------|--------------------------------------------------------------------|---------------------------|----------------------------|
| this menu                      | `E0001/F0001` 0.47                                                 | 0                         | the main screen            |
| `END_WITH_FE` (the old ending) | `F004C` 0.45, `F0003` 0.50, `F004C` 4.52 (mode `E0006` throughout) | `0x4A`                    | "Continue Next?"           |
| `END_FE_AFTER_MODE`            | `E0001/F0001` 0.47, then `F004C` 0.60, `F0003` 0.67, `F004C` 4.67  | `0x4A`                    | "Continue Next?" over main |

The firmware's frame 2 s after LEAVE (`end-*-leave-2s.png`, display memory from 0, as the firmware draws it): the
main screen for this menu; for both 0xFE builds, the message window, an orange box, over the boot logo still in
that memory. That is the "stale" picture of the earlier snapshots: it is what the firmware draws. MAME draws the box
without its text; the unit shows "ERROR!" in it. (The main screen too has the logo's green letters behind it in MAME's
display memory.)

### Results (2026-10-27): the table of contents and the menu folders

The menu `KN7APP.BIN` `bd6c6085d40faa7fe99658a433badef660cafa41` (14,227 bytes), on kn7000_mame `c5392ca` (md5
`2265d97e`). `test/results-2026-10-27/`:
- `card` (`card-summary.txt`): 8 of 8. `KN7MENU.TOC` used; the 8 programs equal `fatscan.py`'s, all placed by it, in
  4 menu folders (Games, HW Probes, ROM dumper passes, Other apps); one folder of the card image looked into (not a
  program's); a folder opened and BACK.
- `tree` on the staged card of KN7000's `tools/sdcard/stage.sh` (`tree-staged-card-summary.txt`): 8 of 8. 28
  programs in 5 menu folders, all placed by the table; HW Probes, then Pinball probes (19 entries) opened; LCDL 3,
  PART SELECT, PAGE DOWN / PAGE UP across its pages; BACK twice, each landing on the folder left.

With `cachesync.inc` (the firmware's cache sequence; `test/results-2026-10-27/card-cachesync-summary.txt`,
`cputime-cachesync-summary.txt`): `card` 8 of 8; `cputime` 5 of 6: pass 9 started from its folder, the whole
application area written, the probe finished, `CPUTIME.BIN` verified ("everything checks out"); but "Continue
Next?" YES then left STYLE CONVERT for the main screen instead of loading the menu again (`back`). The menu as it was
before the change does the same (`cputime-old-caches-summary.txt`), so it is not the caches; on 2026-10-20 `back`
passed. Open: whether the table of contents or the emulator's panel change of 2026-10-27 (kn7000_mame `c5392ca`) is
behind it.

### Results (2026-10-20)

The menu `KN7APP.BIN` `0566fba32f5588761de0cbbb34e3f84c2ae1c16d` (12,739 bytes), the card of `make card`
(table below); every case on the binary of the commit it is documented in, but `buttons`, which needs a
menu that reads no button and was built from the same sources before the release-to-leave change (its
measurement is of the firmware, not of the menu):

| case       | checks                                                    | result                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|------------|-----------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `guard`    | `guard.py` on the menu; the self-test                     | "guard: clean"; 12 of 12 planted references found, the 3 allowed ones let through                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `card`     | menu, list, screen, navigate, repaint, again, leave, taps | 8 of 8: the six programs in `fatscan.py`'s order with their icons (in RAM and on the LCD); every button moves as it should across both pages; scribbling over the LCD makes it draw again within a call; EXIT held and let go, "Continue Next?" YES: the loader loads the menu again; LEAVE, NO: STYLE CONVERT left                                                                                                                                                                                                             |
| `fallback` | menu, list, screen, refuse-crc, refuse-header, taps       | 6 of 6: 8 programs of 10 folders as `fatscan.py` has them (a long name; an 8.3 name; a manifest of nothing usable; a missing and a wrong-size icon; a top-down 32-bit BMP behind a V5 header, a BOM, lower-case keys); RUN on the damaged copy: "Damaged: its CRC-32 does not match. Not started."; on 1,000 random bytes: "Not a KN7LOAD application (bad header): not started."; the menu stays, nothing launched                                                                                                             |
| `buttons`  | menu, buttons, taps                                       | 3 of 3 (Buttons)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `cputime`  | menu, start, area, finished, back, taps; the verifier     | 6 of 6: pass 9 started from `CPUTIME\`: its header at `APP_BASE`, the launch block (`CPUTIME`, `CPUTIME\`, `C:\CPUTIME`), the trampoline wrote all 47,104 words of the application area (the program, then zeros); `C:\CPUTIME.BIN` and `C:\DUMPLIST.TXT` in the root; `verify_dump.py --cputime`: 2 of 2 files as expected, `cpu_tap.lua`: 4 chunks, 41,212,229 reads and 1,722,996 writes by the probe's code, 0 against its rules; `check_cpu_probe.py`: "everything checks out"; YES: the menu again, the launch block zero |

**2026-10-25, the card with `PINBALL\`:** `card` again on the card of eight programs (two pages): 8 of 8, the
list in `fatscan.py`'s order with Pinball Fantasies last. Pinball Fantasies then played from that card in its own
MAME session (`~/compartilhado/Pinball/kn7000/notes/session-2026-10-25/`). **On the owner's unit** the same day
the instrument restarted right after RUN on Pinball Fantasies, while Another World started from the menu; the
game's diagnostic build (`PFDIAG\`, its README "If it does not start") is to find where.

In every case the taps found no write into IC23 or the pools from the converter's code (the firmware's
own IC23 writes: 952,168 in a run), none into the loader's area but the loader's own (and, once pass 9
ran, the probe's own `SV_FG`/`SV_BG`/`SV_SCALE`, as the loader's contract has it), and none into the
converter's RAM, while the menu ran, other than its own and the sector reads it asked for.

**What the tests found.** The first build's sled wrote its closing `rets` at `T_SLED + SLED_LEN`, which
is `T_CODE`: the trampoline's copy then put its own first bytes there, and the sled ran on into the
trampoline, again and again (research-scratch `sessions/2026-10-20_kn7menu`). `guard.py`'s map check
caught the overlap; the sled now ends inside its 32 KB. Second, the menu answered 0xFE while EXIT (or
LEAVE) was still held; now it ends on the release (Buttons).

**Another World through the menu** (technics-anotherworld `probes/cnv/run_menu_route.sh`, its own
acceptance tests with the menu in front, on this card): on `-bios v13`, with a blank IC23 and with a copy
of the owner's (deleted afterwards), 20 of 20 session checks each (the menu lists the six programs, RUN
starts the game from `AW\` with the launch block's prefix, the game's 16 checks, "Continue Next?" YES
brings the menu back and the game starts again from it); IC23 and the pools after POWER OFF identical
to a control run's (a no-op application in the root), the IC23s the same SHA-1s every earlier route gave
(`eb26c67b...`, `14f82423...`); no write into IC23, the pools or the loader from the converter's code; no
foreign write into the game's RAM, the menu's sector reads each inside the destination it asked for.
The same branch's game from the root without the menu, `run_cnv_tests.sh` unchanged: 16 of 16, all clean.

## Files

| file                     | what                                                                                                   |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| `menu.s`                 | the menu: its states, the panel, RUN, the checks, `Launch` (the trampoline's set-up)                   |
| `menu_card.s`            | the card: raw sector reads, the FAT16 reader, directories, long names, the manifest, the icon, sorting |
| `menu_draw.s`            | the screen: the list, the labels, the progress and failure screens, the LCD checksum, drawing          |
| `menu_data.s`            | text, the button table, the panel signatures, the font (`../cnv_romdump/font8x13.inc`)                 |
| `menu.inc`               | the memory map, the records, the variables, the limits, the buttons, the colours                       |
| `tramp.s`                | the trampoline: the copy, the zeros, the checks, the launch block, the caches, the return; `ErrApp`    |
| `mkinc.py`               | the assembled trampoline as data for the menu (`tramp_bin.inc`, `tramp_syms.inc`)                      |
| `gen_icons.py`           | the icons, drawn by code: the default icon (`default_icon.inc`) and the card's six (PNG)               |
| `png2icon.py`            | a PNG to the menu's icon format; `--check` a BMP; `--self-test`                                        |
| `fatscan.py`             | what the menu will list for a folder tree or a card image, by its rules but not its code               |
| `mkcard.py`              | `make card`: the card tree and `card.txt`                                                              |
| `mktoc.py`               | `KN7MENU.TOC`, the menu's table of contents, from a card tree (The table of contents)                  |
| `fatimg.py`              | a folder tree into a FAT16 card image, long names included (for the tests)                             |
| `guard.py`               | the build-time guards: addresses, the five services, frames, the memory map; `--selftest`              |
| `Makefile`               | `make`, `make card`, `make check`                                                                      |
| `test/run_menu_tests.sh` | the MAME tests (How it was tested)                                                                     |
| `test/menu_test.lua`     | the MAME side: the sessions, the checks, the taps                                                      |
| `test/syms.py`           | the menu's addresses and constants for the Lua scripts                                                 |
| `test/mkfallback.py`     | the fallback test card: malformed and missing manifests and icons, damaged binaries                    |
| `test/guard_selftest.s`  | twelve references `guard.py` must find, three it must allow                                            |
| `test/endsig.py`         | what `FindEnd` finds on each program build (Ending)                                                    |

Another World's side is on technics-anotherworld branch `launcher-folders`: `src/cnv_main.s` (`LaunchFolder`,
`AppPath`), `src/platformcnv.inc` (`AW_PATHS`), `tools/cnv_layout.py`, and its tests through the menu,
`probes/cnv/run_menu_route.sh` and `probes/cnv/awmenu_test.lua`.
