/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/scoop_editor_data_m0_xr.c (2026-11-19-92-p6-r57)
   sha256 40a181e96bc02c00ed7e11d90783fd879a13bde847eb482437f14722e2e34b0b (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEMENU    0x20
extern void SeMenu_SetupMenuDisplay(int mode);
void SeFilEnv2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
