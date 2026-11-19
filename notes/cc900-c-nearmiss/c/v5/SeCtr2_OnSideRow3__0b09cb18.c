/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SECTR2    0x3b
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeCtr2_SetSelection(int);
void SeCtr2_OnSideRow3(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 6)
			return;
		SeCtr2_SetSelection(6);
	} else {
		if (v == 5)
			return;
		SeCtr2_SetSelection(5);
	}
	SeMenu_SendEvent(TT_SECTR2, 1);
}
