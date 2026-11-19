/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m129a.c (2026-11-19-13-p6-r41)
   sha256 2e7c283d5e644432235f565d86f54863b4ad46525d24f4743f994933e9cc366e (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_ClearDisplayBuffer(void)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *p;
	unsigned char *e;

	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	p = buf;
	p[0] = 0x88;
	p[1] = m;
	p[2] = 0x0d;
	p[3] = 0;
	p[4] = 0;
	p[5] = 0;
	SeMenu_FlushDisplayObj(p);
}
