/* Phase 6, lane_p6 helper L, round 2, form a: module 129 (audio/semenu_routines.s).
   - SeMenu_ApplySynthParam_Alt: fill a 36-byte object table, set up part a's display (13), store byte 13 as part
     parameter a + 7, and build the word (byte 15 << 8) + byte 14 in the __near word array at 1698 (index a - 1),
     storing after each step as the ROM does.  The callers' char arguments go as ints (int prototypes). */
/* cc900-module: SeMenu_FillObjTable SeMenu_SetupPartDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_6a2[];
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
	*p += t[14];
}
