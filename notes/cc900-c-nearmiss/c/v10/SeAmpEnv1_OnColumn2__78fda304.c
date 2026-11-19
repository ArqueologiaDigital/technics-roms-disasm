/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_7m128a.c (2026-11-19-43-p6-r48)
   sha256 78fda304849f79b9cbcbc4bac8501ba1ea35f7f909aa20a4c557e88a9edd5db5 (tar-sha256); compiled at -O3 -Xr */
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
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	blk = 2;
	if (obj == 0)
		blk = 1;
	buf[6] = 127;
	buf[7] = 0;
	buf[8] = 100;
	buf[9] = 0;
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
