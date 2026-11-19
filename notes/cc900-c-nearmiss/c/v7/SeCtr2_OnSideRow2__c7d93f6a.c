/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SECTR2    0x3b
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeCtr2_SetSelection(int);
void SeCtr2_OnSideRow2(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 2)
			return;
		SeCtr2_SetSelection(2);
	} else {
		if (v == 1)
			return;
		SeCtr2_SetSelection(1);
	}
	SeMenu_SendEvent(TT_SECTR2, 1);
}
