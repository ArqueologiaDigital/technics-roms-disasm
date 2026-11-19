/* Phase 6, lane_p6 helper L, round 2, form a: module 302 (audio/note_voice_mapping.s).
   - CharMap_ActivePreamb_Prologue: byte c of one of the sound table's byte arrays, chosen by the read-only state
     (SndParam_LookupReadOnly(192) == 1: +0x4c for kind 15, else +0x48) or by kind a (15: +0x40, 20: +0x44,
     else +60, which the ROM folds into the displacement).  Both parameters stay in the frame (-Xr). */
/* (no module-local callee) */

extern int SndParam_LookupReadOnly(long);
extern unsigned char *__near SOUND_TABLE_BASE;
extern unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c);

unsigned char CharMap_ActivePreamb_Prologue(unsigned char a, unsigned char c)
{
	long off;

	if (SndParam_LookupReadOnly(192) == 1) {
		off = 0x48;
		if (a == 15)
			off = 0x4c;
		return (*(unsigned char **)(SOUND_TABLE_BASE + off))[c];
	}
	if (a == 15)
		off = 0x40;
	else if (a == 20)
		off = 0x44;
	else
		return (*(unsigned char **)(SOUND_TABLE_BASE + 60))[c];
	return (*(unsigned char **)(SOUND_TABLE_BASE + off))[c];
}
