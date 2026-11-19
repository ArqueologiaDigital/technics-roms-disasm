/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_8m128b.c (2026-11-19-49-p6-r49)
   sha256 717fe385f8794c03be9d4e469f4d89655e4920a96dbaea61f7b2ae94d6012352 (tar-sha256); compiled at -O3 -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawAmpEnvGraph(void);
void SeAmpEnv1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char *p9;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	p6 = &buf[6];
	p7 = &buf[7];
	p8 = &buf[8];
	p9 = &buf[9];
	blk = 2;
	if (obj == 0)
		blk = 1;
	*p6 = 127;
	*p7 = 0;
	*p8 = 100;
	*p9 = 0;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	if (obj == 0)
		v = 40;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 9);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(2);
}
