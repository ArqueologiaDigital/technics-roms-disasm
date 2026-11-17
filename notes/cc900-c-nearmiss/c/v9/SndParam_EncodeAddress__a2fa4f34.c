/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sndparam_routines.c (2026-11-16-38-p6-r6)
   sha256 a2fa4f34bec7c57c7b637be78d5b0351cd4717e078a23aeb854fa7f5e06183d5 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b)
{
	unsigned long r;

	r = 0x8000;
	r += (unsigned int)((a & 0x3f) << 10);
	r |= b & 0x3ff;
	if (b < 0x400) return r;
	return r + 0x10000;
}
