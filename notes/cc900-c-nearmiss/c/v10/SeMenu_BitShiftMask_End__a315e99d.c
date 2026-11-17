/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -O3 -XS -Xr */
unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n)
{
	unsigned char r = a;
	unsigned int i;

	for (i = 0; i < n; i++) r >>= 1;
	return r;
}
