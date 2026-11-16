/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines.c (2026-11-16-38-p6-r6)
   sha256 e326fe50c6f03af25c3d084501ab00e7f02ca00ebf3f217689e3e6ce5b886f40 (tar-sha256); compiled at -Xr
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
