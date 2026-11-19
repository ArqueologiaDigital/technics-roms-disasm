/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 748420cda9fa1a5a8165f07827a04f959e5ccd5cca315c4e3954c316bc586d80 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
#define TT_SEAMPAMP1 0x2b
#define TT_SEAMPENV1 0x2d
void SeAmpEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEAMPENV1, 1);
}
