/* Phase 6, lane_p6 helper M, round 4, module 129, form a: SeMenu_ApplyFilter retry (run r42: +91 @O3Xr).
   Two spots: (1) the cell address: the ROM's `lda xbc,ram_6a2; lda xde,(xbc+wa)` where V4.23 wrote extz/add --
   the array declared with a size (subscripting a sized array gives the (xR+wa) form); (2) the word rebuilt in a
   register (BC) and stored after each step, the last step `add bc,wa` + store instead of `add (xde),wa`: the value
   kept in a local v. */
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
	unsigned int *p;
	unsigned char *t;
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
