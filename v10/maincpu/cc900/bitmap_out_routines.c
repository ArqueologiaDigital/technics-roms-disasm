/* Firmware C for functions of ui/bitmap_out_routines.s (cc900 phase 6).  Built by scripts/build/cc900_firmware_c.py:
   the cc900 reference model at -O3 -XS -Xr, no Toshiba program.  ram_8d3e is a cell the tree has not named yet
   (BitMapOut_ByteData_DiskCheck reads it back). */
extern unsigned char ram_8d3e;

void BitMapOut_StorePresetValue(unsigned char v) { ram_8d3e = v; }
