/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/scoop_editor_data_m0.c (2026-11-19-53-p6-r50)
   sha256 1eadad4a94960dfb1a44f70e2ab160fe6b447e8ed1965cbc8dfdc4c8496baa45 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
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
