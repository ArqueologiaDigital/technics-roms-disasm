/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_8ca0, ram_8ca2, ram_8cac, ram_8cae;

unsigned char BitMapOut_ByteData_DiskCheck(void) { return ram_8ca2; }
void BitMapOut_StorePresetValue(unsigned char v) { ram_8ca2 = v; }
void BitMapOut_SetDefaultTimer(void) { ram_8ca0 = 64; }
unsigned char BitMapOut_GetRenderMode(void) { return ram_8cae; }
unsigned char BitMapOut_PrepareRender_CheckBit1(void) { return ram_8cac; }
void BitMapOut_PrepareRender_CheckBit2(unsigned char v) { ram_8cac = v; }
