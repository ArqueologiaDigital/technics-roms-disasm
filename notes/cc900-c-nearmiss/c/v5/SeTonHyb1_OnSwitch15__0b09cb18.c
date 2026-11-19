/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_SetupMenuDisplay(int mode);
void SeTonHyb1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_LoadObjEntries(&obj);
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}
