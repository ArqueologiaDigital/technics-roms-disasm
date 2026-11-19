/* Phase 6, lane_p6 helper L, round 4, form b: module 129, SeMenu_ApplySynthParam_Alt with a plain (24-bit) word
   array, whose char index V4.23 reads as `lda XBC,_a` + (XBC+WA) (BRIEF2's declaration note). */
/* cc900-module: SeMenu_FillObjTable SeMenu_SetupPartDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int ram_6a2[];
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_SetupPartDisplay(int part, unsigned char *t, int n);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_ApplySynthParam_Alt(unsigned char a);

void SeMenu_ApplySynthParam_Alt(unsigned char a)
{
	unsigned char t[36];
	unsigned int *p;

	SeMenu_FillObjTable(t);
	SeMenu_SetupPartDisplay(a, t, 13);
	SeMenu_StorePartParam((unsigned char)(a + 7), t[13]);
	p = &ram_6a2[(unsigned char)(a - 1)];
	*p = t[15];
	*p <<= 8;
	*p = *p + t[14];
}
