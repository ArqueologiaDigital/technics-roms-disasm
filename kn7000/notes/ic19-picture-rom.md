# IC19, the picture ROM: the Slide Show's 100 PRESET pictures (2026-10-19)

IC19 (`C3CBMD000098`, "64M ROM" in the service manual) holds the pictures a sequencer song can
show at its PIC points: the owner's manual's **Slide Show** (pp. 77, 90-91), the PRESET pictures
0-99 next to the 30 USER slots (`kn5000-docs` `kn7000-slideshow.md`). It was read through the CPU on
the owner's KN7000 (PROGRAM 893 / TABLE 80) by the ROM dumper's IC19 build (`tools/cnv_romdump`,
`releases/2026-10-19/sdcard-pass2-IC19`), and `src/picture.s` rebuilds it byte for byte.

## What the CPU sees

The window `0x57800000`-`0x57FFFFFF` (8 MB) holds one 2 MB image four times: the four 2 MB quarters
of the read are byte-identical. The 2 MB:

| offset                | contents                                                                                        |
|-----------------------|-------------------------------------------------------------------------------------------------|
| `0x000000`-`0x000197` | 102 u32 offsets from `0x57800000`, ascending                                                    |
| `0x000198`-`0x0003FF` | zero                                                                                            |
| `0x000400`            | entry 0: the version string `"7\n"` (`37 0A 00 00`), read by the firmware as PICTURE 7          |
| `0x000404`-`0x1FF49B` | entries 1-100: PRESET 0-99, each a JFIF JPEG, 640x240, then 0-3 zero bytes to a 4-byte boundary |
| `0x1FF49C`            | entry 101: the end of the data                                                                  |
| `0x1FF49C`-`0x1FFFFF` | `0xFF`                                                                                          |

All 100 decode cleanly, all 640x240. The smallest is 6,308 bytes (PRESET 13), the largest 46,959
(PRESET 84, "Starring The KN7000!"), 2,093,050 in all (`ic19-picture-rom-probes/probe.py`).

Entry 0 is the chip's version, in the table flash's form: ASCII digits ended by a line feed. The
version-box procedure `AcAromVerBoxProc` (`0x48488A0B` in 941) loads the u32 at `0x57800000` (`0x400`),
adds the base and accumulates decimal digits from `0x57800400` while they are `'0'`-`'9'`, storing
the result at `0x50007DD0` for the `PICTURE : %4d` row: 7 for this chip. (Before that routine was
read, a 16-bit byte sum, word sum, XOR and the pictures' size were tried for `0x00000A37`; none fits,
and the probe still prints them.)

| PRESET | pictures                                                                                          |
|--------|---------------------------------------------------------------------------------------------------|
| 0-9    | landscapes: sky, snow-covered mountains, lakes, flower fields, a sunset                           |
| 10-19  | coasts, harbours, gardens and houses, fireworks                                                   |
| 20-29  | city skylines by day and by night                                                                 |
| 30-39  | streets and towns, by day and at night                                                            |
| 40-49  | interiors and still lifes                                                                         |
| 50-59  | Christmas and winter ("Merry Christmas!", "Happy Winter!", "X'mas")                               |
| 60-69  | music: a stage, a studio, saxophones, drums, violins, timpani, a Technics keyboard and turntables |
| 70-79  | animals                                                                                           |
| 80-89  | title cards, listed below                                                                         |
| 90-99  | the numbers 1 to 10                                                                               |

The title cards, PRESET 80-89: "Ladies and Gentlemen!", "Welcome to my song", "Made with Love",
"A Musical Present for You", "Starring The KN7000!" (with a picture of the instrument), "Party
Time!", "Herzlich Willkommen!", "Das Musikfest", "Auf Wiedersehen", "Prost!".

## How the firmware reads it (PROGRAM 941)

- A PIC point becomes picture code `0x8000 + n` for PRESET n. At `0x48580A14`-`0x48580A46` the
  slide-show screen's routine (`0x4858099B`) takes `n + 1`, reads `u32[0x57800000 + 4 * (n + 1)]` and
  draws the JPEG at `0x57800000` plus that offset (`0x48580A38` is the only immediate load of
  `0x57800000` in 941, `0x4857F783` in 893).
- The check at `0x48580ABE`-`0x48580AC4` accepts `n < 0x64`, so exactly the 100 pictures of the
  directory. Nothing switches a bank before the read, so the firmware never looks past `0x1FF49C`.

## Why 2 MB of a 64 Mbit chip

Service manual p.102 ("SX-KN7000 MAIN 1/5 SCHEMATIC DIAGRAM (2/2)"):

- IC19 runs in 16-bit mode (BYTE tied high), its data on `D(16)`-`D(31)`.
- CPU `A(1)`-`A(21)` drive its AD0-AD20.
- Its top address pin, AD21 (pin 12), goes through jumper JP10 to ground (the net from C37's ground
  side). So the CPU reaches only the AD21-low half, 4 MB.
- In that half the read shows the same 2 MB twice: the chip's AD20 (`A(21)`) changes nothing.
- The AD21-high half (4 MB) is out of the CPU's reach: no read through the CPU can see it, and it may
  hold anything. Only a chip reader could tell. The instrument never sees it either.

## For MAME

The driver declares `c3cbmd000098.ic19` as `0x800000` `NO_DUMP` in region `picture` and does not map
`0x57800000` yet. Since the window is exactly four copies, the plan is to declare the 2 MB image
(CRC-32 `3372cb5c`, SHA-1 `9631dedfc501b8c11bb93efa2d99750e3c84465a`) and map it with MAME's mirror
(`map(0x57800000, 0x579fffff).mirror(0x600000).rom().region("picture", 0)`), noting that the chip's
other half is unreachable.

Done on 2026-10-19 as branch `technics-kn7000-picrom` (`bca52650007`; KN7000
`tools/mame-pr-planning/kn7000-picrom-pr/`). There `picture_check.sh` reads `0x57800000`-`0x57FFFFFF` through
the emulated CPU after boot, and the result is byte-identical to the instrument's 8 MB read.

## Read twice

A second read on the same instrument, later the same day, was byte-identical to the first: the 8 MB
file and the instrument's `DUMPLIST.TXT` both (`check_real_dump.py first second`: "identical"; kept as
`pass2-run2/` beside the first in the private ROM repository).

## Open

- ~~Whether that instrument's SOFT VERSION screen shows `PICTURE : 7`.~~ Answered 2026-10-19: that screen
  shows only PROGRAM and TABLE (owner; MAME agrees). PICTURE is a row of the DEBUG TOOLS screen's version box
  (SP7001 only), which prints 7 in MAME with the ROM mapped (KN7000 `tools/mame-pr-planning/kn7000-picrom-pr/`).
- Whether IC19 differs between production runs; this read is from an early (PROGRAM 893) instrument.

## Reproduce

    make verify-picture                     # rebuild from src/picture.s + src/picture/*.jpg, check the SHA-1
    make picture-src PICTURE_REF=<IC19.BIN> # regenerate the source and the 100 JPEGs from a read

`PICTURE_REF` defaults to the read itself, kept in the private ROM repository
(`technics_roms` `roms/kn7000/real_dump_v1.3_b893/pass2-run1/IC19.BIN`, with its analysis scripts in
`ic19-analysis/`).
