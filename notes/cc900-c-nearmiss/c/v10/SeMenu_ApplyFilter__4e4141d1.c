/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_4m129c.c (2026-11-19-21-p6-r44)
   sha256 4e4141d125c6d81f571a91e9bb90bbe081bc8c4c7349faf5e3841f87c4bde0e6 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);
extern unsigned int __near ram_6a2[];
void SeMenu_ApplyFilter(unsigned char a)
{
	unsigned char tbl[36];
	unsigned char obj;
	unsigned int *p;
	unsigned char *t;
	unsigned int v;
	int k;

	SeMenu_LoadObjEntries(&obj);
	SeMenu_FillObjTable(tbl);
	if (obj == 0) {
		SeMenu_StorePartParam((unsigned char)(a + 13), tbl[13]);
		SeMenu_SetupPartDisplay(a, tbl, 13);
	} else {
		SeMenu_StorePartParam((unsigned char)(a + 14), tbl[13]);
		SeMenu_SetupPartDisplay((unsigned char)(a + 1), tbl, 13);
	}
	k = (unsigned char)(a - 1);
	p = &ram_6a2[k];
	t = tbl;
	v = t[15];
	*p = v;
	v <<= 8;
	*p = v;
	v += t[14];
	*p = v;
}
