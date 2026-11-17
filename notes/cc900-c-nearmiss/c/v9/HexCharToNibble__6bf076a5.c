/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/graphics_text_vga.c (2026-11-16-45-p6-r9)
   sha256 6bf076a5c28046dcbb9a56457a016223a2be57ad8439b7b2e97d96984741c1cf (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned char HexCharToNibble(unsigned char a)
{
	if (a >= 0x30 && a <= 0x39) return a - 0x30;
	if (a >= 0x61 && a <= 0x66) return a - 0x57;
	if (a >= 0x41 && a <= 0x46) return a - 0x37;
	return 0;
}
