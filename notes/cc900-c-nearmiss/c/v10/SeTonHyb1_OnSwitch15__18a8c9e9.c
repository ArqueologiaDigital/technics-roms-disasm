/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_12m152a.c (2026-11-19-76-p6-r55)
   sha256 18a8c9e99c16f85e523dbca0dca71027b3a818f4bb8f9c3df561baafca33f13b (tar-sha256); compiled at -Xr */
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
void SeTonHyb1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_LoadObjEntries(&obj);
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}
