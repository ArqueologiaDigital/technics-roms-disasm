/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -Xr */
unsigned char HexCharToNibble(unsigned char a)
{
	if (a >= 0x30 && a <= 0x39) return a - 0x30;
	if (a >= 0x61 && a <= 0x66) return a - 0x57;
	if (a >= 0x41 && a <= 0x46) return a - 0x37;
	return 0;
}
