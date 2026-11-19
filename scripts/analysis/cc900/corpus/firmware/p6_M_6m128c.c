/* Phase 6, lane_p6 helper M, round 6, module 128 (display/scoop_editor_data.s), form c: two more of the
   SeMenu_EditFilterCutoff family, the bodies the LPF+Q page's column stubs jump to: SeFilLpq1_OnColumn3_Join21
   (parameter block 1, range 63 / 0 / 50 / 0, id 55 or byte 16 of the part row) and SeFilLpq1_OnColumn4_Join22
   (block 0, range 7 / 5 / 6 / 0, id 54 or byte 15).  The id as in p6_M_6m128a.c (row pointer, then the byte
   offset). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(unsigned char col);
extern void SeFilLpq1_OnColumn3_Join21(unsigned char a, unsigned char c, unsigned char e);
extern void SeFilLpq1_OnColumn4_Join22(unsigned char a, unsigned char c, unsigned char e);

void SeFilLpq1_OnColumn3_Join21(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(1, buf);
	p = buf;
	p[6] = 63;
	p[7] = 0;
	p[8] = 50;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 55;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 16);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 1, part, v, buf);
	SeMenu_BindDialToColumn(c);
}

void SeFilLpq1_OnColumn4_Join22(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(0, buf);
	p = buf;
	p[6] = 7;
	p[7] = 5;
	p[8] = 6;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 54;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 15);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 0, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
