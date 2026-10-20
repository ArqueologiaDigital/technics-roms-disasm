KN7000 DSP TONE 1.0: our own program on the effects DSP, iteration 1 (2026-10-20)
================================================================================

Built from technics-roms-disasm kn7000/tools/dsptone (make card-dir). SHA1SUMS lists the files; each is
byte-identical to what passed its check in MAME (dsptone README.md, "How it was checked").

  sdcard-DSPTONE/KN7APP.BIN     the program
  sdcard-DSPTONE/MANIFEST.TXT   its name in the program menu
  sdcard-DSPTONE/ICON.BMP       its icon

Copy the folder sdcard-DSPTONE to the SD card's root under the name DSPTONE (beside AW, DSPRATE, ...), or
use the menu's card (kn7menu: make card), which holds it as DSPTONE\. The floppy and the menu are the ones
you already use: KN7LOAD.CNV did not change (SHA-1 6b81f382...).

Before you start it: REVERB on (button lit), MAIN VOLUME low to moderate; play a few notes to hear the
reverb as it is.

Then DISK MENU, STYLE CONVERT, KN7LOAD.CNV, OK; in the menu the "DSP tone" row, RUN. After about 4 s of
"Looking for ..." the lines fill in and a steady 440 Hz tone plays (in MAME about 13 dB louder than a C4
note played at the default touch). Right buttons: 1 SINE, 2 CHIRP (about
2.5 s of loading, then a rising sweep once a second), 3 MUTE, 5 STOP (puts the firmware's reverb back and
says "Restored ... read back" in green), then 4 LEAVE. EXIT held 1.5 s = STOP and leave.

What it does to the instrument: it puts a small program of ours into the effects DSP, in the place of the
reverb unit's call, using the firmware's own DSP routines (lock, handshake, "DSP dead" check), and on STOP
puts the firmware's word back and reads it back. It writes nothing to IC23, the user memories or the card.
Everything it changes in the DSP is reset at the next power-up.

If anything goes wrong (a red line, no sound, effects gone after STOP): power the instrument off and on.

Please report: a photo of the screen while it plays (the "Heartbeat ... per second" line) and after STOP;
whether you heard the tone and the sweep, how loud against a note; whether the reverb was back after STOP.
