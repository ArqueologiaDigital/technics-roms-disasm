/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_888a;
extern char ram_888c;

unsigned char GetPlayState1(void) { return ram_888a; }
unsigned char GetPlayState2(void) { return ram_888c; }
void SmfMedley_RawData(char c) { ram_888c = (c != 0); }
