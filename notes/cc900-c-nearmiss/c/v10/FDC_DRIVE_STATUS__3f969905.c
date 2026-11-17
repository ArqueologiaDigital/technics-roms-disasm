/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4b.c (2026-11-16-40-p6-r8)
   sha256 3f9699055ea8ee760c6182765bb0c18af9ae963c90014c6f6548598332507ab7 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_COMMAND_INDEX;
int FDC_DRIVE_STATUS(void)
{
	if (FDC_REQ_COUNT != 0xffff) return 0;
	if (FDC_COMMAND_INDEX != 0) return 0;
	return -1;
}
