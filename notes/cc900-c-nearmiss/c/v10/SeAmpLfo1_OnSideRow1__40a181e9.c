/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/scoop_editor_data_m0_xr.c (2026-11-19-92-p6-r57)
   sha256 40a181e96bc02c00ed7e11d90783fd879a13bde847eb482437f14722e2e34b0b (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEAMPENV1 0x2d
void SeAmpLfo1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEAMPENV1, 0);
}
