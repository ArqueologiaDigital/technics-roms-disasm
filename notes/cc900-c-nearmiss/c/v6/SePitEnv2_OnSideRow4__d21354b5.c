/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
#define TT_SEPITENV2 0x29
void SePitEnv2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEPITENV2, 1);
	}
}
