/* Phase 6, lane_p6 helper M, round 6, module 128, form b: SeMenu_EditFilterCutoff / SeMenu_EditFilterResonance
   (alternative to p6_M_6m128a.c): the row address cast to a byte pointer and the offset added in one expression
   (no pointer local), and a variant with the record as a struct whose 21-byte rows are reached through a row
   pointer type (unsigned char (*)[21]). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(unsigned char col);
extern void SeMenu_EditFilterCutoff(unsigned char a, unsigned char c, unsigned char e);
extern void SeMenu_EditFilterResonance(unsigned char a, unsigned char c, unsigned char e);

void SeMenu_EditFilterCutoff(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 77;
	else {
		v = (unsigned char)(unsigned long)((unsigned char *)((struct seprm *)0)->rec[(unsigned char)(part - 1)] + 17);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 2, part, v, buf);
	SeMenu_BindDialToColumn(c);
}

void SeMenu_EditFilterResonance(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;
	unsigned char (*r)[21];

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 5;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 78;
	else {
		r = &((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)&(*r)[18];
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 3, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
