/* Phase 6, lane_p6 helper L, round 6, form a: module 302.  Retry of CharMap_ActivePreamb_Prologue.  The ROM widens
   the index into XBC (extz xbc) and then ADDS the table pointer to it (`add xbc,(xde)`, `add xbc,(xwa+60)`): the
   index on the left of a pointer addition, `*(i + ptr)`.  The index an unsigned int local assigned after the
   call (Xr: no hoisting). */
/* (no module-local callee) */

extern int SndParam_LookupReadOnly(long);
extern unsigned char *__near SOUND_TABLE_BASE;
extern unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c);

unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c)
{
	unsigned int i;
	int r;
	long off;

	r = SndParam_LookupReadOnly(192);
	i = c;
	if (r == 1) {
		off = 0x48;
		if (a == 15)
			off = 0x4c;
		return *(i + *(unsigned char **)(SOUND_TABLE_BASE + off));
	}
	if (a == 15)
		off = 0x40;
	else if (a == 20)
		off = 0x44;
	else
		return *(i + *(unsigned char **)(SOUND_TABLE_BASE + 60));
	return *(i + *(unsigned char **)(SOUND_TABLE_BASE + off));
}
