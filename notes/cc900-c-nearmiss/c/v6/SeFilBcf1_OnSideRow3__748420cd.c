/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 748420cda9fa1a5a8165f07827a04f959e5ccd5cca315c4e3954c316bc586d80 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SEFILLPQ1 0x30
#define TT_SEFILLFO1 0x39
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilBcf1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILLFO1, 0);
	} else {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}
