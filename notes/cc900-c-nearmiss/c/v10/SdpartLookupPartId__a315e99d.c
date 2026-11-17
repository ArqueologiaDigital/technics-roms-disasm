/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -O3 -XS -Xr */
int SdpartLookupPartId(unsigned int *p, unsigned int v)
{
	int n = 0;

	while (*p != 0xffff) {
		if (*p == v) break;
		p++;
		n++;
	}
	if (*p != 0xffff) return n;
	return -1;
}
