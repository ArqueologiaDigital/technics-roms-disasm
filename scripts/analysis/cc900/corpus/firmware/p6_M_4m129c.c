/* Phase 6, lane_p6 helper M, round 4, module 129, form c: SeMenu_ApplyFilter retry (alternative to p6_M_4m129a.c).
   The cell index in an int local k (16-bit index form), the array unsized; the value in a local v as in form a. */
/* cc900-module: SeMenu_FillObjTable SeMenu_LoadObjEntries SeMenu_SetupPartDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);
extern unsigned int __near ram_6a2[];
extern void SeMenu_ApplyFilter(unsigned char a);

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
