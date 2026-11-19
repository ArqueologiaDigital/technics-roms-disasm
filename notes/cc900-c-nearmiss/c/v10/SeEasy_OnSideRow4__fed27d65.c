/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_12m152b.c (2026-11-19-76-p6-r55)
   sha256 fed27d65674e3c8f1947fb66c32ed89a6a58553a1ab219c33067c482f526bcdc (tar-sha256); compiled at -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeEasy_OnSideRow4(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 7)
			return;
		SeMenu_StorePartParam(0, 7);
	} else {
		if (v == 3)
			return;
		SeMenu_StorePartParam(0, 3);
	}
	SeTitle_DrawField(33, 0);
}
