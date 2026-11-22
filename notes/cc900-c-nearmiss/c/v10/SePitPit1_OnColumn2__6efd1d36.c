/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m0.c (2026-11-21-2-p6-r58)
   sha256 6efd1d36c05650125be185d748e4c214c5ffb523ff1880a112056ea1c2cd2147 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
void SePitPit1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part * 3;
	blk -= 2;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 24;
	p[9] = 232;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(39, blk, part, 4, buf);
	SeMenu_BindDialToColumn(2);
}
