/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m129c.c (2026-11-19-19-p6-r43)
   sha256 c5ed0d0d63dba14906e2745f300fcb14b8e5f23939f13687b96e210030aab2c1 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SDO_Alt2_Cont21=SeMenu_SetupDisplayObject_Alt2_Continue_0x21 */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_SDO_Alt2_Cont21(unsigned char a)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *p;
	unsigned char *e;

	e = buf + 9;
	p = buf;
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
