/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_8d3c, ram_8d3e, ram_8d48, ram_8d4a;

unsigned char BitMapOut_ByteData_DiskCheck(void) { return ram_8d3e; }
void BitMapOut_StorePresetValue(unsigned char v) { ram_8d3e = v; }
void BitMapOut_SetDefaultTimer(void) { ram_8d3c = 64; }
unsigned char BitMapOut_GetRenderMode(void) { return ram_8d4a; }
unsigned char BitMapOut_PrepareRender_CheckBit1(void) { return ram_8d48; }
void BitMapOut_PrepareRender_CheckBit2(unsigned char v) { ram_8d48 = v; }
