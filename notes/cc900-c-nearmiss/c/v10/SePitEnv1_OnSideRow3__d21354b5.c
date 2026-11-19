/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SEPITENV1 0x28
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEPITLFO1 0x2a
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SePitEnv1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}
