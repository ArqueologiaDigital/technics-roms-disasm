/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_14m129a.c (2026-11-19-92-p6-r57)
   sha256 2bac7f73fbe54918251a964732b54a600c6cd11b4168dbe4299b00262f30b6a1 (tar-sha256); compiled at -Xr */
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
