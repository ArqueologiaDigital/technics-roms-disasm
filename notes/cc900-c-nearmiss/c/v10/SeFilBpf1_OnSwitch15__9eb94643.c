/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_10m128c.c (2026-11-19-68-p6-r52)
   sha256 9eb946436acc107c72f7c567a583d7882b794547f887e267f05b636eb3a26a4a (tar-sha256); compiled at -Xr */
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
void SeFilBpf1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	SeMenu_SetupMenuDisplay(0);
	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}
