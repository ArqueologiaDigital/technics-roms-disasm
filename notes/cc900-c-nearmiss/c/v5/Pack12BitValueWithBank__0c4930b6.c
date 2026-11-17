/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/flash_floppy_handlers_m159.c (2026-11-16-68-p6-r12)
   sha256 0c4930b62d4170a3448e43a98414b837ee3077184bfbd732531d9323a1d25c67 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}
