/* Phase 6, lane_p6 helper D, round 16, module 129 (v10 audio/semenu_routines.s), form b: SeMenu_SetPartEnabled
   (see p6_D_16m129.c) with the shift count as part * 2 - 2 and the mask kept in the call's result. */
/* cc900-module: SeMenu_BitShiftMask SeMenu_LoadObjEntries SeMenu_RegisterElement_Extended SeMenu_SetupDisplayObject_Alt1 */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadObjEntries(unsigned char *);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_SetupDisplayObject_Alt1(int, int, unsigned char *, unsigned int);

extern unsigned char __near SEMENU_PART_MASK;

void SeMenu_SetPartEnabled(unsigned char part, unsigned char on)
{
	unsigned char v;
	unsigned char obj;
	unsigned char m;
	unsigned char n;

	if (part >= 1 && part <= 4) {
		SeMenu_LoadObjEntries(&obj);
		n = part * 2 - 2;
		m = SeMenu_BitShiftMask(1, n);
		if (on == 0) SEMENU_PART_MASK &= ~m;
		else SEMENU_PART_MASK |= m;
		v = SEMENU_PART_MASK;
		if (obj == 0) SeMenu_RegisterElement_Extended(0, 17, &v, m);
		else SeMenu_SetupDisplayObject_Alt1(0, 13, &v, m);
	}
}
