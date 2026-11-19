/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m129a.c (2026-11-19-22-p6-r45)
   sha256 4c1ba6c642d242a6e1bf5def919c619a896f1bad4ce3b2dcd20a47ea8a009ff6 (tar-sha256); compiled at -O3 -Xr */
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
		v *= s;
	else {
		v *= (s = -s);
		v = -v;
	}
	*p = v / 50;
}
