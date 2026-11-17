/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4b.c (2026-11-16-40-p6-r8)
   sha256 3f9699055ea8ee760c6182765bb0c18af9ae963c90014c6f6548598332507ab7 (tar-sha256); compiled at -O3 -XS -Xr */
unsigned char HexCharToNibble(unsigned char a)
{
	if (a < 0x30 || a > 0x39) goto lower;
	return a - 0x30;
lower:
	if (a < 0x61 || a > 0x66) goto upper;
	return a - 0x57;
upper:
	if (a < 0x41 || a > 0x46) return 0;
	return a - 0x37;
}
