/* Phase 6, lane_p6 helper M, round 10, module 128 (display/scoop_editor_data.s), form e: the filter key-scale page
   (SeFilFil2_*), a copy of the AMP2 page: column 3 (the matched SeAmpAmp2_OnColumn3 with popup 54, id 60), side rows
   and switches (the matched AMP2 / AMP ENV shapes; TT_SEFILFIL2 with refresh 1 after a part select). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEFILLPQ1 0x30
#define TT_SEFILFIL2 0x36
#define TT_SEFILENV1 0x37
#define TT_SEFILLFO1 0x39

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilFil2_OnColumn3(unsigned char a);
extern void SeFilFil2_OnSideRow1(unsigned char a);
extern void SeFilFil2_OnSideRow2(unsigned char a);
extern void SeFilFil2_OnSideRow3(unsigned char a);
extern void SeFilFil2_OnSideRow4(unsigned char a);
extern void SeFilFil2_OnSideRow5(unsigned char a);
extern void SeFilFil2_OnSwitch25(unsigned char a);
extern void SeFilFil2_OnSwitch15(unsigned char a);

void SeFilFil2_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (SeMenu_StepParamFieldAndSend(54, 3, part, 60, buf) == 1) {
		SeMenu_LoadPartParam(3, &t);
		SeMenu_StorePartParam(10, t);
		SeMenu_DrawKeyScaleGraph(0, 0);
	}
	SeMenu_BindDialToColumn(3);
}

void SeFilFil2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEFILENV1, 0);
}

void SeFilFil2_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILFIL2, 1);
	}
}

void SeFilFil2_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 1);
}

void SeFilFil2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILFIL2, 1);
	}
}

void SeFilFil2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEFILFIL2, 1);
	}
}

void SeFilFil2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilFil2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
