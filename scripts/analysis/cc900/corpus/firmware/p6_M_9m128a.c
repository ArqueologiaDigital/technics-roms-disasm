/* Phase 6, lane_p6 helper M, round 9, module 128 (display/scoop_editor_data.s), form a: no-QIZ members of the
   family.
   SeAmpEnv2_OnColumn1-3: the shape of the matched SeAmpAmp2_OnColumn3 (blocks 5 / 6 / 7, popup 46, ids 51-53),
   then always: copy the block's value to part parameter 10, redraw the key-scale graph (2, 0), and select the
   column in part parameter 9 (0 / 1 / 2) with its title field redrawn when it changed.
   SeAmpEnv1_OnSideRow2-5, _OnSwitch25, _OnSwitch15: the AMP ENV page's side rows (siblings of the matched AMP1 /
   AMP2 / LPF+Q ones).  Row 5 toggles bit 5 of part parameter 0 (res / set on the frame byte) and re-registers the
   display object through SeMenu_SetupDisplayObject_Alt1 (its buffer address taken before the stack argument). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEAMPAMP1 0x2b
#define TT_SEAMPENV1 0x2d
#define TT_SEAMPENV2 0x2e
#define TT_SEAMPLFO1 0x2f
#define TT_SECOPY    0x3d

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void SeMenu_DrawAmpEnvGraph(void);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeMenu_SetupDisplayObject_Alt1(int, int, unsigned char *, unsigned int);
extern void SeAmpEnv2_OnColumn1(unsigned char a);
extern void SeAmpEnv2_OnColumn2(unsigned char a);
extern void SeAmpEnv2_OnColumn3(unsigned char a);
extern void SeAmpEnv1_OnSideRow2(unsigned char a);
extern void SeAmpEnv1_OnSideRow3(unsigned char a);
extern void SeAmpEnv1_OnSideRow4(unsigned char a);
extern void SeAmpEnv1_OnSideRow5(unsigned char a);
extern void SeAmpEnv1_OnSwitch25(unsigned char a);
extern void SeAmpEnv1_OnSwitch15(unsigned char a);

void SeAmpEnv2_OnColumn1(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(5, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(46, 5, part, 51, buf);
	SeMenu_LoadPartParam(5, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 0);
	SeMenu_LoadPartParam(9, &t);
	if (t != 0) {
		SeMenu_StorePartParam(9, 0);
		SeTitle_DrawField(46, 9);
	}
	SeMenu_BindDialToColumn(1);
}

void SeAmpEnv2_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(6, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(46, 6, part, 52, buf);
	SeMenu_LoadPartParam(6, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 0);
	SeMenu_LoadPartParam(9, &t);
	if (t != 1) {
		SeMenu_StorePartParam(9, 1);
		SeTitle_DrawField(46, 9);
	}
	SeMenu_BindDialToColumn(2);
}

void SeAmpEnv2_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(7, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(46, 7, part, 53, buf);
	SeMenu_LoadPartParam(7, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 0);
	SeMenu_LoadPartParam(9, &t);
	if (t != 2) {
		SeMenu_StorePartParam(9, 2);
		SeTitle_DrawField(46, 9);
	}
	SeMenu_BindDialToColumn(3);
}

void SeAmpEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEAMPENV1, 1);
}

void SeAmpEnv1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEAMPLFO1, 0);
	} else {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SEAMPENV1, 1);
	}
}

void SeAmpEnv1_OnSideRow4(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEAMPENV1, 1);
}

void SeAmpEnv1_OnSideRow5(unsigned char a)
{
	unsigned char obj;
	unsigned char v;
	unsigned char *q;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0)
		return;
	if (obj == 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEAMPENV1, 1);
	} else {
		SeMenu_LoadPartParam(0, &v);
		if (v & 0x20)
			v &= ~0x20;
		else
			v |= 0x20;
		SeMenu_StorePartParam(0, v);
		SeTitle_DrawField(45, 0);
		q = &v;
		SeMenu_SetupDisplayObject_Alt1(0, 13, q, 32);
		SeMenu_DrawAmpEnvGraph();
	}
}

void SeAmpEnv1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEAMPENV2, 0);
}

void SeAmpEnv1_OnSwitch15(unsigned char a)
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
