/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/scoop_editor_data_m0.c (2026-11-19-43-p6-r48)
   sha256 208a8fd80a6fed4df011fdf7bdcca91ad5a8fa5e93a09afef584de35586c982c (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
#define TT_SEFILLPQ1 0x30
#define TT_SEFILLFO1 0x39
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
void SeFilLpq1_OnColumn4_Join28(unsigned char a)
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
