/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/scoop_editor_data_m0.c (2026-11-19-53-p6-r50)
   sha256 1eadad4a94960dfb1a44f70e2ab160fe6b447e8ed1965cbc8dfdc4c8496baa45 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawAmpEnvGraph(void);
void SeAmpEnv1_OnColumn7(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 1)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(6, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 100;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(45, 6, part, 45, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(7);
}
