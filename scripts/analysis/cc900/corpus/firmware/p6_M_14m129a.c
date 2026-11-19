/* Phase 6, lane_p6 helper M, round 14, module 129 (audio/semenu_routines.s), form a: the PITCH page's columns 2-4
   (SePitPit1_OnColumn2/3/4), copies of the matched SeTonTon1_OnColumn7/8: the block part * 3 - 2 / - 1 / + 0 in a
   QIZ byte (the ROM: byte mul, then dec 2 / dec 1 on QIZH), popup 39, ids 4 / 5 / 6. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SePitPit1_OnColumn2(unsigned char a);
extern void SePitPit1_OnColumn3(unsigned char a);
extern void SePitPit1_OnColumn4(unsigned char a);

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

void SePitPit1_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part * 3;
	blk--;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(39, blk, part, 5, buf);
	SeMenu_BindDialToColumn(3);
}

void SePitPit1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part * 3;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 7;
	p[7] = 0;
	p[8] = 7;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(39, blk, part, 6, buf);
	SeMenu_BindDialToColumn(4);
}
