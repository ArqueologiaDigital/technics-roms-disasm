/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 927bb52536f32bff43a0ba8d9e4daa5bec3f59c3489a0c4bad53ca7c7e97c3bd (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
void SeFilFil2_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (SeMenu_StepParamFieldAndSend(54, 3, part, 60, buf) == 1) {
		SeMenu_LoadPartParam(3, &t);
		SeMenu_StorePartParam(10, t);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(3);
}
