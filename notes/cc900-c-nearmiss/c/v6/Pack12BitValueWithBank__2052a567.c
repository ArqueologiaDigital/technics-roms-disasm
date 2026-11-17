/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/flash_floppy_handlers.c (2026-11-16-55-p6-r10)
   sha256 2052a567040ae4891326bec758cdc63a742aa3788a305f28bd6878a3402cf9de (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}
