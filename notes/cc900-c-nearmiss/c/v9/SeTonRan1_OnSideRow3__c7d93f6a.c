/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
#define TT_SETONRAN1 0x24
#define TT_SETONRAN2 0x25
void SeTonRan1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SETONRAN2, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SETONRAN1, 1);
}
