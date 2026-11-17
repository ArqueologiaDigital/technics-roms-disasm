/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/flash_floppy_handlers_m159.c (2026-11-16-68-p6-r12)
   sha256 f298cf58f1e95017152f8f428de512d851044cb54b5fa7524a5e6601f38af3d0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}
