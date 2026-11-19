/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SetupMenuDisplay(int mode);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetPartEnabled();
void SeTonTon1_OnColumn1(unsigned char a)
{
	unsigned char p;
	unsigned char flag;

	SeMenu_LoadPartParam(0, &p);
	flag = a & 0x7f;
	if (SeMenu_IsPartEnabled(p) != 0) {
		if (flag == 0)
			return;
		SeMenu_SetPartEnabled(p, 0);
	} else {
		if (flag != 0)
			return;
		SeMenu_SetPartEnabled(p, 1);
	}
	SeTitle_DrawField(34, 1);
	SeMenu_SetupMenuDisplay(1);
}
