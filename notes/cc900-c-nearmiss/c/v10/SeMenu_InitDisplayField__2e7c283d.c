/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m129a.c (2026-11-19-13-p6-r41)
   sha256 2e7c283d5e644432235f565d86f54863b4ad46525d24f4743f994933e9cc366e (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_InitDisplayField(unsigned char a, unsigned char c)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char obj;
	unsigned char *p;
	unsigned char *e;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	p = buf;
	p[0] = 0x80;
	p[1] = m;
	e = &p[2];
	if (obj == 0)
		*e = 0x09;
	else
		*e = 0x12;
	p[3] = a - 1;
	p[4] = 1;
	p[5] = c;
	SeMenu_FlushDisplayObj(p);
}
