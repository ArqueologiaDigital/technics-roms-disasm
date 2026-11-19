/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/scoop_editor_data_m0.c (2026-11-19-53-p6-r50)
   sha256 a1f918fd59b50f73149942e8e254b62d1c13865190456988ab318962c2705994 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpAmp1_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 1)
		return;
	SeMenu_ValidatePartNumber(&part);
	blk = part + 8;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 7;
	p[7] = 5;
	p[8] = 6;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(43, blk, part, 25, buf);
	SeMenu_BindDialToColumn(5);
}
