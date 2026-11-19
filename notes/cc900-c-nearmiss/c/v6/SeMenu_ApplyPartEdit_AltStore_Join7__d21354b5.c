/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeAPE_J7(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 0)
			return;
		SeMenu_StorePartParam(0, 0);
	} else {
		if (v == 1)
			return;
		SeMenu_StorePartParam(0, 1);
	}
	SeTitle_DrawField(40, 0);
}
