/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_11m128a.c (2026-11-19-75-p6-r54)
   sha256 8de83a10ef54af755c2f442ed8daa1af5633d6d9a85cc6c5216744330d3ceb38 (tar-sha256); compiled at -Xr */
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
