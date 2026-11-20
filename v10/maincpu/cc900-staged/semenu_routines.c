/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
