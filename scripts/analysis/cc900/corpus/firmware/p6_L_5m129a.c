/* Phase 6, lane_p6 helper L, round 5, form a: module 129.  Retry of SeMenu_ApplySynthParam_Alt (r46 O3Xr +58: the
   index now matches; the ROM then builds the word in BC, storing it after each step, with the table base in
   XHL; V4.23 added t[14] to memory).  The word in a local, stored three times. */
/* cc900-module: SeMenu_FillObjTable SeMenu_SetupPartDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_6a2[8];
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_SetupPartDisplay(int part, unsigned char *t, int n);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_ApplySynthParam_Alt(unsigned char a);

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
