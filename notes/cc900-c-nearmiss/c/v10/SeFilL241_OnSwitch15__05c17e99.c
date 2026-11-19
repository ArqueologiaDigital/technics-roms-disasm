/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_10m128a.c (2026-11-19-68-p6-r52)
   sha256 05c17e995f3594043cd3d62a0cd789b04a05cb84f5d3097db724f63cbc86d75c (tar-sha256); compiled at -Xr */
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
void SeFilL241_OnSwitch15(unsigned char a)
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
