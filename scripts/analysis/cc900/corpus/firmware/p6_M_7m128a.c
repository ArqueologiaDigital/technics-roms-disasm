/* Phase 6, lane_p6 helper M, round 7, module 128 (display/scoop_editor_data.s), form a: the AMP ENV page's column
   handlers, the EditFilterCutoff family (its id idiom matched in run r47, p6_M_6m128a.c).
   Columns 1-4 keep a byte flag (the parameter block they load) in a callee-saved register: the ROM pushes QIZ and
   keeps the flag in its upper byte.  This file tests whether V4.23 picks that home for a plain unsigned char local
   that lives across the calls.  Column 1: block = (obj != 0) (an scc); columns 2-4: block = obj ? n : n - 1, with
   the four range bytes stored before the block is loaded (the ROM computes their addresses before the flag test).
   Columns 7 and 8 have no flag (constant blocks 6 / 7) and return early on obj (7: obj == 1; 8: obj == 0).
   Frame: buf +0 (12 bytes), obj +12, part +14, the column switch above (each +2 when QIZ is pushed). */
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
extern void SeAmpEnv1_OnColumn7(unsigned char a);
extern void SeAmpEnv1_OnColumn8(unsigned char a);

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
	blk = obj != 0;
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
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	blk = 2;
	if (obj == 0)
		blk = 1;
	buf[6] = 127;
	buf[7] = 0;
	buf[8] = 100;
	buf[9] = 0;
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
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	blk = 3;
	if (obj == 0)
		blk = 2;
	buf[6] = 127;
	buf[7] = 0;
	buf[8] = 100;
	buf[9] = 0;
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
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	blk = 4;
	if (obj == 0)
		blk = 3;
	buf[6] = 127;
	buf[7] = 0;
	buf[8] = 100;
	buf[9] = 0;
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
