/* Phase 6, lane_p6 helper S, round 1 of 2026-11-20, module 128 (display/scoop_editor_data.s), form f:
   SeAmpEnv1_OnColumn2-4 and SeAmpAmp1_OnColumn3/4, one-spot retries of p6_M_9m128b.c (run r51: +25 @O3Xr):
   the ROM takes the buffer into XHL, then &buf[6..9] into XWA / XBC / XDE / XHL, the last reusing the base's
   register; V4.23 gave base XBC, p6 XDE, p7 XHL, p8 XIX, p9 XWA (p6_M_8m128b, temp base: XBC, XHL, XIX,
   XDE, XWA).  p6_M_8m128b's spelling (no base variable, `p6 = &buf[6];` ...) with the four declared
   in reverse, p9 first.
   Everything else is p6_M_9m128b.c's text.
   cc900-options: -O3 -Xr
*/
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_StoreParamByte(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_DrawAmpEnvGraph(void);
extern void SeAmpEnv1_OnColumn2(unsigned char a);
extern void SeAmpEnv1_OnColumn3(unsigned char a);
extern void SeAmpEnv1_OnColumn4(unsigned char a);
extern void SeAmpAmp1_OnColumn3(unsigned char a);
extern void SeAmpAmp1_OnColumn4(unsigned char a);

void SeAmpEnv1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p9;
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
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
	unsigned char *p9;
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
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
	unsigned char *p9;
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
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

void SeAmpAmp1_OnColumn3(unsigned char a)
{
	unsigned char blk;
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p9;
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
	unsigned char v;
	unsigned char *r;
	unsigned char res;

	SeMenu_LoadObjEntries(&obj);
	SeMenu_ValidatePartNumber(&part);
	blk = part;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	p6 = &buf[6];
	p7 = &buf[7];
	p8 = &buf[8];
	p9 = &buf[9];
	if (obj == 0) {
		*p6 = 127;
		*p7 = 0;
		*p8 = 127;
		*p9 = 0;
		v = 23;
	} else {
		*p6 = 255;
		*p7 = 0;
		*p8 = 50;
		*p9 = 206;
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 6);
		part = 0;
	}
	res = SeMenu_StepParamFieldAndSend(43, blk, part, v, buf);
	if (obj == 0 && res == 1)
		SeMenu_StoreParamByte(part, buf[3]);
	SeMenu_BindDialToColumn(3);
}

void SeAmpAmp1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p9;
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
	unsigned char v;
	unsigned char *r;
	unsigned char blk;

	SeMenu_LoadObjEntries(&obj);
	SeMenu_ValidatePartNumber(&part);
	if (obj == 0)
		blk = part + 4;
	else
		blk = part + 2;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	p6 = &buf[6];
	p7 = &buf[7];
	p8 = &buf[8];
	p9 = &buf[9];
	if (obj == 0) {
		*p6 = 255;
		*p7 = 0;
		*p8 = 50;
		*p9 = 206;
		v = 24;
	} else {
		*p6 = 7;
		*p7 = 5;
		*p8 = 6;
		*p9 = 0;
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 7);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(43, blk, part, v, buf);
	SeMenu_BindDialToColumn(4);
}
