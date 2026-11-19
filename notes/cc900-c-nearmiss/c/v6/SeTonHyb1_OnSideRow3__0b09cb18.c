/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SETONHYB1 0x26
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeTonHyb1_OnSideRow3(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SETONHYB1, 1);
	}
}
