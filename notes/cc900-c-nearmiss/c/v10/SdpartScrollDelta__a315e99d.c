/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -O3 -XS -Xr */
int SdpartScrollDelta(long evt, int a, int b)
{
	int r = a;

	if (evt == 0x1c00018L) goto neg;
	if (evt == 0x1c0001aL) goto down;
	if (evt == 0x1c00017L) goto up;
	if (evt != 0x1c00019L) goto zero;
	return r;
up:
	return b;
down:
	b = r;
neg:
	b = (unsigned int)b * 0xffff;
	return b;
zero:
	return 0;
}
