/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 748420cda9fa1a5a8165f07827a04f959e5ccd5cca315c4e3954c316bc586d80 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawBandPassCurve(void);
void SeFilBpf1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(2, &t);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 127;
	p[9] = t + 1;
	SeMenu_SwitchToValueStep(a, p + 10);
	p = buf;
	if (obj == 0)
		SeMenu_StepParamFieldAndSend(52, 4, part, 79, p);
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		SeMenu_StepParamFieldAndSend(52, 4, 0, (unsigned char)(unsigned long)(r + 19), p);
	}
	SeMenu_DrawBandPassCurve();
	SeMenu_BindDialToColumn(4);
}
