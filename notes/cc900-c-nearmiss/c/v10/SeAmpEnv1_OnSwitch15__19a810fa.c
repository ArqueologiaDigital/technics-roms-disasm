/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_9m128a.c (2026-11-19-56-p6-r51)
   sha256 19a810fa27cd20031aec9a0602a65a59b28150711b85d90b4dccb2cc798b7f6f (tar-sha256); compiled at -Xr */
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
void SeAmpEnv1_OnSwitch15(unsigned char a)
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
