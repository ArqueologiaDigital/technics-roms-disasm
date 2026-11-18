/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_5m129a.c (2026-11-18-33-p6-r37)
   sha256 aee4a5a1ed233427f094ed775506e2b4f7ad8d80bb13bc50a0a30760c59e4e2b (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
void SeMenu_SetupDisplayObject_Alt1(unsigned char kind, unsigned char v, unsigned char *val, unsigned char x)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *p;
	unsigned char *q;
	unsigned char t;

	for (p = buf; p < buf + 9; )
		*p++ = 0;
	SeMenu_LoadMasterPtr(&m);
	q = &buf[2];
	*q = v;
	if (kind == 0)
		buf[0] = 0x8e;
	else if (kind == 1)
		buf[0] = 0x8f;
	else if (kind == 2) {
		buf[0] = 0x8f;
		t = *q;
		t |= 0x40;
		*q = t;
	} else
		buf[0] = 0x8d;
	buf[1] = m;
	buf[3] = 1;
	buf[4] = *val;
	buf[5] = x;
	SeMenu_FlushDisplayObj(buf);
}
