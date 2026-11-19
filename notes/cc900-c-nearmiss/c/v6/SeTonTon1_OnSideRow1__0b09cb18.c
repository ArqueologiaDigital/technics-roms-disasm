/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 0b09cb187b6fc2cddfadb157994e37823ac483309daacab7a9e5ce87689be656 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ToggleSolo(void);
void SeTonTon1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}
