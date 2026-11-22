/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m0_b.c (2026-11-21-2-p6-r58)
   sha256 338ea2fe7d82c7ae4573664e403bae682ef33bbc583bfb093833a8b6617422b5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J9=SeMenu_ApplyPartEdit_AltStore_Join9 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
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
