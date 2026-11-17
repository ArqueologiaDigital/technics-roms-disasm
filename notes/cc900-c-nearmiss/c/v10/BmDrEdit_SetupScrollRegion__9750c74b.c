/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1a.c (2026-11-16-31-p6-r1b)
   sha256 9750c74bf124b2aa99540b8b4b6fdaab7ef7968b5c9e4dc00f22f063b001454d (tar-sha256); compiled at -O3 -XS -Xr */
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
	*a = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY * 2 + 1];
}
