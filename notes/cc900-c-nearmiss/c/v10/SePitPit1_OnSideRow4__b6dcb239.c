/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_12m129a.c (2026-11-19-76-p6-r55)
   sha256 b6dcb239bf1095fe4e72442c937b724a875949720b14eb5119f6691d14e5f2be (tar-sha256); compiled at -Xr */
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
