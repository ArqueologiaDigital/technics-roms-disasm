/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SETONTON1 0x22
#define TT_SETONTON2 0x23
void SeTonHyb1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1) {
		if (a == 0)
			SeMenu_SendEvent(TT_SETONTON2, 0);
		else
			SeMenu_SendEvent(TT_SETONTON1, 0);
	}
}
