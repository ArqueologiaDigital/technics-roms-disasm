/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/scoop_editor_data_m0.c (2026-11-19-92-p6-r57)
   sha256 b6d92c8728587c36d7344955e1856c519b3f49fdf7b5bc91b25862fbbea16a72 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SEFILLPQ1 0x30
#define TT_SEFILENV1 0x37
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}
