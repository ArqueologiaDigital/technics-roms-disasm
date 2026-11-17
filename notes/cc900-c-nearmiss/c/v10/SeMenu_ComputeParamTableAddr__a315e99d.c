/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -O3 -XS -Xr */
void SeMenu_ComputeParamTableAddr(unsigned char n, unsigned char *s)
{
	unsigned char *d, *p;
	unsigned char k;

	k = n - 1;
	d = (unsigned char *)0x205f3 + (unsigned int)k * 10;
	p = s;
	s += 10;
	do *d++ = *p++; while (p < s);
}
