KN7000 ROM dumper: the wave ROMs (2026-10-19)
=============================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME.

  sdcard-pass3-WAVE/KN7APP.BIN   the WAVE build: the four wave ROMs, IC203, IC204, IC207, IC208 (16 MB each)
  check_real_dump.py, find_fw.py check on the computer what came back from the card

The floppy is the same as for passes 1 and 2: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the write-protected floppy you already have.

How the wave ROMs are read. They are not on the CPU's bus: the CPU reaches them only through the tone
generators' test latches, exactly as the firmware's own WAVE ROM test does (service manual 8.9). The
dumper repeats that test's accesses, bank by bank (512 banks of 32 KB per chip), switching each tone
generator into test mode for one bank and back out before it returns to the firmware. Your program
893 performs the same accesses in its own test, instruction for instruction. Nothing is written to
the wave ROMs (they are mask ROMs) or anywhere else on the instrument. The firmware knows each chip's
byte sum; the dumper compares, and marks a chip [SUM?] on the screen if its sum differs.

Before
  1. The SD card needs about 70 MB free. (Back up the card first, as before, if you like.)
  2. Remove the pass 1 / pass 2 files from the card's root if they are still there.

On the instrument
  3. Copy sdcard-pass3-WAVE/KN7APP.BIN to the card's root folder, replacing the previous KN7APP.BIN.
  4. Insert the SD card and the floppy. Do not play, and do not touch the panel, during the run:
     the tone generators spend most of it in test mode.
  5. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  6. The dumper's screen: the yellow line at the top right must read "KN7000 ROM DUMPER 1.0 WAVE".
     Four ROMs dump, six show [SKIP]. 64 MB go to the card: expect several times pass 1's duration.
  7. At "Done", photograph the screen. Each wave ROM shows [ OK ] or [SUM?]: [SUM?] means its byte
     sum differs from the one the firmware expects. After about 15 s the firmware asks "Continue
     Next?": answer NO.
  8. Switch the instrument off and on again before playing, so the tone generators start clean.
  9. On the computer: copy IC203.BIN, IC204.BIN, IC207.BIN, IC208.BIN and DUMPLIST.TXT from the
     card's root into pass3-run1/, then delete them from the card.
 10. Second run, to show the reads are stable: steps 4-9 again, into pass3-run2/.
 11. python3 check_real_dump.py pass3-run1 pass3-run2
     Expect "everything checks out": every file whole, identical in both runs, and in the last
     column "= <sum>" for all four: each chip's sum is the one the firmware expects.

Afterwards
 12. Keep the dumps private (copyrighted sample data). Tell me where they are: I will add them to the
     private ROM repository and check the byte and word order, which the sums cannot show.
