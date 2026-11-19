/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_5m129b.c (2026-11-19-29-p6-r46)
   sha256 2bd40e6fa30c96a12e0379872365a8e5623660135fc26e180bc9a202de57a471 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);
extern unsigned int __near ram_6a2[16];
void SeMenu_ApplyFilter(unsigned char a)
{
	unsigned char tbl[36];
	unsigned char obj;
	unsigned char *t;
	unsigned int *p;
	unsigned int v;

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
