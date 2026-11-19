/* Phase 6, lane_p6 helper M, round 10, module 128 (display/scoop_editor_data.s), form c: the band-pass page
   (SeFilBpf1_*).  Columns 2 / 4 / 5: the EditFilterCutoff shape (popup 52; blocks 2 / 4 / 5, ids 77 / 79 / 80 or
   row bytes 17 / 19 / 20), redraw the band-pass curve.  Column 2's upper bound is the other block's value - 1,
   column 4's lower bound its value + 1.  Columns 4 / 5 make the step call in each branch (the panel object with the
   part, else part 0 and the row id; the ROM merges the two calls), with the buffer pointer reloaded after the dial
   step.  Column 3 / 6 / 7 stubs, side rows (type 0 on row 4) and switches as on the other filter pages. */
/* cc900-module: SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeMenu_EditFilterResonance */

#define TT_SEMENU    0x20
#define TT_SEFILLPQ1 0x30
#define TT_SEFILFIL2 0x36
#define TT_SEFILENV1 0x37
#define TT_SEFILLFO1 0x39
#define TT_SECOPY    0x3d

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_EditFilterResonance();
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawBandPassCurve(void);
extern void SeMenu_SetFilterType(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilBpf1_OnColumn2(unsigned char a);
extern void SeFilBpf1_OnColumn3(unsigned char a);
extern void SeFilBpf1_OnColumn4(unsigned char a);
extern void SeFilBpf1_OnColumn5(unsigned char a);
extern void SeFilBpf1_OnColumn6(unsigned char a);
extern void SeFilBpf1_OnColumn7(unsigned char a);
extern void SeFilBpf1_OnSideRow1(unsigned char a);
extern void SeFilBpf1_OnSideRow2(unsigned char a);
extern void SeFilBpf1_OnSideRow3(unsigned char a);
extern void SeFilBpf1_OnSideRow4(unsigned char a);
extern void SeFilBpf1_OnSideRow5(unsigned char a);
extern void SeFilBpf1_OnSwitch25(unsigned char a);
extern void SeFilBpf1_OnSwitch15(unsigned char a);

void SeFilBpf1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(4, &t);
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = t - 1;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 77;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 17);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(52, 2, part, v, buf);
	SeMenu_DrawBandPassCurve();
	SeMenu_BindDialToColumn(2);
}

void SeFilBpf1_OnColumn3(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 3, 52);
	SeMenu_DrawBandPassCurve();
}

void SeFilBpf1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(2, &t);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 127;
	p[9] = t + 1;
	SeMenu_SwitchToValueStep(a, p + 10);
	p = buf;
	if (obj == 0)
		SeMenu_StepParamFieldAndSend(52, 4, part, 79, p);
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		SeMenu_StepParamFieldAndSend(52, 4, 0, (unsigned char)(unsigned long)(r + 19), p);
	}
	SeMenu_DrawBandPassCurve();
	SeMenu_BindDialToColumn(4);
}

void SeFilBpf1_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(5, buf);
	p = buf;
	p[6] = 15;
	p[7] = 0;
	p[8] = 5;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	p = buf;
	if (obj == 0)
		SeMenu_StepParamFieldAndSend(52, 5, part, 80, p);
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		SeMenu_StepParamFieldAndSend(52, 5, 0, (unsigned char)(unsigned long)(r + 20), p);
	}
	SeMenu_DrawBandPassCurve();
	SeMenu_BindDialToColumn(5);
}

void SeFilBpf1_OnColumn6(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 6, 52);
}

void SeFilBpf1_OnColumn7(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 7, 52);
}

void SeFilBpf1_OnSideRow1(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILENV1, 0);
	} else
		SeMenu_ToggleSolo();
}

void SeFilBpf1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilBpf1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILLFO1, 0);
	} else {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilBpf1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilBpf1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilBpf1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilBpf1_OnSwitch15(unsigned char a)
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
