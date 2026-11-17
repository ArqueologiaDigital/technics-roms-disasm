/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4b.c (2026-11-16-40-p6-r8)
   sha256 3f9699055ea8ee760c6182765bb0c18af9ae963c90014c6f6548598332507ab7 (tar-sha256); compiled at -O3 -XS -Xr */
unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n)
{
	unsigned int i;

	for (i = 0; i < n; i++) a >>= 1;
	return a;
}
