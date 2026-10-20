KN7000 pass 9: the CPU timing probe, read only (2026-10-20)
============================================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME (cnv_romdump README.md, "Pass 9").

  sdcard-pass9-CPUTIME/KN7APP.BIN   pass 9: times the main CPU and its memory, changes nothing
  check_cpu_probe.py                decode on the computer what came back (it needs nothing else)

The floppy is the same as for passes 1 to 8: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the floppy you already have, with its write-protect tab at PROTECTED.

What this is. The emulator runs your instrument's main processor (a Panasonic MN10300) at one clock
cycle per instruction and lets every memory answer at once, so programs run faster in MAME than on
the KN7000. This pass measures the real thing: how long each kind of instruction takes, and how long
the processor waits for each kind of memory (work RAM, the program flash, the custom data flash, the
battery-backed SRAM, the LCD), timed with the processor's own 2 MHz timer, the one behind the
firmware's millisecond clock. With it the emulator can run at your instrument's true speed.

What it does to the instrument. It reads, and changes nothing.
  - It reads the memory chips every earlier pass read (work RAM, program and table flash, IC18,
    IC19, IC21, IC23, the LCD picture), the processor's bus and cache settings, its timer, and the
    board's hardware-variant switch (0x98070000), which the firmware itself reads at every start.
  - It writes only to its own scratch area inside the memory the firmware sets aside for STYLE
    CONVERT, to the processor's stack, and to a few LCD pixels near the bottom of the screen, each
    with the colour it already has, so the picture does not change.
  - It never touches the effects DSP, the tone generators, the floppy or SD controllers, IC23 (only
    reads), the flash chips (only reads), or any timer, bus or cache setting (only reads).
  - It calls one small routine of your firmware that only computes (no memory, no hardware), to time
    code running from the flash; it finds it by its exact bytes and skips it if they are not there.
  - It runs with the firmware's interrupts on, like every pass before; nothing else should happen.

How long. First about two seconds while it looks for that routine in the flash. Then four steps of
under a second each, each writing 32 KB to the card. The whole run is well under a minute.

Before
  1. As always: back up the SD card (the whole card as an image) if you have not since pass 8.
  2. The card needs about 150 KB free. Remove the pass 8 files (DSPRATE.BIN, DUMPLIST.TXT) from its
     root if they are still there.

On the instrument
  3. Copy sdcard-pass9-CPUTIME/KN7APP.BIN to the card's root folder, replacing the previous
     KN7APP.BIN. Eject the card properly.
  4. Switch the instrument on as usual and wait for the main screen. Insert the SD card and the
     floppy. Do not play, and do not touch the panel, during the run.
  5. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  6. The screen: the title reads "KN7000 CPU TIMING PROBE", the yellow line at the top right
     "KN7000 CPU TIMING PROBE 1.0". One file: cpu_time.bin; its bar moves in four steps.
  7. If the screen does not change for more than a minute: photograph it, then switch the instrument
     off. Tell me what the screen showed.
  8. At "Done", photograph the screen. After about 15 s the firmware asks "Continue Next?": answer NO.
  9. Switch the instrument off and on again before playing.
 10. On the computer: make a folder pass9-run1/ in your private ROM repository, beside pass8-run1
     (technics_roms, roms/kn7000/real_dump_v1.3_b893/), not inside technics-roms-disasm. Copy
     CPUTIME.BIN (131,072 bytes) and DUMPLIST.TXT from the card's root into it, then delete them
     from the card.
 11. python3 check_cpu_probe.py <that folder>/pass9-run1 --json <that folder>/pass9-run1/cpu_time.json
     Expect "4 with the probe's header", status 0x0 in every chunk, "119 of 119 tests", the firmware
     routine at 0x48471d35 (your PROGRAM 893), a line "core clock implied by ADD: ... MHz", tables of
     ns and cycles, and at the end "everything checks out". Save the output beside the folder, as
     pass9-check-<date>.txt.

Afterwards
 12. Send pass9-run1/ (it holds no copyrighted data: timer counts and the processor's settings) and
     the photograph.
