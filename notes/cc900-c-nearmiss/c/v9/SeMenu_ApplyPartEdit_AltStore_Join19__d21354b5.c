/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J19=SeMenu_ApplyPartEdit_AltStore_Join19 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
void SeAPE_J19(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(0, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 0, part, c, buf);
	SeMenu_BindDialToColumn(7);
}
