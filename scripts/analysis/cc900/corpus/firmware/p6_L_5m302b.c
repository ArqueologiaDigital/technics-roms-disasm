/* Phase 6, lane_p6 helper L, round 5, form b: module 302, CharMap_ActivePreamb_Prologue with the index a long
   (the ROM widens it to XBC before adding it to the table pointer) and the offset declared before it. */
/* (no module-local callee) */

extern int SndParam_LookupReadOnly(long);
extern unsigned char *__near SOUND_TABLE_BASE;
extern unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c);

unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c)
{
	long off;
	unsigned long i;
	int r;

	r = SndParam_LookupReadOnly(192);
	i = (unsigned int)c;
	if (r == 1) {
		off = 0x48;
		if (a == 15)
			off = 0x4c;
		return *(*(unsigned char **)(SOUND_TABLE_BASE + off) + i);
	}
	if (a == 15)
		off = 0x40;
	else if (a == 20)
		off = 0x44;
	else
		return *(*(unsigned char **)(SOUND_TABLE_BASE + 60) + i);
	return *(*(unsigned char **)(SOUND_TABLE_BASE + off) + i);
}
