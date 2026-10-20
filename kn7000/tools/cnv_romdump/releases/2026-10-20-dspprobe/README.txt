KN7000 DSP probe, phase 1: the effects DSP, read only (2026-10-20)
==================================================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME (cnv_romdump README.md, "Results").

  sdcard-pass6-DSPPROBE/KN7APP.BIN  phase 1 of the DSP probe: looks at the effects DSP, changes nothing
  check_dsp_probe.py,               decode on the computer what came back (check_dsp_probe.py; it uses
  check_real_dump.py, find_fw.py,   the other three)
  find_rhythm.py

The floppy is the same as for passes 1 to 5: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the floppy you already have, with its write-protect tab at PROTECTED.

What this is. The KN7000's effects (reverb, chorus, the insert effects) run on a separate processor,
IC306, an Analog Devices ADSP-21065L. The main CPU loads its program at every power-up and talks to it
through a small port. This probe reads that processor's control registers and watches some of its
counters for about a second, so that the emulator can be made to behave like your instrument.

What it does to the instrument. It does not drive the DSP's port itself: it finds the firmware's own
DSP routines in your PROGRAM 893 and calls them, the same ones the firmware uses for every effect
change (with their lock, their wait for the DSP's answer and their "DSP dead" check).
  - It only reads the DSP's registers. It leaves out every register whose reading would change
    something (the DSP's data FIFOs and its audio data buffers) and every reserved address.
  - Like the firmware before every DSP access, the routines write the register number to the port's
    address latch and clear the DSP's answer interrupt; nothing else is written anywhere except the
    files on the card.
  - If the DSP stopped answering (it should not), the firmware's own routine marks it "dead": then
    effect changes are not sent to it until you switch off. The probe sees that, stops reading, and
    says so in its files. Switching off and on restores everything: the DSP is reset and loaded anew.
  - The sound may click once while the probe reads; nothing else should be audible.

Before
  1. As always: back up the SD card (the whole card as an image) if you have not since pass 5.
  2. The card needs about 50 KB free. Remove the pass 5 files (R*.BIN, DUMPLIST.TXT) from its root if
     they are still there.

On the instrument
  3. Copy sdcard-pass6-DSPPROBE/KN7APP.BIN to the card's root folder, replacing the previous
     KN7APP.BIN. Eject the card properly.
  4. Switch the instrument on as usual and wait for the main screen (the firmware loads the DSP during
     start-up; the probe needs that done). Insert the SD card and the floppy. Do not play, and do not
     touch the panel, during the run.
  5. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  6. The screen: the title reads "KN7000 DSP PROBE", the yellow line at the top right
     "KN7000 DSP PROBE 1.0 PHASE 1". Three files: dsp_host.bin, dsp_iop.bin, dsp_time.bin. The first
     seconds (before the list appears) go into finding the firmware's routines. The whole run takes
     well under a minute.
  7. If the screen does not change for more than a minute: photograph it, then switch the instrument
     off. Files already finished are complete on the card; DUMPLIST.TXT is written last.
  8. At "Done", photograph the screen. After about 15 s the firmware asks "Continue Next?": answer NO.
  9. Switch the instrument off and on again before playing.
 10. On the computer: copy DSPHOST.BIN (1,616 bytes), DSPIOP.BIN (2,160 bytes), DSPTIME.BIN (22,000
     bytes) and DUMPLIST.TXT from the card's root into pass6-run1/, then delete them from the card.
 11. python3 check_dsp_probe.py pass6-run1
     Expect "everything checks out" and, in DSPIOP.BIN's lines, "routines found" with the register
     read at 0x4840b433 (your PROGRAM 893). The report names every register and decodes what matters;
     whether its values look sane decides whether phase 2 (reading the DSP's memory) should be run.

Afterwards
 12. Send pass6-run1/ (it holds no copyrighted data, only register values and the firmware's DSP
     variables) and the photograph. Do not run phase 2 before we have looked at this.
