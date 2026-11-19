/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_10m128d.c (2026-11-19-68-p6-r52)
   sha256 4d4b0c2166ad3cd18c5d298f41375ef3f6942e430a2b6b614d86422a24c4d49f (tar-sha256); compiled at -Xr */
#define TT_SEFILLPQ1 0x30
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SetFilterType(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilBcf1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x01;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}
