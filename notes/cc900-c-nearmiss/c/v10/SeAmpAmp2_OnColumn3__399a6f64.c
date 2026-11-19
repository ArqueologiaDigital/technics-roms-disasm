/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_7m128c.c (2026-11-19-43-p6-r48)
   sha256 399a6f64e1bd2509ac73c81b653a72c356154c5c058429d4720d26812a60af59 (tar-sha256); compiled at -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpAmp2_OnColumn3(unsigned char a)
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
	if (SeMenu_StepParamFieldAndSend(44, 3, part, 29, buf) == 1) {
		SeMenu_LoadPartParam(3, &t);
		SeMenu_StorePartParam(10, t);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(3);
}
