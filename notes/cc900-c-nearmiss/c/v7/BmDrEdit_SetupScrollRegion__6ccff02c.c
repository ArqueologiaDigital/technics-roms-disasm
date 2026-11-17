/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines.c (2026-11-16-36-p6-staged-r4)
   sha256 6ccff02c29ea8be09a54b2140dd45429716c2e8fd292df31a7d16b6e568bf79f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned int __near ram_279e;
extern unsigned char WidgetData_DrawbarPositionTable[];
void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2742 & 1) {
		*a = ram_279e;
		*b = ram_279e;
		*b += 11;
		return;
	}
	*a = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2 + 1];
}
