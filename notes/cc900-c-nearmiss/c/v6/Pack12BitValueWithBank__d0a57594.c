/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/flash_floppy_handlers.c (2026-11-16-45-p6-r9)
   sha256 d0a575943eb4e24f31272a755cd698d03d7c73b8c73308c1c702f3996153ca69 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}
