/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_12m152a.c (2026-11-19-76-p6-r55)
   sha256 18a8c9e99c16f85e523dbca0dca71027b3a818f4bb8f9c3df561baafca33f13b (tar-sha256); compiled at -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
void SeTonTon2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part + 1;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 63;
	p[7] = 0;
	p[8] = 50;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(35, blk, part, 0, buf);
	SeMenu_BindDialToColumn(4);
}
