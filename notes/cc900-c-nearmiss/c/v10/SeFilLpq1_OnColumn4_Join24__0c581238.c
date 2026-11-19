/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/scoop_editor_data_m0_b.c (2026-11-19-43-p6-r48)
   sha256 0c581238564079ad37e1f2da3bf97b7b6105b152f57d7241c9d636fe4372e241 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawFilterEqGraph(void);
void SeFilLpq1_OnColumn4_Join24(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 79;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 19);
		part = 0;
	}
	if (SeMenu_StepParamFieldAndSend(48, 4, part, v, buf) == 1)
		SeMenu_DrawFilterEqGraph();
	SeMenu_BindDialToColumn(7);
}
