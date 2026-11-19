/* Phase 6, lane_p6 helper M, round 8, module 128 (display/scoop_editor_data.s), form b: AMP ENV columns 1-4 retry
   (run r48: V4.23 put the block flag in QIZH as the ROM does).
   Column 1: the ROM's scc writes A (a byte), V4.23 wrote WA for `blk = obj != 0`: the comparison cast to unsigned
   char.  (Column 1 also needs the checker fix for V4.23's `inc` with count field 0, i.e. 8: helper M's report.)
   Columns 2-4 (+23): the ROM takes the four range-byte addresses into registers right after LoadObjEntries, before
   the flag is set, and stores through them: four pointer locals assigned first. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawAmpEnvGraph(void);
extern void SeAmpEnv1_OnColumn1(unsigned char a);
extern void SeAmpEnv1_OnColumn2(unsigned char a);
extern void SeAmpEnv1_OnColumn3(unsigned char a);
extern void SeAmpEnv1_OnColumn4(unsigned char a);

void SeAmpEnv1_OnColumn1(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	blk = (unsigned char)(obj != 0);
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 100;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 39;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 8);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(1);
}

void SeAmpEnv1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char *p9;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	p6 = &buf[6];
	p7 = &buf[7];
	p8 = &buf[8];
	p9 = &buf[9];
	blk = 2;
	if (obj == 0)
		blk = 1;
	*p6 = 127;
	*p7 = 0;
	*p8 = 100;
	*p9 = 0;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	if (obj == 0)
		v = 40;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 9);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(2);
}

void SeAmpEnv1_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char *p9;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	p6 = &buf[6];
	p7 = &buf[7];
	p8 = &buf[8];
	p9 = &buf[9];
	blk = 3;
	if (obj == 0)
		blk = 2;
	*p6 = 127;
	*p7 = 0;
	*p8 = 100;
	*p9 = 0;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	if (obj == 0)
		v = 41;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 10);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(3);
}

void SeAmpEnv1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char *p9;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	p6 = &buf[6];
	p7 = &buf[7];
	p8 = &buf[8];
	p9 = &buf[9];
	blk = 4;
	if (obj == 0)
		blk = 3;
	*p6 = 127;
	*p7 = 0;
	*p8 = 100;
	*p9 = 0;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	if (obj == 0)
		v = 42;
	else {
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 11);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(45, blk, part, v, buf);
	SeMenu_DrawAmpEnvGraph();
	SeMenu_BindDialToColumn(4);
}
