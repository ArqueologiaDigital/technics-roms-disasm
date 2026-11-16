/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. 
   cc900 keeps 31 characters of a name, and the two PrepareRender labels agree in their first 31, so the C
   names are shorter:
   cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1
   cc900-name: BitMapOut_PrepRender_CheckBit2=BitMapOut_PrepareRender_CheckBit2 */
extern unsigned char __near ram_8ca0;
extern unsigned char __near ram_8ca2;
extern unsigned char __near ram_8cac;
extern unsigned char __near ram_8cae;

unsigned char BitMapOut_ByteData_DiskCheck(void) { return ram_8ca2; }
void BitMapOut_StorePresetValue(unsigned char v) { ram_8ca2 = v; }
void BitMapOut_SetDefaultTimer(void) { ram_8ca0 = 64; }
unsigned char BitMapOut_GetRenderMode(void) { return ram_8cae; }
unsigned char BitMapOut_PrepRender_CheckBit1(void) { return ram_8cac; }
void BitMapOut_PrepRender_CheckBit2(unsigned char v) { ram_8cac = v; }
