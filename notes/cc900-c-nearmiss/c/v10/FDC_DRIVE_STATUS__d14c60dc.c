/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdc_routines_xr.c (2026-11-16-45-p6-r9)
   sha256 d14c60dc63065cbea79ab82b671b556151e931c5680eb5adc1878b4c3394bf7d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_COMMAND_INDEX;
int FDC_DRIVE_STATUS(void)
{
	if (FDC_REQ_COUNT != 0xffff) return 0;
	if (FDC_COMMAND_INDEX != 0) return 0;
	return -1;
}
