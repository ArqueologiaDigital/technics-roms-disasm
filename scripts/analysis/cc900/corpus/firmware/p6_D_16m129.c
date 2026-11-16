/* Phase 6, lane_p6 helper D, round 16, module 129 (v10 audio/semenu_routines.s), form a (poolmm_D):
   SeMenu_SetPartEnabled -- for part 1..4 sets or clears the part's bit (2 * (part - 1)) in SEMENU_PART_MASK, then
   registers the new mask (a stack copy, moved from the __near cell) with the display object.  The ROM keeps both
   arguments in the frame (no -O).  Form b (p6_D_16m129b.c) computes the shift as part * 2 - 2 into a local. */
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

	if (part < 1 || part > 4) return;
	SeMenu_LoadObjEntries(&obj);
	m = SeMenu_BitShiftMask(1, (unsigned char)(part + part - 2));
	if (on == 0) SEMENU_PART_MASK &= ~m;
	else SEMENU_PART_MASK |= m;
	v = SEMENU_PART_MASK;
	if (obj == 0) SeMenu_RegisterElement_Extended(0, 17, &v, m);
	else SeMenu_SetupDisplayObject_Alt1(0, 13, &v, m);
}
