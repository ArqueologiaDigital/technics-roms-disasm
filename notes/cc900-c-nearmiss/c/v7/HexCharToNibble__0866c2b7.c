/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/graphics_text_vga_m274.c (2026-11-16-68-p6-r12)
   sha256 0866c2b7aa868d3bcc2c8cf87e8cc42c575974fa788641d4bad8b27d424f2f1d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned char HexCharToNibble(unsigned char a)
{
	if (a >= 0x30 && a <= 0x39) return a - 0x30;
	if (a >= 0x61 && a <= 0x66) return a - 0x57;
	if (a >= 0x41 && a <= 0x46) return a - 0x37;
	return 0;
}
