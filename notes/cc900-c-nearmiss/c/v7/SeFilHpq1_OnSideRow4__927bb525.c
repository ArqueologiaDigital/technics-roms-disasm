/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 927bb52536f32bff43a0ba8d9e4daa5bec3f59c3489a0c4bad53ca7c7e97c3bd (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SEFILLPQ1 0x30
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SetFilterType(int);
void SeFilHpq1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x03;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj == 0 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}
