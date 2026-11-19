/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_9m128e.c (2026-11-19-56-p6-r51)
   sha256 2aa7412fea7a6456fd0b04468beb77d8734187dc188e0ec6d72367caf1567674 (tar-sha256); compiled at -Xr */
#define TT_SEFILLPQ1 0x30
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SetFilterType(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilLpq1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x02;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}
