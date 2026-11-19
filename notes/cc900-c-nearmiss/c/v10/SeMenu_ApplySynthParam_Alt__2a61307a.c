/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m129b.c (2026-11-19-29-p6-r46)
   sha256 2a61307a3b3aade00bbe69defa0e93f192b4b129ffae4a0d672de2f21e3ea23b (tar-sha256); compiled at -O3 -Xr */
extern unsigned int ram_6a2[];
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_SetupPartDisplay(int part, unsigned char *t, int n);
extern void SeMenu_StorePartParam(int, int);
void SeMenu_ApplySynthParam_Alt(unsigned char a)
{
	unsigned char t[36];
	unsigned int *p;

	SeMenu_FillObjTable(t);
	SeMenu_SetupPartDisplay(a, t, 13);
	SeMenu_StorePartParam((unsigned char)(a + 7), t[13]);
	p = &ram_6a2[(unsigned char)(a - 1)];
	*p = t[15];
	*p <<= 8;
	*p = *p + t[14];
}
