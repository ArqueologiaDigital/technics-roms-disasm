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
void SeAmpEnv1_OnColumn1(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	blk = (unsigned char)(obj != 0);
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 100;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 39;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 8);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(1);
}
