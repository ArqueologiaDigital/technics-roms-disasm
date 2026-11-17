/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga.c (2026-11-16-55-p6-r10)
   sha256 69cfebfca3d96eb693bdd47e9fa743b089974c6fec4fb0a8e24fcee70dbf23ef (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned char HexCharToNibble(unsigned char a)
{
	if (a >= 0x30 && a <= 0x39) return a - 0x30;
	if (a >= 0x61 && a <= 0x66) return a - 0x57;
	if (a >= 0x41 && a <= 0x46) return a - 0x37;
	return 0;
}
