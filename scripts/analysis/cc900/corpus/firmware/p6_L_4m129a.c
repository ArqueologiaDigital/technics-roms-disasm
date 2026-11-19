/* Phase 6, lane_p6 helper L, round 4, form a: module 129.  Retry of SeMenu_ApplySynthParam_Alt (r43 O3Xr +52):
   the ROM indexes the word array with the 16-bit index register (`lda xde,(xbc+wa)`) where V4.23 widened it
   (extz, add): the array is SIZED (round-2 idiom "subscript a sized array").  The final add is done in the
   register and stored (`*p = *p + t[14]`). */
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

	SeMenu_FillObjTable(t);
	SeMenu_SetupPartDisplay(a, t, 13);
	SeMenu_StorePartParam((unsigned char)(a + 7), t[13]);
	p = &ram_6a2[(unsigned char)(a - 1)];
	*p = t[15];
	*p <<= 8;
	*p = *p + t[14];
}
