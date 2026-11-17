/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/flash_floppy_handlers.c (2026-11-16-45-p6-r9)
   sha256 369f65501346577a47cd56a8f2b71e9a7f31890f03e9b992bf80eeb8773cbfdb (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}
