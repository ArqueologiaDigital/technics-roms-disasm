/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines.c (2026-11-16-36-p6-staged-r4)
   sha256 0a80c6c2aa97bd9566cd635888cce43bab9e628581950c9723f27c3931487df1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2728;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned int __near ram_2784;
extern unsigned char WidgetData_DrawbarPositionTable[];
void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2728 & 1) {
		*a = ram_2784;
		*b = ram_2784;
		*b += 11;
		return;
	}
	*a = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2 + 1];
}
