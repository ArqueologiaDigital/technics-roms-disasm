/* Functions of audio/presentation_sound_nav.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned int DIAL_ENABLE;

unsigned int GetDialEnableState(void) { return DIAL_ENABLE; }
void SetDialEnable(unsigned int v) { DIAL_ENABLE = v; }
