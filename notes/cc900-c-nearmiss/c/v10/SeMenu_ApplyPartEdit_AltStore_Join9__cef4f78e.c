/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_11m129a.c (2026-11-19-75-p6-r54)
   sha256 cef4f78e8e5560b045f78c9bae7b371a8b02f89acf4e6eb28226f24ad5718afb (tar-sha256); compiled at -Xr
   cc900-name: SeAPE_J9=SeMenu_ApplyPartEdit_AltStore_Join9 */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawPitFilEnvGraph(void);
void SeAPE_J9(unsigned char a, unsigned char c)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, &v);
	if (v == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(55, 4, part, c, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(2);
}
