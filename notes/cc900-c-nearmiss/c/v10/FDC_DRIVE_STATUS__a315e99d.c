/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_COMMAND_INDEX;
int FDC_DRIVE_STATUS(void)
{
	if (FDC_REQ_COUNT != 0xffff) return 0;
	if (FDC_COMMAND_INDEX != 0) return 0;
	return -1;
}
