/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/scoop_editor_data_m128.c (2026-11-19-43-p6-r48)
   sha256 a8835538e52f37272f1c9dea5da1c63d618ddf7a1c3dfc8345d0fdfdebeb6870 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeMenu_EditFilterResonance(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 5;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 78;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 18);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 3, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
