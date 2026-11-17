/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_PROBE_FLAG;
extern unsigned int __near FDC_REQ_SECTOR;
int FDC_DETECT_CHECK(void)
{
	if (FDC_REQ_TRACK != 0) return 0;
	if (FDC_REQ_HEAD != 0) return 0;
	if (FDC_COMMAND_INDEX != 3) return 0;
	if (FDC_REQ_COUNT != 1) return 0;
	if (FDC_PROBE_FLAG != 0xffff) return 0;
	return FDC_REQ_SECTOR == 1 ? -1 : 0;
}
