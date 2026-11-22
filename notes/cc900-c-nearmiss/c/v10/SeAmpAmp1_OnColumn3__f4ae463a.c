/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m128d.c (2026-11-21-2-p6-r58)
   sha256 f4ae463a1a88d25599fd188fe5ef26ad01b78b431058acf1f5ea7658e6d18806 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_StoreParamByte(int, int);
extern void SeMenu_BindDialToColumn(int col);
void SeAmpAmp1_OnColumn3(unsigned char a)
{
	unsigned char blk;
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p8;
	unsigned char *p7;
	unsigned char *p6;
	unsigned char *p;
	unsigned char v;
	unsigned char *r;
	unsigned char res;

	SeMenu_LoadObjEntries(&obj);
	SeMenu_ValidatePartNumber(&part);
	blk = part;
	SeMenu_LoadPartParam(blk, buf);
	SeMenu_SwitchToValueStep(a, &buf[10]);
	p = buf;
	p6 = &p[6];
	p7 = &p[7];
	p8 = &p[8];
	p = &p[9];
	if (obj == 0) {
		*p6 = 127;
		*p7 = 0;
		*p8 = 127;
		*p = 0;
		v = 23;
	} else {
		*p6 = 255;
		*p7 = 0;
		*p8 = 50;
		*p = 206;
		r = ((struct seprm *)0)->rec[(unsigned char)(part - 1)];
		v = (unsigned char)(unsigned long)(r + 6);
		part = 0;
	}
	res = SeMenu_StepParamFieldAndSend(43, blk, part, v, buf);
	if (obj == 0 && res == 1)
		SeMenu_StoreParamByte(part, buf[3]);
	SeMenu_BindDialToColumn(3);
}
