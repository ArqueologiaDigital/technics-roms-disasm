/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_9m128a.c (2026-11-19-56-p6-r51)
   sha256 19a810fa27cd20031aec9a0602a65a59b28150711b85d90b4dccb2cc798b7f6f (tar-sha256); compiled at -Xr */
#define TT_SEAMPAMP1 0x2b
#define TT_SEAMPENV1 0x2d
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeAmpEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEAMPENV1, 1);
}
