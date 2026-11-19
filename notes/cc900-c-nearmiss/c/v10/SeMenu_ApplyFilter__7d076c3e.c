/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_2m129a.c (2026-11-19-15-p6-r42)
   sha256 7d076c3ef01880ed23af881502d912aa8d9ee6d6d20a24a228fe604e2318f98c (tar-sha256); compiled at -O3 -Xr */
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

	SeMenu_LoadObjEntries(&obj);
	SeMenu_FillObjTable(tbl);
	if (obj == 0) {
		SeMenu_StorePartParam((unsigned char)(a + 13), tbl[13]);
		SeMenu_SetupPartDisplay(a, tbl, 13);
	} else {
		SeMenu_StorePartParam((unsigned char)(a + 14), tbl[13]);
		SeMenu_SetupPartDisplay((unsigned char)(a + 1), tbl, 13);
	}
	p = &ram_6a2[(unsigned char)(a - 1)];
	t = tbl;
	*p = t[15];
	*p <<= 8;
	*p += t[14];
}
