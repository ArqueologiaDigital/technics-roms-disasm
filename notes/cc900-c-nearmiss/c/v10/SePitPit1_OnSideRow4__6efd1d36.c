/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m0.c (2026-11-21-2-p6-r58)
   sha256 6efd1d36c05650125be185d748e4c214c5ffb523ff1880a112056ea1c2cd2147 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
void SePitPit1_OnSideRow4(unsigned char a)
{
	unsigned char v;

	if (a == 0) {
		SeMenu_LoadPartParam(13, &v);
		if (v > 1) {
			v--;
			SeMenu_StorePartParam(13, v);
			SeTitle_DrawField(39, 13);
		}
	} else
		SeMenu_SelectPartAndRedraw(39, 3, 1);
}
