/* Phase 6, lane_p6 helper M, round 6, module 128 (display/scoop_editor_data.s), form e: more of the LPF+Q page's
   handler bodies.
   SeFilLpq1_OnColumn4_Join24 / _Join25: the EditFilterCutoff shape with one parameter (the column switch): blocks
   4 / 5, ranges 127/0/127/0 and 127/0/13/0, ids 79 / 80 or bytes 19 / 20 of the part row, popup 48; redraw the EQ
   graph when the step reports 1; bind the dial to column 7 / 8.  The id as in p6_M_6m128a.c.
   SeFilLpq1_OnColumn4_Join26 / _Join28: side buttons (0 = open the ENV / LFO page, else solo / select part 2);
   _Join27: select part 1.  The callees take ints here (wa / bc loads): int prototypes. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEFILLPQ1 0x30
#define TT_SEFILENV1 0x37
#define TT_SEFILLFO1 0x39

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawFilterEqGraph(void);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilLpq1_OnColumn4_Join24(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join25(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join26(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join27(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join28(unsigned char a);

void SeFilLpq1_OnColumn4_Join24(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 79;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 19);
		part = 0;
	}
	if (SeMenu_StepParamFieldAndSend(48, 4, part, v, buf) == 1)
		SeMenu_DrawFilterEqGraph();
	SeMenu_BindDialToColumn(7);
}

void SeFilLpq1_OnColumn4_Join25(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(5, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 13;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 80;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 20);
		part = 0;
	}
	if (SeMenu_StepParamFieldAndSend(48, 5, part, v, buf) == 1)
		SeMenu_DrawFilterEqGraph();
	SeMenu_BindDialToColumn(8);
}

void SeFilLpq1_OnColumn4_Join26(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILENV1, 0);
	} else
		SeMenu_ToggleSolo();
}

void SeFilLpq1_OnColumn4_Join27(unsigned char a)
{
	if (a == 0)
		return;
	if (SeMenu_SelectPartIfEnabled(1) == 0)
		return;
	SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	return;
}

void SeFilLpq1_OnColumn4_Join28(unsigned char a)
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
