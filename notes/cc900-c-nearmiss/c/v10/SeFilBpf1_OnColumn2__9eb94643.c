/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_10m128c.c (2026-11-19-68-p6-r52)
   sha256 9eb946436acc107c72f7c567a583d7882b794547f887e267f05b636eb3a26a4a (tar-sha256); compiled at -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawBandPassCurve(void);
void SeFilBpf1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(4, &t);
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = t - 1;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 77;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 17);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(52, 2, part, v, buf);
	SeMenu_DrawBandPassCurve();
	SeMenu_BindDialToColumn(2);
}
