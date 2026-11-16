/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_1d5c;

void SeqData_SetErrorCode(unsigned char e) { if (ram_1d5c == 0) ram_1d5c = e; }
