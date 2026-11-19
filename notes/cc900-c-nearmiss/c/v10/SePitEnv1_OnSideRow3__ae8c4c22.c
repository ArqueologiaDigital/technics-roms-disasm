/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_11m129b.c (2026-11-19-75-p6-r54)
   sha256 ae8c4c22753e4f1acd184328edb4414991c591318614a07de56787c51b4c7b18 (tar-sha256); compiled at -Xr */
#define TT_SEPITENV1 0x28
#define TT_SEPITLFO1 0x2a
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SePitEnv1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}
