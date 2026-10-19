KN7000 ROM dumper: the first runs on a real instrument (2026-10-19)
===================================================================

Built from kn7000_disassembly commit f673f55, tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed the final tests in MAME (that directory's README.md, "Results").

  floppy/kn7load_floppy.img          the loader on a blank disk the KN7000 formatted (1.44 MB image)
  floppy/KN7LOAD.CNV                 the same loader as a plain file
  sdcard-pass1-SAFE/KN7APP.BIN       pass 1: program flash, table flash, IC21               (about 10 MB)
  sdcard-pass2-IC19/KN7APP.BIN       pass 2: the picture flash window, IC19                  (8 MB)
  sdcard-FULL-not-yet/KN7APP.BIN     everything incl. the wave ROMs -- set aside for now, do not use
  check_real_dump.py, find_fw.py     check on the computer what came back from the card

Both passes read with plain CPU reads only, and write plain files (8.3 names, plus DUMPLIST.TXT) to the
SD card's root folder through the firmware's own file open / write / close -- nothing else: no folder, no
long names, no raw sector access, no tone generator registers. Nothing on the instrument is written: the
flash chips are only read, and RAM use stays in the area the firmware reserves for style converters.
The floppy is the same for both passes; only KN7APP.BIN on the card changes.

Pass 2 is separate because only the start of the picture window is known for sure (the firmware's own
picture code uses 0x57800000); its 8 MB extent is an assumption. If that pass misbehaves, pass 1's
files are already safe on the computer.

Before
  1. Back up the SD card on the computer, the whole card as an image, e.g. on Linux:
       lsblk                                   (find the card, e.g. /dev/sdX -- check the size!)
       sudo dd if=/dev/sdX of=kn7000-sdcard-backup.img bs=1M status=progress
     If anything goes wrong, writing that image back restores the card exactly.
     The card needs about 11 MB free.
  2. The floppy: either format a 1.44 MB disk on the KN7000 (DISK MENU > FORMAT) and copy
     floppy/KN7LOAD.CNV onto it from the computer, or write floppy/kn7load_floppy.img to a disk
     (sudo dd if=kn7load_floppy.img of=/dev/sdY bs=512 conv=fsync -- again, check the device).
     Then slide the floppy's write-protect tab to PROTECTED: the instrument only needs to read it.
  3. Optional, as before any experiment: save your panel memories / settings the usual way.

Pass 1 (SAFE), on the instrument
  4. Copy sdcard-pass1-SAFE/KN7APP.BIN to the card's root folder. Eject the card properly.
  5. Insert the SD card and the floppy. Do not play or touch the panel during the run.
  6. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  7. The loader's screen ("KN7000 SD APP LOADER") comes first. When all goes well it is gone within a
     second, replaced by the dumper's; what it found is written to DUMPLIST.TXT anyway.
     - If it stays, with a red message (e.g. "No file routines found"), photograph that screen and
       stop: nothing was written. Send the photo; its last line ("search: fmm table shapes found N,
       file code steps N of 5") says how far the search got. After about 15 s the firmware asks
       "Continue Next?": answer NO.
     - If the firmware's clock is not found, the end screens are held by a delay loop instead: about
       15 s in MAME, perhaps a little more or less on the instrument. Harmless either way.
  8. Then the dumper's screen. Check that the yellow line under PROGRAM / TABLE at the top right reads
     "KN7000 ROM DUMPER 1.0 SAFE". Each ROM's name, address range and progress bar follow. Five ROMs
     dump, five show [SKIP]. Expect a few minutes; the card sets the pace.
  9. At "Done", photograph the screen (the CRC-32 list). After about 15 s the firmware asks
     "Continue Next?": answer NO.
 10. On the computer: copy PRGEVEN.BIN, PRGODD.BIN, TBLEVEN.BIN, TBLODD.BIN, IC21.BIN and DUMPLIST.TXT
     from the card's root into a folder pass1-run1/, then delete them from the card.
 11. Second run, to show the reads are stable: steps 5-10 again, into pass1-run2/.
 12. python3 check_real_dump.py pass1-run1 pass1-run2
     Expect "everything checks out": every file whole (size and CRC-32 = what the instrument computed),
     identical in both runs. On 893 the program and table will say "new: not in our set" -- that is the
     point -- and the script prints the build numbers read from the image itself.

Pass 2 (IC19), only after pass 1 is safely on the computer
 13. Copy sdcard-pass2-IC19/KN7APP.BIN to the card's root, replacing pass 1's KN7APP.BIN.
 14. Steps 5-9 again. The yellow line reads "KN7000 ROM DUMPER 1.0 IC19"; one ROM dumps (8 MB), nine
     show [SKIP].
 15. Copy IC19.BIN and DUMPLIST.TXT into pass2-run1/, delete them from the card; run once more into
     pass2-run2/, then:  python3 check_real_dump.py pass2-run1 pass2-run2

Afterwards
 16. Keep the dumps private (the technics_roms rule: do not publish, do not push). Tell me where they are
     and I will add them to the private ROM repository and look at what IC19 holds.
