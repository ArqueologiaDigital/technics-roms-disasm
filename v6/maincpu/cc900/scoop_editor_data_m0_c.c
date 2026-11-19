/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawAmpEnvGraph(void);
extern void SeAmpEnv1_OnColumn7(unsigned char a);
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeAmpEnv1_OnColumn8(unsigned char a);
extern void SeAmpAmp1_OnColumn5(unsigned char a);
#define TT_SEAMPENV1 0x2d
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeAmpAmp1_OnSideRow1(unsigned char a);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SeAmpAmp1_OnSideRow2(unsigned char a);
#define TT_SEAMPLFO1 0x2f
extern void SeAmpAmp1_OnSideRow3(unsigned char a);
extern void SeAmpAmp1_OnSideRow4(unsigned char a);
extern void SeAmpAmp1_OnSideRow5(unsigned char a);
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeAmpAmp1_OnSwitch15(unsigned char a);
#define TT_SEAMPAMP2 0x2c
extern void SeAmpAmp1_OnSwitch25(unsigned char a);

void SeAmpEnv1_OnColumn7(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 1)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(6, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 100;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(45, 6, part, 45, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(7);
}

void SeAmpEnv1_OnColumn8(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *r;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(7, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
	SeMenu_StepParamFieldAndSend(45, 7, 0, (unsigned char)(unsigned long)(r + 14), buf);
	SeMenu_BindDialToColumn(8);
}


void SeAmpAmp1_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 1)
		return;
	SeMenu_ValidatePartNumber(&part);
	blk = part + 8;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 7;
	p[7] = 5;
	p[8] = 6;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(43, blk, part, 25, buf);
	SeMenu_BindDialToColumn(5);
}

void SeAmpAmp1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEAMPENV1, 0);
}

void SeAmpAmp1_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(43, 1, 1);
}

void SeAmpAmp1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj != 1)
			SeMenu_SendEvent(TT_SEAMPLFO1, 0);
	} else
		SeMenu_SelectPartAndRedraw(43, 2, 1);
}

void SeAmpAmp1_OnSideRow4(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0)
		SeMenu_SelectPartAndRedraw(43, 3, 1);
}

void SeAmpAmp1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0)
		SeMenu_SelectPartAndRedraw(43, 4, 1);
}

void SeAmpAmp1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	SeMenu_SetupMenuDisplay(0);
	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}

void SeAmpAmp1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP2, 0);
}
