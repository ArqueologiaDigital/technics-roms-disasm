KN7000 DSP probe, phase 2: the effects DSP's memory, read back (2026-10-20)
==========================================================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME (cnv_romdump README.md, "Results").

  sdcard-pass7-DSPMEM/KN7APP.BIN    phase 2 of the DSP probe: reads the effects DSP's memory back
  check_dsp_probe.py,               decode on the computer what came back; with --program and your
  check_real_dump.py, find_fw.py,   pass1-run1 folder it compares it with what the firmware loaded
  find_rhythm.py

Run this only after phase 1 (pass 6) has come back and been looked at, and only when asked to.

The floppy is the same as for passes 1 to 6: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the floppy you already have, with its write-protect tab at PROTECTED.

What this is. Phase 1 read the effects DSP's control registers. This one reads part of its memory: the
program the firmware loaded into it at power-up (program memory 0x8000-0x8DFF) and its working data
(data memory 0x9800-0x9FFF and 0xC000-0xC4FF), plus the small blocks that steer its audio transfers.

What it does to the instrument. Like phase 1, it uses the firmware's own DSP routines. Unlike phase 1,
it has to write four of the DSP's registers: the ones of the transfer channel the firmware itself uses
to load the DSP, run here the other way round (from the DSP's memory to the main CPU).
  - Written: DMAC0 (the channel's control), IIEP0 (where to start), IMEP0 (step, 1) and CEP0 (how
    many words). Nothing else: no other DSP register, and never the DSP's memory.
  - Before it starts it checks that the DSP is set up the way the firmware sets it up, and that the
    channel is idle. If not, it writes nothing at all and says so in its files.
  - It reads each word only when the DSP says one is ready, and gives up after a while if none comes:
    a read the DSP cannot answer would freeze the instrument (switching off would then be the cure).
  - At the end it puts the four registers back as it found them.
  - Switching off and on undoes anything it could have left: at every power-up the firmware resets
    the DSP and loads it again, and writes those four registers anew.
  - The sound may click while it reads; nothing else should be audible.

Before
  1. As always: back up the SD card (the whole card as an image) if you have not since pass 6.
  2. The card needs about 50 KB free. Remove the pass 6 files (DSP*.BIN, DUMPLIST.TXT) from its root.

On the instrument
  3. Copy sdcard-pass7-DSPMEM/KN7APP.BIN to the card's root folder, replacing the previous KN7APP.BIN.
     Eject the card properly.
  4. Switch the instrument on as usual and wait for the main screen. Insert the SD card and the
     floppy. Do not play, and do not touch the panel, during the run.
  5. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  6. The screen: the title reads "KN7000 DSP PROBE", the yellow line at the top right
     "KN7000 DSP PROBE 1.0 PHASE 2". Two files: dsp_pm.bin and dsp_dm.bin. The run takes well under a
     minute.
  7. If the screen does not change for more than a minute: photograph it, then switch the instrument
     off and on. Nothing in the instrument is changed by that; tell me what the screen showed.
  8. At "Done", photograph the screen. After about 15 s the firmware asks "Continue Next?": answer NO.
  9. Switch the instrument off and on again before playing.
 10. On the computer: copy DSPPM.BIN (21,632 bytes), DSPDM.BIN (13,984 bytes) and DUMPLIST.TXT from
     the card's root into pass7-run1/, then delete them from the card.
 11. python3 check_dsp_probe.py pass7-run1 --program pass1-run1
     Expect "everything checks out"; the status lines should read "routines found, channel 8
     registers written back", and the program memory should equal the firmware's kernel except where
     the firmware patches it while running.

Afterwards
 12. Keep pass7-run1 private (it holds the firmware's DSP program, copyrighted like the rest of the
     firmware). Tell me where it is.
