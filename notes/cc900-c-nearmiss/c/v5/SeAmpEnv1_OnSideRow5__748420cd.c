/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 748420cda9fa1a5a8165f07827a04f959e5ccd5cca315c4e3954c316bc586d80 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
#define TT_SEAMPENV1 0x2d
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawAmpEnvGraph(void);
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
