/* Phase 6, lane_p6 helper M, round 12, hand source audio/sound_editor_ui.s, form a: the tone pages' handlers in
   the shapes that matched in display/scoop_editor_data.s (module 128) and audio/semenu_routines.s:
   SeTonTon1 (TONE 1): columns 6 / 7 / 8 (block = part * 3 - 1 / + 0 / + 1 in a QIZ byte, popup 34, ids 23 / 4 / 5;
   column 6 stores the block's byte 3 for the part when the step reports 1), side rows (select part n, redraw 34),
   switches (SeMenu_GoToPageOnEnabledPart).
   SeTonTon2 (TONE 2): column 4 (block = part + 1 in QIZ, popup 35, id 0), column 7 (block 10, id 92), side rows,
   switches.  SeTonRan1 / SeTonRan2 (RANGE): side rows and switch 15.  SeTonHyb1 (HYBRID): side rows, switches.
   The callees take ints (wa / bc loads); the file name carries the module of this hand source's routines (152). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SETONTON1 0x22
#define TT_SETONTON2 0x23
#define TT_SETONRAN1 0x24
#define TT_SETONRAN2 0x25
#define TT_SETONHYB1 0x26
#define TT_SECOPY    0x3d

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_StoreParamByte(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SeMenu_GoToPageOnEnabledPart(int);

extern void SeTonTon1_OnColumn6(unsigned char a);
extern void SeTonTon1_OnColumn7(unsigned char a);
extern void SeTonTon1_OnColumn8(unsigned char a);
extern void SeTonTon1_OnSideRow1(unsigned char a);
extern void SeTonTon1_OnSideRow2(unsigned char a);
extern void SeTonTon1_OnSideRow3(unsigned char a);
extern void SeTonTon1_OnSideRow4(unsigned char a);
extern void SeTonTon1_OnSideRow5(unsigned char a);
extern void SeTonTon1_OnSwitch25(unsigned char a);
extern void SeTonTon1_OnSwitch15(unsigned char a);
extern void SeTonTon2_OnColumn4(unsigned char a);
extern void SeTonTon2_OnColumn7(unsigned char a);
extern void SeTonTon2_OnSideRow1(unsigned char a);
extern void SeTonTon2_OnSideRow2(unsigned char a);
extern void SeTonTon2_OnSideRow3(unsigned char a);
extern void SeTonTon2_OnSideRow4(unsigned char a);
extern void SeTonTon2_OnSideRow5(unsigned char a);
extern void SeTonTon2_OnSwitch25(unsigned char a);
extern void SeTonTon2_OnSwitch15(unsigned char a);
extern void SeTonRan1_OnSideRow1(unsigned char a);
extern void SeTonRan1_OnSideRow2(unsigned char a);
extern void SeTonRan1_OnSideRow3(unsigned char a);
extern void SeTonRan1_OnSideRow4(unsigned char a);
extern void SeTonRan1_OnSideRow5(unsigned char a);
extern void SeTonRan1_OnSwitch15(unsigned char a);
extern void SeTonRan2_OnSideRow1(unsigned char a);
extern void SeTonRan2_OnSideRow2(unsigned char a);
extern void SeTonRan2_OnSideRow3(unsigned char a);
extern void SeTonRan2_OnSideRow4(unsigned char a);
extern void SeTonRan2_OnSideRow5(unsigned char a);
extern void SeTonRan2_OnSwitch15(unsigned char a);
extern void SeTonHyb1_OnSideRow1(unsigned char a);
extern void SeTonHyb1_OnSideRow2(unsigned char a);
extern void SeTonHyb1_OnSideRow3(unsigned char a);
extern void SeTonHyb1_OnSideRow4(unsigned char a);
extern void SeTonHyb1_OnSideRow5(unsigned char a);
extern void SeTonHyb1_OnSwitch25(unsigned char a);
extern void SeTonHyb1_OnSwitch15(unsigned char a);

/* ---- TONE 1 ---- */
void SeTonTon1_OnColumn6(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	blk--;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (SeMenu_StepParamFieldAndSend(34, blk, t, 23, buf) == 1)
		SeMenu_StoreParamByte(t, buf[3]);
	SeMenu_BindDialToColumn(6);
}

void SeTonTon1_OnColumn7(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 24;
	p[9] = 232;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(34, blk, t, 4, buf);
	SeMenu_BindDialToColumn(7);
}

void SeTonTon1_OnColumn8(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	blk++;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(34, blk, t, 5, buf);
	SeMenu_BindDialToColumn(8);
}

void SeTonTon1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonTon1_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 1, 0);
}

void SeTonTon1_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 2, 0);
}

void SeTonTon1_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 3, 0);
}

void SeTonTon1_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 4, 0);
}

void SeTonTon1_OnSwitch25(unsigned char a)
{
	if (a == 0)
		SeMenu_GoToPageOnEnabledPart(TT_SETONHYB1);
}

void SeTonTon1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_GoToPageOnEnabledPart(TT_SEMENU);
		SeMenu_SetupMenuDisplay(0);
	}
}

/* ---- TONE 2 ---- */
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

void SeTonTon2_OnColumn7(unsigned char a)
{
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(10, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(35, 10, 0, 92, buf);
	SeMenu_BindDialToColumn(7);
}

void SeTonTon2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonTon2_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 1, 1);
}

void SeTonTon2_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 2, 1);
}

void SeTonTon2_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 3, 1);
}

void SeTonTon2_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 4, 1);
}

void SeTonTon2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SETONHYB1, 0);
}

void SeTonTon2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- RANGE 1 ---- */
void SeTonRan1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonRan1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SETONRAN1, 1);
	}
}

void SeTonRan1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SETONRAN2, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SETONRAN1, 1);
}

void SeTonRan1_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SETONRAN1, 1);
	}
}

void SeTonRan1_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SETONRAN1, 1);
	}
}

void SeTonRan1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- RANGE 2 ---- */
void SeTonRan2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonRan2_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SETONRAN1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SETONRAN2, 1);
}

void SeTonRan2_OnSideRow3(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SETONRAN2, 1);
	}
}

void SeTonRan2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SETONRAN2, 1);
	}
}

void SeTonRan2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SETONRAN2, 1);
	}
}

void SeTonRan2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- HYBRID ---- */
void SeTonHyb1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonHyb1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SETONHYB1, 1);
	}
}

void SeTonHyb1_OnSideRow3(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SETONHYB1, 1);
	}
}

void SeTonHyb1_OnSideRow4(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SETONHYB1, 1);
}

void SeTonHyb1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SETONHYB1, 1);
}

void SeTonHyb1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1) {
		if (a == 0)
			SeMenu_SendEvent(TT_SETONTON2, 0);
		else
			SeMenu_SendEvent(TT_SETONTON1, 0);
	}
}

void SeTonHyb1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_LoadObjEntries(&obj);
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}
