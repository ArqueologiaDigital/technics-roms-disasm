/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_8c84, ram_8c86, ram_8c90, ram_8c92;

unsigned char BitMapOut_ByteData_DiskCheck(void) { return ram_8c86; }
void BitMapOut_StorePresetValue(unsigned char v) { ram_8c86 = v; }
void BitMapOut_SetDefaultTimer(void) { ram_8c84 = 64; }
unsigned char BitMapOut_GetRenderMode(void) { return ram_8c92; }
unsigned char BitMapOut_PrepareRender_CheckBit1(void) { return ram_8c90; }
void BitMapOut_PrepareRender_CheckBit2(unsigned char v) { ram_8c90 = v; }
