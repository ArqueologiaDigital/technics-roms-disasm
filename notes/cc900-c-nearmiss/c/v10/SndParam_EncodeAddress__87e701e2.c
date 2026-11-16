/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3b.c (2026-11-16-37-p6-r5)
   sha256 87e701e28dc0ffe6e2c00b6fe7f01531d2c1c5e103ce52a0a7404b5d93a5dc63 (tar-sha256); compiled at -O3 -Xr */
unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b)
{
	unsigned long r;

	r = 0x8000 + (unsigned long)((a & 0x3f) << 10);
	r |= (unsigned long)(b & 0x3ff);
	if (b >= 0x400) r += 0x10000;
	return r;
}
