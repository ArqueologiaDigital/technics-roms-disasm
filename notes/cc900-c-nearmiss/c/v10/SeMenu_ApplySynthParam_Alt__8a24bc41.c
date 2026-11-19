/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_5m129a.c (2026-11-19-37-p6-r47)
   sha256 8a24bc41f36cb713a7875d4a5bf11f7fcaf2871b14af7a30953cc80ec5a689b6 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_6a2[8];
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_SetupPartDisplay(int part, unsigned char *t, int n);
extern void SeMenu_StorePartParam(int, int);
void SeMenu_ApplySynthParam_Alt(unsigned char a)
{
	unsigned char t[36];
	unsigned int *p;
	unsigned int w;

	SeMenu_FillObjTable(t);
	SeMenu_SetupPartDisplay(a, t, 13);
	SeMenu_StorePartParam((unsigned char)(a + 7), t[13]);
	p = &ram_6a2[(unsigned char)(a - 1)];
	w = t[15];
	*p = w;
	w <<= 8;
	*p = w;
	w += t[14];
	*p = w;
}
