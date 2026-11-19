/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_11m129a.c (2026-11-19-75-p6-r54)
   sha256 cef4f78e8e5560b045f78c9bae7b371a8b02f89acf4e6eb28226f24ad5718afb (tar-sha256); compiled at -Xr
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
