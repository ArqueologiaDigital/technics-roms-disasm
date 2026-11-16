/* Firmware C for functions of file_io/medley.s (cc900 phase 6).  Built by scripts/build/cc900_firmware_c.py:
   the cc900 reference model at -O3 -XS -Xr, no Toshiba program.  ram_8944 is a cell the tree has not named yet
   (GetPlayState2 reads it). */
extern char ram_8944;

void SmfMedley_RawData(char c) { ram_8944 = (c != 0); }
