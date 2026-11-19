/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeTonHyb1_OnColumn8(unsigned char a)
{
	unsigned char v;
	unsigned char v2;
	unsigned char flag;

	flag = a;
	flag &= 0x7f;
	SeMenu_LoadPartParam(0, &v);
	if (flag == 0) {
		if (v == 1)
			return;
		v--;
		SeMenu_StorePartParam(0, v);
	} else {
		if (v == 4)
			return;
		SeMenu_LoadPartParam(v, &v2);
		if (v2 == 127)
			return;
		v++;
		SeMenu_StorePartParam(0, v);
	}
	SeTitle_DrawField(38, 0);
}
