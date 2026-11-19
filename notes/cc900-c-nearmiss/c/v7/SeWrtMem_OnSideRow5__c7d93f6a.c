/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEWRTSND  0x3f
void SeWrtMem_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEWRTSND, 0);
}
