# IC18: the boot ROM and the rhythm data

The KN7000's CPU starts at `0x40000000`, where IC18 answers: the 4 MB mask ROM C3CBND000046 that holds the
rhythm (style) data. Its first 64 KB are not rhythm data but MN10300 code: the instrument's boot ROM. It
sets up the bus and the caches, runs the **update system** (floppy and SD flash update, disk check, device
info) when the right keys are held at power-on, and otherwise jumps to the firmware in the program flash at
`0x48400000`. The firmware itself cannot rewrite its own flash; this is the "updater in another device" that
kn7000_mame `notes/FINDINGS-updater-location-2026-08-09.md` looked for (H5).

[`src/ic18/boot.s`](../src/ic18/boot.s) is all 65,536 bytes, fully disassembled: 18,975 instructions in 401
routines, every one named with a header comment, the data typed, nothing `.incbin`'d. `make verify-ic18`
assembles it and compares it with the chip's first 64 KB.

## Provenance and reproduction

The image is `technics_romsets/kn7000/c3cbnd000046.ic18` (private), the first 4 MB of `R4000000.BIN` from
pass 4 of the dumper on Felipe's own instrument (`technics_roms/roms/kn7000/real_dump_v1.3_b893/`), read
twice and identical both times. Which chip answers at the IC18/IC20 site of that unit has not been checked
by opening it (see that README). The reference is cut by the Makefile and never committed.

| what                        | SHA-1                                      |
|-----------------------------|--------------------------------------------|
| the whole chip, 4,194,304 B | `2dc71f5082063cd6b21e4ed16acd67e9d326a79f` |
| its first 64 KB             | `00db930227efcac3b329edbb210db5ec26dfa25e` |

    make verify-ic18                 # src/ic18/boot.s -> build/kn7000_ic18_boot.bin, compared with the chip
    make ic18-src UNIDASM=...        # regenerate src/ic18/boot.s (tools/gen_ic18_s.py, kn7000_ic18.sym)
    python3 -I notes/ic18-boot-rom-probes/ic18_layout.py .../c3cbnd000046.ic18

`make ic18-src` needs MAME's unidasm and `baserom/kn7000_program.rom` (program 941): routines whose code
is the same as a named firmware routine take its name.

## The 64 KB

The reset code reads its own layout from the image, and the generator checks every constant it relies on
(`layout()` in `tools/gen_ic18_s.py`):

| file offset     | CPU address        | contents                                                                |
|-----------------|--------------------|-------------------------------------------------------------------------|
| `0x0000-0x0010` | `0x40000000`       | reset vector (`jmp Reset`), NMI vector at +8 (through a work-RAM thunk) |
| `0x0011-0x03FF` | `0x40000011`       | what an older link of this ROM left behind (below)                      |
| `0x0400-0x0593` | `0x50010000` (run) | the initialised-data image, copied there by Reset                       |
| `0x0594-0x0AFF` | `0x40000594`       | Reset and the NMI handler, run in place                                 |
| `0x0B00-0xFA0B` | `0x50000010` (run) | the program image: code to `0xCF1C`, then its constant data             |
| `0xFA0C-0xFA17` | `0x4000FA0C`       | `ImageCopyDescriptor`: count, source, destination of that copy          |
| `0xFA18-0xFFFF` |                    | erased (`0xFF`)                                                         |

63,148 of the 65,536 bytes are not `0xFF`; the last used byte is `0xFA17` (`ic18_layout.py`).

**Reset** sets MEMCTR0/6, the caches (CHCTR `0x30` then 3), the port defaults, the SDRAM (eight
refresh cycles through `0x32000040`) and the rest of the memory controller; copies the program image to
`0x50000010` through the uncached view (destination + `0x40000000`), clears `.bss` (`0x50010194`,
`0x1BC0C` bytes), copies `.data`, sets CHCTR bit 7, clears IVAR0-6, and writes two `nop; jmp` thunks in work
RAM: `0x50000000` to IrqDispatch and `0x50000006` to the NMI handler. With IVAR0-6 at 0 and the thunks
in RAM, CHCTR bit 7 is what moves the interrupt entry from the ROM to work RAM (the same question
kn7000_mame `notes/HARDWARE-QUESTIONS-PENDING-FELIPE.md` raises for the firmware's identical sequence).
Port P04 bit 5 is strobed between almost every step of the boot code (TODO: by its pattern, a watchdog
kick; not confirmed on the board).

**BootMain** (tick on timer 4, every flash to read mode):

1. If strap bit 14 (`0x98070000`) is clear, it runs the SD update at once (factory or service set-up, by
   the look of it).
2. It brings up the panel link and reads which of seven key combinations is held (`BootKeyComboMatch`,
   from the panel's sign-on replies). 4 opens the **UPDATE SYSTEM MENU**, 5 **DEVICE INFO** (does the
   program flash identify as flash or mask ROM), 7 **UPDATE DISK CHECK**, each only with an update floppy
   in the drive. On 4 it then offers the **SD update** if the card holds update files.
3. Interrupts and caches off, `jmp 0x48400000`.

The firmware has the same key-combination code as `PanelTypeDetect`; here the result picks the menu.

### Floppy updates

An update floppy is a 1.44 MB disk. `UpdateDiskIdentify` reads LBA 0x21 and compares its first six bytes
with thirteen kinds; the kind is also the target device (`FlashDeviceBase`):

| kind  | name                         | target                                |
|-------|------------------------------|---------------------------------------|
| 0, 1  | `KN7KP1`, `KN7KP2`           | program flash, `0x88400000` and +2 MB |
| 2, 3  | `KN7KT1`, `KN7KT2`           | table flash, `0x88000000` and +2 MB   |
| 4     | `KN7KCT`                     | custom-data flash IC21, `0x96800000`  |
| 5     | `KN7KHD`                     | `0x96000000` (expansion window)       |
| 6, 7  | `KN7KW1`, `KN7KW2`           | `0x97000000`, `0x81000000`            |
| 8, 9  | `KN7KR1`, `KN7KR2`           | CS0 `0x80000000` and +2 MB            |
| 10-12 | `KN7KDM`, `KN7KA1`, `KN7KA2` | picture window `0x97800000`           |

Kinds 8/9 write CS0 itself: on early units an IC20 flash sits where IC18 is (`0x80000000` is the
uncached view of `0x40000000`). LBA 0x22 holds the block sums as '@'-separated hex text; the image follows
from LBA 0x24 as an LZSS stream (4 KB window, 12-bit offsets, 4-bit lengths + 3, window pre-filled up to
`0xFEE`) whose 8-byte header is followed by the 24-bit size. `UpdWriteDisk` decompresses it straight into
the flash, a word at a time; `UpdVerifyDisk` only sums it against LBA 0x22 (UPDATE DISK CHECK). Images
of 2 MB (kinds 0, 2, 8) or 1 MB (kind 0xB) continue on a second disk ("Change disk(2/2)").

The flash driver has two halves: kinds 0-3 are two 16-bit chips side by side (32-bit commands,
`0x00AA00AA` at `0x1554`; Fujitsu `0x22F6/0x22F9/0x225F/0x2250`, Macronix `0xA100/0xA200`), the others one
16-bit chip (`0xAA` at `0xAAAA`; Fujitsu `0x2227..0x22F9`, Atmel `0xC0/0xC2`, Macronix `0xF9/0xA100/0xA200`).
The program flash's version is the byte at `0x4840000F`, shown as `NOW(CURRENT) = VerX.Y` beside the disk's.

### SD updates

`SdFlashUpdate` mounts the card's first FAT12 partition (its own small reader, `Fat*`) and looks for
`KN7KPRG.DAT`, `KN7KTBL.DAT`, `KN7KCSTM.DAT`, `KN7KRHY.DAT` and `KN7KAROM.DAT` (kinds 0, 2, 4, 8, 0xB).
Each found file is written uncompressed: identify, erase, write, verify, then a summary ("Update
Infomation", sic). The SD layer below it (`Sd*`, `Disk*`) is the firmware's design: the routines follow
program 941's in order and many have the same code, but there is no worker task; `DiskCmdTransact` calls
the handler directly, and the board probes the firmware makes are stand-ins here (`PanelSubTypeGet` and
`BoardClass` return 1).

### What else is inside

- The C library under `sprintf` (newlib-style `vsprintf_core`, `strtol`, `localeconv`, the double helpers;
  33 routines are byte-identical to the firmware's, 20 more the same code linked elsewhere).
- The control-panel link driver, a copy of the firmware's (`Panel*`).
- The floppy controller driver (`Fdc*`): a uPD765-family controller at `0x98020000` with DMA channel 0,
  request block of seven words, commands 0-0xB, media geometry for 720 KB, 1.2 MB (77 cylinders, 1024-byte
  sectors) and 1.44 MB disks, disk detection by index pulses.
- A text console on the LCD controller at `0x9CC00000` (frame buffer `0x9CE00000`, 640 pixels a line) with
  an 8x16 font for 0x20-0xFF, and four soft-key captions read through the panel.

### The hardware registers

Every memory operand of the code that names a device register is an `.equ` (`HW` in the generator).

- **The LCD controller** (`LCDC`, `0x9CC00000`). `[INFERENCE]` It is an Epson **S1D13506**, and its
  registers carry that chip's names (`LCDC_LCD_HDISP`, `LCDC_BLT_CTRL0`, `LCDC_LUT_DATA` ...). The
  evidence:
  - `LcdControllerInit` writes 106 registers, and every offset is an S1D13506 register. Between them it
    skips exactly that chip's reserved offsets (`0x033`, `0x037`, `0x045`, `0x049`, `0x107`, `0x116` ...).
  - Its values decode, by that chip's rules, as 640 x 240 at 16 bits a pixel: `0x032` = `0x4F`,
    `0x038` = `0xEF`, `0x040` = `0x15`, and a line offset of `0x280` words.
  - The display memory answers at +`0x200000`, where that chip's M/R# line puts it.
  - The firmware uses `0x004`/`0x005` as pin directions and `0x008`/`0x009` as pin data: the SD slot's
    sense, enable, supply and write-protect lines, and the two SD lamps. Those offsets are the chip's GPIO
    registers.
  - Not checked against a board photo.
  - On the owner's KN7000 its display memory turned out to be 1280 KB (Pinball/kn7000 PFT16 and PFT17,
    `notes/session-2026-10-26/`): words above it read 0xFFDF, and its ink layer is counted from 0x140000,
    with REG[071h] valid up to 160. Those fit the **S1D13806**, the S1D13506 with 1280 KB of memory inside
    (Epson's S1D13806 Series Technical Manual), and not the S1D13506 with its external 512 KB or 2 MB.
    `LcdControllerInit`'s clear of 0x140000 bytes fits it too. The register names stay the S1D13506's,
    which the S1D13806 shares.

  `LcdControllerInitAlt` and `LcdControllerInitOld`, which nothing calls, program other register maps.
  Their operands are spelled `LCDC+0xNN`. `[INFERENCE]` Alt's offsets and values fit the earlier S1D13505;
  Old's map is unidentified.
- **The CPU's own registers** follow the Linux mn10300 port's names wherever this board's known registers
  sit at the same offsets: `CPUM` (`0x20000040`; the NMI handler sets STOP in a loop), `TM0MD`/`TM0BR`
  (the panel link's timer 0) and `TMPSCNT`. Like `IVAR0`, `CHCTR` and `TM4MD` before them, these are
  `[INFERENCE]` names.
- **The floppy controller** at `0x98020000`: `FDC_DOR`, `FDC_MSR_DSR`, `FDC_FIFO` and `FDC_DIR_CCR`,
  two bytes apart. Its DMA data port is `FDC_DACK` (`0x98010000`).
- **The SD card's SPI port**, inside tone generator A: `SD_SPI_DATA`, `SD_SPI_CLOCK`. The power
  controller is `SD_POWER_CTRL`. `SDRAM_CTRL`/`SDRAM_REFRESH` are `[INFERENCE]` names, from the reset's
  eight refresh pulses. `PROGRAM_FLASH_VERSION` is the firmware's release byte.
- Still placeholders, with a TODO each: `UNKNOWN_32000010`, `UNKNOWN_34004002`, `TGA_04`, `TGA_10`.

The base addresses that `FlashDeviceBase` returns stay numbers; its header comment lists them. The
`notes/ic18-boot-rom-probes/leftovers.py` probe counts what is still numeric. On 2026-10-24 it found
0 numeric memory operands, down from 222. The 104 code immediates at or above `0x20000000` that it
still lists are masks, double constants, flash IDs and those device bases.

### Data not typed yet

`leftovers.py` also lists the `.byte` lines that carry no comment. It found 193 bytes under 23
labels, down from 422 bytes before the CRC7 table and `FatMountFailImage` were typed. All of them sit
under a named label, and most of those labels carry a comment. Open items:

- `LcdOldPaletteA`/`B`: 32 bytes each, which `LcdControllerInitOld` writes to every other register from
  `+0x20` and `+0x60`. What their entries mean depends on that unidentified map.
- `OldDataImage`: 36 bytes, the older link's `.data`. Nothing in this ROM reads it.
- `LocaleNumericC` (12 bytes) and `LocaleMonetaryC` (8 bytes): the byte fields that follow the C library's
  "C" locale strings. Their struct layout is not typed.
- The `.data` variables of one or two bytes (`FdcMotorState`, `SdPowerShadow`, `TickPhase2` ...): the
  bytes that pad them to a word are not zero. They look like leftovers in the linked image, and nothing
  reads them.
- `FatMountFailImage` is typed by the variables it lands on. What its numbers were meant to be is still
  a TODO (they describe 32-byte sectors and no FAT).

### The older link

Bytes `0x0011-0x03FF` are from an earlier link of the same program that the new one did not overwrite:
the end of its NMI handler, its own Reset (`OldReset`: the same bus set-up, its program image copied by a
descriptor at `0x4000BBB4`, `.bss` at `0x50180024`), its cache routines, and between them its `.data` image
(`0x40-0x63`). Nothing in this ROM reaches them; their targets outside these bytes are that link's
addresses (`OldLink_*` in the source), not this image's. The last routine is cut off at `0x400`, where the
new `.data` image starts.

### How the source is made

`tools/gen_ic18_s.py` decodes with unidasm at each byte's run address, by recursive descent from the
vectors, the two thunks and BootMain, through the 12 indirect transfers (four `switch` tables, three hashed
`{key, handler}` tables, the interrupt handler table, a table of 11 routine pointers, a routine-pointer
variable), then decodes every gap in a code range as unreferenced code. It keeps a mnemonic only if
`tools/mn10300_asm.py` re-encodes the exact bytes (11 immediates need a `:16`/`:32` width). A routine with
a prologue is named at its `movm`; `call` enters past it, at `NAME_entry`. Names come from
`kn7000_ic18.sym`, then from the firmware; `notes/ic18-boot-rom-probes/digest.py` prints the evidence per
routine and `placeholders.py` what is still unnamed (only branch targets and the older link's addresses).

## The rest of IC18: rhythm data

From `0x10000` the chip holds the style data the firmware reads: the `"Technics Rhythms"` header at
`0x40010000`, which the firmware's probe finds at its third candidate address. The 16-bit word at `+0x10`
(`0xE2DA`) is the big-endian word sum of the `0x100000` words from `0x110000`, and the byte at `+0x2A` is
220, the number of styles; `"jkr_33.ssf"` at `0x3FFFE8` is the version the SP7001 DEBUG TOOLS screen
shows as RHYTHM 33 (`ic18_layout.py` recomputes these). That part is data only; a byte-exact target for
the whole 4 MB is not done: it would be one `.incbin` until the style format is typed.

## Probes

[`ic18-boot-rom-probes/`](ic18-boot-rom-probes/README.md).
