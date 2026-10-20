KN7000 ROM dumper: everything still to read, in one run (2026-10-20)
====================================================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME (cnv_romdump README.md, "Results").

  sdcard-pass5-SURVEY2/KN7APP.BIN  the SURVEY2 build: 14 windows of CPU address space, 54 MB in all
  check_real_dump.py, find_fw.py,  check on the computer what came back from the card, and compare it
  find_rhythm.py                   with passes 1 and 4

The floppy is the same as for passes 1 to 4: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the floppy you already have, with its write-protect tab at PROTECTED.

What this run reads. Fourteen windows, one file each, in this order:

  file          bytes      CPU window              what
  R4000000.BIN  8,388,608  0x40000000-0x407FFFFF   pass 4's six windows again, the same files: the
  R4080000.BIN  8,388,608  0x40800000-0x40FFFFFF   second read of the rhythm ROM (IC18), and of
  R5400000.BIN  8,388,608  0x54000000-0x547FFFFF   IC21 and IC19 through CS5, to compare byte for
  R5480000.BIN  8,388,608  0x54800000-0x54FFFFFF   byte with pass4-run1
  R5500000.BIN  8,388,608  0x55000000-0x557FFFFF
  R5580000.BIN  8,388,608  0x55800000-0x55FFFFFF
  R8400000.BIN  2,097,152  0x84000000-0x841FFFFF   IC23, the battery-backed memory with your panel
                                                   memories and settings (256 KB; 2 MB shows whether
                                                   it repeats)
  R5018000.BIN  1,146,880  0x50180000-0x50297FFF   the work memory the instrument keeps: songs,
                                                   COMPOSER styles, performance pads
  R4C00000.BIN    262,144  0x4C000000-0x4C03FFFF   the library the firmware copies from its own
                                                   program flash at power-on (a cross-check)
  R5680000.BIN  2,097,152  0x56800000-0x569FFFFF   IC21 again, perhaps (pass 1 read it at 0x96800000)
  R4100000.BIN     65,536  0x41000000-0x4100FFFF   the four expansion board slots, empty on your
  R4180000.BIN     65,536  0x41800000-0x4180FFFF   instrument: what an empty slot reads. The firmware
  R5600000.BIN     65,536  0x56000000-0x5600FFFF   itself looks at these four at every power-on
  R5700000.BIN     65,536  0x57000000-0x5700FFFF
  DUMPLIST.TXT  about 2 KB                         sizes and checksums, written at the very end

What it does to the instrument. It only reads, with ordinary CPU reads of memory, like the earlier
passes; no I/O register is read or written, and the tone generators are not touched. Nothing is
written anywhere except the files on the card. In particular IC23 (your panel memories) is only
read. The service manual's schematic shows that IC23's chip select (CS1, the window the firmware
calls 0x44000000) goes to IC23 and nothing else, so reading 2 MB there reads IC23 and its mirrors
only. The dumper reads it at 0x84000000, the uncached view of the same window, which is the one the
firmware itself reads and writes IC23 through: the copy is what is in the chip, with no cache in
between.

Before
  1. Back up the SD card on the computer, the whole card as an image, as before pass 1:
       lsblk                                   (find the card, e.g. /dev/sdX -- check the size!)
       sudo dd if=/dev/sdX of=kn7000-sdcard-backup.img bs=1M status=progress
  2. The SD card needs about 60 MB free (56.2 MB of files). The copy of your card we have is a
     128 MB card with 126 MB free, so there is room once the pass 4 files are off it.
  3. Remove the pass 4 files (R4000000.BIN ... R5580000.BIN, DUMPLIST.TXT) from the card's root if
     they are still there; this run writes files of the same names. Keep pass4-run1/ on the computer:
     it is what this run is compared with.
  4. Optional, as before any experiment: save your panel memories / settings the usual way.

On the instrument
  5. Copy sdcard-pass5-SURVEY2/KN7APP.BIN to the card's root folder, replacing the previous
     KN7APP.BIN. Eject the card properly.
  6. Insert the SD card and the floppy. Do not play, and do not touch the panel, during the run.
  7. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  8. The dumper's screen: the yellow line at the top right must read "KN7000 ROM DUMPER 1.0 SURVEY2".
     The list has 14 lines in two columns, survey_40000000.bin to survey_57000000.bin, none [SKIP];
     the counter reads "ROM n/14". 54 MB go to the card: about 1.1 times as long as pass 4 took.
  9. If the progress bar stops moving for more than a minute: photograph the screen (the "ROM n/14"
     line says which window), then switch the instrument off. Nothing but the card has been written.
     Every window before that one is complete on the card; only DUMPLIST.TXT is missing, because it
     is written at the end. Copy what is there as in step 11 and tell me which window it was. The
     expansion slot windows are last for this reason.
 10. At "Done", photograph the screen. After about 15 s the firmware asks "Continue Next?":
     answer NO.
 11. On the computer: copy the 14 R*.BIN files and DUMPLIST.TXT from the card's root into
     pass5-run1/, then delete them from the card.
     One run is enough: it is itself the second read of pass 4. (A second SURVEY2 run would not be
     identical anyway: IC23 and the work memory hold live data that the instrument changes.)
 12. python3 check_real_dump.py pass5-run1 --pass4 pass4-run1 --pass1 pass1-run1
     (with the real paths of those three folders). Expect "everything checks out":
     - every file whole (size and CRC-32 = what the instrument computed);
     - "second read of the pass 4 windows": every window "identical" to pass4-run1. A window marked
       "differs only where pass 4 read open bus" is fine too: nothing answers there, and what the
       bus floats to need not repeat. A "D" in its slice map would be a real difference;
     - then what was found: whether IC23 repeats every 256 KB, whether IC21 answers at 0x56800000,
       where the library comes from in the program flash, and what the empty slots read.

Afterwards
 13. Keep the dumps private: IC23 and the work memory hold your own panel memories, songs and
     settings, and the rest is copyrighted. Tell me where they are and I will add them to the private
     ROM repository next to passes 1-4.
