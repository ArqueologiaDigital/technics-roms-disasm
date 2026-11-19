/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J16=SeMenu_ApplyPartEdit_AltStore_Join16 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeAPE_J16(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 4, part, c, buf);
	SeMenu_LoadPartParam(4, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 1);
	SeMenu_LoadPartParam(9, &t);
	if (t != 1) {
		SeMenu_StorePartParam(9, 1);
		SeTitle_DrawField(41, 9);
	}
	SeMenu_BindDialToColumn(3);
}
