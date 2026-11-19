/* Phase 6, lane_p6 helper L, round 1, form a: module 303 (audio/note_voice_mapping.s).
   - SndParam_FetchOscTableEntry: read-only check (SndParam_LookupReadOnly(192)), then one of two loaders.
   - FetchOscTableEntry_Prologue (misnamed; the routine after it in the same pool row): a 2-byte cell of a
     row x column table read through SOUND_TABLE_BASE; row clamped to the looked-up limit (if / else), column
     to the table's count (set 0, then override), index unsigned. */
/* cc900-module: ApplyProgramChangeAs_DoLookupRe ApplyProgramChangeAs_LoadReg ApplyProgramChangeAs_LoadReg2 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SndParam_LookupReadOnly(long);
extern void ApplyProgramChangeAs_LoadReg(unsigned char *p);
extern void ApplyProgramChangeAs_LoadReg2(unsigned char *p);
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *__near SOUND_TABLE_BASE;
extern void SndParam_FetchOscTableEntry(unsigned char *p);
extern void FetchOscTableEntry_Prologue(unsigned char *p, long off);

void SndParam_FetchOscTableEntry(unsigned char *p)
{
	if (SndParam_LookupReadOnly(192) == 1)
		ApplyProgramChangeAs_LoadReg2(p);
	else
		ApplyProgramChangeAs_LoadReg(p);
}

void FetchOscTableEntry_Prologue(unsigned char *p, long off)
{
	unsigned char lim;
	unsigned char n;
	unsigned char row;
	unsigned char col;
	unsigned char *t;
	unsigned char *e;
	unsigned int i;

	lim = ApplyProgramChangeAs_DoLookupRe();
	t = SOUND_TABLE_BASE;
	n = (unsigned char)*(long *)(t + 8);
	if (p[0] < lim)
		row = p[0];
	else
		row = 0;
	col = 0;
	if (p[1] < n)
		col = p[1];
	e = *(unsigned char **)(t + off);
	i = row * n + col;
	e += i * 2;
	p[3] = e[0];
	p[4] = e[1];
}
