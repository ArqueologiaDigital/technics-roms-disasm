/* Phase 6, lane_p6 helper M, round 5, module 129, form a: SeMenu_ApplyFilter (run r44: 4m129a/b, the sized array
   fixed the cell address; what is left is the register choice of the last block: the ROM has the cell pointer in
   XDE, the table pointer in XHL and the word in BC; 4m129a gave XHL / XBC / DE).  This form: the three locals
   declared in reverse (v, t, p). */
/* cc900-module: SeMenu_FillObjTable SeMenu_LoadObjEntries SeMenu_SetupPartDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);
extern unsigned int __near ram_6a2[16];
extern void SeMenu_ApplyFilter(unsigned char a);

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
