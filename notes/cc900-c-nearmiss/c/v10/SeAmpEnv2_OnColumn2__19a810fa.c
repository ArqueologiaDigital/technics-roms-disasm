/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_9m128a.c (2026-11-19-56-p6-r51)
   sha256 19a810fa27cd20031aec9a0602a65a59b28150711b85d90b4dccb2cc798b7f6f (tar-sha256); compiled at -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpEnv2_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(6, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(46, 6, part, 52, buf);
	SeMenu_LoadPartParam(6, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 0);
	SeMenu_LoadPartParam(9, &t);
	if (t != 1) {
		SeMenu_StorePartParam(9, 1);
		SeTitle_DrawField(46, 9);
	}
	SeMenu_BindDialToColumn(2);
}
