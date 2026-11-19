/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_9m128a.c (2026-11-19-56-p6-r51)
   sha256 19a810fa27cd20031aec9a0602a65a59b28150711b85d90b4dccb2cc798b7f6f (tar-sha256); compiled at -Xr */
#define TT_SEAMPENV1 0x2d
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawAmpEnvGraph(void);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeMenu_SetupDisplayObject_Alt1(int, int, unsigned char *, unsigned int);
void SeAmpEnv1_OnSideRow5(unsigned char a)
{
	unsigned char obj;
	unsigned char v;
	unsigned char *q;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0)
		return;
	if (obj == 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEAMPENV1, 1);
	} else {
		SeMenu_LoadPartParam(0, &v);
		if (v & 0x20)
			v &= ~0x20;
		else
			v |= 0x20;
		SeMenu_StorePartParam(0, v);
		SeTitle_DrawField(45, 0);
		q = &v;
		SeMenu_SetupDisplayObject_Alt1(0, 13, q, 32);
		SeMenu_DrawAmpEnvGraph();
	}
}
