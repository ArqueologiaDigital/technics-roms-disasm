/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m129b.c (2026-11-19-19-p6-r43)
   sha256 05eab641a49b94cbe9543ba9df5f9edc0142e82f6426827404acf0d7e38a33c5 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_InitDisplayField(unsigned char a, unsigned char c)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char obj;
	unsigned char *e;
	unsigned char *p;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	buf[0] = 0x80;
	buf[1] = m;
	if (obj == 0)
		buf[2] = 0x09;
	else
		buf[2] = 0x12;
	buf[3] = a - 1;
	buf[4] = 1;
	buf[5] = c;
	SeMenu_FlushDisplayObj(buf);
}
