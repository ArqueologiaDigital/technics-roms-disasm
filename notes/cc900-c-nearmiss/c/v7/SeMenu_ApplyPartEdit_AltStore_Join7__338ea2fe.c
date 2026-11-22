/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines_m0_b.c (2026-11-21-2-p6-r58)
   sha256 338ea2fe7d82c7ae4573664e403bae682ef33bbc583bfb093833a8b6617422b5 (tar-sha256); compiled at -Xr
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
