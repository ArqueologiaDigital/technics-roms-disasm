/* Functions of sequencer/seq_event_playback.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_7f40;

unsigned char AccPlay_GetCurrentPart(void) { return ram_7f40; }
