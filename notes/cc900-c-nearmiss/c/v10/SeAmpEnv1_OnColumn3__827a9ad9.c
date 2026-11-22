/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m128e.c (2026-11-21-2-p6-r58)
   sha256 827a9ad92fd8951bfa38f683015fc3bbc8576b37d5274ee7712f09dde5211db1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawAmpEnvGraph(void);
void SeAmpEnv1_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	p = buf;
	p6 = &p[6];
	p7 = &p[7];
	p8 = &p[8];
	p = &p[9];
	blk = 3;
	if (obj == 0)
		blk = 2;
	*p6 = 127;
	*p7 = 0;
	*p8 = 100;
	*p = 0;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	if (obj == 0)
		v = 41;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 10);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(3);
}
