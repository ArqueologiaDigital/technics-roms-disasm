KN7000 DSP probe, pass 8: the effects DSP's frame rate, read only (2026-10-20)
=============================================================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME (cnv_romdump README.md, "Pass 8").

  sdcard-pass8-DSPRATE/KN7APP.BIN   pass 8 of the DSP probe: times the effects DSP's answers, changes nothing
  check_dsp_probe.py,               decode on the computer what came back (check_dsp_probe.py; it uses
  check_real_dump.py, find_fw.py,   the other three)
  find_rhythm.py

The floppy is the same as for passes 1 to 7: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the floppy you already have, with its write-protect tab at PROTECTED.

What this is. Pass 6 showed that the effects DSP (IC306) answers the main CPU at a steady pace, about
41 times per millisecond. The firmware's millisecond clock, which pass 6 used, is too coarse to say
whether the DSP's audio frames run at about 22.5 kHz with nearly two answers per frame, or at 44.1 kHz
with one. This pass times the same answers with the main CPU's own fine timer, the one behind that
millisecond clock (it counts at 2 MHz), and watches one pointer the DSP's program keeps (MSGR2) for
3 seconds. With that the emulator can run the effects at your instrument's rate.

What it does to the instrument. The same as pass 6: it reads, and changes nothing.
  - It does not drive the DSP's port itself: it calls the firmware's own DSP routines in your PROGRAM
    893, the ones the firmware uses for every effect change (with their lock, their wait for the DSP's
    answer and their "DSP dead" check).
  - It reads three of the DSP's registers: MSGR2, and two counters of its audio transfers (CR0A,
    IIR0A). Pass 6 read all three already. 11,056 data reads in all; pass 6 made 10,056.
  - Like the firmware before every DSP access, the routines write the register number to the port's
    address latch and clear the DSP's answer interrupt; nothing else is written anywhere except the
    file on the card. The main CPU's timer is only read, never written.
  - If the DSP stopped answering (it did not in pass 6), the firmware's own routine marks it "dead":
    then effect changes are not sent to it until you switch off. The probe checks that before every
    read, stops, and says so in its file. Switching off and on restores everything.
  - The sound may click once while the probe reads; nothing else should be audible.

How long. The measuring takes about 4 seconds, in four steps of at most a second each; with finding
the firmware's routines and writing the file, the whole run is well under a minute.

Before
  1. As always: back up the SD card (the whole card as an image) if you have not since pass 7.
  2. The card needs about 150 KB free. Remove the pass 7 files (DSPPM.BIN, DSPDM.BIN, DUMPLIST.TXT)
     from its root if they are still there.

On the instrument
  3. Copy sdcard-pass8-DSPRATE/KN7APP.BIN to the card's root folder, replacing the previous
     KN7APP.BIN. Eject the card properly.
  4. Switch the instrument on as usual and wait for the main screen (the firmware loads the DSP during
     start-up; the probe needs that done). Insert the SD card and the floppy. Do not play, and do not
     touch the panel, during the run.
  5. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  6. The screen: the title reads "KN7000 DSP PROBE", the yellow line at the top right
     "KN7000 DSP PROBE 1.0 RATE". One file: dsp_rate.bin; its bar moves in four steps.
  7. If the screen does not change for more than a minute: photograph it, then switch the instrument
     off. Tell me what the screen showed.
  8. At "Done", photograph the screen. After about 15 s the firmware asks "Continue Next?": answer NO.
  9. Switch the instrument off and on again before playing.
 10. On the computer: make a folder pass8-run1/ in your private ROM repository, beside pass6-run1
     (technics_roms, roms/kn7000/real_dump_v1.3_b893/), not inside technics-roms-disasm. Copy
     DSPRATE.BIN (131,072 bytes) and DUMPLIST.TXT from the card's root into it, then delete them
     from the card.
 11. python3 check_dsp_probe.py <that folder>/pass8-run1
     Expect "everything checks out", "routines found" with the register read at 0x4840b433 (your
     PROGRAM 893), "TM4 counts down from 2000 to 0", and at the end a VERDICT and a line
     "verdict: a", "verdict: b" or "verdict: neither". Save the output beside the folder, as
     pass8-check-<date>.txt.

Afterwards
 12. Send pass8-run1/ (it holds no copyrighted data: timer values and three DSP registers) and the
     photograph.
