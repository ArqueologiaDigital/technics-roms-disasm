/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines_m0_b.c (2026-11-19-92-p6-r57)
   sha256 9605076959759449e3659261e016ce4d253b923ed70326daa861129eca483c46 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
#define TT_SEPITENV1 0x28
extern void SeAPE_J7();
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SePitEnv1_OnSideRow4(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(0);
	else if (SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}
