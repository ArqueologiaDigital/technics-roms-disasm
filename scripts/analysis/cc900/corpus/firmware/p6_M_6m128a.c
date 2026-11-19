/* Phase 6, lane_p6 helper M, round 6, module 128 (display/scoop_editor_data.s), form a: SeMenu_EditFilterCutoff /
   SeMenu_EditFilterResonance retry (run r46: +73 @O3Xr; everything else was the ROM's code).  The id: V4.23 folded
   the byte offset into the row index (muls 21, add 17, extz, lda +16); the ROM adds it after the row address
   (muls 21, extz, lda +16, lda +17).  This form: the row's address in a pointer local, the byte offset added to it. */
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
	unsigned char *r;

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
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 17);
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
	unsigned char *r;

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
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 18);
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 3, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
