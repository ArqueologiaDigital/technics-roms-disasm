/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/scoop_editor_data_m0.c (2026-11-19-53-p6-r50)
   sha256 a1f918fd59b50f73149942e8e254b62d1c13865190456988ab318962c2705994 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_SetupMenuDisplay(int mode);
void SeAmpAmp1_OnSwitch15(unsigned char a)
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
