/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_10m128e.c (2026-11-19-68-p6-r52)
   sha256 4b5faa3085fd6d7f5a7b1e0cf97ee3637adc1926897ee625b2d2344779d223df (tar-sha256); compiled at -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
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
