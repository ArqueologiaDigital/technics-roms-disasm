/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines_m0_b.c (2026-11-21-2-p6-r58)
   sha256 338ea2fe7d82c7ae4573664e403bae682ef33bbc583bfb093833a8b6617422b5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J15=SeMenu_ApplyPartEdit_AltStore_Join15 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeAPE_J15(unsigned char a, unsigned char c)
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
	SeMenu_StepParamFieldAndSend(41, 3, part, c, buf);
	SeMenu_LoadPartParam(3, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 1);
	SeMenu_LoadPartParam(9, &t);
	if (t != 0) {
		SeMenu_StorePartParam(9, 0);
		SeTitle_DrawField(41, 9);
	}
	SeMenu_BindDialToColumn(2);
}
