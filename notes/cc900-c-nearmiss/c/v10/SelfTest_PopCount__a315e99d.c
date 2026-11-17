/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -Xr */
unsigned char SelfTest_PopCount(unsigned char a)
{
	unsigned char n, i;

	n = 0;
	for (i = 0; i < 8; i++) {
		if (a & 1) n++;
		a >>= 1;
	}
	return n;
}
