/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -O3 -XS -Xr */
struct pair { unsigned char a, b; };
extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned int __near ram_279e;
extern struct pair WidgetData_DrawbarPositionTable[];
void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2742 & 1) {
		*a = ram_279e;
		*b = ram_279e;
		*b += 11;
	} else {
		*a = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY].a;
		*b = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY].b;
	}
}
