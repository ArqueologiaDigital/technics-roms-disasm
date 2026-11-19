/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeCtr2_OnPartColumn();
extern void SeMenu_LoadObjEntries(unsigned char *);
void SeCtr2_OnColumn7(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1)
		SeCtr2_OnPartColumn(3, a);
}
