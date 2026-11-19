/* Phase 6, lane_p6 helper L, round 6, form a: module 129.  Retry of SeMenu_ApplySynthParam_Alt (r47 O3Xr +56: the
   word now in a register; only the register choice differs: ROM pointer XDE, table base XHL, word BC; V4.23
   XHL / XBC / DE).  The element written through the array three times (no pointer local), word declared first. */
/* cc900-module: SeMenu_FillObjTable SeMenu_SetupPartDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_6a2[8];
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_SetupPartDisplay(int part, unsigned char *t, int n);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_ApplySynthParam_Alt(unsigned char a);

void SeMenu_ApplySynthParam_Alt(unsigned char a)
{
	unsigned int w;
	unsigned char t[36];

	SeMenu_FillObjTable(t);
	SeMenu_SetupPartDisplay(a, t, 13);
	SeMenu_StorePartParam((unsigned char)(a + 7), t[13]);
	w = t[15];
	ram_6a2[(unsigned char)(a - 1)] = w;
	w <<= 8;
	ram_6a2[(unsigned char)(a - 1)] = w;
	w += t[14];
	ram_6a2[(unsigned char)(a - 1)] = w;
}
