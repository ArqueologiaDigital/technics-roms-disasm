/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_8m128a.c (2026-11-19-49-p6-r49)
   sha256 06285d121cc30687c3bc549decd81b3995797cc7dc65c4c39c6497bed3153c66 (tar-sha256); compiled at -Xr */
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
