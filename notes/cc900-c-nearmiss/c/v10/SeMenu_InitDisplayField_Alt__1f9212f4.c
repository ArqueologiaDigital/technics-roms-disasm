/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m129b.c (2026-11-19-13-p6-r41)
   sha256 1f9212f47e7485add79ffa97f84ddf95cae62e9ef1116d87df81197abbaa33fe (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_InitDisplayField_Alt(unsigned char a, unsigned char c, unsigned char x)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char obj;
	unsigned char *p;
	unsigned char *e;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = buf + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	buf[0] = 0x80;
	buf[1] = m;
	if (obj == 0)
		buf[2] = 0x0a;
	else
		buf[2] = 0x13;
	buf[3] = c - 1;
	buf[3] <<= 4;
	buf[3] += a - 1;
	buf[4] = 1;
	buf[5] = x;
	SeMenu_FlushDisplayObj(buf);
}
