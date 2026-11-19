/* lane_p6 helper N, round 7, form a: module 303 (audio/note_voice_mapping.s), new functions.
   - SndParam_ApplyProgramChange: in GM mode (sound parameter 0xc0 = 1) the GM oscillator lookup, else the
     normal one.
   - ApplyProgramChangeAs_DoLookupRe: the program-change bank byte: 0x89 / 0x80 in GM mode (part 15 or not),
     else the low byte of the sound table's long at +4.  One return at the end (the ROM's `jr Return`).
   - ApplyProgramChangeAs_LoadDRAM2: the 2-word sound entry {p[3], p[4]} of the table at sound-table offset off:
     table + 0x80 + table[p[4]] * m + p[3] * 4 -> p[0], p[1].
   cc900-options: -O3 -Xr
*/
/* cc900-module: FetchOscTableEntry_LoadReg FetchOscTableEntry_LoadReg2 */

struct sndtab { long a0; long a4; };
extern struct sndtab *__near SOUND_TABLE_BASE;
extern int SndParam_LookupReadOnly(long);
extern unsigned char GetCurrentPartSelect(void);
extern void FetchOscTableEntry_LoadReg(unsigned char *);
extern void FetchOscTableEntry_LoadReg2(unsigned char *);

void SndParam_ApplyProgramChange(unsigned char *p)
{
	if (SndParam_LookupReadOnly(0xc0L) == 1)
		FetchOscTableEntry_LoadReg2(p);
	else
		FetchOscTableEntry_LoadReg(p);
}

unsigned char ApplyProgramChangeAs_DoLookupRe(void)
{
	unsigned char r;

	if (SndParam_LookupReadOnly(0xc0L) == 1) {
		if (GetCurrentPartSelect() != 15)
			r = 0x80;
		else
			r = 0x89;
	} else
		r = SOUND_TABLE_BASE->a4;
	return r;
}

void ApplyProgramChangeAs_LoadDRAM2(unsigned char *p, long off, unsigned int m)
{
	unsigned char *t;
	unsigned int *w;

	t = *(unsigned char **)((unsigned char *)SOUND_TABLE_BASE + off);
	w = (unsigned int *)(t + 0x80 + (unsigned long)t[p[4]] * m + ((unsigned int)p[3] << 2));
	p[0] = w[0];
	p[1] = w[1];
}
