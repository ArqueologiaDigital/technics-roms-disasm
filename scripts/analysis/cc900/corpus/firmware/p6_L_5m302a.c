/* Phase 6, lane_p6 helper L, round 5, form a: module 302.  Retry of CharMap_ActivePreamb_Prologue (r46 Xr +17: the
   index local went to DE through A; the ROM loads c straight into C and widens BC, with the offset in XWA).
   The index local declared first and assigned from the parameter without a cast. */
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
		return (*(unsigned char **)(SOUND_TABLE_BASE + off))[i];
	}
	if (a == 15)
		off = 0x40;
	else if (a == 20)
		off = 0x44;
	else
		return (*(unsigned char **)(SOUND_TABLE_BASE + 60))[i];
	return (*(unsigned char **)(SOUND_TABLE_BASE + off))[i];
}
