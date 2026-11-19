/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_7m128a.c (2026-11-19-43-p6-r48)
   sha256 78fda304849f79b9cbcbc4bac8501ba1ea35f7f909aa20a4c557e88a9edd5db5 (tar-sha256); compiled at -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpEnv1_OnColumn8(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *r;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(7, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
	SeMenu_StepParamFieldAndSend(45, 7, 0, (unsigned char)(unsigned long)(r + 14), buf);
	SeMenu_BindDialToColumn(8);
}
