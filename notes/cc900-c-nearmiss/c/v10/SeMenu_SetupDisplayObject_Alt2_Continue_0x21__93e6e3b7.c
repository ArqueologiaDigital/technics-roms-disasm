/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m129a.c (2026-11-19-19-p6-r43)
   sha256 93e6e3b7d95dc8f02038d846bb37f2eb30d47216b970e6b67e4693687108e544 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SDO_Alt2_Cont21=SeMenu_SetupDisplayObject_Alt2_Continue_0x21 */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_SDO_Alt2_Cont21(unsigned char a)
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
	buf[0] = 0x88;
	buf[1] = m;
	buf[2] = 0;
	buf[3] = 0;
	buf[4] = a;
	buf[5] = 0;
	SeMenu_FlushDisplayObj(buf);
}
