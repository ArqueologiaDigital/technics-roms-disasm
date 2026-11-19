/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
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
