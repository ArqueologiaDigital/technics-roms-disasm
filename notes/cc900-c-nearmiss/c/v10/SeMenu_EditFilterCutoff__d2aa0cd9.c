/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_5m128a.c (2026-11-19-29-p6-r46)
   sha256 d2aa0cd90b6e331e36e3de41366c20d212502ae8416236285803d72166ef7e81 (tar-sha256); compiled at -O3 -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeMenu_EditFilterCutoff(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 77;
	else {
		v = (unsigned char)(unsigned long)&((struct seprm *)0)->rec[(unsigned char)(part - 1)][17];
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 2, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
