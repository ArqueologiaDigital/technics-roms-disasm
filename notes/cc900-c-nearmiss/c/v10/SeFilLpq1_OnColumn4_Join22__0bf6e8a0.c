/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_6m128c.c (2026-11-19-37-p6-r47)
   sha256 0bf6e8a0d918eb6c5b29497e4c65726611a90cfc6144889c68f70c21557b8019 (tar-sha256); compiled at -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeFilLpq1_OnColumn4_Join22(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(0, buf);
	p = buf;
	p[6] = 7;
	p[7] = 5;
	p[8] = 6;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 54;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 15);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 0, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
