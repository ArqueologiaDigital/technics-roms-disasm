/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_5m129a.c (2026-11-19-29-p6-r46)
   sha256 389457504fba0a401262341469b7485069996a6065a58d803262bbc56e1c776b (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);
extern unsigned int __near ram_6a2[16];
void SeMenu_ApplyFilter(unsigned char a)
{
	unsigned char tbl[36];
	unsigned char obj;
	unsigned int v;
	unsigned char *t;
	unsigned int *p;

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
	v = t[15];
	*p = v;
	v <<= 8;
	*p = v;
	v += t[14];
	*p = v;
}
