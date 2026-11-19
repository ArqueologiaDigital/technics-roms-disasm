/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_6m128e.c (2026-11-19-37-p6-r47)
   sha256 06afb1f33b0baaa707bd78ab00098ce8dcb54e69b8a891f79c1f3b86e37bac84 (tar-sha256); compiled at -Xr */
#define TT_SEFILLPQ1 0x30
#define TT_SEFILLFO1 0x39
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilLpq1_OnColumn4_Join28(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILLFO1, 0);
	} else {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}
