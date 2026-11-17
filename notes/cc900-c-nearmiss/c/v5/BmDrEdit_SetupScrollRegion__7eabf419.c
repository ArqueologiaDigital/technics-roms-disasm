/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines.c (2026-11-16-38-p6-r6)
   sha256 7eabf419ac97e9e3d2bcfb5216cada2decb6f61f13941bb3fc81c3bf68078919 (tar-sha256); compiled at -Xr
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
