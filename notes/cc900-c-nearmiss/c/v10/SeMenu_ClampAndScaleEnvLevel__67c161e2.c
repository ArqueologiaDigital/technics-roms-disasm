/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m129a.c (2026-11-19-15-p6-r42)
   sha256 67c161e25dfdbf9eb6d31ace3b1df1a2d2c1933e524fb9780054924a984863ac (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadRawAddr(unsigned char *k);
extern void SeMenu_LoadPartParam(int, char *);
void SeMenu_ClampAndScaleEnvLevel(char *p)
{
	char s;
	unsigned char k;
	int v;

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
		v = v * s;
	else {
		s = -s;
		v = -(v * s);
	}
	*p = v / 50;
}
