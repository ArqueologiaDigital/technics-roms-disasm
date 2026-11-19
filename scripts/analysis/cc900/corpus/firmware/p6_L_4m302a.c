/* Phase 6, lane_p6 helper L, round 4, form a: module 302.  Retry of CharMap_ActivePreamb_Prologue (r43 Xr +16):
   right after the call the ROM loads c from the frame and widens it (`ld c,(xsp); extz bc`) before testing the
   result, and keeps the offset in XWA: the result goes to a local, then the index local i = c, then the test. */
/* (no module-local callee) */

extern int SndParam_LookupReadOnly(long);
extern unsigned char *__near SOUND_TABLE_BASE;
extern unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c);

unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c)
{
	unsigned int i;
	long off;
	int r;

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
