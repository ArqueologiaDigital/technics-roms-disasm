/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m129a.c (2026-11-19-19-p6-r43)
   sha256 1e90641202ee003c3a2b9a87648ea887d0a8fa2f2ba9bade4c0a3429ee8e8870 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_6a2[];
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
	*p += t[14];
}
