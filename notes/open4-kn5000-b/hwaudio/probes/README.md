# hwaudio probes (lane kn5000-b, 2026-10-31)

All MAME runs use the kn7000_mame overlay's `kn5000` driver.  The runs quoted in `../README.md` used
`/home/fsanches/compartilhado/kn5000dsp_build/kn7000` (SHA-256
`26586387a648100c164ab0d4348f78539564e4a8d48a26bc69a75a540ceb54ca`; the build tree is not a git
checkout) with ROMs from `/home/fsanches/compartilhado/technics_roms/roms` (BIOS v10 by default).
Both runners take the MAME binary as their first argument and put nvram/cfg in a fresh directory under
`$TMPDIR`, so every run is a cold boot.

| file                          | question it answers                                                                                                                                                                                                                       | run                                       |
|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `boot_timeline_tap.lua`       | At what emulated time does each boot milestone (reset, payload transfer, sub-CPU init, graphics, main loop, first screen) first execute? Signal: first opcode fetch with PC == the milestone's address (symbols/*_symbols_reference.txt). | `./run_boot_timeline.sh [MAME] [OUT]`     |
| `run_boot_timeline.sh`        | runner for the above                                                                                                                                                                                                                      |                                           |
| `boot_timeline.txt`           | output of the run quoted in the README (deterministic: four runs gave the same times)                                                                                                                                                     |                                           |
| `subcpu_130000_write_tap.lua` | What does the firmware write to the sub CPU's 0x130000 block (latch +0, data +2), when, from which PC, and does anything read it? Signal: read/write taps on :subcpu program 0x130000-0x130003.                                           | `./run_subcpu_130000_tap.sh [MAME] [OUT]` |
| `run_subcpu_130000_tap.sh`    | runner for the above                                                                                                                                                                                                                      |                                           |
| `subcpu_130000_writes.txt`    | its output: 144 writes, 0 reads in 22.8 s                                                                                                                                                                                                 |                                           |

Service-manual pages (kn5000-xel, kn5000-jy9) were read from renders, not committed (they are the
published manual's own pages):

    P=/home/fsanches/compartilhado/technics-docs/service_manual/technics_sx-kn5000.pdf
    pdftoppm -r 200 -f 35 -l 35 -png "$P" p35      # TONE GENERATOR SECTION (B): IC310, IC311, IC313
    pdftoppm -r 400 -f 35 -l 35 -x 3900 -y 900 -W 1500 -H 1500 -png "$P" dac   # IC313 / IC314 close-up
    pdftoppm -r 200 -f 39 -l 41 -png "$P" faj      # FAJ/ACP/JACK/HB (39-40), SWA (41)
    pdftoppm -r 200 -f 33 -l 34 -png "$P" cpu      # CPU SECTION (B), TONE GENERATOR SECTION (A)
    pdftoppm -r 150 -f 2 -l 2 -png "$P" spec       # specifications: OUTPUT, SPEAKERS
