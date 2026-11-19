/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m129b.c (2026-11-19-19-p6-r43)
   sha256 05eab641a49b94cbe9543ba9df5f9edc0142e82f6426827404acf0d7e38a33c5 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SDO_Alt2_Cont21=SeMenu_SetupDisplayObject_Alt2_Continue_0x21 */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_SDO_Alt2_Cont21(unsigned char a)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *e;
	unsigned char *p;

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
