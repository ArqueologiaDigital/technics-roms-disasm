/* Phase 6, lane_p6 helper M, round 8, module 128 (display/scoop_editor_data.s), form a: the AMP1 page's columns.
   Same family as the matched SeAmpEnv1_OnColumn7 / 8 and SeMenu_EditFilterCutoff (id: row pointer + byte offset).
   SeAmpAmp1_OnColumn3: the block is the part number, kept in a frame byte (+0); the range bytes go through four
   pointer locals taken before the obj test (the ROM's lda xwa / xbc / xde / xhl from the buffer), one range set per
   branch; on the panel object (obj == 0) a step result of 1 also stores the block's byte 3 for the part.
   _OnColumn4 / _OnColumn5 keep the block in QIZ (run r48: V4.23 does home such a byte flag in QIZH):
   part + 4 / part + 2 (4), part + 8 (5).
   Frame: [blk +0,] buf (12), obj, part, the column switch; +2 when QIZ is pushed. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_StoreParamByte(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeAmpAmp1_OnColumn3(unsigned char a);
extern void SeAmpAmp1_OnColumn4(unsigned char a);
extern void SeAmpAmp1_OnColumn5(unsigned char a);

void SeAmpAmp1_OnColumn3(unsigned char a)
{
	unsigned char blk;
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char *p9;
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
	unsigned char *p6;
	unsigned char *p7;
	unsigned char *p8;
	unsigned char *p9;
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

void SeAmpAmp1_OnColumn5(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadObjEntries(&obj);
	if (obj == 1)
		return;
	SeMenu_ValidatePartNumber(&part);
	blk = part + 8;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 7;
	p[7] = 5;
	p[8] = 6;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(43, blk, part, 25, buf);
	SeMenu_BindDialToColumn(5);
}
