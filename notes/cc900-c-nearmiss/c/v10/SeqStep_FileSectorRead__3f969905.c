/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4b.c (2026-11-16-40-p6-r8)
   sha256 3f9699055ea8ee760c6182765bb0c18af9ae963c90014c6f6548598332507ab7 (tar-sha256); compiled at -Xr */
unsigned int __cdecl SeqStep_FileSectorRead(unsigned char **pp)
{
	unsigned int lo, hi;

	lo = *(*pp)++;
	hi = *(*pp)++;
	hi <<= 8;
	return lo + hi;
}
