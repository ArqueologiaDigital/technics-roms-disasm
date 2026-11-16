/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char COM_SELECT;

unsigned char GET_COMPUTER_INTERFACE_SELECTION(void) { return COM_SELECT; }
