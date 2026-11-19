/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_9m128b.c (2026-11-19-56-p6-r51)
   sha256 c7a704cafe716246f5c62c583d31dc57d6fc5d5973eb0e1d88b59197a17833da (tar-sha256); compiled at -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpAmp1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p9;
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
	unsigned char *p;
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
	p = buf;
	p6 = &p[6];
	p7 = &p[7];
	p8 = &p[8];
	p9 = &p[9];
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
