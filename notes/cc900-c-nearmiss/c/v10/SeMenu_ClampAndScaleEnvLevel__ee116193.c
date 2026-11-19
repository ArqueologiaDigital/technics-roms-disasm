/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m129b.c (2026-11-19-22-p6-r45)
   sha256 ee11619358472f85092083e40428b77da248841196009564d822d0d13ccfa59d (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadRawAddr(unsigned char *k);
extern void SeMenu_LoadPartParam(int, char *);
void SeMenu_ClampAndScaleEnvLevel(char *p)
{
	char s;
	unsigned char k;
	int v;
	char t;

	SeMenu_LoadRawAddr(&k);
	if (*p > 50)
		*p = 50;
	if (*p < -50)
		*p = -50;
	SeMenu_LoadPartParam(1, &s);
	v = *p;
	if (k == 55)
		return;
	if (s >= 0)
		v *= s;
	else {
		t = -s;
		s = t;
		v *= t;
		v = -v;
	}
	*p = v / 50;
}
